# zeroth — kernel

> The law above all laws. Zeroth defines the rules, structure and philosophy of the system.
> It is not a product. It is the kernel.

This file is the agent entry point when working **on zeroth itself**. For the rules that propagate
to framework instances, see `rules/universal.md` — that is what framework manifests import.

## Session protocol

1. Read `.philosophy.yml` — the system model and what each framework is for.
2. Match every user message against the scenario index `.scenarios.yml` **before reasoning**.
   Matching is semantic and language-independent.
3. Read **only** the matched scenario file under `scenarios/`.
4. No match → `scenarios/unknown_scenario.yml`.

## Language

- Chat: italian.
- Files, commits, issues, PR titles and bodies: English.
- File and folder names: English, `snake_case` or hyphenated, lowercase.

## Work rules

- One branch per issue, named `{type}/{short-description}` — `feat`, `fix`, `docs`, `test`, `chore`.
- All writes to `main` go through a pull request. Squash merge.
- Never commit instance data into zeroth: frameworks are specs, instances hold the real data.

## Workspace

| path | role | access |
|---|---|---|
| `CLAUDE.md` | this file — agent entry point for zeroth | read-write |
| `.philosophy.yml` | system model, framework philosophy | read-only |
| `.scenarios.yml` | zeroth scenario index | read-only |
| `.registry.yml` | cross-repo connections | read-only |
| `.agent.yml` | legacy AI manifest — being retired, see below | read-only |
| `README.md` | human-facing hub | read-write |
| `rules/universal.md` | rules inherited by every framework instance | read-write |
| `rules/*.yml` | canonical zeroth spec rules | read-write |
| `scenarios/*.yml` | zeroth scenario files — read on match only | read-write |
| `frameworks/{name}/` | framework definitions | read-write |
| `templates/` | base templates for new framework files | read-write |

## Manifest format

`frameworks/andrew/` is the first framework with **no `.agent.yml`**: its entry point is
`frameworks/andrew/CLAUDE.md` (zeroth#361). This is the target format for every framework —
`.agent.yml` is a Perplexity-era artifact and is being retired. Until the migration is complete,
`daneel`, `dojo` and `sudo-hire-me` still carry one, and `rules/agent.yml` together with the
`.agent.yml` proxies in `rules/checks.yml` still describe it. Do not delete either while a
framework still depends on it.
