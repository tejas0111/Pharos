---
name: pharos-ci-and-build-troubleshooting
description: Diagnose failing builds, type errors, lint failures, and CI pipeline regressions with narrow fix paths. Use when the user says: CI, build failure, lint failure, type error, pipeline, broken test job.
---

# CI and Build Troubleshooting

Use when the build pipeline, typecheck, lint, or CI is failing.

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

## Gate

High risk. Do not change build behavior before approval.
