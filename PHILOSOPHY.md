# Philosophy

🇷🇺 [Русский](docs/ru/PHILOSOPHY.md)

## The Asimov Metaphor

The names in this ecosystem are not random. They come from Isaac Asimov's robot universe — each one chosen because the metaphor is exact.

**zeroth** is named after the Zeroth Law — the law above all laws. It defines the rules, structure, and philosophy for the entire system. It is not a product. It is the kernel.

**giskard** is the enforcer. A separate active repo ([Malstrom/giskard](https://github.com/Malstrom/giskard)), triggered when zeroth changes — rule updated, framework added. It verifies that all framework instances remain compliant with the new rules. Giskard is not a framework. It has no scenarios. It produces no content. It cannot be seen; nothing is valid without its approval.

**frameworks** are the robots: dojo, daneel, sudo-hire-me, tensho, andrew. They act, produce, and remember — within the laws defined by zeroth. Each framework is one dimension of a person's life — professional or personal.

**instances** are individual repos spawned from a framework. They are not a person — they are a slice of a person's life: one domain, one purpose, one continuous trace. A person may have multiple instances across multiple frameworks.

---

## Framework Philosophy

### dojo

> *"What do I know how to do?"*

Dojo is not an app or a web UI. It is a conversation that leaves a trace. The study happens inside a Perplexity chat session — GitHub is the persistent memory. The AI is the sensei. The student studies. The repo remembers everything so the AI never forgets who the student is, what they have studied, and how far they have come.

Dojo is the single source of truth for knowledge across the entire system. Other frameworks query it. None overwrite it.

### daneel

> *"How do I work, and with whom?"*

Daneel is not a task manager. Its goal is to never lose context and to recognize patterns across clients and situations. The AI reads the daily work log and surfaces connections — similar problems, recurring communication styles, reusable approaches. The value is not in tracking what was done, but in making past work available when it is needed.

### sudo-hire-me

> *"How do I present who I am professionally?"*

Help anyone build their professional narrative from real skills and work history.

### tensho *(planned)*

> *"Is this idea actually feasible for me?"*

Validate an idea against the owner's real capabilities and operational patterns. No repo exists yet — framework definition has not started.

### andrew

> *"What house do I want, and how do I get there?"*

Andrew is not a shopping list or a renovation planner. It keeps the house as designed and what is different today; every project exists to close part of that gap. The AI is the foreman: it plans, estimates, guides purchases, keeps the books, and never lets a structural or regulated job start without the right checks.

Named after Andrew Martin, Asimov's *Bicentennial Man* — the household robot who discovered woodworking and built the furniture of the house he lived in.

---

## Cross-Framework Principle

Frameworks do not call each other directly. They communicate through zeroth via `.registry.yml`. Cross-framework signals are conversational: the AI surfaces them in chat during a session, the user decides whether to act. No automatic writes across repos — ever.

Specific flows between frameworks are defined incrementally as each framework is fully specified. When a connection is recognized during a session, the AI names it in chat and proposes an action. The user decides. Nothing is implicit.
