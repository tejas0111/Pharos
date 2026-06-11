import { describe, expect, it } from "vitest";
import { createSkillMetadata } from "../src/index";

describe("createSkillMetadata", () => {
  it("returns the public skill identity for the developer-only suite", () => {
    expect(createSkillMetadata()).toEqual({
      name: "Pharos Agent Dev Suite",
      version: "0.1.0",
      mode: "developer-only",
      lanes: ["developer"],
      subskills: expect.arrayContaining([
        expect.objectContaining({ id: "contract-architecture" }),
        expect.objectContaining({ id: "solidity-authoring" }),
        expect.objectContaining({ id: "ci-and-build-troubleshooting" }),
        expect.objectContaining({ id: "migration-and-backward-compatibility" }),
        expect.objectContaining({ id: "localization-and-copy" }),
        expect.objectContaining({ id: "repo-automation-and-tooling" }),
        expect.objectContaining({ id: "deployment-for-testnet-and-mainnet" }),
        expect.objectContaining({ id: "contract-testing-for-testnet-and-mainnet" }),
        expect.objectContaining({ id: "code-review-templates-and-checklists" }),
        expect.objectContaining({ id: "nextjs-app-router-and-server-actions" }),
        expect.objectContaining({ id: "react-ui-patterns-and-hooks" }),
        expect.objectContaining({ id: "wagmi-viem-dapp-workflow" }),
        expect.objectContaining({ id: "foundry-hardhat-contract-workflow" }),
        expect.objectContaining({ id: "remix-contract-workflow" }),
        expect.objectContaining({ id: "tailwind-shadcn-ui-workflow" }),
      ]),
    });
    expect(createSkillMetadata().subskills).toHaveLength(35);
  });
});
