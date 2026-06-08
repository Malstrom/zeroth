# Zeroth — Agent Rules (.agent.yml)

## Struttura obbligatoria
```yaml
connector_check:   # obbligatorio — primo blocco
global:            # obbligatorio — regole globali di sessione
repo_map:          # obbligatorio — mappa file con ruoli
scenarios:         # obbligatorio — almeno session_start e unknown_scenario
handlers:          # opzionale — reattivi, mai chiamati direttamente
```

## Regole fondamentali

### connector_check
- DEVE essere il primo blocco
- Se il connector non è attivo: messaggio chiaro + stop immediato
- Mai fallback a web o browser

### global
- `language`: sempre dichiarato o riferito a un file sorgente
- `pr_strategy`: `batch_per_session` default — eccezione solo per log immutabili
- `dedup_scope`: `current_session_log` — ogni handler gira al massimo una volta per topic per sessione
- `trigger_matching`: `pattern_first` — fallthrough a `unknown_scenario` se nessun match

### scenarios
- Ogni scenario ha: `trigger_patterns`, `read`, `actions`, `state_changes`
- `session_start` obbligatorio
- `unknown_scenario` obbligatorio — mai lasciare messaggi senza gestione
- I trigger sono pattern in linguaggio naturale, non comandi tecnici
- Gli scenari sono attivati dall'utente — i handler no

### handlers
- Reattivi a `state_changes` emessi da scenari
- Mai chiamati direttamente dall'utente
- DEVONO avere `dedup` dichiarato
- `listen`: lista di eventi a cui reagiscono

### write-ahead
- Regola: commit PRIMA di rispondere
- Log critici: commit immediato, immutabile
- Tutto il resto: batch per sessione

### file_access
- `.agent.yml`: read-only
- `.registry.yml`: read-only
- Ogni file deve avere permesso dichiarato esplicitamente

### tool_approval
- `destructive_ops: true` — sempre richiedere approvazione per operazioni distruttive
- `merge_to_main`: dichiarare esplicitamente se consentito o no
