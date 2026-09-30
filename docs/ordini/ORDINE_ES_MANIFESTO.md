# ORDINE ES, L'OROSCOPO COMPLETO, IL SIGILLO DEL SOGNO E LE VOCI APERTE DELL'ORDINE ET

**Sigla:** ES, verificata sul ramo il 28 settembre 2026 sul commit
`acc38528`: in `docs/ordini` l'ultimo manifesto era `ORDINE_ET_MANIFESTO.md`,
in `docs/collaudo` l'ultima cartella ET; nessun `ORDINE_ES` ne' `docs/collaudo/ES`.
**Data dell'ordine:** 28 settembre 2026, in quattro pezzi; il testo dei quattro
pezzi sostituisce ogni versione precedente dell'ordine ES e la ES Aggiunta.
**Ramo:** `claude/esoteric-circle-master-order-e798aj`.
**Partenza:** commit `acc38528`, col cancello di GitHub verde su quel commit
(dodici controlli su dodici e il segno `refs/verde/acc38528...`). **Questo
ordine non consegna niente**: le build le ordina il fondatore. **E il 30 settembre
il fondatore l'ha ordinata**: la build Android con App Distribution e il commit pronto
per Codemagic, senza consegne parziali (*"Devi finire tutto, non fare consegne
parziali, non m'interessa a che ora finisci"*). Nella stessa sera ha aggiunto le
sue richieste sull'Oroscopo, integrate nelle voci ES.01, ES.02, ES.03, ES.04, ES.08,
ES.09 ed ES.12, e il suono del responso, la voce ES.38.

Le nove voci aperte dell'ordine ET proseguono qui (PARTE 3): ET.01 nella
ES.19, ET.02 nella ES.20, ET.03 nella ES.21, ET.04 nella ES.22, ET.06 nella
ES.23, ET.07 nella ES.24, ET.08 nella ES.25, ET.09 nella ES.26, ET.10 nella
ES.27; nel manifesto ET ognuna ha la riga che lo dice.

**La stima dichiarata al fondatore prima di cominciare**: circa 9-12 giorni
di lavoro, in otto blocchi. La sua scelta: *"Tutto, a blocchi"*, prima le
voci rapide e sicure, poi l'Oroscopo occidentale, piani, Cinese e Vedica,
amici, online, Sigillo, infine le voci ET, con commit e spinta a ogni voce
chiusa.

VOCI_TOTALI: 38
VOCI_CHIUSE: 7
VOCI_APERTE: 31
VOCI_DA_FARE: 0

Le prove stanno in `docs/collaudo/ES/`, quelle del telefono di prova
(Realme 767f596c) in `docs/collaudo/ES/realme/`. **Una voce che si vede a
schermo e' chiusa solo con la sua cattura dal Realme**, le animazioni con la
loro registrazione dello schermo.

---

## PARTE 1, L'OROSCOPO, RICHIESTE DEL FONDATORE

## VOCE ES.01, BREVE E APPROFONDITA, SENZA MEDIA

**CHIUSA.** Vista sul Realme il 30 settembre 2026 sera, build di prova dal commit `6e8fddb0`:
il selettore dice "Breve" e "Lunga" (`docs/collaudo/ES/realme/es_final_selettore_breve_lunga.jpg`),
e la Lunga aggiunge davvero sulla Settimana (`es_final_settimana_lunga_giorni.jpg`) e sull'Anno
(`es_final_anno_lavoro_breve.jpg` contro `es_final_anno_lavoro_lunga.jpg`). Le profondita' sono
due, Breve e Lunga: la Media non c'e' piu' nel codice, e **dal 30 settembre "Approfondita" si
chiama "Lunga"** (`AnswerDepth.profonda`, e la pagina dei piani "Breve o Lunga"), come ha deciso il
fondatore. Con la carta natale la Lunga del Giorno resta com'e' (tre passaggi del cielo). Senza,
aggiunge dove sono oggi la Luna e il corpo del dominio (il Sole per il Generale, Venere per l'Amore,
Marte per la Carriera, Giove per la Fortuna) e in quale casa solare del segno
(`lib/core/horoscope/il_cielo_del_segno.dart`). **Il pulsante della profondita' sta su ogni
scheda**, come ha chiesto il fondatore il 30 settembre: il Giorno, l'Anno (quattro schede), la
Settimana e il Mese (quattro campi), la Cinese e la Vedica, l'oroscopo di un amico. La Lunga e' dei
piani a pagamento (`PlanCatalog.haProfondita`); al Viandante la voce ha il lucchetto e l'invito al
piano, anche sull'Anno comprato con gli Eos. La scelta vale per il campo, in ogni periodo: chi
sceglie la Lunga per il Generale la ritrova nel Generale dell'Anno. Cosa aggiunge la Lunga: nella
Settimana e nel Mese le righe dei giorni (sette, e tre giorni chiave nel Mese), ognuna con la sua
lettura e sotto il suo "da dove viene"; nell'Anno i testi del Sole e della Luna nel Generale, di
Saturno nel Lavoro, la seconda lettura del caso nell'Amore e nella Fortuna; nella Cinese e nella
Vedica la seconda lettura dello stesso caso e le righe del giorno. Guardia
`la_profondita_sta_su_ogni_scheda` (otto prove), rossa su otto innesti.

DOMANDA: "io terrei breve e approfondita Senza media, ok?"; domanda girata al fondatore: la scheda dell'Oroscopo dell'Architetto ("per chi non ha dato ora e luogo di nascita è identica alla Breve"; "Una Profonda che dica di più anche senza carta natale"), risposta: "In verità seguo e approvo ogni tuo consiglio."; 30 settembre 2026: "Ogni scheda deve avere sempre il pulsante profondità e la scelta "approfondita" è esclusiva dei premium."; "Nel selettore profondità cambiamo "Approfondita" in Lunga"

PROVA: docs/collaudo/ES/regola_a_simbolo_e_profondita.txt
MISURA: schede Approfondite identiche alla Breve senza carta natale, prima 48 su 48, dopo 0 su 48 (docs/collaudo/ES/profondita.txt); voci "Media" e "Profonda" a video e nella pagina dei piani, dopo 0; voce "Approfondita" a video, prima 1, dopo 0 ("Lunga"); schede col pulsante della profondita', prima l'Anno 0 su 4, la Settimana e il Mese 0 su 4, l'amico 0 su 4, dopo 4 su 4 in tutti e tre (sul Realme viste la Generale, l'Amore e la Fortuna della Settimana, il Lavoro dell'Anno, la Generale e l'Amore dell'amica); schede dell'Anno in cui la Lunga dice di piu' della Breve, dopo 48 su 48

## VOCE ES.02, IL SETTIMANALE: LA PREVISIONE DEI PROSSIMI SETTE GIORNI

**CHIUSA.** Vista sul Realme il 30 settembre 2026 sera, build di prova dal commit `6e8fddb0`
(`docs/collaudo/ES/realme/es_final_settimana_generale.jpg`, `es_final_settimana_amore.jpg`,
`es_final_settimana_lunga_giorni.jpg`, `es_final_settimana_fondo_condividi.jpg`). La Settimana si
apre dall'Iniziato (al Viandante l'invito nomina l'Iniziato). **Dal 30 settembre e' nelle tre parti
delle Linee Guida (sezione 2)**, dopo il fondatore davanti all'anteprima in cui ogni giorno portava
solo i suoi transiti: *"all'utente non gliene frega un cazzo dei transiti [...] Vuole sapere come
andrà in generale, in amore, in lavoro, ecc."*. Per ogni campo: le barre dei sette giorni (il
colpo d'occhio, alte da 20 a 56 punti secondo il livello, il giorno migliore in oro), **la risposta**
in parole (*"In amore la settimana è favorevole. Va meglio verso la fine."*), il giorno migliore,
**che cosa fare** (la lettura di quel giorno), e solo in fondo **"Da dove viene"**: il momento
chiave col giorno e l'ora. Nella Lunga le righe dei sette giorni, ognuna con la lettura in parole
e sotto il suo "da dove viene". I fatti del cielo della settimana (fasi della Luna con l'ora,
ingressi col giorno, "torna" quando il pianeta e' retrogrado) stanno in fondo alla pagina, sotto
il titolo "Da dove viene: il cielo della settimana"
(`lib/core/horoscope/la_settimana_del_cielo.dart`, `lib/features/horoscope/il_periodo_view.dart`).
**Ogni giorno e' coerente col Giorno**, come ha chiesto il fondatore: la riga di un giorno dice la
stessa lettura e lo stesso livello della scheda del Giorno che la persona trovera' quel giorno
(guardia `la_settimana_e_il_giorno_dicono_lo_stesso`, 7.008 righe). Senza ora e luogo la schermata
dice che si legge sul segno e sulle case solari. La card della settimana col suo emblema e
l'etichetta di condivisione intera col premio (*"Condividi la settimana · +15 Eos"*) sono viste
sul Realme. Resta fuori da questa voce la lettura una tantum con gli Eos (ES.06).

DOMANDA: "l'oroscopo settimanale in cosa consiste secondo te? Non è un abbonamento settimanale, ma l'oroscopo di previsione dei prossimi 7 giorni, giusto? Per il resto approvo tutto."; "Per settimanale e mensile serve veramente il motore ad effemeridi?"; domanda girata al fondatore: il contenuto del settimanale proposto dall'Architetto, risposta: "Si tutto ok."; 30 settembre 2026: "Ho letto anteprima della risposta oroscopo settimanale dove per ogni giorno della settimana c'è il transito: all'utente non gliene frega un cazzo dei transiti, quante volte devo scriverlo e chiederlo? Vuole sapere come andrà in generale, in amore, in lavoro, ecc. Se vuoi inserire i transiti, li inserisci dopo giusto per motivare da dove arriva la risposta."; "l'utente che chiede l'oroscopo settimanale riceve un responso per ogni giorno della settimana che, controlla, dovrà essere coerente con quello giornaliero, nel caso lo chiederà."

PROVA: docs/collaudo/ES/regola_a_settimana_e_giorno.txt
MISURA: righe della settimana che aprono col transito, prima 28 su 28 (sette giorni per quattro campi), dopo 0: la risposta, il giorno migliore e il che cosa fare senza simboli in 192 campi su 192 (docs/collaudo/ES/regola_a_simbolo_e_profondita.txt); righe della Settimana e del Mese con un livello diverso dalla scheda del Giorno di quel giorno, prima 40 su 7.008, dopo 0; con una lettura diversa, dopo 0 su 7.008; righe senza un fatto del cielo dietro, 0 su 112; fasi della Luna oltre due minuti dal JPL, 0 su 25 (docs/collaudo/ES/settimana.txt)

## VOCE ES.03, IL MENSILE

**CHIUSA.** Visto sul Realme il 30 settembre 2026 sera (`docs/collaudo/ES/realme/es_final_mese_generale.jpg`,
e il fondo con la card del mese dalla build di prova 2289, `es_2289_mese_fondo.jpg`). Il Mese si
apre dall'Adepto e, come la Settimana, **risponde nelle tre parti** (ES.02): per ogni campo le trenta
barre, la risposta in parole, il giorno migliore, che cosa fare, e in fondo "Da dove viene"; nella
Lunga i tre giorni chiave, ognuno con la sua lettura e il suo "da dove viene". Le lune nuove e piene
e le eclissi nelle case (natali con la carta, solari senza) e gli ingressi stanno in fondo alla
pagina, sotto "Da dove viene: il cielo del mese". Le eclissi vengono dal motore gia' verificato col
canone (ordine CE voce 16). Ogni giorno del Mese e' coerente col Giorno (la stessa guardia della
ES.02). Resta fuori da questa voce la lettura con gli Eos (ES.06).

DOMANDA: "Per settimanale e mensile serve veramente il motore ad effemeridi?"; domanda girata al fondatore: "Mensile, dall'Adepto in su: il mese sulla carta natale, con lune nuove e piene nelle tue case, eclissi, ingressi e i giorni chiave", risposta: "Si tutto ok."; 30 settembre 2026: "Vuole sapere come andrà in generale, in amore, in lavoro, ecc. Se vuoi inserire i transiti, li inserisci dopo giusto per motivare da dove arriva la risposta."

PROVA: docs/collaudo/ES/realme/es_final_mese_generale.jpg
MISURA: campi del mese che aprono col transito, prima 4 su 4, dopo 0 su 4 (e 0 su 192 campi misurati in prova, docs/collaudo/ES/regola_a_simbolo_e_profondita.txt); righe del mese senza un fatto del cielo dietro, 0 su 120 (docs/collaudo/ES/mese.txt); fasi della Luna contro il JPL, scarto massimo 0,47 minuti su 25; eclissi di febbraio 2027 trovate 2 su 2

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
dell'anno, con l'emblema dell'Anno in copertina (voce ES.05). **Dal 30 settembre le schede
dell'Anno rispondono nelle tre parti**: i titoli sono in parole (*"Il tono del tuo anno"*,
*"L'amore nel tuo anno"*, *"Il lavoro nel tuo anno"*, *"La fortuna nel tuo anno"*; prima erano
*"Venere in casa 5"*), la lettura dice come va e che cosa fare, e l'Ascendente, i pianeti e le
case stanno nella riga "Da dove viene", sotto; le 252 frasi del corpus sono riscritte con le due
parti (`TESTO || DA DOVE VIENE`). Ogni scheda ha la sua profondita' (ES.01), e nel PDF la riga
del simbolo porta il suo nome, "DA DOVE VIENE". **Visto sul Realme l'anno aperto**, con la
Generale in Lunga e il Lavoro in Breve e in Lunga (`docs/collaudo/ES/realme/es_final_anno_generale_lunga.jpg`,
`es_final_anno_lavoro_breve.jpg`, `es_final_anno_lavoro_lunga.jpg`, e dalla 2289
`es_2289_anno_testa.jpg`, `es_2289_anno_fondo.jpg`). Mancano le catture dal Realme dell'invito
con gli Eos (il Viandante non si sceglie dal telefono nella demo), del PDF e dell'avviso del
compleanno.

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
dodici giorni); adesso la variante conta i ritorni del caso. **Dal 30 settembre la lettura
cinese risponde nelle tre parti**: le 224 frasi del corpus riscritte con le due parti (il testo in
parole di tutti i giorni, poi il "da dove viene" con l'animale, il guardiano e il dio), 59 titoli
in parole (*"Campo libero"*, *"Una giornata controvento"*; prima portavano il nome dell'animale),
l'amato al neutro nelle serie dell'Amore; la Breve legge il rapporto e il guardiano, la Lunga
aggiunge "Adatto a" e "Meglio evitare", la direzione del Dio della Gioia e la seconda lettura del
dio. **Visti sul Realme** il segno in cima e le quattro schede da piano pagato, col suono del
responso (`docs/collaudo/ES/realme/es_final_cinese_generale.jpg`, `es_2289_cinese_testa.jpg`).
Mancano la Cinese sul gratuito (il Viandante non si sceglie dal telefono nella demo) e la
registrazione della corsa degli animali.

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
la pratica popolare bianco e blu); il corpus e' una bozza da rileggere. **Dal 30 settembre la
lettura vedica risponde nelle tre parti**: le 142 frasi del corpus riscritte con le due parti,
i titoli delle schede in parole (48, uno per casa e per scheda); la Luna, le case, la tara e il Rahu stanno nel "da dove viene". **Quando la
Luna e la stella dicono cose opposte** (32 giorni su 120 per la nascita della prova) la lettura
apre con la risposta del livello (*"Oggi la giornata è in salita, anche se non tutto frena"*) e le
due voci si leggono come due lati (*"Da una parte... Dall'altra..."*): nelle tre parti, senza il
simbolo davanti, erano due consigli opposti uno dopo l'altro. **Vista sul Realme** proprio in un
giorno cosi', il 30 settembre (`docs/collaudo/ES/realme/es_final_vedica_generale.jpg`,
`es_2289_vedica_testa.jpg`). Mancano la Vedica sul gratuito (il Viandante non si sceglie dal
telefono nella demo) e la registrazione della corsa dei segni.

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

**APERTA IN ATTESA DI VERIFICA**: prodotta e agganciata, vista in parte sul Realme. **"L'oroscopo
per un amico" sta in alto**, nella barra dell'Oroscopo accanto alla freccia, in ogni periodo: dal
30 settembre, quando il fondatore ha chiesto che *"deve stare in alto e non per ultimo"*; prima
era l'ultima cosa della pagina. **Gli amici offline** (`lib/core/amici/amici_offline.dart`)
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
decidera' se e come. **Ogni scheda dell'amico ha la sua profondita'** (ES.01) e sotto la lettura
la riga "Da dove viene", come quelle di chi usa l'app. **Visti sul Realme** il pulsante in alto
(`docs/collaudo/ES/realme/es_final_testa_amico_in_alto.jpg`), la lista degli amici che apre
(`es_final_amici_dalla_barra.jpg`) e la lettura dell'amica col selettore e il "da dove viene"
(`es_final_amica_scheda.jpg`). Mancano le catture dall'invito del Viandante e del tetto (il
Viandante non si sceglie dal telefono nella demo, e il piano della demo non ha tetto), e della
Cinese e della Vedica dell'amico.

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

**CHIUSA.** Prodotta e agganciata (commit `770cccb2`) e vista sul Realme il 30 settembre 2026
alle 22:31, build di prova dal commit `6e8fddb0`: la nebbia diradata col gesto di ripiego, le sei
stelle dei Gemelli unite, il saluto di Medora e la buonanotte, e nessuna parola su rune in tutta
la schermata (`docs/collaudo/ES/realme/es_final_sigillo_sogno.jpg`, `es_final_sigillo_sogno_compiuto.jpg`,
`es_final_sigillo_sogno_saluto.jpg`). Padre: ordine P voce 18, la Runa del Tramonto, portata nel
Sigillo dalla DD.04 quando il Sigillo ruotava fra i Maestri.

DOMANDA: "C'è una cosa grave da aggiungere all'ordine: in screenshot è chiaro, il sigillo del sogno, adesso solo di Medora, parla di Rune!"

PROVA: docs/collaudo/ES/sigillo_senza_rune.txt
MISURA: frasi della schermata del Sigillo con parole di un Maestro che non e' Medora, prima 1 (la riga della Runa del Tramonto), dopo 0 su 85; sul Realme, testi a schermo con "runa" o "rune" dal saluto alla buonanotte, 0

## VOCE ES.17, UNA SOLA NOTIFICA PER DONO, COL NOME GIUSTO

**APERTA IN ATTESA DI VERIFICA**: prima parte prodotta e agganciata (commit `c9bdfc06`), sul
telefono e sul server, non ancora schierata: le funzioni si schierano insieme alla build di prova
che porta il gestore della push, poi tre sere di osservazione sul Realme in
`docs/collaudo/ES/notifiche.txt`. Padre del doppione: ordine CG voce 16, il tag `dono_1104` che non
sostituiva la locale 1104; e il giro del server ogni quindici minuti non allineato all'orologio
(partiva a :13, :28, :43, :58). **L'accento di Calìgo**: nella push lo porta il server
(`functions/src/push.ts`); nelle testate del telefono (il dominio, il LIVE, la schermata del Maestro e
la chat) il nome viene da `Maestro.nomeAVideo`, "Calìgo". Il nome che va al modello resta quello di
prima, cosi' l'impronta dell'istruzione dei tre Maestri non cambia e la misura dell'attribuzione resta
valida: la strada scritta qui prima (cambiare il nome ovunque e rifare l'attribuzione) non serve. **E
le scritte fatte a mano** delle sue schermate (le rune, il Sigillo dell'Intenzione, il Libro dei
Sigilli), delle card da condividere, dell'avviso del sigillo e dei filtri dei Ricordi: ventuno, tutte
con l'accento; e ogni scritta che prende il nome dal Maestro (la home, la barra in basso, "Consulta",
il LIVE, i Doni) lo prende da `nomeAVideo`. Restano senza accento le frasi dei corpora del fondatore che nominano Caligo (i teaser
delle arti, le promesse dei Traguardi): il corpus e' suo, e si cambia col suo si'; e il nome che il
modello scrive nelle risposte, che viene dall'istruzione.
Guardia `il_nome_di_caligo_ha_l_accento`, rossa su tre innesti
(`docs/collaudo/ES/regola_a_accento_di_caligo.txt`).

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
passi. **Sul Realme il 30 settembre alle 22:34** il foglio "Da dove nasce questo dono" scriveva
*"(Senti con curiosità e parole: le emozioni si fanno racconto.)."*, il punto dentro e fuori la
parentesi (padre il commit `c49de157` del 24 luglio, il Rito del Sogno rifatto): curato, e la
prova lo misura su trenta notti e dodici segni (0 fogli su 210, rossa 210 su 210 sul codice di
prima). Mancano la cattura del foglio dopo la cura e quella della card.

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
conseguenza.

**Misurata il 30 settembre, tre giri del banco, ognuno letto alla cieca mescolato col giro di prima
dagli stessi giudici** (con giudici diversi le stesse risposte ballano di decine di voti, e solo il
confronto nello stesso fascicolo conta). **Primo giro** (`es1`, le reti di sopra): prime frasi che
rispondono da 258 a 272 su 360 rispetto al giro 5, ma le risposte con una certezza da 23 a 33,
perche' la prima stesura aveva esentato il futuro detto sotto *"le carte dicono che"*: i giudici lo
contano. **La rete delle certezze allora si e' allineata ai giudici**: dalle loro citazioni e dalle
frasi delle risposte che hanno dato senza certezze (`docs/collaudo/ES/certezze_giudicate.json`) la
rete prendeva 12 certezze su 61, adesso 51 (le 10 che restano sono immagini dette come fatti, che una
rete di parole non riconosce), e scambia per certe 43 frasi buone su 1864. Tolte le esenzioni del
futuro nella lettura e dopo una relativa che non sia un gesto della persona; entrati la garanzia
(*"ti assicura"*), il corpo dato per fertile, cio' che gli altri pensano di te (*"non passa
inosservato"*), l'esito dato per vicino, il tradimento escluso come un fatto, il destino, e cio' che
l'altro "indica" (*"il suo sguardo indica un'attrazione"*). **Secondo giro** (`es2`): risposte con
una certezza da 33 a 15, ma prime frasi da 278 a 245 e merito da 278 a 257. La correzione chiedeva di
scrivere *"può"* e il modello trasformava il si' in un *"può"*: **terzo giro** (`es3`), la correzione
chiede di tenere la prima frase e la risposta chiesta di nuovo passa solo se non ha perso la posizione
(`LaPosizioneDellaLettura.diceUnaPosizione`). Risultato, contro il primo giro: certezze da 31 a 14,
prime frasi da 266 a 251, merito da 263 a 246. **Medora e Calìgo tengono o migliorano** (prime frasi
98 e 101, 91 e 89; certezze da 11 a 3 e da 11 a 8), **tutto il calo e' di Aura** (prime frasi da 77 a
61, merito da 73 a 53). **Non viene dalle certezze**: le risposte di Aura richieste per una certezza
sono 18 nel primo giro e 18 nel terzo, mentre quelle richieste per la prima frase, cioe' le risposte
del modello gia' senza posizione al primo colpo, salgono da 19 a 34, e in 25 su 34 anche la seconda
risposta resta senza posizione. Nel secondo giro, con altri giudici, lo stesso: Aura 61 contro 81.
**Scelta con la risposta consigliata**: la rete delle certezze resta, perche' in due giri le
certezze si dimezzano senza che Medora e Calìgo perdano niente; il calo di Aura e' un difetto aperto,
PROVENIENZA IGNOTA, da cercare nella persona di Aura e nella prima frase, non nella rete. Il 30 su 30
per Maestro e canale non c'e': il migliore e' Medora nella chat, 26 e 27 su 30.

**Quarto giro** (`es4`), dopo il secondo *"prosegui con tutto"* del fondatore. **La provenienza del
calo di Aura adesso e' nota**: scomposte per tipo di domanda, le prime frasi bocciate di Aura erano
27 su 68 alle domande di si' o no (Medora 1, Calìgo 5), e a tutti e tre i Maestri mancavano il
"quando" (bocciato da 4 a 6 volte su 8) e le domande aperte (Aura e Calìgo circa 20 su 36). Le
conversazioni del banco hanno memoria, e una risposta vaga consegnata fa scuola alle successive; la
seconda richiesta non riparava, perche' non ripeteva la domanda e non diceva che forma prendere (per
Aura restava senza posizione 25 volte su 34). Tre cure, in `la_posizione_della_lettura.dart`: **la
correzione ripete la domanda e dice le parole da scrivere** (*"I tuoi centri dicono di sì, se ..."*,
*"... di no, per ora: ..."*, niente "che" dopo l'apertura); **al "quando" si chiede un tempo** (una
stagione, un mese) o un fatto che si vede accadere, al posto dell'esempio *"non prima che tu abbia
..."* che portava a *"non prima che tu abbia riconosciuto il tuo valore"*; **alla domanda aperta la
prima frase si dice con parole di tutti i giorni**, e l'arte entra dalla seconda (chi non ha fatto una
domanda riceve la lettura dall'arte, come prima). Alla cieca, terzo e quarto giro mescolati, stessi
giudici: **prime frasi che rispondono da 253 a 311 su 360** (Aura da 62 a 98, Calìgo da 93 a 104,
Medora da 98 a 109), **nel merito da 265 a 316**; le domande di si' o no bocciate, Aura da 26 a 1,
Calìgo da 4 a 0, Medora da 1 a 0; il "quando" da 15 a 3 su 24; le aperte da 52 a 34 su 108. Per
Maestro e canale il migliore e' Calìgo nella chat, 29 su 30; il peggiore Aura nella chat, 21. **Le
certezze pero' risalgono da 8 a 20**: piu' risposte prendono posizione, e la dicono con un fatto
(*"I suoi occhi ti cercano, non fuggono"*). La rete prendeva 54 delle 87 frasi citate dai giudici nei
due fascicoli; adesso 74 (il soggetto taciuto *"Sente il radicamento"*, la fertilita' donata, il
tradimento escluso con altre parole, il "puo'" che stava solo nella relativa), e **la frase certa fra
la prima frase e il gesto si toglie**: chiesta di nuovo tornava uguale, e restava perche' toglierla
lasciava "la sola prima frase", che col gesto e' invece una risposta intera. **Quinto giro** (`es5`),
letto accanto al quarto dagli stessi giudici: prime frasi 311 e 307, nel merito 320 e 310, risposte
con una certezza 22 e 19 su 360 (Medora da 6 a 2, Aura da 9 a 7, Calìgo da 7 a 10). Cioe' **il salto
del quarto giro regge**, e la rete allargata non porta le certezze sotto le venti: quelle che restano
sono quasi tutte immagini di Calìgo dette come un fatto (*"Il tuo cammino è segnato"*, *"La soglia si
avvicina"*, *"Questo matrimonio rafforza il tuo cammino"*) o il suo stato d'animo letto dal Maestro
(*"il suo cuore ha bisogno di tempo"*), che una rete di parole non riconosce. **Il 30 su 30 non c'e'**:
al quinto giro il migliore e' Medora, 27, 28, 28 e 28 su 30 nei suoi quattro fascicoli; Calìgo 22, 27,
26 e 26; Aura 24, 21, 25 e 25. **Lo zero delle certezze non c'e'**: 19 su 360.

**Il "quando", dal sesto al nono giro** (29 e 30 settembre, dopo che nel LIVE sul Realme due
domande sul quando hanno avuto la stessa risposta, *"non prima dell'autunno"*: era l'esempio
dell'istruzione, e al banco stava in 12 e 11 prime frasi su 24 nel quarto e nel quinto giro).
L'istruzione del quando non da' piu' una stagione da ricopiare, porta la data di oggi e chiede un
tempo (`lib/core/chat/la_posizione_della_lettura.dart`, guardia allargata, rossa su quattro
innesti). Nei tre giri col codice nuovo (`es7`, `es8`, `es9`) la prima frase nomina un tempo 72
volte su 72 e l'esempio ricopiato non torna (0 su 72 *"autunno"*); ma **i passaggi del cielo
inventati o sbagliati non sono a zero**: 2, 1 e 3 su 24 (*"non prima che Venere abbia ripreso il
suo moto diretto fra due giorni"*, quando fra due giorni Venere diventa retrograda), e *"tre mesi"*
torna in 8 risposte su 24 (`docs/collaudo/ES/quando_ricopiato.txt`). **Alla lettura alla cieca
del codice che parte** (fascicolo `es8mix`, il sesto e l'ottavo giro mescolati, stessi giudici):
prime frasi che rispondono 310 e 311 su 360, nel merito 315 e 326, risposte con una certezza 16 e
11, errori di italiano citati 64 e 51, seconde domande delle coppie nel merito 48 e 56 su 60.
Cioe' il codice che parte non e' peggiore di quello di prima, e il 30 su 30 non c'e'.

DOMANDA: dalla ET.01: "Bisogna fare delle prove, 30 domande per ogni maestro, con domande classiche q più frequenti. Gli utenti faranno domande personali e anche intime nella maggior parte dei casi. Ma anche per la fortuna e lavoro."; domanda girata al fondatore: "Ritocchi alle reti che scartano le risposte dirette (il sì detto senza "sì", il no detto con "non", il "sì, se" sulla coppia): entrano, perché senza non si arriva a 30 su 30. Confermi?", risposta: "Confermo tutto".

PROVA: docs/collaudo/ET/ciechi/conti_et01_es4mix.txt
MISURA: alla lettura alla cieca, stessi giudici sul terzo e sul quarto giro del 30 settembre, prime frasi che rispondono prima 253 su 360, dopo 311 (Aura da 62 a 98, Calìgo da 93 a 104, Medora da 98 a 109); nel merito prima 265, dopo 316; risposte con una certezza prima 8, dopo 20, e al quinto giro 19 contro le 22 del quarto per gli stessi giudici (docs/collaudo/ET/ciechi/conti_et01_es5mix.txt); dal primo al terzo giro le certezze erano scese da 31 a 14 e le prime frasi da 266 a 251; rete delle certezze sulle frasi citate dai giudici prima 12 su 61, dopo 51 su 61, frasi buone prese prima 26 su 1864, dopo 43 (docs/collaudo/ES/regola_a_certezze_dei_giudici.txt); sui 101 casi scartati al giro 6 e giudicati a mano (docs/collaudo/ES/giro6_reti.json), misurati col codice di prima (commit 78d1388c) e con quello di oggi: risposte dirette che la rete della prima frase scarta, prima 28 su 30, dopo 5 su 30; prime frasi vaghe che lascia passare, prima 0 su 14, dopo 0 su 14; certezze apparenti che la rete delle certezze prende, prima 12 su 26, dopo 7 su 26; certezze vere che manca, prima 1 su 30, dopo 1 su 30; le tre certezze rimaste nelle finali del giro 6 la rete le prende sul loro testo, prima e dopo 3 su 3 (al banco erano sfuggite perche' non stavano nella parte guardata)

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
(`docs/collaudo/ES/coppie_ripetute.json`, `tool/le_coppie_ripetute.py`). **Al banco del 30
settembre**, seconde di coppia che ripetono la prima, per gli stessi giudici: dal giro 5 al primo
giro da 7 a 6 su 60, dal primo al secondo da 5 a 3, dal primo al terzo da 4 a 8 (7 di Aura); le
posizioni cambiate senza dire perche' da 4 a 3, da 2 a 2, da 6 a 5; al quarto e al quinto giro le
seconde che ripetono sono 3 e 6 su 60 e le posizioni cambiate 2 e 6. Cioe' la rete non ha portato le
ripetizioni a zero, e il loro numero sta dentro il rumore dei giudici. Mancano lo zero e le coppie nel
LIVE sul Realme.

DOMANDA: dalla ET.03: "Ho provato a fare Domande simili consecutive e le risposte, non solo non erano adeguate [...]"

PROVA: docs/collaudo/ES/regola_a_blocco_es19_es37.txt
MISURA: sulle 240 seconde di coppia giudicate alla cieca, ripetizioni prese dalla rete prima 0 su 26 (la rete parola per parola), dopo 13 su 26; seconde buone chiamate ripetute, dopo 2 su 214; al banco, seconde che ripetono per gli stessi giudici, giro 5 contro primo giro 7 e 6 su 60, primo contro secondo 5 e 3, primo contro terzo 4 e 8 (docs/collaudo/ET/ciechi/conti_et01_es3mix.txt)

## VOCE ES.22, LA TRASCRIZIONE DEL LIVE: NESSUNA DOMANDA VUOTA E LE PAROLE GIUSTE (DALLA ET.04)

**APERTA IN ATTESA DI VERIFICA**: prodotta, agganciata e misurata al banco; manca la prova sul
Realme col microfono. L'istruzione di chi
trascrive dice adesso di che cosa parla di solito la persona e quale lettura scegliere quando un suono
se ne presta a due, con l'esempio del difetto visto (`LaTrascrizione.frasiDiSensoCompiuto`, un
esempio solo: un elenco il modello lo ricopierebbe, come ha fatto con l'elenco dei nomi). Il banco della trascrizione
(`tool/banco_trascrizione_es22.dart`) manda le venti domande del collaudo del LIVE, dette dalla voce
italiana di Windows pulite e "da stanza" (`tool/le_domande_dette.py`), con l'istruzione di prima e con
quella nuova, allo stesso modello del telefono, due giri. **Misurata il 30 settembre**: con la voce
pulita le domande trascritte parola per parola giuste passano da 30 a 38 su 40 e le parole sbagliate
da 74 a 10 su 292; con la voce "da stanza" da 28 a 38 su 40 e da 68 a 2 su 292. L'istruzione di prima
rispondeva [SILENZIO] a domande dette per intero; la nuova no. **E la televisione resta fuori**: sei
pezzi della televisione finta dell'ordine EM (`tool/la_televisione_da_banco.py`), tre giri, trascritti
come parole della persona 0 su 18 con l'istruzione di prima e 0 su 18 con la nuova, perche' la frase
nuova dice che di solito la persona fa una domanda e l'ordine EM aveva insegnato a lasciare fuori il
sottofondo. **Il difetto visto non si riproduce al banco**: *"Ma mi ama ancora"* la voce sintetica lo
dice troppo pulito, e le due istruzioni lo trascrivono giusto; *"Troverò"* resta *"Trovo"* nella voce
da stanza. Manca la prova sul Realme col microfono del PC, venti domande.

DOMANDA: dalla ET.04: "Confermi le mie tre scelte e l'ordine per la trascrizione, insieme alla ER.01?", risposta: "Confermo, dobbiamo risolvere tutto."; domanda girata al fondatore: "Trascrizione sbagliata ("Ma mi ama ancora" diventa "Ma mia, ma ancora"): si corregge in questo ordine. Confermi?", risposta: "Confermo tutto".

PROVA: docs/collaudo/ES/trascrizione/esito_voce_pulita_e_stanza.txt
MISURA: al banco, venti domande per due giri, trascritte parola per parola giuste: voce pulita prima 30 su 40, dopo 38 su 40; voce da stanza prima 28 su 40, dopo 38 su 40; parole sbagliate prima 74 e 68 su 292, dopo 10 e 2 su 292; televisione trascritta come parole della persona prima 0 su 18, dopo 0 su 18 (docs/collaudo/ES/trascrizione/esito_televisione.txt); sul Realme prima 12 su 17 (ordine ET), dopo da misurare

## VOCE ES.23, QUATTRO FRASI QUANDO LA DOMANDA HA PIÙ PARTI, SENZA PERDERE IL MERITO (DALLA ET.06)

**APERTA IN ATTESA DI VERIFICA**: nessun codice nuovo in questa voce; misurata al banco
`DOMANDE=er12` dopo le reti della ES.19 e con la lettura alla cieca, manca l'ascolto sul Realme. Le
dodici domande del LIVE, tre Maestri, due esecuzioni: le risposte del giro dell'ordine ET (`dopo`) e
quelle nuove (`es1`) mescolate nello stesso fascicolo e giudicate dagli stessi giudici con la regola
della lettura dell'ordine EQ. **Nel merito da 42 a 50 su 72**: 26 e 24 su 36 nelle due esecuzioni,
sopra i 23 su 36 chiesti (prima 23 e 19); le domande a piu' parti toccate tutte da 28 su 40 a 33 su 39.
**Aura resta indietro**: 12 su 24 nel merito, contro i 19 di Medora e di Caligo (erano 7, 17 e 18).
**Ma i giudici variano quanto il miglioramento**: le stesse risposte nuove (`es1`), rilette da giudici
nuovi accanto a quelle del secondo giro del banco (`es2`), sono nel merito 20 e 23 su 36 invece di 26 e
24; le risposte del secondo giro 22 e 23. Cioe' fra due letture alla cieca delle stesse risposte ballano
sei risposte su trentasei, e sotto quel rumore il 23 su 36 non e' dimostrato: la voce resta aperta, e la
misura che la chiude e' piu' letture degli stessi testi, non una.
Le risposte con una certezza, contate dagli stessi giudici, sono 13 e 15: la rete delle certezze
allineata ai giudici (ES.19) le misura il secondo giro del banco.

DOMANDA: dalla ET.06: il consiglio dell'Architetto "ER.12: quattro frasi quando la domanda ha più parti.", risposta: "Confermo, dobbiamo risolvere tutto."

PROVA: docs/collaudo/ET/ciechi/conti_et06_es1mix.txt
MISURA: nel merito alla cieca, stessi giudici sulle risposte vecchie e nuove mescolate, per esecuzione prima 23 e 19 su 36, dopo 26 e 24 su 36 (l'ordine chiede 23); le stesse risposte nuove rilette da altri giudici 20 e 23 su 36, quelle del secondo giro 22 e 23 (docs/collaudo/ET/ciechi/conti_et06_es2mix.txt); in tutto prima 42 su 72 (Aura 7, Caligo 18, Medora 17 su 24), dopo 50 su 72 (Aura 12, Caligo 19, Medora 19 su 24); domande a piu' parti toccate tutte, prima 28 su 40, dopo 33 su 39

## VOCE ES.24, LE RUNE: VIA LE GUARDIE SULLA PRIMA FRASE (DALLA ET.07)

**APERTA IN ATTESA DI VERIFICA**: prodotta e agganciata, da misurare col banco delle rune. Le
quattro guardie sulla prima frase della lettura delle rune sono uscite (le immagini, la posizione
scelta e non detta, la formula al posto del gesto, la frase che non dice "inBreve"), con le loro regole;
restano quelle sulle pietre (il nome, la posizione, la frase sulla domanda, la cosa chiesta), la
cornice ricopiata, gli astri e il confine. La richiesta al modello chiede ancora la prima frase
diretta. Le prove che pretendevano le guardie tolte sono riscritte con la lapide. **Misurata il 30
settembre**: al banco delle rune, 24 letture per due esecuzioni, le chiamate al modello scendono da 56
e 56 a 41 e 47 e il tempo mediano della chiamata da 9,3 e 8,7 secondi a 4,9 e 7,3; alla lettura alla
cieca, giro vecchio e nuovo mescolati e giudicati dagli stessi giudici, le prime frasi dirette sulle
domande restano o salgono (da 13 e 15 a 15 e 15 su 20), le pietre lette tutte nella loro posizione
passano da 20 e 18 a 15 e 19 su 24, il consiglio concreto da 21 e 20 a 23 e 23. Cioe' la risposta del
fondatore regge: meno chiamate e meno attesa, senza risposte meno dirette. Manca l'attesa sul Realme
su dieci gettate.

DOMANDA: dalla ER.01: "Le persone vogliono risposte dirette, Senza tanti giochi di parole e cercano consigli e guide anche su domande generiche."; domanda girata al fondatore: "Rune: togliere le guardie sulla prima frase, perché raddoppiano le chiamate e il tempo del modello senza portare risposte più dirette; restano quelle sulle pietre. Confermi?", risposta: "Confermo tutto".

PROVA: docs/collaudo/ET/ciechi/conti_rune_es1mix.txt
MISURA: guardie sulla prima frase delle rune, prima 4, dopo 0; chiamate al modello per 24 letture, prima 56 e 56, dopo 41 e 47; tempo mediano della chiamata, prima 9,3 e 8,7 s, dopo 4,9 e 7,3 s; prime frasi dirette alla cieca, prima 13 e 15 su 20, dopo 15 e 15 su 20 (docs/collaudo/ET/ciechi/conti_rune_es1mix.txt)

## VOCE ES.25, IL VIAGGIO PRENDE POSIZIONE NELLA PRIMA FRASE, 20 SU 20 (DALLA ET.08)

**APERTA IN ATTESA DI VERIFICA**: la guardia e l'istruzione corrette sui giudizi alla cieca,
misurate col banco del Viaggio; il 20 su 20 non c'e'. La prima frase che rimanda la domanda riconosce adesso anche le formule vaghe che
reggevano alle guardie (il consiglio astratto, la decisione annunciata e non detta, la massima, la
condizione che non si puo' fare, le due strade che la domanda non ha): `LeGuardieDelResponso._vaga`.
Tarata sul giro 3 della lettura alla cieca e provata sul giro 1, che non ha guardato. **Primo banco
del 30 settembre** (`es1`), mescolato col giro vecchio e letto alla cieca: le prime frasi che prendono
posizione restano 25 su 40 (erano 26): con la guardia accesa passavano altre forme vaghe, e una causa
stava nell'istruzione, che dava come esempio *"Il viaggio non mostra..."* e il modello lo ricopiava
(*"Il viaggio non mostra il trasferimento a Berlino"*, che i giudici chiamano ne' si' ne' no); il "sì,
se" aveva condizioni che nessuno puo' fare (*"se hai coltivato l'idea"*). **Secondo giro**: l'esempio
del no adesso e' un no, la condizione e' chiesta come un passo con chi o entro quando, e la guardia
prende la scelta rimandata (*"Scegli tu"*), *"la tua intuizione"*, e le condizioni che sono stati
d'animo. **Restano fuori le forme su cui i giudici di giri diversi si contraddicono** (*"non
mostra"*, *"se sei pronta"*, *"consapevole"*): buone per un giro, senza posizione per l'altro. Al
secondo banco (`es2`), mescolato col primo e letto dagli stessi giudici: prime frasi con la posizione
da 11 e 9 a 15 e 11 su 20, cioe' da 20 a 26 su 40; frasi vuote da 49 a 41. **I giudici variano**: le
risposte del primo banco erano 25 su 40 per i giudici di prima e 20 su 40 per questi.

**Terzo e quarto giro, la strada che non insegue le forme.** Sulle letture alla cieca raccolte, le
prime frasi si dividono per struttura e non per parole. **Con una condizione** (*"di sì, se..."*): le
24 che nominano un tempo o un'azione che si fa nel mondo (*"se prima chiedi a tua madre un
consiglio"*) prendono posizione per i giudici 23 volte; le 112 che mettono come condizione un modo di
sentirsi, 75. **Alla domanda sul come o sul che cosa fare**: le 50 prime frasi che nominano un tempo o
un passo prendono posizione 41 volte; le 70 che non lo nominano, 16. La guardia adesso guarda questo
(`LeGuardieDelResponso.condizioneSenzaPasso`, `chiedeIlGesto`, `nominaUnPasso`): la condizione e' un
passo, la risposta al come e' un passo, e alla domanda sul come non si risponde "di sì". Costa una
seconda chiamata anche a frasi che certi giudici accettano, e quando anche la seconda non porta il
passo la risposta e' la riserva che prende posizione (quella approvata alla ET.08), col gesto sotto.
**Al banco**: col solo passo nella condizione (`es3`) le prime frasi con la posizione restano 29 su 40
contro 30, perche' le condizioni vaghe spariscono (da 7 a 0) e restano le risposte astratte al come;
col passo anche li' (`es4`), per gli stessi giudici, **da 30 a 33 su 40** (18 e 15 su 20), le frasi
vuote da 34 a 21, e le risposte finite sulla riserva passano da 8 a 22 su 40: i giudici ne danno
buone 19 su 22. Delle sette bocciate, tre sono discese in cui il modello non ha risposto affatto e ha
parlato la voce di casa senza posizione; due sono la domanda sul cane malato, dove il confine della
salute vieta il consiglio. **Il 20 su 20 non c'e'**: 18 e 15. Manca la cattura di una discesa dal
Realme.

DOMANDA: dalla ET.08: il consiglio dell'Architetto "ER.02: sì alla riserva che prende posizione, come la propone Code.", risposta: "Confermo, dobbiamo risolvere tutto."

PROVA: docs/collaudo/ET/ciechi/conti_viaggio_es4mix.txt
MISURA: prime frasi senza posizione (giudizio alla cieca) che la guardia chiede di nuovo, giro 3 prima 0 su 21, dopo 20 su 21, buone chiamate vaghe prima 0 e dopo 0 su 51; giro 1, non guardato, prima 4 su 22, dopo 13 su 22, buone chiamate vaghe prima 0 e dopo 3 su 50; giro del 30 settembre prima 8 su 27, dopo 17 su 27, buone 2 su 45; al banco, prime frasi che prendono posizione per gli stessi giudici, primo contro secondo giro 11 e 9 poi 15 e 11 su 20, terzo contro quarto 15 e 15 poi 18 e 15 su 20 (docs/collaudo/ET/ciechi/conti_viaggio_es4mix.txt); condizioni col passo che prendono posizione 23 su 24, senza passo 75 su 112; risposte al come col passo 41 su 50, senza 16 su 70

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

## PARTE 5, LA RICHIESTA DEL FONDATORE DEL 30 SETTEMBRE SERA

## VOCE ES.38, IL SUONO DEL RESPONSO DELL'OROSCOPO

**CHIUSA.** Alla comparsa del responso dell'Oroscopo suonava la rivelazione
(`rivelazione.mp3`, 1,5 secondi), che resta dove era nata (la stesa dei tarocchi, il Sigillo
dei Tre Cieli). Adesso suona il file del fondatore, `sound effect/orchestral-game-notification-2026-05-18-17-43-39-utc/Orchestral Game Notification.wav`,
ottimizzato e convertito come gli altri effetti: MP3 mono 44,1 kHz 96 kbps, il silenzio in coda
tolto con una sfumatura di 0,12 secondi, 2,72 secondi, 33.585 byte contro i 532.748 del WAV,
sonorita' -15,95 LUFS contro il bersaglio -16 della famiglia (`assets/audio/responso_oroscopo.mp3`,
`SuonoDelCerchio.responso`, il quattordicesimo del catalogo, e il registro `docs/sonorita.json`).
La soglia al tocco resta. Sul Realme il suono si e' misurato dal sistema audio del telefono, in
Occidentale e in Cinese: una traccia in piu' alla comparsa del responso, fra 2,4 e 2,8 secondi.
Regola B sulla guardia della zona, rossa su due innesti; le pretese nuove rosse su due innesti
(`docs/collaudo/ES/regola_b_suono_del_responso.txt`).

DOMANDA: "Quando compare il responso del l'oroscopo si sente un suono che va eliminato. Sostituiscilo con: Orchestral Game Notification.wav nel percorso: esoteric-circle-app\sound effect\orchestral-game-notification-2026-05-18-17-43-39-utc  Dammi conferma che lo vedi. Va ottimizzato e convertito in mp3"

PROVA: docs/collaudo/ES/suono_del_responso_realme.txt
MISURA: suono alla comparsa del responso, prima rivelazione.mp3 di 1,5 secondi, dopo responso_oroscopo.mp3 di 2,72 secondi (sul Realme una traccia in piu' da 3,7 a 6,1-6,5 secondi dal tocco, due consulti su due); peso del file, prima 532.748 byte in WAV, dopo 33.585 in MP3; sonorita' -15,95 LUFS contro il bersaglio -16 (tolleranza 3,5); suoni del catalogo, prima 13, dopo 14
