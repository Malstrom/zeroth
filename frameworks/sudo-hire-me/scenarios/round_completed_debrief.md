<!-- source: https://raw.githubusercontent.com/Malstrom/zeroth/main/frameworks/sudo-hire-me/scenarios/round_completed_debrief.md -->

# Scenario: round_completed_debrief

## Trigger

User says they finished a round / colloquio / interview with a company.
Examples: "ho finito il colloquio con Umbrellio", "appena finito lo screening", "fatto il tech interview".

---

## What this scenario does

1. Identifies company + round
2. Runs structured debrief (topic catalog, one question at a time)
3. Runs stories delta gate (mandatory, never skippable — calls `update_stories`)
4. Writes atomically: `pipeline.yml` + main issue body + sub-issue debrief comment (single PR)
5. Reports gaps and proposes next step

---

## Step 1 — Identify company and round

Read context from message. If not clear, ask:
- "Con quale azienda?"
- "Che tipo di round era? (HR screening / technical / tech lead / ...)"

Fetch `hunt/pipeline/{company_slug}.yml` from `Malstrom/sudo-hire-me`.
Fetch the sub-issue for this round (from `rounds[].sub_issue` in pipeline.yml).
If sub-issue does not exist yet, create it using `issue_round.md` template before proceeding.

---

## Step 2 — Debrief: topic catalog

Do NOT ask "qual era la prima domanda esatta" — Igor does not remember precise wording.

Build topic list from:
- `analysis.stack_required` in pipeline.yml
- prep session comments on this round's sub-issue (scan for unchecked prep items)
- `open_gaps` from pipeline.yml (gaps from previous rounds)

For each topic ask:
> "Ti hanno chiesto qualcosa su **[topic]**?"

- **Sì** → ask: "Come hai risposto?" → assess (solid / partial / weak) → extract gap if partial or weak
- **No** → move on

After all topics:
> "C'è qualcosa che non ho coperto? Argomenti che hanno toccato e non sono nella lista?"

Add any new topics Igor mentions. Assess them the same way.

### Assessment values

| Value | Meaning |
|---|---|
| `solid` | Clear, complete answer. No gap. |
| `partial` | Correct direction but missing key details. Gap present. |
| `weak` | Wrong or missing. Gap present, high priority. |

---

## Step 3 — Build open_gaps list

From all `partial` and `weak` topics build:

```yaml
- topic: {snake_case_id}
  description: >
    {what was missing, concise, in English}
  prep_priority: high | medium | low
```

Priority rules:
- `high`: weak assessment OR topic is core to next round's stack
- `medium`: partial assessment, secondary topic
- `low`: partial assessment, nice-to-have topic

Merge with existing `open_gaps` in pipeline.yml:
- Topic already exists: update description + priority
- Topic now solid: remove from open_gaps
- New topic: append

---

## Step 4 — Stories delta gate (MANDATORY — NEVER SKIP)

Before any write operation, call `update_stories`.

`update_stories` handles the full gate:
- checks if stories need updating based on this session
- shows diff table
- waits for approval
- writes only after explicit yes

Even if result is "nothing to update", the call must happen.

---

## Step 5 — Writes (single PR — never split)

All writes in one PR on `Malstrom/sudo-hire-me`.

### 5a. Update `hunt/pipeline/{company_slug}.yml`

Fields to update:
- `status`: new status
- `last_updated`: today's date
- `open_gaps`: merged list from Step 3
- `rounds[]`: update this round's `outcome` and `sub_issue`

### 5b. Regenerate main issue body

Read `Malstrom/zeroth:frameworks/sudo-hire-me/templates/issue_pipeline.md`.
Populate with updated values from pipeline.yml.
Update body of main issue via `update_issue`.

### 5c. Add debrief comment to round sub-issue

Read `Malstrom/zeroth:frameworks/sudo-hire-me/templates/comment_round_debrief.md`.
Populate and post as comment on the round sub-issue.

Header: `## 📋 Round debrief — {date} — {round_name}`

---

## Step 6 — Output to Igor

After all writes confirm:

1. PR link
2. Open gaps with priority (🔴 high 🟡 medium 🟢 low)
3. If passed: propose creating sub-issue for next round
4. If failed/cancelled: note it, no next step unless Igor asks

---

## Sub-issue creation (if missing)

If sub-issue for this round does not exist in pipeline.yml:
1. Read `Malstrom/zeroth:frameworks/sudo-hire-me/templates/issue_round.md`
2. Create issue in `Malstrom/sudo-hire-me` (title: `{Company} — Round {N}: {Round Name}`)
3. Update `rounds[].sub_issue` in pipeline.yml with new issue number
4. Include in same PR as step 5a

---

## Comment type conventions (sub-issue)

| Type | Header pattern | Written by |
|---|---|---|
| Prep session | `## 🎭 Screening prep — {date} (v{n})` | `screening_prep` |
| Round debrief | `## 📋 Round debrief — {date} — {round_name}` | this scenario |
| Manual note | `## 📝 Nota — {date}` | Igor or AI on request |

---

## Dependencies

| Resource | Repo | Path |
|---|---|---|
| pipeline.yml | Malstrom/sudo-hire-me | hunt/pipeline/{company_slug}.yml |
| Main issue | Malstrom/sudo-hire-me | GitHub issue #{main_issue} |
| Round sub-issue | Malstrom/sudo-hire-me | GitHub issue #{sub_issue} |
| issue_pipeline.md | Malstrom/zeroth | frameworks/sudo-hire-me/templates/issue_pipeline.md |
| issue_round.md | Malstrom/zeroth | frameworks/sudo-hire-me/templates/issue_round.md |
| comment_round_debrief.md | Malstrom/zeroth | frameworks/sudo-hire-me/templates/comment_round_debrief.md |
| stories.yml | Malstrom/zeroth | frameworks/sudo-hire-me/stories.yml |
