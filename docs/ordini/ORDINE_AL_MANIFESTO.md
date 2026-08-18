# ORDINE AL. LA RIPARAZIONE DOPO LA 2179: IL COSMO, GLI EOS, LA CAPSULA

Nove voci, da AL.01 ad AL.09. Ramo `claude/esoteric-circle-master-order-e798aj`,
premesse verificate sulla testa `cda32ab` il 18 agosto 2026.

## Come si legge questo file

Una riga per voce, con lo stato in fondo. Stati ammessi: APERTA, CHIUSA,
FERMATA SU PREMESSA FALSA, FERMATA IN ATTESA DI DECISIONE. Finche' una riga
e' APERTA la guardia `test/ordine_al_guard_test.dart` resta rossa. REGOLA
NUOVA NATA DALLA 2179: le voci che si vedono o si sentono sul telefono
(AL.01, AL.02, AL.04, AL.08) NON si dichiarano CHIUSE dal codice: a cura
fatta e guardia verde vanno in FERMATA IN ATTESA DI DECISIONE e la chiusura
la pronuncia il collaudo di Mauro sulla build di AL.09. Un commit per voce;
suite intera UNA volta ad AL.09.

## Le premesse, verificate una per una il 18 agosto 2026

1. **P1 VERA.** Il cosmo porta le scorte di AJ.02 e la sospensione di AJ.01
   (`osservatoreDelCielo`, `_coperto`, `didPushNext`) in
   `cosmos_background.dart`.
2. **P2 VERA.** `sky_overview_screen.dart` si iscrive alla parallasse per
   conto proprio (riga 904, watch; riga 908 `layerOffset(1.0)`).
3. **P3 VERA.** `med_27` poggia su `PezzoDellIdentita('passaporto')` e il
   gesto nasce dal passaporto; sul telefono e' scattato con l'archetipo
   ancora da fare.
4. **P4 VERA.** `card_del_traguardo.dart` riga 148 apre il foglio con
   `backgroundColor: Colors.transparent`; l'enumerazione completa spetta
   alla voce AL.04.
5. **P5 VERA.** "Eos in attesa" e' `StatoDelSigillo.sospeso`; sulla 2179 le
   celebrazioni promettono e la pillola resta a zero.
6. **P6 VERA.** Notifiche e Privacy sono `_AccountEntry` senza onTap;
   Custodisci il tuo cielo attende `quantiMomenti()` prima dell'invito.
7. **P7 VERA.** La frase "Quell'identita' appartiene gia' a un altro
   Cerchio..." non offre nessun "Continua come".
8. **P8 VERA.** La moneta d'oro NON e' nel repository (brand_assets:
   avatars, intro, santuario, sentieri); saldo e volto vivono in
   `SegnoDelBorsellino` e `PortaDellAccount`, un punto per testata.

## Le nove voci

- **AL.01** Il cosmo ritrova profondita' e movimento — FERMATA IN ATTESA DI DECISIONE
  (corse misurate e IDENTICHE a e5b993f, ipotesi delle corse caduta; la causa
  vera era la sospensione che scattava anche sotto le rotte TRASPARENTI:
  curata, guardie dei bordi intatte; chiude il telefono di Mauro sulla 2180)
- **AL.02** Il Cielo di nascita torna a muoversi — FERMATA IN ATTESA DI DECISIONE
  (in banco la nascita correva identica a stanotte: la fisica e' una sola e
  l'ipotesi della differenza di codice fra i due cieli e' caduta; dei tre
  sospetti dell'ordine, la sospensione era gia' curata da AL.01 e vale anche
  per il cosmo dietro la volta, l'iscrizione propria di rotta non esiste, e la
  guardia di Riduci Movimento era MESSA MALE: azzerava l'inclinazione, che e'
  un gesto deliberato come il dito, mentre disableAnimations sul telefono si
  accende anche da solo con risparmio batteria o scala animazioni; curata, il
  tilt resta e la parallasse appiattita pure; guardia
  il_cielo_di_nascita_si_muove con rosso provato, tre misure bugiarde cadute e
  dichiarate nella prova; chiude il telefono di Mauro sulla 2180)
- **AL.03** Il Passaporto pieno conta anche l'archetipo — CHIUSA
  (il gesto 'passaporto' scatta a ogni visita e da solo non dice niente: ora il
  pezzo e' COMPOSTO e matura solo con ogni tessera del documento viva, enumerate
  in `PezziDellIdentita.tessereDelPassaporto` con cosa conta oggi e cosa conta
  dopo scritto accanto; il confronto e' sui pezzi, cosi' la carta dal profilo
  vale come quella dal gesto; guardia il_passaporto_pieno_conta_l_archetipo con
  rosso provato sulla condizione monca; il med_27 gia' scattato sul telefono di
  Mauro NON si revoca, un Sigillo acceso non si spegne mai per legge del diario:
  il caso esiste e la riprogettazione dei traguardi lo assorbira')
- **AL.04** Nessun foglio e' bianco — FERMATA IN ATTESA DI DECISIONE
  (porte enumerate 33 e TUTTE dichiarano il fondo: la causa vera del foglio
  bianco non era un colore mancante ne' Impeller, era lo SCOPE: i fogli vivono
  come rotte del Navigator radice e MaestroScope stava dentro home, quindi
  l'assert di MaestroScope.of in release sparisce, il punto esclamativo lancia
  sul nullo e il builder muore in un foglio muto; misurato in banco con
  l'assert 'scope != null' sia sulla card sia sulle vie; due cure a strati,
  lo scope neutro sopra il Navigator come pavimento e il foglio del traguardo
  che veste il Maestro del suo sentiero; guardia nessun_foglio_e_bianco con
  tre prove e rosso provato togliendo le cure; nessun blur per fotogramma
  toccato; chiude il collaudo di Mauro sulla 2180)
- **AL.05** Gli Eos arrivano davvero nel borsellino — FERMATA IN ATTESA DI DECISIONE
  (filo enumerato con le prove: gesto e accensione vivi, festa viva, la
  chiamata PARTE dal telefono e ARRIVA a Cloud Run, provato dai log del
  server pieni di 401 dal 12 al 16 agosto; il punto rotto e' LA PORTA del
  servizio: cinque callable su sei hanno la policy IAM VUOTA, misurata con
  gcloud, e solo natalchart ha allUsers con run.invoker, infatti e' l'unica
  che funziona; il codice della funzione non gira nemmeno; i candidati
  dell'ordine caduti: la chiamata parte, l'uid non c'entra perche' non si
  arriva al codice, l'errore NON e' inghiottito, la regia lo registra nei
  guasti, e il saldo si applica gia' dalla risposta; cura client fatta: la
  promessa "si riprende alla prossima sincronia" non aveva meccanismo, ora
  esistono il libro degli accrediti e la sincronia riprendiIPremiPersi nel
  guardiano, una volta per sessione, idempotente, col saldo finale chiesto
  allo stato intero perche' una risposta ripetuta porta il saldo di allora;
  guardia gli_eos_arrivano_davvero con rosso provato; IL PASSO DI MAURO,
  guidato: aprire il terminale e dare i cinque comandi qui sotto, uno per
  volta, poi aprire l'app; i Sigilli gia' accesi si riprendono da soli al
  primo avvio)

  ```
  gcloud run services add-iam-policy-binding muoviglieos --member=allUsers --role=roles/run.invoker --region=europe-west1 --project=esoteric-circle
  gcloud run services add-iam-policy-binding statodelcerchio --member=allUsers --role=roles/run.invoker --region=europe-west1 --project=esoteric-circle
  gcloud run services add-iam-policy-binding consumadelgiorno --member=allUsers --role=roles/run.invoker --region=europe-west1 --project=esoteric-circle
  gcloud run services add-iam-policy-binding scrivilamemoria --member=allUsers --role=roles/run.invoker --region=europe-west1 --project=esoteric-circle
  gcloud run services add-iam-policy-binding cancellailcerchio --member=allUsers --role=roles/run.invoker --region=europe-west1 --project=esoteric-circle
  ```
- **AL.06** Il menu' account non ha voci morte — CHIUSA
  (Notifiche e Privacy rispondono con l'anticipo del Santuario, showFeatureSheet,
  ognuna con parole sue invece del foglio scritto a mano con la frase qualunque;
  la causa del "al tocco nulla" della custodia era l'attesa NUDA su
  quantiMomenti, sei letture di rete in fila senza tetto, con l'eccezione
  inghiottita dal gesto: ora due secondi di tetto, il foglio si apre comunque e
  il guasto si registra; sottotitolo nuovo "Salva carta natale, ricordi e Eos:
  se cambi telefono non perdi nulla"; guardia il_menu_account_non_ha_voci_morte
  con enumerazione delle voci per costruzione e rosso provato sull'attesa nuda)
- **AL.07** L'onboarding riconosce e propone "Continua come" — CHIUSA
  (il rifiuto "gia' di un altro Cerchio" ora porta con se' CHI e' stato
  riconosciuto, email e credenziale, invece di buttare via tutto; il
  componente unico ContinuaComeRiconosciuto vive nelle DUE scene, foglio
  dell'account e passo del Risveglio, col pulsante "Continua come [nome]" che
  entra col signInWithCredential e la riga onesta PRIMA del tocco: i passi di
  questo telefono restano qui e i due Cerchi non si uniscono, perche' nessuna
  unione esiste e la vecchia frase che la prometteva e' sparita, con la prova
  che ne vieta il ritorno nei sorgenti; "Piu' tardi" resta; nessuna decisione
  di prodotto e' servita perche' la riga dichiara la realta' e la forma era
  nel dettato; guardia l_onboarding_riconosce_e_propone con rosso provato)
- **AL.08** La capsula persistente di volto e borsellino — FERMATA IN ATTESA DI DECISIONE
  (la capsula vive sopra il Navigator come la barra, in alto a destra su ogni
  schermata tranne le tre soglie del Risveglio dichiarate; volto sopra con la
  porta dell'account e saldo sotto con la MONETA D'ORO consegnata da Mauro,
  docs/consegne/Eos1.png, ritagliata sull'alpha vero e adattata in
  assets/brand/moneta_eos.webp; la scritta incisa si perde alle misure piccole
  ed e' dichiarato; la pillola dentro la capsula e' quella VERA in forma
  verticale nuova, con veste mista, conto che sale e bersaglio del volo; le
  testate hanno perso le loro copie di pillola e porta, Santuario, Passaporto,
  dominio, chat, Consiglio e barre delle arti, e il segno ha UNA casa sola
  sorvegliata dai sorgenti; il cuore delle arti e' passato al capo sinistro
  accanto alla freccia cosi' il titolo non perde punti; i doni scorrono a
  sinistra della capsula e SFUMANO sparendo prima di scivolarci sotto,
  gradiente e mai sfocatura, corretto GUARDANDO l'anteprima; tocco sul volto
  apre AccountScreen e tocco sul saldo apre il borsellino per le vie della
  barra; il saldo a quattro cifre misurato dalla prova; ESPLORA e menu' a
  scomparsa intatti; guardia la_capsula_su_ogni_schermata con rosso provato;
  la vecchia guardia della pillola per testata e' sostituita per decisione di
  Mauro con la grandezza nuova scritta accanto; anteprime rigenerate e
  guardate; chiude il collaudo di Mauro sulla 2180)
- **AL.09** Il manifesto, la suite, la build 2180 — CHIUSA
  (manifesto con gli stati veri e i marcatori contati; suite intera DUE volte
  col giornale pieno su file, la prima ha trovato cinque code vere che sono
  state curate e committate, la seconda e' verde su 2804 prove coi SETTE rossi
  di legge dichiarati e tutti preesistenti alla 2179: attribuzione cieca da
  rimisurare dal PC di Mauro, i due disegni dei sentieri fuori tela col peso
  dei traguardi, gia' rossi sulla testa cda32ab, e le guardie degli ordini
  AC, T e U ancora aperti; pubspec a 0.1.0+2180; build arm64 e distribuzione
  su App Tester coi comandi esatti dell'ordine; il rapporto porta build, link
  della release e l'elenco delle cinque FERMATE IN ATTESA che aspettano il
  collaudo di Mauro, piu' il passo manuale del server per gli Eos)

## I marcatori, contati sulle righe

VOCI_TOTALI: 9
VOCI_APERTE: 0
VOCI_CHIUSE: 4
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 5
