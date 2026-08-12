import 'package:flutter/material.dart';

import '../../core/sigilli/sentieri.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';

/// LE TRE RIGHE SOTTO IL DISEGNO. Ordine S voce 03.
///
/// **Il difetto: chi apre un sentiero non sa cosa sta guardando.** Il disegno e'
/// bello e muto, la lista dice cosa manca ma non dove sei, e nessuno dice cosa si
/// guadagna arrivandoci. E' la voce che risponde alla domanda principe su questa
/// schermata, perche' **una persona torna se sa quanto le manca e cosa ottiene**:
/// oggi non sa ne' l'uno ne' l'altro.
///
/// **Tre righe brevi e non un pannello di aiuto.** Se cresce oltre tre righe e'
/// sbagliata: non e' un tutorial, e la schermata non ha bisogno di essere
/// spiegata. Vivono in un punto solo e i tre sentieri le compongono dalla STESSA
/// struttura, cambiando la sola voce del Maestro: scritte tre volte, divergerebbero
/// al primo ripensamento.
///
/// **La riga "cosa vedi" NON spiega come funziona il disegno.** Adesso che il
/// disegno e' buono, spiegarne il meccanismo lo insulterebbe: dice cosa E' la
/// figura, in una frase del Maestro. Una riga che spiega una cosa che si capisce
/// guardandola e' un tutorial appoggiato sopra un disegno.
class LeTreRigheDelSentiero extends StatelessWidget {
  const LeTreRigheDelSentiero({
    super.key,
    required this.sentiero,
    required this.accesi,
    required this.palette,
  });

  final Sentiero sentiero;

  /// Quanti traguardi sono accesi, mini e grandi insieme: il conto e' uno solo.
  final int accesi;

  final MaestroPalette palette;

  /// COSA E' LA FIGURA, una frase per Maestro. Non come funziona.
  ///
  /// **NON SI DICHIARA UNICO CIO' CHE UNICO NON E', ed e' una differenza fra i
  /// tre.** La Costellazione personale e' inventata e nel cielo di nessun altro
  /// esiste, quindi la sua riga puo' dirlo. L'Albero della Vita no: le dieci
  /// Sefirot, i ventidue sentieri e la loro disposizione sono gli stessi per
  /// chiunque, e una riga che lasciasse intendere che quell'albero e' solo tuo
  /// direbbe il falso, nella stessa famiglia dell'avviso che diceva alla persona
  /// che l'app non sapeva chi fosse. Il loto e' un simbolo condiviso, in misura
  /// minore.
  ///
  /// **Cio' che e' unico nei due casi non e' la figura: sono i frutti che quella
  /// persona ha maturato e i petali che ha aperto.** La struttura e' di tutti, il
  /// cammino sopra e' suo, e le righe lo dicono in quest'ordine.
  static String cosaVedi(Sentiero sentiero) => switch (sentiero) {
        Sentiero.costellazione =>
          // Nessuna virgola prima della "e": la regola della lingua di casa
          // vale su tutte le stringhe del codice, e la guardia la sorveglia.
          'Nessun altro cielo ha questa figura: è la tua e la disegni tu.',
        Sentiero.albero =>
          'Un albero cresce dove lo curi: questo porta i tuoi frutti.',
        Sentiero.loto =>
          'Il loto è un simbolo di tutti: questi petali li hai aperti tu.',
      };

  /// COME SI CHIAMANO I PUNTI di questa figura, al plurale e al singolare.
  static ({String uno, String molti}) nomeDeiPunti(Sentiero sentiero) =>
      switch (sentiero) {
        Sentiero.costellazione => (uno: 'stella', molti: 'stelle'),
        Sentiero.albero => (uno: 'frutto', molti: 'frutti'),
        Sentiero.loto => (uno: 'petalo', molti: 'petali'),
      };

  /// DOVE SEI, col numero letto dal dato e scritto in parole.
  static String doveSei(Sentiero sentiero, int accesi) {
    final nome = nomeDeiPunti(sentiero);
    final quanti = Sentieri.quantiInTutto(sentiero);
    if (accesi == 0) {
      return 'Nessun${nome.uno == 'stella' ? 'a' : ''} ${nome.uno} '
          'ancora acces${nome.uno == 'stella' ? 'a' : 'o'}, '
          'su ${inParole(quanti)}.';
    }
    final acceseLa = nome.uno == 'stella' ? 'accese' : 'accesi';
    return '${inParole(accesi).substring(0, 1).toUpperCase()}'
        '${inParole(accesi).substring(1)} ${nome.molti} $acceseLa '
        'su ${inParole(quanti)}.';
  }

  /// COSA GUADAGNI, detto una volta e senza insistere.
  static const String cosaGuadagni =
      'Ogni traguardo porta Eos. Condividerlo ne porta altri.';

  /// I NUMERI IN PAROLE, da zero a cinquantacinque.
  ///
  /// **Serve un intervallo chiuso e basta**: i traguardi di un sentiero sono
  /// cinquantacinque, quindi non serve un convertitore generale e non si aggiunge
  /// una dipendenza per scrivere una parola. Fuori dall'intervallo si torna alla
  /// cifra, che e' brutto ma vero.
  static String inParole(int n) {
    const unita = [
      'zero', 'uno', 'due', 'tre', 'quattro', 'cinque', 'sei', 'sette', 'otto',
      'nove', 'dieci', 'undici', 'dodici', 'tredici', 'quattordici', 'quindici',
      'sedici', 'diciassette', 'diciotto', 'diciannove',
    ];
    const decine = [
      '', '', 'venti', 'trenta', 'quaranta', 'cinquanta',
    ];
    if (n < 0 || n > 59) return '$n';
    if (n < 20) return unita[n];
    final d = n ~/ 10;
    final u = n % 10;
    if (u == 0) return decine[d];
    // Venti piu' uno fa ventuno, non ventiuno: la vocale cade.
    if (u == 1 || u == 8) {
      return decine[d].substring(0, decine[d].length - 1) + unita[u];
    }
    return decine[d] + unita[u];
  }

  @override
  Widget build(BuildContext context) {
    final righe = <String>[
      doveSei(sentiero, accesi),
      cosaVedi(sentiero),
      cosaGuadagni,
    ];
    return Padding(
      key: const Key('sentiero_tre_righe'),
      padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.lg, vertical: SpacingTokens.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LA PRIMA RIGA E' UN NUMERO E SI VEDE: e' la risposta a "quanto mi
          // manca", che e' la ragione per cui una persona torna.
          Text(righe[0],
              key: const Key('sentiero_dove_sei'),
              style: TypographyTokens.corpo()
                  .copyWith(color: palette.goldSoft, height: 1.35)),
          const SizedBox(height: SpacingTokens.xxs),
          Text(righe[1],
              key: const Key('sentiero_cosa_vedi'),
              style: TypographyTokens.didascalia()
                  .copyWith(color: ColorTokens.textPrimary, height: 1.35)),
          const SizedBox(height: SpacingTokens.xxs),
          Text(righe[2],
              key: const Key('sentiero_cosa_guadagni'),
              style: TypographyTokens.didascalia()
                  .copyWith(color: ColorTokens.textSecondary, height: 1.35)),
        ],
      ),
    );
  }
}
