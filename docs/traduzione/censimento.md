# Censimento delle stringhe rivolte alla persona

<!-- TOTALE_STRINGHE: 6751 -->
<!-- NEI_CORPUS: 5324 -->
<!-- NEL_CODICE: 1427 -->
<!-- CON_ACCORDO: 96 -->
<!-- DA_UN_SISTEMA_DI_TRADUZIONE: 0 -->
<!-- FILE_TOCCATI: 283 -->
<!-- Generato da tool/censimento_stringhe.dart. Non si scrive a mano: si rigenera. -->

Ordine CE voce 15. **Questa voce non traduce niente**, e non aggiunge nessun pacchetto: misura quanto costerebbe tradurre, cosi' la decisione si prende su un numero invece che su un'impressione.

## I cinque numeri

| grandezza | valore |
| --- | --- |
| Stringhe rivolte alla persona | **6751** |
| Che portano CONTENUTO, sotto `lib/core` e `lib/services` | **5324** |
| Che portano INTERFACCIA, sotto `lib/features` e `lib/design_system` | **1427** |
| Che cambiano con genere o numero | **96** |
| Che passano da un sistema di traduzione | **0** |
| File che ne contengono | **283** |

## Il metodo, e cosa NON conta

Si leggono i letterali di `lib/`, saltando i commenti. Una stringa conta come rivolta alla persona se **contiene almeno due parole di lettere e almeno uno spazio**: e' la soglia che tiene fuori i nomi di chiave, i percorsi degli asset, gli identificativi e le costanti tecniche, che sono la maggioranza dei letterali di un programma e non si traducono.

Restano fuori per costruzione: le stringhe di una riga sola senza spazi, quelle che sembrano un percorso o una chiave (contengono `/`, `_`, `.dart`, `http`), e quelle sotto le tre lettere.

**Il numero e' una stima per difetto e per eccesso insieme**, e va detto: una frase spezzata su tre righe conta tre volte, e una chiave scritta a parole conta come frase. Serve a dare l'ordine di grandezza, non il preventivo al centesimo.

## Cosa cambia con chi legge

Sono le stringhe piu' care da tradurre, perche' una lingua diversa accorda in modo diverso. Si riconoscono da tre segni: un'interpolazione accanto a una parola che potrebbe volgere al plurale, un accordo di genere scritto a mano (`/a`, `/o`), e la chiamata alla `d` eufonica, che e' una regola dell'italiano e in un'altra lingua non esiste.

## COSA DICE QUESTO CENSIMENTO

La domanda del fondatore e' se l'internazionalizzazione sia un ordine o tre. **Il censimento risponde: sono due lavori di taglia molto diversa, e vanno separati.**

**L'INTERFACCIA e' un ordine solo.** Sono 1427 stringhe, corte, ripetute e senza contenuto esoterico: pulsanti, etichette, titoli, avvisi. Un traduttore le fa con un glossario, e un sistema di localizzazione le regge tutte.

**IL CONTENUTO NON E' UN ORDINE, e' un progetto.** Sono 5324 stringhe, cioe' 79 per cento del totale, e non sono frasi da tradurre: sono i responsi dei tarocchi, il sapere delle rune, i nomi e le voci degli angeli, i sentieri, l'oroscopo, i testi della sinastria. **Tradurli e' riscrivere un corpus esoterico in un'altra lingua**, e chi lo fa deve conoscere la tradizione in quella lingua, non solo la lingua. Un traduttore generico qui produce testo corretto e falso.

**E c'e' un terzo lavoro, piccolo di numero e grande di rischio: l'accordo.** Sono 96 punti in cui la frase cambia con chi legge o con quanti sono. In italiano si risolvono con un plurale e una `d` eufonica; in una lingua che declina, o che ha generi diversi dai nostri due, ognuno di questi punti e' una decisione. Vanno affrontati PRIMA di tradurre, perche' decidono la forma delle chiavi.

## Da dove conviene cominciare

| file | stringhe |
| --- | --- |
| `lib/core/tarot/tarot_card.dart` | 364 |
| `lib/core/sigilli/sentiero_albero.dart` | 295 |
| `lib/core/sigilli/sentiero_costellazione.dart` | 291 |
| `lib/core/sigilli/sentiero_loto.dart` | 289 |
| `lib/core/angels/angel_lore.dart` | 288 |
| `lib/core/rituals/rito_alba_corpus.dart` | 241 |
| `lib/core/synastry/testi_della_sinastria.dart` | 221 |
| `lib/core/rituals/rune_lore.g.dart` | 195 |
| `lib/core/horoscope/horoscope_data.dart` | 155 |
| `lib/core/synastry/vip_catalog.dart` | 129 |
| `lib/core/entitlement/plan_catalog.dart` | 125 |
| `lib/services/ai/impronta_dell_istruzione.dart` | 122 |
| `lib/services/ai/maestro_persona.dart` | 111 |
| `lib/core/arts/art_catalog.dart` | 106 |
| `lib/core/maestro/voce_del_maestro.dart` | 102 |
| `lib/features/account/account_screen.dart` | 100 |
| `lib/core/domande/cornici_del_presagio.dart` | 88 |
| `lib/core/legal/privacy_policy.dart` | 83 |
| `lib/core/astro/lingua_degli_eventi.dart` | 83 |
| `lib/core/domande/domande_del_cerchio.dart` | 78 |

## Cosa NON esiste oggi, verificato

- Nessun file `.arb` nel repository.
- Nessuna cartella `lib/l10n`.
- Nessuna dipendenza `intl` o `flutter_localizations` in `pubspec.yaml`.
- Nessuna `Locale` dichiarata nell'app.

Quindi le stringhe che passano da un sistema di traduzione sono **0**, e non e' una stima: e' un conto su un sistema che non c'e'.
