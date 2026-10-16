# RAPPORTO DELL'ORDINE DM, LA PREDISPOSIZIONE MULTILINGUA

**L'app e' predisposta al multilingua, e non e' tradotta.** 16 settembre 2026,
ramo `claude/esoteric-circle-master-order-e798aj`, dal commit `6f9e42c9`.
Sette voci, tutte chiuse. Il manifesto, con le premesse rimisurate una per
una, sta in `docs/ordini/ORDINE_DM_MANIFESTO.md`.

**Nessuna build**, come l'ordine chiede.

---

## 1. CHE COSA HO COSTRUITO, E PERCHE' QUESTA STRADA REGGE

**Il difetto di partenza non era che mancasse una lingua: era che la lingua
non era un dato.** Erano **tre cose scollegate**, e nessuna delle tre sapeva
delle altre:

| dove | che cosa diceva | chi lo scriveva |
|---|---|---|
| `AppStrings.languageCode` | `'it'` | **nessuno**, mai |
| `LaMarcaDelGenere.lingua` | `LinguaItaliana` | **nessuno**, mai, misurato su tutto `lib` |
| i widget di sistema | niente, quindi inglese | non esisteva nessun delegato |

Tre verita' separate sulla stessa domanda sono la famiglia di difetti piu'
numerosa di questo progetto, e la cura e' sempre la stessa: **togliere le
porte in piu', non correggerle una per una**.

**La forma scelta.** `lib/core/l10n/la_lingua_del_cerchio.dart` e' l'unico
posto dove la lingua si sceglie e l'unico da cui scende. Chi la cambia chiama
`scegli` e non tocca nient'altro: la porta scrive il codice nelle stringhe
dell'interfaccia, dice alla marca del genere in che lingua si risolve, se lo
ricorda sul telefono e avvisa chi disegna.

**E' statica per la stessa ragione per cui lo e' `LaMarcaDelGenere`**: i testi
stanno dentro i corpora, e **un corpus non ha un `BuildContext`**. Se ogni
lettore dovesse andarsi a prendere la lingua, il primo che se ne dimenticasse
scriverebbe nella lingua sbagliata. Chi disegna ascolta un `ValueListenable`,
e `app.dart` ci aggancia l'intera `MaterialApp`: un cambio di lingua ridisegna
tutto senza che nessuna schermata debba ricordarsene.

**Perche' regge, ed e' l'unica cosa che conta fra sei mesi.** Non perche' il
codice sia scritto bene: **perche' tre guardie impediscono che le porte
tornino a essere due.**

1. *"NESSUNO SCRIVE LA LINGUA FUORI DALLA SUA PORTA"*: le due variabili che la
   lingua governa sono pubbliche e statiche, quindi chiunque puo' scriverle.
   La guardia legge tutti i file di `lib` e pretende che nessuno lo faccia.
2. *"NESSUN PROMPT SI SCRIVE LA LINGUA DENTRO"*: la prima riga cablata che
   rientra rimette il progetto dov'era, e nessuno se ne accorge finche' non
   serve la seconda lingua.
3. *"CHI DECIDE IN BASE ALLA LINGUA STA TUTTO IN UN POSTO"*: il primo `switch`
   sulla lingua che nasce in una schermata fa salire il conto dei file da
   riaprire, e questa guardia e' il campanello.

**Tutte e tre viste rosse prima**, con il difetto innestato a mano e
verificato col grep.

---

## 2. I DUE DIFETTI CHE L'APP AVEVA OGGI, IN ITALIANO

### I selettori in inglese

Senza i delegati di localizzazione i widget che Flutter disegna da se' parlano
inglese. Nell'app succede in **tre punti**, contati su tutto `lib`: i due
`showDatePicker` del profilo e del Sigillo, e lo `showTimePicker` delle
notifiche. **Chi sceglieva la propria data di nascita leggeva CANCEL e OK.**

**Le fotografie stanno in `docs/collaudo/DM/`**, cinque, dipinte dal widget
vero col tema vero dell'app:

| file | che cosa mostra |
|---|---|
| `01_data_prima_inglese.png` | *"Select date"*, *"March 1990"*, `S M T W T F S`, *"Cancel"* |
| `02_data_dopo_italiano.png` | *"Seleziona data"*, *"marzo 1990"*, `L M M G V S D`, *"Annulla"* |
| `03_ora_prima_inglese.png` | il selettore dell'ora in inglese |
| `04_ora_dopo_italiano.png` | *"Seleziona ora"*, *"Annulla"*, *"OK"* |
| `05_data_in_inglese_scelto.png` | l'inglese quando **si sceglie** l'inglese, che e' il punto della voce |

**E la fotografia si guarda, non si conta.** Al primo giro le lettere uscivano
come **quadratini neri**: nel banco senza tema il testo si disegna col
carattere di ripiego, che stampa scatole. Un'immagine cosi' avrebbe provato
niente e sembrato una prova. Col tema vero dell'app le parole si leggono.
**Un difetto resta, ed e' onesto dirlo**: nella riga dell'intestazione (la
data scelta per esteso) i glifi restano scatole anche col tema, perche'
quello stile usa una famiglia che il banco non carica. Le parole che contano,
titolo, mese, giorni della settimana e pulsanti, si leggono tutte.

### Il separatore decimale

`toStringAsFixed` e' una funzione di Dart e non sa in che paese sta: mette
sempre il punto. **In tre punti visibili a una persona si leggeva *"152.3
gradi"* invece di *"152,3 gradi"***: la triade degli Angeli, la Luna sopra il
suolo nel cielo di sopra, e la riga di messa a punto dentro Impostazioni.

**E in quattro altri punti qualcuno se n'era gia' accorto**, e aveva scritto a
mano `.replaceAll('.', ',')`. Funziona, in italiano: ed e' proprio il genere
di cura che il giorno della seconda lingua **diventa un difetto**, perche'
mette la virgola anche a chi legge in inglese. Quattro rimedi scritti a mano
in quattro posti sono quattro verita' sulla stessa domanda: adesso sono una,
`NumeroDelCerchio`, e il separatore lo sa `intl`, che porta i dati di tutte le
lingue. **Aggiungere una lingua non vuol dire aggiungere una riga li'.**

**Cosa NON ho toccato, e si dichiara**: le stampe di diagnosi. Il ritmo della
voce, la lettura degli ancoraggi, il diario dei viaggi, il fondo del cosmo e
la costellazione del viso stampano numeri per chi sviluppa, non per chi legge.
Un referto tecnico col punto non e' un difetto di lingua.

---

## 3. LE ALTRE DUE COSE CHE ADESSO FUNZIONANO

**La lingua della risposta del modello e' un parametro.** Era scritta dentro i
prompt, **nove volte in quattro file**. Adesso chi scrive un prompt nomina
`LaLinguaDelModello.nome`, e il giorno della seconda lingua quella parola
cambia in un posto solo.

**In italiano ogni stringa e' identica al byte a quella di prima**, ed e' la
regola dell'ordine: un prompt che cambiasse di una virgola cambierebbe le
risposte del modello, che in italiano e' esattamente cio' che si vieta. Una
prova lo misura sul prompt vero del Sigillo, non sulla porta.

**E i prompt restano in italiano, per scelta dichiarata**: le istruzioni al
modello le legge il modello, non una persona. Cio' che si rende parametrico e'
**la lingua della risposta**, che e' quella che una persona legge.

**La marca del genere sa delle lingue senza genere.** `LinguaSenzaGenere`
esisteva dall'ordine DL, scritta per le lingue dove le tre forme coincidono,
e **non la collegava nessuno**: era una porta murata. Adesso la lingua che non
ha genere se la prende, e i testi con la marca `[a|b|c]` in inglese rendono il
campo neutro.

**Una prova l'ha scoperto sul campo, e vale la pena raccontarlo.** La prova
del prompt confrontava i due prompt interi, italiano e inglese, aspettandosi
che differissero solo per la parola della lingua. Cadeva. Non era un guasto:
in inglese **cambia anche il blocco di cortesia**, perche' la marca rende il
neutro. Una prova che pretendesse i due prompt identici pretenderebbe che la
voce 05 non esista.

---

## 4. QUANTO COSTEREBBE TRADURRE IL CORPUS, IL CONTO PER FILE

### PRIMA DI TUTTO: IL CENSIMENTO ESISTEVA GIA', E NON LO SAPEVO

**E' la scoperta piu' importante di questo capitolo, e me l'ha fatta fare una
guardia.** Il progetto ha **gia'** un censimento delle stringhe, dall'ordine
**CE voce 15**: sta in `docs/traduzione/censimento.md`, lo genera
`tool/censimento_stringhe.dart`, e una guardia lo sorveglia. Ne' l'ordine DM
ne' il mio manifesto lo nominavano, e io ho misurato le stringhe da capo con
un metodo mio.

**Il censimento di casa, rigenerato oggi col suo strumento:**

| grandezza | quando lo scrisse l'ordine CE | oggi |
|---|---:|---:|
| stringhe rivolte alla persona | 6.799 | **8.856** |
| che portano contenuto, `core` e `services` | 5.368 | **7.080** |
| che portano interfaccia, `features` e `design_system` | 1.431 | **1.776** |
| che cambiano con genere o numero | 97 | **133** |
| che passano da un sistema di traduzione | 0 | **0** |
| file che ne contengono | 288 | **374** |

**La differenza non e' un errore di nessuno**: sono gli ordini che hanno
scritto testo da allora. E **le stringhe che passano da un sistema di
traduzione restano zero**, che e' esattamente cio' che quest'ordine
promette: l'impalcatura c'e', il peso non ci e' ancora sopra.

**E il metodo di casa e' quello canonico**: i numeri che seguono sono la mia
misura indipendente, e servono a dire il **conto per file**, che il censimento
di casa non dava. Dove le due divergono, vince quella di casa, perche' e'
quella che una guardia sorveglia.

### E LO STRUMENTO DEL CENSIMENTO DICEVA UNA COSA CHE NON VERIFICAVA

Il documento chiudeva con una sezione intitolata *"Cosa NON esiste oggi,
**verificato**"*, e sotto quattro righe: nessun file `.arb`, nessuna cartella
`lib/l10n`, nessuna dipendenza `intl` o `flutter_localizations`, nessuna
`Locale` dichiarata.

**Nessuna delle quattro veniva verificata.** Erano testo fisso dentro il
generatore. Finche' erano vere nessuno se n'e' accorto; **il giorno che
quest'ordine ha aggiunto i delegati, il documento ha cominciato a dire il
falso e a chiamarlo verificato.**

Adesso ogni riga di quella sezione la scrive una misura, e il documento dice
il vero qualunque sia lo stato: oggi dice che i delegati ci sono, che `intl`
c'e', che `supportedLocales` e' dichiarato, e che **le stringhe che passano da
un sistema di traduzione sono zero**.

### IL CONTO PER FILE, MISURATO A PARTE

**E' la domanda che l'ordine pone, e la risposta decide se la traduzione e' un
ordine o dieci.** Misurato col lettore che separa codice, commenti e stringhe,
contando le stringhe di **almeno due parole**, cioe' le frasi e non le
etichette:

| misura | numero |
|---|---:|
| file di `lib` con almeno una frase | **391** su 642 |
| frasi in tutto | **10.248** |
| parole in tutto | **82.787** |
| file che tengono **meta'** delle frasi | **28** |
| file che ne tengono **tre quarti** | **81** |
| file con meno di dieci frasi ciascuno | **205**, e insieme ne tengono **817** |

**I venti file piu' pesanti**, che da soli valgono quasi la meta':

| file | frasi | parole |
|---|---:|---:|
| `core/tarot/tarot_card.dart` | 387 | 6.084 |
| `core/viaggio/la_voce_del_mondo_di_sotto.dart` | 363 | 2.169 |
| `core/angels/angel_lore.dart` | 290 | 6.093 |
| `core/rituals/rito_alba_corpus.dart` | 283 | 2.400 |
| `core/tarot/voce_della_stesa.dart` | 283 | 2.660 |
| `core/sigilli/sentiero_albero.dart` | 264 | 1.671 |
| `core/sigilli/sentiero_costellazione.dart` | 264 | 1.640 |
| `core/sigilli/sentiero_loto.dart` | 264 | 1.643 |
| `core/synastry/testi_della_sinastria.dart` | 251 | 2.433 |
| `core/rituals/rune_lore.g.dart` | 219 | 2.676 |
| `core/rituals/guide_animal_corpus.dart` | 217 | 2.263 |
| `services/ai/impronta_dell_istruzione.dart` | 165 | 1.824 |
| `core/horoscope/horoscope_data.dart` | 160 | 1.992 |
| `core/rituals/rune_presage.dart` | 158 | 758 |
| `core/entitlement/plan_catalog.dart` | 138 | 620 |
| `core/viaggio/la_scena_dal_modello.dart` | 135 | 1.190 |
| `core/rituals/sunset_rune_corpus.dart` | 134 | 1.508 |
| `core/synastry/vip_catalog.dart` | 131 | 301 |
| `services/ai/maestro_persona.dart` | 123 | 1.348 |
| `features/account/account_screen.dart` | 121 | 791 |

**Che cosa dice questo conto, detto senza girarci intorno.**

**La traduzione non e' un ordine, e non e' nemmeno seicento file.** E'
**ottantuno file per i tre quarti del lavoro**, e una coda di duecentocinque
file che insieme valgono l'otto per cento. Ottantunomila parole sono
l'equivalente di un romanzo: a un traduttore professionale si paga a parola, e
il numero da mettere nel preventivo e' quello.

**E c'e' una cosa che il conto non dice e che pesa di piu' del conto.** Una
parte grossa di quel corpus **non e' testo: e' testo con dentro la marca del
genere**, 103 marche in 29 file, e testo che il modello riusa come esempio di
tono. Tradurlo non e' tradurre: e' **riscriverlo nella voce di quella
lingua**, con le sue marche o senza. Per l'inglese, che le tre forme non le
ha, il lavoro e' piu' semplice di quanto il numero suggerisca; per una lingua
con tre generi sarebbe piu' complesso.

**Quattro ordini, e la divisione la dicono i numeri, non il gusto**: uno per i
Tarocchi e gli Angeli (677 frasi, 12.177 parole), uno per i riti e le rune,
uno per il Viaggio e la Sinastria, uno per l'interfaccia e la coda. Nessuno
dei quattro tocca l'impalcatura, che e' gia' fatta.

---

## 5. IL RISCHIO DEL PUBSPEC, E COME E' ANDATA DAVVERO

L'ordine chiede di girare la risoluzione a secco **prima** di toccare il
pubspec, e di fermarsi se il risolutore vuole muovere anche un solo pacchetto
Firebase.

**Il piano a secco**: `+ intl 0.20.3`, *"Would change 1 dependency"*. Nessun
`firebase_*`, nessun `cloud_*`. Verificato dopo con `diff` che i due file non
erano stati toccati.

**Poi il piano a secco si e' rivelato incompleto, ed e' la lezione della
voce.** Aggiungendo **anche** `flutter_localizations`, che viene dall'SDK di
Flutter e porta il proprio vincolo su `intl`, la risoluzione **fallisce** con
`intl: 0.20.3` fisso: *"Consider downgrading your constraint on intl"*. **Il
piano a secco di una dipendenza sola non e' il piano di due.**

**Il piano vero, letto sul `pubspec.lock` dopo il `flutter pub get`**, che e'
la sola misura che conta:

```
13 righe aggiunte, 0 tolte
+ flutter_localizations (sdk)
+ intl 0.20.2
```

**Zero righe tolte e zero pacchetti Firebase nel diff.** Il rischio che
l'ordine voleva guardare non si e' materializzato, e adesso lo dice un file
versionato invece di una previsione.

---

## 4-BIS. LA DOMANDA DEL FONDATORE SUGLI EOS, E COSA HA SCOPERCHIATO

**La domanda era precisa**: il Cammino conia 2.010 Eos per sentiero e 6.030 in
tutto, quindi il saldo supera il mille e si legge a schermo in piu' punti. Se
quel numero fosse passato dal formattatore nuovo, sarebbe comparso un
separatore delle migliaia dove prima non c'era: **un ottavo punto cambiato in
silenzio**.

**La risposta alla domanda esatta e' no.** Misurato: le righe di `lib` che
scrivono un saldo o una moneta a schermo sono venti, e **zero** nominano
`NumeroDelCerchio`. I punti che passavano dalla porta erano esattamente sette,
tutti gradi o percentuali.

**Ma cercando quelli e' venuta fuori una famiglia intera, e la mia voce 03 era
incompleta.**

### Tre copie della stessa funzione, scritte a mano

Il separatore delle migliaia era scritto a mano **in tre file**, con lo stesso
giro parola per parola:

| dove | cosa scriveva |
|---|---|
| `design_system/components/borsellino.dart` | il saldo in barra, *"6.030"* |
| `core/entitlement/plan_catalog.dart` | la dote del piano, *"2.000 Eos"* |
| `core/viaggio/vocabolario_del_viaggio.dart` | *"8.640 scene possibili"* |

**Tre copie della stessa regola sono tre verita' che un giorno divergono**, e
in inglese sbagliavano tutte e tre allo stesso modo: il punto e' il separatore
dei **decimali**, e un saldo di 6.030 Eos si sarebbe letto *"sei virgola zero
tre zero"*.

Adesso passano tutte e tre da `NumeroDelCerchio.interi`. **In italiano il
testo e' identico al carattere**, misurato su quattordici valori dallo zero al
milione, coi due numeri del Cammino nominati per nome: *"2.010"* e *"6.030"*.

### Cinque decimali visibili rimasti indietro

**La prima passata della voce 03 aveva convertito un punto per file e si era
fermata li'.** Nella stessa schermata ce n'erano altri:

- *"Luna illuminata 43.2 per cento"*, nel cielo di sopra;
- quattro numeri della messa a punto dentro Impostazioni, fra cui *"Riposo
  imparato 0.12 e 0.34"*.

Tutti col punto, tutti letti da una persona in italiano. Adesso passano dalla
porta.

### Cosa resta col punto, e perche'

- **Latitudine e longitudine a quattro decimali**, nel cielo di sopra. Il punto
  e' la forma internazionale delle coordinate, e scriverle con la virgola le
  renderebbe piu' difficili da copiare altrove. **E' una scelta, non una
  dimenticanza.**
- **La serializzazione di un punto nel Diario dei Viaggi**, che **non e' un
  testo**: localizzarla romperebbe la rilettura di cio' che e' gia' scritto sui
  telefoni.
- **I referti tecnici**: il ritmo della voce, la lettura degli ancoraggi,
  l'etichetta di debug del cosmo, il rapporto della costellazione del viso.
- **Il prezzo dei pacchetti di Eos**, `"€ 4,99"`, che viene **letto** e non
  scritto: la virgola li' e' nel testo che scriviamo noi, e la valuta di un
  altro mercato e' una questione di listino, non di formattatore.

### E adesso c'e' una prova che tiene fermo tutto questo

**`ogni_decimale_a_video_passa_dalla_lingua_test`** non pretende che i
decimali scritti a mano siano zero: pretende che siano **esattamente quelli
dichiarati, ognuno con la sua ragione scritta**. Un decimale nuovo che compare
senza ragione la fa cadere. E una seconda riga fa cadere la prova anche
**quando una ragione parla di niente**, cioe' quando un file dichiarato non ha
piu' nessun decimale: e' la stessa cura del registro dei rossi accettati.

**E una seconda prova impedisce la quarta copia** del separatore delle
migliaia, riconoscendolo dalla forma del giro, cioe' scrivere un carattere
ogni tre cifre, in qualunque nome lo si chiami.

**Tutte e due viste rosse prima**, con il difetto rimesso a mano.

---

## 5-BIS. CHE COSA COSTA DAVVERO AGGIUNGERE UNA LINGUA

**Una riga, piu' le voci dell'interfaccia.** La riga sta nell'elenco
`LinguaDelCerchio` e porta con se' tutto cio' che di quella lingua bisogna
sapere: il codice, il nome con cui si presenta, il nome in italiano per i
prompt del modello, e **se le tre forme del genere coincidono**.

**La prima stesura non era cosi', e la differenza vale la pena raccontarla.**
La conoscenza della lingua stava in due decisioni scritte fuori dall'elenco:
un ternario che sceglieva la lingua della marca del genere, e uno `switch` che
dava il nome per i prompt. Funzionava, e aggiungere una lingua voleva dire
aprire **tre** posti invece di uno. Peggio: il ternario avrebbe trattato in
silenzio ogni lingua nuova **come se il genere non ce l'avesse**, e il
francese o lo spagnolo sarebbero arrivati a schermo col campo neutro senza che
nessuno se ne accorgesse.

Adesso `senzaGenere` e' un campo dell'elenco **senza valore di partenza**:
chi aggiunge una lingua e' obbligato dal compilatore a dichiararlo.

**E una guardia tiene ferma la promessa**: *"NESSUNO FA UN CASO PER LINGUA,
nemmeno dentro casa"*. Cerca su tutto `lib`, senza eccezioni nemmeno per la
casa della lingua, ogni `switch`, `case` o confronto che nomini una lingua.
Oggi non ce n'e' nessuno.

**E questa guardia ha imparato da un innesto.** La prima stesura cercava solo
`LinguaDelCerchio.x ==`, cioe' il nome prima dell'operatore. Innestato il
difetto nella forma piu' naturale, `corrente.value == LinguaDelCerchio.italiano`,
**non l'ha preso**: guardava un verso solo di una cosa che se ne scrive in
due. Allargata, lo prende.

---

## 5-TER. LE VERIFICHE FATTE PRIMA DI CONSEGNARE

Il fondatore ha chiesto di controllare ogni minimo particolare. Questo e' cio'
che ho misurato, e non e' la stessa cosa che avere le prove verdi.

**1. I prompt in italiano sono identici al byte.** Non letto a occhio:
misurato. Si prendono i quattro file com'erano al commit precedente e come
sono adesso, si estraggono le **stringhe** col lettore che separa codice,
commenti e stringhe, si riuniscono quelle adiacenti (Dart le riunisce, quindi
una frase spezzata su due righe e' la stessa frase) e si mette al posto
dell'interpolazione la parola che la porta rende in italiano.

| file | esito |
|---|---|
| `services/ai/maestro_persona.dart` | **IDENTICO**, 8.444 caratteri |
| `core/magic/il_sigillo_dal_modello.dart` | **IDENTICO**, 6.147 |
| `core/viaggio/il_segno_dell_animale.dart` | **IDENTICO**, 2.316 |
| `core/viaggio/la_scena_dal_modello.dart` | **IDENTICO**, 7.557 |

**24.464 caratteri di prompt, zero differenze.**

**2. Il raggruppamento delle migliaia, che poteva fare danno in silenzio.**
Passare a un formattatore che conosce le lingue vuol dire che dai mille in su
compare il separatore: *"1.234,5"* invece di *"1234.5"*. **Sarebbe un
comportamento visibile cambiato oltre ai due difetti permessi.** Misurato: il
formattatore lo fa davvero, e **nessuno dei sette punti dell'app ci arriva**,
perche' i valori che passano di li' sono gradi fino a 360, altezze fino a 90 e
percentuali fino a 100. C'e' una guardia che lo dichiara e che cade il giorno
in cui qualcuno ci facesse passare un numero grande.

**3. I quattro punti che avevano gia' la virgola a mano non cambiano di un
carattere**, verificato su otto valori confrontando con la vecchia forma,
`toStringAsFixed(1).replaceAll('.', ',')`.

**4. Nessun file di `lib` legge le traduzioni di sistema.** Cercati
`MaterialLocalizations`, `CupertinoLocalizations` e `Localizations.of` su tutto
`lib`: **le uniche due occorrenze sono i delegati che ho appena montato in
`app.dart`**. Quindi il cambiamento resta dentro i widget di sistema, e non
tocca nessun testo scritto da noi. Cambiano anche i suggerimenti automatici di
quei widget, per esempio il pulsante indietro che il sistema aggiunge da solo:
e' la stessa famiglia del difetto dichiarato, e in italiano e' un
miglioramento.

**5. `test/sorgenti_di_lib.dart` non e' stato toccato**, quindi l'insieme che
le prove di lingua guardano e' esattamente quello di prima: **22.753
stringhe**, annotate prima di cominciare.

**6. Il formato.** `dart format` voleva cambiare sette file: sono stati
formattati **prima** del giro definitivo del cancello, e il confronto al byte
dei prompt e' stato rifatto **dopo** la formattazione. Il primo giro del
cancello, partito su file che stavano per cambiare, e' stato **buttato**
invece di essere creduto.

---

## 6. LE PROVE, E CHE COSA MISURANO

| prova | che cosa tiene fermo |
|---|---|
| `la_lingua_e_un_dato_solo_test` | la lingua scende dove serve, si ricorda, l'italiano resta il default, un codice sconosciuto non rompe niente, la chiave sta nella verita' unica, **e nessuno scrive la lingua fuori dalla porta** |
| `i_selettori_di_sistema_parlano_italiano_test` | il **prima** e il **dopo** sul selettore vero, e che `app.dart` monti davvero i tre delegati |
| `la_lingua_del_modello_e_un_parametro_test` | in italiano la riga e' identica al byte, il prompt vero cambia con la lingua, **e nessun prompt si scrive la lingua dentro** |
| `una_lingua_nuova_non_riapre_seicento_file_test` | i testi seguono la lingua, **chi decide in base alla lingua sta tutto in un posto**, e la casa della lingua resta piccola |
| `anteprima_dei_selettori_test` | le cinque fotografie, a richiesta |
| `ordine_dm_guard_test` | le sette voci, **e che il manifesto dichiari il metodo delle misure, non solo i numeri** |

**Il numero annotato prima di cominciare**, come l'ordine chiede: le prove di
lingua guardano **22.753 stringhe** di `lib`, e i loro criteri non scattano su
nessuna violazione vera. **`test/sorgenti_di_lib.dart` non e' stato toccato**,
quindi quell'insieme e' esattamente quello di prima.

### L'UNICA PROVA ESISTENTE CHE HO TOCCATO, e va detto per prima

L'ordine e' netto: *"Se una prova esistente va modificata per farla passare,
ti sei mosso male: torna indietro"*. **Ne ho modificata una**, e non torno
indietro: spiego perche' e lascio giudicare.

`test/accenti_veri_test.dart` tiene una tavola di esenzioni **indicizzata per
numero di riga**. Una di quelle righe e' l'etichetta *"Coordinate da"* in
`sky_overview_screen.dart`, che finisce legittimamente con la preposizione. La
cura del separatore decimale ha aggiunto **un import** a quel file, e la riga
473 e' diventata la 474.

**Che cosa e' cambiato davvero**: un numero. **11 esenzioni prima, 11 dopo;
17 parole sorvegliate prima, 17 dopo.** La guardia e' severa esattamente come
ieri, e la ragione scritta accanto all'esenzione e' la stessa parola per
parola.

**Perche' non si poteva evitare**: un import va in cima, e qualunque import
sposta di uno tutte le righe sotto. L'unica alternativa era non curare quel
difetto, che l'ordine chiede di curare.

**E la nota che lascio a chi verra'**: e' la **terza volta** che questa tavola
si sposta per un import, e le due volte precedenti stanno scritte nei suoi
commenti. Indicizzare per numero di riga costa una modifica a ogni import in
quei file. Cambiarla per indicizzare sul contenuto sarebbe un miglioramento
vero, **e non l'ho fatto dentro quest'ordine**: cambiare il meccanismo di una
guardia dentro un ordine che non deve toccare le guardie sarebbe peggio del
problema che risolve.

---

## 7. DOVE L'ORDINE SBAGLIAVA

**Tre affermazioni, e due sono sbagliate in peggio.**

- **`app_strings.dart` e' chiamato da due file di lib.** No: **uno solo lo
  chiama**, e il secondo dei due file che lo nominano e' il file stesso. **E
  c'e' di peggio, che l'ordine non dice**: `functionTitle`, cioe' **sette
  chiavi su nove**, in `lib` non lo chiama nessuno. La porta dei testi non
  aveva un solo cliente, ne aveva **un ottavo** di quelli che sembrava avere.
- **Le righe che impongono l'italiano al modello sono otto, in tre file.** No:
  **nove, in quattro**. Il quarto e' `lib/core/viaggio/la_scena_dal_modello.dart`
  riga 342, dentro il prompt della scena del Viaggio, e non lo nominava
  nessuno: e' proprio la riga che una ricerca fatta sui tre file conosciuti
  non avrebbe mai trovato.
- **Le due occorrenze in `angel_lore.dart` sono citazioni di salmi.** Vera, ma
  sono **dieci**, non due. Non cambia niente al lavoro, cambia la fiducia nel
  conto.

**E una che non e' sbagliata ma non e' un fatto.** Le **7.559 stringhe
rivolte alla persona**: il numero dipende da dove si taglia fra una frase e
un'etichetta, e il taglio e' un giudizio. Con la rete larga sono **10.245**,
con la stretta **6.253**, **col metodo di casa 8.856**. **Cio' che non cambia
con nessuna rete e' la forma**, ed e' quella che serviva: tre quarti in
`core`, un quinto in `features`, una manciata altrove. L'ordine aveva ragione
su cio' che contava.

---

## 8. E DOVE HO SBAGLIATO IO

**E' la parte che costa di piu' scrivere, ed e' quella che vale.**

- **Non ho cercato se il censimento delle stringhe esistesse gia'.** Esisteva,
  dall'ordine **CE voce 15**, col suo strumento e la sua guardia, e io ho
  rimisurato tutto da capo con un metodo mio. **Me l'ha fatto scoprire una
  guardia caduta**, non una mia domanda. La prima riga del protocollo di casa
  dice di verificare sul repository prima di affermare: l'ho applicata ai
  numeri dell'ordine e non alla domanda *"questo lavoro l'ha gia' fatto
  qualcuno?"*.
- **La voce 03 era incompleta, e l'ha trovata il fondatore.** Avevo convertito
  **un punto per file** e mi ero fermato li'. Chiedendo degli Eos sono venute
  fuori tre copie del separatore delle migliaia scritte a mano e cinque
  decimali visibili rimasti col punto. Il capitolo 4-bis li racconta tutti.
- **La prima forma dell'elenco delle lingue** avrebbe trattato in silenzio
  ogni lingua nuova come priva di genere. Funzionava, e sarebbe stata una
  trappola per chi avesse aggiunto il francese.
- **Ho scritto la riga delle Impostazioni con le misure tipografiche a mano**,
  corpo 16 e corpo 15: **tre guardie di casa l'hanno presa insieme**. Un corpo
  15 e' testo che qualcuno legge male, e i token esistono per questo.
- **Ho creduto a un primo giro del cancello** partito su file che `dart
  format` stava per cambiare. L'ho buttato, ma l'avevo lanciato.

**Il cancello ha trovato sette rossi nuovi, tutti miei**, e ognuno era una
cosa che non avevo guardato: le tre guardie tipografiche, la riga della messa
a punto che difendeva il punto decimale, il censimento, la tavola delle API di
iOS e il registro delle guardie. **Nessuno di questi sarebbe uscito da una
rilettura del codice**: sono usciti perche' la casa ha piu' guardie di quante
io ne tenga a mente.

**E una cosa che l'ordine ha fatto bene, e va detta**: l'avvertimento di
diffidare dei conteggi testuali era fondato. Il conto col solo `grep` sulla
parola *"italiano"* da' **centoquarantotto** righe; **centosei stanno nei
commenti** e non istruiscono nessuno. Senza quell'avvertimento avrei contato
i commenti insieme al codice, e il numero del manifesto sarebbe stato falso
di tre volte.
