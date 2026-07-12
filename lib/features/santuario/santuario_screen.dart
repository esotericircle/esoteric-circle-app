import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/astro/moon_phase.dart';
import '../../core/maestro/maestro.dart';
import '../../core/maestro/maestro_controller.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../services/app_services.dart';
import '../maestri/domain_screen.dart';
import 'widgets/maestro_bust.dart';
import 'widgets/moon_widget.dart';

/// La schermata eroe, il Santuario.
///
/// Un unico palco antico e neutro con la Luna in alto nella sua fase reale,
/// molto buio e spazio vuoto attorno. Tre mezzibusti davanti: al centro, piu'
/// grande, l'ultimo Maestro usato; gli altri due arretrati e in penombra. Solo
/// il centrale e' vivo (respiro idle). Un filo d'oro unisce i tre. Toccare il
/// centro entra nel dominio, toccare un laterale lo porta al centro.
///
/// Costruita ai punti dati da Mauro: nel repo non c'e' una Specifica del
/// Santuario dedicata, solo i quattro briefing. Fondo e tempio sono segnaposto
/// architettonico, l'asset ricco arriva dopo.
class SantuarioScreen extends StatefulWidget {
  const SantuarioScreen({super.key});

  /// Maestro preferito, segnaposto in attesa dell'assegnazione all'onboarding.
  static const Maestro preferred = Maestro.medora;

  @override
  State<SantuarioScreen> createState() => _SantuarioScreenState();
}

class _SantuarioScreenState extends State<SantuarioScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breath;
  Maestro? _lastCentral;
  String? _greeting;
  Timer? _greetingTimer;
  final Map<Maestro, int> _greetingIndex = {};

  static const Map<Maestro, List<String>> _greetings = {
    Maestro.medora: [
      'Medora ti accoglie.',
      'Medora ti sorride.',
      'Le stelle si voltano verso di te.',
    ],
    Maestro.aura: [
      'Aura respira con te.',
      'Aura ti avvolge.',
      'Un respiro e sei qui.',
    ],
    Maestro.caligo: [
      'Caligo alza lo sguardo.',
      'Caligo ti riconosce.',
      'Le rune si destano.',
    ],
  };

  @override
  void initState() {
    super.initState();
    _breath = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _greetingTimer?.cancel();
    _breath.dispose();
    super.dispose();
  }

  void _onCentralChanged(Maestro maestro) {
    // Saluto breve a rotazione, mai lo stesso due volte di fila, non blocca.
    final variants = _greetings[maestro]!;
    final next = ((_greetingIndex[maestro] ?? -1) + 1) % variants.length;
    _greetingIndex[maestro] = next;
    setState(() => _greeting = variants[next]);
    _greetingTimer?.cancel();
    _greetingTimer = Timer(const Duration(milliseconds: 1300), () {
      if (mounted) setState(() => _greeting = null);
    });
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

  @override
  Widget build(BuildContext context) {
    final active = context.watch<MaestroController>().activeMaestro;
    final central = active ?? SantuarioScreen.preferred;
    final selected = active != null;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    // Segnala il cambio di centrale per il saluto (solo su un Maestro scelto).
    if (selected && central != _lastCentral) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _onCentralChanged(central);
      });
    }
    _lastCentral = selected ? central : null;

    final moon = MoonPhase.forDate(DateTime.now());

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          // I busti occupano la fascia centrale e bassa in modo pieno, non
          // schiacciati sul fondo. Una carta piu' alta riduce lo spazio morto
          // sopra.
          final centralH = (h * 0.54).clamp(240.0, 460.0);
          // Sollevati dal margine inferiore, cosi' poggiano sul palco senza
          // sprofondare dietro la bottom bar.
          final carouselBottom = h * 0.05;
          final carouselHeight = centralH * 1.28;

          return Stack(
            children: [
              // Luna in alto nella fase reale, illumina la parte alta.
              Positioned(
                top: h * 0.015,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    MoonWidget(phase: moon, size: (w * 0.12).clamp(58.0, 108.0)),
                    Text(
                      moon.italianName,
                      style: TypographyTokens.label(size: 11).copyWith(
                        color: ColorTokens.textMuted,
                      ),
                    ),
                  ],
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
                  onTapCentral: () => _enterDomain(context, central),
                  onTapSide: (m) => _selectSide(context, m),
                ),
              ),

              // Saluto breve appena sopra i busti, non blocca mai.
              if (_greeting != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: carouselBottom + centralH * 1.04,
                  child: IgnorePointer(
                    child: Center(
                      child: AnimatedOpacity(
                        opacity: 1,
                        duration: const Duration(milliseconds: 250),
                        child: Text(
                          _greeting!,
                          style: TypographyTokens.display(size: 18).copyWith(
                            color: context.palette.goldSoft,
                          ),
                        ),
                      ),
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

/// Il carosello dei tre busti: centrale grande e vivo, laterali arretrati e in
/// penombra, uniti dal filo d'oro del cerchio.
class _Carousel extends StatelessWidget {
  const _Carousel({
    required this.central,
    required this.selected,
    required this.centralHeight,
    required this.breath,
    required this.reduceMotion,
    required this.preferred,
    required this.onTapCentral,
    required this.onTapSide,
  });

  final Maestro central;
  final bool selected;
  final double centralHeight;
  final Animation<double> breath;
  final bool reduceMotion;
  final Maestro preferred;
  final VoidCallback onTapCentral;
  final ValueChanged<Maestro> onTapSide;

  @override
  Widget build(BuildContext context) {
    // I due laterali sono gli altri due nell'ordine fisso, primo a sinistra.
    final sides = Maestro.fixedOrder.where((m) => m != central).toList();
    final sideH = centralHeight * 0.64;
    final centralW = centralHeight * 0.75;
    final sideW = sideH * 0.75;

    return AnimatedBuilder(
      animation: breath,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            final breathValue = reduceMotion ? 0.5 : breath.value;

            // Punti di aggancio del filo d'oro, all'altezza del petto.
            final centralPoint = Offset(w / 2, c.maxHeight - centralHeight * 0.5);
            final leftPoint = Offset(w * 0.14 + sideW / 2,
                c.maxHeight - centralHeight * 0.30 - sideH * 0.5);
            final rightPoint = Offset(w * 0.86 - sideW / 2,
                c.maxHeight - centralHeight * 0.30 - sideH * 0.5);

            return Stack(
              clipBehavior: Clip.none,
              children: [
                // Il cerchio visibile: filo sottile di luce dorata.
                Positioned.fill(
                  child: CustomPaint(
                    painter: _GoldenThreadPainter(
                      a: leftPoint,
                      b: centralPoint,
                      cc: rightPoint,
                      color: context.palette.goldSoft,
                    ),
                  ),
                ),

                // Busto sinistro, arretrato e in penombra.
                Positioned(
                  left: w * 0.01,
                  bottom: centralHeight * 0.30,
                  width: sideW,
                  height: sideH,
                  child: GestureDetector(
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

                // Busto destro, arretrato e in penombra.
                Positioned(
                  right: w * 0.01,
                  bottom: centralHeight * 0.30,
                  width: sideW,
                  height: sideH,
                  child: GestureDetector(
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

                // Busto centrale, l'unico vivo.
                Positioned(
                  left: (w - centralW) / 2,
                  bottom: 0,
                  width: centralW,
                  height: centralHeight,
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
              ],
            );
          },
        );
      },
    );
  }
}

/// Filo d'oro sottile che unisce i tre Maestri, discreto.
class _GoldenThreadPainter extends CustomPainter {
  _GoldenThreadPainter({
    required this.a,
    required this.b,
    required this.cc,
    required this.color,
  });

  final Offset a;
  final Offset b;
  final Offset cc;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2);
    // Un arco morbido dai laterali al centro.
    final smooth = Path()
      ..moveTo(a.dx, a.dy)
      ..quadraticBezierTo((a.dx + b.dx) / 2, b.dy - 30, b.dx, b.dy)
      ..quadraticBezierTo((b.dx + cc.dx) / 2, b.dy - 30, cc.dx, cc.dy);
    canvas.drawPath(smooth, paint);
    // piccoli nodi di luce sui Maestri
    final dot = Paint()..color = color.withValues(alpha: 0.7);
    for (final o in [a, b, cc]) {
      canvas.drawCircle(o, 2, dot);
    }
  }

  @override
  bool shouldRepaint(_GoldenThreadPainter old) =>
      old.a != a || old.b != b || old.cc != cc || old.color != color;
}
