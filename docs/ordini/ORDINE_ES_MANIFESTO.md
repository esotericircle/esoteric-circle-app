# ORDINE ES, L'OROSCOPO COMPLETO, IL SIGILLO DEL SOGNO E LE VOCI APERTE DELL'ORDINE ET

**Sigla:** ES, verificata sul ramo il 28 settembre 2026 sul commit
`acc38528`: in `docs/ordini` l'ultimo manifesto era `ORDINE_ET_MANIFESTO.md`,
in `docs/collaudo` l'ultima cartella ET; nessun `ORDINE_ES` ne' `docs/collaudo/ES`.
**Data dell'ordine:** 28 settembre 2026, in quattro pezzi; il testo dei quattro
pezzi sostituisce ogni versione precedente dell'ordine ES e la ES Aggiunta.
**Ramo:** `claude/esoteric-circle-master-order-e798aj`.
**Partenza:** commit `acc38528`, col cancello di GitHub verde su quel commit
(dodici controlli su dodici e il segno `refs/verde/acc38528...`). **Questo
ordine non consegna niente**: le build le ordina il fondatore.

Le nove voci aperte dell'ordine ET proseguono qui (PARTE 3): ET.01 nella
ES.19, ET.02 nella ES.20, ET.03 nella ES.21, ET.04 nella ES.22, ET.06 nella
ES.23, ET.07 nella ES.24, ET.08 nella ES.25, ET.09 nella ES.26, ET.10 nella
ES.27; nel manifesto ET ognuna ha la riga che lo dice.

**La stima dichiarata al fondatore prima di cominciare**: circa 9-12 giorni
di lavoro, in otto blocchi. La sua scelta: *"Tutto, a blocchi"*, prima le
voci rapide e sicure, poi l'Oroscopo occidentale, piani, Cinese e Vedica,
amici, online, Sigillo, infine le voci ET, con commit e spinta a ogni voce
chiusa.

VOCI_TOTALI: 37
VOCI_CHIUSE: 2
VOCI_APERTE: 35
VOCI_DA_FARE: 0

Le prove stanno in `docs/collaudo/ES/`, quelle del telefono di prova
(Realme 767f596c) in `docs/collaudo/ES/realme/`. **Una voce che si vede a
schermo e' chiusa solo con la sua cattura dal Realme**, le animazioni con la
loro registrazione dello schermo.

---

## PARTE 1, L'OROSCOPO, RICHIESTE DEL FONDATORE

## VOCE ES.01, BREVE E APPROFONDITA, SENZA MEDIA

**APERTA IN ATTESA DI VERIFICA**: prodotta e agganciata (blocco 2 dell'ordine ES). Le profondita' sono due, Breve e Approfondita: la Media non c'e' piu' nel codice, il
selettore dice "Approfondita" e la pagina dei piani "Scelta della profondità dell'oroscopo:
Breve o Approfondita". Con la carta natale l'Approfondita resta com'e' (tre passaggi del
cielo). Senza, aggiunge dove sono oggi la Luna e il corpo del dominio (il Sole per il
Generale, Venere per l'Amore, Marte per la Carriera, Giove per la Fortuna) e in quale casa
solare del segno (`lib/core/horoscope/il_cielo_del_segno.dart`). La Cinese e la Vedica
avranno le due profondita' con le voci ES.08 ed ES.09. Mancano le catture dal Realme.

DOMANDA: "io terrei breve e approfondita Senza media, ok?"; domanda girata al fondatore: la scheda dell'Oroscopo dell'Architetto ("per chi non ha dato ora e luogo di nascita è identica alla Breve"; "Una Profonda che dica di più anche senza carta natale"), risposta: "In verità seguo e approvo ogni tuo consiglio."

PROVA: docs/collaudo/ES/profondita.txt
MISURA: schede Approfondite identiche alla Breve senza carta natale, prima 48 su 48, dopo 0 su 48; voci "Media" e "Profonda" a video e nella pagina dei piani, dopo 0

## VOCE ES.02, IL SETTIMANALE: LA PREVISIONE DEI PROSSIMI SETTE GIORNI

**APERTA IN ATTESA DI VERIFICA**: prodotta e agganciata (blocco 2 dell'ordine ES). La Settimana si apre dall'Iniziato (al Viandante l'invito nomina
l'Iniziato) e mostra i fatti del cielo dei sette giorni (fasi della Luna con l'ora, ingressi
col giorno, "torna" quando il pianeta e' retrogrado), e per ogni dominio il giorno migliore, il
momento chiave con giorno e ora e una riga per giorno col livello e la sua ragione
(`lib/core/horoscope/la_settimana_del_cielo.dart`, `lib/features/horoscope/il_periodo_view.dart`).
Senza ora e luogo la schermata dice che si legge sul segno e sulle case solari. Mancano: la
lettura una tantum con gli Eos (voce ES.06), la card della settimana con il suo emblema
(ES.05), la registrazione dal Realme.

DOMANDA: "l'oroscopo settimanale in cosa consiste secondo te? Non è un abbonamento settimanale, ma l'oroscopo di previsione dei prossimi 7 giorni, giusto? Per il resto approvo tutto."; "Per settimanale e mensile serve veramente il motore ad effemeridi?"; domanda girata al fondatore: il contenuto del settimanale proposto dall'Architetto, risposta: "Si tutto ok."

PROVA: docs/collaudo/ES/settimana.txt
MISURA: righe della settimana senza un fatto del cielo dietro, 0 su 112; settimane identiche per due carte diverse dello stesso segno, 0 su 3; fasi della Luna oltre due minuti dal JPL, 0 su 25 (scarto massimo 0,47 minuti)

## VOCE ES.03, IL MENSILE

**APERTA IN ATTESA DI VERIFICA**: prodotta e agganciata (blocco 2 dell'ordine ES). Il Mese si apre dall'Adepto e mostra i trenta giorni: le lune nuove e
piene e le eclissi nelle case (natali con la carta, solari senza), gli ingressi, e per ogni
dominio il giorno migliore, il momento chiave e i tre giorni chiave. Le eclissi vengono dal
motore gia' verificato col canone (ordine CE voce 16). Mancano la lettura con gli Eos (ES.06), la
card del mese (ES.05) e la cattura dal Realme.

DOMANDA: "Per settimanale e mensile serve veramente il motore ad effemeridi?"; domanda girata al fondatore: "Mensile, dall'Adepto in su: il mese sulla carta natale, con lune nuove e piene nelle tue case, eclissi, ingressi e i giorni chiave", risposta: "Si tutto ok."

PROVA: docs/collaudo/ES/mese.txt
MISURA: righe del mese senza un fatto del cielo dietro, 0 su 120; fasi della Luna contro il JPL, scarto massimo 0,47 minuti su 25; eclissi di febbraio 2027 trovate 2 su 2

## VOCE ES.04, L'ANNUALE, DAL COMPLEANNO

**APERTA IN ATTESA DI VERIFICA**: prodotta e agganciata, da vedere sul Realme. "Anno" e' fra i
periodi, e l'anno va dal compleanno al prossimo. Compreso dall'Adepto in su; il Viandante e
l'Iniziato lo aprono con 300 Eos per quell'anno (`ListinoDegliEos.oroscopoAnnuale`), e l'anno
comprato si ricorda sul telefono (chiave `oroscopo_annuale_aperti`, dentro il prefisso
`oroscopo_` che se ne va coi dati). **La Rivoluzione Solare** e' l'istante in cui il Sole torna
alla sua longitudine di nascita: il Sole viene dalle tavole di Chebyshev generate dal JPL DE421
(`lib/core/astro/le_effemeridi_del_jpl.dart`, `tool/genera_effemeridi_del_jpl.py`, errore 0,04
secondi d'arco; Venere, Giove e Saturno dal 2019 al 2050), l'Ascendente e il Medio Cielo col tempo
siderale apparente, le case uguali dall'Ascendente (`lib/core/horoscope/la_rivoluzione_solare.dart`).
Col Sole di Meeus l'istante sbagliava di 638 secondi: per questo le tavole. Il tema si calcola per
la citta' di oggi, e senza quella per il luogo di nascita. **Quattro schede**: Generale
(l'Ascendente dell'anno, le case del Sole e della Luna), Amore (Venere), Carriera (il Medio Cielo e
Saturno), Fortuna (Giove); il livello dalla forza della casa (angolare, succedente, cadente), per
Saturno rovesciato (`lib/core/horoscope/l_annuale.dart`). Le frasi vengono dal corpus
`docs/corpus/oroscopo_annuale.md` (252 frasi) attraverso `tool/_gen_oroscopo_annuale.py`, e la
variante cambia ogni anno. Al prossimo ritorno del Sole parte l'avviso "il tuo anno nuovo e'
pronto" (canale `oroscopo_annuale`), solo col permesso gia' concesso; l'Illuminato ha il PDF
dell'anno, con l'emblema dell'Anno in copertina (voce ES.05). Mancano le catture dal Realme
dell'anno aperto, dell'invito con gli Eos, del PDF e dell'avviso.

DOMANDA: "Inoltre, cosa ne dici dell'oroscopo annuale da integrare?"; domanda girata al fondatore: l'annuale proposto dall'Architetto (Rivoluzione Solare dal compleanno, notifica e card, dall'Adepto in su, 300 Eos, PDF all'Illuminato), risposta: "Per il resto approvo tutto."

PROVA: docs/collaudo/ES/regola_a_rivoluzione_solare.txt
MISURA: istante del ritorno col Sole di Meeus, prima 638 secondi di scarto dal JPL, dopo 10 secondi; ritorni del 2026 con un segno o una casa diversi dal JPL 0 su 10 (rivoluzione_solare_jpl.csv), Ascendente e Medio Cielo entro 0,044 gradi; schede fuori dal loro caso o dal loro livello 0 su 400; lo stesso caso in due anni di fila con la stessa frase 0 su 40; frasi del codice diverse dal corpus 0 su 252

## VOCE ES.05, GLI EMBLEMI DEI PERIODI

**APERTA IN ATTESA DI VERIFICA**: prodotta e agganciata (commit `a9e52f66`). I nove webp dei periodi
sono in `assets/schede`, uguali byte per byte a quelli del PC; la card da condividere porta
l'emblema del periodo (il Giorno quello dell'Oroscopo). Mancano: la cattura dal Realme di una card
per periodo, che si potra' fare quando Settimana, Mese e Anno saranno aperti (voci ES.02, ES.03,
ES.04). La copertina del PDF dell'anno c'e' dal 29 settembre 2026: l'emblema dell'Anno, in una
copia JPEG di 960 per 540 (`assets/pdf/`), perche' il WebP nel PDF diventava pixel e il foglio
pesava 1,3 MB; col JPEG pesa 103 KB. In testa alla schermata resta il segno in
ogni periodo: oggi i periodi diversi dal Giorno sono chiusi e non cambiano la testa.

DOMANDA: "Ma non dovrei creare degli asset per ogni tipo di oroscopo? Ci pensi tu?"; "Cioè un Emblema per ogni tipo di oroscopo, intendevo..."; "attualmente l'utente entra in oroscopo personalizzato e vede il suo segno zodiacale occidentale con il pulsante oroscopo occidentale attivo".

MISURA: webp dei periodi in assets/schede uguali a quelli del PC, prima 0 su 9, dopo 9 su 9 (cmp, e la prova la_tradizione_scelta_sta_in_cima conta 27 emblemi su 27)

## VOCE ES.06, CHI VEDE COSA: PIANI, LIMITI ED EOS

**APERTA IN ATTESA DI VERIFICA**: prodotta e agganciata, da vedere sul Realme. Il catalogo dei
piani (`lib/core/entitlement/plan_catalog.dart`) dice le regole del fondatore, e l'app le legge da
li'. **Il Viandante**: l'oroscopo del giorno occidentale, solo Breve, e il proprio segno cinese e
vedico senza lettura; niente settimanale (la riga passa da "Base" a "No"), niente amici (il tocco
invita al piano). **L'Iniziato**: il settimanale, Breve o Approfondita, Cinese e Vedica con la
lettura, gli amici fino a tre. **L'Adepto**: il mese e l'anno dal compleanno, gli amici fino a
dieci. **L'Illuminato**: l'anno col PDF, gli amici senza limite. Nella mappa entrano tre righe:
"Profondità dell'oroscopo", "Oroscopo dell'anno" (con gli Eos per i primi due piani) e
"Oroscopo per gli amici" (No, 3, 10, Senza limite); la profondita' e i posti degli amici si
leggono da quelle righe (`PlanCatalog.haProfondita`, `AmiciOffline.posti`), non da un secondo
numero scritto altrove. Nessun limite di numero per l'oroscopo del giorno, che resta uguale tutto
il giorno. **Prezzi in Eos**: l'anno 300, un posto in piu' fra gli amici 100. **Il posto comprato
resta**: e' l'unica cosa che gli Eos comprano per sempre, contro la regola che gli Eos non
comprano accessi durevoli, ed e' la decisione del fondatore (*"100 Eos per un posto in più"*,
*"ok , approvato"*). Mancano le catture dal Realme della schermata dei piani.

DOMANDA: "Ma prima di scrivere l'ordine dovresti indicarmi cosa sblocchiamo e a quale tier renderlo disponibile e con quali limiti. E andranno aggiornati anche i piani di abbonamento e bisogna decidere il prezzo in Eos per chi vuole un giro in più a meno che già c'è."; domanda girata al fondatore: la tabella dell'Architetto, risposta: "Approvo tutto. Ma vorrei che l'utente free non avesse accesso al settimanale."; "Anche cinese e vedica saranno disponibili solo per i premium."; "Si per Premium intendo tutti i piani a pagamento. I free potranno solo chiedere oroscopo del giorno e solo occidnetale o solo vedere il proprio segno di vedica o cinese senza lettura come hai suggerito. Non ci sono limiti di numero perchè l'oroscopo è ugale ogni giorno e non cambia se lo chiedo nuovamente lo stesso giorno."; "No, l'utente free non può fare orsocopo per amici, lo vede e se fa click, viene invitato a sottoscrivere abbonamento"; domanda girata al fondatore: "3 per l'Iniziato, 10 per l'Adepto, nessun limite per l'Illuminato [...] 100 Eos per un posto in più", risposta: "ok , approvato"; "Ma il viandante corrisponde al free!".

PROVA: docs/collaudo/ES/piani_es06.md
MISURA: righe della mappa dei piani, prima 33, dopo 36; settimanale per il Viandante, prima "Base", dopo "No"; profondita' per il Viandante, prima non detta, dopo "Breve"; punti del piano, Iniziato prima 14 dopo 15, Adepto prima 12 dopo 14

## VOCE ES.07, IN CIMA IL SEGNO DELLA TRADIZIONE SCELTA

**APERTA IN ATTESA DI VERIFICA**: prodotta e agganciata (commit `a9e52f66`). I quattordici webp in
`assets/img/zodiac`, uguali byte per byte. Scegliendo una tradizione, in cima compare il segno
della persona in quella tradizione (`lib/core/horoscope/i_segni_delle_tradizioni.dart`, schermata in
`la_testa_della_tradizione.dart`). Il segno cinese dal Capodanno lunare, tabella 1900-2100
verificata con l'Osservatorio di Hong Kong; il vedico dalla Luna siderale di Lahiri, con la Luna di
Meeus intera (`lib/core/astro/la_luna_intera.dart`): quella di `Effemeridi` sbaglia fino a 0,27
gradi e avrebbe sbagliato il rashi a circa una nascita su trecento. Cinese e Vedica sono ancora
"In arrivo" finche' le voci ES.08 ed ES.09 non le aprono. Mancano le catture dal Realme della
testa in Occidentale, Cinese e Vedica per due persone. **Una decisione del fondatore**: chi nasce
in Italia la sera della vigilia del Capodanno cinese, quando a Pechino e' gia' il giorno dopo;
l'app oggi usa la data civile del luogo di nascita.

DOMANDA: "Nel momento in cui seleziona l'oroscopo cinese, ad esempio, non dovrebbe comparire il suo segno zodiacale Cinese al posto di quello occidentale?"; "I segni occidentali che ho creato io sono realistici 3d in metallo bronzato."; "In allegato i nuovi emblemi".

PROVA: docs/collaudo/ES/cinese_vedica_dieci_date.csv
MISURA: tradizioni scelte che lasciano in cima il segno occidentale, prima 2 (anzi 6), dopo 0 su 6; webp in assets/img/zodiac uguali a quelli del PC, prima 0 su 14, dopo 14 su 14; segni cinesi e vedici delle dieci nascite diversi dalla fonte, 0 su 20

## VOCE ES.08, LA TRADIZIONE CINESE, APERTA

**APERTA IN ATTESA DI VERIFICA**: prodotta e agganciata, da vedere sul Realme. La Cinese si sceglie
e non ha piu' la clessidra. Il Viandante ne vede il segno e l'invito al piano che apre la lettura
("si apre con l'Iniziato", col suo nome); dall'Iniziato in su "Apri l'almanacco", la stessa
riflessione con i dodici animali in bronzo che corrono e si fermano sul suo, e le stesse quattro
schede: **Generale** dal rapporto fra l'animale del giorno e quello dell'anno di nascita (Sanming
Tonghui, con la precedenza) e dal guardiano del giorno (Jian Chu), **Amore, Lavoro e Fortuna** dal
dio che il tronco di oggi e' per il tronco del giorno di nascita (i Dieci Dei, Yuanhai Ziping), con
la serie dell'Amore per donna, per uomo e neutra. L'Approfondita aggiunge che cosa conviene col
guardiano, la direzione del Dio della Gioia, che cosa e' il dio e che cosa fa al tema della scheda,
e sulla Fortuna la direzione del Dio della Ricchezza. Il livello viene dal rapporto (Generale) e dal
dio (le altre), con la riga che lo dice; il colore e i due numeri dello He Tu sono quelli
dell'elemento del giorno, e la nota lo dice. Il metodo col punto interrogativo e' quello
dell'almanacco; la riga di domani dice l'animale e il guardiano di domani. Le frasi vengono dal
corpus `docs/corpus/oroscopo_cinese.md` (224 frasi, marcate per il genere) attraverso
`tool/_gen_oroscopo_cinese.py`; il motore sta in `lib/core/horoscope/la_lettura_cinese.dart`. La
settimana e il mese cinesi dicono che sono in arrivo e riportano al giorno; senza data di nascita
si chiede la data. Il catalogo dei piani lo dice: una voce dell'Iniziato e la riga "Oroscopo cinese
del giorno" (Viandante: solo il segno). **Un difetto della regola delle varianti preso dalla Regola
A e riparato prima della consegna**: il corpus proponeva il giorno giuliano modulo le varianti, e
chi era nato Topo leggeva la stessa frase ogni volta che tornava il Cavallo (il ramo torna ogni
dodici giorni); adesso la variante conta i ritorni del caso. Mancano le catture dal Realme: la
Cinese sul gratuito e da Iniziato, la corsa degli animali, le quattro schede.

DOMANDA: "Mi hai consigliato tu di sbloccare in MVP anche vedico e cinese!"; "Se sceglie oroscopo cinese significa che è selezionabile e sbloccato"; "Le risposte devono seguire le regole delle risposte. Ma possiamo usare lo stesso tipo di linguaggio e ci sono delle tradizioni o metodi o pratiche da seguire in particolare? Quindi, il repsonso avverrà con la stessa animazione e con la stessa divisione in generica, amore, lavoro e fortuna?"; domanda girata al fondatore: il metodo dell'Architetto (almanacco Tong Shu e Dieci Dei del BaZi) e "Confermi il Capodanno lunare per il segno cinese e il segno lunare per il vedico?", risposta: "COnfermo tutto."

PROVA: docs/collaudo/ES/regola_a_lettura_cinese.txt
MISURA: Generali col guardiano diverso dall'almanacco pubblicato 0 su 30; schede fuori dal loro gruppo o dal loro livello 0 su 4320; stessa frase al ritorno dello stesso caso, prima (giorno giuliano) 700 ritorni del rapporto su 1200, 720 del guardiano, 600 del colore, dopo 0 su 1200 per ognuna; testi con un difetto di scrittura 0 su 11520 schede; schede a video diverse dalla lettura 0 su 4; frasi del codice diverse dal corpus 0 su 224

## VOCE ES.09, LA TRADIZIONE VEDICA, APERTA

**APERTA IN ATTESA DI VERIFICA**: prodotta e agganciata, da vedere sul Realme. La Vedica si
sceglie e non ha piu' la clessidra. Il Viandante ne vede il segno lunare e l'invito al piano;
dall'Iniziato in su "Interroga la Luna", la stessa riflessione con la corsa dei segni che si ferma
sul segno lunare di nascita, e le quattro schede. **Generale**: la Chandra Bala (la casa in cui
passa la Luna di oggi contata dalla Luna di nascita), la Tara Bala (il nakshatra di oggi contato da
quello di nascita) e il Rahu Kalam della citta'; l'Approfondita aggiunge il pianeta del giorno.
**Amore, Lavoro, Fortuna**: la settima e la quinta, la decima, la seconda e l'undicesima casa
dalla Luna di nascita, con la precedenza delle specifiche (l'ottava su tutto, poi la Luna nella
casa, poi la Luna che la guarda). Livello dalla regola con la sua riga; colore del giorno dal
Brihat Jataka e numero dalla numerologia indiana moderna, e la riga lo dice. La Luna del giorno si
legge all'alba del luogo; l'alba e il tramonto si calcolano col Sole di Meeus al minuto
(`lib/core/astro/l_alba_e_il_tramonto.dart`). Senza l'ora di nascita la Generale dice che la
stella manca e la riga porta ai dati; senza la citta' di oggi il Rahu Kalam la chiede; col segno
lunare incerto si chiede l'ora. La settimana e il mese vedici dicono che sono in arrivo. Le frasi
vengono dal corpus `docs/corpus/oroscopo_vedico.md` (142 frasi) attraverso
`tool/_gen_oroscopo_vedico.py`, con la variante che segue il ritorno del caso come nella Cinese; il
motore sta in `lib/core/horoscope/la_lettura_vedica.dart`. Il catalogo dei piani lo dice. **Da
decidere col fondatore**: i colori del venerdi' e del sabato (il testo dice "variegato" e "nero",
la pratica popolare bianco e blu); il corpus e' una bozza da rileggere. Mancano le catture dal
Realme.

DOMANDA: "Mi hai consigliato tu di sbloccare in MVP anche vedico e cinese!"; "Se sceglie oroscopo cinese significa che è selezionabile e sbloccato"; domanda girata al fondatore: il metodo dell'Architetto (segno lunare siderale Lahiri, Chandra Bala, Tara Bala, Rahu Kalam) e "Confermi il Capodanno lunare per il segno cinese e il segno lunare per il vedico?", risposta: "COnfermo tutto."

PROVA: docs/collaudo/ES/regola_a_lettura_vedica.txt
MISURA: nascite con rashi o nakshatra diverso da Drik Panchang 0 su 20; estremi del Rahu Kalam diversi da Drik 0 su 42, alba e tramonto entro 1,9 secondi dal JPL; schede fuori dal loro gruppo 0 su 480; stessa frase al ritorno dello stesso caso 0 su 219; schede a video diverse dalla lettura 0 su 4; frasi del codice diverse dal corpus 0 su 142

## VOCE ES.10, IL TOOLTIP DI OGNI TRADIZIONE

**APERTA IN ATTESA DI VERIFICA**: prodotta e agganciata (commit `a9e52f66`). Accanto al segno di
ognuna delle sette tradizioni il punto interrogativo apre la nota in quattro parti (che cos'e',
un po' di storia, come si calcola il tuo segno, le fonti), `lib/core/horoscope/le_note_delle_tradizioni.dart`.
Le 62 affermazioni con la loro fonte, la parafrasi e il grado di solidita' sono in
`docs/collaudo/ES/tooltip.txt`; sei sono di solidita' media o debole, e il rapporto le elenca.
Mancano le catture dal Realme di tre note aperte.

DOMANDA: "a fianco dell'emblema dell'oroscopo cinese serve un tooltip che spieghi all'utente dincosa si tratta , tradizione, cenni storici, fonti, ecc."

PROVA: docs/collaudo/ES/tooltip.txt
MISURA: tradizioni senza nota, prima 7, dopo 0 su 7; affermazioni delle note senza fonte, dopo 0 su 62

## VOCE ES.11, LE QUATTRO TRADIZIONI IN ARRIVO: EMBLEMA, SEGNO E CLESSIDRA

**APERTA IN ATTESA DI VERIFICA**: prodotta e agganciata (commit `a9e52f66`). I diciotto webp degli
emblemi in `assets/schede`; la clessidra al posto del lucchetto sulle sei tradizioni non pronte;
toccandone una, in cima l'emblema, il segno calcolato davvero ("Il tuo segno maya è 7 Akʼbʼal"),
il punto interrogativo della nota e "In arrivo". **Sotto non si apre il consulto occidentale**,
che si leggerebbe come suo: c'e' la riga che lo dice e "Torna al tuo oroscopo di oggi". Senza
l'ora la dimora araba non si dice, e il decano o il rashi a cavallo di un confine si dicono
tutti e due. **Otto nomi dei decani** sono letti in una scansione guasta del greco di Efestione
(Gemelli II, Cancro II, Leone II, Scorpione III, i tre del Capricorno, Sagittario III): vanno
riscontrati sull'edizione Pingree (1973) o sulla traduzione di Schmidt (1994) prima di chiudere.
Mancano le catture dal Realme delle quattro.

DOMANDA: domanda girata al fondatore: "A. La figura del segno [...] B. L'emblema e il nome del segno", risposta: "La B."; riga della scheda dell'Architetto: "Le sei tradizioni in arrivo (Vedica, Cinese, Maya, Celtica, Egizia, Araba) portano il lucchetto. Per tua regola il lucchetto è solo del Premium e le arti non ancora pronte hanno la clessidra.", risposta: "In verità seguo e approvo ogni tuo consiglio."; domanda girata al fondatore: "i sei emblemi delle tradizioni [...] Li aggiungo all'ordine ES?", risposta: "Si inseriscili nell'ordine."

PROVA: docs/collaudo/ES/in_arrivo.txt
MISURA: tradizioni col lucchetto, prima 6, dopo 0; webp uguali a quelli del PC, prima 0 su 18, dopo 18 su 18; segni diversi dalla fonte sulle dieci nascite, 0 su 40 (dieci_date.csv)

## VOCE ES.12, GLI AMICI OFFLINE E L'OROSCOPO PER GLI AMICI

**APERTA IN ATTESA DI VERIFICA**: prodotta e agganciata, da vedere sul Realme. In fondo
all'oroscopo c'e' "L'oroscopo per un amico". **Gli amici offline** (`lib/core/amici/amici_offline.dart`)
tengono nome, data, ora e luogo di nascita, stanno sul telefono, se ne vanno con l'account
(prefisso `amici_offline` in `CioCheETuo`) e sono nello scarico dei dati: sono il contenitore che
le altre funzioni di compatibilita' potranno richiamare. Il Viandante vede la voce e il tocco lo
invita al piano; dall'Iniziato si aggiungono fino al tetto del piano, e al tetto compare la spesa
di 100 Eos per un posto in piu'. **L'oroscopo dell'amico**
(`lib/features/amici/l_oroscopo_dell_amico_screen.dart`): si sceglie la tradizione, in cima il suo
segno, sotto le quattro schede del giorno, e "Manda a" apre la card da condividere. L'Occidentale
legge il suo segno solare, e la riga dice che con la carta natale sarebbe piu' sua; la Cinese dal
suo animale; la Vedica dalla sua Luna di nascita, e senza l'ora, nei giorni in cui la Luna cambia
segno, chiede l'ora invece di scegliere a caso. Si parla al neutro, perche' il genere dell'amico
non si sa. **Scelta presa con la risposta consigliata**: gli amici restano sul telefono e non
salgono sul server, come i luoghi e le preferenze; il giorno che l'app diventera' social si
decidera' se e come. Mancano le catture dal Realme della lista, dell'invito, del tetto e delle
tre letture.

DOMANDA: "Ho intenzione di inserire la possibilità ai premium di poter calcolare l'oroscopo per gli amici così da poterlo condividere con gli amici e creare vitalità: l'utente premium potrà inserire data e ora di nascita dell'amico, scegliere la tipologia di oroscopo, scoprire il segno corrispondete e creare l'oroscopo e con la condivisione inviarlo all'amico."; "servirà che l'utente inserisca i dati e il nome dell'amico che verranno memorizzati in un contenitore "amici offline" che potranno essere richiamati nelle altre funzionalità di compatibilità. Ti ricordo che l'app dovrà diventare "Social""; "No, l'utente free non può fare orsocopo per amici, lo vede e se fa click, viene invitato a sottoscrivere abbonamento"; domanda girata al fondatore: "3 per l'Iniziato, 10 per l'Adepto, nessun limite per l'Illuminato [...] 100 Eos per un posto in più", risposta: "ok , approvato".

PROVA: docs/collaudo/ES/regola_a_es04_es12_es15.txt
MISURA: posti per piano diversi da quelli del fondatore, 0 su 4 (0, 3, 10, senza limite), con 100 Eos per un posto in piu'; letture dell'amico mancanti 0 su 9 (tre amici per tre tradizioni, due senza ora con la Luna che cambia segno, dove la Vedica chiede l'ora); giorni del 1990 in cui la data sola basta alla Vedica 205 su 365

## VOCE ES.13, LA CARD CON NOME E DATI DI NASCITA

**APERTA IN ATTESA DI VERIFICA**: prodotta e agganciata (commit `a9e52f66`). La card propria porta
l'emblema del periodo, il nome senza cognome (la prima parola del nome: "Mario Rossi" esce
"Mario"), la data, l'ora e il luogo che l'app conosce, il numero al centro del suo riquadro e
"Scarica l'app: esotericircle.app". Mancano: la card dell'amico (voce ES.12), il segno della
Cinese e della Vedica sulla card quando saranno aperte (ES.08, ES.09), le catture dal Realme.

DOMANDA: "Io nella card da condividere inserirei i dati di nascita e il nome o lo pseudonimo. Non serve il cognome e quindi potrebbero essere anche inventati"

MISURA: card col cognome, dopo 0 (prova su "Mario Rossi"); card senza dati di nascita quando l'app li conosce, dopo 0

## VOCE ES.14, IL NUMERO FORTUNATO CENTRATO NEL SUO RIQUADRO

**APERTA IN ATTESA DI VERIFICA**: prodotta e agganciata (commit `4f7d265a`), misurata in prova
sulla schermata vera, manca la cattura dal Realme, che arriva con la build di prova del blocco.
Padre: ordine DD voce 09, commit `b6188d20`. Il riquadro e' `RiquadroDelNumero`
(`lib/features/horoscope/riquadro_del_numero.dart`), che servira' anche alla Cinese e alla Vedica.

DOMANDA: "Utlima cosa, nel riquadro del numero fortunato, il numero deve essere centrato nel riquadro"

PROVA: docs/collaudo/ES/numero_centrato.txt
MISURA: distanza fra il centro della cifra e il centro del riquadro sull'OroscopoScreen, prima 23,7 punti alla scala 1,0 e 30,5 alla scala 1,3, dopo 0,0 e 0,0

## VOCE ES.15, "ONLINE" NELLA BARRA IN ALTO E I PROSSIMI EVENTI COSMICI NEL PASSPORT

**APERTA IN ATTESA DI VERIFICA**: prodotta e agganciata, da vedere sul Realme; la funzione nuova
del server, `chiEOnline`, si distribuisce con la build di prova. Al centro della barra in alto c'e'
la lucina verde, "Online" e il numero di chi ha l'app davanti adesso (`lib/features/shell/barra_dell_identita.dart`,
`lib/services/server/chi_e_online.dart`). **Il numero lo dice il server**: il telefono chiede ogni
due minuti finche' l'app e' davanti, e smette in pausa; la domanda scrive la presenza di chi
chiede in `users/{uid}/presenza/adesso` (un campo solo, l'istante), e il server conta con un conto
aggregato le presenze degli ultimi due minuti e mezzo (`functions/src/presenza.ts`). Torna un
numero, mai l'elenco di chi c'e'. La presenza sta nel ramo della persona, quindi se ne va con
l'azzeramento dei dati e con l'account senza una riga in piu'; il conto ha il suo indice in
`firestore.indexes.json`, e la privacy policy lo dice (in app e sul sito, data 29 settembre 2026).
Senza rete o senza server si legge la lucina con "Online" e nessun numero, mai un numero
inventato. **"Prossimi Eventi Cosmici"** e' salito in cima al Cosmic Passport: la tessera dice i
due eventi che arrivano prima col loro "fra quanto", dal motore del Calendario, e il tocco apre il
Calendario come faceva la barra. Le prove della regola vecchia sono riscritte con la lapide. Mancano
la distribuzione della funzione e le catture dal Realme della barra col numero e del Passport.

DOMANDA: "in alto nella barra superiore al centro bisogerà inserire "online" con lucina verde e n. di utenti online al posto di Eventi cosmici che andrà in Passport in alto come "Prossimi Eventi Cosmici""

PROVA: docs/collaudo/ES/regola_a_es04_es12_es15.txt
MISURA: al centro della barra "Eventi Cosmici", prima 1, dopo 0; "Online" con la lucina, prima 0, dopo 1; numero a video senza server, dopo 0 (nessuno inventato), col server 1.284 letto "1.284"; eventi in cima al Passport, prima 0, dopo 2, sopra i traguardi (303 contro 463 punti); passo del telefono e del server, 120 secondi tutti e due

## PARTE 2, IL SIGILLO DEL SOGNO, RILIEVI DEL FONDATORE

## VOCE ES.16, IL SIGILLO DEL SOGNO DI MEDORA NON PARLA DI RUNE

**APERTA IN ATTESA DI VERIFICA**: prodotta e agganciata (commit `770cccb2`), manca la cattura
dal Realme, con la build di prova del blocco. Padre: ordine P voce 18, la Runa del Tramonto,
portata nel Sigillo dalla DD.04 quando il Sigillo ruotava fra i Maestri.

DOMANDA: "C'è una cosa grave da aggiungere all'ordine: in screenshot è chiaro, il sigillo del sogno, adesso solo di Medora, parla di Rune!"

PROVA: docs/collaudo/ES/sigillo_senza_rune.txt
MISURA: frasi della schermata del Sigillo con parole di un Maestro che non e' Medora, prima 1 (la riga della Runa del Tramonto), dopo 0 su 85

## VOCE ES.17, UNA SOLA NOTIFICA PER DONO, COL NOME GIUSTO

**APERTA IN ATTESA DI VERIFICA**: prima parte prodotta e agganciata (commit `c9bdfc06`), sul
telefono e sul server, non ancora schierata: le funzioni si schierano insieme alla build di prova
che porta il gestore della push, poi tre sere di osservazione sul Realme in
`docs/collaudo/ES/notifiche.txt`. Padre del doppione: ordine CG voce 16, il tag `dono_1104` che non
sostituiva la locale 1104; e il giro del server ogni quindici minuti non allineato all'orologio
(partiva a :13, :28, :43, :58). L'accento di Calìgo nella testata e nella push si fa con la ES.19,
perche' cambia l'impronta dell'istruzione dei Maestri e vuole la misura dell'attribuzione rifatta.

DOMANDA: "Inoltre mi è arrivata doppia notifica "Caligo ha qualcosa da dirti" alle 22:40 e la notifica del sigillo del giorno alle 22.30."; dal rapporto dell'ordine ET, LE COSE CHE ASPETTANO TE, punto 6: "Il nome di Caligo senza accento nella testata del dominio e del LIVE"; domanda girata al fondatore: "Il nome Calìgo con l'accento nella testata e nella push lo metto in ogni caso. Confermi?", risposta: "Confermo tutto".

MISURA: in prova, notifiche per la sera del 28 settembre (locale alle 22:30, due push dello stesso Dono), prima 3, dopo 1; titolo del Sigillo del Sogno, prima a nome del Maestro della push, dopo "Medora"

## VOCE ES.18, IL SIGILLO DEL SOGNO CONTROLLATO DA CIMA A FONDO, RISPOSTE COMPRESE

**APERTA IN ATTESA DI VERIFICA**: controllato e curato nel codice, da vedere sul Realme.
L'ispezione, con le quattro domande del fondatore su ogni passo, ha trovato quattordici punti;
curati nel codice:
- la card chiusa della Runa del Tramonto prometteva che il Sigillo l'avrebbe nominata, falso dalla
  ES.16 (padre P voce 18, reso falso da ES.16);
- "il cielo notturno reale" in quattro punti: le stelle della scena sono disegnate con un seme
  fisso, reali sono la Luna nella sua fase e il segno (PROVENIENZA IGNOTA);
- il foglio "Da dove nasce" scriveva "stanotte è un congiunzione", "un quadratura", "un nessun
  aspetto" (padre CE voce 13) e non diceva che le righe di "Oggi" e "Se guardi indietro" vengono
  dalla Luna di nascita (padre EE.04 ed EH.01);
- la riga della figura diceva "ancora 3 notti" quando ne restavano 2 (padre EH voce 01);
- "esattamente di fronte" su un aspetto calcolato per segno intero (padre CE voce 13);
- tre nomi per lo stesso Dono, "Rito della Notte", "RITO DEL SOGNO", "Sigillo del Sogno": adesso
  uno solo (PROVENIENZA IGNOTA);
- al compimento il Sigillo e l'Arcano dell'Alba, di Medora dall'ordine DT voce 15, suonavano con la
  voce di Caligo e di Aura (padre DT voce 15);
- la formula "ti mostra la finestra di oggi" di Medora prometteva una previsione anche sul Sigillo,
  che guarda indietro (PROVENIENZA IGNOTA);
- fra mezzanotte e le cinque la riga del respiro spariva e il saluto cambiava: ora vale il giorno
  del rito, come per la parola dell'Alba (padre DA voce 06, EH voce 01);
- la riga del respiro, che viene dalla meditazione di Aura, ora lo dice;
- con Riduci Movimento l'invito diceva "Alza il telefono verso il cielo";
- il ricordo diceva che il Sigillo raccoglie un sogno raccontato, falso dalla CB.01.
**Le risposte, lette a mano** (docs/collaudo/ES/sigillo_risposte_*.md, otto saluti diversi per due
nascite, il controller vero della chat e Gemini): Medora chiudeva con arcani mai estratti,
"l'Arcano della Giustizia", "l'arcano del Carro", uno per giro in tre giri. La causa era nella regola
della chiusura dei Maestri, che chiedeva "il nome proprio di una runa, di un segno o di un arcano"
(padre EK voce 02): ora un arcano o una runa solo se sono già usciti. Dopo, zero arcani inventati su
sedici risposte in due giri. Tolte anche le due frasi d'attacco di Medora con "carta", che il modello
leggeva come un arcano. **Il Cammino**: su 165 "cosa apre" dei Traguardi, 99 nominano funzioni che
non esistono, 31 sono dubbi; nessun traguardo sblocca niente (docs/collaudo/ES/cosa_apre.txt);
arrivavano al Maestro, che li prometteva. Ora il Maestro riceve il nome del passo e non la promessa;
il corpus del fondatore non è stato toccato. **Da decidere col fondatore, scelta consigliata già
applicata**: il Sentiero del Cammino del gesto "sogno" resta quello di Caligo (spostarlo cambierebbe
i traguardi già raccolti); le 99 promesse del corpus vanno riscritte da lui o tenute come nomi dei
passi. Mancano le catture dal Realme del foglio e della card.

DOMANDA: "code deve controllare ancora tutto il funzionamento del sigillo del sogno e le risposte!"; le domande del fondatore da farsi su ogni funzionalità, del 27 settembre: "trasparenza, coerenza, verità e funzionalità", "c'è qualcosa di inventato?".

PROVA: docs/collaudo/ES/regola_a_sigillo.txt
MISURA: testi del Sigillo che dicono "cielo notturno reale" da 4 a 0; fogli con l'aspetto sgrammaticato da 4 su 6 a 0 su 6; righe della figura con le notti sbagliate 0 su 115 (prima sbagliata ogni volta che restavano 2 notti o piu'); nomi del Dono da 3 a 1; Doni che suonano con la voce di un altro Maestro da 2 su 2 a 0; arcani inventati nelle risposte di Medora da 3 in 3 giri a 0 su 16 risposte in 2 giri; "cosa apre" che arrivano al Maestro da 165 su 165 a 0 su 165

## PARTE 3, LE NOVE VOCI APERTE DELL'ORDINE ET

## VOCE ES.19, IL BANCO DELLE TRENTA DOMANDE ARRIVA A 30 SU 30 (DALLA ET.01)

**APERTA IN ATTESA DI VERIFICA**: le reti corrette sui 101 giudizi dati a mano del giro 6 del
banco, da misurare col banco delle trenta domande e la lettura alla cieca. **La rete della prima
frase** (`lib/core/chat/la_posizione_della_lettura.dart`) riconosce adesso il si' detto con la cosa
(*"l'amore è presente"*, *"c'è ancora un legame"*, *"la soglia del ritorno è aperta"*, *"leggo
successo"*, *"avrà esito positivo"*), il no detto con un verbo (*"le rune non rivelano un
tradimento"*, *"non è il momento"*), *"Il presagio dice"* e le lame come lettura, e la massima "non X,
ma Y" quando Y e' un'azione (*"Non cercare di dimenticare, ma di trasformare"*) o quando il si' e'
gia' detto. **"È possibile" passa solo con la sua condizione** (*"è possibile, a patto che..."*), cioe'
nella forma del "sì, se" che il fondatore ha approvato; da solo resta una prudenza e resta scartato:
qui il giudice alla cieca del giro 2 e i giudizi a mano del giro 6 si contraddicevano, e la scelta e'
presa con la risposta consigliata. **La rete delle certezze** (`le_certezze_del_maestro.dart`): il
futuro detto sotto *"le rune dicono che"* e' lettura, *"potrai"* e' una possibilita', il futuro dopo
una condizione o dopo un consiglio (*"Concentra il tuo intento e le risorse seguiranno"*) e' una
conseguenza. Mancano: il banco delle trenta domande (circa 1,4 dollari) e la lettura alla cieca, per
il 30 su 30 per Maestro e canale.

DOMANDA: dalla ET.01: "Bisogna fare delle prove, 30 domande per ogni maestro, con domande classiche q più frequenti. Gli utenti faranno domande personali e anche intime nella maggior parte dei casi. Ma anche per la fortuna e lavoro."; domanda girata al fondatore: "Ritocchi alle reti che scartano le risposte dirette (il sì detto senza "sì", il no detto con "non", il "sì, se" sulla coppia): entrano, perché senza non si arriva a 30 su 30. Confermi?", risposta: "Confermo tutto".

PROVA: docs/collaudo/ES/regola_a_blocco_es19_es37.txt
MISURA: sui 101 casi scartati al giro 6 e giudicati a mano (docs/collaudo/ES/giro6_reti.json), misurati col codice di prima (commit 78d1388c) e con quello di oggi: risposte dirette che la rete della prima frase scarta, prima 28 su 30, dopo 5 su 30; prime frasi vaghe che lascia passare, prima 0 su 14, dopo 0 su 14; certezze apparenti che la rete delle certezze prende, prima 12 su 26, dopo 7 su 26; certezze vere che manca, prima 1 su 30, dopo 1 su 30; le tre certezze rimaste nelle finali del giro 6 la rete le prende sul loro testo, prima e dopo 3 su 3 (al banco erano sfuggite perche' non stavano nella parte guardata)

## VOCE ES.20, VOCE, TESTO A VIDEO E CHAT CON LE STESSE PAROLE (DALLA ET.02)

**APERTA IN ATTESA DI VERIFICA**: prodotta e agganciata, da vedere sul Realme. La risposta detta a
voce nel LIVE porta un segno, `ChatMessage.dettoNelLive`, che si salva col messaggio sul server e si
rilegge riaprendo la conversazione; sotto una risposta col segno la chat non aggiunge l'invito a
tornare (`ConsiglioFinale.invitoSotto`), come ha confermato il fondatore. La chat scritta resta com'era.
Manca la cattura dal Realme della chat dopo un LIVE, e la voce ritrascritta col microfono del PC.

DOMANDA: dalla ET.02: "Deve anche verificare che quello che il maestro dice corrisponda a quello che ha detto."; domanda girata al fondatore: "Invito a tornare nella chat del LIVE: esce, perché la chat deve dire solo quello che dice la voce. Confermi?", risposta: "Confermo tutto".

PROVA: docs/collaudo/ES/regola_a_blocco_es19_es37.txt
MISURA: sotto l'ultima risposta detta nel LIVE, invito a tornare in chat prima 1 su 1 (Realme, Calìgo), dopo 0 su 1 in prova, anche riaprendo la conversazione; nella chat scritta l'invito resta, 1 su 1

## VOCE ES.21, DOMANDE SIMILI DI FILA, ZERO RIPETIZIONI (DALLA ET.03)

**APERTA IN ATTESA DI VERIFICA**: la rete e' tarata sui giudizi alla cieca, da misurare col banco.
Le seconde di coppia che ripetevano la prima non ricalcavano parola per parola, ridicevano la stessa
cosa con altre parole, e la rete dell'ordine EN voce 06 non le vedeva. **Dentro la stessa rete**
(`LaRispostaRipetuta.ridiceLaPrecedente`, una porta sola): si confrontano le prime tre frasi della
risposta di prima e di quella nuova, senza le parole delle due domande e senza le parole di tutti i
giorni dei Maestri; da 0,4 in su la risposta si chiede di nuovo una volta, nominando quella di prima.
La soglia e' tarata sulle 240 seconde di coppia giudicate alla cieca in quattro fasi del banco
(`docs/collaudo/ES/coppie_ripetute.json`, `tool/le_coppie_ripetute.py`). Manca il banco delle trenta
domande con la lettura alla cieca delle coppie, e le coppie nel LIVE sul Realme.

DOMANDA: dalla ET.03: "Ho provato a fare Domande simili consecutive e le risposte, non solo non erano adeguate [...]"

PROVA: docs/collaudo/ES/regola_a_blocco_es19_es37.txt
MISURA: sulle 240 seconde di coppia giudicate alla cieca, ripetizioni prese dalla rete prima 0 su 26 (la rete parola per parola), dopo 13 su 26; seconde buone chiamate ripetute, dopo 2 su 214

## VOCE ES.22, LA TRASCRIZIONE DEL LIVE: NESSUNA DOMANDA VUOTA E LE PAROLE GIUSTE (DALLA ET.04)

**APERTA IN ATTESA DI VERIFICA**: prodotta e agganciata, non ancora misurata. L'istruzione di chi
trascrive dice adesso di che cosa parla di solito la persona e quale lettura scegliere quando un suono
se ne presta a due, con l'esempio del difetto visto (`LaTrascrizione.frasiDiSensoCompiuto`, un
esempio solo: un elenco il modello lo ricopierebbe, come ha fatto con l'elenco dei nomi). Il banco della trascrizione
(`tool/banco_trascrizione_es22.dart`) manda le venti domande del collaudo del LIVE, dette dalla voce
italiana di Windows pulite e "da stanza" (`tool/le_domande_dette.py`), con l'istruzione di prima e con
quella nuova, allo stesso modello del telefono. Mancano: la scelta dell'istruzione misurata al banco e
la prova sul Realme col microfono, venti domande.

DOMANDA: dalla ET.04: "Confermi le mie tre scelte e l'ordine per la trascrizione, insieme alla ER.01?", risposta: "Confermo, dobbiamo risolvere tutto."; domanda girata al fondatore: "Trascrizione sbagliata ("Ma mi ama ancora" diventa "Ma mia, ma ancora"): si corregge in questo ordine. Confermi?", risposta: "Confermo tutto".

PROVA: tool/banco_trascrizione_es22.dart
MISURA: domande trascritte parola per parola giuste sul Realme, prima 12 su 17 (ordine ET), dopo da misurare

## VOCE ES.23, QUATTRO FRASI QUANDO LA DOMANDA HA PIÙ PARTI, SENZA PERDERE IL MERITO (DALLA ET.06)

**APERTA IN ATTESA DI VERIFICA**: nessun codice nuovo in questa voce; il merito delle risposte a
piu' parti si misura col banco `DOMANDE=er12` dopo le reti della ES.19, che toccano le stesse
risposte, e con la lettura alla cieca (l'ordine chiede 23 su 36).

DOMANDA: dalla ET.06: il consiglio dell'Architetto "ER.12: quattro frasi quando la domanda ha più parti.", risposta: "Confermo, dobbiamo risolvere tutto."

PROVA: docs/collaudo/ET/live_quattro_frasi.txt
MISURA: nel merito alla cieca, prima 20 e 18 su 36 (ordine ET), dopo da misurare col banco

## VOCE ES.24, LE RUNE: VIA LE GUARDIE SULLA PRIMA FRASE (DALLA ET.07)

**APERTA IN ATTESA DI VERIFICA**: prodotta e agganciata, da misurare col banco delle rune. Le
quattro guardie sulla prima frase della lettura delle rune sono uscite (le immagini, la posizione
scelta e non detta, la formula al posto del gesto, la frase che non dice "inBreve"), con le loro regole;
restano quelle sulle pietre (il nome, la posizione, la frase sulla domanda, la cosa chiesta), la
cornice ricopiata, gli astri e il confine. La richiesta al modello chiede ancora la prima frase
diretta. Le prove che pretendevano le guardie tolte sono riscritte con la lapide. Mancano il banco delle
rune (le chiamate e il tempo per lettura) e l'attesa sul Realme su dieci gettate.

DOMANDA: dalla ER.01: "Le persone vogliono risposte dirette, Senza tanti giochi di parole e cercano consigli e guide anche su domande generiche."; domanda girata al fondatore: "Rune: togliere le guardie sulla prima frase, perché raddoppiano le chiamate e il tempo del modello senza portare risposte più dirette; restano quelle sulle pietre. Confermi?", risposta: "Confermo tutto".

PROVA: docs/collaudo/ES/regola_a_blocco_es19_es37.txt
MISURA: guardie sulla prima frase delle rune, prima 4, dopo 0; letture di prova scartate per la prima frase, prima 4 su 4 (immagini, posizione non detta, formula, inBreve), dopo 0 su 4; chiamate per lettura al banco, prima 56 per 24 letture, dopo da misurare

## VOCE ES.25, IL VIAGGIO PRENDE POSIZIONE NELLA PRIMA FRASE, 20 SU 20 (DALLA ET.08)

**APERTA IN ATTESA DI VERIFICA**: la guardia corretta sui giudizi alla cieca, da misurare col
banco del Viaggio. La prima frase che rimanda la domanda riconosce adesso anche le formule vaghe che
reggevano alle guardie (il consiglio astratto, la decisione annunciata e non detta, la massima, la
condizione che non si puo' fare, le due strade che la domanda non ha): `LeGuardieDelResponso._vaga`.
Tarata sul giro 3 della lettura alla cieca e provata sul giro 1, che non ha guardato. Manca il banco
del Viaggio con la lettura alla cieca, per il 20 su 20, e la cattura di una discesa dal Realme.

DOMANDA: dalla ET.08: il consiglio dell'Architetto "ER.02: sì alla riserva che prende posizione, come la propone Code.", risposta: "Confermo, dobbiamo risolvere tutto."

PROVA: docs/collaudo/ES/regola_a_blocco_es19_es37.txt
MISURA: prime frasi senza posizione (giudizio alla cieca) che la guardia chiede di nuovo, giro 3 prima 0 su 21, dopo 20 su 21, buone chiamate vaghe prima 0 e dopo 0 su 51; giro 1, non guardato, prima 4 su 22, dopo 12 su 22, buone chiamate vaghe prima 0 e dopo 3 su 50

## VOCE ES.26, IL RETRO DELLE SCHEDE A 402 PUNTI (DALLA ET.09)

**CHIUSA.** Le quattro catture a 402 punti in `docs/collaudo/ES/realme/` (`es26_retro_verticale_402.jpg`,
`es26_retro_orizzontale_402.jpg`, `es26_retro_quadrata_402.jpg`, `es26_retro_dominio_402.jpg`); la
guardia della ET.09 misura adesso a 360 e a 402 punti, vista rossa alle due larghezze. Lo schermo del
Realme: prima densita' 480 e 360 punti, durante "Larghezza minima" 402 (densita' 429), dopo di nuovo
480 e 360 punti, riletto da adb.

DOMANDA: dalla ET.09: "Inserisci anche che i testi nel rovescio delle schede sono minuscoli, quasi illeggibili."; domanda girata al fondatore: "Retro a 402 punti: Code cambia la misura dello schermo del Realme per la prova e poi la rimette com'era. Confermi?", risposta: "Confermo tutto".

PROVA: docs/collaudo/ES/retro_402.txt
MISURA: schede col testo del retro rimpicciolito in home a 402 punti, prima non misurate (la ET.09 misurava a 360), dopo 0 su 67; il testo del retro in home a 402 punti e' quello dei domini, 15,9 punti nell'orizzontale, 15,2 nel quadrato, 13,0 nel verticale, come nei domini

## VOCE ES.27, L'INTRO REGISTRATA SUL REALME (DALLA ET.10)

**CHIUSA.** La registrazione dello schermo e dell'audio dal Realme,
`docs/collaudo/ES/realme/es27_intro_intera.mp4`, allineata al sorgente con correlazione 0,994; le
impostazioni prima, durante e dopo in `docs/collaudo/ES/intro_realme.txt`.

DOMANDA: "Ho creato una nuova cersione della intro da sostituire e la 5"; domanda girata al fondatore: "Intro sul Realme: Code riaccende le animazioni solo per registrare e poi le rispegne. Confermi?", risposta: "Confermo tutto".

PROVA: docs/collaudo/ES/intro_realme.txt
MISURA: durata dell'intro registrata 14,0 secondi contro i 14 del sorgente; scale delle animazioni del Realme prima 0,0, durante 1,0, dopo 0,0 su tutte e tre

## PARTE 4, DIFETTI E MIGLIORIE TROVATI DALL'ARCHITETTO, APPROVATI DAL FONDATORE

## VOCE ES.28, L'INDICATORE DAL CIELO VERO

**APERTA IN ATTESA DI VERIFICA**: prodotta e agganciata (blocco 2 dell'ordine ES). Il livello di ogni scheda nasce dagli aspetti del giorno che parlano
al dominio, armonici +1 e tesi -1, pesati dall'orbita, o senza carta dalla Luna di oggi
nelle case solari (`lib/core/horoscope/il_livello_del_cielo.dart`); la scala resta da due a
cinque; sotto il livello la riga dice da dove viene. La card e la chiamata del mattino
leggono lo stesso valore della scheda. Mancano la Cinese e la Vedica (ES.08, ES.09) e le
catture dal Realme.

DOMANDA: riga della scheda: "L'indicatore del livello della giornata sembra una misura ma non viene dal cielo, nemmeno per chi ha la carta natale."; domanda girata al fondatore: il metodo della Cinese e della Vedica, risposta: "COnfermo tutto."

PROVA: docs/collaudo/ES/indicatore.txt
MISURA: schede il cui livello non dipende dal cielo, prima 48 su 48, dopo 0 su 48 nell'Occidentale

## VOCE ES.29, NUMERO FORTUNATO E COLORE CON UNA REGOLA DICHIARATA

**APERTA IN ATTESA DI VERIFICA**: prodotta e agganciata (blocco 2 dell'ordine ES). Il numero e' il giorno personale della numerologia (Hans Decoz),
senza data di nascita il giorno universale; il colore e' quello di William Lilly (Christian
Astrology, 1647, confrontato con Agrippa) del pianeta del passaggio piu' stretto, o senza carta
del signore del segno della Luna (domicili di Tolomeo); una riga sotto dice la regola
(`lib/core/horoscope/il_numero_e_il_colore.dart`). La tavolozza di colori per segno del corpus
(`horoscope_data.dart`, generato da docs/corpus/oroscopo.md) non la chiama piu' nessuno: il
corpus e' del fondatore e non si tocca senza di lui. Mancano Cinese e Vedica e le catture.

DOMANDA: riga della scheda: "Numero e colore con una regola dichiarata, oppure via. Per esempio il colore del pianeta che oggi pesa di più e un numero dalla numerologia del giorno incrociata con la data di nascita."

PROVA: docs/collaudo/ES/numero_colore.txt
MISURA: numeri e colori senza una regola dietro, prima 30 su 30, dopo 0 su 30 (dieci persone in tre giorni, Occidentale)

## VOCE ES.30, IL PUNTO INTERROGATIVO DEL METODO

**APERTA IN ATTESA DI VERIFICA**: prodotta e agganciata (commit `a9e52f66`) per le quattro schede del
giorno nell'Occidentale: il punto interrogativo accanto al livello apre la nota del metodo
(`lib/core/horoscope/il_metodo_del_responso.dart`), che cambia coi dati di nascita e **dice anche
cio' che oggi non viene dal cielo**: il livello da uno a cinque, il numero e il colore del giorno
nascono dal segno e dalla data (la voce ES.28 portera' il livello dal cielo vero, e la nota
cambiera' con lei). Mancano le note della settimana, del mese, dell'anno, della Cinese e della
Vedica, che nascono con le loro voci, e le catture dal Realme.

DOMANDA: riga dell'Architetto: "manca il punto interrogativo del metodo"; briefing, sezione 48, "Tooltip di trasparenza metodologica".

MISURA: schede del giorno senza nota del metodo, prima 4, dopo 0 su 4

## VOCE ES.31, L'INVITO A COMPLETARE ORA E LUOGO DI NASCITA

**APERTA IN ATTESA DI VERIFICA**: prodotta e agganciata (commit `a9e52f66`). **Il fatto dell'ordine
era in parte superato**: dall'Oroscopo ai dati di nascita si arrivava gia' dall'ordine CS voce S1,
col pulsante nella nota sotto le quattro schede, cioe' dopo il consulto e fuori vista. Adesso
sotto "Interroga il cielo" c'e' la riga "Con la tua ora e il tuo luogo di nascita questa
lettura parlerà al tuo cielo" (o "...anche alle tue case" a chi manca solo l'ora), che porta
alla schermata dei dati; a chi ha la carta completa non c'e'. **Sotto il gesto e non sopra**:
sopra spingeva "Interroga il cielo" sotto la piega del Realme. Manca la registrazione dal
Realme dall'invito alla scheda personalizzata.

DOMANDA: riga della scheda: "Un invito dentro l'Oroscopo a completare ora e luogo di nascita".

MISURA: tocchi dall'invito alla schermata dei dati di nascita, 1; inviti mostrati a chi ha gia' la carta completa, dopo 0; gesto "Interroga il cielo" sotto la piega del Realme con l'invito, 0 (finisce a 673 punti su 797)

## VOCE ES.32, L'ORA D'ORO E LA NOTIFICA DEL RAHU KALAM

**APERTA IN ATTESA DI VERIFICA**: prodotta e agganciata (blocco 2 dell'ordine ES). Per chi ha la carta natale la scheda Generale dice l'istante del giorno
in cui la Luna forma un trigono, un sestile o una congiunzione esatta al Sole, a Venere o a
Giove di nascita (`lib/core/horoscope/l_ora_d_oro.dart`, con la Luna di Meeus intera); un
giorno senza non mostra niente, e succede circa un giorno su due. **Le due notifiche ci sono**
(`lib/core/horoscope/le_chiamate_del_cielo.dart`): un quarto d'ora prima dell'ora d'oro, nei
giorni in cui c'e', per chi ha la carta natale; e all'alba il Rahu Kalam del giorno con le sue ore
nella citta' della persona, per chi ha aperto la lettura vedica almeno una volta. Si programmano sette
giorni alla volta a ogni avvio, annullando prima le quattordici di prima; ognuna ha il suo canale
(`ora_d_oro`, `rahu_kalam`) e il suo interruttore nel menu Notifiche, accese di partenza per la regola
del fondatore sulle notifiche. Mancano le catture dal Realme e una notifica vista arrivare.

DOMANDA: riga della scheda: "L'ora d'oro di oggi. Dall'orario esatto degli aspetti della Luna ai punti natali si ricava un momento preciso della giornata"; domanda girata al fondatore: "Il Rahu Kalam [...] È il contrario della nostra ora d'oro", risposta: "COnfermo tutto."

PROVA: docs/collaudo/ES/ore_d_oro.csv
MISURA: scarto medio dal JPL DE440s su cinque ore d'oro 0,18 minuti; ore d'oro mostrate senza un aspetto vero, 0 su 6 giorni che non ne hanno; notifiche dell'ora d'oro e del Rahu Kalam, prima 0 canali, dopo 2 (docs/collaudo/ES/regola_a_blocco_es19_es37.txt); su 77 giorni di controllo, avvisi dell'ora d'oro sbagliati o mancanti 0 (35 giorni con l'ora d'oro, 42 senza e nessun avviso); avvisi del Rahu Kalam a chi non ha mai letto la Vedica 0, dopo la prima lettura 7 su 7 giorni

## VOCE ES.33, IL CIELO CHE SI ACCENDE SULLA FRASE

**APERTA IN ATTESA DI VERIFICA**: prodotta e agganciata (blocco 2 dell'ordine ES). Per chi ha la carta natale, sotto il responso c'e' la riga del passaggio
che il testo nomina per primo; un tocco apre la ruota della carta col pianeta di oggi e la
linea dell'aspetto al punto natale, un altro la chiude
(`lib/features/horoscope/la_ruota_del_passaggio.dart`). Il testo del responso resta un
paragrafo solo, e il tocco sul testo continua a completarne la scrittura: per questo la riga
sta sotto. Manca la registrazione dal Realme.

DOMANDA: riga della scheda: "Il cielo che si accende sulla frase. Toccando la riga del transito, una piccola ruota mostra il pianeta di oggi che attraversa la casa nominata."

MISURA: ruote che mostrano un pianeta, una casa o un aspetto diversi dalla frase, 0 su 80 (venti giorni per quattro domini)

## VOCE ES.34, LA RAGIONE PER TORNARE DOMANI

**APERTA IN ATTESA DI VERIFICA**: prodotta e agganciata (blocco 2 dell'ordine ES). In fondo all'Oroscopo, dopo il consulto, una riga calcolata dice dove
sara' la Luna domani: nella casa natale con la carta, nella casa solare senza
(`lib/core/horoscope/il_domani.dart`), e di che cosa parlera' il cielo. Cinese e Vedica con le
voci ES.08 ed ES.09. Manca la cattura dal Realme.

DOMANDA: riga della scheda: "Ti propongo un'anticipazione calcolata in fondo"; Linee Guida, sezione 12.1.

PROVA: docs/collaudo/ES/domani.txt
MISURA: chiusure dell'Oroscopo senza ragione per tornare, prima 1, dopo 0; anticipazioni che non corrispondono al giorno dopo, 0 su 30 (Occidentale)

## VOCE ES.35, LA RIVELAZIONE DEL SEGNO

**APERTA IN ATTESA DI VERIFICA**: prodotta e agganciata, da vedere sul Realme. La prima volta che
si sceglie la Cinese o la Vedica compare la figura in bronzo del segno che si accende, e la frase
"Il tuo segno cinese è il Cavallo" (`lib/features/horoscope/la_rivelazione_del_segno.dart`), con
"Condividi" (la tessera come immagine, dalla porta della condivisione) e "Continua". Una volta sola
per tradizione, segnata sul telefono; con Riduci Movimento la figura e' gia' li'; col segno incerto
(la Vedica senza ora nei giorni in cui la Luna cambia segno) la rivelazione aspetta. Mancano la
registrazione dello schermo dal Realme e una condivisione vera.

DOMANDA: riga dell'Architetto: "La prima volta che la persona sceglie Cinese o Vedica, la figura in bronzo appare con la sua animazione e la frase "Il tuo segno cinese è il Cavallo". È il momento da condividere."

PROVA: docs/collaudo/ES/regola_a_blocco_es19_es37.txt
MISURA: rivelazioni alla prima scelta, prima 0, dopo 2 su 2 (Cinese, Vedica), con la frase uguale a quella del segno; rivelazioni alla seconda scelta, dopo 0

## VOCE ES.36, TRE TRADIZIONI SU TRE

**APERTA IN ATTESA DI VERIFICA**: prodotta e agganciata, da vedere sul Realme. Sotto le quattro
schede del giorno, dal primo piano a pagamento e con la data di nascita, la tessera "I tre cieli di
oggi" dice per ogni dominio se le tre tradizioni sono d'accordo (*"Oggi tre tradizioni su tre vedono
il lavoro favorevole"*) e, se non lo sono, chi vede cosa (*"Sul lavoro le tre tradizioni non sono
d'accordo: favorevole per l'occidentale e la cinese, in salita per la vedica."*). L'esito viene dal
livello che ogni scheda porta gia': 4 e 5 favorevole, 3 in equilibrio, 2 in salita
(`lib/core/horoscope/i_tre_cieli.dart`). Al Viandante non si mostra: direbbe cio' che vedono letture
che non sono sue. Manca la cattura dal Realme.

DOMANDA: riga dell'Architetto: "Quando occidentale, cinese e vedica danno lo stesso esito su un dominio, lo si dice: "Oggi tre tradizioni su tre vedono il lavoro favorevole". Se non sono d'accordo, si dice anche questo."

PROVA: docs/collaudo/ES/regola_a_blocco_es19_es37.txt
MISURA: in sessanta giorni veri, domini con le tre tradizioni d'accordo 55, in disaccordo 185, esiti o frasi diversi dalla regola scritta nella prova 0 su 240

## VOCE ES.37, IL SIGILLO "TRE CIELI"

**APERTA IN ATTESA DI VERIFICA**: prodotta e agganciata, da vedere sul Realme. **Il Sigillo dei Tre
Cieli e' un Sigillo a parte, non un gradino dei Sentieri**: i gradini sono i 165 del corpus del
fondatore, con le loro posizioni e i loro Eos, e il corpus non si cambia senza il suo si'. Si accende
il giorno rituale in cui si leggono la Occidentale, la Cinese e la Vedica, si conta, e si mostra in
fondo alla tessera dei tre cieli: acceso, o quali tradizioni mancano oggi
(`lib/core/horoscope/il_sigillo_dei_tre_cieli.dart`). Non conia Eos. Scelta presa con la risposta
consigliata: se il fondatore lo vuole fra i gradini, basta aggiungerlo al corpus. Manca la cattura dal
Realme.

DOMANDA: riga dell'Architetto: "un Sigillo "Tre Cieli" per chi legge tutte e tre le tradizioni nello stesso giorno."

PROVA: docs/collaudo/ES/regola_a_blocco_es19_es37.txt
MISURA: il Sigillo acceso dopo la terza tradizione letta nello stesso giorno, prima non esisteva, dopo acceso 1 su 1 e contato 1 giorno; acceso con due tradizioni, 0
