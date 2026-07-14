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

/// L'accento dell'elemento: oro per il Rito dell'Alba, il colore della Guida per
/// gli altri tre.
Color _accentFor(DailyElement element) {
  final guide = element.guide;
  if (guide == null) return _gold;
  return MaestroPalette.forKey(ThemeKey.of(guide)).primary;
}

/// La striscia del giorno, fissa in cima al Santuario: i quattro elementi
/// giornalieri come icone, quello della fascia oraria attiva centrato e in
/// evidenza con un lieve pulsare, nel colore del suo accento. Un tocco apre
/// direttamente l'esperienza, senza passare dal dominio.
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

  static const double _itemWidth = 84;
  static const double _height = 92;

  DateTime Function() get _clock => widget.clock ?? DateTime.now;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    // Centra l'elemento corrente alla prima comparsa.
    WidgetsBinding.instance.addPostFrameCallback((_) => _centerCurrent());
  }

  void _centerCurrent() {
    if (!_scroll.hasClients) return;
    final current = DailyElements.current(_clock());
    final index = DailyElement.values.indexOf(current);
    final viewport = _scroll.position.viewportDimension;
    final target =
        (index * _itemWidth) - (viewport - _itemWidth) / 2;
    final max = _scroll.position.maxScrollExtent;
    _scroll.jumpTo(target.clamp(0.0, max));
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
    final current = DailyElements.current(_clock());
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
          return _StripItem(
            element: element,
            active: element == current,
            accent: _accentFor(element),
            pulse: _pulse,
            width: _itemWidth,
            onTap: () => _open(element),
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
  });

  final DailyElement element;
  final bool active;
  final Color accent;
  final Animation<double> pulse;
  final double width;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: Key('daily_element_${element.name}'),
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: pulse,
              builder: (context, child) {
                // L'elemento attivo pulsa leggermente; gli altri restano fermi.
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
    );
  }
}
