import 'package:flutter/foundation.dart';

import 'plan_catalog.dart';
import 'tier.dart';

/// Le quote giornaliere dei riti a consumo.
///
/// La matrice le promette da sempre, tre sinastrie e una carta al giorno per
/// il Viandante, mentre nel codice non esisteva niente che le imponesse: erano
/// promesse a senso unico, cioe' regali.
enum RitualQuota {
  sinastria(PlanCatalog.rigaSinastria),
  cartaSingola(PlanCatalog.rigaCartaSingola);

  const RitualQuota(this.riga);

  /// La riga della matrice che promette il limite di questa quota. Il numero
  /// NON sta qui: sta nella matrice, e da li' si legge.
  final String riga;
}

/// Contatore giornaliero delle quote a consumo, una per tipo.
///
/// Il giorno si azzera al cambio di data, come gia' fa il contatore delle
/// domande: due contatori diversi con la stessa idea di giorno, cosi' chi
/// legge non deve ricordarsi quale delle due regole vale dove.
class RitualAllowance extends ChangeNotifier {
  RitualAllowance({DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;
  final Map<RitualQuota, int> _conteggi = {};
  String _giorno = '';

  String _oggi() {
    final n = _clock();
    return '${n.year}-${n.month}-${n.day}';
  }

  void _rollover() {
    final t = _oggi();
    if (t != _giorno) {
      _giorno = t;
      _conteggi.clear();
    }
  }

  /// Quante ne restano oggi, oppure null se sono illimitate.
  int? restanti(RitualQuota quota, Tier tier) {
    final limite = PlanCatalog.limiteGiornaliero(quota.riga, tier);
    if (limite == null) return null;
    _rollover();
    final usate = _conteggi[quota] ?? 0;
    return limite - usate < 0 ? 0 : limite - usate;
  }

  /// Se se ne puo' fare un'altra adesso.
  bool puo(RitualQuota quota, Tier tier) {
    final r = restanti(quota, tier);
    return r == null || r > 0;
  }

  /// Registra un consumo. Chi ha l'illimitato non intacca niente.
  void registra(RitualQuota quota, Tier tier) {
    if (PlanCatalog.limiteGiornaliero(quota.riga, tier) == null) return;
    _rollover();
    _conteggi[quota] = (_conteggi[quota] ?? 0) + 1;
    notifyListeners();
  }
}
