import 'package:flutter/material.dart';

import '../theme/maestro_palette.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/typography_tokens.dart';

/// **DA DOVE VIENE UN BLOCCO DI TESTO.** Ordine CS voce S5.
///
/// **Il difetto che questo segno chiude.** Il corpus degli Angeli porta una
/// confidenza per voce e dice di se stesso che le chiavi di lettura *"sono
/// scritte in redazione, non sono tradizione documentata [...] Vanno mostrate
/// come chiave di lettura del Maestro, mai attribuite alla tradizione"*.
/// Quella distinzione esisteva nel corpus, non a video: la persona leggeva un
/// salmo del 1823 e una lettura scritta oggi con lo stesso carattere, uno sotto
/// l'altra, e nulla diceva che sono due cose diverse.
///
/// **Perche' un segno solo e non uno per schermata.** La scheda degli Angeli la
/// distinzione la faceva gia', a mano, con la riga "MEDORA LA LEGGE COSI'";
/// l'angelo ingrandito, che mostra gli stessi campi, non la faceva affatto.
/// Due superfici che mostrano lo stesso dato in due modi diversi sono due
/// verita', ed e' la famiglia di difetti che questo progetto insegue da sempre.
///
/// **Non e' un avvertimento e non e' una scusa.** Dire "questo viene da Lenain,
/// 1823" e dire "questa e' la lettura di Medora" sono tutte e due affermazioni
/// positive: la prima porta il peso di una fonte, la seconda porta il valore di
/// una voce. Il segno non toglie autorita' a niente, la attribuisce.
enum Provenienza {
  /// Viene da una fonte, e la fonte si nomina.
  tradizione,

  /// La scrive il Cerchio, e si mostra come voce del Maestro.
  cerchio,
}

/// La riga che dice da dove nasce il blocco che le sta sotto.
class SegnoDellaProvenienza extends StatelessWidget {
  const SegnoDellaProvenienza({
    super.key,
    required this.provenienza,
    required this.palette,
    this.dettaglio,
  });

  final Provenienza provenienza;
  final MaestroPalette palette;

  /// Il nome della fonte quando la provenienza e' la tradizione, oppure il modo
  /// in cui il Maestro si nomina quando la scrive il Cerchio. Nullo, il segno
  /// dice comunque la famiglia: meglio una parola sola che nessuna.
  final String? dettaglio;

  /// La riga cosi' come si legge, senza il colore: serve alle prove e a chi
  /// deve confrontare due superfici senza montarle tutte e due.
  static String rigaDi(Provenienza provenienza, {String? dettaglio}) {
    final d = dettaglio?.trim();
    switch (provenienza) {
      case Provenienza.tradizione:
        return d == null || d.isEmpty
            ? 'DALLA TRADIZIONE'
            : 'DALLA TRADIZIONE · ${d.toUpperCase()}';
      case Provenienza.cerchio:
        return d == null || d.isEmpty
            ? 'LO LEGGE IL CERCHIO'
            : d.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(
        rigaDi(provenienza, dettaglio: dettaglio),
        key: Key(provenienza == Provenienza.tradizione
            ? 'segno_dalla_tradizione'
            : 'segno_dal_cerchio'),
        style: TypographyTokens.etichetta()
            .copyWith(color: palette.goldSoft, letterSpacing: 2),
      ),
    );
  }
}

/// Un blocco di testo col suo segno sopra, per le schermate che mostrano piu'
/// voci di provenienza diversa una sotto l'altra.
class VoceConProvenienza extends StatelessWidget {
  const VoceConProvenienza({
    super.key,
    required this.provenienza,
    required this.palette,
    required this.figlio,
    this.dettaglio,
  });

  final Provenienza provenienza;
  final MaestroPalette palette;
  final String? dettaglio;
  final Widget figlio;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegnoDellaProvenienza(
            provenienza: provenienza,
            palette: palette,
            dettaglio: dettaglio),
        const SizedBox(height: SpacingTokens.xs),
        figlio,
      ],
    );
  }
}
