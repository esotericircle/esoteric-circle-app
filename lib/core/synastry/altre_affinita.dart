import '../astro/zodiac.dart';
import '../astro/natal_chart.dart';
import 'cielo_della_sinastria.dart';

/// LE ALTRE AFFINITA'. Ordine BX voce 09, terzo rilievo.
///
/// **Il fondatore ha chiesto altre barre oltre a quelle che ci sono.** Le tre
/// di oggi guardano tutte lo stesso materiale, gli aspetti fra i punti
/// personali: amore, mente, scintille. Queste tre guardano cose diverse, e
/// ognuna poggia su una tradizione reale e documentata, come la regola del
/// progetto impone: **niente e' inventato qui dentro.**
///
/// **TERRA COMUNE, dalla dottrina dei quattro elementi** (Tolomeo,
/// Tetrabiblos I.17-18): fuoco e aria si sostengono, terra e acqua si
/// sostengono, e le coppie fuoco-acqua e terra-aria sono quelle che faticano.
/// E' la piu' antica misura di compatibilita' che l'astrologia conosca, e non
/// dice se vi amate: dice se vi capite senza spiegarvi.
///
/// **RITMO, dalle qualita' cardinale, fissa e mobile** (stessa fonte, I.12).
/// Due cardinali cominciano insieme e si scontrano sul comando; due fissi
/// tengono e non si spostano; due mobili si adattano e nessuno decide. La
/// tradizione considera piu' fluide le coppie di qualita' DIVERSA, e questa
/// barra misura proprio quello.
///
/// **VITA QUOTIDIANA, dagli aspetti della Luna e dell'Ascendente.** La
/// tradizione lega la Luna alle abitudini, alla casa e al modo di riposare, e
/// l'Ascendente al modo di presentarsi al mondo: i loro aspetti fra due cieli
/// dicono come si sta insieme il martedi' pomeriggio, che non e' la stessa
/// domanda dell'amore.
///
/// **Saturno era la prima scelta ed e' stata scartata da un fatto**: i punti
/// del cielo che questa sinastria calcola sono sei, Sole, Luna, Mercurio,
/// Venere, Marte e Ascendente, e Saturno non c'e'. Aggiungerlo vorrebbe dire
/// cambiare il modello degli aspetti, che questa voce non ha mandato di
/// toccare, e inventarlo sarebbe peggio.
class AltreAffinita {
  const AltreAffinita._();

  /// La qualita' di un segno: cardinale, fissa, mobile. **Non e' una tabella
  /// inventata**: e' l'ordine dello zodiaco, dove ogni terzetto ripete il
  /// ciclo cardinale, fisso, mobile a partire dall'Ariete.
  static int _qualita(Zodiac segno) => segno.index % 3;

  /// **TERRA COMUNE**, da zero a cento.
  static int terraComune(CieloDiSinastria tuo, CieloDiSinastria suo) {
    final mio = tuo.segnoSolare.element;
    final tuoElemento = suo.segnoSolare.element;
    if (mio == tuoElemento) return 92;
    const amici = {
      ZodiacElement.fire: ZodiacElement.air,
      ZodiacElement.air: ZodiacElement.fire,
      ZodiacElement.earth: ZodiacElement.water,
      ZodiacElement.water: ZodiacElement.earth,
    };
    if (amici[mio] == tuoElemento) return 74;
    // Fuoco con acqua, terra con aria: la coppia che la tradizione chiama
    // faticosa. Non e' zero, perche' faticoso non vuol dire impossibile.
    const opposti = {
      ZodiacElement.fire: ZodiacElement.water,
      ZodiacElement.water: ZodiacElement.fire,
      ZodiacElement.earth: ZodiacElement.air,
      ZodiacElement.air: ZodiacElement.earth,
    };
    return opposti[mio] == tuoElemento ? 28 : 46;
  }

  /// **RITMO**, da zero a cento.
  static int ritmo(CieloDiSinastria tuo, CieloDiSinastria suo) {
    final mia = _qualita(tuo.segnoSolare);
    final sua = _qualita(suo.segnoSolare);
    if (mia != sua) return 80;
    // Stessa qualita': si somigliano troppo, e la tradizione lo dice da
    // sempre. Fra i tre casi il piu' duro e' cardinale con cardinale, dove
    // nessuno dei due cede il comando.
    return mia == 0 ? 34 : 52;
  }

  /// **VITA QUOTIDIANA**, da zero a cento. Senza aspetti fra Luna e
  /// Ascendente resta al mezzo dichiarato: **non si inventa un legame che il
  /// cielo non porta.**
  static int vitaQuotidiana(List<AspettoDiSinastria> aspetti) {
    var punti = 0.0;
    var quanti = 0;
    for (final a in aspetti) {
      const casa = {PuntoDelCielo.luna, PuntoDelCielo.ascendente};
      final tocca = casa.contains(a.tuo) && casa.contains(a.suo);
      if (!tocca) continue;
      quanti++;
      switch (a.tipo) {
        case AspectType.trine:
          punti += 1.0;
        case AspectType.sextile:
          punti += 0.7;
        case AspectType.conjunction:
          punti += 0.45;
        case AspectType.opposition:
          punti += 0.15;
        case AspectType.square:
          punti -= 0.5;
      }
    }
    if (quanti == 0) return 50;
    final media = (punti / quanti).clamp(-1.0, 1.0);
    return (50 + media * 45).round().clamp(4, 96);
  }
}
