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
