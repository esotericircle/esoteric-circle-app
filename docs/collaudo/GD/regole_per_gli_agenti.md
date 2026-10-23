# Regole comuni per gli agenti dell'ordine GD (leggerle tutte prima di cominciare)

Progetto: app Flutter Esoteric Circle, tutto in italiano. Testo dell'ordine: `docs/ordini/ORDINE_GD_TESTO.md` nel ramo (copia di `D:\Clienti Roogly\Rituali Cartomanzia\App\ORDINE_GD_Esoteric_Circle.md`). Catture del fondatore: `D:\Clienti Roogly\Rituali Cartomanzia\App\Catture GD\` (guardale con lo strumento Read). Leggi anche `CLAUDE.md` alla radice del repo: le sue regole valgono.

## Punto di partenza e git
- Lavori in una cartella git tua (worktree). PRIMA DI TUTTO esegui `git checkout -B gd-<tuaparte> 02522987d2c2b3182b782dd7161b41ff53ed5ffd` e verifica con `git log --oneline -1` che la testa sia `02522987`. Se il tuo worktree parte da un altro commit, i tuoi commit non si fondono: e' obbligatorio.
- Fai commit sul tuo ramo locale (autore: `git -c user.name="Mauro Battaglia" -c user.email="cloud@esotericircle.app" commit ...`), senza righe di attribuzione. NON spingere mai, non creare rami remoti.
- Tocca SOLO i file della tua parte. Non toccare: `docs/ordini/*MANIFESTO*`, `docs/ordini/RAPPORTO_*`, `docs/STATO_VIVO.md`, `docs/guardie.md`, `CLAUDE.md`, `pubspec.yaml` (se serve un asset nuovo nel pubspec, scrivilo nel tuo resoconto invece di farlo), e i file delle altre parti.

## Vietato (regole fisse dell'ordine)
- Nessuna chiamata a pagamento: niente Gemini, Vertex, banchi, `tool/banchi_col_modello`. Nessuna build (`flutter build`), nessun `firebase deploy`, niente telefono (`adb`): il collaudo sul telefono lo fa la sessione principale.
- Niente dati di produzione.
- La grafica e' dipinta, non disegnata: il codice mostra, ritaglia, sceglie e dissolve immagini e video dipinti esistenti; non disegna figure (CustomPainter di simboli, icone fatte a mano) al posto dei pezzi dipinti. Le barre di un'infografica sono grafica funzionale e si possono disegnare.
- Lingua dei testi a video e dei commenti: italiano con accenti veri nei testi a video, mai il trattino lungo, MAI la virgola prima di "e" o "ed", il tu. Commenti nello stile del codice intorno (densita' e lessico).
- Le barre del titolo restano semitrasparenti (velo `AppTheme.veloDellaBarra`).
- Le funzioni non nominate restano com'erano. Il Calendario lunare non si tocca.

## Le prove (obbligatorio)
- Sul computer fai girare SOLO le prove della tua zona (`flutter test test/<file>_test.dart ...`), mai la suite intera. Su Windows i file sorgente possono restare bloccati da processi: se una scrittura da' "Invalid argument" o "Permission denied", sposta il file (`mv`) e riscrivi il contenuto; poi verifica col grep che il testo nuovo ci sia.
- Ogni voce ha una prova che misura il fatto chiesto (non la sola presenza di un widget). Per ogni prova nuova vale la **Regola A**: rimetti a mano il difetto (o il codice di prima), verifica COL GREP che il difetto sia entrato, fai girare la prova e vedila ROSSA, togli il difetto, rivedila verde. Scrivi ogni innesto con l'esito in `docs/collaudo/GD/regola_a_<tuaparte>.txt` (file, testo innestato, verifica grep, motivo del rosso, tolto). Se il rosso non scatta, cambia la grandezza misurata, mai la soglia.
- **Regola B**: prima di toccare una zona gia' coperta da una prova, falla diventare rossa con un innesto e annotalo nello stesso file.
- Una prova che scorre un insieme di file o elementi dichiara il suo cardinale minimo (`test/cardinale_minimo.dart`, `cardinaleMinimo(...)`); per scorrere i sorgenti di lib usa `test/sorgenti_di_lib.dart` (`sorgentiDiLib()`).
- Prima di consegnare: `flutter analyze` sui file toccati senza problemi, `dart format` solo sui file toccati, e le prove della tua zona verdi (comprese quelle vecchie che tocchi).
- Le prove a video che hanno bisogno di immagini: decodificale con `precacheImage` dentro `tester.runAsync` prima di misurare.

## Il resoconto (obbligatorio)
Alla fine scrivi `docs/collaudo/GD/parte_<tuaparte>.md`, e committalo, con per OGNI voce della tua parte:
- lo stato proposto: CHIUSA (se provata a video nelle prove) oppure APERTA IN ATTESA DI VERIFICA (se si vede solo sul telefono) oppure PREMESSA CADUTA (se un fatto dell'ordine e' falso: dillo col file e la riga);
- `DOMANDA:` la frase del fondatore citata dall'ordine, alla lettera;
- `PROVA:` il percorso di un file che esiste nel repo (la prova o una cattura);
- `MISURA:` numeri col prima e il dopo;
- il PADRE di ogni difetto: l'ordine e la voce che l'hanno causato (cerca con `git log -S` o nei rapporti `docs/ordini/`), oppure PROVENIENZA IGNOTA;
- le scelte che hai preso con la ragione;
- cosa resta da vedere sul telefono (quali schermate catturare e come arrivarci);
- le guardie nuove che hai scritto, dicendo per ciascuna se passa dalla porta comune (`sorgentiDiLib`), se ha un cardinale proprio o se non scopre insiemi;
- eventuali comandi da far eseguire al fondatore (pubblicazione di funzioni del server: mai eseguirla tu).
Poi rispondi con un riassunto breve: lo sha del tuo ultimo commit, il nome del ramo, le voci e il loro stato, i file toccati.
