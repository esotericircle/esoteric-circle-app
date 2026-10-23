import 'package:flutter/material.dart';

import '../../core/responsi/la_forma_del_responso.dart';
import '../theme/maestro_palette.dart';
import '../tokens/color_tokens.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/typography_tokens.dart';
import 'il_responso_interpretato.dart';

/// **LA SINGOLA CARTA, CHIUSA ALL'APERTURA E APRIBILE AL TOCCO.** Ordine GC
/// voci GC.06 e GC.18, 22 ottobre 2026.
///
/// Il fondatore, alle 16:06: *"io noto che c'è troppo testo e infografica
/// zero"*; alle 16:09, alla direzione proposta dall'Architetto: *"Approvo"*.
/// Linee Guida V14, sezione 2, strato 3: il testo narrato e' espandibile.
/// Il riquadro di una carta mostra subito la sua parola chiave, grande, e il
/// titolo; il paragrafo resta chiuso e si apre al tocco. **Non si toglie ne'
/// si accorcia niente**: il paragrafo e' quello intero della forma della
/// singola (`ResponsoInterpretato.singola`, GC.05), si mostra soltanto quando
/// la persona lo chiede.
///
/// Un pezzo solo per le due arti: la Stesa di Tarocchi (`BollaDellaPosizione`)
/// e l'Oracolo degli Angeli passano di qui, cosi' la regola dello strato 3 e
/// il gesto che apre stanno in un posto.
class LaSingolaCheSiApre extends StatefulWidget {
  const LaSingolaCheSiApre({
    super.key,
    required this.responso,
    required this.parolaChiave,
    required this.palette,
    required this.chiave,
    this.etichetta,
    this.mostraIlTitolo = true,
    this.apertaAllInizio = false,
  });

  /// Il responso della carta, nella forma della singola.
  final ResponsoInterpretato responso;

  /// La parola chiave della carta, dal corpus: grande, sopra il titolo.
  final String parolaChiave;

  final MaestroPalette palette;

  /// La radice delle chiavi, per le prove: `<chiave>_parola`,
  /// `<chiave>_apri`, `<chiave>_paragrafo`.
  final String chiave;

  /// Il titolo del paragrafo, sopra di lui (nell'Oracolo "Il suo messaggio
  /// per te"); nullo, nessuno.
  final String? etichetta;

  /// Se il titolo del responso si mostra (nell'Oracolo il titolo della carta
  /// e' gia' il nome dell'angelo, nella testata).
  final bool mostraIlTitolo;

  /// Aperta gia' all'apertura: per le anteprime e le prove che leggono il
  /// paragrafo. La persona la trova chiusa.
  final bool apertaAllInizio;

  /// La riga del gesto, chiusa e aperta.
  static const String rigaPerAprire = 'Leggi il suo messaggio';
  static const String rigaPerChiudere = 'Chiudi';

  @override
  State<LaSingolaCheSiApre> createState() => _LaSingolaCheSiApreState();
}

class _LaSingolaCheSiApreState extends State<LaSingolaCheSiApre> {
  late bool _aperta = widget.apertaAllInizio;

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final parola = widget.parolaChiave.trim().replaceFirst(RegExp(r'[.]$'), '');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (parola.isNotEmpty) ...[
          Text(parola,
              key: Key('${widget.chiave}_parola'),
              style: TypographyTokens.titoloSezione()
                  .copyWith(color: palette.goldSoft, height: 1.2)),
          const SizedBox(height: SpacingTokens.xxs),
        ],
        if (widget.etichetta != null) ...[
          Text(widget.etichetta!,
              style: TypographyTokens.etichetta()
                  .copyWith(color: palette.goldSoft)),
          const SizedBox(height: SpacingTokens.xxs),
        ],
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          alignment: Alignment.topCenter,
          child: KeyedSubtree(
            key: Key('${widget.chiave}_paragrafo'),
            child: IlResponsoInterpretato(
              responso: widget.responso,
              chiave: widget.chiave,
              palette: palette,
              mostraIlTitolo: widget.mostraIlTitolo,
              // Chiusa: il titolo soltanto, nessun paragrafo.
              paragrafiVisibili: _aperta ? null : 0,
              stileDelTitolo: TypographyTokens.titoloScheda()
                  .copyWith(color: palette.goldSoft, height: 1.25),
              stile: TypographyTokens.lettura()
                  .copyWith(color: ColorTokens.textPrimary),
            ),
          ),
        ),
        Semantics(
          button: true,
          child: InkWell(
            key: Key('${widget.chiave}_apri'),
            enableFeedback: false,
            borderRadius: BorderRadius.circular(SpacingTokens.radiusSm),
            onTap: () => setState(() => _aperta = !_aperta),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: SpacingTokens.xs),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                      _aperta
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      size: 20,
                      color: palette.goldSoft),
                  const SizedBox(width: SpacingTokens.xxs),
                  Text(
                      _aperta
                          ? LaSingolaCheSiApre.rigaPerChiudere
                          : LaSingolaCheSiApre.rigaPerAprire,
                      style: TypographyTokens.etichetta().copyWith(
                          color: palette.goldSoft, letterSpacing: 1.1)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
