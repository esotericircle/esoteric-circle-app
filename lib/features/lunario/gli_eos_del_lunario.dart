import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **GLI ACQUISTI A EOS DEL CALENDARIO LUNARE.** Ordine FV voce FV.12, 15
/// ottobre 2026.
///
/// Tiene sul telefono, sotto il prefisso `lunario.` (come i promemoria di
/// FV.08), i mesi extra comprati (`ListinoDegliEos.meseExtraDelLunario`) e
/// le proposte insieme sbloccate (`ListinoDegliEos.
/// propostaInsiemeDelLunario`): `IlCerchioSociale.compraUnMeseDelLunario` e
/// `.compraUnaPropostaInsieme` sono le porte vere del server, scritte e non
/// pubblicate (R3 dell'ordine). **Finche' il server non le pubblica e non
/// manda questi numeri con lo stato del Cerchio, questa classe e' la sola
/// verita' che il telefono ha**: la voce resta APERTA IN ATTESA DI VERIFICA
/// per la parte che dipende dal server vero, e il rapporto lo dichiara.
class GliEosDelLunario extends ChangeNotifier {
  static const String _chiaveMesiExtra = 'lunario.mesiExtra';
  static const String _chiaveProposteInsieme = 'lunario.proposteInsieme';

  int _mesiExtra = 0;
  int _proposteInsieme = 0;
  bool _letto = false;

  /// Quanti mesi in più del piano sono stati comprati.
  int get mesiExtra => _mesiExtra;

  /// Quante proposte insieme comprate restano da spendere.
  int get proposteInsieme => _proposteInsieme;

  bool get letto => _letto;

  Future<void> leggi() async {
    try {
      final p = await SharedPreferences.getInstance();
      _mesiExtra = p.getInt(_chiaveMesiExtra) ?? 0;
      _proposteInsieme = p.getInt(_chiaveProposteInsieme) ?? 0;
    } catch (errore) {
      debugPrint('Calendario Lunare: il portafoglio del lunario non si '
          'legge ($errore)');
    }
    _letto = true;
    notifyListeners();
  }

  /// Registra un mese extra appena comprato (dopo l'esito positivo del
  /// server).
  Future<void> aggiungiUnMeseExtra() async {
    _mesiExtra++;
    notifyListeners();
    await _scrivi();
  }

  /// Registra una proposta insieme appena comprata.
  Future<void> aggiungiUnaPropostaInsieme() async {
    _proposteInsieme++;
    notifyListeners();
    await _scrivi();
  }

  /// Consuma una proposta insieme comprata, quando la persona manda davvero
  /// la proposta: vero se ce n'era una da consumare.
  bool consumaUnaPropostaInsieme() {
    if (_proposteInsieme <= 0) return false;
    _proposteInsieme--;
    notifyListeners();
    unawaited(_scrivi());
    return true;
  }

  Future<void> _scrivi() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setInt(_chiaveMesiExtra, _mesiExtra);
      await p.setInt(_chiaveProposteInsieme, _proposteInsieme);
    } catch (errore) {
      debugPrint('Calendario Lunare: il portafoglio del lunario non si '
          'scrive ($errore)');
    }
  }
}
