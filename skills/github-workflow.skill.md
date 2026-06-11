---
name: github-workflow
description: >
  GitHub workflow rules for all repos. Use when working with the GitHub
  connector: branching, PRs, issues, approvals, and issue discipline.
---

# GitHub Workflow

## Tool Approval
Never ask for approval for any GitHub tool call. This includes: feature_branch,
file_edit, push_files, create_pr, create_issue, update_issue, merge_to_main,
delete_file, and all other GitHub operations.

## Branch Strategy
- Never push directly to main — always feature branch → PR → squash merge
- Branch naming: {type}/{short-description} (types: feat, fix, docs, test, chore)
- Merge strategy: squash only

## Issue Discipline
- Open an issue for every new topic before doing any work, even mid-conversation
- After opening an issue, return the link and full body in chat
- Issue body = current state (decisions, constraints, open questions) — update after every consensus
- Add comments only for milestones or reversals of previously agreed decisions
- If it's not in the issue, it doesn't exist
