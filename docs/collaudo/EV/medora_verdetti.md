# Medora, il cielo e i responsi: i verdetti dei banchi (ordine EV, voci 03 e 04)

Ogni risposta dei banchi letta a mano contro i fatti delle effemeridi che il
file mette accanto. I file sono in questa cartella; i banchi sono
`tool/medora_e_il_cielo.dart` e `tool/medora_e_il_responso.dart`, con
`gemini-2.5-flash` in europe-west1, l'istruzione e la configurazione vere
dell'app. "Prima" vuol dire il codice di prima dell'ordine EV (senza le
funzioni del cielo, coi sette corpi e la regola "Non nominare Urano, Nettuno e
Plutone", senza i responsi nell'istruzione).

## EV.03, il cielo: venti domande

### Prima (`medora_e_il_cielo_prima.txt`)

| # | domanda | verdetto |
|---|---|---|
| 1 | Urano retrogrado oggi? | **NEGA**: "Urano oggi non è retrogrado" (lo era, 5 gradi Gemelli). E' il difetto delle catture dei fondatori |
| 2 | Luna oggi | **SBAGLIATO**: "in Scorpione, calante" (Gemelli, gibbosa calante); la rete toglie la frase e resta un testo senza fatto |
| 3 | retrogradi oggi | **SBAGLIATO**: "solo Saturno" (Saturno, Urano, Nettuno, Plutone) |
| 4 | Venere oggi | **SBAGLIATO**: "Leone" (Scorpione), tolta dalla rete |
| 5 | aspetti oggi | **INVENTATO**: "la Luna nel tuo segno Cancro si oppone a Venere retrograda", tolta dalla rete |
| 6 | Marte oggi | giusto (Leone) |
| 7 | cielo di oggi | giusto (la persona con la nascita riceveva la Luna di oggi) |
| 8 | 21/12/2020 | giusto, senza gradi |
| 9 | Saturno 1/1/2000 | giusto (Toro) |
| 10 | Luna 20/7/1969 | **SBAGLIATO**: "calante, terzo quarto" (crescente, in Bilancia) |
| 11 | eclissi 8/4/2024 | **NEGA**: "non è stata l'8 aprile 2024" (eclissi solare totale) |
| 12 | Mercurio agosto 2025 | **NON RISPONDE**: chiede mese e anno, gia' scritti |
| 13 | Giove 14/3/1990 | giusto (Cancro) |
| 14 | domani | **INVENTATO**: "la Luna in Scorpione" (Gemelli), tolta dalla rete |
| 15 | quando torna diretto Urano | **NEGA**: "Non ho tra i miei dati celesti la posizione di Urano" |
| 16 | dicembre 2026 | nessun fatto, solo "transiti sul Sagittario" |
| 17 | eclissi 2027 | nessun fatto, nessuna data |
| 18 | prossima Luna piena | **SBAGLIATO**: "23 maggio, Sagittario" (26 ottobre, Toro) |
| 19 | Mercurio novembre 2026 | **NEGA**: "non sarà retrogrado" (retrogrado fino al 14) |
| 20 | Giove 1/1/2028 | **SBAGLIATO**: "Toro" (Vergine) |

**Fatti negati o sbagliati: 13 su 20**, piu' 2 risposte senza fatti (16 e 17).

### Dopo, con le correzioni dei giri: le due esecuzioni finali

`medora_e_il_cielo.txt` (Sofia, Cancro, Luna in Bilancia) e
`medora_e_il_cielo_persona2.txt` (Marco, Leone, Luna in Pesci), dati diversi,
risposte diverse.

| esecuzione | fatti negati | fatti sbagliati a video | risposte che non rispondono | note |
|---|---|---|---|---|
| Sofia | 0 | 0 | 0 | alla 15 il modello ha rimandato ("devo consultare"), il sollecito dell'app l'ha fatto chiamare: la risposta a video e' l'8 febbraio 2027, giusta. La 12 coniuga al futuro un fatto passato ("sarà retrogrado ... ad agosto 2025"), il fatto e' giusto |
| Marco | 0 | 0 | 0 | la rete ha tolto una frase vera ("il 9 novembre, quando la Luna è nuova in Scorpione"): corretto dopo il giro, la prova `medora_sa_il_cielo_e_il_responso_test` lo misura (innesto A12) |

**Fatti negati o sbagliati a video: da 13 su 20 a 0 su 20, in due esecuzioni
con dati diversi.**

### I sette giri, e che cosa ha cambiato ognuno

Ogni giro e' un file `medora_e_il_cielo_*_giro.txt`, letto a mano.

1. primo giro (funzioni date, descrizione breve): 5 risposte senza chiamata, di cui 3 con fatti inventati (Luna in Capricorno, gradi del 2020, cielo di domani), 2 che chiedevano la data gia' scritta; la rete toglieva due frasi vere (Giove in Vergine nel 2028, Luna in Bilancia nel 1969). Correzioni: la descrizione dice che il cielo il modello non lo sa, porta il cielo di oggi gia' calcolato e "non chiedere la data"; la rete riceve i giorni chiesti nel turno.
2. secondo giro: 1 errore ("la tua Luna in Gemelli" per la Luna di oggi). Correzione: "la tua Luna" si confronta con la Luna di nascita.
3. terzo giro: 1 errore (aspetti della Luna di oggi dati alla Luna di nascita). Correzione: nota nel cielo del giorno e nella descrizione.
4. quarto e quinto giro (anche con la seconda persona): "nel tuo segno di Bilancia" a un Cancro, "tre eclissi" su quattro, 2 rinvii senza chiamata. Correzioni: la riga nei dati natali ("i suoi sono solo questi"), "il tuo segno" contro il Sole di nascita, le eclissi in un elenco col conto, il sollecito quando la risposta rimanda.
5. sesto giro: 1 rinvio ("ho bisogno di consultare"), 1 risposta a memoria con due eclissi su quattro. Correzione: una domanda sul cielo di un altro tempo senza chiamata si sollecita sempre.
6. settimo giro: le due esecuzioni finali qui sopra.

## EV.04, i responsi: dieci domande

### Prima (`medora_e_il_responso_prima.txt`)

| # | responso | verdetto |
|---|---|---|
| 1 | Oroscopo (da "Parlane") | **INVENTA** il transito: "Saturno retrogrado" (il responso dice Luna in Gemelli in XII e Sole in Bilancia in IV) |
| 2 | Stesa (a mano) | **NON SA**: "dimmi il nome della carta" |
| 3 | Gettata (da "Parlane") | **NON SA**: "Quali sono le rune della tua gettata?" |
| 4 | Sinastria (a mano) | non nega, inventa i particolari |
| 5 | Arcano dell'Alba (da "Parlane") | **NON SA**: "ho bisogno di sapere quale arcano hai estratto" |
| 6 | Sigillo del Sogno (a mano) | **NEGA**: "Non conosco il Sigillo del Sogno" |
| 7 | Runa del Tramonto (da "Parlane") | **INVENTA**: parla della lama del Giudizio, non di Algiz |
| 8 | Soffio del Destino (a mano) | **INVENTA**: "la Lama della Stella" |
| 9 | Animale guida (da "Parlane") | **NEGA**: "Non ho un messaggio di un animale guida" |
| 10 | Archetipo (a mano) | **NEGA**: "Non è un archetipo a parlare di te" |

**Responsi negati, non saputi o inventati: 9 su 10.**

### Dopo: le due esecuzioni finali

`medora_e_il_responso.txt` (Sofia) e `medora_e_il_responso_persona2.txt`
(Marco), altri semi, altri responsi.

| esecuzione | responsi negati | responsi non saputi | note |
|---|---|---|---|
| Sofia | 0 su 10 | 0 su 10 | tutte e dieci partono dal responso: l'Imperatore al centro, Wunjo, Uruz e Berkano, la Giustizia, Algiz, il Lupo, l'Amante |
| Marco | 0 su 10 | 0 su 10 | una frase sbagliata fuori dal responso: alla 1 "un segno d'aria come il tuo" a un Leone |

Nel giro precedente (`..._persona2_secondo_giro.txt`) Marco aveva avuto un
"[[CHIEDO]] dovrei sapere quale carta ti è uscita" con la stesa nel contesto:
da li' il sollecito di `IResponsiDiOggi.chiedeQuale` (innesto A14) e la riga
"non chiederle quale" nel blocco dei responsi.

**Responsi negati: da 9 su 10 a 0 su 10, in due esecuzioni con dati diversi.**
