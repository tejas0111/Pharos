import type { PublicClient } from "viem";
import { readActivity } from "../readers/activity";
import { readBalances } from "../readers/balances";
import { createRpcClient } from "../readers/rpc-client";
import type { ParsedIntent, WalletContextResult } from "../types";

type ReaderOverrides = {
  client?: PublicClient;
  readBalances?: typeof readBalances;
  readActivity?: typeof readActivity;
};

export async function buildWalletContext(
  intent: ParsedIntent,
  overrides: ReaderOverrides = {},
): Promise<WalletContextResult> {
  const balanceReader = overrides.readBalances ?? readBalances;
  const activityReader = overrides.readActivity ?? readActivity;
  const client =
    overrides.client ??
    (overrides.readBalances && overrides.readActivity
      ? ({} as PublicClient)
      : createRpcClient(intent.network));

  const [balances, activity] = await Promise.all([
    balanceReader(client, intent.wallets),
    activityReader(client, intent.wallets),
  ]);

  const wallets = balances.map((balance) => {
    const activityMatch = activity.find((entry) => entry.address === balance.address);

    return {
      address: balance.address,
      nativeBalance: balance.nativeBalance,
      tokens: balance.tokens,
      recentActivity: activityMatch?.recentActivity ?? [],
      topContracts: activityMatch?.topContracts ?? [],
    };
  });

  const contractCounts = new Map<string, number>();

  for (const wallet of wallets) {
    for (const contract of wallet.topContracts) {
      contractCounts.set(contract, (contractCounts.get(contract) ?? 0) + 1);
    }
  }

  const sharedContracts = [...contractCounts.entries()]
    .filter(([, count]) => count > 1)
    .map(([contract]) => contract);

  return {
    wallets,
    sharedContracts,
  };
}
