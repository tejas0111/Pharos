import { readFileSync } from "node:fs";
import { join } from "node:path";
import { describe, expect, it } from "vitest";

const DEPLOY_SKILL_ROOT = join(process.cwd(), "deploy-skill/skill");

function readDeploySkillFile(relativePath: string) {
  return readFileSync(join(DEPLOY_SKILL_ROOT, relativePath), "utf8");
}

describe("deploy skill package", () => {
  it("defines distinct testnet and mainnet deployment variants", () => {
    const master = readDeploySkillFile("SKILL.md");
    const testnet = readDeploySkillFile("subskills/testnet-deployment/SKILL.md");
    const mainnet = readDeploySkillFile("subskills/mainnet-deployment/SKILL.md");

    expect(master).toContain("route to the matching variant");
    expect(master).toContain("scripts/deploy-testnet-hardhat.sh");
    expect(master).toContain("scripts/deploy-mainnet-hardhat.sh");
    expect(master).toContain("scripts/verify-testnet-hardhat.sh");
    expect(master).toContain("scripts/verify-mainnet-hardhat.sh");
    expect(testnet).toContain("Pharos Testnet Deployment");
    expect(mainnet).toContain("Pharos Mainnet Deployment");
  });

  it("ships Foundry deploy templates for both networks", () => {
    const testnetScript = readDeploySkillFile("scripts/deploy-testnet.sh");
    const mainnetScript = readDeploySkillFile("scripts/deploy-mainnet.sh");
    const testnetHardhatScript = readDeploySkillFile("scripts/deploy-testnet-hardhat.sh");
    const mainnetHardhatScript = readDeploySkillFile("scripts/deploy-mainnet-hardhat.sh");
    const testnetVerifyScript = readDeploySkillFile("scripts/verify-testnet-hardhat.sh");
    const mainnetVerifyScript = readDeploySkillFile("scripts/verify-mainnet-hardhat.sh");

    expect(testnetScript).toContain("PHAROS_TESTNET_RPC_URL");
    expect(testnetScript).toContain("forge");
    expect(testnetScript).toContain("script");
    expect(mainnetScript).toContain("PHAROS_MAINNET_RPC_URL");
    expect(mainnetScript).toContain("forge");
    expect(mainnetScript).toContain("script");
    expect(testnetHardhatScript).toContain("PHAROS_TESTNET_RPC_URL");
    expect(testnetHardhatScript).toContain("hardhat");
    expect(testnetHardhatScript).toContain("deploy");
    expect(testnetHardhatScript).toContain("pharosTestnet");
    expect(mainnetHardhatScript).toContain("PHAROS_MAINNET_RPC_URL");
    expect(mainnetHardhatScript).toContain("hardhat");
    expect(mainnetHardhatScript).toContain("deploy");
    expect(mainnetHardhatScript).toContain("pharosMainnet");
    expect(testnetVerifyScript).toContain("hardhat");
    expect(testnetVerifyScript).toContain("verify");
    expect(testnetVerifyScript).toContain("DEPLOYED_ADDRESS");
    expect(mainnetVerifyScript).toContain("hardhat");
    expect(mainnetVerifyScript).toContain("verify");
    expect(mainnetVerifyScript).toContain("DEPLOYED_ADDRESS");
  });
});
