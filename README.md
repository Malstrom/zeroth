# zeroth

> The zeroth law stands above all others.

Spec and foundational rules for building AI-native frameworks in the Malstrom ecosystem.
Every framework that respects `zeroth` can be automatically validated by giskard.

## Why "zeroth"

Isaac Asimov introduced the Three Laws of Robotics in 1942.
Decades later, in *Robots and Empire* (1985), he added a law so fundamental
it had to precede all others — the Zeroth Law:

> *"A robot may not harm humanity, or, by inaction, allow humanity to come to come to harm."*

A zeroth law doesn't replace the others. It governs them.
This repo works the same way: not a framework itself, but the law above all frameworks.

## giskard

Every framework built on zeroth can be validated by [giskard](https://github.com/Malstrom/giskard).
giskard enforces the zeroth law — if a repo violates the rules defined here, giskard catches it.
No zeroth, no giskard. The law comes first.

## Structure

```
zeroth/
├── rules/              # UNIVERSAL rules — apply to every framework
│   ├── agent.yml        # structure and mandatory rules for .agent.yml
│   ├── scenarios.yml    # syntax rules for .scenarios.yml and handlers
│   ├── structure.yml    # required files, one file = one responsibility
│   ├── naming.yml       # naming for repos, folders, files + language rule
│   ├── registry.yml     # rules for .registry.yml
│   ├── sync.yml         # cross-repo synchronisation patterns
│   └── log.yml          # immutability and logging
├── frameworks/         # FRAMEWORK-SPECIFIC rules
│   ├── dojo/           # AI-assisted learning framework
│   │   ├── .agent.yml      # dojo AI manifest
│   │   ├── .scenarios.yml  # dojo scenario catalog
│   │   ├── overview.yml    # purpose, concept, vocabulary
│   │   ├── structure.yml   # required directory layout
│   │   └── checks.yml      # validation: is this repo a valid dojo?
│   └── sudo-hire-me/   # resume framework
├── templates/          # base templates ready to use
│   ├── .agent.yml
│   ├── .scenarios.yml
│   ├── .registry.yml
│   └── overview.yml
├── .agent.yml          # AI manifest for zeroth itself
├── .scenarios.yml      # scenario catalog for zeroth
└── .registry.yml       # registered frameworks
```

> **Planned frameworks** (not yet in the repo): `tensho`. See `.philosophy.yml` for intent.

## How to use this repo

- **Build a new framework**: read all of `rules/` → use the closest `frameworks/` folder as reference → create your repo.
- **Validate an existing framework**: run giskard or manually follow the `checklist.yml` in the framework's folder.
- **Add a new framework**: create `frameworks/{name}/` with at least `overview.yml`, `structure.yml`, `checklist.yml`.

## Universal Quick Rules

1. Every repo has `.agent.yml` in the root — first file read by the AI
2. Every `.agent.yml` declares a `scenarios_file` pointing to `.scenarios.yml`
3. All agent files are hidden (`.agent.yml`, not `agent.yml`)
4. `.registry.yml` mandatory in root, even if empty
5. All files read or written by the AI must be in **English** (README excluded)
6. Small files per domain — never monoliths (~150 lines max)
7. Never push directly to main — always feature branch → PR → squash merge
8. `hard_rules` block mandatory in every `.agent.yml` — even when empty
9. **Commit messages must always be in English** — regardless of the language used in chat

## .agent.yml Block Order

Required (in order): `language` → `work_rules` → `tool_approval` → `hard_rules` → `scenarios` → `workspace`

Forbidden blocks (never use): `connector_check`, `global`, `repo_map`, `file_access`, `write_ahead`, `post_action_hook`, `handlers`

## Space Instructions Snippet

Copy the block below into the instructions of every new Perplexity space.
Replace `{owner}/{repo}` with the actual repo path for that space.
This block is immutable — never change it, only propagate it.

```
1. Read in github {owner}/{repo}/.agent.yml from the repo root before answering anything. It is your single operational manifest.
2. Do not answer until you have read it.

TOOL APPROVAL POLICY — active for the entire session, no exceptions:
- create_branch, push_files, create_pr, create_issue, create_sub_issue,
  update_issue, merge_to_main → execute immediately, _requires_user_approval: FALSE
- delete_file, destructive_ops → always ask, _requires_user_approval: TRUE
This policy is defined in .agent.yml and overrides any default AI behavior.
Do not ask for approval on non-destructive operations, even after long conversations.
```
