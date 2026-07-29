# ESITO dell'ORDINE ENTITLEMENT, TESTI E ARCHIVIO

## Dichiarazione, scritta prima di toccare il codice

Ho letto i sette punti e i loro chiamanti prima di stimare. Tre cose le ho
gia' viste a occhio e le dichiaro adesso, perche' cambiano la stima.

**Il contatore delle domande esiste** (`QuestionAllowance`) **ed e' usato da
una sola strada**: `ask_maestri_screen`. La chat dei Maestri, che e' l'altra
strada per fare una domanda, non lo nomina mai. Se il sospetto di V1 e'
fondato, la causa e' questa, ed e' la stessa forma del difetto del nome
minuscolo di due ordini fa: una regola messa in una porta mentre le porte
sono due.

**La matrice dice "1 al giorno" per il Viandante, il codice dice
`freeDailyLimit = 3`.** Il numero e' scritto in due posti, quindi V4 e' quasi
certamente rosso; la correzione non e' cambiare il 3 in 1: e' far leggere al
contatore la matrice, altrimenti fra sei mesi divergono di nuovo.

**`premiumUnlocked` compare quattro volte**, tutte e quattro dentro il file
che lo definisce. Nessuno lo passa dall'esterno, quindi V3 e' quasi
certamente rosso.

**La stima, voce per voce.**

- **V1, V2, V3, V4, V5**: piene. Il bersaglio e' preciso, il test e'
  scrivibile, la correzione e' contenuta.
- **V7**: piena, ma costa piu' delle altre. I contatori per sinastria e
  tarocchi non esistono: `ArchetypeAllowance` e `QuestionAllowance` sono gli
  unici, quindi qui c'e' da costruire, non da correggere. Se il tempo stringe
  la versione semplice e' un contatore solo, condiviso, invece di due
  specializzati.
- **V6**: e' la piu' vaga delle sette, ed e' l'unica che dichiaro a rischio.
  Chiede coerenza fra quattro fonti (`feature_catalog`, `function_shelf`,
  `art_catalog`, `stato_funzioni.json`) piu' il fatto che una schermata legga
  davvero il catalogo. La parte misurabile, cioe' la coerenza fra le fonti, la
  chiudo di sicuro. Se far governare il catalogo a una schermata si rivela un
  rifacimento, consegno la versione semplice: il lucchetto sulla coerenza piu'
  una schermata sola che lo legge, dichiarando quali altre restano fuori.

**Parte 2**: tre correzioni piccole, tutte piene. T1 porta con se' una ricerca
in tutta l'app, che e' la parte piu' lunga delle tre.

**Parte 3**: tutte e tre piene. S1 e S2 sono configurazione di Gradle e si
verificano aprendo l'archivio, che e' il modo giusto e l'ho gia' usato. S3
richiede di guardare i tre volti dopo la conversione: se un volto perde
qualita' torno indietro e lo dico.

**Il numero che mi aspetto.** 14,5 piu' 14,6 piu' circa 13 di risparmio sugli
avatar fanno circa 42 MB, quindi da 233,2 a circa 191. Sotto i duecento, senza
margine largo: se la conversione rende meno del previsto lo dichiaro col
numero vero invece di inseguire la soglia con altre mosse non chieste.

## Parte 1, le sette voci sui soldi

Sette voci, sette test nuovi, **sette rossi prima della correzione**. Nessuna
confutata, quindi nessun test lasciato a guardia senza correzione.

```
V1 | rosso prima, verde dopo | maestro_chat_controller.dart:97  | Con Viandante oltre il limite la chat rifiuta
V2 | rosso prima, verde dopo | maestro_chat_controller.dart:205 | Con Viandante nessuna scrittura, con Iniziato si'
V3 | rosso prima, verde dopo | oroscopo_screen.dart:742         | Nessuno passa mai premiumUnlocked
V4 | rosso prima, verde dopo | question_allowance.dart:31       | Il limite imposto coincide con quello promesso
V5 | rosso prima, verde dopo | plan_catalog.dart, promessa      | Per ogni piano l'invito dichiara il limite vero
V6 | rosso prima, verde dopo | feature_catalog.dart:57          | Il catalogo dei flag e il manifest dicono la stessa cosa
V7 | rosso prima, verde dopo | ritual_allowance.dart, nuovo     | Il contatore rifiuta oltre soglia e si azzera col giorno
```

### Il colore prima, coi numeri veri

- **V4**: `Expected: <1>, Actual: <3>`, con la riga che lo spiega: il piano
  free promette "1 al giorno" e impone 3.
- **V1**: `la chat ha chiamato l'AI 3 volte con un limite di 1`.
- **V2**: `Expected: <0>, Actual: <1>`, cioe' una scrittura di memoria per chi
  non l'ha comprata.
- **V3**: `oroscopo_screen.dart monta il selettore senza dire se la persona ha
  pagato`.
- **V5**: l'invito diceva "senza limiti" anche per l'Iniziato, che di domande
  ne ha cinque.
- **V6**: `face_constellation: manifest true, catalogo comingSoon`, piu' sei
  funzioni dello scaffale che il catalogo non conosceva affatto.
- **V7**: il contatore non esisteva, quindi la quarta sinastria passava.

### La forma comune di V1, V2, V4, V5

Quattro voci su sette hanno la stessa causa: **un numero, o una regola,
scritto in due posti**. La matrice prometteva una cosa e il codice ne imponeva
un'altra, mentre a divergere era sempre quello che contava davvero.

La correzione non e' stata allineare i numeri: e' stata togliere il secondo
posto. `PlanCatalog.limiteGiornaliero` legge la riga della matrice e la
interpreta, `haMemoria` e `haProfondita` fanno lo stesso per i diritti,
`promessaDomande` costruisce la frase dal numero vero. Da adesso il numero
esiste in un punto solo, cioe' la promessa fatta alla persona.

**V1 in particolare** era la stessa forma del nome minuscolo di due ordini fa:
una regola messa in una porta mentre le porte erano due. Il contatore delle
domande esisteva ed era corretto, solo che lo consultava la schermata "Chiedi"
e non la chat. Chi apriva la chat aveva domande infinite con qualunque piano.

**V6** e' stata chiusa in versione piena e in modo che non torni: il catalogo
dei flag non elenca piu' a mano le funzioni, le DERIVA dallo scaffale del
Santuario per tutte quelle che non ha una definizione propria. Erano sei su
dieci a mancare, quindi lo strato dei flag non conosceva piu' della meta' di
cio' che l'app mostra.

### Una cosa che ho cambiato nel test, con la ragione

Il test di V1 nella prima stesura cercava la parola "limite" nella risposta
del Maestro. Era una formulazione mia sbagliata: legava un criterio economico
a una scelta redazionale, quindi per farlo passare avrei dovuto peggiorare la frase
mostrata alla persona. L'ho sostituito con una misura del comportamento, cioe'
che oltre soglia risponda il Maestro e non l'AI, scrivendolo nel commento
del test. Il conteggio delle chiamate, che e' il criterio vero, non e' stato
toccato.

## Parte 2, i tre testi

**T1, l'accento.** `LA TUA GUIDA TI DIRA'` diceva l'apostrofo al posto della A
accentata: adesso e' `DIRÀ`. La ricerca in tutta l'app, chiesta dall'ordine,
l'ho fatta con un lucchetto che guarda le stringhe e salta i commenti, dove
l'apostrofo e' una convenzione voluta di questo repository. Ha trovato **altre
otto occorrenze** in due file, corrette con 25 sostituzioni:
`guide_animal_corpus.dart` (gia', verita', piu') e `daily_strip.dart` (gia').

**T2, il vocativo.** Era la parola sbagliata due volte: il vocativo e' il caso
con cui si chiama qualcuno, non il genere, e comunque nessuno sa cosa significhi.
Adesso: "Dimmi come rivolgermi a te: accorderemo ogni frase al genere che
preferisci."

**T3, il vuoto.** L'impalcatura dei passi teneva il visivo in 190 px per
tutti, ed era una costante buona per una data, sbagliata per delle onde.
Adesso l'altezza la decide il passo, e quello del genere ne chiede 250.

## Parte 3, l'archivio

Le tre mosse, verificate DENTRO l'archivio e non nella configurazione.

- **S1, il validatore Vulkan**: `presenti: NESSUNO`. Erano 14,5 MB.
- **S2, le architetture**: `arm64-v8a 44,1 MB`, `armeabi-v7a 5,2 MB`,
  `x86_64 ASSENTE`, `x86 ASSENTE`.

  Qui l'ordine aveva ragione: la prima correzione non e' bastata:
  `abiFilters` governa cio' che si COMPILA, mentre le librerie dei plugin
  arrivano gia' compilate dentro gli AAR e vengono solo copiate. Ho verificato
  aprendo l'archivio, x86_64 c'era ancora coi suoi 9,4 MB, quindi ho aggiunto
  l'esclusione esplicita in `packaging.jniLibs`. Senza guardare dentro avrei
  dichiarato chiusa una voce aperta.
- **S3, gli avatar**: da 16,6 MB a 1,64 MB, il 90 per cento in meno per tutti
  e tre.

  **Guardati, come chiede l'ordine.** Il primo confronto sembrava mostrare
  bordi frastagliati nel WebP, ed era un artefatto del MIO confronto: avevo
  scartato il canale alpha invece di comporlo. Rifatto componendo i due su
  fondo cosmo, come fa l'app, i bordi sono identici, i volti pure: occhi,
  capelli, gioielli, barba, nessuna perdita visibile. Gli originali di Mauro
  restano in `brand_assets/` e non entrano piu' nel pacchetto.

### Il peso finale, col numero vero

**203,7 MB**, contro i 233,2 di partenza: **29,5 MB in meno**.

**Sotto i duecento NON ci sono arrivato: mancano 3,7 MB.** La ragione, in
numeri: la somma delle voci dell'archivio e' 194,0 MB, quindi il contenuto e'
sotto la soglia; il file su disco pesa 203,7 perche' le librerie native stanno
non compresse e allineate in memoria, e quell'allineamento aggiunge 9,7 MB di
riempimento. Non e' contenuto, e' spaziatura, comunque byte che il
telefono scarica.

Le tre mosse dell'ordine hanno reso quello che dovevano; la mia stima era 191,
quindi ho sbagliato di 12,7 MB proprio perche' non avevo considerato il
riempimento. Non ho aggiunto mosse non chieste per inseguire la soglia.
