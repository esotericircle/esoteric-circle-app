import '../entitlement/tier.dart';

/// **QUANTE LETTURE DEL VISO SI POSSONO FARE IN UN GIORNO.**
/// Ordine CX, 8 settembre 2026.
///
/// **Nasce da un lucchetto che nessuno aveva chiesto.** Parole del fondatore
/// mentre provava la funzione: *"c'e' un lucchetto 'per oggi hai gia' guardato
/// il tuo volto, il Cerchio non ne apre piu'". MA CHE COSA VUOL DIRE? TI AVEVO
/// DATO DEI LIMITI?"*
///
/// **PROVENIENZA, accertata sul grafo dei commit e non a memoria.** Il limite
/// che bloccava il Viso e' `ArchetypeAllowance`, nato il **22 luglio 2026** col
/// commit *"Test Archetipo: il cuore deterministico"*, e scritto per il **Test
/// Archetipo**. Il giorno dopo, il **23 luglio 2026**, la Costellazione del
/// Viso e' nata riusando quella stessa classe. **Nessun ordine ha mai chiesto
/// un limite giornaliero per il Viso**: e' stato ereditato da un'altra
/// funzione perche' la classe era li' e si chiamava in modo generico.
///
/// **E non c'e' nemmeno la ragione tecnica che di solito giustifica un
/// limite.** Il Test Archetipo e le funzioni a pagamento hanno un costo per
/// ogni esecuzione; **la lettura del viso gira tutta sul telefono**, dentro
/// MediaPipe, e non tocca nessun server. Contarla vuol dire mettere un
/// contatore su una cosa che non costa niente a nessuno.
///
/// **Perche' una porta sua e non un numero tolto e basta.** Se domani il
/// fondatore decidesse un limite per il Viso, deve poterlo scrivere in un
/// posto che parla del Viso. Riusare il limite di un'altra funzione e' esatta-
/// mente il modo in cui questo e' successo, e toglierlo senza lasciare una
/// porta lo farebbe tornare alla prima occasione.
class QuanteLettureDelViso {
  const QuanteLettureDelViso._();

  /// **NESSUN LIMITE, PER NESSUN LIVELLO, finche' il fondatore non ne chiede
  /// uno.** Nullo vuol dire illimitato, come nel resto del progetto.
  ///
  /// Il livello entra nella firma perche' la decisione di domani potrebbe
  /// dipenderne, e cambiarla allora non deve voler dire cambiare ogni
  /// chiamante.
  static int? limite(Tier tier) => null;

  /// Se si puo' fare un'altra lettura oggi.
  static bool consentito({required int fattiOggi, required Tier tier}) {
    final max = limite(tier);
    if (max == null) return true;
    return (fattiOggi < 0 ? 0 : fattiOggi) < max;
  }

  /// Quante ne restano oggi, nullo se illimitate.
  static int? rimanenti({required int fattiOggi, required Tier tier}) {
    final max = limite(tier);
    if (max == null) return null;
    final fatti = fattiOggi < 0 ? 0 : fattiOggi;
    return fatti >= max ? 0 : max - fatti;
  }
}
