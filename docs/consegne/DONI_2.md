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

**Dove si e' fermato il lavoro.** La costante `_dayAccent` va sostituita con una funzione che deriva l'accento da `gift.maestro`. Il lavoro e' stato iniziato e poi **riportato indietro di proposito**: delle undici occorrenze, sei stanno dentro widget annidati (`_BasePanel`, `_BaseRow` e gli altri) dove `gift` non e' in visibilita', quindi l'accento va passato loro come parametro. E' un lavoro breve ma va fatto e verificato in un colpo solo, e il margine non bastava.

## VOCE 3, aperta e non iniziata

L'emblema di Aura, con la decisione gia' presa da Mauro:

- l'invito piu' evidente, **corpo 16** invece di 14, e la scena tenuta aperta piu' a lungo. Oggi l'invito e' `TypographyTokens.body(size: 14)` in oro all'85% di alpha, `consulto_del_cielo_view.dart:265`, e dura quanto la scena, cioe' `durataBattuta 2000ms x battuteDellaScena 2` = quattro secondi;
- **fiore piu' invito**, non il solo fiore;
- **strada A**, il loto disegnato in codice come `CustomPainter` in oro, che entra nello stesso ritaglio dall'alto degli altri simboli. `_SimboloCheSiCompone` oggi riceve un `Image.asset` e va reso capace di accettare un widget qualunque;
- **il loto non esiste come asset**, verificato il 6 agosto 2026: nessun file con "lot", "loto" o "lotus" in `assets/` ne' in `brand_assets/`. La strada A e' stata scelta sapendo che un loto vettoriale in oro piatto si vedra' che e' un'altra cosa accanto all'arte Total Metal degli altri simboli.

**E va riscritta la regola in `simbolo_dellattesa.dart`, nello stesso commit del loto.** Oggi quel file si rifiuta per principio di mostrare qualcosa ad Aura senza Test, e la ragione scritta e' che un simbolo al posto dell'archetipo dichiarerebbe alla persona un archetipo che non ha. Il loto regge perche' **non e' uno dei dodici archetipi: e' il fiore che aspetta di aprirsi**, quindi non dichiara niente di falso. Se la regola non viene riscritta insieme, resta li' a dire il contrario di quello che il codice fa.

## Le anteprime, non fatte

Nessuna delle tre. Dipendono tutte dalle voci 2 e 3.

## Perche' mi sono fermato qui

Il margine di contesto era finito, e l'ordine dice di non aprire cio' che non si puo' chiudere ne' verificare. La modifica parziale della VOCE 2 e' stata **riportata indietro**, non lasciata a meta': l'albero di lavoro e' pulito, `flutter analyze` da' zero errori, e l'ultimo commit e' verde e spinto.
