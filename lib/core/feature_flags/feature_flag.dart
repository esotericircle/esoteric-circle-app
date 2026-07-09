import 'package:flutter/widgets.dart';

import '../entitlement/tier.dart';
import '../maestro/maestro.dart';

/// I tre stati visivi in cui ogni funzione dell'app puo' trovarsi.
///
/// Sono il cuore del modello a feature flag: la stessa base di codice mostra
/// una funzione come pienamente attiva, come anticipo (Coming soon) o come
/// contenuto premium bloccato, senza mai un vicolo cieco.
///
/// Riferimento: Linee Guida UX sezione 4 e Master Tecnico sezione 28/41.
enum FeatureStatus {
  /// Pienamente funzionante e rifinita.
  active,

  /// Visibile ma in grigio o semitrasparenza, con badge. Il tocco mostra un
  /// anticipo elegante, mai un errore.
  comingSoon,

  /// Visibile con lucchetto e invito all'upgrade del tier corretto.
  premiumLocked,
}

/// Come Remote Config vuole che una funzione si comporti, a prescindere dal
/// tier dell'utente. E' la leva lato server dei feature flag.
enum RemoteAvailability {
  /// Disponibile: lo stato effettivo dipende poi dal tier.
  enabled,

  /// Forzata a Coming soon per tutti (funzione non ancora pronta).
  comingSoon,
}

/// Definizione statica di una funzione dell'app nel catalogo.
///
/// Descrive cosa e' la funzione (titolo, anticipo, icona, dominio del
/// Maestro) e le sue regole di disponibilita' (leva remota e tier minimo).
/// Lo stato effettivo viene calcolato a runtime da `FeatureFlagService`
/// combinando questa definizione con Remote Config e con l'entitlement.
@immutable
class FeatureDefinition {
  const FeatureDefinition({
    required this.id,
    required this.title,
    required this.teaser,
    required this.icon,
    this.owner,
    this.requiredTier = Tier.free,
    this.defaultAvailability = RemoteAvailability.enabled,
  });

  /// Chiave stabile, coincide con il parametro Remote Config corrispondente.
  final String id;
  final String title;

  /// Anticipo elegante mostrato al tocco quando la funzione non e' attiva.
  final String teaser;
  final IconData icon;

  /// Maestro di dominio, se la funzione ne appartiene a uno.
  final Maestro? owner;

  /// Tier minimo per usarla. Oltre il tier dell'utente diventa premium bloccata.
  final Tier requiredTier;

  /// Comportamento di default se Remote Config non specifica nulla.
  final RemoteAvailability defaultAvailability;

  bool get isPremium => requiredTier != Tier.free;
}
