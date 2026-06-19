// ---- In-Memory Rate Limiter ----
const RATE_LIMIT_WINDOW = 60_000; // 1 minute
const RATE_LIMIT_MAX = 30; // max requests per tool per window
const REQUEST_LOG = new Map();
const CLEANUP_INTERVAL = 300_000; // cleanup stale entries every 5 minutes

function checkRateLimit(toolName) {
  const now = Date.now();
  if (!REQUEST_LOG.has(toolName)) {
    REQUEST_LOG.set(toolName, []);
  }
  const timestamps = REQUEST_LOG.get(toolName);
  while (timestamps.length > 0 && timestamps[0] < now - RATE_LIMIT_WINDOW) {
    timestamps.shift();
  }
  if (timestamps.length >= RATE_LIMIT_MAX) {
    const retryAfter = Math.ceil((timestamps[0] + RATE_LIMIT_WINDOW - now) / 1000);
    return { limited: true, retryAfter };
  }
  timestamps.push(now);
  return { limited: false };
}

// Periodic cleanup: remove stale tool entries from the log
setInterval(() => {
  const now = Date.now();
  for (const [tool, timestamps] of REQUEST_LOG.entries()) {
    // Remove expired timestamps
    while (timestamps.length > 0 && timestamps[0] < now - RATE_LIMIT_WINDOW) {
      timestamps.shift();
    }
    // If no recent activity, remove the entry entirely
    if (timestamps.length === 0) {
      REQUEST_LOG.delete(tool);
    }
  }
}, CLEANUP_INTERVAL);

export { checkRateLimit };
