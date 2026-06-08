# Zeroth — Sync Rules

## Principio
La sincronizzazione tra framework è **event-driven**, mai polling.
Un framework non controlla periodicamente gli altri — reagisce a eventi.

## Pattern validi

### Push sync
Framework A emette `state_change` → post-action hook legge `.registry.yml` → sync verso Framework B
```
dojo emette exam-failed
→ hook legge registry
→ sudo-hire-me aggiunge topic a needs_study
```

### Pull sync
Framework A legge dati da Framework B all'avvio scenario
```
sudo-hire-me scenario cv-write
→ legge scroll/README.md da dojo
→ verifica skill dichiarate nel CV
```

### Bidirezionale
Entrambi i pattern attivi sulla stessa coppia di framework.
Esempio: dojo ⇔ sudo-hire-me (già implementato).

## Regole
- Ogni sync DEVE avere `trigger` esplicito — mai sync impliciti
- `conflict_check` prima di ogni write cross-repo
- Se PR aperta sullo stesso file: stop e notifica, mai sovrascrivere
- `auto-merge: true` solo per operazioni additive (aggiungere righe, mai modificare)
- Sync distruttivi (delete, overwrite): sempre `auto-merge: false`
