import 'package:flutter/material.dart';

import '../theme/maestro_palette.dart';
import '../tokens/color_tokens.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/typography_tokens.dart';
import 'riquadro_arancione.dart';
import 'riquadro_in_evidenza.dart';

/// **IL RESPONSO IN TRE PARAGRAFI, col secondo nel riquadro e il "da dove
/// viene" in fondo.** Ordine FK, aggiunta voce A2, 11 ottobre 2026.
///
/// Il fondatore: *"Prendi spunto dalle risposte dell'oroscopo come
/// formattazione: 3 paragrafi, il secondo e' evidenziato in riquadro e solo
/// alla fine un piccolo paragrafo in corsivo 'da dove viene'."*
///
/// La forma e' presa dall'Oroscopo vero: il riquadro e' `RiquadroInEvidenza`,
/// lo stesso fondo appena dorato col filo d'oro; il "da dove viene" porta la
/// sua etichetta e il ruolo `didascalia`, come la riga del livello delle
/// schede del giorno, **in corsivo** perche' cosi' l'ha chiesto il fondatore.
/// Il formato scritto sta in `docs/responsi/il_titolo_e_il_formato.md`.
///
/// I paragrafi sono tre e non si spezzano in blocchi per righe: *"non si
/// parla di righe ma di paragrafi"*.
class ResponsoInTreParagrafi extends StatelessWidget {
  const ResponsoInTreParagrafi({
    super.key,
    required this.paragrafi,
    required this.stile,
    this.daDoveViene,
    this.palette,
    this.approfondimento = const [],
  });

  final List<String> paragrafi;
  final TextStyle stile;

  /// Il paragrafo piccolo in fondo: da dove viene la lettura.
  final String? daDoveViene;
  final MaestroPalette? palette;

  /// **I DUE PARAGRAFI DELL'APPROFONDIMENTO DELLA LUNGA, nel riquadro
  /// arancione.** Ordine FN, 13 ottobre 2026. Vuoto alla profondita' Breve:
  /// niente riquadro, il responso resta quello di sempre.
  final List<String> approfondimento;

  /// Quale paragrafo va nel riquadro, contando da zero: il secondo dei tre.
  static bool eInEvidenza(int indice, int quanti) => quanti == 3 && indice == 1;

  @override
  Widget build(BuildContext context) {
    final distanza = (stile.fontSize ?? TypographyTokens.pavimento) * 1.2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < paragrafi.length; i++) ...[
          if (i > 0) SizedBox(height: distanza),
          if (eInEvidenza(i, paragrafi.length))
            RiquadroInEvidenza(
              palette: palette,
              child: Text(paragrafi[i],
                  key: Key('responso_paragrafo_$i'), style: stile),
            )
          else
            Text(paragrafi[i], key: Key('responso_paragrafo_$i'), style: stile),
        ],
        // **L'APPROFONDIMENTO DELLA LUNGA, ordine FN.** Due paragrafi, un
        // riquadro solo: il fondatore ha detto "un riquadro arancione", non
        // uno per paragrafo.
        if (approfondimento.length >= 2) ...[
          SizedBox(height: distanza),
          RiquadroArancione(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(approfondimento[0],
                    key: const Key('responso_approfondimento_0'),
                    style: stile),
                SizedBox(height: distanza),
                Text(approfondimento[1],
                    key: const Key('responso_approfondimento_1'),
                    style: stile),
              ],
            ),
          ),
        ],
        if (daDoveViene != null && daDoveViene!.trim().isNotEmpty) ...[
          SizedBox(height: distanza),
          Text('Da dove viene',
              style: TypographyTokens.etichetta().copyWith(
                  color: ColorTokens.textSecondary, letterSpacing: 1.2)),
          const SizedBox(height: SpacingTokens.xxs),
          Text(daDoveViene!,
              key: const Key('responso_da_dove_viene'),
              style: TypographyTokens.didascalia().copyWith(
                  color: ColorTokens.textSecondary,
                  height: 1.35,
                  fontStyle: FontStyle.italic)),
        ],
      ],
    );
  }
}
