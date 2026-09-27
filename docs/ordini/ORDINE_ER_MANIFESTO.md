# ORDINE ER, LE ARTI CHE RISPONDONO, LA SINASTRIA VIP, IL GEMELLO ASTRALE, LA HOME CON TUTTE LE ARTI E IL LIVE

**Sigla:** ER, verificata sul ramo il 27 settembre 2026: in `docs/ordini`
l'ultimo manifesto era `ORDINE_EQ_MANIFESTO.md`, in `docs/collaudo` l'ultima
cartella EQ; nessun `ORDINE_ER_*`, nessuna `docs/collaudo/ER`.
**Data dell'ordine:** 27 settembre 2026, arrivato in tre pezzi, piu'
l'aggiunta del fondatore "ER Aggiunta" (voce ER.20).
**Ramo:** `claude/esoteric-circle-master-order-e798aj`.
**Partenza:** commit `3a2c12d3` dell'ordine EQ, col cancello di GitHub verde
su quel commit (dodici controlli su dodici). Le voci ancora aperte dell'ordine
EQ restano dell'EQ. **Questo ordine non consegna niente**: le build le ordina
il fondatore.

Il testo intero dell'ordine e' quello del fondatore, in sei parti: le rune
(ER.01), il Viaggio dello Sciamano (ER.02, ER.03), la Sinastria VIP e il
Gemello Astrale (ER.04, ER.05, ER.06), la home e le schede (ER.07, ER.08,
ER.09, ER.10), il LIVE (ER.11, ER.12, ER.13), i difetti trovati
dall'Architetto (ER.14 fino a ER.19); e l'aggiunta, il Segreto dell'Iride
(ER.20). Le catture del fondatore stanno in `Catture fondatore/ER` sul PC,
fuori dal repository.

VOCI_TOTALI: 20
VOCI_CHIUSE: 0
VOCI_APERTE: 13
VOCI_DA_FARE: 7

Le prove stanno in `docs/collaudo/ER/`; quelle viste sul telefono di prova
(Realme 767f596c, 360 per 800 punti) in `docs/collaudo/ER/realme/`. **Una
voce che si vede a schermo resta APERTA IN ATTESA DI VERIFICA finche' la sua
cattura dal Realme non e' in quella cartella**: la misura in prova dice che
il codice fa la cosa, la cattura dice che la persona la vede.

---

## PARTE 1, LE RUNE

## VOCE ER.01, L'ESTRAZIONE RUNE INTERPRETA DAVVERO

**DA FARE.**

## PARTE 2, IL VIAGGIO DELLO SCIAMANO

## VOCE ER.02, IL VIAGGIO RISPONDE ALLA DOMANDA

**DA FARE.**

## VOCE ER.03, IL TITOLO DEL VIAGGIO SCRITTO COME GLI ALTRI

**APERTA IN ATTESA DI VERIFICA**: manca la cattura dal Realme della card del
Viaggio accanto a un'altra card, nel dominio di Calìgo e in home.

Fatto (commit `5a70fc73`): la card del Viaggio non ha piu' il titolo scritto a
parte. `righeDelTitolo` e' uscito da `lib/core/arts/art_catalog.dart` (con la
lapide in `la_promessa_del_viaggio.dart`), e la scheda disegna "Il Viaggio
dello Sciamano" con lo stile e le regole di andata a capo comuni a tutte le
arti (`IlTitoloColTrattino`, voce ER.09). La descrizione che cambia dopo la
quarta discesa resta.

DOMANDA: "Aggiungi all'ordine: "Viaggiò dello sciamano" deve tornare ad essere scritto come gli altri."
PROVA: docs/collaudo/ER/titoli.txt
MISURA: card d'arte col titolo scritto in modo diverso dalle altre, da 1 (il Viaggio, con le tre righe "VIAGGIO", "dello", "SCIAMANO") a 0 su 67; il Viaggio si legge "Il Viaggio dello / Sciamano" in due righe nei tre formati di home

## PARTE 3, LA SINASTRIA VIP E IL GEMELLO ASTRALE

## VOCE ER.04, LA MIA CARTA: AVATAR O FOTO, NON UN VIP

**APERTA IN ATTESA DI VERIFICA**: mancano le catture dal Realme del tocco
sulla propria carta, della scelta e della carta con l'immagine nella porta,
nel responso e nella card da condividere.

Fatto (commit `156e86bd`): la carta "Tu" della porta della sinastria apre il
foglio del volto (`lib/features/synastry/il_foglio_del_tuo_volto.dart`):
fotocamera, galleria o avatar. La scelta si scrive nel profilo
(`ProfileController.setAvatarPhoto`) e da li' arriva nella porta, nel
responso e nella card. Il confronto fra due VIP (ordine BO voce 13) resta,
dalla scelta "Confronta 2 VIP": solo li' la prima carta e' un VIP e il suo
tocco lo cambia. La prova CA.02 di `la_porta_della_sinastria_test.dart` e'
riscritta con la lapide.

DOMANDA: "Nella sinistria vip c'è una regressione: in "sinastria con un vip" se faccio click sulla mia carta, mi fa scegliere un vip anziché farmi scegliere un avatar o di inserire una mia foto o immagine."
PROVA: docs/collaudo/ER/la_carta_tu.txt
MISURA: tocchi sulla propria carta che aprono la scelta di un VIP, da 1 su 1 a 0; foto scelta presente nella porta, nel profilo e nel responso, 3 su 3

## VOCE ER.05, LA POSSIBILITÀ DI INCONTRO DICE LA REALTÀ

**APERTA IN ATTESA DI VERIFICA**: manca la cattura dal Realme del responso a
360 punti di larghezza.

Fatto (commit `e393f4e7`): la barra dell'incontro era l'indice sulla scala
di chi guarda (la percentuale divisa per 3,6 punti), con una parola a destra
("Alla vostra portata") che andava a capo. Adesso la barra e' la percentuale
vera, sulla stessa scala delle altre barre, e a destra c'e' il numero.

DOMANDA: "Inoltre, nei risultato, la infografica di "possibilità di incontro" è scritto male, va a capo e la percentuale bassissima mostra una barra colorata altissima che è assolutamente non coerente con le altre infografiche barre. Rimettiamo la realtà."
PROVA: docs/collaudo/ER/incontro.txt
MISURA: barre dell'incontro piu' lunghe della loro percentuale vera, da 20 su 20 (Billie Eilish al 3,8 per cento con la barra piena) a 0 su 20; etichette spezzate dentro una parola, da 1 (la cattura, a 70 punti) a 0

## VOCE ER.06, IL GEMELLO ASTRALE IN UNA SCHERMATA SOLA

**APERTA IN ATTESA DI VERIFICA**: mancano le catture in raffica dal Realme,
dall'apertura del Gemello al responso intero (sul Realme non c'e'
`screenrecord`, si fotografa in raffica), e a 402 punti.

Fatto (commit `5bae25bc`): `schermata_del_gemello.dart` e' una schermata sola
in tre tempi. Il nastro delle carte dei VIP poco sovrapposte, il pulsante
"Cerca il tuo gemello VIP", la corsa che rallenta (3,4 secondi) e si ferma coi
tre gemelli, il piu' vicino al centro; il podio con le percentuali, e sotto il
responso intero, senza toccare niente. La galleria non porta piu' al Gemello
(lapide), `rivelazione_del_gemello.dart` e' cancellato.

DOMANDA: "Inoltre, nel gemello astrale, quando lo apro calcola immediatamente il gemello Vip, ma sopra mostra "scegli il tuo vip" e sotto c'è l'elenco delle carte del vip che in questa funzione non hanno senso. [...] La prima e unica schermata che si deve aprire è una schermata semplice con le carte dei vip in orizzontale poco sovrapposte. Al click su un pulsante nuovo "cerca il tuo gemello VIP" le carte iniziano a scorrere velocemente, poi rallentando vengono estratte le 3 carte dei gemelli vip con al centro il gemello più vicino [...] Ma tutto nella stessa schermata Senza bisognondi cliccare sull'immagine della carta del gemello."
PROVA: docs/collaudo/ER/gemello_una_schermata.txt
MISURA: elementi della galleria nella schermata del Gemello (titolo "Scegli il tuo VIP", ricerca, categoria, elenco), da 4 a 0; gesti fra il pulsante e il responso intero, da 1 (il tocco sulla carta) a 0; parti del responso che mancano, 0 su 11; percentuali sul podio, 3 su 3

## PARTE 4, LA HOME E LE SCHEDE

## VOCE ER.07, L'ORO DELL'OROSCOPO

**APERTA IN ATTESA DI VERIFICA**: manca la cattura dal Realme della scheda
dell'Oroscopo.

Fatto (commit `798055fd`): i tre webp dell'Oroscopo in `assets/schede` sono
quelli corretti del PC del fondatore. Guardia `l_oro_dell_oroscopo`.

DOMANDA: "la scheda dell'oroscopo, l'emblema sembra più bronzo che oro. Sistema le schede oroscopo o poi falla aggiornare a Code."; domanda girata al fondatore: "L'oro dell'Oroscopo corretto va bene?", risposta: "Sì, salvalo".
PROVA: docs/collaudo/ER/oro_dell_oroscopo.txt
MISURA: webp dell'Oroscopo in assets/schede uguali byte per byte a quelli del PC, da 0 su 3 a 3 su 3

## VOCE ER.08, LE RIGHE DELLA HOME: UNDICI CATEGORIE SCELTE DAL FONDATORE

**APERTA IN ATTESA DI VERIFICA**: mancano le catture dal Realme della home
intera, dall'alto in basso, a 360 punti.

Fatto (commit `5a70fc73`, con la ER.20 in `171f9e4c`): la home ha le undici
righe della voce, con titoli, forme e ordine delle arti scritti
dall'Architetto e approvati dal fondatore (`le_righe_della_casa.dart`).
**La regola dei doppioni del 26 settembre e' uscita**, come ha detto il
fondatore ("togli regola del 26 settembre"): `senzaDoppioniInVista` ha la
lapide, e la guardia `nessun_doppione_in_vista` e' diventata
`i_doppioni_della_home_sono_voluti`, che confronta ogni riga con l'elenco
scritto (alla prima stesura confrontava la riga con se stessa ed era cieca:
vista verde con l'innesto, cambiata la grandezza, vista rossa).

DOMANDA: "rivediamo l'ordinamento delle categorie della home in modo da avere righe con schede verticali, poi orizzontali e poi quadrate."; "Ok, togli regola del 26 settembre. Se ci sono righe ovvero categorie con lo stesso colore significa che non vanno bene [...] Non ha senso avere categorie di un solo colore, tanto vale che l'utente vada direttamente nel singolo dominio."; risposta alle undici righe: "Per ora va bene così".
PROVA: docs/collaudo/ER/righe_della_home.txt
MISURA: coppie di righe vicine con la stessa forma, da 5 su 9 a 0 su 10; righe con le arti di un solo Maestro, da 4 su 10 a 0 su 11; arti del catalogo visibili in home, da 30 a 67 (66 della voce piu' il Segreto dell'Iride della ER.20); righe diverse dall'elenco della voce, 0 su 11; arti spostate dalla regola dei doppioni, 0

## VOCE ER.09, LE MISURE DELLE SCHEDE IN HOME

**APERTA IN ATTESA DI VERIFICA**: mancano le catture dal Realme di una riga
per forma.

Fatto (commit `5a70fc73`): in home le verticali e le quadrate sono larghe 128
punti, le orizzontali 137; nei domini restano 184 e 288. I titoli in home
sono a 12 punti (`misuraDelTitoloInCasa`), al massimo due righe, e vanno a
capo fra parole o, se una parola non ci sta, col trattino in sillaba
(`lib/design_system/typography/il_titolo_col_trattino.dart`). Niente freccia a
fine riga: "No, basta il taglio".

DOMANDA: "Ma così niente rimani in evidenza, hanno tutti la stessa importanza. Diminuisci ulteriormente quelle orizzontali del 10% e aumenta verticali e quadrate fino a 2 arti e mezzo."; domanda girata al fondatore: "La freccia a fine riga la mettiamo?", risposta: "No, basta il taglio"; risposta all'anteprima dell'Architetto: "La home mi convince adesso."
PROVA: docs/collaudo/ER/titoli.txt
MISURA: larghezza in home delle verticali e quadrate, da 162 a 128 punti; delle orizzontali, da 253 a 137; titoli su piu' di due righe o tagliati, 0 su 201 (67 arti nei tre formati); larghezze nei domini, 184 e 288 prima e dopo

## VOCE ER.10, TUTTE LE ARTI AL LORO POSTO, NELLA HOME E NEI DOMINI

**APERTA IN ATTESA DI VERIFICA**: mancano le catture dal Realme di un dominio
per Maestro e della home con una delle arti nuove.

Fatto (commit `5a70fc73`): dodici arti nuove del briefing nel catalogo, coi
Maestri scelti dal fondatore (Medora: Time Machine Astrologica, Cosmic Scan,
Cosmic Dating, Sinastria NFC e QR; Aura: Breathwork, Percorso di Risveglio,
Feng Shui, Specchio dell'Anima; Calìgo: Rituali Collettivi, Alchimia, Albero
della Vita, Cosmic Academy), ognuna con la fase del briefing (Breathwork,
Specchio dell'Anima e Alchimia, senza fase nel briefing, in fase successiva).
In `assets/schede` i 216 webp del PC, e ogni arte ha il suo sfondo. I domini
hanno le sezioni della voce, e la riga "In arrivo" non c'e' piu': ogni arte
sta nella sezione del suo Maestro.

DOMANDA: "Adesso inoltre ci sono tutte le arti previste dal progetto o ne manca qualcuna tipo la scansione dell'occhio? Facciamole tutte. Avendole tutte, possiamo inserirle ognuna nella giusta categoria sia in home sia nei singoli domini così da avere già una visione futura dell'app conclusa."; risposta sulle arti da creare: "Arti dei Maestri, Funzioni trasversali"; risposta sui Maestri: "Come propongo"; "Le 11 vanno bene."
PROVA: docs/collaudo/ER/sfondi_dal_pc.txt
MISURA: arti del catalogo senza sfondo, da 24 a 0; arti del briefing scelte dal fondatore presenti nel catalogo, da 0 su 12 a 12 su 12; arti nella riga "In arrivo" dei domini, da 24 a 0; webp di assets/schede diversi da quelli del PC con lo stesso nome, da 6 a 0 (elenco dei domini in docs/collaudo/ER/righe_della_home.txt)

## PARTE 5, IL LIVE

## VOCE ER.11, IL VOLTO DEL LIVE IN QUALITÀ LITE

**DA FARE.**

## VOCE ER.12, LE RISPOSTE DEL LIVE SI FERMANO ALLA TERZA FRASE

**DA FARE.**

## VOCE ER.13, LA DOMANDA E LA RISPOSTA SI SCRIVONO COME A MACCHINA

**DA FARE.**

## PARTE 6, DIFETTI TROVATI DALL'ARCHITETTO

## VOCE ER.14, L'OROSCOPO CAMBIA OGNI GIORNO IN TUTTE LE SUE PARTI

**DA FARE.**

## VOCE ER.15, L'AZIONE DEL VIAGGIO NON È SEMPRE IL FOGLIO

**DA FARE.**

## VOCE ER.16, "LE STA ADDOSSO"

**APERTA IN ATTESA DI VERIFICA**: manca la cattura dal Realme del Gemello con
una VIP al primo posto e un secondo a un punto.

Fatto (commit `e393f4e7`): ogni VIP del catalogo ha il suo genere
(`vip_catalog.dart`), e la riga del distacco in `gemello_astrale.dart` dice
"le sta addosso" o "gli sta addosso" secondo chi e' al primo posto. Guardia
nuova `i_vip_hanno_nome_e_genere`.

DOMANDA: domanda girata al fondatore: "Quali dei miei rilievi sulle tue catture metto in fondo all'ordine ER?", risposta: ""gli sta addosso", Distanza detta due volte, "Venere Quadratura Marte", "Beyonce" senza accento".
PROVA: docs/collaudo/ER/gemello_frasi.txt
MISURA: frasi del distacco col pronome sbagliato, da 21 su 50 a 0 su 50

## VOCE ER.17, LA DISTANZA SI DICE UNA VOLTA

**APERTA IN ATTESA DI VERIFICA**: manca la cattura dal Realme del responso con
un VIP di cui non si sa dove viva.

Fatto (commit `e393f4e7`): la nota del luogo ignoto sotto la barra
dell'incontro e' uscita (`possibilita_di_incontro.dart`); la cosa la dice una
volta sola la frase dell'incontro. Guardia nuova
`la_sinastria_dice_le_cose_una_volta_e_in_italiano`, che conta le volte.

DOMANDA: domanda girata al fondatore: "Quali dei miei rilievi sulle tue catture metto in fondo all'ordine ER?", risposta: ""gli sta addosso", Distanza detta due volte, "Venere Quadratura Marte", "Beyonce" senza accento".
PROVA: docs/collaudo/ER/sinastria_guardie.txt
MISURA: responsi che dicono due volte che la distanza non entra nel conto, sui VIP senza luogo pubblico, da tutti a 0

## VOCE ER.18, "VENERE QUADRATURA MARTE" DENTRO LA FRASE

**APERTA IN ATTESA DI VERIFICA**: manca la cattura dal Realme della riga del
cielo del giorno.

Fatto (commit `e393f4e7`): `cielo_del_giorno_sulla_coppia.dart` non mette piu'
il titolo dell'aspetto dentro la frase: *"Oggi Marte tocca i gradi dove la
Venere di Margot Robbie è in quadratura con il tuo Marte"*, per le tre forme
(tocca, sfiora, nessun passaggio) e per i cinque aspetti.

DOMANDA: domanda girata al fondatore: "Quali dei miei rilievi sulle tue catture metto in fondo all'ordine ER?", risposta: ""gli sta addosso", Distanza detta due volte, "Venere Quadratura Marte", "Beyonce" senza accento".
PROVA: docs/collaudo/ER/cielo_del_giorno.txt
MISURA: frasi del cielo del giorno col titolo dell'aspetto in maiuscolo dentro la frase, da 15 su 15 a 0 su 15

## VOCE ER.19, BEYONCÉ

**APERTA IN ATTESA DI VERIFICA**: manca la cattura dal Realme della carta di
Beyoncé.

Fatto (commit `e393f4e7`): i nomi del catalogo dei VIP portano i loro segni
("Beyoncé"); la ricerca li trova anche scritti senza. La guardia degli accenti
della sinastria cercava solo le vocali con l'apostrofo in fondo e non vedeva
questo difetto (PROVENIENZA IGNOTA): lo copre adesso
`i_vip_hanno_nome_e_genere`, vista rossa.

DOMANDA: domanda girata al fondatore: "Quali dei miei rilievi sulle tue catture metto in fondo all'ordine ER?", risposta: ""gli sta addosso", Distanza detta due volte, "Venere Quadratura Marte", "Beyonce" senza accento".
PROVA: docs/collaudo/ER/sinastria_guardie.txt
MISURA: nomi del catalogo scritti senza il loro segno, da 1 ("Beyonce") a 0

## PARTE 7, L'AGGIUNTA DEL FONDATORE

## VOCE ER.20, IL SEGRETO DELL'IRIDE ENTRA NEL CATALOGO, NEL DOMINIO DI AURA E NELLA HOME

**APERTA IN ATTESA DI VERIFICA**: mancano le catture dal Realme della scheda
in "Il tuo corpo", in "I più condivisi" e nel dominio di Aura, e del suo dorso
con la frase.

Fatto (commit `171f9e4c`): "Il Segreto dell'Iride" e' nel catalogo, di Aura,
in arrivo, Fase 2, col dorso "La tua iride, letta come una mappa di segni."
e i tre webp del PC. Sta nel dominio di Aura, sezione Fisiognomica, dopo lo
Specchio dell'Anima; in home in "Il tuo corpo" dopo Magia Verde e in "I più
condivisi"; e in "La tua energia" entra Cosmic Voice Analysis.

DOMANDA: "Ci siamo dimenticati di creare asset per scansione occhio e inserirlo in home"; "Ordine già lanciato. Scrivi un mini ordine da aggiungere per l'occhio. Nome evocativo scegli tu"; decisione del fondatore sulla lettura dell'iride: di Aura, in Fase 2, fuori dalla Demo.
PROVA: docs/collaudo/ER/iride_sfondi.txt
MISURA: webp del Segreto dell'Iride in assets/schede uguali byte per byte a quelli del PC, da 0 su 3 a 3 su 3; arti del catalogo visibili in home, da 66 a 67; coppie di schede vicine dello stesso Maestro nelle righe Il tuo corpo, I più condivisi e La tua energia, 0 (docs/collaudo/ER/righe_della_home.txt)
