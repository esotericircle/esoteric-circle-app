import 'package:flutter/material.dart';

import '../../../design_system/transizioni/velo_del_cerchio.dart';
import '../../../design_system/theme/maestro_palette.dart';
import '../../../design_system/tokens/color_tokens.dart';
import '../../../design_system/tokens/spacing_tokens.dart';
import '../../../design_system/tokens/typography_tokens.dart';

/// **FONTI E METODO, DA UNA PORTA SOLA.** Ordine CS, voce S2 della scansione,
/// 7 settembre 2026.
///
/// **Perche' nasce.** La scansione ha misurato che **quattro arti attive non
/// dichiaravano nessuna fonte a video**: la Stesa di Tarocchi, la Sinastria
/// VIP, il Sigillo dell'Intenzione e il Soffio del Destino. E' lo stesso
/// difetto che ha aperto l'ordine CS, quando il fondatore ha letto nel tooltip
/// degli Angeli che le tavole originali non erano state consultate.
///
/// **Il caso piu' netto era il Sigillo**, perche' la fonte c'era e non
/// arrivava a chi legge: il commento in testa alla sua schermata nomina Austin
/// Osman Spare e la Rosa dei Petali della Golden Dawn, due tradizioni precise,
/// scritte nel codice e mai a video.
///
/// **Perche' una porta sola.** Cinque schermate si erano scritte ognuna il
/// proprio foglio, quaranta righe l'una. Aggiungerne altre quattro uguali
/// vorrebbe dire nove copie della stessa cosa, e alla prossima modifica del
/// tono se ne aggiornerebbero otto su nove. Le cinque esistenti restano dove
/// sono, perche' funzionano e toccarle e' lavoro a se': le nuove passano di
/// qui.
class FoglioDelleFonti {
  const FoglioDelleFonti._();

  /// Apre il foglio delle fonti di un'arte.
  ///
  /// [testo] e' cio' che la persona legge: la tradizione con nome e opera, il
  /// metodo, e cosa e' curatela del Cerchio invece che tradizione. **Non e' il
  /// posto delle scuse**: il metodo e i suoi limiti stanno nei documenti,
  /// questo foglio dice da dove nasce cio' che si sta leggendo.
  static Future<void> apri(
    BuildContext context, {
    required MaestroPalette palette,
    required String testo,
    required String chiave,
  }) {
    return foglioDelCerchio<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheet) => Container(
        key: Key(chiave),
        padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, SpacingTokens.md,
            SpacingTokens.lg, SpacingTokens.xl),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [palette.surfaceElevated, palette.deepest],
          ),
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(SpacingTokens.radiusXl)),
          border: Border.all(color: palette.gold.withValues(alpha: 0.3)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fonti e metodo',
                    style: TypographyTokens.titoloScheda()
                        .copyWith(color: palette.goldSoft)),
                const SizedBox(height: SpacingTokens.sm),
                Text(testo,
                    style: TypographyTokens.didascalia().copyWith(
                        color: ColorTokens.textPrimary, height: 1.45)),
                const SizedBox(height: SpacingTokens.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Il comando che apre il foglio: la stessa icona discreta delle altre arti.
  static Widget bottone(
    BuildContext context, {
    required MaestroPalette palette,
    required String testo,
    required String chiave,
  }) {
    return IconButton(
      key: Key('${chiave}_bottone'),
      icon: const Icon(Icons.info_outline_rounded),
      tooltip: 'Fonti e metodo',
      onPressed: () =>
          apri(context, palette: palette, testo: testo, chiave: chiave),
    );
  }
}

/// **I TESTI DELLE QUATTRO ARTI.** Ordine CS voce S2.
///
/// Ogni riga nomina l'opera e l'autore, dice cosa fa il calcolo, e distingue
/// cio' che viene dalla tradizione da cio' che scrive il Cerchio. Le fonti non
/// sono state scelte a memoria: sono quelle che il codice gia' usava, lette
/// nei suoi commenti e verificate sul comportamento.
class TestiDelleFonti {
  const TestiDelleFonti._();

  /// La Stesa di Tarocchi a tre carte.
  static const String tarocchi =
      'Le settantotto carte seguono il mazzo Rider-Waite-Smith, disegnato nel '
      '1909 da Pamela Colman Smith su indicazione di Arthur Edward Waite: è il '
      'mazzo su cui si regge quasi tutta la cartomanzia moderna: è quello '
      'che questa app illustra.\n\n'
      'La stesa a tre carte è la forma più antica e più semplice della '
      'lettura: tre posizioni, una domanda sola. Il dritto e il rovescio sono '
      'due letture della stessa carta: il rovescio non è una condanna, è un '
      'nodo da sciogliere.\n\n'
      'Le carte escono da un mescolamento vero, che parte dalla tua domanda e '
      'dal momento in cui la fai. Le parole con cui Medora le racconta sono '
      'curatela del Cerchio, scritte sul senso tradizionale di ogni carta.';

  /// La Sinastria VIP.
  static const String sinastria =
      'Le affinità nascono dalla sinastria, cioè dal confronto fra due cieli '
      'di nascita. Ogni barra poggia su una dottrina dichiarata.\n\n'
      'Terra comune viene dai quattro elementi, come Tolomeo li fissa nel '
      'Tetrabiblos I.17-18: fuoco e aria si sostengono; terra e acqua si '
      'sostengono. È la più antica misura di compatibilità che l\'astrologia '
      'conosca. Non dice se vi amate: dice se vi capite senza spiegarvi.\n\n'
      'Ritmo viene dalle qualità cardinale, fissa e mobile, dalla stessa opera, '
      'I.12. Vita quotidiana guarda gli aspetti della Luna e dell\'Ascendente, '
      'che la tradizione lega alle abitudini e al modo di presentarsi.\n\n'
      'I cieli dei personaggi vengono dalle loro date di nascita pubbliche. È '
      'un gioco simbolico di intrattenimento, non una previsione.';

  /// Il Sigillo dell'Intenzione.
  static const String sigillo =
      'Il metodo è quello di Austin Osman Spare, l\'artista inglese che nei '
      'primi del Novecento insegnò a ridurre una frase di intenzione alle sue '
      'lettere per intrecciarle in un unico segno.\n\n'
      'La ruota su cui le lettere si dispongono è la Rosa dei Petali della '
      'Golden Dawn, lo schema con cui quell\'ordine legava l\'alfabeto ebraico '
      'a una figura di petali concentrici.\n\n'
      'Il glifo che ne esce è tuo e di nessun altro: nasce dalle lettere della '
      'frase che hai scritto, quindi due intenzioni diverse non possono dare '
      'lo stesso segno.';

  /// L'Oroscopo Personalizzato.
  static const String oroscopo =
      'Le quattro schede nascono dal cielo vero di oggi sopra la tua carta '
      'di nascita: gli aspetti che i pianeti di adesso formano coi tuoi '
      'punti natali, la casa che ognuno sta attraversando e chi è '
      'retrogrado.\n\n'
      'La carta di nascita si calcola sulle effemeridi svizzere, lo '
      'standard astronomico che l\'astrologia usa da decenni; i transiti '
      'del giorno si calcolano sul dispositivo, senza rete.\n\n'
      'La lettura segue l\'astrologia occidentale, quella dei dodici '
      'segni e delle dodici case. Le parole con cui Medora la racconta '
      'sono curatela del Cerchio: il cielo dice dove sono i pianeti, non '
      'cosa farne.\n\n';
      // **IL RIPIEGO NON SI DICE QUI.** La schermata lo dichiara gia' sotto
      // le schede leggendo il livello dalla porta unica, `CieloDiOggi`:
      // ripeterlo in un testo fisso vorrebbe dire tenere due verita' sullo
      // stesso fatto, e la seconda invecchia da sola.

  /// La Meditazione.
  static const String meditazione =
      'I toni che senti sono generati dal dispositivo in tempo reale: 432 '
      'e 528 hertz, insieme a un battito binaurale che nasce dalla piccola '
      'differenza fra l\'orecchio destro e il sinistro, per questo '
      'servono le cuffie.\n\n'
      'Il 432 e le frequenze Solfeggio appartengono a una tradizione '
      'culturale della musica e del suono, non alla medicina: qui stanno '
      'per quello che sono, una cornice di benessere.\n\n'
      'Il mandala che vedi non è un\'animazione preparata: è cimatica, '
      'cioè la figura che quel suono disegna. Pulsa col respiro che la '
      'guida ti propone.';

  /// Il Soffio del Destino.
  static const String soffio =
      'Le due righe del Soffio nascono dai transiti veri di oggi sul tuo cielo '
      'di nascita: gli aspetti che i pianeti di adesso formano coi tuoi punti '
      'natali, calcolati sul dispositivo dalle effemeridi, senza rete.\n\n'
      'È la stessa sorgente dell\'Oroscopo. Non ne esiste una seconda: due '
      'porte sullo stesso cielo potrebbero dire due cose diverse nella stessa '
      'mattina.\n\n'
      'Un aspetto morbido apre la prima riga, uno teso apre la seconda. Se il '
      'cielo di oggi non ne offre, quella riga non compare: il Soffio dice '
      'come sta il cielo e cosa farne lo decidi tu.';
}
