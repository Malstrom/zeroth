# Universal zeroth rules

> Rules that apply to **every framework instance**, whatever the framework.

This file is imported by each framework manifest (`frameworks/{framework}/CLAUDE.md`).
It is addressed to the agent running **inside an instance repo**, not to someone working on
zeroth itself — for that, see `CLAUDE.md` at the repo root.

## Language

- **Chat**: the language declared in the instance identity file (e.g. `.andrew.yml` → `language.chat`).
- **Files, commits, issues, labels, PR bodies**: always English. Never overridden by a framework.
- **File and folder names**: English, `snake_case`, lowercase.

## Scenario protocol

1. Match **every** user message against the framework scenario index **before reasoning**.
2. Matching is semantic and language-independent: match intent, never literal strings.
3. Preconditions are checked **before** trigger matching — scenarios whose preconditions fail are
   excluded from routing.
4. First semantic match wins: priority descending, then declaration order.
5. Read **only** the matched scenario file. Never load the whole scenario set.
6. No match → `unknown_scenario`.

### Escape triggers

These abort any active scenario and return to routing: `stop`, `cancel`, `abort`, `wrong`,
`reset`, `esci`, `annulla`. A framework may extend the list, never shorten it.

## File access modes

Every path an instance may touch is declared with one of these modes. They are contracts,
not conventions.

| mode | meaning |
|---|---|
| `read-only` | never write — writing is an error |
| `read-write` | create if missing, overwrite if it exists |
| `append-only` | create if missing, append if it exists — **never** overwrite or edit past entries |
| `write-once` | create if missing, **error** if it exists |

Corrections to `append-only` files are new entries that reference what they correct, never edits
to the original.

## Templates

Every generatable file starts from its template in `frameworks/{framework}/templates/`.
Read the template before creating the file. Placeholder format: `{{TOKEN}}`.
Never deviate from a template's structure — change the template first, then use it.

## Enums

Framework vocabularies (work types, categories, levels, statuses…) are **closed sets** declared in
`frameworks/{framework}/overview.yml`. Use only values from there. A value that is missing is a
framework change, not an improvisation.

## Cross-framework signals

Frameworks never call each other and never write to each other's repos. When a session surfaces
something that belongs to another framework, the agent **names it in chat** and proposes an action.
The owner decides. Nothing is implicit, nothing is automatic.

## Privacy

Instance repos hold real personal data. Never copy instance content into zeroth, into an issue on
a public repo, or into any other instance.
