import '../astro/effemeridi.dart';
import '../astro/zodiac.dart';
import 'cielo_di_oggi.dart';
import 'corrente_del_cielo.dart';
import 'il_cielo_del_segno.dart';

/// **NUMERO FORTUNATO E COLORE DEL GIORNO CON UNA REGOLA DICHIARATA, ordine
/// ES voce 29.**
///
/// Il fatto dell'Architetto: il numero era `1 + (seed % 90)` e il colore
/// `palette[seed]`, due hash senza regola. Adesso:
///
/// - **il colore** e' quello tradizionale del pianeta che oggi pesa di piu'
///   per la persona: con la carta natale il pianeta classico del passaggio
///   piu' stretto; senza carta il signore del segno in cui sta la Luna. I
///   colori vengono da William Lilly, *Christian Astrology* (1647), libro I,
///   capitoli VIII-XV, voce "Colours" di ogni pianeta, confrontati con
///   Agrippa, *De occulta philosophia* (1533), I.49; i domicili da Tolomeo,
///   *Tetrabiblos* I.17. Tabella e citazioni in
///   `docs/collaudo/ES/numero_colore.txt`.
/// - **il numero** e' il giorno personale della numerologia: anno personale
///   (giorno e mese di nascita piu' anno corrente), mese personale (piu' il
///   mese corrente), giorno personale (piu' il giorno corrente), ridotti ogni
///   volta a una cifra, numeri maestri compresi, come Hans Decoz. Senza la
///   data di nascita si usa il giorno universale (la sola data di oggi
///   ridotta), e la riga lo dice.
abstract final class IlNumeroEIlColore {
  /// I domicili della tradizione, senza i pianeti moderni.
  static const Map<Zodiac, CorpoCeleste> signoreDi = {
    Zodiac.aries: CorpoCeleste.marte,
    Zodiac.taurus: CorpoCeleste.venere,
    Zodiac.gemini: CorpoCeleste.mercurio,
    Zodiac.cancer: CorpoCeleste.luna,
    Zodiac.leo: CorpoCeleste.sole,
    Zodiac.virgo: CorpoCeleste.mercurio,
    Zodiac.libra: CorpoCeleste.venere,
    Zodiac.scorpio: CorpoCeleste.marte,
    Zodiac.sagittarius: CorpoCeleste.giove,
    Zodiac.capricorn: CorpoCeleste.saturno,
    Zodiac.aquarius: CorpoCeleste.saturno,
    Zodiac.pisces: CorpoCeleste.giove,
  };

  /// Il colore di ogni pianeta classico, come nome dei colori dell'app.
  /// Lilly: Sole giallo e oro; Luna bianco e argento; Mercurio grigio misto
  /// al celeste; Venere bianco e un poco di verde (il bianco e' gia' della
  /// Luna, e il verde lo danno Lilly e Agrippa); Marte rosso; Giove verde
  /// mare o blu (Agrippa: zaffiro); Saturno nero e piombo.
  static const Map<CorpoCeleste, String> coloreDi = {
    CorpoCeleste.sole: 'oro',
    CorpoCeleste.luna: 'argento',
    CorpoCeleste.mercurio: 'grigio azzurro',
    CorpoCeleste.venere: 'verde',
    CorpoCeleste.marte: 'rosso',
    CorpoCeleste.giove: 'blu zaffiro',
    CorpoCeleste.saturno: 'nero piombo',
  };

  /// La riduzione della numerologia: la somma delle cifre fino a una cifra.
  static int riduci(int n) {
    var v = n.abs();
    while (v > 9) {
      var s = 0;
      while (v > 0) {
        s += v % 10;
        v ~/= 10;
      }
      v = s;
    }
    return v;
  }

  /// Il giorno personale (1-9) di chi e' nato il giorno [nascita], per [oggi].
  static int giornoPersonale(DateTime nascita, DateTime oggi) {
    final anno =
        riduci(riduci(nascita.month) + riduci(nascita.day) + riduci(oggi.year));
    final mese = riduci(anno + riduci(oggi.month));
    return riduci(mese + riduci(oggi.day));
  }

  /// Il giorno universale (1-9): la sola data di [oggi].
  static int giornoUniversale(DateTime oggi) =>
      riduci(riduci(oggi.year) + riduci(oggi.month) + riduci(oggi.day));

  /// Il pianeta che oggi pesa di piu', con la sua ragione.
  static (CorpoCeleste, String) pianetaDelGiorno(
      Zodiac segno, CieloDiOggi cielo, DateTime quando) {
    if (cielo.ceCieloVero) {
      final classici = [
        for (final v in cielo.voci)
          if (coloreDi.containsKey(v.transito)) v,
      ]..sort((a, b) => a.orbe.abs().compareTo(b.orbe.abs()));
      if (classici.isNotEmpty) {
        final v = classici.first;
        return (
          v.transito,
          '${CorrenteDelCielo.colSuoArticolo(v.transito)}, il pianeta del '
              'passaggio più stretto di oggi'
        );
      }
    }
    final luna = IlCieloDelSegno.segnoDi(CorpoCeleste.luna, quando);
    final signore = signoreDi[luna]!;
    return (
      signore,
      '${CorrenteDelCielo.colSuoArticolo(signore)}, signore del segno in cui '
          'oggi sta la Luna (${luna.italianName})'
    );
  }

  /// Il numero, il colore e la riga che li spiega.
  static (int, String, String) per({
    required Zodiac segno,
    required CieloDiOggi cielo,
    required DateTime quando,
    DateTime? nascita,
  }) {
    final (pianeta, ragione) = pianetaDelGiorno(segno, cielo, quando);
    final colore = coloreDi[pianeta]!;
    final numero = nascita == null
        ? giornoUniversale(quando)
        : giornoPersonale(nascita, quando);
    final delNumero = nascita == null
        ? 'il giorno universale di oggi, dalla sola data'
        : 'il tuo giorno personale, dalla tua data di nascita e da quella di '
            'oggi';
    return (
      numero,
      colore,
      'Il numero è $delNumero. Il colore è quello di $ragione.'
    );
  }
}
