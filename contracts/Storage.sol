// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title Storage
/// @notice Simple store/retrieve uint256 — matches the Pharos Skill Engine example
/// @dev Minimal contract for deployment proof
contract Storage {
    // --- Errors ---
    error Storage__NotOwner();

    // --- Events ---
    event Stored(address indexed caller, uint256 oldValue, uint256 newValue);

    // --- State ---
    uint256 private s_value;
    address private immutable i_owner;

    // --- Constructor ---
    constructor() {
        i_owner = msg.sender;
    }

    // --- Modifiers ---
    modifier onlyOwner() {
        if (msg.sender != i_owner) revert Storage__NotOwner();
        _;
    }

    // --- Public Functions ---

    /// @notice Store a new value
    /// @param _value The value to store
    function store(uint256 _value) external onlyOwner {
        uint256 old = s_value;
        s_value = _value;
        emit Stored(msg.sender, old, _value);
    }

    // --- View Functions ---

    /// @notice Retrieve the stored value
    /// @return The current stored value
    function retrieve() external view returns (uint256) {
        return s_value;
    }

    /// @notice Get the contract owner
    function owner() external view returns (address) {
        return i_owner;
    }
}
