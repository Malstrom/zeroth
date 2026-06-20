<!-- AI: before editing this file, read templates/framework_readme.md in zeroth. -->

# aurora

> What have I done, for whom, and what do I need to do next?

---

## 🧠 Why aurora exists

Knowledge work is invisible. You spend years working for clients, solving problems, making decisions — and almost none of it leaves a trace you can actually use. The next time you need that context, it is gone. You start over.

This is not a discipline problem. It is a system problem.

> ***Professional memory does not persist on its own.***
>
> The brain is not designed to store what it has done — it is designed to do things. We naturally delegate memory to external systems. When no system exists, the memory does not exist either. [Wegner, 1987 — Transactive Memory](https://doi.org/10.1521/soco.1987.5.3.277).

> ***Reconstructing context burns the capacity you need for actual work.***
>
> Every time you re-read old emails, scroll through notes, or re-brief an AI on who a client is and what happened last time, you consume working memory that should go into the task at hand. [Sweller, 1988 — Cognitive Load Theory](https://doi.org/10.1207/s15516709cog1202_4).

> ***Work done without a record loses its value over time.***
>
> Organisations and individuals lose compounding value when past knowledge is not retrievable. Solving the same problem twice, failing to reuse a solution, missing a pattern across clients — these are not mistakes, they are the inevitable result of no memory system. [Walsh & Ungson, 1991 — Organizational Memory](https://doi.org/10.2307/258607).

> ***Switching to a logging tool is a cost most people stop paying.***
>
> Every time you leave your work to write a note in another tool, you pay a measurable cognitive switching cost. Most people stop logging within weeks — not because they are lazy, but because the friction is real. [Rubinstein et al., 2001 — Executive Control of Cognitive Processes](https://doi.org/10.1037/0096-1523.27.4.763).

The risk with AI is that it makes the problem feel solved without solving it. You can ask an AI anything — but if the AI has no memory of what you have done, you are just asking a very fast stranger. Every session starts from zero.

autora is designed to be the memory layer that makes AI actually useful over time. The AI reads your full work history at the start of every session — clients, contacts, past work, open tasks. It accompanies you while you work, logs what happens, and builds a retrievable record of everything. The next session starts exactly where the last one ended. The goal is not to track work. The goal is to never lose the context of your work again.

---

## ⚙️ How it works

- Your profile, clients, contacts, and active work all live in the instance repo.
- At the start of every session the AI reads your full context — no re-briefing required.
- You ingest a task: the AI reads it, links it to the right client, and prepares the work.
- You work: the AI accompanies you, produces outputs, drafts replies, runs playbooks.
- At the end of every session the AI writes an immutable log entry — what was done, for whom, what was decided.
- When you need past context, the AI recalls it from the log — across clients, topics, or time ranges.
- Indexes are generated automatically so recall stays fast even across years of work.

---

## 🚀 How to start

Create a new aurora instance using the `spawn` scenario from your zeroth Perplexity Space.
