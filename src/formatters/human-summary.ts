import type { DeveloperPlan, DeveloperPromptIntent } from "../types";

export function buildHumanSummary(intent: DeveloperPromptIntent, plan: DeveloperPlan) {
  const frameworkLabel = intent.frameworks.length > 0 ? ` using ${intent.frameworks.join(", ")}` : "";
  const approvalLabel = plan.approvalRequired
    ? "approval required before edits"
    : "plan-first, then proceed if the user agrees";
  return `Pharos Agent Dev Suite: ${plan.title.toLowerCase()}${frameworkLabel} - ${approvalLabel}.`;
}
