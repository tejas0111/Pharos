# SPN Sponsored Transactions

## Overview

Pharos's SPN (Sponsored Transaction Network) enables **gasless transactions** for end users by having dApps cover gas fees. This subskill covers deploying and configuring a Paymaster contract that implements the ERC-4337 `IPaymaster` interface.

## Key Concepts

- **Paymaster**: A contract that pays gas fees on behalf of users. Implements `validatePaymasterUserOp` and `postOp`.
- **EntryPoint**: The ERC-4337 singleton contract that coordinates UserOperation validation and execution.
- **UserOperation**: A pseudo-transaction object representing a user's intent to execute a contract call.
- **Sponsorship**: The act of a dApp/protocol covering gas costs for its users.

## Contracts

### `PharosSPNPaymaster.sol`

Location: `contracts/PharosSPNPaymaster.sol`

A production-ready ERC-4337 Paymaster with:
- **Whitelist**: Only pre-approved users get sponsored transactions
- **Budget Management**: Per-sponsor and global budget caps
- **Pause/Unpause**: Emergency stop for sponsorship
- **Batch Operations**: Add multiple sponsors in one transaction

**Key Functions:**

```solidity
// Add a user to the sponsorship whitelist
function addSponsor(address _user) external onlyOwner

// Add multiple users at once
function addSponsors(address[] calldata _users) external onlyOwner

// Set per-sponsor budget
function setSponsorBudget(address _sponsor, uint256 _amount) external onlyOwner

// Set global budget cap
function setGlobalBudget(uint256 _amount) external onlyOwner

// ERC-4337: Validate UserOperation (called by EntryPoint)
function validatePaymasterUserOp(
    PackedUserOperation calldata userOp,
    bytes32 userOpHash,
    uint256 maxCost
) external onlyEntryPoint returns (bytes memory context, uint256 validationData)

// ERC-4337: Post-operation hook
function postOp(
    PostOpMode mode,
    bytes calldata context,
    uint256 actualGasCost,
    uint256 actualUserOpFeePerGas
) external onlyEntryPoint
```

## Deployment

### Prerequisites
- Deployer has PROS/PHRS for gas
- ERC-4337 EntryPoint is deployed on target chain
- For Pharos Atlantic: EntryPoint v0.7 at `0x0000000071727De22E5E9d8BAf0edAc6f37da032`

### Steps

```bash
# Deploy Paymaster
forge script script/DeploySPNPaymaster.s.sol --rpc-url <RPC_URL> --broadcast

# Add sponsored users
cast send --private-key $PRIVATE_KEY <PAYMASTER_ADDR> "addSponsor(address)" <USER_ADDRESS>

# Set budgets
cast send --private-key $PRIVATE_KEY <PAYMASTER_ADDR> "setGlobalBudget(uint256)" <BUDGET_IN_WEI>
```

### Environment Variables
```
PRIVATE_KEY=0x...
ENTRYPOINT_ADDRESS=0x0000000071727De22E5E9d8BAf0edAc6f37da032
```

## Testing

Run the SPN Paymaster test suite:
```bash
forge test --match-contract PharosSPNPaymasterTest -vv
```

Tests cover: construction, sponsor management, budget tracking, pause/unpause, UserOperation validation, postOp accounting, and access control.

## Integration with MCP

MCP tools available:
- `pharos_spn_configure`: Configure sponsorship rules
- `pharos_spn_fund`: Fund the paymaster
- `pharos_spn_status`: Check paymaster state

## Security Considerations

1. **Budget Tracking**: Always set both per-sponsor and global budgets
2. **Whitelist Control**: Only add trusted users to avoid griefing
3. **Pause Mechanism**: Emergency pause protects against exploits
4. **EntryPoint Validation**: Only the real EntryPoint can trigger paymaster payments
5. **Oracle Independence**: No external price feeds needed
