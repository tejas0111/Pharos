# Screenshots

Placeholder directory for visual proof images. Replace these before submitting to DoraHacks.

## Required Screenshots

### 1. Counter Contract on PharosScan

Open the deployed Counter contract in a browser and take a screenshot:

**URL**: https://atlantic.pharosscan.xyz/address/0x55ec4b1e32537b6f72aa20153735709837488e4e

**What to capture**: The explorer page showing the contract address, transaction hash, and (if verified) source code tab.

![Counter on PharosScan](./counter-pharosscan.png)

### 2. Agent Workflow Terminal Output

Run the token launch workflow and screenshot the terminal:

```bash
export PRIVATE_KEY=0x...
bash agent/token-workflow.sh
```

**What to capture**: The full terminal output showing all 3 steps — deploy, balance check, transfer — with the success messages and final explorer link.

![Agent Workflow](./agent-workflow-terminal.png)

### 3. PharosERC20 on Explorer

Open the deployed PharosERC20 contract and take a screenshot:

**URL**: https://atlantic.pharosscan.xyz/address/0x3636F1BBcc56D1b5a22F8B778494D1553d95B4CD

**What to capture**: The explorer page showing the token name (PharosToken), symbol (PHT), and total supply.

![PharosERC20 on PharosScan](./pharoserc20-pharosscan.png)

---

## Instructions

1. Open each URL in Chrome/Firefox
2. Take a full-page screenshot (or crop to show the relevant section)
3. Save the image as `counter-pharosscan.png`, `agent-workflow-terminal.png`, and `pharoserc20-pharosscan.png`
4. Replace the placeholder references above with the actual images
5. Include them in your DoraHacks submission

> **Note**: The `architecture.png` diagram should be generated from `architecture.txt` using a tool like `asciiflow.com` or manually drawn.
