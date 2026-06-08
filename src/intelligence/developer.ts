import type { WalletContextEntry } from "../types";

export function analyzeDeveloperLane(input: {
  wallets: WalletContextEntry[];
  sharedContracts: string[];
  prompt: string;
}) {
  const integrationTargets = [...new Set(input.wallets.flatMap((wallet) => wallet.topContracts))];

  return {
    integrationTargets,
    contractContext: input.sharedContracts,
    buildRecommendations: [
      "Generate a contract interaction layer with typed read and write helpers",
      "Create an initial app flow with wallet connection, read state, and transaction preview screens",
      `Use the prompt context to scaffold a medium complexity dapp around: ${input.prompt}`,
    ],
  };
}
