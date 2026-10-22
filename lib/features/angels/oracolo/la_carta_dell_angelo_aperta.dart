import 'package:flutter/material.dart';

import '../../../core/angels/angel_catalog.dart';
import '../../../design_system/components/segno_della_provenienza.dart';
import '../../../design_system/theme/maestro_palette.dart';
import '../../../design_system/tokens/color_tokens.dart';
import '../../../design_system/tokens/spacing_tokens.dart';
import '../../../design_system/tokens/typography_tokens.dart';
import '../../../design_system/transizioni/velo_del_cerchio.dart';
import 'oracolo_degli_angeli_screen.dart' show LaCartaDellAngelo;

/// **LA CARTA DELL'ANGELO, APERTA AL TOCCO.** Ordine GC voce GC.14, 22
/// ottobre 2026. Il fondatore: *"Se faccio click su una carta in verticale
/// ottengo una schermata popup con la descrizione della carta angelo."*
///
/// Il foglio dice chi e' l'angelo uscito con i dati e i testi che l'app ha
/// gia' per i 72, nessun testo nuovo e nessun campo inventato (Regola Zero):
/// la carta dipinta, la sua parola sopra (Fare, Sentire, Capire o "La carta
/// del momento"), il numero e il nome, il coro e l'arcangelo che lo regge
/// (`AngelCatalog`), che cosa porta secondo la tradizione col segno della sua
/// fonte, Lenain 1823 (`AngelLore`, le stesse righe della bolla della carta),
/// e il suo messaggio per te in questa consultazione. Si chiude col tocco
/// fuori o col pulsante.
///
/// Non e' l'`AngeloIngrandito` dei tre angeli della persona: quello dice
/// "perche' e' tuo" e dalla nascita, e un angelo uscito dal mazzo non lo e'.
class LaCartaDellAngeloAperta extends StatelessWidget {
  const LaCartaDellAngeloAperta({
    super.key,
    required this.angelo,
    required this.parola,
    required this.chiE,
    required this.messaggio,
    required this.palette,
    this.cosaPorta,
  });

  final Angel angelo;

  /// La scritta sopra la carta in piedi.
  final String parola;

  /// La riga col numero, il coro e l'arcangelo.
  final String chiE;

  /// Che cosa porta, con la sua fonte; nullo se il Corpus non lo regge.
  final ({String testo, Provenienza da, String fonte})? cosaPorta;

  /// Il messaggio della carta in questa consultazione, dal corpus.
  final String messaggio;

  final MaestroPalette palette;

  /// La riga del pulsante che chiude.
  static const String chiudi = 'Chiudi';

  /// Apre il foglio, che sale dal basso e si chiude col tocco fuori.
  static Future<void> apri(
    BuildContext context, {
    required Angel angelo,
    required String parola,
    required String chiE,
    required String messaggio,
    required MaestroPalette palette,
    ({String testo, Provenienza da, String fonte})? cosaPorta,
  }) {
    return foglioDelCerchio<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => LaCartaDellAngeloAperta(
        angelo: angelo,
        parola: parola,
        chiE: chiE,
        messaggio: messaggio,
        palette: palette,
        cosaPorta: cosaPorta,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final porta = cosaPorta;
    return DraggableScrollableSheet(
      initialChildSize: 0.86,
      minChildSize: 0.5,
      maxChildSize: 0.96,
      expand: false,
      builder: (context, controllo) => Container(
        key: const Key('oracolo_carta_aperta'),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [palette.surfaceElevated, palette.deepest],
          ),
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(SpacingTokens.radiusLg)),
          border: Border.all(color: palette.gold.withValues(alpha: 0.3)),
        ),
        child: ListView(
          controller: controllo,
          padding: const EdgeInsets.all(SpacingTokens.lg),
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: palette.gold.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: SpacingTokens.lg),
            Text(parola.toUpperCase(),
                textAlign: TextAlign.center,
                style: TypographyTokens.etichetta()
                    .copyWith(color: palette.goldSoft, letterSpacing: 2)),
            const SizedBox(height: SpacingTokens.sm),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 240),
                child: AspectRatio(
                  aspectRatio: 2 / 3,
                  // **LA CARTA COL SUO NUMERO E IL SUO NOME** (simulazione
                  // da persona dell'ordine GC): la stessa carta del tavolo,
                  // coi cartigli scritti in Flutter. L'arte da sola ha i
                  // cartigli vuoti, e sul Realme il foglio li mostrava cosi'.
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
                    child: LaCartaDellAngelo(angelo: angelo, palette: palette),
                  ),
                ),
              ),
            ),
            const SizedBox(height: SpacingTokens.md),
            Text('${angelo.number}. ${angelo.name}',
                key: const Key('oracolo_carta_aperta_nome'),
                textAlign: TextAlign.center,
                style: TypographyTokens.cerimoniale()),
            const SizedBox(height: SpacingTokens.xs),
            Text(chiE,
                textAlign: TextAlign.center,
                style: TypographyTokens.corpo()
                    .copyWith(color: ColorTokens.textSecondary)),
            if (porta != null) ...[
              const SizedBox(height: SpacingTokens.md),
              SegnoDellaProvenienza(
                  provenienza: porta.da,
                  palette: palette,
                  dettaglio: porta.fonte),
              const SizedBox(height: SpacingTokens.xxs),
              Text(porta.testo,
                  style: TypographyTokens.corpo().copyWith(height: 1.45)),
            ],
            const SizedBox(height: SpacingTokens.md),
            Text('Il suo messaggio per te',
                style: TypographyTokens.etichetta()
                    .copyWith(color: palette.goldSoft, letterSpacing: 1.6)),
            const SizedBox(height: SpacingTokens.xxs),
            Text(messaggio,
                key: const Key('oracolo_carta_aperta_messaggio'),
                style: TypographyTokens.lettura()
                    .copyWith(color: ColorTokens.textPrimary)),
            const SizedBox(height: SpacingTokens.lg),
            Center(
              child: TextButton(
                key: const Key('oracolo_carta_aperta_chiudi'),
                onPressed: () => Navigator.of(context).maybePop(),
                child: Text(chiudi,
                    style: TypographyTokens.corpo()
                        .copyWith(color: palette.goldSoft)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
