# Zeroth — Naming Rules

## Fundamental Rule
Names must be **evocative**, not descriptive. The name suggests the essence, not the function.

## Language Rule
**All files read or written by an AI agent must be in English.** This applies to:
- `.agent.yml` and `.registry.yml` — always English
- `kata/`, `scroll/`, `log/`, `densho/`, `templates/` content — always English
- Any file declared in `repo_map` inside `.agent.yml` — always English

Exception: files that are explicitly human-only (e.g. `README.md`) may be in any language.

## Repo
- Maximum 2 words
- Lowercase, separator: hyphen `-`
- Evocative, not technical
- Valid examples: `dojo`, `tensho`, `zeroth`, `sudo-hire-me`
- Invalid examples: `ai-learning-framework`, `skill-tracker-v2`, `my-repo`

## Folders
- Maximum 2 words
- Lowercase, no separator if possible
- Evocative of content, not technical
- Valid examples: `kata/`, `scroll/`, `forge/`, `hunt/`, `log/`
- Invalid examples: `training-data/`, `session-logs/`, `user-profiles/`

## Files
- Lowercase, separator: hyphen `-` or underscore `_` (consistent per repo)
- Special AI files: always with dot prefix — `.agent.yml`, `.registry.yml`
- Identity files: lowercase proper name (e.g. `sensei.md`, `igor.md`)
- Logs: format `YYYY-MM-DD_{type}_{topic}.md`

## Reserved Special Files
| File | Role | AI Access |
|------|------|-----------|
| `.agent.yml` | AI manifest, entry point | Read-only |
| `.registry.yml` | Cross-repo connection map | Read-only, never proactive |
| `sensei.md` | User identity and profile | Read-write |
| `README.md` | Human navigation hub | Write-only (AI does not read) |
