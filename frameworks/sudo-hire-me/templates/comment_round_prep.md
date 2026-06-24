<!-- source: https://raw.githubusercontent.com/Malstrom/zeroth/main/frameworks/sudo-hire-me/templates/comment_round_prep.md -->
<!-- Template for round_prep scenario end-of-session comment.
     Used via issue: comment: from: in round_prep.yml.
     Placeholders replaced at runtime by the scenario.

     AGENT RULES:
     - {{all_questions_table}}: include EVERY question asked, regardless of type
       (personal, recruiter, soft, technical, architecture, leadership, strategy).
       One row per question. No exceptions.
     - {{final_answers}}: one answer per question, in the same order as the table.
       Count must match {{question_count}}. If a question has no final answer, write TBD.
     - Do NOT split questions across sections.
-->

## 🎯 Round prep — {{round_type}} — {{date}}

**Round:** {{round_name}} (simulato) | **Interviewer:** {{interviewer_name}} ({{interviewer_role}})

---

### 📖 Storia personale — {{story_score}}/10

{{story_feedback}}

---

### 🛠️ Tutte le domande ({{question_count}} totali)

<!-- Include ALL questions. No filtering. -->

| # | Tipo | Domanda | Esito | Note |
|---|---|---|---|---|
{{all_questions_table}}

---

### 🎯 Fit feedback

{{fit_feedback}}

---

### 📋 Risposte finali da usare domani ({{language}})

<!-- One entry per question row above, same order. Count must match {{question_count}}. -->

{{final_answers}}

---

### 📋 Da ricordare domani

{{checklist}}

---

_Prep session {{date}}_
