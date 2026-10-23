# Rapporto simulazione Realme, gruppo E: Home, Cerchio sociale, account e piani (ordine GA, voci GA.09 e GA.10)

Telefono Realme RMX3081 (767f596c), build di rilascio 8ba00294 (versionCode 2314), piano **Viandante**, nome "Prova", Gemelli. Il 21 ottobre 2026 dalle 11:00 alle 12:13 (ora vera). **L'orologio del telefono non e' stato spostato**: alle 12:07 telefono e PC avevano la stessa ora, `auto_time = 1`.

Stato lasciato: app aperta sulla Home. Eos 115 all'inizio e 115 alla fine, nessun Eos speso, piano ancora Viandante (non ho mai toccato "Attiva in Demo": ho aperto il foglio "Passa a L'Illuminato" e l'ho chiuso con Indietro), nessuna condivisione, nessun invito, nessun permesso di sistema concesso o negato (notifiche, fotocamera e microfono restano negati come li ho trovati), nessun acquisto, nessuna cancellazione (ho aperto "Cancella i tuoi dati" e ho scelto "Lascia tutto"), nessun cambio di nome o di sigillo. Interruttori che ho mosso e **rimesso come li ho trovati**: Effetti sonori, Musica d'ambiente, Riduci animazioni, Modalita' semplice, Lingua (Italiano), Tutorial all'apertura (Disattivato), le arti preferite della Home (le tre aggiunte tolte). Cose che ho scritto nell'account di collaudo, uso normale: **il Ritratto degli Enigmi compilato fino a venti caratteristiche** (otto erano gia' segnate dalla carta natale, dodici scelte da me a caso) e due risposte della Prova della settimana mai consegnate (le ho perse uscendo).

**chiamate al modello: 0.** Il Viandante aveva gia' esaurito le tre domande del giorno (il gruppo D le aveva usate: la chat dice "Non ti resta nessuna domanda ai Maestri, oggi"), quindi la prova D1 e' stata fatta sulle conversazioni gia' esistenti, vedi sotto.

## Elenco delle voci chiuse con la prova (regola ordine EH)

Questo rapporto non chiude nessuna voce da solo: e' una simulazione. Per il coordinatore:

```
DOMANDA: "Mi vengono segnalati molti bug" (ordine FZ voce 09: la simulazione da persona prima della consegna) e GA.10 "testi sotto soglia"
PROVA: docs/collaudo/GA/simulazioni/E_home_cerchio_account/contrasti_uscita.txt (233 misure) e le catture della stessa cartella
MISURA: funzioni provate 8 su 8, opzioni provate 63 e non provate 42; difetti 35 (nessuno di gravita' 3, 12 di gravita' 2, 23 di gravita' 1); testi sotto soglia 79 su 233, di cui 9 sotto anche sul colore piu' frequente dello sfondo; chiamate al modello 0
```

## Conti

| Voce | Numero |
|---|---|
| Funzioni provate | 8 su 8 |
| Opzioni provate | 63 |
| Opzioni non provate | 42 (motivo in ogni riga: permesso di sistema, invio a terzi, scrittura sul server, nessun amico, piano) |
| Difetti gravita 3 | 0 |
| Difetti gravita 2 | 12 |
| Difetti gravita 1 | 23 |
| Misure di contrasto | 233 (`misura_contrasti.py`, uscita in `contrasti_uscita.txt`) |
| Testi sotto soglia | 79 su 233: 9 sotto anche sul fondo piu' frequente (da curare per primi), 70 sotto solo nel punto piu' chiaro del cielo stellato dietro il testo |

## Le tre risposte del bambino e le prove, funzione per funzione

### 1. Home e domini (`home_01_aperta.png`, `home_02_giu.png`)

Le tre risposte, senza toccare niente:
1. **Che cos'e'?** "E' la schermata iniziale: in alto una striscia di cose del giorno (Alba, Soffio, Tramonto), poi la luna di adesso con una frase, poi tre personaggi e un pulsante per entrare in un luogo." Giusta, ma non so chi sono i tre personaggi: il nome di quello al centro compare solo dentro il pulsante ("Entra nel Dominio di Medora"), ai lati leggo "Divinazione" ed "Energia" che sono nomi di altro.
2. **Che cosa devo fare adesso?** "Toccare il pulsante, oppure uno dei personaggi, oppure scorrere." Non e' detto che le icone con l'orologio (Soffio, Tramonto) siano chiuse fino a una certa ora.
3. **Che cosa otterro'?** "Astrologia, Cartomanzia, Destino" sotto il personaggio lo dice abbastanza. I doni del giorno si capiscono solo toccando il "?" (foglio "Arcano dell'Alba, alle 7:00, guidato da Medora, un arcano maggiore scelto al mattino": chiaro).

| Opzione | Provata | Esito |
|---|---|---|
| Tocco sul volto in alto, apre Account | provata | apre "Il tuo account" |
| Numero accanto al volto ("4") | non provata | non risulta toccabile e non ha etichetta |
| "Online N" apre la tendina degli amici | provata | foglio vuoto con rotella per circa 3 s, poi "I tuoi amici presenti: il tuo Cerchio e' ancora da chiamare. Il Cerchio adesso: 1 nel Cerchio" e il pulsante "Il tuo Cerchio" |
| Moneta apre il Borsellino | provata | foglio con 115 Eos (vedi funzione 8) |
| Tocco sul cielo (luna) apre il Cielo reale | provata | apre "Il cielo di adesso" (gruppo B); l'invito animato dopo 3 s non verificato |
| Carosello: tocco su un Maestro laterale lo porta al centro | provata | Medora al centro, il colore della Home segue il Maestro |
| Carosello: scorrimento col dito | non provata | non ho scorso sul carosello (la prova e' caduta sulla riga delle schede) |
| "Entra nel Dominio di ..." | provata | apre il dominio (Medora, Calìgo, Aura provati anche dalla barra in basso) |
| Icona chat accanto al pulsante | provata | apre la chat del Maestro al centro |
| Le arti preferite: matita, foglio a spunte | provata | foglio "Le arti preferite: scegline fino a 9", sezioni Medora, Aura, Calìgo |
| Le arti preferite: tetto di 9 | provata | aggiunte 3 (arrivata a 9), la decima non si spunta e non compare nessuna spiegazione (H6) |
| Le arti preferite: pressione lunga toglie una scheda | provata | pressione di 1 s sulla scheda "Oroscopo Universale": nessun effetto visibile (H6) |
| Dieci righe di schede, "Vedi tutto" | provata | "Il tuo destino: Vedi tutto" apre una griglia a due colonne di schede In arrivo |
| Scheda attiva, "i" in alto a destra | provata | popover "La videocamera legge i tuoi tratti e li unisce in una costellazione. Tocca per entrare", sopra la scheda accanto (H7) |
| Scheda attiva, tocco entra | non provata | apre funzioni degli altri gruppi |
| Scheda In arrivo (clessidra), tocco | provata | popover "I Nodi Lunari: da dove vieni e dove stai andando. In arrivo, fase 2", non si apre |
| Dominio di Medora, Aura, Calìgo | provata | tutti e tre si aprono, con le arti accese e quelle in grigio |
| Striscia "I tuoi doni del giorno": "?" di Alba | provata | foglio di spiegazione, "Ho capito" chiude |
| Striscia: scorrimento orizzontale (Soffio, Tramonto, Notte) | provata | quattro caselle |
| Striscia: tocco su Alba | provata | apre "Arcano dell'Alba" (Il Mago rovesciato, gia' tirato oggi), Indietro torna alla Home |
| Striscia: tocco su Soffio, Tramonto, Notte | non provata | finestre orarie dei doni, gruppo C |
| Primo approdo (cinque fumetti) | provata | 1, 3, 4, 5 su 5 visti ("Il Cerchio ti accoglie", "Il Cerchio a un click", "I Doni del giorno", "Il Cammino e gli Eos"), "Avanti" funziona, "Disattiva" e "Salta" non toccati |

**Opzioni provate 18, non provate 4** per la funzione 1.

Difetti Home:

| N | Cattura | Descrizione | Gravita' | Cura proposta | Padre |
|---|---|---|---|---|---|
| H1 | home_01_aperta | In alto "4" e "Online 1" senza etichetta: non si capisce che cos'e' il 4 (livello?) e se "1" sono io | 1 | un'etichetta breve o un tocco che spieghi | PROVENIENZA IGNOTA |
| H2 | home_01_aperta | Il nome del Maestro al centro non e' scritto, e "DIVINAZIONE" sbatte contro il bordo della carta di Medora | 1 | scrivere il nome sotto la carta centrale e accorciare la fascia | PROVENIENZA IGNOTA |
| H3 | home_01_aperta | Soffio e Tramonto hanno solo un orologio grigio: non dicono "arriva alle 13:00" | 1 | scrivere l'ora sotto il nome ("13:00") | PROVENIENZA IGNOTA |
| H4 | home_17_cima | Con Aura al centro la Home e' verde e il corsivo "Chi nasce sotto Gemelli cerca quiete" ha 3,86 a 1 e "Entra nel Dominio di Aura" (oro su verde) 3,19 a 1 | 2 | testo piu' chiaro o velo scuro dietro il pulsante e la frase; atteso 4,5 e oltre | PROVENIENZA IGNOTA |
| H5 | home_10_doni_aiuto | "Guidato da Medora" e' blu (44,72,159) su quasi nero: **2,40 a 1** | 2 | usare l'oro o il crema dei testi accanto: atteso circa 9 a 1 | PROVENIENZA IGNOTA |
| H6 | home_06_tetto_9 | Il decimo gusto non si spunta senza dire perche'; la pressione lunga non fa nulla | 1 | una riga "Hai gia' 9 arti: togline una" e verificare la pressione lunga | PROVENIENZA IGNOTA |
| H7 | home_20_scheda_girata_info | Il popover della "i" si apre sopra la scheda vicina e copre il titolo della riga | 1 | aprirlo ancorato alla scheda toccata | PROVENIENZA IGNOTA |
| H8 | (nessuna: prova con uiautomator) | Dalla Home il lettore dello schermo vede solo la barra in alto e la barra in basso: nessuna scheda, nessun Maestro, nessun dono ha un nome | 2 | dare un nome a schede e Maestri (Semantics) | PROVENIENZA IGNOTA |

### 2. Il tuo Cerchio (`cerchio_01_aperto.png`)

Le tre risposte:
1. **Che cos'e'?** "Una pagina con un cerchio vuoto, scritto '0 amici su 3 posti del tuo piano', due pulsanti, e sotto 'I tuoi amici: il tuo Cerchio e' ancora vuoto'." Chiaro.
2. **Che cosa devo fare?** "Toccare il pulsante giallo per chiamare qualcuno." Lo cerco con fatica: il testo sul pulsante e' crema su giallo, quasi illeggibile (C1).
3. **Che cosa otterro'?** "Amici nel Cerchio." "Gli Enigmi del Cerchio" non dice che cosa siano.

| Opzione | Provata | Esito |
|---|---|---|
| Apri il Cerchio da Account | provata | si apre |
| Chiama nel tuo Cerchio | provata | apre la pagina con quattro modi |
| Chiama chi conosci, "Apri la rubrica" | non provata | chiede il permesso dei contatti |
| Manda il tuo invito, "Manda il link" | non provata | crea un link sul server e apre la condivisione, il fondatore ha chiesto di non inviare |
| Siete vicini, "Mostra il mio codice" | provata | rotella a 2 s, a 10 s un QR con un codice di sei lettere e "Vale ancora 4:40" |
| Siete vicini, "Inquadra il suo codice" | non provata | fotocamera negata, aprirebbe la richiesta di sistema |
| Hai il suo sigillo? "Manda l'invito" | non provata | invia un invito |
| Richieste di legame (Accetta, Non ora) | non provata | nessuna richiesta presente |
| Scheda dell'amico, segni (18), cenni, doni, regalo di Eos | non provata | 0 amici |
| Il tuo nome nel Cerchio (da Profilo): nome PROVAFZE, sigillo, "Chi ti vede" (I tuoi amici, Tutto il Cerchio), "Solo chi ha il tuo sigillo", Ritratto, link d'invito (Rinnova, Revoca), persone bloccate "Nessuna" | provata | aperta e scorsa tutta, i controlli non toccati |
| Cambia il nome, Rinnova, Revoca, "Chi ti vede", "Solo chi ha il tuo sigillo" | non provata | scrivono sul server o invalidano il link |
| Limite amici 3 / segni 5 al giorno | provata | la card dice "0 amici su 3 posti" e la matrice dei piani "Amici nel Cerchio 3 / 15 / 50 / 150" e "Segni agli amici 5 / 20 / 40 / 60 al giorno": coerenti |

**Opzioni provate 5, non provate 7.**

| N | Cattura | Descrizione | Gravita' | Cura proposta | Padre |
|---|---|---|---|---|---|
| C1 | cerchio_01_aperto, cerchio_02_chiama, enigmi_02_dopo | **Quattro pulsanti pieni d'oro** ("Chiama nel tuo Cerchio", "Apri la rubrica", "Manda il link", "Compila il Ritratto") portano testo crema (244,241,232) su oro (212,175,55): **1,86 a 1** | 2 | testo scuro sull'oro (come "Avanti" del primo approdo che e' nero su oro): atteso circa 9 a 1 | PROVENIENZA IGNOTA |
| C2 | cerchio_02_chiama, online_01_tendina | Rotella senza una parola: la tendina Online resta vuota circa 3 s, il codice quasi 10 s | 1 | una riga "Un attimo" sotto la rotella | PROVENIENZA IGNOTA |

### 3. Gli Enigmi (`enigmi_02_dopo.png`)

Le tre risposte:
1. **Che cos'e'?** "Una pagina di giochi: Il tuo Ritratto, Chi del Cerchio, La Prova della settimana, Il Pellegrinaggio." Non so che cosa sia un enigma.
2. **Che cosa devo fare?** "Il pulsante giallo dice 'Compila il Ritratto', quindi quello." Gli altri due pulsanti sono grigi e, toccati, **non succede niente** e non dicono perche' (E1).
3. **Che cosa otterro'?** "Entrare negli enigmi." Il Pellegrinaggio dice "1 passi di 15" e "Tu: un passo" ma non dice come si fa un passo (E2).

| Opzione | Provata | Esito |
|---|---|---|
| Aprire Enigmi senza Ritratto | provata | tre sezioni, due pulsanti grigi |
| "Apri Chi del Cerchio" senza Ritratto | provata | nessun effetto, nessun messaggio (E1) |
| "Fai la Prova" senza Ritratto | provata | nessun effetto, nessun messaggio (E1) |
| "Compila il Ritratto" | provata | rotella circa 5 s, poi 8 caratteristiche gia' segnate "Dalla tua carta" e le altre da scegliere; contatore "Ne hai scelte 8 di 20: ne mancano 12" |
| Scegliere fino a venti caratteristiche | provata | scelte 12 in piu'; a venti il testo diventa "Hai scelto le tue venti caratteristiche" e la ventunesima non si spunta senza spiegazione (E4) |
| "Chiudi il Ritratto" | provata | torna agli Enigmi, ora i due pulsanti sono oro |
| Interruttori "Non comparire negli Enigmi", "Il tuo archetipo", "Il tuo animale guida" | non provata | non li ho trovati ne' negli Enigmi ne' nel Ritratto (scorso fino in fondo) |
| "Apri Chi del Cerchio" col Ritratto | provata | "Servono quattro persone del tuo Cerchio col Ritratto compilato: per ora ne trovo 0." Chiaro |
| "Un indizio in piu'" (5 Eos), "Scopri il segno di chi ti ha riconosciuto" (20 Eos) | non provata | nessun enigma aperto |
| "Fai la Prova" col Ritratto: domande 1 e 2, poi Indietro | provata | "Le parole che non arrivano": dieci domande a quattro risposte; uscendo e rientrando le due risposte sono sparite, senza avviso (E3) |
| Prova: domande 3 a 10, consegna, "Presagio", "Lettura a due" | non provata | servono amici e finirebbe scritta sul server |
| Il Pellegrinaggio | provata | solo testo e barra, nessun comando (E2) |

**Opzioni provate 9, non provate 3.**

| N | Cattura | Descrizione | Gravita' | Cura proposta | Padre |
|---|---|---|---|---|---|
| E1 | enigmi_02_dopo, enigmi_06_prova_bloccata | I pulsanti "Apri Chi del Cerchio" e "Fai la Prova" sono grigi, il tocco non fa niente e non c'e' una riga che dica "compila prima il Ritratto"; sopra c'e' scritto anche "Ti restano 3 enigmi oggi" | 2 | al tocco, una riga "Compila prima il tuo Ritratto" con il pulsante che porta li' | PROVENIENZA IGNOTA |
| E2 | enigmi_02_dopo | Il Pellegrinaggio dice "1 passi di 15" (concordanza) e "Tu: un passo", ma non spiega come si fa un passo ne' da dove si guadagna | 2 | una riga "Si fa un passo ogni volta che..." e "1 passo" al singolare | PROVENIENZA IGNOTA |
| E3 | enigmi_13_prova_due_risposte | Uscire dalla Prova con due risposte date le butta senza chiedere | 1 | un avviso "Hai risposto a 2 domande: esci?" o il salvataggio | PROVENIENZA IGNOTA |
| E4 | enigmi_09_ritratto_venti | I cerchietti sembrano scelta unica ma nello stesso gruppo se ne spuntano cinque insieme (anche "Arrivo sempre dieci minuti prima" e "Parto senza avere deciso dove dormo"); a venti non se ne spunta una ventunesima senza dirlo | 1 | quadratini al posto dei cerchietti e una riga al tetto | PROVENIENZA IGNOTA |
| E5 | enigmi_02_dopo | "Ti restano 3 enigmi oggi" appare prima di poter giocare | 1 | mostrarlo solo dopo il Ritratto | PROVENIENZA IGNOTA |

### 4. Account (`account_01.png`, `account_02_giu.png`, `account_03_giu2.png`)

Le tre risposte:
1. **Che cos'e'?** "Una pagina di voci: in alto una nuvola barrata con 'Il tuo cielo non e' ancora custodito, vive solo su questo telefono', poi Registra e conserva, Profilo, Dati di nascita, Il tuo Cerchio, Invita un amico, Chi ti ha invitato, Rivedi il primo approdo, Tutorial, Abbonamento, Diario, Notifiche, Impostazioni, Privacy e dati." "Custodito" non e' una parola che userei (A1).
2. **Che cosa devo fare?** "Se voglio tenere quello che ho fatto, toccare 'Registra e conserva il tuo Cerchio'." La carta lo dice bene ("alla prima registrazione, 250 Eos in dono").
3. **Che cosa otterro'?** "Il mio cielo e i miei Eos su qualsiasi telefono." Chiaro.

| Opzione | Provata | Esito |
|---|---|---|
| Account aperto dal volto | provata | si apre |
| Registra e conserva il tuo Cerchio (Google, Apple, email) | non provata | crea un account |
| Profilo: nome nel Cerchio | provata | vedi funzione 2 |
| Profilo: "Scatta o scegli una foto" | non provata | fotocamera e galleria |
| I tuoi dati di nascita | non provata | gia' coperti dal gruppo D, ho solo visto la riga |
| Il tuo Cerchio | provata | funzione 2 |
| Invita un amico | non provata | crea un link e apre la condivisione |
| Chi ti ha invitato | non provata | scrive un codice sul server |
| Rivedi il primo approdo | provata | cinque fumetti, vedi funzione 1 |
| Tutorial all'apertura | provata | tocco: da "Disattivato" a "Attivo a ogni apertura" e ritorno; **rimesso a "Disattivato"** |
| Abbonamento | provata | funzione 7 |
| Diario Cosmico | provata | si apre sul Cammino e sui Ricordi, vedi D1 |
| Notifiche | provata | funzione 5 |
| Impostazioni | provata | funzione 6 |
| Privacy e dati: Privacy e permessi | provata | schermata con disclaimer, "Cosa contiamo", "Da dove vengono i numeri", "Cosa tocca del telefono" |
| Privacy e dati: Privacy policy | non provata | apre una pagina esterna |
| Privacy e dati: Scarica i tuoi dati | non provata | scarica un file |
| Privacy e dati: Cancella i tuoi dati | provata | dialogo "Ricominciare da zero?", **annullato con "Lascia tutto"** (A3) |
| Privacy e dati: Cancella il tuo account | non provata | irreversibile |
| Esci dal Cerchio, Verifica o cambia l'email, cambia la password | non provata | per l'ospite non ci sono: non trovati |

**Opzioni provate 11, non provate 9.**

| N | Cattura | Descrizione | Gravita' | Cura proposta | Padre |
|---|---|---|---|---|---|
| A1 | account_01 | "Il tuo cielo non e' ancora custodito. Vive solo su questo telefono": parola difficile | 1 | "Il tuo cielo e' solo su questo telefono: registrati per non perderlo" | PROVENIENZA IGNOTA |
| A3 | privacy_05b_cancella_dati_ferma | Nel dialogo "Ricominciare da zero?" (azione senza ritorno) "Lascia tutto" e "Ricomincia" sono viola (90,58,166) su viola scuro (28,19,56): **2,16 a 1**, e identici fra loro: non si distingue cosa annulla e cosa distrugge | 2 | "Lascia tutto" crema, "Ricomincia" oro o rosso, atteso oltre 7 a 1 | PROVENIENZA IGNOTA |

(Le sigle A2 e A4 non sono usate.)

### 5. Notifiche (`notifiche_01_aperta.png`, `notifiche_05_fondo.png`)

Le tre risposte:
1. **Che cos'e'?** "Un elenco di quattro appuntamenti con l'ora (07:00 Arcano dell'Alba, 13:00 Soffio del Destino, 18:30 La Runa del Tramonto, 22:30 Sigillo del Sogno) con un interruttore ciascuno, e un riquadro 'Il telefono non mi lascia ancora avvisarti'."
2. **Che cosa devo fare?** "Toccare il riquadro per dare il permesso, poi scegliere gli appuntamenti." Il riquadro lo dice, e' il solo punto chiaro.
3. **Che cosa otterro'?** "Un avviso all'ora del dono." Le descrizioni sono troncate con i puntini ("Scegli fra i ventidue arcani coperti e gira q...").

| Opzione | Provata | Esito |
|---|---|---|
| Riquadro del permesso | non provata | aprirebbe la richiesta di sistema, regola: nessun permesso nuovo |
| Interruttore Arcano dell'Alba | provata | tocco senza effetto, nessun messaggio (N1); lo stato resta "acceso" ma grigio |
| Interruttori Soffio, Runa, Sigillo | non provata | stesso componente, non toccati |
| Cambia l'ora (tocco su "07:00" e sull'orologio) | provata | nessun selettore dell'ora compare entro 1,5 s (N4) |
| "L'ora d'oro", "Il Rahu Kalam" | non provata | interruttori dello stesso tipo |
| "Le chiamate arrivano?": "Guarda la coda" | provata | "4 chiamate in coda sul telefono" (N3) |
| "Le chiamate arrivano?": "Provala adesso" | non provata | manderebbe un avviso e chiederebbe il permesso |
| Il conto "Un Dono ti chiama" | non provata | non l'ho trovato |

**Opzioni provate 3, non provate 5.**

| N | Cattura | Descrizione | Gravita' | Cura proposta | Padre |
|---|---|---|---|---|---|
| N1 | notifiche_07_dopo_tocco_alba | Gli interruttori sono tutti grigi con il pallino scuro a destra, uguali per acceso e spento, e il tocco non cambia niente e non dice perche' (manca il permesso) | 2 | colore diverso acceso e spento, e al tocco la frase "Concedi prima il permesso" | PROVENIENZA IGNOTA |
| N2 | notifiche_01_aperta | Le descrizioni dei doni sono tagliate con "..." | 1 | lasciare due righe piene o accorciare il testo | PROVENIENZA IGNOTA |
| N3 | notifiche_06_coda | "4 chiamate in coda sul telefono" mentre il permesso e' negato: due frasi che si contraddicono | 1 | dire "4 chiamate pronte, partiranno quando concedi il permesso" | PROVENIENZA IGNOTA |
| N4 | notifiche_01_aperta | Toccare l'ora non apre nessun selettore (da riprovare col permesso concesso) | 1 | se serve il permesso, dirlo | PROVENIENZA IGNOTA |

### 6. Impostazioni (`impost_01_aperta.png`, `impost_03_giu.png`, `impost_04_suono.png`, `impost_07_fondo.png`)

Le tre risposte:
1. **Che cos'e'?** "La pagina delle regolazioni: Il tuo piano, Aspetto, Lingua, Voce e sottotitoli, Suono e vibrazione, Account, Messa a punto."
2. **Che cosa devo fare?** "Spostare gli interruttori che mi servono." Chiaro. Gli interruttori accesi sono oro, spenti viola con pallino oro: si legge bene.
3. **Che cosa otterro'?** Quasi tutto e' spiegato in una riga. Non capisco "Messa a punto" (I1) e "La voce dei Maestri arrivera' presto" (I3).

| Opzione | Provata | Esito |
|---|---|---|
| Il tuo piano ("Piano Viandante, vedi i piani del Cerchio e cosa aprono") | non provata | stessa schermata dei piani della funzione 7 |
| Riduci animazioni | provata | acceso e spento, rimesso spento |
| Modalita' semplice | provata | acceso e spento, rimesso spento |
| Lingua: Italiano, English | provata | il menu mostra le due voci; con English **solo "Il Cerchio" della barra diventa "The Circle"**, il resto resta in italiano (I2); rimesso Italiano |
| Sottotitoli | non provata | non toccato |
| Suono e vibrazione (comando grande) | non provata | non toccato |
| "Suono": Effetti sonori e Musica d'ambiente | provata | spenti e riaccesi; spento l'interruttore, il cursore del volume diventa grigio |
| "Suono": Volume degli effetti (100%) e della musica (60%) | non provata | cursori non mossi |
| Account (Il tuo account) | non provata | stessa pagina di prima |
| Messa a punto, "Sensore vivo" | provata | solo lettura, vedi I1 |
| Privacy e permessi da Impostazioni | non provata | **non c'e' in Impostazioni**, si trova in Account, Privacy e dati (I4) |

**Opzioni provate 5, non provate 6.**

| N | Cattura | Descrizione | Gravita' | Cura proposta | Padre |
|---|---|---|---|---|---|
| I1 | impost_07_fondo | "Messa a punto / Sensore vivo" mostra righe da collaudo ("Mano: 0,0 e 0,0 gradi dal riposo, su 26 a fondo corsa", "Risposta dopo la curva 0,00 e 0,00 su 1,00", "Il cielo si ridipinge a 30 fotogrammi al secondo", "Riposo imparato 0,06 e -0,01") a chiunque | 2 | toglierla dalla vista normale o nasconderla dietro un tocco lungo | PROVENIENZA IGNOTA |
| I2 | impost_12_home_english | La Lingua dice "L'interfaccia e i selettori di sistema" ma con English cambia una sola etichetta | 2 | dire "La traduzione e' in arrivo" oppure togliere il selettore finche' non e' tradotta | ordine DM (l'app e' predisposta al multilingua e non e' tradotta), commit c383e6ae |
| I3 | impost_03_giu | "La voce dei Maestri arrivera' presto" e "Sottotitoli: attivi di default, in attesa della voce" mentre il LIVE a voce esiste dall'Adepto | 1 | allineare il testo allo stato vero | PROVENIENZA IGNOTA |
| I4 | impost_07_fondo | "Privacy e permessi" non e' in Impostazioni: la persona la cerca li | 1 | una riga di collegamento | PROVENIENZA IGNOTA |

### 7. I piani (`piani_01_aperta.png`, `piani_03_viandante_fine.png`, `piani_04_iniziato_fine.png`, `piani_09_matrice_destra.png`, `piani_10_illuminato_mese.png`, `piani_11_dopo_scegli.png`)

Le tre risposte:
1. **Che cos'e'?** "Le carte dei piani: Demo, Viandante (il mio, con 'Piano attuale'), L'Iniziato (Consigliato), L'Adepto, L'Illuminato, con i prezzi, e sotto un confronto."
2. **Che cosa devo fare?** "Scegliere settimana, mese o anno, poi toccare 'Scegli ...'." Chiaro. In fondo "Nella demo i piani sono visibili ma il pagamento non e' integrato".
3. **Che cosa otterro'?** Le liste dicono tutto, ma le carte a prezzo annuale mostrano numeri diversi dal confronto (P1).

**Che cosa dice ogni carta** (piano a ciclo "Anno", quello di partenza):
- **Demo**: "Tutte le funzioni attive, per la presentazione." Nessun pulsante visibile.
- **Viandante** (Piano attuale, "Esplora la soglia"): accesso al Cerchio con i tre Maestri; i quattro Doni del giorno; carta natale occidentale in lettura base; tre domande al giorno a un Maestro, senza memoria; **una stesa di tarocchi al giorno**; Sinastria VIP fino a 3; Sinastria evolutiva una coppia nuova, Oggi fra voi e due capitoli; Oracolo degli Angeli: l'angelo dell'ora, il messaggio del giorno e una consultazione col tuo Angelo Custode; Calendario Lunare il mese in corso e una categoria; **Respiro della Luna: la Luna di quest'ora, il respiro di oggi e la perla del giorno**; oroscopo del giorno; Angel Numbers e Angelo Custode una tantum; Mood Tracker base; con piccolo banner e video reward opzionali.
- **L'Iniziato** (Consigliato, "I Maestri ti conoscono e ti ricordano", 2,99 a settimana, 9,99 al mese, 99,99 all'anno, 8,33 al mese, sconto 17%): tutto di Viandante senza pubblicita'; memoria AI esclusiva e persistente; carta natale completa; oroscopo settimanale; **11 domande al giorno**; **3 stese di tarocchi al giorno, anche la croce a quattro carte**; Sinastria VIP fino a 5; Sinastria evolutiva 2 coppie, cinque capitoli, Intervalli di Keplero; Oracolo 3 consultazioni; Calendario Lunare tutte le categorie, promemoria e il mese dopo; **Respiro della Luna: la collana completa, lo scrigno e gli avvisi**; sintesi comparativa; correlazione mood-transiti; Diario completo; oroscopo completo, cinese, vedico; oroscopo per gli amici fino a tre; 2 gettate di rune e I-Ching e Pendolo a Eos scontati.
- **L'Adepto** ("I Maestri ti parlano, anche con la voce", 4,99, 19,99, 189,99 all'anno, 15,83 al mese, sconto 21%): tutto di Iniziato; LIVE 55 minuti al mese; 14 domande; **3 stese di tarocchi al giorno, da una, tre, quattro o dieci carte**; **la stesa a dieci carte, 1 al giorno**; Sinastria VIP fino a 5; Sinastria evolutiva 5 coppie, Tema Composito; Oracolo 5 consultazioni; Calendario Lunare dodici mesi avanti e "Trova il giorno insieme"; **3 gettate di rune, I-Ching e Pendolo inclusi** (questa riga prende il posto della riga sul Respiro); oroscopo mensile e dell'anno; amici fino a dieci; oracoli secondari, meditazioni e frequenze; transit tracker con alert; Diario con AI; memoria AI profonda.
- **L'Illuminato** ("Sei oltre il velo", 6,99, 29,99, 279,99 all'anno, 23,33 al mese, sconto 22%): tutto di Adepto con i tetti piu' alti; 18 domande; **5 stese di tarocchi al giorno, anche la stesa a dieci carte, 1 al giorno**; LIVE 95 minuti; 25 sinastrie VIP; 15 coppie evolutive; 6 consultazioni; Calendario Lunare dodici mesi, "Trova il giorno insieme" e un mese in piu' con gli Eos; Albero della Vita dinamico; memoria anima; Diario con AI e report PDF; accesso anticipato; Eos bonus mensili al massimo.

**Controlli richiesti:**
- **"Respiriamo insieme" non compare da nessuna parte.** Cercato nel testo della matrice (quattro passate complete a sinistra e a destra, zero ricorrenze), nelle liste di Iniziato (testo letto dal lettore dello schermo), nelle schede di Adepto e Illuminato (lette dalle catture; nel codice `plan_catalog.dart` la parola esiste solo in commenti), nel foglio di conferma "Passa a L'Illuminato", nel Borsellino e nelle schermate di spesa. Il Respiro appare solo in tre righe del Viandante e dell'Iniziato e in tre righe della matrice ("collana completa e scrigno", "avvisi", "tempo sotto il dito su tutto il mese").
- **Stesa contata per stesa e non per carta, 1 / 3 / 3 / 5**: card Viandante "Una stesa di tarocchi al giorno", Iniziato "3 stese ... anche la croce a quattro carte", Adepto "3 stese ... da una, tre, quattro o dieci carte", Illuminato "5 stese ...". La matrice dice "Stese di tarocchi: 1 / 3 / 3 / 5 al giorno". **Giusto.**
- **Stesa a dieci carte solo per Adepto e Illuminato, una al giorno**: matrice "Stesa da 10 carte: No / No / 1 al giorno / 1 al giorno", card Adepto "La stesa a dieci carte, 1 al giorno", card Illuminato "anche la stesa a dieci carte, 1 al giorno", nessuna menzione in Viandante e Iniziato. **Giusto.**

| Opzione | Provata | Esito |
|---|---|---|
| Aprire "I piani del Cerchio" da Account, Abbonamento | provata | si apre in meno di 2 s |
| Carta Demo | non provata | potrebbe attivare qualcosa |
| Carta Viandante | provata | "Piano attuale", nessun pulsante |
| Ciclo Settimana, Mese, Anno su Illuminato | provata | il prezzo e il pulsante cambiano ("Scegli L'Illuminato, 29,99 € al mese") |
| Cicli sulle altre carte | non provata | stesso componente |
| "Scegli L'Illuminato, ..." | provata | foglio "Passa a L'Illuminato: nella demo il pagamento non e' integrato... Puoi comunque provare questo livello in modalita' Demo", pulsanti **Chiudi** e **Attiva in Demo**; **ho premuto Indietro, piano invariato** |
| "Attiva in Demo" | non provata | cambia il piano sul server |
| "Scegli" su Iniziato e Adepto | non provata | stesso foglio |
| Confronto completo (matrice), scorrimento a destra | provata | quattro colonne, circa 49 righe lette per intero |
| "Il tuo piano" da Impostazioni | non provata | stessa schermata |

**Opzioni provate 5, non provate 5.**

| N | Cattura | Descrizione | Gravita' | Cura proposta | Padre |
|---|---|---|---|---|---|
| P1 | piani_04_iniziato_fine, piani_09_matrice_destra | Le card al ciclo Anno dicono 11 domande (Iniziato), 14 (Adepto), 18 (Illuminato) e LIVE 55 e 95 minuti, la matrice sotto dice 12, 17, 21 e 80, 150: il confronto non segue il ciclo | 1 | scrivere nel confronto che i numeri sono "al mese" o mostrare quelli del ciclo scelto | PROVENIENZA IGNOTA |
| P2 | piani_09_matrice_destra | La matrice promette "Il ritorno della carta" (dall'Iniziato) e "Rileggere una stesa" (Illuminato): non ho trovato un comando che li usi (voce gia' segnalata in `le_opzioni.md`) | 1 | togliere la riga o costruire la funzione | PROVENIENZA IGNOTA |

### 8. Borsellino (`borsellino_01.png`, `borsellino_02_giu.png`, `borsellino_03_fondo.png`)

Le tre risposte:
1. **Che cos'e'?** "Un foglio con scritto '115 Eos, il tuo saldo nel Cerchio', la prossima ricarica, tre pacchetti con il prezzo in euro, cosa posso fare oggi, gli ultimi Eos guadagnati."
2. **Che cosa devo fare?** "Niente: leggere. In fondo 'Guarda i piani' e 'Chiudi'." Giusto.
3. **Che cosa otterro'?** "Capisco quanti Eos ho, che i pacchetti 'arrivano con la pubblicazione dell'app' (quindi non si comprano) e che i miei limiti di oggi sono finiti." Chiaro.

Prezzi e voci lette: Manciata di Eos 300 Eos 2,99 €; Borsa di Eos 900 Eos 7,99 €; Scrigno di Eos 2500 Eos 19,99 €; **nessun pulsante di acquisto**. "Cosa puoi fare oggi": domande ai Maestri finite, approfondimenti e confronti fra i Maestri "non nel tuo piano", gettate di rune finite, stese finite, stese a dieci carte non nel piano, "Ti restano 2 sinastrie su 3". "Gli ultimi Eos": +10 Il tuo volto letto, +45 Il Sogno di Saturno retrogrado, +20 Dono del giorno, +10 Premi ritrovati (due volte), +10 Il cielo dell'istante, +20 Dono del giorno. "Con un piano i tetti si allargano... Iniziato 500 Eos, Adepto 1.500 Eos, Illuminato 3.000 Eos" (coincide con la matrice).

| Opzione | Provata | Esito |
|---|---|---|
| Apri il Borsellino dalla moneta | provata | si apre |
| Saldo | provata | 115 Eos |
| "La prossima ricarica" | provata | "Il tuo piano non porta Eos ogni mese: questi li guadagni tu, accendendo i Sigilli del cammino" |
| Pacchetti | provata | elencati, non in vendita, spiegato |
| "Cosa puoi fare oggi" | provata | sette righe |
| "Gli ultimi Eos" | provata | sette righe |
| "Guarda i piani" | non provata | porta alla funzione 7 |
| "Chiudi" | provata | chiude |
| Conferma della spesa sopra 100 Eos | non provata | col saldo di 115 la spesa da 150 Eos del confronto fra Maestri dice "te ne mancano 35" e non arriva alla conferma (foglio visto: "Riscatta un confronto di sinastria · 150 Eos (te ne mancano 35)", "Non ora", "Vedi i piani"; premuto "Non ora") |
| Prezzo del riscatto della stesa (150 o 120) | non provata | la stesa e' finita ma non ho aperto la funzione (gruppo A) |

**Opzioni provate 7, non provate 3.**

| N | Cattura | Descrizione | Gravita' | Cura proposta | Padre |
|---|---|---|---|---|---|
| B1 | borsellino_01 | Nel foglio il saldo ha l'icona di un sole, nella barra in alto la moneta: due immagini per la stessa cosa | 1 | la stessa moneta | PROVENIENZA IGNOTA |
| B2 | borsellino_03_fondo | "Premi ritrovati" compare due volte di fila (+10, +10) senza dire quali | 1 | dire che cosa e' stato ritrovato | `lib/features/sigilli/regia_del_cammino.dart` riga 669 (la voce), ordine PROVENIENZA IGNOTA |
| B3 | borsellino_02_giu | "Cosa puoi fare oggi" dice "Domani torna intero" ma non che cosa costa farlo oggi con gli Eos (80, 60, 150...) | 1 | accanto a ogni limite finito il prezzo in Eos e il pulsante | PROVENIENZA IGNOTA |
| B4 | caligo_05_confronto_foglio | Il foglio del confronto fra Maestri chiama la cosa "confronto di sinastria" (voce gia' vista dal gruppo D) | 1 | "confronto fra i Maestri" | gruppo D, D-confronto |

## La prova D1 (chat dei Maestri), cosa vedo e cosa no

Premessa: **il Viandante aveva 0 domande rimaste** (header della chat: "Non ti resta nessuna domanda ai Maestri, oggi"), perche' il gruppo D le aveva usate alle 10:25. **Non ho mandato nessuna domanda: chiamate al modello 0.** Ho usato le conversazioni di oggi del gruppo D: Aura (due scambi: archetipo e salute) e Calìgo (denaro).

1. **Esco con la freccia e rientro da "Consulta Aura"**: si apre una chat **nuova**, con il benvenuto "Anima del Cerchio, quello che provi ha un posto, qui. Il tuo Sole in Gemelli e il tuo cammino del Costruttore..." e la carta "Parlagli come parleresti a una persona" (`chat_02_aperta_dopo.png`). La conversazione di prima non si vede. **La meta' di D1 che dice "la chat si riapre nuova" e' vera.**
2. **Il menu a tendina**: l'icona in alto a destra, un riquadro con un "+", **sembra "nuova chat" ma apre una tendina** (`chat_03_menu.png`) con: "Nuova chat", poi la conversazione con il titolo ("Il mio archetipo…", "Oggi", e un cestino), poi "Chat precedenti", poi "LIVE con Aura". **Le ultime conversazioni compaiono col loro titolo** (qui una sola, perche' Aura ne ha una sola oggi). Le etichette non sono quelle dell'ordine DZ.03: leggo "Nuova chat" e "Chat precedenti", non "Nuova conversazione" e "I giorni prima" (D1d).
3. **Tocco sulla conversazione**: **la riapre con la domanda e con la risposta** (`chat_09_riaperta_collassata.png`, `chat_10_espansa.png`): le due domande della persona e le due risposte di Aura; **la prima risposta e' ripiegata in una riga con i puntini e una freccia** ("Il tuo archetipo del Giullare t..."), l'ultima e' aperta per intero. Con Calìgo (`caligo_03_riaperta.png`, `caligo_04_fine.png`) lo stesso: riaperta con la sua domanda e la sua risposta, e in fondo "Vai piu' a fondo" e "Chiedi anche agli altri". **Dunque la parte "la risposta non si rilegge" di D1 non e' confermata**: si rilegge, dalla tendina. Quello che manca e' farsi trovare (D1b).
4. **Dal Diario Cosmico**: il ricordo "Ho 8000 euro di risparmi. Le rune mi dicono di investirli tu..." toccato apre "Quel giorno" con **solo la domanda e una riga tecnica "Turno conv.caligo.c1792571121221"**, nessuna risposta e nessun modo di aprire la chat (`diario_07_tocco_ricordo.png`). **Qui D1 e' confermato** (D1c). Non ho provato "Chat precedenti" della tendina (apre il Diario filtrato).

| N | Cattura | Descrizione | Gravita' | Cura proposta | Padre |
|---|---|---|---|---|---|
| D1b | chat_02_aperta_dopo, chat_03_menu | Entrando da "Consulta" la chat e' sempre nuova e nulla dice che la conversazione di prima esiste: si trova solo dall'icona "+" che sembra "nuova chat" | 2 | all'apertura una riga "Riprendi: Il mio archetipo..." sopra il benvenuto, o riaprire l'ultima conversazione | PROVENIENZA IGNOTA (ordine DZ.03 la dichiara nel menu) |
| D1c | diario_07_tocco_ricordo | Il ricordo del Diario apre una pagina con la domanda e un identificativo tecnico, senza risposta e senza collegamento alla chat | 2 | aprire la conversazione e togliere "Turno conv.caligo.c..." | PROVENIENZA IGNOTA |
| D1d | chat_03_menu | Le etichette della tendina non sono quelle dell'ordine | 1 | allineare ordine e app | ordine DZ.03 |
| D1e | chat_09_riaperta_collassata | Le risposte vecchie sono ripiegate su una riga con puntini: sembra che la risposta manchi | 1 | mostrare almeno due righe, la freccia piu' evidente | PROVENIENZA IGNOTA |

## Visibilita' dei testi (GA.10)

Metodo come i gruppi precedenti: rettangolo del testo sulla cattura renderizzata, colore del testo = media del 3 per cento dei pixel piu' lontani dallo sfondo, sfondo = colore piu' frequente e, sulle scene a cielo stellato, **il punto piu' chiaro dello sfondo** (98 percentile). Soglia 4,5 a 1 per il testo da leggere, 3 a 1 per i titoli grandi. Script `misura_contrasti.py`, uscita completa in `contrasti_uscita.txt`: **233 misure, 79 sotto soglia, 9 sotto soglia anche sul fondo piu' frequente**. Le catture di rettangoli di alcune schermate (Primo approdo, Chi del Cerchio) non sono misurate.

**I 9 sotto soglia sul fondo piu' frequente** (da curare per primi):

| Testo | Contrasto frequente | Contrasto peggiore | Soglia | Cattura | Cura che pesa meno sulla grafica |
|---|---|---|---|---|---|
| Guidato da Medora (blu su nero) | 2,40 | 1,90 | 4,5 | home_10_doni_aiuto | colore del testo come "Ho capito", oro |
| Chi nasce sotto Gemelli cerca quiete (corsivo, Home verde) | 3,86 | 2,31 | 4,5 | home_17_cima | velo scuro dietro il corsivo |
| Entra nel Dominio di Aura (pulsante) | 3,19 | 2,29 | 4,5 | home_17_cima | pulsante piu' scuro o testo bianco |
| LASCIA TUTTO (dialogo cancella i dati) | 2,16 | 1,88 | 4,5 | privacy_05b_cancella_dati_ferma | crema invece di viola |
| RICOMINCIA (dialogo cancella i dati) | 2,16 | 1,77 | 4,5 | privacy_05b_cancella_dati_ferma | oro invece di viola |
| CHIAMA NEL TUO CERCHIO (pulsante oro) | 1,86 | 1,52 | 4,5 | cerchio_01_aperto | testo scuro sull'oro |
| APRI LA RUBRICA (pulsante oro) | 1,86 | 1,53 | 4,5 | cerchio_02_chiama | testo scuro sull'oro |
| MANDA IL LINK (pulsante oro) | 1,86 | 1,49 | 4,5 | cerchio_02_chiama | testo scuro sull'oro |
| COMPILA IL RITRATTO (pulsante oro) | 1,86 | 1,55 | 4,5 | enigmi_02_dopo | testo scuro sull'oro |

**Gli altri 70** sono sotto soglia solo nel punto piu' chiaro del cielo (stelle e nebulose dietro il testo); sul fondo frequente tutti passano. Quelli piu' bassi nel punto peggiore: "La giusta ora per chi nasce sotto Gemelli" 3,00 e "GIBBOSA CRESCENTE" 2,84 (home_01_aperta, sul cielo luminoso), "Quanto lontano portare il cammino" 2,99 (impost_01_aperta), "La voce dei Maestri arrivera' presto" 3,02 (impost_03_giu), "Vale ancora 4:40" 2,62 (cerchio_05_codice_dopo10s), "Venti caratteristiche che dicono come sei fatto" 2,95 (enigmi_04_ritratto_dopo), "Il tuo cielo non e' ancora custodito" 4,18, e la serie dei testi corsivi grigio crema (215,210,194) che a 2,3-3,9 nel punto peggiore e' quasi sempre sotto la soglia. **Cura unica proposta per i 70**: un velo scuro leggero (circa il 25 per cento) dietro le colonne di testo corsivo dei fogli su cosmo, e il crema (244,241,232) al posto del (215,210,194) per i testi lunghi: porterebbe i peggiori da circa 3 a circa 4,5.

Una misura non attendibile: "Astrologia, Cartomanzia, Destino" (home_01_aperta) ha il peggiore a 1,73 perche' il rettangolo prende una zona piu' scura del carosello; sul fondo frequente fa 3,76 contro 3,0, quindi passa.

Totali per funzione (misurati / sotto soglia): Home 44 / 15, Impostazioni 30 / 10, Enigmi 29 / 12, Piani 26 / 8, Profilo (dentro Account e Cerchio) 22 / 7, Cerchio 18 / 9, Privacy 17 / 6, Borsellino 14 / 1, Chat (prova D1) 12 / 7, Notifiche 11 / 3, Account 10 / 1.

## Riepilogo dei conti (opzioni, difetti)

Opzioni per funzione, provate / non provate: Home 18 / 4, Cerchio 5 / 7, Enigmi 9 / 3, Account 11 / 9, Notifiche 3 / 5, Impostazioni 5 / 6, Piani 5 / 5, Borsellino 7 / 3. **In tutto 63 provate e 42 non provate.**

Difetti: **gravita' 2: H4, H5, H8, A3, N1, I1, I2, C1, E1, E2, D1b, D1c (12)**; **gravita' 1: H1, H2, H3, H6, H7, A1, N2, N3, N4, I3, I4, C2, E3, E4, E5, P1, P2, B1, B2, B3, B4, D1d, D1e (23)**; gravita' 3: nessuno. Totale 35.

## Catture

64 catture in questa cartella (tolte quelle ripetute). Le catture delle funzioni con piu' schermate (Home, Impostazioni, Piani) superano le otto richieste perche' ciascuna serve a una misura di contrasto; le altre sono sotto otto.
