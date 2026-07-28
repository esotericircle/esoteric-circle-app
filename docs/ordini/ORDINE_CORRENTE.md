# ORDINE C, gli angeli entrano in scena

Emesso dall'Architetto in Cowork il 29 luglio 2026. Sostituisce l'ordine precedente, che e' chiuso per quanto dichiarato.

## Perche' questo ordine ha piu' voci

La regola resta un ordine un oggetto, e qui l'oggetto e' uno: **il contenuto degli angeli che arriva a schermo**. Le voci sono tre e sono tutte piccole, tutte dello stesso oggetto, tutte a basso rischio. Le due voci di build in fondo sono separate apposta e vanno per ultime: se una si rivela non banale, la lasci e lo scrivi, senza che blocchi il resto.

## Dichiarazione all'inizio, obbligatoria

Prima di scrivere codice, stima e scrivi in `docs/ordini/ESITO_C.md` se chiudi per intero e fin dove arrivi, con la ragione in numeri. Il 29 luglio questa regola ha funzionato al primo tentativo, quindi resta.

---

## C1. Il corpus arriva nelle carte

`docs/corpus/angeli.md` e' sul disco dal 29 luglio, 206 KB, tutti e settantadue gli angeli, nove cori su nove. Il tuo catalogo oggi nasce dagli stem degli asset e non lo legge: virtu', salmo e archi di gradi sono nel file e non nell'app.

Modella il corpus e collegalo. Ogni carta dell'angelo mostra: nome, numero, coro, arcangelo del coro, arco di gradi col segno, la chiave di lettura, e il salmo con la sua numerazione. Sparisce la riga che dichiara che quello strato arrivera'.

**Leggi PRIMA la politica di pubblicazione in testa al file.** Non e' un preambolo, e' un vincolo, e i verificatori l'hanno prodotta guardando la tradizione reale. In sintesi, e il file ha l'elenco per numero d'angelo:

- Fuori tutto cio' che riguarda guarigione, salute, malattia, fertilita', sterilita', longevita', vista, udito, olfatto, medicina.
- Fuori ogni promessa di esito: protezione dalle armi, vittoria, liberazione dei prigionieri in senso letterale, distruzione dei nemici, tesori, denaro, promozioni, pietra filosofale, panacea.
- Fuori i nomi delle entita' avverse e le corrispondenze goetiche.
- Fuori i nomi alternativi non attestati: in dubbio si pubblica il solo nome principale.
- Le date del custode non si mostrano come verita' astronomica: sono convenzione. L'angelo si determina dalla longitudine solare reale, come hai gia' fatto.
- La chiave di lettura e l'ombra sono scritte in redazione, non sono tradizione: si mostrano come voce del Maestro e non accanto all'elenco delle fonti.

Il campo `confidenza` di ogni angelo dice quanto la fonte regge. Dove e' bassa, mostra meno invece di mostrare male.

Un test verifica che nessuno dei termini vietati compaia nei testi mostrati all'utente. E' il modo per non doverlo ricontrollare a mano ogni volta.

## C2. La tessera degli Angeli mostra tre miniature

Difetto che hai trovato tu guardando, e la diagnosi era giusta: nella carta natale la tessera mostra una miniatura invece di tre, e il test non l'ha colto perche' conta le arti distinte nella schermata dedicata, dove sono tre, non in quella tessera.

Correggi la tessera. Poi correggi il test: deve misurare il numero dove l'utente lo vede, non dove e' comodo misurarlo. Vale come regola generale ed e' finita nel Protocollo Operativo.

## C3. Fonti e metodo sulla schermata degli angeli

Le Linee Guida, sezione 15, prescrivono che "ogni responso espone un piccolo punto interrogativo discreto che, al tap, apre una nota brevissima sulla tradizione, arte o metodo usato per quel calcolo". La schermata degli angeli e' nuova, quindi nasce con la nota invece di doverla ricevere dopo.

Il testo della nota dice tre cose e nient'altro: che sono i settantadue nomi dello Shemhamphorash della tradizione cabalistica; che i tre angeli si ricavano dalla posizione del Sole in archi di cinque gradi, dal giorno e dall'ora di nascita; che le fonti sono repertori che dichiarano di derivare da Lenain e Ambelain, e che le tavole originali non sono state consultate in edizione primaria. Quest'ultima frase e' scomoda ed e' proprio per questo che ci va.

---

## Le due voci di build, per ultime

## C4. L'APK non porta librerie native che non servono

L'APK pesa 25 MiB in piu' della build precedente, e non per il codice: dentro ci sono le librerie native di ML Kit anche per x86_64 e armeabi-v7a. La tua diagnosi e' corretta, `--target-platform android-arm64` filtra le librerie di Flutter, non quelle dei plugin.

Si risolve dichiarando gli ABI nel Gradle, cosi' il filtro vale anche per i plugin. Se la strada si rivela non banale, non insistere: scrivilo nell'esito e passa oltre.

## C5. Il controllo di integrita' guarda anche le librerie native

Hai detto una cosa giusta: `verifica_apk.py` guarda le otto famiglie di asset, non le librerie native, e fa quello per cui e' nato. Estendilo, cosi' il peso ha un guardiano. Deve fallire se nell'archivio compaiono librerie native per ABI diversi da quello dichiarato.

---

## Criteri di accettazione, in numeri

- Tutti e settantadue gli angeli sono modellati nel codice e leggono dal corpus. Un test conta 72.
- Ogni angelo mostra nome, numero, coro, arcangelo, arco di gradi, segno e salmo. Un test verifica i sette campi su un campione di dodici angeli, uno per coro piu' tre.
- Zero occorrenze dei termini vietati nei testi mostrati all'utente. Un test scandaglia le stringhe cercando almeno: guarigione, guarire, malattia, malattie, fertilita', sterilita', longevita', panacea, tesori, nemici, prigionieri, promozione. Il test elenca i termini che cerca, cosi' si puo' allungare.
- La tessera degli Angeli nella carta natale mostra **tre** miniature distinte. Un test le conta nella tessera, non nella schermata dedicata.
- La nota Fonti e metodo esiste sulla schermata degli angeli, con la sua chiave, e contiene la frase sulle edizioni primarie non consultate.
- L'APK non contiene librerie native per ABI diversi da arm64-v8a, oppure l'esito spiega perche' non e' stato possibile.
- Il peso dell'APK non supera quello della build precedente di piu' di 1 MiB, al netto di eventuali asset nuovi, che vanno dichiarati.
- Suite intera verde, `flutter analyze` pulito, zero nuovi avvisi, integrita' verde, numero di versione non inferiore a 2100.

## Autorizzazione

Itera da solo finche' i numeri passano, debug incluso. Non chiedere conferme su scelte interne.

## Alla fine

```
flutter build apk --debug --target-platform android-arm64 --dart-define=APP_CHECK_DEBUG_TOKEN=2f4013f2-e6e7-49b2-a3aa-402f28cd365a
```

```
firebase appdistribution:distribute "build/app/outputs/flutter-apk/app-debug.apk" --app 1:425821975933:android:1b1ca4db8d4df69b940814 --testers "cloud@esotericircle.app" --release-notes "Gli angeli entrano in scena"
```

Esito in `docs/ordini/ESITO_C.md` coi numeri misurati. **Poi fermati**: gli altri ordini li apre l'Architetto.

Niente trattino lungo. Niente virgola prima della "e" congiunzione.
