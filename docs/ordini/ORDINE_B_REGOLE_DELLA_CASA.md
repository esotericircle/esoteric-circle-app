# ORDINE B, le regole della casa

Emesso dall'Architetto in Cowork la notte del 28 luglio 2026. Secondo ordine della coda in `docs/ordini/CODA.md`. **Non aprirlo prima di aver chiuso `ORDINE_CORRENTE.md`.**

## Che cosa è

Otto regole delle Linee Guida UX Trasversali che oggi sono violate. Valgono su tutta l'app, quindi si correggono **una volta sola**, non dentro le singole funzionalità. Correggerle qui significa che quando Mauro revisionerà una funzionalità alla volta ne troverà molte già a posto.

Ogni voce porta la citazione testuale del documento che la prescrive. Il dettaglio completo sta in `claude/Registro_Prescrizioni_Disattese_Esoteric_Circle` nel Project, voci da P15 a P23.

---

## B1. Il disclaimer torna a mostrarsi una volta sola

**Prescrizione**, Linee Guida sezione 20: "Disclaimer: mostrato una sola volta a onboarding e registrazione, mai su ogni card o responso (accessibile in info e privacy)".

**Oggi**: l'Oroscopo lo stampa in fondo a ogni responso, la Stesa pure, ed è ripetuto in ogni arte, in ogni soglia, in ogni anticipo.

Mostralo una volta all'onboarding, poi rendilo raggiungibile dalle informazioni e dalla privacy. Toglilo da tutti i responsi. Questa da sola alleggerisce ogni schermata dell'app.

## B2. Il punto interrogativo con Fonti e metodo, su tutti i responsi

**Prescrizione**, Linee Guida sezione 15: "Ogni responso espone un piccolo punto interrogativo discreto che, al tap, apre una nota brevissima sulla tradizione, arte o metodo usato per quel calcolo".

**Oggi**: esiste in Runa del Tramonto, Test Archetipo, Costellazione del Viso, Animale Guida, Rune e Rito del Sogno. Manca proprio nelle due headline di Medora, cioè Oroscopo Personalizzato e Stesa di Tarocchi.

Un solo componente condiviso, usato ovunque ci sia un responso. Il Briefing Operativo lo chiama "convenzione trasversale gia dalla Demo" e cita le fonti da nominare: "Jones per il volto, core shamanism per l Animale Guida, effemeridi svizzere per la carta natale".

## B3. Ogni chiusura lascia una ragione per tornare

**Prescrizione**, Linee Guida sezione 12.1: "Ogni schermata che chiude un'esperienza lascia all'utente una ragione dichiarata per tornare. La ragione è esplicita e appartiene a uno dei tre tipi seguenti".

**Oggi**: Oroscopo e Stesa chiudono con Condividi più disclaimer. Nessun appuntamento con un'ora, nessuna attesa che matura, nessun filo narrativo.

Applica i tre tipi previsti dal documento a ogni schermata che chiude una esperienza. È la carenza che l'audit esperienziale misura come 3,5 su 10 alla domanda "perché tornare domani", quindi vale più di quanto costi.

## B4. Il catalogo dei visivi, e mai lo stesso grafico due volte

**Prescrizione**, Linee Guida regola 21: "Ogni responso ha prima un segno grafico a tema e poi poco testo, e non si ripete mai lo stesso tipo di grafico", più "Per ogni funzione si sceglie la sua rappresentazione a tema, e si tiene un catalogo per non ripetersi".

**Oggi**: le quattro schede dell'Oroscopo usano lo stesso contatore a cinque icone, con la sola icona che cambia. Le quattro forme vive che erano state costruite, anello, orbite, scia, quadrifoglio, sono state sostituite. Il catalogo non esiste, quindi la regola non è verificabile.

Costruisci il catalogo come dato, non come commento: ogni funzione dichiara quale rappresentazione usa, e un test fallisce se due funzioni ne dichiarano la stessa. Poi ripristina le quattro forme distinte dell'Oroscopo. Per la scheda Generale, la sezione 10 prescrive l'anello: "Favorevolezza o intensita di una giornata o di un area: anello che si riempie con percentuale al centro".

## B5. Un controllo o è collegato o è dichiarato

**Prescrizione**, Linee Guida sezione 4.1: "Un controllo interattivo, interruttore, selettore, tendina o cursore che sia, o è collegato a un effetto reale sul risultato, oppure è presentato in uno degli stati non attivi previsti sopra, Coming soon o Premium bloccata".

**Tre violazioni accertate**:
- l'interruttore delle carte rovesciate nella Stesa, pienamente attivo, che non tocca il pescaggio. `TarotSpread.draw` non accetta alcun parametro sui rovesci e applica sempre `reversedChance` a 0,30. Il difetto D05 del Registro.
- l'interruttore Sottotitoli in Impostazioni, con aspetto di comando attivo e sottotitolo "Attivi di default, in attesa della voce", senza badge né velo.
- il selettore di profondità della Stesa, che porta il valore e non lo consuma.

Per ciascuno: o si collega, oppure si dichiara. Non esiste la terza possibilità. Poi aggiungi un test che scandagli le schermate e fallisca se trova un controllo abilitato il cui valore non raggiunge alcun consumatore.

## B6. L'aiuto dopo tre secondi, su tutte le funzioni

**Prescrizione**, Linee Guida sezione 24: "dopo tre secondi di inattivita' compaiono due silhouette grandi e senza sfondo, un viso di profilo che soffia con labbra unite e guance gonfie, e una mano con un solo dito indice dritto che scorre da sinistra a destra".

**Emendamento**, `claude/Regole_Inviti_e_Affordance_Esoteric_Circle`: "In revisione di ogni funzionalita' si verifica se una silhouette esistente puo' diventare un fantasma, e se puo' si sostituisce".

**Oggi**: esiste solo nella Runa del Tramonto e nella home. Nella Stesa lo scuotimento offre la sola riga statica. Lo stesso in Estrazione Rune, Rito del Sogno, Costellazione del Viso.

Un solo componente condiviso per la scala dell'aiuto, applicato a ogni funzione che chiede un gesto. Dove il gesto ha una geometria sullo schermo si usa il fantasma del gesto, dove non ce l'ha, cioè soffio, scuotimento, giroscopio e fotocamera, si usa la silhouette.

## B7. Il testo narrato è espandibile

**Prescrizione**, Linee Guida sezione 2: "Espandibile: si mostra un estratto e si apre il resto al tocco, per non spaventare chi non ama leggere".

**Oggi**: né l'Oroscopo né la Stesa mostrano un estratto apribile, il testo è stampato per intero in colonna.

Un solo componente condiviso, usato in ogni responso testuale lungo.

## B8. Suono e vibrazione dietro un solo interruttore

**Prescrizione**, Linee Guida sezione 6: "Dove una funzione usa suono e vibrazione, per esempio la stesa, i due stanno sempre dietro un unico comando in app, un pulsante Suono e Muto che li governa insieme".

**Oggi**: il comando esiste solo dentro la Stesa come stato locale. L'aptica dell'incisione della Runa e quella del tamburo dell'Animale Guida non stanno dietro alcun interruttore, e le Impostazioni non ne offrono uno globale.

Un interruttore globale nelle Impostazioni che governa suono e vibrazione insieme, che ogni funzione rispetta, col comando locale che resta dov'è e riflette lo stato globale.

---

## Fuori scope di questo ordine

Non toccare la profondità Media, il gating con gli Eos e i deep link: dipendono da funzioni che ancora non esistono e vanno affrontati insieme a quelle. Non toccare i minimi tipografici: Mauro ha deciso il 28 luglio che si correggono funzionalità per funzionalità, non in blocco.

## Criteri di accettazione, in numeri

- Il disclaimer compare **una volta sola** nell'intero percorso dell'utente. Un test attraversa cinque schermate di responso e verifica zero occorrenze.
- Il punto interrogativo con Fonti e metodo compare su **tutti** i responsi, contati e verificati uno per uno. Zero responsi senza.
- Ogni schermata che chiude una esperienza espone una ragione dichiarata per tornare, di uno dei tre tipi previsti. Un test le conta e fallisce se ne trova una senza.
- Il catalogo dei visivi esiste come dato, e un test fallisce se due funzioni dichiarano la stessa rappresentazione.
- Le quattro schede dell'Oroscopo usano quattro forme diverse, di cui l'anello sulla Generale.
- Zero controlli abilitati il cui valore non raggiunge un consumatore. Un test lo verifica sull'intero albero.
- Ogni funzione che chiede un gesto ha l'aiuto dopo tre secondi. Un test le conta.
- Ogni responso testuale più lungo di una soglia dichiarata è espandibile.
- Un solo interruttore globale governa suono e vibrazione, e ogni punto che vibra o suona lo rispetta. Un test lo verifica su tre funzioni diverse.
- Suite intera verde, `flutter analyze` pulito, zero nuovi avvisi, integrità dell'APK verde.

## Alla fine

Costruisci e distribuisci come nell'ordine precedente, poi scrivi l'esito in `docs/ordini/ESITO_B.md` con ogni criterio e il suo valore misurato. Poi apri il prossimo ordine della coda.

Niente trattino lungo. Niente proposizione dopo la virgola che inizia con la lettera e.
