import '../../core/entitlement/plan_catalog.dart';
import '../../core/entitlement/tier.dart';
import '../../core/lunario/le_attivita_del_lunario.dart';

/// **I PIANI E GLI EOS DEL CALENDARIO LUNARE.** Ordine FV voce FV.12, 15
/// ottobre 2026. Fonte: proposta dell'Architetto del 15 ottobre 2026, "Piani
/// ed Eos (proposta)"; il fondatore: "Siz approvo tutto"; Linee Guida V13
/// sezione 27.
///
/// Legge la matrice vera di `PlanCatalog` (le righe `RigaDelPiano.lunario*`),
/// invece di restituire sempre tutto aperto come prima di questa voce:
/// - Viandante: il mese in corso, una categoria sola di "Trova il giorno",
///   niente promemoria, niente "Trova il giorno insieme".
/// - Iniziato: tutte le categorie, i promemoria, anche il mese dopo.
/// - Adepto e Illuminato: dodici mesi avanti, "Trova il giorno insieme".
///
/// Ogni voce che il piano chiude resta Premium bloccata col lucchetto e
/// l'invito, mai un vicolo cieco: la schermata lo mostra (il lucchetto sugli
/// emblemi delle categorie chiuse, l'invito quando si tenta di scorrere oltre
/// il mese apribile o di aprire "Trova il giorno insieme").
abstract final class IlPianoDelLunario {
  /// Quanti mesi dopo quello in corso si possono scorrere (FV.05 e FV.12),
  /// SENZA contare il mese extra comprato a Eos: vedi [mesiAvantiCon].
  static int mesiAvanti(Tier tier) => PlanCatalog.mesiAvantiDelLunario(tier);

  /// Come [mesiAvanti], ma con [mesiExtra] mesi in più comprati a Eos
  /// (`ListinoDegliEos.meseExtraDelLunario`, uno per acquisto).
  static int mesiAvantiCon({required Tier tier, required int mesiExtra}) =>
      mesiAvanti(tier) + mesiExtra;

  /// Se la categoria si apre a questo piano.
  ///
  /// **Il Viandante non resta a mani vuote**: la prima categoria dell'elenco
  /// (Capelli e unghie) resta sempre aperta, cosi' "Trova il giorno" si vede
  /// funzionare davvero anche senza un piano, mai un vicolo cieco. Le altre
  /// dieci si aprono dall'Iniziato.
  static bool categoriaAperta(CategoriaDelLunario c, Tier tier) =>
      c == CategoriaDelLunario.values.first ||
      PlanCatalog.apre(RigaDelPiano.lunarioTutteLeCategorie, tier);

  /// Se i promemoria si fissano a questo piano (dall'Iniziato in su).
  static bool promemoriaAperti(Tier tier) =>
      PlanCatalog.apre(RigaDelPiano.lunarioPromemoria, tier);

  /// **SE "TROVA IL GIORNO INSIEME" SI APRE A QUESTO PIANO** (FV.10):
  /// dall'Adepto in su. Chi non ce l'ha nel piano puo' comunque aprire una
  /// proposta sola con gli Eos (`ListinoDegliEos.propostaInsiemeDelLunario`,
  /// `IlCerchioSociale.compraUnaPropostaInsieme`): quello e' un credito
  /// comprato e non cambia questa risposta, che resta la domanda "il piano
  /// lo apre?" e non "si puo' usare adesso?".
  static bool trovaInsiemeAperto(Tier tier) =>
      PlanCatalog.apre(RigaDelPiano.lunarioInsieme, tier);
}
