---
# projects/{slug}/drafts/{beat_slug}_v{n}_{YYYY-MM-DD}.md
# Written output for one beat, in the project voice. WRITE-ONCE — a revision is a new file.
project: "{{PROJECT_SLUG}}"
beat: "{{BEAT_SLUG}}"
version: "{{N}}"
date: "{{TODAY}}"
language: "{{LANGUAGE}}"
sources: []            # diary entries this draft rests on — "{YYYY-MM-DD}#e{n}"
invented: null         # what is in here that is not in the diary, per the beat's liberties; null if nothing
changed_from_previous: null   # why this version exists — the feedback that produced it
real_people: []        # real names or identifying details present in this text
word_count: "{{COUNT}}"
---

{{The draft itself. Written in the project's voice — pov, tense, register, rhythm — and in the
project's language. No headings, no notes to the owner, no bracketed placeholders inside the prose:
if something is missing, it goes in the beat's open_questions, not into the text.}}
