/// CHI TIENE IL TOKEN E SINCRONIZZA LE SCELTE. Ordine CG voce 16.
///
/// **IL LEGAME COL MENU' CHE ESISTE, ed e' il vincolo dell'ordine.** Le push
/// si accendono e si spengono dalle STESSE cinque scelte di
/// `SceltaDegliAvvisi`, con le STESSE ore. **Non nasce un secondo elenco di
/// interruttori**, e una prova enumera i punti di `lib/` che accendono o
/// spengono l'avviso di un Dono e pretende che passino tutti da li'.
///
/// **QUANDO SI SINCRONIZZA, e la ragione e' il costo.** Non a ogni tocco: a
/// ogni CAMBIO VERO, cioe' quando il token, il fuso o l'elenco delle scelte
/// non sono piu' quelli mandati l'ultima volta. Chi apre la pagina delle
/// notifiche, accende e riaccende lo stesso Dono, torna alla scelta di prima
/// e non manda niente.
///
/// **IL TOKEN E' UN DATO NUOVO E SE NE VA CON LA PERSONA**: sta sotto il
/// prefisso `push.`, che e' in `CioCheETuo`, ed e' nominato nella privacy
/// policy.
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/push/porta_delle_push.dart';
import 'daily_elements.dart';
import 'scelta_degli_avvisi.dart';

class CustodeDellePush extends ChangeNotifier {
  CustodeDellePush({
    PortaDelleScelte porta = const PortaSpentaDelleScelte(),
  }) : _porta = porta;

  final PortaDelleScelte _porta;

  /// **IL PREFISSO E' `push.`**, gia' in `CioCheETuo`: il token e' un dato
  /// della persona, e se ne va con lei.
  static const String prefisso = 'push.';
  static const String _kToken = 'push.token';
  static const String _kUltimeMandate = 'push.ultimeMandate';

  String? _token;
  String? get token => _token;

  /// Cosa si e' mandato l'ultima volta, per non rimandare l'uguale.
  String _ultimeMandate = '';

  /// **QUANTE SINCRONIE SONO PARTITE**, per le misure.
  int sincronieVersoIlServer = 0;

  bool _caricato = false;
  bool get caricato => _caricato;

  Future<void> carica() async {
    if (_caricato) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString(_kToken);
      _ultimeMandate = prefs.getString(_kUltimeMandate) ?? '';
    } catch (errore) {
      debugPrint('Push: le chiavi non si leggono. $errore');
    }
    _caricato = true;
    notifyListeners();
  }

  /// **IL TOKEN NUOVO, dal sistema.**
  ///
  /// Si chiama al primo avvio e a ogni rigenerazione: e' la cura del token
  /// che scade, cioe' la parte che tutti dimenticano. Senza, dopo la prima
  /// rigenerazione il server spingerebbe verso un indirizzo morto.
  Future<void> tokenNuovo(String token) async {
    if (token == _token) return;
    _token = token;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kToken, token);
    } catch (errore) {
      debugPrint('Push: il token non si salva. $errore');
    }
  }

  /// SINCRONIZZA, ma solo se qualcosa e' davvero cambiato.
  ///
  /// Torna vero quando ha mandato qualcosa.
  Future<bool> sincronizza({
    required SceltaDegliAvvisi scelta,
    required String fuso,
  }) async {
    final token = _token;
    if (token == null || token.isEmpty) return false;

    final doni = <String, int>{
      for (final d in DailyElement.values)
        if (scelta.chiama(d)) d.name: scelta.minutiDi(d),
    };
    final scelte = ScelteDaMandare(token: token, fuso: fuso, doni: doni);
    final impronta = jsonEncode(scelte.aMappa());

    // **NIENTE DA MANDARE SE NIENTE E' CAMBIATO.** Chi apre la pagina,
    // accende e rispegne lo stesso Dono e torna com'era non fa partire
    // nessuna scrittura.
    if (impronta == _ultimeMandate) return false;

    final preso = await _porta.manda(scelte);
    sincronieVersoIlServer++;
    if (!preso) return false;
    _ultimeMandate = impronta;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kUltimeMandate, impronta);
    } catch (errore) {
      debugPrint('Push: la sincronia non si segna. $errore');
    }
    return true;
  }

  /// Toglie il token dal server e dal telefono.
  Future<void> dimentica() async {
    final aveva = _token != null;
    _token = null;
    _ultimeMandate = '';
    sincronieVersoIlServer = 0;
    notifyListeners();
    if (aveva) await _porta.togli();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kToken);
      await prefs.remove(_kUltimeMandate);
    } catch (errore) {
      debugPrint('Push: le chiavi non si tolgono. $errore');
    }
  }
}
