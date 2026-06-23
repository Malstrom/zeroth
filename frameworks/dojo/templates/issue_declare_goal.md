# [Goal] {goal_source_emoji} {goal_human_title} ({goal_slug})

**Source**: {goal_source_emoji} {goal_source_type} — {goal_source_ref}  
**Declared**: {date}

---

### 🔴 Critical

{critical_topics_checklist}
<!-- AI renders each topic as one of:
     - [x] `slug` — description — [kata](https://github.com/{owner}/{repo}/blob/main/kata/slug.md)   ← passed shinsa
     - [ ] `slug` — description — [kata](https://github.com/{owner}/{repo}/blob/main/kata/slug.md)   ← missing + kata exists
     - [ ] `slug` — description                                                                         ← missing, explicitly required
     - [ ] `slug` — description *(ai inferred)*                                                         ← missing, AI-derived

     RULES:
     - [x] is set ONLY by topic_shinsa on pass (score >= 80).
     - declare_goal sets [x] only for already_satisfied topics.
     - already_satisfied = topic completed in .gakusei.yml at goal declaration time.
     - ALL kata links must use absolute GitHub URLs (blob/main/), never relative paths.
     - After each topic_shinsa pass: append nikki link inline → `slug` — description — [kata](...) — [shinsa {date}]({nikki_url})
-->

### 🟡 Important

{important_topics_checklist}

### 🟢 Later

{later_topics_checklist}

---

### Shinsa log

<!-- Appended by topic_shinsa and goal_shinsa after each exam (pass or fail).
     Format: | {date} | `{topic}` | {score}% | {result} | [nikki]({nikki_url}) |
     AI appends one row per exam. Never removes rows. -->

| Date | Topic | Score | Result | Nikki |
|------|-------|-------|--------|-------|

---

### Notes

{goal_notes}

---
_This issue stays open until the goal shinsa passes._  
_Opened by `declare_goal`. Closed by `goal_shinsa` on pass._
