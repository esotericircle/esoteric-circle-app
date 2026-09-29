import '../astro/celestial.dart';
import '../astro/eclissi.dart';
import '../astro/effemeridi.dart';
import '../astro/il_sole_di_nascita.dart';
import '../astro/la_luna_intera.dart';
import '../astro/natal_chart.dart';
import '../astro/transiti_nelle_case.dart';
import '../astro/zodiac.dart';
import 'cielo_di_oggi.dart';
import 'corrente_del_cielo.dart';
import 'horoscope.dart';
import 'il_cielo_del_segno.dart';
import 'il_livello_del_cielo.dart';
import 'l_ora_d_oro.dart';

/// Un fatto del cielo in un periodo: un ingresso o una fase della Luna.
class EventoDelCielo {
  const EventoDelCielo(
      {required this.istante, required this.testo, this.conOra = false});

  /// In tempo universale.
  final DateTime istante;
  final String testo;

  /// Se l'ora e' affidabile al minuto (le fasi della Luna, dalla Luna intera)
  /// o solo il giorno (gli ingressi, dal motore dei transiti).
  final bool conOra;
}

/// Un giorno di un dominio: il livello e da dove viene.
class GiornoDelPeriodo {
  const GiornoDelPeriodo(
      {required this.giorno, required this.livello, required this.motivo});

  final DateTime giorno;
  final int livello;
  final String motivo;
}

/// Un dominio nel periodo: i giorni, il migliore e il momento chiave.
class DominioDelPeriodo {
  const DominioDelPeriodo({
    required this.dominio,
    required this.giorni,
    required this.migliore,
    required this.momentoChiave,
  });

  final HoroscopeDomain dominio;
  final List<GiornoDelPeriodo> giorni;
  final GiornoDelPeriodo migliore;
  final String momentoChiave;
}

/// Un periodo intero: gli eventi e i quattro domini.
class IlPeriodoDelCielo {
  const IlPeriodoDelCielo({
    required this.eventi,
    required this.domini,
    required this.dallaCarta,
  });

  final List<EventoDelCielo> eventi;
  final List<DominioDelPeriodo> domini;

  /// Vero se letto sulla carta natale, falso se sul segno e sulle case
  /// solari: la schermata lo dice.
  final bool dallaCarta;
}

/// **IL SETTIMANALE: LA PREVISIONE DEI PROSSIMI SETTE GIORNI, ordine ES voce
/// 02.** E, con trenta giorni, la base del mensile (voce ES.03).
///
/// Il fondatore: *"l'oroscopo di previsione dei prossimi 7 giorni, giusto?"*,
/// e il contenuto proposto dall'Architetto, *"Si tutto ok."*. Tutto viene dal
/// motore delle effemeridi dell'app, sul telefono, senza modello:
/// - **gli eventi**: gli ingressi del Sole e dei pianeti da Mercurio a
///   Saturno nei segni (col giorno: il motore dei transiti data un ingresso
///   al giorno, non al minuto) e le fasi della Luna (col giorno e l'ora: dalla
///   Luna intera e dal Sole misurato);
/// - **una riga per giorno** e per dominio, col livello del cielo di quel
///   giorno e la sua ragione ([IlLivelloDelCielo]);
/// - **il giorno migliore** del dominio, il livello piu' alto (a parita' il
///   primo);
/// - **il momento chiave** con giorno e ora: con la carta, il primo aspetto
///   esatto favorevole della Luna al corpo natale del dominio (Sole, Venere,
///   Marte, Giove); senza carta, o se non ce n'e', la prima fase della Luna in
///   una casa del dominio, o la prima fase.
abstract final class LaSettimanaDelCielo {
  static const List<String> giorniDellaSettimana = [
    'lunedì',
    'martedì',
    'mercoledì',
    'giovedì',
    'venerdì',
    'sabato',
    'domenica',
  ];

  static const List<String> mesi = [
    'gennaio', 'febbraio', 'marzo', 'aprile', 'maggio', 'giugno', //
    'luglio', 'agosto', 'settembre', 'ottobre', 'novembre', 'dicembre',
  ];

  /// "giovedì 2 ottobre"
  static String data(DateTime g) {
    final l = g.isUtc ? g.toLocal() : g;
    return '${giorniDellaSettimana[l.weekday - 1]} ${l.day} ${mesi[l.month - 1]}';
  }

  static String ora(DateTime g) {
    final l = g.toLocal();
    return '${l.hour.toString().padLeft(2, '0')}:'
        '${l.minute.toString().padLeft(2, '0')}';
  }

  /// Il corpo natale di ogni dominio, per il momento chiave.
  static const Map<HoroscopeDomain, String> corpoNataleDi = {
    HoroscopeDomain.generale: 'sun',
    HoroscopeDomain.amore: 'venus',
    HoroscopeDomain.carriera: 'mars',
    HoroscopeDomain.fortuna: 'jupiter',
  };

  static const Map<String, String> _alCorpo = {
    'sun': 'al tuo Sole',
    'venus': 'alla tua Venere',
    'mars': 'al tuo Marte',
    'jupiter': 'al tuo Giove',
  };

  static const List<CorpoCeleste> _chiEntra = [
    CorpoCeleste.sole,
    CorpoCeleste.mercurio,
    CorpoCeleste.venere,
    CorpoCeleste.marte,
    CorpoCeleste.giove,
    CorpoCeleste.saturno,
  ];

  static const List<String> _nomiDelleFasi = [
    'Luna nuova',
    'Primo quarto',
    'Luna piena',
    'Ultimo quarto',
  ];

  static double _elongazione(DateTime utc) {
    final jd = LaLunaIntera.giornoGiuliano(utc);
    final d = (LaLunaIntera.longitudine(jd) - IlSoleDiNascita.longitudine(jd)) %
        360.0;
    return d < 0 ? d + 360 : d;
  }

  /// Le fasi principali della Luna in [da, a): (istante, indice 0-3).
  static List<(DateTime, int)> fasi(DateTime da, DateTime a) {
    final trovate = <(DateTime, int)>[];
    for (var k = 0; k < 4; k++) {
      final bersaglio = k * 90.0;
      double scarto(DateTime t) {
        var d = (_elongazione(t) - bersaglio) % 360.0;
        if (d > 180) d -= 360;
        return d;
      }

      var t0 = da;
      var s0 = scarto(t0);
      while (t0.isBefore(a)) {
        final t1 = t0.add(const Duration(hours: 6));
        final s1 = scarto(t1);
        if (s0 <= 0 && s1 > 0 && (s1 - s0) < 30) {
          var lo = t0;
          var hi = t1;
          while (hi.difference(lo).inSeconds > 30) {
            final mid = lo.add(hi.difference(lo) ~/ 2);
            if (scarto(mid) <= 0) {
              lo = mid;
            } else {
              hi = mid;
            }
          }
          final t = lo.add(hi.difference(lo) ~/ 2);
          if (!t.isBefore(da) && t.isBefore(a)) trovate.add((t, k));
        }
        t0 = t1;
        s0 = s1;
      }
    }
    trovate.sort((x, y) => x.$1.compareTo(y.$1));
    return trovate;
  }

  /// Gli ingressi nei segni in [da, a): (giorno, corpo, segno).
  static List<(DateTime, CorpoCeleste, Zodiac)> ingressi(
      DateTime da, DateTime a) {
    final trovati = <(DateTime, CorpoCeleste, Zodiac)>[];
    int segno(CorpoCeleste c, DateTime t) =>
        (Effemeridi.longitudineEclittica(c, Celestial.julianDay(t)) ~/ 30) % 12;
    for (final c in _chiEntra) {
      var t0 = da;
      var s0 = segno(c, t0);
      while (t0.isBefore(a)) {
        final t1 = t0.add(const Duration(hours: 12));
        final s1 = segno(c, t1);
        if (s1 != s0) {
          var lo = t0;
          var hi = t1;
          while (hi.difference(lo).inMinutes > 10) {
            final mid = lo.add(hi.difference(lo) ~/ 2);
            if (segno(c, mid) == s0) {
              lo = mid;
            } else {
              hi = mid;
            }
          }
          if (!hi.isBefore(da) && hi.isBefore(a)) {
            trovati.add((hi, c, Zodiac.values[s1]));
          }
        }
        t0 = t1;
        s0 = s1;
      }
    }
    trovati.sort((x, y) => x.$1.compareTo(y.$1));
    return trovati;
  }

  /// La casa (1-12) della longitudine [l]: natale con la carta, solare dal
  /// [segno] senza. Il secondo valore dice se e' natale.
  static (int, bool) _casa(double l, Zodiac segno, NatalChart? carta) {
    if (carta != null && carta.hasTime && carta.houses.length == 12) {
      final c = TransitiNelleCase.casaDi(l, carta.houses);
      if (c != null) return (c, true);
    }
    return (
      IlCieloDelSegno.casaSolare(segno, Zodiac.values[(l ~/ 30) % 12]),
      false
    );
  }

  /// Il periodo di [giorni] giorni a partire dal giorno civile di [oggi].
  static IlPeriodoDelCielo per({
    required Zodiac segno,
    required NatalChart? carta,
    required DateTime oggi,
    int giorni = 7,
  }) {
    final inizio = DateTime(oggi.year, oggi.month, oggi.day);
    final da = inizio.toUtc();
    final a = DateTime(oggi.year, oggi.month, oggi.day + giorni).toUtc();

    // Gli eventi.
    final eventi = <EventoDelCielo>[];
    final fasiDelPeriodo = fasi(da, a);
    for (final (t, k) in fasiDelPeriodo) {
      final l = LaLunaIntera.longitudine(LaLunaIntera.giornoGiuliano(t));
      final (casa, natale) = _casa(l, segno, carta);
      final dove = Zodiac.values[(l ~/ 30) % 12];
      eventi.add(EventoDelCielo(
        istante: t,
        conOra: true,
        testo: '${data(t)} alle ${ora(t)}: ${_nomiDelleFasi[k]} in '
            '${dove.italianName}, nella tua '
            '${CorrenteDelCielo.ordinaliDelleCase[casa - 1]} casa'
            '${natale ? '' : ' solare'}.',
      ));
    }
    for (final (t, c, z) in ingressi(da, a)) {
      // Un pianeta retrogrado "torna" nel segno da cui era uscito: dire
      // "entra" due volte nello stesso mese farebbe chiedere come si puo'.
      final indietro = Effemeridi.retrogrado(c, Celestial.julianDay(t));
      eventi.add(EventoDelCielo(
        istante: t,
        testo: '${data(t)}: '
            '${CorrenteDelCielo.colSuoArticolo(c, maiuscola: false)} '
            '${indietro ? 'torna' : 'entra'} in ${z.italianName}'
            '${indietro ? (c == CorpoCeleste.venere ? ', retrograda' : ', retrogrado') : ''}.',
      ));
    }
    // Le eclissi del periodo, dal motore verificato col canone (ordine CE
    // voce 16), nella casa in cui cadono.
    for (var anno = da.year; anno <= a.year; anno++) {
      for (final e in MotoreDelleEclissi.nellAnnoDi(anno)) {
        if (e.massimo.isBefore(da) || !e.massimo.isBefore(a)) continue;
        final l =
            LaLunaIntera.longitudine(LaLunaIntera.giornoGiuliano(e.massimo));
        // All'eclissi solare Luna e Sole stanno insieme; a quella lunare la
        // Luna sta dove si oscura: in tutti e due i casi il punto e' la Luna.
        final lDove = l;
        final (casa, natale) = _casa(lDove, segno, carta);
        final dove = Zodiac.values[(lDove ~/ 30) % 12];
        eventi.add(EventoDelCielo(
          istante: e.massimo,
          conOra: true,
          testo: '${data(e.massimo)} alle ${ora(e.massimo)}: '
              '${e.specie.nome} in ${dove.italianName}, nella tua '
              '${CorrenteDelCielo.ordinaliDelleCase[casa - 1]} casa'
              '${natale ? '' : ' solare'}.',
        ));
      }
    }
    eventi.sort((x, y) => x.istante.compareTo(y.istante));

    // I domini.
    final domini = <DominioDelPeriodo>[];
    final cieli = <CieloDiOggi>[];
    final mezzogiorni = <DateTime>[];
    for (var d = 0; d < giorni; d++) {
      final m = DateTime(inizio.year, inizio.month, inizio.day + d, 12).toUtc();
      mezzogiorni.add(m);
      cieli.add(CieloDiOggi.perIlGiorno(adesso: m, carta: carta));
    }
    for (final dominio in HoroscopeDomain.values) {
      final righe = <GiornoDelPeriodo>[
        for (var d = 0; d < giorni; d++)
          () {
            final (livello, motivo) = IlLivelloDelCielo.per(
                dominio: dominio,
                segno: segno,
                cielo: cieli[d],
                quando: mezzogiorni[d]);
            return GiornoDelPeriodo(
                giorno: DateTime(inizio.year, inizio.month, inizio.day + d),
                livello: livello,
                motivo: motivo);
          }(),
      ];
      var migliore = righe.first;
      for (final r in righe) {
        if (r.livello > migliore.livello) migliore = r;
      }
      domini.add(DominioDelPeriodo(
        dominio: dominio,
        giorni: righe,
        migliore: migliore,
        momentoChiave:
            _momentoChiave(dominio, segno, carta, da, a, fasiDelPeriodo),
      ));
    }
    return IlPeriodoDelCielo(
      eventi: eventi,
      domini: domini,
      dallaCarta: carta != null,
    );
  }

  static String _momentoChiave(
    HoroscopeDomain dominio,
    Zodiac segno,
    NatalChart? carta,
    DateTime da,
    DateTime a,
    List<(DateTime, int)> fasiDelPeriodo,
  ) {
    if (carta != null) {
      final id = corpoNataleDi[dominio]!;
      double? natale;
      for (final p in carta.planets) {
        if (p.id == id) natale = p.longitude;
      }
      if (natale != null) {
        for (final (nome, angoli) in const [
          ('un trigono', [120.0, 240.0]),
          ('un sestile', [60.0, 300.0]),
          ('una congiunzione', [0.0]),
        ]) {
          final istanti = <DateTime>[
            for (final ang in angoli)
              ...LOraDOro.passaggi(da, a, (natale + ang) % 360.0),
          ]..sort();
          if (istanti.isNotEmpty) {
            final t = istanti.first;
            return '${data(t)} alle ${ora(t)}: la Luna forma $nome '
                '${_alCorpo[id]} di nascita.';
          }
        }
      }
    }
    final caseDelDominio = CorrenteDelCielo.caseDi[dominio]!;
    (DateTime, int)? scelta;
    for (final f in fasiDelPeriodo) {
      final l = LaLunaIntera.longitudine(LaLunaIntera.giornoGiuliano(f.$1));
      final (casa, _) = _casa(l, segno, carta);
      if (caseDelDominio.contains(casa)) {
        scelta = f;
        break;
      }
    }
    scelta ??= fasiDelPeriodo.firstOrNull;
    if (scelta == null) {
      return 'Nessuna fase della Luna e nessun passaggio esatto in questo '
          'periodo: il cielo scorre senza un momento solo.';
    }
    // Col segno e la casa: "Ultimo quarto" da solo non dice che cosa c'entri
    // con chi legge (visto sul Realme).
    final (t, k) = scelta;
    final l = LaLunaIntera.longitudine(LaLunaIntera.giornoGiuliano(t));
    final (casa, natale) = _casa(l, segno, carta);
    final dove = Zodiac.values[(l ~/ 30) % 12];
    return '${data(t)} alle ${ora(t)}: ${_nomiDelleFasi[k]} in '
        '${dove.italianName}, nella tua '
        '${CorrenteDelCielo.ordinaliDelleCase[casa - 1]} casa'
        '${natale ? '' : ' solare'}, quella '
        '${CorrenteDelCielo.materiaDelleCase[casa - 1]}.';
  }
}
