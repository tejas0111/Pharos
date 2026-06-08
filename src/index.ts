import { parseIntent } from "./intent/parse-intent";
import { buildHumanSummary } from "./formatters/human-summary";
import { buildStructuredPayload } from "./formatters/structured-payload";
import { analyzeDefiLane } from "./intelligence/defi";
import { analyzeDeveloperLane } from "./intelligence/developer";
import { analyzeInvestorLane } from "./intelligence/investor";
import { buildWalletContext } from "./orchestrator/build-context";

export { parseIntent } from "./intent/parse-intent";

export function createSkillMetadata() {
  return {
    name: "Pharos Power Skill",
    version: "0.1.0",
    lanes: ["investor", "developer", "defi"] as const,
  };
}

export async function runSkill(prompt: string) {
  const intent = parseIntent(prompt);
  const context = await buildWalletContext(intent);

  const laneResult =
    intent.lane === "developer"
      ? analyzeDeveloperLane({ ...context, prompt: intent.prompt })
      : intent.lane === "defi"
        ? analyzeDefiLane(context)
        : analyzeInvestorLane(context);

  const payload = buildStructuredPayload({
    network: intent.network,
    lane: intent.lane,
    mode: intent.mode,
    walletCount: intent.wallets.length,
    wallets: context.wallets,
    sharedContracts: context.sharedContracts,
    ...laneResult,
  });

  return {
    summary: buildHumanSummary(intent.lane, payload),
    payload,
  };
}
