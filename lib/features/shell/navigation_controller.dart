import 'package:flutter/foundation.dart';

import '../../core/maestro/maestro.dart';
import '../../core/maestro/maestro_controller.dart';

/// Le due schermate ancorate nello shell, sotto la bottom bar.
///
/// Il Santuario e' la schermata eroe; il Cosmic Passport e' la quinta
/// destinazione distinta. I tre Maestri della bottom bar non sono schermate a
/// se': scelgono il busto centrale del Santuario. Il dominio di un Maestro e la
/// chat sono route spinte sopra lo shell, con la loro freccia Indietro e senza
/// bottom bar, cosi' restano superfici immersive.
enum ShellView { santuario, passport }

/// Coordina la schermata dello shell e, con il controller del Maestro, il
/// Maestro centrale del Santuario.
class NavigationController extends ChangeNotifier {
  NavigationController(this._maestro);

  final MaestroController _maestro;

  ShellView _view = ShellView.santuario;
  ShellView get view => _view;

  /// Ancora al Santuario in stato neutro: la panoramica dei tre, nessuno
  /// scelto. E' cio' che fa la voce Santuario della bottom bar.
  void goToSantuario() {
    _maestro.clearMaestro();
    if (_view != ShellView.santuario) {
      _view = ShellView.santuario;
    }
    notifyListeners();
  }

  /// Porta al Santuario e mette quel Maestro al centro (busti che ruotano,
  /// aura predominante, cosmo che vira). E' cio' che fanno le voci Maestro
  /// della bottom bar.
  void selectCentral(Maestro maestro) {
    _view = ShellView.santuario;
    _maestro.selectMaestro(maestro);
    notifyListeners();
  }

  /// Quinta destinazione: il Cosmic Passport.
  void goToPassport() {
    if (_view != ShellView.passport) {
      _view = ShellView.passport;
      notifyListeners();
    }
  }
}
