export function prepareSafeAction(input: { action: string; hasPrivateKey: boolean }) {
  if (!input.hasPrivateKey) {
    throw new Error("A private key is required for safe mode execution");
  }

  return {
    preview: `Safe action prepared: ${input.action}`,
  };
}
