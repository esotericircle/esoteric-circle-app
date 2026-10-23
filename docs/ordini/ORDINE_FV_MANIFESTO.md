# MANIFESTO DELL'ORDINE FV, IL CALENDARIO LUNARE PERSONALE: L'ALMANACCO DI MEDORA

Testo dell'ordine, parola per parola: `docs/ordini/ORDINE_FV_TESTO.md`. Testo dell'aggiunta: `docs/ordini/ORDINE_FV_Aggiunta_Esoteric_Circle.md` (riportato nelle voci FV.15-FV.17). Rapporto: `docs/ordini/RAPPORTO_ORDINE_FV.md`. Una voce CHIUSA porta sotto di se' DOMANDA, PROVA e MISURA; una voce aperta dice che cosa aspetta e porta le sue prove. Nessuna build in questo ordine (R3): le voci che si vedono solo sul telefono, o che aspettano una pubblicazione sul server, restano aperte.

VOCI_TOTALI: 17
VOCI_CHIUSE: 14
VOCI_APERTE: 3
VOCI_DA_FARE: 0

## VOCE FV.01

**CHIUSA.** I sette file di P1 e i 25 pezzi di P2 nel ramo: le immagini convertite in webp mantenendo la trasparenza (alfa identico sui PNG, 0 pixel cambiati), il video ricompresso (voce FV.02) in `brand_assets/calendario_lunare/`, dichiarati in `pubspec.yaml` e in `docs/stato_asset.json`. Nessun asset rigenerato o ritoccato. La tavola chiara `card_mese_sfondo_v1.png` (consegnata in piu') lasciata fuori: il fondatore aveva scartato il bianco ("Ma perché la tavola è bianca?"), e il JPG notturno e' quello nel ramo. Le tre luci di P2 si posano in fusione schermo senza riquadro visibile sullo sfondo della scena.

DOMANDA: "Va bene Salva" sul video e sugli asset della scena; "Approvo cominciamo" sull'elenco; "Ma perché la tavola è bianca? Ok il bianco e il tondo della luna, ma la luna risplende di notte"
PROVA: docs/collaudo/FV/fv01_asset.txt
MISURA: sei file di P1 da 639.812 a 668.332 byte -> da 74.096 a 169.148 byte WebP; 25 pezzi di P2 da 66.036 a 519.291 byte sorgente, alfa identico sui 13 PNG con trasparenza (57.497 o 172.544 pixel trasparenti, 0 cambiati); card_mese_sfondo_v1.png scartata, scarto medio dal JPG 150,04 su 255, colore medio PNG (206,204,198) contro JPG (50,58,77); le tre luci in fusione schermo, scarto sul bordo del riquadro 0,000-0,152 su 255, canale piu' alto del bordo al massimo 3 su 255 (docs/collaudo/FV/fv01_luci_in_fusione_schermo.png)

## VOCE FV.02

**APERTA IN ATTESA DI VERIFICA.** La scena dell'Almanacco di Luce: il video parte all'apertura, una volta per apertura, dal lettore e dalla regia comuni (P6); si ferma sull'ultimo fotogramma, che resta come sfondo fisso con sopra, in dissolvenza, il mese di trenta lune (FV.05) posato sul velo misurato. Il tocco che salta il video passa dal punto unico di P6. Ripieghi con Riduci Movimento, grafica alleggerita e video che non si carica; audio come nella Stesa.

ASPETTA: il fondatore, alla prossima build che ordinera': aprire il Calendario Lunare sul telefono, guardare l'Almanacco aprirsi e la luce salire nel velo, il mese comparire in dissolvenza sull'ultimo fotogramma. Il filmato vero non si cattura in una prova headless.
DOMANDA: "parte all'apertura della funzionalità e basta"; "No, si ripete sempre il video, ma si può sfumare saltare con un click"
PROVA: test/il_calendario_lunare_a_video_test.dart
MISURA: video ricompresso da 7.761.187 a 3.557.679 byte (7,76 a 3,56 MB), SHA-256 585ac4b3...450; fotogramma a 4 secondi, scarto medio 2,07 su 255; ultimo fotogramma contro lunario_ultimo_fotogramma_v1.jpg, scarto 9,35 su 255 ricompresso contro 9,49 d'origine (docs/collaudo/FV/fv02_ultimo_fotogramma_dopo.png); velo rimisurato Rect.fromLTRB(239, 307, 837, 1087), dal 22,1 al 77,5 per cento della larghezza, dal 16,0 al 56,6 per cento dell'altezza (l'Architetto: dal 21 al 78, dal 19 al 64; docs/collaudo/FV/fv02_il_velo_misurato.png); due prove a video verdi (il video parte e il tocco lo salta, il ripiego senza video), la terza (il video vero sul telefono) resta aperta

## VOCE FV.03

**CHIUSA.** Ogni giorno del mese mostra la Luna vera di quel giorno: una fotografia della serie "Moon Phase and Libration, 2026" dello Scientific Visualization Studio della NASA (svs.gsfc.nasa.gov/5587/), trenta immagini per una lunazione intera (dall'11 ottobre all'8 novembre 2026), scontornate su fondo trasparente, in `assets/img/calendario_lunare/lune/`. Il giorno prende l'immagine con l'elongazione piu' vicina a quella calcolata dal motore a mezzogiorno locale. Per l'emisfero sud l'immagine ruota di 180 gradi, verificato su due fonti di divulgazione astronomica. Attribuzione in `fonti_dei_dati.dart`, nessun logo, nessuna sponsorizzazione, la NASA mai nominata nei testi di Medora: le linee guida NASA rilette il 15 ottobre 2026 punto per punto.

DOMANDA: "A, foto vere della Luna"
PROVA: docs/collaudo/FV/fv03_lune.txt
MISURA: trenta immagini, indirizzo e SHA-256 di ogni fotogramma d'origine dichiarati; scarto peggiore fra la frazione accesa misurata nel disco e la fase pubblicata da mooninfo 1,62 punti percentuali; pixel accesi fuori dal disco previsto al massimo 121 su un raggio di circa 320-340 pixel; pixel fuori dal disco con alfa diversa da 0 dopo lo scontorno: 0 su tutti i trenta; linee guida NASA verificate punto per punto, 0 occorrenze di "nasa" fuori dai commenti di codice e da fonti_dei_dati.dart (docs/collaudo/FV/fv03_linee_guida_nasa.txt)

## VOCE FV.04

**CHIUSA.** Un punto solo (`IlMotoreLunare`) calcola per ogni giorno, nell'ora locale: fase ed elongazione, segno della Luna e ora del cambio, la Luna fuori corso (dall'ultimo aspetto maggiore a un pianeta classico fino all'ingresso nel segno successivo), il giorno lunare, il tipo di giorno biodinamico secondo il metodo di Maria Thun sui confini IAU veri delle costellazioni (Delporte 1930/Roman 1987, VizieR VI/42), proiettati sull'eclittica J2000 con la precessione rigorosa di Meeus; l'Ofiuco resta senza tipo, non documentato. Usa solo `lib/core/astro/meeus/`, nessun secondo motore.

DOMANDA: "la Luna fuori corso, cioè l'intervallo dall'ultimo aspetto maggiore della Luna a un pianeta fino al suo ingresso nel segno successivo"
PROVA: test/il_motore_lunare_contro_le_effemeridi_test.dart
MISURA: la Luna fuori corso contro Moon Tracks, 27 intervalli di ottobre-novembre 2026, scarto massimo inizio 0,92 minuti, fine 0,87 minuti; contro Swiss Ephemeris, 163 intervalli su tutto il 2026, scarto massimo inizio 14,3 secondi, fine 13,1 secondi; la Luna in J2000 contro Swiss Ephemeris, scarto massimo 6,9 secondi d'arco su 24 istanti; tredici confini IAU delle costellazioni, citati con la fonte; tempo di calcolo un mese 145 ms, dodici mesi 1.462 ms; corretto nella Regola A un difetto vero: il bersaglio della bisezione degli ingressi nei segni era mezzo grado oltre il vero confine (`s2 * 30.0 + 0.5` invece di `s2 * 30.0`), uno scarto sistematico di circa 50 minuti

## VOCE FV.05

**CHIUSA.** La griglia del mese: sette colonne, la settimana dal lunedi', nomi italiani. Ogni giorno e' la sua Luna vera (FV.03) nel castone, col numero. All'apertura le lune si accendono a cascata dalla Luna nuova alla piena; con Riduci Movimento, tutte insieme in dissolvenza. Il giorno di oggi si riconosce (alone d'oro). Sotto ogni Luna, piccoli, i sigilli quando servono (Luna fuori corso, tipo biodinamico per orto e piante). Il tocco apre il foglio del giorno nel formato del responso, con "Da dove viene" in fondo.

DOMANDA: "Il mese di trenta lune"
PROVA: test/il_calendario_lunare_a_video_test.dart
MISURA: sette colonne dal lunedi' verificate sul primo ottobre 2026 (giovedi' vero); cascata e dissolvenza con Riduci Movimento, due prove verdi; il foglio del giorno dice fase, segno e cambio, fuori corso, giorno lunare, tipo biodinamico e "Da dove viene", una prova verde con le stringhe vere lette dal `RichText`; anteprima `docs/preview/FV/fv_lunario_1_mese_e_giorni_tuoi_dopo.png` guardata: la griglia corretta, oggi col suo alone, i sigilli visibili sotto le lune

## VOCE FV.06

**CHIUSA.** Sopra il mese, la fila degli undici emblemi dipinti di P2, ognuno con le sue attivita' (27 in tutto). Il tocco su un'attivita' accende d'oro i giorni buoni (scia d'oro, poi aloni) e spegne quelli da evitare (opacita'); con Riduci Movimento niente scia, gli aloni in dissolvenza. Ogni giorno d'oro mostra al tocco il suo perche'. Il corpus delle regole lunari, scritto da Code con la fonte di ciascuna (il Barbanera dal 1762, Maria Thun per orto e piante, l'astrologia elettiva classica per amore, inizi e viaggi), nessuna attivita' di salute o di soldi.

DOMANDA: "Non ci sono altre cose da fare oltre semina, taglio, ecc?"; "Approvo" sulle undici categorie
PROVA: test/il_corpus_del_lunario_test.dart
MISURA: 27 attivita' in undici categorie, tutte con almeno una regola con fonte vera; 13 fonti, 36 regole generate, 0 difetti al controllo; il Dart generato uguale alla fonte riletta; esiti deterministici verificati (Luna crescente accende il taglio per farli crescere, le ore fuori corso tolgono l'oro a inizi e viaggi anche con pesi positivi); anteprima `docs/preview/FV/fv_lunario_2_trova_il_giorno_aloni_dopo.png` guardata: Orto e Semina scelti, i giorni 12 e 20 accesi d'oro con l'alone, il 5 e il 28 spenti

## VOCE FV.07

**CHIUSA.** Sul mese compaiono quattro segni che solo la persona vede, coi sigilli d'oro di P2: il ritorno della Luna di nascita, la Luna sul Sole, la Luna nel segno solare, il ritorno della fase di nascita (contenuto simbolico, nessun calcolo di fertilita'). Senza l'ora di nascita i due che dipendono dalla Luna di nascita tacciono, con l'invito a inserirla.

DOMANDA: "I giorni tuoi"
PROVA: test/i_giorni_tuoi_test.dart
MISURA: col l'ora nota, il ritorno della Luna e la Luna sul Sole compaiono circa una volta per mese siderale, la Luna nel segno per due o tre giorni, il ritorno della fase circa una volta per mese sinodico, ogni segno con titolo e testo non vuoti; senza l'ora, il ritorno della Luna e la fase di nascita non compaiono mai, la Luna sul Sole e nel segno continuano; nessun testo di fertilita' o concepimento; calcolato solo su `IlCieloDiMeeus`, nessun secondo motore; anteprima guardata, i sigilli visibili sotto le lune del 3, 7, 8 e 22 ottobre

## VOCE FV.08

**CHIUSA.** Su un giorno d'oro la persona fissa la sua attivita' con un tocco. Il giorno prima, alle 20, arriva l'avviso del telefono nella voce di Medora. Passa dal punto degli avvisi che l'app usa gia' (P8) e dalla richiesta del permesso gia' in uso. Senza permesso il promemoria resta segnato sul mese e l'app lo dice. Le attivita' fissate si vedono con l'emblema piccolo della categoria; si tolgono con un tocco.

DOMANDA: "Il promemoria senza fatica"
PROVA: test/il_calendario_lunare_a_video_test.dart
MISURA: il promemoria si fissa con un tocco, programma l'avviso alle 20 del giorno prima, si vede sul mese con l'emblema piccolo, si toglie con un tocco (una prova verde, i tre gesti letti dal servizio finto); senza permesso il segno resta sul mese e l'app lo dice, senza vicoli ciechi (una prova verde); rossa nella Regola A mostrando il pulsante solo sui giorni da evitare invece che su quelli d'oro (docs/collaudo/FV/fv0508_regola_a.txt)

## VOCE FV.09

**CHIUSA.** Sul giorno della Luna nuova compare il seme di luce. Chi vuole scrive la sua intenzione in una riga; alla Luna piena Medora gliela ricorda con un avviso. Nessun'altra tappa, nessun obbligo. L'intenzione e' privata: non va sulla card (guardia di FV.11) e non va al Cerchio; classificata memoria del solo telefono (`lunario.` in `LeMemorieCustodite.delTelefono`) e aggiunta allo scarico dei dati.

DOMANDA: "non mi piace la cosa dell'intenzione, lo trovo impegnativo, ma lasciamolo per ora"; "leggerissima"
PROVA: test/il_calendario_lunare_a_video_test.dart
MISURA: il seme di luce compare sulla Luna nuova, l'intenzione si scrive in una riga, l'avviso e' programmato alla Luna piena, l'intenzione non entra nel testo del promemoria (una prova verde); `lunario.` classificato `delTelefono` in `le_memorie_custodite.dart` e aggiunto a `scarico_dei_tuoi_dati.dart` (export e cancellazione coerenti, per la regola di casa BC.02)

## VOCE FV.10

**APERTA IN ATTESA DI VERIFICA.** La persona sceglie uno o piu' amici del Cerchio e un'attivita' (le undici categorie di FV.06); il calendario accende i giorni buoni per tutti, piu' i giorni tuoi di chi ha dato la sua nascita col consenso esplicito (gesto di P7, scopo `lunario`, mai nel profilo pubblico). La proposta si manda e gli amici rispondono si', no o un altro giorno d'oro, con le porte nuove `proponiGiornoInsieme` e `rispondiAlGiorno` in `il_cerchio_sociale.ts`, scritte e provate, non pubblicate. Un amico fuori dal Cerchio riceve l'invito dalla pagina che l'app usa gia' (`ScegliDallaRubricaScreen`).

ASPETTA: `proponiGiornoInsieme` e `rispondiAlGiorno` pubblicate dal fondatore (comando in fondo al rapporto); poi la prossima build, per guardare la proposta arrivare su due telefoni veri.
DOMANDA: "Come renderla social e virale? Perché la persona dovrebbe coinvolgere i propri amici?"
PROVA: test/il_lunario_sociale_e_piani_test.dart
MISURA: il consenso per "Trova il giorno insieme" porta lo scopo `lunario` e sei campi (nascita, giorno, oraNota, nome, scopo, minutoLocale), passa solo col codice; il Viandante e l'Iniziato vedono il lucchetto con l'invito alla proposta a Eos, l'Adepto apre senza lucchetto; 253 prove su 253 verdi lato server (`il_cerchio_sociale.test.js`, `sociale.test.js`); "cena" non e' entrata come attivita' nuova per non toccare in parallelo il contratto condiviso con la voce FV.06, le undici categorie esistenti (viaggio e trasloco inclusi) bastano

## VOCE FV.11

**CHIUSA.** La card del mese usa `card_mese_sfondo_v1`, formato unico verticale (768x1376). Nel campo centrale (rimisurato: dal 13,2 all'86,8 per cento della larghezza, dal 24,2 al 79,8 dell'altezza) le trenta lune vere del mese e, se scelta, i giorni d'oro dell'attivita'. In alto il titolo del mese; in basso il sigillo di Medora, il logo e il collegamento diretto. Mai dati di nascita: niente giorni tuoi, niente intenzione, per costruzione (la classe non ha il campo).

DOMANDA: "la luna risplende di notte" (sullo sfondo, la stessa scelta di FV.01)
PROVA: test/la_card_del_mese_test.dart
MISURA: campo centrale Rect.fromLTRB(101,333,667,1098) su 768x1376, dal 13,2 all'86,8 per cento della larghezza, dal 24,2 al 79,8 dell'altezza (l'Architetto: 13-87, 24-80); nessun riferimento a `SegnoDelGiornoTuo`, `TipoDelGiornoTuo` o "intenzione" nel codice (0 trovati, scansione del sorgente senza i commenti); anteprima `docs/preview/FV/fv_lunario_4_la_card_del_mese_dopo.png` guardata: titolo, lune, due giorni d'oro, firma di Medora e del Cerchio leggibili. **Difetto vero trovato dalle anteprime** (R10): nessuna prova aveva mai montato la card, e la fascia della firma traboccava di 11-17 pixel secondo la larghezza; corretto con un `FittedBox` prima di scrivere la guardia, vista rossa due volte (il trabocco rimesso, una parola vietata di FV.07 nel codice; docs/collaudo/FV/fv11_la_card_del_mese_regola_a.txt)

## VOCE FV.12

**APERTA IN ATTESA DI VERIFICA.** Viandante: il mese in corso, i giorni tuoi, "Trova il giorno" su una categoria (dieci col lucchetto). Iniziato: tutte le undici categorie, i promemoria, il mese successivo. Adepto e Illuminato: dodici mesi avanti, "Trova il giorno insieme". Con gli Eos: un mese extra (60 Eos) o una proposta insieme (50 Eos), mai una chiamata al modello. Quattro righe nuove in `PlanCatalog.matrix` e una in ogni descrizione di piano; il listino del server (`compraUnMeseDelLunario`, `compraUnaPropostaInsiemeDelLunario`) scritto e provato, non pubblicato.

ASPETTA: `compraUnMeseDelLunario` e `compraUnaPropostaInsiemeDelLunario` pubblicate dal fondatore (comando in fondo al rapporto); poi la prossima build, per guardare i lucchetti e gli acquisti veri sul telefono.
DOMANDA: "Piani ed Eos (proposta)"
PROVA: test/il_lunario_sociale_e_piani_test.dart
MISURA: Viandante con dieci categorie su undici bloccate, Iniziato con le undici aperte; Viandante e Iniziato vedono il mese in corso o il mese dopo con l'invito a Eos, l'Adepto scorre dodici mesi senza lucchetto; `trovaInsiemeAperto` falso su free e tier1, vero su tier2 e tier3; `meseExtraDelLunario` 60 Eos (fra `confrontoDelCieloInPiu` 30 e `amicoInPiu` 100), `propostaInsiemeDelLunario` 50 Eos; `PlanCatalog.matrix.length` da 58 a 62, un `highlights` in piu' per ognuno dei quattro piani (test/entitlement_test.dart); nessuna chiamata al modello nell'acquisto (R2)

## VOCE FV.13

**CHIUSA.** Il Calendario Lunare esce dal Coming soon: `art_catalog.dart` porta `lunar_calendar` come `ArtState.attiva` e `ArtPhase.mvp`, col teaser riscritto per dire il vero di cio' che la funzione fa oggi. Resta nel dominio di Medora (sezione Lunologia) e nella riga della home dove gia' stava, con lo sfondo Calendario-Lunare.

DOMANDA: "In aggiunta. Iniziamo con il calendario lunare"
PROVA: test/art_catalog_test.dart
MISURA: `lunar_calendar` `ArtState.attiva`, `ArtPhase.mvp`, teaser di 105 caratteri ("Il mese di trenta lune vere: scegli cosa vuoi fare e i giorni giusti si accendono d'oro, col loro perché."); 10 guardie di casa che scattano su ogni arte nuova estese (scaffale, fila, fonti, cammino, soglia unica, accenti, segno con una porta sola, descrizioni con una misura sola, memorie e scarico dei dati), tutte verdi; 4 anteprime guardate: la schermata vera, titolo "Calendario Lunare" in alto, nessun grigio ne' badge Coming soon

## VOCE FV.14

**CHIUSA.** Manifesto con la sua guardia, rapporto, STATO_VIVO e registro delle guardie aggiornati. Anteprime a 360 per 797, densita' 3, in `docs/preview/FV/`, guardate una per una: il mese di trenta lune e i giorni tuoi, "Trova il giorno" con gli aloni, il foglio del giorno, la card del mese. In locale sono girate solo le prove delle voci e le guardie della zona toccata; la suite intera la fa il cancello di GitHub a ogni push. Nessuna build.

DOMANDA: "L'ordine si consegna solo col verde di GitHub sul commit consegnato. Nessun rosso si consegna."
PROVA: docs/ordini/RAPPORTO_ORDINE_FV.md
MISURA: quattro anteprime guardate, un difetto vero trovato guardandole (la card del mese traboccava, corretto prima della consegna); nove guardie nuove di quest'ordine, tutte viste rosse (il registro da 783 a 792); il primo giro del cancello sul commit 7398994b e' stato rosso, coi rossi letti dalle annotazioni, rifatti in locale e corretti (vedi il rapporto); il verde di GitHub sul commit consegnato e' scritto nel rapporto

## VOCE FV.15

**CHIUSA.** (Ordine FV aggiunta, voce FVA.01.) L'Oracolo degli Angeli risponde alle domande delicate come le chat dei Maestri, non con la cura: tolti `la_domanda_delicata.dart`, la risposta di cura, il 112, ogni invito a chiamare qualcuno, la riga dedicata nell'istruzione. Al suo posto, `MaestroPersona.temaDelicato` e `ConfineDelResponso.perIlModello`, le stesse porte delle chat. Ogni domanda, anche sensibile, estrae le tre carte come tutte le altre.

DOMANDA: "elimina tutta la parte e ciò che riguarda alle domande sensibili, non lo abbiamo fatto per le altre funzionalità e non vedo perché dobbiamo farlo adesso [...] Il consiglio di chiamare qualcuno sarebbe già una presa di posizione"
PROVA: test/l_oracolo_degli_angeli_test.dart
MISURA: nessun numero e nessun invito a chiamare qualcuno in nessun testo dell'Oracolo, del corpus o dell'istruzione (scansione di tutti i file di `lib/core/oracolo_angeli/` e `lib/features/angels/oracolo/`, 0 trovati); sei righe del corpus corrette, che invitavano a chiamare una persona; istruzione dell'Oracolo: 2.812 caratteri prima (circa 804 token), 3.406 dopo (circa 974 token); stima aggiornata al piu' 0,0002 euro la Breve e 0,0003 la Lunga (la differenza di 170 token in ingresso sposta il costo di meno di 0,00002 euro, sotto la cifra significativa del listino); guardia della cura tolta con la lapide nel registro

## VOCE FV.16

**CHIUSA.** (Ordine FV aggiunta, voce FVA.02.) La prima esecuzione vera del modello dell'Oracolo, col si' del fondatore sulla stima del rapporto FU: venti consultazioni, dieci Brevi e dieci Lunghe, nessuna delicata, con un banco nuovo (`il_banco_dell_oracolo_degli_angeli`, in `tool/banchi_col_modello/`) che chiama Gemini 2.5 Flash-Lite via REST per contare i token senza Cloud Monitoring.

DOMANDA: "ok per la prova del modello a pagamento", sulla stima del rapporto FU (venti consultazioni, al massimo 0,005 euro)
PROVA: docs/collaudo/FV/fva02_venti_consultazioni.txt
MISURA: venti consultazioni vere, costo reale 0,003418 dollari contro la stima di 0,005 euro al massimo; risposta dal modello in 14 su 20 (70%); nelle altre sei ha parlato il corpus, come vuole la casa: quattro per il riquadro sopra il tetto di 420 caratteri (421 a 554), una per l'approfondimento2 sopra tetto (447), una per la parola vietata "guari" su "guarire" in senso non sanitario. La voce FU.04 (il modello dell'Oracolo) resta aperta col difetto e il suo padre (ordine FU voce FU.04, il tetto dei caratteri e il filtro, mai provati prima con risposte vere), come vuole la regola della chiusura quando il formato non regge

## VOCE FV.17

**CHIUSA.** (Ordine FV aggiunta, voce FVA.03.) Le altre risposte del fondatore sul rapporto FU, registrate: la pubblicazione delle funzioni la fa lui, Code non pubblica niente (punto 1); lo sfondo della Sinastria VIP scorre con le carte, resta com'e' (punto 4); gli altri video (intro, rivelazione del Maestro, velo dell'onboarding) non si toccano, gia' ok cosi' (punto 5).

DOMANDA: "deploy dopo"; "lo sfondo scorre con le carte"; "non toccarli perché sono già ok così. La Intro, tra l'altro ha già il click per skippare"
PROVA: docs/STATO_VIVO.md
MISURA: 3 risposte scritte in STATO_VIVO (sezione dell'ordine FU) e in 1 riga "**Aggiunta del" nel rapporto FU, in coda, secondo la regola dei rapporti consegnati; 0 file di codice toccati da questa voce
