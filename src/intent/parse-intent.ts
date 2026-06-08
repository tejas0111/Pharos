import { z } from "zod";
import { getSubskill, listSubskills } from "../registry";
import type { DeveloperPromptIntent, DeveloperSubskillId } from "../types";

const FRAMEWORK_PATTERNS: Array<[string, RegExp]> = [
  ["next.js", /\bnext(?:\.js)?\b/i],
  ["react", /\breact\b/i],
  ["wagmi", /\bwagmi\b/i],
  ["viem", /\bviem\b/i],
  ["ethers", /\bether?s?\b/i],
  ["foundry", /\bfoundry\b/i],
  ["hardhat", /\bhardhat\b/i],
  ["remix", /\bremix\b/i],
  ["thirdweb", /\bthirdweb\b/i],
  ["rainbowkit", /\brainbowkit\b/i],
  ["shadcn", /\bshadcn\b/i],
  ["tailwind", /\btailwind\b/i],
  ["vite", /\bvite\b/i],
];

const FILE_HINT_REGEX = /\b(?:[A-Za-z0-9_.-]+\/)+[A-Za-z0-9_.-]+\.(?:ts|tsx|js|jsx|sol|md|json|yaml|yml|mjs|cjs)\b/g;

type Rule = {
  id: DeveloperSubskillId;
  patterns: RegExp[];
};

const ROUTING_RULES: Rule[] = [
  {
    id: "repo-automation-and-tooling",
    patterns: [/automation/i, /task runner/i, /precommit/i, /makefile/i, /script/i, /tooling/i],
  },
  {
    id: "contract-testing-for-testnet-and-mainnet",
    patterns: [/network-specific test/i, /testnet tests/i, /mainnet tests/i, /contract testing/i],
  },
  {
    id: "deployment-for-testnet-and-mainnet",
    patterns: [/testnet/i, /mainnet/i, /network-specific deploy/i, /deploy flow/i, /release checklist/i],
  },
  {
    id: "code-review-templates-and-checklists",
    patterns: [/code review template/i, /pr checklist/i, /review rubric/i, /review checklist/i, /review template/i],
  },
  {
    id: "nextjs-app-router-and-server-actions",
    patterns: [/next\.?js app router/i, /app router/i, /server actions/i, /route handlers/i, /\brsc\b/i],
  },
  {
    id: "wagmi-viem-dapp-workflow",
    patterns: [/wagmi/i, /viem/i, /wallet connect/i, /contract read/i, /contract write/i, /dapp workflow/i],
  },
  {
    id: "foundry-hardhat-contract-workflow",
    patterns: [/foundry/i, /hardhat/i, /\bforge\b/i, /\banvil\b/i, /solidity workflow/i, /contract workflow/i],
  },
  {
    id: "remix-contract-workflow",
    patterns: [/remix/i, /browser solidity/i, /remix workflow/i, /quick contract iteration/i],
  },
  {
    id: "tailwind-shadcn-ui-workflow",
    patterns: [/tailwind/i, /\bshadcn\b/i, /design system/i, /component styles/i, /ui workflow/i],
  },
  {
    id: "react-ui-patterns-and-hooks",
    patterns: [/react hooks/i, /component pattern/i, /\bhook\b/i, /\bcontext\b/i, /ui patterns/i],
  },
  {
    id: "migration-and-backward-compatibility",
    patterns: [/migration/i, /backward compatibility/i, /compatibility layer/i, /breaking change/i],
  },
  {
    id: "dependency-upgrade-management",
    patterns: [/dependency upgrade/i, /upgrade dependencies/i, /package update/i, /version bump/i, /toolchain update/i, /toolchain versions/i],
  },
  {
    id: "performance-optimization",
    patterns: [/performance/i, /optimize/i, /slow/i, /bottleneck/i, /bundle size/i, /latency/i],
  },
  {
    id: "accessibility-review",
    patterns: [/accessibility/i, /\ba11y\b/i, /screen reader/i, /keyboard/i, /contrast/i, /semantics/i],
  },
  {
    id: "release-notes-and-changelog",
    patterns: [/release notes/i, /changelog/i, /release summary/i, /shipping notes/i],
  },
  {
    id: "code-scaffolding-and-generation",
    patterns: [/scaffold/i, /starter/i, /boilerplate/i, /generate files/i, /template/i],
  },
  {
    id: "state-management-integration",
    patterns: [/state management/i, /\bzustand\b/i, /\bredux\b/i, /query client/i, /\bstore\b/i, /\bcache\b/i],
  },
  {
    id: "monorepo-workspace-management",
    patterns: [/monorepo/i, /workspace/i, /turborepo/i, /pnpm workspace/i, /shared package/i],
  },
  {
    id: "localization-and-copy",
    patterns: [/localization/i, /\bi18n\b/i, /translation/i, /microcopy/i, /\bcopy\b/i, /labels/i],
  },
  {
    id: "contract-review",
    patterns: [/review.*contract/i, /audit/i, /security review/i, /solidity review/i],
  },
  {
    id: "deployment-and-verification",
    patterns: [/deploy/i, /verification/i, /verify.*contract/i, /release checklist/i],
  },
  {
    id: "ci-and-build-troubleshooting",
    patterns: [/\bci\b/i, /\bci\/cd\b/i, /build failure/i, /type error/i, /lint/i, /pipeline/i],
  },
  {
    id: "bug-finding-and-debugging",
    patterns: [/debug/i, /bug/i, /failing test/i, /runtime error/i, /root cause/i],
  },
  {
    id: "test-generation",
    patterns: [/write tests/i, /generate tests/i, /test file/i, /fixtures/i],
  },
  {
    id: "testing-strategy",
    patterns: [/test strategy/i, /coverage/i, /test plan/i, /edge cases/i],
  },
  {
    id: "solidity-authoring",
    patterns: [/write.*solidity/i, /implement contract/i, /contract code/i, /\bsolidity\b/i],
  },
  {
    id: "contract-architecture",
    patterns: [/architecture/i, /module boundary/i, /storage layout/i, /access control/i],
  },
  {
    id: "protocol-integration-planning",
    patterns: [/integration/i, /call sequence/i, /approval flow/i, /protocol flow/i],
  },
  {
    id: "interface-abi-design",
    patterns: [/abi/i, /interface/i, /events?/i, /errors?/i, /typed binding/i],
  },
  {
    id: "frontend-dapp-integration",
    patterns: [/frontend/i, /dapp/i, /ui integration/i, /wallet connect/i, /transaction preview/i],
  },
  {
    id: "wallet-and-transaction-ui",
    patterns: [/wallet ui/i, /transaction ui/i, /history/i, /status screen/i, /preview modal/i],
  },
  {
    id: "framework-integration",
    patterns: [/next\.js/i, /\bwagmi\b/i, /\bviem\b/i, /\bethers\b/i, /\bfoundry\b/i, /\bhardhat\b/i, /\bremix\b/i],
  },
  {
    id: "repo-onboarding",
    patterns: [/onboard/i, /map repo/i, /project layout/i, /where is the code/i],
  },
  {
    id: "docs-and-example-generation",
    patterns: [/docs?/i, /readme/i, /examples?/i, /usage instructions/i, /prompt examples?/i],
  },
];

function detectSubskill(prompt: string): DeveloperSubskillId {
  for (const rule of ROUTING_RULES) {
    if (rule.patterns.some((pattern) => pattern.test(prompt))) {
      return rule.id;
    }
  }

  return "repo-onboarding";
}

function detectFrameworks(prompt: string): string[] {
  return FRAMEWORK_PATTERNS.filter(([, pattern]) => pattern.test(prompt)).map(([name]) => name);
}

function detectFileHints(prompt: string): string[] {
  return [...prompt.matchAll(FILE_HINT_REGEX)].map((match) => match[0]);
}

function buildGoal(prompt: string): string {
  const trimmed = prompt.trim();
  return trimmed.length > 120 ? `${trimmed.slice(0, 117)}...` : trimmed;
}

const developerIntentSchema = z.object({
  prompt: z.string().min(1),
  subskillId: z.enum([
    "contract-architecture",
    "solidity-authoring",
    "interface-abi-design",
    "protocol-integration-planning",
    "frontend-dapp-integration",
    "wallet-and-transaction-ui",
    "framework-integration",
    "testing-strategy",
    "test-generation",
    "contract-review",
    "bug-finding-and-debugging",
    "deployment-and-verification",
    "repo-onboarding",
    "docs-and-example-generation",
    "ci-and-build-troubleshooting",
    "migration-and-backward-compatibility",
    "refactoring-and-code-health",
    "dependency-upgrade-management",
    "performance-optimization",
    "accessibility-review",
    "release-notes-and-changelog",
    "code-scaffolding-and-generation",
    "state-management-integration",
    "monorepo-workspace-management",
    "localization-and-copy",
    "repo-automation-and-tooling",
    "deployment-for-testnet-and-mainnet",
    "contract-testing-for-testnet-and-mainnet",
    "code-review-templates-and-checklists",
    "nextjs-app-router-and-server-actions",
    "react-ui-patterns-and-hooks",
    "wagmi-viem-dapp-workflow",
    "foundry-hardhat-contract-workflow",
    "remix-contract-workflow",
    "tailwind-shadcn-ui-workflow",
  ]),
  risk: z.enum(["low", "medium", "high"]),
  approvalRequired: z.boolean(),
  frameworks: z.array(z.string()),
  stackHints: z.array(z.string()),
  fileHints: z.array(z.string()),
  goal: z.string().min(1),
});

export function parseDeveloperIntent(prompt: string): DeveloperPromptIntent {
  const subskillId = detectSubskill(prompt);
  const subskill = getSubskill(subskillId);
  const frameworks = detectFrameworks(prompt);
  const fileHints = detectFileHints(prompt);
  const stackHints = [...frameworks, ...fileHints];
  const goal = buildGoal(prompt);

  return developerIntentSchema.parse({
    prompt,
    subskillId,
    risk: subskill.risk,
    approvalRequired: subskill.approvalRequired,
    frameworks,
    stackHints,
    fileHints,
    goal,
  });
}

export function listDeveloperRoutingSignals() {
  return listSubskills().map(({ id, title, summary, risk, approvalRequired }) => ({
    id,
    title,
    summary,
    risk,
    approvalRequired,
  }));
}
