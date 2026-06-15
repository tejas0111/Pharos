// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title Counter
/// @notice A simple counter contract — part of the Pharos example dapp
/// @dev Demonstrates basic Solidity patterns: events, state, access control
contract Counter {
    // --- Errors ---
    error Counter__NotOwner();
    error Counter__CannotDecrementBelowZero();

    // --- Events ---
    event CounterIncremented(address indexed caller, uint256 newValue);
    event CounterDecremented(address indexed caller, uint256 newValue);
    event CounterReset(address indexed caller);

    // --- State ---
    uint256 private s_count;
    address private immutable i_owner;

    // --- Constructor ---
    constructor() {
        i_owner = msg.sender;
    }

    // --- Modifiers ---
    modifier onlyOwner() {
        if (msg.sender != i_owner) revert Counter__NotOwner();
        _;
    }

    // --- Public Functions ---

    /// @notice Increment the counter by 1
    function increment() external {
        s_count++;
        emit CounterIncremented(msg.sender, s_count);
    }

    /// @notice Decrement the counter by 1
    /// @dev Reverts if counter is 0
    function decrement() external {
        if (s_count == 0) revert Counter__CannotDecrementBelowZero();
        s_count--;
        emit CounterDecremented(msg.sender, s_count);
    }

    /// @notice Reset the counter to 0
    /// @dev Only the contract owner can reset
    function reset() external onlyOwner {
        s_count = 0;
        emit CounterReset(msg.sender);
    }

    // --- View Functions ---

    /// @notice Get the current count
    function getCount() external view returns (uint256) {
        return s_count;
    }

    /// @notice Get the contract owner
    function getOwner() external view returns (address) {
        return i_owner;
    }
}
