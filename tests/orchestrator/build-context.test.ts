import { describe, expect, it } from "vitest";
import { buildWalletContext } from "../../src/orchestrator/build-context";

describe("buildWalletContext", () => {
  it("builds per-wallet context and aggregate contract sets", async () => {
    const result = await buildWalletContext(
      {
        lane: "investor",
        mode: "read",
        network: "pharos-testnet",
        prompt: "analyze wallets",
        wantsExecution: false,
        wallets: [
          { address: "0x1111111111111111111111111111111111111111" },
          { address: "0x2222222222222222222222222222222222222222" },
        ],
      },
      {
        readBalances: async () => [
          {
            address: "0x1111111111111111111111111111111111111111",
            nativeBalance: "10",
            tokens: [{ symbol: "AAA", balance: "20" }],
          },
          {
            address: "0x2222222222222222222222222222222222222222",
            nativeBalance: "5",
            tokens: [{ symbol: "BBB", balance: "8" }],
          },
        ],
        readActivity: async () => [
          {
            address: "0x1111111111111111111111111111111111111111",
            topContracts: ["0xaaaa"],
            recentActivity: ["swap"],
          },
          {
            address: "0x2222222222222222222222222222222222222222",
            topContracts: ["0xaaaa", "0xbbbb"],
            recentActivity: ["bridge"],
          },
        ],
      },
    );

    expect(result.wallets).toHaveLength(2);
    expect(result.sharedContracts).toEqual(["0xaaaa"]);
  });
});
