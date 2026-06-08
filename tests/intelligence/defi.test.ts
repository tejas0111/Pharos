import { describe, expect, it } from "vitest";
import { analyzeDefiLane } from "../../src/intelligence/defi";

describe("analyzeDefiLane", () => {
  it("flags wallet approvals and protocol overlap signals", () => {
    const result = analyzeDefiLane({
      wallets: [
        {
          address: "0x1111111111111111111111111111111111111111",
          nativeBalance: "2",
          tokens: [{ symbol: "AAA", balance: "50" }],
          recentActivity: ["swap", "approve"],
          topContracts: ["0xrouter"],
        },
      ],
      sharedContracts: ["0xrouter"],
    });

    expect(result.protocolSignals).toContain("Repeated interaction with 0xrouter");
    expect(result.allowanceFlags).toContain("Review active token approvals before expert execution");
  });
});
