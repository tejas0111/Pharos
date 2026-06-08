export type SkillLane = "investor" | "developer" | "defi";
export type SkillMode = "read" | "safe" | "expert";
export type SupportedNetwork = "pharos-mainnet" | "pharos-testnet";
export type SkillCapability =
  | "ecosystem-scan"
  | "balance-query"
  | "transaction-status"
  | "contract-read"
  | "send-transaction"
  | "gas-estimation"
  | "deploy-contract"
  | "verify-contract"
  | "quick-erc20-deploy"
  | "batch-transfer"
  | "wallet-aggregation"
  | "contract-script-generation";

export interface WalletInput {
  address: `0x${string}`;
}

export interface ParsedIntent {
  capability: SkillCapability;
  lane: SkillLane;
  mode: SkillMode;
  network: SupportedNetwork;
  wallets: WalletInput[];
  contractAddresses: `0x${string}`[];
  tokenAddresses: `0x${string}`[];
  transactionHashes: `0x${string}`[];
  recipientAddresses: `0x${string}`[];
  amount?: string;
  method?: string;
  constructorArgs: string[];
  prompt: string;
  wantsExecution: boolean;
}

export interface NetworkConfig {
  key: SupportedNetwork;
  chainId: number;
  rpcUrlEnvVar: string;
  explorerBaseUrl: string;
}

export interface WalletTokenBalance {
  symbol: string;
  balance: string;
  address?: `0x${string}`;
}

export interface WalletContextEntry {
  address: `0x${string}`;
  nativeBalance: string;
  tokens: WalletTokenBalance[];
  recentActivity: string[];
  topContracts: string[];
}

export interface WalletContextResult {
  wallets: WalletContextEntry[];
  sharedContracts: string[];
}

export interface Insight {
  type: string;
  severity: "low" | "medium" | "high";
  message: string;
}

export type DeveloperSubskillId =
  | "contract-architecture"
  | "solidity-authoring"
  | "interface-abi-design"
  | "protocol-integration-planning"
  | "frontend-dapp-integration"
  | "wallet-and-transaction-ui"
  | "framework-integration"
  | "testing-strategy"
  | "test-generation"
  | "contract-review"
  | "bug-finding-and-debugging"
  | "deployment-and-verification"
  | "repo-onboarding"
  | "docs-and-example-generation"
  | "ci-and-build-troubleshooting"
  | "migration-and-backward-compatibility"
  | "refactoring-and-code-health"
  | "dependency-upgrade-management"
  | "performance-optimization"
  | "accessibility-review"
  | "release-notes-and-changelog"
  | "code-scaffolding-and-generation"
  | "state-management-integration"
  | "monorepo-workspace-management"
  | "localization-and-copy"
  | "repo-automation-and-tooling"
  | "code-review-templates-and-checklists"
  | "nextjs-app-router-and-server-actions"
  | "react-ui-patterns-and-hooks"
  | "wagmi-viem-dapp-workflow"
  | "foundry-hardhat-contract-workflow"
  | "remix-contract-workflow"
  | "tailwind-shadcn-ui-workflow"
  | "deployment-for-testnet-and-mainnet"
  | "contract-testing-for-testnet-and-mainnet";

export type DeveloperRisk = "low" | "medium" | "high";

export interface DeveloperSubskillSpec {
  id: DeveloperSubskillId;
  title: string;
  summary: string;
  risk: DeveloperRisk;
  approvalRequired: boolean;
  useWhen: string[];
  workflow: string[];
  deliverables: string[];
  examples: string[];
}

export interface DeveloperPromptIntent {
  prompt: string;
  subskillId: DeveloperSubskillId;
  risk: DeveloperRisk;
  approvalRequired: boolean;
  frameworks: string[];
  stackHints: string[];
  fileHints: string[];
  goal: string;
}

export interface DeveloperPlan {
  subskillId: DeveloperSubskillId;
  title: string;
  summary: string;
  risk: DeveloperRisk;
  approvalRequired: boolean;
  approvalQuestion: string;
  steps: string[];
  assumptions: string[];
  verification: string[];
  deliverables: string[];
  warnings: string[];
}

export interface DeveloperSkillMetadata {
  name: string;
  version: string;
  mode: "developer-only";
  lanes: ["developer"];
  subskills: Array<{
    id: DeveloperSubskillId;
    title: string;
    risk: DeveloperRisk;
    approvalRequired: boolean;
  }>;
}
