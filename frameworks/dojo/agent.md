# Dojo Framework — .agent.yml Rules

Inherits all rules from `zeroth/rules/agent.md`. The following are dojo-specific additions.

## Required Scenarios
| Scenario | Trigger | Purpose |
|----------|---------|----------|
| `session_start` | auto on open | Read sensei + last log, propose next action |
| `dojo_study` | user asks to study a topic | Explain + create/update kata |
| `dojo_exam` | user requests exam on topic | 6-question exam, score/30, immutable log |
| `dojo_randori` | user requests drill/quiz | Generate HTML quiz artifact |
| `densho_open` | user imports a course/book | Parse + create densho file, detect kata gaps |
| `unknown_scenario` | no trigger matched | Map to closest or propose new scenario |

## Required Handlers
| Handler | Listens to | Purpose |
|---------|------------|----------|
| `kata_trigger` | `exam-failed`, `kata-gap-detected`, `densho-updated` | Create/update kata |
| `sensei_trigger` | `exam-passed`, `scroll-updated` | Update mastery in sensei.md |
| `session_end` | `goodbye`, `topic-closed`, `session-idle` | Write session log |

## Dojo-specific global rules
- `language`: always read from `sensei.md` at `session_start`
- `pr_strategy`: `batch_per_session` — exception: exam log → immediate PR
- Exam logs: immutable, commit before responding, append-only on correction
- Scoring: first answer only — correction is learning signal, not retry

## Exam format
- 6 questions, 5 points each, total 30
- One question at a time, interview style
- PC mode: theory + code; phone mode: theory only
- Pass threshold: 18/30 (60%)
