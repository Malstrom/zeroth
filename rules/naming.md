# Zeroth — Naming Rules

## Regola fondamentale
I nomi devono essere **evocativi**, non descrittivi. Il nome suggerisce l'essenza, non la funzione.

## Repo
- Massimo 2 parole
- Lowercase, separatore: trattino `-`
- Evocativo, non tecnico
- Esempi validi: `dojo`, `tensho`, `zeroth`, `sudo-hire-me`
- Esempi non validi: `ai-learning-framework`, `skill-tracker-v2`, `my-repo`

## Cartelle
- Massimo 2 parole
- Lowercase, nessun separatore se possibile
- Evocativo del contenuto, non tecnico
- Esempi validi: `kata/`, `scroll/`, `forge/`, `hunt/`, `log/`
- Esempi non validi: `training-data/`, `session-logs/`, `user-profiles/`

## File
- Lowercase, separatore: trattino `-` o underscore `_` (coerente per repo)
- File speciali AI: sempre con punto `.agent.yml`, `.registry.yml`
- File identità: nome proprio minuscolo (es. `sensei.md`, `igor.md`)
- Log: formato `YYYY-MM-DD_{type}_{topic}.md`

## File speciali riservati
| File | Ruolo | Accesso AI |
|---|---|---|
| `.agent.yml` | Manifest AI, entry point | Read-only |
| `.registry.yml` | Mappa connessioni cross-repo | Read-only, mai proattivo |
| `sensei.md` | Identità utente e profilo | Read-write |
| `README.md` | Hub navigazione umana | Write-only (AI non legge) |
