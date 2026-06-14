import { buildDeveloperPlan } from "./harness/build-plan";
import { buildHumanSummary } from "./formatters/human-summary";
import { buildStructuredPayload } from "./formatters/structured-payload";
import { parseDeveloperIntent } from "./intent/parse-intent";
import { createDeveloperSkillMetadata, getSubskill, listSubskills } from "./registry";

export { buildDeveloperPlan } from "./harness/build-plan";
export { parseDeveloperIntent } from "./intent/parse-intent";
export { createDeveloperSkillMetadata, getSubskill, listSubskills } from "./registry";

export function createSkillMetadata() {
  return createDeveloperSkillMetadata();
}

export async function runSkill(prompt: string) {
  const intent = parseDeveloperIntent(prompt);
  const plan = buildDeveloperPlan(intent);
  const subskill = getSubskill(intent.subskillId);

  const payload = buildStructuredPayload({
    metadata: createDeveloperSkillMetadata(),
    intent,
    subskill,
    plan,
    nextAction: plan.approvalRequired
      ? "show-plan-and-wait-for-user-confirmation"
      : "show-plan-and-proceed-if-approved",
  });

  return { summary: buildHumanSummary(intent, plan), payload };
}
