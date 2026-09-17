import 'attribuzioni_degli_arcani.dart';
import 'sacchetto_dell_alba.dart';

/// **UNA LETTURA DELL'ARCANO DELL'ALBA**, scritta a mano nel corpus dei
/// tarocchi. Ordine DT voci 07, 08 e 09, 17 settembre 2026.
///
/// Porta i due movimenti che dipendono dalla carta e non dal nome: il **dono**,
/// che e' un respiro, un'azione o una parola secondo la famiglia, e la
/// chiusura di **Medora**. Il primo movimento, la carta nominata col verso e
/// l'attribuzione, si compone dal nome e non sta qui.
///
/// **La fonte e' `docs/corpus/tarocchi.md`**, sezione *Arcano dell'Alba, le
/// letture del dono*; il file dei dati si genera da li' con
/// `tool/genera_letture_dell_alba.py` e una prova pretende che i due dicano
/// la stessa cosa.
class LetturaDellAlba {
  const LetturaDellAlba({
    required this.carta,
    required this.rovescio,
    required this.numero,
    this.parola,
    required this.dono,
    required this.medora,
  });

  /// L'indice della carta nell'ordine delle attribuzioni, cioe' del corpus.
  final int carta;
  final bool rovescio;

  /// Il numero della lettura dentro il suo stato, da uno.
  final int numero;

  /// La parola del giorno, solo per le carte zodiacali.
  final String? parola;

  /// Il secondo movimento: il dono.
  final String dono;

  /// Il terzo movimento: la chiusura di Medora.
  final String medora;

  StatoDellAlba get stato => StatoDellAlba(carta, rovescio: rovescio);

  AttribuzioneDellArcano get attribuzione =>
      AttribuzioneDellArcano.tutte[carta];
}
