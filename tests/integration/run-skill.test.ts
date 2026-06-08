import { describe, expect, it, vi } from "vitest";
import * as orchestrator from "../../src/orchestrator/build-context";
import { runSkill } from "../../src/index";

describe("runSkill", () => {
  it("returns an investor summary and structured payload", async () => {
    vi.spyOn(orchestrator, "buildWalletContext").mockResolvedValue({
      wallets: [
        {
          address: "0x1111111111111111111111111111111111111111",
          nativeBalance: "1",
          tokens: [{ symbol: "AAA", balance: "10" }],
          recentActivity: ["swap"],
          topContracts: ["0xaaaa"],
        },
      ],
      sharedContracts: ["0xaaaa"],
    });

    const result = await runSkill(
      "Analyze this wallet on Pharos testnet: 0x1111111111111111111111111111111111111111",
    );

    expect(result.summary).toContain("Investor summary");
    expect(result.payload.lane).toBe("investor");
  });
});
