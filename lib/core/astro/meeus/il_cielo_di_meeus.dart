import 'dart:math' as math;

import 'corpo_celeste.dart';
import 'i_pianeti_di_meeus.dart';
import 'la_luna_intera.dart';

export 'corpo_celeste.dart';

/// Una domanda al cielo fuori dall'intervallo verificato: la chiamata non
/// gira. Ordine FD voce 02.2.
class FuoriDalCieloVerificato implements Exception {
  const FuoriDalCieloVerificato(this.cosa, this.jdUt);

  final String cosa;
  final double jdUt;

  @override
  String toString() => 'FuoriDalCieloVerificato: $cosa al giorno giuliano '
      '$jdUt, fuori da ${IlCieloDiMeeus.primoGiornoVerificato}-'
      '${IlCieloDiMeeus.ultimoGiornoVerificato} (dal 31 dicembre 1899 al 1 gennaio 2101 alle 12 UT)';
}

/// IL CIELO DI MEEUS, LA PORTA SOLA. Ordine FD voce 02.
///
/// **Il difetto, misurato.** Prima di quest'ordine in `lib` convivevano sei
/// fonti della posizione di un corpo: `Effemeridi` (elementi medi, verificata
/// dal 2020 al 2030 e usata anche per le nascite), `IlSoleDiNascita` (Meeus
/// cap. 25 a bassa precisione), `LaLunaIntera`, `IlCieloDelJpl` (polinomi
/// sul DE421 per quattro corpi), il Sole NOAA scritto due volte dentro
/// `SunsetTime`, piu' tre tempi siderali, cinque obliquita' e due Delta T.
/// La Luna del confronto del cielo veniva da `Effemeridi`.
///
/// **Adesso.** Ogni posizione nel cielo passa da qui, e qui si calcola con
/// Meeus, *Astronomical Algorithms*, 2a ed. 1998:
/// - Sole e pianeti: [IPianetiDiMeeus] (cap. 25, 32, 33, 37, 21);
/// - Luna: [LaLunaIntera] (cap. 47 completo, longitudine e latitudine);
/// - tempo: giorno giuliano (cap. 7), Delta T (Espenak e Meeus 2006);
/// - nutazione e obliquita' (cap. 22), tempo siderale (cap. 12),
///   Ascendente e Medio Cielo (cap. 13 e 14).
///
/// **L'intervallo verificato e' dichiarato, e fuori la chiamata non gira**
/// (lancia [FuoriDalCieloVerificato]): dal 31 dicembre 1899 al 31
/// dicembre 2099, misurato contro il JPL DE440s su sessanta istanti
/// (`docs/collaudo/FD/riferimenti_del_cielo.csv`, prova
/// `il_cielo_di_meeus_contro_il_jpl_test.dart`).
///
/// **Tutto entra in tempo universale**: la conversione al tempo dinamico col
/// Delta T avviene qui e in nessun altro posto.
abstract final class IlCieloDiMeeus {
  static const double _g = math.pi / 180.0;

  /// Il primo giorno giuliano verificato, 1899-12-31 0h UT: il 1 gennaio
  /// 1900 dei selettori della data, nell'ora di Roma, cade ancora li'.
  static const double primoGiornoVerificato = 2415019.5;

  /// Il giorno giuliano dopo l'ultimo verificato, 2101-01-01 12h UT.
  ///
  /// Fino all'aggiunta della Macchina del tempo all'ordine FH (10 ottobre
  /// 2026) era 2100-01-01 0h UT. La Macchina arriva al 31 dicembre 2100
  /// compreso, con l'ora di nascita ereditata: a ovest di Greenwich quel
  /// giorno cade gia' nel 2101 in tempo universale, fino a dodici ore. La
  /// finestra si e' allungata solo dopo la misura: dodici istanti nuovi fra
  /// il 1 gennaio 2100 e questo, contro il JPL DE440s
  /// (`tool/riferimenti_del_cielo_jpl.py`), dentro gli stessi scarti
  /// dichiarati in [scartoMisurato].
  static const double ultimoGiornoVerificato = 2488435.0;

  /// Il primo istante verificato.
  static final DateTime primoIstanteVerificato = DateTime.utc(1899, 12, 31);

  /// L'istante dopo l'ultimo verificato.
  static final DateTime ultimoIstanteVerificato = DateTime.utc(2101, 1, 1, 12);

  /// Se il giorno giuliano [jdUt] sta dentro l'intervallo verificato.
  static bool verificato(double jdUt) =>
      jdUt >= primoGiornoVerificato && jdUt < ultimoGiornoVerificato;

  /// Se l'istante sta dentro l'intervallo verificato.
  static bool istanteVerificato(DateTime istante) =>
      verificato(giornoGiuliano(istante));

  static void _pretendi(String cosa, double jdUt) {
    if (!verificato(jdUt)) throw FuoriDalCieloVerificato(cosa, jdUt);
  }

  static double _norm(double gradi) {
    final r = gradi % 360.0;
    return r < 0 ? r + 360.0 : r;
  }

  // ---------------------------------------------------------------------
  // IL TEMPO
  // ---------------------------------------------------------------------

  /// Il giorno giuliano di un istante, in tempo universale (Meeus cap. 7).
  static double giornoGiuliano(DateTime istante) =>
      LaLunaIntera.giornoGiuliano(istante);

  /// L'istante di un giorno giuliano in tempo universale.
  static DateTime istanteDi(double jdUt) => DateTime.fromMicrosecondsSinceEpoch(
      ((jdUt - 2440587.5) * 86400000000.0).round(),
      isUtc: true);

  /// Il giorno giuliano delle effemeridi (tempo dinamico) da quello in tempo
  /// universale, col Delta T di Espenak e Meeus.
  static double effemeridi(double jdUt) {
    final anno = 2000.0 + (jdUt - 2451545.0) / 365.25;
    return jdUt + LaLunaIntera.deltaT(anno) / 86400.0;
  }

  // ---------------------------------------------------------------------
  // LE POSIZIONI
  // ---------------------------------------------------------------------

  /// Longitudine eclittica geocentrica apparente di [corpo], in gradi
  /// [0, 360), all'equinozio vero della data (zodiaco tropicale), al giorno
  /// giuliano [jdUt] in tempo universale.
  static double longitudine(CorpoCeleste corpo, double jdUt) {
    _pretendi('la longitudine di ${corpo.nome}', jdUt);
    return switch (corpo) {
      CorpoCeleste.sole => IPianetiDiMeeus.sole(effemeridi(jdUt)),
      CorpoCeleste.luna => LaLunaIntera.longitudine(jdUt),
      _ => IPianetiDiMeeus.longitudine(corpo.name, effemeridi(jdUt)),
    };
  }

  /// La stessa longitudine, per un istante.
  static double longitudineAllIstante(CorpoCeleste corpo, DateTime istante) =>
      longitudine(corpo, giornoGiuliano(istante));

  /// Latitudine eclittica geocentrica della Luna, in gradi (Meeus 47.B).
  static double latitudineDellaLuna(double jdUt) {
    _pretendi('la latitudine della Luna', jdUt);
    return LaLunaIntera.latitudine(jdUt);
  }

  /// Latitudine eclittica geocentrica di [corpo], in gradi, al giorno
  /// giuliano [jdUt] in tempo universale. Per il Sole e' zero (la beta del
  /// Sole resta sotto il secondo d'arco), per la Luna e' Meeus 47.B, per i
  /// pianeti la beta del VSOP87D col tempo di luce. Ordine FG parte 2: serve
  /// a disegnare i pianeti dove sono e non sull'eclittica.
  static double latitudine(CorpoCeleste corpo, double jdUt) {
    _pretendi('la latitudine di ${corpo.nome}', jdUt);
    return switch (corpo) {
      CorpoCeleste.sole => 0.0,
      CorpoCeleste.luna => LaLunaIntera.latitudine(jdUt),
      _ => IPianetiDiMeeus.latitudine(corpo.name, effemeridi(jdUt)),
    };
  }

  /// Tutti i corpi a un istante, nell'ordine dell'enum.
  static Map<CorpoCeleste, double> tutte(double jdUt) => {
        for (final c in CorpoCeleste.values) c: longitudine(c, jdUt),
      };

  /// Di quanti gradi al giorno si muove un corpo, col segno. Negativo vuol
  /// dire retrogrado.
  static double velocitaGiornaliera(CorpoCeleste corpo, double jdUt) {
    var delta = longitudine(corpo, jdUt + 0.5) - longitudine(corpo, jdUt - 0.5);
    // Il salto da 359 a 1 grado non e' un moto di meno 358 gradi.
    if (delta > 180.0) delta -= 360.0;
    if (delta < -180.0) delta += 360.0;
    return delta;
  }

  /// Vero se il corpo e' retrogrado. Il Sole e la Luna non lo sono mai.
  static bool retrogrado(CorpoCeleste corpo, double jdUt) =>
      velocitaGiornaliera(corpo, jdUt) < 0;

  /// LO SCARTO MASSIMO MISURATO contro il JPL DE440s, in gradi, sui sessanta
  /// istanti fra il 31 dicembre 1899 e il 31 dicembre 2099 (5 ottobre 2026,
  /// col Delta T anno per anno). Misurati, in secondi d'arco: Sole 0,3, Luna
  /// 11,0, Mercurio 0,5, Venere 1,0, Marte 2,5, Giove 1,1, Saturno 1,0, Urano
  /// 2,5, Nettuno 2,7, Plutone 3,3. Qui arrotondati per eccesso al decimillesimo
  /// di grado sopra; la prova `il_cielo_di_meeus_contro_il_jpl_test.dart`
  /// pretende che lo scarto vero non lo superi.
  static const Map<CorpoCeleste, double> scartoMisurato = {
    CorpoCeleste.sole: 0.0001,
    CorpoCeleste.luna: 0.0035,
    CorpoCeleste.mercurio: 0.0002,
    CorpoCeleste.venere: 0.0003,
    CorpoCeleste.marte: 0.0008,
    CorpoCeleste.giove: 0.0004,
    CorpoCeleste.saturno: 0.0003,
    CorpoCeleste.urano: 0.0008,
    CorpoCeleste.nettuno: 0.0008,
    CorpoCeleste.plutone: 0.0010,
  };

  /// DI QUANTI GIORNI E' INCERTO il momento esatto di un transito: lo scarto
  /// misurato diviso per la velocita'.
  static double giorniDiIncertezza(CorpoCeleste corpo, double jdUt) {
    final velocita = velocitaGiornaliera(corpo, jdUt).abs();
    if (velocita < 1e-9) return double.infinity;
    return scartoMisurato[corpo]! / velocita;
  }

  // ---------------------------------------------------------------------
  // NUTAZIONE, OBLIQUITA', TEMPO SIDERALE
  // ---------------------------------------------------------------------

  /// La nutazione in longitudine, in gradi (Meeus 22.A completa).
  static double nutazioneInLongitudine(double jdUt) =>
      LaLunaIntera.nutazioneInLongitudine(effemeridi(jdUt));

  /// L'obliquita' vera dell'eclittica, in gradi: la media di Meeus 22.2 piu'
  /// la nutazione in obliquita' coi quattro termini maggiori (22.A, precisa
  /// al decimo di secondo d'arco).
  static double obliquitaVera(double jdUt) {
    final t = (effemeridi(jdUt) - 2451545.0) / 36525.0;
    final media = 23.4392911 -
        (46.8150 * t + 0.00059 * t * t - 0.001813 * t * t * t) / 3600.0;
    final omega = (125.04452 - 1934.136261 * t) * _g;
    final lSole = (280.4665 + 36000.7698 * t) * _g;
    final lLuna = (218.3165 + 481267.8813 * t) * _g;
    final deps = (9.20 * math.cos(omega) +
            0.57 * math.cos(2 * lSole) +
            0.10 * math.cos(2 * lLuna) -
            0.09 * math.cos(2 * omega)) /
        3600.0;
    return media + deps;
  }

  /// Il tempo siderale apparente di Greenwich, in gradi (Meeus 12.4 con
  /// l'equazione degli equinozi).
  static double tempoSiderale(double jdUt) {
    final t = (jdUt - 2451545.0) / 36525.0;
    final medio = 280.46061837 +
        360.98564736629 * (jdUt - 2451545.0) +
        0.000387933 * t * t -
        t * t * t / 38710000.0;
    return _norm(medio +
        nutazioneInLongitudine(jdUt) * math.cos(obliquitaVera(jdUt) * _g));
  }

  /// Il tempo siderale apparente locale, per la longitudine [lonEst] in
  /// gradi verso est.
  static double tempoSideraleLocale(double jdUt, double lonEst) =>
      _norm(tempoSiderale(jdUt) + lonEst);

  /// Ascensione retta e declinazione, in gradi, di un punto dell'eclittica
  /// della data (Meeus 13.3 e 13.4) con l'obliquita' vera.
  static ({double ascensioneRetta, double declinazione}) equatoriali(
      double longitudine, double latitudine, double jdUt) {
    final eps = obliquitaVera(jdUt) * _g;
    final l = longitudine * _g, b = latitudine * _g;
    final dec = math.asin((math.sin(b) * math.cos(eps) +
            math.cos(b) * math.sin(eps) * math.sin(l))
        .clamp(-1.0, 1.0));
    final ra = math.atan2(
        math.sin(l) * math.cos(eps) - math.tan(b) * math.sin(eps), math.cos(l));
    return (ascensioneRetta: _norm(ra / _g), declinazione: dec / _g);
  }

  /// L'ASCENDENTE, in gradi, per il luogo a latitudine [lat] e longitudine
  /// [lonEst] (Meeus cap. 14): il punto dell'eclittica che sorge a est.
  static double ascendente(double jdUt, double lat, double lonEst) {
    _pretendi('l\'Ascendente', jdUt);
    final ramc = tempoSideraleLocale(jdUt, lonEst) * _g;
    final eps = obliquitaVera(jdUt) * _g;
    final phi = lat * _g;
    final asc = math.atan2(math.cos(ramc),
            -math.sin(ramc) * math.cos(eps) - math.tan(phi) * math.sin(eps)) /
        _g;
    return _norm(asc);
  }

  /// IL MEDIO CIELO, in gradi, per la longitudine [lonEst].
  static double medioCielo(double jdUt, double lonEst) {
    _pretendi('il Medio Cielo', jdUt);
    final ramc = tempoSideraleLocale(jdUt, lonEst) * _g;
    final eps = obliquitaVera(jdUt) * _g;
    return _norm(
        math.atan2(math.sin(ramc), math.cos(ramc) * math.cos(eps)) / _g);
  }

  // ---------------------------------------------------------------------
  // LO ZODIACO SIDERALE
  // ---------------------------------------------------------------------

  /// L'ayanamsa di Lahiri media, in gradi, per [t] secoli da J2000 in tempo
  /// dinamico. Interpolata sulla Swiss Ephemeris 2.10.03 (SE_SIDM_LAHIRI, 23
  /// gradi 15 primi 0,658 secondi al 21 marzo 1956): scarto sotto un
  /// millesimo di secondo d'arco fra il 1900 e il 2100.
  static double ayanamsaMedia(double t) =>
      23.8570923260 + 1.3968879401 * t + 0.0003070962 * t * t;

  /// La longitudine siderale (Lahiri) di [corpo], in gradi [0, 360). La
  /// longitudine e' apparente, quindi si toglie l'ayanamsa vera: la media
  /// piu' la nutazione in longitudine. Una definizione sola, ordine FD voce
  /// 02: prima ce n'erano due, e quella dei pianeti toglieva la sola media.
  static double siderale(CorpoCeleste corpo, double jdUt) {
    final t = (effemeridi(jdUt) - 2451545.0) / 36525.0;
    final vera = ayanamsaMedia(t) + nutazioneInLongitudine(jdUt);
    return _norm(longitudine(corpo, jdUt) - vera);
  }
}
