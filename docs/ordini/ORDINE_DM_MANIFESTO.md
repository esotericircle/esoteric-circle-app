# ORDINE DM, LA PREDISPOSIZIONE MULTILINGUA

**Sigla:** DM. **Data:** 16 settembre 2026. **Ramo:**
`claude/esoteric-circle-master-order-e798aj`. Parte dal commit `6f9e42c9`,
con gli ordini CODEMAGIC1 e DR chiusi.

**L'app e' predisposta al multilingua, e non e' tradotta.** Domani una lingua
nuova si deve poter aggiungere senza riaprire seicento file. Oggi non entra
nessuna traduzione che non serva a provare che l'impalcatura regge.

VOCI_TOTALI: 7
VOCI_CHIUSE: 7
VOCI_APERTE: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
VOCI_FERMATE_SU_PREMESSA_FALSA: 0

Il rapporto sta in `docs/ordini/RAPPORTO_ORDINE_DM.md`.

---

## I FATTI, RIMISURATI

**Regola DM.00.A**: ogni numero dell'ordine e' stato rimisurato. Dove il mio
diverge sta scritto qui accanto, **col metodo di tutti e due**.

**E il metodo conta piu' del numero.** L'ordine avverte di diffidare dei
conteggi fatti con una ricerca testuale, *"un commento e una citazione dentro
un testo somigliano a una riga di codice e non lo sono"*. Per questo le misure
sulle stringhe non le ha prese `grep`: le ha prese una macchina a stati che
cammina sul sorgente e sa in che cosa si trova, e distingue **codice,
commento e stringa**, con le stringhe grezze, quelle a tre virgolette, le
sequenze di fuga e l'interpolazione `${...}`, che dentro una stringa e'
codice. Il conto fatto col solo `grep` sulla parola *"italiano"* avrebbe dato
**centoquarantotto** righe: centosei stanno nei commenti e non istruiscono
nessuno.

| premessa | l'ordine dice | la mia misura | esito |
|---|---|---|---|
| file dart in lib | 633 | **633 al commit `bc81dcde`**, contati con `git ls-tree -r`. Oggi sono **638**, e i cinque in piu' li ho scritti io con l'ordine DR | **VERA** |
| `app_strings.dart` dichiara nove chiavi | 9 | **9**: due in `_nav`, sette in `_functions` | **VERA** |
| ed e' chiamato da due file di lib | 2 | **uno solo lo chiama**, `lib/features/shell/vie_del_cerchio.dart`. I file che lo NOMINANO sono due, ma il secondo e' il file stesso. **E c'e' di peggio, che l'ordine non dice**: `functionTitle`, cioe' **sette chiavi su nove**, non lo chiama nessuno in `lib`, solo una prova | **DIVERGE, e in peggio** |
| niente `flutter_localizations` e niente `intl`, nemmeno nel lock | assente | **vera**: nessuna delle due nel `pubspec.yaml`, e `intl` non compare in nessuna riga di `pubspec.lock` | **VERA** |
| nessun `localizationsDelegates` e nessun `supportedLocales` in lib | zero | **zero**, cercati su tutto `lib` | **VERA** |
| i tre punti dove si vede: `showDatePicker` a `dati_di_nascita_screen.dart` riga 194, a `i_pezzi_del_sigillo.dart` riga 146, `showTimePicker` a `notifiche_screen.dart` riga 189 | tre righe | **vera, e sono esattamente tre in tutto `lib`**. Le righe 146 e 189 combaciano al numero; la prima oggi e' la **218** perche' l'ordine DR ha allungato quel file, e al commit `bc81dcde` era la 194 | **VERA** |
| le stringhe rivolte alla persona sono 7.559, di cui 5.757 in core, 1.408 in features, 50 in design_system, 343 in services | 7.559 | **dipende da dove si taglia, e il taglio e' un giudizio, non un fatto.** Con la rete "almeno due parole": **10.245** (7.757 core, 1.976 features, 77 design_system, 433 services). Con la rete "frase con accento o punteggiatura di frase": **6.253** (4.754, 1.077, 47, 374). Il numero dell'ordine sta fra le due. **Cio' che non cambia con nessuna rete e' la forma**: circa tre quarti in `core`, un quinto in `features`, una manciata altrove | **VERA NELL'ORDINE DI GRANDEZZA E NELLA FORMA** |
| le righe che impongono l'italiano al modello sono otto, in tre file | 8 in 3 | **nove in quattro**. I cinque di `maestro_persona.dart` (righe 36, 532, 550, 583, 584) e i due di `il_sigillo_dal_modello.dart` e l'uno di `il_segno_dell_animale.dart` ci sono tutti. **Ma ce n'e' un quarto che l'ordine non nomina**: `lib/core/viaggio/la_scena_dal_modello.dart` riga 342, *"- Italiano con gli accenti veri. Niente trattino lungo."*, dentro il prompt della scena del Viaggio | **DIVERGE, e in peggio** |
| le due occorrenze in `angel_lore.dart` sono citazioni di salmi | non c'entrano | **vera, e sono dieci, non due**: dieci stringhe di quel file nominano le Bibbie italiane per dire in quale numerazione sta un salmo. Nessuna e' un'istruzione | **VERA, e piu' larga** |
| la marca del genere: 29 file portano marche | 29 | **29**, e le marche sono **103**. Contate riconoscendo la forma `[a|b|c]` **dentro le stringhe** e non nei commenti | **VERA** |
| e 44 toccano il meccanismo | 44 | **53** con la mia rete, che prende chi nomina `LaMarcaDelGenere` **oppure** `CourtesyForm`. Con la sola `LaMarcaDelGenere` il numero scende: la differenza e' quale delle due porte si conta | **DIVERGE PER METODO** |
| dentro c'e' gia' `LinguaSenzaGenere` | esiste | **vera** | **VERA** |
| `LaMarcaDelGenere.lingua` alla riga 125 e' inizializzato a `LinguaItaliana` e nessun file di lib lo scrive | mai scritto | **vera**: cercata ogni assegnazione in `lib`, non ce n'e' nessuna | **VERA** |
| la tavola dei dodici mesi e' scritta a mano in 12 file | 12 | **12 file contengono i dodici nomi dei mesi in stringhe**, e uno dei dodici e' `data_italiana.dart`, cioe' la porta comune. Quindi le tavole **a mano** sono **undici** | **VERA, con una precisazione** |
| e `data_italiana.dart` e' usata da 7 | 7 | **sei file la importano**, piu' se stessa fa sette. Stesso modo di contare di `app_strings` | **VERA, contando il file stesso** |
| `toStringAsFixed` compare in 12 file | 12 | **12** | **VERA** |
| `test/sorgenti_di_lib.dart` e' usata da 132 file di prova | 132 | **132** | **VERA** |
| `test/localization_test.dart` scrive `AppStrings.languageCode` in quattro punti | 4 | **4** | **VERA** |

---

## IL RISCHIO DEL PUBSPEC, GUARDATO PRIMA DI TOCCARLO

L'ordine chiede la risoluzione a secco prima di muovere una riga, perche' le
dipendenze Firebase sono fissate senza caret: il commento alle righe 36-43 del
`pubspec.yaml` dice che le patch successive estendono una classe che il
platform interface 7.1.0 non ha, e **con quelle l'app non compila**.

**Il piano, letto con `dart pub add --dry-run intl`, senza toccare nessun
file** (verificato dopo con `diff` che `pubspec.yaml` e `pubspec.lock` erano
byte per byte quelli di prima):

```
Resolving dependencies...
+ intl 0.20.3
Would change 1 dependency.
```

**Una sola dipendenza si muove, ed e' quella che si sta aggiungendo.** Nessun
pacchetto `firebase_*` e nessun `cloud_*` compare fra i cambiamenti. Le
novanta e passa righe *"X available"* che il comando stampa sono l'elenco di
cio' che **esiste piu' nuovo**, non di cio' che il risolutore vuole muovere:
confonderle col piano sarebbe l'errore che questo controllo esiste per
evitare.

---

## LE VOCI

- **DM.01**, la lingua e' un dato solo, e si ricorda fra un avvio e l'altro.
  **CHIUSA**
- **DM.02**, i widget di sistema parlano la lingua giusta, e i due selettori
  smettono di essere in inglese. **CHIUSA**
- **DM.03**, il separatore decimale segue la lingua: in italiano la virgola.
  **CHIUSA**
- **DM.04**, la lingua della risposta del modello e' un parametro, non una
  riga cablata. **CHIUSA**
- **DM.05**, la marca del genere sa che esistono lingue senza genere, e
  qualcuno glielo dice. **CHIUSA**
- **DM.06**, l'impalcatura dei testi: una lingua nuova si aggiunge senza
  riaprire seicento file, e quanto inglese entra serve solo a provarlo.
  **CHIUSA**
- **DM.07**, il manifesto, le guardie, il rapporto, le fotografie dei
  selettori e il conto di cosa costerebbe tradurre il corpus. **CHIUSA**

---

## CIO' CHE QUEST'ORDINE NON TOCCA, E SI MISURA

- **Il comportamento visibile in italiano non cambia di un carattere**, salvo
  i due difetti nominati. Il modo di verificarlo non e' la parola di chi
  lavora: e' che **nessuna prova esistente venga modificata per farla
  passare**. Se una cade, si torna indietro.
- **I calcoli astronomici e l'ora di nascita non si toccano.**
- **Le guardie di lingua restano rumorose come oggi sull'italiano.** Prima di
  toccare `test/sorgenti_di_lib.dart` si annota quante violazioni italiane
  trovano le prove di lingua, e dopo si verifica che il numero non sia sceso.
- **Il trattino lungo resta vietato in qualunque lingua.**
- **Le chiamate a runtime restano su Vertex AI con Gemini.**
