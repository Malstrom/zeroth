<!-- frameworks/daneel/templates/issue_body.md -->
<!-- Template for GitHub issue body created by ingest_task scenario. -->
<!-- All fields are parsed by downstream scenarios (work_session, draft_reply, close_task). -->
<!-- Use exact section headers — scenarios match on them. -->

## Task
{{Raw description of what was requested. Preserve original wording where possible.}}

## Source
- type: {{email | chat | meeting | other}}
- contact: {{contact_slug — ref to contacts/{slug}.yml | null}}
- received: {{YYYY-MM-DD}}
- deadline: {{YYYY-MM-DD | null}}

## Work type
{{work_type — must be a value from work_type enum in overview.yml}}

## Prior art
- playbook: {{client playbook name | root playbook name | none}}
- past issues: {{#123 one-line description, #456 one-line description | none}}

## Notes
{{Additional context, constraints, documents received, special instructions.}}
{{Omit section if empty.}}
