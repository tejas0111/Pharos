// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title Demo
/// @notice Simple demo contract for Pharos Atlantic Testnet deployment proof
/// @dev Stores a greeting message — minimal, auditable, easy to verify on explorer
contract Demo {
    // --- Errors ---
    error Demo__EmptyGreeting();
    error Demo__NotOwner();

    // --- Events ---
    event GreetingUpdated(address indexed updater, string oldGreeting, string newGreeting);

    // --- State ---
    string private s_greeting;
    address private immutable i_owner;

    // --- Constructor ---
    constructor(string memory _greeting) {
        if (bytes(_greeting).length == 0) revert Demo__EmptyGreeting();
        i_owner = msg.sender;
        s_greeting = _greeting;
    }

    // --- Modifiers ---
    modifier onlyOwner() {
        if (msg.sender != i_owner) revert Demo__NotOwner();
        _;
    }

    // --- Public Functions ---

    /// @notice Update the greeting
    /// @param _newGreeting New greeting string
    function setGreeting(string calldata _newGreeting) external onlyOwner {
        if (bytes(_newGreeting).length == 0) revert Demo__EmptyGreeting();
        string memory old = s_greeting;
        s_greeting = _newGreeting;
        emit GreetingUpdated(msg.sender, old, _newGreeting);
    }

    // --- View Functions ---

    /// @notice Get the current greeting
    function greeting() external view returns (string memory) {
        return s_greeting;
    }

    /// @notice Get the contract owner
    function owner() external view returns (address) {
        return i_owner;
    }
}
