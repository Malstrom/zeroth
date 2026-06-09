# Dojo Framework — Overview

## Purpose
An opinionated AI-assisted learning framework. The repo is the source of truth. The AI is the sensei. The user is the student.

## Core Concept
Learning happens through a cycle: **study → drill → exam → track**. Every step is recorded, immutable, and queryable by the AI.

## Vocabulary
| Term | Meaning |
|------|---------|
| `kata` | Unit of knowledge: theory + snippets + flashcards for one topic |
| `scroll` | Mastery tracker: exam history + current level per topic |
| `randori` | Free-drill session: AI generates quiz, user answers, weak spots surfaced |
| `densho` | Source material: imported course/book structured by chapter |
| `sensei` | User identity file: language, mastery map, learning journey |
| `log` | Immutable session record: exam, randori, or study session |
| `onboarding` | First-run setup flow |

## Key Principles
- One repo per student instance (fork of `dojo-framework`)
- AI reads `.agent.yml` at session start — no exceptions
- Exam logs are immutable: commit before responding, never overwrite
- Mastery state lives in `sensei.md` + `scroll/` — not in the AI's memory
