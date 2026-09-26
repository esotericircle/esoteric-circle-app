# ORDINE DO, IL SIGILLO DELL'INTENZIONE DIVENTA UN OGGETTO CHE VIVE

**Sigla:** DO. **Data:** 15 settembre 2026. **Ramo:**
`claude/esoteric-circle-master-order-e798aj`. Segue l'ordine DN, commit
`6ad6349e`, build 2261; gira dopo l'ordine DP, build 2262, per scelta del
fondatore. Sostituisce integralmente l'ordine DH, mai eseguito.

Il fatto, nelle parole del fondatore: alla fine della funzione ci si chiedeva
*"e adesso? cosa mi rimane? cosa ho ottenuto? cosa me ne faccio? cosa devo
fare?"*. La causa era una sola: **il Sigillo era un momento, e nella
tradizione e' un oggetto**. Adesso il sigillo tracciato entra nel Libro dei
Sigilli vivo e spento, si carica col dito, si mette come sfondo del telefono,
e alla data scelta Caligo chiede com'e' andata.

VOCI_TOTALI: 15
VOCI_CHIUSE: 15
VOCI_SBLOCCATE_E_APERTE: 0

Il rapporto sta in `docs/ordini/RAPPORTO_ORDINE_DO.md`, le schermate della
prova sul telefono in `docs/collaudo/DO/`.

---

## LE PREMESSE

Verificate sul commit `b885e2dd`, prima di toccare il codice.

| premessa | esito |
|---|---|
| P1, non esiste `docs/ordini/ORDINE_DH_MANIFESTO.md` | **vera**, zero file DH |
| P2, in `plan_catalog.dart` la parola sigillo non compare | **vera**, zero occorrenze |
| P3, nessuna nozione di scadenza, sigillo vivo o spento, Libro, tetto alle riformulazioni | **vera** per il Sigillo; *scadenza* compare in `lib` solo in tre file di altri domini |
| P4, esistono `ViaMagica` con nome e dominio, il campo `riformulata`, `IntentionSigil.cammino` e `lettereUniche`, il tracciamento di 2400 ms | **vera** |
| P5, intorno alla riga 401 il Condividi manca per l'ordine CG voci 06 e 08 | **vera**, riga 403 |
| P6, chi produce `riformulata` | **una tabella nel codice**, `LettoreIntenzione`: una frase fissa quando l'intenzione chiede di agire sulla volonta' di un altro, altrimenti la frase com'e'. Nessun modello |
| P7, il segno e' deterministico dal testo | **si'**, lo prova `sigillo_intenzione_test` a cento ripetizioni |
| P8, la via si sceglie o si deduce | **si deduceva** dalle parole, con un elenco per via e la Bianca di ripiego |
| P9, le prove sul Sigillo | `sigillo_schermata_test` e `sigillo_intenzione_test` sulla schermata e sul calcolo; `ogni_arte_dichiara_la_fonte`, la barra, la tipografia e le arti come guardie di casa |
| P10, le notifiche locali programmate dei Doni | **esistono**: `ServizioAvvisi` in `avvisi_del_rito.dart`, l'implementazione `AvvisiLocali` sopra `flutter_local_notifications`, consegna approssimata, un canale per chiamata |

---

## DO.00, IL FATTO E LE CINQUE DOMANDE. CHIUSA

Le cinque domande sono il metro di collaudo della voce DO.13; ognuna ha la
sua schermata, nel rapporto.

## DO.01, LE TRE INFORMAZIONI ALL'INGRESSO. CHIUSA

*Cosa stai per fare* sotto il titolo, *cosa ti restera'* prima del campo, *da
dove viene* in basso e breve, con The Book of Pleasure del 1913. Il foglio
delle fonti porta il perche' del non leggersi. **Una differenza dichiarata**:
le tre righe dettate avevano la virgola prima della *e*, e la regola della
virgola vale per tutte le stringhe di `lib` senza deroghe, per decisione del
fondatore sulle cornici del presagio. Le quattro virgole sono state tolte, il
senso resta. Il disclaimer resta dov'e': all'onboarding e alla registrazione.

## DO.02, IL SIGILLO E' UN OGGETTO CON UNO STATO. CHIUSA

`SigilloVivo` in `lib/core/magic/il_sigillo_vivo.dart`: intenzione,
riformulazione, via, segno (dal testo, deterministico), nascita, scadenza,
cariche, stato. Quattro stati. **Nasce vivo e spento**. Arriva alla sua data
all'inizio del giorno scelto, cosi' chi tocca la chiamata trova la domanda.

## DO.03, LA CARICA COL GESTO. CHIUSA

Si ripassa col dito il segno, dal cerchietto alla barra, passando per ogni
punto in ordine; se il dito si stacca si riparte dal capo. Una carica al
giorno per sigillo vivo. **Il segno si fa piu' luminoso e piu' inciso**:
tratto piu' largo e opaco, alone, ombra dello scavo e filo chiaro. Nessun
numero. La luce e' la radice della carica, cosi' la prima carica cambia il
segno a vista; si affievolisce con la curva della nitidezza del Viaggio. Il
gesto vince sullo scorrimento della pagina. Nessun modello. **Provata sul
telefono**: `11_la_carica_ha_acceso_il_segno.jpg`.

## DO.04, LA DIMENTICANZA LA FA L'APP. CHIUSA

La riga dell'ordine a tracciamento finito, sotto la data in cui l'app si fara'
viva. Il sigillo non compare in nessun'altra schermata.

## DO.05, LA FINE DEL CICLO. CHIUSA

Alla data, nel Libro e in cima alla schermata del Sigillo: *"Questo sigillo e'
arrivato alla sua data. Com'e' andata?"* con *Si e' compiuto*, *Lo lascio
andare*, *Lo rinnovo*. Il compimento porta il testo che nomina l'intenzione e
resta nel Libro, sigillato nell'oro.

## DO.06, IL LIBRO DEI SIGILLI. CHIUSA

`LibroDeiSigilliScreen` e la scheda `SigilloDelLibroScreen`: prima gli
arrivati alla data, poi i vivi per data, poi compiuti e lasciati dal piu'
recente. Di ognuno il segno con la sua luce, l'intenzione, la via, le date e
lo stato. Da qui si carica, si mette come sfondo, si rinnova, si dichiara. Il
comando *Porta alla data (Demo)* serve al collaudo.

## DO.07, IL SIGILLO COME SFONDO DEL TELEFONO. CHIUSA

I tre fondi del fondatore, impronte verificate (commit `3ee00e20`). Il segno a
luce piena nella fascia fra il 35 e il 60 per cento, largo il 55 per cento;
la luminosita' media della fascia, misurata sui fondi veri, e' 7,4, 23,5 e
22,5 su 255. Fuori dal segno **nessun pixel cambia**: nessuna scritta.
Android, *"Imposta come sfondo"* con Home, Blocco, Entrambe e il permesso
SET_WALLPAPER; iOS, *"Salva nelle foto"* con due righe e la chiave di sola
aggiunta. **Applicato davvero sul telefono**; la schermata di blocco il Realme
non ce l'ha, e lo si dice nel rapporto.

**Il cerchio come cornice e il glifo piu' grande**, chiesti dal fondatore
guardando la prima prova sul telefono: *"Buttato li' cosi', sembra uno
scarabocchio"*. La cornice prende tutto il 55 per cento consentito, un anello
nel colore della via con un filo interno e un alone; il glifo passa dal 42 al
47 per cento della larghezza. Le tre immagini composte sui fondi veri gli sono
state mandate prima della build. Oltre il 55 per cento si va solo su sua
parola, perche' quel limite lo ha fissato lui.

## DO.08, LA NOTIFICA ALLA SCADENZA. CHIUSA

`LaChiamataDelSigillo`, sul meccanismo dei Doni, canale suo, alle 10 del
giorno scelto a finestra approssimata. I due limiti sono dichiarati nel
codice. Il Libro programma, sposta e toglie la chiamata. Il testo non
contiene l'intenzione. **Verificate in coda sul telefono**: cinque chiamate
al 15 ottobre, una per sigillo aperto.

## DO.09, LA VIA E LA RIFORMULAZIONE. CHIUSA

La via si sceglie **prima** di scrivere, e resta quella dichiarata. La
riformulazione di Caligo e' su richiesta, Gemini 2.5 Flash su europe-west1
col blocco di cortesia, **tre per sigillo**. Una frase sulla volonta' di un
altro non si traccia: si riscrive su chi scrive. **Sui temi delicati Caligo
non riscrive**, e lo dice: la frase del metodo, *detta come se fosse gia'
vera*, diventava *"Io vinco la mia causa"*, *"Sono fertile"*.

## DO.10, I TESTI CON LE REGOLE DEL VIAGGIO. CHIUSA

Titolo, responso e compimento dal modello sull'intenzione vera, con tutte le
guardie del Viaggio, generalizzate con `diSostanza` per la prima persona del
metodo, **piu' le guardie nate da sette sonde col modello vero**, e la
riserva di casa. Due tentativi per il pezzo scartato.

## DO.11, I LIMITI E I COSTI. CHIUSA

Nella matrice: sigilli vivi insieme 1, 2, 3, 5; la carica sempre aperta.
Tetto tecnico di dieci tracciamenti al giorno. Al limite la strada per il
Libro, provata sul telefono. **Un sigillo completo costa 0,00072 dollari**.

## DO.12, LA CONCORDANZA DI GENERE. CHIUSA

Ogni testo di `lib` passa dal dizionario DL.06 nella guardia di casa; i testi
del modello dalle guardie con la forma scelta; la riformulazione, in prima
persona, da una guardia sua. Nessuna marca serve: nessuna frase di casa porta
un genere. La frase di tabella *"mi rendo degno"* e' diventata neutra.

## DO.13, LE PROVE E LA PROVA A VIDEO. CHIUSA

Le cinque domande con la loro schermata, nel rapporto. **La prova ha trovato
cinque guasti prima della release**, tutti curati con la loro guardia vista
rossa: lo sfondo che faceva ripartire l'app, il tasto indietro perso dopo la
ricreazione, il segno spento invisibile nelle miniature, il nome della via
senza contrasto, la riga falsa quando la riformulazione e' scartata.

## DO.14, IL RAPPORTO. CHIUSA

In `docs/ordini/RAPPORTO_ORDINE_DO.md`.

---

## LE GUARDIE

`il_sigillo_vive` e' nuova e non scopre insiemi di file; `sigillo_schermata`
e' riscritta sul percorso nuovo; `la_sonda_del_sigillo` chiama il modello vero
solo col token. **Cinquantuno innesti, quarantanove rossi**: i due verdi
erano il primo innesto di due guardie della riformulazione, cieche perche' la
guardia dei terzi del Viaggio prendeva gli stessi casi. Una e' stata tolta,
perche' ripeteva quella del Viaggio; l'altra e' stata rifatta su un caso che
solo lei vede, e al secondo innesto sono diventate rosse tutte e due.
