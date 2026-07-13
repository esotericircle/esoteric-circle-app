import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'tier.dart';

/// Contatore locale delle domande ai Maestri per l'utente Free.
///
/// L'utente Free ha una sola domanda singola al giorno a un Maestro. Il
/// confronto a piu' Maestri e le domande oltre la prima sono dal Tier a
/// pagamento, che qui non consuma il contatore (domande illimitate). Il conteggio
/// si azzera al cambio di giorno.
///
/// L'orologio e' iniettabile per i test; la persistenza e' best effort su
/// `SharedPreferences`, senza crash se non e' disponibile.
class QuestionAllowance extends ChangeNotifier {
  QuestionAllowance({
    DateTime Function()? clock,
    this.freeDailyLimit = 1,
  }) : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;

  /// Quante domande singole al giorno per l'utente Free.
  final int freeDailyLimit;

  static const _kDay = 'allowance.day';
  static const _kCount = 'allowance.count';

  int _count = 0;
  String _day = '';

  String _today() {
    final n = _clock();
    return '${n.year}-${n.month}-${n.day}';
  }

  // Se e' cambiato il giorno, azzera il conteggio.
  void _rollover() {
    final t = _today();
    if (t != _day) {
      _day = t;
      _count = 0;
    }
  }

  /// Domande consumate oggi (solo il Free consuma).
  int usedToday() {
    _rollover();
    return _count;
  }

  /// Domande singole ancora disponibili oggi. Per i Tier a pagamento e'
  /// idealmente illimitato: restituisce un numero molto alto.
  int remaining(Tier tier) {
    if (tier != Tier.free) return 1 << 30;
    _rollover();
    final left = freeDailyLimit - _count;
    return left < 0 ? 0 : left;
  }

  /// Se l'utente puo' porre un'altra domanda singola adesso.
  bool canAsk(Tier tier) {
    if (tier != Tier.free) return true;
    _rollover();
    return _count < freeDailyLimit;
  }

  /// Il confronto a piu' Maestri e' riservato al Tier a pagamento.
  bool canCompare(Tier tier) => tier != Tier.free;

  /// Registra una domanda consumata. Solo il Free intacca il contatore.
  void record(Tier tier) {
    if (tier != Tier.free) return;
    _rollover();
    _count++;
    notifyListeners();
    _persist();
  }

  /// Carica il conteggio salvato, best effort.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _day = prefs.getString(_kDay) ?? '';
      _count = prefs.getInt(_kCount) ?? 0;
      _rollover();
      notifyListeners();
    } catch (_) {
      // Nessuna persistenza: si resta sui valori in memoria.
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kDay, _day);
      await prefs.setInt(_kCount, _count);
    } catch (_) {
      // Best effort.
    }
  }
}
