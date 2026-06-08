import { describe, expect, it } from "vitest";
import { parseIntent } from "../../src/intent/parse-intent";

describe("parseIntent", () => {
  it("classifies an investor request with wallets", () => {
    const result = parseIntent(
      "Analyze these wallets on Pharos testnet and show portfolio overlap: 0x1111111111111111111111111111111111111111, 0x2222222222222222222222222222222222222222",
    );

    expect(result.lane).toBe("investor");
    expect(result.network).toBe("pharos-testnet");
    expect(result.wallets).toHaveLength(2);
    expect(result.mode).toBe("read");
  });

  it("classifies a developer build request", () => {
    const result = parseIntent(
      "Inspect this Pharos contract flow and build the interaction layer for a medium complexity dapp",
    );

    expect(result.lane).toBe("developer");
  });

  it("switches to expert mode when arbitrary execution is requested", () => {
    const result = parseIntent(
      "Use expert mode and prepare a custom contract write on Pharos mainnet for 0x3333333333333333333333333333333333333333",
    );

    expect(result.mode).toBe("expert");
    expect(result.wantsExecution).toBe(true);
  });
});
