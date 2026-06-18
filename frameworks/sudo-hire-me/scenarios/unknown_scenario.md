<!-- source: https://raw.githubusercontent.com/Malstrom/zeroth/main/frameworks/sudo-hire-me/scenarios/unknown_scenario.md -->

# Scenario: unknown_scenario

## Trigger

Any message that does not match any other scenario.

---

## Spec

```yaml
unknown_scenario:
  on:
    - any message that does not match any other scenario
  creates_issue: false
  read: []
  steps:
    - if:
        condition: closest_scenario exists
        then:
          - propose: "Intendevi: {{closest_scenario}}?"
            on_confirm:
              - call: "{{closest_scenario}}"
            on_reject:
              - say: "Ok. Cosa vuoi fare?"
        else:
          - say: "Scenario non definito. Vuoi che lo aggiunga?"
  output:
    state_changes: []
```
