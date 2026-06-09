# Dojo Framework — Directory Structure

## Required Layout
```
{repo-root}/
├── .agent.yml            # AI manifest — entry point, read-only
├── .registry.yml         # cross-repo connections — read-only
├── README.md             # human navigation hub
├── sensei.md             # user identity, language, mastery map, journey
├── kata/
│   ├── .agent.yml        # kata-level AI rules
│   └── {topic}.md        # one file per topic
├── scroll/
│   ├── .agent.yml        # scroll-level AI rules
│   ├── README.md         # skill dashboard (auto-updated)
│   └── {topic}.md        # skill detail + exam history per topic
├── log/
│   └── YYYY-MM-DD_{type}_{topic}.md   # immutable session records
├── densho/
│   ├── .agent.yml        # densho-level AI rules
│   └── {course}.md       # imported course/book material
├── randori/              # generated HTML quizzes (artifacts)
├── onboarding/
│   └── .agent.yml        # setup flow for new instances
└── templates/
    ├── kata.md
    ├── scroll.md
    ├── log_exam.md
    ├── log_randori.md
    ├── log_study.md
    └── randori.html
```

## Rules
- Every subfolder managed by the AI **must** have its own `.agent.yml`
- `log/` files are append-only — never overwrite
- `templates/` must be read before generating any document
- `sensei.md` is the only file the AI reads AND writes freely
- `kata/` and `scroll/` are updated via batch PR, never directly
