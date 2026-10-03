# ORDINE E, la Risonanza equilibrata

Emesso dall'Architetto in Cowork il 29 luglio 2026. Sostituisce l'ordine D, che risulta chiuso col commit `3087b56` e le quattro voci verdi in `ESITO_D.md`.

## Prima di tutto, due cose che ti riguardano

**Il push non e' piu' bloccato, e non lo era nemmeno quando lo hai dichiarato.** Verificato sul file: `.git/config` ha un solo remoto, `origin`, il cui indirizzo porta gia' la credenziale, e non c'e' alcun credential helper locale. L'ultimo push e' passato proprio cosi'. Il remoto e' fermo a `6c134de` mentre tu sei a `3087b56` perche' il push non e' stato **tentato**, non perche' sia fallito. Da adesso tentalo sempre, alla fine di ogni ordine, come dice la regola operativa. Se fallisce riporta l'errore testuale invece di dedurre che sia la solita finestra interattiva.

**La consegna invece era davvero bloccata e avevi ragione tu**: `firebase login:list` mostra la sessione ma non vede che il token di aggiornamento e' scaduto. Mauro sta rifacendo il login dal browser. Se al momento della consegna fallisce ancora per autenticazione, scrivilo nell'esito e fermati: non e' una cosa che puoi risolvere.

---

## L'oggetto

Un oggetto solo: **la Risonanza che assegna il Maestro non e' equilibrata, e un Maestro intero e' irraggiungibile.**

Misurato su ventimila carte natali casuali: **Medora 72,2 per cento, Caligo 26,3 per cento, Aura 1,5 per cento.**

Non e' sfortuna, e' strutturale. In `lib/core/astro/resonance.dart` i pesi fissi danno a Medora 11,5 punti di partenza, Sole 3, Luna 1, Mercurio 2, Giove 1, Urano 0,5, Nodo 1, Ascendente 2, Medio Cielo 1, contro i 7,5 di Aura e i 7,5 di Caligo. Chi parte da undici e mezzo vince quasi sempre contro chi parte da sette e mezzo.

**L'aggravante.** Quando la carta natale ripiega su `NatalChart.essential`, che porta il solo Sole, Medora non vince nel settantadue per cento dei casi: vince **sempre**. FreeAstroAPI adesso e' viva, quindi in condizioni normali la carta completa arriva, ma il ripiego resta ogni volta che manca la rete oppure l'ora di nascita.

**Perche' conta piu' di quanto sembri.** La Risonanza e' il momento cerimoniale dell'onboarding, quello in cui l'app dice alla persona quale Maestro l'ha scelta. Se Aura tocca a una persona su sessantasei, la promessa dei tre Maestri viene smentita nel primo minuto di vita dell'utente, e un intero dominio con tutte le sue arti resta di fatto senza pubblico. Il briefing tecnico prescrive espressamente il riequilibrio piu' un test statistico permanente, e stima il lavoro in circa un'ora.

## Cosa deve restare vero dopo la correzione

**Deterministico.** La stessa carta natale deve dare sempre lo stesso Maestro. Non introdurre casualita': una persona che rifa' l'onboarding con gli stessi dati deve ritrovare il suo Maestro.

**Significativo.** L'assegnazione deve continuare a dipendere dalla carta, non diventare una rotazione mascherata. Se il risultato fosse indistinguibile da un sorteggio, avremmo scambiato un difetto con un inganno.

**Onesto sul ripiego.** Con la sola carta essenziale l'informazione e' povera. O si equilibra anche quel caso, oppure la schermata dichiara che l'assegnazione e' provvisoria e si affinera' quando arrivera' l'ora di nascita. Scegli tu la strada e dichiarala.

## Criteri di accettazione, in numeri

- Su un campione di **almeno ventimila** carte natali generate in modo pseudocasuale ma riproducibile da un seme fisso, **nessun Maestro scende sotto il 25 per cento e nessuno supera il 40 per cento**.
- Lo stesso vale sul caso di ripiego con la sola carta essenziale: **nessun Maestro sotto il 20 per cento**. Se scegli invece la strada della dichiarazione provvisoria, questo criterio decade e va sostituito da un test che verifica la presenza di quella dichiarazione a schermo.
- Il test statistico e' **permanente** e vive nella suite, non e' uno script eseguito una volta. Gira con un seme fisso, quindi non e' instabile.
- Determinismo: la stessa carta natale ripetuta cento volte da' cento volte lo stesso Maestro. Un test lo verifica.
- Significativita': su un campione, carte natali molto diverse fra loro non danno tutte lo stesso Maestro, e carte natali quasi identiche danno lo stesso. Un test lo verifica su almeno tre coppie costruite a mano.
- L'esito riporta la distribuzione **prima e dopo**, in percentuale, per tutti e tre i Maestri e per entrambi i casi, carta completa e carta essenziale.
- Suite intera verde, `flutter analyze` pulito, zero nuovi avvisi, integrita' verde, numero di versione non inferiore a 2100.

## Come arrivarci, se ti serve una direzione

Non e' prescrittivo, decidi tu. La via piu' semplice e' normalizzare: ogni Maestro dichiara i suoi indicatori, e il punteggio di ciascuno viene diviso per il massimo teorico del proprio dominio, cosi' si confrontano percentuali invece di punti grezzi e il numero di indicatori smette di essere un vantaggio. La via alternativa e' ribilanciare i pesi a mano finche' i totali teorici coincidono, che pero' e' fragile: basta aggiungere un indicatore domani e si rompe di nuovo. Se scegli la seconda, il test permanente diventa ancora piu' necessario.

## Autorizzazione

Itera da solo finche' i numeri passano, debug incluso. Sei autorizzato a cambiare i pesi, la formula e la forma dei dati, purche' determinismo e significativita' restino veri e la suite resti verde.

## Alla fine

Push, sempre. Poi:

```
flutter build apk --debug --target-platform android-arm64 --dart-define=APP_CHECK_DEBUG_TOKEN=2f4013f2-e6e7-49b2-a3aa-402f28cd365a
```

```
firebase appdistribution:distribute "build/app/outputs/flutter-apk/app-debug.apk" --app 1:425821975933:android:1b1ca4db8d4df69b940814 --testers "cloud@esotericircle.app" --release-notes "Risonanza equilibrata"
```

Esito in `docs/ordini/ESITO_E.md`, con le distribuzioni prima e dopo in percentuale. **Poi fermati.**

Niente trattino lungo. Mai la virgola prima della "e" congiunzione.
