import 'package:flutter/foundation.dart';

/// Livello di qualita' grafica a runtime.
///
/// Il design system e' pensato per 60fps con degradazione graceful: i device
/// deboli riducono effetti (numero di stelle, blur, ombre, parallasse) per
/// mantenere fluidita' e batteria. In C1 il tier e' impostabile manualmente e
/// vale come interruttore per gli effetti; il rilevamento automatico in base
/// alle prestazioni del device arrivera' piu' avanti.
///
/// Riferimento: Master Tecnico sezione 25, Quality Tier dinamico.
enum QualityTier {
  /// Effetti pieni.
  high,

  /// Effetti ridotti.
  medium,

  /// Effetti minimi, priorita' alla fluidita'.
  low,
}

class QualityTierController extends ChangeNotifier {
  QualityTierController({QualityTier initial = QualityTier.high})
      : _tier = initial;

  QualityTier _tier;
  QualityTier get tier => _tier;

  /// Densita' di stelle e particelle in base al tier.
  int get starDensity => switch (_tier) {
        QualityTier.high => 90,
        QualityTier.medium => 45,
        QualityTier.low => 0,
      };

  /// Se true, gli effetti pesanti (blur, aloni ampi) sono attivi.
  bool get richEffects => _tier == QualityTier.high;

  void setTier(QualityTier tier) {
    if (tier == _tier) return;
    _tier = tier;
    notifyListeners();
  }
}
