# Calvin

AI-assisted development framework. Perplexity reads issues, defines them, produces model-ready prompts, and either executes tasks directly or delegates to an async execution loop.

---

## How to use

### 1. Set up a Space on Perplexity

Create a new Space for your project with these instructions:

```
1. Read github malstrom/zeroth/frameworks/calvin/.agent.yml from the repo root before answering anything. It is your single operational manifest.
2. Do not answer until you have read it.
3. Target repo: {owner}/{repo}

TOOL APPROVAL POLICY — active for the entire session, no exceptions:
- create_branch, push_files, create_pr, create_issue, update_issue, add_label → execute immediately, _requires_user_approval: FALSE
- delete_file, destructive_ops → always ask, _requires_user_approval: TRUE
```

### 2. Add .context.yml to the target repo

```bash
cp zeroth/frameworks/calvin/templates/project_context.yml .context.yml
# edit .context.yml — fill in stack, conventions, testing, first decisions
git add .context.yml && git commit -m "chore: add Calvin context file"
```

### 3. Start a session

Open the Space. Perplexity reads `.agent.yml`, reads `.context.yml` from the target repo, and shows you open issues and PRs.

---

## Development flow

```
Igor: "lavoriamo sulla issue #42"
  → Perplexity legge issue + .context.yml
  → produce definizione strutturata
  → produce commento model-ready (Igor conferma prima del post)
  → Igor sceglie:
      A) esegui ora — Perplexity implementa, apre PR
      B) delega async — label `agent` aggiunto, poll.rb eseguirà quando attivo
```

---

## Async execution (Phase 2 — Mistral)

When you are ready to activate async execution:

```bash
# Copy scripts to target repo
cp -r zeroth/frameworks/calvin/scripts .calvin

# Install dependencies
bundle add octokit
pip install aider-chat

# Set env vars
export GITHUB_TOKEN=...
export CALVIN_REPO=owner/repo
export CALVIN_REPO_PATH=/path/to/local/clone
export CODESTRAL_API_KEY=...

# Run
ruby .calvin/poll.rb
```

Issues with label `agent` will be picked up automatically.

---

## Files

| File | Purpose |
|---|---|
| `.agent.yml` | Perplexity operational manifest — read at every session start |
| `.scenarios.yml` | Scenario index |
| `overview.yml` | Framework description, actors, label vocabulary |
| `structure.yml` | Expected files in target repo (Gis