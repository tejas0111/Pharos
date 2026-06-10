import { describe, expect, it } from "vitest";
import { prepareSafeAction } from "../../src/execution/safe-mode";
import { prepareExpertAction } from "../../src/execution/expert-mode";

describe("execution gating", () => {
  it("requires explicit private key material for safe mode", () => {
    expect(() =>
      prepareSafeAction({
        action: "transfer",
        hasPrivateKey: false,
      }),
    ).toThrow(/private key/i);
  });

  it("requires explicit warnings for expert mode", () => {
    const result = prepareExpertAction({
      action: "custom write",
      hasPrivateKey: true,
      contractAddress: "0x1111111111111111111111111111111111111111",
    });

    expect(result.warning).toContain("dangerous");
  });
});
