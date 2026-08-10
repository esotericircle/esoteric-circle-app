import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/astro/resonance.dart';
import '../../core/maestro/maestro.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../design_system/typography/paragrafi_di_lettura.dart';

/// La risonanza coi tre Maestri: tre aure che pulsano a intensita' diversa. La
/// piu' forte si fa avanti, ed e' il Maestro che risuona con il tuo cielo.
class ResonanceScreen extends StatelessWidget {
  const ResonanceScreen({
    super.key,
    required this.resonance,
    required this.onContinue,
  });

  final Resonance resonance;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    // Ordine: vincitore al centro, gli altri ai lati.
    final others =
        Maestro.values.where((m) => m != resonance.winner).toList();
    final etichette = PercentualiRisonanza.formatta(resonance.scores);
    final ordered = [others.first, resonance.winner, others.last];

    return Padding(
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Column(
        children: [
          const SizedBox(height: SpacingTokens.sm),
          Text('LA RISONANZA',
              style: TypographyTokens.etichetta()
                  .copyWith(color: palette.goldSoft, letterSpacing: 3)),
          const SizedBox(height: SpacingTokens.xs),
          Text('Chi risuona con te',
              style: TypographyTokens.cerimoniale(),
              textAlign: TextAlign.center),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (final m in ordered)
                  // Expanded, non larghezza libera: senza, il nome piu' lungo
                  // rubava spazio e MEDORA andava a capo con la A da sola.
                  Expanded(
                    child: _MaestroAura(
                      maestro: m,
                      intensity: resonance.scoreOf(m),
                      isWinner: m == resonance.winner,
                      etichetta: etichette[m] ?? '',
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(SpacingTokens.md),
            decoration: BoxDecoration(
              color: palette.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
              border: Border.all(color: palette.gold.withValues(alpha: 0.3)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ParagrafiDiLettura(testo: resonance.reason, textAlign: TextAlign.center, stile: TypographyTokens.lettura()
                      .copyWith(color: ColorTokens.textPrimary, height: 1.45)),
                // Pareggio vero: due numeri identici e un vincitore sono una
                // contraddizione, a meno di dire con che criterio uno passa
                // avanti. Il criterio esiste gia' nel motore, e' il fattore
                // decisivo, quindi qui si dichiara invece di nasconderlo.
                if (PercentualiRisonanza.pareggioVero(resonance.scores)) ...[
                  const SizedBox(height: SpacingTokens.sm),
                  Text(
                    'Due voci pesano uguale: a decidere è ${resonance.deciding}.',
                    textAlign: TextAlign.center,
                    style: TypographyTokens.corpo().copyWith(
                        color: palette.goldSoft.withValues(alpha: 0.85),
                        height: 1.4),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: palette.gold,
                foregroundColor: palette.deepest,
                padding: const EdgeInsets.symmetric(vertical: SpacingTokens.md),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(SpacingTokens.radiusPill),
                ),
              ),
              onPressed: onContinue,
              child: ParagrafiDiLettura(testo: 'Rivela il tuo Maestro', stile: TypographyTokens.lettura(weight: 600)
                      .copyWith(color: palette.deepest)),
            ),
          ),
          const SizedBox(height: SpacingTokens.sm),
        ],
      ),
    );
  }
}

class _MaestroAura extends StatefulWidget {
  const _MaestroAura({
    required this.maestro,
    required this.intensity,
    required this.isWinner,
    required this.etichetta,
  });

  final Maestro maestro;
  final double intensity;
  final bool isWinner;

  /// La percentuale gia' scritta, decisa guardando tutti e tre insieme: da
  /// sola questa tessera non puo' sapere se il suo numero collide con un
  /// altro, quindi il calcolo non vive qui.
  final String etichetta;

  @override
  State<_MaestroAura> createState() => _MaestroAuraState();
}

class _MaestroAuraState extends State<_MaestroAura>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = MaestroPalette.forKey(ThemeKey.of(widget.maestro));
    final base = widget.isWinner ? 96.0 : 58.0;
    // La piu' forte pulsa piu' ampia e viva.
    final pulseAmp = 0.08 + widget.intensity * 0.14;

    return Expanded(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final ph = _c.value * 2 * math.pi;
          final pulse = 1 + pulseAmp * math.sin(ph);
          final forward = widget.isWinner ? -8 + 4 * math.sin(ph) : 0.0;
          return Transform.translate(
            offset: Offset(0, forward),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 150,
                  child: Center(
                    child: CustomPaint(
                      size: Size(base * 1.6, base * 1.6),
                      painter: _OrbPainter(
                        color: p.glow,
                        gold: p.goldSoft,
                        radius: base / 2 * pulse,
                        intensity: widget.intensity,
                        winner: widget.isWinner,
                      ),
                    ),
                  ),
                ),
                // Altezza fissa e una riga sola: il vincitore ha il nome piu'
                // grande, e senza questa scatola le tre percentuali cadevano
                // su tre linee di base diverse, come tre righe storte.
                SizedBox(
                  height: 30,
                  child: Center(
                    child: Text(
                      widget.maestro.displayName,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.visible,
                      textAlign: TextAlign.center,
                      style: (widget.isWinner
                              ? TypographyTokens.cerimoniale()
                              : TypographyTokens.titoloSezione())
                          .copyWith(
                        color: widget.isWinner
                            ? p.goldSoft
                            : ColorTokens.textSecondary,
                      ),
                    ),
                  ),
                ),
                Text(
                  widget.etichetta,
                  style: TypographyTokens.didascalia().copyWith(
                      color: ColorTokens.textMuted, letterSpacing: 1),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _OrbPainter extends CustomPainter {
  _OrbPainter({
    required this.color,
    required this.gold,
    required this.radius,
    required this.intensity,
    required this.winner,
  });

  final Color color;
  final Color gold;
  final double radius;
  final double intensity;
  final bool winner;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    // Alone.
    canvas.drawCircle(
        c,
        radius * 1.5,
        Paint()
          ..color = color.withValues(alpha: 0.15 + intensity * 0.3)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 14 + intensity * 14));
    // Corpo dell'aura.
    canvas.drawCircle(
      c,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Color.lerp(color, Colors.white, 0.3)!,
            color.withValues(alpha: 0.7),
            color.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.6, 1.0],
        ).createShader(Rect.fromCircle(center: c, radius: radius)),
    );
    if (winner) {
      canvas.drawCircle(
          c,
          radius + 5,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4
            ..color = gold.withValues(alpha: 0.8));
    }
  }

  @override
  bool shouldRepaint(_OrbPainter old) =>
      old.radius != radius || old.intensity != intensity;
}


/// Come si scrivono le tre percentuali della Risonanza.
///
/// Arrotondate a intero, due punteggi vicini ma diversi finivano tutti e due
/// su 35: a schermo si leggeva un pareggio con un vincitore, cioe' una
/// contraddizione, e chi legge pensa a un errore di conto. Qui il decimale
/// compare SOLO quando serve a separare due numeri che collidono, cosi' nel
/// caso normale restano tre interi puliti.
class PercentualiRisonanza {
  /// L'etichetta di ciascun Maestro, gia' pronta da mostrare.
  static Map<Maestro, String> formatta(Map<Maestro, double> punteggi) {
    String intero(double v) => '${(v * 100).round()}%';
    final interi = {for (final e in punteggi.entries) e.key: intero(e.value)};

    // Collisione: due etichette identiche su punteggi che identici non sono.
    final conteggio = <String, int>{};
    for (final e in interi.entries) {
      conteggio[e.value] = (conteggio[e.value] ?? 0) + 1;
    }
    final collide = <String>{
      for (final e in conteggio.entries)
        if (e.value > 1) e.key,
    };
    if (collide.isEmpty || pareggioVero(punteggi)) return interi;

    return {
      for (final e in punteggi.entries)
        e.key: collide.contains(interi[e.key])
            // La virgola, non il punto: e' un numero italiano a schermo.
            ? '${(e.value * 100).toStringAsFixed(1).replaceAll('.', ',')}%'
            : interi[e.key]!,
    };
  }

  /// Vero se due punteggi sono davvero uguali, non solo vicini.
  ///
  /// In quel caso il decimale non separa niente e sarebbe disonesto fingere
  /// una differenza: e' la schermata a dover dichiarare il criterio con cui
  /// uno dei due passa avanti.
  static bool pareggioVero(Map<Maestro, double> punteggi) {
    final v = punteggi.values.toList()..sort((a, b) => b.compareTo(a));
    for (var i = 0; i + 1 < v.length; i++) {
      if ((v[i] - v[i + 1]).abs() < 0.0005) return true;
    }
    return false;
  }
}
