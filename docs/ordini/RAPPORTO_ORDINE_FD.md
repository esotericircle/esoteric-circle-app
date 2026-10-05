# RAPPORTO DELL'ORDINE FD, LA CONFERMA DELLA SPESA, LA PORTA SOLA DEL CIELO, I BANCHI, IL TASTO INDIETRO E IL CERCHIO DEI COLLAUDI

**Niente si spende al primo tocco.** Prima dei minuti del LIVE o degli Eos
compare sempre la stessa conferma, col costo, il saldo e due pulsanti, e un
punto di spesa nuovo che la saltasse non compila. **Il cielo ha una porta
sola**, Meeus, verificata contro il JPL dal 1900 al 2100, e fuori da quegli
anni non risponde; il motore del 2020-2030 non esiste piu'. **I banchi col
modello hanno un comando solo**, girano prima di ogni consegna e dicono
quanto costano. **Il tasto indietro non esce mai dall'app**: sulla home
chiede di premerlo di nuovo. **Il Cerchio popolato e' stato visto su un
telefono vero**, col secondo account di collaudo, e torna vuoto quando
l'altro esce. **E con l'Aggiunta FD.06**: la rubrica del telefono e' la prima
strada per chiamare qualcuno nel Cerchio, e i contatti non lasciano il
telefono.

Ramo `claude/esoteric-circle-master-order-e798aj`, partenza `07d74c3d`, 5
ottobre 2026. Manifesto: `docs/ordini/ORDINE_FD_MANIFESTO.md`. Regola A:
`docs/collaudo/FD/regola_a_fd.txt`. Anteprime a 360 per 797 punti:
`docs/preview/FD/`. Catture del Realme: `docs/collaudo/FD/realme/`. Build e
consegna in fondo, nelle righe in coda.

## LE VOCI CHIUSE, con la prova di ciascuna

- FD.02, una porta sola per il cielo, con la sua validita': test/il_cielo_ha_una_porta_sola_test.dart
- FD.03, i banchi col modello non sono codice morto: test/i_banchi_col_modello_hanno_un_comando_test.dart
- FD.05, il Cerchio popolato visto su un telefono vero: test/i_collaudi_sono_registrati_test.dart
- FD.06, la rubrica come prima strada nel Cerchio: test/la_rubrica_resta_sul_telefono_test.dart

La FD.01 e la FD.04 sono APERTE IN ATTESA DI VERIFICA: il codice e le prove
sono fatti, e si chiudono nelle righe in coda con la cattura del Realme sulla
build 2298, la conferma dei minuti del LIVE (che chiude anche la EJ.10) e
l'avviso del tasto indietro sulla home.

## LE PREMESSE ABBATTUTE

- **FD.01, "la conferma del costo esiste gia' da qualche parte e il LIVE la
  salta": falsa a meta'.** Prima dell'ordine nessun punto mostrava il costo
  e il saldo con due pulsanti: c'erano quattro modi diversi (la riga col
  prezzo della porta della spesa, il riscatto a un tocco, il confronto in
  piu', il dialogo proprio del dono), e due soli punti avevano due pulsanti,
  senza il saldo. Il LIVE non saltava una conferma: non ne aveva nessuna, e il
  tocco sulla pastiglia apriva subito una sessione a pagamento. I quindici
  punti con file e riga in `docs/collaudo/FD/i_punti_di_spesa.md`, ricontati
  sul codice finale: le diciannove righe citate sono identiche.
- **FD.02, il motore del 2020-2030.** Vero che c'era (`Effemeridi`, 29 righe
  di chiamata in 16 file, pianeti da elementi medi di Keplero) e che non
  c'era un motore dei pianeti valido per tutti gli anni. Accanto c'erano due
  Soli e due Lune (Celestial e NightSky da una parte, Meeus dall'altra) e tre
  punti che usavano la Luna del motore 2020-2030 su date di nascita fuori
  dalla sua epoca (`birth_moon.dart`, `guide_animal_day.dart`,
  `natal_identity.dart`: PROVENIENZA IGNOTA, nessun commit li dichiarava).
  Fonti della posizione di un corpo in `lib` prima 6, dopo 1.
- **FD.05, "un account sull'emulatore del PC".** L'emulatore su questo PC
  non parte: la virtualizzazione e' spenta nel firmware e il servizio aehd
  esce con l'errore -95. La scelta del fondatore del 5 ottobre 2026 e' stata
  il secondo telefono finto, `tool/il_secondo_telefono.py`, un client che
  parla al server come l'app con un account nato anonimo.
- **FD.06, "Manda il link manda a una persona per volta".** Misurato: il
  pulsante apre il foglio di condivisione del sistema
  (`lib/features/account/invita_un_amico.dart:29-30`, poi
  `PortaDellaCondivisione.testo`, poi `SharePlus.instance.share` in
  `lib/core/condivisione/porta_della_condivisione.dart:216-221`). Dal foglio
  si sceglie un'app, e dentro l'app di solito una persona; la rubrica
  adesso ne chiama fino a dieci in un messaggio solo.

## LE VOCI, PRIMA E DOPO

**FD.01, nessuna spesa senza conferma.** Una conferma sola,
`LaConfermaDellaSpesa` (`lib/design_system/components/la_conferma_della_spesa.dart`),
coi testi dell'ordine alla lettera. Ogni porta che consuma pretende un
`ConsensoDellaSpesa`, che ha il costruttore privato e lo crea solo la
conferma: un punto di spesa nuovo che la salti non compila (la guardia lo
prova rompendolo). I minuti del LIVE si leggono dal server prima del tocco con
la funzione nuova `iMinutiDelLive`. Punti con la conferma di costo e saldo
prima 0 su 15, dopo 15 su 15; modi diversi di confermare prima 4, dopo 1;
con "Non ora" il saldo resta 300 e i movimenti 0, il LIVE chiama solo
`iMinutiDelLive`; col saldo corto il pulsante e' spento e i movimenti 0.
Anteprime: `fd_conferma_minuti.png`, `fd_conferma_eos.png`,
`fd_conferma_saldo_corto.png`.

**FD.02, una porta sola per il cielo.** `IlCieloDiMeeus`
(`lib/core/astro/meeus/il_cielo_di_meeus.dart`): VSOP87D troncato per i
pianeti, il capitolo 47 intero per la Luna, il 37 per Plutone, il tempo
dinamico da una tavola anno per anno. Intervallo verificato dal 31 dicembre
1899 al 31 dicembre 2099: fuori, `FuoriDalCieloVerificato`, e la chiamata
non risponde con un numero sbagliato. Le eclissi dichiarano il loro, 2021-2030.
Contro il JPL DE440s su 60 istanti del secolo (`docs/collaudo/FD/riferimenti_del_cielo.csv`),
lo scarto massimo in secondi d'arco: Sole 0,3, Luna 11,0, Mercurio 0,5,
Venere 1,0, Marte 2,5, Giove 1,1, Saturno 1,0, Urano 2,5, Nettuno 2,7,
Plutone 3,3, latitudine della Luna 2,2. Prima, col vecchio motore, fino a
0,570 gradi su Saturno al 1950. Le venti coppie del confronto in
`docs/collaudo/FD/il_confronto_prima_e_dopo.txt`: la Luna si sposta al
massimo di 647,6 secondi d'arco, e su 20 coppie 0 cambiano l'affinita', 0
il cielo di oggi, 0 il segno della Luna. Cancellati `Effemeridi`,
`IlSoleDiNascita`, `IlCieloDelJpl`, `le_effemeridi_del_jpl` col suo
generatore, e il Sole NOAA dell'alba e del tramonto.

**FD.03, i banchi col modello.** Un comando,
`python tool/banchi_col_modello/i_cinque_banchi.py --costo`, scritto nel
README insieme a cosa misura ognuno dei cinque. Il risultato del giro sta in
`docs/collaudo/banchi_col_modello/<data>.txt`; `tool/consegna.py` non
consegna se l'ultimo giro non e' passato sullo stesso codice di `lib`, `test`
e banchi. Il giro dell'ordine, sul commit `5710ea75`, dal 14:48 al 16:09
UTC del 5 ottobre 2026, in `docs/collaudo/banchi_col_modello/2026-10-05.txt`:
cinque PASSATO su cinque. Il classificatore 40 giuste su 41 (97,6 per
cento); su 1.100 discese il titolo dal modello 97,0 per cento, la risposta
76,1, il gesto 97,5, 0,003059 dollari a discesa; venti cammini con 0 strati
che si ripetono; il segno accettato 11 volte su 12; trenta sigilli, 0,00072
dollari l'uno. Comandi per lanciarli prima 0 (tre righe a mano), dopo 1;
giri registrati prima 0, dopo 1 passato (e uno rosso, tenuto). Costo di un
giro intero: 3,22 euro (3,60 dollari da Monitoring, cambio BCE 1,1204).

**FD.04, il tasto indietro.** Sulla home il primo tocco mostra "Premi di
nuovo per uscire." per due secondi, e solo un secondo tocco entro due secondi
esce (`lib/features/shell/il_tasto_indietro_della_home.dart`). Dal Passport
torna al Cerchio. In `lib` un punto solo chiude l'app. Le 67 rotte con file,
riga e dove porta il tasto in
`docs/collaudo/FD/le_schermate_e_il_tasto_indietro.md`, generato da
`tool/le_schermate_e_il_tasto_indietro.py` (66 prima della rubrica della
FD.06). Anteprima: `fd_home_avviso_indietro.png`.

**FD.05, il Cerchio dei collaudi.** Lo spazio proprio della presenza per i
due account di collaudo (`functions/src/i_collaudi.ts`; registro leggibile
`docs/collaudo/registro_dei_collaudi.md`): il Realme, `iToukegmg2P3...`, e il
secondo telefono finto, `Osut7u5T...`, "Collaudo Due". Nessun documento di
un utente reale letto o scritto. Le catture:
`00_tendina_prima_del_legame.png`, `01_cerchio_popolato_semaforo_verde.png`
(ONLINE 2, "Collaudo Due" col semaforo verde), `02_riga_dell_ultimo_dato.png`
("Il Cerchio come era alle 12:11."), `03_cerchio_di_nuovo_vuoto.png`
(ONLINE 1, nessun amico presente). La prima prova della terza cattura e'
scartata e tenuta con il suo nome (`03_prima_prova_scartata_presenza_rimasta.png`):
un giro della presenza rimasto acceso dopo l'uscita aveva rimesso il secondo
account presente.

**FD.06, la rubrica.** In "Chiama nel Cerchio" la scheda "Chiama chi
conosci" e' la prima delle quattro. Il permesso si chiede solo al tocco di
"Apri la rubrica", con la riga dell'ordine; negato, la scheda dice "La
rubrica è chiusa. Puoi sempre mandare il link." e non lo richiede da se'.
I contatti si leggono sul telefono, in ordine alfabetico con la ricerca, se
ne scelgono fino a dieci ("Dieci per volta."), e "Manda l’invito" passa un
messaggio solo all'app dei messaggi coi destinatari, il link e gli Eos del
listino (150). Nessuna copia, nessun indice, nessun confronto con gli
utenti. Le due righe tolte dalle schede stanno intere nella pagina unica
della privacy, sezione "Il Cerchio: inviti, codici e rubrica". I testi della
scadenza del link e del codice stanno nell'app e nel server, pubblicato dal
fondatore alle 11:14 UTC del 5 ottobre 2026 (`chiediIlLegame`,
`rispondiAlLegame`, `paginaDellInvito`, verificati ACTIVE; la pagina
pubblicata dice gia' il testo nuovo). Anteprime:
`fd06_quattro_schede.png`, `fd06_rubrica_tre_scelti.png`,
`fd06_rubrica_al_tetto.png`, `fd06_permesso_negato.png`,
`fd06_link_scaduto.png`.

## FIN DOVE SONO ARRIVATO

Fatte tutte e sei le voci, col codice, le prove viste rosse e le anteprime.
Restano, e si scrivono in coda con la loro prova: la suite intera e il
cancello coi tre numeri uguali, la build 2298 con la consegna, le due catture
del Realme che chiudono la FD.01 (e la EJ.10) e la FD.04.

## LA REGOLA A E LA REGOLA B

Gli innesti in `docs/collaudo/FD/regola_a_fd.txt`, col banco
`tool/gli_innesti_dell_ordine_fd.py`: A1-A7 e A9-A36, tutti rossi sul
bersaglio, piu' B1-B3 (A35 e A36 fatti a mano e scritti nello stesso registro). A8 e' stato tolto perche' misurava un doppione del
pulsante spento, poi tolto dal codice. A14, A26 e A27 sono stati verdi al
primo giro, e adesso sono rossi. A14: lo scarto che la porta dichiarava
era piu' largo del vero, e un difetto ci stava dentro; e' stato rimisurato
col tempo dinamico anno per anno e dichiarato com'e' (commit `1258ae9e`).
A26 confrontava i numeri interi invece delle sole cifre, e si e' cambiata la
grandezza misurata. A27 colpiva un controllo doppio, tolto dal codice, e
l'innesto e' passato su quello vero. **Regola B,
confessata**: le guardie `il_cerchio_non_ha_testo_libero` e
`le_chiavi_di_ios_ci_sono_tutte` e la prova EY.04 del server sono state viste
rosse dopo il tocco della FD.06 e non prima (B1, B2, B3). La guardia del
manifesto e' stata vista rossa prima di portarla a sei voci. Le altre viste
rosse prima del tocco: `una_sola_porta_per_i_transiti`, `fase_lunare_vera`,
`la_luna_intera`, `la_rivoluzione_solare`, `il_listino_vivo`,
`il_cerchio_si_apre_a_quattordici_anni`. Il registro delle guardie e' a 696.

## I DIFETTI TROVATI, ognuno col suo padre

1. **"Il tuo Cerchio" diceva vuoto con un amico presente.** Visto sul
   Realme nel giro della FD.05: il legame era nato con la schermata aperta, e
   al ritorno l'elenco restava "Il tuo Cerchio è ancora vuoto" sotto la
   tendina che mostrava l'amico. Padre: ordine EY, commit `af6a327d`, che
   leggeva il Cerchio una volta sola. Curato: si rilegge quando si chiude
   una rotta sopra e quando l'app torna in primo piano
   (`test/il_cerchio_si_rilegge_al_ritorno_test.dart`, A33 e A34).
2. **Il tutorial sotto i tasti di sistema.** Il fatto di un tester su un
   Redmi Note 14: al passo dei Maestri il tasto Avanti finiva sotto la barra
   dei tre tasti, e il tutorial non si chiudeva ne' andava avanti. Padre:
   ordine CB voce 02, commit `20879fa6`, che contava l'ingombro sullo schermo
   intero e col carattere a scala 1. Curato: il fumetto sta fra le barre di
   sistema, la carta si misura con la scala vera, e se non ci sta il testo
   scorre e i tasti restano (prova in `test/il_primo_approdo_test.dart`,
   rossa sul codice di prima, A35; anteprima
   `fd_tutorial_redmi_tasti_di_sistema.png`).
3. **La Luna del motore 2020-2030 su date di nascita.** Tre punti, PROVENIENZA
   IGNOTA. Curati dalla porta sola della FD.02.
4. **Due rosse della suite intera, mie.** La chiave `perche` della risposta
   del server letta nella porta del Cerchio (ordine FD voce 06), esentata
   dalla guardia degli accenti come chiave; e una frase mia nella pagina
   della privacy con la virgola davanti a "e" (ordine FD voce 06), riscritta.
5. **Il comando dei banchi perdeva il giro.** Il primo giro, ottanta minuti,
   e' caduto su un 401 di Monitoring: il gettone preso all'inizio era
   scaduto, e il file del giro non e' nato. Padre: ordine FD voce 03. Curato
   (`2edb46d8`): il gettone si prende al momento del costo, e gli esiti si
   scrivono comunque. Il secondo giro e' caduto sul quarto banco, il segno,
   con un 429 di Vertex, "Resource exhausted": la quota della regione era
   consumata dalle cento discese appena fatte, e le chiamate dei banchi non
   riprovavano. Padre: ordine DI (commit `86a95f25`), che ha scritto la
   chiamata delle cento discese senza riprovare su una quota esaurita;
   l'ordine FC voce 11 l'ha spostata in `test/la_prova_a_cento_discese_comune.dart`
   com'era. Curato (`5710ea75`): fino a cinque nuovi
   tentativi con attese da due a trentadue secondi su 429 e 503. Lo stesso
   giro ha mostrato altri due difetti del comando, ordine FD voce 03:
   l'uscita delle prove non si teneva, e il motivo del rosso si e' letto solo
   rifacendo il banco da solo; e le misure stampate dai banchi non venivano
   lette. Curati nello stesso commit. Il giro rosso resta in
   `docs/collaudo/banchi_col_modello/2026-10-05.giro_rosso_429`. E la
   consegna confrontava tutta la cartella `test/` col commit del giro: un
   `const` chiesto dall'analisi in una prova del Cerchio avrebbe preteso un
   giro nuovo, ottanta minuti e tre euro, senza che i banchi eseguissero
   quella prova. Padre: ordine FD voce 03. Adesso confronta `lib`, la
   cartella dei banchi e i file di `test/` che i banchi importano a catena,
   quattro (A36: rossa contro il commit di prima dei nuovi tentativi).
6. **La barra grigia della rubrica.** Vista nell'anteprima al tetto dei dieci.
   Padre: ordine FD voce 06. Curata avvolgendo la schermata come le altre del
   Cerchio.
7. **Le rosse della prima suite intera dell'ordine** (commit `98509b5b`):
   l'apostrofo di un messaggio di Meeus (FD.02), il censimento dei vuoti
   (FD.05), due guardie del server sulla forma nuova dell'istantanea con lo
   spazio dei collaudi (FD.05), il sigillo a cinque voci.
8. **Un giro della presenza rimasto acceso.** Fermare il compito non aveva
   fermato il ciclo python del secondo telefono, che ha rimesso la presenza
   dopo l'uscita: la prima terza cattura e' scartata. Padre: il mio modo di
   condurre il collaudo della FD.05.

## LE DECISIONI CHE RESTANO AL FONDATORE

1. **"1 minuto" al singolare.** L'ordine scrive "NN minuti"; con un minuto
   solo la conferma dice "1 minuto". E' l'unico scarto dai testi alla
   lettera.
2. **L'apostrofo tipografico in "Manda l’invito"** e nei testi nuovi, come in
   tutta l'app.
3. **La riga del permesso su Android.** Prima della finestra di sistema
   compare la riga dell'ordine nel preludio del permesso, come per gli altri
   permessi dell'app; su iOS la stessa riga sta nella chiave
   `NSContactsUsageDescription`.
4. **`CostoInChiaro` resta.** E' la riga sopra i pulsanti delle arti a
   consumo (ordine AN voce 05) che dice cosa resta gratis oggi o quanto
   costa la prossima: informa prima del tocco, non conferma, e la conferma
   resta una sola.
5. **Il riscatto dell'invito dice "scaduto"** solo quando il server risponde
   "codice scaduto"; ogni altro rifiuto resta il rifiuto di prima.
6. **Il secondo telefono finto al posto dell'emulatore**, finche' la
   virtualizzazione resta spenta nel firmware del PC.

**Aggiunta del 5 ottobre 2026, ordine FD, voce chiusa**: FD.01, nessuna spesa senza conferma: test/la_spesa_passa_dalla_conferma_test.dart, e sul Realme con la build 2298 docs/collaudo/FD/realme/04_conferma_dei_minuti_del_live.png (il tocco sulla pastiglia d'oro apre "Stai per aprire una sessione dal vivo." con 20 minuti dei 146 disponibili) e 05_dopo_non_ora_nessuna_sessione.png ("Non ora" non apre niente); chiude anche la EJ.10, con la riga in coda al rapporto EJ.

**Aggiunta del 5 ottobre 2026, ordine FD, voce chiusa**: FD.04, il tasto indietro non esce mai dall'app: test/il_tasto_indietro_non_esce_dall_app_test.dart, e sul Realme con la build 2298 docs/collaudo/FD/realme/06_home_premi_di_nuovo_per_uscire.png (dalla chat di Medora al dominio, dal dominio alla home, sulla home "Premi di nuovo per uscire." e l'app resta in primo piano quattro secondi dopo).

**Aggiunta del 5 ottobre 2026, ordine FD, il cancello, la build e la consegna**: il cancello di GitHub sul commit `d251c4c2` ha eseguito 6796 casi, 6796 passati, 0 rossi, 0 saltati, in sei pezzi, e il server 188 su 188; la ref `refs/verde/d251c4c2...` scritta da GitHub (il giro prima, su `a5c8ec08`, era caduto su una sola prova, il rapporto FD non ancora registrato: registrato in `d251c4c2`). Build 2298 dalla copia pulita al commit `d251c4c2`, `flutter build apk --release --target-platform android-arm64`, 243,9 MB, rifatta perche' la prima, su `a5c8ec08`, era piu' vecchia del commit da consegnare; consegnata con `tool/consegna.py`: i cinque banchi passati sul codice consegnato, il cancello verde riconosciuto dalla ref, release `282gqliiurp00`, distribuita a cloud@esotericircle.app (accettati 1), installata sul Realme 767f596c (versionCode 2298), registro `docs/versione_distribuita.json` da 2297 a 2298. La suite intera locale sullo stesso commit si scrive nella riga dopo.

**Aggiunta del 5 ottobre 2026, ordine FD, i tre numeri**: la suite intera locale sul commit consegnato `d251c4c2`, copia pulita a fine riga LF, `TZ=Europe/Rome flutter test -r expanded`: 6796 passati su 6796, 0 rossi, 0 saltati, in 59 minuti e 57 secondi. Casi sul ramo 6796, eseguiti dal cancello 6796, eseguiti sul PC 6796: coincidono (R7). Il cancello e' verde anche sul commit `96521041`, quello che Codemagic costruisce per iOS.

**Aggiunta del 5 ottobre 2026, ordine FD, la firma nella storia**: tolta la copia di lavoro `ecs`, che conteneva le copie locali dei file della firma, si e' guardata la storia intera, dopo `git fetch --all --prune`: 41 riferimenti (26 rami locali, 13 remoti, 0 etichette, lo stash), 2304 commit, 43724 oggetti. Nessun file della firma e' mai stato aggiunto a un commit, su nessun ramo, in nessun momento. Per nome, `git rev-list --all --objects` e `git log --all --name-only` e `git log --reflog --name-only` filtrati su .jks, .keystore, .p12, .pfx, .p8, .mobileprovision, .provisionprofile, .cer, .der, .pem, .key, .csr, key.properties, keystore.properties e signing.properties: 0, 0 e 0. Per contenuto, `git cat-file --batch` su tutti i 24690 blob raggiungibili da `git rev-list --all --reflog --objects`: keystore Java (primi byte FEEDFEED o CECECECE) 0, PKCS12 o DER 0, chiavi o certificati PEM 0, profili di provisioning 0, righe storePassword= o keyPassword= con un valore 0. `git log --all --reflog -S` trova quattro commit con quelle parole, e nessuno porta un segreto: `3087b563` (il codice di build che legge le due password dal file locale escluso da git, e il messaggio che spiega come crearlo), `5f9aaa67` e `fc4725be` (le istruzioni della prima build iOS e una prova che cerca le intestazioni PEM nel testo). Nessuna storia riscritta, niente cancellato.

**Aggiunta del 5 ottobre 2026, ordine FD, un difetto fuori ordine**: il tutorial del primo approdo sul Redmi Note 14 di un tester, coi tre tasti di sistema e il carattere ingrandito: al passo dei Maestri, 2 di 5, il tasto Avanti stava sotto la barra dei tasti, e il tutorial non si chiudeva ne' andava avanti. Padre: ordine CB voce 02, commit `20879fa6`, che contava l'ingombro sullo schermo intero e col carattere a scala 1. Curato in `6944b91f` (il fumetto fra le barre di sistema, la misura con la scala vera, il testo che scorre se non ci sta; A35) e in `a77ca273`, dopo un secondo difetto visto sul Realme con la 2298: l'ultima riga dei Maestri tagliata con lo spazio libero sotto, perche' il fumetto era posato sull'altezza stimata, corta di dieci punti, figlio di `6944b91f` (adesso si posa sull'altezza vera; A37). Prima e dopo in `docs/collaudo/FD/tutorial_redmi/`: 01, la cattura del tester; 02, il Realme con la 2298, i tre tasti in vista; 03, l'anteprima nella geometria del Redmi col codice curato. Prove in `test/il_primo_approdo_test.dart`: tasti sotto le barre sul Redmi 0 su 15, testo tagliato con lo spazio libero sul Realme 0 su 5. La cura della riga e' nel ramo e non nella 2298: entra nella prossima build. Il Registro dei Difetti che gli ordini P ed ENTITLEMENT citano non e' un file del repo, ne' oggi ne' in nessun commit della storia: il difetto e' registrato qui e in docs/STATO_VIVO.md.
