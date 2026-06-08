import type { SkillLane } from "../types";

export function buildHumanSummary(lane: SkillLane, details: Record<string, unknown>) {
  if (lane === "developer") {
    return `Developer summary: ${JSON.stringify(details)}`;
  }

  if (lane === "defi") {
    return `DeFi summary: ${JSON.stringify(details)}`;
  }

  return `Investor summary: ${JSON.stringify(details)}`;
}
