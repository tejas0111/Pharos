import { getSubskill } from "../registry";
import type { DeveloperPlan, DeveloperPromptIntent } from "../types";

function buildApprovalQuestion(title: string, approvalRequired: boolean) {
  return approvalRequired
    ? `Is this plan correct for ${title}, or do you want changes before I touch the code?`
    : `Does this plan look right for ${title}, or should I revise it first?`;
}

function buildAssumptions(intent: DeveloperPromptIntent): string[] {
  const assumptions = ["The request is for developer work only, not RPC or onchain execution."];
  if (intent.frameworks.length > 0) {
    assumptions.push(`Detected framework hints: ${intent.frameworks.join(", ")}`);
  } else {
    assumptions.push("No framework was named, so the plan should stay framework-agnostic until clarified.");
  }
  if (intent.fileHints.length > 0) {
    assumptions.push(`Referenced files: ${intent.fileHints.join(", ")}`);
  }
  return assumptions;
}

function buildWarnings(intent: DeveloperPromptIntent): string[] {
  const warnings: string[] = [];
  if (intent.approvalRequired) {
    warnings.push("This is a higher-risk change, so the plan must be shown to the user before edits.");
  }
  if (intent.subskillId === "contract-review" || intent.subskillId === "bug-finding-and-debugging") {
    warnings.push("Findings should be backed by evidence, not intuition.");
  }
  if (intent.subskillId === "ci-and-build-troubleshooting") {
    warnings.push("Keep the fix narrow; do not widen the blast radius while repairing the pipeline.");
  }
  return warnings;
}

export function buildDeveloperPlan(intent: DeveloperPromptIntent): DeveloperPlan {
  const subskill = getSubskill(intent.subskillId);

  return {
    subskillId: subskill.id,
    title: subskill.title,
    summary: subskill.summary,
    risk: subskill.risk,
    approvalRequired: subskill.approvalRequired,
    approvalQuestion: buildApprovalQuestion(subskill.title, subskill.approvalRequired),
    steps: [
      "Classify the request and confirm the target outcome.",
      ...subskill.workflow,
      "Verify the result with the smallest meaningful check: build, test, lint, diff review, or a targeted smoke check.",
      "Summarize the changes, assumptions, and the next step for the user.",
    ],
    assumptions: buildAssumptions(intent),
    verification: [
      "The plan matches the requested Pharos developer task.",
      "The implementation path is narrow enough to review quickly.",
      "The verification step is explicit and appropriate for the target.",
    ],
    deliverables: subskill.deliverables,
    warnings: buildWarnings(intent),
  };
}
