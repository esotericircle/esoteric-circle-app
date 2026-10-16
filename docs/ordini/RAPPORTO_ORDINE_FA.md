# RAPPORTO DELL'ORDINE FA, LE ICONE, I NOMI E LE PROMESSE

**FA.03 era la possibilita' (a): la cattura, non l'app.** La vetrina non aveva
schede, era un elenco unico che scorreva: la cattura degli archetipi
trascinava oltre la fine dell'elenco, che non si muoveva, e fotografava la
stessa schermata di quella degli Arcani. Nessun difetto vivo nell'app, ma
una prova che dichiarava cio' che non provava.

Ramo `claude/esoteric-circle-master-order-e798aj`, partenza `31821ce2`, 4
ottobre 2026. Manifesto: `docs/ordini/ORDINE_FA_MANIFESTO.md`. Registro della
Regola A: `docs/collaudo/FA/regola_a_fa.txt`. Anteprime prima e dopo, a 360
per 797 punti: `docs/preview/prima_dopo/fa*`. **Nessuna build** (R9).

## LE VOCI CHIUSE, con la prova di ciascuna

- FA.01, via le carte dalle icone del profilo: test/gli_arcani_escono_dalle_icone_test.dart
- FA.02, il segno numero 15 dice il vero: test/i_segni_dicono_il_vero_test.dart
- FA.03, la cattura che mostra un'altra schermata: test/le_catture_della_vetrina_sono_diverse_test.dart
- FA.06, la frase neutra, e basta una: test/i_segni_dicono_il_vero_test.dart

Le altre due, FA.04 ed FA.05, sono APERTE IN ATTESA DI VERIFICA: il codice e
le prove ci sono, il server va pubblicato.

## LE PREMESSE ABBATTUTE

Verificate tutte sul worktree alla testa `31821ce2`, prima di scrivere codice.

- **F1 vera.** Quattro famiglie, 12, 12, 22 e 12, 58 icone, `famiglia:indice`.
- **F2 vera.** `IconaDelProfilo.da` ricadeva su `segno:0`, l'Ariete, per
  chiunque.
- **F3 vera.** `iconaValida` e `QUANTE_ICONE` in `functions/src/sociale.ts`, e
  `i_numeri_del_cerchio_sociale_test` confronta i conti.
- **F4 vera.** Il quindicesimo segno apriva la porta della Sinastria VIP.
- **F5 vera.** La sola sinastria del progetto e' la Sinastria VIP
  (`porta_della_sinastria.dart`).
- **F6 vera.** Due varianti di genere e una neutra, dall'ordine EZ.
- **F7 vera.** Le due catture erano la stessa schermata: qui ho misurato il
  4,94 per cento di pixel diversi nella fascia bassa con differenza massima 30
  su 765, cioe' lo stesso disegno con un rumore minimo. La causa e' in testa
  al rapporto.
- **F8 vera.** Cinque letture per apertura e quarantaquattro per quella che
  ricostruisce: le cinque erano quattro fisse piu' la domanda degli amici
  con un amico presente, e la domanda cresceva di una lettura per ogni amico
  presente, senza tetto.
- **F9 vera.** `CartaDiNascitaDeiTarocchi` esiste e l'Arcano personale vive
  nel Passaporto: non l'ho toccato.
- **F10 vera.** La sigla FA era libera.
- **F11 vera.**

## FIN DOVE SONO ARRIVATO, E PERCHE'

Tutte e sei le voci, col codice, le prove, la Regola A e le anteprime; il
fondatore ha scelto "tutto, in una volta" sulla stima di cinque o sei ore.
**Server: 182 prove su 182.** Nessuna build, nessuna chiamata al modello.

**Del manifesto EZ** ho toccato la riga di stato della voce EZ.03, come chiede
la FA.05, e due cose che la sua guardia pretende insieme: i marcatori
(chiuse da 4 a 5, aperte da 4 a 3) e la riga della voce nell'elenco delle
chiuse del rapporto EZ. Il resto e' com'era.

**Una scelta di forma, mia, dichiarata (FA.03).** La vetrina mostra adesso
una famiglia alla volta, con tre scelte in cima, e si apre sulla famiglia
dell'icona di oggi. Con tre famiglie da dodici l'elenco unico scorreva
appena, e le catture degli animali e degli archetipi sarebbero tornate la
stessa schermata: il difetto non si curava rifacendo le catture.

**Una scelta di forma, mia, dichiarata (FA.05).** Per stare sempre sotto le
dieci letture qualunque sia il numero degli amici, la tendina mostra al
massimo **sei amici presenti**, trovati con una domanda sola sulle presenze
che portano chi guarda fra i loro amici. La presenza porta adesso l'elenco
degli amici, aggiornato nello stesso punto e nella stessa transazione dei
legami.

## LE DECISIONI CHE RESTANO AL FONDATORE

1. **La pubblicazione** del server e dell'indice nuovo (il comando e' qui
   sotto). Senza, il telefono nuovo funziona e la tendina mostra gli amici
   presenti solo dopo che le presenze hanno l'elenco degli amici, cioe' al
   primo passo di ciascuno col server nuovo.
2. **I sei amici presenti nella tendina**: se il fondatore ne vuole di piu',
   la soglia di dieci letture va rialzata insieme.
3. **Le persone bloccate** non mostrano piu' sempre il sigillo sotto il nome:
   la regola della FA.04 vale anche li', come l'ordine chiede.

## IL COMANDO PER LA PUBBLICAZIONE

Dal worktree, al commit di consegna, prima gli indici:

    firebase deploy --project esoteric-circle --only "firestore:indexes,functions:ilMioProfiloNelCerchio,functions:scegliIlNome,functions:aggiornaIlProfiloNelCerchio,functions:ilCodiceDellInvito,functions:leggiIlCodice,functions:chiediIlLegame,functions:rispondiAlLegame,functions:bloccaUnaPersona,functions:ilMioCerchio,functions:compraUnPostoNelCerchio,functions:laTendinaDelCerchio,functions:mandaUnSegno,functions:rispondiAlSegno,functions:mandaUnDono,functions:regalaGliEos,functions:scriviIlTokenDelCerchio,functions:paginaDellInvito,functions:chiEOnline,functions:riscattaLInvito,functions:cancellaIlCerchio,functions:azzeraIDatiDelCerchio"

E' lo stesso comando dell'ordine EZ, piu' le due porte che cancellano il
Cerchio (tolgono anche l'amico dalle presenze degli altri). Chi pubblica
questo comando pubblica anche il lavoro EZ ancora fermo.

## LE MISURE, voce per voce

- **FA.01.** Icone prima 58 in quattro famiglie, dopo 36 in tre, uguali al
  server. Fra i dati di prova di partenza tre persone avevano un Arcano (le
  anteprime dell'ordine EZ: chi guarda, "Luce del Mago" e la scheda
  dell'amico): ricadono su Toro, Gemelli e Pesci, il loro segno. Una persona
  dei Pesci con l'Arcano 1 diventa `segno:11`; prima ogni codice sbagliato
  diventava `segno:0`. Pixel nella corona: 0 su 36 icone.
- **FA.02.** Segni che promettono una cosa e ne aprono un'altra: 1 su 18
  prima, 0 dopo; richieste con una destinazione irraggiungibile 0 su 6.
- **FA.03.** Pixel diversi (oltre 32 su 765) nel rettangolo delle icone, fra
  le tre famiglie della vetrina: segni e animali 24,80 per cento, segni e
  archetipi 24,03, animali e archetipi 10,63; la stessa schermata resa due
  volte 0,00. Soglia 5 per cento.
- **FA.04.** Due nomi uguali per l'occhio: sigilli a schermo 2 su 2, sul
  terzo 0; nessuna collisione: 0 su 3; nel tuo Cerchio coi due "Eco Corvo
  Mite" prima 0 sigilli, dopo 2.
- **FA.05.** Letture di un'apertura normale, contate sul codice: al massimo 10
  (tetto 1, identita' 1, legami 1, blocchi 1, amici presenti al massimo 6),
  soglia 10; prima 4 piu' una per ogni amico presente. L'apertura che
  ricostruisce l'istantanea: 44, condivisa ogni trenta secondi fra tutti.
  Il primo passo della presenza legge adesso anche i legami: 2 letture invece
  di 1, una volta per avvio.
- **FA.06.** Righe e risposte dei segni: 73, col genere di chi legge 0; prima
  1 segno marcato con tre forme.

## COSA HANNO TROVATO LE PROVE

- **La prova delle anteprime EZ nominava la famiglia degli Arcani**, e senza
  la famiglia non compilava piu': corretta con la lapide.
- **La prima misura della FA.03 confrontava la stessa schermata con un'altra
  famiglia** e guardava anche il fondo vuoto sotto le icone: misurava 10,54
  per cento su due schermate uguali. Corretta la grandezza (il rettangolo
  delle icone, la stessa famiglia resa due volte), non la soglia.
