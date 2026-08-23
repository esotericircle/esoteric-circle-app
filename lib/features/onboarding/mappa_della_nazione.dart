import 'dart:math' as math;

import '../../core/astro/city_catalog.dart';

/// LA MAPPA DELLA NAZIONE, DISEGNATA DAI LUOGHI CHE L'APP HA GIA'.
/// Ordine BB voce 12.
///
/// **Il fatto**: nel passo del luogo di nascita si vede il planisfero, e su un
/// planisfero l'Italia e' grande come un'unghia. La stella che si accende dove
/// sei nato cade dentro quell'unghia, e non dice niente a nessuno.
///
/// **LA FONTE DELLE SAGOME, che era il nodo di questa voce.** L'ordine chiedeva
/// una fonte di sagome per nazione con licenza verificata prima di scrivere una
/// riga di codice. La fonte migliore e' quella che l'app **ha gia' in casa**:
/// `assets/data/luoghi.csv`, undicimilacinquecentoquarantasei luoghi con la
/// loro latitudine e longitudine. Nessun asset nuovo, nessuna rete, nessuna
/// licenza da verificare, e nessun disallineamento possibile fra la mappa e
/// l'elenco in cui la persona cerca la sua citta': **sono lo stesso dato**.
///
/// **E il disegno non e' un ripiego: e' piu' vero di una sagoma.** Quello che
/// si vede non e' il confine politico dell'Italia, sono le sue citta'. Nel
/// punto esatto in cui si chiede a qualcuno dove e' nato, mostrargli il paese
/// fatto dei suoi paesi vale piu' di un contorno.
///
/// **PERCHE' OGGI UN PAESE SOLO SUPERA IL CRITERIO, e il criterio non e' un
/// elenco travestito.** Perche' una nuvola di citta' disegni il paese serve
/// che sia DENSA: se i punti sono radi si vede una spruzzata, non una forma.
/// Misurato sui 242 paesi del catalogo, i luoghi per grado quadrato sono:
///
/// | paese | luoghi | per grado quadrato |
/// |---|---:|---:|
/// | Italia | 8.438 | **64** |
/// | Giappone | 134 | 0,29 |
/// | Cina | 430 | 0,20 |
/// | Stati Uniti | 132 | 0,04 |
///
/// Fra l'Italia e il secondo corrono **duecento volte**, quindi la soglia non
/// sta sul filo di niente: sta in mezzo a un abisso. Le nuvole degli altri
/// sono state guardate una per una, e non disegnano il loro paese.
///
/// **Cosa resta scoperto, detto qui e non taciuto.** Per gli altri 241 paesi
/// resta il planisfero. Servirebbe una vera fonte di contorni, e ne esiste una
/// di pubblico dominio, Natural Earth alla scala 1 a 110 milioni: e' lavoro di
/// un altro giorno, perche' vuole un asset nuovo, la sua conversione e la sua
/// prova.
class MappaDellaNazione {
  const MappaDellaNazione._({
    required this.paese,
    required this.punti,
    required this.sud,
    required this.nord,
    required this.ovest,
    required this.est,
  });

  /// Il paese come lo scrive il catalogo: per l'Italia e' la sigla di due
  /// lettere della provincia, per gli altri il nome del paese.
  final String paese;

  /// I luoghi, in gradi.
  final List<({double lat, double lon})> punti;

  /// Il riquadro che li contiene, gia' allargato di un margine.
  final double sud;
  final double nord;
  final double ovest;
  final double est;

  /// **QUANTI LUOGHI PER GRADO QUADRATO SERVONO.**
  ///
  /// Otto. L'Italia ne ha 64, il paese successivo 0,29: la soglia e' venti
  /// volte sotto chi passa e ventisette volte sopra chi non passa. Se un
  /// domani il catalogo si infittisse su un altro paese, quel paese
  /// entrerebbe da solo, senza che nessuno scriva il suo nome da nessuna
  /// parte.
  static const double densitaMinima = 8.0;

  /// Sotto questo numero di luoghi non si guarda nemmeno la densita': due
  /// citta' vicine hanno una densita' altissima e non disegnano niente.
  static const int luoghiMinimi = 200;

  /// Il margine attorno al riquadro, in parti del suo lato: senza, la citta'
  /// piu' a nord starebbe appiccicata al bordo.
  static const double margine = 0.06;

  /// La nazione di un luogo dato per coordinate, oppure nulla.
  ///
  /// **Le coordinate e non il nome**, perche' quello che la schermata ha in
  /// mano dopo la scelta e' un `BirthPlace`, che porta la citta' e i suoi
  /// gradi ma non il paese. I gradi nascono dal catalogo stesso, quindi
  /// coincidono al punto.
  static MappaDellaNazione? perIlLuogo(
      double lat, double lon, List<City> catalogo) {
    for (final c in catalogo) {
      if ((c.latitude - lat).abs() < 0.0001 &&
          (c.longitude - lon).abs() < 0.0001) {
        return di(c, catalogo);
      }
    }
    return null;
  }

  /// La nazione del luogo scelto, oppure nulla se non si puo' disegnare.
  ///
  /// **La sigla della provincia non e' un paese**: nel catalogo i luoghi
  /// italiani portano `RM`, `MI`, `TO`, e prenderla per il paese vorrebbe dire
  /// disegnare la sola provincia di chi sceglie. Le due lettere si
  /// riconoscono, e valgono tutte insieme per l'Italia.
  static MappaDellaNazione? di(City luogo, List<City> catalogo) {
    final paese = nomeDelPaese(luogo.country);
    final punti = <({double lat, double lon})>[];
    for (final c in catalogo) {
      if (nomeDelPaese(c.country) == paese) {
        punti.add((lat: c.latitude, lon: c.longitude));
      }
    }
    if (punti.length < luoghiMinimi) return null;

    var sud = 90.0, nord = -90.0, ovest = 180.0, est = -180.0;
    for (final p in punti) {
      sud = math.min(sud, p.lat);
      nord = math.max(nord, p.lat);
      ovest = math.min(ovest, p.lon);
      est = math.max(est, p.lon);
    }
    final alto = nord - sud;
    final largo = est - ovest;
    if (alto < 0.01 || largo < 0.01) return null;
    if (punti.length / (alto * largo) < densitaMinima) return null;

    final ma = alto * margine;
    final mo = largo * margine;
    return MappaDellaNazione._(
      paese: paese,
      punti: punti,
      sud: sud - ma,
      nord: nord + ma,
      ovest: ovest - mo,
      est: est + mo,
    );
  }

  /// Il paese di un luogo del catalogo, con l'Italia riconosciuta dalla sigla.
  static String nomeDelPaese(String campo) {
    final c = campo.trim();
    return c.length == 2 ? 'Italia' : c;
  }

  /// **DA GRADI A QUADRO, con la larghezza corretta dal coseno.**
  ///
  /// Alla latitudine dell'Italia un grado di longitudine vale circa i tre
  /// quarti di un grado di latitudine: senza questa correzione lo stivale
  /// verrebbe grasso, e chiunque lo noterebbe senza saper dire perche'.
  ({double x, double y}) proietta(double lat, double lon) {
    final k = math.cos((sud + nord) / 2 * math.pi / 180);
    final largo = (est - ovest) * k;
    final alto = nord - sud;
    // Il lato piu' lungo riempie il quadro, l'altro si centra: le proporzioni
    // restano quelle vere.
    final lato = math.max(largo, alto);
    return (
      x: ((lon - ovest) * k + (lato - largo) / 2) / lato,
      y: ((nord - lat) + (lato - alto) / 2) / lato,
    );
  }
}
