# RAPPORTO DELL'ORDINE EZ, IL CERCHIO SENZA DIFETTI

Ramo `claude/esoteric-circle-master-order-e798aj`, partenza `983a9cfc`, 4
ottobre 2026. Manifesto: `docs/ordini/ORDINE_EZ_MANIFESTO.md`. Registro della
Regola A: `docs/collaudo/EZ/regola_a_ez.txt`. Anteprime prima e dopo, a 360
per 797 punti: `docs/preview/prima_dopo/ez*`. **Nessuna build** (R9).

## LE VOCI CHIUSE, con la prova di ciascuna

- EZ.02, il confronto del cielo cambia davvero ogni giorno: test/il_confronto_del_cielo_e_simmetrico_test.dart
- EZ.05, il gift Eos si dichiara invece di fallire: test/il_gift_eos_si_dichiara_test.dart
- EZ.06, gli amici offline hanno un numero anche all'Illuminato: test/gli_amici_offline_hanno_un_numero_test.dart
- EZ.08, i diciotto segni coi testi veri: test/i_segni_del_cerchio_hanno_i_testi_veri_test.dart

Le altre quattro: EZ.01 APERTA IN ATTESA DI VERIFICA (il giudizio visivo sulle
icone piccole e' del fondatore), EZ.03 APERTA sulla soglia delle letture,
EZ.04 ed EZ.07 APERTE IN ATTESA DI VERIFICA (la pubblicazione delle funzioni e
una build).

## LE PREMESSE ABBATTUTE

Verificate tutte sul worktree alla testa `983a9cfc`, prima di scrivere codice.

- **Q1 vera.** `FamigliaDelleIcone` con 12, 12, 22 e 12 (58), il codice
  `famiglia:indice`, il getter `asset` e `eUnaCarta` col commento "l'icona
  tonda ne prende il cuore".
- **Q2 FALSA, ed e' il caso che l'ordine stesso prevedeva.** Il disegno passa
  GIA' da un componente solo, `IconaTonda` in
  `lib/features/cerchio/widgets/disegni_del_cerchio.dart`: SETTE chiamate in
  cinque file (il confronto due, il profilo due, il tuo Cerchio, la richiesta
  di legame, la scheda dell'amico), nessun altro punto legge l'immagine. Nel
  primo messaggio al fondatore avevo scritto otto: ho contato male io, sono
  sette, e la prova li conta. **La tendina e i doni non disegnano icone**:
  le catture "dentro la tendina vera" non si possono fare, e le ho fatte nella
  vetrina, nel tuo Cerchio, nel profilo e nella scheda dell'amico.
- **Q3 vera.** `IlConfrontoDelCielo.fra` usa `AltreAffinita.terraComune` e
  `.ritmo`; in `functions/src` non compare `terraComune`.
- **Q4 vera.** Le 78 coppie su 29 giorni, e il cambio col giorno pretendeva
  solo `greaterThan(1)` su Leone e Pesci.
- **Q5 vera.** Quattro valori per Leone e Pesci in trenta giorni.
- **Q6 vera.** 841 contro 120.000. **Ma il conto dell'ordine EY era
  incompleto**: non contava il tetto della porta (EY.16, una lettura per
  chiamata) ne' il passo della presenza (due letture al minuto). Rifatto col
  metodo intero, lo stesso scenario dava 901 per la tendina e 120 per il passo.
- **Q7 vera.** `Effemeridi` e' la porta sola del cielo, verificata contro JPL
  Horizons (`test/effemeridi_contro_fonte_terza_test.dart`).
- **Q8 vera.** 150 e 150 in `borsellino.ts`, e `DOTE_DEL_PIANO` dice che
  l'accredito scattera' quando gli abbonamenti saranno acquistabili.
- **Q9 vera.** `"acquisto"` esiste solo come tipo di movimento: nessuna porta
  lo scrive.
- **Q10 vera.** La riga si chiama "Oroscopo per gli amici",
  `['No', '3', '10', 'Senza limite']`, e `amicoInPiu` ha il nullo
  sull'Illuminato.
- **Q11 vera.** Segnaposto dichiarati di Code; il server conosce gli
  identificativi in `RISPOSTE_PER_SEGNO`.
- **Q12 vera.** L'ultimo manifesto era `ORDINE_EY_MANIFESTO.md`.
- **Q13 vera.** Niente in CLAUDE.md o negli agenti dice il contrario.

## FIN DOVE SONO ARRIVATO, E PERCHE'

Tutte e otto le voci, col codice, le prove, la Regola A e le anteprime. Il
fondatore ha scelto "tutto, in una volta" sulla stima di nove o dieci ore.
**Server: 181 prove su 181** (`npm test`). Nessuna build: la ordina il
fondatore (R9). Nessuna chiamata al modello in nessuna voce (R11).

**Cosa ferma la verifica a video.** Le voci EZ.03, EZ.04, EZ.07 ed EZ.08
toccano il server, e le funzioni le pubblica il fondatore (il controllo dei
permessi di Code nega il deploy). Il telefono di oggi resta compatibile col
server nuovo e il telefono nuovo col server di oggi: chi non ha la build nuova
non manda `quattordici` e il server la ricava dalla maggiore eta' dichiarata;
chi non ha il server nuovo riceve dal telefono campi in piu' che ignora.

## LE DECISIONI CHE RESTANO AL FONDATORE

1. **La pubblicazione** (il comando e' qui sotto), con gli indici nuovi di
   Firestore.
2. **EZ.03, la soglia delle 150 letture.** Il costo che cresceva con le
   persone e' sceso di venti volte (un'apertura che rifa' l'istantanea: da
   1.006 a 44 letture). Ma nello scenario dell'ordine EY, sessanta aperture
   della tendina in un'ora, ogni apertura legge per forza cinque documenti
   (il tetto della porta EY.16, l'identita', i legami, i blocchi, la domanda
   degli amici): 300 letture prima ancora dell'istantanea, e nessun disegno
   che tenga il tetto per identita' e i controlli sul server scende sotto due
   per apertura. Con sei aperture in un'ora il conto e' 32. **La scelta
   consigliata**: misurare sullo scenario d'uso (sei aperture) e chiudere
   cosi'; l'alternativa e' fondere identita', legami e blocchi in un
   documento solo, un rifacimento delle porte EY che porta a tre letture per
   apertura (180 in un'ora con sessanta aperture, ancora sopra 150).
3. **EZ.01, le icone piccole.** A 44 e 64 punti gli **archetipi** (statue alte
   e sottili su fondo trasparente) e gli **Arcani** (carte intere) diventano
   piccoli. Il progetto non ha un'immagine dell'Arcano senza la cornice della
   carta: se il fondatore la vuole, e' un'immagine nuova, che genera lui.
   Catture: `docs/preview/prima_dopo/ez01_vetrina_gli_archetipi_dopo.png`,
   `ez01_vetrina_gli_arcani_dopo.png`, `ez01_il_tuo_cerchio_quattro_famiglie_dopo.png`.
4. **EZ.08, la sinastria fra due amici.** Il Cerchio non porta la nascita di
   un amico, solo il segno: "Facciamo la sinastria" apre la porta della
   Sinastria, dove si sceglie con chi farla. Una sinastria vera fra due
   persone del Cerchio vorrebbe la nascita dell'altro, cioe' un consenso che
   oggi non esiste.
5. **EZ.07, il dominio `esotericircle.app`** oggi non risponde: finche' non
   passa a Firebase Hosting i link partono da `esoteric-circle.web.app`. Il
   Team ID Z3T97U389U e' quello che Firebase pubblica nel file di Apple; il
   fondatore lo conferma in Apple Developer, Membership. Quando l'app sara'
   su Play con la firma di Google, la sua impronta va registrata in Firebase
   e il file si aggiorna da se'.
6. **EZ.04, chi non ha una data di nascita** (l'identita' d'esempio) non
   apre il Cerchio sociale e legge la stessa riga dei quattordici anni: senza
   data l'eta' non si sa, e la regola sceglie di non aprire.
7. **Gli indirizzi degli store** per la pagina del link, quando l'app sara'
   pubblicata: si scrivono in `INDIRIZZI_DEGLI_STORE` e basta.

## IL COMANDO PER LA PUBBLICAZIONE

Dal worktree, al commit di consegna:

    firebase deploy --project esoteric-circle --only "firestore:indexes,functions:ilMioProfiloNelCerchio,functions:scegliIlNome,functions:aggiornaIlProfiloNelCerchio,functions:ilCodiceDellInvito,functions:leggiIlCodice,functions:chiediIlLegame,functions:rispondiAlLegame,functions:bloccaUnaPersona,functions:ilMioCerchio,functions:compraUnPostoNelCerchio,functions:laTendinaDelCerchio,functions:mandaUnSegno,functions:rispondiAlSegno,functions:mandaUnDono,functions:regalaGliEos,functions:scriviIlTokenDelCerchio,functions:paginaDellInvito,functions:chiEOnline,functions:riscattaLInvito"

Prima gli indici: le aggregazioni per arte e la domanda degli amici li
vogliono, e finche' si costruiscono (qualche minuto) la tendina risponde con
un errore che il telefono tratta come il Cerchio che non risponde.

## LE MISURE, voce per voce

- **EZ.01.** Pixel del soggetto nella corona del tondo: 0 su 58 icone a 112
  punti e 0 su 58 a 44 punti; col riempimento di prima (innesto A1) ogni
  icona ne aveva. Margine per lato: 18,5 punti a 112 (16,5 per cento), 8 a 44
  (18 per cento), 11,5 a 64 nella vetrina. Punti che leggono l'immagine fuori
  dal componente: 0; chiamate del componente: 7 in 5 file, prima e dopo.
- **EZ.02.** Valori distinti in trenta giorni dal 4 ottobre 2026 sulle 78
  coppie: prima da 3 a 7, mediana 4, la peggiore Ariete e Toro (3); dopo da
  18 a 25, mediana 22, la peggiore Bilancia e Pesci (18). Quattro finestre di
  stagioni diverse: minimo 17 (Ariete e Sagittario, dal 30 luglio 2027).
  Salto massimo fra due giorni: prima 11 (Ariete e Leone), dopo 6. Simmetria:
  0 differenze su 2.262 confronti. Leone e Pesci il 4 e il 5 ottobre: prima
  51 e 50, dopo 59 e 55.
- **EZ.03.** Mille presenti, cento telefoni che chiedono, quindici amici di
  cui uno presente. Un'apertura che rifa' l'istantanea: 1.006 contro 44.
  Sessanta aperture in un'ora: 901 contro 323. Sei aperture: 90 contro 32. Il
  passo della presenza in un'ora: 120 contro 61. L'istantanea passa da un
  elenco di tutti i presenti (fino a tremila schede) a quattordici numeri e
  ventiquattro schede.
- **EZ.04.** 16 porte del server su 16 passano dalla soglia, dentro la
  transazione del tetto (zero letture in piu'); 15 gesti del telefono a
  tredici anni, al server ne arriva 1 su 16 (la porta che riceve l'eta').
- **EZ.05.** Porte che alzano gli Eos regalabili: 0. Pulsanti che tentano di
  spendere: 1 prima, 0 dopo.
- **EZ.06.** Piani senza limite: 1 su 4 prima, 0 su 4 dopo, nella matrice e
  nel listino. Posti 0, 3, 10, 50.
- **EZ.07.** Rimandi a uno store nella pagina: 2 prima, 0 dopo col dato vuoto,
  2 col dato pieno. Impronta del file di Android uguale a quella dell'APK.
- **EZ.08.** 18 segni, 6 per categoria, 0 incompleti, 0 segnaposto, 0 righe
  astrali che affermano il cielo su 24 (prima 4 dei 6 segni astrali), 0
  differenze col server.

## LA REGOLA A

Diciassette innesti, uno o due per ogni prova nuova, tutti entrati (grep del pezzo nuovo 1, del vecchio 0) e tutti ROSSI, ogni file rimesso uguale al byte: `docs/collaudo/EZ/regola_a_ez.txt`. **A11 la prima volta e' restata verde**: la prova del gift era cieca a una porta che alza gli Eos regalabili; cambiata la grandezza misurata, poi rossa. Le guardie salgono da 664 a **670** (`docs/guardie.md`, categorie 148, 227 e 295).

## COSA HANNO TROVATO LE PROVE E LE ANTEPRIME

- **La regola delle forme vietate non vedeva "è"** (EZ.08): in Dart `\b` non
  conta le lettere accentate. L'ha mostrato la prova stessa, che prendeva tre
  righe di prima su quattro; i confini sono scritti a mano.
- **Le prove del Cerchio montavano il Cerchio senza data di nascita**
  (EZ.04): con la soglia nuova sarebbero diventate tutte la riga dei
  quattordici anni. Ora montano una nascita adulta.
- **Il primo prototipo del cielo di oggi** (EZ.02) mediava la Luna sui due
  segni separatamente: per molte coppie i due termini si annullavano, e non
  arrivava insieme a quindici valori e al salto di dodici. Per i segni
  opposti i due punti medi annullavano il cielo per intero. Curato col punto
  d'incontro e la regola dell'opposto.
- **Le anteprime**: la vetrina e il tuo Cerchio mostrano le figure intere;
  gli archetipi e gli Arcani piccoli sono la decisione 3.
