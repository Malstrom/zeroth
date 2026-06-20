<!-- AI: before editing this file, read templates/framework_readme.md in zeroth. -->

# sudo-hire-me

> How do I find and land the job I actually want?

---

## 🧠 Why sudo-hire-me exists

A job search looks simple from the outside: apply, interview, decide. In practice it is a project that runs for weeks or months, across dozens of companies, with no single source of truth, no persistent memory, and constant emotional noise pulling your decisions in the wrong direction.

The research is clear on why this goes wrong — and what a system needs to fix it.

> ***Your pipeline lives everywhere, so it lives nowhere.***
>
> Spreadsheets, email threads, Notion boards, LinkedIn notes — state is distributed across tools that don’t talk to each other and go stale the moment you stop updating them. The brain cannot trust what it cannot verify, and stops trying. [Allen, 2001 — Getting Things Done](https://gettingthingsdone.com).

> ***Every session starts from zero because the AI has no memory.***
>
> Re-explaining your situation, your constraints, and your pipeline at the start of every chat consumes working memory that should go into actual decisions — not into reconstructing context. [Sweller, 1988](https://doi.org/10.1207/s15516709cog1202_4).

> ***When you update state, you lose history.***
>
> Overwriting a company’s status means you no longer know what happened, when, or why. Without an immutable log, a pipeline is a snapshot — not a record. Decisions made without history tend to repeat mistakes. [Event sourcing principle — Fowler, 2005](https://martinfowler.com/eaaDev/EventSourcing.html).

> ***Rejection and ghosting distort your priorities.***
>
> Emotional responses to individual events — a rejection, a slow offer, a disappointing interview — systematically bias how you evaluate the rest of your pipeline. Without a system that separates signal from noise, you optimise for how you feel, not for what makes sense. [Baumeister et al., 1998](https://doi.org/10.1037/1089-2680.2.1.3); [Slovic et al., 2002](https://doi.org/10.1177/1529100612452544).

The risk with AI is that it makes you faster at the wrong things — generating cover letters, drafting emails, rehearsing answers — without ever building a coherent view of your search. You stay busy but not strategic.

sudo-hire-me is designed to fix the system, not the symptoms. The AI knows your full pipeline, your profile, your constraints, and your history — from the first session to the last. Every event is written to an immutable log. Nothing is overwritten. The next session starts exactly where the last one ended. The goal is not to apply faster. The goal is to make better decisions about where to invest your time — and land the right job.

---

## ⚙️ How it works

- Your profile, stack, targets, and constraints live in one file in the instance repo.
- Every company you track has its own file — current state, last action, next step.
- Every event (application sent, interview completed, offer received, rejection) is written to an immutable log — nothing is ever overwritten.
- At the start of every session the AI reads your full pipeline and your profile — no re-briefing, no context loss.
- The AI acts through declared scenarios — it does not improvise. Every action is predictable and auditable.
- You can pick up any session — days or weeks later — and the AI knows exactly where you are and what needs to happen next.

---

## 🚀 How to start

Create a new sudo-hire-me instance using the `spawn` scenario from your zeroth Perplexity Space.
