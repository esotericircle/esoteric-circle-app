import 'package:flutter/foundation.dart';

import '../entitlement/entitlement_service.dart';
import 'feature_catalog.dart';
import 'feature_flag.dart';
import 'feature_flag_source.dart';

/// Risolve lo stato effettivo di ogni funzione combinando tre ingredienti:
/// la definizione del catalogo, le leve remote (Remote Config, oggi locali) e
/// l'entitlement del tier dell'utente.
///
/// Regola di risoluzione, nell'ordine:
/// 1. se la leva remota (o il default) e' Coming soon, la funzione e' Coming soon;
/// 2. altrimenti, se il tier dell'utente non copre il tier richiesto, e'
///    premium bloccata;
/// 3. altrimenti e' attiva.
///
/// Questo garantisce che una funzione non ancora pronta resti Coming soon per
/// tutti, e che una funzione pronta ma a pagamento mostri il lucchetto a chi
/// non ha il tier. Mai un vicolo cieco.
class FeatureFlagService extends ChangeNotifier {
  FeatureFlagService({
    required EntitlementService entitlement,
    FeatureFlagSource source = const LocalFeatureFlagSource(),
  })  : _entitlement = entitlement,
        _source = source {
    // Lo stato dipende anche dal tier: se cambia, ricalcola e notifica.
    _entitlement.addListener(_onEntitlementChanged);
  }

  final EntitlementService _entitlement;
  final FeatureFlagSource _source;

  Map<String, RemoteAvailability> _remote = {};
  bool _loaded = false;
  bool get isLoaded => _loaded;

  /// Carica le leve remote dalla sorgente. Idempotente e sicuro anche offline:
  /// in caso di errore si resta sui default del catalogo.
  Future<void> initialize() async {
    try {
      _remote = await _source.load();
    } catch (error, stack) {
      debugPrint('FeatureFlagService: uso i default del catalogo ($error).');
      debugPrintStack(stackTrace: stack);
      _remote = {};
    } finally {
      _loaded = true;
      notifyListeners();
    }
  }

  RemoteAvailability _availabilityOf(FeatureDefinition def) =>
      _remote[def.id] ?? def.defaultAvailability;

  /// Stato effettivo di una funzione per l'utente corrente.
  FeatureStatus statusOf(FeatureDefinition def) {
    if (_availabilityOf(def) == RemoteAvailability.comingSoon) {
      return FeatureStatus.comingSoon;
    }
    if (!_entitlement.tier.satisfies(def.requiredTier)) {
      return FeatureStatus.premiumLocked;
    }
    return FeatureStatus.active;
  }

  FeatureStatus statusById(String id) {
    final def = FeatureCatalog.byId(id);
    return def == null ? FeatureStatus.comingSoon : statusOf(def);
  }

  bool isActive(String id) => statusById(id) == FeatureStatus.active;

  void _onEntitlementChanged() => notifyListeners();

  @override
  void dispose() {
    _entitlement.removeListener(_onEntitlementChanged);
    super.dispose();
  }
}
