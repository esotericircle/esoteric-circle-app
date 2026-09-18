# RAPPORTO DELL'ORDINE DY, IL TUTORIAL CHE SI PUO' SALTARE O DISATTIVARE E I TOOLTIP CHE SI LEGGONO PER INTERO

**Data:** 18 settembre 2026. **Ramo:** `claude/esoteric-circle-master-order-e798aj`.
**Manifesto:** `docs/ordini/ORDINE_DY_MANIFESTO.md`, con i file e le righe
del tutorial, dei suoi due pulsanti e della voce del menu', e il censimento
dei tooltip. **Sigla:** DY, la prima libera, verificata sul ramo.

**Tre voci, tre chiuse.** Nessuna build: l'ordine la vieta senza un ordine
del fondatore, e qui sotto la chiedo.

---

## 1. VOCE PER VOCE

| voce | prodotto | agganciato al codice | verificato a video |
|---|---|---|---|
| DY.01 il tutorial a ogni apertura, con Salta e Disattiva | si' | si': `main()` arma l'apertura, il tutorial legge la scelta | **no**, serve una build |
| DY.02 la voce del menu' | si' | si': *Tutorial all'apertura*, stessa chiave di *Disattiva* | **no**, serve una build |
| DY.03 il testo dei tooltip sotto le barre | si' | si': una riga nella porta di tutti i fogli | **no**, serve una build; al banco il foglio comincia a 62 punti su 62 con otto testi su otto |

**Come si comporta adesso il tutorial.**
- All'apertura dell'app, dopo la intro, si presenta, se il Risveglio e'
  fatto e non e' stato disattivato.
- *Salta* e l'arrivo in fondo lo chiudono per quell'apertura; all'apertura
  dopo torna.
- *Disattiva* lo chiude e non torna piu'.
- Dal menu' utente *Tutorial all'apertura* dice *Attivo* o *Disattivato* e
  al tocco cambia; *Rivedi il primo approdo* resta e lo mostra subito.
- Finito il primo Risveglio si presenta subito, e non piu' all'apertura dopo.

**Una scelta dichiarata, dove l'ordine tace**: arrivare in fondo ai cinque
fumetti vale come *Salta*. La regola del fondatore dice che il tutorial si
presenta sempre finche' non si disattiva, quindi l'unica cosa che lo ferma e'
*Disattiva*. Se preferisce che chi lo finisce non lo riveda, e' una riga.

## 2. GLI SCARTI FRA L'ORDINE E IL RAMO

- **"Il tutorial deve sempre attivarsi"**: sul ramo **non lo faceva**, e non
  per un difetto. Si presentava una volta sola per decisione dell'ordine CB
  voce 02 (*"solo appena l'utente approda per la prima volta"*):
  `primo_approdo.dart:294-298` e `314-325` nella 2271. L'ordine DY cambia la
  regola, e il codice la segue.
- **Il tutorial aveva gia' "Salta"** (`primo_approdo.dart:710-716` nella
  2271); **non aveva "Disattiva"**.
- **Il menu' utente aveva una voce**, *Rivedi il primo approdo*
  (`account_screen.dart:206-217`), che lo fa ripartire subito; **nessuna lo
  attivava o lo disattivava**.
- **Trovato misurando**: dopo il primo Risveglio il tutorial non compariva
  affatto. Il Risveglio e' una rotta spinta sopra il guscio
  (`lib/app.dart:674-679`), il tutorial vive sotto di lei dall'avvio e
  decideva solo alla nascita (`primo_approdo.dart:372-376` nella 2271).
  Armato alla fine del rito, aspettava l'apertura dopo.
- **"Tooltip"**: nelle catture e' il pannello *Fonti e metodo*, non
  l'etichetta di sistema dei pulsanti a icona. Le ho censite tutte e due, e
  la cura riguarda i pannelli.

## 3. IL CENSIMENTO DEI TOOLTIP

Per intero nel manifesto. **Diciassette pannelli informativi**: nove con un
foglio proprio (quattro bassi, che non arrivano mai alle barre, e cinque che
possono crescere), otto dal foglio delle fonti comune. **Tutti aprono un
foglio della porta comune**, e la cura sta nella porta: vale anche per gli
altri venti fogli dell'app. Le 28 etichette di sistema dei pulsanti a icona
sono una parola o tre, compaiono accanto all'icona e nessuna sta nelle barre
in alto.

**Col testo piu' lungo**: i sette testi del foglio comune e uno quattro volte
il piu' lungo, a 360 per 640 col testo a 1,3, sotto una barra di stato di 24
punti e la barra dell'identita' coi suoi 38. Il foglio comincia a 62,0 punti
in tutti e otto i casi; senza la cura sale sotto le barre in tutti e otto.

## 4. I PADRI

- **Il testo sotto le barre**: ordine **AM voce 04**, commit `3549c4d6` del
  18 agosto 2026, che ha messo la barra dell'identita' sopra il Navigator e
  ha dichiarato la sua altezza nel `padding.top`, cosi' che le aree sicure la
  rispettassero. I fogli non la rispettavano: `showModalBottomSheet` con
  `isScrollControlled` e senza `useSafeArea` sale fino al bordo. La porta
  unica dell'ordine **CF voce 09** (commit `c4f70b69`, 31 agosto 2026) ha
  ereditato il difetto senza vederlo.
- **Il tutorial che non compariva dopo il primo Risveglio**: ordine **CB
  voce 02**, dove il tutorial e' nato con la sola decisione alla nascita.
- **Il tutorial che si presentava una volta sola** non e' un difetto: era la
  regola dell'ordine CB voce 02, che l'ordine DY cambia.

## 5. LE PROVE

- **Regola B**: `il_primo_approdo_test` rossa togliendo *Salta* (due
  cadute); `il_velo_e_uno_solo_test` rossa col foglio delle fonti aperto dal
  framework. Innesti tolti e verificati col grep.
- **Regola A, guardie nuove tutte viste rosse**: la porta senza l'area sicura
  (otto testi su otto sotto le barre, e il censimento); *Disattiva* tolto;
  *Salta* che disattiva; la scelta ignorata; il Risveglio che non richiama;
  l'apertura non armata in `main()`. Ognuno ripristinato dal commit di lavoro
  e verificato col grep.
- **Registro delle guardie**: 442, categorie 137, 113 e 192.
- **Sigillo aggregato**: `'DY': 3`.

## 6. UN MIO ERRORE, DICHIARATO

Mentre preparavo gli innesti ho lanciato un comando che conteneva
`git checkout -- .` sull'albero di lavoro del DY, e ha cancellato le modifiche
non committate a cinque file. Le ho rifatte da capo con gli stessi testi, poi
ho fatto un commit di lavoro locale prima di ogni innesto. Nessun lavoro del
ramo canonico e' stato toccato. La lezione e' in memoria: mai `checkout` con
lavoro non committato, e Python su Windows va aperto con `newline=''`, perche'
riscrive i file con CRLF.

## 7. LA BUILD

**Serve una build per vedere a video le tre voci**, e l'ordine non la
concede: la chiedo al fondatore. Sarebbe la 2272. Sul telefono di collaudo
oggi c'e' la 2271, che non ha il DY.
