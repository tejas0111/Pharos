import { z } from "zod";
import type { ParsedIntent, SkillLane, SkillMode, SupportedNetwork } from "../types";

const ADDRESS_REGEX = /0x[a-fA-F0-9]{40}/g;

function inferLane(prompt: string): SkillLane {
  const lower = prompt.toLowerCase();

  if (lower.includes("defi") || lower.includes("allowance") || lower.includes("protocol")) {
    return "defi";
  }

  if (lower.includes("dapp") || lower.includes("developer") || lower.includes("contract flow")) {
    return "developer";
  }

  return "investor";
}

function inferMode(prompt: string): SkillMode {
  const lower = prompt.toLowerCase();

  if (lower.includes("expert mode") || lower.includes("custom write")) {
    return "expert";
  }

  if (lower.includes("safe mode") || lower.includes("approve") || lower.includes("transfer")) {
    return "safe";
  }

  return "read";
}

function inferNetwork(prompt: string): SupportedNetwork {
  return prompt.toLowerCase().includes("testnet") ? "pharos-testnet" : "pharos-mainnet";
}

const parsedIntentSchema = z.object({
  lane: z.enum(["investor", "developer", "defi"]),
  mode: z.enum(["read", "safe", "expert"]),
  network: z.enum(["pharos-mainnet", "pharos-testnet"]),
  wallets: z.array(z.object({ address: z.string().regex(/^0x[a-fA-F0-9]{40}$/) })).max(10),
  prompt: z.string().min(1),
  wantsExecution: z.boolean(),
});

export function parseIntent(prompt: string): ParsedIntent {
  const mode = inferMode(prompt);
  const wallets = [...prompt.matchAll(ADDRESS_REGEX)].map((match) => ({
    address: match[0] as `0x${string}`,
  }));

  return parsedIntentSchema.parse({
    lane: inferLane(prompt),
    mode,
    network: inferNetwork(prompt),
    wallets,
    prompt,
    wantsExecution: mode !== "read",
  }) as ParsedIntent;
}
