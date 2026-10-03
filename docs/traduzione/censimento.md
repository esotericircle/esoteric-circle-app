# Censimento delle stringhe rivolte alla persona

<!-- TOTALE_STRINGHE: 8856 -->
<!-- NEI_CORPUS: 7080 -->
<!-- NEL_CODICE: 1776 -->
<!-- CON_ACCORDO: 133 -->
<!-- DA_UN_SISTEMA_DI_TRADUZIONE: 0 -->
<!-- FILE_TOCCATI: 374 -->
<!-- Generato da tool/censimento_stringhe.dart. Non si scrive a mano: si rigenera. -->

Ordine CE voce 15. **Questa voce non traduce niente**, e non aggiunge nessun pacchetto: misura quanto costerebbe tradurre, cosi' la decisione si prende su un numero invece che su un'impressione.

## I cinque numeri

| grandezza | valore |
| --- | --- |
| Stringhe rivolte alla persona | **8856** |
| Che portano CONTENUTO, sotto `lib/core` e `lib/services` | **7080** |
| Che portano INTERFACCIA, sotto `lib/features` e `lib/design_system` | **1776** |
| Che cambiano con genere o numero | **133** |
| Che passano da un sistema di traduzione | **0** |
| File che ne contengono | **374** |

## Il metodo, e cosa NON conta

Si leggono i letterali di `lib/`, saltando i commenti. Una stringa conta come rivolta alla persona se **contiene almeno due parole di lettere e almeno uno spazio**: e' la soglia che tiene fuori i nomi di chiave, i percorsi degli asset, gli identificativi e le costanti tecniche, che sono la maggioranza dei letterali di un programma e non si traducono.

Restano fuori per costruzione: le stringhe di una riga sola senza spazi, quelle che sembrano un percorso o una chiave (contengono `/`, `_`, `.dart`, `http`), e quelle sotto le tre lettere.

**Il numero e' una stima per difetto e per eccesso insieme**, e va detto: una frase spezzata su tre righe conta tre volte, e una chiave scritta a parole conta come frase. Serve a dare l'ordine di grandezza, non il preventivo al centesimo.

## Cosa cambia con chi legge

Sono le stringhe piu' care da tradurre, perche' una lingua diversa accorda in modo diverso. Si riconoscono da tre segni: un'interpolazione accanto a una parola che potrebbe volgere al plurale, un accordo di genere scritto a mano (`/a`, `/o`), e la chiamata alla `d` eufonica, che e' una regola dell'italiano e in un'altra lingua non esiste.

## COSA DICE QUESTO CENSIMENTO

La domanda del fondatore e' se l'internazionalizzazione sia un ordine o tre. **Il censimento risponde: sono due lavori di taglia molto diversa, e vanno separati.**

**L'INTERFACCIA e' un ordine solo.** Sono 1776 stringhe, corte, ripetute e senza contenuto esoterico: pulsanti, etichette, titoli, avvisi. Un traduttore le fa con un glossario, e un sistema di localizzazione le regge tutte.

**IL CONTENUTO NON E' UN ORDINE, e' un progetto.** Sono 7080 stringhe, cioe' 80 per cento del totale, e non sono frasi da tradurre: sono i responsi dei tarocchi, il sapere delle rune, i nomi e le voci degli angeli, i sentieri, l'oroscopo, i testi della sinastria. **Tradurli e' riscrivere un corpus esoterico in un'altra lingua**, e chi lo fa deve conoscere la tradizione in quella lingua, non solo la lingua. Un traduttore generico qui produce testo corretto e falso.

**E c'e' un terzo lavoro, piccolo di numero e grande di rischio: l'accordo.** Sono 133 punti in cui la frase cambia con chi legge o con quanti sono. In italiano si risolvono con un plurale e una `d` eufonica; in una lingua che declina, o che ha generi diversi dai nostri due, ognuno di questi punti e' una decisione. Vanno affrontati PRIMA di tradurre, perche' decidono la forma delle chiavi.

## Da dove conviene cominciare

| file | stringhe |
| --- | --- |
| `lib/core/tarot/tarot_card.dart` | 364 |
| `lib/core/viaggio/la_voce_del_mondo_di_sotto.dart` | 346 |
| `lib/core/angels/angel_lore.dart` | 289 |
| `lib/core/sigilli/sentiero_albero.dart` | 264 |
| `lib/core/sigilli/sentiero_loto.dart` | 262 |
| `lib/core/sigilli/sentiero_costellazione.dart` | 262 |
| `lib/core/tarot/voce_della_stesa.dart` | 261 |
| `lib/core/synastry/testi_della_sinastria.dart` | 250 |
| `lib/core/rituals/rito_alba_corpus.dart` | 243 |
| `lib/core/rituals/rune_lore.g.dart` | 195 |
| `lib/core/horoscope/horoscope_data.dart` | 155 |
| `lib/services/ai/impronta_dell_istruzione.dart` | 145 |
| `lib/core/entitlement/plan_catalog.dart` | 130 |
| `lib/core/synastry/vip_catalog.dart` | 129 |
| `lib/core/rituals/rune_presage.dart` | 126 |
| `lib/features/account/account_screen.dart` | 106 |
| `lib/core/arts/art_catalog.dart` | 105 |
| `lib/services/ai/maestro_persona.dart` | 103 |
| `lib/core/viaggio/la_scena_dal_modello.dart` | 102 |
| `lib/core/maestro/voce_del_maestro.dart` | 101 |

## Che cosa c'e' e che cosa no, MISURATO a ogni giro

| cosa | c'e' |
| --- | --- |
| file `.arb` nel repository | no |
| cartella `lib/l10n` | no |
| dipendenza `intl` | si |
| dipendenza `flutter_localizations` | si |
| `supportedLocales` dichiarati nell'app | si |

**L'IMPALCATURA C'E', E I TESTI NON CI PASSANO ANCORA.** Ordine DM, 16 settembre 2026: l'app e' predisposta al multilingua, non tradotta. I delegati di sistema, il separatore decimale, la lingua della risposta del modello e la marca del genere leggono la lingua da una porta sola; il corpus editoriale resta italiano.

Le stringhe che passano da un sistema di traduzione sono **0**: l'impalcatura regge un peso che non le e' ancora stato messo sopra, ed e' esattamente cio' che quell'ordine voleva.
