# RAPPORTO DELL'ORDINE EY, IL MOTORE SOCIALE DEL CERCHIO

Ramo `claude/esoteric-circle-master-order-e798aj`, partenza `784dd20b`, 4
ottobre 2026. Manifesto: `docs/ordini/ORDINE_EY_MANIFESTO.md`. Registro della
Regola A: `docs/collaudo/EY/regola_a_ey.txt`. Anteprime:
`docs/preview/prima_dopo/ey*`.

## LE VOCI CHIUSE, con la prova di ciascuna

- EY.01, lo pseudonimo e il sigillo: docs/collaudo/EY/realme/07_nome_riservato.png
- EY.03, il menu' del profilo: docs/collaudo/EY/realme/18_icona_scelta_toro.png
- EY.07, quanti amici per piano: test/i_numeri_del_cerchio_sociale_test.dart
- EY.16, il tetto per identita' sulle porte sociali: test/il_cerchio_custodisce_il_cammino_test.dart

Le altre tredici sono APERTE IN ATTESA DI VERIFICA oppure APERTE su una
decisione del fondatore (EY.09, EY.12). **Undici di loro chiedono due
persone**: il legame, i semaforini, la tendina con gli amici presenti, i
segni, le reazioni, i doni, il confronto, il glifo, il link aperto da un
altro telefono. Con un telefono solo si vede la propria meta' (catture
01-18 in `docs/collaudo/EY/realme/`): si chiudono col secondo telefono del
fondatore, seguendo le frasi di collaudo piu' sotto.

## LE PREMESSE ABBATTUTE

Verificate tutte sul worktree di lavoro alla testa `784dd20b`, prima di
scrivere codice.

- **P1 vera.** `lib/core/amici/amici_offline.dart`, classe `AmiciOffline`,
  chiave `'amici_offline'`, posti da `PlanCatalog.matrix` sulla riga
  `RigaDelPiano.amici`.
- **P2 vera.** Le due schermate degli amici esistono.
- **P3 vera.** `OGNI_QUANTO_CHIEDE_MS` 60.000, `FINESTRA_DELLA_PRESENZA_MS`
  60.000 piu' 30.000; `chiEOnline` in `cerchio.ts`.
- **P4 vera.** Nella porta della condivisione l'unico "link" era `'linkedin'`.
  Il link d'invito viaggiava per un'altra strada, `bonus_della_condivisione.dart`.
- **P5 vera.** `amicoInPiu` a 100 Eos, `gratisAlGiorno[Tier.tier3]` nullo.
- **P6 vera.** `indirizzoDelRitorno` e `impostazioniDelLink()`.
- **P7 vera.** `kRuneStrokes` e `RunePainter`.
- **P8 vera.** Il client legge solo il proprio ramo e non scrive mai.
- **P9 vera, e rispettata.** `enforceAppCheck: false` su tutte le callable,
  anche le sedici nuove.
- **P10 FALSA A META', fermata e corretta dall'EY Aggiunta 1.** Esisteva gia'
  un legame di attribuzione dell'invito: `riscattaLInvito` scrive
  `invitatoDa`, i conti degli inviti accolti e un movimento con l'uid
  dell'invitato. Il motore sociale si innesta su quel legame e non ne crea un
  secondo: una porta sola scrive `invitatoDa` (quella di oggi), e chi entra
  col tuo invito trova l'invito al legame in arrivo, arancione pieno, e lo
  accetta lui (`invitoDalRiscatto`). Nessun terzo posto scrive un legame.
- **P11 vera.** L'ultimo manifesto era `ORDINE_EX_MANIFESTO.md`.
- **P12 vera.** Niente in CLAUDE.md o negli agenti vieta l'ordine.
- **Due fatti superati, dichiarati nel primo rapporto e accolti
  dall'Aggiunta 1**: la domanda dell'invito esisteva gia' (CC.08, montata con
  DW.05), e il premio era 60 a testa per decisione del 18 settembre.

## FIN DOVE SONO ARRIVATO, E PERCHE'

Dichiarato in testa (R1): tutte e diciassette le voci, e la build alla fine,
perche' il fondatore ha superato la R9 il 4 ottobre ("Finisci tutto e vai anche
oltre [...] Alla fine fai test su Cell collegato al PC e poi consegna nuova build
su AppTester e pronta per Codemagic").

Fatto: tutto il codice delle diciassette voci, sul server e sul telefono, con
le prove e le anteprime. **Server: 179 prove su 179** (`npm test`).

**Cio' che non dipende da me e ferma la verifica a video.** La pubblicazione
delle funzioni e' stata negata due volte dal controllo dei permessi di Code
("Production Deploy"), come nelle note di lavoro. Le funzioni le pubblica il
fondatore; finche' non sono pubblicate, sul telefono il Cerchio sociale dice
"Il Cerchio non risponde adesso" (ripiego dichiarato a schermo) e il premio
dell'invito resta di sessanta. Per questo le voci che si vedono sul telefono
sono APERTE IN ATTESA DI VERIFICA: si chiudono quando le avro' guardate sul
Realme con le funzioni pubblicate.

**Le funzioni e l'hosting li ha pubblicati il fondatore il 4 ottobre 2026**
coi due comandi qui sotto; verificato in sola lettura con gcloud: le sedici
porte nuove ACTIVE alle 04:52Z, e la pagina del link risponde su
`esoteric-circle.web.app/i/...`. Da li' il collaudo sul Realme, nella
sezione che segue.

## IL COLLAUDO SUL REALME, e cio' che ha trovato

Realme 767f596c, build 2296, catture in `docs/collaudo/EY/realme/` (01-18).
Visto con un telefono solo: il sigillo W9TP, il nome riservato rifiutato e
il libero accettato, "0 amici su 150 posti", il codice da inquadrare
opaco (712HS9) col conto alla rovescia dei cinque minuti, il foglio di
condivisione che parte da "Manda il link", la tendina dal tocco su
Online, l'icona cambiata e tornata dal server.

Cio' che ha trovato, ognuno col suo padre (Regola C):

- **Il tocco su "Online" non apriva la tendina** (EY.08). La barra vive
  sopra il Navigator e la tendina partiva da quel contesto: il dialogo
  moriva in silenzio. Prove e anteprime montavano la tendina da sola e non
  potevano vederlo. Curato col contesto del navigatore; la prova
  `test/la_tendina_si_apre_dalla_barra_test.dart` monta l'app intera e
  tocca la barra vera, rossa col difetto rimesso (A21).
- **"Ancora senza nome" per chi era gia' nel Cerchio** (EY.01): il nome
  si proponeva solo nell'onboarding. Adesso chi entra senza nome riceve il
  nome iniziatico dalla sua nascita.
- **I titoli troncati** ("Il tuo nome nel Cerc...", "Chiama nel tuo
  Cerc...", EY.03 ed EY.04): accorciati in "Nome nel Cerchio" e "Chiama
  nel Cerchio".
- **I due pulsanti del codice viola e a capo** (EY.04): d'oro, uno sotto
  l'altro, "Mostra il mio codice" e "Inquadra il suo codice".
- **Lo sfondo nero delle schermate del Cerchio**, visto dal fondatore
  sulle anteprime (EY.03, EY.04, EY.05, EY.13, EY.14): adesso il cielo
  cosmico dell'app sotto ogni schermata, la Scaffold trasparente.
- **I fogli neri** (EY.03, EY.04, EY.12): il foglio delle icone, la
  richiesta di legame e il regalo degli Eos, col "Fatto" viola. Adesso
  hanno il velo della tendina e i pulsanti d'oro (`fondoDelFoglio`).
- **Il prefisso `cerchio.` senza strada** (EY.01), trovato dalla suite:
  la proposta del nome e il Maestro del profilo non avevano una via ne'
  nelle memorie custodite ne' nello scarico dei tuoi dati. Dichiarati.
- **Il cancello di GitHub era rosso su analyze da prima di questo
  ordine**: era rosso anche su `784dd20b`. Padre: ordine EW voce 04, il
  banco del costo in `tool/` (un uso della porta dei banchi non
  dichiarato e un const). Riparato.

**La build consegnata.** 2296, dal commit `9ccc5ef1` col cancello di GitHub
verde (segno `refs/verde/9ccc5ef1...`), release App Distribution
`62oo5v3oerb0g` a cloud@esotericircle.app, accettata 1, registro da 2295 a
2296. Prima di caricare: prova di accensione sul Realme, archivio guardato
dentro. Il foglio delle icone col velo, visto sul telefono con questa build:
`docs/collaudo/EY/realme/19_foglio_icone_col_velo.png`. **Pronta per
Codemagic** dal ramo canonico, che e' lo stesso commit.

**Le frasi per il secondo telefono del fondatore**, una per voce:

- EY.04: dal telefono A "Mostra il mio codice", dal B "Inquadra il suo
  codice": sul B compare la richiesta col nome e l'icona di A, e il
  legame nasce solo col tocco su "Entra nel suo Cerchio".
- EY.05: sul telefono che ha mandato il link, l'amico appare arancione
  finche' l'altro non accetta, poi verde; un blocco lo toglie dagli elenchi
  senza che l'altro lo sappia.
- EY.06 ed EY.15/EY.17: il link mandato da A, aperto dal B appena
  installato e registrato: 150 Eos a tutti e due, e l'invito di A gia'
  pronto sul B; il link non porta l'uid, solo il codice dopo `/i/`.
- EY.08: con A e B amici e tutti e due nell'app, il tocco su Online mostra
  l'altro fra i presenti con cosa sta facendo.
- EY.10, EY.11, EY.12: A manda un segno, B risponde con una risposta o una
  reazione; A manda un dono; i prezzi in Eos sono quelli del listino.
- EY.13 ed EY.14: dalla scheda dell'amico, "Confronta i cieli di oggi" da
  tutti e due i lati da' lo stesso numero; il glifo ha la stessa forma sui
  due telefoni.
- EY.02: la scheda di A vista dal B non porta mai nome vero, nascita,
  luogo, email ne' foto.

## LE DECISIONI CHE RESTANO AL FONDATORE

1. **La pubblicazione delle funzioni e dell'hosting**: fatta dal fondatore il
   4 ottobre 2026, verificata ACTIVE.
2. **Sotto i quattordici anni (EY.09)**: in Italia il consenso lo presta chi
   esercita la responsabilita' genitoriale. Nessun meccanismo costruito, come
   l'ordine prescrive. La voce resta APERTA su questa decisione.
3. **Il Gift Eos (EY.12)**: costruito con la sua regola (100-500 al giorno,
   solo agli amici, solo da `borsellino.regalabili`), ma oggi nessuna porta
   accredita Eos comprati e la dote del piano "scattera' quando gli
   abbonamenti saranno acquistabili" (`borsellino.ts`): i regalabili valgono
   zero per tutti e la porta lo dice. Non ho inventato una fonte. La voce
   resta APERTA su questa decisione.
4. **L'illimitato degli amici offline (EY.07)**, riportato e non corretto: il
   listino (`amicoInPiu`, Illuminato nullo) e la matrice (`'Senza limite'`)
   dicono ancora senza limite contro la decisione del 29 agosto.
5. **I testi dei segni e delle risposte** sono segnaposto di Code: li
   riscrive l'Architetto (`lib/core/cerchio/i_segni_del_cerchio.dart`).
6. **La verifica del dominio per i link**: Android apre il link `/i/` nell'app
   senza chiedere solo con `assetlinks.json` (serve l'impronta della chiave di
   firma, che non tocco); iPhone con il file `apple-app-site-association` e la
   capacita' Associated Domains gia' nel profilo. Finche' mancano, il link
   apre la pagina del server, che ha il pulsante `esotericircle://` per chi ha
   l'app.
7. **I pulsanti degli store nella pagina del link** portano alla scheda Play
   (`com.esotericircle.esoteric_circle`) e a una ricerca nell'App Store:
   l'app non e' pubblicata, e i due indirizzi vanno confermati.

## IL COMANDO PER LA PUBBLICAZIONE

Dal worktree `C:\Users\user\Desktop\esoteric-circle-app\.claude\worktrees\esoteric-circle-v3-realignment-a88835`
(dipendenze gia' installate), al commit di consegna:

    firebase deploy --project esoteric-circle --only "functions:ilMioProfiloNelCerchio,functions:scegliIlNome,functions:aggiornaIlProfiloNelCerchio,functions:ilCodiceDellInvito,functions:leggiIlCodice,functions:chiediIlLegame,functions:rispondiAlLegame,functions:bloccaUnaPersona,functions:ilMioCerchio,functions:compraUnPostoNelCerchio,functions:laTendinaDelCerchio,functions:mandaUnSegno,functions:rispondiAlSegno,functions:mandaUnDono,functions:regalaGliEos,functions:scriviIlTokenDelCerchio,functions:paginaDellInvito,functions:chiEOnline,functions:riscattaLInvito,functions:cancellaIlCerchio,functions:azzeraIDatiDelCerchio,functions:statoDelCerchio,functions:consumaDelGiorno,functions:muoviGliEos"
    firebase deploy --project esoteric-circle --only hosting

Le funzioni gia' pubblicate restano compatibili con la build 2295: un telefono
vecchio manda `chiEOnline` senza l'arte (vale "nel Cerchio") e riscatta i
link col formato vecchio (compatibilita' dichiarata).

## LE MISURE, voce per voce

Le misure complete, la domanda e la frase di accettazione di ogni voce stanno
nel manifesto. Qui le cose che il manifesto non ha spazio per dire.

- **EY.01**: elenco offensivo iniziale **56 voci** (32 radici che cadono
  dovunque, 24 parole che cadono solo intere, perche' "nazi" sta in Ignazio e
  "negro" in Montenegro); 55 nomi veri provati, 0 caduti. Il confronto dei
  riservati: intero, per parola, con le cifre tolte; in testa o in coda solo
  per i quattro nomi propri del Cerchio (Medora, Caligo, Esoteric, Circle),
  perche' altrimenti Laura, Leos e Stafford non potrebbero chiamarsi cosi'.
  La forma ammessa accetta le lettere latine accentate. **Il nome lasciato**
  resta di chi lo lascia per novanta giorni (`nomi_lasciati`). **La Morte e il
  Diavolo** restano fuori dal nome proposto (chi li vuole li scrive).
- **EY.03**: le icone spente sono per singola icona (l'animale incontrato nel
  Viaggio, l'Arcano uscito all'Alba o in una stesa, l'archetipo che ha guidato
  il test); l'Arcano personale e' aperto dal primo giorno; i segni sono tutti
  aperti. Il server accetta qualunque icona valida: la vetrina e' del
  telefono.
- **EY.04**: la ricerca libera non esiste; "chi ha il tuo sigillo" e' un campo
  di quattro caratteri, che e' un'identita' da sapere. Il codice da inquadrare
  e' anche scrivibile a mano (fallback a gesto tattile). **L'attribuzione
  automatica dell'installazione non e' costruita**: su Android passa dal Play
  Store e l'app non e' pubblicata, su iPhone non esiste una via aperta.
- **EY.05**: chi rifiuta un invito non lo dice a nessuno: per chi ha invitato
  l'invito resta "in attesa", e un secondo invito e' chiuso trenta giorni.
- **EY.08, LE DUE MISURE DELLE LETTURE** (obbligatorie): un telefono con la
  tendina aperta che la chiede una volta al minuto per un'ora, con mille
  presenti e cento telefoni che chiedono nello stesso mezzo minuto: **841
  letture con l'istantanea, 120.000 con la via ingenua** (che legge presenze e
  profili a ogni domanda). In piu', dichiarato: la presenza (`chiEOnline`)
  adesso legge una volta il ramo `stato/identita` a ogni passo, per scrivere
  la scheda che l'istantanea legge: una lettura al minuto per telefono. Chi e'
  invisibile non compare in nessun elenco ne' nelle arti, e conta solo nel
  numero anonimo "Online".
- **EY.09**: la maggiore eta' si ricava sul telefono dalla data di nascita e
  arriva al server come vero o falso, mai come data; finche' non arriva,
  nessuno e' maggiorenne per la presenza pubblica.
- **EY.10**: i segni vanno solo agli amici (le persone simili ricevono il solo
  cenno, voce 12). **Il canale delle notifiche** e' Firebase Messaging, lo
  stesso dei Doni; sul telefono la notifica sta su un canale Android nuovo,
  "Il Cerchio", accanto a quelli dei Doni, perche' Android ordina le notifiche
  per canale. Su iPhone la notifica arriva gia' composta.
- **EY.12**: il cenno non conta nel tetto dei segni; a un presente non amico
  si manda una volta sola (`stato/cenni`), mai a un minorenne.
- **EY.13**: lo stato del giorno e' l'aspetto della Luna di oggi verso i due
  segni. La prima stesura usava l'accordo d'elemento, e la prova ha trovato
  che per due elementi opposti la media vale sempre 60: il cielo del giorno non
  contava. **"Facciamo la sinastria"** apre il confronto del cielo, che e' la
  sinastria fra due amici: la Sinastria VIP e' con i personaggi.
- **EY.15**: i chiamanti della porta della condivisione sono **25 in 21 file**,
  non dodici. Il link si aggiunge in tre vie su quattro: lo scarico dei propri
  dati resta fuori.
- **EY.16**: la porta della tendina ha 30 chiamate l'ora, la piu' stretta per
  frequenza insieme a tre porte di spesa (nome, gift, posto) che ne hanno 20
  perche' muovono denaro o identita'.
- **EY.17**: la compatibilita' col formato vecchio si potra' togliere trenta
  giorni dopo la prima build che porta il codice nuovo
  (`FINE_DELLA_COMPATIBILITA`).

## COSA HANNO TROVATO LE PROVE E LE ANTEPRIME

- **Il confronto del cielo** non cambiava col giorno per due elementi opposti
  (sopra).
- **La porta della condivisione** lasciava salire l'errore della rete fino a
  chi condivideva, e sbagliava il tipo del ripiego col tempo scaduto.
- **Le anteprime**: i pulsanti di "Ti cercano" schiacciavano il nome fino a
  "E..." e mandavano a capo "Cerchi / o"; "1 amici"; i segni a tre colonne
  spezzavano "Confrontiam / o"; i pulsanti di solo testo erano viola sul nero;
  la riga della cadenza del nome era troncata. Tutti curati e rivisti.
- **La Regola A**: tre prove la prima volta non vedevano il loro difetto
  (A10, A20) o il banco non entrava (A11): curate e confessate nel registro.

## IL CONTO DELLE GUARDIE

Sei guardie nuove, tutte nate rosse: il registro sale da 658 a **664**
(`docs/guardie.md`, categorie 147, 224 e 293). Due guardie estese invece di
scriverne di nuove: le callable (da 13 a 29, col tetto in ogni porta sociale)
e la porta unica della condivisione (P.28).
