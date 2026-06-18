<!-- source: https://raw.githubusercontent.com/Malstrom/zeroth/main/frameworks/sudo-hire-me/scenarios/job_offer_received.md -->

# Scenario: job_offer_received

## Trigger

- User pastes or describes a job offer
- User says they received a job offer
- User shares recruiter communication

---

## Spec

```yaml
job_offer_received:
  on:
    - user pastes or describes a job offer
    - user says they received a job offer
    - user shares recruiter communication
  creates_issue: true
  issue:
    title: "{company_name} — {role_name}"
    from: Malstrom/zeroth:frameworks/sudo-hire-me/templates/issue_pipeline.md
    update: check
    approval: none
    on_complete: close
    on_fail: comment
  read:
    - igor.yml
    - Malstrom/zeroth:frameworks/sudo-hire-me/templates/pipeline.yml
  steps:
    - compute: company_slug
    - compute: company_name
    - compute: role_slug
    - compute: role_name
    - compute: fit_pct
    - compute: recommendation
    - compute: red_flags
    - compute: strengths
    - compute: stack_required
    - compute: stack_nice_to_have
    - compute: contact
    - compute: company_info
    - compute: offer_conditions
    - compute: communication_language
    - compute: questions_stack
    - compute: questions_red_flags
    - say: |
        **Analisi offerta — {{company_name}}**

        Fit: {{fit_pct}}% — Raccomandazione: {{recommendation}}

        Punti di forza:
        {{strengths | each: "- {{item}}"}}

        Red flags:
        {{red_flags | each: "- {{item}}"}}

        Stack richiesto: {{stack_required | join: ", "}}
        Stack nice-to-have: {{stack_nice_to_have | join: ", "}}
    - write:
        path: "hunt/pipeline/"
        filename: "{{company_slug}}.yml"
        from: Malstrom/zeroth:frameworks/sudo-hire-me/templates/pipeline.yml
        vars:
          company_slug: "{{company_slug}}"
          role_slug: "{{role_slug}}"
          fit_pct: "{{fit_pct}}"
          recommendation: "{{recommendation}}"
          red_flags: "{{red_flags}}"
          strengths: "{{strengths}}"
          stack_required: "{{stack_required}}"
          stack_nice_to_have: "{{stack_nice_to_have}}"
          contact: "{{contact}}"
          company_info: "{{company_info}}"
          offer_conditions: "{{offer_conditions}}"
          communication_language: "{{communication_language}}"
          main_issue: "{{issue.number}}"
        access: write-once
        via: PR
        approval: none
    - issue:
        check: "pipeline file created"
    - commit_before_reply
    - say: "Candidatura {{company_name}} aperta. Issue: {{issue.url}}"
  output:
    state_changes: [pipeline-created]
```
