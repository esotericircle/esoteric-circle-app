# ORDINE GD, PARTE D: LA SINASTRIA EVOLUTIVA (voci GD.13-GD.22)

23 ottobre 2026. Ramo locale `gd-d`, partenza `02522987`. Il giudizio del fondatore sulla funzione com'era: *"SEMPLICEMENTE FA CAGARE"*. Nessuna chiamata al modello (la Sinastria evolutiva non ne fa: e' tutta dal corpus), nessuna build, nessun `firebase deploy`, niente telefono, niente dati di produzione. Le innestature della Regola A e della Regola B, una per prova, stanno in `docs/collaudo/GD/regola_a_d.txt` (20 rossi visti, tutti tolti, grep a zero).

## LE VOCI E LA LORO PROVA

| voce | stato proposto | prova |
|---|---|---|
| GD.13 | CHIUSA | `test/gd_la_sinastria_evolutiva_test.dart` (gruppo GD.13, tre schermi) |
| GD.14 | CHIUSA | `test/gd_la_sinastria_evolutiva_test.dart` (gruppo GD.14, quattro prove) |
| GD.15 | CHIUSA | `test/gd_la_sinastria_evolutiva_test.dart` (GD.15, il censimento) |
| GD.16 | CHIUSA | `test/gd_la_sinastria_evolutiva_test.dart` (GD.16, due prove) |
| GD.17 | CHIUSA | `test/gd_la_sinastria_evolutiva_test.dart` (GD.17, tre prove) |
| GD.18 | CHIUSA | `test/gd_la_sinastria_evolutiva_test.dart` (GD.18) |
| GD.19 | CHIUSA | `test/gd_la_sinastria_evolutiva_test.dart` (GD.19) |
| GD.20 | CHIUSA | `test/gd20_gli_amici_offline_hanno_una_porta_sola_test.dart` |
| GD.21 | APERTA IN ATTESA DI VERIFICA | `test/gd21_la_sinastria_arriva_all_amico_test.dart`, `functions/src/sinastria_evolutiva.test.ts` |
| GD.22 | CHIUSA | `test/gd_la_sinastria_evolutiva_test.dart` (GD.16 e GD.22, GD.22) |

Tutte le voci restano comunque da guardare sul Realme per la simulazione da persona e del bambino (FZ.09, GA.09): l'elenco delle schermate e' in fondo. La GD.21 resta aperta perche' la porta del server `mandaLaSinastria` e la lettura delle `sinastrie` in `ilMioCerchio` sono scritte e provate ma non pubblicate (R3): finche' il fondatore non le pubblica, sul telefono la riga della consegna dice che la porta non e' aperta.

## VOCE PER VOCE

### GD.13, il video a tutto schermo, i testi sopra, la domanda sopra la testa di Medora

DOMANDA: "Video introduzione bello, ma è tagliato per fare spazio a testo e pulsante, ma perché è tagliato? Il video copre tutta l'area del telefono e sopra testi e pulsante [...] Prima di tutto, via tutto il testo e lascia solo il pulsante sotto. Sopra la testa di Medora inserisci il testo «Con chi vuoi scoprire la tua compatibilità?»"
PROVA: test/gd_la_sinastria_evolutiva_test.dart
MISURA: area dello schermo coperta dal video, prima 390 per 693,3 su 390 per 844 punti (l'82,1 per cento: la scena era alta quanto il taglio 688x1223 a tutta larghezza, `GeometriaDelloStudio.altezza` e sotto stava il velo col testo), dopo 329.160 su 329.160 punti quadrati a 390x844 (rapporto 1,0000), 273.600 su 273.600 a 360x760, 400.760 su 400.760 a 430x932. Testo sotto il titolo: prima 2 righe ("Con chi leggo il tuo cielo?" e "Scrivi la sua nascita o leggila dal suo telefono: leggo i vostri due cieli."), dopo 0. Pulsanti sulla scena: 1. La domanda finisce a 270,1 punti, la testa di Medora comincia a 278,1 (390x844); sotto la barra del titolo (comincia a 218,1, la barra finisce a 56).

Fatto: `GeometriaDelloStudio.aTuttoSchermo` (lo stesso taglio del video coperto come un `BoxFit.cover`: la scala piu' grande, l'avanzo tolto in parti uguali dai lati), `LoStudioDiMedora(altezza:)`; sfondo, video, Medora e statua con la stessa scala e la stessa origine. La scena resta dal bordo alto sotto la barra semitrasparente (GC.02, la guardia `la_sinastria_evolutiva_si_apre_sulla_scena` resta verde). Il testo e il pulsante aspettano la scena ferma (FXA.08) e stanno sopra il video.
PADRE: il video tagliato, ordine FT voce FT.02 (la scena alta quanto il taglio a tutta larghezza, commit c63de67d) e ordine FY voce FY.11 (il velo col titolo e la riga sotto la scena, commit 0046fa96); le due righe, ordine FY voce FY.11.

### GD.14, la tendina che sale, con la scelta guidata fra online e offline

DOMANDA: "Quando l'utente fa click sul pulsante in basso, si apre verso l'alto una tendina in semitrasparenza con la scelta guidata, uno alla volta, tra on-line e offline. Se sceglie online comparirà l'elenco degli amici del cerchio e se non ne ha verrà informato che non ha amci nel cerchio e se vorrà invitalri. In quest'ultimo caso passerà alle schermate di invito nel cerchio della funzionalità Social, ma potrà tornare indietro, Senza uscire, con la freccetta indietro. Se sceglierà offline, comparirà l'elenco degli amici che ha già creato offline (la stessa lista dell'oroscopo, per intenderci) oppure potrà inserirne uno nuovo"
PROVA: test/gd_la_sinastria_evolutiva_test.dart
MISURA: prima il tocco apriva una seconda schermata piena ("La sua nascita", cattura GD_12), 0 passi guidati; dopo una tendina dal fondo (da 473 a 844 punti) con il velo a 0,82 di opacita', 4 stati provati: primo passo (online e offline, nessun elenco), online pieno (Stella Lieve, tocco, modulo col suo nome), online vuoto ("Non hai ancora amici nel Cerchio." e l'invito: l'invito apre `InvitaNelCerchioScreen`, la freccia indietro torna alla tendina e la Sinastria c'e' ancora), offline (l'amica salvata dall'Oroscopo nella lista, compilata nel modulo e "Una persona nuova").

Fatto: `lib/features/synastry/la_tendina_della_sinastria.dart`. L'elenco online e' quello del Cerchio (`IlCerchioSociale.cerchio.amici`, tutti gli amici e non solo i presenti: il fondatore dice "amici del cerchio"); se l'elenco non c'e' ancora la tendina chiama una volta `caricaIlCerchio` (Firestore, non il modello). Sotto i quattordici anni la tendina dice la riga del Cerchio chiuso, senza invito. La lettura a due telefoni (FT.03, che per la Sinastria resta, FY.14) sta nel modulo: "Hai un codice dal suo telefono?".
PADRE: ordine FT voce FT.14 (il ponte che apriva la nascita a mano) e ordine FY voce FY.11 (la scelta portata sotto la scena, ma ancora verso la schermata della nascita).

### GD.15, il modulo dei dati, elegante

DOMANDA: "La schermata di inserimento dati non va bene, è scarna e confusionaria e Senza un minimo di cura grafica [...] Dopo la selezione comparirà il modulo inserimento dati graficamente elegante per inserire nome, data e orario di nascita"
PROVA: test/gd_la_sinastria_evolutiva_test.dart
MISURA: censimento dei testi contro i ruoli tipografici del responso dei Tarocchi (titoloSezione, titoloScheda, titoloDiRiga, etichetta, lettura, corpo, didascalia): prima, "La sua nascita", 9 testi fuori misura su 14 (Roboto 14 e 16, gli stili di sistema di `TextField`, `ListTile`, `TextButton`, `FilledButton`); dopo, il modulo della tendina, 0 fuori misura su 22. I tre campi (nome, data, ora) nei riquadri della casa (`RiquadroInEvidenza`): prima 0, dopo 3.
PADRE: ordine FT voce FT.03 (commit ce7906e5, il modulo coi componenti di sistema).

### GD.16, la tipologia del legame, una sola alla volta

DOMANDA: "Poi potrà scelgiere che tipo di sinastria vuole scoprire e potrà scegliere tra «Amore. amicizia, famiglia, lavoro» selezionando le icone appositamente create. L'utente potrà scoprire la sinastria solo di una tipologia alla volta, quindi o Amore o Amicizia o Famiglia o Lavoro. Se vorrà la sinastria di un'altra tipologia, dovrà rifare una sinastria nuova"
PROVA: test/gd_la_sinastria_evolutiva_test.dart
MISURA: icone del modulo: le 4 dipinte (`legame_amore/amicizia/famiglia/lavoro_v1.webp`), legami scelti dopo tre tocchi su tre icone: 1. Coppie nuove rimaste al piano Illuminato (15 al giorno): all'inizio 15, dopo la prima sinastria (amicizia) 14, dopo la rilettura della stessa coppia con lo stesso legame 14, dopo la stessa persona col legame lavoro 13. Prima: il legame si cambiava nella lettura con un tocco, gratis (0 consumi per un'altra tipologia). L'Amore sotto i sedici anni (amica nata nel 2012): la riga "Il legame amore si apre dai sedici anni." e il pulsante resta spento.

Fatto: la scelta nel modulo; la lettura non ha piu' le quattro icone; in fondo "Un'altra sinastria" riporta alla scena e la nuova scelta si conta come una coppia nuova (`AvvioSinastriaEvolutiva`, `LeCoppieScoperte`: l'impronta e' coppia piu' legame). **La regola dei sedici anni non e' rotta**: l'app la controlla nel modulo e nella lettura (`SbarramentoDEta`, una scelta d'amore chiusa si legge come amicizia, come prima), il server la rifa' nella lettura a due telefoni (`amoreDalServer`, FT.04, invariato); le prove di `la_sinastria_evolutiva_a_video_test.dart` misurano ancora i tre casi (quindici anni, no del server, sedici compiuti), riscritte sulla forma nuova.
PADRE: ordine FT voce FT.06 (le quattro icone nella lettura, il legame che cambia la lettura senza un conto) e voce FT.13 (il conto solo della coppia, non del legame).

### GD.17, Breve e Lunga nella Sinastria

DOMANDA: "Inoltre ci sarà il selettore di profondità breve o lunga. Lunga sarà esclusiva degli utenti premium a pagamento che aggiungerà solo alla prima risposta del responso 2 paragrafi di cui il secondo in riquadro con titolo"
PROVA: test/gd_la_sinastria_evolutiva_test.dart
MISURA: paragrafi della prima risposta: Breve 3, Lunga 5; il secondo in piu' nel riquadro col titolo "Il filo che vi lega" (trovato una volta, dentro il riquadro); negli altri quattro capitoli 0 paragrafi della Lunga. Al Viandante la Lunga col lucchetto (`TendinaSelettore`, la stessa della Stesa) e il tocco apre l'invito ai piani; chiesta senza piano, si legge Breve. Lunghe composte dal corpus su 40 coppie per 4 legami: 160 su 160, nessuna ripete un paragrafo del capitolo ne' il testo del cielo comune.

**IL RIPIEGO, la richiesta dell'ordine.** PREMESSA DA PRECISARE: nella Sinastria evolutiva non c'e' una strada del modello, ne' quindi un ripiego che possa perdere la Lunga: la lettura e' tutta dal corpus (`la_lettura_evolutiva.dart`, "Tutto deterministico, nessun modello") e la Lunga pure (`la_lunga_della_sinastria.dart`). La prova lo misura invece di supporlo: le quaranta coppie passano dalla stessa funzione che usa la schermata, senza rete e senza provider e una guardia nella stessa prova cade se un sorgente della Sinastria (10 file) nomina un modello (`AiProvider`, `firebase_ai`, `GenerativeModel`, `generateContent`): se un giorno nascesse una strada del modello, la prova del ripiego andrebbe scritta li'.

Fatto: `RigaDelPiano.sinastriaLunga` in `plan_catalog.dart` ("Sinastria evolutiva: risposta lunga", No/Si'/Si'/Si', dall'Iniziato come le altre Lunghe); i due paragrafi: il secondo contatto che tocca il primo capitolo (o un'altra apertura dello stesso tono, se il contatto e' uno solo) e, nel riquadro, il filo del Tema Composito (la variante che il capitolo del cielo comune non usa).
PADRE: funzione nuova, nessun difetto.

### GD.18, il pulsante, la riflessione e la statua sul tavolo

DOMANDA: "Quando avrà inserito i dati si attiverà il pulsante «scopri la compatibilità» Al click sul pulsante, si avvia l'animazione di riflessione come per oroscopo o tarocchi e alla fine comparirà sul tavolo di Medora la statua grande scontornata simbolo della risultato della sinastria"
PROVA: test/gd_la_sinastria_evolutiva_test.dart
MISURA: il pulsante spento col solo nome, senza l'ora, senza il legame, acceso con tutto; al tocco la riflessione (`AttesaDiMedora`, la stessa scena della Stesa e dell'Oracolo, con le righe dei due cieli) per il suo minimo garantito; la statua alta prima 0 (sul tavolo non c'era niente: la coppia era un riquadro di 96x128 accanto al titolo e i medaglioni rotondi di lato 52), dopo 345,1 punti su 844 (il 40,9 per cento dello schermo), con la base sul piano del tavolo (721 punti, sotto Medora che finisce a 621). Pixel trasparenti del file della statua: prima 0 (`coppia_pesci_v1.webp`, RGB senza alfa), dopo il 39,5 per cento (`statua_pesci_v1.webp`).

Fatto: le statue ci sono, come ha detto il fondatore ("ci sono già"): sono le dodici coppie dipinte del segno della relazione (`coppia_<segno>_v1.webp`), statue d'oro e d'argento su fondo nero pieno. `tool/scontorna_le_statue_della_sinastria.py` toglie solo il fondo (R8) e scrive dodici file nuovi `assets/img/sinastria/statua_<segno>_v1.webp`, ritagliati alla figura, nella cartella gia' dichiarata nel pubspec; le misure in `GeometriaDelloStudio.statue`. Il segno e' quello del Sole composito, come per la coppia di prima.
PADRE: ordine FT voce FT.06 (i medaglioni rotondi, `_Medaglione` e la coppia piccola accanto al titolo).

### GD.19, il responso apre con l'infografica e ogni bolla ha la sua

DOMANDA: "Il responso mostrerà già all'inizio o quasi, magari dopo il titolo, le barre di infografica. E ogni bolla dovrà avere la sua infografica" e "usa la stessa, così l'utente non deve imparare a leggerne una diversa per ogni bolla nella stessa funzionalità"
PROVA: test/gd_la_sinastria_evolutiva_test.dart
MISURA: barre dopo il titolo: prima 0, dopo 5 (una per capitolo), 68 punti sotto il titolo "Tu e Giulia"; valori uguali al ricalcolo indipendente dagli aspetti (per la coppia di prova 0,000; 0,080; 0,598; 0,070; 0,223), diversi per un'altra coppia. Bolle con la loro infografica, tutte dello stesso tipo (`IlGraficoDelleBarre`): prima 1 di un altro tipo (la corda divisa di Keplero), dopo 8 provate (Oggi fra voi, i cinque capitoli, Keplero, il cielo comune) piu' il Momento giusto quando ha dei giorni.

I dati, tutti dal calcolo della sinastria (`le_barre_della_sinastria.dart`): la forza del contatto piu' stretto di ogni capitolo e di ogni coppia di punti (`AspettoEvolutivo.forzaCon`, gli orbi gia' approvati), l'accensione dei transiti di oggi per capitolo (la porta sola `MoltiplicatoreCeleste.accensione`), la vicinanza di ogni corda alla sua consonanza, la forza dell'aspetto del cielo comune, l'accensione di ogni giorno del Momento giusto. Nessun numero scritto a mano.
PADRE: ordine FT voce FT.06 (il responso senza infografica) e voce FT.08 (la corda divisa, un grafico diverso dagli altri).

### GD.20, la lista degli amici e' una sola

DOMANDA: "la lista di amici offline, devono essere condivisi tra le funzionalità, adesso c'è per l'oroscopo, ma devono essere condivise con le altre funzionalità di compatibilità che verranno"
PROVA: test/gd20_gli_amici_offline_hanno_una_porta_sola_test.dart
MISURA: file di `lib` che leggono o scrivono una lista di amici sul telefono: 1 prima, 1 dopo (`amici_offline.dart`); funzioni che passano dalla sua porta: prima 1 (la rubrica dell'Oroscopo), dopo 2 (piu' la tendina della Sinastria). La prova del giro: l'amica salvata dall'Oroscopo si vede nella Sinastria, la persona nuova scritta nella Sinastria entra nella lista (`amici_offline` sul telefono) e si vede nella rubrica dell'Oroscopo.

PREMESSA: vera, con una precisazione. La Sinastria non aveva una seconda lista: non leggeva gli amici offline per niente (la nascita si scriveva ogni volta a mano). Al Viandante la lista e' chiusa (posti zero): la persona nuova vale per la lettura e il modulo lo dice prima.
PADRE: ordine FT voce FT.14 (la Sinastria che chiedeva la nascita a mano, senza la lista).

### GD.21, la lettura arriva anche all'amico del Cerchio

DOMANDA: proposta dell'Architetto approvata dal fondatore con "2 si" (l'ordine non riporta altre parole del fondatore).
PROVA: test/gd21_la_sinastria_arriva_all_amico_test.dart
MISURA: giro fra due identita' di collaudo finte ("u-io" e "u-stella"): letture consegnate prima 0 (la porta non esisteva), dopo 1; capitoli arrivati uguali parola per parola, titolo e paragrafi: 5 su 5; dati di nascita nel corpo consegnato: 0 (cercati 1992, 1990, 08:15, 14:30, "nascita"). A chi non e' nel Cerchio (una persona sconosciuta al Cerchio, una persona offline): chiamate alla porta 0, consegne 0. Lato server (`functions/src/sinastria_evolutiva.test.ts`, 4 prove nuove, verdi con le altre: 82 su 82 con `sociale.test.ts` e `cerchio.test.ts`): il responso passa intero fra amici, una nascita infilata nel corpo non arriva, a chi non e' amico o ha bloccato non arriva niente, un responso monco non si consegna.

Fatto: lato telefono `IlCerchioSociale.mandaLaSinastria` (non chiama la porta per chi non e' amico), `SinastriaRicevuta` e `IlMioCerchio.sinastrie`, `LaSinastriaCondivisa` (la forma della porta, presa dai capitoli che la schermata ha appena composto: lo stesso responso, i capitoli che il piano di chi legge apre), la schermata `LaSinastriaRicevutaScreen` e la voce "Il vostro cielo è stato letto" nel tuo Cerchio. Lato server `mandaLaSinastria` in `functions/src/il_cerchio_sociale.ts` (tetto 30 l'ora in `TETTI_DELLE_PORTE`, esportata da `index.ts`), la raccolta `utenti/{uid}/sinastrie`, l'avviso "<nome>: il vostro cielo è stato letto", la lettura delle sinastrie dentro `ilMioCerchio`; la logica pura `sinastriaDaCorpo` e `laSinastriaSiConsegna` in `functions/src/sinastria_evolutiva.ts`. Le due guardie del server che contano le porte sociali passano da 35 a 36 (commento accanto).
PADRE: funzione nuova, nessun difetto.

### GD.22, "Oggi fra voi" sulla scheda della coppia

DOMANDA: proposta dell'Architetto approvata dal fondatore con "3 ok".
PROVA: test/gd_la_sinastria_evolutiva_test.dart
MISURA: la riga viva sulla scena della coppia, il 23 ottobre "Giove allarga oggi il punto in cui vi riconoscete.", il 24 ottobre "Oggi Giove passa sui gradi dove il legame vi indica una strada: la direzione sembra ampia e promettente." (righe diverse: 2 su 2 giorni); coppie nuove rimaste alla rilettura: 14 prima, 14 dopo (nessun contatore scalato).

PREMESSA: vera per i testi (72 di "Oggi fra voi" e 72 del "Momento giusto", 144, dall'ordine FT). PREMESSA DA PRECISARE per la scheda: sul ramo non c'era una "scheda di una coppia gia' scoperta" (nessun ricordo delle coppie lette). Adesso la coppia gia' scoperta e' riconosciuta (`LeCoppieScoperte`, un'impronta di coppia e legame, nessuna nascita salvata, sotto il prefisso `sinastria.` che l'uscita dall'account toglie) e la sua scheda e' la scena con la statua, la riga viva e la lettura; rileggerla non consuma.
PADRE: nessun difetto (funzione nuova sui testi dell'ordine FT voce FT.09).

## LE SCELTE DI CODE, CON LA RAGIONE

- **La tendina porta tutto il percorso, il modulo in un passo solo.** Nome, data, ora, legame, profondita' e pulsante stanno nello stesso passo, nell'ordine delle frasi del fondatore ("Dopo la selezione [...] il modulo", "Poi potrà scegliere che tipo", "Inoltre ci sarà il selettore", "Quando avrà inserito i dati si attiverà il pulsante"): cosi' il pulsante spento dice che cosa manca, in una riga sotto di lui.
- **Online sono gli amici del Cerchio, non i presenti adesso.** Il fondatore dice "l'elenco degli amici del cerchio"; i presenti chiederebbero la tendina della presenza (con il suo tetto di trenta chiamate l'ora).
- **La statua e' la coppia del segno della relazione, scontornata.** Le sole figure dipinte "grandi" della cartella sono le dodici coppie (statue su fondo nero); i medaglioni dei capitoli sono tondi. Le coppie originali restano (il ritratto, la card e il Diario le usano col fondo).
- **La statua sta sul piano del tavolo, alta 500 pixel dello sfondo**, dalla base fino a sotto il viso di Medora: grande e Medora resta in vista dietro di lei.
- **Il titolo del riquadro della Lunga e' "Il filo che vi lega"**, come chiesto dall'ordine; il riquadro porta il Tema Composito, che e' letteralmente il terzo cielo della relazione.
- **La forma del dato fra telefono e server della GD.21 e' il responso composto, non i due cieli.** Mandare i due cieli avrebbe fatto viaggiare le nascite; il server non riscrive niente e butta ogni campo che non sia di un responso.
- **Il ritaglio della scena a tutto schermo e' un cover centrato**: a 360x800 si perdono 45 punti per lato del dipinto, mai una banda vuota.
- **`AttesaDiMedora` ha un parametro in piu', `righeProprie`**: la Sinastria riflette con la stessa scena e le sue righe nominano i due cieli invece delle carte (la regola delle righe della Stesa). E' l'unico tocco a un file della Stesa, additivo: senza il parametro la Stesa e l'Oracolo restano com'erano.

## DOVE HO TOCCATO, OLTRE LA SINASTRIA

- `lib/features/tarot/attesa_di_medora.dart`: il parametro `righeProprie` (additivo).
- `lib/core/entitlement/plan_catalog.dart`: `RigaDelPiano.sinastriaLunga` e la sua riga nella matrice.
- `lib/core/cerchio/il_cerchio_sociale.dart`: `SinastriaRicevuta`, `IlMioCerchio.sinastrie`, `mandaLaSinastria`.
- `lib/features/cerchio/il_tuo_cerchio_screen.dart`: la voce "Il vostro cielo è stato letto".
- `lib/features/shell/dove_si_vede_la_barra.dart`: `LaSinastriaRicevutaScreen` dichiarata senza barra (guardia `ogni_schermata_dichiara_la_barra`).
- `functions/src/` (non pubblicato): `il_cerchio_sociale.ts`, `sinastria_evolutiva.ts`, `sociale.ts`, `index.ts` e le prove `sinastria_evolutiva.test.ts`, `sociale.test.ts`.

## LE PROVE VECCHIE AGGIORNATE, E PERCHE'

- `la_sinastria_evolutiva_si_apre_sulla_scena_test.dart`: la scelta passa dalla tendina (GD.14) e la lettura si cerca sotto la scena a tutto schermo (GD.13); al posto del titolo della scelta, uscito, si misura che il pulsante non copre Medora. LAPIDI nei commenti.
- `la_sinastria_evolutiva_a_video_test.dart`: la figura della coppia e' la statua (GD.18); le tre prove dello sbarramento d'eta' chiedono il legame alla schermata invece di toccarlo nella lettura (GD.16) e misurano gli stessi tre fatti.
- `il_ponte_conta_le_coppie_nuove_test.dart`, `il_giro_delle_sinastrie_test.dart`: la scelta dalla tendina (aiuto comune `test/la_tendina_della_sinastria_aiuto.dart`).
- `la_scena_della_sinastria_e_un_filmato_test.dart`: si scorre fino ai nomi, sotto la scena a tutto schermo.
- `functions/src/sociale.test.ts`: le porte sociali sono 36 (la nuova `mandaLaSinastria`).

Verdi in locale: le prove della zona (le 13 della Sinastria, le 3 nuove, 18 + 2 + 3 prove nuove) e le guardie di casa che scorrono `lib` (186 file) piu' le prove che nominano piano, Cerchio, amici e attesa (71 file): l'esito e' scritto in fondo.

## LE GUARDIE NUOVE

- `test/gd20_gli_amici_offline_hanno_una_porta_sola_test.dart`: passa dalla porta comune `sorgentiDiLib()`, dichiara il cardinale minimo (1 file che tocca la lista, 2 funzioni che usano la porta).
- `test/gd_la_sinastria_evolutiva_test.dart`: prove a video della schermata, non scopre insiemi tranne la guardia del modello (10 sorgenti, cardinale minimo dichiarato), il censimento del modulo (almeno 15 testi) e le bolle (8, il cardinale dell'elenco).
- `test/gd21_la_sinastria_arriva_all_amico_test.dart`: prova del giro, non scopre insiemi.
- `functions/src/sinastria_evolutiva.test.ts`: quattro prove della GD.21, non scoprono insiemi.

## DA FARE NELLA SESSIONE PRINCIPALE (file comuni che la parte d non tocca)

- **Il registro delle guardie** `docs/guardie.md`: la guardia nuova `gd20_gli_amici_offline_hanno_una_porta_sola` passa dalla porta comune `sorgentiDiLib()` e va registrata (categoria uno, cardinale proprio dichiarato, Regola A in `regola_a_d.txt` A2), con le prove nuove `gd_la_sinastria_evolutiva`, `gd21_la_sinastria_arriva_all_amico` e le quattro prove del server. Finche' non c'e', `il_registro_delle_guardie_quadra_test.dart` cade ("nessuna guardia della porta comune resta fuori dal registro": `gd20_gli_amici_offline_hanno_una_porta_sola_test.dart`).
- **`docs/stato_asset.json`**: se il fondatore vuole, una nota sulle dodici statue scontornate (cartella gia' dichiarata, la guardia degli asset resta verde).

## IL COMANDO DA FAR ESEGUIRE AL FONDATORE (mai eseguito da Code)

```
cd functions
npm run build
firebase deploy --only functions:mandaLaSinastria,functions:ilMioCerchio
```

`ilMioCerchio` va ripubblicata perche' adesso porta anche le sinastrie ricevute. Prima della pubblicazione, sul telefono la riga della consegna dice che la porta non e' aperta e l'amico non riceve niente: nessun dato si perde.

## ASSET DA AGGIUNGERE AL PUBSPEC

Nessuno: le dodici statue nuove (`assets/img/sinastria/statua_<segno>_v1.webp`, da 140 a 175 KB l'una) stanno in `assets/img/sinastria/`, cartella gia' dichiarata. Da aggiungere, se il fondatore lo vuole, la nota in `docs/stato_asset.json` (file comune, non toccato).

## DA VEDERE SUL TELEFONO (simulazione da persona e del bambino)

1. Home, dominio di Medora, "Sinastria evolutiva": il video a tutto schermo (nessuna banda), la domanda sopra la testa di Medora, il solo pulsante "Scegli la persona". Toccare durante il video (salta).
2. "Scegli la persona": la tendina che sale velata, Online e Offline. Online senza amici (account di collaudo senza Cerchio): la riga e "Invita nel Cerchio", poi la freccia indietro. Online con amici. Offline con e senza amici salvati.
3. Il modulo: tastiera sul nome (la tendina sale con la tastiera), calendario, orologio, "Non conosco l'ora", "Hai un codice dal suo telefono?", le quattro icone, la tendina Breve/Lunga col lucchetto al Viandante.
4. "Scopri la compatibilità": la riflessione, poi la statua sul tavolo (guardare lo scontorno sulla statua dei Pesci, la piu' difficile), la riga viva e "Scorri in su per leggere il vostro cielo".
5. La lettura: le barre dopo il titolo, la barra in ogni bolla, la Lunga col riquadro "Il filo che vi lega" (Iniziato), "Un'altra sinastria".
6. Cambiare la data del telefono di collaudo al giorno dopo e rileggere la stessa coppia: la riga viva cambia, il conto delle coppie no.
7. La GD.21 dopo la pubblicazione: due account di collaudo amici nel Cerchio, lettura dall'uno, avviso e "Il vostro cielo è stato letto" sull'altro.
