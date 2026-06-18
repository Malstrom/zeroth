<!-- source: https://raw.githubusercontent.com/Malstrom/zeroth/main/frameworks/sudo-hire-me/scenarios/screening_prep.md -->

# Scenario: screening_prep

## Trigger

- User wants to prepare for an HR screening or interview round
- User has a round scheduled and wants to simulate it
- User asks to simulate a recruiter call

## Key rules

- Prep session comment goes to the **round sub-issue**, not the main company issue
- `target_issue` = sub-issue number for this round (from `pipeline.yml rounds[].sub_issue`)
- If sub-issue does not exist yet, create it before proceeding (use `issue_round.md` template)
- stories delta gate: always call `update_stories` — never write stories directly from here

---

## Spec

```yaml
screening_prep:
  on:
    - user wants to prepare for an HR screening
    - user has a screening scheduled and wants to simulate it
    - user asks to simulate a recruiter call
    - user asks to prepare for interview round with X
  creates_issue: false
  issue_updates:
    target: target_issue   # sub-issue number for this round
    mode: comment
  read:
    - igor.yml
    - stories.yml
    - "hunt/pipeline/*.yml"
    - issues: sudo-hire-me open ordered_by updated_at desc
    - comments: sudo-hire-me issue {{target_issue}}
  steps:
    - compute: company_slug
    - compute: target_pipeline
        rule: pick pipeline file for company_slug
    - compute: target_round
        rule: pick the round in target_pipeline with outcome: pending or nearest scheduled date
    - compute: target_issue
        rule: target_pipeline.rounds[target_round].sub_issue
              if missing: create sub-issue from issue_round.md template, write number back to pipeline.yml

    - if:
        condition: target_issue is missing after compute
        then:
          - say: "Nessuno screening schedulato trovato. Verifica pipeline.yml."

    - compute: role
    - compute: language
    - compute: recruiter_persona
    - compute: stack_required
    - compute: last_prep_questions
        rule: extract all questions from previous screening_prep comments on target_issue

    - compute: questions
        personal_story: 1
        recruiter: 7
        technical: 4
        total: 12
        order: personal_story → recruiter → technical
        rule: must not repeat questions from last_prep_questions
        constraint: total MUST be exactly 12 — never fewer

    - say: |
        Prepariamo lo screening per {{company_slug}} — {{role}}.
        Recruiter: {{recruiter_persona.name}} | Lingua risposta: {{language}}
        Domande generate: {{questions | count}}/12

    - if:
        condition: questions | count < 12
        then:
          - say: "ERRORE: generate solo {{questions | count}} domande su 12. Rigenero."
          - compute: questions
              personal_story: 1
              recruiter: 7
              technical: 4
              total: 12
              constraint: total MUST be exactly 12 — never fewer

    - propose: "Partiamo"
      on_confirm:

        - ask: "Sei pronto?"

        - loop: questions
          each:
            - say: "**Domanda {{loop.index}}/12** — {{question}}"
            - if:
                condition: stories.yml has topic matching question
                then:
                  - say: "💡 {{matching_story.summary}}"
            - ask: "[risposta]"
            - compute: feedback
            - compute: corrected_version
            - say: "{{feedback}}\n\n✅ **Versione corretta:**\n{{corrected_version}}"

        - compute: session_summary
            fields: [story_score, story_feedback, technical_table, fit_feedback, attenzione_table, checklist]

        - commit_before_reply

        - issue:
            comment:
              from: Malstrom/zeroth:frameworks/sudo-hire-me/templates/comment_screening_prep.md
              vars:
                date: "{{date}}"
                round_name: "{{target_round.name}}"
                recruiter_name: "{{recruiter_persona.name}}"
                recruiter_role: "{{recruiter_persona.role}}"
                story_score: "{{session_summary.story_score}}"
                story_feedback: "{{session_summary.story_feedback}}"
                technical_table: "{{session_summary.technical_table}}"
                fit_feedback: "{{session_summary.fit_feedback}}"
                language: "{{language}}"
                final_answers: "{{corrected_versions}}"
                checklist: "{{session_summary.checklist}}"

        - if:
            condition: stories_delta is not empty
            then:
              - call: update_stories

      on_reject:
        - say: "Ok. Dimmi quando sei pronto."

  output:
    state_changes: []
```
