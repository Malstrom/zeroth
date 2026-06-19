# aurora

AI-native framework for professional work management.
Spec lives in [Malstrom/zeroth](https://github.com/Malstrom/zeroth) under `frameworks/aurora/`.

## What aurora does

- Manages clients, tasks, contacts, playbooks and daily work logs
- All AI-facing data is YAML; all human-facing output is Markdown
- Write-ahead logging: entries are immutable once written
- Scenario-driven: every AI action is declared in `.scenarios.yml`

## Repo layout

```
aurora_{instance}/
├── .aurora.yml          # user profile (owner, roles, domains, language, timezone)
├── .agent.yml           # AI manifest and entry point
├── .scenarios.yml       # scenario catalog
├── .registry.yml        # cross-repo connection map
├── README.md            # this file (human navigation hub, AI does not read)
├── clients/             # one subfolder per client
│   └── {slug}/
│       ├── context.yml
│       ├── summary.md
│       ├── inbox/
│       ├── output/
│       ├── playbooks/
│       └── log/
├── contacts/            # external and internal contact profiles
├── playbooks/           # step-by-step recurring work instructions
└── templates/           # read cross-repo from zeroth, never copied here
```

## Spec & rules

- Structure: [`frameworks/aurora/structure.yml`](frameworks/aurora/structure.yml)
- Scenarios: [`frameworks/aurora/.scenarios.yml`](frameworks/aurora/.scenarios.yml)
- Agent manifest: [`frameworks/aurora/.agent.yml`](frameworks/aurora/.agent.yml)
- Zeroth rules: [`rules/`](../../rules/)
