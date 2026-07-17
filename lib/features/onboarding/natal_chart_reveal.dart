import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/astro/natal_chart.dart';
import '../../core/astro/natal_chart_controller.dart';
import '../../core/astro/natal_poetics.dart';
import '../../core/identity/natal_identity.dart';
import '../../design_system/components/depth_card.dart';
import '../../design_system/components/natal_wheel.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../identity/widgets/identity_widgets.dart';
import 'widgets/nature_emblem.dart';

/// La carta natale a due livelli: prima il colpo d'occhio (frase poetica e tre
/// aure intrecciate), poi la ruota elegante con gli aspetti attivabili e la
/// legenda viva, una tessera per pianeta collegata alla ruota.
class NatalChartReveal extends StatefulWidget {
  const NatalChartReveal({super.key, required this.onContinue});

  final VoidCallback onContinue;

  @override
  State<NatalChartReveal> createState() => _NatalChartRevealState();
}

class _NatalChartRevealState extends State<NatalChartReveal> {
  final _scroll = ScrollController();
  final _tileKeys = <String, GlobalKey>{};
  String? _selectedId;
  bool _showAspects = false;

  void _selectPlanet(String id, {bool scrollToTile = false}) {
    setState(() => _selectedId = _selectedId == id ? null : id);
    HapticFeedback.selectionClick();
    if (scrollToTile && _selectedId == id) {
      final key = _tileKeys[id];
      final ctx = key?.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(ctx,
            duration: const Duration(milliseconds: 400),
            alignment: 0.3,
            curve: Curves.easeOut);
      }
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<NatalChartController>();
    final identity = context.watch<BirthIdentityController>();
    final palette = context.palette;

    if (controller.status != ChartStatus.ready || controller.chart == null) {
      return const _Loading();
    }
    final chart = controller.chart!;

    return SingleChildScrollView(
      controller: _scroll,
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: SpacingTokens.sm),
          Text('IL TUO CIELO',
              style: TypographyTokens.label(size: 13)
                  .copyWith(color: palette.goldSoft, letterSpacing: 3)),
          const SizedBox(height: SpacingTokens.md),
          // --- Portale al cielo reale della nascita (al posto del vecchio
          //     bagliore), sempre riapribile a tutto schermo. ---
          if (identity.details != null)
            BirthSkyPortal(
              details: identity.details!,
              moonPhase: identity.facts?.moonPhase,
            ),
          const SizedBox(height: SpacingTokens.md),
          // --- Colpo d'occhio: frase poetica ---
          Text(
            NatalPoetics.glanceSummary(chart),
            textAlign: TextAlign.center,
            style: TypographyTokens.display(size: 22).copyWith(height: 1.4),
          ),
          const SizedBox(height: SpacingTokens.sm),
          _AscendantNote(chart: chart),
          const SizedBox(height: SpacingTokens.lg),
          // --- Fatti identitari: fase lunare di nascita e numero della vita ---
          if (identity.facts != null) ...[
            IdentityFactsSection(facts: identity.facts!),
            const SizedBox(height: SpacingTokens.lg),
          ],
          // --- La ruota, con aspetti attivabili ---
          NatalWheel(
            chart: chart,
            size: 320,
            showAspects: _showAspects,
            highlightPlanetId: _selectedId,
            onPlanetTap: (id) => _selectPlanet(id, scrollToTile: true),
          ),
          const SizedBox(height: SpacingTokens.sm),
          if (chart.aspects.isNotEmpty)
            _AspectToggle(
              value: _showAspects,
              onChanged: (v) => setState(() => _showAspects = v),
            ),
          const SizedBox(height: SpacingTokens.lg),
          _LegendHeader(),
          const SizedBox(height: SpacingTokens.sm),
          // --- Legenda viva ---
          for (final p in chart.planets)
            _PlanetTile(
              key: _tileKeys.putIfAbsent(p.id, () => GlobalKey()),
              planet: p,
              selected: _selectedId == p.id,
              onTap: () => _selectPlanet(p.id),
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
              onPressed: widget.onContinue,
              child: Text('Scopri chi risuona con te',
                  style: TypographyTokens.body(size: 17, weight: 600)
                      .copyWith(color: palette.deepest)),
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),
        ],
      ),
    );
  }

}

class _AscendantNote extends StatelessWidget {
  const _AscendantNote({required this.chart});
  final NatalChart chart;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    if (chart.hasTime && chart.ascendant != null) {
      // Con l'ora, l'Ascendente si celebra.
      return Container(
        padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.md, vertical: SpacingTokens.xs),
        decoration: BoxDecoration(
          color: palette.gold.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
          border: Border.all(color: palette.gold.withValues(alpha: 0.5)),
        ),
        child: Text(
          'Ascendente in ${chart.ascendant!.italianName}: la soglia da cui ti mostri al mondo.',
          textAlign: TextAlign.center,
          style: TypographyTokens.body(size: TypographyTokens.guide)
              .copyWith(color: palette.goldSoft, height: 1.4),
        ),
      );
    }
    // Solo senza ora, il messaggio velato.
    return Text(
      'Senza l\'ora di nascita l\'Ascendente e le Case restano velati. Potrai aggiungerla per completare il cielo.',
      textAlign: TextAlign.center,
      style: TypographyTokens.body(size: TypographyTokens.guide)
          .copyWith(color: ColorTokens.textPrimary, height: 1.4),
    );
  }
}

class _AspectToggle extends StatelessWidget {
  const _AspectToggle({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.md, vertical: SpacingTokens.xs),
        decoration: BoxDecoration(
          color: value
              ? palette.gold.withValues(alpha: 0.18)
              : ColorTokens.glassTint,
          borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
          border: Border.all(
              color: value ? palette.gold : ColorTokens.glassStroke),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(value ? Icons.grain : Icons.blur_on,
                size: 18,
                color: value ? palette.goldSoft : ColorTokens.textSecondary),
            const SizedBox(width: 6),
            Text(value ? 'Aspetti accesi' : 'Mostra gli aspetti',
                style: TypographyTokens.body(size: 16).copyWith(
                  color:
                      value ? palette.goldSoft : ColorTokens.textSecondary,
                )),
          ],
        ),
      ),
    );
  }
}

class _LegendHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: 20, height: 1, color: palette.gold.withValues(alpha: 0.6)),
        const SizedBox(width: SpacingTokens.xs),
        Text('LA LEGENDA VIVA',
            style: TypographyTokens.label(size: 13).copyWith(
                color: palette.goldSoft, letterSpacing: 2)),
        const SizedBox(width: SpacingTokens.xs),
        Container(width: 20, height: 1, color: palette.gold.withValues(alpha: 0.6)),
      ],
    );
  }
}

class _PlanetTile extends StatelessWidget {
  const _PlanetTile({
    super.key,
    required this.planet,
    required this.selected,
    required this.onTap,
  });

  final PlanetPosition planet;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final dignity = NatalPoetics.dignityOf(planet.id, planet.sign);

    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.xs),
      child: DepthCard(
        onTap: onTap,
        padding: const EdgeInsets.all(SpacingTokens.sm),
        borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: selected
                  ? palette.gold
                  : Colors.transparent,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(SpacingTokens.radiusSm),
          ),
          child: Padding(
            padding: const EdgeInsets.all(SpacingTokens.xs),
            child: Row(
              children: [
                NatureEmblem(
                  element: planet.sign.element,
                  dignity: dignity,
                  retrograde: planet.retrograde,
                  size: 42,
                ),
                const SizedBox(width: SpacingTokens.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _sym(planet.glyph, palette.goldSoft, 16),
                          const SizedBox(width: 6),
                          Text(planet.name,
                              style: TypographyTokens.display(size: 16)),
                          const SizedBox(width: 8),
                          _sym(planet.sign.symbol, palette.goldSoft, 14),
                          const SizedBox(width: 4),
                          Text(planet.sign.italianName,
                              style: TypographyTokens.body(size: 13).copyWith(
                                  color: ColorTokens.textSecondary)),
                          if (planet.retrograde) ...[
                            const SizedBox(width: 6),
                            Text('R',
                                style: TypographyTokens.body(size: 12).copyWith(
                                    color: const Color(0xFFE0733A),
                                    fontWeight: FontWeight.w700)),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(NatalPoetics.meaningOf(planet.id),
                          style: TypographyTokens.body(size: TypographyTokens.guide)
                              .copyWith(color: ColorTokens.textPrimary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sym(String glyph, Color color, double size) {
    // Il glifo del Sole non e' nel font simboli: si disegna.
    if (glyph == '☉') {
      return SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _SunGlyphPainter(color)),
      );
    }
    return Text(
      glyph,
      style: TextStyle(
          fontFamily: 'NotoSansSymbols', color: color, fontSize: size),
    );
  }
}

class _SunGlyphPainter extends CustomPainter {
  _SunGlyphPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width * 0.42;
    canvas.drawCircle(c, r,
        Paint()..style = PaintingStyle.stroke..strokeWidth = 1.4..color = color);
    canvas.drawCircle(c, size.width * 0.09, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_SunGlyphPainter old) => old.color != color;
}

class _Loading extends StatelessWidget {
  const _Loading();
  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 42,
            height: 42,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(palette.goldSoft),
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          Text('Traccio il tuo cielo...',
              style: TypographyTokens.body(size: TypographyTokens.guide)
                  .copyWith(color: ColorTokens.textSecondary)),
        ],
      ),
    );
  }
}
