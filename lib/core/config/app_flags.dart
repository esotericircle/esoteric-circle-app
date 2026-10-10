/// Bandiere di configurazione dell'app, semplici e a compile time.
///
/// `isDemo` accende gli affordance della presentazione, per esempio il piano
/// Demo che sblocca tutte le funzioni attive. Nell'MVP si spegne e restano solo
/// i quattro livelli canonici, senza toccare altro. In futuro puo' arrivare da
/// Remote Config (parametro demo_mode) dietro la stessa lettura.
class AppFlags {
  const AppFlags._();

  static const bool isDemo = true;
}
