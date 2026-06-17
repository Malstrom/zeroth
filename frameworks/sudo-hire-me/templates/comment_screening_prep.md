<!-- Template for screening_prep scenario end-of-session comment.
     Used via issue: comment: in .scenarios.yml.
     Placeholders replaced at runtime by the scenario.

     AGENT RULES:
     - {all_questions_table}: include EVERY question asked, regardless of type
       (personal, recruiter, technical). One row per question. No exceptions.
     - {final_answers}: one answer per question, in the same order as the table.
       Count must match. If a question has no final answer, write TBD.
     - Do NOT split questions across sections (e.g. technical here, recruiter elsewhere).
-->

## 🎭 Screening prep — {date}

**Round:** {round_name} (simulato) | **Recruiter:** {recruiter_name} ({recruiter_role})

---

### 📖 Storia personale — {story_score}/10

{story_feedback}

---

### 🛠️ Tutte le domande ({question_count} totali)

<!-- Include ALL questions: personale, recruiter, tecnica. No filtering. -->

| # | Tipo | Domanda | Esito | Note |
|---|---|---|---|---|
{all_questions_table}

---

### 🎯 Fit feedback

{fit_feedback}

---

### 📋 Risposte finali da usare domani ({language})

<!-- One entry per question row above, same order. Count must match {question_count}. -->

{final_answers}

---

### 📋 Da ricordare domani

{checklist}

---

_Prep session {date}_
