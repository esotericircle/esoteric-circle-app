import 'effemeridi.dart';
import 'natal_chart.dart';
import 'transiti_del_giorno.dart';

/// IN QUALE CASA NATALE STA PASSANDO OGGI UN PIANETA.
///
/// **Perche' questa e' la frase centrale.** Un astrologo previsionale non dice
/// "Saturno in trigono al tuo Sole", dice "Saturno sta attraversando la tua
/// settima casa". L'aspetto dice CHE COSA si muove, la casa dice DOVE nella
/// vita: il lavoro, la casa, gli affetti, il denaro. Senza le case un oroscopo
/// parla di geometria, con le case parla di te.
///
/// **E' aritmetica, non un secondo motore.** Le dodici cuspidi arrivano gia'
/// dalla carta natale conservata, le longitudini di oggi dal motore locale.
/// Qui si stabilisce solo in quale arco cade un grado.
///
/// **Senza ora di nascita non ci sono case, e non si inventano.** Le cuspidi
/// discendono dall'orizzonte locale all'istante della nascita: senza l'ora,
/// `NatalChart` non le porta proprio, e qui torna vuoto. Una casa inventata
/// darebbe una frase esatta e falsa insieme, ed e' la piu' pericolosa perche' e'
/// anche la piu' bella da leggere.
class TransitiNelleCase {
  const TransitiNelleCase._();

  /// Quante case ha una carta completa.
  static const int quanteCase = 12;

  /// In quale casa cade [longitudine], date le cuspidi natali.
  ///
  /// Torna un numero da 1 a 12, oppure null se le cuspidi non ci sono o non
  /// sono dodici. La casa N va dalla sua cuspide a quella della casa N piu' 1,
  /// percorrendo lo zodiaco in avanti: le case NON sono larghe trenta gradi
  /// ciascuna, con Placido e con le altre domificazioni per tempo possono
  /// essere molto diverse fra loro, quindi si misura l'arco vero invece di
  /// dividere per dodici.
  static int? casaDi(double longitudine, List<HouseCusp> cuspidi) {
    if (cuspidi.length != quanteCase) return null;

    final perNumero = <int, double>{
      for (final c in cuspidi) c.number: c.longitude,
    };
    if (perNumero.length != quanteCase) return null;
    for (var n = 1; n <= quanteCase; n++) {
      if (!perNumero.containsKey(n)) return null;
    }

    for (var n = 1; n <= quanteCase; n++) {
      final inizio = perNumero[n]!;
      final fine = perNumero[n == quanteCase ? 1 : n + 1]!;
      final ampiezza = _avanti(fine - inizio);
      final quanto = _avanti(longitudine - inizio);
      // L'ampiezza zero vorrebbe dire due cuspidi coincidenti, cioe' una carta
      // malformata: si salta invece di dichiarare una casa larga tutto il giro.
      if (ampiezza > 0 && quanto < ampiezza) return n;
    }
    return null;
  }

  /// Le case attraversate oggi dai corpi, per questa carta.
  ///
  /// Vuoto se la carta manca, e' essenziale o non ha le case.
  static Map<CorpoCeleste, int> perIlGiorno({
    required DateTime adesso,
    required NatalChart? carta,
  }) {
    if (carta == null || carta.isEssential || carta.houses.isEmpty) {
      return const {};
    }
    final posizioni = TransitiDelGiorno.posizioni(adesso);
    final esito = <CorpoCeleste, int>{};
    for (final voce in posizioni.entries) {
      final casa = casaDi(voce.value, carta.houses);
      if (casa != null) esito[voce.key] = casa;
    }
    return esito;
  }

  /// Distanza in avanti sullo zodiaco, sempre da 0 a 360.
  static double _avanti(double gradi) {
    final v = gradi % 360.0;
    return v < 0 ? v + 360.0 : v;
  }
}
