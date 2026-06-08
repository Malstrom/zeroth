# Zeroth — Structure Rules

## File obbligatori
Ogni framework conforme DEVE avere:
```
.agent.yml        # manifest AI — obbligatorio
.registry.yml     # connessioni cross-repo — obbligatorio anche se vuoto
README.md         # hub navigazione umana
```

## Principio base
- **File piccoli per dominio**, mai monoliti
- Un file = una responsabilità
- Se un file supera ~150 righe, va suddiviso
- Le cartelle raggruppano per funzione, non per tipo di file

## Template
- Ogni documento generabile ha un template in `templates/`
- L'AI legge il template PRIMA di generare qualsiasi documento
- I placeholder usano formato `{{TOKEN}}`
- Mai deviare dalla struttura del template — aggiorna prima il template, poi usalo

## Immutabilità
- I log di eventi critici (esami, decisioni) sono immutabili
- Correzioni: append, mai overwrite
- File immutabili dichiarati esplicitamente in `.agent.yml`
