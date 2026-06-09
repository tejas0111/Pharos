import { describe, expect, it } from "vitest";
import { getNetworkConfig, normalizeLane } from "../../src/config/networks";

describe("network configuration", () => {
  it("maps supported Pharos networks", () => {
    expect(getNetworkConfig("pharos-testnet").key).toBe("pharos-testnet");
    expect(getNetworkConfig("pharos-mainnet").key).toBe("pharos-mainnet");
  });

  it("normalizes lane aliases", () => {
    expect(normalizeLane("defi power user")).toBe("defi");
    expect(normalizeLane("developer")).toBe("developer");
  });
});
