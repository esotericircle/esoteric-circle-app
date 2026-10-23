import '../../core/entitlement/plan_catalog.dart';
import '../../core/entitlement/tier.dart';

/// **I PIANI E GLI EOS DEL RESPIRO DELLA LUNA.** Ordine FX voce FX.10, 16
/// ottobre 2026. Fonte: la proposta approvata dal fondatore ("1 ok"), coi
/// prezzi in Eos lasciati a Code ("lo decide code").
///
/// Sul modello esatto di `IlPianoDelLunario` (ordine FV voce FV.12): legge
/// la matrice vera di `PlanCatalog` (le righe `RigaDelPiano.respiro*`),
/// invece di decidere qui chi vede cosa.
///
/// - **Viandante**: la Luna di quest'ora coi suoi numeri, il respiro di
///   oggi, la parola di Medora, la perla del giorno (sempre apribili, non
///   righe della matrice: nessuna chiamata al modello le regola, come il
///   nutrimento dell'animale guida). Il tempo sotto il dito scorre solo
///   nelle 24 ore di oggi.
/// - **Iniziato**: in più la collana completa con la consegna alla Luna
///   nuova, lo scrigno delle collane, gli avvisi, e il tempo sotto il dito
///   su tutto il mese.
/// - **Adepto e Illuminato**: lo stesso Respiro dell'Iniziato. Il respiro
///   condiviso (il conteggio collettivo alla Luna piena e la collana a due,
///   ordine FX voce FX.09) e' uscito con la decisione del fondatore del 20
///   ottobre 2026, "Le funzioni del Respiro non si pubblicano": niente piu'
///   riga nella matrice, voci nel listino o porte a video.
///
/// Ogni voce che il piano chiude resta Premium bloccata col lucchetto e
/// l'invito, mai un vicolo cieco (la schermata lo mostra, come per il
/// Calendario Lunare).
abstract final class IlPianoDelRespiro {
  /// Se la collana completa (la consegna alla Luna nuova e lo scrigno delle
  /// collane) si apre a questo piano: dall'Iniziato in su.
  static bool collanaCompletaAperta(Tier tier) =>
      PlanCatalog.apre(RigaDelPiano.respiroCollanaCompleta, tier);

  /// Se gli avvisi del Respiro della Luna si fissano a questo piano:
  /// dall'Iniziato in su.
  static bool avvisiAperti(Tier tier) =>
      PlanCatalog.apre(RigaDelPiano.respiroAvvisi, tier);

  /// Se il tempo sotto il dito (il trascinamento che fa scorrere la Luna nel
  /// tempo) scorre su tutto il mese; altrimenti scorre solo nelle 24 ore di
  /// oggi (il Viandante).
  static bool tempoSottoIlDitoSuTuttoIlMese(Tier tier) =>
      PlanCatalog.apre(RigaDelPiano.respiroTempoSottoIlDitoMese, tier);

  // LAPIDE, ordine GA, decisione del fondatore del 20 ottobre 2026: qui
  // c'era `respiroInsiemeAperto` (FX.09), dall'Adepto in su. Il respiro
  // condiviso non si pubblica, e il piano non lo apre a nessuno.
}
