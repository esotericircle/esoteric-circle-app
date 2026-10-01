# RAPPORTO DELL'ORDINE EV

Ramo `claude/esoteric-circle-master-order-e798aj`, partenza `0f7a0625`.
Il manifesto con le DOMANDA, PROVA e MISURA di ogni voce:
`docs/ordini/ORDINE_EV_MANIFESTO.md`. **Le voci 14: chiuse 5, aperte in attesa
di verifica 9.**

## Le voci chiuse, con la prova

| voce | prova | misura |
| --- | --- | --- |
| EV.01 tutti i prezzi a 99 | `docs/collaudo/EV/realme/ev01_adepto_prezzi_interi.png` (e `ev01_iniziato_prezzi_interi.png`, `ev01_illuminato_prezzi_interi.png`) | prezzi non a ,99 da 5 a 0 su 9; sconti diversi dal calcolo 0 su 3; nomi e prezzi tagliati a 360 punti da 5 e 15 su 18 a 0 |
| EV.04 Medora non nega il responso | `docs/collaudo/EV/medora_e_il_responso.txt` | risposte che negano o ignorano il responso, da 9 su 10 a 0 su 10, in due esecuzioni con persone diverse |
| EV.51 le richieste di "Note di Keep" | `docs/collaudo/EV/note_di_keep.txt` | permessi sugli account nell'archivio 0 su 18 |
| EV.54 i tre Angeli nel Passaporto | `docs/collaudo/EV/realme/ev_angeli_tre_nel_passaporto.png` | carte nella bolla da 1 a 3, nomi da 1 a 3 |
| EV.56 niente catture dello schermo | `docs/collaudo/EV/ev56_catture_bloccate.txt` | catture leggibili dalla build senza catture permesse, da tutte a 0 su 3 (0 byte, finestra SECURE) |

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
| EV.58 le memorie che tornano col tuo account | censimento di 40 prefissi, 12 famiglie nuove che viaggiano col Custode, i Ricordi mandati e ripresi, le arti preferite scelte che vincono; prove rosse e verdi, server provato | la funzione statoDelCerchio pubblicata con le memorie; poi la reinstallazione con l'account del fondatore, dopo che la build nuova ha mandato le memorie almeno una volta |

**Il pezzo 2 dell'ordine non e' arrivato**: le voci dell'Architetto EV.07 ed
EV.08 non ci sono. La voce EU.14 del manifesto EU porta la riga "prosegue
nell'ordine EV, voce EV.08", come l'ordine chiede.

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
A3-A28, piu' due innesti a mano sul server (le memorie lette dal cammino, le
arti preferite del telefono che vincono), rossi e poi rimessi. Due innesti sono stati verdi o rossi per la ragione sbagliata al primo
giro e sono stati rifatti, scritto nello stesso file (A6: la prova non misurava
la data; A17 e A19: la compilazione rotta). Guardia nuova nel registro:
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

## La consegna

(si completa con la consegna)
