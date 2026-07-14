import 'package:flutter/material.dart';

import '../../core/maestro/maestro.dart';
import '../../core/rituals/daily_elements.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../rituals/breath_destiny_screen.dart';
import '../rituals/dawn_rite_screen.dart';
import '../rituals/day_oracle_screen.dart';
import '../rituals/sunset_rune_screen.dart';

const Color _gold = Color(0xFFE8C463);

/// La route dell'esperienza di un elemento giornaliero. Un solo posto che lega
/// l'elemento alla sua schermata, cosi' lo usano sia il tocco sulla striscia sia
/// il deep-link da notifica push.
Route<void> dailyElementRoute(DailyElement element) {
  switch (element) {
    case DailyElement.dawn:
      return DawnRiteScreen.route();
    case DailyElement.breath:
      return BreathDestinyScreen.route();
    case DailyElement.oracle:
      return DayOracleScreen.route();
    case DailyElement.rune:
      return SunsetRuneScreen.route();
  }
}

/// Apre direttamente l'esperienza dell'elemento, senza schermata intermedia di
/// dominio. Alla chiusura si torna da dove si e' partiti (il Santuario).
void openDailyElement(BuildContext context, DailyElement element) {
  Navigator.of(context).push(dailyElementRoute(element));
}

/// L'icona dell'elemento nella striscia del giorno.
IconData _iconFor(DailyElement element) {
  switch (element) {
    case DailyElement.dawn:
      return Icons.wb_twilight_rounded;
    case DailyElement.breath:
      return Icons.air_rounded;
    case DailyElement.oracle:
      return Icons.wb_sunny_rounded;
    case DailyElement.rune:
      return Icons.brightness_3_rounded;
  }
}

/// L'accento dell'elemento: oro per il Rito dell'Alba, il colore del Maestro per
/// gli altri tre.
Color _accentFor(DailyElement element) {
  final guide = element.guide;
  if (guide == null) return _gold;
  return MaestroPalette.forKey(ThemeKey.of(guide)).primary;
}

/// La riga "Guidato da" del popup informativo. Per il Rito dell'Alba, che
/// ruota, indica il Maestro di turno del giorno; per gli altri il loro Maestro
/// fisso.
String _guideLine(DailyElement element, Maestro maestro) {
  if (element.guide == null) {
    return 'Guidato dal Maestro di turno del giorno, oggi ${maestro.displayName}';
  }
  return 'Guidato da ${maestro.displayName}';
}

/// Apre il popup informativo dell'elemento: cosa e', quale Maestro lo guida e a
/// cosa serve. Breve e chiudibile, non apre l'esperienza.
void _showElementInfo(
  BuildContext context,
  DailyElement element,
  Maestro maestro,
  Color accent,
) {
  showDialog<void>(
    context: context,
    barrierColor: ColorTokens.scrim,
    builder: (context) => Dialog(
      key: Key('daily_info_${element.name}'),
      backgroundColor: ColorTokens.neutralDeep,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: accent.withValues(alpha: 0.55)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            SpacingTokens.lg, SpacingTokens.lg, SpacingTokens.lg, SpacingTokens.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      accent.withValues(alpha: 0.5),
                      ColorTokens.neutralDeepest.withValues(alpha: 0.3),
                    ]),
                    border: Border.all(color: accent.withValues(alpha: 0.9)),
                  ),
                  alignment: Alignment.center,
                  child: Icon(_iconFor(element), size: 18, color: _gold),
                ),
                const SizedBox(width: SpacingTokens.sm),
                Expanded(
                  child: Text(
                    element.title,
                    style: TypographyTokens.display(size: 18).copyWith(
                      color: _gold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: SpacingTokens.sm),
            Row(
              children: [
                Icon(Icons.schedule_rounded,
                    size: 15, color: accent.withValues(alpha: 0.9)),
                const SizedBox(width: 6),
                Text(
                  'Alle ${element.clockLabel}',
                  style: TypographyTokens.label(size: 11).copyWith(
                    color: ColorTokens.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              _guideLine(element, maestro),
              style: TypographyTokens.body(size: 14).copyWith(
                color: accent.withValues(alpha: 0.95),
              ),
            ),
            const SizedBox(height: SpacingTokens.sm),
            Text(
              element.description,
              style: TypographyTokens.body(size: 15).copyWith(
                color: ColorTokens.textPrimary,
              ),
            ),
            const SizedBox(height: SpacingTokens.sm),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                key: Key('daily_info_close_${element.name}'),
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Ho capito',
                  style: TypographyTokens.label(size: 12).copyWith(color: _gold),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// La striscia del giorno, fissa in cima al Santuario: i quattro elementi
/// giornalieri come icone, quello della fascia oraria attiva in evidenza con un
/// lieve pulsare, nel colore del suo accento. Ogni elemento mostra in alto il
/// suo orario e un piccolo cerchio "i" che apre la spiegazione. Un tocco
/// sull'icona apre direttamente l'esperienza, senza passare dal dominio.
class DailyStrip extends StatefulWidget {
  const DailyStrip({super.key, this.clock, this.onOpen});

  /// Orologio iniettabile per i test. Di default l'ora locale del dispositivo.
  final DateTime Function()? clock;

  /// Callback di apertura, iniettabile per i test. Di default apre la route
  /// reale dell'elemento.
  final void Function(BuildContext context, DailyElement element)? onOpen;

  @override
  State<DailyStrip> createState() => _DailyStripState();
}

class _DailyStripState extends State<DailyStrip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  final ScrollController _scroll = ScrollController();

  static const double _itemWidth = 88;
  static const double _height = 108;

  DateTime Function() get _clock => widget.clock ?? DateTime.now;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _open(DailyElement element) {
    final open = widget.onOpen ?? openDailyElement;
    open(context, element);
  }

  @override
  Widget build(BuildContext context) {
    final now = _clock();
    final current = DailyElements.current(now);
    return Container(
      key: const Key('santuario_daily_strip'),
      height: _height,
      decoration: BoxDecoration(
        // Fondo coerente col tempio: una fascia scura con un filo d'oro sotto.
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ColorTokens.neutralDeepest.withValues(alpha: 0.0),
            ColorTokens.neutralDeepest.withValues(alpha: 0.55),
          ],
        ),
        border: Border(
          bottom: BorderSide(color: _gold.withValues(alpha: 0.25)),
        ),
      ),
      child: ListView.builder(
        controller: _scroll,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.md),
        itemCount: DailyElement.values.length,
        itemBuilder: (context, i) {
          final element = DailyElement.values[i];
          final accent = _accentFor(element);
          final maestro = DailyElements.maestroFor(element, now);
          return _StripItem(
            element: element,
            active: element == current,
            accent: accent,
            pulse: _pulse,
            width: _itemWidth,
            onTap: () => _open(element),
            onInfo: () => _showElementInfo(context, element, maestro, accent),
          );
        },
      ),
    );
  }
}

class _StripItem extends StatelessWidget {
  const _StripItem({
    required this.element,
    required this.active,
    required this.accent,
    required this.pulse,
    required this.width,
    required this.onTap,
    required this.onInfo,
  });

  final DailyElement element;
  final bool active;
  final Color accent;
  final Animation<double> pulse;
  final double width;
  final VoidCallback onTap;
  final VoidCallback onInfo;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Stack(
        children: [
          // Area di tocco principale: apre direttamente l'esperienza.
          Positioned.fill(
            child: GestureDetector(
              key: Key('daily_element_${element.name}'),
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Il riquadro dell'orario dell'elemento.
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: accent.withValues(alpha: active ? 0.22 : 0.12),
                      border: Border.all(
                        color: accent.withValues(alpha: active ? 0.7 : 0.3),
                      ),
                    ),
                    child: Text(
                      element.clockLabel,
                      style: TypographyTokens.label(size: 9).copyWith(
                        color: active ? _gold : ColorTokens.textSecondary,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  AnimatedBuilder(
                    animation: pulse,
                    builder: (context, child) {
                      // L'elemento attivo pulsa leggermente; gli altri fermi.
                      final scale = active ? 1.0 + 0.06 * pulse.value : 1.0;
                      return Transform.scale(scale: scale, child: child);
                    },
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [
                          accent.withValues(alpha: active ? 0.55 : 0.18),
                          ColorTokens.neutralDeepest.withValues(alpha: 0.3),
                        ]),
                        border: Border.all(
                          color: accent.withValues(alpha: active ? 0.95 : 0.35),
                          width: active ? 1.8 : 1,
                        ),
                        boxShadow: active
                            ? [
                                BoxShadow(
                                  color: accent.withValues(alpha: 0.45),
                                  blurRadius: 16,
                                  spreadRadius: -3,
                                ),
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        _iconFor(element),
                        size: 22,
                        color: active
                            ? _gold
                            : ColorTokens.textSecondary.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    element.shortLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TypographyTokens.label(size: 10).copyWith(
                      color: active ? _gold : ColorTokens.textSecondary,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Cerchio informativo "i", area di tocco separata: apre solo il popup.
          Positioned(
            top: 0,
            right: 6,
            child: GestureDetector(
              key: Key('daily_info_button_${element.name}'),
              behavior: HitTestBehavior.opaque,
              onTap: onInfo,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ColorTokens.neutralDeepest.withValues(alpha: 0.7),
                  border: Border.all(
                    color: accent.withValues(alpha: 0.6),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'i',
                  style: TypographyTokens.label(size: 11).copyWith(
                    color: accent.withValues(alpha: 0.95),
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
