import 'aspetti_di_oggi.dart';
import 'celestial.dart';
import 'eclissi.dart';
import 'effemeridi.dart';
import 'moon_phase.dart';
import 'natal_chart.dart';
import 'night_sky.dart';
import 'transiti_del_giorno.dart';
import 'zodiac.dart';

/// **IL CIELO DI QUALUNQUE GIORNO, PER IL MAESTRO.** Ordine EV voce 03, il
/// fondatore: *"Medora in chat deve sapere qual è la situazione astrale oggi
/// e di ogni giorno di qualunque mese e anno"*.
///
/// Sulle catture dei fondatori Medora rispondeva *"Non ho tra le mie note che
/// Urano sia retrogrado oggi"*, il giorno in cui Urano era retrogrado a 5
/// gradi dei Gemelli e l'Oroscopo lo diceva. Due ragioni, tutte e due nel
/// codice: al modello arrivavano sei pianeti e la regola di non nominare
/// Urano, Nettuno e Plutone (ordine ET voce 01, quando le effemeridi non li
/// avevano), e il cielo arrivava solo a chi aveva i dati di nascita.
///
/// Qui il cielo di un giorno e di un periodo si compone dal motore delle
/// effemeridi dell'app ([Effemeridi], la stessa porta dei transiti
/// dell'Oroscopo), in una forma che il modello riceve quando lo chiede con
/// una funzione (`LeFunzioniDelCielo`): il modello non sa il cielo, lo
/// domanda, e non lo inventa.
abstract final class IlCieloPerIlMaestro {
  /// I corpi del cielo detto: i dieci delle effemeridi.
  static const List<CorpoCeleste> corpi = CorpoCeleste.values;

  /// Gli orbi degli aspetti fra i pianeti del giorno, in gradi: larghi per
  /// i luminari, stretti per gli altri, come nella tradizione (Lilly).
  static double _orbo(CorpoCeleste a, CorpoCeleste b, AspectType t) {
    final luminare = a == CorpoCeleste.sole ||
        a == CorpoCeleste.luna ||
        b == CorpoCeleste.sole ||
        b == CorpoCeleste.luna;
    final base = t == AspectType.sextile ? 4.0 : 6.0;
    return luminare ? base + 2 : base;
  }

  static String _segno(double longitudine) =>
      Zodiac.values[(longitudine / 30).floor() % 12].italianName;

  static int _gradi(double longitudine) => (longitudine % 30).floor();

  static String _data(DateTime g) =>
      '${g.year.toString().padLeft(4, '0')}-'
      '${g.month.toString().padLeft(2, '0')}-'
      '${g.day.toString().padLeft(2, '0')}';

  /// Il nome di un punto della carta natale dal suo identificativo.
  static String _puntoNatale(String id) {
    if (id == AspettiDiOggi.idAscendente) return 'Ascendente';
    if (id == AspettiDiOggi.idMedioCielo) return 'Medio Cielo';
    for (final c in CorpoCeleste.values) {
      if (c.id == id) return c.nome;
    }
    return id;
  }

  /// **IL CIELO DI UN GIORNO.** Le posizioni dei dieci corpi nel segno e al
  /// grado, i retrogradi, la Luna col suo segno e la sua fase, gli aspetti
  /// fra i pianeti del giorno, l'eclissi se cade quel giorno e, con la carta
  /// natale, i transiti sulla carta. Il cielo si fotografa alle 12 UTC del
  /// giorno civile, come quello dei transiti dell'Oroscopo.
  static Map<String, Object?> delGiorno(DateTime giorno, {NatalChart? carta}) {
    final civile = DateTime(giorno.year, giorno.month, giorno.day);
    final jd = TransitiDelGiorno.giornoGiulianoDi(civile);
    final istante = TransitiDelGiorno.istanteDi(civile);
    final posizioni = Effemeridi.tutte(jd);
    final pianeti = <Map<String, Object?>>[
      for (final c in corpi)
        {
          'corpo': c.nome,
          'segno': _segno(posizioni[c]!),
          'gradi': _gradi(posizioni[c]!),
          if (c != CorpoCeleste.sole && c != CorpoCeleste.luna)
            'retrogrado': Effemeridi.retrogrado(c, jd),
        },
    ];
    final aspetti = <String>[];
    for (var i = 0; i < corpi.length; i++) {
      for (var j = i + 1; j < corpi.length; j++) {
        final a = corpi[i], b = corpi[j];
        for (final t in AspectType.values) {
          final asp = ChartAspect(
              aLongitude: posizioni[a]!, bLongitude: posizioni[b]!, type: t);
          final orbo = (asp.separazione - t.angoloEsatto).abs();
          if (orbo <= _orbo(a, b, t)) {
            aspetti.add('${a.nome} ${t.italianName.toLowerCase()} ${b.nome} '
                '(orbo ${orbo.toStringAsFixed(0)} gradi)');
          }
        }
      }
    }
    final fase = MoonPhase.forDate(istante);
    final eclissi = MotoreDelleEclissi.nelGiornoDi(civile);
    final transiti = carta == null
        ? const <ChartAspect>[]
        : AspettiDiOggi.fra(transiti: posizioni, carta: carta);
    return {
      'data': _data(civile),
      // **IL CIELO DEL GIORNO NON E' QUELLO DI NASCITA**, ordine EV voce 03:
      // sul banco del 1 ottobre Medora ha dato due volte alla "tua Luna in
      // Bilancia", la Luna di nascita, il segno o gli aspetti della Luna del
      // giorno, che era nei Gemelli.
      'nota': 'Sono i corpi del cielo di questo giorno, non quelli di '
          'nascita della persona: la Luna di questo giorno non è la sua Luna '
          'di nascita. I suoi aspetti non sono aspetti della sua Luna.',
      'pianeti': pianeti,
      'luna': {
        'segno': NightSky.moonSign(istante).italianName,
        'fase': fase.italianName,
        'illuminata_per_cento': (fase.illumination * 100).round(),
      },
      'retrogradi': [
        for (final p in pianeti)
          if (p['retrogrado'] == true) p['corpo'],
      ],
      'aspetti_fra_i_pianeti': aspetti,
      if (eclissi != null) 'eclissi': eclissi.specie.nome,
      if (carta != null)
        'transiti_sulla_carta_natale': [
          for (final t in transiti)
            '${_puntoNatale(t.aId ?? '')} di oggi '
                '${t.type.italianName.toLowerCase()} '
                '${_puntoNatale(t.bId ?? '')} di nascita',
        ],
      'precisione': Effemeridi.dentroEpocaVerificata(civile)
          ? 'calcolato dalle effemeridi dell\'app, verificate contro il JPL '
              'entro un decimo di grado'
          : 'calcolato dalle effemeridi dell\'app, fuori dagli anni '
              '${Effemeridi.primoAnnoVerificato}-'
              '${Effemeridi.ultimoAnnoVerificato} in cui sono verificate: '
              'i segni restano giusti, i gradi possono sbagliare di poco',
    };
  }

  /// Quanti giorni al massimo copre un periodo: un anno e un mese.
  static const int giorniMassimi = 400;

  /// **IL CIELO DI UN PERIODO**: un mese, un anno, un intervallo. Le
  /// posizioni al primo giorno e, giorno per giorno, gli eventi: i pianeti
  /// che cambiano segno, quelli che diventano retrogradi o tornano diretti,
  /// le lune nuove e piene, le eclissi. La Luna che cambia segno ogni due
  /// giorni e mezzo non si elenca: sarebbe rumore.
  static Map<String, Object?> delPeriodo(DateTime dal, DateTime al) {
    var inizio = DateTime(dal.year, dal.month, dal.day);
    var fine = DateTime(al.year, al.month, al.day);
    if (fine.isBefore(inizio)) (inizio, fine) = (fine, inizio);
    final giorni = fine.difference(inizio).inDays.clamp(0, giorniMassimi);
    fine = DateTime(inizio.year, inizio.month, inizio.day + giorni);
    final eventi = <String>[];
    var ieri = _stato(inizio);
    for (var i = 1; i <= giorni; i++) {
      final g = DateTime(inizio.year, inizio.month, inizio.day + i);
      final oggi = _stato(g);
      for (final c in corpi) {
        if (c == CorpoCeleste.luna) continue;
        if (oggi.segni[c] != ieri.segni[c]) {
          eventi.add('${_data(g)}: ${c.nome} entra in ${oggi.segni[c]}');
        }
        if (oggi.retrogradi[c] != ieri.retrogradi[c]) {
          eventi.add('${_data(g)}: ${c.nome} '
              '${oggi.retrogradi[c]! ? 'diventa retrogrado' : 'torna diretto'}');
        }
      }
      if (oggi.fase != ieri.fase &&
          (oggi.fase == 'Luna nuova' || oggi.fase == 'Luna piena')) {
        eventi.add('${_data(g)}: ${oggi.fase} in ${oggi.segnoDellaLuna}');
      }
      final e = MotoreDelleEclissi.nelGiornoDi(g);
      if (e != null && e.giorno.day == g.day && e.giorno.month == g.month) {
        eventi.add('${_data(g)}: ${e.specie.nome}');
      }
      ieri = oggi;
    }
    return {
      'dal': _data(inizio),
      'al': _data(fine),
      'cielo_al_primo_giorno': delGiorno(inizio),
      'eventi': eventi,
      // Le eclissi anche in un elenco loro, col conto: sul banco del 1
      // ottobre 2026 Medora ha detto "tre eclissi" nel 2027 elencandone tre
      // delle quattro che gli eventi portavano.
      'eclissi': [
        for (final e in eventi)
          if (e.contains('eclissi')) e,
      ],
      'quante_eclissi': eventi.where((e) => e.contains('eclissi')).length,
    };
  }

  static _StatoDelGiorno _stato(DateTime g) {
    final jd = TransitiDelGiorno.giornoGiulianoDi(g);
    final pos = Effemeridi.tutte(jd);
    final istante = TransitiDelGiorno.istanteDi(g);
    return _StatoDelGiorno(
      segni: {for (final c in corpi) c: _segno(pos[c]!)},
      retrogradi: {
        for (final c in corpi)
          c: c != CorpoCeleste.sole &&
              c != CorpoCeleste.luna &&
              Effemeridi.retrogrado(c, jd),
      },
      fase: MoonPhase.forDate(istante).italianName,
      segnoDellaLuna: NightSky.moonSign(istante).italianName,
    );
  }

  /// **IL CIELO DI OGGI IN RIGHE**, per chi lo mette nell'istruzione: le
  /// stesse cose di [delGiorno], dette in una riga per pianeta.
  static String oggiInRighe(DateTime adesso, {NatalChart? carta}) {
    final g = delGiorno(adesso, carta: carta);
    final pianeti = [
      for (final p in (g['pianeti']! as List).cast<Map<String, Object?>>())
        '${p['corpo']} a ${p['gradi']} gradi in ${p['segno']}'
            '${p['retrogrado'] == true ? ', retrogrado' : ''}',
    ];
    final luna = g['luna']! as Map<String, Object?>;
    final transiti = (g['transiti_sulla_carta_natale'] as List?) ?? const [];
    return [
      'IL CIELO DI OGGI (${g['data']}), calcolato dalle effemeridi '
          'dell\'app: ${pianeti.join('; ')}.',
      'La Luna è in ${luna['segno']}, ${luna['fase']}.',
      if ((g['aspetti_fra_i_pianeti']! as List).isNotEmpty)
        'Aspetti fra i pianeti di oggi: '
            '${(g['aspetti_fra_i_pianeti']! as List).join('; ')}.',
      if (transiti.isNotEmpty)
        'Transiti di oggi sulla carta della persona: '
            '${transiti.join('; ')}.',
    ].join('\n');
  }

  /// Usato dalle prove: il giorno giuliano del cielo detto.
  static double giornoGiulianoDi(DateTime g) => Celestial.julianDay(
      TransitiDelGiorno.istanteDi(DateTime(g.year, g.month, g.day)));
}

class _StatoDelGiorno {
  const _StatoDelGiorno({
    required this.segni,
    required this.retrogradi,
    required this.fase,
    required this.segnoDellaLuna,
  });

  final Map<CorpoCeleste, String> segni;
  final Map<CorpoCeleste, bool> retrogradi;
  final String fase;
  final String segnoDellaLuna;
}
