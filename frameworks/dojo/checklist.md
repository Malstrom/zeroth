# Dojo Framework — Validation Checklist

A repo is a valid dojo instance if ALL of the following are true.

## Structure
- [ ] `.agent.yml` exists in root
- [ ] `.registry.yml` exists in root
- [ ] `sensei.md` exists in root
- [ ] `kata/` directory exists with `.agent.yml`
- [ ] `scroll/` directory exists with `.agent.yml` and `README.md`
- [ ] `log/` directory exists
- [ ] `templates/` directory exists with all 5 required templates
- [ ] `densho/` directory exists with `.agent.yml`
- [ ] `onboarding/.agent.yml` exists

## .agent.yml
- [ ] `connector_check` is the first block
- [ ] `global.language` reads from `sensei.md`
- [ ] `global.pr_strategy` is `batch_per_session`
- [ ] All 6 required scenarios are present
- [ ] All 3 required handlers are present
- [ ] `write_ahead.exam_mode` is defined
- [ ] `tool_approval.destructive_ops: true`
- [ ] `template_rule` mapping covers all 5 templates

## Behaviour
- [ ] Exam logs are committed before AI responds
- [ ] Exam logs are never overwritten (append-only)
- [ ] AI language is read from `sensei.md`, not hardcoded
- [ ] AI does not read `README.md` (human-only)
- [ ] Templates are read before generating any document
