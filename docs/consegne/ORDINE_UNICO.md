# ORDINE UNICO, quattro voci. Dove sono arrivato

Scritto il 6 agosto 2026, a sessione ancora aperta, perche' l'ordine lo chiede
a chi si ferma. **Non e' un riassunto di comodo: e' il punto esatto in cui
lasciare il lavoro, con quello che ho verificato e quello che non ho toccato.**

Ramo: `claude/ordine-unico-b1e463`, nato dal canonico aggiornato a distanza zero
nei due sensi da `6a40e2d`, e gia' spinto sul canonico a ogni voce chiusa.

## Cosa e' fatto e spinto

- **Voce 4, l'intro video.** Chiusa prima di questo ordine e consegnata come
  build 2150, commit `83e8617`. Poi l'aggiunta col video nuovo, commit
  `5cb1885`: `Intro-Test-3` convertito dal SORGENTE e non dal convertito
  precedente, il secondo tolto dal pacchetto, la prova che conta i file nella
  cartella dell'intro invece di nominarli.
- **Voce 1, l'emblema dell'archetipo.** Commit `b3dec34`. Vedi la voce dedicata
  in `STATO_VIVO.md`, che e' aggiornata e non va riletta qui.

## Cosa NON e' fatto

- **Voce 2, il Soffio del Destino.** Premesse enumerate, nessuna riga scritta.
- **Voce 3, la striscia Sentieri.** Non cominciata, premesse non enumerate.
- **La build finale e la consegna.** L'ordine le vuole solo dopo la voce 4, che
  qui vuol dire dopo tutte: l'ultima consegnata resta la 2150, che contiene
  l'intro col video **secondo**, non il terzo. Chi riprende deve costruire e
  consegnare.

## Voce 2, le premesse come le ho verificate

**2a. Vera in parte, e la forma esatta conta.** L'etichetta `PAROLA DEL GIORNO`
esce da `lib/features/rituals/ritual_gift_card.dart:168`, dentro `RitualGiftCard`,
che e' la stessa scheda usata dal Soffio (`breath_destiny_screen.dart:326`) e dal
Rito dell'Alba (`dawn_rite_screen.dart:450`). Sotto l'etichetta **non c'e' il
vuoto**: quando `word` e' nullo compare la scritta `In arrivo`. E' peggio del
vuoto, non meglio, perche' e' esattamente il campo che dice alla persona di
aspettare qualcosa, che le regole dell'ordine vietano. La parola arriva da
`DawnGift.word`, riempita da `rito?.parola` in `dawn_gift.dart:178`: quando il
rito del giorno non porta una parola, il campo resta nullo.

**2b. FALSA.** I due pulsanti hanno il loro testo, scritto in chiaro:
`Da dove nasce questo dono` (`ritual_gift_card.dart:258`, con l'icona info e la
freccetta) e `Condividi la parola` (`ritual_gift_card.dart:407`, dentro un
`TextButton.icon` col bordo). Nessuna etichetta vuota nel codice.

**Cosa credo di aver capito, e che NON ho verificato**: fino al 5 agosto 2026
l'accento di quella scheda era una costante unica, e su vetro chiaro il testo
poteva risultare illeggibile. Il rapporto di contrasto minimo e' stato imposto
in `_accentoDi(Maestro)` proprio per questo, ed e' entrato nella 2150. Se Mauro
ha guardato una build precedente, "pulsanti senza testo" e "testo invisibile"
sono la stessa cosa vista da fuori. **Va confermato guardando, non ragionando**:
serve una cattura piu' alta della scheda, perche' le due anteprime che esistono
oggi, `soffio-destino-dono.png` e `rito-alba-dono.png`, si fermano prima dei
pulsanti.

**2c. Vera.** Il fondale e' `assets/ritual_backgrounds/breath_meadow.png`,
composto in `breath_destiny_screen.dart:89` insieme al soffione: prato e cielo
diurni, non il cosmo condiviso. E' un canvas dipinto a livelli, non un widget di
sfondo riusabile, quindi toglierlo non e' cambiare una riga. **Non ho misurato
quanto costa**, e l'ordine lo chiedeva: e' la prima cosa da fare riprendendo.

**2d. Il simbolo NON respira.** Ci sono due controllori, `_disperse` (la
dispersione del soffione al gesto, `easeOutCubic`) e `_ambient` (brezza e
brillio, un moto continuo di sfondo). Nessuno dei due e' legato ai tempi del
respiro dichiarati dal testo: il testo dice "sei tempi dentro e sei fuori, tre
volte" e il simbolo fa altro.

## Le rotture di lingua, viste a video e non nel sorgente

Nell'anteprima `soffio-destino-dono.png`, che e' la scheda vera a 1080x2391:

- `La Luna è Luna calante.` La frase si compone col nome della fase, e per
  alcune fasi esce ripetuta o sgrammaticata. Mauro cita `La Luna e' Ultimo
  quarto`, che e' la stessa rottura su un'altra fase.
- `(6 tempi, 3 giri)` in coda a `Sei tempi dentro e sei fuori, tre volte`: le
  cifre ripetono cio' che la frase ha appena detto in parole.

Tutte e due stanno nel corpus dei riti, non nella schermata.

## Quello che chi riprende deve sapere, e che non e' scritto altrove

- **Le anteprime si scrivono in `docs/preview` solo con `AGGIORNA_ANTEPRIME=1`
  nell'ambiente.** Senza, finiscono in `build/preview` e sembra che la cattura
  non abbia fatto niente.
- **Il precarico va fatto prima di ogni scatto che mostra arte**, e la cattura
  lo fa gia' da sola: quello che NON fa da sola e' il precarico di un'immagine
  che compare solo in quella scena, come l'emblema dell'archetipo.
- **Montare l'app intera in prova richiede `onboarding.done` a vero**, altrimenti
  il Risveglio si spinge SOPRA lo shell e niente del Santuario e' raggiungibile.
- **`CosmicPassport` ha gia' il suo scorrimento dentro**: avvolgerlo in un
  `SingleChildScrollView` lo fa esplodere in altezza non vincolata.
- **Il guardiano della lingua legge anche i nomi di variabile interpolati**
  dentro una stringa mostrata. Una variabile chiamata `identita` dentro
  `'... ${identita.qualcosa}'` viene letta come una parola italiana senza
  accento, e ha ragione lui.
