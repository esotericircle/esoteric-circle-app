# ESITO: L'INTRO DAVANTI A TUTTO

**Provvisoria, per le dimostrazioni.** Sta scritto nel commento in testa al file:
va sostituita quando arriveranno gli asset definitivi, e il video si chiama
`Intro-Test`.

## La sequenza

Tre secondi di nero con la frase che si scrive lettera per lettera, dissolvenza
di mezzo secondo, il video una volta sola a tutto schermo senza tagliare il
soggetto, dissolvenza, il logo che cresce di poco, dissolvenza, e poi **si va
dove si sarebbe andati comunque**.

**La destinazione sta sempre sotto, gia' costruita**: l'intro non decide dove si
va, ritarda solo il momento in cui si vede. Chi ha gia' fatto il Risveglio entra
nel Cerchio, chi non l'ha fatto lo trova ad aspettarlo.

## Il logo: ho scelto quello COMPLETO

`Logo-Definitivo-2.png`, quello col nome, **perche' una firma d'apertura deve
dire come si chiama il prodotto**: il solo simbolo e' un'icona, e un'icona non
si presenta.

Esportato in `assets/brand/logo.png`, **162 KB** a 720 pixel di lato con
tavolozza a 256 colori e trasparenza conservata. Il sorgente resta fuori dal
versionamento, dov'era.

**Un limite che dichiaro**: il sorgente del logo completo e' 410 per 410, quindi
a densita' 3 copre bene fino a circa 240 punti logici a schermo. Il logo compare
a 220 e cresce dell'otto per cento: ci sta, e piu' grande si vedrebbe la
sgranatura del sorgente, non del nostro export.

## La voce, e la firma che le cede il posto

`principio.mp3` parte insieme alla comparsa della scritta, e **la macchina da
scrivere e' calibrata sulla sua durata**, letta dal file e non scritta a mano: se
un giorno la voce cambia, la scritta la segue da sola. Il ripiego dichiarato,
2,43 secondi, vale quando la durata non si legge.

**La firma non suona quando c'e' l'intro**, ed e' la seconda delle due strade che
l'ordine lasciava scegliere. La firma dura due secondi e la voce 2,43: farle
convivere sulla stessa schermata nera vorrebbe dire sfumarne una sotto l'altra in
tre secondi scarsi. Due suoni che si contendono lo stesso momento non fanno
un'apertura piu' ricca, fanno rumore. La firma resta per le sessioni senza intro.

**Il tocco ferma anche la voce**, subito. **Riduci Movimento non tocca l'audio**:
la voce suona comunque, cambia solo il modo in cui la scritta compare. **Col
suono di sistema spento la voce non suona e i tempi restano identici**, perche'
la sequenza non dipende dall'audio, lo accompagna.

**La regola dei cinque suoni ha fatto il suo mestiere**: la voce e' il sesto, e
la prova l'ha denunciata come suono nato fuori dal catalogo. L'ho fatta entrare
nel catalogo invece di aggirare la regola.

## Il peso

| Cosa | Byte | |
|---|---|---|
| Video | 1.717.300 | 1,72 MB |
| Logo esportato | 162.008 | 0,16 MB |
| Voce | 39.332 | 0,04 MB |
| **Somma** | **1.918.640** | **1,92 MB** |

**La dipendenza**: `video_player ^2.13.0`, che ha portato con se' sette pacchetti
fra plugin di piattaforma e interfacce. Il peso vero lo si legge nell'archivio
finale, dichiarato nella consegna.

## Le prove

**Sei**, e coprono le due cose che l'ordine chiede: la sequenza coi suoi tempi,
compreso il respiro fra la fine della scrittura e la dissolvenza; e il tocco che
salta e porta alla destinazione, **in tutti e due i casi**, con l'intro e senza,
che e' il modo di provare che la destinazione sotto e' la stessa.

**Il video non si riproduce in prova headless**: non c'e' una piattaforma che lo
decodifichi. La sequenza prosegue lo stesso, perche' il codice tratta un video
che non parte come un video finito.

## I tre fotogrammi

- `docs/preview/prima_dopo/intro_frase.png`, la frase a meta' scrittura
- `docs/preview/prima_dopo/intro_logo.png`, il logo
- `docs/preview/prima_dopo/intro_destinazione.png`, la destinazione

## La frase di accettazione

**Apri l'app: schermo nero, "IN PRINCIPIO ERA IL NULLA" che si scrive mentre la
voce la pronuncia, poi il video, poi il logo, poi il Cerchio. Riaprila e tocca lo
schermo: salta tutto e sei subito dentro.**
