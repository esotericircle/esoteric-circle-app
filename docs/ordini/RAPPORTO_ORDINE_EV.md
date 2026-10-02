# RAPPORTO DELL'ORDINE EV

Ramo `claude/esoteric-circle-master-order-e798aj`, partenza `0f7a0625`.
Il manifesto con le DOMANDA, PROVA e MISURA di ogni voce:
`docs/ordini/ORDINE_EV_MANIFESTO.md`. **Le voci 20: chiuse 9, aperte in attesa
di verifica 11.** Il pezzo 2 (le voci dell'Architetto EV.07-EV.10) e' arrivato
la sera del 1 ottobre, dopo la consegna della 2291; durante il suo lavoro il
fondatore ha segnalato il Viaggio che tace (EV.59) e ha chiesto le catture
indietro (EV.60).

**La stima, dichiarata prima di cominciare il pezzo 2**: cinque o sei ore
(EV.07 tre quarti d'ora, EV.08 due ore e mezza, EV.09 un'ora e mezza con le
catture, EV.10 un'ora, piu' suite, cancello, build e consegna). Oltre la soglia
dei novanta minuti: per la regola del fondatore ("usa la risposta consigliata
senza disturbarmi") non mi sono fermato.

## Le voci chiuse, con la prova

| voce | prova | misura |
| --- | --- | --- |
| EV.01 tutti i prezzi a 99 | `docs/collaudo/EV/realme/ev01_adepto_prezzi_interi.png` (e `ev01_iniziato_prezzi_interi.png`, `ev01_illuminato_prezzi_interi.png`) | prezzi non a ,99 da 5 a 0 su 9; sconti diversi dal calcolo 0 su 3; nomi e prezzi tagliati a 360 punti da 5 e 15 su 18 a 0 |
| EV.04 Medora non nega il responso | `docs/collaudo/EV/medora_e_il_responso.txt` | risposte che negano o ignorano il responso, da 9 su 10 a 0 su 10, in due esecuzioni con persone diverse |
| EV.51 le richieste di "Note di Keep" | `docs/collaudo/EV/note_di_keep.txt` | permessi sugli account nell'archivio 0 su 18 |
| EV.54 i tre Angeli nel Passaporto | `docs/collaudo/EV/realme/ev_angeli_tre_nel_passaporto.png` | carte nella bolla da 1 a 3, nomi da 1 a 3 |
| EV.56 niente catture dello schermo (superata da EV.60) | `docs/collaudo/EV/ev56_catture_bloccate.txt` | catture leggibili dalla build senza catture permesse, da tutte a 0 su 3 (0 byte, finestra SECURE) |
| EV.07 i corpora e il confine (con l'EV Aggiunta) | `docs/collaudo/EV/ev07_corpora_e_confine.txt` | file diversi dalla fonte 0 su 13; frasi al futuro rivolte a chi legge da 54 a 0; frasi fuori dal confine da 15 a 0 |
| EV.08 la verifica delle affermazioni | `docs/collaudo/EV/affermazioni.md` | affermazioni SENZA FONTE da 88 a 0 su 759; testi nuovi diversi dalla fonte 0 su 20 |
| EV.60 le catture tornano | `docs/collaudo/EV/ev60_catture_tornate.txt` | catture leggibili dalla build consegnata da 0 su 3 (2290) a 1 su 1 (2292), 338.676 byte |
| EV.10 il "Rivediamoci domani" | `docs/collaudo/EV/inviti_del_cielo.txt` | inviti col cielo sbagliato in sessanta giorni, da 101 a 0 su 480 |

## Le voci aperte, e che cosa manca a ognuna

| voce | fatto | manca |
| --- | --- | --- |
| EV.02 il Sigillo | corretto, guardato sul Realme (un tocco con la tastiera aperta traccia il sigillo) | l'iPhone di collaudo con una build da questo commit (Codemagic) |
| EV.03 Medora e il cielo | chat: da 13 su 20 fatti negati o sbagliati a 0 su 20 in due esecuzioni; Realme 3 date su 3 | il LIVE a voce sul Realme |
| EV.05 la tastiera | cura difensiva; Realme 0 su 3 ritorni con la tastiera aperta | l'iPhone di collaudo con la build nuova; la causa non si e' trovata (PROVENIENZA IGNOTA) |
| EV.06 ONLINE fermo a 1 | causa letta nel database, cura nel telefono e nel server | due telefoni con la build 2290 e la funzione pubblicata |
| EV.52 l'archetipo dopo la reinstallazione | corretto, prova rossa e verde | la reinstallazione con l'account del fondatore |
| EV.53 il Viaggio che torna al primo cammino | corretto e pubblicato sul server | un cammino nuovo e l'app riaperta |
| EV.55 la scheda delle notifiche | tolta dall'avvio, due righe al primo Dono | un telefono che non ha mai concesso le notifiche |
| EV.57 ONLINE che cambia numero | con EV.06 | con EV.06 |
| EV.09 le rifiniture dei "Da dove viene" | i cinque testi nel codice, guardia rossa su cinque innesti | le catture della Settimana Lunga vedica e cinese: dal Realme non si portano sul PC (il cavo cade oltre una decina di KB); le puoi fare tu dalla 2292, che lascia catturare |
| EV.59 il Viaggio che tace | silenzi al primo strato da 8 su 12 a 3 su 18; la cenere torna com'era dopo un silenzio | una discesa con la domanda scritta sul telefono del fondatore |
| EV.58 le memorie che tornano col tuo account | censimento di 40 prefissi, 12 famiglie nuove che viaggiano col Custode, i Ricordi mandati e ripresi, le arti preferite scelte che vincono; prove rosse e verdi, server provato | la funzione statoDelCerchio pubblicata con le memorie; poi la reinstallazione con l'account del fondatore, dopo che la build nuova ha mandato le memorie almeno una volta |

La voce EU.14 del manifesto EU porta la riga "prosegue nell'ordine EV, voce
EV.08", come l'ordine chiede; la EV.08 e' chiusa.

## Voce per voce

### EV.01, tutti i prezzi a 99

**Il difetto c'era nel codice di partenza**: 5 prezzi su 9 non finivano in ,99
(`test/entitlement_test.dart`, rossa sul commit `0f7a0625`). Padre: ordine EU,
che aveva portato a 99 solo quattro prezzi. Adesso i nove sono a ,99 e gli
sconti annuali sono ricalcolati: Iniziato 17 per cento (8,33 al mese), Adepto
21 (15,83), Illuminato 22 (23,33). Sul Realme la casella della settimana diceva
"SETTIM..." e "189,99" andava a capo con l'euro: si rimpiccioliscono quanto
basta per stare interi (`test/i_prezzi_dei_piani_stanno_interi_test.dart`, 18
caselle a 360 punti al carattere normale e massimo).

**Che cosa impostare negli store (lo fa il fondatore).** Nel codice non c'e'
nessun prodotto degli store: l'app non ha ancora la libreria degli acquisti e
la pagina dice "il pagamento non è integrato". Gli identificativi qui sotto
sono una proposta; quando li crei, scrivimi quelli veri e li metto nel
codice.

Google Play Console (Monetizza, Abbonamenti): un abbonamento per piano, tre
piani base ciascuno.

| ID abbonamento | piano base | prezzo (Italia, IVA inclusa) |
| --- | --- | ---: |
| `iniziato` | `settimanale` | 2,99 € |
| `iniziato` | `mensile` | 9,99 € |
| `iniziato` | `annuale` | 99,99 € |
| `adepto` | `settimanale` | 4,99 € |
| `adepto` | `mensile` | 19,99 € |
| `adepto` | `annuale` | 189,99 € |
| `illuminato` | `settimanale` | 6,99 € |
| `illuminato` | `mensile` | 29,99 € |
| `illuminato` | `annuale` | 279,99 € |

App Store Connect (Abbonamenti): un gruppo, "Il Cerchio", con nove abbonamenti,
in ordine di livello dall'Illuminato all'Iniziato (Apple usa l'ordine del
gruppo per gli aggiornamenti e i declassamenti).

| ID prodotto | durata | prezzo |
| --- | --- | ---: |
| `com.esotericircle.iniziato.settimanale` | 1 settimana | 2,99 € |
| `com.esotericircle.iniziato.mensile` | 1 mese | 9,99 € |
| `com.esotericircle.iniziato.annuale` | 1 anno | 99,99 € |
| `com.esotericircle.adepto.settimanale` | 1 settimana | 4,99 € |
| `com.esotericircle.adepto.mensile` | 1 mese | 19,99 € |
| `com.esotericircle.adepto.annuale` | 1 anno | 189,99 € |
| `com.esotericircle.illuminato.settimanale` | 1 settimana | 6,99 € |
| `com.esotericircle.illuminato.mensile` | 1 mese | 29,99 € |
| `com.esotericircle.illuminato.annuale` | 1 anno | 279,99 € |

### EV.02, "Traccia il sigillo" che non si tocca

**Il difetto c'era nel codice di partenza.** Il pulsante si accendeva solo
senza una proposta di Calìgo in sospeso; dopo "Chiedi a Calìgo di riscriverla"
la proposta restava sopra il campo, fuori vista con la tastiera aperta, e il
pulsante restava spento senza spiegazione. Padre: ordine DO (`de03a1ea`).
Adesso dice che cosa fa ("Scrivi la tua intenzione", "Calìgo sta riscrivendo la
frase", "Traccia con la forma di Calìgo", "Traccia il sigillo") e lo fa; il
tracciamento chiude la tastiera. Sul Realme, intenzione scritta e "Fra un mese"
scelto, tastiera aperta: un tocco, sigillo tracciato
(`realme/ev02_tastiera_aperta_pulsante_acceso.png`,
`realme/ev02_dopo_un_tocco_sigillo_tracciato.png`, filmato
`realme/ev02_sigillo_con_la_tastiera.mp4`).

### EV.03, Medora conosce il cielo di ogni giorno

**Il difetto c'era nel codice di partenza.** Al modello arrivavano sei pianeti
con la regola "Non nominare Urano, Nettuno e Plutone" (padre: ordine ET voce
01), e il cielo di oggi solo a chi aveva i dati di nascita (padre: ordine DS
voce 08). Al banco, col codice di prima, Medora diceva "Urano oggi non è
retrogrado", "solo Saturno è retrogrado", "Non ho tra i miei dati celesti la
posizione di Urano": 13 risposte su 20 con fatti negati o sbagliati.

**Come il dato arriva al modello.** Il modello di Medora (e degli altri due
Maestri, in chat e nel LIVE, che passano dalla stessa porta
`FirebaseMaestroAiProvider.reply`) riceve due funzioni:
`cielo_del_giorno(data)` e `cielo_del_periodo(dal, al)`. Quando la domanda
tocca il cielo, il modello le chiama; la libreria `firebase_ai` le esegue sul
telefono con `IlCieloPerIlMaestro`, che legge le effemeridi dell'app (le stesse
dei transiti dell'Oroscopo: dieci corpi, verificate contro il JPL fra il 2020
e il 2030), e rimanda al modello i fatti: segno e grado di ogni corpo,
retrogradi, segno, fase e luce della Luna, aspetti, eclissi, transiti sulla
carta natale; per un periodo gli ingressi, le stazioni, le lune nuove e piene
e le eclissi giorno per giorno, fino a un anno. La descrizione delle funzioni
porta la data di oggi e il cielo di oggi gia' calcolato, e dice che ogni fatto
del cielo viene solo da li'. Se il modello rimanda ("devo consultare il
cielo") o risponde a memoria sul cielo di un altro tempo, l'app gli chiede una
volta di chiamare la funzione. Dopo, la rete del cielo detto toglie le frasi
smentite dal calcolo: adesso lascia stare le frasi vere sugli altri giorni
chiesti e controlla "la tua Luna" e "il tuo segno" contro i dati di nascita.

**Il registro di tre domande con date diverse**, dal Realme
(`docs/collaudo/EV/registro_tre_domande_realme.txt`):

```
18:49:12 Cielo per il Maestro: cielo_del_giorno(2026-10-01)
18:50:01 Cielo per il Maestro: cielo_del_giorno(2020-12-21)
18:51:26 Cielo per il Maestro: cielo_del_periodo(2026-12-01, 2026-12-31)
```

Le risposte: "oggi Urano è retrogrado nel cielo. Si trova a 5 gradi in
Gemelli"; "Il 21 dicembre 2020 [...] Giove e Saturno erano congiunti a 0 gradi
in Acquario"; "A dicembre 2026 [...] il Sole in Sagittario [...] in Capricorno il
giorno 22".

**I banchi.** Venti domande (oggi, passato, futuro), con e senza dati di
nascita, sette giri letti a mano: ogni giro ha trovato qualcosa e ha cambiato
il codice (`docs/collaudo/EV/medora_verdetti.md`). Le due esecuzioni finali,
con due persone diverse: 0 fatti negati o sbagliati su 20 e su 20. **Resta
aperta per il LIVE**, che passa dalla stessa porta ma non e' stato provato a
voce sul Realme.

Le effemeridi dell'app non trovano l'eclissi lunare di penombra del 18 luglio
2027 (Medora ne dice quattro nel 2027, le fonti ne contano cinque): e' un
limite del motore delle eclissi, non della chat, e lo segnalo all'Architetto.

### EV.04, Medora non nega il responso

**Il difetto c'era nel codice di partenza**: "Parlane con..." passava alla
chat una frase sola col segno (padre: ordine CG voci 06 e 08), e chi scriveva
a mano non portava niente. Al banco, col codice di prima, 9 risposte su 10
negavano, non sapevano o inventavano il responso ("dimmi il nome della carta",
"Non conosco il Sigillo del Sogno", "Non ho un messaggio di un animale
guida"). Adesso ogni responso che compare si ricorda per il giorno; il
Maestro riceve i responsi di oggi, quello di partenza intero e per primo, col
"Da dove viene" dell'Oroscopo, e la regola di non negarli e di non chiedere
quale. Banco: 0 su 10 in due esecuzioni. Sul Realme: dall'Oroscopo, "Parlane
con Medora", "Che cosa vuol dire il transito che ho letto sotto la Generale di
oggi?": "il Sole in Bilancia di oggi è in quadratura al tuo Urano di nascita",
che e' il "Da dove viene" della scheda.

### EV.05, la tastiera aperta in home

**Non riprodotto**: col codice di partenza, sul Realme e nelle prove, la
tastiera si chiudeva gia' tornando; la cattura viene da un iPhone con una
build vecchia. PROVENIENZA IGNOTA. Il blocco: nei rapporti dell'iPhone di
collaudo nessuno dell'app; Crashlytics da qui non si legge (il progetto non ha
l'esportazione verso BigQuery): **guarda tu la console di Firebase,
Crashlytics, iOS, attorno all'ora del blocco**, e mandami cio' che vedi. Cura
difensiva: l'app chiude la tastiera da se' quando una pagina si chiude senza
un campo col fuoco e quando si cambia scheda nella barra. Sul Realme 0 su 3
ritorni con la tastiera aperta (chat, foglio dell'amico, Sigillo).

### EV.06 ed EV.57, "ONLINE"

Il numero e' quello delle persone con l'app aperta in tutto il mondo, letto
dal database del Cerchio: **non ha niente a che vedere con la rete locale**.
Restava a 1 e cambiava perche' ogni telefono chiedeva ogni due minuti e chi
chiudeva restava contato due minuti e mezzo: due telefoni si vedevano solo
quando le chiamate cadevano vicine (`docs/collaudo/EV/online.txt`, con le
presenze lette nel database). Padre: ordine ES voce 15. Adesso una chiamata al
minuto, una finestra di 90 secondi, e chi chiude esce subito. Sul Realme con
la build nuova, "ONLINE 2" mentre era aperto un secondo telefono.

### EV.07, i corpora corretti e il confine com'era

I cinque corpora dell'Architetto sono nel ramo uguali byte per byte (sha1 in
`docs/collaudo/EV/ev07_corpora_e_confine.txt`), i dati del codice
rigenerati, il confine identico a quello di prima dell'ordine EU.

**La misura ha trovato una cosa che il rapporto EU non diceva.** Col confine
di prima, sulle 6192 voci dei dodici corpora, le frasi col futuro di un gesto
sono **quindici**, non tre: il rapporto EU guardava solo le schede che le
prove componevano. Code non riscrive i corpora: sono dichiarate in
`test/le_frasi_dei_corpora_in_attesa.dart` e la voce resta aperta. **Per
l'Architetto**, le quindici, con la parola che il confine prende:

1. `oroscopo_eu_cinese_giorno.md` riga 330, "che cosa porterai";
2. riga 816, "il giorno in cui tornerai a farlo";
3. riga 1000, "l'ora in cui saluterai";
4. riga 1554, "riprenderai da un punto già caldo e non sprecherai";
5. `oroscopo_eu_cinese_mese.md` riga 107, "chi porterai";
6. `oroscopo_eu_cinese_settimana.md` riga 66, "la data in cui restituirai il favore";
7. riga 870, "la data in cui lo verificherai";
8. `oroscopo_eu_occidentale_giorno.md` riga 535, "la data in cui partirai davvero";
9. `oroscopo_eu_occidentale_settimana.md` riga 587, "passerai solo per il brindisi";
10. `oroscopo_eu_vedica_giorno.md` riga 311, "la guarderai domani mattina";
11. riga 1438, "l'orario in cui chiuderai il computer";
12. riga 1577, "un libro letto che non rileggerai";
13. riga 1635, "comprerai meno e cucinerai con più calma";
14. riga 1698, "deciderai ogni volta con lucidità";
15. `oroscopo_eu_vedica_settimana.md` riga 594, "non porterai messaggi".

La maggior parte e' il futuro di un gesto scelto, come le tre gia' corrette;
la 4, la 13 e la 14 dicono invece un effetto ("comprerai meno"), che e' piu'
vicino a una previsione. Padre del difetto di misura: ordine EU voce EU.14.

### L'EV Aggiunta, le frasi al futuro e le tre virgole

L'Architetto ha controllato i dodici corpora interi e ha riscritto **tutte**
le frasi con un verbo al futuro rivolto a chi legge (per il suo conto 55; per
il mio 54 frasi e 56 parole, fra cui "farai" 10 volte, "avrai" e "potrai" 6,
"userai" 5), e i tre testi del file di verifica con la virgola prima della
"e". I dieci file sono nel ramo uguali byte per byte; i tre testi nel codice
sono i suoi, carattere per carattere, e **i miei adattamenti col punto non ci
sono piu' (da 3 a 0)**; l'elenco delle frasi in attesa e' vuoto, e la EV.07 e'
chiusa.

**Perche' erano 55 e non 15**, ed e' una cosa da sapere: il confine del
responso cerca il futuro con almeno tre lettere prima di "-erai", "-irai",
"-drai", "-rrai", quindi "vedrai", "farai", "avrai", "potrai", "saprai" e
"userai" gli sfuggono. Il confine e' rimasto com'era per decisione
dell'Architetto; i futuri dei corpora li tiene fuori la guardia nuova
`i_corpora_non_dicono_il_futuro`, che legge ogni riga dei dodici corpora e
diventa rossa su qualunque parola in "-rai" non dichiarata (le dichiarate, una
per una con la ragione, sono "distrai", "attrai", "estrai", "sottrai",
"trai", "ritrai", "contrai"; nei corpora c'e' solo "distrai"). **Per
l'Architetto**: il confine vale anche per le risposte dei modelli (Rune,
Tarocchi), dove i futuri corti oggi passano; se vuole, la regola si allarga
con una sua voce.

### EV.08, la verifica delle affermazioni

Fatta tutta, coi testi e le fonti dell'Architetto: diciassette testi nuovi
nel codice e nei corpora, carattere per carattere, e ogni fonte accanto alla
sua frase. `docs/collaudo/EV/affermazioni.md` e' rigenerato da uno strumento
(`tool/rigenera_affermazioni_ev.py`) che parte dal file EU, da' a ogni riga
l'esito dell'Architetto e riporta ogni "file:riga" allo stato di oggi: 759
affermazioni, 722 con una fonte, 32 fatti di calcolo, 5 scelte dell'app,
nessuna senza fonte. **(Superato dall'EV Aggiunta: l'Architetto ha
riscritto i tre testi e gli adattamenti sono zero.)** **Tre testi nuovi
portavano una virgola prima della "e"** (O-M-006 "lo abbassano, e contano", V-M-001 "nel 1955, e il giorno",
C-G-069 "dodici giorni, e per il tuo"): la regola del fondatore non ha
deroghe, e la virgola e' diventata un punto ("lo abbassano. Contano"); ogni
altro carattere e' dell'Architetto, e la guardia dichiara i tre adattamenti.
Se l'Architetto preferisce un'altra forma, la sostituisce lui. **Una cosa
rimasta**: la regola del caso 1.8 del corpus
cinese dice ancora "Nella tradizione i rami uguali si rafforzano", la frase che
l'Architetto ha giudicato senza fonte in C-G-068. E' una nota del corpus, non
va a video, e Code non l'ha toccata: la riscrive l'Architetto, se vuole.

### EV.09, le rifiniture dei "Da dove viene"

I cinque testi dell'Architetto sono nel codice: "screziato" nella riga della
Fortuna, il Rahu Kalam in corso con l'ora, la riga della ruota "Guardalo sulla
tua carta, nella tua terza casa.", "lo stesso passaggio di giovedì 1 ottobre"
per il secondo di due giorni migliori uguali, e niente "oggi" sotto la data di
un altro giorno nella Vedica e nella Cinese ("Il livello viene dalla Luna di
quel giorno..."). Mancano le catture dal Realme: si fanno con la build nuova,
che lascia catturare.

### EV.10, il "Rivediamoci domani" col cielo sbagliato

**Da dove viene**: e' l'invito a tornare di Medora, scritto dall'app e non dal
modello (`ConsiglioFinale.invitoDelRitorno`), dal calcolo dell'app sulle sue
effemeridi; c'e' anche nel codice di oggi. **Sulle catture non si legge il
giorno**: "Rivediamoci domani: la Luna entra in Gemelli" alle 7:30 era vero il
29 settembre (ingresso alle 19:22 del 30, sulle effemeridi dell'app, d'accordo
con l'Architetto), e sbagliato il 30 settembre e il 1 ottobre, dove l'app di
allora avrebbe scritto un'altra cosa. Una strada per vederlo sbagliato c'era
davvero: la chat componeva l'invito con l'ora della risposta, e una
conversazione riaperta il giorno dopo diceva ancora "domani".

Misurando sessanta giorni sono usciti tre difetti, tutti corretti e provati:
l'ingresso cercato dall'ora piena (9 inviti sbagliati su 240), la fase
riconosciuta dal suo nome, che comincia dodici ore prima dell'istante esatto
(92 su 240: "Ripassa fra 8 giorni, per la Luna piena" alle 12 del 18
settembre, col Primo quarto alle 23), e l'ora della risposta al posto di
quella di chi legge. Dopo: 0 su 480. La rete del cielo detto, che controlla le
frasi di Medora, contava i giorni allo stesso modo ed e' corretta con loro.

### EV.51, "Note di Keep"

**Non sono dell'app.** L'archivio non chiede nessun permesso sugli account e
la registrazione con Google consegna solo l'account scelto. Le notifiche
"Autorizzazione richiesta da Note di Keep" sono di Google Play Services per
l'app Google Keep: puoi consentire se usi Keep su quegli account, altrimenti
ignorarle.

### EV.52, l'archetipo dopo la reinstallazione

**Il difetto c'era**: il Cerchio custodiva l'archetipo e nessuno lo
rimetteva sul telefono (padre: ordine AP voce 01). Adesso torna con gli Eos e
i Sigilli. Quando reinstalli e ti registri col tuo account, l'emblema deve
tornare senza rifare il Test.

### EV.53, il Viaggio che torna al primo cammino

**Il difetto c'era**, sul server: confrontava chiavi che il telefono scrive con
un altro nome, e restava fermo sulla prima copia (padre: ordine EE voce 13).
Corretto e pubblicato il 1 ottobre. **Il tuo secondo cammino non torna**: la
copia vecchia aveva gia' riscritto il telefono. Dal prossimo cammino resta.

### EV.54, i tre Angeli

Le tre carte a ventaglio e i tre nomi nella bolla del Passaporto.

### EV.55, la scheda delle notifiche

All'avvio non compare piu'. Alla prima apertura di un Dono: "Attiva le
notifiche. Ti avviso quando i tuoi Doni sono pronti. Puoi attivarle e
disattivarle dal menù Notifiche." col pulsante "Attiva". Il foglio scorre se
non ci sta: il pulsante giallo sotto la barra veniva dal testo lungo, che
spingeva il pulsante oltre il bordo.

### EV.56, niente catture dello schermo

Su Android lo schermo si protegge all'avvio: niente catture e niente
registrazioni, l'anteprima fra le app recenti e' nera. **Su iOS non si puo'**:
il sistema non lascia a un'app il modo di impedire una cattura. **Una
conseguenza da sapere**: anche voi fondatori non potete piu' mandarmi catture
dai telefoni Android con la build consegnata. Se vi servono durante il
collaudo, ditemelo e consegno le build di collaudo con le catture accese
(`--dart-define=CATTURE_PERMESSE=true`).

Provato sul Realme con la build 2290 senza catture permesse: la finestra
dell'app ha il segno `SECURE` e tre catture su tre escono vuote
(`docs/collaudo/EV/ev56_catture_bloccate.txt`).

### EV.59, il Viaggio dello Sciamano che tace

**Il difetto c'era, ed era grave.** Con la stessa strada dell'app e il modello
vero, la prima discesa con una domanda scritta finiva nel silenzio **8 volte
su 12** (`docs/collaudo/EV/viaggio_primo_strato_prima.txt`). Il modello
rispondeva, ma due guardie dello stile scartavano tutto: "non prende posizione"
(*"I segni del viaggio dicono di sì, se sai che cosa lasci"*, scartata perche'
la condizione non e' un passo) e "non nomina la domanda" (*"il matrimonio che
cerchi"* a *"quando mi sposerò?"*). Padre: ordine ES voce 25, del 30
settembre. Il silenzio dell'ordine DR voce 07 era nato per non dare la voce di
casa a chi ha scritto una domanda, non per tacere davanti a risposte del
modello scritte proprio per quella domanda.

Adesso, quando nessuna risposta regge, l'ultima scartata per lo stile si
rilegge con le sole guardie dure (previsioni, promesse, decisioni gravi,
terzi, genere, scena): se regge, e' la risposta. Un "sì" a una domanda sul
"come" non passa mai. Dopo: 3 su 18
(`docs/collaudo/EV/viaggio_primo_strato_dopo.txt`); i silenzi rimasti sono
risposte che prevedevano il futuro, ed e' giusto che non passino.

**Visto leggendo le risposte accettate, e non curato**: il modello scrive ancora
a volte frasi che una guardia non prende, *"Il matrimonio arriva quando..."*
dopo una condizione, o *"entro la fine di agosto"* per un concorso di ottobre.
Inseguire ogni forma con una regola non converge (l'ordine DN l'ha gia'
mostrato): lo dico qui perche' tu lo sappia, la cura vera e' nell'istruzione
del modello, ed e' una voce d'ordine. Il banco
dell'ordine ER, dopo il riconoscimento, resta sano
(`docs/collaudo/ER/viaggio/ev_dopo_lo_stile.txt`, 0 azioni col foglio).

**Il cammino fermo e l'animale gia' consumato** erano lo stesso silenzio visto
da due lati: il silenzio non consuma la discesa (per regola), ma la cenere
grattata era gia' salvata. Adesso il silenzio rimette la cenere com'era.
**E una guardia nuova** dalla stessa sonda: col profilo neutro il modello ha
scritto "se sei dispost a riconoscere"; ora quella risposta si scarta.

### EV.60, le catture tornano

Le catture si fanno di nuovo, anche dalla build consegnata. La protezione
resta pronta, spenta: si accende solo costruendo con
`--dart-define=CATTURE_VIETATE=true`, il giorno in cui la vorrai negli store.

### EV.58, le memorie che tornano col tuo account

**Il difetto c'era, e non solo nella Runa del Tramonto.** Hai chiesto di
cercare lo stesso problema nelle altre funzioni: l'ho cercato su tutte. Ho
preso ogni chiave che l'app scrive sul telefono e che l'app stessa dichiara
tua (40 prefissi) e ho guardato, per ognuna, se dopo una reinstallazione
torna. **Dodici famiglie non tornavano**, e adesso viaggiano col Custode
(lo stesso giro che gia' riportava Eos, Sigilli, Alba e Viaggio):

1. la Runa del Tramonto (le sere della settimana);
2. i riti, col loro ultimo giorno (la serie che vedi);
3. i dettagli del cammino: ora del gesto, sentieri, ultimo giorno;
4. i Sigilli del Libro;
5. gli amici offline gia' posti;
6. le sinastrie salvate;
7. gli Oroscopi aperti e comprati, i tre cieli, il segno e la testa rivelati;
8. le letture del mese;
9. il Loto;
10. i titoli delle conversazioni;
11. gli avvisi scelti;
12. il verso del Viaggio gia' udito.

E due strade che esistevano a meta': **i Ricordi del Cosmic Journal** non
arrivavano mai al Cerchio (la funzione che li manda non aveva chiamanti,
padre ordine CG voce 03): adesso si mandano e si riprendono una volta per
installazione. **Le arti preferite** tornavano indietro se le cambiavi dopo la
prima custodia (a parita' vinceva il server, e il telefono mandava anche lo
scaffale di partenza; padre ordine AP voce 02): adesso il telefono le manda
solo quando le hai scelte, e vincono.

Il padre del difetto principale e' l'**ordine AP voce 01** (commit
`d2f41ba0`): la custodia del cammino e' nata elencando alcune famiglie e
lasciando fuori le altre, senza un censimento che dicesse quali. La guardia
nuova (`test/le_memorie_tornano_col_tuo_account_test.dart`) pretende che ogni
chiave dichiarata tua abbia una casella: torna con le memorie, ha una strada
sua, o resta sul telefono con la ragione scritta. Una chiave nuova senza
casella la fa diventare rossa.

**Restano sul telefono, per scelta**: le impostazioni, i permessi, la
posizione, la cache della carta natale (si ricalcola), e tre cose che la
schermata e l'informativa promettono di non portare via dal telefono: la
lista degli amici offline, le letture del viso, lo storico completo
dell'archetipo (il dominante col suo giorno invece torna, voce EV.52). Se
vuoi che viaggino anche quelle, va cambiata prima la promessa scritta.

**Cio' che non torna**: le tue cinque sere del Tramonto. Stavano solo sul
telefono e la disinstallazione le ha cancellate prima che esistesse una
strada verso il Cerchio. Da questa build in avanti restano.

**Altri difetti trovati nel censimento, non curati in questo ordine** (non
toccano cio' che hai segnalato, li scrivo perche' non si perdano):

- l'Alba fusa sul server legge un campo `sacchetto` che il telefono non manda:
  PROVENIENZA IGNOTA, non risalito;
- l'identita' (nome, data, ora, luogo) si fonde campo per campo e a parita'
  vince il server: un cambio fatto sul telefono dopo la prima custodia puo'
  tornare indietro. PROVENIENZA IGNOTA, non risalito;
- l'elenco dei movimenti degli Eos non torna dopo una reinstallazione (torna
  il saldo): PROVENIENZA IGNOTA;
- la foto del profilo non torna: PROVENIENZA IGNOTA;
- la serie del cammino si fonde al piu' alto, e una serie interrotta sul
  telefono puo' tornare intera dal Cerchio: PROVENIENZA IGNOTA.

## Le guardie e la Regola A

Ogni prova nuova e' nata rossa, con l'innesto del difetto verificato col grep e
il file rimesso identico (sha1): `docs/collaudo/EV/regola_a_ev.txt`, innesti
A3-A43, piu' due innesti a mano sul server (le memorie lette dal cammino, le
arti preferite del telefono che vincono), rossi e poi rimessi. Due innesti sono stati verdi o rossi per la ragione sbagliata al primo
giro e sono stati rifatti, scritto nello stesso file (A6: la prova non misurava
la data; A17 e A19: la compilazione rotta; nel pezzo 2 A30, che cambiava una
parola che la guardia non legge, rifatto come A30b, e A41, che la misura non
poteva vedere, rifatto come A41b). **La Regola B** per il pezzo 2: prima di
toccare il confine ho visto rossa la sua prova (`il_confine_del_responso_test`
e `l_oroscopo_e_la_sua_anatomia_test`, rosse col confine di prima sulla frase
"partirai davvero"); il Viaggio e la nota del metodo li ho toccati senza
vederne rossa prima la guardia: lo dichiaro. Guardia nuova nel registro:
`ordine_ev_guard` (646). La Regola B non e' stata fatta prima di toccare le
zone del cielo detto, del Passaporto e dell'Oroscopo: lo dichiaro.

## La suite

La prima suite intera sulla copia (commit `42df2c2b`) ha dato 69 rosse: il
foglio delle notifiche compariva alla prima apertura di ogni Dono anche nelle
prove (difetto mio, corretto); tutte le rosse rifatte nel worktree di lavoro
sono verdi, salvo le 7 accettate (le soglie delle pose e sei guardie d'ordine
vecchie). Il cancello di GitHub ha poi trovato BC.02 (la chiave nuova dei
responsi mancava nello scarico dei tuoi dati) e due avvisi dell'analisi in
`tool/`: corretti.

La seconda suite intera, sul commit `b2263a0f` con la EV.58: **6502 verdi,
11 saltate, 9 rosse**. Le 7 accettate di prima, e 2 nuove mie (padre: ordine
EV voce 58): cinque ragioni scritte in `le_memorie_custodite.dart` con
l'apostrofo al posto dell'accento ("gia'", "identita'", "e'"), prese da
`accenti_veri` e `testo_a_video`. Corrette e rifatte verdi.

La terza suite intera, sul commit `37b00be6` col pezzo 2: **6512 verdi, 11
saltate, 11 rosse**. Le 7 accettate di prima, e 4 nuove (padre: ordine EV voci
EV.08 e EV.10): tre testi dell'Architetto con la virgola prima della "e"
(`language_rule` e `la_lettura_cinese`, adattati e dichiarati, vedi EV.08), la
tabella generata delle lunghezze dei responsi da rigenerare perche' la nota del
metodo e' cambiata (`le_lunghezze_dei_responsi`, rigenerata con
`AGGIORNA_LUNGHEZZE=1`), e la guardia nuova degli inviti che porta la stringa
"DateTime.now" (`una_prova_dichiara_il_suo_istante`, dichiarata con la sua
ragione). Rifatte verdi tutte e quattro. Il processo della suite e' rimasto
appeso dopo l'ultima prova e l'ho chiuso a mano: i conti sono quelli dell'ultima
riga scritta.

## La consegna

**Il server**, 1 ottobre 2026 sera: pubblicate dal commit `b2263a0f` le
funzioni `statoDelCerchio` (il Viaggio della EV.53 e le memorie della EV.58)
e `chiEOnline` (EV.06 ed EV.57), regione europe-west1, "Successful update
operation" per tutte e due. Il server nuovo accetta anche i telefoni vecchi,
che non mandano memorie ne' l'uscita dal conto.

**La prova di accensione cadeva per il cavo, non per l'app.** Due volte la
consegna si e' fermata su "nessun Displayed" con zero righe di log. Misurato:
sul Realme ogni uscita dal telefono oltre una decina di KB fa cadere il
collegamento (8000 byte chiesti, 8054 arrivati; 16000 chiesti, 0 arrivati e
il telefono "offline"), mentre l'installazione, che va nell'altro verso,
passa; il log intero sono 750 KB. Letto filtrato sul telefono, lo stesso
avvio porta "Displayed com.esotericircle.esoteric_circle/.MainActivity:
+1s317ms" e nessun FATAL. `tool/consegna.py` ora filtra il log sul telefono e
ne porta solo le righe che la prova legge, piu' le ultime 25. PROVENIENZA
IGNOTA del guasto del collegamento (il cavo o la porta: nel pomeriggio le
catture da 300 KB passavano).

**La build 2291**, dal commit `a8d35a53` col cancello verde di GitHub
(segno `refs/verde/a8d35a53...`), costruita con `flutter build apk --release
--target-platform android-arm64`, 248.231.356 byte, numero 2291 letto
dall'archivio. Prova di accensione sul Realme passata (processo vivo, primo
fotogramma disegnato, nessun FATAL), installata: `versionCode=2291`,
aggiornata alle 22:21. **Release `3k9n4mjs9m5dg` su App Distribution**,
distribuita a cloud@esotericircle.app, riletta dal server: **inviti accettati
1**. La 2290 non e' mai stata distribuita (solo installata sul Realme).

Un secondo guasto dello stesso cavo, a release gia' distribuita: la consegna
leggeva il numero dal telefono con la scheda intera del pacchetto, troppo
grande per il collegamento, ed e' morta prima di scrivere il registro.
Il registro `docs/versione_distribuita.json` l'ho scritto a mano coi valori
della procedura (numero dall'archivio con aapt2, peso, release, cancello) e
lo dice nel campo del telefono; `tool/consegna.py` ora filtra anche quella
lettura sul telefono e, se il telefono tace, legge il numero dall'archivio.

**La build 2292, col pezzo 2**, dal commit `eec08c93` col cancello verde
(segno `refs/verde/eec08c93...`), 248.231.356 byte, numero 2292 letto
dall'archivio. Prova di accensione sul Realme passata, installata
(`versionCode=2292`). **Release `4jncjpqp18rh8`**, distribuita a
cloud@esotericircle.app, riletta dal server: inviti accettati 1. Le note
passavano dalla riga di comando di Windows e "più" e' arrivato come "pi?":
corrette sul server con una richiesta di modifica della release, rilette giuste.
Questa volta il registro l'ha scritto la consegna da sola. Il server non e'
cambiato dal pezzo 1.

**Codemagic (iPhone)**: si puo' lanciare adesso, sul ramo
`claude/esoteric-circle-master-order-e798aj`, dall'ultimo commit di questo
rapporto, col cancello verde.
