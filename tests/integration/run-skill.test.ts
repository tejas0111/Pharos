import { describe, expect, it } from "vitest";
import { runSkill } from "../../src/index";

describe("runSkill", () => {
  it("returns a developer plan and structured payload for high-risk contract work", async () => {
    const result = await runSkill(
      "Design the contract architecture for a staking protocol with access control and upgrade boundaries",
    );

    expect(result.summary).toContain("Pharos Agent Dev Suite");
    expect(result.summary).toContain("approval required before edits");
    expect(result.payload.plan.approvalRequired).toBe(true);
    expect(result.payload.plan.title).toBe("Contract Architecture");
    expect(result.payload.nextAction).toBe("show-plan-and-wait-for-user-confirmation");
  });
});
