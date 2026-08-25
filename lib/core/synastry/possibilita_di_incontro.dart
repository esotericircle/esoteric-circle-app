import 'dart:math' as math;

import 'cielo_del_giorno_sulla_coppia.dart';
import 'cielo_della_sinastria.dart';
import 'vip_catalog.dart';

/// DOVE SEI TU, per il conto della distanza: due coordinate e un nome.
///
/// **Prende numeri e non classi, per la stessa ragione del cielo.** Il luogo
/// della persona puo' arrivare da tre posti diversi (`LuogoAttuale` dichiarato,
/// il GPS, il luogo di nascita), con tre modelli diversi. Qui entra cio' che
/// serve, e chi lo ha lo passa.
class DoveSei {
  const DoveSei({
    required this.citta,
    required this.latitudine,
    required this.longitudine,
  });

  final String citta;
  final double latitudine;
  final double longitudine;
}

/// LA POSSIBILITA' DI INCONTRO, e stavolta si spiega. Ordine BO voce 03.
///
/// **Parole del fondatore, che sono la premessa di questa classe**: "se un vip
/// abita nella mia citta' o sotto casa o nel mio paese dovrebbe avere maggiori
/// probabilita' di incontro, ma cmq i testi di responso sono sempre gli
/// stessi".
///
/// **Il difetto misurato.** Il numero era `((lo * 7 + hi * 13) % 39) / 10 +
/// 0.2` sugli INDICI DEI DUE SEGNI: stava fra 0,2 e 4,0 per cento, non
/// conosceva ne' la citta', ne' il paese, ne' se il VIP fosse ancora vivo, e la
/// battuta sotto la barra nasceva dallo stesso resto. Due VIP dello stesso
/// segno, uno a Milano e uno a Los Angeles, davano lo stesso identico numero.
///
/// Adesso nasce da tre fatti veri e dichiarati: **se e' in vita**, **quanto
/// dista la sua citta' dalla tua** e **quanto si fa vedere in pubblico**. E si
/// SPIEGA sempre in una riga che nomina quei fatti, perche' una percentuale
/// senza il suo perche' e' un numero che nessuno puo' contestare ne' credere.
class PossibilitaDiIncontro {
  const PossibilitaDiIncontro({
    required this.esiste,
    required this.percento,
    required this.perche,
    this.chilometri,
    this.suaCitta,
    this.sueCoordinate,
    this.celeste,
    this.giornoPiuAcceso,
    this.baseGeografica,
  });

  /// **Falsa per chi non c'e' piu'.** Ordine BO voce 04: l'incontro non esiste
  /// e non si mostra, e al suo posto la scena parla di eredita'.
  final bool esiste;

  /// La percentuale, da 0,1 a [tetto].
  final double percento;

  /// La riga che dice il perche', e nomina sempre almeno un fatto vero.
  final String perche;

  /// Quanti chilometri vi separano, quando si sa dove vive.
  final double? chilometri;

  /// Come si chiama la citta' dove vive, quando e' pubblica.
  final String? suaCitta;

  /// Dove sta quella citta'. **Serve alla mappa della voce BO.09, e la mappa
  /// non deve stimarla**: il dossier le ha, e una posizione stimata da una
  /// distanza sarebbe un punto inventato messo su una mappa vera.
  final ({double lat, double lon})? sueCoordinate;

  /// **IL CIELO DEL GIORNO SU QUESTA COPPIA, ordine BO voce 12.** Nullo
  /// quando non e' stato chiesto, cioe' quando chi chiama non ha passato gli
  /// aspetti: la geografia da sola resta valida ed e' quella della voce 03.
  final MoltiplicatoreCeleste? celeste;

  /// Il giorno dei prossimi sei mesi in cui quel legame e' piu' acceso.
  final GiornoPiuAcceso? giornoPiuAcceso;

  /// La percentuale PRIMA del moltiplicatore, cioe' la sola geografia.
  /// **La voce 03 e' chiusa e non si riapre**: il suo calcolo resta la base, e
  /// questa riga lo dimostra tenendolo visibile accanto al risultato.
  final double? baseGeografica;

  /// **IL TETTO, e non e' un numero indovinato.** E' la percentuale che tocca
  /// alla persona piu' esposta del catalogo se vive nella tua stessa citta':
  /// diciotto per cento, cioe' "quasi una su cinque", che e' quanto si puo'
  /// onestamente dire di chi fa vita pubblica a due passi da te. Sopra
  /// sarebbe una promessa, sotto sarebbe la stessa piattezza di prima.
  static const double tetto = 18.0;

  /// Il pavimento: nessuna possibilita' scende a zero, perche' zero vorrebbe
  /// dire impossibile, e non lo e'.
  static const double pavimento = 0.1;

  /// **LA SCALA DELLA DISTANZA, in chilometri.** La possibilita' scende come
  /// `scala / (scala + km)`: vale mezzo a trecento chilometri, cioe' alla
  /// distanza di un viaggio in giornata, e continua a scendere senza mai
  /// arrivare a zero. Trecento e' la scelta dichiarata del progetto: dentro
  /// una citta' e nella sua provincia il fattore resta quasi pieno, a mille
  /// chilometri e' sceso a un quarto, dall'altra parte del mondo a un
  /// trentesimo.
  static const double scalaInChilometri = 300.0;

  /// Il fattore per chi non dichiara pubblicamente dove vive.
  ///
  /// **Non e' zero e non e' uno.** Non sapere dove vive non vuol dire che sia
  /// lontano, e nemmeno vicino: e' il valore che tocca a un continente di
  /// distanza media, cioe' quanto vale `scala / (scala + 2200)`. Dichiararlo
  /// qui invece di lasciarlo cadere da una formula rende visibile che e' una
  /// scelta e non un caso.
  static const double fattoreSenzaCitta = 0.12;

  /// LA DISTANZA IN CHILOMETRI fra due punti della sfera, con la formula
  /// dell'emisenoverso. Raggio medio terrestre 6.371 chilometri.
  static double chilometriFra(
      double lat1, double lon1, double lat2, double lon2) {
    const grad = math.pi / 180.0;
    const raggio = 6371.0;
    final dLat = (lat2 - lat1) * grad;
    final dLon = (lon2 - lon1) * grad;
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * grad) *
            math.cos(lat2 * grad) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return raggio * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  /// Il conto, per questo VIP e per dove sei tu.
  factory PossibilitaDiIncontro.per({
    required Vip vip,
    DoveSei? doveSei,
    List<AspettoDiSinastria>? aspetti,
    CieloDiSinastria? tuo,
    CieloDiSinastria? suo,
    DateTime? quando,
    bool cercaIlGiornoMigliore = false,
  }) {
    // **CHI NON C'E' PIU' NON SI INCONTRA.** Ordine BO voce 04: non e' un
    // numero basso, e' una domanda che non si pone.
    if (vip.eScomparso) {
      return PossibilitaDiIncontro(
        esiste: false,
        percento: 0,
        perche: '${vip.name} ci ha lasciati nel ${vip.annoDellaScomparsa}: '
            'un incontro non è fra le cose che il cielo può promettere.',
      );
    }

    final sua = vip.luogoDiOggi;
    double fattore;
    double? km;
    String perche;
    final comeSiMostra = vip.esposizione.comeSiDice;

    if (sua == null || doveSei == null) {
      fattore = fattoreSenzaCitta;
      perche = sua == null
          ? 'Non si sa pubblicamente dove viva, quindi la distanza non entra '
              'nel conto: resta che $comeSiMostra.'
          : 'Vive a ${sua.nome}. Non hai ancora detto al Cerchio dove stai, '
              'quindi la distanza non entra nel conto: resta che '
              '$comeSiMostra.';
    } else {
      km = chilometriFra(doveSei.latitudine, doveSei.longitudine,
          sua.latitudine, sua.longitudine);
      fattore = scalaInChilometri / (scalaInChilometri + km);
      if (km < 20) {
        perche = 'Vive a ${sua.nome}, la tua stessa città: $comeSiMostra.';
      } else if (km < 200) {
        perche = 'Vive a ${sua.nome}, a ${_km(km)} da te, un viaggio in '
            'giornata: $comeSiMostra.';
      } else {
        perche = 'Vive a ${sua.nome}, a ${_km(km)} da te: $comeSiMostra.';
      }
    }

    // **LA BASE GEOGRAFICA, che e' la voce 03 e non si tocca.**
    final base = tetto * vip.esposizione.peso * fattore;

    // **IL CIELO DEL GIORNO MOLTIPLICA, ordine BO voce 12.** La geografia
    // dice se un incontro e' possibile, il cielo dice quando. Il tetto e il
    // pavimento restano e valgono DOPO la moltiplicazione.
    MoltiplicatoreCeleste? celeste;
    GiornoPiuAcceso? migliore;
    if (aspetti != null && tuo != null && suo != null) {
      celeste = MoltiplicatoreCeleste.per(
        aspetti: aspetti,
        tuo: tuo,
        suo: suo,
        giorno: quando ?? DateTime.now(),
      );
      if (cercaIlGiornoMigliore) {
        migliore = GiornoPiuAcceso.cerca(
          aspetti: aspetti,
          tuo: tuo,
          suo: suo,
          da: quando ?? DateTime.now(),
        );
      }
    }
    final percento = (base * (celeste?.valore ?? 1.0))
        .clamp(pavimento, tetto)
        .toDouble();

    return PossibilitaDiIncontro(
      esiste: true,
      percento: percento,
      perche: perche,
      chilometri: km,
      suaCitta: sua?.nome,
      sueCoordinate:
          sua == null ? null : (lat: sua.latitudine, lon: sua.longitudine),
      celeste: celeste,
      giornoPiuAcceso: migliore,
      baseGeografica: base.clamp(pavimento, tetto).toDouble(),
    );
  }

  /// I chilometri come si scrivono in italiano, col punto delle migliaia.
  static String _km(double km) {
    final n = km.round();
    if (n < 1000) return '$n km';
    final migliaia = n ~/ 1000;
    final resto = (n % 1000).toString().padLeft(3, '0');
    return '$migliaia.$resto km';
  }

  /// La percentuale come si scrive, con la virgola decimale italiana.
  String get etichetta =>
      '${percento.toStringAsFixed(1).replaceAll('.', ',')}%';
}

/// L'EREDITA', per chi non c'e' piu'. Ordine BO voce 04.
///
/// **Al posto dell'incontro, che non esiste, una domanda diversa**: cosa del
/// suo cielo vive nel tuo. E si dice con un fatto vero della sinastria, non
/// con una frase di circostanza: e' lo stesso aspetto che il responso ha gia'
/// calcolato, il piu' stretto dei suoi.
class EreditaDelCielo {
  const EreditaDelCielo._();

  /// Il testo dell'eredita', oppure nullo se il VIP e' in vita.
  static String? per(Vip vip, List<AspettoDiSinastria> aspetti) {
    if (!vip.eScomparso) return null;
    final anno = vip.annoDellaScomparsa;
    final apertura = anno == null
        ? '${vip.name} non c\'è più.'
        : '${vip.name} ci ha lasciati nel $anno.';
    if (aspetti.isEmpty) {
      return '$apertura Il suo cielo e il tuo non si toccano in nessuno dei '
          'punti che contano: quello che resta di lui lo trovi nel suo '
          'lavoro, non in un angolo fra le vostre carte.';
    }
    final primo = aspetti.first;
    return '$apertura Quello che del suo cielo continua nel tuo è '
        '${primo.fatto}: quel punto tu ce l\'hai ancora. Ogni volta che lo '
        'usi stai facendo qualcosa che lui ha fatto prima di te.';
  }
}
