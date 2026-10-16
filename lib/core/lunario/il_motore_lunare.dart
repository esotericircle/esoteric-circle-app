import 'dart:math' as math;

import '../astro/il_segno_del_cielo.dart';
import '../astro/meeus/il_cielo_di_meeus.dart';
import '../astro/zodiac.dart';
import 'il_giorno_lunare.dart';

/// **IL MOTORE LUNARE, IN UN PUNTO SOLO.** Ordine FV voce FV.04, 15 ottobre
/// 2026 (Master V13 sezioni 41 e 43; Briefing Progetto V13 sezione 38).
///
/// Per ogni giorno, nell'ora locale del telefono (il `DateTime` locale di
/// Dart): fase ed elongazione, segno della Luna e ingressi, Luna fuori corso,
/// giorno lunare, tipo biodinamico. Le posizioni vengono tutte da
/// `IlCieloDiMeeus`, nessun secondo motore. Il Respiro della Luna, quando
/// sara' costruito, chiedera' a questo file.
///
/// **LE CONVENZIONI, dichiarate una per una.**
///
/// - **Elongazione, segno, fase, illuminazione, tipo biodinamico**: a
///   mezzogiorno locale del giorno (ordine FV, FV.03 e FV.04).
/// - **Ingressi nei segni**: l'istante in cui la longitudine eclittica
///   apparente della Luna (zodiaco tropicale, equinozio vero della data,
///   come tutta l'app) attraversa un multiplo di 30 gradi, cercato per
///   bisezione fino al decimo di secondo; restituito in ora locale.
/// - **Luna fuori corso** ([corpiDelFuoriCorso], [aspettiMaggiori]): dalla
///   definizione classica di William Lilly, *Christian Astrology* (1647),
///   libro I: la Luna e' "void of course" quando non perfeziona piu' alcun
///   aspetto prima di lasciare il segno. Nella forma delle effemeridi
///   moderne (la stessa di Moon Tracks, confrontata nella prova): dall'ultimo
///   aspetto tolemaico ESATTO (congiunzione, sestile, quadrato, trigono,
///   opposizione) della Luna a uno dei sette corpi della tradizione (Sole,
///   Mercurio, Venere, Marte, Giove, Saturno) perfezionato mentre la Luna sta
///   nel segno, fino al suo ingresso nel segno successivo. Urano, Nettuno e
///   Plutone non contano: Lilly non li conosceva, e su ottobre e novembre
///   2026 Moon Tracks li ignora come qui. Se nel segno la Luna non fa nessun
///   aspetto, e' fuori corso dall'ingresso al successivo.
/// - **Giorno lunare** (1..30): il giorno civile locale in cui cade la
///   congiunzione vera (Luna nuova, elongazione zero) e' il giorno 1, il
///   seguente il 2, e cosi' fino alla congiunzione successiva. E' il conto
///   della "luna prima" del computo ecclesiastico (l'eta' della Luna dei
///   lunari, "giorni della Luna": i giorni dall'ultimo novilunio,
///   https://it.wikipedia.org/wiki/Et%C3%A0_della_Luna), con la congiunzione
///   cercata dal motore e non da una tabella media. Una lunazione dura al
///   piu' 29,83 giorni, quindi il conto non supera mai 30.
/// - **Luna nuova e Luna piena**: vere se l'istante esatto (elongazione 0 o
///   180 gradi) cade fra la mezzanotte locale del giorno e quella dopo.
/// - **Tipo biodinamico**: vedi [confiniDelleCostellazioni].
abstract final class IlMotoreLunare {
  // ---------------------------------------------------------------------
  // LE SCELTE DICHIARATE
  // ---------------------------------------------------------------------

  /// I corpi della Luna fuori corso: i sette della tradizione meno la Luna.
  static const List<CorpoCeleste> corpiDelFuoriCorso = [
    CorpoCeleste.sole,
    CorpoCeleste.mercurio,
    CorpoCeleste.venere,
    CorpoCeleste.marte,
    CorpoCeleste.giove,
    CorpoCeleste.saturno,
  ];

  /// Gli aspetti maggiori tolemaici, come differenza di longitudine Luna
  /// meno corpo in gradi (sestile, quadrato e trigono da tutti e due i lati).
  static const List<double> aspettiMaggiori = [
    0, 60, 90, 120, 180, 240, 270, 300, //
  ];

  /// **I CONFINI DELLE COSTELLAZIONI ZODIACALI SULL'ECLITTICA**, per il
  /// calendario biodinamico.
  ///
  /// Il metodo di Maria Thun (il calendario *Aussaattage*; Bross-Burkhardt,
  /// "Saatkalender und Mondkalender, kritisch betrachtet", 2011) lega il
  /// giorno alla costellazione VERA davanti a cui passa la Luna, di
  /// grandezza diseguale: radice nelle costellazioni di terra (Toro, Vergine,
  /// Capricorno), foglia in quelle d'acqua (Cancro, Scorpione, Pesci), fiore
  /// in quelle d'aria (Gemelli, Bilancia, Acquario), frutto in quelle di fuoco
  /// (Ariete, Leone, Sagittario). Thun dichiara di usare "dati astronomici"
  /// (lo stesso documento, nota 14) ma i suoi gradi esatti non sono
  /// pubblicati in una fonte che si possa citare: qui si usano i confini
  /// ufficiali delle costellazioni, quelli della IAU (Delporte, *Delimitation
  /// scientifique des constellations*, 1930, in coordinate B1875), nella
  /// tabella di Roman (1987, PASP 99, 695, VizieR VI/42), intersecati con
  /// l'eclittica media J2000 (latitudine zero) da
  /// `tool/lunario_confini_delle_costellazioni.py` (astropy
  /// `get_constellation`, passo di un millesimo di grado; uscita in
  /// `docs/collaudo/FV/fv04_confini_delle_costellazioni.txt`).
  ///
  /// La Luna si riporta allo stesso riferimento con
  /// `IlCieloDiMeeus.longitudineJ2000` (nutazione tolta, precessione
  /// rigorosa di Meeus 21.7): la sua latitudine non conta, la si proietta
  /// sull'eclittica come i confini.
  ///
  /// **L'OFIUCO.** L'eclittica attraversa l'Ofiuco (da 247,643 a 266,244
  /// gradi J2000), che nei dodici del metodo non c'e'. Nessuna fonte
  /// verificabile dice se Thun lo conti nello Scorpione o nel Sagittario:
  /// li' il tipo NON si mostra (nullo), come vuole l'ordine per un confine
  /// che non si documenta.
  static const List<({double da, String iau, Zodiac? segno})>
      confiniDelleCostellazioni = [
    (da: 28.686, iau: 'Ari', segno: Zodiac.aries),
    (da: 53.413, iau: 'Tau', segno: Zodiac.taurus),
    (da: 90.133, iau: 'Gem', segno: Zodiac.gemini),
    (da: 117.981, iau: 'Cnc', segno: Zodiac.cancer),
    (da: 138.034, iau: 'Leo', segno: Zodiac.leo),
    (da: 173.850, iau: 'Vir', segno: Zodiac.virgo),
    (da: 217.813, iau: 'Lib', segno: Zodiac.libra),
    (da: 241.052, iau: 'Sco', segno: Zodiac.scorpio),
    (da: 247.643, iau: 'Oph', segno: null),
    (da: 266.244, iau: 'Sgr', segno: Zodiac.sagittarius),
    (da: 299.662, iau: 'Cap', segno: Zodiac.capricorn),
    (da: 327.492, iau: 'Aqr', segno: Zodiac.aquarius),
    (da: 351.651, iau: 'Psc', segno: Zodiac.pisces),
  ];

  // ---------------------------------------------------------------------
  // LE PORTE PUBBLICHE
  // ---------------------------------------------------------------------

  /// Il giorno lunare di un giorno del calendario, in ora locale.
  static GiornoLunare delGiorno(DateTime giorno) =>
      _giorni(DateTime(giorno.year, giorno.month, giorno.day), 1).single;

  /// I giorni di un mese del calendario.
  static List<GiornoLunare> delMese(int anno, int mese) =>
      _giorni(DateTime(anno, mese, 1), DateTime(anno, mese + 1, 0).day);

  /// L'elongazione della Luna dal Sole, da 0 a 360 gradi.
  static double elongazione(DateTime istante) =>
      _elongazione(IlCieloDiMeeus.giornoGiuliano(istante));

  /// La fase da un'elongazione: otto settori di 45 gradi centrati sulle
  /// quattro fasi principali.
  static FaseLunare faseDi(double elongazione) {
    final i = (((elongazione + 22.5) % 360) ~/ 45);
    return FaseLunare.values[i];
  }

  /// Gli ingressi della Luna nei segni fra [inizio] e [fine], in ora locale.
  static List<CambioDiSegno> ingressiFra(DateTime inizio, DateTime fine) => [
        for (final i in _ingressi(IlCieloDiMeeus.giornoGiuliano(inizio),
            IlCieloDiMeeus.giornoGiuliano(fine)))
          CambioDiSegno(istante: _locale(i.jd), segno: i.segno),
      ];

  /// Gli intervalli INTERI di Luna fuori corso che toccano [inizio, fine),
  /// non tagliati, in ora locale.
  static List<IntervalloFuoriCorso> fuoriCorsoFra(
          DateTime inizio, DateTime fine) =>
      [
        for (final v in _fuoriCorso(IlCieloDiMeeus.giornoGiuliano(inizio),
            IlCieloDiMeeus.giornoGiuliano(fine)))
          IntervalloFuoriCorso(inizio: _locale(v.$1), fine: _locale(v.$2)),
      ];

  /// Gli istanti esatti delle Lune nuove fra [inizio] e [fine], in ora
  /// locale.
  static List<DateTime> luneNuoveFra(DateTime inizio, DateTime fine) => [
        for (final jd in _fasiEsatte(0, IlCieloDiMeeus.giornoGiuliano(inizio),
            IlCieloDiMeeus.giornoGiuliano(fine)))
          _locale(jd),
      ];

  /// Gli istanti esatti delle Lune piene fra [inizio] e [fine], in ora
  /// locale.
  static List<DateTime> lunePieneFra(DateTime inizio, DateTime fine) => [
        for (final jd in _fasiEsatte(180, IlCieloDiMeeus.giornoGiuliano(inizio),
            IlCieloDiMeeus.giornoGiuliano(fine)))
          _locale(jd),
      ];

  /// La costellazione IAU davanti a cui sta un punto dell'eclittica, dalla
  /// longitudine eclittica J2000 [lonJ2000] in gradi.
  static ({double da, String iau, Zodiac? segno}) costellazioneDi(
      double lonJ2000) {
    final l = lonJ2000 % 360;
    var scelta = confiniDelleCostellazioni.last; // i Pesci passano lo zero
    for (final c in confiniDelleCostellazioni) {
      if (l >= c.da) scelta = c;
    }
    return scelta;
  }

  /// Il tipo biodinamico di una costellazione dello zodiaco, dal suo
  /// elemento; nullo fuori dai dodici (l'Ofiuco).
  static TipoBiodinamico? tipoDi(Zodiac? costellazione) =>
      switch (costellazione?.element) {
        ZodiacElement.earth => TipoBiodinamico.radice,
        ZodiacElement.water => TipoBiodinamico.foglia,
        ZodiacElement.air => TipoBiodinamico.fiore,
        ZodiacElement.fire => TipoBiodinamico.frutto,
        null => null,
      };

  /// Il tipo biodinamico all'istante [istante].
  static TipoBiodinamico? tipoBiodinamicoAllIstante(DateTime istante) =>
      tipoDi(costellazioneDi(IlCieloDiMeeus.longitudineJ2000(
              CorpoCeleste.luna, IlCieloDiMeeus.giornoGiuliano(istante)))
          .segno);

  // ---------------------------------------------------------------------
  // IL CALCOLO
  // ---------------------------------------------------------------------

  /// Un decimo di secondo, in giorni: la precisione delle bisezioni.
  static const double _precisione = 0.1 / 86400.0;

  static DateTime _locale(double jd) => IlCieloDiMeeus.istanteDi(jd).toLocal();

  static double _lon(CorpoCeleste c, double jd) =>
      IlCieloDiMeeus.longitudine(c, jd);

  static double _elongazione(double jd) =>
      (_lon(CorpoCeleste.luna, jd) - _lon(CorpoCeleste.sole, jd)) % 360;

  /// Lo scarto di [angolo] da [bersaglio] ricondotto fra -180 e 180.
  static double _scarto(double angolo, double bersaglio) =>
      ((angolo - bersaglio + 540) % 360) - 180;

  /// Lo zero di [f] fra [a] e [b], con f(a) < 0 <= f(b).
  static double _bisezione(double Function(double) f, double a, double b) {
    while (b - a > _precisione) {
      final m = (a + b) / 2;
      if (f(m) < 0) {
        a = m;
      } else {
        b = m;
      }
    }
    return (a + b) / 2;
  }

  static List<GiornoLunare> _giorni(DateTime primo, int quanti) {
    final mezzanotti = [
      for (var i = 0; i <= quanti; i++)
        DateTime(primo.year, primo.month, primo.day + i),
    ];
    final jd = [for (final m in mezzanotti) IlCieloDiMeeus.giornoGiuliano(m)];
    final jdA = jd.first, jdB = jd.last;
    final ingressi = _ingressi(jdA, jdB);
    final vuoti = _fuoriCorso(jdA, jdB);
    // La congiunzione che apre il primo giorno sta al piu' una lunazione
    // prima: si cerca da 31 giorni prima.
    final nuove = _fasiEsatte(0, jdA - 31, jdB);
    final piene = _fasiEsatte(180, jdA, jdB);

    final giorni = <GiornoLunare>[];
    for (var i = 0; i < quanti; i++) {
      final a = jd[i], b = jd[i + 1];
      final mezzanotte = mezzanotti[i];
      final mezzogiorno =
          DateTime(mezzanotte.year, mezzanotte.month, mezzanotte.day, 12);
      final jdM = IlCieloDiMeeus.giornoGiuliano(mezzogiorno);
      final e = _elongazione(jdM);
      final lunaLon = _lon(CorpoCeleste.luna, jdM);
      // Il giorno civile della congiunzione e' il giorno 1.
      final ultimaNuova = nuove.lastWhere((n) => n < b);
      final giornoDellaNuova = _locale(ultimaNuova);
      final primoGiorno = DateTime(
          giornoDellaNuova.year, giornoDellaNuova.month, giornoDellaNuova.day);
      final giornoLunare = _giorniCivili(primoGiorno, mezzanotte) + 1;
      giorni.add(GiornoLunare(
        giorno: mezzanotte,
        elongazione: e,
        illuminazione: (1 - math.cos(e * math.pi / 180)) / 2,
        crescente: e < 180,
        fase: faseDi(e),
        segno: IlSegnoDelCielo.dellaLongitudine(lunaLon),
        cambiDiSegno: [
          for (final x in ingressi)
            if (x.jd >= a && x.jd < b)
              CambioDiSegno(istante: _locale(x.jd), segno: x.segno),
        ],
        fuoriCorso: [
          for (final v in vuoti)
            if (v.$2 > a && v.$1 < b)
              // Il taglio usa le mezzanotti stesse e non il loro giorno
              // giuliano, che torna indietro con qualche microsecondo di
              // arrotondamento.
              IntervalloFuoriCorso(
                inizio: v.$1 <= a ? mezzanotte : _locale(v.$1),
                fine: v.$2 >= b ? mezzanotti[i + 1] : _locale(v.$2),
              ),
        ],
        giornoLunare: giornoLunare,
        tipoBiodinamico: tipoDi(costellazioneDi(
                IlCieloDiMeeus.longitudineJ2000(CorpoCeleste.luna, jdM))
            .segno),
        lunaNuova: nuove.any((n) => n >= a && n < b),
        lunaPiena: piene.any((n) => n >= a && n < b),
      ));
    }
    return giorni;
  }

  /// I giorni civili fra due mezzanotti locali, contati sul calendario e non
  /// in ore (un giorno dell'ora legale dura 23 o 25 ore).
  static int _giorniCivili(DateTime da, DateTime a) =>
      DateTime.utc(a.year, a.month, a.day)
          .difference(DateTime.utc(da.year, da.month, da.day))
          .inDays;

  /// Gli ingressi della Luna nei segni fra [jdA] e [jdB]: il segno si
  /// guarda ogni sei ore (la Luna non attraversa un segno intero in meno di
  /// due giorni), e a ogni cambio il confine si cerca per bisezione.
  static List<({double jd, Zodiac segno})> _ingressi(double jdA, double jdB) {
    const passo = 0.25;
    final risultato = <({double jd, Zodiac segno})>[];
    var t = jdA;
    var s = _lon(CorpoCeleste.luna, t) ~/ 30;
    while (t < jdB) {
      final t2 = math.min(t + passo, jdB);
      final s2 = _lon(CorpoCeleste.luna, t2) ~/ 30;
      if (s2 != s) {
        final confine = s2 * 30.0;
        final z = _bisezione(
            (x) => _scarto(_lon(CorpoCeleste.luna, x), confine), t, t2);
        risultato.add((jd: z, segno: Zodiac.values[s2 % 12]));
      }
      t = t2;
      s = s2;
    }
    return risultato;
  }

  /// Gli intervalli interi di Luna fuori corso che toccano [jdA, jdB), come
  /// coppie (inizio, fine) in giorni giuliani.
  static List<(double, double)> _fuoriCorso(double jdA, double jdB) {
    // Un segno dura al piu' 2,6 giorni: tre giorni di margine per lato
    // prendono l'ingresso che apre il primo intervallo e quello che chiude
    // l'ultimo.
    final ingressi = _ingressi(jdA - 3, jdB + 3);
    final risultato = <(double, double)>[];
    for (var i = 1; i < ingressi.length; i++) {
      final entrata = ingressi[i - 1].jd, uscita = ingressi[i].jd;
      if (uscita <= jdA) continue;
      final inizio = _ultimoAspetto(entrata, uscita) ?? entrata;
      if (inizio >= jdB) continue;
      risultato.add((inizio, uscita));
    }
    return risultato;
  }

  /// L'istante dell'ultimo aspetto maggiore esatto della Luna a uno dei
  /// [corpiDelFuoriCorso] in [entrata, uscita), o nullo se non ce n'e'.
  ///
  /// Si cammina all'indietro dall'uscita a passi di due ore: la Luna corre
  /// sempre piu' di ogni pianeta (anche retrogrado), quindi la differenza di
  /// longitudine cresce e in due ore avanza al piu' di un grado e mezzo,
  /// molto meno dei trenta che separano due aspetti. Il primo passo che
  /// contiene un aspetto contiene l'ultimo.
  static double? _ultimoAspetto(double entrata, double uscita) {
    const passo = 2 / 24;
    var t2 = uscita;
    var lunaB = _lon(CorpoCeleste.luna, t2);
    var corpiB = [for (final c in corpiDelFuoriCorso) _lon(c, t2)];
    while (t2 > entrata) {
      final t1 = math.max(t2 - passo, entrata);
      final lunaA = _lon(CorpoCeleste.luna, t1);
      final corpiA = [for (final c in corpiDelFuoriCorso) _lon(c, t1)];
      double? migliore;
      for (var k = 0; k < corpiDelFuoriCorso.length; k++) {
        final corpo = corpiDelFuoriCorso[k];
        for (final a in aspettiMaggiori) {
          final fa = _scarto(lunaA - corpiA[k], a);
          final fb = _scarto(lunaB - corpiB[k], a);
          if (fa < 0 && fb >= 0 && fb - fa < 90) {
            final z = _bisezione(
                (x) => _scarto(_lon(CorpoCeleste.luna, x) - _lon(corpo, x), a),
                t1,
                t2);
            // L'aspetto all'istante esatto dell'uscita non e' nel segno.
            if (z < uscita && (migliore == null || z > migliore)) migliore = z;
          }
        }
      }
      if (migliore != null) return migliore;
      t2 = t1;
      lunaB = lunaA;
      corpiB = corpiA;
    }
    return null;
  }

  /// Gli istanti in cui l'elongazione vale [bersaglio] fra [jdA] e [jdB]:
  /// l'elongazione si guarda ogni dodici ore (al piu' otto gradi), e a ogni
  /// passaggio l'istante si cerca per bisezione.
  static List<double> _fasiEsatte(double bersaglio, double jdA, double jdB) {
    const passo = 0.5;
    final risultato = <double>[];
    var t = jdA;
    var f = _scarto(_elongazione(t), bersaglio);
    while (t < jdB) {
      final t2 = math.min(t + passo, jdB);
      final f2 = _scarto(_elongazione(t2), bersaglio);
      if (f < 0 && f2 >= 0 && f2 - f < 90) {
        risultato
            .add(_bisezione((x) => _scarto(_elongazione(x), bersaglio), t, t2));
      }
      t = t2;
      f = f2;
    }
    return risultato;
  }
}
