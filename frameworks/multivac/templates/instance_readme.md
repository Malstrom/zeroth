# {{INSTANCE_REPO}}

> What paperwork exists, and what state is each administrative process in?

Private [multivac](https://github.com/Malstrom/zeroth/tree/main/frameworks/multivac) instance of
{{OWNER_NAME}}. Holds identity documents and administrative processes for {{OWNER_NAME}} and close
family. **This repo must stay private.**

## People

| person | relation | documents | open processes |
|---|---|---|---|
| {{person}} | {{relation}} | {{n}} | {{n}} |

## How to use

Open Claude Code in this folder and just talk: "aggiungi mia madre", "ho rinnovato il passaporto",
"voglio avviare la richiesta di cittadinanza per mia madre", "a che punto è la pratica X?".
multivac reads `CLAUDE.md`, recognizes the scenario and does the rest.

## Structure

```
people/{slug}/person.yml       identity data
people/{slug}/vault/           documents — write-once, one file per issue/renewal
people/{slug}/docs/            scans and attachments
people/{slug}/processes/       administrative processes — state + append-only history
people/{slug}/log/             paperwork diary
```
