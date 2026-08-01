# ESITO: I MAESTRI PARLANO DAVVERO

## Prima di tutto: il margine e' finito, e non ho aperto niente a meta'

Questa coda arriva dopo cinque voci gia' chiuse e consegnate nella stessa
sessione, dalla 2123 alla 2127. **Il contesto residuo non basta per la voce 1**,
che e' un lavoro da sessione intera: una Cloud Function nuova, tre prompt di
sistema, il contesto della persona, il tetto in uscita, e le prove di tutto
questo.

**Non ho iniziato quello che non potevo finire ne' verificare.** Aprire la
Cloud Function e lasciarla a meta' vorrebbe dire consegnare a suite rossa, che
l'ordine vieta, oppure consegnare codice non provato, che e' peggio.

Quello che ho fatto e' la **RICOGNIZIONE**, che non e' un ripiego: chi riprende
questa coda parte da qui invece che dal punto in cui sono partito io, ed evita
di riscrivere quello che c'e' gia'.

## Voce 1, LA CHAT CON GEMINI: **il ponte esiste gia', e va verificato prima di rifarlo**

**L'ordine dice che la chat non funziona: la prima cosa da stabilire e' perche',
perche' il collegamento a Gemini c'e' gia'.**

In `lib/services/ai/firebase_maestro_ai_provider.dart` sono gia' dichiarati:

| cosa | valore |
|---|---|
| regione Vertex | `europe-west1`, come chiede l'ordine |
| modello chat | `gemini-2.5-flash` |
| modello risposta breve | `gemini-2.5-flash-lite` |
| modello risposta profonda | `gemini-2.5-flash` |
| tetto breve | 260 token |
| tetto profondo | 780 token |
| pensiero, breve | 0 |
| pensiero, profondo | 512 |
| finestra di storia | 20 messaggi |

E in `lib/services/ai/maestro_persona.dart` c'e' gia' `systemInstruction`, cioe'
l'ossatura delle personalita'.

**Quindi la voce 1 non e' "collegare Gemini", e':**
1. **capire perche' la chat non risponde** (App Check? entitlement? un errore
   inghiottito da uno dei quattro `catch (_)` di
   `maestro_chat_controller.dart`, che nascondono l'errore vero: sono il primo
   posto dove guardare);
2. decidere se il ponte deve passare da una Cloud Function come chiede l'ordine.
   **Questa e' una decisione, e la dichiaro invece di prenderla da solo**: il
   provider attuale usa l'SDK Firebase AI dal client, che NON espone chiavi
   (l'autenticazione e' Firebase piu' App Check, non una chiave in chiaro).
   L'ordine chiede la Cloud Function per tenere la chiave sul server, ma qui una
   chiave nell'app non c'e'. Spostare tutto su callable ha altri vantaggi veri,
   il controllo del costo lato server e il rate limiting, e va deciso per quelli.
3. i tre prompt distinti, il contesto della persona, il tetto a 180 parole.

**I tetti attuali, 260 e 780 token, non corrispondono a 180 parole**: 180 parole
italiane stanno intorno ai 300 token. Il tetto profondo va rivisto, oppure va
dichiarato perche' resta piu' alto.

## Voci 2, 3, 4 e 5: **non aperte**

- **2, la chat non deve sembrare una chat.** Dipende dalla 1: l'apertura del
  Maestro e le tre vie si compongono in locale dai dati, quindi si possono fare
  anche senza Gemini, ma metterle davanti a una chat che non risponde
  peggiorerebbe la cosa invece di migliorarla.
- **3, il costo.** Stato attuale accertato: **modello giusto al task giusto
  ATTIVO** (Flash e Flash-Lite, mai il modello grande); **tetto in uscita
  ATTIVO** (260 e 780); **niente ricerca web e niente immagini ATTIVO** (il
  provider non le chiede); **cache del contesto NON ATTIVA**, non c'e' traccia
  di context caching sui prompt di sistema; **la chat non si pre-genera
  ATTIVO**, non esiste catalogo di frasi per la chat.
- **4, l'oroscopo.** Confermato: usa `hash FNV` e non guarda transiti, ed e'
  scritto nella memoria di progetto. La callable `natalChart` c'e' e risponde.
- **5, le rune vergini.** Generazione di immagini, non codice.

## Voce 4e, i TAROCCHI usano l'AI?

**Non verificato**, e non lo scrivo per intuizione. Va guardato in
`lib/core/tarot/` e in `maestro_oracle.dart` prima di dire si' o no.

## L'appendice, la Luna velata

**Non fatta.** Sta gia' in RIPRESA.md dalla 2127, dichiarata li' come voce a se'.

## Cosa NON e' cambiato nel codice

Niente. Questo giro consegna documenti, non software: nessuna build nuova,
perche' non c'e' niente di nuovo da provare sul telefono. **La 2127 resta
l'ultima build valida.**
