# {{INSTANCE_REPO}}

> What house do I want, and how do I get there?

Private [andrew](https://github.com/Malstrom/zeroth/tree/main/frameworks/andrew) instance of {{OWNER_NAME}}.

## Houses

| house | relation | open differences | open projects |
|---|---|---|---|
| {{house}} | {{relation}} | {{n}} | {{n}} |

## How to use

Open Claude Code in this folder and just talk: "I want to build the kitchen",
"I borrowed Mario's circular saw", "I paid 84 € at Leroy Merlin", "which drill should I buy?".
andrew reads `CLAUDE.md`, recognizes the scenario and does the rest.

## Structure

```
houses/{slug}/   house data, target plans, rooms, tools, stock, projects, purchases, ledger, docs, log
contacts/        lenders, craftsmen, suppliers
playbooks/       procedures learned on closed projects
```
