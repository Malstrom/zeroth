<!-- source: https://raw.githubusercontent.com/Malstrom/zeroth/main/frameworks/sudo-hire-me/scenarios/round_completed.md -->

# Scenario: round_completed (DEPRECATED)

> **Deprecated.** Replaced by `round_completed_debrief`.
> This file exists only as a redirect stub.

## Redirect

If this scenario is triggered, immediately call `round_completed_debrief` instead.

```yaml
round_completed:
  on:
    - ~   # deprecated — no trigger
  deprecated: true
  replaced_by: round_completed_debrief
  creates_issue: false
  read: []
  steps:
    - call: round_completed_debrief
  output:
    state_changes: []
```
