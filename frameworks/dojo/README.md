<!-- AI: before editing this file, read templates/framework_readme.md in zeroth. -->

# dojo

> What do I know how to do?

---

## 🧠 Why dojo exists

Most people study with books or courses. The problem is structural: a book contains 100% of the information, but you already know most of it. You read everything to find the 10% that is actually new to you. It is slow, passive, and easy to forget.

The research is clear on why this fails — and what works instead.

***You remember what you retrieve, not what you read.***

Recalling information actively beats re-reading it every time — the act of retrieval itself is what builds durable memory. [Roediger & Karpicke, 2006](https://doi.org/10.1177/1745691612443552).

***You forget everything you don’t revisit at the right moment.***

Memory decays on a predictable curve. Reviewing at increasing intervals — just before you forget — is the most efficient way to retain knowledge long-term. [Ebbinghaus, 1885](https://psychclassics.yorku.ca/Ebbinghaus/index.htm); [Cepeda et al., 2006](https://doi.org/10.1111/j.1467-8721.2007.00476.x).

***You only understand something when you can explain it.***

Connecting new knowledge to what you already know, and being forced to articulate it, produces far deeper comprehension than passive absorption. [Chi et al., 1994](https://doi.org/10.1207/s1532690xci1204_1).

***Knowledge learned out of context doesn’t transfer.***

What you study in a course feels clear until you face a real problem — and don’t recognise it. Learning anchored to real situations and your own context transfers. Abstract learning often doesn’t. [Lave & Wenger, 1991](https://doi.org/10.1017/CBO9780511815355); [Morris et al., 1977](https://doi.org/10.1037/0278-7393.3.5.519).

***You don’t know what you don’t know.***

People systematically overestimate how well they understand something after reading it passively. Without an external map of your actual knowledge, you study the wrong things. [Kruger & Dunning, 1999](https://doi.org/10.1037/0022-3514.77.6.1121); [Bjork et al., 2013](https://doi.org/10.1016/j.intell.2013.01.004).

***Isolated knowledge is useless knowledge.***

A course here, a book there, notes saved somewhere else — none of it connects. Understanding deepens when new knowledge is anchored to what you already know across domains. [Ausubel, 1968](https://www.worldcat.org/title/educational-psychology-a-cognitive-view/oclc/396748); [Siemens, 2005](https://doi.org/10.3217/zfhe-2-05-01).

The risk with AI is the opposite trap: you get the answer instantly, but you never build the knowledge. You become faster but shallower. More dependent, not more capable.

dojo is designed to avoid both failure modes. The AI acts as a sensei, not a search engine. It does not give you the answer — it works out what you already know and what you do not, then operates only on the gap. Every session builds on the last. Everything is saved to GitHub, so the AI never forgets who you are, what you have studied, and how far you have come. The knowledge is yours, persistent, always accessible, never locked inside a chat that disappears.

The goal is not to study faster. The goal is to become someone who actually knows things — and keeps knowing them.

---

## ⚙️ How it works

- You study inside a Perplexity Space backed by a dojo instance repo on GitHub.
- The AI reads your knowledge state at the start of every session — what you know, what you have studied, how you performed.
- The session works on the delta: what you do not know yet, or what you know weakly.
- After each concept, the AI drills you with open questions (randori) — no score, immediate feedback.
- When a topic is solid, you take a formal exam (shinsa) — scored, no hints.
- At the end of every session, the AI writes a structured trace to the repo: topics covered, results, updated knowledge state.
- The repo is the persistent memory. The next session starts from exactly where the last one ended.
- You can have multiple dojo instances — one per domain, one per language, one per skill.

---

## 🚀 How to start

Create a new dojo instance using the `spawn` scenario from your zeroth Perplexity Space.
