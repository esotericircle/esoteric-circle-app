# ORDINE CZ, MANIFESTO

8 settembre 2026. Sedici voci: le feste dei traguardi, la Meditazione, e le
quattro risposte che mancavano.

## PERCHE' SI CHIAMA CZ E NON CY

**L'ordine e' arrivato col nome CY, e quel nome era gia' occupato.** La notte
fra il 7 e l'8 settembre e' stato consegnato un ordine CY, quello del testo
doppio e della sentinella della musica, e il suo nome sta dentro le note della
release `1r7u0qg4ifb60`, gia' rilette dal server.

Rinominarlo avrebbe reso false quelle note. **Decisione presa e motivata:
questo ordine e' CZ.**

---

## REGOLA ZERO

**Le tre righe che l'ordine cita sono state verificate sul ramo e
corrispondono tutte.** `regia_del_cammino.dart:273` porta
`if (conLaScena.isEmpty) return true;`; `meritaLaScena` pretende
`laStradaELibera`, `prossimoDi(sentiero)` e l'assenza dal
`_scenePerSentieroOggi`; il commento afferma che tre al giorno e' *"il numero
che il fondatore ha approvato"*. **Nessuna differenza da dichiarare.**

---

## PARTE PRIMA, LE FESTE

### La misura, prima della cura

L'ordine chiede il numero prima di correggere, e questo e' il numero. Su un
anno di uso onesto, con le venti arti compiute ogni giorno:

| | |
| --- | ---: |
| traguardi accesi | 2080 |
| con la loro festa | **1095**, il 52,6 per cento |
| **persi per la SCALA lineare** | **985** |
| persi per il tetto del giorno | 0 |
| persi per la strada occupata | 0 |

**Quasi meta' dei traguardi accesi non festeggiava mai, e la causa era tutta
la scala.** Dopo la cura: **2080 su 2080**. La misura vive in
`test/quante_feste_si_perdono_test.dart`.

### CZ.01, la scena lineare contro l'accensione sparsa. CHIUSA

Dal 3 settembre `quelliCheSiAccendono` accende i traguardi **sparsi**, come il
fondatore aveva chiesto il 26 agosto. La scena era rimasta governata da
`prossimoDi`, che e' **lineare**: un traguardo acceso fuori da quell'ordine non
e' mai il prossimo, quindi non meritava mai la scena.

**Accensione sparsa e festa lineare non possono convivere**, e le 985 feste
perse sono la misura di quella contraddizione. La condizione e' uscita.

### CZ.02, nessuna festa si perde in silenzio. CHIUSA

Il ramo `if (conLaScena.isEmpty) return true;` **dichiarava successo buttando
via la festa**. Violava nel modo peggiore la legge del fondatore del 23 agosto:
*una funzione trattenuta in silenzio va dichiarata a chi la aspetta, oppure non
va trattenuta.* Questa non la dichiarava e non la tratteneva: la cancellava.

Il commento *"Chi non ha la scena non entra nemmeno in coda"* descriveva un
comportamento che il fondatore non ha mai chiesto, ed e' uscito col codice.

### CZ.03, il tetto di tre feste al giorno. CHIUSA

**PROVENIENZA: ordine CQ voce 2.13.** Il tetto era gia' stato tolto il 23
agosto con l'ordine BD voce 08 ed e' tornato il 3 settembre **con un altro nome
e in un altro file**. Il commento affermava che tre al giorno era *"il numero
che il fondatore ha approvato"*: il fondatore dichiara di non aver mai
approvato nessun tetto numerico.

**LA CONSEGUENZA E' STATA MISURATA E PORTATA AL FONDATORE PRIMA DI
PROCEDERE.** Senza tetto il giorno peggiore dell'anno porta **tredici** feste a
chi compie tutte e venti le arti nella prima sessione, con una media di 5,67.
E' lo stesso tredici che aveva fatto nascere il tetto. La differenza e' che
adesso **non arrivano in raffica**: `FesteInCorso` ne tiene una a schermo e
mette le altre in coda.

Il fondatore ha letto la misura e ha scelto la **via uno, nessun tetto**.

### CZ.04, la strada libera. CHIUSA, e la valvola esiste gia'

Il caso peggiore che l'ordine chiede di dichiarare: **una festa che non trova
mai una schermata dove aprirsi lascerebbe la strada occupata per sempre.**
Verificato sul ramo: la valvola c'e' gia' ed e' il **confine del giorno
rituale**, in `diario_del_cammino.dart`, che congeda cio' che e' rimasto
appeso. Il commento la chiama per nome, *"valvola di sicurezza"*, e viene
dall'ordine CP voce 01. **Non ne serve una seconda**, e aggiungerla vorrebbe
dire due verita' sullo stesso fatto.

### CZ.05, le tre guardie. TUTTE NATE ROSSE

Innestati il tetto e la scala, **verificati col grep** alle righe 1311 e 1317
prima di leggere l'esito, tutte e tre sono cadute nominando il fatto:
`cal_16` acceso senza scena, il conto degli accesi che non arriva a cinque, il
tetto ritrovato nel sorgente.

La terza applica la **REGOLA H** ed e' il lucchetto contro il terzo ritorno:
cerca **sei nomi diversi** di conto delle scene in due file, **togliendo i
commenti prima di contare**.

### E quattro guardie esistenti custodivano il tetto senza dirlo

Lo zero delle otto aperture, il tre delle sette arti, il tre a strada libera e
il due dopo il congedo erano **tutti numeri prodotti dal tetto**, non dalla
difesa vera. Aggiornate con la ragione scritta.

### E UNA PRETESA ERA FALSA DA SEMPRE

*"Nessun evento accende piu' di un traguardo"* leggeva il numero delle
**SCENE**, che il tetto teneva a una per costruzione: **la prova passava senza
aver mai guardato una accensione.** Misurata la cosa giusta, su **5082 eventi**
un evento solo ne accende fino a **quattro**, e sono cieli rari che soddisfano
piu' condizioni insieme.

---

## PARTE SECONDA, LA MEDITAZIONE

### CZ.06, la frequenza la assegna Aura. CHIUSA

Le sette corrispondenze dell'ordine, lette **per posizione** e non per nome:
aggiungere un centro senza la sua frequenza non compila. Una riga sola di Aura
nomina il centro e il numero.

**La scelta libera non sparisce**: scende sotto, dietro un tocco, con la sua
etichetta. Una funzione tolta in silenzio e' cio' che la legge del fondatore
vieta; qui si sposta e si dichiara.

### CZ.07, le tre righe e la verita' sulle fonti. CHIUSA

Le due materie non hanno lo stesso peso, e il testo lo dice. Il solfeggio e'
una costruzione della fine del Novecento, attribuita a Guido d'Arezzo senza
nessuna fonte documentata prima degli anni Settanta. I binaurali hanno
letteratura vera, da Heinrich Wilhelm Dove nel 1839, **con risultati modesti e
non concordi**.

**E il DNA non si nomina affatto**, nemmeno per smentirlo: e' la promessa piu'
diffusa di questa materia, e nominarla per negarla la metterebbe comunque nella
testa di chi legge.

### CZ.08, il Loto guidato dal dito. CHIUSA

Il cerchio che si gonfia e' uscito, e il pittore a cimatica e' stato **tolto**
invece di essere lasciato spento: un componente che nessuno monta e' un
componente che qualcuno rimonta.

Dito giu' inspira, dito alzato espira, **vibrazione al cambio di fase** perche'
l'esperienza funzioni a occhi chiusi. La chiusura dura **quanto l'inspiro
appena fatto**: simmetria senza ritmo imposto. Con Riduci Movimento i petali
non si animano e la vibrazione resta.

### CZ.09, la card del respiro. FERMATA, e si dichiara

La figura c'e' ed e' calcolata: `RespiroGuidatoDalDito.figura` da' la quota del
dentro di ogni respiro, e la prova dimostra che **due respiri della stessa
durata ma di forma opposta danno figure diverse**, che e' la ragione per cui
vale la pena condividerla.

**Il disegno della card non e' montato**, e non lo dichiaro fatto. Passa dal
punto unico della condivisione, e va costruito sul modello che adesso esiste.

### CZ.10, la traccia che cresce. CHIUSA

Il fiore si riempie **coi centri, non con le sessioni**: chi respira sette
volte sulla gola ha il fiore pieno per un settimo, e i sei petali spenti sono
la domanda che si pone da sola.

**I tre traguardi proposti e non montati** stanno in
`docs/ordini/CZ_traguardi_del_loto.md`, con la condizione misurata contro i 55
del Loto. Il secondo **collide** e lo sconsiglio; il terzo **e' impossibile
come scritto**, perche' il centro segue il giorno della settimana ed e'
biiettivo, quindi tre giorni consecutivi portano sempre tre centri diversi.

**E UN DIFETTO MIO, PRESO DALLO SBARRAMENTO FINALE.** Avevo aggiunto il
prefisso `loto.` alla dimenticanza e non ai gruppi dello scarico: la traccia
dei respiri si sarebbe **cancellata senza potersi scaricare**, cioe' chi
avesse chiesto i propri dati ne avrebbe ricevuti meno di quanti l'app ne
tiene. Lo ha colto la guardia BC.02 *"e non si scarica meno di quello che si
cancella"*, che confronta le due liste invece di guardarle una alla volta:
`prefissi che si cancellano 31, gruppi dello scarico 30, scoperti 1`.
Riparato in `lib/core/identity/scarico_dei_tuoi_dati.dart` col gruppo *I tuoi
respiri nella Meditazione*.

---

## PARTE TERZA, LE QUATTRO RISPOSTE

### CZ.11, la notifica. RISPOSTA DAL TELEFONO, e c'era una seconda causa

**Prima:** sveglia programmata per le 04:40, alle 04:41 **uscita dalla coda**, e
in `dumpsys notification` **nessuna notifica**.

**La causa:** nel manifest c'era solo `ScheduledNotificationBootReceiver`,
quello del riavvio. **Mancava `ScheduledNotificationReceiver`**, quello che
riceve la sveglia e posta l'avviso: il broadcast non trovava nessuno.

**E' mio, ed e' della voce CW.06**: ho aggiunto il receiver del ritorno e non
quello dell'arrivo, e la guardia che avevo scritto chiedeva per nome soltanto
il primo, restando verde su un manifest che non poteva consegnare niente.

**Perche' il pulsante di prova funzionava:** `show` posta subito e dentro il
processo dell'app, senza passare da nessun receiver.

**Dopo:** sveglia 04:55, alle 04:57 la notifica c'e', id 1101, canale
`dono_breath`, **vista nella tendina**.

**E un secondo difetto dalla stessa misura**: la coda portava l'Alba alle 06:00
mentre il menu' dichiarava le 07:00. `programmaProssimo` non guardava l'ora
scelta. Riparato: l'ora scelta a mano vince su tutto, e il sorgere vero resta
solo quando vale ancora l'ora d'ancora.

### CZ.12, il censimento della parola rito. FATTO, e nulla e' stato cambiato

**115 occorrenze, 112 righe distinte**, in `docs/ordini/CZ_censimento_rito.txt`
e classificate in `CZ_censimento_rito.md`.

**Su 112 righe una sola nomina una formula da pronunciare**, ed e' quella dove
il fondatore ha gia' messo MANTRA. Le altre sono azioni da compiere, nomi
propri di schermate, o **chiavi di SharedPreferences che non si toccano**
perche' rinominarle azzererebbe le ore scelte su ogni telefono.

### CZ.13, le tre premesse dell'ordine CW. NOMINATE

1. **CW.02 diceva che il Sigillo non ruota il Maestro.** Ruotava: era il solo
   pulsante ad avere un nome scritto a mano. *Nasce dallo screenshot con due
   nomi diversi: chi ha scritto la voce ha concluso che il nome non cambia
   mai, mentre cambiava in un punto solo su due.*
2. **CW.05 dava i punti nel titolo come regressione.** La correzione non era
   mai stata fatta. *Nasce dal registro degli ordini, che porta CQ1.07 col nome
   "la stella" senza dire quale proprieta' misurava: un titolo di voce non e'
   la voce.*
3. **CW.06 attribuiva la perdita delle notifiche al fuso.** Era gia' riparato
   da CQ 1.09. *Nasce dal referto di CQ, che descriveva il difetto con molta
   forza e non diceva altrettanto chiaramente che era chiuso: un difetto
   raccontato bene resta in mente piu' a lungo della sua cura.*

### CZ.14, come un rosso ha attraversato una consegna. TROVATA E CHIUSA

1. **Lo sbarramento gira su tutte le guardie.** `flutter test "$@"` senza
   argomenti e' la suite intera, e `codemagic.yaml` lo invoca cosi'.
2. **La via esiste, ed e' che la consegna non lo chiamava.**
   `tool/consegna.py` **non nominava lo sbarramento in nessuna riga**: erano due
   strumenti separati. Chi costruiva e caricava consegnava su qualunque rosso,
   **senza scavalco e senza lasciare traccia**. Lo scavalco dichiarato,
   `SPEDISCO_SU_ROSSO`, almeno si stampa; saltare lo sbarramento non si vedeva.
3. **Adesso lo sbarramento scrive un gettone** col numero di build e col conto
   delle prove, nei tre rami che lasciano produrre l'archivio, e **lo cancella
   quando la suite e' rossa**. La consegna lo legge e si ferma se manca o se il
   numero non e' il suo: un gettone di ieri non vale per la build di oggi.

### CZ.15, la bonifica sotto la Regola H. CENSITA, e la porta esiste

Su **813 file di prova**: **88** provano una presenza senza provare nessuna
assenza, **311** leggono il sorgente senza togliere i commenti. Elenchi in
`docs/ordini/CZ_regola_h.txt`.

**Invece di riscrivere 311 file con la stessa logica duplicata si e' scritta
una porta**, `senzaCommenti` in `test/sorgenti_di_lib.dart`. Toglie righe,
blocchi e commenti di coda, e **non tocca le stringhe**: una barra dentro un
indirizzo non apre nessun commento.

**Le altre restano elencate per un ordine successivo**, come la voce dice.

### CZ.16, la prova visiva. FATTA, e una fotografia manca

Dispositivo 767f596c, build 2236 installata e accesa senza FATAL EXCEPTION.

| file | cosa si vede dentro |
| --- | --- |
| `01_notifica.png` | nella tendina, **Soffio del Destino**, *"È l'ora del respiro. Il Soffio del Destino ti aspett…"*, col nome e l'icona di Esoteric Circle |
| `02_loto.png` | il Loto a sette petali **chiuso**, e *"Oggi è acceso il sacro, Svadhisthana, che apre su ciò che ti muove: la tradizione gli accosta i 417 hertz"*, piu' *"Preferisco scegliere io"* |
| `03_loto_respira.png` | lo stesso fiore **aperto sotto il dito**, coi petali distesi su tutto il riquadro |
| `04_mantra.png` | il riquadro **IL MANTRA DI OGGI** nel Rito dell'Alba |

**LA FOTOGRAFIA DELLA FESTA NON E' STATA OTTENUTA**, e lo dichiaro invece di
darla per fatta. Il profilo di collaudo ha gia' compiuto i gesti che
accendevano i traguardi raggiungibili, e nella sessione di questa notte non ne
e' maturato nessuno da fotografare. **Le tre guardie della voce CZ.05 provano
il comportamento sul dato**, e la prova a video resta da fare al primo
traguardo che si accende.

---

VOCI_TOTALI: 16
VOCI_CHIUSE: 15
VOCI_APERTE: 0
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
VOCI_FERMATE_SU_LAVORO_NON_MONTATO: 1
GUARDIE_NUOVE: 10
PREMESSE_DELL_ORDINE_CORRETTE: 0
VERIFICA_A_VIDEO: 767f596c
