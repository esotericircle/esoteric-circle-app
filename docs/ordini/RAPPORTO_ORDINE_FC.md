# RAPPORTO DELL'ORDINE FC, L'OROSCOPO UNIVERSALE, UNA PORTA SOLA E IL VERDE CHE DICE IL VERO

**L'oroscopo di un amico e' l'Oroscopo.** La schermata dell'amico non c'e'
piu': chi apre l'oroscopo di un amico apre la stessa schermata del proprio,
col soggetto impostato su di lui, e ha il cielo, il gesto con la sua scena,
le infografiche, i quattro periodi e le tradizioni. Il nome dell'arte e'
"Oroscopo Universale". Il cancello di GitHub esegue gia' la suite intera, e
adesso il suo verde dice quanti e quali rossi ha accettato. Delle sette rosse
ereditate una e' chiusa, sei restano dichiarate col gesto che serve. E in
cima alla rubrica degli amici c'e' una riga che porta al Cerchio, coi
presenti quando il telefono li sa gia' (Aggiunta 1, voce FC.09).

Ramo `claude/esoteric-circle-master-order-e798aj`, partenza `bcf8eaff`, 4
ottobre 2026. Manifesto: `docs/ordini/ORDINE_FC_MANIFESTO.md`. Regola A:
`docs/collaudo/FC/regola_a_fc.txt`. Anteprime prima e dopo, a coppie, a 360
per 797 punti: `docs/preview/prima_dopo/fc_*`. Prova del cancello:
`docs/collaudo/FC/il_cancello_diventa_rosso.txt`. Build e consegna in fondo.

## LE VOCI CHIUSE, con la prova di ciascuna

- FC.01, l'oroscopo si chiama Universale: test/l_oroscopo_si_chiama_universale_test.dart
- FC.02, una porta sola per l'oroscopo: test/l_oroscopo_e_uno_solo_test.dart
- FC.03, il gesto e la riflessione ci sono sempre: test/l_oroscopo_e_uno_solo_test.dart
- FC.04, il fondale cosmico, non il nero: test/l_oroscopo_e_uno_solo_test.dart
- FC.05, le stesse infografiche: test/l_oroscopo_e_uno_solo_test.dart
- FC.06, giorno, settimana, mese, anno anche per l'amico: test/l_oroscopo_e_uno_solo_test.dart
- FC.08, il cancello esegue la suite intera: docs/collaudo/FC/il_cancello_diventa_rosso.txt
- FC.09, il Cerchio si vede dalla rubrica degli amici: test/il_cerchio_si_vede_dalla_rubrica_test.dart

La FC.07 e' APERTA: sei rosse su sette restano, dichiarate una per una qui
sotto e nel manifesto.

## LE PREMESSE ABBATTUTE

Verificate sul worktree alla testa `bcf8eaff` e sul Realme (build 2296),
prima di scrivere codice.

- **H1 vera.** `lib/features/amici/l_oroscopo_dell_amico_screen.dart`
  componeva le letture da se' (`Horoscope.forSign`, `LaLetturaCinese.schede`,
  `LaLetturaVedica.schede`) e ridisegnava tradizioni, schede, profondita' e
  corsa dello zodiaco.
- **H2 vera a meta'.** La riga c'era, alla 287. Ma nell'app
  `InterrogaIlCielo.ancheFuoriDalGiorno` valeva vero: lo spegneva solo la
  configurazione delle prove. Sul Realme il gesto dell'amico c'era. Il
  difetto che il fondatore ha visto era un altro, misurato a fotogrammi sul
  telefono: al tocco il pulsante spariva, per circa due secondi non si
  vedeva niente (ne' la corona dei corpi, ne' la riga della riflessione, che
  nella schermata dell'amico non esistevano), poi le schede comparivano
  sotto la piega. Nell'oroscopo proprio, nello stesso istante, la corona si
  raccoglie attorno all'emblema. L'interruttore e' tolto lo stesso.
- **H3 vera.** `Scaffold(backgroundColor: palette.deepest)`, nessun fondale.
  E nera era anche la lista "I tuoi amici", che e' il primo passo del giro.
- **H4 vera.** Una sola infografica (`DomainLevel`), nessun selettore dei
  periodi, solo il Giorno.
- **H5**: l'elenco e' nella sezione dopo.
- **H6 vera, e il conto non e' piccolo**: 78 occorrenze del nome in 46 file,
  ricomposte come le legge la persona (2 a video in 2 file, 12 commenti in
  10, 14 nelle prove in 9, 49 nei documenti in 26, 0 nel server, nelle
  notifiche e nei testi di condivisione).
- **H7 vera.**
- **H8 vera.** CLAUDE.md e gli agenti non nominano ne' la schermata
  dell'amico ne' il nome dell'arte.
- **H9 vera, e incompleta.** Le sette rosse ci sono, ma non erano in silenzio:
  stanno in `tool/rossi_accettati.txt` dalla loro nascita, due righe (la
  CR.13, e una riga per le sei guardie d'ordine). E non sono le sole: nello
  stesso registro ci sono dieci rossi del corredo a scala 1,3 (il Risveglio,
  la chat, la custodia del cielo, la galleria della Sinastria VIP). Il verde
  del cancello conteneva diciassette prove rosse.
- **H10 falsa.** Il cancello esegue la suite intera dall'ordine ACCELERA del
  26 settembre 2026: sei pezzi paralleli in `verde.yml`, piu' il corredo a
  scala 1,3, il server e le chiusure, e una decisione finale che scrive la
  ref del verde (`refs/verde/<sha>`), circa dieci minuti. Il verde non vedeva
  le sette perche' sono accettate, non perche' la suite non girasse. Il
  difetto vero e' quello della premessa: un verde con dei rossi accettati e
  un verde pieno si leggevano uguali.

## L'ELENCO DELLA PREMESSA H5: CIO' CHE L'OROSCOPO PROPRIO AVEVA E QUELLO DELL'AMICO NO

1. Il fondale cosmico in parallasse (`CosmosBackground`).
2. La barra con le fonti ("i") e il cuore dell'arte (`SogliaArte`).
3. L'emblema grande con la corona dei corpi che si raccoglie durante la
   riflessione, e il punto interrogativo della tradizione accanto al nome.
4. La testata col periodo e le date ("Oroscopo del giorno", la data).
5. Il selettore dei periodi, Giorno, Settimana, Mese e Anno, coi limiti del
   piano.
6. La Settimana e il Mese (il giorno migliore e il momento chiave di ogni
   campo), anche nella Vedica e nella Cinese; l'Anno dalla Rivoluzione
   Solare coi dodici mesi, la card dell'anno e il PDF; l'anno della Cinese e
   della Vedica.
7. La riga delle tradizioni che scorre, con le tradizioni in arrivo e il
   messaggio di Medora, e la lettura cinese e vedica aperta dal piano.
8. La scena della riflessione: i due momenti al posto delle schede (il fatto
   del giorno, l'almanacco, la Luna), la cascata delle schede a macchina da
   scrivere, l'attesa piena una volta al giorno.
9. I Tre Cieli di oggi.
10. Le infografiche della scheda oltre al livello: le ore del giorno, il
    numero e il colore della Fortuna, la ruota del passaggio, l'ora d'oro, e
    l'apertura col nome.
11. La nota del cielo e l'invito a completare i dati.
12. Le azioni del responso: custodire, parlarne con Medora, condividere.
13. La ragione per tornare domani (dove sara' la Luna).
14. La lettura completa di oggi con gli Eos.
15. La card dei periodi.
16. Il gesto nel Cammino.
17. La rivelazione del segno a foglio, la prima volta della Cinese e della
    Vedica.

E l'amico aveva tre cose che l'oroscopo proprio non aveva, portate dentro:
la riga "Oroscopo per" col nome dell'amico e il cambio di amico, la testa
della tradizione rivelata per lui (con la stessa chiave, quindi le teste gia'
viste restano viste), il premio della condivisione detto sull'amico. E una
quarta che sembrava scontata e che la porta unica stava per perdere, trovata
dalla prova riscritta: il segno detto di lui, "Il segno di Lucia è
Capricorno".

## LE DIFFERENZE RIMASTE DOPO IL GIRO DELL'UTENTE (R16)

L'oroscopo proprio e quello di Lucia percorsi uno dopo l'altro, sul codice e
sulle anteprime a coppie (sul Realme nella sezione della consegna). Tutte
volute, tutte scritte in `IlSoggettoDellOroscopo`:

1. **Il titolo nella barra**, solo per l'amico: "L'oroscopo di Lucia"
   (intero: nella prima stesura era tagliato, vedi i difetti).
2. **La frase del segno sotto l'emblema occidentale**, solo per l'amico.
3. **La nota del segno solare** al posto dell'invito a completare i propri
   dati e della nota del cielo: di un amico la carta non c'e'.
4. **Niente ruota del passaggio ne' ora d'oro** per l'amico: vogliono la
   carta natale. Tolte, non disegnate vuote.
5. **Niente nome nell'apertura delle schede** per l'amico: il neutro, perche'
   il suo genere non si sa.
6. **Il Sigillo dei Tre Cieli e' di chi guarda**: i Tre Cieli dell'amico si
   leggono, la riga del Sigillo no, e la lettura non lo accende.
7. **Il Cammino e' di chi guarda**: la lettura di un amico non entra nel
   Cammino, perche' il gesto segnala al server il rito compiuto e prima non
   ci passava (R14).
8. **La rivelazione del segno a foglio** dice "il tuo segno": per l'amico si
   rivela la testa in cima, e il foglio no.
9. **Gli inviti ai dati mancanti**, per l'amico, dicono cosa manca e di chi,
   e non si toccano: porterebbero ai dati di chi guarda.
10. **L'anno dell'amico** si calcola sul suo luogo di nascita (dove vive
    adesso non si sa), e non programma l'avviso del compleanno.
11. **La card e' un regalo**: "Il tuo oroscopo", "Te lo manda", e il premio
    dice "Hai mandato un oroscopo a Lucia"; parlarne con Medora apre con la
    frase sull'amico.
12. **Il cielo del fondale** ha il seme dell'amico.
13. **L'attesa piena e' una al giorno per chi guarda**: la seconda lettura del
    giorno, propria o di un amico, ha la riflessione breve, 3,0 secondi
    invece di 4,0 (ordine BK voce 05). Voluta: il rito si accorcia per chi lo
    ha gia' visto oggi.
14. **Il Rahu Kalam della Vedica e le ore del giorno** si calcolano dove sei
    tu, altrimenti sul luogo di nascita del soggetto: come faceva la
    schermata dell'amico.

## LA RIGA DEL CERCHIO NELLA RUBRICA (FC.09)

Il fondatore: *"in amico vorrei che comparissero anche gli amici online"*.
In cima alla rubrica "I tuoi amici" una riga sola, toccabile, nei tre casi
dichiarati in `lib/features/amici/il_ponte_verso_il_cerchio.dart`:

| caso | quando | testo segnaposto | il tocco |
| --- | --- | --- | --- |
| con i presenti | amici nel Cerchio e una tendina di questa sessione, vecchia al piu' un minuto | "Nel tuo Cerchio c'è 1 persona: 1 è qui adesso." | il tuo Cerchio |
| senza i presenti | amici nel Cerchio, tendina mai arrivata o vecchia | "Nel tuo Cerchio c'è 1 persona." (nessuno zero inventato) | il tuo Cerchio |
| il Cerchio ti aspetta | nessun amico nel Cerchio | "Il tuo Cerchio ti aspetta: chiama chi ti sta a cuore." | l'invito |

**I testi sono segnaposto dichiarati**, al neutro ("persone", perche' il
genere di chi e' nel Cerchio non si sa): li scrive l'Architetto. **Nessuna
lettura in piu'**: gli amici del Cerchio vengono dai legami che il telefono
ha gia', i presenti solo dall'ultima tendina; la riga non chiama mai la
tendina. Misura: chiamate al server all'apertura della rubrica **0 prima e
0 dopo** in tutti e tre i casi (`test/il_cerchio_si_vede_dalla_rubrica_test.dart`).
**La riga non elenca nessuno**: niente nomi, niente volti; l'elenco vive nel
Cerchio. Anteprime dei tre casi: `docs/preview/prima_dopo/fc09_rubrica_*`.

**Il ponte al contrario non c'e'**: misurato il 4 ottobre 2026, dal Cerchio
alla rubrica degli amici non porta nessun tocco, e la rubrica si apre solo
dall'oroscopo ("Oroscopo per"). Non costruito, come chiede l'Aggiunta. La
fusione delle due rubriche resta una decisione del fondatore (sotto).

**R16, il giro dell'utente sulla riga**: chi apre "Oroscopo per" per
scegliere un amico trova in cima il Cerchio, e un tocco lo porta via
dall'oroscopo; col tasto indietro torna alla rubrica, e da li' all'oroscopo.
E' la sola strada nuova, e torna indietro da dove e' venuta.

## LO STATO DELLE SETTE ROSSE (FC.07)

Rosse prima 7, dopo 6. Tutte rosse dalla nascita, volute dal loro ordine:

| rossa | cosa pretende | rossa da | stato |
| --- | --- | --- | --- |
| ACCELERA | zero voci aperte; ACCELERA.03 aspettava la prima consegna col verdetto di GitHub | 26/09/2026, `91c21317` | **chiusa**: la consegna era arrivata con la 2287 il 28/09, e il manifesto non lo diceva |
| CR.13 | le soglie della scansione a quattro pose misurate su un telefono | 06/09/2026, `6734d8c3` | **rossa dichiarata**: serve il fondatore davanti al Realme che gira la testa |
| EI | zero voci aperte; EI.10 | 23/09/2026, `83084b8b` | **rossa dichiarata**: il soffio vero del fondatore |
| EJ | zero voci aperte; sette voci | 24/09/2026, `8aa44dcd` | **rossa dichiarata**: giudizi del fondatore e risposte dirette non ancora a zero |
| EK | zero voci aperte; due voci | 24/09/2026, `9100412c` | **rossa dichiarata**: la scelta sul controllo dopo la risposta, lo sguardo sui volti |
| EM | zero voci aperte; sei voci | 25/09/2026, `55ab1bda` | **rossa dichiarata**: l'account del Realme fra i fondatori del LIVE (console), la televisione vera, l'attesa |
| EN | zero voci aperte; tre voci | 25/09/2026, `201ac46f` | **rossa dichiarata**: l'attesa del LIVE, la cornice, il testo delle 09:54 |

Nessuna cancellata, nessuna allentata. Per EI, EJ, EK, EM ed EN la forma delle
guardie dall'ordine EQ in poi (le aperte dichiarate e non pretese a zero)
sarebbe la cura (3), e contraddice la REGOLA G: e' una decisione del
fondatore, qui sotto.

## FIN DOVE SONO ARRIVATO, E PERCHE'

Tutte e nove le voci; otto chiuse, la FC.07 aperta con sei rosse che non si
chiudono senza un gesto del fondatore. **SUITE_E_CONSEGNA**

## LA REGOLA A E LA REGOLA B

**Regola A**: 23 innesti, tutti entrati (verificati col grep) e tutti rossi,
ognuno restituito al byte. Il registro e' `docs/collaudo/FC/regola_a_fc.txt`,
il banco `tool/gli_innesti_dell_ordine_fc.py`. Una nota: l'innesto A15 (il
catalogo col nome di prima) ha fatto cadere `il_nome_breve_dell_oroscopo` e
`i_domini_a_schede` nel banco; la terza, `le_schede_dell_arte`, l'ho vista
rossa a mano col catalogo di prima, perche' il banco ne mostrava solo due.

**Regola B mancata e recuperata**: le tre prove che pretendevano il nome
dell'arte le ho cambiate insieme al catalogo senza vederle rosse prima.
Recuperata con l'innesto A15, che le ha viste rosse dopo; la data nel
registro `docs/guardie.md` porta la nota. **Padre: ordine FC voce 01.**

**Una prova diventata tautologica, dichiarata**:
`le_tradizioni_dell_amico_nell_ordine_della_persona` controllava che la
riga delle tradizioni dell'amico seguisse l'ordine della persona; adesso la
riga e' una sola per tutti e due, e la prova non puo' piu' cadere per la
causa per cui era nata. La tengo, con la lapide; chi sorveglia la classe e'
`l_oroscopo_e_uno_solo`.

## LE ANTEPRIME

A 360 per 797 punti, a coppie (se', amico), in `docs/preview/prima_dopo/`:
`fc_tuo_apertura`, `fc_tuo_riflessione`, `fc_tuo_responso`,
`fc_tuo_settimana` e le stesse `fc_amico_*`, ognuna prima e dopo (manca solo
`fc_amico_settimana_prima`: la schermata dell'amico non aveva i periodi);
`fc_amici_lista` prima e dopo; i tre casi della riga del Cerchio
`fc09_rubrica_*`. Le "prima" sono uscite dal codice di `bcf8eaff` col gesto
riacceso nelle prove, perche' la configurazione di allora lo spegneva: la
variante della prova sta in
`docs/collaudo/FC/le_anteprime_dell_ordine_fc_prima_test.dart.txt`. Dove la
differenza si vede di piu': la riflessione dell'amico, prima sul nero senza
scena ne' periodi, dopo nel cosmo con la corona dei corpi e "Il cielo si
raccoglie.".

## I DIFETTI TROVATI, ognuno col suo padre

1. **La seconda porta dell'oroscopo.** **Padre: ordine ES voce 12.** E' la
   ventiduesima della famiglia delle due porte.
2. **La scena del gesto dell'amico, vuota.** La schermata dell'amico aveva il
   pulsante e la pausa, non la scena. **Padre: ordine EX Aggiunta 5, voce
   EX.12**, che ha messo il gesto nella copia invece di passare per l'unica.
3. **La lista degli amici nera.** **Padre: ordine ES voce 12.**
4. **ACCELERA.03 rimasta aperta dopo la consegna che la chiudeva.** **Padre:
   ordine ER**, che ha consegnato la 2287 col verdetto di GitHub senza toccare
   il manifesto ACCELERA.
5. **Il verde che non diceva i rossi accettati.** **Padre: ordine ACCELERA**,
   che ha portato la suite nel cancello, e l'ordine CODEMAGIC1 voce 05, che
   ha portato nelle annotazioni pubbliche solo il rosso.
6. **Nella prima stesura della porta unica, tre difetti miei. Padre: ordine
   FC voce 02.** Il segno non era piu' detto dell'amico ("Il segno di Lucia
   è…"), trovato dalla prova riscritta; il titolo dell'amico era tagliato
   ("L'oroscopo di Lu…"), trovato guardando l'anteprima; la lettura di un
   amico entrava nel Cammino, cioe' una chiamata al server in piu' per ogni
   lettura, trovato rileggendo il gesto per la regola R14. Tutti e tre
   corretti, con la loro prova.
7. **Le prove che leggevano i periodi senza toccare il gesto.** Erano verdi
   grazie all'interruttore, e cinque sono cadute quando l'ho tolto (piu'
   quattro che non si vedevano, in un file che non compilava). **Padre:
   ordine EX Aggiunta 5, voce EX.12**, che aveva spento il gesto nella suite
   invece di farlo toccare. Adesso toccano (`test/il_gesto_nelle_prove.dart`).
8. **Il banco**: tre volte l'heredoc della shell ha tolto le barre rovesce
   da uno script Python, due volte prima di scrivere (fermato
   dall'asserzione) e una volta scrivendo in una prova (trovato dall'analisi);
   e un'espressione regolare sbagliata nella prima stesura della guardia di
   FC.01 (trovata dall'analisi). **Padre: ordine FC, il banco.**

## LE DECISIONI CHE RESTANO AL FONDATORE

1. **Le sei rosse dichiarate**, ognuna col suo gesto: misurare le soglie
   della scansione sul Realme (CR.13); soffiare sul Soffio del Destino
   (EI.10); aggiungere l'account del Realme ai fondatori del LIVE dalla
   console (EM.02, 06, 07, 08); i giudizi su voci, volti, cornice e attesa
   (EJ, EK, EM, EN). Oppure decidere la cura (3) per le cinque guardie
   d'ordine: le aperte dichiarate invece che pretese a zero, contro la REGOLA
   G.
2. **La fusione delle due rubriche** ("I tuoi amici" sul telefono e "Il
   tuo Cerchio" sul server), e cosa succede alla scheda di una persona
   quando entra davvero nel Cerchio. La FC.09 e' un ponte, non la fusione.
   E i testi segnaposto della riga, che scrive l'Architetto.
3. **I dieci rossi del corredo a scala 1,3**, accettati dall'ordine CM e mai
   chiusi: sono testi tagliati a carattere grande nel Risveglio, nella chat,
   nella custodia del cielo e nella galleria della Sinastria VIP. Non erano
   in quest'ordine; li dichiaro perche' stanno nel verde.
4. **I quattro briefing**: nessuno usa "Oroscopo Personalizzato" come nome
   dell'arte (li' si chiama "Oroscopo a quattro versioni"); nel Briefing
   Progetto Definitivo ci sono due usi comuni, riga 22 ("l oroscopo
   personalizzato", sul posizionamento) e riga 49 ("oroscopi
   personalizzati", nel dominio di Medora). Li aggiorna l'Architetto.

## MIGLIORIE ED EFFETTI WOW CHE PROPONGO (R17)

Viste con il codice davanti, non costruite.

1. **La carta natale dell'amico.** L'amico ha data, ora, luogo e fuso: col
   motore che c'e' si potrebbe calcolare la sua carta, e allora la ruota del
   passaggio, l'ora d'oro e i transiti veri tornerebbero anche per lui. Le
   due infografiche tolte tornerebbero piene.
2. **L'oroscopo di coppia nella stessa schermata.** Dalla lettura di Lucia,
   un tocco che mette accanto i due giorni: dove i livelli si somigliano,
   dove si completano. I dati ci sono tutti.
3. **La card regalo con l'animazione.** La card dell'amico potrebbe partire
   come un breve video (la corsa dello zodiaco che si ferma sul suo segno),
   che sui social vale piu' di un'immagine.
4. **Il cielo dell'amico che si riconosce.** Il seme del fondale e' gia' suo:
   la sua costellazione potrebbe accendersi in oro nel cielo, come si accende
   la propria.
5. **Il promemoria del compleanno dell'amico**: il giorno prima, un avviso
   "Domani Lucia compie gli anni: il suo anno nuovo e' pronto", con la card
   dell'anno da mandarle.
6. **Il Cammino degli amici**, senza chiamate in piu': un traguardo locale
   "hai letto il cielo di tre amici", che oggi la regola R14 lascia fuori dal
   Cammino del server.
7. **Le lucine del Cerchio nella riga**: quando i presenti sono noti, tante
   lucine quanti sono, accese una dopo l'altra (non i volti, che la riga non
   elenca), e la riga che respira piano finche' c'e' qualcuno.
