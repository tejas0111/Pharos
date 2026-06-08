import { describe, expect, it } from "vitest";
import { parseDeveloperIntent } from "../../src/intent/parse-intent";

describe("parseDeveloperIntent", () => {
  it("routes contract architecture work to the contract-architecture subskill", () => {
    const intent = parseDeveloperIntent(
      "Design the contract architecture for a staking protocol with access control and storage layout",
    );

    expect(intent.subskillId).toBe("contract-architecture");
    expect(intent.risk).toBe("high");
    expect(intent.approvalRequired).toBe(true);
  });

  it("routes generic frontend integration tasks to the frontend subskill", () => {
    const intent = parseDeveloperIntent(
      "Integrate this frontend app with shared state and component boundaries",
    );

    expect(intent.subskillId).toBe("frontend-dapp-integration");
    expect(intent.frameworks).toEqual([]);
  });

  it("routes dependency upgrade work to the upgrade management subskill", () => {
    const intent = parseDeveloperIntent("Upgrade dependencies and toolchain versions for this repo");

    expect(intent.subskillId).toBe("dependency-upgrade-management");
    expect(intent.risk).toBe("medium");
  });

  it("routes localization work to the copy and localization subskill", () => {
    const intent = parseDeveloperIntent("Improve the localization copy and labels for the wallet flow");

    expect(intent.subskillId).toBe("localization-and-copy");
    expect(intent.approvalRequired).toBe(false);
  });

  it("routes repo automation work to the automation subskill", () => {
    const intent = parseDeveloperIntent("Add scripts and task runner automation for lint, test, and build");

    expect(intent.subskillId).toBe("repo-automation-and-tooling");
  });

  it("routes deployment planning for testnet and mainnet to the deployment subskill", () => {
    const intent = parseDeveloperIntent("Plan deployment for testnet and mainnet with release checklist");

    expect(intent.subskillId).toBe("deployment-for-testnet-and-mainnet");
    expect(intent.risk).toBe("high");
  });

  it("routes network-aware contract testing to the contract testing subskill", () => {
    const intent = parseDeveloperIntent(
      "Design contract testing for testnet and mainnet with environment-aware checks",
    );

    expect(intent.subskillId).toBe("contract-testing-for-testnet-and-mainnet");
    expect(intent.approvalRequired).toBe(true);
  });

  it("routes code review template requests to the checklist subskill", () => {
    const intent = parseDeveloperIntent("Create a code review checklist and PR template for contract changes");

    expect(intent.subskillId).toBe("code-review-templates-and-checklists");
  });

  it("routes Next.js app router requests to the Next.js helper subskill", () => {
    const intent = parseDeveloperIntent("Use the Next.js App Router and server actions for this flow");

    expect(intent.subskillId).toBe("nextjs-app-router-and-server-actions");
  });

  it("routes React hook improvements to the React helper subskill", () => {
    const intent = parseDeveloperIntent("Refactor this React hook and component pattern for state handling");

    expect(intent.subskillId).toBe("react-ui-patterns-and-hooks");
  });

  it("routes Wagmi and Viem requests to the dapp workflow subskill", () => {
    const intent = parseDeveloperIntent("Wire wagmi and viem into the wallet connect and contract write flow");

    expect(intent.subskillId).toBe("wagmi-viem-dapp-workflow");
  });

  it("routes Foundry and Hardhat requests to the contract workflow subskill", () => {
    const intent = parseDeveloperIntent("Set up a Foundry and Hardhat contract workflow with forge tests");

    expect(intent.subskillId).toBe("foundry-hardhat-contract-workflow");
  });

  it("routes Remix requests to the Remix helper subskill", () => {
    const intent = parseDeveloperIntent("Set up a Remix workflow for quick contract iteration");

    expect(intent.subskillId).toBe("remix-contract-workflow");
  });

  it("routes Tailwind and shadcn requests to the UI workflow subskill", () => {
    const intent = parseDeveloperIntent("Design the UI with Tailwind and shadcn component styles");

    expect(intent.subskillId).toBe("tailwind-shadcn-ui-workflow");
  });
});
