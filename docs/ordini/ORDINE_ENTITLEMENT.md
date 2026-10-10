# ORDINE ENTITLEMENT per Claude Code, da eseguire DOPO

Emesso dall'Architetto in Cowork il 27 luglio 2026.
Non eseguire finché `docs/ordini/ORDINE_CORRENTE.md` non è chiuso e l'app non è stata vista girare sul telefono.

## Oggetto

Chiudere le sette segnalazioni non verificate su entitlement e percorso a pagamento. Sono le uniche del Registro dei Difetti che producono danno economico diretto: un limite promesso e non imposto è ricavo che non entra, un contenuto premium regalato al gratuito è valore che esce.

Correzione al Registro da tenere presente: la riga che indica "le sette più serie" elenca N19, N20, N21, N23, N24, N25 e N13. È sbagliata. N24 è l'elisione di un articolo nelle Impostazioni, N25 è la dimensione di un carattere in un badge, N13 è una didascalia del Sigillo. Le sette vere sono queste.

## Metodo, non negoziabile

La prova del rosso non si argomenta, si esegue. Per ogni voce, in quest'ordine:

1. Leggi il codice al punto indicato più tutti i suoi chiamanti.
2. Scrivi il test che deve fallire se il sospetto è fondato.
3. Eseguilo PRIMA di correggere. Registra il colore.
4. Rosso significa confermato: correggi, poi rendi verde lo stesso identico test senza riscriverlo per farlo passare.
5. Verde significa confutato: non correggere nulla. Tieni il test come lucchetto.

Un test che passa perché non riesce a misurare vale come rosso.

## Le sette voci

**V1, ex N16.** La chat ignora il limite giornaliero di domande. `lib/features/maestri/chat/maestro_chat_controller.dart:97`. Test: con piano Viandante, inviare più messaggi del limite dichiarato dalla matrice, asserire il rifiuto oltre soglia.

**V2, ex N17.** La memoria dei Maestri, venduta come esclusiva dell'Iniziato, viene distillata anche per il gratuito. `lib/features/maestri/chat/maestro_chat_controller.dart:205`. Test: con Viandante nessuna scrittura sul repository della memoria, con Iniziato sì.

**V3, ex N18.** La profondità Profonda resta col lucchetto anche per chi ha pagato. `lib/features/horoscope/answer_depth.dart:58`. `premiumUnlocked` non è mai portato a true in tutta l'app. Test: con entitlement Iniziato o Illuminato la voce Profonda è selezionabile e non porta al messaggio di blocco.

**V4, ex N20.** La matrice promette al Viandante una domanda al giorno, il codice ne concede tre. `lib/core/entitlement/plan_catalog.dart:214`. Test: il limite letto dalla matrice coincide con quello imposto dal contatore, per tutti e quattro i piani.

**V5, ex N21.** L'invito all'upgrade promette domande senza limiti per qualunque piano. `lib/features/maestri/ask/ask_maestri_screen.dart:113`. Test: per ciascun piano di destinazione il testo mostrato dichiara il limite reale di quel piano.

**V6, ex N22.** Lo strato dei feature flag è istanziato ma non governa nulla, e dichiara la Costellazione del Viso in arrivo mentre altrove è attiva. `lib/core/feature_flags/feature_catalog.dart:57`. Test: almeno una schermata legge davvero il catalogo, più coerenza fra `feature_catalog`, `function_shelf`, `art_catalog` e `stato_funzioni.json` su tutte le voci.

**V7, ex N23.** I limiti di tre sinastrie e una carta al giorno per il Viandante non esistono nel codice. `lib/core/entitlement/plan_catalog.dart:224`. Test: la quarta sinastria e la seconda estrazione nello stesso giorno rituale vengono rifiutate.

## Criteri di accettazione, in numeri

- Sette test nuovi, nessuno saltato.
- Colore di ciascuno PRIMA della correzione dichiarato nel rapporto.
- Zero correzioni su voci risultate verdi.
- Suite verde, `flutter analyze` pulito, zero nuovi avvisi.
- Nessuna soglia scritta due volte: se la matrice dei piani è la fonte, il codice la legge invece di ricopiarla.

## Autorizzazione

Itera da solo finché i numeri passano, debug incluso.

## Come riportare

In `docs/ordini/ESITO_ENTITLEMENT.md`, una riga per voce:

`V1 | rosso prima, verde dopo | file:riga | nome del test`

oppure

`V1 | verde prima | confutato | nome del test lasciato a guardia`

Niente trattino lungo. Niente proposizione dopo la virgola che inizia con la lettera e.
