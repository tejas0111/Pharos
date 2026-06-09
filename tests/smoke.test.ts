import { describe, expect, it } from "vitest";
import { createSkillMetadata } from "../src/index";

describe("createSkillMetadata", () => {
  it("returns the public skill identity", () => {
    expect(createSkillMetadata()).toEqual({
      name: "Pharos Power Skill",
      version: "0.1.0",
      lanes: ["investor", "developer", "defi"],
    });
  });
});
