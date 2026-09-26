# ORDINE EO, LA NUOVA HOME A SCHEDE, I DOMINI RIORDINATI E IL LIVE PIÙ PRONTO

**Sigla:** EO, riverificata sul ramo il 26 settembre 2026 prima di
cominciare: in `docs/ordini` l'ultimo ordine era EN, nessun `ORDINE_EO_*`.
**Data dell'ordine:** 26 settembre 2026.
**Ramo:** `claude/esoteric-circle-master-order-e798aj`.

**Le consegne del fondatore, in coda all'ordine**: *"Procedi Senza
fermarti, se hai domande, usa le risposte consigliate. Fai tutti i test su
Cell e controlla che tutto funzioni anche su iPhone. Alla fine, quando sei
sicuro che è tutto ok, consegna nuova build. Poi deciderò se consegnare
anche su Apple App distribution"* e *"Non consegnare la versione
iPhone,.prima devo controllare io"*.

**E una voce nata a ordine aperto**, dal fondatore lo stesso giorno: la
EO.17, nessun doppione in vista nella home.

VOCI_TOTALI: 17
VOCI_CHIUSE: 17
VOCI_APERTE: 0

Le prove stanno in `docs/collaudo/EO/`; quelle viste sul telefono di prova
(Realme 767f596c, build 0.1.0+2283) in `docs/collaudo/EO/realme/`.

---

## UNA COSA DA SAPERE PRIMA DI LEGGERE LE VOCI: IL REALME HA LE ANIMAZIONI A ZERO

Sul Realme del collaudo le tre scale delle animazioni sono a zero, e Flutter
lo legge come **riduzione del movimento**. L'ordine spegne con la riduzione
del movimento solo il riflesso (EO.06) e il sollevamento (EO.07): **sul
Realme quei due effetti sono spenti, come l'ordine vuole**, e si vedono su un
telefono con le animazioni accese, per esempio l'iPhone. Il tocco (EO.03) e
il giro (EO.04, EO.05) l'ordine non li esenta: si animano anche con le scale
a zero, e non si accorciano (`AnimationBehavior.preserve`, come per i riti).
Per misurare il riflesso sul Realme si e' costruita una build di misura che
lo accende a forza (`--dart-define=EO_LUCE_FORZATA=true`), mai consegnata.

---

## VOCE EO.01, GLI SFONDI DELLE SCHEDE NELL'APP

I 99 WebP stanno in `assets/schede/`, registrati in `pubspec.yaml` e nel
manifesto degli asset (`docs/stato_asset.json`); le immagini di lavorazione
restano fuori dal repository. Ogni arte e' legata al suo file per
identificativo del catalogo in `lib/core/arts/gli_sfondi_delle_schede.dart`,
con i tre sfondi dei Maestri per la riga "In arrivo". La guardia
`gli_sfondi_delle_schede_test.dart` conta i file, dichiara il cardinale e
pretende la registrazione.

**Due difetti di questa voce, trovati dalla suite intera e riparati**: la
cartella nuova non era nel manifesto degli asset (`stato_asset_test` rossa
sul ramo spinto) e la guardia degli sfondi scorreva una cartella senza
dichiarare il cardinale (`ogni_guardia_dichiara_quanto_guarda` rossa).

**CHIUSA.**
DOMANDA: "Allora, iniziamo a fare tutte le schede dell'ultimo elenco, 10 per ogni maestro. Poi deciderò quali inserire in MVP."
PROVA: docs/collaudo/EO/realme/eo10_eo13_dominio_medora.png
MISURA: WebP delle schede nel repository e registrati, da 0 a 99; sul Realme gli sfondi a video in home e nei tre domini, 30 arti su 30 col loro file

## VOCE EO.02, COM'È FATTA UNA SCHEDA

Una sola scheda per tutta l'app, `lib/features/schede/la_scheda_dell_arte.dart`:
l'immagine del suo formato senza testo sopra, il titolo del catalogo sotto,
allineato a sinistra, su al massimo due righe e mai rimpicciolito (le righe
decise del Viaggio dello Sciamano restano le sue), la "i" dorata in alto a
destra, la clessidra in alto a sinistra sulle arti in arrivo, il lucchetto
sulle Premium. La larghezza della scheda viene dalla parola piu' lunga del
catalogo col carattere vero, cosi' nessuna parola si spezza. Le etichette
brevi dello scaffale di prima ("Tarocchi", "Oroscopo") sono uscite: esistevano
perche' la bolla rimpiccioliva i nomi lunghi, e la scheda non lo fa.

**CHIUSA.**
DOMANDA: "Si. Ma preferirei allineamento a sinistra"
PROVA: docs/collaudo/EO/eo02_09_guardia_verde.txt
MISURA: titoli rimpiccioliti in home da 1 (Oroscopo Personalizzato nella bolla dello scaffale di prima, ordine BK) a 0 su 56 schede; su una riga 45, su due righe 9, righe decise 2, oltre due righe 0; a testo 1,3: 46, 8, 2, 0 e 0 rimpiccioliti

## VOCE EO.03, IL TOCCO SULLA SCHEDA

La scheda si abbassa, poi si ingrandisce e svanisce sopra l'arte che intanto
si apre sotto; in tutto circa tre decimi di secondo.

**Difetto trovato sul telefono e riparato**: la scheda che svaniva si fermava
a meta', semitrasparente, sopra l'arte appena aperta. L'uscita si animava col
ticchettio della scheda, e la home coperta dalla nuova schermata ammutolisce
i suoi ticchettii; sul Realme la transizione di pagina e' venti volte piu'
corta e la copertura e' immediata. Adesso l'uscita vive nell'overlay della
radice col suo controllore. La prova nuova apre un'arte vera con le
animazioni a zero, ed e' caduta sul codice di prima (scheda ancora a video
dopo 1,5 secondi).

**CHIUSA.**
DOMANDA: "Al tocco la scheda si allarga, ma non diventa lo sfondo della funzionalità bensì si ingrandisce e con dissolvenza svanisce per far vedere sotto la funzionalità pronta. Deve essere una transizione veloce."
PROVA: docs/collaudo/EO/realme/eo03_tocco_oroscopo_registro_e_fotogrammi.txt
MISURA: sul Realme, dal tocco alla fine dell'uscita 317 ms, fotogrammi persi 0 su 101 della superficie dell'app; scheda rimasta sopra l'arte da 1 (prima build di prova) a 0; nelle prove 310 ms, anche con le animazioni a zero

## VOCE EO.04, LA "i" GIRA LA SCHEDA

La "i" gira la scheda in tre dimensioni e sul retro mostra le informazioni;
lo stesso angolo in alto a destra la rigira; sul retro un tocco fuori
dall'angolo entra nell'arte con la transizione della EO.03. L'area della "i"
e' di 48 punti. **Difetto mio trovato prima della prova e riparato**: girata
di mezzo giro la pila e' specchiata, e l'area della "i" sul retro finiva a
sinistra; adesso si specchia anche lei.

**CHIUSA.**
DOMANDA: "premendo su "i" la scheda flippa e dietro ci sono le info della funzionalità. All'altro click in alto a destra torna indietro."
PROVA: docs/collaudo/EO/realme/eo04_la_i_gira_rigira_e_dal_retro_entra.png
MISURA: sul Realme, Estrazione Rune: il tocco sulla "i" gira, lo stesso angolo rigira, dal retro il tocco fuori dall'angolo entra, 3 su 3; area della "i" 48 punti (la guardia pretende almeno 48, vista rossa a 30)

## VOCE EO.05, LE ARTI IN ARRIVO

Le arti in arrivo portano la clessidra; al tocco la scheda si gira da sola e
mostra le informazioni e la fase ("In arrivo, Fase 2"); nessuna pagina si
apre. Alla persona, fuori dalla Demo, si dice solo "In arrivo", come diceva
la card di prima.

**CHIUSA.**
DOMANDA: "Ok per clessidra e tuoi suggerimenti"
PROVA: docs/collaudo/EO/realme/eo05_in_arrivo_si_gira_e_si_rigira.png
MISURA: sul Realme, Invocazione del Giorno: al tocco la scheda si gira e dice "In arrivo, Fase 2", pagine aperte 0; l'angolo la rigira; nelle prove la guardia e' caduta innestando un'apertura al posto del giro

## VOCE EO.06, IL RIFLESSO DELL'ORO

Una banda di luce scorre sulle schede con l'inclinazione del telefono, letta
dalla porta del sensore che c'e' gia' (la parallasse del cielo); senza
sensore segue lo scorrimento della riga; si spegne con la riduzione del
movimento. **Difetto della prima stesura, riparato**: la luce apriva una
seconda iscrizione all'accelerometro, e la regola della casa ne vuole una
sola (`scena_unica_test`, `lo_scuotimento_ha_una_porta_sola_test`).

La misura dei fotogrammi e' fatta. Resta aperta per una decisione del
fondatore: **sul suo Realme il riflesso non si vede**, perche' le animazioni
a zero valgono come riduzione del movimento. Si vede su un telefono con le
animazioni accese (l'iPhone) e nella build di misura.

Misura dell'ordine EO: fotogrammi al secondo mentre si scorre la home, 59,7
senza riflesso (664 in 11,1 secondi, 0 persi) e 59,7 col riflesso acceso a
forza (656 in 11,0 secondi, 0 persi), prova
`docs/collaudo/EO/realme/eo06_fotogrammi_con_e_senza_riflesso.txt`. **La
domanda l'ha chiusa il fondatore con l'ordine EP, voce EP.09**: la luce resta
accesa anche con le animazioni a zero.

**CHIUSA.**
DOMANDA: "Luce sempre accesa" ("Il riflesso d'oro e la scheda che si solleva restano accesi anche se le animazioni del telefono sono a zero")
PROVA: docs/collaudo/EP/ep09_fotogrammi_luce_accesa_animazioni_a_zero.txt
MISURA: sul Realme con le animazioni a zero riflesso da spento ad acceso; fotogrammi scorrendo la home 59,3 al secondo col riflesso acceso (733 in 12,35 secondi, 0 persi), contro 59,7 senza

## VOCE EO.07, LA SCHEDA AL CENTRO SI SOLLEVA

In ogni riga la scheda al centro si ingrandisce appena (fino a 1,05) e prende
luce, le altre restano un poco in ombra; si spegne con la riduzione del
movimento. **Difetto trovato sul telefono con la build di misura, riparato**:
l'ombra copriva tutto il riquadro della scheda, titolo e aria sotto compresi,
e si vedeva un rettangolo scuro; adesso copre la sola immagine.

Nelle prove la scheda al centro a 1,03 con ombra 0,13, le laterali a 1,00
con ombra 0,32; vista nella build di misura dell'ordine EO
(`docs/collaudo/EO/realme/eo06_eo07_luce_forzata_riparata.png`). **Chiusa
dal fondatore con l'ordine EP, voce EP.09.**

**CHIUSA.**
DOMANDA: "Luce sempre accesa" ("Il riflesso d'oro e la scheda che si solleva restano accesi anche se le animazioni del telefono sono a zero")
PROVA: docs/collaudo/EP/realme/ep09_scheda_al_centro_sollevata_con_le_animazioni_a_zero.png
MISURA: sul Realme con le animazioni a zero la scheda al centro da ferma a sollevata e in luce, le laterali in ombra; nelle prove la scheda al centro a 1,03 con ombra 0,13, le laterali a 1,00 con ombra 0,32, anche con la riduzione del movimento

## VOCE EO.08, IL PULSANTE PER LA CHAT SOTTO "ENTRA NEL DOMINIO"

"Consulta [Nome]" apre la chat del Maestro davanti e cambia con lui; il
tocco sul Maestro apre ancora il dominio.

**Lo spazio sotto l'ho misurato, e sul formato del telefono del fondatore non
c'e'.** Il blocco d'ingresso cresce verso l'alto: col pulsante sotto, la
suite intera ha visto il busto centrale scendere da oltre 260 a 245 punti
(`i_maestri_si_sovrappongono`, che pretende i 260 chiesti dal fondatore) e i
tre Maestri dal 30 al 28 per cento della prima schermata
(`i_tre_maestri_dominano_la_home`). Il registro dei rossi accettati vale solo
per rossi che il fondatore ha accettato, quindi la scelta e' stata questa:
**sotto dove sotto il busto non perde niente, accanto a "Entra" in tondo dove
sotto costerebbe punti ai Maestri**, con la stessa etichetta per chi legge
con la voce. La decisione la prende la scena dalle sue misure. Sonda: accanto
fino a 430 per 932 punti, sotto a 480 per 1067.

Sul Realme "Consulta" sta accanto, in tondo, e apre la chat di Medora
(`docs/collaudo/EO/realme/eo08_eo16_consulta_apre_la_chat_dal_vivo_accanto_ai_contatori.png`).
**Chiusa dal fondatore con l'ordine EP, voce EP.10**: accanto, come adesso.

**CHIUSA.**
DOMANDA: "Per ora lascia il pulsante pillola chat a fianco a "entra nel dominio" in home sotto ogni maestro."
PROVA: docs/collaudo/EP/realme/ep10_consulta_accanto_a_entra.png
MISURA: "Consulta" accanto a "Entra nel Dominio" in tondo sul Realme; i Maestri alle misure chieste, busto centrale oltre 260 punti e tre Maestri al 30 per cento della prima schermata

## VOCE EO.09, LE RIGHE DELLA HOME

Dieci righe al posto dello scaffale e della striscia, nell'ordine e coi
formati del fondatore, in `lib/features/santuario/le_righe_della_casa.dart`;
la prima e' "Le arti preferite", quadrata, col seme dell'ordine e con la
matita e la pressione lunga di prima. Il titolo "Conosci te stesso" segue la
marca del genere della casa: "te stessa" al femminile. Dalla EO.17 i doppioni
in vista vanno in fondo alla loro riga.

**CHIUSA.**
DOMANDA: "Mi serve una proposta di ordine di comparsa di categorie e arti"
PROVA: docs/collaudo/EO/realme/eo17_home_scorsa_in_giu_nessun_doppione.png
MISURA: righe a video contro l'elenco del fondatore da 2 (scaffale e striscia) a 10 su 10; schede con le arti dell'elenco 56 su 56; formati 10 su 10

## VOCE EO.10, L'ORDINE DI SEZIONI E SCHEDE NEI TRE DOMINI

Le sezioni sono righe di schede nell'ordine del fondatore
(`lib/core/arts/l_ordine_dei_domini.dart`), anche contro la regola che
metteva prima le sezioni vive; la scheda "Consulta" resta in cima; il Mood
Tracker e' passato in Energia. Il formato scelto e' verticale, come le
locandine. Sono usciti dal codice il dominio a riquadri e collassi, la card
di prima (`ArtCard`) e le tre viste che nessuno usava piu' (`visibleFor`,
`visibleArts`, `hasActive`); la promessa del Viaggio sta sul retro della
scheda.

**CHIUSA.**
DOMANDA: "Bisogna decidere l'ordine di categorie e schede dei singoli domini. Fai la tua proposta"
PROVA: docs/collaudo/EO/realme/eo10_eo13_dominio_aura.png
MISURA: domini con le sezioni nell'ordine del fondatore da 1 su 3 (solo Calìgo, prima le vive davanti) a 3 su 3, schede nelle sezioni 30 su 30 (10 per Maestro), sul Realme e nella guardia i_domini_a_schede

## VOCE EO.11, DUE SEZIONI CAMBIANO NOME

"Rune" e' Divinazione, "Archetipi" e' Fisiognomica, ovunque: il catalogo, le
arti del Maestro (home, pilastri, chat, persona dei Maestri), la parola sotto
i Maestri di lato e il fumetto del primo approdo. L'istruzione dei Maestri e'
cambiata con loro: rifatta l'attribuzione cieca, tre giri, 90,0, 87,7 e 89,5
per cento, media 89,1 (sopra la soglia di 85, sotto il 92,8 dell'ordine EN),
e registrate le impronte nuove.

**CHIUSA.**
DOMANDA: "Ok confermo, scrivi l'ordine per Code."
PROVA: docs/collaudo/EO/eo11_dopo.txt
MISURA: righe a video coi nomi vecchi da 9 a 0 su 30 (docs/collaudo/EO/eo11_prima.txt)

## VOCE EO.12, IL TEST ARCHETIPO SOLO NEL PASSAPORTO

`archetype_test` porta `soloNelPassaporto`, come l'Angelo Custode: esce dal
dominio, dalla riga "In arrivo" e dalle arti selezionabili; il Passaporto lo
apriva gia' dalla sua tessera.

**CHIUSA.**
DOMANDA: "Per questo test archtipo non è propriamente una funzionalità."
PROVA: docs/collaudo/EO/eo10_13_prove_verdi.txt
MISURA: Test Archetipo nel dominio di Aura da 1 a 0; tessere del Passaporto che lo aprono 1 (l_archetipo_si_apre_dal_passport verde)

## VOCE EO.13, LA RIGA "IN ARRIVO" IN FONDO A OGNI DOMINIO

In fondo a ogni dominio la riga "In arrivo" con le arti del Maestro che non
sono in EO.10 e che la visibilita' mostra: lo sfondo del Maestro senza
emblema, l'icona dell'arte in oro al centro, la clessidra, il titolo come in
EO.02, il comportamento della EO.05.

**CHIUSA.**
DOMANDA: "Ok confermo, scrivi l'ordine per Code."
PROVA: docs/collaudo/EO/realme/eo10_eo13_dominio_caligo.png
MISURA: arti in arrivo in fondo ai domini da 0 a 24 (Medora 7, Aura 8, Calìgo 9), tutte con sfondo del Maestro, icona e clessidra

## VOCE EO.14, I TEMPI DELLA RISPOSTA NEL LIVE

Il LIVE risponde con Flash-Lite, la domanda finita si chiude dopo 1,3
secondi di silenzio, la voce parte dalla prima frase. **Sul Realme la
chiusura a 1,3 secondi scatta raramente**: la trascrizione anticipata impiega
da 1,1 a 1,8 secondi, quindi arriva quando la chiusura normale dei 2 secondi
e' vicina. Il guadagno vero viene dal modello e dalla risposta che e' gia'
pronta quando la frase si chiude ("la chat ha risposto in 3 ms").

**Difetto trovato nel collaudo e riparato**: una domanda di Aura tornava
vuota tre volte su tre da tutte le trascrizioni, mentre il controllo della
stessa frase l'aveva capita; adesso vale l'ultimo controllo con parole.
PROVENIENZA IGNOTA per la trascrizione vuota: nella build di prima la stessa
domanda passava.

**CHIUSA.**
DOMANDA: "nelle chat live bisogna ridurre il tempo in cui la risposta viene scritta e il tempo di risposta del maestro, il più possibile."
PROVA: docs/collaudo/EO/live/logcat_eo14_dopo_medora.txt
MISURA: dalla fine della domanda al Maestro che parla, stesse domande, prima Medora 6850, 5888, 7670, Aura 6202, 5685, 7480, Calìgo 6817, 6344, 6257 ms (mediana 6344), dopo Medora 4407, 4709, 4831, Aura 4791, 4828, 4246, 4960, Calìgo 4849, 4948, 5051 ms (mediana 4830); risposta scritta a video dalla fine della domanda, mediana da 4145 a 2333 ms; dalla prima all'ultima parola scritta 0 secondi prima e dopo (compare intera)

## VOCE EO.15, LE VOCI PREDEFINITE

Le voci di partenza sono quelle del fondatore: Medora Erinome, Aura Sulafat,
Calìgo Algenib, tutte Gemini (`functions/src/live.ts`, pubblicato). La voce
del LIVE la sceglie il server da una configurazione unica, non per profilo:
la partenza vale finche' il selettore non ne ha un'altra.

**CHIUSA.**
DOMANDA: "allego le voci da lasciare di default, già scelte"
PROVA: docs/collaudo/EO/eo15_voci_dei_live_dal_server.txt
MISURA: voci di partenza uguali a quelle del fondatore da 1 su 3 (prima Medora Sulafat, Aura Autonoe, Calìgo Algenib) a 3 su 3; nei LIVE di stamattina 40 sintesi su 40 con Erinome, Sulafat e Algenib, dai registri del server

## VOCE EO.16, IL PULSANTE "DAL VIVO" ACCANTO AI CONTATORI

La pastiglia "Dal vivo" esce dalla testata e sta a destra delle due righe dei
contatori, centrata sulla loro altezza.

**CHIUSA.**
DOMANDA: "il pulsante "dal vivo" lo metti a fianco alle due righe dei contatori"
PROVA: docs/collaudo/EO/realme/eo08_eo16_consulta_apre_la_chat_dal_vivo_accanto_ai_contatori.png
MISURA: pastiglia a destra dei contatori da 0 a 1 (sul Realme nella chat di Medora, nelle prove in tutte e tre); scarto dal centro dei contatori entro 2 punti (la_barra_e_la_pastiglia_della_chat)

## VOCE EO.17, NESSUN DOPPIONE IN VISTA NELLA HOME

Richiesta del fondatore del 26 settembre 2026, a ordine aperto. Per ogni riga
dall'alto, le schede che si vedono senza scorrere di lato devono essere arti
non ancora viste piu' su; un doppione che cadrebbe in vista va in fondo alla
riga. Il numero di schede in vista si calcola dalla larghezza vera dello
schermo e dalla scala del testo. Dove le arti nuove non bastano, il doppione
resterebbe (oggi non capita a nessuna delle larghezze provate).

**CHIUSA.**
DOMANDA: "dalla apertura della home Senza spostare le categorie verso destra, fai in modo che scorrendo verso il basso non si vedano la stessa scheda funzionalità"
PROVA: docs/collaudo/EO/eo17_doppioni_in_vista_dopo.txt
MISURA: schede doppie in vista da 5 a 0 su 20 a 360, 390 e 412 punti, da 5 a 0 su 14 a testo 1,3 (docs/collaudo/EO/eo17_doppioni_in_vista_prima.txt); sul Realme 20 schede in vista tutte diverse
