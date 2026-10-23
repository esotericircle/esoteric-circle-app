import 'package:flutter/foundation.dart';

/// IL CONSENSO DELLA SPESA. Ordine FD voce 01.
///
/// **Il difetto, misurato.** Prima di quest'ordine nessun punto dell'app
/// che consuma minuti o Eos mostrava una conferma con il costo e il saldo
/// insieme: tredici punti in tutto. Tre spendevano al primo tocco su una
/// riga col prezzo (`PortaDellaSpesa`), sei col riscatto nel foglio
/// dell'invito, uno col confronto del cielo in piu', e il LIVE apriva una
/// sessione a pagamento al primo tocco sulla pastiglia. Il dono e il regalo
/// avevano due pulsanti ma senza il saldo. L'elenco con i file e le righe sta
/// nel rapporto dell'ordine FD.
///
/// **Perche' un oggetto e non una regola scritta.** Ogni porta che consuma
/// (`SpesaDegliEos.perLaVoce`, `QuestionAllowance.riscatta`,
/// `IlCerchioSociale.mandaUnDono`, `regalaGliEos`, `compraUnPosto`,
/// `SchermataLive.route`) pretende questo consenso come argomento, e il
/// consenso lo crea **solo** `LaConfermaDellaSpesa`, quando la persona tocca
/// il pulsante di conferma. Un punto di spesa nuovo che salti la conferma non
/// compila: e' la guardia piu' forte che si possa scrivere, perche' non
/// aspetta che giri una prova.
@immutable
class ConsensoDellaSpesa {
  const ConsensoDellaSpesa._(this.quanti);

  /// Quanto la persona ha accettato di spendere: Eos, oppure minuti.
  final int quanti;

  /// Il solo costruttore fuori da questo file, per la conferma.
  /// La guardia `la_spesa_passa_dalla_conferma_test.dart` pretende che in
  /// `lib` lo chiami soltanto `la_conferma_della_spesa.dart`.
  static ConsensoDellaSpesa dato(int quanti) => ConsensoDellaSpesa._(quanti);

  /// Per le prove che chiamano le porte di spesa direttamente. Mai in `lib`,
  /// e la stessa guardia lo verifica.
  @visibleForTesting
  static ConsensoDellaSpesa perLeProve(int quanti) =>
      ConsensoDellaSpesa._(quanti);
}
