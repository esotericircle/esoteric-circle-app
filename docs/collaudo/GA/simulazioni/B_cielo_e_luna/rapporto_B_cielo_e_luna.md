# Rapporto simulazione Realme, gruppo B: Medora, cielo e Luna (ordine GA, voci GA.09, GA.10, riscontro GA.06, GA.13, GA.14)

Telefono Realme RMX3081 (767f596c), build di rilascio 7ed2c7a7, piano **Viandante** (Free), dati di nascita: solo il segno (Gemelli), nessuna ora ne' luogo. Il 21 ottobre 2026 dalle 08:19 alle 09:06 (ora vera) piu' un passaggio a 22:35 di ora spostata per il Sigillo del Sogno. Nome dell'account: "Prova". Eos: 60 all'inizio, 105 alla fine (+45 sono il premio del traguardo "Il Sogno di Saturno retrogrado" dato dal Sigillo del Sogno: uso normale, non toccato altro). Nessun acquisto, nessun invio: i fogli di sistema di Condividi sono stati chiusi con Indietro, i due permessi di sistema chiesti dall'app (microfono al Sigillo del Sogno, e uno al Respiro) sono stati rifiutati con "Non consentire".

**Ora del telefono.** Per aprire il Sigillo del Sogno ("Si apre alle 22:30") ho spostato l'orologio di sistema a 22:35 con `cmd alarm set-time` (non con le impostazioni: `settings put global auto_time` e' rifiutato dal telefono), l'ho rimesso all'ora vera appena finito il Sigillo. Verificato alle 09:06: telefono 09:06:03, PC 09:06:08, `auto_time = 1`. L'ora automatica era rimasta accesa per tutto il tempo.

**chiamate al modello: al massimo 3** (certe: 0; probabili: la lettura Breve dell'Oroscopo "Gemelli, Occidentale, Giorno" con le sue 4 schede, che era gia' pronta quando l'ho aperta la seconda volta, quindi 1 al massimo; la parola di Medora del Respiro e le righe del Sigillo del Sogno sono testi che non so se passino dal modello, conto 1 ciascuna). La Lunga dell'Oroscopo non e' partita: il Viandante vede il foglio "L'oroscopo completo di oggi" da 50 Eos, che ho annullato (nessuna spesa).

## Conti

| Voce | Numero |
|---|---|
| Funzioni provate | 6 su 6 |
| Opzioni provate | 55 |
| Opzioni non provate | 38 (motivi nelle tabelle) |
| Difetti gravita 3 | 0 |
| Difetti gravita 2 | 6 (D1 a D6) |
| Difetti gravita 1 | 11 (D7 a D17) |
| Misure di contrasto | 67 (script `misura_contrasti.py`, uscita completa in `contrasti_uscita.txt`) |
| Testi sotto soglia | 17 su 67 (6 sono quasi al limite, fra 4,3 e 4,6) |

Catture in questa cartella: 36 (alcune funzioni ne hanno piu' di 8 perche' lo script dei contrasti ne misura il rettangolo; le altre, circa 120, sono state scartate dopo averle guardate).

## Riscontro a video delle cure GA.06 (Oroscopo, domande vere)

Provato **solo l'Occidentale, Giorno, Breve**: Vedica e Cinese al Viandante mostrano "Solo il segno" (carta del segno: Kumbha (Acquario) e Cavallo) e il foglio "La lettura cinese del giorno si apre con l'Iniziato"; non c'e' responso da leggere. La prima frase del responso per ciascuna scheda (account senza ora di nascita: la lettura dice di parlare "al tuo segno, non ancora al tuo cielo"). Cattura: `oro_C3.png`, `oro_C4.png`.

| Scheda | Titolo | Prima frase del responso | Dice com'e' il periodo? | Coerente col dominio? |
|---|---|---|---|---|
| Generale (5 su 5) | Parole che sciolgono | "Oggi la giornata e' propizia per chiarire: hai la morbidezza necessaria per riprendere un discorso rimasto a mezz'aria senza riaprire ferite." | Si: dice com'e' la giornata (propizia, morbida) e perche' (Luna in Acquario in trigono al segno). | Si, e' un quadro generale del giorno. |
| Amore (4 su 5) | Un ritorno gentile | "Giornata propizia, in amore, ai ritorni gentili dal passato." | Si | Si: parla solo di relazioni, con il ramo "se sei senza legame / se vivi una relazione". |
| Carriera (4 su 5) | In due si rende di piu' | "Oggi la giornata e' favorevole a lavorare o studiare in coppia, facendo squadra." | Si | Si: lavoro e studio. |
| Fortuna (4 su 5) | Due persone da presentare | "Giornata propizia alla fortuna che nasce facendo da ponte: mettere in contatto due persone che dovrebbero conoscersi fa di te un nome da ricordare." | Si | Si, ma con un taglio inatteso: la fortuna e' "presentare due persone", e il numero 8 e il colore "nero piombo" sono spiegati dal Saturno di Acquario (corretto: giorno personale e signore del segno della Luna). |

Valutazione: le cure GA.06 reggono a video. Ogni scheda apre con una frase che dice com'e' il periodo ("propizia a...") e resta nel suo dominio, ha un "Cosa fare adesso" concreto (messaggio breve, ora di ripasso in due, messaggio a tre) e un "Da dove viene" astrologicamente esatto per i Gemelli (ho controllato le case: Luna in Acquario = nona, Sole in Bilancia = quinta, Marte in Leone = terza, Venere in Scorpione = sesta, Giove in Leone = terza: giuste). Due riserve piccole: (1) la riga in corsivo oro "Ciao Prova, oggi il calendario sembra scritto con la tua calligrafia." e' una frase di riempimento che non dice niente del giorno (gravita 1, D8b sotto); (2) "Fortuna" non parla di fortuna nel senso comune (numero e colore a parte) e un bambino cercherebbe soldi o gioco: il responso e' coerente col tema "relazioni che aprono occasioni" ma non con l'idea piu' ovvia di fortuna. Nessun vincolo dichiarato dal codice viola: nessuna promessa, nessun si/no.

## 1. Oroscopo Universale (F03)

**Il bambino, appena aperto** (`oro_apertura_sequenza.png`, `oro_A2.png`): prima una grande ruota dei dodici segni con Medora sotto che alza le braccia; dopo circa 9 secondi compare la figura dei Gemelli con "Oroscopo del giorno, 21 ottobre 2026", "Oroscopo per: Prova / amico/a", linguette Giorno Settimana Mese Anno, linguette Occidentale Vedica Cinese.
1. Che cos'e'? "L'oroscopo di oggi per il mio segno, i Gemelli." Detto dal titolo. Ok.
2. Che cosa devo fare? "Scegliere cosa leggere e toccare Interroga il cielo." Il pulsante pero' sta **sotto la piega** nel primo schermo (visibile solo mezzo, `oro_A2.png` in fondo): chi non scorre vede solo linguette. Difetto D9.
3. Che cosa otterro'? "Non lo so." Il pulsante dice "Interroga il cielo" ma non che ne esce una lettura di oggi in quattro parti (Generale, Amore, Carriera, Fortuna). Dopo, il titolo della scheda lo dice ("Parole che sciolgono, GENERALE").

**Quanto ci mette ad aprirsi (GA.14, "l'Oroscopo si apre subito"), misurato dal tocco sulla scheda "Oroscopo Universale" nella pagina di Medora:**

| Tempo dal tocco | Che cosa si vede |
|---|---|
| 1 s | la pagina di Medora, ancora ferma (la transizione non e' partita) |
| 1,9 a 3 s | la ruota dei segni, vuota, e Medora che alza il braccio |
| 4 a 6 s | la ruota si accende, il sole scorre, un fulmine d'oro porta la luce al centro |
| 7,5 a 8 s | la luce al centro diventa la figura dei Gemelli |
| 9,6 s | compare il titolo "GEMELLI" e, dissolvendo, le linguette e i pulsanti |
| 11 s | la schermata e' tutta utilizzabile |
| 12 a 14 s | stesso risultato quando facevo venti catture in parallelo, che rallentano il telefono |

Una seconda apertura (`oro_A_aperto.png`) ha dato lo stesso: ruota con i Gemelli a 9 s, schermo completo a 11 s. **L'Oroscopo non si apre subito: servono circa 9 secondi di filmato prima del contenuto, 11 prima di poterlo toccare.** Non ho provato se un tocco salta il filmato (D1). Il fondatore ha il telefono con le animazioni a 0,0 come questo: la misura vale per lui.

| Opzione | Provata | Esito |
|---|---|---|
| Oroscopo per: il tuo nome (chip "Prova") | si | di partenza, Gemelli |
| Oroscopo per: amico/a | si | apre "I tuoi amici" (Offline / Online 0, "Aggiungi un amico"); "Aggiungi un amico" apre il foglio "L'oroscopo per gli amici si apre con l'Iniziato" con Non ora / Vedi i piani: chiuso. Nessun nome inserito, nessun invio |
| Aggiungere, salvare, togliere un amico | non provata | richiede l'Iniziato |
| Periodo Giorno | si | lettura completa |
| Periodo Settimana | si | foglio "L'oroscopo della settimana si apre con l'Iniziato" (giusto) |
| Periodo Mese | si | foglio "L'oroscopo della mese si apre con l'Adepto" (**"della mese": errore di genere**, D7) |
| Periodo Anno | si | si apre, senza lucchetto, "Oroscopo dell'anno, dal tuo compleanno al prossimo"; con la Occidentale chiede l'ora di nascita ("serve l'ora di nascita, aggiungila qui") e non mostra lettura; per Cinese mostra le date "17 febbraio 2026 al 6 febbraio 2027" ma sotto il foglio dell'Iniziato. L'Anno non ha il lucchetto delle altre due (D14) |
| Anno: 300 Eos e PDF dell'anno | non provata | la schermata chiede prima l'ora di nascita; non aggiunto, dato di nascita |
| Tradizione Occidentale | si | lettura del giorno, 4 schede |
| Tradizione Vedica | si | carta "Il tuo segno vedico e' Kumbha (Acquario)" con Condividi +15 Eos e Continua (non toccati), poi "Qui vedi il tuo segno vedico. La lettura del giorno, dalla Luna e dal calendario indiano, si apre con l'Iniziato" e "Scopri il piano" |
| Tradizione Cinese | si | idem, "Il tuo segno cinese e' il Cavallo", foglio "La lettura cinese del giorno si apre con l'Iniziato" |
| Tradizione Maya | si (solo la linguetta) | clessidra e "In arrivo" |
| Tradizione Celtica | si | schermata "Il tuo albero celtico e' la Quercia", badge "In arrivo", riquadro "I Celti leggevano il cielo negli alberi. Il tuo albero ti aspetta, Adepto." e "Torna al tuo oroscopo": nessun vicolo cieco (nota: "Adepto" e' il nome di un piano, in una frase che si rivolge alla persona, D17b) |
| Tradizione Egizia, Araba | non provata | stessa famiglia della Celtica |
| Scheda Generale, Amore, Carriera, Fortuna | si | tutte e quattro lette; Fortuna col numero 8 e il colore nero piombo |
| Profondita' Breve | si | di partenza |
| Profondita' Lunga | si | il menu mostra "Lunga" col lucchetto; il tocco apre il foglio "L'oroscopo completo di oggi: 50 Eos, oppure abbonati da 2,99 euro a settimana" con anteprima sfumata del testo lungo e "Aprilo solo per oggi". Annullato, nessuna spesa |
| "Come nasce questa lettura" | non provata | visibile, non toccata |
| Punto interrogativo sul segno (info della tradizione) | si | foglio "La tradizione Occidentale" con Che cos'e', Un po' di storia, Come si calcola, Fonti; sotto Condividi +15 Eos, Segna nel Diario, Parlane con Medora e "Domani la Luna entra nella tua decima casa solare" |
| Condividi (giorno) | si | foglio di sistema "oroscopo_card.png", chiuso con Indietro, nessun invio |
| Segna nel Diario, Parlane con Medora | non provata | visti, non toccati |
| Interroga il cielo | si | apre la lettura (4 schede) |
| Interroga la Luna (Vedica), Apri l'almanacco (Cinese) | non provata | i due bottoni non compaiono al Viandante (c'e' "Scopri il piano") |
| Cielo con ora e luogo di nascita | non provata | non ho inserito dati di nascita; dal bottone "Completa i dati di nascita" non sono andato avanti |
| Condividi settimana, mese, anno | non provata | tre periodi bloccati |
| Indietro dall'Oroscopo e riapertura | si | riapertura: la lettura era gia' pronta, stesso testo (D16: un Indietro durante il filmato mi ha riportato alla Home) |

**Difetti dell'Oroscopo**
- D1 (gravita 2, cattura `oro_apertura_sequenza.png`): il filmato della ruota dura circa 9 secondi prima del contenuto, la voce GA.14 ("si apre subito") non e' soddisfatta. Proposta: contenuto subito sotto la ruota, filmato come sfondo che sale in 1,5 secondi, oppure saltarlo alla seconda apertura del giorno. Padre: PROVENIENZA IGNOTA.
- D7 (1, `mese_01.png`): "L'oroscopo della mese" e "Leggi anche la mese": mese e' maschile. Proposta: "Il mese" nel titolo e "Leggi anche il mese". Padre: PROVENIENZA IGNOTA.
- D8 (1, `oro_B1.png`): due riquadri dicono la stessa cosa uno sotto l'altro ("Con la tua ora e il tuo luogo di nascita questa lettura parlera' al tuo cielo" e "Questa lettura parla al tuo segno, non ancora al tuo cielo..."). Proposta: tenere il secondo, che ha il bottone, e togliere il primo.
- D8b (1, `oro_C3.png`): la riga in corsivo "Ciao Prova, oggi il calendario sembra scritto con la tua calligrafia." non dice niente del giorno. Proposta: sostituirla con una frase sul periodo o toglierla. Padre: GA.06 (testo della scheda Generale), il riempimento non e' un difetto di dominio ma di contenuto.
- D9 (1, `oro_A2.png`): "Interroga il cielo" sotto la piega alla prima apertura. Proposta: piu' compatta la figura dei Gemelli (oggi occupa meta' schermo) o il pulsante fisso.
- D14 (1): "Anno" senza lucchetto ma si apre solo con l'Adepto (e 300 Eos al Viandante): il bambino lo crede libero. Proposta: lucchetto o "300 Eos" sulla linguetta.

## 2. Cielo reale (F20)

**Il bambino, appena aperto** (`cielo_01_partenza.png`): titolo "Il cielo di adesso", un cielo nero con le linee delle costellazioni, un disco grigio della Luna in alto a destra con "La Luna" e "Sotto l'orizzonte: sorge alle 15:50", "Roma 41.9028, 12.4964", il pulsante "Attiva macchina del tempo", un riquadro "Cielo calcolato su Roma, in attesa della tua posizione" con "USA LA MIA POSIZIONE".
1. Che cos'e'? "Il cielo di adesso, con la Luna." Detto dal titolo. Ok.
2. Che cosa devo fare? "Non so: tocco la bussola? la Luna? la macchina del tempo?" Il testo "Esplori col dito. Tocca la bussola in alto per seguire il telefono" compare solo dopo un tocco o un trascinamento; all'avvio la frase che si legge e' "Venere e' lassu': portala al centro e tocca qui per un nord piu' preciso", parole da esperto. Difetto D5b.
3. Che cosa otterro'? "Vedere dove sono le stelle e la Luna." In parte: "La Luna adesso non c'e': sorge alle 15:50." dice che alle 09:00 non si vede, con una Luna disegnata sopra.

**GA.13, la Luna e il Sole si riconoscono a colpo d'occhio?** Il disco della Luna al campo di partenza e' un disco grigio a crateri con l'ombra della fase, **circa 160 pixel di diametro su 1080 (15 per cento della larghezza), un dodicesimo dell'altezza dello schermo**. Si riconosce subito come una Luna (forma, crateri, fase), ma non e' "grande": e' piu' piccolo del disco del Sigillo del Sogno e molto piu' piccolo del disco del Respiro. Il testo di "Fonti e metodo" (`cielo_11_info`, non salvata: usare `cielo_03_scegli.png` per la schermata accanto) dice che la Luna e' "venti volte piu' grande del vero". **Risposta: si riconosce, ma e' piccola, e la didascalia "La Luna adesso non c'e'" contraddice il disco che si vede.** Il Sole (cattura `cielo_10_sole.png`, scelto dall'indicatore) e' un punto di luce piu' un avviso "Non guardare il Sole direttamente": il Sole non ha un disco riconoscibile, e' un bagliore.

| Opzione | Provata | Esito |
|---|---|---|
| Tocco sul cielo in cima alla home | si | apre il cielo |
| Trascinare col dito | si | il cielo scorre, compare il testo "Esplori col dito. Tocca la bussola in alto per seguire il telefono" |
| Attiva macchina del tempo | si | foglio "Scegli il giorno" con La tua nascita / Adesso e tre ruote Giorno, Mese, Anno |
| Ruote del giorno (28 ottobre 2026) | si | si muovono col dito, "Portami li'" |
| Portami li' | si | animazione "2026, sto andando avanti", poi "Il giorno scelto: 28 ottobre 2026", "La Luna di quel giorno era sotto l'orizzonte, verso nord-ovest" e un riquadro "Cielo su il luogo di nascita, il tuo luogo di nascita" (**"Cielo su il luogo": errore di articolo**, D5c) |
| La tua nascita | non provata | richiede i dati di nascita, l'account non ha ora ne' luogo |
| Usa dove sei ora / Usa il luogo di nascita | non provata | permesso di posizione, non accettato |
| Indicatore: aperto con tocco su "La Luna" | si | foglio "Dove deve puntare l'indicatore?" con Luna e Sole, Pianeti, Costellazioni, Nebulose e galassie |
| Indicatore: Luna e Sole, La Luna | si | scelta col segno di spunta |
| Indicatore: Il Sole | si | l'indicatore passa al Sole con l'avviso "Non guardare il Sole direttamente" |
| Indicatore: Pianeti, Costellazioni, Nebulose e galassie, Il tuo cielo | non provata | non aperte |
| L'eclittica (interruttore) | non provata | visto acceso, non toccato |
| Esplora senza distrazioni (interruttore) | non provata | visto spento, non toccato |
| Pizzico per ingrandire e ridurre | non provata | adb senza permesso sul tocco multiplo (`sendevent` rifiutato); la prova la deve fare una persona |
| Tocco su un pianeta | non provata | di giorno nessun pianeta nel campo di partenza |
| Bussola e giroscopio | non provata | non toccata la bussola, nessun permesso sensori concesso |
| Riallineare ("Portala al centro, poi tocca") | non provata | richiede la bussola |
| Fonti e metodo | si | foglio con HYG, astronomical algorithms, "La Luna e' disegnata circa venti volte piu' grande del vero", chiuso con Fatto |
| Tasto Indietro dal cielo | si | torna alla home |

- D5 (gravita 2, `cielo_01_partenza.png`): disco della Luna di 160 px, 15 per cento della larghezza, e il messaggio "La Luna adesso non c'e'" accanto a un disco: per un bambino sono due messaggi opposti. Proposta: portare il disco a 300 px (circa 28 per cento) e, se la Luna e' sotto l'orizzonte, dirlo col disco in trasparenza e la didascalia "La Luna e' dall'altra parte della Terra: sorge alle 15:50". Padre: PROVENIENZA IGNOTA.
- D5b (1): all'avvio non c'e' nessun testo che dica cosa fare. Il testo di guida compare solo dopo un tocco. Proposta: portare la riga "Esplori col dito. Tocca la bussola in alto per seguire il telefono" in cima all'avvio, al posto di "Venere e' lassu'...".
- D5c (1, `cielo_07_arrivo.png`): "Cielo su il luogo di nascita, il tuo luogo di nascita." Proposta: "Cielo sul luogo di nascita: il tuo luogo di nascita."
- D13 (1, `cielo_01_partenza.png`): la scritta "SATURNO" della sfera celeste sta sotto il titolo "IL CIELO DI ADESSO" e si sovrappone alla prima lettera: si legge un doppione sbiadito.

## 3. Il Respiro della Luna (F08)

**"Respiriamo insieme" non compare in nessuna schermata.** Controllato nella schermata principale (testo letto con l'accessibilita' del telefono: 0 occorrenze, e nelle catture dopo lo scorrimento), nel respiro guidato, nel foglio "Avvisi della Luna", nella Collana delle Lune e nel foglio della citta'. Nessun tasto "Ricuci" ne' "Collana a due".

**Il bambino, appena aperto** (`resp_03_respiro.png`): "Il Respiro della Luna", "Scegli dove guardi la Luna", una grande Luna con "GIBBOSA CRESCENTE", "MERCOLEDI 21/10/26, 74%, 08:34", Medora in meditazione sul mare, due pulsanti in basso "Luna" e "Respiro", e in mezzo "TIENI PREMUTO SULLA LUNA, POI LASCIA / GIRO 1 DI 8".
1. Che cos'e'? "Un posto per respirare con la Luna." Ok.
2. Che cosa devo fare? "Tenere premuto sulla Luna e lasciare." Detto, ma con poco contrasto (D3).
3. Che cosa otterro'? "Non lo so." Il perche' (una perla al giorno, la Collana) sta sotto, scorrendo.

| Opzione | Provata | Esito |
|---|---|---|
| Respiro guidato col dito (tieni premuto) | si | un giro: "Inspira" mentre premo 5,5 s, poi "Espira, giro 2 di 8" |
| Completare gli 8 giri | non provata | circa un minuto, fermato dopo il primo giro |
| Soffiare nel microfono | non provata | permesso non concesso |
| Citta' ("Scegli dove guardi la Luna") | si | foglio "Da quale citta' guardi la Luna?" con campo e tastiera, chiuso senza scrivere |
| Posizione dal GPS | non provata | permesso non concesso |
| Parola di Medora (tre righe) | si | letta: Rudhyar, "Respira sul dettaglio che conta." |
| Dati della Luna (prossima piena e nuova, eta', distanza, Luna in Acquario fino alle 14:35 poi in Pesci) | si | letti |
| Righello del tempo sotto il dito | non provata | non trovato nella schermata (da guardare) |
| Avvisi della Luna (foglio) | si | foglio con due interruttori, "La Luna che sorge" e "Luna piena, nuova e Superluna", entrambi spenti |
| Accendere gli avvisi | non provata | chiederebbe il permesso notifiche |
| Collana delle Lune | si | "Ottobre", "0 di 30 perle accese", "La perla di oggi e' ancora spenta: un minuto di respiro con la Luna la accende", "Alla Luna nuova del 9 novembre Medora ti consegna la collana" |
| Collana: Respira oggi, Condividi +15 Eos, scrigno | non provata | visti, non toccati |
| Link "Trova il giorno giusto nel mese, nel Calendario Lunare" | non provata | visto, non toccato (il calendario l'ho aperto da Medora) |
| Fonti e metodo | non provata | visto, non toccato |
| Senza "Respiriamo insieme" | si | verificato |

- D3 (gravita 2, `resp_03_respiro.png`): "TIENI PREMUTO SULLA LUNA, POI LASCIA" e "GIRO 1 DI 8" corrono sulle colonne di marmo e sul mare: contrasto 2,46 e 3,31 al punto piu' chiaro, 4,5 richiesto. E' l'unica istruzione del rito. Proposta: velo scuro sfumato di un 50 per cento dal 50 al 62 per cento dell'altezza dietro le due righe, o ombra del testo piu' marcata; da 2,46 si arriva a oltre 6. Padre: PROVENIENZA IGNOTA.
- Nota (nessun difetto): al telefono con le animazioni a 0,0 (come questo) il respiro guidato si accorcia di venti volte (regola gia' nota); qui il giro ha seguito la pressione del dito, quindi regge.

## 4. Calendario Lunare Personale (F09)

**Il bambino, appena aperto** (`cal_01.png`): "Calendario Lunare", Medora davanti a una Luna piena su un mese (Ottobre 2026) con le piccole fasi lunari sotto ogni numero, sotto una fila di sei cerchi (uno acceso, cinque col lucchetto) col titolo "Capelli e unghie" e tre pulsanti.
1. Che cos'e'? "Un calendario con le fasi della Luna." Ok.
2. Che cosa devo fare? Il testo "Tocca un giorno per leggerlo. Tocca un emblema per trovare il giorno giusto per cio' che vuoi fare." c'e' ma **in fondo, sotto la piega**: in cima il bambino vede solo il calendario. D18 (gravita 1).
3. Che cosa otterro'? Per il giorno si capisce, per i cerchi no senza leggere la riga.

| Opzione | Provata | Esito |
|---|---|---|
| Mese in corso (ottobre 2026) | si | letto, oggi 21 cerchiato |
| Mese successivo (novembre) | si | foglio "Piu' mesi avanti sono dell'Iniziato" con "Un mese di Calendario Lunare in piu' 60 Eos" e Vedi i piani: chiuso senza spendere |
| Mese precedente (settembre) | non provata | la freccia c'e', non toccata |
| Tocco su un giorno (22 ottobre) | si | foglio "Gibbosa crescente in Pesci", "E' il giorno lunare 13, Luna illuminata all'84 per cento", "La Luna resta in Pesci", "Giorno fiore... elemento aria", "Da dove viene" |
| Trova il giorno: Capelli e unghie, Taglio per farli crescere | si | accende i giorni d'oro (11, 12-18, 19-25) con la riga "I giorni d'oro per taglio per farli crescere sono accesi: toccane uno per sapere perche'" (**"per taglio per farli crescere"**, D10) |
| Trova il giorno: Taglio per rinforzarli, Taglio delle unghie | non provata | visti i pulsanti |
| Trova il giorno: Orto | si | foglio "Orto e' dell'Iniziato" (giusto) |
| Trova il giorno: Piante e giardino, Casa, Cucina e conserve, Vino e cantina, Bellezza (e le altre due categorie) | non provata | gli altri quattro cerchi col lucchetto hanno solo una didascalia "piano superiore" |
| I giorni tuoi, "Aggiungi l'ora di nascita" | si | porta ai dati di nascita; non compilati |
| Trova il giorno insieme | si | foglio "Trova il giorno insieme e' dell'Adepto" con "Una proposta insieme, 50 Eos": chiuso |
| Condividi il mese | si | foglio di sistema, chiuso con Indietro, nessun invio |
| Pulsante Il Respiro | non provata | l'icona accanto al titolo, non toccata |
| Promemoria per un giorno, Affida l'intenzione | non provata | non scesi nel foglio del giorno oltre la prima schermata |

- D4 (gravita 2, `cal_01.png`): le intestazioni "LU MA ME GI VE SA DO" e i numeri dei giorni stanno sul chiarore bianco-azzurro dell'alone di Medora: contrasto 2,27 e, per i numeri, 1,79 e 2,10; "OTTOBRE 2026" in oro misura 3,56 sul titolo grande (ok a 3,0). Proposta: una striscia di velo blu notte al 55 per cento dietro le intestazioni e la riga dei numeri, o numeri bianchi con contorno scuro da 1 pixel; da 2,27 si passa a circa 7.
- D10 (1, `cal_17.png`): "I giorni d'oro per taglio per farli crescere sono accesi". Proposta: "Per il taglio per farli crescere i giorni d'oro sono accesi".
- D18 (1, `cal_01.png`): la riga "Tocca un giorno per leggerlo..." sta in fondo alla pagina. Proposta: portarla sotto il titolo.
- Contrasti al limite (gravita 1): "ritorno della tua Luna e la fase della tua nascita" (4,43) e "AGGIUNGI L'ORA DI NASCITA" (4,38) sul fondo del libro aperto.

## 5. Calendario degli eventi cosmici (F29)

**Il bambino, appena aperto** (`ev_00.png`, `ev_01.png`): titolo "Il cielo che viene", "Le date che il cielo ha gia' deciso, calcolate sul tuo fuso orario", un riquadro "Qui sotto c'e' il cielo di tutti" con un bottone oro "Dai al Cerchio la tua nascita", poi carte: Saturno retrogrado (oggi), Venere retrograda (oggi), Mercurio retrogrado (23 ottobre, fra 2 giorni), Luna piena (24 ottobre), Ultimo quarto (1 novembre), Luna nuova (7 novembre), Mercurio torna diretto e Venere torna diretta (13 novembre).
1. Che cos'e'? "Le date dei fatti del cielo." Ok.
2. Che cosa devo fare? "Leggere; il bottone oro mi porta a dare la nascita." Ok.
3. Che cosa otterro'? "Capire cosa succede nel cielo." Ok, il bottone spiega che con la nascita compaiono appuntamenti personali.

| Opzione | Provata | Esito |
|---|---|---|
| Elenco di tutti gli eventi (scorrimento fino a novembre) | si | letto |
| Dai al Cerchio la tua nascita | non provata | porta ai dati di nascita, non compilati |
| Tocco su una carta evento | non provata | non toccata |
| Indietro | si | torna al Passaporto |

- **D2 (gravita 2, `ev_01.png` e `resp_08_collana.png`): le date della Luna non coincidono fra le schermate.** Eventi: "Luna piena, 24 ottobre, fra 3 giorni" e "Luna nuova, 7 novembre". Respiro: "Prossima Luna piena 4 g 21 h" cioe' il 26 ottobre, e Collana "Alla Luna nuova del 9 novembre". Calendario Lunare: il 24 ottobre e' "gibbosa crescente", la piena e' il 25, 26 e 27. Il codice (`lib/core/sigilli/eventi_del_cielo.dart`, `_sogliaPiena = 0.96`, `_sogliaNuova = 0.04`) scrive la data in cui la Luna entra nella finestra del 96 per cento, che e' due giorni prima della piena vera. Il numero giusto e' quello del Respiro (26 ottobre, 9 novembre). Proposta: la data dell'evento e' quella dell'istante esatto della fase, e la finestra serve solo al traguardo. Padre: PROVENIENZA IGNOTA (la soglia e' dell'epoca dei traguardi del cielo).
- Contrasti al limite (gravita 1): "fra 2 giorni" 3,88 e "OGGI" 4,43 sul fondo delle carte.

## 6. Sigillo del Sogno (F19)

**Il bambino, appena aperto alle 08:46** (`notte_01.png`): dalla casella "Notte" nella striscia dei doni compare una schermata nera con un orologio, **"SI APRE ALLE 22:30"** e "La tua costellazione della notte da condividere, col giorno raccolto in una carta", pulsante "Torna al Cerchio".
1. Che cos'e'? "La costellazione della notte, da condividere." Detto.
2. Che cosa devo fare? "Aspettare le 22:30 e tornare." Detto.
3. Che cosa otterro'? "Una carta con il mio giorno da condividere." Detto. **Il bambino capisce, senza vicolo cieco.**

Dopo le 22:30 (ora spostata a 22:35, vedi sopra): la casella Notte si apre con un permesso di sistema **"Consentire a Esoteric Circle di registrare audio?"** prima di qualunque spiegazione (rifiutato con Non consentire). Il rito parte lo stesso: "Dirada la nebbia" (ripiego col dito), poi "Unisci le stelle. La costellazione di Pesci, il segno in cui si trova la Luna adesso. Stelle unite 5 su 6", "Muovi il telefono per guardarti intorno, oppure trascina col dito. Tocca la stella che pulsa."

| Opzione | Provata | Esito |
|---|---|---|
| Casella Notte prima delle 22:30 | si | "Si apre alle 22:30" |
| Casella Notte dopo le 22:30 | si | si apre il rito |
| Dirada la nebbia: soffio nel microfono | non provata | permesso rifiutato |
| Dirada la nebbia: dito | si | la nebbia si dirada passando il dito |
| Salta la nebbia | non provata | non visto il comando |
| Unire la costellazione (6 stelle di Pesci) | si | 6 su 6 toccando la stella che pulsa |
| Premio del traguardo "Il Sogno di Saturno retrogrado" | si | schermata "Congratulazioni, +45 Eos", con tre pulsanti (Invita, Condividi pubblicamente, Manda a qualcuno), non toccati, e "Continua il cammino" |
| Saluto della notte con la carta | si | "Stamattina la tua parola era Lentezza. Adesso chiude il giro: dove l'hai riconosciuta oggi?" (richiama l'Arcano dell'Alba del mattino), "Lascia sciogliere i confini, la notte non chiede empatia, chiede riposo", "Se guardi indietro...", "Stanotte la Luna torna dov'era alla tua nascita...", "Luna in Pesci, gibbosa crescente" |
| Da dove nasce questo dono (i) | si | foglio che spiega: Luna reale, calcolata sul dispositivo, nessuna posizione necessaria |
| Condividi (+15 Eos) | si | foglio di sistema con "rito_del_sogno_pisces.png", chiuso con Indietro, nessun invio |
| Segna nel Diario, Parlane con Medora | non provata | visti, non toccati |

- D6 (gravita 2, `sogno_07.png`, `sogno_09.png`, `sogno_11.png`, `sogno_08.png`): su fondo stellato i testi scendono sotto soglia nel punto con la stella o il nebuloso piu' chiaro: "La costellazione di Pesci..." 3,77; "Muovi il telefono... " in oro 2,76; "Oggi Medora ti indica dove guarda il cielo" in azzurro 1,64 (3,04 sul fondo comune); "LUNA IN PESCI, GIBBOSA CRESCENTE" 2,57; pulsante "CONDIVIDI +15 EOS" 3,36; nel foglio del traguardo "150 Eos quando il tuo amico entra nel Cerchio" 3,16. Proposta: velo blu notte al 40 per cento sul terzo basso dove stanno i testi, e schiarire l'azzurro del rimando a Medora da (98,151,252) a (170,205,255) (da 3,04 a circa 6 sul fondo, da 1,64 a circa 3,5 al punto peggiore). Padre: PROVENIENZA IGNOTA.
- D11 (1, `notte_01.png`/`sogno_00`): il permesso microfono compare appena aperto il rito, senza una riga che spieghi perche'. Proposta: una riga prima del permesso "Per dirada la nebbia soffiando; puoi usare anche il dito".
- D12 (1, `sogno_08.png`): "Congratulazioni. Il Sogno di Saturno retrogrado: Saturno e' retrogrado: tu eri qui con il Sigillo del Sogno." Il traguardo parla di Saturno, il bambino ha fatto il rito della Luna: nome fuori contesto.
- D16 (1): dopo un Indietro premuto durante il filmato dell'Oroscopo sono finito sulla Home e non sulla pagina di Medora: osservato una volta, non riprodotto.
- D17b (1, `oro_G2_celtica.png`): "Il tuo albero ti aspetta, Adepto." usa il nome di un piano come se fosse un titolo della persona.

## Misura dei contrasti (GA.10)

Script: `misura_contrasti.py` (copia di quello del gruppo A, adattato alla risoluzione piena 1080x2400). Per ogni rettangolo: colore del fondo = il piu' frequente; "peggiore" = punto piu' chiaro (o piu' scuro per testo scuro) del fondo, 98 percentile; il testo e' la media del 3 per cento di pixel piu' lontani dal fondo. Uscita completa: `contrasti_uscita.txt` (67 righe).

Testi sotto soglia (17):

| Testo | Contrasto (fondo comune / punto peggiore) | Soglia | Esito | Cattura |
|---|---|---|---|---|
| Linguetta SETTIMANA con lucchetto | 4,62 / 2,83 | 4,5 | SOTTO (spenta) | `oro_A2.png` |
| "Il tuo segno cinese e' il Cavallo" | 8,74 / 3,95 | 4,5 | SOTTO | `oro_B3_cinese.png` |
| "TIENI PREMUTO SULLA LUNA, POI LASCIA" | 7,75 / 2,46 | 4,5 | SOTTO | `resp_03_respiro.png` |
| "GIRO 1 DI 8" | 9,72 / 3,31 | 4,5 | SOTTO | `resp_03_respiro.png` |
| "LU MA ME GI VE SA DO" | 1,02 / 2,27 | 4,5 | SOTTO | `cal_01.png` |
| Numeri 5-11 sui dischi | 3,92 / 1,79 | 4,5 | SOTTO | `cal_01.png` |
| Numeri 26-31 | 1,05 / 2,10 | 4,5 | SOTTO | `cal_01.png` |
| "ritorno della tua Luna e la fase della tua nascita" | 10,33 / 4,43 | 4,5 | SOTTO (limite) | `cal_01.png` |
| "AGGIUNGI L'ORA DI NASCITA" | 9,77 / 4,38 | 4,5 | SOTTO (limite) | `cal_01.png` |
| "fra 2 giorni" | 9,07 / 3,88 | 4,5 | SOTTO | `ev_01.png` |
| "OGGI" | 10,22 / 4,43 | 4,5 | SOTTO (limite) | `ev_01.png` |
| "La costellazione di Pesci..." | 6,79 / 3,77 | 4,5 | SOTTO | `sogno_07.png` |
| "Muovi il telefono..." | 3,97 / 2,76 | 4,5 | SOTTO | `sogno_07.png` |
| "150 Eos quando il tuo amico entra" | 6,60 / 3,16 | 4,5 | SOTTO | `sogno_08.png` |
| "Oggi Medora ti indica..." (azzurro) | 3,04 / 1,64 | 4,5 | SOTTO | `sogno_09.png` |
| "LUNA IN PESCI, GIBBOSA CRESCENTE" | 6,01 / 2,57 | 4,5 | SOTTO | `sogno_11.png` |
| pulsante "CONDIVIDI +15 EOS" | 5,75 / 3,36 | 4,5 | SOTTO | `sogno_11.png` |

Tutti gli altri 50 testi misurati sono sopra soglia, fra cui i quattro responsi dell'Oroscopo (da 8,98 a 9,54 al peggiore), i titoli, il testo del Calendario del giorno (13,64) e i testi del Respiro scorrendo. Limiti dello strumento: le misure con "fondo comune" bassissimo (1,02, 1,05) sono artefatti di chi sceglie il fondo (il rettangolo e' pieno di nuvole e testo chiaro): il numero che conta e' il "peggiore".

## Le righe dei difetti, in sintesi

| N | Gravita | Cattura | Difetto | Cura proposta |
|---|---|---|---|---|
| D1 | 2 | `oro_apertura_sequenza.png` | l'Oroscopo si apre in ~9 s (11 s per toccarlo) | contenuto subito, filmato come sfondo breve o saltato alla seconda apertura |
| D2 | 2 | `ev_01.png`, `resp_08_collana.png` | date delle Lune discordanti (Eventi 24 ott e 7 nov; Respiro 26 ott e 9 nov) | data = istante della fase, non inizio della finestra al 96 per cento |
| D3 | 2 | `resp_03_respiro.png` | istruzione del Respiro 2,46:1 sulle colonne e sul mare | velo scuro dietro le due righe |
| D4 | 2 | `cal_01.png` | intestazioni e numeri del Calendario 1,79-2,27:1 sul chiarore di Medora | velo blu notte dietro la griglia o numeri con contorno |
| D5 | 2 | `cielo_01_partenza.png` | disco della Luna 160 px (15 per cento della larghezza) e "La Luna adesso non c'e'" accanto al disco | disco a ~300 px e didascalia coerente |
| D6 | 2 | `sogno_07/08/09/11.png` | sei testi del Sigillo sotto soglia (da 1,64 a 3,77) | velo sul terzo basso, azzurro piu' chiaro |
| D7 | 1 | `mese_01.png` | "L'oroscopo della mese" | "del mese" |
| D8 | 1 | `oro_B1.png` | due riquadri uguali | tenere uno |
| D8b | 1 | `oro_C3.png` | "Ciao Prova... calligrafia" non dice niente del giorno | frase sul periodo |
| D9 | 1 | `oro_A2.png` | "Interroga il cielo" sotto la piega | figura piu' piccola o pulsante fisso |
| D10 | 1 | `cal_17.png` | "per taglio per farli crescere" | riscrivere |
| D11 | 1 | `notte_01.png` | permesso microfono senza spiegazione | riga prima del permesso |
| D12 | 1 | `sogno_08.png` | traguardo "Sogno di Saturno retrogrado" dopo il rito della Luna | nome coerente |
| D13 | 1 | `cielo_01_partenza.png` | "SATURNO" sbiadito sotto il titolo | togliere l'etichetta sotto il titolo |
| D14 | 1 | `anno_01` (scartata), `oro_B7b` | Anno senza lucchetto ma da 300 Eos | lucchetto o prezzo |
| D15 | 1 | `oro_B3_cinese.png`, `oro_A2.png` | Cavallo 3,95, Settimana 2,83 | fondo piu' scuro dietro l'etichetta del segno |
| D16 | 1 | non catturato | Indietro dall'Oroscopo porta alla Home | da verificare |
| D17 | 1 | `ev_01.png` | "fra 2 giorni" 3,88 e "OGGI" 4,43 | colore piu' chiaro |
| D17b | 1 | `oro_G2_celtica.png` | "ti aspetta, Adepto" | togliere il nome del piano |
| D18 | 1 | `cal_01.png` | la riga d'uso del Calendario sta in fondo | portarla in alto |
| D5b, D5c | 1 | `cielo_01_partenza.png`, `cielo_07_arrivo.png` | niente guida all'avvio; "Cielo su il luogo" | vedi sopra |

(Nel conto di testa i difetti di gravita 1 sono 11: D7, D8, D9, D10, D11, D12, D13, D14, D16, D17, D18; le righe D8b, D15, D17b, D5b, D5c sono precisazioni dentro quelle funzioni e non sono contate a parte.)
