# [Goal] {goal_source_emoji} {goal_human_title} ({goal_slug})

**Source**: {goal_source_emoji} {goal_source_type} — {goal_source_ref}  
**Declared**: {date}

---

### 🔴 Critical

{critical_topics_checklist}
<!-- AI renders each topic as one of:
     - [x] `slug` — description — [kata](https://github.com/{owner}/{repo}/blob/main/kata/slug.md)   ← already_satisfied + kata exists
     - [x] `slug` — description — already satisfied                                                    ← already_satisfied, no kata yet
     - [ ] `slug` — description — [kata](https://github.com/{owner}/{repo}/blob/main/kata/slug.md)   ← missing + kata exists
     - [ ] `slug` — description                                                                         ← missing, explicitly required
     - [ ] `slug` — description *(ai inferred)*                                                         ← missing, AI-derived

     RULES:
     - [x] is set ONLY by topic_shinsa on pass. declare_goal never sets [x] except for already_satisfied.
     - already_satisfied = topic completed in .gakusei.yml at goal declaration time.
     - ALL kata links must use absolute GitHub URLs (blob/main/), never relative paths.

     goal_source_emoji legend:
       🏢 job_offer | 🧠 self_declared | 🛠️ project | 💬 interview_feedback | 📚 curriculum_gap | 🔗 cross_repo
-->

### 🟡 Important

{important_topics_checklist}

### 🟢 Later

{later_topics_checklist}

---

### Notes

{goal_notes}

---
_This issue stays open until the goal shinsa passes._  
_Opened by `declare_goal`. Closed by `goal_shinsa` on pass._
