/// **IL VERSO SI RECUPERA DOVE SI PUO'.** Ordine EC voce 06, 21 settembre
/// 2026.
///
/// **Decisione del fondatore, verbatim**, alla domanda sui Ricordi gia'
/// salvati senza verso: *"Recupera dove si puo'"*.
///
/// **Il verso non e' perduto: sta nel testo.** Un Ricordo custodito porta il
/// responso per intero, e quel responso nomina le figure col loro verso. La
/// Stesa lo fa con `DrawnCard.displayName`, cioe' *"Re di Spade rovesciato"*;
/// l'Estrazione lo fa nella terza parte del presagio, *"Uruz in merkstave
/// (rovesciata) per ..."*. **A perderlo erano i soli dati**, che la voce
/// EC.05 ha riparato per i Ricordi nuovi: qui si riparano quelli gia' sui
/// telefoni delle persone.
///
/// **NESSUN VERSO SI INVENTA, ed e' la regola che comanda su tutte.** Se il
/// testo non dice il verso di **ogni** figura di quel Ricordo, il Ricordo
/// resta esattamente com'e'. Meglio un Ricordo senza verso che un Ricordo con
/// un verso supposto: il primo non dice niente, il secondo dice il falso.
///
/// **Non si perde niente.** Il recupero aggiunge una chiave e non tocca
/// nessun altro campo: titolo, testo, data e il resto dei dati restano
/// quelli. Ed e' **innocuo se si ripete**, perche' un Ricordo che la chiave
/// ce l'ha gia' non viene nemmeno guardato.
library;

import '../tarot/tarot_card.dart';
import 'ricordo_custodito.dart';

abstract final class IlVersoRecuperato {
  /// La chiave dei versi, la stessa che le schermate scrivono dall'ordine
  /// EC voce 05.
  static const String chiave = 'versi';

  /// Le arti su cui il recupero ha senso, con la chiave dei nomi delle
  /// figure. Le altre due arti con figure, `alba` e `tramonto`, il verso lo
  /// salvano da sempre in una chiave loro: non c'e' niente da recuperare.
  static const Map<String, String> arti = {
    'stesa': 'carte',
    'gettata': 'rune',
  };

  /// I dati di [ricordo] col verso ricostruito, oppure **null** quando non
  /// c'e' niente da fare o il testo non basta.
  ///
  /// Torna null, e quindi lascia il Ricordo intatto, in cinque casi: l'arte
  /// non ha figure, la chiave dei versi c'e' gia', i nomi mancano, una figura
  /// non si riconosce, oppure **il testo non dice il verso di anche una sola
  /// figura**.
  static Map<String, String>? datiRecuperati(RicordoCustodito ricordo) {
    final chiaveDeiNomi = arti[ricordo.arte];
    if (chiaveDeiNomi == null) return null;
    if ((ricordo.dati[chiave] ?? '').trim().isNotEmpty) return null;
    final nomi = _pezzi(ricordo.dati[chiaveDeiNomi]);
    if (nomi.isEmpty) return null;

    final versi = <String>[];
    for (final nome in nomi) {
      final verso = ricordo.arte == 'stesa'
          ? _versoDiUnaCarta(nome, ricordo.testo)
          : _versoDiUnaRuna(nome, ricordo.testo);
      // **Basta una figura muta e non si tocca niente.** Un elenco di versi
      // a meta' direbbe "dritta" dove non si sa, che e' inventare.
      if (verso == null) return null;
      versi.add(verso);
    }
    return {...ricordo.dati, chiave: versi.join(',')};
  }

  /// Il verso di una carta, letto dal testo del responso.
  ///
  /// Il testo la nomina *"Il Papa"* se e' dritta e *"Re di Spade rovesciato"*
  /// se e' rovesciata, con la parola del rovescio accordata al genere della
  /// carta. Se il nome non compare affatto, il testo non dice niente di lei.
  static String? _versoDiUnaCarta(String nome, String testo) {
    final carta = TarotDeck.cards
        .where((c) => _uguali(c.name, nome))
        .cast<dynamic>()
        .firstWhere((c) => true, orElse: () => null);
    if (carta == null) return null;
    final basso = testo.toLowerCase();
    final n = nome.trim().toLowerCase();
    if (!basso.contains(n)) return null;
    final rovescio = '$n ${(carta.reversedWord as String).toLowerCase()}';
    return basso.contains(rovescio) ? 'rovesciata' : 'dritta';
  }

  /// Il verso di una runa, letto dal presagio.
  ///
  /// La terza parte del presagio scrive *"Uruz in merkstave (rovesciata) per
  /// ..."* oppure *"Uruz diritta per ..."*, e nelle gettate libere
  /// *"rovesciata"* e *"dritta"*. Si guarda cosa segue il nome.
  static String? _versoDiUnaRuna(String nome, String testo) {
    final basso = testo.toLowerCase();
    final n = nome.trim().toLowerCase();
    final dove = basso.indexOf(n);
    if (dove < 0) return null;
    final dopo = basso.substring(
        dove + n.length, (dove + n.length + 32).clamp(0, basso.length));
    if (dopo.startsWith(' in merkstave (rovesciata)') ||
        dopo.startsWith(' rovesciata')) {
      return 'ombra';
    }
    if (dopo.startsWith(' diritta') || dopo.startsWith(' dritta')) {
      return 'dritta';
    }
    return null;
  }

  static bool _uguali(String a, String b) =>
      a.trim().toLowerCase() == b.trim().toLowerCase();

  static List<String> _pezzi(String? grezzo) => (grezzo ?? '')
      .split(',')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList(growable: false);
}
