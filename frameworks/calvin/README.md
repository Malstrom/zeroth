# Calvin

Autonomous development loop for any repo. Igor creates issues. Perplexity writes the async-ready comment. The model executes, opens a PR. Igor reviews and merges.

## Flow

```
Igor + Perplexity reason in chat
  → create_epic    : create parent issue (label: epic)
  → decompose      : break into sub-issues (label: task)
  → write_async_ready : post model-ready comment + label: agent
  → calvin.rb      : picks up issue, runs Aider, opens PR
  → review_pr      : Igor reviews, Perplexity proposes .calvin/ updates
  → update_context : .calvin/ updated, context never lost
```

## Actors

| Actor | Role |
|---|---|
| Igor | creates issues, reviews PRs |
| Perplexity | writes async-ready comments, manages labels, updates .calvin/ |
| calvin.rb | polls `agent` label, runs Aider, opens PR |
| Model (Aider) | executes task, opens PR, writes Calvin notes |

## Bootstrap a new repo

Tell Perplexity: `calvanize` — creates `.calvin/` in the target repo.

## Files

```
frameworks/calvin/
  .agent.yml          ← operational manifest (read first)
  .scenarios.yml      ← scenario index
  overview.yml        ← decisions, label lifecycle, actors
  structure.yml       ← file map with roles
  scenarios/          ← 6 scenario files
  templates/          ← issue_epic, issue_task, issue_async_ready
  scripts/
    calvin.rb         ← entry point (ruby calvin.rb)
    lib/              ← 8 classes
```

## Instance layout (per repo)

```
.calvin/
  stack.yml           ← tech stack + key libs
  conventions.yml     ← naming, patterns, do-not-touch rules
  testing.yml         ← test strategy, coverage rules
  decisions.yml       ← append-only architecture decisions
  schema.yml          ← logical model schema
```

## Requirements

- Ruby, `octokit` gem, `aider`, `gh` CLI
- `GITHUB_TOKEN`, `CALVIN_REPO`, `CALVIN_REPO_PATH` env vars
- Labels `agent`, `agent:review`, `agent:blocked` created in target repo
