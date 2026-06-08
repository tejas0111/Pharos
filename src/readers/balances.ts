import type { PublicClient } from "viem";
import type { WalletInput, WalletTokenBalance } from "../types";

export interface WalletBalanceSnapshot {
  address: `0x${string}`;
  nativeBalance: string;
  tokens: WalletTokenBalance[];
}

export async function readBalances(
  _client: PublicClient,
  wallets: WalletInput[],
): Promise<WalletBalanceSnapshot[]> {
  return wallets.map((wallet) => ({
    address: wallet.address,
    nativeBalance: "0",
    tokens: [],
  }));
}
