---
name: pharos-code-scaffolding-and-generation
description: "Generate starter files, boilerplate, or project scaffolds for Pharos developer workflows. Use when scaffolding new projects, creating starter files, generating boilerplate, initializing project setup, or creating file templates for Pharos dapps. Keywords: scaffold, starter, boilerplate, generate files, template, create, initialize, project setup, file generation, Pharos, Solidity, Foundry, Hardhat, Next.js, React, TypeScript, dapp."
metadata:
  audience: developer
  version: 1.2.0
  category: workflow
slash: true
---

# Code Scaffolding and Generation

Generate starter files, boilerplate, or project scaffolds for Pharos developer workflows on mainnet (1672) and testnet (688689).

## Pharos Foundry Project Scaffold

```bash
forge init pharos-staking --no-commit
cd pharos-staking
forge install foundry-rs/forge-std --no-commit
```

### foundry.toml

```toml
[rpc_endpoints]
pharos_mainnet = "$PHAROS_MAINNET_RPC_URL"
pharos_testnet = "$PHAROS_TESTNET_RPC_URL"

[etherscan]
pharos_mainnet = { key = "${PHAROSSCAN_API_KEY}", url = "$PHAROSSCAN_MAINNET_API_URL" }
pharos_testnet = { key = "${PHAROSSCAN_API_KEY}", url = "$PHAROSSCAN_TESTNET_API_URL" }
```

### PharosStaking.sol

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract PharosStaking {
    mapping(address => uint256) public stakes;
    event Staked(address indexed user, uint256 amount);

    function stake() external payable {
        stakes[msg.sender] += msg.value;
        emit Staked(msg.sender, msg.value);
    }

    function unstake(uint256 amount) external {
        require(stakes[msg.sender] >= amount);
        stakes[msg.sender] -= amount;
        (bool sent,) = payable(msg.sender).call{value: amount, gas: 10000}("");
        require(sent);
    }
}
```

### DeployPharosStaking.s.sol

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {PharosStaking} from "../src/PharosStaking.sol";

contract DeployPharosStaking is Script {
    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        require(block.chainid == 1672 || block.chainid == 688689, "Wrong chain");
        vm.startBroadcast(pk);
        new PharosStaking();
        vm.stopBroadcast();
    }
}
```

### test/PharosStaking.t.sol

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {PharosStaking} from "../src/PharosStaking.sol";

contract PharosStakingTest is Test {
    PharosStaking staking;

    function setUp() public {
        vm.createSelectFork("pharos_testnet");
        staking = new PharosStaking();
    }

    function test_Stake() public {
        vm.deal(address(this), 10 ether);
        staking.stake{value: 1 ether}();
        assertEq(staking.stakes(address(this)), 1 ether);
    }
}
```

### .env

```bash
PRIVATE_KEY=0x...
PHAROSSCAN_API_KEY=...
```

## When to Use

scaffold, starter, boilerplate, generate files, template, create a new, initialize, project setup, file generation

## When NOT to Use

editing existing code (use the relevant subskill for that code), or writing documentation (use docs-and-example-generation)

## Prerequisites
- **Gate Fix**: Perform the mandatory "Gate Fix" check before proceeding.
- **Security**:
    - **.env Usage**: Environment variables MUST be stored in a `.env` file in the project root. NEVER use `export VAR=...` for sensitive data.
    - **Mandatory Check**: The Agent MUST verify `.env` exists and variables are set using `grep -q` (NEVER `cat`, `head`, `tail` — those expose secrets) before any deployment or on-chain action.
    - **Git**: Ensure `.env` is listed in `.gitignore` to prevent accidental commits.

- **Foundry**: `forge build` must succeed. Run `forge --version` to verify installation.
- **RPC endpoint**: Set `PHAROS_TESTNET_RPC=$PHAROS_TESTNET_RPC_URL` or `PHAROS_MAINNET_RPC=$PHAROS_MAINNET_RPC_URL` in your environment or `.env`.
- **PharosScan API key**: Set `PHAROSSCAN_API_KEY` for contract verification (https://www.pharosscan.xyz).
- **Network reachability**: Run `cast chain-id --rpc-url $RPC_URL` to confirm the target network is reachable.
- **Foundry config**: `foundry.toml` should have `[rpc_endpoints]` section with `pharos_testnet` and `pharos_mainnet` entries.
## Workflow
- **Strict .env Check**: Confirm `.env` exists with `test -f .env` and check variables via `grep -q` (without printing values). NEVER print `.env` contents. Do NOT proceed if missing or if the user suggests `export`.

1. **Requirement Gathering**: Analyze the user's request to identify the specific task, target environment (Atlantic 688689 or Pacific 1672), and any missing context. Zero-assumption delivery.
2. **Mandatory Plan (`PLAN.md`)**: Create or update `PLAN.md` in the project root with the proposed strategy. **Wait for explicit 'Approve' or 'Proceed' from the user before taking any action.**
3. Identify the target structure and minimum usable files.
4. Check prerequisites: verify Foundry is installed, RPC endpoints are reachable, and required env vars are set. Ask the user for any missing values before proceeding.
5. Draft the scaffold and explain the generated pieces.
6. Show the plan and proceed once it looks right.
7. Keep the scaffold minimal and directly useful.
## Output

- file scaffold
- starter layout
- generation notes
- follow-up suggestions

## Examples

- "Scaffold a Pharos Foundry project with forge init, PHRS staking contract, deploy script with chain 1672 validation, and test"
- "Generate a starter Next.js dapp with wagmi, RainbowKit, and Pharos mainnet config"
- "Create a boilerplate Pharos Hardhat project with deploy scripts and test helpers for chain ID 1672"
- "Scaffold a Pharos staking contract + deploy + test with forge init in one command"
- "Generate a Pharos project template with foundry.toml RPC endpoints for mainnet and testnet"

## Verification

File structure check. `forge build` on the generated scaffold. `forge test --fork-url pharos_testnet` passes.

## Related

docs-and-example-generation (content, not structure), framework-integration (configuration setup)

## Gate


Low risk. Show the file tree and `.env.example` keys before writing; generate files only after user confirms scaffold type and target path.
