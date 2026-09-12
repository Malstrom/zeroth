<!-- AI: before editing this file, read templates/framework_readme.md in zeroth. -->

# andrew

> What house do I want, and how do I get there?

---

## 🧠 Why andrew exists

Renovating a house is a long chain of decisions — what to change, how, by whom, with which tools, at what cost. Most of them are taken on the fly and forgotten: measurements live in an app, receipts in a drawer, tools in someone else's garage, and nobody knows what the house has really cost.

> ***Your own project will take longer than you think.***
>
> People underestimate how long their own tasks will take, even when they remember that similar past tasks ran late. [Buehler, Griffin & Ross, 1994](https://doi.org/10.1037/0022-3514.67.3.366).

> ***Building estimates are too low as a rule, not by accident.***
>
> Across hundreds of construction projects, cost overruns are the norm and have not improved in decades. [Flyvbjerg, Holm & Buhl, 2002](https://doi.org/10.1080/01944360208976273).

> ***Good estimates come from what really happened, not from the plan.***
>
> Forecasts improve when they are anchored to the actual outcomes of similar past projects instead of the details of the current one. [Flyvbjerg, 2006](https://doi.org/10.1177/875697280603700302).

> ***You overvalue what you build yourself.***
>
> People place a higher value on things they assembled with their own hands — a bias that quietly tilts the choice between doing it yourself and hiring someone. [Norton, Mochon & Ariely, 2012](https://doi.org/10.1016/j.jcps.2011.08.002).

The AI trap: ask a chatbot "how much does a kitchen cost?" and you get a confident, generic number — detached from your walls, your skills, your tools and what you already spent. It makes the planning fallacy faster, not smaller.

andrew keeps the house you want, the house you have, and the real record of what every job cost and how long it took — so each decision is taken on your data, and every new estimate learns from the last project.

---

## ⚙️ How it works

- The target house comes from your plan (e.g. a MagicPlan export); each room records what is different today.
- Every difference is closed by a project; the gap between the house you have and the house you want is always visible.
- For each project the AI proposes options — full DIY, mixed, professionals, or buying finished products — each with a cost estimate by category.
- Tools are tracked in the house where they are stored, including what you borrowed, rented or lent.
- Before buying, the AI checks what you already own, what you could borrow or rent, compares products and computes quantities of consumables from your real measurements.
- Every euro spent on the house — purchase, running costs, works — goes into an append-only ledger; project costs are computed from it.
- Structural and regulated work (load-bearing walls, electrical and gas systems) never starts without the right checks and professionals.
- When a project closes, what you learned becomes a playbook for the next house.

---

## 🚀 How to start

Create a new andrew instance using the `spawn` scenario from zeroth, then open Claude Code in the instance folder — `CLAUDE.md` loads the framework automatically.
