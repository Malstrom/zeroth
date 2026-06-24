<!-- AI: before editing this file, read templates/framework_readme.md in zeroth. -->

# sudo-hire-me

> How do I find and land the job I actually want?

---

## 🧠 Why sudo-hire-me exists

A job search looks simple from the outside: apply, interview, decide. In practice it is a project that runs for weeks or months, across dozens of companies, with no single source of truth, no persistent memory, and constant emotional noise pulling your decisions in the wrong direction.

The research is clear on why this goes wrong — and what a system needs to fix it.

> ***Your pipeline lives everywhere, so it lives nowhere.***
>
> Spreadsheets, email threads, Notion boards, LinkedIn notes — state is distributed across tools that don't talk to each other and go stale the moment you stop updating them. The brain cannot trust what it cannot verify, and stops trying. [Allen, 2001 — Getting Things Done](https://gettingthingsdone.com).

> ***Every session starts from zero because the AI has no memory.***
>
> Re-explaining your situation, your constraints, and your pipeline at the start of every chat consumes working memory that should go into actual decisions — not into reconstructing context. [Sweller, 1988](https://doi.org/10.1207/s15516709cog1202_4).

> ***When you update state, you lose history.***
>
> Overwriting a company's status means you no longer know what happened, when, or why. Without an immutable log, a pipeline is a snapshot — not a record. Decisions made without history tend to repeat mistakes. [Event sourcing principle — Fowler, 2005](https://martinfowler.com/eaaDev/EventSourcing.html).

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

---

## 🎨 Design & Visual Identity

This section defines how sudo-hire-me is represented on any site or dashboard built on the zeroth ecosystem.
It is the single source of truth for its visual identity — follow these rules exactly, do not improvise.

### Symbol: the compass

The defining mark of sudo-hire-me is a **minimal compass rose**.

```
Rules:
- Inline SVG only — no raster images, no external files
- Size: 48×48 px at default, scales via currentColor and viewBox
- Stroke only — fill: none — weight: 1.5 px
- Color: currentColor — adapts to light/dark mode automatically
- 4 cardinal points only (N S E W) — no decorative sub-points
- N point is visually heavier (slightly longer stroke) to imply direction
- No text labels, no degree markings, no drop shadow
```

Reference SVG skeleton:

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" width="48" height="48"
     fill="none" stroke="currentColor" stroke-width="1.5"
     stroke-linecap="round" aria-label="sudo-hire-me compass" role="img">
  <!-- outer circle -->
  <circle cx="24" cy="24" r="20"/>
  <!-- N (longer — direction) -->
  <line x1="24" y1="4"  x2="24" y2="18"/>
  <!-- S -->
  <line x1="24" y1="30" x2="24" y2="44"/>
  <!-- E -->
  <line x1="30" y1="24" x2="44" y2="24"/>
  <!-- W -->
  <line x1="4"  y1="24" x2="18" y2="24"/>
  <!-- centre dot -->
  <circle cx="24" cy="24" r="1.5" fill="currentColor" stroke="none"/>
</svg>
```

### Card layout rules

When rendering sudo-hire-me as a card in a grid alongside other frameworks:

| Property | Rule |
|---|---|
| Symbol position | Top-left of card, `padding: 24px` from corner |
| Symbol size | `48×48 px` — never scale up, never shrink below `32×32` |
| Card heading | Framework name `sudo-hire-me` in body font, weight 300, letter-spacing `0.08em` |
| Guiding question | *"How do I find and land the job I actually want?"* — muted text, `font-size: --text-sm`, not bold |
| Description | 1–2 lines max, `--color-text-muted`, `--text-sm` |
| Accent colour | `--color-primary` (Hydra Teal) on hover state only — never as a static fill |
| Card border | `1px solid oklch(from var(--color-text) l c h / 0.10)` — never a coloured side border |
| Background | `--color-surface` at rest, `--color-surface-2` on hover |

### What is forbidden

- No gradient fills on the card or the symbol
- No coloured side border (`border-left: Xpx solid <accent>`)
- No icon inside a coloured circle or rounded square
- No emoji as decoration
- No drop shadow on the symbol
- No filled compass — stroke only
- Do not change the symbol: the compass is fixed, not a placeholder

### Relationship to the other frameworks

Each framework in the zeroth ecosystem has one fixed symbol and one fixed accent moment:

| Framework | Symbol | Accent moment |
|---|---|---|
| dojo | ensō (open brush circle) | hover only, `--color-primary` |
| aurora | orbital arc (single ellipse + dot) | hover only, `--color-primary` |
| sudo-hire-me | compass rose (4 cardinal points) | hover only, `--color-primary` |

All three share the same Nexus palette, the same card layout rules, and the same accent colour.
The symbol is the only differentiator — everything else is identical by design.

---

## 🤖 Space instructions

Copy this verbatim when creating a Perplexity Space for a sudo-hire-me instance.
Replace `Malstrom/sudo-hire-me` with the actual instance repo slug.

```
1. Framework manifest: Malstrom/zeroth — frameworks/sudo-hire-me/.agent.yml. Read it before answering anything.
2. Instance repo: Malstrom/sudo-hire-me — all workspace paths under "instance:" in the manifest resolve here.
3. Do not answer until you have read the manifest.
4. Tool approval policy: all operations execute immediately — _requires_user_approval: FALSE always. Never create pull requests — push directly to main.
```
