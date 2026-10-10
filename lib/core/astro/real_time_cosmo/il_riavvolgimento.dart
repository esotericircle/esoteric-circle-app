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
///
/// **I DUE TEMPI, ordine FH parte 8.** In trentasette anni la Luna compie 457
/// lunazioni: dentro sette secondi sono 65 al secondo, una fase ogni mezzo
/// fotogramma, invisibile (voce 8.1). Per questo la corsa qui sopra si ferma
/// UN ANNO prima della nascita, e l'ultimo anno e' il rallentamento (voce
/// 8.2): [kGiorniSideraliDellUltimoAnno] giorni siderali percorsi in
/// [kDurataDelRallentamento] secondi, con passi che scendono in modo lineare
/// da quasi tre giorni a un giorno solo. Ogni istante del rallentamento sta a
/// un numero INTERO di giorni siderali dalla nascita: il tempo siderale e'
/// sempre quello della nascita, le stelle restano ferme sull'orizzonte e la
/// Luna cammina fra loro mostrando le sue ultime dodici o tredici lunazioni
/// una per una, fino a fermarsi su quella della notte di nascita. I passi non
/// scendono mai sotto il giorno: con passi piu' corti due istanti di fila
/// cadrebbero sullo stesso giorno siderale e la Luna si fermerebbe per poi
/// saltare. L'ultimo istante e' quello della nascita, esatto.
library;

import 'dart:math' as math;

import '../celestial.dart';

/// Il tetto della voce 3.3.
const int kIstantiAlSecondo = 24;

/// Quanto dura la corsa, in secondi.
const double kDurataDelRiavvolgimento = 7.0;

/// Quanto dura il rallentamento dell'ultimo anno, in secondi (ordine FH voce
/// 8.2): dodici lunazioni e mezza in otto secondi, poco piu' di mezzo secondo
/// l'una, e ognuna piu' lenta della precedente.
const double kDurataDelRallentamento = 8.0;

/// L'ultimo anno in giorni siderali: 365,25 giorni solari sono 366,25 giorni
/// siderali, e il rallentamento ne percorre un numero intero.
const int kGiorniSideraliDellUltimoAnno = 366;

/// Sotto questo distacco fra l'adesso e l'inizio del rallentamento la corsa
/// non c'e': chi e' nato da poco piu' di un anno passa subito all'ultimo.
const double kGiorniMinimiDellaCorsa = 30;

/// I giri all'indietro del cielo in piu' della differenza vera.
const int kGiriDelCielo = 6;

/// I cicli della Luna attraversati a ritroso.
const int kLunazioni = 24;

/// La finestra di giorni attorno alla data che scorre.
const int kGiorniDellaFinestra = 15;

/// Fra i candidati della finestra, quanti si calcolano davvero dopo la stima.
const int kCandidatiCalcolati = 3;

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
double angoloDiFase(double jd) =>
    _norm(Celestial.moonIllumination(jd).elongationDeg);

double _norm(double a) {
  final r = a % 360;
  return r < 0 ? r + 360 : r;
}

/// Il piano del riavvolgimento: gli istanti (giorni giuliani) e il luogo di
/// ciascuno. Il luogo scivola da quello di adesso a quello della nascita.
class PianoDelRiavvolgimento {
  PianoDelRiavvolgimento._(this.istanti, this.latitudini, this.longitudini,
      {required this.fineDellaCorsa,
      required this.durataDellaCorsa,
      required this.durataDelRallentamento});

  final List<double> istanti;
  final List<double> latitudini;
  final List<double> longitudini;

  /// L'indice dell'istante dove finisce la corsa e comincia il rallentamento
  /// (ordine FH voce 8.2). Senza rallentamento e' l'ultimo.
  final int fineDellaCorsa;

  /// Le durate dei due tempi in secondi: il tetto della voce 3.3 vale per
  /// tutti e due, (istanti del tempo) / (durata) mai sopra
  /// [kIstantiAlSecondo].
  final double durataDellaCorsa;
  final double durataDelRallentamento;

  int get length => istanti.length;

  /// Il punto fra gli istanti, da 0 a length - 1, dopo [secondi] dall'inizio
  /// della corsa.
  double puntoAl(double secondi) {
    if (secondi < durataDellaCorsa) {
      return secondi / durataDellaCorsa * fineDellaCorsa;
    }
    if (durataDelRallentamento <= 0) return (length - 1).toDouble();
    final r =
        ((secondi - durataDellaCorsa) / durataDelRallentamento).clamp(0.0, 1.0);
    return fineDellaCorsa + r * (length - 1 - fineDellaCorsa);
  }

  /// LA DATA CHE SCORRE, al punto [k] fra gli istanti (aggiunta del
  /// fondatore all'ordine FH parte 8, 10 ottobre 2026: sotto gli anni la
  /// data, da oggi alla nascita). Si legge sulla curva degli anni e non sugli
  /// istanti della corsa: quelli stanno fino a quindici giorni lontano dalla
  /// curva, avanti e indietro, e una data che torna su' mentre scende si
  /// vedrebbe. Nel rallentamento gli istanti scendono sempre, e la data e'
  /// quella del cielo disegnato.
  double dataAlPunto(double k) {
    final fine = fineDellaCorsa;
    if (k < fine && fine > 1) {
      final traguardo = istanti[fine];
      return traguardo + (istanti.first - traguardo) * anniRimasti(k / fine);
    }
    final k0 = k.floor().clamp(0, length - 1);
    final k1 = math.min(k0 + 1, length - 1);
    return istanti[k0] + (istanti[k1] - istanti[k0]) * (k - k0);
  }

  /// La durata intera dei due tempi.
  double get durata => durataDellaCorsa + durataDelRallentamento;

  /// Gli istanti del rallentamento, dall'inizio alla nascita: [giorni]
  /// giorni siderali in [passi] passi lineari che finiscono a un giorno.
  static List<double> ultimoAnno(
      double jdNascita, double giornoSiderale, int giorni, int passi) {
    final fuori = <double>[jdNascita + giorni * giornoSiderale];
    if (passi < 1) return fuori;
    // Il primo passo vale a, l'ultimo uno: la somma e' passi * (a + 1) / 2,
    // cioe' i giorni.
    final a = 2 * giorni / passi - 1;
    var fatti = 0.0;
    for (var j = 1; j <= passi; j++) {
      fatti +=
          passi == 1 ? giorni.toDouble() : a + (1 - a) * (j - 1) / (passi - 1);
      final m = j == passi ? giorni : fatti.round();
      fuori.add(jdNascita + (giorni - m) * giornoSiderale);
    }
    return fuori;
  }

  static PianoDelRiavvolgimento prepara({
    required double jdAdesso,
    required double jdNascita,
    required double latAdesso,
    required double lonAdesso,
    required double latNascita,
    required double lonNascita,
    int istantiAlSecondo = kIstantiAlSecondo,
  }) {
    // IL SECONDO TEMPO, l'ultimo anno (ordine FH voce 8.2).
    final lst0 = Celestial.localSiderealDegrees(jdNascita, lonNascita);
    final lst1 = Celestial.localSiderealDegrees(jdNascita + 0.25, lonNascita);
    final giornoSiderale = 360 / (_norm(lst1 - lst0) * 4);
    final giorni = math.max(
        0,
        math.min(kGiorniSideraliDellUltimoAnno,
            ((jdAdesso - jdNascita) / giornoSiderale).floor()));
    final passi =
        math.min((kDurataDelRallentamento * istantiAlSecondo).floor(), giorni);
    final ultimo = ultimoAnno(jdNascita, giornoSiderale, giorni, passi);
    final durataDelRallentamento = passi / istantiAlSecondo;
    final traguardo = ultimo.first;

    if (jdAdesso - traguardo < kGiorniMinimiDellaCorsa) {
      // Nessuna corsa: dall'adesso si passa all'ultimo anno.
      final istanti = [jdAdesso, ...ultimo];
      return PianoDelRiavvolgimento._(
        istanti,
        [latAdesso, for (final _ in ultimo) latNascita],
        [lonAdesso, for (final _ in ultimo) lonNascita],
        fineDellaCorsa: 1,
        durataDellaCorsa: 1 / istantiAlSecondo,
        durataDelRallentamento: durataDelRallentamento,
      );
    }

    // IL PRIMO TEMPO, la corsa: dall'adesso fino al traguardo, un anno prima
    // della nascita.
    final n = math.max(2, (kDurataDelRiavvolgimento * istantiAlSecondo).ceil());
    final lstAdesso = Celestial.localSiderealDegrees(jdAdesso, lonAdesso);
    final lstNascita = Celestial.localSiderealDegrees(traguardo, lonNascita);
    final giriTotali = _norm(lstAdesso - lstNascita) + 360.0 * kGiriDelCielo;
    final faseAdesso = angoloDiFase(jdAdesso);
    final faseNascita = angoloDiFase(traguardo);
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
        istanti.add(traguardo);
        continue;
      }
      final data = traguardo + (jdAdesso - traguardo) * anniRimasti(s);
      final lstVoluto = lstNascita + giriTotali * giriRimasti(s);
      final faseVoluta = faseNascita + fasiTotali * anniRimasti(s);
      istanti.add(_istanteVicino(data, lstVoluto, faseVoluta, lo, traguardo));
    }
    for (var j = 1; j < ultimo.length; j++) {
      istanti.add(ultimo[j]);
      lat.add(latNascita);
      lon.add(lonNascita);
    }
    return PianoDelRiavvolgimento._(istanti, lat, lon,
        fineDellaCorsa: n - 1,
        durataDellaCorsa: kDurataDelRiavvolgimento,
        durataDelRallentamento: durataDelRallentamento);
  }

  /// Fra i giorni attorno a [data], il momento col tempo siderale
  /// [lstVoluto] e la fase della Luna piu' vicina a [faseVoluta].
  ///
  /// **Mai prima del traguardo della corsa**, che dall'ordine FH e' l'inizio
  /// dell'ultimo anno: prima era la nascita. Un'ipotesi della prima stesura diceva che
  /// questo confine costasse precisione a ridosso della fine (la fase
  /// sbagliava fino a 93 gradi); misurata, e' caduta: con e senza confine lo
  /// scarto era lo stesso, e la causa vera era [angoloDiFase] ripiegato in
  /// due. Il confine resta, e non costa niente.
  ///
  /// **La fase si stima e poi si calcola.** Calcolarla in tutti i trentuno
  /// candidati costava 1.850 millisecondi per piano nella prova; qui si stima
  /// e la si calcola davvero solo nei [kCandidatiCalcolati] migliori.
  ///
  /// Fino all'ordine FG la stima usava la sola velocita' della fase nel
  /// giorno della data: con tre candidati calcolati lo scarto arrivava a 17,8
  /// gradi, con cinque era 6,84. Nell'ordine FH la corsa finisce un anno
  /// prima della nascita, le date cambiano, e con cinque lo scarto e' salito a
  /// 12,1 gradi: all'istante 98 il candidato migliore (2,88 gradi) stava al
  /// bordo della finestra, dove la Luna accelera, e la stima lo metteva in
  /// fondo anche con otto calcolati. Con la stima a tratti qui sotto lo scarto
  /// peggiore e' 6,68 gradi gia' con due calcolati; se ne tengono tre, 570
  /// millisecondi per il piano intero coi due tempi.
  static double _istanteVicino(double data, double lstVoluto, double faseVoluta,
      double lon, double nascita) {
    // La velocita' del tempo siderale si misura, non si scrive: le costanti
    // del cielo vivono nella porta di Meeus.
    final lst0 = Celestial.localSiderealDegrees(data, lon);
    final lst1 = Celestial.localSiderealDegrees(data + 0.25, lon);
    // In un quarto di giorno il tempo siderale avanza di circa novanta gradi.
    final gradiAlGiorno = _norm(lst1 - lst0) * 4;
    final giornoSiderale = 360 / gradiAlGiorno;
    final base = data + _norm(lstVoluto - lst0) / gradiAlGiorno;
    // LA STIMA A TRATTI (ordine FH parte 8): la fase esatta nei nodi della
    // finestra, dispiegata (cresce sempre, meno di un giro fra due nodi), e in
    // mezzo la retta fra i due nodi accanto. La stima con la sola velocita'
    // del giorno di mezzo sbagliava di decine di gradi ai bordi, dove la
    // Luna accelera o rallenta, e lasciava fuori il candidato migliore.
    const f = kGiorniDellaFinestra, m = kGiorniDellaFinestra ~/ 2;
    const nodi = [-f, -m, 0, m, f];
    final fasiDeiNodi = <double>[];
    for (final j in nodi) {
      final v = angoloDiFase(base + j * giornoSiderale);
      fasiDeiNodi.add(fasiDeiNodi.isEmpty
          ? v
          : fasiDeiNodi.last + _norm(v - fasiDeiNodi.last));
    }
    final stime = <(double, double)>[];
    for (var j = -kGiorniDellaFinestra; j <= kGiorniDellaFinestra; j++) {
      final t = base + j * giornoSiderale;
      // Mai prima della nascita: il riavvolgimento si ferma li'.
      if (t < nascita) continue;
      var n = 0;
      while (n < nodi.length - 2 && j > nodi[n + 1]) {
        n++;
      }
      final stimata = fasiDeiNodi[n] +
          (fasiDeiNodi[n + 1] - fasiDeiNodi[n]) *
              (j - nodi[n]) /
              (nodi[n + 1] - nodi[n]);
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
