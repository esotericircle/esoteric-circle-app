# CENSIMENTO DELLA PAROLA RITO E RITUALE

Ordine CZ voce 12, 8 settembre 2026. **Nessuna di queste occorrenze e' stata
cambiata**, come la voce impone: la decisione su ognuna la prende il fondatore
leggendo questo elenco.

## COME E' STATO FATTO

Cercate le parole `rito`, `riti`, `rituale`, `rituali` **soltanto dentro le
stringhe letterali** di `lib`, saltando le righe di commento. Le righe di
commento si tolgono prima di contare, perche' nove volte in questo progetto
un'asserzione che cerca testo nel sorgente ha pescato il commento che la
spiega, ed e' una delle tre origini della Regola H.

**115 occorrenze, 112 righe distinte.** L'elenco per intero, con file e riga,
sta in `docs/ordini/CZ_censimento_rito.txt`.

## LA DOMANDA CHE DECIDE, ed e' una sola

**La parola MANTRA vale solo per una formula da pronunciare o da ripetere.**
Per un'azione da compiere non vale: un mantra non si esegue, si dice.

Su questo criterio le 112 righe si dividono in **quattro famiglie**, e solo la
prima e' materia di decisione.

---

## FAMIGLIA A, UNA FORMULA DA PRONUNCIARE. Qui la parola mantra ha senso

**Sono pochissime, ed e' il dato che conta**: la parola `rituale` in questa app
quasi mai nomina una formula.

| file e riga | testo | perche' |
| --- | --- | --- |
| `lib/features/rituals/ritual_gift_card.dart` | **IL MANTRA DI OGGI** | **gia' cambiato dal fondatore**, ed e' l'unico caso in cui il gesto e' *"nomina a mente una cosa"*, cioe' una formula |

**Una sola riga su 112.** Il resto nomina azioni.

---

## FAMIGLIA B, UN'AZIONE DA COMPIERE. La parola mantra NON vale

Sono la maggioranza. Il gesto e' fisico: guardare, respirare, prendere,
inclinare, accendere. Un mantra non si compie.

| file | esempi |
| --- | --- |
| `lib/core/rituals/rito_alba_corpus.dart:425,491,501` | *"centro del rito: se fai solo questo, il rito e' fatto"*, *"e non rialzarle per tutto il rito"*, *"Quattro dentro e quattro fuori, dieci giri"* |
| `lib/core/chat/immersive_intents.dart:218,219,224,225` | *"rito della candela"*, *"Un rito con la candela si accende, non si racconta"* |
| `lib/core/permissions/app_permission.dart:67` | *"Questo rito ha bisogno della fotocamera"* |
| `lib/core/angels/angel_lore.dart:446` | *"Il gesto ripetuto che tiene insieme il senso"* |

**Raccomandazione: non toccarle.** Dire *"il mantra della candela si accende"*
sarebbe falso.

---

## FAMIGLIA C, IL NOME PROPRIO DI UNA FUNZIONE

`Rito dell'Alba` e' il nome di una schermata, non la descrizione di un gesto.
Compare in decine di punti: catalogo delle arti, piani, permessi, sentieri dei
traguardi, avvisi.

| file | esempi |
| --- | --- |
| `lib/core/entitlement/plan_catalog.dart:127,412` | *"I quattro elementi giornalieri: Rito dell'Alba..."* |
| `lib/core/permissions/registro_dei_permessi.dart:117` | *"Il Rito dell'Alba..."* |
| `lib/core/sigilli/sentiero_loto.dart:39,104,170` | *"Hai compiuto il Rito dell'Alba in 2 giorni diversi"* |
| `lib/core/maestro/maestro.dart:45,46,47` | *"Custode delle rune e dei riti antichi"*, *"Rune, Rituali, Numerologia"* |

**Raccomandazione: non toccarle, e se si toccano si toccano TUTTE INSIEME.**
Cambiare il nome di una funzione in meta' dei punti e' peggio che non
cambiarlo: chi legge *"Rito dell'Alba"* nel menu' e *"Mantra dell'Alba"* nel
piano crede che siano due cose.

---

## FAMIGLIA D, CHIAVI E DATI, non testi

Non si vedono a schermo e **non vanno toccate mai**: cambiarle cancellerebbe i
dati gia' salvati sui telefoni.

| file e riga | testo |
| --- | --- |
| `lib/core/rituals/scelta_degli_avvisi.dart:43,49` | `rituale.avviso.ora.${dono.name}`, `rituale.avviso.${dono.name}` |
| `lib/core/sigilli/diario_del_cammino.dart:792` | `${c.rito}:${c.arco}` |

Sono chiavi di `SharedPreferences`. La riga 43 e la 49 conservano le ore che la
persona ha scelto per le sue notifiche: **rinominarle vorrebbe dire che ogni
telefono gia' installato torna alle ore di fabbrica**.

---

## IL CONTO, e la conclusione che ne segue

| famiglia | quante | decisione |
| --- | ---: | --- |
| A, formula da pronunciare | **1** | gia' fatta dal fondatore |
| B, azione da compiere | la maggioranza | non toccare, sarebbe falso |
| C, nome proprio di una funzione | decine | tutte insieme o nessuna |
| D, chiavi di memoria | 3 | mai, si perderebbero i dati |

**La conclusione, e la scrivo perche' e' la sola cosa utile di questo
censimento**: la parola `mantra` in questa app ha **un posto solo**, ed e'
quello dove il fondatore l'ha gia' messa. Ovunque altro il gesto e' un'azione
o il nome di una schermata.

**La decisione finale su ciascuna riga resta del fondatore**, come la voce
dice: qui c'e' l'elenco e il criterio, non una modifica.
