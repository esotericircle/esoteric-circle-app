import 'dart:async';

import 'package:flutter/widgets.dart';

import 'porta_del_cerchio.dart';

/// **QUANTI SONO NEL CERCHIO ADESSO. Ordine ES voce 15.**
///
/// Il fondatore: *"in alto nella barra superiore al centro bisogerà inserire
/// "online" con lucina verde e n. di utenti online"*.
///
/// Chiede il numero al server all'avvio e poi ogni [ogni], **solo finche'
/// l'app e' davanti**: in pausa il passo si ferma, e al ritorno si chiede
/// subito, cosi' chi riapre l'app non legge il numero di un'ora fa. La
/// domanda stessa e' la presenza: il server segna chi chiede, quindi un'app
/// in pausa smette di contare fra gli online da sola, entro la finestra del
/// server (`functions/src/presenza.ts`, due minuti e mezzo).
///
/// **Con la porta spenta non parte nessun passo**, ne' nelle prove ne' senza
/// Firebase: il numero resta nullo, e la barra mostra la lucina senza
/// numero invece di inventarne uno.
class ChiEOnline extends ChangeNotifier with WidgetsBindingObserver {
  ChiEOnline({required PortaDelCerchio porta}) : _porta = porta;

  final PortaDelCerchio _porta;

  /// Ogni quanto si chiede. Lo stesso numero sta nel server
  /// (`OGNI_QUANTO_CHIEDE_MS`), e la prova pretende che coincidano: un
  /// telefono che chiedesse piu' di rado della finestra uscirebbe dal conto
  /// fra una domanda e l'altra.
  static const Duration ogni = Duration(minutes: 2);

  Timer? _passo;
  bool _avviato = false;
  bool _chiuso = false;
  int? _quanti;

  /// Quante persone hanno l'app davanti adesso, chi guarda compreso. Nullo
  /// finche' il server non l'ha detto.
  int? get quanti => _quanti;

  /// Accende il passo. Non fa niente con la porta spenta.
  void avvia() {
    if (_avviato || !_porta.viva) return;
    _avviato = true;
    WidgetsBinding.instance.addObserver(this);
    _riparti();
  }

  void _riparti() {
    _passo?.cancel();
    unawaited(chiedi());
    _passo = Timer.periodic(ogni, (_) => unawaited(chiedi()));
  }

  /// Una domanda sola al server. Pubblica per le prove.
  Future<void> chiedi() async {
    final n = await _porta.chiEOnline();
    if (_chiuso || n == null || n == _quanti) return;
    _quanti = n;
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Si riparte solo se il passo era fermo: un passaggio da "inattiva",
    // come la tendina delle notifiche, non e' un ritorno e non vale una
    // domanda in piu'.
    if (state == AppLifecycleState.resumed && _passo == null) {
      _riparti();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      _passo?.cancel();
      _passo = null;
    }
  }

  @override
  void dispose() {
    _chiuso = true;
    _passo?.cancel();
    if (_avviato) WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
