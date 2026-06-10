import { describe, expect, it } from "vitest";
import { analyzeInvestorLane } from "../../src/intelligence/investor";

describe("analyzeInvestorLane", () => {
  it("detects concentration and low-gas wallets", () => {
    const result = analyzeInvestorLane({
      wallets: [
        {
          address: "0x1111111111111111111111111111111111111111",
          nativeBalance: "0.01",
          tokens: [{ symbol: "AAA", balance: "100" }],
          recentActivity: ["swap"],
          topContracts: ["0xaaaa"],
        },
        {
          address: "0x2222222222222222222222222222222222222222",
          nativeBalance: "5",
          tokens: [{ symbol: "AAA", balance: "200" }],
          recentActivity: [],
          topContracts: ["0xaaaa"],
        },
      ],
      sharedContracts: ["0xaaaa"],
    });

    expect(result.insights.some((item) => item.type === "concentration")).toBe(true);
    expect(result.insights.some((item) => item.type === "low_gas")).toBe(true);
    expect(result.aggregate.tokenExposureCombined).toEqual([{ symbol: "AAA", balance: "300" }]);
  });
});
