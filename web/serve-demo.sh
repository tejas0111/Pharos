#!/bin/bash
# Demo: serve both pages, print URLs, ready for screen recording
set -e
PORT=${1:-8092}
echo "═══ Pharos Web Demo ═══"
echo "Serving on port $PORT"
echo ""
echo "  Landing:  http://localhost:$PORT/"
echo "  Docs:     http://localhost:$PORT/docs.html"
echo ""
echo "Record flow:"
echo "  1. Landing page → scroll through hero, deploy flow, scanline effects"
echo "  2. Docs page   → navigate sections via sidebar & arrows"
echo "  3. Copy button → click code-block copy icon"
echo "  4. Mobile      → resize browser to 375px, show hamburger menu"
echo ""
echo "  Open both with:"
echo "    chromium http://localhost:$PORT/ http://localhost:$PORT/docs.html"
echo ""
cd "$(dirname "$0")"
${PYTHON:-python3} -m http.server "$PORT"
