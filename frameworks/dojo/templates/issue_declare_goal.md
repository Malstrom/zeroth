# 🎯 Goal: {goal_slug}

**Source**: {goal_source_emoji} {goal_source_type} — {goal_source_ref}  
**Declared**: {date}

---

### 🔴 Critical

{critical_topics_checklist}
<!-- AI renders each topic as one of:
     - [x] `slug` — description — [kata](kata/slug.md)              ← kata exists
     - [x] `slug` — description — already satisfied                  ← passed, no kata yet
     - [ ] `slug` — description                                       ← explicitly required
     - [ ] `slug` — description *(ai inferred)*                       ← AI-derived
     topic_shinsa updates [x] and posts a comment with kata link on pass.
     goal_source_emoji: 🏢 job_offer | 🧠 self_declared | 🛠️ project | 💬 interview_feedback | 📚 curriculum_gap | 🔗 cross_repo
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
