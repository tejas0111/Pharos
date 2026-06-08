import type {
  DeveloperSkillMetadata,
  DeveloperSubskillId,
  DeveloperSubskillSpec,
} from "../types";
import { DEVELOPER_SUBSKILLS } from "./subskills";

export function listSubskills(): DeveloperSubskillSpec[] {
  return DEVELOPER_SUBSKILLS;
}

export function getSubskill(subskillId: DeveloperSubskillId): DeveloperSubskillSpec {
  const subskill = DEVELOPER_SUBSKILLS.find((entry) => entry.id === subskillId);
  if (!subskill) {
    throw new Error(`Unknown Pharos developer subskill: ${subskillId}`);
  }
  return subskill;
}

export function createDeveloperSkillMetadata(): DeveloperSkillMetadata {
  return {
    name: "Pharos Agent Dev Suite",
    version: "0.1.0",
    mode: "developer-only",
    lanes: ["developer"],
    subskills: DEVELOPER_SUBSKILLS.map(({ id, title, risk, approvalRequired }) => ({
      id,
      title,
      risk,
      approvalRequired,
    })),
  };
}
