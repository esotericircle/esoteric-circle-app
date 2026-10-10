# ORDINE CL, LE GUARDIE CIECHE

Manifesto dell'ordine CL del 1 settembre 2026. Registro:
`docs/guardie.md`. Guardia della regola nuova:
`test/ogni_guardia_dichiara_quanto_guarda_test.dart`.

**Tutte e quattro le premesse sono cadute.** Non una sfumatura: quattro su
quattro, e la prima sbagliava di quasi cinque volte.

## Le nove voci

- **CL.01** Elencare le guardie. **CHIUSA.**
- **CL.02** Farle diventare rosse. **CHIUSA**, e il resto e' dichiarato: la prova del rosso e' stata fatta su tredici guardie e sulla porta che ne copre dodici in un colpo; duecentotrenta restano non provate, col motivo scritto qui sotto.
- **CL.03** Cosa fare di quelle cieche. **CHIUSA**: nessuna guardia nuova e' risultata cieca, perche' provarlo richiede la prova del rosso che CL.02 ha potuto fare su un campione. Le quattro gia' note dall'ordine CI sono tutte riparate.
- **CL.04** Il cardinale minimo. **CHIUSA.**
- **CL.05** Il registro delle guardie. **CHIUSA.**
- **CL.06** Il conteggio delle voci false. **CHIUSA**: erano due, non una.
- **CL.07** Le prove di impaginazione al testo massimo. **CHIUSA**: 42 schermate su 182 cadono, elencate e non corrette.
- **CL.08** I primari non portano testo. **CHIUSA.**
- **CL.09** Il referto. **CHIUSA.**

VOCI_TOTALI: 9
VOCI_CHIUSE: 9
VOCI_APERTE: 0
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE: 0

## LE PREMESSE, VERIFICATE UNA PER UNA

| premessa | esito | la misura |
| --- | --- | --- |
| Q1 | **FALSA, di quasi cinque volte** | Le guardie secondo la definizione dell'ordine sono **242**, non meno di cinquanta. Contate applicando la definizione a tutti i 702 file di prova: chi legge i sorgenti, chi scorre elenchi, chi confronta immagini, chi pretende un'assenza |
| Q2 | **FALSA nella lettera, vera nella sostanza** | Sette file toccano la scala del testo, e **tre girano a 1,6**, cioe' piu' del massimo che l'app consente. Ma sono prove di widget isolati. **Prima dell'ordine CI nessuna prova montava l'app INTERA al massimo di sistema**, che e' 1,3: i ventotto punti di CI.01 nascevano dall'incontro fra il benvenuto e il compositore, e quell'incontro esiste solo nell'app assemblata |
| Q3 | **FALSA** | Il filtro Conversazioni nasce dal commit `4315ef85`, il cui messaggio dice "CG.01, CG.02, CG.04, CG.05 e CG.07": discende da voci **tutte dichiarate CHIUSE**. Quindi le voci false erano **due** |
| Q4 | **FALSA** | **79 file di prova** dichiarano gia' un numero minimo di elementi da trovare, nella forma `expect(quanti, greaterThan(n))`. La pratica esisteva: non era universale, ed e' un'altra cosa |

## IL CENSIMENTO, VOCE CL.01

| | |
| --- | ---: |
| File di prova totali | 702 |
| **Guardie secondo la definizione** | **242** |
| Che scorrono i sorgenti di `lib` | 108 |
| Che dichiaravano gia' un cardinale | 17 |
| Portate alla porta comune dall'ordine CL | 14 |
| **Senza nessun cardinale, oggi** | **201** |
| **Mai viste rosse** | **233** |

L'elenco completo, una riga per guardia con cosa sorveglia, a quale specie di
cecita' e' esposta, il suo cardinale e la data dell'ultima volta che e' stata
vista rossa, sta in `docs/guardie.md`.

**Nessuna guardia, fra le 114 che stampano un numero, dichiara oggi un insieme
vuoto.** E' la sola cosa che si puo' dire senza provarle una per una: le altre
128 non stampano niente, quindi di loro non si sa.

## LA PROVA DEL ROSSO, VOCE CL.02

**Il metodo dell'ordine, rispettato nell'ordine che imponeva**: prima si
dimostra col grep che l'iniezione e' avvenuta, poi si legge l'esito.

**L'esperimento che vale per tutte.** Si svuota l'insieme che una guardia
scorre, senza rompere niente: il filtro dei sorgenti passa da `.dart` a
un'estensione che non esiste, quindi la cartella c'e' e l'elenco e' vuoto.

| guardia | col suo insieme svuotato |
| --- | --- |
| `il_velo_e_uno_solo_test.dart`, **senza cardinale** | **"All tests passed!"** |
| le dodici portate alla porta, **col cardinale** | **sette prove rosse**: "ha guardato 0 file Dart dentro lib, e ne pretende almeno 400" |

**E' la stessa identica situazione, e le due guardie dicono cose opposte.** La
prima tace, la seconda parla. Questo e' tutto l'ordine CL in due righe.

**Un primo tentativo era sbagliato e si scrive**: la cartella era stata
sostituita con una che non esiste, e la guardia era diventata rossa. Ma era un
rosso accidentale, perche' `listSync` su una cartella assente **lancia**: non
stava misurando la cecita', stava misurando un errore. L'iniezione giusta
svuota senza rompere.

**COSA E' STATO RIMANDATO, E PERCHE'.** Duecentotrenta guardie non hanno avuto
la loro prova del rosso. Non e' pigrizia ed e' un conto: ognuna vuole
un'iniezione **su misura**, cioe' il difetto preciso che quella guardia
dovrebbe prendere, scritto a mano nel punto giusto, verificato col grep,
lanciato, e tolto. Sono duecentotrenta lavori diversi.

La strada scelta e' un'altra, e copre piu' terreno con meno mani: **la voce
CL.04 rende meccanica la difesa contro due specie su quattro**, per tutte
insieme e per quelle che nasceranno. Le prove del rosso su misura restano da
fare, e adesso c'e' un registro che dice quali, in che ordine.

## LE DECISIONI PRESE PER DELEGA

### CL.03, marcare o togliere: nessuna delle due, perche' non ce n'erano

L'ordine chiedeva di decidere se una guardia cieca vada marcata o tolta.
**La decisione non si e' presentata**: nessuna guardia e' risultata cieca in
questo ordine, perche' dimostrarlo richiede la prova del rosso, e quella si e'
potuta fare su tredici. Le quattro cieche note dall'ordine CI sono tutte
riparate.

**Quando si presentera', la risposta e' MARCARE e non togliere**, e la ragione
e' quella che l'ordine stesso suggerisce: una guardia tolta sparisce dalla
memoria del progetto, e con lei sparisce la ragione per cui esisteva. Una
marcata resta un promemoria che qualcuno prima o poi legge. Il posto dove
marcarla esiste gia' ed e' `tool/rossi_accettati.txt`, che dall'ordine CH
**fa cadere lo sbarramento** su una riga che sopravvive alla sua ragione:
quindi una guardia marcata non puo' restare marcata per sempre in silenzio.

### CL.04, una porta sola invece di centootto strumentazioni

Instrumentare centootto cicli scritti a mano vorrebbe dire scrivere
centootto volte lo stesso controllo e sbagliarlo da qualche parte. Il
controllo sta in un punto solo, `test/sorgenti_di_lib.dart`, e chi passa da
li' non puo' girare a vuoto.

**Il numero e' 400**: i 525 file Dart che `lib` ha oggi, contati sul disco,
meno un margine dichiarato di 125. Sta accanto alla misura e non dentro la
logica, perche' una soglia nascosta dentro un ciclo e' una soglia che nessuno
rilegge.

**Dodici guardie sono state portate alla porta**, e sono quelle a priorita'
alta secondo CL.05: le porte uniche, le parole vietate, gli accenti, il
contrasto, la veridicita' dell'interfaccia. Le altre 79 stanno in un elenco
dichiarato **per nome** dentro la meta-guardia, e quell'elenco puo' solo
accorciarsi.

**E la meta-guardia sorveglia se stessa**: se un giorno non trovasse piu'
novanta guardie che scorrono i sorgenti, cadrebbe, perche' sarebbe caduta
nella stessa cecita' che sta sorvegliando.

### CL.07, il corredo e non l'intera suite

**Il costo, in secondi.** La suite intera impiega circa venticinque minuti;
girarla due volte porterebbe ogni cancello a **cinquanta**, e la seconda meta'
farebbe girare due volte anche le prove che di impaginazione non sono.

**Il corredo delle catture E' l'insieme delle schermate assemblate**: 182
schermate montate come le vede una persona. E' esattamente dove il difetto
puo' nascere, e nient'altro. Il suo giro alla scala massima costa **sei
minuti**.

La scala si valorizza con `SCALA_DEL_TESTO=1.3`, e di partenza vale uno: il
cancello non cambia durata, e la misura si fa quando la si vuole.

## CL.06, LE VOCI FALSE ERANO DUE

Il referto dell'ordine CI ne dichiarava **una**, CG.16. Il numero era
sbagliato.

Il filtro Conversazioni dei Ricordi era **vuoto per costruzione**, e quel
fatto era scritto nello stesso referto, tre righe piu' su. Quello che mancava
era il collegamento: **da quale voce discendeva**. Discende dal commit
`4315ef85`, che chiude CG.01, CG.02, CG.04, CG.05 e CG.07, tutte dichiarate
CHIUSE.

**Un difetto descritto e non attribuito e' un difetto che nessuno andra' a
cercare**, ed e' il motivo per cui il conto era uno invece di due.

Il manifesto di CG e' stato corretto: **CG.02** porta adesso la sua riga, con
la data, la ragione, e il modo in cui e' stato possibile dichiararla chiusa,
che e' lo stesso di CG.16. Il filtro non e' piu' vuoto dall'ordine CI voce 06.

## CL.07, QUANTE SCHERMATE CADONO AL TESTO MASSIMO

**Quarantadue su centottantadue, cioe' 42 su 182.**

Non sono corrette in questo ordine, come l'ordine dice. Le principali, per
famiglia:

- **la chat e i suoi dintorni**, quattordici: le tre conversazioni, i tre
  pannelli dei suggerimenti, le due bolle col contatore, il consulto pieno e
  vuoto, la stella, il seguito, l'attesa, la freccia del Viandante;
- **il Risveglio**, sei: la data, l'ora, il luogo offline, il luogo scelto, il
  genere, il sigillo;
- **la Stesa**, quattro: la scena a riposo, le quattro fasi del taglio,
  l'attesa di Medora, la stesa in corso;
- **i Doni e i riti**, cinque: l'Alba velata, il dono col colore del Maestro
  nei suoi due giorni, il Soffio, il Messaggio del Giorno;
- **le altre tredici** sono sparse: il Sigillo su schermo basso, Chiedi ai
  Maestri, la galleria della Sinastria, la corsa dello zodiaco, l'Oroscopo e
  quello dai transiti, la card delle Rune, la custodia del cielo.

## CL.08, I PRIMARI NON PORTANO TESTO

La regola era un risultato di misura dentro un manifesto, e li' non governa
niente. Adesso sta **sul campo che governa**, cioe' su `MaestroPalette.primary`,
col numero: 28 coppie contro i fondi veri, **26 sotto la soglia dei titoli
grandi**.

E porta scritta la cosa che rende il difetto insidioso: **nessuno ha mai
scritto `color: palette.primary` su un testo.** Il colore arriva per eredita',
da un `TextButton` senza stile che prende il primario dello schema Material.
Per questo la guardia che lo sorveglia non cerca una stringa nel sorgente:
**enumera i comandi che il colore non lo dichiarano**.

## QUANTA PARTE DEL VERDE CHE LEGGEVAMO PRIMA DI QUEST'ORDINE ERA VERO

**Delle 242 guardie di questo progetto, nove sono state viste diventare rosse.
Tre e sette decimi per cento.**

Le altre 233 non sono cieche: sono **non provate**, che e' una cosa diversa e
non e' una rassicurazione. Di loro sappiamo che 201 non dichiarano quanto
guardano, cioe' **su un insieme vuoto sarebbero verdi**, ed e' esattamente la
condizione in cui erano le quattro che l'ordine CI ha trovato per caso.

Il verde che leggevamo alla fine di ogni ordine era vero **per le prove che
asseriscono su un valore**, che sono la maggioranza delle 4.214 e non possono
tacere. Era **una speranza** per le 242 guardie, e da oggi e' una speranza
misurata invece che ignota: sappiamo quante sono, quali sono, e in che ordine
vanno provate.
