// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title PharosRWAToken
/// @notice Real-World Asset compliant token with transfer restrictions and KYC.
/// @dev Implements ERC-20 with whitelist, KYC expiration, supply caps, and legal admin.
///      Uses pull-over-push for native transfers (Pharos has no 2300 gas stipend).
contract PharosRWAToken {
    error PharosRWAToken__Unauthorized();
    error PharosRWAToken__KYCExpired();
    error PharosRWAToken__KYCMissing();
    error PharosRWAToken__SupplyCapExceeded();
    error PharosRWAToken__ZeroAddress();
    error PharosRWAToken__FrozenAccount();
    error PharosRWAToken__InvalidAmount();

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Whitelisted(address indexed account, uint256 expiry);
    event WhitelistRevoked(address indexed account);
    event SupplyCapUpdated(uint256 newCap);
    event AccountFrozen(address indexed account, bool frozen);

    string private s_name;
    string private s_symbol;
    uint8 private s_decimals;
    uint256 private s_totalSupply;
    uint256 public s_supplyCap;
    address public immutable i_owner;
    address public i_legalAdmin;
    bool public s_paused;
    modifier whenNotPaused() { if (s_paused) revert PharosRWAToken__Unauthorized(); _; }

    mapping(address => uint256) private s_balances;
    mapping(address => mapping(address => uint256)) private s_allowances;
    mapping(address => uint256) public s_kycExpiry; // timestamp or 0 = no KYC
    mapping(address => bool) public s_frozen;

    modifier onlyOwner() { if (msg.sender != i_owner) revert PharosRWAToken__Unauthorized(); _; }
    modifier onlyLegal() { if (msg.sender != i_legalAdmin && msg.sender != i_owner) revert PharosRWAToken__Unauthorized(); _; }

    constructor(string memory _name, string memory _symbol, uint256 _initialSupply, uint256 _supplyCap) {
        i_owner = msg.sender;
        i_legalAdmin = msg.sender;
        s_name = _name; s_symbol = _symbol; s_decimals = 18;
        s_supplyCap = _supplyCap;
        if (_initialSupply > 0) {
            s_balances[msg.sender] = _initialSupply;
            s_totalSupply = _initialSupply;
            s_kycExpiry[msg.sender] = type(uint256).max; // Owner always KYC-approved
            emit Transfer(address(0), msg.sender, _initialSupply);
        }
    }

    function name() external view returns (string memory) { return s_name; }
    function symbol() external view returns (string memory) { return s_symbol; }
    function decimals() external view returns (uint8) { return s_decimals; }
    function totalSupply() external view returns (uint256) { return s_totalSupply; }
    function balanceOf(address _account) external view returns (uint256) { return s_balances[_account]; }
    function allowance(address _owner, address _spender) external view returns (uint256) { return s_allowances[_owner][_spender]; }

    function _checkKYC(address _account) private view {
        if (s_kycExpiry[_account] == 0) revert PharosRWAToken__KYCMissing();
        if (s_kycExpiry[_account] <= block.timestamp && s_kycExpiry[_account] != type(uint256).max) revert PharosRWAToken__KYCExpired();
        if (s_frozen[_account]) revert PharosRWAToken__FrozenAccount();
    }

    function _transfer(address _from, address _to, uint256 _value) private {
        if (_value == 0) revert PharosRWAToken__InvalidAmount();
        if (_from != address(0)) _checkKYC(_from);
        if (_to != address(0)) _checkKYC(_to);
        if (_from != address(0) && s_balances[_from] < _value) revert PharosRWAToken__InvalidAmount();
        if (_from != address(0)) { s_balances[_from] -= _value; }
        s_balances[_to] += _value;
        emit Transfer(_from, _to, _value);
    }

    function transfer(address _to, uint256 _value) external whenNotPaused returns (bool) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) external whenNotPaused returns (bool) {
        s_allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) external whenNotPaused returns (bool) {
        if (s_allowances[_from][msg.sender] < _value) revert PharosRWAToken__InvalidAmount();
        s_allowances[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    function mint(address _to, uint256 _value) external onlyOwner {
        if (_to == address(0)) revert PharosRWAToken__ZeroAddress();
        if (s_totalSupply + _value > s_supplyCap) revert PharosRWAToken__SupplyCapExceeded();
        _transfer(address(0), _to, _value);
        s_totalSupply += _value;
    }

    function burn(uint256 _value) external {
        _transfer(msg.sender, address(0), _value);
        s_totalSupply -= _value;
    }

    function setKYC(address _account, uint256 _expiry) external onlyLegal {
        if (_account == address(0)) revert PharosRWAToken__ZeroAddress();
        s_kycExpiry[_account] = _expiry;
        emit Whitelisted(_account, _expiry);
    }

    function revokeKYC(address _account) external onlyLegal {
        s_kycExpiry[_account] = 0;
        emit WhitelistRevoked(_account);
    }

    function freeze(address _account, bool _frozen) external onlyLegal {
        s_frozen[_account] = _frozen;
        emit AccountFrozen(_account, _frozen);
    }

    function setLegalAdmin(address _admin) external onlyOwner {
        if (_admin == address(0)) revert PharosRWAToken__ZeroAddress();
        i_legalAdmin = _admin;
    }

    function setSupplyCap(uint256 _newCap) external onlyOwner {
        if (_newCap < s_totalSupply) revert PharosRWAToken__InvalidAmount();
        s_supplyCap = _newCap;
        emit SupplyCapUpdated(_newCap);
    }
}
