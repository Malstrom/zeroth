<!-- source: https://raw.githubusercontent.com/Malstrom/zeroth/main/frameworks/sudo-hire-me/scenarios/update_stories.md -->

# Scenario: update_stories

## Trigger

- Called from another scenario after a session that may have produced stories delta
- User explicitly asks to update stories

## Hard rule

This is the ONLY place where `stories.yml` is written.
No other scenario may write `stories.yml` directly.
This gate is mandatory and never skippable (see `hard_rules.stories_delta` in `.agent.yml`).

---

## Spec

```yaml
update_stories:
  on:
    - user asks to update stories
    - called from another scenario after approval gate
  creates_issue: false
  read:
    - stories.yml
  steps:
    - compute: stories_delta
        rule: |
          Derive from context inherited from calling scenario.
          Per topic touched in session, compare Igor's answers vs stories.yml.
          Include only if Igor added concepts or was more precise.
          Ignore if Igor said less than what is already in stories.yml.
          Always include topics not present in stories.yml.
          Language for new/updated stories: Italian only — never Russian or English.

    - if:
        condition: stories_delta is empty
        then:
          - say: "Nessuna storia da aggiornare in questa sessione."
        else:
          - say: |
              ## Stories delta

              | Story ID | Storia attuale (sintesi) | Proposta (sintesi) |
              |---|---|---|
              {{stories_delta | each: "| {{topic}} | {{current_summary | default: '—'}} | {{proposed_summary}} |"}}
          - ask: "Approvi? Dimmi quali topic approvare (o 'tutti')."
          - loop: approved_topics
            each:
              - write:
                  path: stories.yml
                  from: Malstrom/zeroth:frameworks/sudo-hire-me/templates/story_entry.yml
                  vars:
                    topic: "{{delta.topic}}"
                    content: "{{delta.proposed_story}}"
                  access: read-write
                  via: PR
                  approval: none
  output:
    state_changes: []
```
