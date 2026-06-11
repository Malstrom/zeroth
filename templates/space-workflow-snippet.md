# Space Workflow — Regola Immutabile

> Copia questa sezione nel file `.agent.yml` o nelle istruzioni di ogni nuovo spazio.
> NON modificare questa regola. Propagarla invariata.

---

```yaml
# ---------------------------------------------------------------------------
# WORK STYLE — IMMUTABLE RULE
# ---------------------------------------------------------------------------
work_style:
  issue_first:
    rule: EVERY task or new chat topic MUST have a GitHub issue before any work starts
    immutable: true  # this rule must never be changed, only propagated

  new_topic_in_chat:
    rule: open issue immediately
    precision: low_ok
    update_before_pr: true
    post_open:
      - return issue link in chat
      - return issue body in chat

  issue_discipline:
    rule: issues are the single source of truth for every decision made in chat
    always:
      - every decision or constraint agreed in chat → update issue body to reflect current state
      - every new topic that emerges → open a new issue immediately, even mid-conversation
      - never let a decision live only in chat — if it's not in the issue, it doesn't exist
      - create sub-issues when a task is too large or has independent workstreams
      - link issues when dependencies exist between tasks
    body_policy:
      rule: issue body always reflects current state — not history
      update_trigger: after every consensus reached in chat
      content: decisions made, constraints, open questions
    comment_policy:
      rule: comments are reserved for significant events only
      comment_trigger: milestone_or_reversal_only
      forbidden: do not add comments for every micro-decision or chat exchange
    applies_to: all_repos

  pr_discipline:
    rule: every change goes through a PR linked to its issue
    always:
      - NEVER push directly to main
      - feature branch → PR → squash merge
      - branch naming: "{type}/{short-description}" where type = feat | fix | docs | test | chore
      - every PR must reference its issue (closing keyword or explicit link)
    merge_strategy: squash
    applies_to: all_repos
```
