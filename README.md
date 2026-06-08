# zeroth

> The zeroth law stands above all others.

Spec e regole fondamentali per costruire framework AI-native compatibili con l'ecosistema Malstrom.
Ogni framework che rispetta `zeroth` può essere validato da [`giskard`](https://github.com/Malstrom/giskard).

## Contenuto

```
zeroth/
├── rules/
│   ├── naming.md        # regole di naming per repo, cartelle, file
│   ├── structure.md     # struttura obbligatoria di ogni framework
│   ├── agent.md         # regole per .agent.yml
│   ├── registry.md      # regole per .registry.yml
│   ├── sync.md          # pattern di sincronizzazione cross-repo
│   └── log.md           # regole immutabilità e logging
└── templates/
    ├── .agent.yml       # template base
    └── .registry.yml    # template base
```

## Framework conformi
| Framework | Repo | Stato |
|---|---|---|
| dojo | [Malstrom/dojo-framework](https://github.com/Malstrom/dojo-framework) | ✅ reference impl |
| sudo-hire-me | [Malstrom/sudo-hire-me](https://github.com/Malstrom/sudo-hire-me) | ✅ conforme |
| tensho | [Malstrom/tensho](https://github.com/Malstrom/tensho) | ✅ conforme |
