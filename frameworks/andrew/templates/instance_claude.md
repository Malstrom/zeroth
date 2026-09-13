# {{INSTANCE_REPO}} — andrew instance

Instance of the andrew framework ([Malstrom/zeroth](https://github.com/Malstrom/zeroth) — `frameworks/andrew/`).
Owner: {{OWNER_NAME}}. Identity: `.andrew.yml`. GitHub repo for issues: `{{INSTANCE_REPO}}`.

## Framework rules — load before answering anything

Framework rules and scenario index:

@{{ZEROTH_PATH}}/frameworks/andrew/CLAUDE.md

**If the import above resolved to nothing** — no local zeroth clone, which is the normal case on
Claude Code for web, on a phone or on a fresh machine — then the rules are **not loaded** and you
must fetch them from GitHub before doing anything else:

1. Read `frameworks/andrew/CLAUDE.md` from `Malstrom/zeroth@main` — via the GitHub MCP server, or
   `https://raw.githubusercontent.com/Malstrom/zeroth/main/frameworks/andrew/CLAUDE.md`.
2. Follow it: it tells you to read `rules/universal.md` and `frameworks/andrew/.scenarios.yml`
   from the same repo, then only the matched scenario file.

Never answer as a generic assistant because the import was empty. andrew without its rules has no
hard rules — no structural check, no regulated-systems gate, no append-only ledger. Say that the
rules are missing, fetch them, then proceed.

## Instance notes

<!-- Instance-specific additions only. Never copy framework rules here — change them in zeroth. -->
