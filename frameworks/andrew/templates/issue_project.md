<!-- frameworks/andrew/templates/issue_project.md -->
<!-- GitHub issue body for a project, created by plan_project. -->
<!-- Section headers are parsed by other scenarios — keep them exact. -->

## Project
{{PROJECT_TITLE}} — `houses/{{HOUSE_SLUG}}/projects/{{PROJECT_SLUG}}.yml`

## Closes
{{- rooms/{room}.yml → {diff_id}: description (one line per diff)}}

## Options
| id | option | estimate (EUR) | requires |
|---|---|---|---|
| {{a}} | {{title}} | {{total}} | {{requires | none}} |

## Chosen option
{{option id + reason | not decided yet}}

## Checklist
### Tools
- [ ] {{tool — in house / missing / borrowed until YYYY-MM-DD}}
### Materials
- [ ] {{material — quantity}}
### Tasks
- [ ] {{task id — title — execution}}

## Budget
{{EUR | none}}
