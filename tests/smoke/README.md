# Giskard zeroth — smoke test matrix

Documenta lo stato atteso di ogni check in `giskard --mode zeroth` sul repo zeroth stesso.
Usare come riferimento per interpretare i report di giskard.

> Aggiornato dopo merge PR #235, #236.

---

## Come leggere la tabella

| Colonna | Significato |
|---|---|
| `framework` | sezione del report giskard |
| `check` | label esatto nel checks.yml |
| `atteso` | ✅ pass / ❌ fail / ⚠️ skip |
| `motivo` | perché non è ✅ |

---

## dojo

| check | atteso | motivo |
|---|---|---|
| `frameworks/dojo/structure.yml present` | ✅ | |
| `frameworks/dojo/.agent.yml present` | ✅ | |
| `frameworks/dojo/.scenarios.yml present` | ✅ | |
| `frameworks/dojo/.registry.yml present` | ✅ | |
| `frameworks/dojo/README.md present` | ✅ | |
| `frameworks/dojo/templates/ present` | ✅ | |
| `frameworks/dojo/kiroku/ present` | ✅ | |
| `frameworks/dojo/.scenarios.yml index format valid` | ⚠️ skip | dojo usa formato monolitico (`required_scenarios`) — migrazione pendente |
| `frameworks/dojo/.scenarios.yml scenario files exist` | ⚠️ skip | dipende da index format |

---

## sudo-hire-me

| check | atteso | motivo |
|---|---|---|
| `frameworks/sudo-hire-me/structure.yml present` | ✅ | |
| `frameworks/sudo-hire-me/.agent.yml present` | ✅ | |
| `frameworks/sudo-hire-me/.scenarios.yml present` | ✅ | |
| `frameworks/sudo-hire-me/.registry.yml present` | ✅ | aggiunto in PR #236 |
| `frameworks/sudo-hire-me/README.md present` | ✅ | aggiunto in PR #236 |
| `frameworks/sudo-hire-me/scenarios/ present` | ✅ | dir già presente |
| `frameworks/sudo-hire-me/.scenarios.yml index format valid` | ✅ | usa già formato index |
| `frameworks/sudo-hire-me/.scenarios.yml scenario files exist` | ✅ | file scenario presenti in `scenarios/` |

---

## aurora

| check | atteso | motivo |
|---|---|---|
| `frameworks/aurora/structure.yml present` | ✅ | |
| `frameworks/aurora/.agent.yml present` | ✅ | |
| `frameworks/aurora/.scenarios.yml present` | ✅ | |
| `frameworks/aurora/.registry.yml present` | ✅ | aggiunto in PR #236 |
| `frameworks/aurora/README.md present` | ✅ | aggiunto in PR #236 |
| `frameworks/aurora/templates/ present` | ✅ | |
| `frameworks/aurora/.scenarios.yml index format valid` | ❌ fail | aurora usa formato monolitico — migrazione richiesta (issue separata) |
| `frameworks/aurora/.scenarios.yml scenario files exist` | ⚠️ skip | dipende da index format valid |

---

## Risultato atteso complessivo

```
result: ❌ failed
  dojo:       ⚠️  7 passed / 0 failed / 2 skipped
  sudo-hire-me: ✅  8 passed / 0 failed / 0 skipped
  aurora:     ❌  6 passed / 1 failed / 1 skipped
```

### Failure aperti (legittimi, non regressioni)

| failure | tracker |
|---|---|
| `aurora/.scenarios.yml index format valid` | migrazione aurora → index format (issue da aprire) |

### Skip aperti (legittimi, non regressioni)

| skip | sblocco |
|---|---|
| `dojo/.scenarios.yml index format valid` | dopo migrazione dojo → index format |
| `dojo/.scenarios.yml scenario files exist` | idem |
| `aurora/.scenarios.yml scenario files exist` | dopo migrazione aurora → index format |
