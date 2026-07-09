import 'package:flutter/foundation.dart';

import 'maestro.dart';

/// Stato del Maestro attivo dell'app.
///
/// Espone la chiave di tema corrente (uno dei tre Maestri oppure neutro) e la
/// cambia. La transizione visiva vera e propria, la dissolvenza cromatica, e'
/// gestita dal livello di presentazione (`MaestroScope`), che osserva questo
/// controller: qui resta solo lo stato, senza logica di animazione.
///
/// Riferimento: Home Il Santuario, cambio di Maestro che trigga la
/// transizione globale del tema colori.
class MaestroController extends ChangeNotifier {
  MaestroController({ThemeKey initial = const ThemeKey.neutral()})
      : _activeKey = initial;

  ThemeKey _activeKey;
  ThemeKey get activeKey => _activeKey;

  /// Maestro attivo, oppure null quando il tema e' neutro.
  Maestro? get activeMaestro => _activeKey.maestro;

  bool get isNeutral => _activeKey.isNeutral;

  /// Seleziona un Maestro e passa al suo tema.
  void selectMaestro(Maestro maestro) => _setKey(ThemeKey.of(maestro));

  /// Torna allo stato neutro (Il Santuario senza Maestro selezionato).
  void clearMaestro() => _setKey(const ThemeKey.neutral());

  /// Tocca lo stesso Maestro gia' attivo: torna a neutro (toggle).
  void toggleMaestro(Maestro maestro) {
    if (_activeKey.maestro == maestro) {
      clearMaestro();
    } else {
      selectMaestro(maestro);
    }
  }

  void _setKey(ThemeKey key) {
    if (key == _activeKey) return;
    _activeKey = key;
    notifyListeners();
  }
}
