import { createPublicClient, http } from "viem";
import type { PublicClient } from "viem";
import { getNetworkConfig } from "../config/networks";
import type { SupportedNetwork } from "../types";

export function createRpcClient(network: SupportedNetwork): PublicClient {
  const config = getNetworkConfig(network);
  const url = process.env[config.rpcUrlEnvVar];

  if (!url) {
    throw new Error(`Missing RPC URL in ${config.rpcUrlEnvVar}`);
  }

  return createPublicClient({
    transport: http(url),
  });
}
