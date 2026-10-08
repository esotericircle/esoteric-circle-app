/// IL RIAVVOLGIMENTO DEL CIELO, ordine FG parte 3 (voci 3.2 e 3.3).
///
/// **IL TETTO, dichiarato prima della scena (voce 3.3)**: non piu' di
/// [kIstantiAlSecondo] istanti calcolati al secondo; fra un istante e il
/// successivo i fotogrammi interpolano i versori delle stelle e dei corpi.
/// Se sul telefono lento non regge si abbassa [kIstantiAlSecondo], non la
/// fluidita': l'interpolazione resta a ogni fotogramma.
///
/// **Ogni istante calcolato e' un istante VERO del cielo.** Riavvolgere
/// trent'anni in pochi secondi alla lettera vorrebbe dire undicimila giri del
/// cielo e trecentosettanta lunazioni, che campionati a ventiquattro al
/// secondo diventano rumore: le stelle salterebbero a caso e la Luna
/// cambierebbe fase a caso. La scena vuole invece che il senso del movimento
/// lo diano la rotazione diurna accelerata, le fasi della Luna e il moto dei
/// pianeti (voce 3.2). Per questo l'istante k si sceglie cosi':
///
/// 1. la data scende dall'adesso alla nascita con la curva degli anni, che
///    accelera fino a zero ([anniRimasti]);
/// 2. il tempo siderale locale scende con dolcezza da quello di adesso a
///    quello della nascita, girando all'indietro [kGiriDelCielo] volte in
///    piu': e' la rotazione diurna, che accelera e poi rallenta fino a
///    fermarsi sull'istante della nascita;
/// 3. la fase della Luna scende con la data, attraversando a ritroso
///    [kLunazioni] cicli;
/// 4. fra i giorni vicini alla data del punto 1 (piu' o meno quindici) si
///    prende il momento in cui il tempo siderale vale quello del punto 2, e
///    fra quei trentuno momenti quello in cui la fase della Luna e' piu'
///    vicina a quella del punto 3. La fase cambia di circa dodici gradi al
///    giorno: l'errore resta intorno ai sei gradi (misurato 6,84).
///
/// Cosi' le stelle girano fluide, la Luna scorre le sue fasi, i pianeti
/// tornano sui loro passi, e niente e' inventato: ogni istante calcolato e'
/// un momento reale, al piu' quindici giorni lontano dalla data che scorre.
/// L'ultimo e' l'istante della nascita, esatto.
library;

import 'dart:math' as math;

import '../celestial.dart';

/// Il tetto della voce 3.3.
const int kIstantiAlSecondo = 24;

/// Quanto dura la corsa, in secondi.
const double kDurataDelRiavvolgimento = 7.0;

/// I giri all'indietro del cielo in piu' della differenza vera.
const int kGiriDelCielo = 6;

/// I cicli della Luna attraversati a ritroso.
const int kLunazioni = 24;

/// La finestra di giorni attorno alla data che scorre.
const int kGiorniDellaFinestra = 15;

/// Fra i candidati della finestra, quanti si calcolano davvero dopo la stima.
const int kCandidatiCalcolati = 5;

/// La curva degli anni: frazione dell'intervallo ancora da percorrere al
/// punto s fra 0 e 1. Scende accelerando (voce 3.2): lenta all'inizio,
/// rapidissima alla fine.
double anniRimasti(double s) {
  final x = s.clamp(0.0, 1.0);
  return 1 - x * x * x;
}

/// La curva della rotazione: frazione di giri ancora da fare. Accelera e poi
/// rallenta fino a fermarsi.
double giriRimasti(double s) {
  final x = s.clamp(0.0, 1.0);
  return 1 - x * x * (3 - 2 * x);
}

/// L'angolo di fase della Luna, da 0 a 360, crescente dalla luna nuova.
/// `MoonIllumination.elongationDeg` e' gia' l'angolo intero (misurato giorno
/// per giorno: 4 il giorno dopo la nuova, 178 alla piena, 352 la vigilia della
/// nuova); la prima stesura lo ripiegava in due con `waxing`, e nella meta'
/// calante la fase voluta girava al contrario.
double angoloDiFase(double jd) => _norm(Celestial.moonIllumination(jd).elongationDeg);

double _norm(double a) {
  final r = a % 360;
  return r < 0 ? r + 360 : r;
}

/// Il piano del riavvolgimento: gli istanti (giorni giuliani) e il luogo di
/// ciascuno. Il luogo scivola da quello di adesso a quello della nascita.
class PianoDelRiavvolgimento {
  PianoDelRiavvolgimento._(this.istanti, this.latitudini, this.longitudini);

  final List<double> istanti;
  final List<double> latitudini;
  final List<double> longitudini;

  int get length => istanti.length;

  static PianoDelRiavvolgimento prepara({
    required double jdAdesso,
    required double jdNascita,
    required double latAdesso,
    required double lonAdesso,
    required double latNascita,
    required double lonNascita,
    int istantiAlSecondo = kIstantiAlSecondo,
  }) {
    final n = math.max(2, (kDurataDelRiavvolgimento * istantiAlSecondo).ceil());
    final lstAdesso = Celestial.localSiderealDegrees(jdAdesso, lonAdesso);
    final lstNascita = Celestial.localSiderealDegrees(jdNascita, lonNascita);
    final giriTotali = _norm(lstAdesso - lstNascita) + 360.0 * kGiriDelCielo;
    final faseAdesso = angoloDiFase(jdAdesso);
    final faseNascita = angoloDiFase(jdNascita);
    final fasiTotali = _norm(faseAdesso - faseNascita) + 360.0 * kLunazioni;
    final istanti = <double>[];
    final lat = <double>[];
    final lon = <double>[];
    for (var k = 0; k < n; k++) {
      final s = k / (n - 1);
      final la = latNascita + (latAdesso - latNascita) * anniRimasti(s);
      final lo = lonNascita + (lonAdesso - lonNascita) * anniRimasti(s);
      lat.add(la);
      lon.add(lo);
      if (k == 0) {
        istanti.add(jdAdesso);
        continue;
      }
      if (k == n - 1) {
        istanti.add(jdNascita);
        continue;
      }
      final data = jdNascita + (jdAdesso - jdNascita) * anniRimasti(s);
      final lstVoluto = lstNascita + giriTotali * giriRimasti(s);
      final faseVoluta = faseNascita + fasiTotali * anniRimasti(s);
      istanti.add(_istanteVicino(data, lstVoluto, faseVoluta, lo, jdNascita));
    }
    return PianoDelRiavvolgimento._(istanti, lat, lon);
  }

  /// Fra i giorni attorno a [data], il momento col tempo siderale
  /// [lstVoluto] e la fase della Luna piu' vicina a [faseVoluta].
  ///
  /// **Mai prima della nascita.** Un'ipotesi della prima stesura diceva che
  /// questo confine costasse precisione a ridosso della fine (la fase
  /// sbagliava fino a 93 gradi); misurata, e' caduta: con e senza confine lo
  /// scarto era lo stesso, e la causa vera era [angoloDiFase] ripiegato in
  /// due. Il confine resta, e non costa niente.
  ///
  /// **La fase si stima e poi si calcola.** Calcolarla in tutti i trentuno
  /// candidati costava 1.850 millisecondi per piano nella prova; qui si stima
  /// con la sua velocita' misurata nel giorno della data, e la si calcola
  /// davvero solo nei [kCandidatiCalcolati] migliori. Con tre la stima
  /// sbagliava candidato e lo scarto arrivava a 17,8 gradi; con cinque e'
  /// 6,84 gradi, in 429 millisecondi.
  static double _istanteVicino(double data, double lstVoluto,
      double faseVoluta, double lon, double nascita) {
    // La velocita' del tempo siderale si misura, non si scrive: le costanti
    // del cielo vivono nella porta di Meeus.
    final lst0 = Celestial.localSiderealDegrees(data, lon);
    final lst1 = Celestial.localSiderealDegrees(data + 0.25, lon);
    // In un quarto di giorno il tempo siderale avanza di circa novanta gradi.
    final gradiAlGiorno = _norm(lst1 - lst0) * 4;
    final giornoSiderale = 360 / gradiAlGiorno;
    final base = data + _norm(lstVoluto - lst0) / gradiAlGiorno;
    final fase0 = angoloDiFase(base);
    final faseAlGiorno = _norm(angoloDiFase(base + 1) - fase0);
    final stime = <(double, double)>[];
    for (var j = -kGiorniDellaFinestra; j <= kGiorniDellaFinestra; j++) {
      final t = base + j * giornoSiderale;
      // Mai prima della nascita: il riavvolgimento si ferma li'.
      if (t < nascita) continue;
      final stimata = fase0 + faseAlGiorno * (t - base);
      stime.add((t, (_norm(stimata - faseVoluta + 180) - 180).abs()));
    }
    stime.sort((a, b) => a.$2.compareTo(b.$2));
    var migliore = stime.first.$1;
    var scartoMigliore = double.infinity;
    for (final (t, _) in stime.take(kCandidatiCalcolati)) {
      final d = (_norm(angoloDiFase(t) - faseVoluta + 180) - 180).abs();
      if (d < scartoMigliore) {
        scartoMigliore = d;
        migliore = t;
      }
    }
    return migliore;
  }
}
