---
name: pharos-bug-finding-and-debugging
description: Trace failures in compile, runtime, test, or UI behavior and propose focused fixes with root-cause analysis. Use when the user says: bug, debug, error, failing build, failing test, runtime issue.
---

# Bug Finding and Debugging

Use when the user needs a root-cause analysis or a narrow fix.

## Workflow

1. Reproduce or reason about the failure from the error output.
2. Isolate the root cause and the smallest safe fix.
3. Show the fix plan and ask for approval before editing.
4. Patch the issue and verify the failure is gone.

## Output

- root cause
- fix plan
- patch notes
- verification result

## Gate

High risk. Do not edit files before approval.
