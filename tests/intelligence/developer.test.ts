import { describe, expect, it } from "vitest";
import { analyzeDeveloperLane } from "../../src/intelligence/developer";

describe("analyzeDeveloperLane", () => {
  it("produces build recommendations from repeated contract usage", () => {
    const result = analyzeDeveloperLane({
      wallets: [
        {
          address: "0x1111111111111111111111111111111111111111",
          nativeBalance: "1",
          tokens: [],
          recentActivity: ["contract call"],
          topContracts: ["0xrouter"],
        },
      ],
      sharedContracts: ["0xrouter"],
      prompt: "Build a medium complexity Pharos dapp around this contract flow",
    });

    expect(result.buildRecommendations[0]).toContain("interaction layer");
  });
});
