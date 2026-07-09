import 'package:flutter/foundation.dart';

import '../../core/maestro/maestro.dart';
import '../../core/maestro/maestro_controller.dart';

/// Le destinazioni della navigazione principale (bottom bar).
///
/// Il Santuario e' l'ancora neutra; i tre Maestri sono le altre voci. La
/// bottom bar dei tre Maestri e il Santuario condividono questo insieme.
enum AppDestination {
  santuario,
  medora,
  aura,
  caligo;

  /// Maestro associato alla destinazione, null per il Santuario.
  Maestro? get maestro => switch (this) {
        AppDestination.santuario => null,
        AppDestination.medora => Maestro.medora,
        AppDestination.aura => Maestro.aura,
        AppDestination.caligo => Maestro.caligo,
      };

  static AppDestination forMaestro(Maestro? maestro) => switch (maestro) {
        null => AppDestination.santuario,
        Maestro.medora => AppDestination.medora,
        Maestro.aura => AppDestination.aura,
        Maestro.caligo => AppDestination.caligo,
      };
}

/// Coordina la voce di navigazione attiva e la tiene sincronizzata con il
/// Maestro attivo: cambiare tab cambia Maestro (e quindi il tema), e viceversa.
class NavigationController extends ChangeNotifier {
  NavigationController(this._maestro) {
    _current = AppDestination.forMaestro(_maestro.activeMaestro);
    _maestro.addListener(_syncFromMaestro);
  }

  final MaestroController _maestro;
  late AppDestination _current;

  AppDestination get current => _current;
  int get index => _current.index;

  /// Naviga a una destinazione e allinea il tema del Maestro.
  void goTo(AppDestination destination) {
    if (destination == _current) return;
    _current = destination;
    final maestro = destination.maestro;
    if (maestro == null) {
      _maestro.clearMaestro();
    } else {
      _maestro.selectMaestro(maestro);
    }
    notifyListeners();
  }

  void goToIndex(int index) => goTo(AppDestination.values[index]);

  /// Se il Maestro cambia da un'altra parte dell'app, aggiorna la tab.
  void _syncFromMaestro() {
    final target = AppDestination.forMaestro(_maestro.activeMaestro);
    if (target != _current) {
      _current = target;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _maestro.removeListener(_syncFromMaestro);
    super.dispose();
  }
}
