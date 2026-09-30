# RAPPORTO DELL'ORDINE ES

L'Oroscopo completo, il Sigillo del Sogno e le voci aperte dell'ordine ET.
Ordine del 28 settembre 2026 in quattro pezzi, trentasette voci, piu' la
ES.38 chiesta dal fondatore il 30 settembre sera; lavoro dal 28 settembre.
Ramo `claude/esoteric-circle-master-order-e798aj`. Manifesto
`docs/ordini/ORDINE_ES_MANIFESTO.md`, prove in `docs/collaudo/ES/`, quelle
del telefono in `docs/collaudo/ES/realme/`. L'ordine non consegnava niente
finche' il fondatore non l'ha chiesto: **il 30 settembre ha ordinato la build
di consegna** (Android con App Distribution, il commit pronto per Codemagic),
*"Devi finire tutto, non fare consegne parziali"*.

**Il conto** (manifesto riletto dal file il 30 settembre 2026 sera): 38 voci,
**7 chiuse**, **31 aperte in attesa di verifica**, **0 da fare**. Nessuna
voce aperta e' chiusa per scorciatoia. **Il 30 su 30 delle trenta domande,
lo zero delle ripetizioni e il 20 su 20 del Viaggio non ci sono**, e lo dico
qui in cima perche' e' la cosa che conta di piu' fra quelle che mancano.

## LE VOCI CHIUSE, CON LA LORO PROVA

- **ES.01, Breve e Lunga su ogni scheda.**
  DOMANDA: *"Ogni scheda deve avere sempre il pulsante profondità e la scelta
  "approfondita" è esclusiva dei premium."*; *"Nel selettore profondità
  cambiamo "Approfondita" in Lunga"*.
  PROVA: `docs/collaudo/ES/regola_a_simbolo_e_profondita.txt`, e sul Realme
  `es_final_selettore_breve_lunga.jpg`, `es_final_anno_lavoro_breve.jpg`
  contro `es_final_anno_lavoro_lunga.jpg`.
  MISURA: voce "Approfondita" a video da 1 a 0; schede col pulsante, prima
  0 su 4 sull'Anno, sulla Settimana e sul Mese, sull'amico, dopo 4 su 4;
  schede dell'Anno in cui la Lunga dice di piu', 48 su 48.
- **ES.02, la Settimana nelle tre parti, coerente col Giorno.**
  DOMANDA: *"all'utente non gliene frega un cazzo dei transiti [...] Vuole
  sapere come andrà in generale, in amore, in lavoro, ecc."*; *"dovrà essere
  coerente con quello giornaliero, nel caso lo chiederà"*.
  PROVA: `docs/collaudo/ES/regola_a_settimana_e_giorno.txt`, e sul Realme
  `es_final_settimana_generale.jpg`, `es_final_settimana_lunga_giorni.jpg`.
  MISURA: righe che aprono col transito da 28 su 28 a 0 (192 campi su 192
  in parole); righe della Settimana e del Mese col livello diverso dal
  Giorno di quel giorno da 40 a 0 su 7.008, con la lettura diversa 0.
- **ES.03, il Mese nelle tre parti.**
  DOMANDA: la stessa della ES.02. PROVA: `docs/collaudo/ES/realme/es_final_mese_generale.jpg`.
  MISURA: campi del mese che aprono col transito da 4 su 4 a 0; righe senza
  un fatto del cielo 0 su 120; eclissi di febbraio 2027 trovate 2 su 2.
- **ES.16, il Sigillo del Sogno di Medora non parla di rune.**
  DOMANDA: *"il sigillo del sogno, adesso solo di Medora, parla di Rune!"*.
  PROVA: `docs/collaudo/ES/sigillo_senza_rune.txt`, e sul Realme il 30
  settembre alle 22:31 `es_final_sigillo_sogno_compiuto.jpg`,
  `es_final_sigillo_sogno_saluto.jpg`.
  MISURA: frasi con le parole di un altro Maestro da 1 a 0 su 85; sul
  Realme testi con "runa" o "rune" dal saluto alla buonanotte, 0.
- **ES.26, il retro delle schede a 402 punti.** `docs/collaudo/ES/retro_402.txt`.
  Schede col testo del retro rimpicciolito in home a 402 punti, 0 su 67; il
  testo in home e' quello dei domini (15,9, 15,2 e 13,0 punti nei tre
  formati). Quattro catture dal Realme a 402 punti. Lo schermo del Realme:
  prima densita' 480 e 360 punti, durante "Larghezza minima" 402 (densita'
  429), dopo di nuovo 480 e 360, riletto da adb.
- **ES.27, l'intro registrata sul Realme.** `docs/collaudo/ES/intro_realme.txt`.
  Durata dell'intro registrata 14,0 secondi contro i 14 del sorgente,
  correlazione 0,994; le scale delle animazioni del Realme prima 0,0,
  durante 1,0, dopo 0,0.
- **ES.38, il suono del responso dell'Oroscopo.**
  DOMANDA: *"Quando compare il responso del l'oroscopo si sente un suono che
  va eliminato. Sostituiscilo con: Orchestral Game Notification.wav [...] Va
  ottimizzato e convertito in mp3"*.
  PROVA: `docs/collaudo/ES/suono_del_responso_realme.txt`.
  MISURA: il suono alla comparsa del responso da 1,5 secondi (rivelazione) a
  2,72 (il tuo file); il file da 532.748 byte in WAV a 33.585 in MP3 mono;
  sonorita' -15,95 LUFS contro il bersaglio -16 degli altri effetti; sul
  Realme una traccia in piu' fra 2,4 e 2,8 secondi, in due consulti su due.

## LE TUE RICHIESTE DEL 30 SETTEMBRE SERA, UNA PER UNA

1. **"L'oroscopo per un amico" in alto**: sta nella barra dell'Oroscopo,
   accanto alla freccia, in ogni periodo; visto sul Realme
   (`es_final_testa_amico_in_alto.jpg`), il tocco apre gli amici
   (`es_final_amici_dalla_barra.jpg`).
2. **Il pulsante della profondita' su ogni scheda, la Lunga dei piani a
   pagamento**: Giorno, Anno, Settimana, Mese, Cinese, Vedica, amico. Al
   Viandante la voce ha il lucchetto e l'invito. Sul Realme non ho potuto
   vedere il Viandante: nella demo non si sceglie dal telefono (la sua scheda
   non ha pulsante e i controlli dimostrativi non sono collegati). Lo misura
   la prova, rossa quando la Lunga si apre al Viandante.
3. **"Approfondita" diventa "Lunga"**, nel selettore e nella pagina dei piani.
4. **Le letture nelle tre parti** delle Linee Guida, sezione 2: la risposta,
   che cosa fare, e solo dopo "Da dove viene" col simbolo. La Settimana e il
   Mese per campo (barre dei giorni, risposta, giorno migliore, che cosa fare,
   transiti in fondo); l'Anno, la Cinese e la Vedica coi titoli in parole e il
   simbolo nella riga "Da dove viene" sotto la lettura; **622 frasi dei tre
   corpora riscritte** con le due parti e rilette una per una, 92 titoli in
   parole. Guardia `il_simbolo_non_apre_mai`: 658 frasi, 111 titoli, 9.120
   schede Breve e Lunga, 192 risposte dei periodi, zero simboli in apertura.
5. **Vedica, Cinese e amici solo ai piani a pagamento**: era gia' cosi'
   dall'ordine ES, verificato nel codice (`PlanCatalog`).
6. **Maya, Egizia, Celtica e Araba restano con la clessidra "in arrivo"**:
   non le ho toccate.
7. **Il suono del responso**: il tuo file, vedi ES.38.
8. **La Settimana coerente col Giorno**: ogni riga dice la stessa lettura e lo
   stesso livello della scheda del Giorno di quel giorno. La prova ha trovato
   un difetto vero: il livello della riga si misurava a mezzogiorno di Roma e
   la scheda alle 12 UTC; senza carta natale, nei giorni in cui la Luna cambia
   segno fra quelle due ore, i pallini non coincidevano (40 righe su 7.008 in
   un anno). Adesso 0.

## LE VOCI APERTE, E CHE COSA MANCA A CIASCUNA

Tutte le voci aperte sono prodotte e agganciate, misurate in prova, e
aspettano la verifica a video sul Realme (e la ES.17 tre sere di
osservazione). Per ciascuna il manifesto porta la prova e la misura. Le tre
voci chiuse il 30 settembre (ES.01, ES.02, ES.03) restano qui sotto con le
misure di prima, perche' il loro cammino si legga intero.

- **ES.01** (chiusa, sopra) Breve e Approfondita: senza carta, Approfondite
  identiche alla Breve da 48 su 48 a 0 (`docs/collaudo/ES/profondita.txt`);
  dal 30 settembre "Lunga", su ogni scheda.
- **ES.02** (chiusa, sopra) il settimanale: 0 righe su 112 senza un fatto del cielo; fasi
  della Luna entro 0,47 minuti dal JPL (`docs/collaudo/ES/settimana.txt`).
  Manca la lettura una tantum con gli Eos (ES.06).
- **ES.03** (chiusa, sopra) il mensile: 0 righe su 120 senza un fatto del cielo, le due
  eclissi di febbraio 2027 trovate (`docs/collaudo/ES/mese.txt`).
- **ES.04** l'anno dal compleanno con la Rivoluzione Solare: il Sole dalle
  tavole di Chebyshev del JPL DE421 (col Sole di Meeus il ritorno sbagliava
  di 638 secondi, adesso di 10), 0 su 10 ritorni con un segno o una casa
  diversi dal JPL, 0 su 400 schede fuori dal loro caso, 252 frasi del corpus
  uguali al codice; 300 Eos per chi non ha l'Adepto; il PDF dell'Illuminato
  con l'emblema dell'Anno, 103 KB (`docs/collaudo/ES/regola_a_rivoluzione_solare.txt`).
  Dal 30 settembre nelle tre parti, coi titoli in parole e la profondita' su
  ogni scheda; visto sul Realme. Mancano l'invito con gli Eos (il Viandante
  non si sceglie dal telefono nella demo), il PDF e l'avviso.
- **ES.05** gli emblemi dei periodi: 9 su 9 uguali byte per byte; la
  copertina del PDF dell'anno c'e'.
- **ES.06** i piani del fondatore: la mappa da 33 a 36 righe, il settimanale
  non e' del Viandante, la profondita' e i posti degli amici letti dalla
  mappa (`docs/collaudo/ES/piani_es06.md`).
- **ES.07** il segno della tradizione in cima: 0 su 6 tradizioni lasciano
  l'occidentale; 14 figure su 14 uguali byte per byte.
- **ES.08** la Cinese aperta: 0 su 30 guardiani diversi dall'almanacco
  pubblicato (`docs/collaudo/ES/regola_a_lettura_cinese.txt`). Dal 30
  settembre le 224 frasi nelle due parti e 59 titoli in parole; vista sul
  Realme da piano pagato, col suono nuovo. Manca il Viandante.
- **ES.09** la Vedica aperta: 0 su 20 nascite diverse da Drik Panchang, 0
  su 42 estremi del Rahu Kalam (`docs/collaudo/ES/regola_a_lettura_vedica.txt`).
  Dal 30 settembre nelle due parti; quando la Luna e la stella si
  contraddicono (32 giorni su 120) apre con la risposta del livello e dice i
  due lati. Vista sul Realme proprio in un giorno cosi'. Manca il Viandante.
- **ES.10** le note delle sette tradizioni, 62 affermazioni con la fonte
  (`docs/collaudo/ES/tooltip.txt`).
- **ES.11** le quattro tradizioni in arrivo: clessidra, emblema, segno
  calcolato, 0 su 40 segni diversi dalla fonte. **Otto nomi dei decani**
  egizi vanno riscontrati sull'edizione Pingree di Efestione.
- **ES.12** gli amici offline e l'oroscopo per gli amici: 0, 3, 10, senza
  limite, 100 Eos per un posto in piu'; letture dell'amico mancanti 0 su 9
  (`docs/collaudo/ES/regola_a_es04_es12_es15.txt`). Dal 30 settembre il
  pulsante sta in alto e ogni scheda dell'amico ha la profondita' e il "da
  dove viene"; visti sul Realme. Mancano l'invito del Viandante e il tetto.
- **ES.13** la card con nome senza cognome e nascita.
- **ES.14** il numero al centro del suo riquadro.
- **ES.15** "Online" con la lucina verde e il numero, dal server
  (`chiEOnline`, da distribuire con la build di prova); i Prossimi Eventi
  Cosmici in cima al Passport, due: il tocco apre il Calendario.
- **ES.16** (chiusa, sopra) il Sigillo del Sogno di Medora senza rune.
- **ES.17** una sola notifica per Dono (da schierare con le funzioni).
- **ES.18** il Sigillo del Sogno da cima a fondo: le frasi false tolte, la
  chiusura senza arcani mai estratti (0 su 16 dopo), media dell'attribuzione
  alla cieca 94,4 (`docs/collaudo/ES/regola_a_sigillo.txt`).
- **ES.19** le reti della prima frase e delle certezze. Tre giri del banco,
  ognuno letto alla cieca accanto al giro di prima dagli stessi giudici.
  **Le risposte con una certezza si dimezzano**: da 31 a 14 su 360 (la rete
  allineata alle frasi che i giudici citano: prendeva 12 certezze su 61,
  adesso 51). **Le prime frasi dirette scendono da 266 a 251 e il merito da
  263 a 246, ed e' tutto Aura** (prime frasi da 77 a 61); Medora e Calìgo
  tengono (98 e 101, 91 e 89). Il calo di Aura non viene dalle certezze: le
  sue risposte richieste per una certezza sono 18 e 18, quelle nate gia'
  senza posizione salgono da 19 a 34. Il 30 su 30 non c'e': il migliore e'
  Medora in chat, 26 e 27 (`docs/collaudo/ET/ciechi/conti_et01_es3mix.txt`).
  **Dal quarto al nono giro**: la correzione che ripete la domanda porta le
  prime frasi da 253 a 311 su 360; il "quando" senza la stagione da
  ricopiare (nel LIVE sul Realme due domande avevano avuto *"non prima
  dell'autunno"*) nomina un tempo 72 volte su 72 in tre giri, ma i passaggi
  del cielo inventati o sbagliati restano 2, 1 e 3 su 24. Alla lettura alla
  cieca del codice che parte (`es8mix`): prime frasi 310 e 311, merito 315 e
  326, certezze 16 e 11.
- **ES.20** sotto la risposta detta nel LIVE niente invito a tornare, anche
  riaprendo la conversazione.
- **ES.21** la rete che non ridice la risposta di prima: sulle 240 seconde
  giudicate prende 13 ripetizioni su 26 con 2 sbagli su 214; al banco le
  seconde che ripetono restano fra 3 e 8 su 60 secondo il giro, dentro il
  rumore dei giudici. Lo zero non c'e'.
- **ES.22** la trascrizione del LIVE, al banco: domande trascritte giuste
  parola per parola da 30 a 38 su 40 (voce pulita) e da 28 a 38 su 40 (voce
  da stanza); la televisione trascritta come parole della persona 0 su 18
  prima e dopo (`docs/collaudo/ES/trascrizione/`). Manca il Realme col
  microfono.
- **ES.23** il merito del LIVE alle domande a piu' parti: 26 e 24 su 36 per
  i primi giudici (l'ordine chiede 23), ma le stesse risposte rilette da
  altri giudici fanno 20 e 23. Sotto questo rumore il 23 non e' dimostrato,
  e la voce resta aperta.
- **ES.24** le rune senza le guardie sulla prima frase: chiamate al modello
  da 56 a 41 e 47 per 24 letture, tempo mediano della chiamata da 9,3 e 8,7
  a 4,9 e 7,3 secondi, prime frasi dirette da 13 e 15 a 15 e 15 su 20.
- **ES.25** il Viaggio: per gli stessi giudici, prime frasi che prendono
  posizione da 20 a 26 su 40 dopo il secondo giro (istruzione corretta e
  guardia allargata). Il 20 su 20 e' lontano.
- **ES.28** il livello dal cielo: 0 su 48 livelli che non ne dipendono.
- **ES.29** numero e colore con una regola: da 30 su 30 senza regola a 0.
- **ES.30** il metodo sulle quattro schede del giorno.
- **ES.31** l'invito ai dati di nascita sotto "Interroga il cielo".
- **ES.32** l'ora d'oro: scarto medio dal JPL 0,18 minuti; le due notifiche
  ci sono, 0 avvisi sbagliati su 77 giorni, il Rahu Kalam solo a chi legge
  la Vedica.
- **ES.33** la ruota del passaggio: 0 su 80 ruote diverse dalla frase.
- **ES.34** la ragione per tornare domani: 0 su 30 diverse dal giorno dopo.
- **ES.35** la rivelazione del segno cinese e vedico, una volta sola.
- **ES.36** i tre cieli di oggi: in sessanta giorni 55 domini d'accordo e 185
  no, 0 su 240 fuori dalla regola.
- **ES.37** il Sigillo dei Tre Cieli, acceso alla terza tradizione letta nel
  giorno.

## LE VOCI DA FARE

Nessuna: le trentotto voci sono chiuse o aperte in attesa di verifica.

## I DIFETTI TROVATI, OGNUNO COL SUO PADRE

- Il numero fortunato attaccato a sinistra: padre DD.09, commit `b6188d20`.
- La riga della Runa del Tramonto nel Sigillo di Medora: padre P.18, portata
  dalla DD.04.
- Tre notifiche per un Dono: padre CG.16 (il tag `dono_1104` non sostituiva la
  locale 1104) e il giro del server non allineato all'orologio.
- Le chiavi `avviso_dono_` che non si cancellavano e poi non si scaricavano:
  padre ES.17 (`c9bdfc06` con la riparazione `dd53d8f1`), mio.
- "Interroga il cielo" spinto sotto la piega dall'invito della ES.31, il
  pulsante in maiuscoletto su due righe, foglio e dialogo fuori dalla porta
  del velo, InkWell senza l'interruttore del silenzio, un `fontSize` scritto a
  mano, il Sole di nascita preso dal motore dei transiti, un TextPainter
  senza la scala, due ", e", una freccia non dichiarata: padre il blocco 1 e 2
  di quest'ordine (`a9e52f66`, `b6106fb7`), miei, presi dalla suite intera
  prima di spingere.
- La Luna di `Effemeridi` sbaglia fino a 0,27 gradi: non e' un difetto nuovo
  (e' dichiarato nel file), ma per i segni vedici e arabi non basta; per loro
  c'e' la Luna di Meeus intera, `lib/core/astro/la_luna_intera.dart`.
- La variante della lettura cinese scelta col giorno giuliano ripeteva la
  stessa frase al ritorno dello stesso caso 700 volte su 1.200: padre ES.08,
  mio, preso dalla Regola A prima della consegna.
- Il Sole di Meeus per la Rivoluzione Solare, 638 secondi di scarto
  sull'istante del ritorno: padre ES.04, mio, preso dalla prova contro il
  JPL prima del commit; curato con le tavole di Chebyshev.
- Medora che nominava arcani mai estratti nella chiusura del Sigillo del
  Sogno: padre la regola di chiusura della persona dei Maestri, curata con la
  ES.18 (0 su 16 dopo).
- **Sedici difetti miei presi dalla suite intera** sulle voci ES.04, ES.12 ed
  ES.15 (commit `50747b54` e `78d1388c`), tutti corretti prima della spinta
  nel commit `9cba8b61`: il contatore di chi e' online non dichiarato fra i
  provider impersonali, la scheda dell'amico senza la porta dei paragrafi, la
  callable nuova non dichiarata, il PDF che apriva il foglio di sistema da
  se' e portava un import inutile, una virgola prima della "e" nella privacy
  policy, la bolla dei traguardi scesa sotto la piega nella prova, la
  dipendenza `pdf` non classificata per iOS, il foglio degli amici senza
  fondo, le rotte degli amici costruite a mano, le due schermate degli amici
  non classificate per la barra, `assets/pdf/` fuori dal manifesto degli
  asset, le misure del PDF scritte a mano (cinque rossi).
- **Nel blocco delle voci ES.19-ES.37**, presi dalle prove prima del commit:
  la rete della prima frase cercava "leggo" dopo il verbo della lettura, cioe'
  dopo se stesso (mio, ES.19); la massima "non X, ma Y" fermava anche un "sì,
  se" gia' detto (padre ET.01, la regola della massima); la radice di cinque
  lettere che avrebbe rotto `substring(0, 6)` (mio, ES.21, preso rileggendo).
- **Una guardia che non copriva la sua zona**: `la_posizione_e_una_lettura`
  restava verde col "quando" sempre accettato. Padre: la guardia dell'ordine
  ET voce 01, che non aveva un caso del quando. Riparata, adesso e' rossa.
- **Le certezze salite da 23 a 33 al primo giro del banco**: padre ES.19,
  mio (l'esenzione del futuro sotto "le carte dicono che", presa per buona
  dai giudizi dati a mano del giro 6). Curato allineando la rete ai giudici
  alla cieca.
- **Le prime frasi dirette scese da 278 a 245 al secondo giro**: padre ES.19,
  mio (la correzione delle certezze chiedeva "può" e la risposta nuova
  passava anche senza il si'). Curato al terzo giro; resta il calo di Aura.
- **Il calo delle prime frasi di Aura** (da 77 a 61 su 120, due giri su due
  con giudici diversi): **PROVENIENZA IGNOTA**. Le richieste per una
  certezza sono le stesse del primo giro; salgono le risposte che il modello
  da' gia' senza posizione. Aperto.
- **L'esempio "Il viaggio non mostra..." nell'istruzione del Viaggio**, che il
  modello ricopiava e i giudici bocciano: padre ET.08 (l'esempio era nella
  regola della prima frase). Curato alla ES.25.
- **Una prova nata verde due volte**: `le_certezze_dei_giudici` con la quota
  dei due terzi, e la prova della posizione che resta con una domanda di si'
  o no che la rete scartava gia'. Padre: io, nello scrivere la prova. Cambiata
  la grandezza, non la soglia; tutte e due rosse adesso
  (`docs/collaudo/ES/regola_a_certezze_dei_giudici.txt`,
  `regola_a_posizione_resta.txt`).
- **Tre difetti miei presi dalla suite intera** sul commit `d3c85ca6`, prima
  della spinta: un `\$` in una regola delle certezze che la guardia del testo
  a video legge come codice mostrato; la forma "scegli tu" della guardia del
  Viaggio che scartava anche *"il primo passo lo scegli tu"*, e con lei due
  discese della prova al femminile e una frase della prova della 2260 (adesso
  vale solo come imperativo in testa alla frase, e la frase della prova e'
  riscritta con la lapide). Padre ES.19 ed ES.25, miei.
- **Un `dart format` su una cartella** ha riformattato due file non miei
  (`il_rimando_in_fondo.dart`, `la_marca_del_genere.dart`): padre io, rimessi
  com'erano prima del commit.
- **Dal 29 e 30 settembre, prima della build di prova 2289**: il
  sottotitolo dell'Oroscopo che a 360 punti lasciava "giorno" o "settimana"
  da soli sulla seconda riga (padre ordine 2171 voce 5, il sottotitolo del
  periodo); la frase del segno attaccata al sottotitolo e "In arrivo" che
  toccava la riga delle tradizioni (padre ES.07 ed ES.11, miei); le tre
  tradizioni dell'amico su due righe (padre ES.12, mio); **la scritta dei
  pulsanti pieni in viola scuro sul viola, contrasto 1,63**, perche' il tema
  non dichiarava il colore di cio' che sta sul primario e dodici pulsanti lo
  prendevano da li' (PROVENIENZA IGNOTA: il tema e' cosi' da prima di questi
  ordini, e nessuna prova guardava il contrasto di un pulsante senza stile);
  una virgola prima della "e" nell'istruzione del quando (padre ES.19, commit
  `0e44b652`, mio). Tutti curati, adesso 7,18 di contrasto.
- **Visto sul Realme dalla build di prova 2289**: *"Condividi la settimana ·
  +15 Eo"*, l'etichetta tagliata. Padre ES.05, mio: in prova il premio non
  c'e' e l'etichetta ci stava. Adesso si rimpicciolisce intera, e la prova
  monta una porta del premio finta.
- **La Settimana che portava per ogni giorno solo i suoi transiti**, che hai
  trovato nell'anteprima. Padre ES.02 ed ES.03, miei: l'ordine descriveva
  *"una riga per giorno col livello e la sua ragione"*, l'ho eseguito alla
  lettera e non l'ho messo accanto alle Linee Guida, sezione 2 (la risposta,
  che cosa fare, da dove viene) ne' alla regola ferma dell'ordine AS in
  STATO_VIVO (*"transiti, pianeti e meccaniche non sono il contenuto"*). E'
  la mancanza piu' grave di quest'ordine, e l'ho scritta in memoria perche'
  non torni.
- **Una guardia che non copriva piu' la sua zona**: `la_settimana_viene_dal_cielo`
  restava verde con le sette righe lette tutte dal cielo del primo giorno.
  Padre ES.02, la guardia mia; presa dalla Regola B prima di toccare la zona,
  riparata, poi rossa (80 righe su 112).
- **Il livello delle righe della Settimana misurato a un'altra ora del
  Giorno** (mezzogiorno di Roma contro le 12 UTC): 40 righe su 7.008 in un
  anno col livello diverso dal Giorno. Padre ES.02, mio; preso dalla prova
  nata dalla tua domanda sulla coerenza.
- **Nella Vedica, la Luna e la stella che si contraddicono** (*"comincia
  qualcosa"* e subito dopo *"meglio non aprire cose nuove"*, a 2 su 5):
  32 giorni su 120. Il difetto c'era gia' (padre ES.09, la composizione della
  Generale), ma col simbolo davanti a ogni frase si capiva che erano due
  voci; l'hanno scoperto le tre parti. Mio, preso guardando l'anteprima.
- **Le barre dei giorni che sembravano tutte uguali** (sei punti fra un
  livello e l'altro) e la frase *"i giorni più aperti sono gli ultimi"*
  sopra un giorno migliore a meta' settimana: padre la Settimana nelle tre
  parti, mia, di stasera; prese guardando le anteprime.
- **La media dei periodi detta alla voce col punto** (*"3.5 su 5"*) e **"a
  quattr'occhi"** nel corpus annuale riscritto, che la guardia legge come un
  accento mancato: miei, di stasera, presi dalla suite intera.
- **La prova del pulsante "Consulta" in home cercava "Caligo" senza
  accento**: di sera davanti c'e' Calìgo e il pulsante dice il nome a video,
  quindi la prova cadeva a quell'ora anche sul commit gia' spinto. Padre
  ES.17 (`c9bdfc06`, il nome a video di Calìgo), mio: non avevo aggiornato
  la prova. Curata.
- **Il foglio "Da dove nasce questo dono" del Sigillo del Sogno** scriveva
  *"(Senti con curiosità e parole: le emozioni si fanno racconto.)."*, il
  punto dentro e fuori la parentesi. Visto sul Realme il 30 settembre alle
  22:34. Padre il commit `c49de157` del 24 luglio (il Rito del Sogno
  rifatto). Curato, con la prova su trenta notti e dodici segni; la cattura
  dopo la cura manca.
- **Il cancello di GitHub rosso sul commit `368fb5ef`**: nel registro dei
  rossi accettati restavano tre righe del corredo a scala 1,3 (le due
  catture dell'Oroscopo e la corsa dello zodiaco) che dopo il lavoro
  dell'ordine ES passano, e il cancello non produce l'archivio finche' una
  riga sopravvive alla sua ragione. Padre io: la suite locale gira alla
  scala uno, e il corredo a scala 1,3 lo guarda solo GitHub. Tolte le tre
  righe, e il manifesto dell'ordine CM dice adesso dieci schermate invece di
  tredici.
- **Due giri delle anteprime caduti su 39 e 26 catture con l'errno 1224**
  di Windows (un altro processo tiene il PNG appena scritto): non e' un
  difetto del codice; adesso la scrittura delle anteprime aspetta il lock.

## LE SCELTE FATTE CON LA RISPOSTA CONSIGLIATA

Il fondatore ha detto: *"Se hai domande, usa la risposta consigliata Senza
disturbarmi."* Queste sono le scelte, ognuna col suo perche'; ognuna si
cambia in un punto.

1. **I colori vedici del venerdi' e del sabato**: resta il testo classico
   (Brihat Jataka, "variegato" e "nero"): la riga lo dice.
2. **La vigilia del Capodanno cinese**: la data civile del luogo di nascita.
3. **Il Sentiero del "sogno"** resta a Calìgo come nel corpus.
4. **Le 99 promesse "cosa apre" dei Traguardi** che non esistono nell'app non
   arrivano piu' al Maestro; il corpus e' tuo e non l'ho toccato
   (`docs/collaudo/ES/cosa_apre.txt`: 35 esistono, 99 no, 31 dubbie).
5. **Gli amici e gli anni comprati stanno sul telefono**, come i luoghi e le
   preferenze.
6. **Il luogo della Rivoluzione Solare** e' la citta' di oggi, altrimenti
   quello di nascita.
7. **Il posto in piu' fra gli amici resta per sempre**: e' l'unica cosa che
   gli Eos comprano per sempre, come hai approvato.
8. **"È possibile" nella prima frase del Maestro** passa solo con la sua
   condizione ("è possibile, a patto che..."), che e' il "sì, se" che hai
   approvato; da solo resta una prudenza e si chiede di nuovo.
9. **Le notifiche dell'ora d'oro e del Rahu Kalam** sono accese di partenza,
   come hai deciso per tutte le notifiche; il Rahu Kalam arriva solo a chi ha
   aperto la lettura vedica almeno una volta.
10. **Il Sigillo dei Tre Cieli e' un Sigillo a parte**, non un gradino dei
    165: il corpus dei Traguardi e' tuo. Non conia Eos. Se lo vuoi fra i
    gradini, si aggiunge al corpus.
11. **I tre cieli e il loro Sigillo non si mostrano al Viandante**: direbbero
    cio' che vedono la Cinese e la Vedica, che sono letture dei piani.
12. **La presenza per il numero di chi e' online** sta sul server nel ramo
    della persona (l'istante dell'ultima domanda, nient'altro); la privacy
    policy lo dice in app e sul sito, con la data del 29 settembre 2026.
13. **La rete delle certezze allineata ai giudici resta**, anche se le prime
    frasi di Aura sono scese: le certezze si dimezzano in due giri, Medora e
    Calìgo non perdono niente, e il calo di Aura non passa dalla rete. Se
    preferisci la rete di prima finche' Aura non e' curata, si torna indietro
    in un punto (`lib/core/chat/le_certezze_del_maestro.dart`).
14. **Nella guardia del Viaggio restano fuori le forme su cui i giudici si
    contraddicono** (*"non mostra"*, *"se sei pronta"*, *"consapevole"*):
    contro quelle lavora l'istruzione, non la guardia.
15. **La ES.23 non si chiude** anche se i primi giudici davano 26 e 24 su 36:
    altri giudici sulle stesse risposte danno 20 e 23.
16. **La scelta della profondita' vale per il campo, in ogni periodo**: chi
    sceglie la Lunga per l'Amore la ritrova nell'Amore dell'Anno e della
    Settimana. Una scelta per ogni scheda di ogni periodo sarebbero
    ventiquattro interruttori da ricordare.
17. **La regola 16 delle Linee Guida** dice che chi non ha il Premium sblocca
    la Lunga una risposta alla volta pagando in Eos. Nel listino degli Eos non
    c'e' un prezzo per la Lunga dell'Oroscopo, e stasera mi hai detto che la
    Lunga e' dei Premium: oggi al Viandante la voce ha il lucchetto e
    l'invito al piano. Il prezzo lo decidi tu (sotto, fra le cose che
    aspettano te).
18. **Il Viandante che compra l'Anno con 300 Eos legge la Breve**: la Lunga
    resta dei piani.
19. **Il Giorno lascia il passaggio del cielo nel testo**, dopo la risposta
    in parole (com'e' dall'ordine ER voce 14), e sotto la riga "Da dove
    viene". Spostarlo tutto nella riga cambierebbe che cosa aggiunge la Lunga
    del Giorno, che oggi sono passaggi del cielo: te lo chiedo sotto.
20. **La Cinese non apre con una frase di sintesi**: il rapporto fra gli
    animali e il guardiano parlano di due cose diverse (come va con gli
    altri, a che cosa e' adatto il giorno), e nei giorni a 2 su 5 che ho
    letto non si contraddicono come nella Vedica.
21. **Il suono nuovo vale solo per il responso dell'Oroscopo**: la
    rivelazione resta alla stesa dei tarocchi e al Sigillo dei Tre Cieli,
    perche' hai chiesto di cambiare il suono di quel momento. Il file e' in
    mono come gli altri effetti (e' un segnale, non musica) e al volume
    della famiglia.
22. **I testi riscritti dei tre corpora** (622 frasi) sono miei, fatti con
    nove scrittori in parallelo e riletti tutti prima di entrare: nelle
    serie dell'Amore cinese la persona amata e' al neutro (*"chi ami"*); le
    frasi sulla salute e sul denaro sono piu' prudenti di prima; nella
    direzione della Fortuna cinese i gesti (*"siediti con lo sguardo a
    est"*) sono simbolici e lo dicono.

## LE COSE CHE ASPETTANO TE

1. **La nascita italiana la sera della vigilia del Capodanno cinese**, quando
   a Pechino e' gia' il giorno dopo: l'app usa la data civile del luogo di
   nascita. Se preferisci la data di Pechino, si cambia in un punto.
2. **La tavolozza dei colori per segno del corpus** (`docs/corpus/oroscopo.md`)
   non la chiama piu' nessuno dalla ES.29: il corpus e' tuo; senza il tuo si'
   non la tolgo.
3. **La Settimana e il Mese si aprono gia' col piano**; le letture una tantum
   con gli Eos arrivano con la ES.06.
4. **La build** e' questa, di consegna. Il numero di chi e' online arriva gia'
   dal server (sul Realme *"Online adesso: una persona"*).
5. **Il 30 su 30 delle trenta domande e il 20 su 20 del Viaggio** non ci sono
   dopo tre giri: le reti di parole inseguono le forme e i giudici alla cieca
   si contraddicono fra loro di sei risposte su trentasei. Il prossimo passo
   serio e' sulla persona di Aura e sulla prima frase del Viaggio, e va
   misurato con piu' letture degli stessi testi.
6. **Il prezzo in Eos della Lunga per chi non ha il Premium**, se la vuoi
   come dice la regola 16 delle Linee Guida (una risposta alla volta). Oggi
   non c'e', e la voce invita al piano.
7. **Il passaggio del cielo nel Giorno**: oggi sta nel testo dopo la
   risposta in parole. Se lo vuoi solo nella riga "Da dove viene", la Lunga
   del Giorno va ripensata (oggi aggiunge proprio passaggi del cielo).
8. **I 622 testi riscritti** della Cinese, della Vedica e dell'Anno: sono una
   bozza mia, come i corpora di prima; stanno in `docs/corpus/` e si
   cambiano li'.
9. **Il Viandante sul Realme**: nella demo non si sceglie dal telefono,
   quindi i lucchetti della Lunga, della Cinese, della Vedica e degli amici
   per il Viandante li hanno visti solo le prove. Se vuoi vederli tu, serve
   un account di prova senza piano.
10. **Il contenuto che scorre sotto la barra in alto trasparente** (si vede
    nelle catture dell'Oroscopo): e' cosi' in venticinque schermate, per
    scelta di disegno di un ordine vecchio; non l'ho toccato.
11. **I passaggi del cielo inventati nella risposta al "quando"** (2, 1 e 3
    su 24 negli ultimi tre giri): serve una rete che confronti la frase coi
    dati del cielo dati al Maestro, e in quest'ordine non c'e'.
