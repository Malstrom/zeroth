# sudo-hire-me

AI-native framework for active job search management.
Spec lives in [Malstrom/zeroth](https://github.com/Malstrom/zeroth) under `frameworks/sudo-hire-me/`.

## What sudo-hire-me does

- Tracks the full job search pipeline (companies, applications, events)
- Immutable event log: every pipeline event is written once and never edited
- Scenario-driven: every AI action is declared in `.scenarios.yml`
- Profile and assets managed in the instance repo, spec managed here in zeroth

## Repo layout

```
{instance}/
├── .agent.yml           # AI manifest and entry point
├── .scenarios.yml       # scenario catalog (index format)
├── .registry.yml        # cross-repo connection map
├── README.md            # this file (human navigation hub)
├── igor.yml             # candidate profile (name, stack, targets, constraints)
├── hunt/                # active job search
│   └── pipeline/
│       ├── {company_slug}.yml          # current state per company
│       └── log/{company_slug}/
│           └── YYYY-MM-DD_{event_slug}.yml  # immutable event log
└── assets/              # profile photos and attachments (read-only)
```

> Templates live in zeroth under `frameworks/sudo-hire-me/templates/` — read cross-repo, never copied to the instance.

## Spec & rules

- Structure: [`frameworks/sudo-hire-me/structure.yml`](frameworks/sudo-hire-me/structure.yml)
- Scenarios: [`frameworks/sudo-hire-me/.scenarios.yml`](frameworks/sudo-hire-me/.scenarios.yml)
- Agent manifest: [`frameworks/sudo-hire-me/.agent.yml`](frameworks/sudo-hire-me/.agent.yml)
- Zeroth rules: [`rules/`](../../rules/)
