---
name: pharos-accessibility-review
description: "Review Pharos dapp UI behavior for keyboard support, semantics, contrast, and screen-reader friendliness. Use when auditing accessibility, a11y, keyboard navigation, screen reader support, ARIA semantics, tab order, or focus management in Pharos web3 dapps. Keywords: accessibility, a11y, keyboard, screen reader, contrast, semantics, ARIA, tab order, focus management, accessible, Pharos, dapp, React, Next.js, Tailwind, shadcn."
metadata:
  audience: developer
  version: 1.0.0
  category: frontend
slash: true
---

# Accessibility Review

Review UI behavior for keyboard support, semantics, contrast, and screen-reader friendliness.

## When to Use

accessibility, a11y, keyboard, screen reader, contrast, semantics, ARIA, tab order, focus management, accessible

## When NOT to Use

general UI component design (use react-ui-patterns-and-hooks or tailwind-shadcn-ui-workflow), or dapp-specific UI (use frontend-dapp-integration)

## Workflow

1. Inspect the UI flow for accessibility-sensitive interactions.
2. List the issues by severity and user impact.
3. Present the accessibility plan and ask if the fixes are correct.
4. Patch the issues and verify the interaction paths again.

## Output

- accessibility findings
- severity list
- fix plan
- verification notes

## Examples

- "Review this transaction modal for accessibility issues"
- "Check whether this wallet flow is keyboard-friendly"
- "Audit the color contrast and ARIA labels on this dapp dashboard"

## Verification

Keyboard navigation test. axe-core or lighthouse accessibility check.

## Related

react-ui-patterns-and-hooks (component patterns), tailwind-shadcn-ui-workflow (styling)
