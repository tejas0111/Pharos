# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability in the Pharos Agent Dev Suite, please report it privately.

**Do not** open a public GitHub issue for security vulnerabilities.

**How to report:**
- Email: [tejas.yonk@gmail.com](mailto:tejas.yonk@gmail.com)
- GitHub: Open a [private security advisory](https://github.com/tejas0111/Pharos/security/advisories/new)

You should receive a response within 48 hours. If not, follow up via email.

## Scope

This policy covers:
- The MCP server (`mcp-server/index.js`) — all 21 tools
- The Solidity contracts (`contracts/`) — Counter, PharosERC20, Storage
- The skill subskills (`skill/subskills/`) — all 42 markdown files
- The agent scripts (`agent/`) — mcp-client, demos
- The CI/CD pipeline (`.github/workflows/`)
- The web frontend (`web/`) — docs and landing page

Out of scope:
- Third-party dependencies (please report to the respective maintainers)
- The Pharos blockchain itself (contact the Pharos team)
- Foundry, viem, or other development tools

## Disclosure Process

1. **Report received** — acknowledged within 48 hours
2. **Triage** — severity assessment within 5 business days
3. **Fix** — remediation developed and tested
4. **Release** — patch published, advisory disclosed

## Bug Bounty

This project currently does not offer a bug bounty program. Researchers who report valid vulnerabilities will be credited in the release notes.

## Security Best Practices (for users)

- Never commit `.env` files — use `PRIVATE_KEY` as a CI secret or shell env var
- Avoid `cat`, `head`, `tail` on `.env` — use `grep -q` for existence checks
- Always run `forge script` with `--broadcast` only after verifying simulation output
- Use a dedicated deployer wallet with minimal funds
- Verify contracts on PharosScan after deployment
- Set `MAINTAINER_CONFIRM` for mainnet deploys in CI
- Pin your `foundry.toml` Solidity version (`solc_version = "0.8.26"`)
