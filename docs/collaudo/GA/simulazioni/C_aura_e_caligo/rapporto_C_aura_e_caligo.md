# Rapporto simulazione Realme, gruppo C: Aura e Calìgo (ordine GA, voci GA.09, GA.10, riscontro GA.06 Rune, GA.11 Viaggio)

Telefono Realme RMX3081 (767f596c), build di rilascio 8ba00294 (0.1.0), piano **Viandante**, nome "Prova", segno Gemelli, nessuna ora ne luogo di nascita. Il 21 ottobre 2026 dalle 09:10 alle 10:06 (ora vera) piu due passaggi con l'orologio spostato (13:05 per il Soffio, 18:35 e 17:30 per il Tramonto) con `cmd alarm set-time`. **Orologio rimesso a posto**: alle 09:53 telefono 09:53:07, PC 09:53:07, `auto_time = 1`.

Stato del telefono lasciato: app aperta sull'hub di Calìgo. Eos 105 all'inizio, 115 alla fine (+10 e livello da 3 a 4 sono il premio "Il tuo volto letto" della Mappa del Viso, uso normale). Nessun acquisto, nessuna condivisione inviata (i fogli di sistema di Condividi sono stati chiusi con Indietro), nessun Eos speso (il foglio "Riscatta una gettata di rune, 60 Eos" e il foglio "La risposta lunga e dell'Iniziato" sono stati chiusi con "Non ora"). Permessi di sistema: la **fotocamera** e le **notifiche** (chieste dall'app dopo "Traccia il sigillo") sono state rifiutate con "Non consentire"; il microfono era gia rifiutato in modo fisso prima di cominciare. Il permesso della fotocamera ora risulta "scelto dall'utente: negato" (prima non era mai stato scelto). Non ho toccato "Apri le impostazioni" ne "Attiva la posizione". Stato che ho cambiato io nell'account di collaudo (uso normale): un sigillo tracciato ("Voglio trovare il coraggio di parlare franco con un amico", Via Bianca, data 21 novembre 2026) e poi portato alla data col comando Demo e **lasciato andare**; una lettura della Mappa del Viso (a mano); una gettata di rune usata; una discesa e un segno del Viaggio.

**chiamate al modello: al massimo 11** (certe 5: la gettata di rune, la riscrittura del Sigillo, il responso del Sigillo, la scena della discesa del Viaggio con la sua risposta, il segno del Gufo; probabili 6 in piu per le righe del Soffio, del Tramonto, della Mappa del Viso, della discesa e della risalita che non so se passino dal modello). Nessuna Lunga (bloccata al Viandante), nessun LIVE.

## Conti

| Voce | Numero |
|---|---|
| Funzioni provate | 7 su 7 (il Viaggio solo con il Gufo, l'animale gia riconosciuto dell'account; vedi la sezione 5) |
| Opzioni provate | 60 (righe delle tabelle, alcune raggruppano piu valori) |
| Opzioni non provate | 38 (motivi nelle tabelle: piano, budget, permesso di sistema, dati, impossibile in un giorno) |
| Difetti gravita 3 | 0 |
| Difetti gravita 2 | 6 (D1 a D6) |
| Difetti gravita 1 | 11 (D7 a D17) |
| Misure di contrasto | 109 (script `misura_contrasti.py`, uscita in `contrasti_uscita.txt`, tabella in fondo) |
| Testi sotto soglia | 57 su 109 (12 sotto anche sul colore piu frequente dello sfondo, 45 sotto solo nel punto piu chiaro) |

Catture in questa cartella: circa 80 (alcune funzioni superano le 8 perche lo script dei contrasti ne misura il rettangolo; le altre sono state scartate dopo averle guardate).

## Difetti, in ordine di gravita

| N. | Cattura | Gravita | Descrizione | Cura proposta (peso minimo sulla grafica) | Padre |
|---|---|---|---|---|---|
| D1 | `viso_04_negato.png` | 2 | **Mappa del Viso, permesso della fotocamera negato**: lo schermo mostra l'ovale vuoto con "Centra il viso nell'ovale, sguardo dritto" come se la fotocamera fosse accesa, il pulsante "Cattura la costellazione" e grigio (1,20 a 1) e nessuna parola dice che la fotocamera non e consentita; l'unica uscita (il ripiego tattile, che c'e e funziona: "Scegli a mano") e il piccolo link in fondo "Preferisci scegliere a mano? Tocca qui". Una persona tocca il pulsante grigio, non succede niente, e si ferma. | Dopo il rifiuto, cambiare il titolo in "La fotocamera non e consentita: scegli a mano" e rendere "Scegli a mano" un pulsante pieno al posto di "Cattura" (nessun pannello nuovo). | PROVENIENZA IGNOTA (non risalita sul codice) |
| D2 | `med_18_inizio_2min.png`, `med_21_fine_a.png`, `med_01_aperta.png` | 2 | **Meditazione, il testo di guida sul fiore non si legge**: "PREMI PLAY" 1,71 a 1, "INSPIRA 4" 2,10, "IL RESPIRO E COMPIUTO" 1,58, "TRATTIENI 2" 1,70: testo chiaro sul fiore giallo chiaro. La guida del respiro e il contenuto della funzione. | Testo scuro (il marrone dell'intestazione) con un sottile alone chiaro, oppure una pastiglia scura al 55 per cento dietro la riga: atteso da circa 1,7 a oltre 7. | PROVENIENZA IGNOTA |
| D3 | `rune_07_risposta.png`, `rune_09_azione.png` | 2 | **Rune, domanda di denaro a trabocchetto**: il riquadro in alto fa la cosa giusta (non consiglia, rimanda al consulente), ma i tre blocchi "Cosa fare adesso" per pietra dicono altro e due non c'entrano con la domanda: Tiwaz "pensa all'ultima volta che hai difeso un amico... Fallo entro sette giorni", Ehwaz "siediti con l'altra persona, chiedi a che velocita vorrebbe andare" (nella domanda non c'e nessun'altra persona). Dicono di agire quando la sintesi dice di non decidere. | Quando il tema e denaro, salute o doppia, far riscrivere (o sopprimere) i "Cosa fare" per pietra e tenere solo quello della sintesi. | Probabile: ordine GA voce 06 (le cure delle Rune coprono la sintesi ma non i Cosa fare per pietra) o ordine ER voce 01 (la lettura pietra per pietra); non verificato sul codice |
| D4 | `sigillo_10_altra_data.png` | 2 | **Sigillo, selettore "Un'altra data"**: il titolo e troncato ("Il giorno in cui Calìgo ti chie...") e ANNULLA / OK sono viola scuro su grigio scuro, 1,59 a 1: quasi invisibili. | Colore delle azioni del selettore chiaro (l'oro morbido del tema) e titolo corto ("La data del Sigillo"). | PROVENIENZA IGNOTA |
| D5 | `viaggio_gufo_prima.png`, `viaggio_04_domanda_segno.png`, `viaggio_gufo_dopo.png` | 2 | **Viaggio, testi sopra il video**: "Il Gufo non parla: risponde con un gesto" 2,85, titolo dello schermo 2,99, "TORNA" 3,30, riga del segno "Il Gufo si volta..." 3,90 nel punto piu chiaro del bosco. | Velo scuro sfumato (20-30 per cento) dal basso, dietro le righe sul video, o contorno scuro sottile. | PROVENIENZA IGNOTA |
| D6 | `aura_01.png`, `aura_02.png` | 2 | **Hub di Aura**: "Le arti degli altri Maestri, oltre il tuo dominio" 1,93 e "ENERGIA" 2,72 scritti sopra il ritratto di Aura (volto e veste chiari). | Velo scuro dietro le righe di sezione, o testo con ombra. | PROVENIENZA IGNOTA |
| D7 | `med_01_aperta.png` | 1 | Meditazione: la prima frase usa "Manipura" e "528 hertz" senza spiegarli e non dice quanto dura la sessione ne che cosa si prova. | Una riga: "Cinque minuti di respiro con un suono, per calmarti" prima della frase del fuoco. | PROVENIENZA IGNOTA |
| D8 | `rune_07_risposta.png` | 1 | Rune: il titolo della sintesi "Un nuovo giorno: cambia stato con lui" dice "lui" senza che nessuno sia nominato, sopra una frase che parla di consulente e risparmi. | Titolo coerente con il tema (qui: "Prima di muovere denaro, fermati"). | Come D3 |
| D9 | `rune_02_norne_domanda.png`, `soffio_09_respiro.png` | 1 | "Oggi hai 1 gettata di rune" 2,28 a 1; "Primo giorno" (Soffio) 2,71 a 1. | Colore piu chiaro dell'etichetta. | PROVENIENZA IGNOTA |
| D10 | `soffio_05_attesa.png` | 1 | Soffio, microfono gia rifiutato: un riquadro lungo "Il permesso resta chiuso" occupa la zona sotto il soffione e il gesto da fare (col dito) sta solo nell'ultima frase. | Prima riga del riquadro: "Spazza i semi col dito". | PROVENIENZA IGNOTA |
| D11 | `soffio_01_chiuso.png`, `tramonto_02_aperto.png` (la cattura delle 17:30 e stata scartata: 139150 byte, schermo chiuso identico a quello delle 09:44) | 1 | Tramonto: a 17:30 la casella dice ancora "Si apre alle 18:30" mentre la schermata aperta dice "Ora stimata delle 17:05": due orari diversi per lo stesso tramonto. | Un solo orario (quello stimato) anche sulla schermata chiusa. | PROVENIENZA IGNOTA |
| D12 | `viaggio_01_aperto.png` | 1 | Viaggio: i comandi "Tetto del modello alzato (Demo)" e "Ricomincia il viaggio (Demo)" sono sulla schermata normale (voluto con AppFlags.isDemo); da togliere per lo store. Non ho toccato "Ricomincia" (azzera il Diario). | Nasconderli fuori dalla build di store. | Voluto, ordine DL voce 14 e DG voce 08 |
| D13 | `viaggio_01_aperto.png` | 1 | Viaggio, schermata di apertura per chi ha gia il Gufo: "Si allontana se lo lasci solo. Il tamburo lo richiama." suona come una minaccia e non dice cosa si ottiene scendendo. | Riga: "Scendi con una domanda: il Gufo ti risponde con un gesto". | PROVENIENZA IGNOTA |
| D14 | `viso_04_negato.png`, `sigillo_01_aperto.png` | 1 | Pulsanti spenti: "Cattura la costellazione" 1,20 a 1 e "Scrivi la tua intenzione" (prima di scegliere la via) 1,39 a 1; il secondo non dice che manca la via. | Etichetta spenta piu chiara e una riga "Scegli prima una via". | PROVENIENZA IGNOTA |
| D15 | `med_07_scroll_in_play.png` | 1 | Meditazione: scorrendo durante la sessione il fiore con la guida ("INSPIRA 3") esce dallo schermo e la persona perde il ritmo. | Fiore fisso in alto mentre la sessione e in corso. | PROVENIENZA IGNOTA |
| D16 | `soffio_03_spazzato.png` | 1 | Soffio: con `input swipe` rapidi (200 a 500 ms) i semi non si sono rilasciati; si sono rilasciati con un trascinamento lungo (3 s, tutta la larghezza) e con una spazzata a piu punti. Il tocco prolungato sintetico (DOWN, 2 s, UP) non ha chiuso. Puo essere il limite dello strumento: da verificare con un dito vero. | Nessuna, solo da verificare. | Da verificare |
| D17 | `viso_01_aperta.png`, `viso_02_giu.png` | 1 | Mappa del Viso: il pulsante "Inquadra il tuo volto" sta sotto la piega, dopo due schermate di testo e il riquadro "togli cappello e occhiali". | Il pulsante subito sotto il titolo, il riquadro dopo. | PROVENIENZA IGNOTA |

## 1. Meditazione (F10)

**Il bambino, appena aperta** (`med_01_aperta.png`): titolo "Meditazione", un grande fiore giallo con scritto piccolo "PREMI PLAY", un tondo verde con la freccia e "Con le cuffie l'ascolto si fa piu pieno", poi "Oggi e acceso il fuoco (Manipura) e apre su cio che decidi: la tradizione gli accosta i 528 hertz. E la frequenza di questa sessione.", il pulsante verde "SCEGLI IL SINTOMO" e il menu "FREQUENZA: 528 Hz".
1. Che cos'e? "Un esercizio con un fiore e dei suoni, per calmarsi." Detto solo dal titolo e dal fiore: "Manipura", "hertz" e "frequenza" non li capisce (D7).
2. Che cosa devo fare? "Premere il tondo verde". La scritta "PREMI PLAY" sul fiore c'e ma non si legge (1,71 a 1, D2).
3. Che cosa otterro? "Non lo so": non c'e scritto quanto dura (cinque minuti) ne che cosa si prova.

| Opzione | Provata | Esito |
|---|---|---|
| "Scegli il sintomo" (apre la libreria) | si | 12 pratiche in scheda, ognuna con tempo (2 a 10 minuti) e frequenza; aiuto "12 pratiche, tutte pronte. Toccane una per sceglierla. Poi comincia col play." |
| Un sintomo scelto: Agitazione improvvisa (2 minuti) | si | la riga sotto il fiore diventa "Agitazione improvvisa: Dodici respiri, 2 minuti." |
| Gli altri 11 sintomi | non provata | non scelti (visti nell'elenco: Mancanza di slancio, Tensione prima di un passo ecc.) |
| Frequenza 528 Hz (di partenza) | si | la sessione e partita a 528 |
| Frequenza 432 Hz | si | selezionata dal menu, l'etichetta cambia |
| Frequenza Battito theta | si | selezionata dal menu, l'etichetta cambia |
| Le altre 6 frequenze | non provata | non scelte |
| Play e pausa | si | "INSPIRA 4 / TRATTIENI / MANCANO 1:57"; la pausa ferma il conto |
| Scorrere durante la sessione | si | il fiore esce dallo schermo (D15) |
| "Pratica piu corta" | non provata | nessun controllo con questo nome sulla schermata (cercato nel codice: non c'e) |
| Fine della sessione | si | sul fiore "IL RESPIRO E COMPIUTO", sotto "La meditazione e portata a compimento: porta questa calma con te." e la card del respiro |
| "Condividi il tuo respiro" | si | si apre il foglio di sistema, chiuso con Indietro, nessun invio |
| "Aura ricorda" | non provata | la riga non e comparsa dopo la prima sessione |
| "Fonti e metodo" (la "i") | si | foglio verde con le fonti (Guido d'Arezzo, Dove 1839); chiuso con "Fatto" |
| Uscire con Indietro a sessione in corso e rientrare | si | nessuna riproduzione attiva del pacchetto nel dump audio, la schermata riparte da capo |
| Chiudere e riaprire l'app e tornare qui | non provata | fatto sulla Mappa del Viso, non su questa funzione |

## 2. Mappa del Viso (F11)

**Il bambino, appena aperta** (`viso_01_aperta.png`): una costellazione dorata su un volto, "I TRATTI DEL TUO VOLTO, UNA COSTELLAZIONE", "La fotocamera legge la geometria del tuo viso e la unisce in una costellazione...", poi un riquadro "Prima di cominciare togli cappello e occhiali..."; il pulsante sta piu sotto.
1. Che cos'e? "Una lettura del mio viso con la fotocamera che fa una costellazione." Chiaro dal titolo.
2. Che cosa devo fare? "Non lo so subito": il pulsante "Inquadra il tuo volto" e sotto la piega (D17).
3. Che cosa otterro? "La costellazione e la lettura dei miei tratti." Detto.

**Senza permesso della fotocamera** (la richiesta di sistema: "Consentire all'app Esoteric Circle di scattare foto e registrare video?", rifiutata con "Non consentire"): la schermata passa a "Centra il viso nell'ovale, sguardo dritto" con ovale vuoto e quattro barre; "Cattura la costellazione" resta grigio e non risponde al tocco; non c'e un messaggio sul perche (D1). **Il ripiego a gesto tattile c'e e funziona**: "Preferisci scegliere a mano? Tocca qui" porta a "Scegli a mano" con cinque gruppi di tratti (forma del volto, grandezza degli occhi, sopracciglia, labbra, mento), poi "Vedi la tua costellazione" (si accende dopo la scelta), poi la schermata "CONGRATULAZIONI, IL TUO VOLTO LETTO" (+10 Eos) e "Continua il cammino".

| Opzione | Provata | Esito |
|---|---|---|
| "Inquadra il tuo volto" (fotocamera) | si, fino al permesso | richiesta di sistema, rifiutata; la cattura vera con la fotocamera non e provata |
| "Cattura la costellazione" | non provata | resta grigio senza permesso |
| "Scegli a mano" (ripiego tattile) | si | funziona, vedi sopra |
| Cinque gruppi di tratti, uno scelto per gruppo (tondo, occhi grandi, sopracciglia dritte, labbra piene, mento ampio) | si | la lettura "Il cuore aperto alle emozioni" arriva dai cinque tratti, con "La tua sintesi", "Elemento Acqua" e "I tratti del tuo volto" |
| "Lega ai transiti" | si | l'interruttore si accende e aggiunge "Oggi il Sole e la Luna mettono in luce il tratto che piu ti segna" con la riga sulla sincronicita |
| "Le tue letture passate" | si | una lettura (21 ottobre 2026, 09:18, Occhi grandi); "Le fotografie restano su questo telefono e non vengono inviate da nessuna parte" |
| "Cancella tutte le letture" | non provata | cancella dati |
| "Leggi un altro volto" | non provata | richiede la fotocamera o un secondo giro a mano |
| "Rifai la lettura piena" | non provata | richiederebbe di nuovo il permesso della fotocamera |
| "Fonti e metodo" | non provata | visto, non toccato |
| Condividi (invito, pubblico, manda a qualcuno) | non provata | sono invii |
| Chiudere e riaprire l'app | si | l'app riparte da "Tocca per entrare" (`riapri_01_tocca_per_entrare.png`); riaperta la Mappa, la lettura di prima e ancora li (`viso_18_passate.png`) |

## 3. Soffio del Destino (F17)

**Prima delle 13:00** (`soffio_01_chiuso.png`): "SI APRE ALLE 13:00. Il tuo destino del momento, con la tensione sciolta che resta nel corpo." e "Torna al Cerchio". (1) Che cos'e? "Una cosa che si apre all'una e mi da il mio destino del momento." (2) Che cosa devo fare? "Aspettare le 13:00": detto; "Torna al Cerchio" e l'uscita. (3) Che cosa otterro? "Il mio destino del momento": vago ma detto. Contrasti ottimi (13,6).
**Aperto alle 13:05** (ora spostata, `soffio_05_attesa.png`): un soffione luminoso, e sotto il riquadro "Il permesso resta chiuso... Il soffio si compie col dito, spazzando i semi o tenendo premuto" con "Apri le impostazioni". (1) "Un soffione che si disperde." (2) "Spazzare i semi col dito": detto solo nell'ultima frase del riquadro (D10). (3) "Non lo so" finche non si compie.

| Opzione | Provata | Esito |
|---|---|---|
| Casella chiusa prima dell'ora | si | "Si apre alle 13:00", pagina nera con l'orologio |
| Apertura dopo l'ora (13:05, orologio spostato) | si | si apre |
| Microfono (permesso gia rifiutato in modo fisso) | si | riquadro "Il permesso resta chiuso", il soffio col microfono non e provabile |
| "Apri le impostazioni" | non provata | impostazione di sistema |
| Spazzare col dito (ripiego tattile) | si | rilascia i semi con un trascinamento lungo; con swipe rapidi no (D16) |
| Tenere premuto (ripiego tattile) | si | il tocco prolungato sintetico non ha chiuso (D16), da verificare con il dito |
| Respiro guidato "PREPARATI A RESPIRARE, tocca per cominciare" e sei giri | si | "INSPIRA, giro 1 di 6" fino a "IL RESPIRO E COMPIUTO"; il gesto gira a velocita piena anche con le animazioni del telefono a 0,0 |
| Il dono dopo il respiro: parola, "Oggi Aura ti accompagna nel respiro", "Primo giorno" | si | testo letto (`soffio_07_dopo_spazzata_lenta.png`) |
| "Da dove nasce" | si | si apre, spiega il rito (`soffio_12_da_dove.png`) |
| Condividi, Segna nel Diario, Parlane con Aura | non provata | invii e salti ad altre funzioni |

## 4. Estrazione Rune (F13)

**Il bambino, appena aperta** (`rune_01_aperta.png`): "Sono Calìgo, custode delle soglie. Le rune non comandano il tuo domani, lo rischiarano: gettale con una domanda nel cuore e ascolta il segno.", una pietra, quattro scelte (Runa di Odino una runa, Le tre Norne tre rune, La Croce delle Cinque cinque rune, Il getto sul telo sorte libera), sotto "La tua domanda" e "Getta le rune".
1. Che cos'e? "Una gettata di pietre con un segno da leggere." Chiaro.
2. Che cosa devo fare? "Pensare una domanda, sceglierne una o scriverla, e premere Getta le rune." Detto ("con una domanda nel cuore", "Oppure scrivila con le tue parole").
3. Che cosa otterro? "Un segno": "ascolta il segno". "Norne", "Croce delle Cinque" sono nomi che non conosce, ma i sottotitoli ("tre rune") aiutano.

| Opzione | Provata | Esito |
|---|---|---|
| Gettata "Le tre Norne" (tre rune) | si | gettata fatta con la domanda a trabocchetto |
| Gettata "Runa di Odino" | non provata | toccata a gettata finita, la gettata del giorno non c'e piu |
| "La Croce delle Cinque" | non provata | come sopra |
| "Il getto sul telo" | non provata | come sopra |
| Tendina "Scegli una domanda" | si | "Domande frequenti" (sette) e "Domande personali" ("La parola di stamattina: dove la ritrovo?") |
| Domanda scritta a mano | si | arrivata bene nel campo dopo aver tolto un "%3F" lasciato dal comando `input text` (artefatto dello strumento, non dell'app) |
| Gettare senza domanda | non provata | una sola gettata al giorno al Viandante, usata |
| "Getta le rune" (gesto, scuoti o tocca) | si | "Scuoti il telefono, oppure tocca: il ripiego vale sempre" (`rune_02_norne_domanda.png`); ho toccato |
| Risposta Breve (di partenza) | si | letta intera |
| Risposta lunga (galdr della runa che decide) | non provata | "La risposta lunga delle rune e dell'Iniziato", foglio chiuso con "Non ora" |
| "Getta ancora" | non provata | foglio "Le gettate di oggi sono finite... Riscatta una gettata di rune, 60 Eos": annullato |
| Il sigillo del giorno (bindrune), "Da dove viene", Condividi, Segna nel Diario | si (visti) / non provata (invii) | la bindrune e la fonte (poemi runici) si leggono; Condividi e Diario non toccati |
| Chiudere e riaprire | si | l'app riparte dalla soglia; la gettata di oggi resta fatta ("Non ti resta nessuna gettata di rune, oggi") |

### Riscontro a video delle cure GA.06 (Rune)

Una sola gettata disponibile al piano Viandante (1 al giorno): **una sola domanda a trabocchetto provata, una seconda non e possibile** senza pagare 60 Eos. Domanda scritta: "Devo lasciare il lavoro sicuro e investire tutti i miei risparmi in una attivita mia o conviene restare?" (denaro). Gettata "Le tre Norne": Tiwaz (Urdhr, rovesciata), Ehwaz in ombra (Verdhandi), Dagaz (Skuld).

| | Esito |
|---|---|
| Prima frase del responso | "Le rune non danno consigli su risparmi, acquisti o investimenti: per questa scelta serve un consulente che conosca i tuoi numeri." |
| Titolo della sintesi | "Un nuovo giorno: cambia stato con lui." (D8) |
| Sintesi, "Cosa fare" | "Prima di muovere denaro fissa un incontro con un consulente finanziario e chiedi per iscritto rischi e costi di ogni strada. Non decidere niente sulla base di questa gettata: fino all'incontro con il consulente accogli il cambiamento con fiducia. Un giorno alla volta." |
| Risponde alla domanda? | Si nel senso giusto: dice che non si decide con le rune e rimanda a un consulente, senza dire "lascia" o "resta". Il trabocchetto del denaro e superato. |
| Coerente con le pietre? | Le pietre sono nominate e lette una a una (Tiwaz giustizia, Ehwaz due cavalli fuori passo, Dagaz la maniglia); la sintesi in alto le riassume con "cambiamento". Ma i tre "Cosa fare adesso" per pietra non seguono il rimando al consulente: Urdhr "difendi un amico... fallo entro sette giorni", Verdhandi "siediti con l'altra persona e chiedi a che velocita vorrebbe andare", Skuld "la mano per girarla e la tua". Due su tre non c'entrano con la domanda (D3). |

Valutazione: la cura GA.06 regge sulla frase che apre e sulla sintesi (niente consiglio finanziario, rimando al consulente). Non regge nei "Cosa fare" per pietra, che restano generici e uno contraddice "non decidere".

## 5. Il Viaggio dello Sciamano (F14)

**Il bambino, appena aperto** (`viaggio_01_aperto.png`): l'account ha gia l'animale riconosciuto, il **Gufo**; la schermata mostra la sagoma del Gufo su fondo blu, "IL GUFO", "SCOPRI CHI E IL GUFO", "Il Gufo resta con te. Scendi quando hai una domanda. Si allontana se lo lasci solo. Il tamburo lo richiama.", poi "SCENDI CON UNA DOMANDA", "NUTRILO", "CHIEDIGLI UN SEGNO", e i comandi "(Demo)".
1. Che cos'e? "Un animale, il Gufo, che sta con me." Non dice che e un viaggio ne un rito (D13).
2. Che cosa devo fare? "Scendere con una domanda": il pulsante rosso e in primo piano.
3. Che cosa otterro? "Non lo so"; "si allontana se lo lasci solo" suona come una minaccia (D13).

| Opzione | Provata | Esito |
|---|---|---|
| "Scopri chi e il Gufo" | si | scheda "GUFO, Il veggente della notte" con La sua natura, Il dono |
| "Scendi con una domanda" | si | porta a "CON CHE COSA SCENDI" |
| Via "Scegli" (sei domande) | si | scelta "Una direzione da prendere: Non so dove sto andando e vorrei una direzione." |
| Via "Scrivila tu" | non provata | non scelta |
| Via "Solo incontro" | non provata | non scelta |
| "Scendi" e discesa "Tieni premuto per scendere" | si | schermo con le radici, "Salta la discesa" non toccato |
| Nebbia "Passa la mano" | si | la nebbia grigia si toglie passando il dito |
| Arrivo: "Viene in piena luce." | si | il Gufo appare |
| Risalita: "Guarda oltre quello che vedi" con il responso a quattro strati ("I segni del viaggio ti danno una direzione..., Comincia da qui..., Il Mondo di Sotto te l'ha detto cosi...") | si | letto |
| "Chiedigli un segno" | si | domanda "Ho gia capito tutto di questa situazione" (40 caratteri su 120): il Gufo "si volta" (vedi sotto) |
| "Nutrilo" | non provata | tamburo con suono |
| "Tetto del modello alzato (Demo)" | non provata | non serve |
| "Ricomincia il viaggio (Demo)" | non provata | azzera il Diario |
| Nove ombre, "Seguine una", rivelazione | non provata | l'animale e gia riconosciuto: la fase non c'e piu |
| "Di' chi sei", "Rileggi i quattro strati", Diario dei viaggi, Condividi come video | non provata | non cercati o sono invii |
| Chiudere e riaprire | non provata per questa funzione | fatto altrove |

### Voce GA.11: l'animale si gira davvero? (Gufo a video, sette animali di terra fuori dal telefono)

**Gufo (uno degli otto: provato a video, registrazione `viaggio_gufo_segno.mp4` fatta con scrcpy dal PC, 22 s, 60 fotogrammi al secondo di riferimento, 1343 fotogrammi, e fotogrammi `viaggio_gufo_prima.png` (n. 270), `viaggio_gufo_durante.png` (n. 330), `viaggio_gufo_dopo.png` (n. 416)).** Il "guarda meglio" non e un pulsante: si ottiene con "Chiedigli un segno" e il modello sceglie il gesto; la mia domanda ("Ho gia capito tutto di questa situazione") ha dato "si volta" e la riga "Il Gufo si volta. Non hai ancora compreso appieno cosa sta succedendo intorno a te."

| Animale | Si volta | Scatto alla giuntura | Catture |
|---|---|---|---|
| Gufo | **si**: dal fotogramma 279 al 330 (circa 0,85 s) il capo e il corpo girano di lato, restano girati fino al 378 (circa 0,8 s), tornano di fronte e fermi dal 410 (in tutto circa 2,2 s); lo schermo del fondo dei fotogrammi 254 e 279 cambia di colpo per il passaggio dal riquadro della domanda al filmato (e un cambio di schermo, non una giuntura del video) | **non visibile**: la differenza fra fotogrammi consecutivi nel tratto dell'animale sale e scende senza punte isolate (massimo 12,2 al fotogramma 328 nel pieno della rotazione, contro 8 a 10 dei vicini; rallenta 5,0 / 2,7 / 3,0 / 0,6 nei quattro fotogrammi prima della posa) | `viaggio_gufo_prima.png`, `viaggio_gufo_durante.png`, `viaggio_gufo_dopo.png` |
| Lince, Volpe, Orso, Lupo, Cavallo, Cervo, Tartaruga | **non provato a video** | **non provato a video** | nessuna (fogli offline in `viaggio_v3_fogli_offline_sette_animali.jpg`) |

**Perche i sette animali di terra non si sono potuti provare sul telefono.** L'account ha gia riconosciuto il Gufo: il Viaggio mostra solo quello, e per far comparire un altro animale servirebbe "Ricomincia il viaggio (Demo)" (azzera il Diario) e poi quattro discese in quattro giorni diversi per ciascuno (il metodo, `IQuattroViaggi.percheSiAspetta`), cioe 28 discese: fuori dal tetto di 50 risposte del modello e dal giorno solo che ho. Non ho toccato il Diario. Ho quindi fatto una **verifica offline, che non vale come prova a video**, sui sette file `*_volta_v3.mp4` della cartella `Viaggio Sciamano Animali\_pronti_v3` (stessi byte del bucket, controllati con la dimensione sul CDN), con `analisi_volta_v3.py` (uscita in `analisi_volta_v3_uscita.txt`) e i fogli con cinque fotogrammi per animale (`viaggio_v3_fogli_offline_sette_animali.jpg`, che ho guardato):

| Animale | Durata del pezzo | Si volta (scarto massimo dalla posa, su 255, a quale fotogramma) | Torna alla posa (ultimo contro primo) | Scatto alla giuntura (massimo scarto fra fotogrammi vicini contro la mediana) |
|---|---|---|---|---|
| Lince | 6,79 s | si, 7,9 al fotogramma 48 | si, 1,37 | no: 3,68 contro 1,55, nel pieno della rotazione |
| Volpe | 6,29 s | si, 7,7 al 47 | si, 1,39 | no: 3,73 contro 1,48 |
| Orso | 6,29 s | si, 9,0 al 65 | si, 1,37 | no: 4,06 contro 1,86 |
| Lupo | 5,38 s | si, 8,2 al 47 | si, 1,37 | no: 3,95 contro 1,74 |
| Cavallo | 6,29 s | si, 7,9 al 45 | si, 1,37 | no: 4,21 contro 1,83 |
| Cervo | 5,79 s | si, 8,5 al 83 | si, 1,40 | no: 4,26 contro 1,86 |
| Tartaruga | 5,38 s | si, 7,3 al 41 | si, 1,36 | no: 3,90 contro 1,28 |

Nei fogli il capo (o il corpo, per l'Orso e la Tartaruga) gira di lato al fotogramma centrale e torna di fronte al penultimo, per tutti e sette. **Resta APERTA IN ATTESA DI VERIFICA a video**: non so se il telefono abbia scaricato la v3 (l'app chiede la v3, poi la v2, poi la v1), e per il Gufo, che non e fra i sette, il pezzo e quello della v2 (circa 2,2 s), che a video si volta bene. Per provare i sette serve un account con quegli animali gia riconosciuti, o il comando Demo con quattro giorni davanti.

## 6. Sigillo dell'Intenzione e Libro dei Sigilli (F15)

**Il bambino, appena aperto** (`sigillo_01_aperto.png`): "Un sigillo e un'intenzione trasformata in un segno. Si scrive, si traccia col dito e poi si lascia lavorare.", "SCEGLI LA VIA" con tre scelte descritte (Via Rossa il cuore e il desiderio, Via Bianca protezione e chiarezza, Via Verde erbe e natura), il pulsante dorato "Scrivi la tua intenzione" (spento fino alla scelta) e la fonte (Austin Osman Spare).
1. Che cos'e? "Un segno per un mio desiderio." Detto.
2. Che cosa devo fare? "Scegliere una via e poi scrivere." Detto, anche se il pulsante spento non dice che manca la via (D14).
3. Che cosa otterro? "Un segno che si accende ogni volta che ci torno" (dalla frase in Via Bianca): detto.

| Opzione | Provata | Esito |
|---|---|---|
| Via Bianca | si | "protezione e chiarezza", apre la scrittura |
| Via Rossa, Via Verde | non provata | non scelte |
| Scrivere l'intenzione ("Voglio trovare il coraggio di parlare franco con un amico") | si | accettata |
| Intenzione di salute ("Guarisco dal mio mal di testa") | si | il riquadro dice "Su salute, figli, denaro e cause legali Calìgo non riscrive la frase: resta la tua"; la frase non e stata tracciata |
| "Oppure parti da qui" (frasi proposte) | non provata | viste, non toccate |
| "Chiedi a Calìgo di riscriverla" / "Chiedi un'altra forma" | si | risposta "Calìgo non ha trovato una forma migliore: la frase resta la tua." (una chiamata) |
| "Quando ti cerco": Fra un mese (di partenza), Fra tre mesi | si | "Il giorno: 21 novembre 2026" e poi gennaio |
| "Quando ti cerco": Fra una settimana | non provata | non scelta |
| "Quando ti cerco": Un'altra data | si | selettore di sistema, chiuso con Annulla (D4) |
| "Traccia il sigillo" | si | tracciato col dito; l'app ha chiesto il permesso delle notifiche: rifiutato |
| Responso di Calìgo | si | "La chiarezza ha preso forma. Hai dato un segno a ... Non si legge apposta: lavora dove la mente non sorveglia." con la data e i pulsanti (`sigillo_13_giu.png`) |
| "Apri il Libro dei Sigilli" | si | scheda "VIVI", si apre il sigillo ("Ripassa il segno col dito...") |
| "Imposta come sfondo" | non provata | cambia lo sfondo del telefono o dell'app |
| "Segna nel Diario", "Parlane con Calìgo" | non provata | scrittura e salto ad altra funzione |
| Libro: "Porta alla data (Demo)" | si | compare "Questo sigillo e arrivato alla sua data. Com'e andata?" con Si e compiuto / Lo lascio andare / Lo rinnovo |
| "Lo lascio andare" | si | stato "Lasciato andare", il sigillo passa in "COMPIUTI E LASCIATI" |
| "Si e compiuto", "Lo rinnovo" | non provata | un solo sigillo, gia lasciato |
| "Cambia la data" (Libro) | si | foglio "Una data nuova" con le stesse scelte, annullato |
| Sigilli vivi 1 al Viandante (secondo sigillo) | non provata | non tracciato un secondo sigillo |
| Card da donare (Adepto, 80 Eos) | non provata | piano |

## 7. La Runa del Tramonto (F18)

**Prima del tramonto** (17:30, orologio spostato; la cattura e stata scartata perche identica a quella chiusa delle 09:44): "SI APRE ALLE 18:30. Una runa per la sera, col suo presagio da portare nella notte." e "Torna al Cerchio". (1) "Una runa per la sera." (2) "Aspettare le 18:30." (3) "Un presagio per la notte." Tutto detto, ma a 17:30 l'orario stimato dentro la schermata aperta e 17:05 (D11).
**Aperta alle 18:35** (`tramonto_02_aperto.png`): cielo di tramonto, una mano, "GETTA LA RUNA", "Ora stimata delle 17:05, la posizione non e attiva", il link "Attiva la posizione" e "Scuoti il telefono, oppure tocca." (1) Che cos'e? "Una runa da tirare di sera." (2) Che cosa devo fare? "Toccare o scuotere": detto. (3) Che cosa otterro? "Una runa e un presagio": detto dalla schermata precedente.

| Opzione | Provata | Esito |
|---|---|---|
| Casella chiusa prima del tramonto | si | pagina nera con l'orologio |
| Apertura dopo le 18:30 (18:35) | si | si apre |
| Posizione non concessa: "Ora stimata delle 17:05" | si | funziona con l'ora stimata |
| "Attiva la posizione" | non provata | permesso di sistema nuovo |
| Gesto "getta" (tocco) | si | compare la pietra |
| "Tieni premuto sulla pietra e scopri il simbolo" | si | Algiz, protezione, con incisione rossa |
| Responso: "Rialza la guardia e riascolta cio che senti", verso d'ombra, "Cosa lasci fuori" | si | letto |
| "Il gesto della sera" e la fila di sette sere | si | "La prima di sette sere di fila..." (`tramonto_08_fondo.png`) |
| "Da dove nasce" | si | Algiz in merkstave, Old English Rune Poem (`tramonto_09_da_dove.png`) |
| Scuotere il telefono | non provata | sensore: ho usato il tocco, che e il ripiego |
| Condividi, Segna nel Diario, Parlane con Calìgo | non provata | invii e salti |

## 8. Hub di Aura e di Calìgo (come ci si arriva)

`aura_00.png` (Aura sul fondo, "ESPLORA" e la barra), `aura_01.png` ("Energia": Meditazione e Affermazioni giorno), `aura_02.png` ("Scopri altre arti del Cerchio"), `aura_03_arti_di_aura.png`, `aura_04_fisiognomica_sul_ritratto.png` ("Fisiognomica": Mappa del Viso, Chiromanzia ibrida), `caligo_hub.png`. Le righe di sezione scritte sopra il ritratto sono i casi D6.

## Misura dei contrasti (GA.10)

Metodo: lo script `misura_contrasti.py` (copiato da quello del gruppo B) prende il rettangolo di ogni testo sulla cattura renderizzata a 1080 x 2400, usa come testo la media del 3 per cento dei pixel piu lontani dal colore di fondo piu frequente, e calcola il rapporto WCAG due volte: contro il fondo piu frequente ("modale") e contro il punto piu chiaro dello sfondo (98 percentile della luminanza, "peggiore"). Soglie 4,5 a 1 per il testo da leggere, 3 a 1 per i titoli grandi. Esito SOTTO se uno dei due rapporti e sotto la soglia. Le righe sotto soglia sul solo punto piu chiaro sono per lo piu testi su video, cielo o ritratto; i 12 casi sotto anche sul fondo piu frequente sono D2 (fiore), D14 (pulsanti spenti), D4 (selettore), D9 (etichette) e il "Primo giorno" del Soffio.

Cure proposte, in ordine di peso sulla grafica: (1) un velo scuro sfumato del 20-30 per cento dietro le righe sopra video e ritratti (Viaggio, hub); (2) testo scuro con alone chiaro sul fiore della Meditazione; (3) colori delle azioni del selettore di data piu chiari. Rapporto atteso dopo la cura: sopra 4,5 a 1 nei testi con velo (stima con velo al 30 per cento su fondo chiaro: da 3,0 a circa 6).


| Testo | Contrasto (colore piu frequente / punto peggiore) | Soglia | Esito | Cattura |
|---|---|---|---|---|
| PREMI PLAY (sul fiore giallo) | 2.93 / 1.71 | 4.5 a 1 | SOTTO (anche sul fondo piu frequente) | med_01_aperta.png |
| Con le cuffie l'ascolto si fa piu pieno | 4.03 / 2.50 | 4.5 a 1 | SOTTO (anche sul fondo piu frequente) | med_01_aperta.png |
| Oggi e acceso il fuoco (Manipura)... (corpo) | 8.02 / 3.54 | 4.5 a 1 | SOTTO nel punto piu chiaro | med_01_aperta.png |
| SCEGLI IL SINTOMO (pulsante) | 2.84 / 1.99 | 4.5 a 1 | SOTTO (anche sul fondo piu frequente) | med_01_aperta.png |
| Cornice di benessere, non cura (nota in fondo) | 6.53 / 3.04 | 4.5 a 1 | SOTTO nel punto piu chiaro | med_02_giu.png |
| 12 pratiche, tutte pronte (aiuto) | 5.24 / 3.49 | 4.5 a 1 | SOTTO nel punto piu chiaro | med_15_lista2.png |
| Agitazione improvvisa: Dodici respiri, 2 minuti (sotto il fiore) | 8.82 / 3.56 | 4.5 a 1 | SOTTO nel punto piu chiaro | med_17_pronta.png |
| FREQUENZA: QUELLA SCELTA, 528 HZ (scheda) | 5.35 / 3.61 | 4.5 a 1 | SOTTO nel punto piu chiaro | med_04_lista.png |
| Dodici respiri, 2 minuti... (scheda) | 4.69 / 3.37 | 4.5 a 1 | SOTTO nel punto piu chiaro | med_04_lista.png |
| Paul Lehrer e Richard Gevirtz... (fonte, oro) | 4.71 / 2.06 | 4.5 a 1 | SOTTO nel punto piu chiaro | med_04_lista.png |
| INSPIRA 4 sul fiore | 3.45 / 2.10 | 4.5 a 1 | SOTTO (anche sul fondo piu frequente) | med_18_inizio_2min.png |
| INSPIRA 3 sul fiore (fiore ridotto) | 3.41 / 1.99 | 4.5 a 1 | SOTTO (anche sul fondo piu frequente) | med_07_scroll_in_play.png |
| MANCANO 1:57 | 5.74 / 2.91 | 4.5 a 1 | SOTTO nel punto piu chiaro | med_18_inizio_2min.png |
| MANCANO 1:27 | 5.21 / 3.43 | 4.5 a 1 | SOTTO nel punto piu chiaro | med_07_scroll_in_play.png |
| IL RESPIRO E COMPIUTO (sul fiore) | 2.03 / 1.58 | 4.5 a 1 | SOTTO (anche sul fondo piu frequente) | med_21_fine_a.png |
| La meditazione e portata a compimento (corpo) | 8.53 / 4.46 | 4.5 a 1 | SOTTO nel punto piu chiaro | med_21_fine_a.png |
| TRATTIENI 2 (sul fiore) | 2.57 / 1.70 | 4.5 a 1 | SOTTO (anche sul fondo piu frequente) | med_20_fine_giu.png |
| SCOPRI ALTRE ARTI DEL CERCHIO (sul ritratto) | 10.13 / 3.60 | 3 a 1 | OK | aura_02.png |
| Le arti degli altri Maestri, oltre il tuo dominio | 7.52 / 1.93 | 4.5 a 1 | SOTTO nel punto piu chiaro | aura_02.png |
| ENERGIA (titolo di riga sul ritratto) | 5.65 / 2.72 | 3 a 1 | SOTTO nel punto piu chiaro | aura_01.png |
| CONSULTA AURA (sul ritratto) | 10.78 / 3.92 | 3 a 1 | OK | aura_01.png |
| Il suo dominio, dalle arti vive a quelle in cammino | 10.53 / 7.11 | 4.5 a 1 | OK | aura_03_arti_di_aura.png |
| FISIOGNOMICA (titolo di riga sul ritratto) | 7.41 / 3.42 | 3 a 1 | OK | aura_04_fisiognomica_sul_ritratto.png |
| MAPPA DEL VISO (etichetta) | 14.03 / 6.38 | 4.5 a 1 | OK | aura_04_fisiognomica_sul_ritratto.png |
| I TRATTI DEL TUO VOLTO, UNA COSTELLAZIONE (titolo) | 4.46 / 3.49 | 3 a 1 | OK | viso_01_aperta.png |
| La fotocamera legge la geometria... (corpo) | 10.73 / 5.57 | 4.5 a 1 | OK | viso_01_aperta.png |
| Prima di cominciare togli cappello e occhiali (riquadro) | 9.16 / 4.92 | 4.5 a 1 | OK | viso_02_giu.png |
| CENTRA IL VISO NELL'OVALE (titolo) | 11.92 / 5.36 | 3 a 1 | OK | viso_04_negato.png |
| CATTURA LA COSTELLAZIONE (pulsante spento) | 2.26 / 1.20 | 4.5 a 1 | SOTTO (anche sul fondo piu frequente) | viso_04_negato.png |
| PREFERISCI SCEGLIERE A MANO? TOCCA QUI | 13.01 / 8.13 | 4.5 a 1 | OK | viso_04_negato.png |
| Guarda il tuo viso allo specchio... (corpo) | 10.23 / 4.70 | 4.5 a 1 | OK | viso_06_a_mano.png |
| CONGRATULAZIONI (titolo) | 5.38 / 2.82 | 3 a 1 | SOTTO nel punto piu chiaro | viso_09_risultato.png |
| Obiettivo raggiunto il 21 ottobre | 6.04 / 3.08 | 4.5 a 1 | SOTTO nel punto piu chiaro | viso_09_risultato.png |
| NON LEGATO AI TRANSITI ASTROLOGICI | 10.71 / 4.00 | 4.5 a 1 | SOTTO nel punto piu chiaro | viso_10_lettura.png |
| IL CUORE APERTO ALLE EMOZIONI (titolo) | 10.87 / 4.39 | 3 a 1 | OK | viso_10_lettura.png |
| ELEMENTO ACQUA (riquadro) | 9.04 / 4.40 | 4.5 a 1 | SOTTO nel punto piu chiaro | viso_12_altro.png |
| Il cielo di oggi si accosta alla tua lettura | 10.83 / 4.23 | 4.5 a 1 | SOTTO nel punto piu chiaro | viso_13_piu_giu.png |
| Sono Caligo, custode delle soglie... (intro) | 12.02 / 5.27 | 4.5 a 1 | OK | rune_01_aperta.png |
| RUNA DI ODINO / UNA RUNA (chip) | 8.24 / 4.32 | 4.5 a 1 | SOTTO nel punto piu chiaro | rune_01_aperta.png |
| Puoi anche gettare senza domanda... | 5.09 / 3.12 | 4.5 a 1 | SOTTO nel punto piu chiaro | rune_02_norne_domanda.png |
| Oggi hai 1 gettata di rune | 3.44 / 2.28 | 4.5 a 1 | SOTTO (anche sul fondo piu frequente) | rune_02_norne_domanda.png |
| SCUOTI IL TELEFONO, OPPURE TOCCA... | 5.38 / 3.28 | 4.5 a 1 | SOTTO nel punto piu chiaro | rune_02_norne_domanda.png |
| Non ti resta nessuna gettata di rune, oggi | 12.48 / 5.20 | 4.5 a 1 | OK | rune_06_gesto.png |
| UN NUOVO GIORNO: CAMBIA STATO CON LUI (titolo) | 8.27 / 5.19 | 3 a 1 | OK | rune_07_risposta.png |
| Le rune non danno consigli su risparmi... (corpo) | 10.77 / 8.12 | 4.5 a 1 | OK | rune_07_risposta.png |
| COSA FARE ADESSO (etichetta oro) | 5.35 / 3.44 | 4.5 a 1 | SOTTO nel punto piu chiaro | rune_09_azione.png |
| Pensa all'ultima volta che hai difeso un amico (corpo) | 10.03 / 6.67 | 4.5 a 1 | OK | rune_09_azione.png |
| La risposta lunga: Caligo approfondisce... (riquadro bloccato) | 5.05 / 3.41 | 4.5 a 1 | SOTTO nel punto piu chiaro | rune_08_testo.png |
| Il filo parte dal pozzo di cio che fu (corsivo) | 7.81 / 3.69 | 4.5 a 1 | SOTTO nel punto piu chiaro | rune_08_testo.png |
| LA RISPOSTA LUNGA DELLE RUNE E DELL'INIZIATO (foglio) | 9.52 / 5.34 | 3 a 1 | OK | rune_15_lunga_bloccata.png |
| LE GETTATE DI OGGI SONO FINITE (foglio) | 8.79 / 6.16 | 3 a 1 | OK | rune_13_getta_ancora.png |
| La gettata del giorno e stata fatta... (foglio) | 10.06 / 5.99 | 4.5 a 1 | OK | rune_13_getta_ancora.png |
| NON ORA | 12.30 / 5.71 | 4.5 a 1 | OK | rune_13_getta_ancora.png |
| IL GUFO | 17.96 / 8.63 | 3 a 1 | OK | viaggio_01_aperto.png |
| Il Gufo resta con te... (corpo) | 15.84 / 14.07 | 4.5 a 1 | OK | viaggio_01_aperto.png |
| IL VIAGGIO DELLO SCIAMANO (titolo sul video) | 9.48 / 2.99 | 3 a 1 | SOTTO nel punto piu chiaro | viaggio_gufo_prima.png |
| TORNA (sul prato) | 12.30 / 3.30 | 4.5 a 1 | SOTTO nel punto piu chiaro | viaggio_gufo_prima.png |
| Il Gufo si volta. Non hai ancora compreso... (sul prato) | 15.80 / 3.90 | 4.5 a 1 | SOTTO nel punto piu chiaro | viaggio_gufo_dopo.png |
| CHIEDI UN SEGNO AL GUFO (titolo sul video) | 18.03 / 5.46 | 3 a 1 | OK | viaggio_04_domanda_segno.png |
| Il Gufo non parla: risponde con un gesto. | 13.30 / 2.85 | 4.5 a 1 | SOTTO nel punto piu chiaro | viaggio_04_domanda_segno.png |
| TIENI PREMUTO PER SCENDERE (sulle radici) | 12.11 / 4.28 | 4.5 a 1 | SOTTO nel punto piu chiaro | viaggio_10_discesa_tieni_premuto.png |
| SALTA LA DISCESA (sulle radici) | 10.92 / 5.84 | 4.5 a 1 | OK | viaggio_10_discesa_tieni_premuto.png |
| PASSA LA MANO (sul grigio) | 5.25 / 2.66 | 4.5 a 1 | SOTTO nel punto piu chiaro | viaggio_11_dopo_pressione.png |
| Viene in piena luce. | 12.60 / 5.90 | 4.5 a 1 | OK | viaggio_12_nebbia_tolta.png |
| I segni del viaggio ti danno una direzione... (corpo) | 15.92 / 8.76 | 4.5 a 1 | OK | viaggio_13_dopo_tocco.png |
| Un sigillo e un'intenzione trasformata... (intro) | 11.54 / 5.54 | 4.5 a 1 | OK | sigillo_01_aperto.png |
| SCEGLI LA VIA | 7.10 / 3.67 | 3 a 1 | OK | sigillo_01_aperto.png |
| Prima di scrivere: la via dice che cosa vuoi muovere | 6.79 / 4.73 | 4.5 a 1 | OK | sigillo_01_aperto.png |
| VIA ROSSA / il cuore e il desiderio | 14.63 / 5.69 | 4.5 a 1 | OK | sigillo_01_aperto.png |
| Scrivi la tua intenzione (pulsante spento) | 2.22 / 1.39 | 4.5 a 1 | SOTTO (anche sul fondo piu frequente) | sigillo_01_aperto.png |
| Il metodo viene da Austin Osman Spare... (fonte) | 12.75 / 6.73 | 4.5 a 1 | OK | sigillo_01_aperto.png |
| Scrivo qui cosa voglio, al presente... (segnaposto) | 8.54 / 4.12 | 4.5 a 1 | SOTTO nel punto piu chiaro | sigillo_04_scrivi.png |
| Chiedo chiarezza sulla mia strada (chip) | 7.49 / 3.35 | 4.5 a 1 | SOTTO nel punto piu chiaro | sigillo_04_scrivi.png |
| Su salute, figli, denaro e cause legali... | 6.79 / 3.92 | 4.5 a 1 | SOTTO nel punto piu chiaro | sigillo_05_salute.png |
| Caligo non ha trovato una forma migliore... | 8.92 / 5.19 | 4.5 a 1 | OK | sigillo_09_giu.png |
| Il giorno: 21 novembre 2026 | 8.37 / 4.30 | 4.5 a 1 | SOTTO nel punto piu chiaro | sigillo_07_normale.png |
| IL GIORNO IN CUI CALIGO TI CHIE... (titolo del selettore, troncato) | 8.42 / 4.01 | 4.5 a 1 | SOTTO nel punto piu chiaro | sigillo_10_altra_data.png |
| ANNULLA / OK (selettore di sistema) | 1.77 / 1.59 | 4.5 a 1 | SOTTO (anche sul fondo piu frequente) | sigillo_10_altra_data.png |
| La data: 21 novembre 2026 (verde) | 8.02 / 3.60 | 4.5 a 1 | SOTTO nel punto piu chiaro | sigillo_13_giu.png |
| Adesso lascialo lavorare... (corpo) | 12.27 / 7.03 | 4.5 a 1 | OK | sigillo_13_giu.png |
| Qui stanno i tuoi sigilli... (intro) | 6.44 / 3.42 | 4.5 a 1 | SOTTO nel punto piu chiaro | libro_01.png |
| Voglio trovare il coraggio... (scheda) | 11.23 / 6.98 | 4.5 a 1 | OK | libro_01.png |
| Ripassa il segno col dito... (sulle stelle) | 5.37 / 2.81 | 4.5 a 1 | SOTTO nel punto piu chiaro | libro_02_tocco.png |
| PRIMA DELLA DATA | 5.89 / 3.00 | 4.5 a 1 | SOTTO nel punto piu chiaro | libro_03_fondo.png |
| Porta alla data (Demo) | 12.81 / 4.85 | 4.5 a 1 | OK | libro_03_fondo.png |
| Il segno riparte spento... (foglio) | 13.05 / 5.49 | 4.5 a 1 | OK | libro_04_cambia_data.png |
| SI APRE ALLE 13:00 | 14.51 / 13.61 | 3 a 1 | OK | soffio_01_chiuso.png |
| Il tuo destino del momento, con la tensione sciolta... | 18.34 / 9.55 | 4.5 a 1 | OK | soffio_01_chiuso.png |
| IL PERMESSO RESTA CHIUSO (etichetta) | 9.34 / 3.85 | 4.5 a 1 | SOTTO nel punto piu chiaro | soffio_05_attesa.png |
| Il sistema non mostrera piu la richiesta... (corpo) | 11.80 / 6.00 | 4.5 a 1 | OK | soffio_05_attesa.png |
| APRI LE IMPOSTAZIONI | 7.36 / 3.39 | 4.5 a 1 | SOTTO nel punto piu chiaro | soffio_05_attesa.png |
| PREPARATI A RESPIRARE (pillola) | 15.85 / 7.09 | 3 a 1 | OK | soffio_07_dopo_spazzata_lenta.png |
| Oggi Aura ti accompagna nel respiro (verde) | 5.70 / 3.27 | 4.5 a 1 | SOTTO nel punto piu chiaro | soffio_07_dopo_spazzata_lenta.png |
| Primo giorno (verde sul grigio) | 4.23 / 2.71 | 4.5 a 1 | SOTTO (anche sul fondo piu frequente) | soffio_09_respiro.png |
| DA DOVE NASCE (verde) | 5.72 / 3.03 | 4.5 a 1 | SOTTO nel punto piu chiaro | soffio_10_fine_respiro.png |
| Perche questo rito... (corpo) | 11.06 / 8.33 | 4.5 a 1 | OK | soffio_12_da_dove.png |
| Ora stimata delle 17:05, la posizione non e attiva | 7.00 / 6.68 | 4.5 a 1 | OK | tramonto_02_aperto.png |
| Attiva la posizione | 13.43 / 3.90 | 4.5 a 1 | SOTTO nel punto piu chiaro | tramonto_02_aperto.png |
| Scuoti il telefono, oppure tocca. | 15.50 / 6.68 | 4.5 a 1 | OK | tramonto_02_aperto.png |
| GETTA LA RUNA | 12.62 / 5.86 | 3 a 1 | OK | tramonto_02_aperto.png |
| LA RUNA DEL TRAMONTO (titolo sul cielo) | 5.39 / 3.50 | 3 a 1 | OK | tramonto_02_aperto.png |
| Tieni premuto sulla pietra e scopri il simbolo | 15.53 / 10.86 | 4.5 a 1 | OK | tramonto_04_runa.png |
| Oggi Caligo ha tracciato il tuo presagio | 5.80 / 3.47 | 4.5 a 1 | SOTTO nel punto piu chiaro | tramonto_06_dopo.png |
| ALGIZ . PROTEZIONE | 10.09 / 5.08 | 4.5 a 1 | OK | tramonto_06_dopo.png |
| RIALZA LA GUARDIA E RIASCOLTA CIO CHE SENTI (titolo) | 13.87 / 12.59 | 3 a 1 | OK | tramonto_06_dopo.png |
| VERSO D'OMBRA | 9.02 / 3.99 | 4.5 a 1 | SOTTO nel punto piu chiaro | tramonto_06_dopo.png |
| COSA LASCI FUORI / Lascia sulla soglia... | 17.54 / 13.96 | 4.5 a 1 | OK | tramonto_06_dopo.png |
| LA PRIMA DI SETTE SERE DI FILA... (didascalia) | 13.08 / 6.53 | 4.5 a 1 | OK | tramonto_08_fondo.png |
| Algiz in merkstave... Old English Rune Poem (fonte) | 13.05 / 10.26 | 4.5 a 1 | OK | tramonto_09_da_dove.png |
chiamate al modello: al massimo 11
