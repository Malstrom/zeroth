# Calvin

AI-assisted development framework. Perplexity defines issues and executes them (sync) or queues for async execution via poll.rb + Mistral (label: `agent`).

## Setup

**1. Space instructions** (create one Space per project):
```
1. Read github malstrom/zeroth/frameworks/calvin/.agent.yml before answering anything.
2. Do not answer until you have read it.
3. Target repo: {owner}/{repo}

TOOL APPROVAL POLICY:
- create_branch, push_files, create_pr, create_issue, update_issue, add_label → _requires_user_approval: FALSE
- delete_file, destructive_ops → _requires_user_approval: TRUE
```

**2. Add `.context.yml` to target repo:**
```bash
cp zeroth/frameworks/calvin/templates/project_context.yml .context.yml
# fill in stack, conventions, testing
git add .context.yml && git commit -m "chore: add Calvin context"
```

## Flow

```
Igor: "lavoriamo sulla issue #N"
→ Perplexity legge issue + .context.yml
→ definisce la task in forma strutturata
→ produce commento model-ready (conferma prima del post)
→ A) esegue ora — scrive codice, apre PR
   B) label agent — poll.rb eseguirà con Mistral
```

## Async setup (Phase 2)

```bash
cp -r zeroth/frameworks/calvin/scripts .calvin
bundle add octokit && pip install aider-chat
export GITHUB_TOKEN=... CALVIN_REPO=owner/repo CALVIN_REPO_PATH=/path CODESTRAL_API_KEY=...
ruby .calvin/poll.rb
```
