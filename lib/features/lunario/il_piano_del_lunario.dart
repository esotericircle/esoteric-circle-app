import '../../core/entitlement/tier.dart';
import '../../core/lunario/le_attivita_del_lunario.dart';

/// **IL PUNTO DEI PIANI DEL CALENDARIO LUNARE, ANCORA APERTO.** Ordine FV
/// voce FV.12, 15 ottobre 2026.
///
/// La schermata legge il piano della persona e chiede qui che cosa si apre:
/// quanti mesi avanti, quali categorie di "Trova il giorno", se i promemoria
/// e "Trova il giorno insieme". **Oggi qui non c'e' nessun limite**: le
/// righe nuove di `PlanCatalog`, il lucchetto e l'invito li scrive la voce
/// FV.12, che e' di un altro lavoro dell'ordine e arriva dopo questa
/// schermata. Quando arriva, cambia questo file e basta: la schermata chiede
/// gia' tutto da qui.
abstract final class IlPianoDelLunario {
  /// Quanti mesi dopo quello in corso si possono scorrere (FV.05 e FV.12).
  static int mesiAvanti(Tier tier) => 12;

  /// Se la categoria si apre a questo piano.
  static bool categoriaAperta(CategoriaDelLunario c, Tier tier) => true;

  /// Se i promemoria si fissano a questo piano.
  static bool promemoriaAperti(Tier tier) => true;
}
