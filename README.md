# zeroth

> The zeroth law stands above all others.

Spec and foundational rules for building AI-native frameworks in the Malstrom ecosystem.
Every framework that respects `zeroth` can be automatically validated by giskard.

## Why "zeroth"

Isaac Asimov introduced the Three Laws of Robotics in 1942.
Decades later, in *Robots and Empire* (1985), he added a law so fundamental
it had to precede all others — the Zeroth Law:

> *"A robot may not harm humanity, or, by inaction, allow humanity to come to harm."*

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
│   │   └── checklist.yml   # validation: is this repo a valid dojo?
│   ├── tensho/         # GTM tracker
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
8. `post_action_hook` and `handlers` are mandatory blocks in every `.agent.yml`, even when empty

## .agent.yml Block Order

Required (in order): `connector_check` → `global` → `repo_map` → `file_access` → `tool_approval` → `write_ahead` → `scenarios` → `post_action_hook` → `handlers`

Optional (template only): `template_rule`
