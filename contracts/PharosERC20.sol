// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title PharosERC20
/// @notice Standard ERC-20 token for Pharos testnet deployment example
/// @dev Inline implementation — no external dependency required
contract PharosERC20 {
    // --- Errors ---
    error PharosERC20__InvalidTransfer();
    error PharosERC20__InvalidApproval();
    error PharosERC20__InsufficientBalance();
    error PharosERC20__InsufficientAllowance();
    error PharosERC20__ZeroAddress();
    error PharosERC20__NotOwner();
    error PharosERC20__InvalidInput();
    error PharosERC20__MaxSupplyExceeded();
    error PharosERC20__PermitExpired();
    error PharosERC20__InvalidSignature();

    // --- Events ---
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // --- State ---
    address private immutable i_owner;
    string private s_name;
    string private s_symbol;
    uint8 private s_decimals;
    uint256 private s_totalSupply;
    mapping(address => uint256) private s_balances;
    mapping(address => mapping(address => uint256)) private s_allowances;
    mapping(address => uint256) private s_nonces;
    bytes32 private immutable i_domainSeparator;

    // --- Modifiers ---
    modifier onlyOwner() {
        if (msg.sender != i_owner) revert PharosERC20__NotOwner();
        _;
    }

    // --- Constructor ---
    constructor(string memory _name, string memory _symbol, uint256 _initialSupply) {
        if (bytes(_name).length == 0) revert PharosERC20__InvalidInput();
        if (bytes(_symbol).length == 0) revert PharosERC20__InvalidInput();
        i_owner = msg.sender;
        s_name = _name;
        s_symbol = _symbol;
        s_decimals = 18;
        s_totalSupply = _initialSupply;
        s_balances[msg.sender] = _initialSupply;
        i_domainSeparator = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(_name)),
                keccak256(bytes("1")),
                block.chainid,
                address(this)
            )
        );
        emit Transfer(address(0), msg.sender, _initialSupply);
    }

    // --- ERC-20 Standard ---
    function name() external view returns (string memory) {
        return s_name;
    }

    function symbol() external view returns (string memory) {
        return s_symbol;
    }

    function decimals() external view returns (uint8) {
        return s_decimals;
    }

    function totalSupply() external view returns (uint256) {
        return s_totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return s_balances[account];
    }

    function transfer(address to, uint256 value) external returns (bool) {
        if (to == address(0)) revert PharosERC20__ZeroAddress();
        if (s_balances[msg.sender] < value) revert PharosERC20__InsufficientBalance();
        s_balances[msg.sender] -= value;
        s_balances[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function allowance(address _owner, address spender) external view returns (uint256) {
        return s_allowances[_owner][spender];
    }

    function approve(address spender, uint256 value) external returns (bool) {
        if (spender == address(0)) revert PharosERC20__ZeroAddress();
        s_allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        if (to == address(0)) revert PharosERC20__ZeroAddress();
        if (s_balances[from] < value) revert PharosERC20__InsufficientBalance();
        if (s_allowances[from][msg.sender] < value) revert PharosERC20__InsufficientAllowance();
        s_balances[from] -= value;
        s_balances[to] += value;
        s_allowances[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true;
    }

    // --- Owner ---
    function owner() external view returns (address) {
        return i_owner;
    }

    uint256 public constant MAX_SUPPLY = 1_000_000_000e18; // 1 billion

    // --- Mint (owner only) ---
    function mint(address to, uint256 value) external onlyOwner {
        if (to == address(0)) revert PharosERC20__ZeroAddress();
        if (s_totalSupply + value > MAX_SUPPLY) revert PharosERC20__MaxSupplyExceeded();
        s_totalSupply += value;
        s_balances[to] += value;
        emit Transfer(address(0), to, value);
    }

    // --- Burn ---
    function burn(address from, uint256 value) external onlyOwner {
        if (from == address(0)) revert PharosERC20__ZeroAddress();
        if (s_balances[from] < value) revert PharosERC20__InsufficientBalance();
        s_balances[from] -= value;
        s_totalSupply -= value;
        emit Transfer(from, address(0), value);
    }

    // --- EIP-2612 Permit ---
    function nonces(address owner_) external view returns (uint256) {
        return s_nonces[owner_];
    }

    function DOMAIN_SEPARATOR() external view returns (bytes32) {
        return i_domainSeparator;
    }

    function permit(address owner_, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s)
        external
    {
        if (deadline < block.timestamp) revert PharosERC20__PermitExpired();
        bytes32 structHash = keccak256(
            abi.encode(
                keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"),
                owner_,
                spender,
                value,
                s_nonces[owner_]++,
                deadline
            )
        );
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", i_domainSeparator, structHash));
        address recovered = ecrecover(digest, v, r, s);
        if (recovered == address(0) || recovered != owner_) revert PharosERC20__InvalidSignature();
        s_allowances[owner_][spender] = value;
        emit Approval(owner_, spender, value);
    }
}
