# ORDINE EP, LA HOME PIÙ FITTA, GLI SFONDI UNICI DEI MAESTRI, LA SCHEDA CONSULTA E LA CHAT

**Sigla:** EP, verificata sul ramo il 26 settembre 2026: in `docs/ordini`
l'ultimo ordine era EO, nessun `ORDINE_EP_*`, nessuna cartella
`docs/collaudo/EP`.
**Data dell'ordine:** 26 settembre 2026.
**Ramo:** `claude/esoteric-circle-master-order-e798aj`.

**Le consegne del fondatore, a ordine aperto**: sulla stima di otto ore,
*"Tutto, poi build"*; e *"Ho fretta e sono tutte modifiche estetiche, cerca
di fare in fretta. Fai test anche su celle poi consegna nuova build pronta
anche per codemagic"*.

**Le risposte alle tre domande aperte dell'ordine EO**, dall'ordine: EO.06
ed EO.07, riflesso e sollevamento con le animazioni a zero, *"Luce sempre
accesa"* (voce EP.09); EO.08, *"Per ora lascia il pulsante pillola chat a
fianco a "entra nel dominio" in home sotto ogni maestro."* (voce EP.10); la
trascrizione anticipata del LIVE non e' approvata, e il LIVE resta com'e'.

VOCI_TOTALI: 15
VOCI_CHIUSE: 15
VOCI_APERTE: 0

Le prove stanno in `docs/collaudo/EP/`; quelle viste sul telefono di prova
(Realme 767f596c, 360 per 800 punti, animazioni del telefono a zero, build di
prova 0.1.0+2284) in `docs/collaudo/EP/realme/`. Gli innesti della Regola A in
`docs/collaudo/EP/regola_a_innesti.txt` e
`docs/collaudo/EP/regola_a_titoli_delle_righe.txt`.

---

## PARTE 1, GLI SFONDI

## VOCE EP.01, GLI SFONDI NUOVI DELLE SCHEDE

I 99 WebP della cartella del fondatore `assets/Sfondi Schede/webp` sono
copiati sopra quelli di `assets/schede/`, con gli stessi nomi: ne erano
cambiati 79. Della stessa cartella entrano solo i tre orizzontali di
"Consulta" della voce EP.12 (l'ordine diceva i verticali, il fondatore l'ha
corretto a ordine aperto); i quadrati, i verticali e tutti i PNG restano
fuori. La guardia `gli_sfondi_delle_schede_test.dart` conta 102 file e
pretende che di "Consulta" ci siano solo i tre orizzontali.

**CHIUSA.**
DOMANDA: "VOGLIO LO STESSO SFONDO DELLE SCHEDE PER OGNI MAESTRO. Per ogni maestro la scheda deve avere lo stesso sfondo."; "Lo sfondo di Aura fa schifo, mi piace la finezza ed eleganza dello sfondo di Caligo."
PROVA: docs/collaudo/EP/ep01_confronto_sfondi.txt
MISURA: file di assets/schede diversi da quelli della cartella del fondatore, da 79 a 0 su 99 (sha1 di ciascuno accanto); sul Realme la home e i tre domini con gli sfondi nuovi (docs/collaudo/EP/realme/ep01_home_sfondi_nuovi.png, docs/collaudo/EP/realme/ep12_ep13_ep14_ep15_aura_e_caligo_dominio_chat_menu.png)

## PARTE 2, LA HOME

## VOCE EP.02, LE SCHEDE DELLA HOME ALL'88%

In home le schede sono a 162 punti le verticali e le quadrate, a 253 le
orizzontali, per la scala del testo; nei domini restano 184 e 288
(`LaSchedaDellArte.larghezzaPer`, parametro `inCasa`). I titoli sono quelli
di prima: stesso carattere, stessa misura. La parola piu' lunga della home,
misurata col Cinzel vero, e' "Interpretazione": 161,3 punti su 162.

**CHIUSA.**
DOMANDA: "Le tessere schede sono troppo grandi in home. [...] Senza esagerare, però, io pensavo di ridurre all'80%."; "Schede all'88%"; "Invece, per ora, nei singoli domini lasciamo la grandezza attuale perché consono poche arti per ogni dominio."
PROVA: docs/collaudo/EP/ep02_ep07_misure_della_home.txt
MISURA: larghezza delle schede in home da 184 a 162 punti e da 288 a 253; nei domini 184 e 288 invariate; titoli della home rimpiccioliti 0, oltre due righe 0, parole spezzate 0, a testo 1,0 e 1,3; la parola piu' lunga, "Interpretazione", 161,3 punti su 162 (a testo 1,3, 204,3 su 210,6)

## VOCE EP.03, I MARGINI DELLE RIGHE DELLA HOME

A sinistra della prima scheda 16 punti, fra una scheda e l'altra 12
(`LaRigaDelleSchede.margineInCasa`, `spazioInCasa`); nei domini restano 24 e
16.

**Una misura da sapere, e l'ho messa nel rapporto come domanda**: a 360
punti, cioe' sul Realme del fondatore, con le schede verticali e quadrate
la terza non si vede tagliata: 16 + 162 + 12 + 162 + 12 fa 364, e comincia
fuori dallo schermo. Si vede tagliata dal 16 per cento a 390 punti e dal 30
a 412. Le orizzontali mostrano la seconda tagliata a tutte e tre le
larghezze.

**CHIUSA.**
DOMANDA: "Margini 16 e 12" ("La terza scheda si vede tagliata sul bordo e fa capire che la riga scorre.")
PROVA: docs/collaudo/EP/ep02_ep07_misure_della_home.txt
MISURA: margine da 24 a 16 punti, spazio fra le schede da 16 a 12; a 360 punti quadrate e verticali 2 intere e 0% della terza, orizzontali 1 intera e 31% della seconda; a 390 punti 2 intere e 16%, 1 e 43%; a 412 punti 2 intere e 30%, 1 e 52%

## VOCE EP.04, LO SPAZIO FRA LE RIGHE DELLA HOME

La riga della home finisce dove finisce il titolo piu' alto fra le sue arti,
sulla scheda al centro sollevata, e non tre righe di titolo dopo come prima.
Da li' al titolo della riga dopo restano 24 punti; fra il titolo della riga e
le sue schede 8. **A riposo**, dove le schede in vista hanno titoli piu'
corti di quello piu' lungo della riga o non sono sollevate, il vuoto a video
va da 26 a 50 punti.

**Due difetti trovati e curati in questa voce, padre la voce EP.07**: l'area
di tocco di "Vedi tutto", alta 48 punti, allungava la testata della riga (40
punti invece di 24 sopra il titolo, 16 invece di 8 sotto). Ora sale nel vuoto
sopra il titolo senza allungare niente.

**CHIUSA.**
DOMANDA: "Ridurre lo spazio verticale tra le file di categorie."; "24 punti" ("Come Disney+ e Prime. Il titolo di riga dista 8 punti dalle schede.")
PROVA: docs/collaudo/EP/ep02_ep07_misure_della_home.txt
MISURA: vuoto fra la fine di una riga e il titolo della successiva da circa 90 a 24 punti, nove vuoti su nove a testo 1,0 e 1,3; a riposo, dal titolo piu' basso in vista, da 26,3 a 50,4 punti; fra titolo di riga e schede da 12 a 8; sul Realme docs/collaudo/EP/realme/ep02_ep03_ep04_ep05_ep06_ep07_ep08_ep11_home_scorsa_in_giu.png

## VOCE EP.05, "TROVA UNA RISPOSTA" SUBITO DOPO LE PREFERITE

La riga si chiama "Trova una risposta", con le stesse arti e lo stesso
formato, e sta seconda (`LeRigheDellaCasa.righe`, chiave
`trova_una_risposta`).

**CHIUSA.**
DOMANDA: "dopo le arti preferite, metti la categoria "Cerca una risposta", ma cambiagli il nome in "trova una risposta"."
PROVA: docs/collaudo/EP/realme/ep02_ep03_ep04_ep05_ep06_ep07_ep08_ep11_home_scorsa_in_giu.png
MISURA: righe a video nell'ordine dell'ordine, 10 su 10; "Cerca una risposta" a video da 1 a 0, "Trova una risposta" da 0 a 1

## VOCE EP.06, IL PUNTINO D'ORO SULLE ARTI DEL GIORNO

Le arti del giorno, ricavate dal catalogo, sono quattro: Oroscopo
Personalizzato (`horoscope`), Affermazioni del Giorno
(`daily_affirmations`), Bioritmo (`biorhythm`) e Il Respiro della Luna
(`lunology`): il loro contenuto cambia da solo col giorno. **Restano
fuori**, con la ragione scritta in `lib/core/arts/le_arti_del_giorno.dart`,
l'Oracolo dei Cristalli e le altre estrazioni, perche' il contenuto nasce dal
gesto e non dal giorno, e il Mood Tracker, perche' il contenuto lo scrive la
persona. Il puntino sta in basso a destra dell'immagine, lontano dalla "i",
dalla clessidra e dal lucchetto; si spegne quando quel giorno l'arte si apre
da qualunque porta (scheda, striscia del dominio, chat) e torna il giorno
dopo.

**CHIUSA.**
DOMANDA: "Puntino d'oro nuovo" ("Sulle arti che cambiano ogni giorno, finché non le apri.")
PROVA: docs/collaudo/EP/realme/ep06_puntino_prima_apertura_e_dopo.png
MISURA: arti del giorno col puntino prima dell'apertura, 4 su 4 dove compaiono; dopo l'apertura dell'Oroscopo, puntini sull'Oroscopo da 1 a 0 (visto sul Realme); il giorno dopo, con la data spostata nella prova, di nuovo 1; puntino sovrapposto alla "i" 0

## VOCE EP.07, "VEDI TUTTO"

Accanto al titolo di ogni riga della home "Vedi tutto" apre la categoria
intera in griglia (`lib/features/santuario/la_categoria_intera.dart`): tutte
le arti della riga nell'ordine del fondatore, in formato verticale, a 162
punti per la scala del testo, due colonne anche a 360 punti. Nelle preferite
la matita resta.

**Due difetti visti sul Realme e curati, padre questa voce**: nella prima
build di prova i titoli delle righe si spezzavano a meta' parola ("LE ARTI
PREFER / ITE") e "Trova una risposta" andava su tre righe, perche' lo spazio
vuoto e il titolo si dividevano a meta' la riga; nella seconda si leggeva
"Vedi tutt", perche' il pulsante prendeva dal tema una spaziatura delle
lettere che la larghezza riservata non contava. Due prove nuove, nate rosse
sui difetti veri (`docs/collaudo/EP/regola_a_titoli_delle_righe.txt`); "Vedi
tutto" e' in tondo e non in maiuscoletto, 62 punti invece di 98, e cosi' i
dieci titoli stanno su una riga a 360 punti.

**CHIUSA.**
DOMANDA: "Vedi tutto" ("Accanto al titolo della riga, apre la categoria intera in griglia.")
PROVA: docs/collaudo/EP/realme/ep07_vedi_tutto_apre_la_griglia.png
MISURA: righe con "Vedi tutto" da 0 a 10; il tocco apre la griglia con tutte le arti della sua categoria, 10 su 10; titoli delle righe su una riga a 360 e 390 punti e testo 1,0, 10 su 10; parole spezzate 0 anche a testo 1,3

## VOCE EP.08, I TITOLI DELLE RIGHE IN GIALLO ORO

I titoli delle righe della home e delle sezioni dei domini, riga "In arrivo"
compresa, sono nell'oro del design system, `ColorTokens.gold`
(`LaRigaDelleSchede.coloreDelTitolo`): la riga e' la stessa in home e nei
domini.

**CHIUSA.**
DOMANDA: "I titoli delle categorie in giallo oro."; "Home e domini"
PROVA: docs/collaudo/EP/realme/ep12_ep08_consulta_medora_in_cima_al_dominio.png
MISURA: titoli di riga in oro, in home da 0 a 10 su 10, nei domini da 0 a tutti (una riga sola per home e domini); sul Realme la home e i tre domini

## VOCE EP.09, RIFLESSO E SOLLEVAMENTO ANCHE CON LE ANIMAZIONI A ZERO

`LaLuceDelleSchede.spenta` non guarda piu' la riduzione del movimento: la
luce e' sempre accesa, e la build di misura con `EO_LUCE_FORZATA` non serve
piu'. Chiude la EO.06 e la EO.07.

**CHIUSA.**
DOMANDA: "Luce sempre accesa" ("Il riflesso d'oro e la scheda che si solleva restano accesi anche se le animazioni del telefono sono a zero")
PROVA: docs/collaudo/EP/ep09_fotogrammi_luce_accesa_animazioni_a_zero.txt
MISURA: sul Realme con le tre scale delle animazioni a 0,0, riflesso e sollevamento da spenti ad accesi (la scheda al centro sollevata e in luce, le laterali in ombra: docs/collaudo/EP/realme/ep09_scheda_al_centro_sollevata_con_le_animazioni_a_zero.png); fotogrammi scorrendo la home 733 in 12,35 secondi, 59,3 al secondo, 0 persi, contro 59,7 senza luce dell'ordine EO

## VOCE EP.10, "CONSULTA" IN HOME RESTA ACCANTO A "ENTRA NEL DOMINIO"

Nessuna modifica. Chiude la EO.08.

**CHIUSA.**
DOMANDA: "Per ora lascia il pulsante pillola chat a fianco a "entra nel dominio" in home sotto ogni maestro."
PROVA: docs/collaudo/EP/realme/ep10_consulta_accanto_a_entra.png
MISURA: posizione invariata, accanto a "Entra nel Dominio" in tondo, sul Realme; per i tre Maestri la guardia `il_pulsante_consulta_in_home_test.dart`, 3 su 3

## VOCE EP.11, LA REGOLA DEI DOPPIONI CON LE MISURE NUOVE

`LeRigheDellaCasa.visibiliSenzaScorrere` conta le schede in vista con le
misure della home (162 e 253, margine 16, spazio 12) e l'ordine nuovo.

**CHIUSA.**
DOMANDA: "dalla apertura della home Senza spostare le categorie verso destra, fai in modo che scorrendo verso il basso non si vedano la stessa scheda funzionalità"
PROVA: docs/collaudo/EP/realme/ep02_ep03_ep04_ep05_ep06_ep07_ep08_ep11_home_scorsa_in_giu.png
MISURA: schede doppie in vista 0, a 360, 390 e 412 punti e a testo 1,3 (`nessun_doppione_in_vista_test.dart`); sul Realme le dieci righe scorse in giu', nessuna scheda in vista ripetuta

## PARTE 3, I DOMINI

## VOCE EP.12, LA SCHEDA "CONSULTA" IN CIMA A OGNI DOMINIO

In cima a ogni dominio la scheda "Consulta" e' una `LaSchedaDellArte` come le
altre, alla misura del dominio, con l'immagine del suo Maestro
(`GliSfondiDelleSchede.consultaDi`) e il titolo "Consulta" col nome del
Maestro; il tocco la preme e la fa svanire, e apre la chat di quel Maestro.

**Orizzontale e non verticale.** L'ordine diceva verticale, con le immagini
`Consulta-<Maestro>-Vert-1.webp`; visto il lavoro, il fondatore l'ha
corretto a ordine aperto: *"in ogni dominio, in alto ci devi mettere la
scheda della chat orizzontale e non quadrata."* Adesso e' orizzontale, 288
punti per la scala del testo, con `Consulta-<Maestro>-Oriz-1.webp`; la
guardia pretende il formato orizzontale ed e' stata vista rossa rimettendo
il verticale.

**Il nome**: l'app scrive il Maestro "Caligo" in tutti i suoi punti
(`Maestro.caligo.displayName`, l'intestazione della chat, "Scrivi a
Caligo"), e la scheda segue lo stesso nome; l'ordine scrive "Calìgo". Non ho
cambiato il nome in un punto solo: e' una domanda nel rapporto.

**CHIUSA.**
DOMANDA: "Nel dominio di ogni maestro serve anche fare la scheda "Consulta [nome Maestro]"."; "Ma in ogni dominio, in alto ci devi mettere la scheda della chat orizzontale e non quadrata."
PROVA: docs/collaudo/EP/realme/ep12_consulta_orizzontale_nei_tre_domini.png
MISURA: domini con la scheda Consulta illustrata in cima da 0 a 3, orizzontale in 3 su 3; tocco che apre la chat del suo Maestro 3 su 3 sul Realme

## PARTE 4, LA CHAT

## VOCE EP.13, IL PULSANTE "LIVE"

La pastiglia accanto ai contatori dice "LIVE"; e' larga 72 punti invece di
88. Anche il foglio di chi non ha il piano dice "LIVE con" il nome del
Maestro.

**CHIUSA.**
DOMANDA: "nella chat il pulsante sarà semplicemente "LIVE" in maiuscolo"
PROVA: docs/collaudo/EP/realme/ep12_ep13_ep14_chat_di_medora_live_e_due_righe.png
MISURA: "Dal vivo" a video da 3 a 0 chat; "LIVE" da 0 a 3, sul Realme

## VOCE EP.14, LE DUE RIGHE DEI CONTATORI

Nella chat ciascun contatore sta su una riga sola: dove non ci sta intero si
stringe invece di andare a capo (`RigaDelResiduo`, forma stretta).

**Una misura da sapere, e l'ho messa nel rapporto come domanda**: con la
frase piu' lunga, "Ti restano 49 domande ai Maestri su 50, oggi", a 360
punti la riga si stringe al 73 per cento, e a testo 1,3 al 56. Con la frase
di inizio giornata, "Oggi hai 50 domande ai Maestri", sul Realme sta intera.

**Una guardia nata cieca due volte, e curata**: misurava la frase piu'
corta, e poi il paragrafo della clessidra invece della frase. Ora e' rossa
su sei combinazioni su sei col difetto innestato.

**CHIUSA.**
DOMANDA: "e le righe dei contatori dovranno restare 2 Senza andare a capo."
PROVA: docs/collaudo/EP/ep13_ep14_ep15_misure_della_chat.txt
MISURA: righe dei contatori da 3 a 2 nelle tre chat, a 360, 390 e 412 punti, a testo 1,0 e 1,3 (sei combinazioni, 6 righe su 6 in ciascuna); sul Realme due righe (docs/collaudo/EP/realme/ep12_ep13_ep14_chat_di_medora_live_e_due_righe.png)

## VOCE EP.15, IL MENÙ DELLA CHAT NEL COLORE DEL MAESTRO

Il menu' della barra della chat ha lo sfondo della superficie del suo
Maestro (`MaestroPalette.surface`) e un filo d'oro: blu per Medora, verde per
Aura, rosso per Calìgo.

**CHIUSA.**
DOMANDA: "lo sfondo del menù Chat deve essere del colore del maestro e non grigio/nero."
PROVA: docs/collaudo/EP/realme/ep15_menu_di_medora_blu.png
MISURA: menu' con lo sfondo grigio o nero da 3 a 0; menu' nel colore del suo Maestro da 0 a 3, sul Realme (Aura e Calìgo in docs/collaudo/EP/realme/ep12_ep13_ep14_ep15_aura_e_caligo_dominio_chat_menu.png)
