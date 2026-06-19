#!/usr/bin/env bash
set -euo pipefail

PORT="${1:-8092}"
DIR="$(cd "$(dirname "$0")" && pwd)"

echo "========================================"
echo "  Pharos ADS — Interactive Demo"
echo "  Serving at http://localhost:$PORT"
echo "  Press Ctrl+C to stop"
echo "========================================"
echo ""
echo "📡 6 interactive contracts:"
echo "   SPN Paymaster · zkLogin · LendingPool"
echo "   DEXPool · StakingPool · RWAToken"necho ""
echo "📚 45 subskills · 167 tests · 21 MCP tools"
echo ""

cd "$DIR"
${PYTHON:-python3} -m http.server "$PORT"
