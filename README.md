# zeroth

> The zeroth law stands above all others.

Spec and foundational rules for building AI-native frameworks in the Malstrom ecosystem.
Every framework that respects `zeroth` can be automatically validated.

## Structure

```
zeroth/
├── rules/              # UNIVERSAL rules — apply to every framework
│   ├── agent.md        # structure and mandatory rules for .agent.yml
│   ├── structure.md    # required files, one file = one responsibility
│   ├── naming.md       # naming for repos, folders, files + language rule
│   ├── registry.md     # rules for .registry.yml
│   ├── sync.md         # cross-repo synchronisation patterns
│   └── log.md          # immutability and logging
├── frameworks/         # FRAMEWORK-SPECIFIC rules
│   ├── dojo/           # AI-assisted learning framework
│   │   ├── overview.md     # purpose, concept, vocabulary
│   │   ├── structure.md    # required directory layout
│   │   ├── agent.md        # dojo-specific .agent.yml rules
│   │   └── checklist.md    # validation: is this repo a valid dojo?
│   ├── tensho/         # GTM tracker
│   ├── sudo-hire-me/   # resume framework
│   └── synca/          # [to be defined]
└── templates/          # base templates ready to use
    ├── .agent.yml
    └── .registry.yml
```

## How to use this repo

- **Build a new framework**: read all of `rules/` → use the closest `frameworks/` folder as reference → create your repo.
- **Validate an existing framework**: use the `checklist.md` in the framework’s folder under `frameworks/`.
- **Add a new framework**: create `frameworks/{name}/` with at least `overview.md`, `structure.md`, `agent.md`, `checklist.md`.

## Universal Quick Rules

1. Every repo has `.agent.yml` in the root — first file read by the AI
2. Every subfolder managed by the AI has its own `.agent.yml`
3. All agent files are hidden (`.agent.yml`, not `agent.yml`)
4. `.registry.yml` mandatory in root, even if empty
5. All files read or written by the AI must be in **English**
6. Small files per domain — never monoliths (~150 lines max)

## Registered Frameworks

| Framework | Repo | Type | Status |
|-----------|------|------|--------|
| dojo | [Malstrom/dojo](https://github.com/Malstrom/dojo) | AI learning | ✅ reference impl |
| tensho | [Malstrom/tensho](https://github.com/Malstrom/tensho) | GTM tracker | ⚠️ rules WIP |
| sudo-hire-me | [Malstrom/sudo-hire-me](https://github.com/Malstrom/sudo-hire-me) | resume | ⚠️ rules WIP |
| synca | [Malstrom/synca](https://github.com/Malstrom/synca) | TBD | ⚠️ rules WIP |
