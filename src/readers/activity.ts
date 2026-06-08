import type { PublicClient } from "viem";
import type { WalletInput } from "../types";

export interface WalletActivitySnapshot {
  address: `0x${string}`;
  recentActivity: string[];
  topContracts: string[];
}

export async function readActivity(
  _client: PublicClient,
  wallets: WalletInput[],
): Promise<WalletActivitySnapshot[]> {
  return wallets.map((wallet) => ({
    address: wallet.address,
    recentActivity: [],
    topContracts: [],
  }));
}
