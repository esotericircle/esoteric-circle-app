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
VOCI_APERTE: 19
VOCI_DA_FARE: 16

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

**DA FARE.**

DOMANDA: "Inoltre, cosa ne dici dell'oroscopo annuale da integrare?"; domanda girata al fondatore: l'annuale proposto dall'Architetto (Rivoluzione Solare dal compleanno, notifica e card, dall'Adepto in su, 300 Eos, PDF all'Illuminato), risposta: "Per il resto approvo tutto."

## VOCE ES.05, GLI EMBLEMI DEI PERIODI

**APERTA IN ATTESA DI VERIFICA**: prodotta e agganciata (commit `a9e52f66`). I nove webp dei periodi
sono in `assets/schede`, uguali byte per byte a quelli del PC; la card da condividere porta
l'emblema del periodo (il Giorno quello dell'Oroscopo). Mancano: la cattura dal Realme di una card
per periodo, che si potra' fare quando Settimana, Mese e Anno saranno aperti (voci ES.02, ES.03,
ES.04), e la copertina del PDF dell'anno (voce ES.04). In testa alla schermata resta il segno in
ogni periodo: oggi i periodi diversi dal Giorno sono chiusi e non cambiano la testa.

DOMANDA: "Ma non dovrei creare degli asset per ogni tipo di oroscopo? Ci pensi tu?"; "Cioè un Emblema per ogni tipo di oroscopo, intendevo..."; "attualmente l'utente entra in oroscopo personalizzato e vede il suo segno zodiacale occidentale con il pulsante oroscopo occidentale attivo".

MISURA: webp dei periodi in assets/schede uguali a quelli del PC, prima 0 su 9, dopo 9 su 9 (cmp, e la prova la_tradizione_scelta_sta_in_cima conta 27 emblemi su 27)

## VOCE ES.06, CHI VEDE COSA: PIANI, LIMITI ED EOS

**DA FARE.**

DOMANDA: "Ma prima di scrivere l'ordine dovresti indicarmi cosa sblocchiamo e a quale tier renderlo disponibile e con quali limiti. E andranno aggiornati anche i piani di abbonamento e bisogna decidere il prezzo in Eos per chi vuole un giro in più a meno che già c'è."; domanda girata al fondatore: la tabella dell'Architetto, risposta: "Approvo tutto. Ma vorrei che l'utente free non avesse accesso al settimanale."; "Anche cinese e vedica saranno disponibili solo per i premium."; "Si per Premium intendo tutti i piani a pagamento. I free potranno solo chiedere oroscopo del giorno e solo occidnetale o solo vedere il proprio segno di vedica o cinese senza lettura come hai suggerito. Non ci sono limiti di numero perchè l'oroscopo è ugale ogni giorno e non cambia se lo chiedo nuovamente lo stesso giorno."; "No, l'utente free non può fare orsocopo per amici, lo vede e se fa click, viene invitato a sottoscrivere abbonamento"; domanda girata al fondatore: "3 per l'Iniziato, 10 per l'Adepto, nessun limite per l'Illuminato [...] 100 Eos per un posto in più", risposta: "ok , approvato"; "Ma il viandante corrisponde al free!".

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

**DA FARE.**

DOMANDA: "Mi hai consigliato tu di sbloccare in MVP anche vedico e cinese!"; "Se sceglie oroscopo cinese significa che è selezionabile e sbloccato"; domanda girata al fondatore: il metodo dell'Architetto (segno lunare siderale Lahiri, Chandra Bala, Tara Bala, Rahu Kalam) e "Confermi il Capodanno lunare per il segno cinese e il segno lunare per il vedico?", risposta: "COnfermo tutto."

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

**DA FARE.**

DOMANDA: "Ho intenzione di inserire la possibilità ai premium di poter calcolare l'oroscopo per gli amici così da poterlo condividere con gli amici e creare vitalità: l'utente premium potrà inserire data e ora di nascita dell'amico, scegliere la tipologia di oroscopo, scoprire il segno corrispondete e creare l'oroscopo e con la condivisione inviarlo all'amico."; "servirà che l'utente inserisca i dati e il nome dell'amico che verranno memorizzati in un contenitore "amici offline" che potranno essere richiamati nelle altre funzionalità di compatibilità. Ti ricordo che l'app dovrà diventare "Social""; "No, l'utente free non può fare orsocopo per amici, lo vede e se fa click, viene invitato a sottoscrivere abbonamento"; domanda girata al fondatore: "3 per l'Iniziato, 10 per l'Adepto, nessun limite per l'Illuminato [...] 100 Eos per un posto in più", risposta: "ok , approvato".

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

**DA FARE.**

DOMANDA: "in alto nella barra superiore al centro bisogerà inserire "online" con lucina verde e n. di utenti online al posto di Eventi cosmici che andrà in Passport in alto come "Prossimi Eventi Cosmici""

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

**DA FARE.**

DOMANDA: "code deve controllare ancora tutto il funzionamento del sigillo del sogno e le risposte!"; le domande del fondatore da farsi su ogni funzionalità, del 27 settembre: "trasparenza, coerenza, verità e funzionalità", "c'è qualcosa di inventato?".

## PARTE 3, LE NOVE VOCI APERTE DELL'ORDINE ET

## VOCE ES.19, IL BANCO DELLE TRENTA DOMANDE ARRIVA A 30 SU 30 (DALLA ET.01)

**DA FARE.**

DOMANDA: dalla ET.01: "Bisogna fare delle prove, 30 domande per ogni maestro, con domande classiche q più frequenti. Gli utenti faranno domande personali e anche intime nella maggior parte dei casi. Ma anche per la fortuna e lavoro."; domanda girata al fondatore: "Ritocchi alle reti che scartano le risposte dirette (il sì detto senza "sì", il no detto con "non", il "sì, se" sulla coppia): entrano, perché senza non si arriva a 30 su 30. Confermi?", risposta: "Confermo tutto".

## VOCE ES.20, VOCE, TESTO A VIDEO E CHAT CON LE STESSE PAROLE (DALLA ET.02)

**DA FARE.**

DOMANDA: dalla ET.02: "Deve anche verificare che quello che il maestro dice corrisponda a quello che ha detto."; domanda girata al fondatore: "Invito a tornare nella chat del LIVE: esce, perché la chat deve dire solo quello che dice la voce. Confermi?", risposta: "Confermo tutto".

## VOCE ES.21, DOMANDE SIMILI DI FILA, ZERO RIPETIZIONI (DALLA ET.03)

**DA FARE.**

DOMANDA: dalla ET.03: "Ho provato a fare Domande simili consecutive e le risposte, non solo non erano adeguate [...]"

## VOCE ES.22, LA TRASCRIZIONE DEL LIVE: NESSUNA DOMANDA VUOTA E LE PAROLE GIUSTE (DALLA ET.04)

**DA FARE.**

DOMANDA: dalla ET.04: "Confermi le mie tre scelte e l'ordine per la trascrizione, insieme alla ER.01?", risposta: "Confermo, dobbiamo risolvere tutto."; domanda girata al fondatore: "Trascrizione sbagliata ("Ma mi ama ancora" diventa "Ma mia, ma ancora"): si corregge in questo ordine. Confermi?", risposta: "Confermo tutto".

## VOCE ES.23, QUATTRO FRASI QUANDO LA DOMANDA HA PIÙ PARTI, SENZA PERDERE IL MERITO (DALLA ET.06)

**DA FARE.**

DOMANDA: dalla ET.06: il consiglio dell'Architetto "ER.12: quattro frasi quando la domanda ha più parti.", risposta: "Confermo, dobbiamo risolvere tutto."

## VOCE ES.24, LE RUNE: VIA LE GUARDIE SULLA PRIMA FRASE (DALLA ET.07)

**DA FARE.**

DOMANDA: dalla ER.01: "Le persone vogliono risposte dirette, Senza tanti giochi di parole e cercano consigli e guide anche su domande generiche."; domanda girata al fondatore: "Rune: togliere le guardie sulla prima frase, perché raddoppiano le chiamate e il tempo del modello senza portare risposte più dirette; restano quelle sulle pietre. Confermi?", risposta: "Confermo tutto".

## VOCE ES.25, IL VIAGGIO PRENDE POSIZIONE NELLA PRIMA FRASE, 20 SU 20 (DALLA ET.08)

**DA FARE.**

DOMANDA: dalla ET.08: il consiglio dell'Architetto "ER.02: sì alla riserva che prende posizione, come la propone Code.", risposta: "Confermo, dobbiamo risolvere tutto."

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
giorno senza non mostra niente, e succede circa un giorno su due. **Mancano le due
notifiche** (un quarto d'ora prima dell'ora d'oro e il Rahu Kalam del mattino, che nasce con
la voce ES.09) e le catture dal Realme.

DOMANDA: riga della scheda: "L'ora d'oro di oggi. Dall'orario esatto degli aspetti della Luna ai punti natali si ricava un momento preciso della giornata"; domanda girata al fondatore: "Il Rahu Kalam [...] È il contrario della nostra ora d'oro", risposta: "COnfermo tutto."

PROVA: docs/collaudo/ES/ore_d_oro.csv
MISURA: scarto medio dal JPL DE440s su cinque ore d'oro 0,18 minuti; ore d'oro mostrate senza un aspetto vero, 0 su 6 giorni che non ne hanno

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

**DA FARE.**

DOMANDA: riga dell'Architetto: "La prima volta che la persona sceglie Cinese o Vedica, la figura in bronzo appare con la sua animazione e la frase "Il tuo segno cinese è il Cavallo". È il momento da condividere."

## VOCE ES.36, TRE TRADIZIONI SU TRE

**DA FARE.**

DOMANDA: riga dell'Architetto: "Quando occidentale, cinese e vedica danno lo stesso esito su un dominio, lo si dice: "Oggi tre tradizioni su tre vedono il lavoro favorevole". Se non sono d'accordo, si dice anche questo."

## VOCE ES.37, IL SIGILLO "TRE CIELI"

**DA FARE.**

DOMANDA: riga dell'Architetto: "un Sigillo "Tre Cieli" per chi legge tutte e tre le tradizioni nello stesso giorno."
