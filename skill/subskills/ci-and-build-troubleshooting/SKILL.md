---
name: pharos-ci-and-build-troubleshooting
description: "Diagnose failing builds, type errors, lint jobs, and CI regressions with a narrow fix path. Use when the user says: CI, build failure, lint failure, type error, pipeline, broken test job, build is failing, CI is red, compilation error. Do NOT use for: runtime bugs (use bug-finding-and-debugging), or performance improvements (use performance-optimization). See also: bug-finding-and-debugging (runtime bugs, not build failures)."
---

# CI and Build Troubleshooting

Diagnose failing builds, type errors, lint jobs, and CI regressions with a narrow fix path.

## When to Use

CI, build failure, lint failure, type error, pipeline, broken test job, build is failing, CI is red, compilation error

## When NOT to Use

runtime bugs (use bug-finding-and-debugging), or performance improvements (use performance-optimization)

## Workflow

1. Read the failure output and isolate the failing stage.
2. Narrow the fix to the smallest change that restores the pipeline.
3. Show the plan and ask before editing files that affect build behavior.
4. Verify the pipeline or local equivalent after the fix.

## Output

- failure analysis
- fix plan
- pipeline notes
- verification command

## Examples

- "Fix this failing TypeScript build in the repo"
- "Diagnose why CI is failing after the recent changes"
- "Resolve the Solidity compiler version mismatch in the CI pipeline"

## Verification

The exact failing command passes. Re-run the pipeline step or equivalent local command.

## Related

bug-finding-and-debugging (runtime bugs, not build failures)
