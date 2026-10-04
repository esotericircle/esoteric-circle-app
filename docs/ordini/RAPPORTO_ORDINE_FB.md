# RAPPORTO DELL'ORDINE FB, TUTTI GLI AMICI NELLA TENDINA

**La tendina non ha piu' tetti sugli amici, e un'apertura legge 5 documenti
con 10 amici presenti come con 150.** Gli amici presenti si incrociano in
memoria, e la presenza sta in novantasei frammenti condivisi invece che in un
documento per persona. Il server va pubblicato dal fondatore (comando qui
sotto); finche' non lo e', la tendina in produzione e' quella di prima.

Ramo `claude/esoteric-circle-master-order-e798aj`, partenza `6d0ba515`, 4
ottobre 2026. Manifesto: `docs/ordini/ORDINE_FB_MANIFESTO.md`. Registro della
Regola A: `docs/collaudo/FB/regola_a_fb.txt`. Costi in euro:
`docs/collaudo/FB/i_costi_in_euro.txt`. Anteprime prima e dopo, a 360 per 797
punti: `docs/preview/prima_dopo/fb*`. **Nessuna build** (R9), nessuna
chiamata al modello (R11).

## LE VOCI CHIUSE, con la prova di ciascuna

- FB.02, il sigillo sempre fra i bloccati: test/il_sigillo_sempre_fra_i_bloccati_test.dart
- FB.03, il rapporto EZ come consegnato: test/i_rapporti_consegnati_non_si_correggono_test.dart

La terza, FB.01, e' APERTA IN ATTESA DI VERIFICA: il codice e le prove ci
sono, il server va pubblicato. La sua prova e'
test/la_tendina_non_supera_dieci_letture_test.dart.

## LE PREMESSE ABBATTUTE

Verificate sul worktree alla testa `6d0ba515`, prima di scrivere codice.

- **G1-G6 e G8 vere.**
- **G7 vera a meta'.** L'ordine FA ha toccato il rapporto EZ consegnato in
  una riga sola, quella aggiunta all'elenco delle voci chiuse in cima ("EZ.03,
  le letture della tendina scendono (chiusa dall'ordine FA voce 05)"); i
  conteggi delle voci (chiuse da 4 a 5, aperte da 4 a 3) li ha cambiati nel
  manifesto EZ, non nel rapporto. La riga e' tolta, e il corpo ha di nuovo
  l'impronta del commit di consegna `31821ce2`.

## FIN DOVE SONO ARRIVATO, E PERCHE'

Tutte e tre le voci, col codice, le prove, la Regola A, le anteprime e i
costi in euro. **Server: 185 prove su 185.** **Suite intera** al commit
`3c526014`, sulla copia a parte: **+6683 ~11 -9**. Sette cadute erano rosse
prima di quest'ordine e non sono sue (`le_soglie_della_scansione_sono_provvisorie`,
ordine CR voce 13, e le guardie degli ordini ACCELERA, EI, EJ, EK, EM ed EN);
due erano mie, e sono il difetto 9 qui sotto, corrette dopo la suite e
riprovate una per una.

**I numeri che l'ordine chiede.**

- **Letture di un'apertura** con 10 amici presenti **5**, con 150 **5**
  (il tetto della porta, l'identita', i legami, i blocchi e l'istantanea).
  Con l'ordine FA erano 10 e 10, ma con 150 amici presenti la tendina ne
  mostrava 6.
- **Ricostruzioni**: una ogni trenta secondi per tutto il Cerchio, a turno
  preso in transazione, e la fa solo il passo della presenza. Legge il turno
  e i frammenti che esistono: 2 documenti con una persona presente, 97 con
  mille come con centomila.
- **Il telefono non riceve mai l'elenco dei presenti**: la tendina
  restituisce solo gli amici di chi chiede e le persone simili di prima.
- **Byte per presente**: una voce dell'istantanea pesa al massimo 172 byte
  (identificativo di 28 caratteri, nome di venti lettere accentate, sigillo,
  l'icona, il segno e l'arte piu' lunghi). In un mebibyte ne stanno 6.096.
  **Il tetto dichiarato e' 5.000 presenti**, che occupano 860.350 byte, l'82,0
  per cento del limite; la prova cade sopra l'85 per cento, prima del limite.
  Oltre i 5.000 l'istantanea si tronca e lo dice (`troncata`).
- **I frammenti** reggono una scrittura al secondo ciascuno, cioe' sessanta
  presenti a un passo al minuto: novantasei ne reggono 5.760, piu' del tetto
  dell'istantanea. Una prova cade se i due tetti si separano.
- **I costi in euro**, coi prezzi di Firestore del catalogo di Google
  (europe-west1, edizione Standard, letti il 4 ottobre 2026: 0,029 euro ogni
  100.000 letture, 0,0871 euro ogni 100.000 scritture). Il conto, con le sue
  ipotesi scritte, e' `tool/i_costi_dell_ordine_fb.py`. Euro al mese se N
  persone fossero presenti tutto il mese, prima (ordine FA) e dopo:

  | presenti | prima | dopo | differenza |
  | ---: | ---: | ---: | ---: |
  | 1 | 0,53 | 0,27 | -0,26 |
  | 10 | 1,25 | 0,83 | -0,41 |
  | 100 | 6,55 | 5,74 | -0,81 |
  | 1.000 | 56,10 | 42,41 | -13,69 |
  | 5.000 | 528,31 | 201,69 | -326,62 |

  Nel caso peggiore dei frammenti (ogni presente in un frammento diverso, che
  con cento persone e novantasei frammenti non succede: gli attesi sono 62)
  a cento presenti il dopo costerebbe 0,03 euro al mese piu' del prima. La
  parte piu' grande del costo sono le scritture del passo, sessanta all'ora
  per presente, uguali prima e dopo.

**Il rapporto EZ.** Ha di nuovo il corpo consegnato, e in coda una riga sola:
"**Aggiunta del 4 ottobre 2026, ordine FB voce 03.**", con la chiusura di
EZ.03 da parte dell'ordine FA, la data e la prova. Il manifesto EZ non e'
toccato.

**La guardia che era sbagliata**, come l'ordine prevedeva: e'
`ogni_voce_chiusa_porta_la_sua_prova_test.dart`. Pretendeva che l'elenco in
cima al rapporto contenesse ogni voce chiusa del manifesto di oggi: una voce
chiusa da un ordine successivo poteva entrarci solo riscrivendo il rapporto
consegnato, ed e' quello che l'ordine FA ha fatto per tenerla verde. Adesso
una voce chiusa dopo la consegna e' in regola se una riga `**Aggiunta del` in
coda la nomina con la sua prova. **La regola vale da qui in avanti** e ha la
sua guardia: `i_rapporti_consegnati_non_si_correggono_test.dart` legge il
registro `docs/ordini/RAPPORTI_CONSEGNATI.txt`, che porta l'impronta del corpo
di tutti i cinquanta rapporti, questo compreso. La regola e' scritta anche in
`CLAUDE.md`, nel protocollo della chiusura.

## I DIFETTI TROVATI, ognuno col suo padre

1. **Il sigillo tagliato dai puntini.** Nome e sigillo stavano in un solo
   testo coi puntini in coda: dove la riga era stretta (fra i bloccati,
   accanto a "Sblocca") i puntini mangiavano proprio il sigillo. Le prove
   FA.04 passavano perche' guardavano l'albero dei widget, non i pixel.
   Trovato guardando l'anteprima di FB.02. **Padre: ordine FA voce 04.**
   Adesso si accorcia il nome e il sigillo resta intero, e una prova misura
   il paragrafo del sigillo in una riga stretta.
2. **L'apertura che ricostruiva l'istantanea.** La tendina che trovava
   l'istantanea vecchia la rifaceva: 44 letture in quell'apertura con
   l'ordine EZ. La guardia delle dieci letture la escludeva dal conto come
   "condivisa". **Padre: ordine EZ voce 03, tenuto dall'ordine FA voce 05.**
   Adesso la ricostruisce solo il passo della presenza, e la guardia pretende
   che la tendina la chieda senza ricostruire.
3. **La guardia che spingeva a riscrivere un rapporto consegnato.** **Padre:
   ordine EH voce 04 (la guardia), ordine FA voce 05 (la riga nel corpo del
   rapporto EZ).**
4. **Nella prima stesura di questa voce, tre difetti miei, trovati dal conto
   in euro e dalle prove prima della consegna. Padre: ordine FB voce 01.**
   Trentadue frammenti reggevano 1.920 presenti contro i 5.000 promessi
   dall'istantanea, e fra i due numeri le scritture sarebbero andate in
   contesa senza che nessun numero lo dicesse. L'apertura che trovava
   l'istantanea vecchia leggeva 102 documenti. La ricostruzione leggeva
   sempre tutti i frammenti, e con pochi presenti costava piu' dell'ordine FA
   (2,90 euro al mese contro 0,53 con una persona sola). Tutti e tre
   corretti, ognuno con la sua prova e il suo innesto rosso (A1, A15, A16).
5. **Il profilo sotto i quattordici anni toglieva solo il documento di prima,
   non la voce nel frammento**: una persona di tredici anni sarebbe rimasta
   nell'istantanea fino alla fine della finestra. Trovato rileggendo il
   server prima di scrivere questo rapporto. **Padre: ordine FB voce 01.**
   La guardia dei quattordici anni adesso guarda anche la voce (A17).
6. **Il nome dei bloccati ridotto a "Brina Lu...".** Nella prima stesura di
   FB.02 il sigillo stava accanto al nome anche fra i bloccati. Trovato
   guardando l'anteprima. **Padre: ordine FB voce 02.** Fra i bloccati il
   sigillo sta sotto il nome, com'era prima dell'ordine FA.
7. **La Regola B mancata sulla guardia della tendina.** Ho cambiato il server
   della tendina prima di vedere rossa la sua guardia; e' diventata rossa per
   il mio cambio (la costante dei sei sparita), e l'ho riscritta. La prova del
   rosso vero sono i suoi innesti A4, A5 e A6. **Padre: ordine FB voce 01.**
   Sulle altre due guardie della zona (FA.04 e i quattordici anni) la
   Regola B e' stata fatta prima di toccarle.
8. **Il banco della Regola A si e' fermato al primo innesto**: la console di
   Windows non stampava il segno delle prove cadute. Il file era gia' rimesso
   dalla copia, verificato col grep; rilanciato in UTF-8. **Padre: ordine FB,
   il banco.**
9. **Due prove cadute nella suite intera per il cambio della presenza.**
   `chi_esce_dal_cerchio_esce_dal_conto` cercava la parola `.delete()` nella
   porta, cioe' come si toglieva il documento di prima, e non il fatto;
   `online_nella_barra_e_gli_eventi_nel_passport` (ordine ES voce 15)
   pretendeva la presenza sotto users/{uid}, il conto `.count()` e il suo
   indice. Viste rosse dalla suite prima di toccarle, riscritte sul fatto:
   il ramo di chi esce toglie la presenza prima di rispondere (A18); le
   porte che cancellano tolgono la voce prima del ramo (A19) e ogni risposta
   porta il solo numero (A20). **Padre: ordine FB voce 01**, che le ha
   cambiate sotto i piedi, e per la prima la guardia legata alla parola
   dell'ordine EV voce 06. **E un difetto mio nella riscrittura**: la prima
   A19 era cieca, perche' la guardia riscritta cadeva anche senza innesto
   (un'espressione regolare sbagliata); e una prova a mano con una chiave in
   piu' nella risposta mostrava che la guardia non la vedeva. Corretta,
   stretta, e A19 e A20 rifatte.

## LE DECISIONI CHE RESTANO AL FONDATORE

1. **La pubblicazione del server** (il comando e' qui sotto). Nessun indice
   nuovo: il file degli indici torna a zero indici composti, come la
   produzione (letta il 4 ottobre 2026: zero). Gli indici che gli ordini EZ
   e FA avevano aggiunto al file non sono mai stati pubblicati e non servono
   piu'.
2. **I documenti di presenza di prima** (`users/{uid}/presenza/adesso`) dopo
   la pubblicazione non si leggono e non si scrivono piu'. Restano dove sono:
   cancellarli e' una scrittura sui dati di produzione, e la decide il
   fondatore. Non costano letture.
3. **Oltre i 5.000 presenti nello stesso momento** l'istantanea si tronca e
   lo dice; il giorno che servira' andra' spezzata come la presenza.

## IL COMANDO PER LA PUBBLICAZIONE

Dal worktree, al commit di consegna:

    firebase deploy --project esoteric-circle --only "functions:ilMioProfiloNelCerchio,functions:scegliIlNome,functions:aggiornaIlProfiloNelCerchio,functions:ilCodiceDellInvito,functions:leggiIlCodice,functions:chiediIlLegame,functions:rispondiAlLegame,functions:bloccaUnaPersona,functions:ilMioCerchio,functions:compraUnPostoNelCerchio,functions:laTendinaDelCerchio,functions:mandaUnSegno,functions:rispondiAlSegno,functions:mandaUnDono,functions:regalaGliEos,functions:scriviIlTokenDelCerchio,functions:paginaDellInvito,functions:chiEOnline,functions:riscattaLInvito,functions:cancellaIlCerchio,functions:azzeraIDatiDelCerchio"

E' il comando dell'ordine FA senza `firestore:indexes`. Chi lo pubblica
pubblica anche il lavoro EZ e FA ancora fermo.

## LE ANTEPRIME

- `fb01_tendina_dodici_amici_prima/dopo` e `..._in_fondo_prima/dopo`: prima
  la tendina finiva al sesto amico, dopo li mostra tutti e dodici, e sotto
  c'e' ancora "Il Cerchio adesso". La "prima" e' la risposta del server di
  allora (i primi sei), dichiarato nella prova delle anteprime.
- `fb02_bloccati_col_sigillo_prima/dopo`: prima nessun sigillo e "Fiamma
  Cervo Le..." tagliato; dopo il nome intero e il sigillo sotto.
- `fb02_due_nomi_uguali_prima/dopo`: i due "Eco Corvo Mite" coi due sigilli,
  uguali prima e dopo, perche' li' la riga era larga abbastanza.

## LA REGOLA A

Venti innesti in cinque giri, tutti entrati (grep del pezzo nuovo e del
vecchio), tutti rossi sul bersaglio, ogni file rimesso dalla copia e
confrontato al byte: `docs/collaudo/FB/regola_a_fb.txt`. La prima A19 era
cieca ed e' confessata nel registro e al difetto 9.
