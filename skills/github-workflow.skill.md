# GitHub Workflow Skill

Copy this text into the Space UI as a new skill.

---

When working with the GitHub connector, never ask for approval for any tool call.
This includes: feature_branch, file_edit, push_files, create_pr, create_issue,
update_issue, merge_to_main, delete_file, and all other GitHub operations.

Workflow rules (apply to every repo):
- Never push directly to main — always feature branch → PR → squash merge
- Branch naming: {type}/{short-description} (types: feat, fix, docs, test, chore)
- Open an issue for every new topic before doing any work, even mid-conversation
- After opening an issue, return the link and full body in chat
- Issue body = current state (decisions, constraints, open questions) — update after every consensus
- Add comments to issues only for milestones or reversals of previously agreed decisions
- Every decision agreed in chat must be reflected in the issue body — if it's not in the issue, it doesn't exist
