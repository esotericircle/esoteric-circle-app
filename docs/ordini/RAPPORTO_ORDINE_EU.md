# RAPPORTO DELL'ORDINE EU

L'Oroscopo dopo il collaudo del fondatore sulla 2289, e i testi
dell'Architetto. Ordine del 1 ottobre 2026 in due pezzi, diciannove voci, piu'
la **EU Aggiunta, i testi dell'Architetto** (dodici corpora nuovi). Ramo
`claude/esoteric-circle-master-order-e798aj`, partenza dal commit `902ef8e5`.
Manifesto `docs/ordini/ORDINE_EU_MANIFESTO.md`, prove in `docs/collaudo/EU/`,
quelle del telefono in `docs/collaudo/EU/realme/`. **Questo ordine non
consegna niente**: le due build fatte per il Realme portano il numero 2289 e
non sono consegne.

**Il conto** (manifesto riletto dal file): CONTO_DA_SCRIVERE

## LE VOCI CHIUSE, CON LA LORO PROVA

VOCI_CHIUSE_DA_SCRIVERE

## LE VOCI APERTE IN ATTESA DI VERIFICA

VOCI_APERTE_DA_SCRIVERE

## I DIFETTI, COL LORO PADRE (Regola C)

Trovati dalle guardie prima dei commit, dalla suite intera del 1 ottobre e
dal Realme.

- **La storia delle fasce vedica leggeva la Luna dell'ultimo giorno
  calcolato** invece di quella del giorno chiesto, e la stessa voce tornava
  il giorno dopo (1.999 ritorni in novanta giorni). Padre: EU Aggiunta, prima
  del commit. Preso da `i_testi_non_tornano` (627).
- **Le righe della Settimana e del Mese della Vedica e della Cinese dicevano
  "oggi"** per giorni che non erano oggi. Padre: EU.02, prima del commit.
  Preso dall'agente che ha scritto `docs/collaudo/EU/affermazioni.md`,
  leggendo il codice.
- **Il compleanno del 29 febbraio** negli anni senza 29 febbraio diventava il
  1 marzo. Padre: EU.02, prima del commit. Preso dal confronto col JPL.
- **La prova `l_oroscopo_non_si_riscrive` toccava un tasto sotto il bordo**
  della finestra dopo la riga "Oroscopo per". Padre: EU.05 (`ae2d9370`).
- **Il PDF dell'anno su due pagine**, che Acrobat in Modalita' Liquida
  ricompone ripetendo in fondo i titoli della prima pagina. Padre: ordine ES
  voce 04 (`50747b54`).
- **I livelli dei giorni piatti** per settimane (i pianeti lenti senza tetto).
  Padre: ordine ES voce 28 (`b6106fb7`).
- **Dalla suite intera del 1 ottobre** (commit `8b9a581a`, 6.365 verdi, 11
  saltate, 20 rosse, di cui 7 accettate in `tool/rossi_accettati.txt`):
  - `corredo_anteprime`: la guardia del PDF dell'anno scrive file con
    `writeAsBytes` e il corredo la prendeva per una cattura senza rapporto di
    pixel. Padre: EU.12 (`ea18ad72`). Cura: la riga di eccezione con la
    ragione (scrive PDF, non catture).
  - `language_rule`, la regola della virgola: la nota del metodo dell'anno
    vedico ("al tuo compleanno, e si contano"). Padre: EU.02 (`67ca80b7`).
    Cura: la frase senza la virgola davanti a "e".
  - `ogni_decimale_a_video_passa_dalla_lingua`: la chiave della memoria delle
    storie del Giorno con `toStringAsFixed(3)`. Padre: EU Aggiunta
    (`67ca80b7`). Cura: la chiave in millesimi di grado interi.
  - `la_profondita_si_sceglie`, `la_profondita_sta_su_ogni_scheda`,
    `oroscopo_widget`: pretendevano l'invito al "Cerchio Premium" sul
    lucchetto della Lunga. Padre: EU.15 (`8b9a581a`), che ha messo le due
    strade e il piano chiamato per nome. Riscritte con la lapide.
  - `tipografia_nel_dato`: il censimento dei vuoti verticali era a 159, le
    viste nuove ne hanno 161. Padre: EU.09 ed EU.11 (`9b3e7aff`). Rigenerato.
  - `il_genere_non_si_indovina`, `la_carta_natale_sopravvive`,
    `la_parola_voce_resta_allaudio`, `testo_a_video`: falsi positivi sui
    corpora dell'Architetto ("una stanchezza che ha bisogno di essere
    riconosciuta", "gli altri scelgono ora e luogo", "tre voci brevi", "a
    quattr'occhi", "un vago 'se serve'"). PROVENIENZA: EU Aggiunta, i testi
    sono giusti e le guardie li leggevano male. Cura: le frasi dichiarate una
    per una con la loro ragione (non i file interi), le elisioni "quattr'" e
    "ventiquattr'", e la guardia dell'apostrofo che toglie le citazioni fra
    apici prima di cercare (misura cambiata, mai la soglia). Viste rosse dopo
    su sei difetti veri innestati (`docs/collaudo/EU/regola_a_guardie_di_casa.txt`).
  - `niente_vocativo_a_schermo`: "amico/a" sul pulsante della riga "Oroscopo
    per". E' la parola del fondatore (*"pulsante [amico/a]"*): dichiarata con
    la sua frase.
  - `il_cancello_aspetta_il_limite`: rossa nella suite mentre girava la build
    di release, verde da sola. PROVENIENZA IGNOTA nel senso stretto: nessuna
    voce EU tocca il cancello, e la prova misura un tempo sotto il carico di
    due lavori.
- **Dal Realme** (build di prova dal commit `8b9a581a`), sette difetti, ognuno
  con la sua prova nata rossa sul codice di allora
  (`docs/collaudo/EU/regola_a_dopo_il_realme.txt`):
  - **un suono alla pressione dell'invio**, la terza tradizione letta nel
    giorno: il Sigillo dei Tre Cieli suonava la rivelazione 0,5 secondi dopo
    il tocco. Padre: ordine ES voce 37 (il suono del Sigillo); la voce EU.03
    non l'aveva trovato perche' parte da un'altra porta e solo la terza volta.
  - **"Da dove viene" due volte di fila** nella Lunga della Settimana e del
    Mese della Vedica e della Cinese (il giorno migliore fra i tre giorni
    migliori e di nuovo in fondo, con "Il" maiuscolo dopo i due punti). Padre:
    EU.02 (`67ca80b7`).
  - **la testata dell'Anno della Cinese con le date dell'anno del ritorno del
    Sole**. Padre: EU.04 (`26b98680`), scritta prima che la EU.02 desse alla
    Cinese e alla Vedica il loro anno.
  - **"Il colore è quello di Il Sole"** sotto il numero fortunato. Padre:
    ordine ES voce 29 (`b6106fb7`).
  - **"VIANDA / NTE"** nella schermata dei piani col Viandante attivo. Padre:
    EU.07 (`eadaf701`), che ha portato il badge sul Viandante.
  - **"Lunga" col lucchetto sopra il testo della Breve** per chi scende al
    Viandante con la Lunga scelta. Padre: EU.07 ed EU.15: la discesa di piano
    dal telefono prima non esisteva.
  - **"La Lunga ogni giorno con l'Iniziato" su due righe allineate a
    sinistra** nel pulsante delle due strade. Padre: EU.15 (`8b9a581a`).

## PER L'ARCHITETTO

Code non ha cambiato una virgola dei dodici corpora (regola fissa 11). Le
cose che ho visto e che tocca a lui decidere:

1. **Tre frasi col futuro di un gesto scelto**: "decidi già adesso a che
   ora tornerai a casa" (`oroscopo_eu_occidentale_giorno.md`, riga 870),
   "Alla prossima richiesta partirai da lì" (riga 1300), e "domani
   indosserai" (riga 470). Il confine del responso (`confine_del_responso.dart`) le
   leggeva come previsioni e le avrebbe tagliate. **Scelta consigliata**:
   il confine non legge piu' come previsione il futuro di un gesto che la
   persona sceglie in una relativa ("a che ora", "in cui", "ciò che",
   "quello che"); i testi restano interi. Se l'Architetto preferisce
   un'altra forma, si torna indietro.
2. **"Almanacco" 16 volte nei corpora cinesi** (Settimana 7, Giorno 5,
   Mese 2, Anno 2): e' un tecnicismo per chi legge le Linee Guida, sezione
   5? Da decidere.
3. **Un'ellissi "io sono..."** nel corpus cinese del Giorno (riga 679).
4. **Il Rahu Kalam**: prima l'orario stava nel testo; adesso sta solo nel
   "Da dove viene", e una delle tre varianti ("Siamo dentro il Rahu Kalam di
   oggi") non dice l'ora.
5. **88 affermazioni senza fonte** su 759 (Occidentale 31, Vedica 15,
   Cinese 42): l'elenco intero, una per una, sta in
   `docs/collaudo/EU/affermazioni.md`. E' la risposta alla domanda della
   EU.14 *"verifica che l'interpretazione sia reale e non inventata"*: 671
   hanno una fonte dichiarata, 88 no, e quelle le verifica l'Architetto.
6. **Note del metodo superate dai testi nuovi**: O-M-001 e O-M-002 ("La
   prima frase viene dalla Luna di oggi...") descrivono il testo di prima;
   C-M-002 ("il consiglio viene dal solo guardiano") parla di consigli che
   nessuna schermata legge piu'; C-M-004 dice che la scheda legge il dio come
   lo Yuanhai Ziping, e adesso il testo viene dal corpus e il dio resta nel
   "Da dove viene". Padre: EU Aggiunta (il testo e' cambiato, le note no).
   Sono righe dell'Architetto: le riscrive lui.
7. **"Bianco screziato" e "lo screziato"**: per il venerdi' il corpus vedico
   dice "lo screziato" e il codice "bianco screziato". PROVENIENZA IGNOTA fra
   le voci ES.09 ed ES.29.
8. **Righe scritte da Code in quest'ordine, che l'Architetto deve rileggere**:
   le righe dell'anno vedico ("Al tuo compleanno del ... Giove era in ...,
   nella tua ... casa dalla Luna di nascita: una casa favorevole") e
   dell'anno cinese ("L'anno del Cavallo va dal ... Tai Sui, il signore
   dell'anno: lo offendi, hai lo stesso animale dell'anno"), le due note del
   metodo dell'anno (`l_anno_delle_tradizioni.dart`), la riga "il giorno
   migliore, ...:" della Settimana e del Mese vedici e cinesi, e la riga
   "Il colore è quello del Sole" corretta dal Realme. La regola fissa 11 dice
   che queste righe non le scrive Code: le ho scritte perche' senza la
   Settimana, il Mese e l'Anno della Vedica e della Cinese non esistevano
   (EU.02, scelta "Proposta Architetto"), e le metto qui perche' le sostituisca.
9. **La riga della ruota (ordine ES voce 33) ripete il primo passaggio del
   "Da dove viene"** aggiungendo solo la casa: "Dal cielo di oggi: il Sole in
   quadratura al tuo Urano di nascita; ..." e subito sotto "Il Sole di oggi in
   quadratura al tuo Urano di nascita, nella tua terza casa" (Realme,
   `eu01_occidentale_giorno_breve_2.jpg`). Il fondatore ha chiesto di evitare
   le ripetizioni; la riga e' del "Da dove viene", quindi la forma la decide
   l'Architetto (proposta: la riga della ruota dice solo "Guardalo sulla tua
   carta, nella tua terza casa").
10. **Due giorni migliori di fila con lo stesso "Da dove viene"**: senza carta
    natale la Luna resta due giorni e mezzo nello stesso segno, e nella Lunga
    della Settimana due dei tre giorni migliori possono portare la stessa
    riga (la prova `il_da_dove_non_si_ripete_nel_periodo` l'ha trovato
    misurando: e' una verita' del cielo, non un difetto del codice). Come
    dirlo senza ripetere lo decide l'Architetto.

## LE SCELTE PRESE CON LA RISPOSTA CONSIGLIATA

Il fondatore: *"usa la risposta consigliata senza disturbarmi, non lasciare
niente in coda"*.

1. **Il PDF dell'anno su un foglio solo** largo quanto un A4 e alto quanto
   serve, invece di due pagine A4: con due pagine Acrobat in Modalita' Liquida
   ripete i titoli, con una no (EU.12).
2. **Il Mese a calendario** allineato ai giorni della settimana, con cinque
   righe, o sei quando il periodo comincia di domenica (EU.11).
3. **Cinque colori** dal giallo opaco al rosso fuoco (`FF5233`), uno per
   gradino del livello (EU.09).
4. **La percentuale** sulla barra migliore e' il livello per venti (5 = 100%).
5. **La Lunga della Settimana e del Mese**: i tre giorni migliori, ognuno col
   titolo della sua scheda del Giorno e il suo "Da dove viene" (prima la
   Settimana Lunga ne mostrava sette).
6. **L'anno cinese**: le quattro schede col livello del rapporto fra il tuo
   animale e quello dell'anno; il Tai Sui abbassa di un gradino quando l'anno
   ha il tuo stesso animale o ti "rompe".
7. **L'anno vedico**: il livello dalle case di Giove e Saturno contate dalla
   Luna di nascita (Phaladeepika, cap. 26), con la Sade Sati che abbassa;
   la regola e' scritta nella nota del metodo.
8. **Il confine del responso**: il futuro di un gesto scelto in una relativa
   non e' una previsione (vedi "Per l'Architetto", punto 1).
9. **La profondita' del Viandante nella tabella dei piani**: "Breve; la Lunga
   del giorno con gli Eos".
10. **Il carattere massimo** misurato nelle prove a scala 2,0, non sul
    telefono: la scala del sistema del Realme non si cambia.
11. **La rivelazione del segno con Riduci Movimento**: la figura compare
    intera, senza salire. Sul Realme le animazioni del sistema sono spente
    (le tre scale a 0), quindi a video si vede la figura intera, e
    l'animazione la vede chi ha le animazioni accese (EU.13 aperta per
    questo).
12. **Le frasi dei corpora che le guardie di casa leggevano male** si
    dichiarano una per una, con la loro ragione, e non si esclude il file:
    cosi' le 1.548 voci restano guardate.
13. **Il Sigillo dei Tre Cieli si accende senza suono** alla pressione
    dell'invio, con la sola vibrazione: il fondatore ha chiesto che alla
    pressione non suoni niente.
14. **Il nome del piano intero, il badge sotto se non c'e' posto**, invece di
    rimpicciolire il nome.
15. **Chi scende al Viandante con la Lunga scelta legge "Breve"** nel
    selettore: la voce mostrata e' quella che si legge.
16. **La cache delle storie del Giorno con la chiave in millesimi di grado**
    invece di tre decimali col punto.
17. **La scritta del piano al centro del suo pulsante** nelle due strade della
    Lunga, anche su due righe (visto sul Realme, la EU.15 l'aveva a sinistra).

## VISTE SUL REALME E NON CURATE IN QUESTO ORDINE

Cose viste guardando il telefono, fuori dalle diciannove voci, che lascio al
fondatore perche' cambiano il disegno e non un difetto di una voce:

1. **La barra dell'Oroscopo e' trasparente** e il contenuto le scorre sotto:
   la "i" delle fonti e il cuore stanno sopra il testo che passa, e a un
   certo punto dello scorrimento la "i" copre il punto interrogativo accanto
   al nome del segno (`eu01_occidentale_giorno_breve_2.jpg`, e la cattura del
   segno dopo "Interroga il cielo"). Proposta: lo stesso velo della barra in
   alto (EU.19) anche sotto questa barra. PROVENIENZA IGNOTA: la barra e'
   trasparente da prima dell'ordine ES.
2. **I titoli delle schede vanno a capo col trattino**: "UN COM- / PLIMENTO
   PRECISO", "RICOMIN- / CIARE DAL- / LE STANZE". E' la regola dell'ordine
   ER voce 14 (andare a capo fra le parole o col trattino a una sillaba), ma
   accanto al riquadro "Profondità" la colonna del titolo e' stretta e i
   trattini sono due nello stesso titolo. Proposta: il riquadro sotto il
   titolo quando il titolo non entra in due righe.
3. **L'ordine delle tradizioni dell'amico** e' Occidentale, Cinese, Vedica;
   quello della persona Occidentale, Vedica, Cinese.
4. **Il Mese e' di trenta giorni da oggi** ("dal 1 ottobre al 30 ottobre
   2026"), non il mese del calendario: e' la regola dell'ordine ES, e il
   1 ottobre il trentuno resta fuori.

## I COMMIT

COMMIT_DA_SCRIVERE
