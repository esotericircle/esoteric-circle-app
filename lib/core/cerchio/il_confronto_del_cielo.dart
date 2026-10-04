import 'dart:math' as math;

import '../astro/night_sky.dart';
import '../astro/zodiac.dart';
import '../synastry/altre_affinita.dart';
import '../synastry/cielo_della_sinastria.dart';

/// **IL CONFRONTO DEL CIELO FRA DUE AMICI, ordine EY voce 13.**
///
/// Deterministico e senza modello. Il fondatore: "l'oroscopo e segno vanno
/// bene per iniziare". Il confronto e' sul SEGNO e non sulla carta intera:
/// il profilo pubblico di un amico porta il segno, mai la data ne' l'ora, e
/// nessun numero finge una precisione che non c'e'.
///
/// **Le quattro barre.**
/// - **Terra comune** e **Ritmo** sono le stesse funzioni che calcolano le
///   barre della Sinastria VIP (`AltreAffinita.terraComune` e `.ritmo`):
///   l'elemento e la modalita' dei due segni. Non riscritte, usate.
/// - **L'aspetto dei segni**: la distanza fra i due segni sulla ruota, cioe'
///   l'aspetto tolemaico fra i loro gradi medi (congiunzione, sestile,
///   quadrato, trigono, opposizione, e i due minori).
/// - **Il cielo di oggi, ordine EZ voce 02**: la LONGITUDINE VERA della Luna
///   di oggi (`NightSky.moonEclipticLongitude`, che chiede a `Effemeridi`, la
///   porta sola del cielo) misurata dal PUNTO D'INCONTRO dei due segni, il
///   punto medio fra i loro gradi centrali sull'arco piu' corto: e' il punto
///   su cui la tradizione costruisce la carta composita di una coppia. La
///   Luna congiunta al punto accorda tutti e due, opposta li mette alla
///   prova, e in mezzo la giornata scorre: il valore e' il coseno della
///   distanza. Per due segni opposti i punti medi sono due, a 180 gradi
///   l'uno dall'altro, e la loro media annullerebbe il cielo: vale quello
///   che viene prima nella ruota dall'Ariete, una regola che non dipende
///   dall'ordine dei due.
///
///   **Perche' non piu' il segno della Luna.** Con l'ordine EY il cielo del
///   giorno guardava la Luna per segno, che resta nello stesso segno due o
///   tre giorni: Leone e Pesci leggevano quattro valori in trenta giorni, e
///   per ventisei giorni su trenta lo stesso numero. Rilievo
///   dell'Architetto del 4 ottobre 2026, approvato dal fondatore.
///
/// **IL CIELO MODULA, NON SOSTITUISCE.** La base e' la media pesata delle tre
/// barre dei segni, che non cambiano mai per una coppia; il cielo di oggi la
/// sposta di al massimo venti punti in su o in giu'. Per lasciargli posto
/// senza sfondare il cento, la base si avvicina al cinquanta di tre decimi,
/// uguale per tutte le coppie: chi sta sopra resta sopra nei giorni medi.
/// Le due prove dell'ordine EZ voce 02 lo misurano su tutte le 78 coppie e
/// trenta giorni: almeno quindici valori per coppia e venti di mediana,
/// perche' un numero che non cambia almeno un giorno su due non da'
/// nessuna ragione per tornare; e mai un salto oltre dodici punti fra due
/// giorni, perche' un numero che salta da 87 a 42 sembra tirato a caso.
///
/// **LA SIMMETRIA E' UNA PROVA, NON UNA SPERANZA.** Ogni barra e' simmetrica
/// per costruzione, e il punto d'incontro e' lo stesso visto dai due lati:
/// da A verso B e da B verso A esce lo stesso numero. Una prova enumera le
/// 78 coppie di segni in piu' giorni e lo pretende.
class IlConfrontoDelCielo {
  const IlConfrontoDelCielo._({
    required this.affinita,
    required this.terraComune,
    required this.ritmo,
    required this.aspetto,
    required this.cieloDiOggi,
    required this.lunaDiOggi,
    required this.nomeDellAspetto,
  });

  /// L'affinita' del giorno, da 0 a 100.
  final int affinita;
  final int terraComune;
  final int ritmo;
  final int aspetto;
  final int cieloDiOggi;
  final Zodiac lunaDiOggi;
  final String nomeDellAspetto;

  /// I pesi della base, dichiarati: elemento e aspetto pesano di piu',
  /// perche' sono le due relazioni che la tradizione mette davanti.
  static const double pesoTerra = 0.3;
  static const double pesoRitmo = 0.2;
  static const double pesoAspetto = 0.3;

  /// Di quanto la base si avvicina al cinquanta per lasciare posto al cielo.
  static const double fattoreDellaBase = 0.7;

  /// Di quanti punti, al massimo, il cielo di oggi sposta il numero.
  static const double ampiezzaDelGiorno = 20;

  /// IL PUNTO D'INCONTRO dei due segni, in gradi: il punto medio fra i loro
  /// gradi centrali sull'arco piu' corto. Per due segni opposti, quello dei
  /// due che viene prima nella ruota dall'Ariete.
  static double puntoDIncontro(Zodiac a, Zodiac b) {
    final ma = a.index * 30 + 15.0;
    var d = (b.index * 30 + 15.0 - ma) % 360;
    if (d > 180) d -= 360;
    if (d.abs() == 180) {
      return math.min((ma + 90) % 360, (ma + 270) % 360);
    }
    return (ma + d / 2) % 360;
  }

  static CieloDiSinastria _cielo(Zodiac s) =>
      CieloDiSinastria(longitudini: const {}, segnoSolare: s, oraNota: false);

  /// L'aspetto fra due segni dalla loro distanza sulla ruota, e quanto vale.
  static (int, String) aspettoFra(Zodiac a, Zodiac b) {
    final d = (a.index - b.index).abs();
    final passi = d > 6 ? 12 - d : d;
    return switch (passi) {
      0 => (85, 'congiunzione'),
      1 => (50, 'semisestile'),
      2 => (78, 'sestile'),
      3 => (38, 'quadrato'),
      4 => (92, 'trigono'),
      5 => (42, 'quinconce'),
      _ => (55, 'opposizione'),
    };
  }

  static IlConfrontoDelCielo fra(Zodiac a, Zodiac b, DateTime giorno) {
    final terra = AltreAffinita.terraComune(_cielo(a), _cielo(b));
    final ritmo = AltreAffinita.ritmo(_cielo(a), _cielo(b));
    final (aspetto, nome) = aspettoFra(a, b);
    // A mezzogiorno del giorno: la Luna del giorno e' una per tutti e due.
    final mezzogiorno = DateTime.utc(giorno.year, giorno.month, giorno.day, 12);
    final luna = NightSky.moonSign(mezzogiorno);
    final distanza =
        NightSky.moonEclipticLongitude(mezzogiorno) - puntoDIncontro(a, b);
    // Da +1 con la Luna sul punto d'incontro a -1 con la Luna opposta.
    final accordo = math.cos(distanza * math.pi / 180);
    final cieloDiOggi = (50 + 50 * accordo).round();
    final base =
        (pesoTerra * terra + pesoRitmo * ritmo + pesoAspetto * aspetto) /
            (pesoTerra + pesoRitmo + pesoAspetto);
    final totale =
        50 + fattoreDellaBase * (base - 50) + ampiezzaDelGiorno * accordo;
    return IlConfrontoDelCielo._(
      affinita: totale.round().clamp(0, 100),
      terraComune: terra,
      ritmo: ritmo,
      aspetto: aspetto,
      cieloDiOggi: cieloDiOggi,
      lunaDiOggi: luna,
      nomeDellAspetto: nome,
    );
  }

  /// Le quattro barre nell'ordine in cui si riempiono.
  List<(String, int)> get barre => [
        ('Terra comune', terraComune),
        ('Ritmo', ritmo),
        ('L’aspetto dei segni', aspetto),
        ('Il cielo di oggi', cieloDiOggi),
      ];

  /// La riga che dice come stanno insieme i due cieli di oggi.
  String rigaDelGiorno(Zodiac a, Zodiac b) {
    final insieme = cieloDiOggi >= 70
        ? 'li accorda tutti e due'
        : cieloDiOggi >= 50
            ? 'li tocca con garbo'
            : 'chiede a tutti e due un passo di pazienza';
    return 'Oggi la Luna in ${lunaDiOggi.italianName} $insieme: '
        '${a.italianName} e ${b.italianName} in $nomeDellAspetto.';
  }

  /// IL PANNELLO FONTI E METODO, come su ogni arte.
  static const String fontiEMetodo =
      'Da dove viene la percentuale. La base sono tre misure sui due segni '
      'solari, che per la vostra coppia non cambiano mai: l’elemento (Terra '
      'comune), la modalità cardinale, fissa o mobile (Ritmo) e l’aspetto '
      'fra i due segni sulla ruota. Il cielo di oggi la sposta di al massimo '
      'venti punti: è la distanza della Luna vera di oggi dal punto '
      'd’incontro dei vostri due segni, il punto medio su cui la tradizione '
      'costruisce la carta composita di una coppia. Luna vicina, giornata '
      'che vi accorda; Luna opposta, giornata che vi mette alla prova. '
      'Elementi, modalità e aspetti tolemaici sono della tradizione '
      'astrologica, la stessa da cui nascono le barre della Sinastria '
      'VIP.\n\n'
      'Cosa confronta. Il segno e non la carta intera: del cielo di un amico '
      'il Cerchio conosce il segno, mai la data, l’ora o il luogo. Per questo '
      'il numero non finge la precisione di una sinastria completa.\n\n'
      'La lettura è una chiave di lettura del Maestro e non una dottrina '
      'tradizionale: la tradizione dà gli elementi, le modalità e gli '
      'aspetti, il modo di pesarli insieme è del Cerchio.';

  /// La riga che dichiara su cosa poggia il numero.
  static const String sulSegno =
      'Il confronto è sul segno e non sulla carta intera.';
}
