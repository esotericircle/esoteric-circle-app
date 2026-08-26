import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/maestro/maestro.dart';
import '../../../design_system/theme/maestro_palette.dart';
import '../../../design_system/tokens/spacing_tokens.dart';

/// Rivelazione cinematografica del Maestro: la figura, grande e presente, esce
/// dalla propria cornice a carta (la testa rompe il bordo superiore), con aura
/// che pulsa nel suo colore, galleggiamento e respiro, e un ingresso scenico.
///
/// L'animazione piena del personaggio arriva a C3; qui la figura non e' mai
/// ferma nel vuoto.
///
/// **IL VIDEO DELLA RIVELAZIONE NON ABITA PIU' QUI, ordine BR voce 1.** Per un
/// giorno il filmato del Maestro e' stato montato dentro questo Stack, sopra il
/// ritratto e con le misure della cornice: era cio' che l'ordine BQ chiedeva, e
/// cio' che l'ordine BQ chiedeva era sbagliato. Adesso il filmato e' lo sfondo
/// dell'intera schermata di rivelazione e vive in `MaestroRevealScreen`; questa
/// carta e' cio' che si vede quando un filmato non c'e', ed e' rimasta identica
/// a com'era.
class MaestroCardReveal extends StatefulWidget {
  const MaestroCardReveal({
    super.key,
    required this.maestro,
    required this.palette,
    this.reduceMotion = false,
    this.width = 240,
    this.height = 340,
  });

  final Maestro maestro;
  final MaestroPalette palette;
  final bool reduceMotion;
  final double width;
  final double height;

  @override
  State<MaestroCardReveal> createState() => _MaestroCardRevealState();
}

class _MaestroCardRevealState extends State<MaestroCardReveal>
    with TickerProviderStateMixin {
  late final AnimationController _enter;
  late final AnimationController _idle;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _idle = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
    if (widget.reduceMotion) {
      // Con Riduci Movimento la figura appare presente e ferma, senza ingresso
      // scenico ne galleggiamento.
      _enter.value = 1;
    } else {
      _enter.forward();
      _idle.repeat();
    }
  }

  @override
  void dispose() {
    _enter.dispose();
    _idle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.palette;
    return AnimatedBuilder(
      animation: Listenable.merge([_enter, _idle]),
      builder: (context, _) {
        final e = Curves.easeOutBack.transform(_enter.value.clamp(0.0, 1.0));
        final opacity = (_enter.value * 1.6).clamp(0.0, 1.0);
        final phase = _idle.value * 2 * math.pi;
        final floatY = math.sin(phase) * 6;
        final breath = 1 + 0.012 * math.sin(phase);
        final auraPulse = 0.5 + 0.5 * math.sin(phase);
        final entranceRise = (1 - e) * 46;
        final glowBurst = (1 - _enter.value);

        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, floatY + entranceRise),
            child: Transform.scale(
              scale: (0.7 + 0.3 * e) * breath,
              // FittedBox: il Maestro esce dalla cornice di 58 px, e su uno
              // schermo basso quel debordare finiva sopra il soprattitolo e
              // il nome, coprendoli. Cosi' la carta si rimpicciolisce invece
              // di traboccare, e il testo sopra resta sempre leggibile.
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                width: widget.width,
                height: widget.height + 70, // spazio per la testa che esce
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: [
                    // Aura pulsante nel colore del Maestro.
                    Positioned(
                      bottom: 20,
                      child: Container(
                        width: widget.width * 1.15,
                        height: widget.width * 1.15,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              p.glow.withValues(
                                  alpha: 0.18 + 0.22 * auraPulse + 0.3 * glowBurst),
                              p.primary.withValues(alpha: 0.12),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                    // Cornice a carta.
                    Positioned(
                      bottom: 0,
                      child: _CardFrame(
                        palette: p,
                        width: widget.width,
                        height: widget.height,
                      ),
                    ),
                    // Il Maestro che esce dalla cornice (testa sopra il bordo).
                    Positioned(
                      bottom: 8,
                      child: RitrattoInteroDelMaestro(
                        maestro: widget.maestro,
                        altezza: widget.height + 58,
                      ),
                    ),
                  ],
                ),
              ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// LA FIGURA INTERA DEL MAESTRO, e la porta da cui passa.
///
/// **Esiste perche' la scelta dell'immagine del Maestro deve vivere in un punto
/// solo, e la guardia `il_busto_e_la_forma_del_maestro_test` lo pretende
/// sull'elenco dei file.** Le schermate in cui il Maestro presiede passano da
/// `BustoDelMaestro`, che lo taglia dalla vita in su; qui invece il Maestro non
/// presiede niente, e' la figura intera dentro la sua carta. Il velo della
/// rivelazione ha bisogno della STESSA figura per tenerla sotto al filmato, e
/// senza questa porta se la sarebbe presa da se': due punti che scelgono la
/// stessa immagine divergono al primo cambiamento.
class RitrattoInteroDelMaestro extends StatelessWidget {
  const RitrattoInteroDelMaestro({
    super.key,
    required this.maestro,
    required this.altezza,
  });

  final Maestro maestro;

  /// L'altezza del riquadro. Nella carta e' l'altezza della cornice piu' i 58
  /// della testa che esce dal bordo.
  final double altezza;

  /// L'altezza a cui la carta disegna la figura con le sue misure
  /// predefinite: 340 di cornice piu' i 58 della testa che esce.
  static const double altezzaNellaCarta = 340 + 58;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: altezza,
      child: Image.asset(
        maestro.avatarAsset,
        fit: BoxFit.contain,
        alignment: Alignment.bottomCenter,
        errorBuilder: (_, __, ___) => Icon(
          maestro.icon,
          size: 120,
          color: MaestroPalette.forKey(ThemeKey.of(maestro)).goldSoft,
        ),
      ),
    );
  }
}

class _CardFrame extends StatelessWidget {
  const _CardFrame({
    required this.palette,
    required this.width,
    required this.height,
  });

  final MaestroPalette palette;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [palette.surfaceElevated, palette.deepest],
        ),
        border: Border.all(color: palette.gold.withValues(alpha: 0.8), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
            border:
                Border.all(color: palette.gold.withValues(alpha: 0.35), width: 1),
          ),
          child: Stack(
            children: [
              for (final a in const [
                Alignment.topLeft,
                Alignment.topRight,
                Alignment.bottomLeft,
                Alignment.bottomRight,
              ])
                Align(
                  alignment: a,
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Transform.rotate(
                      angle: math.pi / 4,
                      child: Container(
                        width: 6,
                        height: 6,
                        color: palette.goldSoft.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
