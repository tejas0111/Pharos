export type SkillLane = "investor" | "developer" | "defi";
export type SkillMode = "read" | "safe" | "expert";
export type SupportedNetwork = "pharos-mainnet" | "pharos-testnet";

export interface WalletInput {
  address: `0x${string}`;
}

export interface ParsedIntent {
  lane: SkillLane;
  mode: SkillMode;
  network: SupportedNetwork;
  wallets: WalletInput[];
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
