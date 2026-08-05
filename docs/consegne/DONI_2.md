# DONI 2, consegna parziale

Ramo `claude/doni-2`, nato da `origin/claude/esoteric-circle-master-order-e798aj` a `2c2b7c6`, distanza zero nei due sensi al momento della creazione.

Questa consegna copre **una voce su tre**. Le altre due sono aperte e non iniziate, e il perche' sta in fondo.

Deroga applicata come ordinato: `STATO_VIVO.md` e `RIPRESA.md` **non** sono stati toccati, e l'agente `custode-memoria` non e' stato invocato.

## Le cinque premesse, verificate prima di scrivere

**1. VERA.** La frase segnaposto sta in `lib/features/rituals/ritual_gift_card.dart`, righe 225-235 prima della correzione, scritta due volte come letterale. I campi del modello sono `GiftSource.transit` e `GiftSource.tradition`, in `lib/core/rituals/dawn_gift.dart`. La frase non usciva da nessun contenuto: era il ripiego del `??`, e scattava sempre perche' i due campi nascevano `null` cablati.

**2. VERA.** `CieloDiOggi.perIlGiorno` sta in `lib/core/horoscope/cielo_di_oggi.dart:57` e pretende `({required DateTime adesso, required NatalChart? carta})`. Con carta nulla o essenziale torna `CieloDiOggi.nessuno`.

**3. VERA.** La striscia ha la palette del Maestro del giorno, la scheda no. `dawn_rite_screen.dart:278` calcola `MaestroPalette.forKey(ThemeKey.of(maestro))` e la usa per barra e sfondo, ma costruisce `RitualGiftCard(gift:, streak:, onShare:)` senza passargliela: il costruttore non ha il parametro. I colori della scheda sono sei costanti di file, righe 12-19, uguali per tutti e tre i Maestri tutti i giorni.

**4. VERA.** `DailyRituals.dawnMaestro(date)` in `daily_rituals.dart:14` e `DailyElements.maestroFor(element, now)` in `daily_elements.dart:140`, che vale `element.guide ?? DailyRituals.dawnMaestro(now)`.

**5. FALSA.** Non sono due porte, e' una sola: `SimboloDellAttesa.per` in `lib/core/maestro/simbolo_dellattesa.dart:56`, disegnata da `_SimboloCheSiCompone` in `consulto_del_cielo_view.dart:202`. Medora, Aura e Caligo passano tutti di li'. La differenza sta nel dato: Medora ha il segno dal contesto natale, Aura ha l'archetipo da `ArchetypeHistory.ultimo?.dominante`, che e' nullo finche' la persona non ha fatto il Test. Il comportamento visto era quello progettato, non un guasto.

## VOCE 1, chiusa

Commit `f196446`, spinto su `claude/doni-2` e verificato con `git ls-remote`.

- `DawnGift.transitoDiOggi(date, carta)` compone il transito con `CieloDiOggi.perIlGiorno` piu' `CorrenteDelCielo.frase`, prendendo la voce piu' stretta. **E' la stessa porta dell'Oroscopo**: se ne esistesse una seconda, il Rito e l'Oroscopo potrebbero dire due cose diverse dello stesso cielo nella stessa mattina.
- La carta natale arriva alla schermata dell'Alba da `BirthIdentityController.chart`, la stessa fonte dell'Oroscopo.
- `tradition` resta nullo **per una ragione dichiarata, non per attesa**: i nove riti dell'Alba sono composti dal progetto gesto per gesto, e per nessuno esiste oggi una fonte verificata da citare. Il posto dove entrera' e' `FormaDelRito.fonte`, ed e' scritto nel codice.
- Le due righe **spariscono** quando il dato non c'e', come gia' fanno le varianti del rito.
- Corrette due intestazioni che dichiaravano il falso, fra cui quella che diceva che un motore a effemeridi non esisteva ancora.

**Un rosso e' restato verde, e la prova era mia.** Rimettendo il segnaposto dentro la card come letterale, tutte e sette le prove restavano verdi: enumeravano il modello, e un testo mostrato puo' nascere anche dove il modello non arriva. Aggiunta una prova che scandisce le stringhe vive di `lib/features/rituals`, saltando i commenti. Ri-iniettato il difetto, adesso cade e nomina la riga.

**Un catch muto non e' entrato.** Il guardiano ha visto il quarto catch muto contro i tre dichiarati: adesso e' `on ProviderNotFoundException catch (assente)` con la ragione scritta.

1734 prove verdi in 8 minuti e 9 secondi, zero errori all'analisi.

## VOCE 2, aperta e non iniziata

Il colore della scheda piena. Il progetto e' deciso e vale la pena scriverlo, perche' e' la parte non ovvia:

**La porta e' `gift.maestro`, e non una palette passata dall'esterno.** Il dono sa gia' di chi e' il giorno, perche' gliel'ha messo dentro `DawnGift.forMaestro`, che a sua volta lo prende da `DailyRituals.dawnMaestro` per la rotazione e da `DailyElements.maestroFor` per i riti con guida fissa come il Soffio del Destino. Passare una palette dalle due schermate creerebbe **due** punti che decidono lo stesso colore, ed e' esattamente cio' che la voce vuole evitare.

**Il testo resta scuro su chiaro.** A gesto completato la scena e' luce piena e la bolla e' vetro chiaro: tingere l'inchiostro col colore del Maestro peggiorerebbe la lettura senza dire niente di piu'. Il Maestro si vede dove il colore e' colore, cioe' negli accenti e nel bordo.

**Dove si e' fermato il lavoro.** La costante `_dayAccent` va sostituita con una funzione che deriva l'accento da `gift.maestro`. Il lavoro e' stato iniziato e poi **riportato indietro di proposito**, perche' va fatto e verificato in un colpo solo e il margine non bastava.

> **CORREZIONE del 6 agosto 2026, fatta rimisurando.** Le occorrenze sono
> undici, e questo era giusto. La ripartizione no: **otto** stanno dentro widget
> annidati, non sei, e i due nominati qui sopra, `_BasePanel` e `_BaseRow`, di
> accento **non ne hanno affatto**. Quelli veri sono `_BaseToggle` (3),
> `_ShareWordButton` (3) e `_StreakChip` (2); le altre tre occorrenze sono la
> dichiarazione e due dentro `_RitualGiftCardState`, dove `gift` e' gia' in
> visibilita'.
>
> **Non era un conto impreciso, era un conto fatto guardando il posto
> sbagliato**: erano stati cercati i widget che AVREBBERO avuto il problema,
> invece delle righe che HANNO l'occorrenza. Il metodo giusto e' partire dalle
> occorrenze e chiedere al file in quale classe cadono.

## VOCE 3, aperta e non iniziata

L'emblema di Aura, con la decisione gia' presa da Mauro:

- l'invito piu' evidente, **corpo 16** invece di 14, e la scena tenuta aperta piu' a lungo. Oggi l'invito e' `TypographyTokens.body(size: 14)` in oro all'85% di alpha, `consulto_del_cielo_view.dart:265`, e dura quanto la scena, cioe' `durataBattuta 2000ms x battuteDellaScena 2` = quattro secondi;
- **fiore piu' invito**, non il solo fiore;
- **strada A**, il loto disegnato in codice come `CustomPainter` in oro, che entra nello stesso ritaglio dall'alto degli altri simboli. `_SimboloCheSiCompone` oggi riceve un `Image.asset` e va reso capace di accettare un widget qualunque;
- **il loto non esiste come asset**, verificato il 6 agosto 2026: nessun file con "lot", "loto" o "lotus" in `assets/` ne' in `brand_assets/`. La strada A e' stata scelta sapendo che un loto vettoriale in oro piatto si vedra' che e' un'altra cosa accanto all'arte Total Metal degli altri simboli.

**E va riscritta la regola in `simbolo_dellattesa.dart`, nello stesso commit del loto.** Oggi quel file si rifiuta per principio di mostrare qualcosa ad Aura senza Test, e la ragione scritta e' che un simbolo al posto dell'archetipo dichiarerebbe alla persona un archetipo che non ha. Il loto regge perche' **non e' uno dei dodici archetipi: e' il fiore che aspetta di aprirsi**, quindi non dichiara niente di falso. Se la regola non viene riscritta insieme, resta li' a dire il contrario di quello che il codice fa.

## Le anteprime, non fatte

Nessuna delle tre. Dipendono tutte dalle voci 2 e 3.

---

# RIPRESA del 6 agosto 2026: voci 2 e 3, chiuse

Ripreso da un'altra sessione che aveva finito il contesto. Ramo `claude/doni-2`
a `e0d1303`, albero pulito salvo `.github/workflows/ronda.yml` non tracciato,
che non e' stato toccato. Suite di partenza **1734 verdi**.

Deroga applicata: `STATO_VIVO.md` e `RIPRESA.md` non toccati, `custode-memoria`
non invocato.

## Le premesse, riverificate

Tutte confermate tranne una cifra, corretta qui sopra. `docs/regole/` **non
esiste**: le regole di casa sono arrivate da Mauro a voce, e per sua decisione
**non** vanno scritte nel repo, perche' il Protocollo vive fuori e riscriverlo a
memoria ne farebbe una copia impoverita che qualcuno leggerebbe come sovrana.

## VOCE 2, chiusa in `f2dee3c`

L'accento nasce da `gift.maestro`. Il costruttore della scheda **non accetta
colori dall'esterno**, cosi' il secondo punto non e' nemmeno possibile, e una
prova lo verifica leggendo il sorgente.

**La scoperta che ha cambiato il progetto.** Preso com'e', il verde di Aura sul
vetro chiaro ha contrasto **2,9**, sotto la soglia di 4,5: sarebbe stato
l'unico accento illeggibile dei tre, proprio dove va letto. Invece di scegliere
a mano tre colori, il colore del Maestro **si scurisce finche' il contrasto non
basta**: blu e rosso passano al primo giro e restano quelli della palette, il
verde scende di quanto serve. Una prova pretende anche che il verde di partenza
NON passi, altrimenti non starebbe verificando niente.

Quattro mutazioni viste rosse. Due anteprime a 1080x2391 in due giorni con
Maestri diversi, trovati dal codice e non supposti.

## VOCE 3, chiusa

- **Il loto e' disegnato**, `LotoDorato` in `design_system/components`, sette
  petali chiusi a ventaglio piu' il bocciolo e due tratti d'acqua. Il file
  **dichiara di essere un ripiego** e dice cosa fare quando l'arte vera
  arrivera'.
- **Il modello ha imparato il loto**: `SimboloDellAttesa.loto`, che viaggia
  separato da `asset` proprio perche' non e' un file. La strada resta **una
  sola** per tutti e tre i Maestri.
- **`_SimboloCheSiCompone` accetta un widget qualunque**, non piu' un percorso:
  il loto entra dallo stesso ritaglio che scende dall'alto degli altri simboli,
  quindi non c'e' un secondo modo di far comparire la stessa cosa.
- **L'invito a corpo 16**, e la riserva di spazio misura lo stesso corpo:
  lasciarla a 14 avrebbe fatto sbagliare il calcolo di quanto ci sta.
- **La battuta dura 3 secondi invece di 2 quando c'e' un invito.** La durata la
  decide il modello, non il Maestro: se domani un altro Maestro avesse un
  invito, la scena si adeguerebbe da sola.
- **La regola riscritta nello stesso commit.** Resta vero che i dodici emblemi
  non si mostrano a chi non ha fatto il Test; il loto regge perche' **non e'
  uno dei dodici**.

## Cosa hanno trovato le prove, e cosa ho sbagliato io

1. **La prima stesura della prova vedeva zero widget**, e sembrava un guasto del
   loto. Era il montaggio: la vista chiede due provider e il `MaestroScope`, e
   li stavo omettendo. Non concludere che la misura e' cieca prima di aver
   guardato se il caso percorre il ramo.

2. **Un rosso e' restato verde.** Tolto il `precache`, la prova sulla decodifica
   restava verde. Invece di dichiararla cieca ho fatto puntare l'emblema a un
   file inesistente: **e' diventata rossa**. La verifica sulla decodifica
   funziona; e' il `precache` a non servire in questo ambiente, perche' il
   bundle di prova risolve l'asset da solo. Resta indispensabile nella cattura
   headless, che e' un contesto diverso.

3. **Due prove esistenti pretendevano il vecchio.** `il_simbolo_si_compone_test`
   diceva che ad Aura senza Test non deve comparire nessun simbolo. Aggiornata,
   non aggirata, e con lei tre commenti dello stesso file che continuavano a
   dichiarare che il loto non esiste: **il file diceva il contrario di quello
   che l'app fa**.

4. **Mi sono cancellato le modifiche con un `git checkout`** il cui `||` non e'
   mai scattato. Ritrovate nella copia di lavoro e verificate riga per riga.

## Cosa NON e' il massimo

1. **Il loto si vedra' che e' un'altra cosa.** Un fiore vettoriale in oro piatto
   accanto all'arte Total Metal incisa degli altri simboli non si confonde. E'
   la scelta dell'ordine, presa sapendolo, ma va guardata a video prima di
   considerarla buona.
2. **Nessuna prova guarda i pixel del fiore.** Si verifica che ci sia, che abbia
   una misura e che non sia un emblema: che sia bello, o anche solo che assomigli
   a un loto, lo puo' dire solo l'occhio.
3. **Il contrasto si misura contro il vetro reso opaco**, cioe' contro la scena
   a luce piena. Se un giorno la scheda comparisse su un fondo scuro, la soglia
   andrebbe rifatta.

## L'ANTEPRIMA DEL LOTO ERA FALSA, e l'ha vista Mauro

La prima `chat-aura-loto-e-invito.png` **non era una verifica**. Due segni la
smascheravano: il **nastro di debug** in alto a destra e il **fondo verde
pieno** invece del cosmo condiviso. Montava il widget in isolamento, quindi non
diceva niente su come il loto appare dentro la chat di Aura, che era l'unica
cosa da giudicare.

Rifatta dalla strada vera: `mount` dell'app intera, `openChat(Aura)`, una
domanda a una voce che non risponde mai, e la scena del consulto vive li'. Con
la verifica prima dello scatto che `consulto_del_cielo`, il loto e l'invito
siano davvero nella scena.

### Il nastro non era solo mio: erano cinque

Cercandolo, **cinque catture gia' nel repo montavano un `MaterialApp` senza
spegnere il nastro**, e producevano anteprime che l'app non produce:

| Riga | Cattura |
|---|---|
| 703 | la card del Test Archetipo |
| 872 | la card della Costellazione del Viso |
| 1433 | il Rito della Buonanotte |
| 1703 | la card dell'Animale Guida |
| 1928 | la card dell'Estrazione Rune |

Spente tutte e cinque e rigenerato il corredo. Verificato **sui pixel**: zero
anteprime hanno ancora rosso acceso nell'angolo in alto a destra.

`le_anteprime_non_montano_il_nastro_test.dart` impedisce il ritorno. E' una
prova **strutturale e non sui pixel**, perche' il nastro si dipinge solo in
debug e in un punto che dipende dalla direzione del testo: si guarda la causa,
cioe' il `MaterialApp` che non lo spegne, invece dell'effetto. Sorveglia anche
che `lib/app.dart` continui a spegnerlo, e in un punto solo. Due mutazioni viste
rosse.

## LE ANTEPRIME CHE MONTANO UNA SCENA CHE L'APP NON MONTA

**Voce a se', elencata e NON corretta**, come ordinato. La famiglia e' uscita
due volte in due giorni, quindi vale la pena sapere quanto e' larga.

Su **66 catture, 28 non passano dall'app vera**. Non sono tutte sbagliate: una
card da condividere e' fatta apposta per essere resa da sola, ed e' giusto
catturarla cosi'. Sono sbagliate quelle che dovrebbero mostrare una SCHERMATA e
invece mostrano un componente.

**Dieci costruiscono un `MaterialApp` nel corpo della cattura:**
righe 694 (card del Test Archetipo), 864 (card della Costellazione del Viso),
1695 (card dell'Animale Guida), 1919 (card dell'Estrazione Rune), 2084 (card
Oroscopo), 2227 (reveal elementale), 2296 (card Stesa), 2569 (il Profilo),
2706 (le catture dell'istante), 3556 (Le tue arti).

**Otto passano da `mountAnimal`:** 1605, 1618, 1636 (Animale Guida), 1848,
1858, 1884, 1895, 1906 (Estrazione Rune).

**Cinque da `mountRisveglio`:** 3139, 3149, 3165, 3184, 3226.

**Tre da `mountFace`:** 824, 833, 890 (Costellazione del Viso).

**Una da `natalHost`:** 3407 (il cielo reale di nascita).

**Una con `pumpWidget` diretto:** 3516 (la mano del tocco).

**IL CRITERIO, formulato sul FATTO e non sul nome.**

> **Un'anteprima deve essere montata come e' montato cio' che prova.**
>
> Una card da condividere e' resa da sola anche nell'app, quindi isolarla e'
> corretto. Una schermata nell'app non e' mai sola, quindi catturarla sola e'
> falso.

Il nome resta un buon indizio, **non il criterio**: altrimenti basterebbe
rinominare un file per farlo uscire dalla lista. Si guarda come la cosa vive
nell'app, non come si chiama il suo file.

Con quel taglio, oggi le sospette sono le schermate intere: il Risveglio (5),
la Costellazione del Viso (3), l'Animale Guida (3), l'Estrazione Rune (5).

## I numeri

Suite intera **1753 verdi** alla chiusura della Voce 3, e rieseguita dopo la
correzione delle anteprime. `analyze` 59 prima, 59 dopo. Tre anteprime a
1080x2391, piu' il corredo rigenerato. Nessuna build, `versionCode` intatto.

## IL CERCHIO VUOTO ACCANTO ALLA BOLLA, e le due classi che ha aperto

Visibile **solo grazie alla cattura vera**: nella chat di Aura l'icona
dell'utente era un cerchio vuoto, in quella di Medora la miniatura del segno.

**Non erano due porte.** `chat_bubble.dart:541` chiama `UserAvatar.forUser` per
tutte e tre le chat, e quella porta ha gia' quattro ripieghi in ordine
dichiarato. Era una porta sola che falliva in silenzio, per **due ragioni
diverse**, e vanno separate perche' una e' del corredo e una dell'app.

### 1. Il precache a mano era la porta che si riapriva

In cattura headless nessuno decodifica gli asset. La regola c'era, ed era
scritta a chiare lettere sopra il precache delle catture di Medora, con tanto
di spiegazione di cosa succede a chi se la dimentica. **E' successo lo stesso**,
non per distrazione ma perche' una regola che va ricordata a mano in ogni file
cade sempre.

Ora **`capture` precarica da solo**: percorre l'albero, raccoglie le immagini
che ci sono davvero e le precarica tutte prima di scattare. Nessuna cattura
nuova puo' nascere senza, perche' non c'e' niente da scrivere. Enumerare invece
di elencare a mano e' la stessa scelta fatta ovunque qui: l'elenco invecchia,
l'albero no.

**Al primo giro sono cadute cinquantotto catture.** `precacheImage` non lancia:
riporta il guasto a `FlutterError.onError`, e in una prova quello fa cadere il
test, quindi il `try` che avevo messo attorno non serviva a niente. L'errore va
passato al suo `onError`, ed e' scritto accanto al codice perche' non e'
ovvio.

### 2. Il ripiego muto era nell'app, non nella cattura

`ZodiacEmblem` aveva un `errorBuilder` che restituiva un `SizedBox` vuoto. Il
commento diceva che gli asset ci sono tutti, ed e' vero, ma **il ramo esisteva
lo stesso e scavalcava la catena**: quattro gradini dichiarati piu' un quinto,
non dichiarato, che li vinceva tutti e restituiva il nulla.

Adesso `ZodiacEmblem` accetta un `ripiego` e `UserAvatar` gli passa il gradino
successivo, cioe' iniziali e poi sigillo. **Se il glifo non si decodifica si
scende nella catena, non si cade fuori.**

**Cosa NON ho potuto chiudere.** Le altre due chiamate di `ZodiacEmblem` stanno
in `lib/features/horoscope/`, che quest'ordine mi vieta: li' il ripiego muto
sopravvive. E' nominato nel codice, cosi' chi tocchera' quei due punti lo trova
scritto invece di scoprirlo.

`licona_dellutente_e_decodificata_test.dart` pretende che il glifo sia
**DECODIFICATO** per tre segni, che l'arte esista su disco per tutti e dodici,
che la catena non sia scavalcabile, e che `capture` continui a precaricare da
solo. Tre mutazioni viste rosse.

## LA LUNA DI NASCITA: la frase dice il vero, e resta

Verificata la catena per intero, su richiesta:

- `NatalFacts.moonPhase` nasce da `details.dateTime`, cioe' **l'istante di
  nascita**, non da oggi;
- `MaestroPersona:373` scrive `- Fase lunare di nascita: ...` nel prompt, quindi
  il dato **parte davvero** verso il modello;
- `FrasiDellAttesa` mostra la riga solo se `pieno(natal.moonPhase)`: se il dato
  manca, la frase non compare gia' adesso.

**Nessuna modifica.** Il meccanismo che governa le frasi d'attesa e' quello
giusto e funzionava.

## VOCE IN CODA: il fuso della Luna di nascita, ricavato dalla longitudine

`NatalIdentity` non corregge l'istante di nascita col fuso vero del luogo, ma
con la longitudine divisa per quindici. Il commento lo dichiara e dice che sulla
sola fase lunare pesa meno di un'ora di Luna, che a occhio non si distingue.

**Non e' un difetto e non va toccata**, ma e' un'assunzione: messa qui perche'
chi la incontrera' la trovi gia' nominata invece di scoprirla e allarmarsi.

## I due rilievi sul disegno, NON corretti

Segnalati da Mauro guardando l'anteprima buona, e lasciati in sospeso perche'
sono giudizi d'occhio:

1. **Il petalo centrale scuro lascia un buco al centro del fiore.** Il velo di
   riempimento e' lo stesso per tutti i petali, ma quello centrale sta dritto e
   sovrapposto agli altri due, quindi il suo contorno si legge come un vuoto.
2. **Le due linee dell'acqua sono spezzate a meta'** e si leggono come un tratto
   interrotto invece che come acqua. Sono nate cosi' per lasciare respirare il
   fiore al centro, ma l'effetto e' un'altra cosa.

## Perche' mi sono fermato qui

Il margine di contesto era finito, e l'ordine dice di non aprire cio' che non si puo' chiudere ne' verificare. La modifica parziale della VOCE 2 e' stata **riportata indietro**, non lasciata a meta': l'albero di lavoro e' pulito, `flutter analyze` da' zero errori, e l'ultimo commit e' verde e spinto.
