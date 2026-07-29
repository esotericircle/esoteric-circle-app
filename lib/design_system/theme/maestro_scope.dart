import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/maestro/maestro.dart';
import '../../core/maestro/maestro_controller.dart';
import 'maestro_palette.dart';

/// Rende disponibile ai discendenti la palette del Maestro attivo, gia'
/// interpolata durante la transizione.
///
/// Ogni widget che vuole colorarsi con il tema corrente legge
/// `context.palette`. Poiche' durante il cambio di Maestro la palette esposta
/// e' quella interpolata istante per istante, l'intera interfaccia sfuma
/// insieme: e' la dissolvenza cromatica globale richiesta.
class MaestroScope extends StatefulWidget {
  const MaestroScope({
    super.key,
    required this.child,
    this.maestro,
    this.transitionDuration = const Duration(milliseconds: 850),
  });

  final Widget child;

  /// Il proprietario di questa parte dell'albero, quando ce n'e' uno.
  ///
  /// Le arti appartengono a un Maestro, quindi il loro colore non dipende da
  /// chi era attivo un istante prima: e' il loro. Dichiararlo qui vuol dire
  /// che il colore c'e' dal primo frame, da qualunque strada si arrivi.
  ///
  /// Nullo per le schermate condivise, come il Santuario, che seguono il
  /// Maestro attivo.
  final Maestro? maestro;

  final Duration transitionDuration;

  static MaestroPalette of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<_InheritedMaestroPalette>();
    assert(scope != null, 'MaestroScope non trovato nell\'albero dei widget.');
    return scope!.palette;
  }

  @override
  State<MaestroScope> createState() => _MaestroScopeState();
}

class _MaestroScopeState extends State<MaestroScope>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late MaestroPalette _from;
  late MaestroPalette _to;
  ThemeKey? _lastKey;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.transitionDuration,
      value: 1,
    );
    // La palette iniziale viene fissata al primo didChangeDependencies.
    _from = MaestroPalette.neutral;
    _to = MaestroPalette.neutral;
  }

  /// La chiave di tema che questo scope deve mostrare.
  ///
  /// Se l'albero ha un proprietario dichiarato, e' la sua, e il Maestro attivo
  /// nel resto dell'app non c'entra: nemmeno lo si osserva, cosi' un cambio di
  /// tema avvenuto fuori non fa virare il colore sotto i piedi di chi sta
  /// usando l'arte.
  ThemeKey _chiaveDaMostrare() {
    final proprietario = widget.maestro;
    if (proprietario != null) return ThemeKey.of(proprietario);
    return context.watch<MaestroController>().activeKey;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final key = _chiaveDaMostrare();
    if (key == _lastKey) return;
    final target = MaestroPalette.forKey(key);
    if (_lastKey == null) {
      // Primo frame: nessuna animazione, si parte dalla palette corrente.
      _from = target;
      _to = target;
      _controller.value = 1;
    } else {
      // Cambio di Maestro: parti dalla palette mostrata ora e sfuma alla nuova.
      _from = _currentPalette();
      _to = target;
      _controller
        ..reset()
        ..forward();
    }
    _lastKey = key;
  }

  MaestroPalette _currentPalette() =>
      MaestroPalette.lerp(_from, _to, _controller.value);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final curved =
            Curves.easeInOutCubic.transform(_controller.value);
        final palette = MaestroPalette.lerp(_from, _to, curved);
        return _InheritedMaestroPalette(
          palette: palette,
          child: child!,
        );
      },
      child: widget.child,
    );
  }
}

class _InheritedMaestroPalette extends InheritedWidget {
  const _InheritedMaestroPalette({
    required this.palette,
    required super.child,
  });

  final MaestroPalette palette;

  @override
  bool updateShouldNotify(_InheritedMaestroPalette oldWidget) =>
      oldWidget.palette != palette;
}

/// Scorciatoia leggibile per accedere alla palette del Maestro attivo.
extension MaestroPaletteContext on BuildContext {
  MaestroPalette get palette => MaestroScope.of(this);
}
