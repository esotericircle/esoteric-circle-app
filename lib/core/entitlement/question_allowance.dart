import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'plan_catalog.dart';
import 'tier.dart';

/// Contatore locale delle domande ai Maestri, per tier.
///
/// Il limite giornaliero di risposte Breve a un Maestro segue la mappa dei
/// piani: Viandante 3, Iniziato 5, Adepto 10, Illuminato illimitate. Le tre del
/// Free sono spendibili anche su Maestri diversi. Il conteggio si azzera al
/// cambio di giorno. Il confronto a piu' Maestri (sintesi comparativa) resta
/// riservato al Tier a pagamento.
///
/// L'orologio e' iniettabile per i test; la persistenza e' best effort su
/// `SharedPreferences`, senza crash se non e' disponibile.
class QuestionAllowance extends ChangeNotifier {
  QuestionAllowance({
    DateTime Function()? clock,
    this.freeDailyLimit,
  }) : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;

  /// Un limite imposto dall'esterno, solo per i test: nell'app resta nullo e
  /// il numero arriva dalla matrice.
  final int? freeDailyLimit;

  /// Il limite giornaliero per tier, oppure null se illimitato.
  ///
  /// LO LEGGE DALLA MATRICE dei piani, che e' la fonte di cio' che si promette
  /// alla persona. Prima i numeri erano scritti qui: la matrice prometteva al
  /// Viandante una domanda al giorno e questo file ne concedeva tre, quindi la
  /// promessa e l'imposizione erano due cose diverse, e a rimetterci era solo
  /// una delle due parti.
  int? dailyLimit(Tier tier) {
    if (tier == Tier.free && freeDailyLimit != null) return freeDailyLimit;
    return PlanCatalog.limiteGiornaliero(PlanCatalog.rigaDomande, tier);
  }

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

  /// Domande consumate oggi.
  int usedToday() {
    _rollover();
    return _count;
  }

  /// Domande singole ancora disponibili oggi. Per un tier illimitato restituisce
  /// un numero molto alto.
  int remaining(Tier tier) {
    final limit = dailyLimit(tier);
    if (limit == null) return 1 << 30;
    _rollover();
    final left = limit - _count;
    return left < 0 ? 0 : left;
  }

  /// Se l'utente puo' porre un'altra domanda singola adesso.
  bool canAsk(Tier tier) {
    final limit = dailyLimit(tier);
    if (limit == null) return true;
    _rollover();
    return _count < limit;
  }

  /// Il confronto a piu' Maestri (sintesi comparativa) e' riservato al Tier a
  /// pagamento.
  bool canCompare(Tier tier) => tier != Tier.free;

  /// Registra una domanda consumata. I tier con un limite finito intaccano il
  /// contatore; quello illimitato no.
  void record(Tier tier) {
    if (dailyLimit(tier) == null) return;
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
