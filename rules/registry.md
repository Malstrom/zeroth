# Zeroth — Registry Rules (.registry.yml)

## Scopo
Il registry mappa le connessioni tra framework. NON è una lista statica di link.
È una dichiarazione di dipendenze, sync e conflict check.

## Struttura obbligatoria
```yaml
identity:
  repo: owner/repo-name
  type: workspace | tool | gtm | learning
  version: semver
  last-updated: YYYY-MM-DD

connections:
  - repo: owner/altro-repo
    purpose: descrizione
    read:
      - path: file/da/leggere
        reason: perché
    sync:
      - trigger: nome-evento
        condition: quando
        action:
          target: owner/repo
          file: path
          operation: cosa fare
          pr: true|false
          auto-merge: true|false
```

## Regole
- MAI leggere `.registry.yml` proattivamente — solo quando scatta un post-action hook
- Ogni `sync.trigger` DEVE corrispondere a un `state_change` dichiarato in `.agent.yml`
- `conflict_check` obbligatorio per ogni file condiviso tra framework
- `auto-merge: true` solo per sync automatici non distruttivi
- Ogni connessione DEVE dichiarare `purpose` — niente connessioni anonime

## Versioning (da implementare)
```yaml
requires:
  repo: owner/dojo-framework
  min-version: "1.2.0"
```
- I framework specializzati dichiarano la versione minima di dojo richiesta
- Incompatibilità di versione è un errore bloccante per giskard
