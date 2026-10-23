/// IL RITRATTO. Ordine FF voce 02, 7 ottobre 2026.
///
/// Il fondatore, il 6 ottobre 2026, sul questionario delle caratteristiche e
/// sulla preselezione dalla carta natale. Ogni persona ha un Ritratto: venti
/// caratteristiche scelte fra le centoventi del corpus dell'Architetto
/// (`docs/corpus/Corpus_Il_Ritratto.md`, generato in
/// `il_ritratto_del_corpus.g.dart`), il serbatoio da cui i giochi del
/// Cerchio pescano gli indizi. Otto le propone il sistema dalla carta
/// natale, le altre dodici le sceglie la persona.
///
/// **Perche' non si riempiono tutte e venti**: due persone dello stesso
/// segno avrebbero lo stesso Ritratto, e chi conosce il segno di qualcuno lo
/// indovinerebbe senza conoscerlo.
///
/// Il Ritratto intero lo vede solo chi lo possiede: il server non lo
/// restituisce a nessun altro, e i giochi ne tirano fuori una caratteristica
/// per volta, come indizio.
library;

import '../astro/zodiac.dart';
import 'il_ritratto_del_corpus.g.dart';

enum ElementoDelTratto { fuoco, terra, aria, acqua, libera }

/// Una caratteristica del corpus.
class TrattoDelRitratto {
  const TrattoDelRitratto(
      this.numero, this.testoMarcato, this.elemento, this.sezione);

  /// Il numero del corpus, da 1 a 120: e' l'identificativo che viaggia.
  final int numero;

  /// Il testo, in prima persona, come lo scrive l'Architetto.
  final String testoMarcato;
  final ElementoDelTratto elemento;

  /// L'indice in [sezioniDelRitratto].
  final int sezione;
}

abstract final class IlRitratto {
  /// Quante caratteristiche ha un Ritratto compilato.
  static const int quante = 20;

  /// Quante ne propone il sistema dalla carta natale.
  static const int proposte = 8;

  static List<TrattoDelRitratto> get tutti => trattiDelCorpus;

  /// La caratteristica col numero dato, nulla se non esiste.
  static TrattoDelRitratto? tratto(int numero) =>
      numero >= 1 && numero <= trattiDelCorpus.length
          ? trattiDelCorpus[numero - 1]
          : null;

  /// L'elemento del segno, nella lingua del corpus.
  static ElementoDelTratto elementoDel(Zodiac segno) => switch (segno.element) {
        ZodiacElement.fire => ElementoDelTratto.fuoco,
        ZodiacElement.earth => ElementoDelTratto.terra,
        ZodiacElement.air => ElementoDelTratto.aria,
        ZodiacElement.water => ElementoDelTratto.acqua,
      };

  /// **LE OTTO PROPOSTE, come le vuole il corpus**: tre dall'elemento del
  /// Sole, due da quello della Luna, due da quello dell'Ascendente, una
  /// ancora dal Sole. Dentro un elemento si prende in ordine di numero,
  /// saltando quelle gia' prese, partendo dalla posizione data dal resto
  /// della divisione del giorno di nascita per quante caratteristiche ha
  /// quell'elemento. Senza Ascendente i suoi due vengono dalla Luna; senza
  /// Luna tutte e otto dal Sole. Le [ElementoDelTratto.libera] non si
  /// propongono mai. Deterministica: stessa carta, stesse proposte.
  static List<int> proposteDallaCarta({
    required Zodiac sole,
    Zodiac? luna,
    Zodiac? ascendente,
    required int giornoDiNascita,
  }) {
    final eSole = elementoDel(sole);
    final eLuna = luna == null ? eSole : elementoDel(luna);
    final eAsc = ascendente == null ? eLuna : elementoDel(ascendente);
    final ordine = [eSole, eSole, eSole, eLuna, eLuna, eAsc, eAsc, eSole];
    final prese = <int>[];
    for (final e in ordine) {
      final dellElemento = [
        for (final t in trattiDelCorpus)
          if (t.elemento == e) t.numero,
      ];
      final n = dellElemento.length;
      final inizio = giornoDiNascita % n;
      for (var i = 0; i < n; i++) {
        final candidato = dellElemento[(inizio + i) % n];
        if (!prese.contains(candidato)) {
          prese.add(candidato);
          break;
        }
      }
    }
    return prese;
  }

  /// Vero se [scelte] e' un Ritratto che si puo' chiudere: venti
  /// caratteristiche diverse, tutte del corpus.
  static bool siChiude(Iterable<int> scelte) {
    final insieme = scelte.toSet();
    return scelte.length == quante &&
        insieme.length == quante &&
        insieme.every((n) => tratto(n) != null);
  }
}
