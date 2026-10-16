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
/// - **Adepto e Illuminato**: in più Respiriamo insieme, con la collana a
///   due e la bussola verso la Luna.
///
/// Ogni voce che il piano chiude resta Premium bloccata col lucchetto e
/// l'invito, mai un vicolo cieco (la schermata lo mostra, come per il
/// Calendario Lunare): chi non ha Respiriamo insieme nel piano lo apre per
/// una Luna piena sola con `ListinoDegliEos.respiroInsiemeUnaVolta`, e la
/// collana a due per un ciclo solo con
/// `ListinoDegliEos.collanaADueUnaVolta`.
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

  /// **SE "RESPIRIAMO INSIEME" SI APRE A QUESTO PIANO** (FX.09): dall'Adepto
  /// in su. Chi non ce l'ha nel piano puo' comunque aprire un assaggio del
  /// conteggio collettivo con gli Eos
  /// (`ListinoDegliEos.respiroInsiemeUnaVolta`) o la collana a due per un
  /// ciclo solo (`ListinoDegliEos.collanaADueUnaVolta`): quelli sono crediti
  /// comprati e non cambiano questa risposta, che resta la domanda "il
  /// piano lo apre?" e non "si puo' usare adesso?".
  static bool respiroInsiemeAperto(Tier tier) =>
      PlanCatalog.apre(RigaDelPiano.respiroInsieme, tier);
}
