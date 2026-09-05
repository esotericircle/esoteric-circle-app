import 'package:flutter/material.dart';

import '../theme/maestro_palette.dart';
import 'cosmos_background.dart';

/// Slot di fondale condiviso dei cinque rituali quotidiani.
///
/// Un solo componente parametrico, usato da tutti e cinque gli screen (alba,
/// soffio, oracolo, runa del tramonto, buonanotte). Accetta il percorso di un
/// asset PNG di fondale: quando c'e', lo rende full-bleed; quando manca, o non
/// si carica, monta il motore unico della scena, [CosmosBackground], con la
/// tinta del Maestro dell'elemento imposta e il suo seme: prima qui viveva un
/// painter gemello senza sensore, il quarto modo di disegnare lo stesso cielo.
///
/// Obiettivo: quando arriveranno i PNG definitivi basta cablarli nello slot
/// [assetPath], senza toccare altro.
///
/// La tinta viene dalla [palette] passata dallo screen, cioe' quella
/// dell'elemento del rito, non da `context.palette`: nei riti alba e
/// buonanotte il Maestro ruota col giorno e non coincide con quello attivo
/// nello shell.
class RitualBackdrop extends StatelessWidget {
  const RitualBackdrop({
    super.key,
    required this.palette,
    required this.child,
    this.assetPath,
  });

  /// Palette dell'elemento del rito, per la tinta dell'accento.
  final MaestroPalette palette;

  /// Percorso dell'asset PNG di fondale, quando disponibile. Null, o asset non
  /// caricabile, ripiega sul fondo procedurale.
  final String? assetPath;

  /// Contenuto del rito, disegnato sopra il fondale.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final path = assetPath;
    if (path != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            path,
            fit: BoxFit.cover,
            // Se il PNG manca o non si decodifica, non si resta con un buco:
            // si ripiega sul fondo procedurale, stesso slot, stessa tinta.
            errorBuilder: (context, error, stack) => CosmosBackground(
              seed: 2,
              paletteOverride: palette,
              showZodiac: false,
              child: const SizedBox.expand(),
            ),
          ),
          child,
        ],
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        CosmosBackground(
          seed: 2,
          paletteOverride: palette,
          showZodiac: false,
          child: const SizedBox.expand(),
        ),
        child,
      ],
    );
  }
}
