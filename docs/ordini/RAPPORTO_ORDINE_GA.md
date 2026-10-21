# RAPPORTO DELL'ORDINE GA, RESPONSI DIRETTI, STESE CONTATE PER STESA E CACCIA AI DIFETTI ANCHE SU IPHONE

20-21 ottobre 2026. Testo dell'ordine: `docs/ordini/ORDINE_GA_TESTO.md`.
Manifesto: `docs/ordini/ORDINE_GA_MANIFESTO.md`, 16 voci: **2 chiuse, 14 aperte
in attesa di verifica, 0 da fare**. Ramo `claude/esoteric-circle-master-order-e798aj`.

**Leggi questo prima di tutto.** Delle sedici voci ne chiudo due, e le altre
quattordici le scrivo aperte. Non perche' siano da fare: sono prodotte e
agganciate al codice, ma ognuna aspetta qualcosa che il codice non puo'
darsi da solo (una cattura sul telefono col codice finale, un piano diverso
dal Viandante, il tuo sì a una spesa, una decisione tua). Ogni voce aperta dice
nel manifesto che cosa aspetta, in una riga che comincia con `ASPETTA:`. La
regola e' la tua del 24 settembre: una voce non guardata a video non si
scrive chiusa. **Le tre cose che pesano di piu' sono in fondo, nella sezione
"Quello che resta aperto, coi numeri": le Rune sono ancora l'arte piu'
debole nella lettura cieca (6 su 12), le schede delle singole pietre sono
generiche e il Cosa fare legato alla domanda e' 14 su 35.**

## LE VOCI CHIUSE E LA LORO PROVA

| voce | prova |
|---|---|
| GA.07, i testi riscritti, mai troncati | `test/le_lunghezze_dei_responsi_test.dart` |
| GA.12, ogni cura verificata anche su iPhone (portata ridotta da te il 21 ottobre) | `docs/collaudo/GA/ios/avvio_07_dopo_90s.png` |

Le due voci chiuse, con DOMANDA, PROVA e MISURA, stanno nel manifesto.

**GA.07**: la misura e' sui corpora, non sui testi che scrive il modello (quelli
restano aperti per la regola delle spese). Voci con almeno un difetto
misurabile: da 1.284 su 1.548 nell'Oroscopo a 0; paragrafi fuori dalle 40-50
parole da 21.060 a 0; paragrafi troncati 0; nessuna chiamata a pagamento.

**GA.12**: il simulatore di iPhone compila l'app e la apre. La macchina e'
un macOS Intel di GitHub con Xcode 26.3, un iPhone 17 Pro con iOS 26.2. Tre
tentativi sono caduti prima del quarto (Xcode 16.4, il framework `Pods_Runner`
che non veniva costruito, l'architettura, poi un controllo di "app viva" che
su iOS 26 non funzionava): la causa vera era che il bersaglio `Pods-Runner`
non veniva costruito da solo, e adesso lo si costruisce a mano. Sette catture
dell'avvio, a 3, 8, 15, 25, 40, 60 e 90 secondi; a 40, 60 e 90 si vede "Il
Risveglio". Niente Firebase Test Lab e niente catture per ogni difetto, come
hai deciso il 21 ottobre.

## CHE COSA TI SERVE PER DECIDERE

1. **I numeri delle stese non sono quelli che avevi scritto.** Tu: 1, 3, 6 e
   10. Nel codice: **1, 3, 3 e 5** (Viandante, Iniziato, Adepto, Illuminato),
   con la stesa a dieci carte una al giorno per Adepto e Illuminato. La
   ragione: avevi scritto "deve rientrare nel 30% dopo provvigioni 15% store e
   22% iva, altrimenti Code le puo' modificare". Con 6 stese al giorno
   l'Adepto mensile, nel caso peggiore, esce a oltre il 39 per cento; con 3
   e' al 29,4. Vale per il mensile e per l'annuale (Adepto 3 in entrambi i
   cicli). Se vuoi 6 e 10, serve un prezzo diverso: dimmi tu.
2. **Una frase del corpus dell'Architetto adattata**: "Se il tempo tuo salta"
   diventa "Se il tempo per te salta" (genere a tre vie).
3. **Le funzioni del Respiro** sono ancora esportate in `functions/src/index.ts`
   anche se "Respiriamo insieme" non si promette piu'.
4. **La data della Luna.** Il Calendario degli eventi mostra 24 ottobre e 7
   novembre; il Respiro della Luna e la Collana mostrano 26 ottobre e 9
   novembre (le Lune piena e nuova esatte). Sono due letture dello stesso
   evento: la finestra che comincia e il picco. La guardia
   `la_prossima_data_e_il_giorno_in_cui_comincia_test` (ordine DS voce 08)
   vuole la prima. Non ho toccato nulla: scegli tu quale dire.
5. **La carta "Hai chiesto a ..."** (ordine FE voce 22, su tua richiesta)
   compare in cima a ogni chat, anche in quelle di un altro Maestro: la
   conversazione con Aura mostrava la domanda fatta a Calìgo. Il difetto e' che
   la carta non filtra per Maestro; la cura e' piccola, ma e' un disegno tuo.
6. **Il limite delle domande ai Maestri non ha uscita**: il messaggio non ha
   pulsante ne' il prezzo (80 Eos) ne' un invito ai piani, e ogni Maestro dice
   una frase diversa (difetto D10 del gruppo D).
7. **Il Diario** si riapre in "Quel giorno" senza la chat; non ha l'anno
   (spostando il telefono a gennaio 2027 i mesi tornano a zero).
8. **Crashlytics su iPhone** tace da settembre: o l'app non cade, o non
   segnala. Non ho modo di distinguere i due casi da qui.
9. **Il filmato della ruota dell'Oroscopo** dura circa 9 secondi prima del
   contenuto. La voce GA.14 chiedeva che il tocco rispondesse subito e non che
   il filmato sparisse: se vuoi che duri meno, e' una scelta tua.
10. **Le Rune**: servono testi scritti a mano per pietra e per tipo di domanda,
    non altri pozzi di voci neutre. Quanto lavoro e quante letture ciechi
    ancora vuoi spendere.
11. **I versetti di Martini** (Bibbia, Passigli 1842) tengono la virgola
    prima di "e" per citazione alla lettera: ho insegnato l'eccezione alle
    guardie. Confermi?
12. **Il dominio "Fortuna"** dell'Oroscopo parla di relazioni e occasioni; e'
    una delle quattro letture del campione.

## I DIFETTI TROVATI E CURATI DALLA CACCIA (GA.11), PER IL CONFRONTO CON LA LISTA DEI TESTER

Build presa come ultima: **2314**, quella che hai dichiarato ultima su Android e
su iPhone (la precedente su iPhone era la 2307, cattura in
`docs/collaudo/GA/ga11_testflight_2314.jpg`). Le vie: le cinque simulazioni
dell'ordine, il confronto fra le build, i registri di errore (Crashlytics,
letti senza credenziali in chat), i difetti aperti in STATO_VIVO. Ogni
difetto ha il suo commit, il suo padre e la sua guardia nata rossa
(`docs/collaudo/GA/ga11_regola_a.txt`).

1. **La coda dei consumi si avvelenava** (`f304d061`): un consumo che il
   server rifiuta in modo definitivo restava in coda e bloccava i
   successivi. Padre: FT.13 e FU.
2. **La scena che arriva pronta tardi** (`5f5c9daa`): il video che arriva dopo
   l'attesa partiva lo stesso e rinasconde il resto gia' comparso (Porta della
   Sinastria VIP, Chat senza messaggi). Padre: ordine FY, commit `8ac4f41c`. Vedi anche la
   tua decisione del 20 ottobre, `1580c8f2`: l'attesa delle scene torna a 4
   secondi, poi la scena ferma con la posa del Maestro.
3. **La home con un'altezza negativa** (`d4587e48`): l'errore rosso
   `_elements.contains(element)` della home (238 eventi su Crashlytics).
   Padre: commit `bc162adf` del 7 agosto 2026 (la sottrazione dello spazio
   della barra senza pavimento); era gia' in STATO_VIVO come PROVENIENZA IGNOTA.
4. **Una porta del server non pubblicata dice il vero** (`8e7627d8`): la
   ricucitura della perla del Respiro e le porte di Respiriamo insieme
   davanti a funzioni non pubblicate. Padre: ordine FF voce 02 e ordine FX
   voci FXA.03.
5. **La riga del premio monca** (`3219ca83`, finita in `c1eb2c14`): sulla
   card del traguardo la riga del premio si spezzava (la maiuscola sulla
   prima lettera). Padre: PROVENIENZA IGNOTA.
6. **Il tutorial del primo approdo con vincoli negativi** (`52164e7a`): sei
   eventi di Crashlytics sulla 2314, finestra 360x0 al benvenuto. Dopo la cura
   0 vincoli negativi (resta un overflow di 8 pixel per un fotogramma a
   360x40, non grave, stampato dalla prova). Padre: ordine FD, commit
   `6944b91f`.
7. **Il conto dei momenti senza rete** (`9517c5ab`): la home usciva con
   `cloud_firestore/unavailable` come errore senza padrone, e il primo avviso a
   chi usa il Cerchio senza account non compariva. Padre: ordine N voce 1c,
   commit `df7551f1`.
8. **Il Viaggio dello Sciamano, il "si volta"** (`fb2b74fb` e `248f16c9`): il
   gesto faceva girare il centro invece del pezzo; adesso il Gufo si volta
   davvero (registrazione, circa 2,2 secondi, nessuno scatto alla giuntura) e
   i sette animali di terra hanno il video nuovo dell'Architetto (manifesto
   v3). Padre del difetto: la v2, commit `fb2b74fb`, dello stesso ordine. **Provato a video: il solo Gufo.** I sette di terra sono analizzati sui
   file locali (si voltano senza scatti) ma non provati sul telefono, perche'
   servirebbe azzerare il Diario in Demo, e non scrivo dati di produzione.

Cinque guardie nuove nate rosse; a queste si aggiungono i difetti di GA.06,
GA.08, GA.10, GA.13, GA.14 e GA.15 curati dalle loro voci.

## LE SIMULAZIONI SUL REALME (GA.09 E FZ.09)

Fatte su un Realme 767f596c con il Viandante di collaudo, in cinque gruppi, sul
codice di poco prima delle ultime cure delle risposte. Rapporti in
`docs/collaudo/GA/simulazioni/`.

| gruppo | funzioni | opzioni provate | non provate | difetti (g3 / g2 / g1) |
|---|---:|---:|---:|---|
| A, carte e coppia | 6 | 49 | 17 | 13 (1 / 5 / 7) |
| B, cielo e Luna | 6 | 55 | 38 | 17 (0 / 6 / 11) |
| C, Aura e Calìgo | 7 | 60 | 38 | 17 (0 / 6 / 11) |
| D, Passaporto e conversazione | 6 | 59 | 28 | 30 (1 / 14 / 15) |
| E, Home, Cerchio, account e piani | 8 | 63 | 42 | 35 (0 / 12 / 23) |
| **in tutto** | **33 su 33** | **286** | **163** | **112** |

Le due gravita' 3: il consiglio dell'Oracolo che a una domanda di salute dice
"comincia, senza aspettare il permesso" (curato in `la_risposta_dai_doni.dart`,
con tre domande nuove nella prova) e le risposte dei Maestri che sembravano non
potersi rileggere (verificato: uscendo dalla chat si apre una conversazione
nuova, ma il filo di un'ora e la card "Hai chiesto a ..." le riportano;
resta il difetto di visibilita' D1 del gruppo D). **Nessun difetto di
gravita' 3 e' rimasto aperto.** Le opzioni non provate sono quelle che
chiedono un piano diverso dal Viandante (cambiare piano scrive sul server di
produzione), un permesso di sistema, un invio a terzi o una scrittura sul
server. L'elenco intero delle opzioni: `docs/collaudo/GA/le_opzioni.md`.

I padri di ogni difetto stanno nella colonna "Padre" dei cinque rapporti
(Regola C): dove non si e' potuto risalire c'e' scritto PROVENIENZA IGNOTA per
esteso, e sono la maggioranza.

## LA VERIFICA FINALE SULLA BUILD DI RILASCIO

Dopo l'installazione della build di rilascio sul Realme (commit `9a77eca1`, poi
`08d3d5da`), un secondo agente Sonnet indipendente ha verificato a video dieci
punti delle ultime cure, con il limite giornaliero dei Maestri gia' esaurito
sull'account di collaudo dalle simulazioni precedenti: **0 chiamate ai Maestri
spese** in questa verifica. Rapporto:
`docs/collaudo/GA/verifica_finale/rapporto_verifica_finale.md`.

Nove punti a posto: l'Oracolo si apre senza carte (GA.08), il tempo della
ruota dell'Oroscopo circa 10-12 secondi senza blocco del tocco (GA.14), la
Luna riconoscibile a colpo d'occhio (GA.13), nessuna carta "Hai chiesto a..."
che contamina la chat di un altro Maestro, il corsivo della Home e i pulsanti
d'oro leggibili (GA.10), la Home senza riquadri rotti. Tre non verificabili
per il limite (Oracolo, Tarocchi, Rune: il contenuto generato dai Maestri).

**Un falso difetto, trovato e chiuso nella stessa verifica.** La prima
cattura dei selettori bloccati della Stesa di Tarocchi (Chiave di lettura,
Tipo di stesa, Mazzo) sembrava mostrare un vicolo cieco silenzioso al tocco su
una voce col lucchetto. Una prova sullo stesso percorso di codice
(`test/le_voci_bloccate_della_stesa_invitano_test.dart`, nata rossa
sull'innesto verificato col grep) mostrava invece l'invito comparire in 600
millisecondi. La riverifica sul Realme, con un log Android senza eccezioni e
le coordinate del tocco incrociate con `uiautomator dump`, ha trovato la
causa vera: il tocco usava le coordinate della cattura scalata (900x2000)
senza moltiplicarle per 1,2 per tornare al pixel del device (1080x2400),
cadendo fuori dalla voce bloccata. Col tocco giusto l'invito compare sempre,
sui tre selettori. **PROVENIENZA del falso difetto: errore dell'agente di
verifica nel calcolo delle coordinate, non il codice.** Dettaglio per esteso:
`docs/collaudo/GA/verifica_finale/rapporto_verifica_finale.md`, sezione
"Correzione del 21 ottobre 2026".

## QUELLO CHE RESTA APERTO, COI NUMERI

**1. Le Rune sono l'arte piu' debole (GA.06, GA.05).** Ultima lettura cieca
indipendente (Sonnet, 12 gettate, `docs/collaudo/GA/lettori_ciechi/esiti/
giro10_esito_rune_12.md`): D1 (la prima frase risponde) 10 su 12, D2 (il Cosa
fare e' un'azione concreta) 8 su 12, D3 (coerenza con simboli e domanda) 10 su
12, **i tre si' insieme 6 su 12** (5 su 12 prima dell'ultimo giro, 3 su 40 al
primo). Trabocchetti: D1 4 su 4, D2 4 su 4, D3 3 su 4 (la salute e' fatta
bene). Le schede delle singole pietre con il Cosa fare legato alla domanda:
**14 su 35**. Causa: le schede sono generiche (in due gettate un limite sul
denaro dove la domanda non parlava di soldi), perche' i testi sono pozzi di
voci neutre invece di testi scritti per pietra e per tipo di domanda.
Padre: ordine GA voci 03, 04, 05 e 07 (compositore a frammenti, `a533412c`, e
corpus nella forma nuova, `fae20893`). La voce non si rilegge piu', per tua
decisione del 21 ottobre.

**2. Le altre tre arti nell'ultima lettura (12 responsi ciascuna).** Tarocchi
**11 su 12** (da 3 su 40 al primo giro; resta: carte singole con presupposti e
ripetizioni, il Tre di Spade identico in due stese; "decide un avvocato"
curato in "ti guida un avvocato", padre ordine GA voce 06, quarto giro).
Oracolo **10 su 12** (le carte singole sono ancora generiche). Oroscopo **9
su 12** (campione variato per tradizione e periodo; resta: il rito non
sempre legato al tema, strutture "Se... se..."). Lo scambio dei simboli e'
riconosciuto: 48 su 48, 40 su 40, 40 su 40, 40 su 40.

**3. GA.10.** 221 testi sotto soglia sulle catture: 36 sotto 4,5 anche sul
colore di fondo piu' frequente (32 curati, 4 pulsanti spenti esenti), 185
sotto soglia solo nel punto piu' chiaro del cielo (13 toccati dalla cura
comune dell'ombra, **172 lasciati come segnalazione**: decidi tu). I valori
"dopo" sono calcolati, non misurati sul telefono.

**4. GA.13.** Il disco della Luna al campo di partenza misura circa 160 pixel
su 1080 (53 punti su 360), al limite basso dei 55-60 dell'ordine. Il pizzico
per ingrandire non si prova con adb: serve un dito.

**5. GA.14.** Il tocco sull'Oroscopo non e' stato misurato dopo la cura (prima:
317 ms misurati dall'ordine EO); il filmato della ruota prima del contenuto
dura circa 9 secondi.

**6. GA.15.** L'account di collaudo non ha l'ora di nascita: la cura non e'
vista nel caso in cui conta.

**7. Il Viaggio.** Segno senza rete che consuma il tetto, titolo del segno
sopra l'animale, "Scendi", ombra del Serpente; Volpe, Orso e Tartaruga che
guardano di lato. Padre: ordine FZ.

**8. GA.01 e GA.02.** I numeri stanno nel codice del server
(`functions/src/budget.ts`: `stese: [1, 3, 3, 5]`, `steseDaDieci: [0, 0, 1, 1]`)
ma **il server in produzione non li ha ancora**: le funzioni vanno
pubblicate (vedi sotto).

## LE SCHERMATE CHE VERIFICHI TU SU IPHONE CON TESTFLIGHT

Il simulatore ha compilato e aperto l'app. Queste le guardi tu, nell'ordine,
sulla build di TestFlight:

1. Home: si apre senza altezze rotte, il tutorial del primo approdo si legge.
2. Oroscopo: si apre; quanto tarda il tocco; il filmato della ruota.
3. Oroscopo: la risposta ha il titolo, i paragrafi, il riquadro "Cosa fare
   adesso" e il rito col suo titolo (nella Lunga, dall'Iniziato).
4. Tarocchi: una stesa a tre carte, la forma del responso e la frase che
   risponde subito.
5. Tarocchi: il conteggio "stese" nella riga del piano.
6. Tarocchi: tocco su un mazzo bloccato (Marsiglia) e sulla Lunga: l'invito
   al piano, mai un vicolo cieco.
7. Oracolo degli Angeli: si apre senza carte in vista.
8. Oracolo: una domanda di salute ("ho mal di testa") riceve il limite medico.
9. Rune: la risposta della gettata e le schede delle pietre (sono il
   difetto piu' grosso: dimmi cosa leggi).
10. Cielo reale: la Luna si individua a colpo d'occhio.
11. Calendario degli eventi e Respiro della Luna: le due date della Luna
    (decisione 4).
12. Viaggio dello Sciamano: il Gufo si volta senza scatti.
13. Viaggio: gli altri sette animali di terra (Lince, Volpe, Orso, Lupo,
    Cavallo, Cervo, Tartaruga), che non ho potuto provare.
14. Meditazione: il testo della guida si legge sul fiore.
15. Pulsanti d'oro (Sigillo, Arcano dell'Alba): il testo scuro si legge.
16. Chat dei Maestri: nessuna citazione falsa ("come ti ho gia' detto").
17. Diario Cosmico: il filo, "Quel giorno", e se serve l'anno.
18. Passaporto: la carta natale e il cielo di nascita con e senza luogo.
19. Cerchio sociale: l'invito a custodire senza rete, e con rete.
20. Account con ora di nascita data: l'Oroscopo non la chiede piu'.
21. Impostazioni e piani: le quattro card dei piani dicono 1, 3, 3 e 5 stese.

## PER LA CONSEGNA

- **Funzioni del server per la Croce Celtica.** Da lanciare tu, dalla radice
  del repo, sull'ultimo commit del ramo, in PowerShell:

```powershell
$env:FUNCTIONS_DISCOVERY_TIMEOUT=600
firebase deploy --only "functions:statoDelCerchio,functions:consumaDelGiorno,functions:muoviGliEos" --project esoteric-circle
```

- **Build di collaudo** (Android su App Distribution, iPhone su TestFlight
  con Codemagic): parte solo dopo il verde di GitHub sul commit consegnato e
  dopo la pubblicazione delle funzioni. Aspetto il tuo sì.
- **Spese.** Nessuna chiamata a Gemini o a Vertex senza il tuo sì. Le
  simulazioni sul Realme hanno usato il tuo sì di 1,5 euro (circa 300 chiamate
  al massimo, usate al piu' una quarantina). I banchi non sono girati.

## DICHIARAZIONI

- GA.09 e' fatta solo col Viandante: le opzioni dei piani non sono provate.
- La simulazione sul Realme e' di poco anteriore alle ultime cure delle
  risposte (`8ba00294`); la verifica sul codice finale e' nella sezione
  seguente.
- Guardie nel registro: da 842 a 879. `ordine_ga_guard` e' nata rossa per
  costruzione.
