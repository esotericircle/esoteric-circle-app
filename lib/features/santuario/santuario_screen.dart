import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/astro/moon_phase.dart';
import '../../core/astro/zodiac.dart';
import '../../core/astro/zodiac_controller.dart';
import '../../core/maestro/maestro.dart';
import '../../core/maestro/maestro_controller.dart';
import '../../core/motion/parallax_controller.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../services/app_services.dart';
import '../maestri/domain_screen.dart';
import 'sky_overview_screen.dart';
import 'widgets/maestro_bust.dart';
import 'widgets/moon_widget.dart';

/// La schermata eroe, il Santuario.
///
/// Un unico palco antico e neutro con la Luna reale in alto e, dietro i
/// Maestri, una silhouette architettonica di tempio fatta di linee dorate e
/// stelle. Tre mezzibusti davanti: al centro, piu' grande e vivo, l'ultimo
/// Maestro usato; gli altri due sbucano ai lati, piu' in alto, piu' scuri e
/// arretrati nella parallasse. Un filo d'oro li unisce. Toccare il centro entra
/// nel dominio, toccare un laterale lo porta al centro.
///
/// Costruita ai punti dati da Mauro: nel repo non c'e' una Specifica del
/// Santuario dedicata, solo i quattro briefing. Fondo, tempio e cielo sono un
/// segnaposto architettonico, l'asset dipinto e il motore a effemeridi
/// arrivano dopo.
class SantuarioScreen extends StatefulWidget {
  const SantuarioScreen({super.key});

  /// Maestro preferito, segnaposto in attesa dell'assegnazione all'onboarding.
  static const Maestro preferred = Maestro.medora;

  /// Zona franca del titolo in alto, in coordinate normalizzate (0..1): il
  /// cosmo di sfondo non fa nascere stelle qui, cosi' nessuna cade su una
  /// lettera. La legge il cosmo dello shell quando mostra il Santuario.
  static const Rect titleKeepOut = Rect.fromLTRB(0.04, 0.15, 0.96, 0.34);

  @override
  State<SantuarioScreen> createState() => _SantuarioScreenState();
}

class _SantuarioScreenState extends State<SantuarioScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breath;

  // Invito al tocco del cielo: appare dopo qualche secondo di inattivita' e si
  // dissolve al primo tocco, coerente con la scala dell'aiuto universale.
  Timer? _skyHintTimer;
  bool _showSkyHint = false;
  bool _skyHintDismissed = false;

  @override
  void initState() {
    super.initState();
    _breath = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    _armSkyHint();
  }

  // Arma l'invito al cielo: dopo tre secondi senza tocco, lo mostra.
  void _armSkyHint() {
    _skyHintTimer?.cancel();
    if (_skyHintDismissed) return;
    _skyHintTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && !_skyHintDismissed) setState(() => _showSkyHint = true);
    });
  }

  void _dismissSkyHint() {
    _skyHintTimer?.cancel();
    if (_skyHintDismissed && !_showSkyHint) return;
    _skyHintDismissed = true;
    if (mounted) setState(() => _showSkyHint = false);
  }

  void _openSky(BuildContext context) {
    _dismissSkyHint();
    Navigator.of(context).push(SkyOverviewScreen.route());
  }

  @override
  void dispose() {
    _skyHintTimer?.cancel();
    _breath.dispose();
    super.dispose();
  }

  void _enterDomain(BuildContext context, Maestro maestro) {
    // Ingresso rapido nel dominio. L'incantesimo a tutto schermo resta per la
    // prima volta, non a ogni ingresso: segnaposto per un passo successivo.
    context.read<MaestroController>().selectMaestro(maestro);
    final services = context.read<AppServices>();
    Navigator.of(context).push(
      DomainScreen.route(maestro: maestro, services: services),
    );
  }

  void _selectSide(BuildContext context, Maestro maestro) {
    context.read<MaestroController>().selectMaestro(maestro);
  }

  /// La riga personale del Maestro al centro, con lo slot pronto per nome e
  /// segno dell'utente, cosi' sembra parlare proprio a lui. Per ora nome e
  /// segno sono segnaposto. Per Medora la parte astronomica resta vera (luce e
  /// tendenza reali della Luna); Aura e Caligo sono testo segnaposto.
  ///
  /// Non ripete il nome della fase, gia' mostrato nell'occhiello in alto.
  String _personalLine(Maestro maestro, MoonPhase moon, String name, String sign) {
    switch (maestro) {
      case Maestro.medora:
        final pct = (moon.illumination * 100).round();
        final tend = moon.waxing ? 'cresce' : 'cala';
        return '$name, la Luna $tend al $pct%: la giusta ora per chi nasce sotto $sign.';
      case Maestro.aura:
        return "$name, l'energia di chi nasce sotto $sign cerca quiete: una mano sul cuore.";
      case Maestro.caligo:
        return '$name, per chi nasce sotto $sign stanotte sale una runa di pazienza.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = context.watch<MaestroController>().activeMaestro;
    final central = active ?? SantuarioScreen.preferred;
    final selected = active != null;
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final parallax = context.watch<ParallaxController>();
    final palette = context.palette;

    final moon = MoonPhase.forDate(DateTime.now());

    // Slot personali: nome e segno dell'utente. Segnaposto in attesa del
    // profilo reale; il segno si legge gia' dal controller dello zodiaco.
    const userName = 'Viandante';
    final userSign =
        (context.watch<ZodiacController>().sunSign ?? Zodiac.gemini).italianName;
    final personalLine = _personalLine(central, moon, userName, userSign);

    // Riduci Movimento: niente deriva di parallasse, scena ferma.
    Offset depth(double d) => reduceMotion ? Offset.zero : parallax.layerOffset(d);

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          // I busti occupano la fascia centrale e bassa in modo pieno, non
          // schiacciati sul fondo. Una carta piu' alta riduce lo spazio morto.
          final centralH = (h * 0.54).clamp(240.0, 460.0);
          // Sollevati dal margine inferiore: lasciano spazio, sotto il centro,
          // al pulsante Entra nel Dominio, e poggiano sul palco senza
          // sprofondare dietro la bottom bar.
          final carouselBottom = h * 0.11;
          final carouselHeight = centralH * 1.32;

          return Stack(
            children: [
              // Nessuna forma vettoriale come fondale: dietro i Maestri resta
              // il cosmo pulito (stelle, nebulose, Luna) e lo spazio scuro. Il
              // fondale dipinto del Santuario, quando pronto, si monta qui come
              // piano profondo dietro i busti.

              // Cielo in alto: nebulose soffuse tinte sull'accento del Maestro
              // e un paio di stelle piu' luminose a evocare i pianeti, in
              // attesa del motore a effemeridi.
              Positioned.fill(
                child: CustomPaint(
                  painter: _SkyAccentsPainter(
                    glow: palette.glow,
                    primary: palette.primary,
                    star: palette.goldSoft,
                    offset: depth(0.12),
                  ),
                ),
              ),

              // Il cielo in alto e' toccabile: apre "Il cielo sopra di te",
              // per ora segnaposto. Poco testo dopo il segno visivo: un
              // occhiello con la fase reale, un'intestazione e una sola riga
              // personale nella voce del Maestro. La fase non si ripete.
              Positioned(
                top: h * 0.015,
                left: 0,
                right: 0,
                child: GestureDetector(
                  key: const Key('santuario_sky_tap'),
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _openSky(context),
                  child: Column(
                    children: [
                      MoonWidget(
                          phase: moon, size: (w * 0.12).clamp(58.0, 108.0)),
                      // 1. Occhiello: la fase reale della Luna, piccola.
                      Text(
                        moon.italianName.toUpperCase(),
                        style: TypographyTokens.label(size: 10).copyWith(
                          color: palette.goldSoft,
                          letterSpacing: 1.6,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // 2. Intestazione.
                      Text(
                        'Il cielo sopra di te, stanotte',
                        style: TypographyTokens.display(size: 17),
                      ),
                      const SizedBox(height: 4),
                      // 3. Riga personale, nella voce del Maestro al centro.
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          personalLine,
                          textAlign: TextAlign.center,
                          style: TypographyTokens.body(size: 13).copyWith(
                            color: ColorTokens.textSecondary,
                            fontStyle: FontStyle.italic,
                            height: 1.3,
                          ),
                        ),
                      ),
                      // Invito al tocco, dopo qualche secondo di inattivita':
                      // discreto, animato, si dissolve al primo tocco.
                      _SkyTapHint(
                        visible: _showSkyHint,
                        pulse: _breath,
                        reduceMotion: reduceMotion,
                        color: palette.goldSoft,
                      ),
                    ],
                  ),
                ),
              ),

              // Palco e busti, alzati verso il centro della scena.
              Positioned(
                left: 0,
                right: 0,
                bottom: carouselBottom,
                height: carouselHeight,
                child: _Carousel(
                  central: central,
                  selected: selected,
                  centralHeight: centralH,
                  breath: _breath,
                  reduceMotion: reduceMotion,
                  preferred: SantuarioScreen.preferred,
                  centralDepth: depth(0.5),
                  sideDepth: depth(0.28),
                  onTapCentral: () => _enterDomain(context, central),
                  onTapSide: (m) => _selectSide(context, m),
                ),
              ),

              // Terza via al dominio: un pulsante a bolla discreto sotto il
              // Maestro al centro, nella sua palette, col nome che si aggiorna.
              Positioned(
                left: 0,
                right: 0,
                bottom: h * 0.035,
                child: Center(
                  child: _EnterDomainButton(
                    maestro: central,
                    onTap: () => _enterDomain(context, central),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Il carosello dei tre busti: centrale grande e vivo, laterali alzati verso
/// l'alto, arretrati e in penombra, uniti dal filo d'oro del cerchio.
class _Carousel extends StatelessWidget {
  const _Carousel({
    required this.central,
    required this.selected,
    required this.centralHeight,
    required this.breath,
    required this.reduceMotion,
    required this.preferred,
    required this.centralDepth,
    required this.sideDepth,
    required this.onTapCentral,
    required this.onTapSide,
  });

  final Maestro central;
  final bool selected;
  final double centralHeight;
  final Animation<double> breath;
  final bool reduceMotion;
  final Maestro preferred;

  /// Deriva di parallasse (giroscopio) del busto centrale, piano in primo
  /// piano: si inclina un po' di piu' dei laterali.
  final Offset centralDepth;

  /// Deriva di parallasse dei laterali, piano arretrato: si inclina di meno.
  final Offset sideDepth;
  final VoidCallback onTapCentral;
  final ValueChanged<Maestro> onTapSide;

  @override
  Widget build(BuildContext context) {
    // I due laterali sono gli altri due nell'ordine fisso, primo a sinistra.
    final sides = Maestro.fixedOrder.where((m) => m != central).toList();
    final sideH = centralHeight * 0.60;
    final centralW = centralHeight * 0.75;
    final sideW = sideH * 0.75;
    // Laterali sollevati: sbucano ai lati sopra la carta centrale, cosi' si
    // vede che i Maestri sono tre.
    final sideBottom = centralHeight * 0.44;

    return AnimatedBuilder(
      animation: breath,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            final breathValue = reduceMotion ? 0.5 : breath.value;

            // Il cerchio che unisce i tre Maestri e' ora l'anello del
            // Santuario, dietro i busti: qui restano solo le figure.
            return Stack(
              clipBehavior: Clip.none,
              children: [
                // Busto sinistro, alzato, arretrato e in penombra.
                Positioned(
                  left: w * 0.01,
                  bottom: sideBottom,
                  width: sideW,
                  height: sideH,
                  child: Transform.translate(
                    offset: sideDepth,
                    child: GestureDetector(
                      key: const Key('santuario_side_left'),
                      onTap: () => onTapSide(sides[0]),
                      child: MaestroBust(
                        maestro: sides[0],
                        height: sideH,
                        central: false,
                        dim: 0.5,
                        preferred: sides[0] == preferred,
                      ),
                    ),
                  ),
                ),

                // Busto destro, alzato, arretrato e in penombra.
                Positioned(
                  right: w * 0.01,
                  bottom: sideBottom,
                  width: sideW,
                  height: sideH,
                  child: Transform.translate(
                    offset: sideDepth,
                    child: GestureDetector(
                      key: const Key('santuario_side_right'),
                      onTap: () => onTapSide(sides[1]),
                      child: MaestroBust(
                        maestro: sides[1],
                        height: sideH,
                        central: false,
                        dim: 0.5,
                        preferred: sides[1] == preferred,
                      ),
                    ),
                  ),
                ),

                // Busto centrale, l'unico vivo, in primo piano: respira e si
                // inclina un po' di piu' col giroscopio.
                Positioned(
                  left: (w - centralW) / 2,
                  bottom: 0,
                  width: centralW,
                  height: centralHeight,
                  child: Transform.translate(
                    offset: centralDepth,
                    child: GestureDetector(
                      key: const Key('santuario_central_bust'),
                      onTap: onTapCentral,
                      child: MaestroBust(
                        maestro: central,
                        height: centralHeight,
                        central: true,
                        breath: breathValue,
                        preferred: central == preferred,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/// Pulsante a bolla discreto, terza via al dominio del Maestro al centro. Sta
/// nella palette del Maestro e il nome si aggiorna col centro.
class _EnterDomainButton extends StatelessWidget {
  const _EnterDomainButton({required this.maestro, required this.onTap});

  final Maestro maestro;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(ThemeKey.of(maestro));
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const Key('santuario_enter_domain'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: SpacingTokens.sm, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
            gradient: LinearGradient(
              colors: [
                palette.primary.withValues(alpha: 0.6),
                palette.surfaceElevated.withValues(alpha: 0.6),
              ],
            ),
            border: Border.all(color: palette.gold.withValues(alpha: 0.6)),
            boxShadow: [
              BoxShadow(
                color: palette.glow.withValues(alpha: 0.35),
                blurRadius: 16,
                spreadRadius: -4,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(maestro.icon, size: 16, color: palette.goldSoft),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Entra nel Dominio di ${maestro.displayName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TypographyTokens.label(size: 12)
                      .copyWith(color: palette.goldSoft, letterSpacing: 0.3),
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.chevron_right_rounded,
                  size: 16, color: palette.goldSoft),
            ],
          ),
        ),
      ),
    );
  }
}

/// Invito discreto al tocco del cielo: un piccolo simbolo che pulsa piano e una
/// riga breve. Compare dopo qualche secondo di inattivita' e si dissolve al
/// primo tocco. Con Riduci Movimento resta fermo, senza pulsazione.
class _SkyTapHint extends StatelessWidget {
  const _SkyTapHint({
    required this.visible,
    required this.pulse,
    required this.reduceMotion,
    required this.color,
  });

  final bool visible;
  final Animation<double> pulse;
  final bool reduceMotion;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 400),
        child: !visible
            ? const SizedBox(width: double.infinity)
            : Padding(
                padding: const EdgeInsets.only(top: 10),
                child: AnimatedBuilder(
                  animation: pulse,
                  builder: (context, child) {
                    final t = reduceMotion
                        ? 0.5
                        : 0.5 + 0.5 * math.sin(2 * math.pi * pulse.value);
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Opacity(
                          opacity: 0.55 + 0.35 * t,
                          child: Transform.translate(
                            offset: Offset(0, reduceMotion ? 0 : -2 * t),
                            child: Icon(Icons.touch_app_outlined,
                                size: 18, color: color),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Tocca il cielo',
                          style: TypographyTokens.label(size: 9).copyWith(
                            color: color.withValues(alpha: 0.75),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
      ),
    );
  }
}

/// Accenti del cielo del Santuario: nebulose soffuse tinte sull'accento del
/// Maestro e un paio di stelle piu' luminose a evocare i pianeti. Sparso ed
/// elegante, mai affollato.
class _SkyAccentsPainter extends CustomPainter {
  _SkyAccentsPainter({
    required this.glow,
    required this.primary,
    required this.star,
    required this.offset,
  });

  final Color glow;
  final Color primary;
  final Color star;
  final Offset offset;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    final w = size.width;
    final h = size.height;

    // Nebulose soffuse, ai lati della Luna, tinte sull'accento.
    const nebulae = [
      (Offset(0.18, 0.12), 0.30),
      (Offset(0.86, 0.13), 0.26),
      (Offset(0.66, 0.08), 0.20),
    ];
    for (var i = 0; i < nebulae.length; i++) {
      final (pos, rf) = nebulae[i];
      final center = Offset(pos.dx * w, pos.dy * h);
      final radius = w * rf;
      final color = i.isEven ? glow : primary;
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = color.withValues(alpha: 0.05)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60),
      );
    }

    // Stelle-pianeta: piu' luminose, con un piccolo alone. In alto, ai lati
    // della Luna, lontane dal testo del titolo.
    const planets = [
      (Offset(0.22, 0.11), 2.4),
      (Offset(0.80, 0.12), 1.8),
    ];
    for (final (pos, r) in planets) {
      final center = Offset(pos.dx * w, pos.dy * h);
      canvas.drawCircle(
        center,
        r * 3.2,
        Paint()
          ..color = star.withValues(alpha: 0.18)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
      canvas.drawCircle(
        center,
        r,
        Paint()..color = Colors.white.withValues(alpha: 0.85),
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SkyAccentsPainter old) =>
      old.glow != glow ||
      old.primary != primary ||
      old.star != star ||
      old.offset != offset;
}

