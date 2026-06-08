import { parseIntent } from "./intent/parse-intent";

export { parseIntent } from "./intent/parse-intent";

export function createSkillMetadata() {
  return {
    name: "Pharos Power Skill",
    version: "0.1.0",
    lanes: ["investor", "developer", "defi"] as const,
  };
}

export async function runSkill(prompt: string) {
  return parseIntent(prompt);
}
