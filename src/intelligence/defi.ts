import type { WalletContextEntry } from "../types";

export function analyzeDefiLane(input: {
  wallets: WalletContextEntry[];
  sharedContracts: string[];
}) {
  return {
    protocolSignals: input.sharedContracts.map((contract) => `Repeated interaction with ${contract}`),
    allowanceFlags: ["Review active token approvals before expert execution"],
    actionOpportunities: [
      "Use safe mode to top up underfunded wallets",
      "Use expert mode only after verifying contract call parameters",
    ],
  };
}
