import type { Insight, WalletContextEntry } from "../types";

export function analyzeInvestorLane(input: {
  wallets: WalletContextEntry[];
  sharedContracts: string[];
}) {
  const tokenBalances = new Map<string, number>();
  const insights: Insight[] = [];

  for (const wallet of input.wallets) {
    if (Number(wallet.nativeBalance) < 0.05) {
      insights.push({
        type: "low_gas",
        severity: "medium",
        message: `${wallet.address} has low native balance for follow-up actions`,
      });
    }

    for (const token of wallet.tokens) {
      tokenBalances.set(token.symbol, (tokenBalances.get(token.symbol) ?? 0) + Number(token.balance));
    }
  }

  const tokenExposureCombined = [...tokenBalances.entries()].map(([symbol, balance]) => ({
    symbol,
    balance: String(balance),
  }));

  if (tokenExposureCombined.length === 1) {
    insights.push({
      type: "concentration",
      severity: "medium",
      message: `Combined wallet exposure is concentrated in ${tokenExposureCombined[0].symbol}`,
    });
  }

  return {
    aggregate: {
      tokenExposureCombined,
      sharedContracts: input.sharedContracts,
    },
    insights,
    suggestedActions: [
      {
        mode: "safe" as const,
        label: "Fund low-gas wallet",
        description: "Top up the wallet with the lowest native balance before follow-up actions",
      },
    ],
  };
}
