import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../../core/rituals/animal_catalog.dart';
import '../../../../core/viaggio/l_apparizione.dart';

/// **LA SAGOMA CHE ATTRAVERSA IL CIELO.** Ordine DE voce 10, 11 settembre 2026.
///
/// *"Non porta testo, non e' toccabile, non annuncia niente. Passa e basta."*
///
/// **TRE DIVIETI SCRITTI NEL CODICE, e si vedono tutti e tre in questa
/// classe.** Nessun `Text` dentro, quindi non porta testo; `IgnorePointer`
/// attorno, quindi non e' toccabile; nessun callback in uscita, quindi non
/// annuncia niente a nessuno. Non sono tre commenti: sono tre fatti che una
/// guardia puo' leggere.
///
/// **E NON DECIDE SE MOSTRARSI.** Quella decisione vive in [LApparizione], che
/// e' materia di regole e di numeri; qui c'e' solo il passaggio. Chi la monta
/// la costruisce **dopo** aver chiesto, e cosi' l'unica strada per vederla
/// resta quella con le cinque porte.
class ApparizioneDellAnimale extends StatefulWidget {
  const ApparizioneDellAnimale({
    super.key,
    required this.animale,
    this.quandoEPassata,
  });

  /// L'animale riconosciuto. **La sagoma e' la sua**, presa dal canale alpha
  /// della stessa illustrazione che sta nel Passaporto.
  final GuideAnimal animale;

  /// Chiamata quando il passaggio e' finito, perche' chi la monta possa
  /// toglierla dall'albero. **Non e' un annuncio alla persona**: e' pulizia.
  final VoidCallback? quandoEPassata;

  @override
  State<ApparizioneDellAnimale> createState() =>
      _ApparizioneDellAnimaleState();
}

class _ApparizioneDellAnimaleState extends State<ApparizioneDellAnimale>
    with SingleTickerProviderStateMixin {
  late final AnimationController _passaggio = AnimationController(
    vsync: this,
    duration: LApparizione.quantoDura,
  );

  @override
  void initState() {
    super.initState();
    _passaggio.forward().whenComplete(() {
      if (mounted) widget.quandoEPassata?.call();
    });
  }

  @override
  void dispose() {
    _passaggio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // **SE IL SISTEMA CHIEDE MENO MOVIMENTO, non si disegna niente.** La porta
    // vera sta in `LApparizione.siPuoMostrare`, ma questa e' la seconda
    // serratura: una funzione che si accende per caso non deve avere una sola
    // chiave.
    if (MediaQuery.of(context).disableAnimations) {
      return const SizedBox.shrink();
    }
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _passaggio,
        builder: (context, _) {
          final t = _passaggio.value;
          // **ENTRA DA UN LATO ED ESCE DALL'ALTRO**, e non si ferma mai al
          // centro: fermarsi vorrebbe dire chiedere di essere guardata.
          final quanto = -0.25 + 1.5 * t;
          // **SI VEDE SOLO NEL MEZZO DEL PASSAGGIO**: appare e sparisce
          // dentro i bordi, cosi' non c'e' un istante in cui si materializza.
          final quantaLuce = (1 - (2 * t - 1).abs()).clamp(0.0, 1.0);
          return LayoutBuilder(
            builder: (context, vincoli) {
              final larga = vincoli.maxWidth.isFinite ? vincoli.maxWidth : 360;
              final alta = vincoli.maxHeight.isFinite ? vincoli.maxHeight : 640;
              final misura = larga * 0.22;
              return Stack(
                children: [
                  Positioned(
                    left: larga * quanto,
                    // Una curva appena accennata: una sagoma che attraversa in
                    // orizzontale perfetto sembra un banner.
                    top: alta * (0.16 + 0.05 * (t - 0.5) * (t - 0.5) * 4),
                    width: misura,
                    height: misura,
                    child: Opacity(
                      opacity: 0.42 * quantaLuce,
                      child: ImageFiltered(
                        imageFilter: ui.ImageFilter.blur(
                            sigmaX: misura * 0.03,
                            sigmaY: misura * 0.03,
                            tileMode: TileMode.decal),
                        child: ColorFiltered(
                          // La forma vera dell'animale, presa dal suo alpha.
                          colorFilter: const ColorFilter.mode(
                              Color(0xFF0A0710), BlendMode.srcIn),
                          child: Image.asset(
                            widget.animale.fullPath,
                            key: const Key('viaggio_apparizione'),
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) =>
                                const SizedBox.shrink(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
