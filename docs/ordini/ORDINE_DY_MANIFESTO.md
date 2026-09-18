# ORDINE DY, IL TUTORIAL CHE SI PUO' SALTARE O DISATTIVARE E I TOOLTIP CHE SI LEGGONO PER INTERO

**Sigla:** DY, la prima libera: verificato sul ramo, in `docs/ordini` non c'e'
nessun `ORDINE_DY_*`, in `test` nessun `ordine_dy_*`, in `docs/STATO_VIVO.md`
nessuna menzione. **Data:** 18 settembre 2026. **Ramo:**
`claude/esoteric-circle-master-order-e798aj`. Parte dal commit dell'ordine DX.

**Il fatto, dal fondatore**: *"all'apertura dell'app, quando l'utente accede
alla home dopo la intro, il tutorial deve sempre attivarsi. il tutorial deve
contenere anche il pulsante "disattiva" oltre che "salta". quindi se preme su
"salta" la prossima volta il tutorial si presenta ancora, ma se ha premuto
precedentemente su "disattiva" ovviamente non si deve presentare piu'"*;
*"la voce attiva e disattiva deve comparire anche nel menu' utente"*;
*"quando i testi dei tooltip sono lunghi, la parte alta scompare sotto la prima
barra in alto sottile"*. Con due catture Android delle 18:32 e 18:33: il
pannello *Fonti e metodo* della Runa del Tramonto, col titolo dentro la barra
di stato e la prima riga sotto la barra dell'identita'.

VOCI_TOTALI: 3
VOCI_CHIUSE: 3
VOCI_APERTE: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0

Il rapporto sta in `docs/ordini/RAPPORTO_ORDINE_DY.md`.

---

## I FATTI, RISCONTRATI SUL CODICE PRIMA DI USARLI

| cosa dice l'ordine | il riscontro sul ramo | esito |
|---|---|---|
| esiste un tutorial sulla home dopo la intro | **vero**: il Primo Approdo, cinque fumetti, `lib/features/onboarding/primo_approdo.dart`, montato in `lib/app.dart:600` dentro l'intro e fuori dalle due barre | **VERO** |
| oggi si presenta sempre | **falso**: si presenta **una volta sola**. Lo arma la fine del Risveglio (`risveglio_journey.dart:249`), e chiuso o saltato scrive `avvisi.primoApprodo.visto` e toglie l'arma (`primo_approdo.dart:314-325`): non torna piu' da solo. Deciso dal fondatore con l'ordine CB voce 02, *"solo appena l'utente approda per la prima volta"* | **SMENTITO, E LO CAMBIA LA VOCE 01** |
| il tutorial ha "Salta" | **vero**: `primo_approdo.dart:710-716`, su tutti e cinque i fumetti | **VERO** |
| il tutorial ha "Disattiva" | **falso**: non c'e' | **MANCA** |
| nel menu' utente c'e' la voce | **in parte**: c'e' *Rivedi il primo approdo* (`account_screen.dart:206-217`), che lo fa ripartire subito; non c'e' niente che lo attivi o lo disattivi | **MANCA** |
| il testo dei tooltip sparisce sotto la barra | **vero, e la causa e' una sola**: tutti i fogli passano da `foglioDelCerchio` (`lib/design_system/transizioni/velo_del_cerchio.dart:53`), che apre `showModalBottomSheet` senza `useSafeArea`. Con `isScrollControlled: true` il foglio puo' crescere fino al bordo alto dello schermo, e la barra dell'identita', che vive sopra il Navigator (`barra_dell_identita.dart:148-167`), gli si disegna sopra insieme alla barra di stato. La barra dichiara la sua altezza nel `padding.top` della MediaQuery proprio perche' ogni area sicura la rispetti: il foglio non la guardava | **VERO, CAUSA NELLA PORTA** |
| il tutorial compare subito dopo il primo Risveglio | **falso, trovato misurando**: il Risveglio e' una rotta spinta sopra il guscio (`lib/app.dart:674-679`), il tutorial vive sotto di lei dall'avvio e decideva solo alla nascita (`primo_approdo.dart:372-376` nella 2270). Armato alla fine del rito, compariva solo all'apertura dopo | **TROVATO** |

---

## DOVE STANNO LE COSE, come chiede l'ordine

- **Il tutorial**: `PrimoApprodo`, `lib/features/onboarding/primo_approdo.dart:430`, montato in `lib/app.dart:600`.
- **Salta**: `primo_approdo.dart:829`. **Disattiva**: `primo_approdo.dart:822`, che chiama `_disattiva` alla riga 497.
- **La regola dell'apertura**: `MemoriaDelPrimoApprodo.daMostrare`, `primo_approdo.dart:341`; l'apertura si arma in `lib/main.dart:106` (`nuovaApertura`, riga 326 del tutorial); la fine del Risveglio lo richiama con `approdoDopoIlRito`, riga 424.
- **La voce del menu' utente**: `lib/features/account/account_screen.dart:229`, `tutorial_all_apertura`, accanto a *Rivedi il primo approdo* alla riga 211.
- **La cura dei fogli**: `lib/design_system/transizioni/velo_del_cerchio.dart:84`, `useSafeArea: true`.

(Righe del commit di chiusura dell'ordine.)

---

## LE VOCI

- **DY.01**, il tutorial si presenta a ogni apertura dopo la intro, con Salta
  e Disattiva; Salta lo fa tornare all'apertura dopo, Disattiva no.
  **Fatto**: l'apertura arma il tutorial da `main()` (`nuovaApertura`),
  purche' il Risveglio sia fatto; *Disattiva* accanto a *Salta* su tutti e
  cinque i fumetti, e scrive `avvisi.primoApprodo.disattivato`; *Salta* e
  la fine non scrivono piu' niente che lo tenga lontano; finito il primo
  Risveglio il tutorial si presenta subito (`approdoDopoIlRito`), e non
  piu' all'apertura dopo. Prove in `test/il_primo_approdo_test.dart`, viste
  rosse con cinque innesti. **Una scelta dichiarata, perche' l'ordine tace**:
  arrivare in fondo ai cinque fumetti vale come *Salta*, quindi all'apertura
  dopo il tutorial torna; lo ferma solo *Disattiva*, come dice la regola del
  fondatore. **Prodotto e agganciato; a video da vedere con una build.**
  **CHIUSA.**
- **DY.02**, nel menu' utente la voce che lo attiva e lo disattiva.
  **Fatto**: *Tutorial all'apertura* in `account_screen.dart`, accanto a
  *Rivedi il primo approdo*, che resta: dice *Attivo* o *Disattivato* e al
  tocco cambia, con la stessa chiave di *Disattiva*; l'elenco del menu' si
  ridisegna quando la scelta cambia. **Prodotto e agganciato; a video da
  vedere con una build.** **CHIUSA.**
- **DY.03**, il testo dei tooltip si legge per intero, mai sotto le barre in
  alto; il censimento qui sotto.
  **Fatto**: una riga nella porta dei fogli, `useSafeArea: true`, che vale
  per tutti i 37 fogli; il censimento dei diciassette pannelli qui sotto.
  Guardia `test/il_testo_dei_fogli_non_passa_sotto_le_barre_test.dart`: con
  otto testi su otto il foglio comincia a 62 punti, dove finiscono le barre,
  e senza la cura sale sotto di loro. **Prodotto e agganciato; a video da
  vedere con una build, sulla Runa del Tramonto delle catture.** **CHIUSA.**

---

## IL CENSIMENTO DEI TOOLTIP, VOCE DY.03

**Cosa si e' contato.** Nelle catture il *tooltip* e' il pannello che si apre
dal pulsante informativo, *Fonti e metodo*. Si sono cercati tutti i pulsanti
informativi di `lib` (`grep -rn "tooltip:" lib`, 45 righe) e il foglio che
ciascuno apre; poi, per non lasciare fuori niente, **tutti i fogli dell'app**:
37 chiamate a `foglioDelCerchio` in 28 file, e nessuna chiamata diretta a
`showModalBottomSheet` fuori dalla porta.

**I pannelli informativi, diciassette.**

| pannello | pulsante | foglio che apre | esito |
|---|---|---|---|
| Angeli, *Fonti e metodo* | `lib/features/angels/angels_screen.dart:197` | `angels_screen.dart:117`, foglio basso | sotto le barre |
| Test dell'Archetipo, *Fonti e metodo* | `lib/features/maestri/aura/archetype/archetype_test_screen.dart:202` | `archetype_test_screen.dart:248`, foglio basso | sotto le barre |
| Costellazione del Viso, *Fonti e metodo* | `lib/features/maestri/aura/face/face_constellation_screen.dart:339` | `face_constellation_screen.dart:439`, foglio basso | sotto le barre |
| Animale Guida, *Fonti e metodo* | `lib/features/maestri/caligo/animal/guide_animal_screen.dart:207` | `guide_animal_screen.dart:331`, foglio basso | sotto le barre |
| Estrazione delle Rune, *Fonti e metodo* | `lib/features/maestri/caligo/rune/rune_draw_screen.dart:436` | `rune_draw_screen.dart:490`, foglio che cresce | curato dalla porta |
| Rito del Sogno, *Da dove nasce questo dono* | `lib/features/rituals/dream_rite_screen.dart:412` | `dream_rite_screen.dart:901`, foglio che cresce | curato dalla porta |
| Runa del Tramonto, *Fonti e metodo* (le catture) | `lib/features/rituals/sunset_rune_screen.dart:697` | `sunset_rune_screen.dart:1633`, foglio che cresce | curato dalla porta |
| Il cielo di oggi, *Fonti e metodo* | `lib/features/santuario/sky_overview_screen.dart:1043` | `sky_overview_screen.dart:420`, foglio che cresce | curato dalla porta |
| Sentiero, *Dove sono in questo sentiero* | `lib/features/sigilli/sentiero_screen.dart:255` | `lib/features/sigilli/la_mappa_del_sentiero.dart:51`, foglio che cresce | curato dalla porta |
| Oroscopo, *Fonti e metodo* comune | `lib/features/horoscope/oroscopo_screen.dart:414` | `lib/features/maestri/widgets/foglio_delle_fonti.dart:46`, foglio che cresce | curato dalla porta, provato col suo testo |
| Meditazione, *Fonti e metodo* comune | `lib/features/maestri/aura/meditation/meditation_screen.dart:598` | `foglio_delle_fonti.dart:46` | curato dalla porta, provato col suo testo |
| Sigillo dell'Intenzione, *Fonti e metodo* comune | `lib/features/maestri/caligo/sigillo/sigillo_intenzione_screen.dart:320` | `foglio_delle_fonti.dart:46` | curato dalla porta, provato col suo testo |
| Viaggio dello Sciamano, *Fonti e metodo* comune | `lib/features/maestri/caligo/viaggio/viaggio_dello_sciamano_screen.dart:996` | `foglio_delle_fonti.dart:46` | curato dalla porta |
| Cosmic Passport, *Fonti e metodo* comune | `lib/features/passport/cosmic_passport_screen.dart:672` | `foglio_delle_fonti.dart:46` | curato dalla porta, provato col suo testo |
| Soffio del Destino, *Fonti e metodo* comune | `lib/features/rituals/breath_destiny_screen.dart:615` | `foglio_delle_fonti.dart:46` | curato dalla porta, provato col suo testo |
| Sinastria VIP, *Fonti e metodo* comune | `lib/features/synastry/sinastria_vip_screen.dart:610` | `foglio_delle_fonti.dart:46` | curato dalla porta, provato col suo testo |
| Stesa delle Tre Carte, *Fonti e metodo* comune | `lib/features/tarot/stesa_tre_carte_screen.dart:1056` | `foglio_delle_fonti.dart:46` | curato dalla porta, provato col suo testo |

**Foglio basso** vuol dire che il foglio non puo' crescere oltre i nove
sedicesimi dello schermo (`isScrollControlled` falso): non arriva mai alle
barre, qualunque sia il testo. **Curato dalla porta** vuol dire che il foglio
puo' crescere fino in cima, ed e' la famiglia delle catture: adesso si ferma
sotto le barre, per tutti, dalla riga 84 di `velo_del_cerchio.dart`.

**Col testo piu' lungo.** La guardia
`test/il_testo_dei_fogli_non_passa_sotto_le_barre_test.dart` apre il foglio
delle fonti comune con **ognuno dei sette testi** di `TestiDelleFonti` e con
un testo quattro volte il piu' lungo, su uno schermo di 360 per 640 col testo
alla scala massima dell'app (1,3), sotto una barra di stato di 24 punti e la
barra dell'identita' coi suoi 38: il foglio e il titolo stanno sempre sotto.
I pannelli con un foglio proprio che puo' crescere sono provati dalla stessa
porta, perche' la cura non dipende dal contenuto: il foglio si ferma dove
finiscono le barre, e un testo lungo scorre dentro di lui.

**Gli altri 28 `tooltip:` non sono pannelli**: sono le etichette di sistema
dei pulsanti a icona (*Indietro*, *Altro*, *Detta il messaggio* e simili), una
parola o tre che compaiono tenendo premuto accanto all'icona. Nessuna sta
nelle barre in alto e nessuna porta un testo lungo. Esito: nessuna cura
necessaria, **a video da vedere** come gli altri.

**I fogli che non sono pannelli informativi** (20 degli altri) passano dalla
stessa porta e hanno la stessa cura: chi di loro puo' crescere si ferma sotto
le barre.
