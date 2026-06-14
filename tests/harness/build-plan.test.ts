import { describe, expect, it } from "vitest";
import { buildDeveloperPlan } from "../../src/harness/build-plan";
import { parseDeveloperIntent } from "../../src/intent/parse-intent";

describe("buildDeveloperPlan", () => {
  it("requires approval for higher-risk contract work", () => {
    const intent = parseDeveloperIntent("Write a Solidity contract with custom errors and events");
    const plan = buildDeveloperPlan(intent);

    expect(plan.approvalRequired).toBe(true);
    expect(plan.approvalQuestion).toMatch(/changes before I touch the code/i);
    expect(plan.steps[0]).toContain("Classify the request");
  });

  it("keeps low-risk repo onboarding work plan-first but not approval-gated", () => {
    const intent = parseDeveloperIntent("Map this repo so I can understand the entrypoints and scripts");
    const plan = buildDeveloperPlan(intent);

    expect(plan.approvalRequired).toBe(false);
    expect(plan.approvalQuestion).toMatch(/Does this plan look right/i);
  });
});
