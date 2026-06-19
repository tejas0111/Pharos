// ---- In-Memory Rate Limiter ----
const RATE_LIMIT_WINDOW = 60_000; // 1 minute
const RATE_LIMIT_MAX = 30; // max requests per tool per window
const requestLog = new Map();

function checkRateLimit(toolName) {
  const now = Date.now();
  if (!requestLog.has(toolName)) {
    requestLog.set(toolName, []);
  }
  const timestamps = requestLog.get(toolName);
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

export { checkRateLimit };
