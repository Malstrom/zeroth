# Zeroth — Log Rules

## Immutabilità
- I log di eventi critici sono immutabili una volta committati
- "Critico" = esami, decisioni di prodotto, transazioni
- Correzioni: append con entry `correction:`, MAI overwrite
- Il primo tentativo è sempre il dato reale — la correzione è segnale di apprendimento

## Formato file log
```
log/YYYY-MM-DD_{type}_{topic}.md
```
- `type`: `exam`, `randori`, `study`, `session`, `decision`
- `topic`: snake_case, max 2 parole
- Esempi: `2026-06-08_exam_python.md`, `2026-06-08_decision_gtm.md`

## Commit strategy
- Log critici: commit immediato, PR immediata, merge immediato
- Log di sessione: commit a fine sessione
- Mai batch un log critico con altri file

## Contenuto minimo
Ogni log DEVE contenere:
- Data e tipo sessione
- Decisioni prese con ragionamento (non solo output)
- Stato al termine
- Prossima azione
