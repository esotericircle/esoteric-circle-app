import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **GLI ACQUISTI A EOS DEL RESPIRO DELLA LUNA.** Ordine FX voce FX.10, 16
/// ottobre 2026.
///
/// Sul modello esatto di `GliEosDelLunario` (ordine FV voce FV.12): tiene
/// sul telefono, sotto il prefisso `respiro.`, i crediti comprati a Eos
/// finche' il server non li pubblica (R3 dell'ordine) e non manda questi
/// numeri col resto dello stato del Cerchio. **Finche' quel giorno non
/// arriva, questa classe e' la sola verita' che il telefono ha**: la voce
/// resta APERTA IN ATTESA DI VERIFICA per la parte che dipende dal server
/// vero, e il rapporto lo dichiara.
///
/// Le porte vere del server (quando saranno pubblicate, nella stessa forma
/// delle altre voci a Eos del Cerchio) consumano
/// `ListinoDegliEos.perlaRicucita`, `.respiroInsiemeUnaVolta` e
/// `.collanaADueUnaVolta`.
class GliEosDelRespiro extends ChangeNotifier {
  static const String _chiavePerleRicucite = 'respiro.perleRicucite';
  static const String _chiaveAssaggiRespiroInsieme =
      'respiro.assaggiRespiroInsieme';
  static const String _chiaveCollaneADueComprate =
      'respiro.collaneADueComprate';

  int _perleRicucite = 0;
  int _assaggiRespiroInsieme = 0;
  int _collaneADueComprate = 0;
  bool _letto = false;

  /// Quante perle ricucite comprate restano da spendere.
  int get perleRicucite => _perleRicucite;

  /// Quanti assaggi di Respiriamo insieme comprati restano da spendere.
  int get assaggiRespiroInsieme => _assaggiRespiroInsieme;

  /// Quante collane a due comprate a Eos restano da spendere.
  int get collaneADueComprate => _collaneADueComprate;

  bool get letto => _letto;

  Future<void> leggi() async {
    try {
      final p = await SharedPreferences.getInstance();
      _perleRicucite = p.getInt(_chiavePerleRicucite) ?? 0;
      _assaggiRespiroInsieme = p.getInt(_chiaveAssaggiRespiroInsieme) ?? 0;
      _collaneADueComprate = p.getInt(_chiaveCollaneADueComprate) ?? 0;
    } catch (errore) {
      debugPrint('Respiro della Luna: il portafoglio non si legge ($errore)');
    }
    _letto = true;
    notifyListeners();
  }

  /// Registra una perla ricucita appena comprata (dopo l'esito positivo del
  /// server).
  Future<void> aggiungiUnaPerlaRicucita() async {
    _perleRicucite++;
    notifyListeners();
    await _scrivi();
  }

  /// Registra un assaggio di Respiriamo insieme appena comprato.
  Future<void> aggiungiUnAssaggioDiRespiroInsieme() async {
    _assaggiRespiroInsieme++;
    notifyListeners();
    await _scrivi();
  }

  /// Registra una collana a due comprata a Eos.
  Future<void> aggiungiUnaCollanaADue() async {
    _collaneADueComprate++;
    notifyListeners();
    await _scrivi();
  }

  /// Consuma una perla ricucita comprata, quando la persona la ricuce per
  /// davvero: vero se ce n'era una da consumare.
  bool consumaUnaPerlaRicucita() {
    if (_perleRicucite <= 0) return false;
    _perleRicucite--;
    notifyListeners();
    unawaited(_scrivi());
    return true;
  }

  /// Consuma un assaggio di Respiriamo insieme, quando la persona entra per
  /// davvero nel conteggio collettivo.
  bool consumaUnAssaggioDiRespiroInsieme() {
    if (_assaggiRespiroInsieme <= 0) return false;
    _assaggiRespiroInsieme--;
    notifyListeners();
    unawaited(_scrivi());
    return true;
  }

  /// Consuma una collana a due comprata, quando l'invito parte per davvero.
  bool consumaUnaCollanaADue() {
    if (_collaneADueComprate <= 0) return false;
    _collaneADueComprate--;
    notifyListeners();
    unawaited(_scrivi());
    return true;
  }

  Future<void> _scrivi() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setInt(_chiavePerleRicucite, _perleRicucite);
      await p.setInt(_chiaveAssaggiRespiroInsieme, _assaggiRespiroInsieme);
      await p.setInt(_chiaveCollaneADueComprate, _collaneADueComprate);
    } catch (errore) {
      debugPrint('Respiro della Luna: il portafoglio non si scrive ($errore)');
    }
  }
}
