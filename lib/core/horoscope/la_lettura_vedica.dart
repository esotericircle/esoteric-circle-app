import '../astro/il_fuso_della_nascita.dart';
import '../astro/l_alba_e_il_tramonto.dart';
import '../chat/user_profile.dart';
import 'horoscope.dart';
import 'i_segni_delle_tradizioni.dart';
import 'la_lettura_cinese.dart';
import 'oroscopo_vedico_data.dart';

/// Il luogo di oggi per l'alba, il tramonto e il Rahu Kalam.
class LuogoDelGiorno {
  const LuogoDelGiorno(
      {required this.lat, required this.lon, required this.citta});
  final double lat;
  final double lon;
  final String citta;
}

/// Come la tradizione giudica una casa o una tara.
enum EsitoVedico { favorevole, attenzione, sfavorevole, ottava }

/// **L'OROSCOPO VEDICO DEL GIORNO, ordine ES voce 09.**
///
/// Le stesse quattro schede della lettura occidentale e della cinese, dalla
/// Luna siderale (Lahiri) e dal calendario indiano, tutto sul telefono:
/// - **Generale**: la Chandra Bala (la casa in cui transita la Luna di oggi,
///   contata dalla Luna di nascita; Brihat Samhita 104, Phaladeepika 26),
///   la Tara Bala (il nakshatra di oggi contato da quello di nascita, a
///   gruppi di nove; Raman, *Muhurtha* III) e il Rahu Kalam del luogo;
///   l'Approfondita aggiunge il pianeta del giorno;
/// - **Amore, Lavoro, Fortuna**: la casa della Luna di oggi letta sulla
///   settima e la quinta, sulla decima, sulla seconda e l'undicesima, con la
///   precedenza della specifica (l'ottava su tutto, poi la Luna nella casa,
///   poi la Luna che la guarda dalla settima, poi la Chandra Bala);
/// - **colore e numero** del pianeta del giorno: il colore dal Brihat Jataka,
///   il numero dalla numerologia indiana moderna, e la nota lo dice.
///
/// La Tara Bala vuole il nakshatra di nascita, e la Luna ne cambia uno al
/// giorno: senza l'ora di nascita la Generale dice la sola Chandra Bala, e lo
/// dice. Senza il rashi certo non c'e' lettura.
///
/// Il giorno si legge alla Luna dell'alba del luogo (la convenzione del
/// panchang); senza il luogo, alla Luna delle sei.
abstract final class LaLetturaVedica {
  /// I 27 nakshatra con la traduzione del nome (Monier-Williams, per le
  /// etimologie correnti).
  static const List<(String, String)> nakshatra = [
    ('Ashvini', 'i cavalieri'),
    ('Bharani', 'colei che porta'),
    ('Krittika', 'colei che taglia'),
    ('Rohini', 'la rossa'),
    ('Mrigashira', 'la testa del cervo'),
    ('Ardra', 'l\'umida'),
    ('Punarvasu', 'il ritorno della luce'),
    ('Pushya', 'il nutrimento'),
    ('Ashlesha', 'l\'abbraccio'),
    ('Magha', 'la potente'),
    ('Purva Phalguni', 'la prima rossastra'),
    ('Uttara Phalguni', 'la seconda rossastra'),
    ('Hasta', 'la mano'),
    ('Chitra', 'la splendente'),
    ('Svati', 'l\'indipendente'),
    ('Vishakha', 'quella dai due rami'),
    ('Anuradha', 'il successo che segue'),
    ('Jyeshtha', 'la maggiore'),
    ('Mula', 'la radice'),
    ('Purva Ashadha', 'la prima invincibile'),
    ('Uttara Ashadha', 'la seconda invincibile'),
    ('Shravana', 'l\'ascolto'),
    ('Dhanishtha', 'la più ricca'),
    ('Shatabhisha', 'i cento medici'),
    ('Purva Bhadrapada', 'i primi piedi beati'),
    ('Uttara Bhadrapada', 'i secondi piedi beati'),
    ('Revati', 'la prospera'),
  ];

  /// Il segno della Luna col suo articolo: "nel Cancro".
  static const List<String> _nelSegno = [
    'nell\'Ariete', 'nel Toro', 'nei Gemelli', 'nel Cancro', //
    'nel Leone', 'nella Vergine', 'nella Bilancia', 'nello Scorpione',
    'nel Sagittario', 'nel Capricorno', 'nell\'Acquario', 'nei Pesci',
  ];

  static const List<String> _ordinali = [
    'prima', 'seconda', 'terza', 'quarta', 'quinta', 'sesta', //
    'settima', 'ottava', 'nona', 'decima', 'undicesima', 'dodicesima',
  ];

  /// Il pianeta, il colore e il numero del giorno, da domenica.
  static const List<(String, String, int)> pianetiDelGiorno = [
    ('il Sole', 'rosso', 1),
    ('la Luna', 'bianco', 2),
    ('Marte', 'rosso', 9),
    ('Mercurio', 'verde', 5),
    ('Giove', 'giallo', 3),
    ('Venere', 'bianco screziato', 6),
    ('Saturno', 'nero', 8),
  ];

  /// La parte del giorno di luce (1..8) che e' del Rahu Kalam, da domenica.
  static const List<int> parteDelRahu = [8, 2, 7, 5, 6, 4, 3];

  /// Chandra Bala: favorevoli 1, 3, 6, 7, 10, 11; di attenzione 2, 5, 9;
  /// sfavorevoli 4 e 12; l'ottava a se'.
  static EsitoVedico esitoDellaCasa(int casa) => switch (casa) {
        1 || 3 || 6 || 7 || 10 || 11 => EsitoVedico.favorevole,
        2 || 5 || 9 => EsitoVedico.attenzione,
        8 => EsitoVedico.ottava,
        _ => EsitoVedico.sfavorevole,
      };

  /// Tara Bala, come Drik: favorevoli Sampat, Kshema, Sadhana, Mitra, Parama
  /// Mitra; di attenzione Janma e Pratyak; sfavorevoli Vipat e Naidhana.
  static EsitoVedico esitoDellaTara(int tara) => switch (tara) {
        2 || 4 || 6 || 8 || 9 => EsitoVedico.favorevole,
        1 || 5 => EsitoVedico.attenzione,
        _ => EsitoVedico.sfavorevole,
      };

  /// La casa della Luna di oggi (1..12) contata dal rashi di nascita.
  static int casa(int rashiNascita, int rashiOggi) =>
      (rashiOggi - rashiNascita) % 12 + 1;

  /// La tara (1..9) del nakshatra di oggi contato da quello di nascita.
  static int tara(int nakshatraNascita, int nakshatraOggi) =>
      ((nakshatraOggi - nakshatraNascita) % 27) % 9 + 1;

  /// Il rashi e il nakshatra della Luna siderale all'istante [utc].
  static (int, int) lunaAlle(DateTime utc) {
    final l = ISegniDelleTradizioni.lunaSiderale(utc);
    return ((l ~/ 30) % 12, (l / (360 / 27)).floor() % 27);
  }

  /// L'istante del giorno civile [giorno] a cui si legge la Luna: l'alba del
  /// luogo, o le sei del telefono.
  static DateTime istanteDelGiorno(DateTime giorno, LuogoDelGiorno? luogo) {
    final seiLocali = DateTime(giorno.year, giorno.month, giorno.day, 6);
    if (luogo == null) return seiLocali.toUtc();
    final e = LAlbaEIlTramonto.delGiorno(giorno,
        lat: luogo.lat, lon: luogo.lon, offset: seiLocali.timeZoneOffset);
    return e?.alba ?? seiLocali.toUtc();
  }

  /// La Luna di nascita: il rashi, e il nakshatra se l'ora c'e'. Null senza
  /// un rashi certo.
  static (int, int?)? lunaDiNascita(NascitaDeiSegni n) {
    if (n.oraNota) {
      final (r, k) = lunaAlle(IlFusoDellaNascita.inUtc(n.locale, n.fuso));
      return (r, k);
    }
    final s = ISegniDelleTradizioni.vedica(n);
    if (!s.certo) return null;
    final r =
        ISegniDelleTradizioni.rashi.indexWhere((x) => s.nome.startsWith('$x '));
    return r < 0 ? null : (r, null);
  }

  // Il conto dei ritorni: per ogni giorno dal 2020, il rashi e il nakshatra
  // della Luna all'istante del giorno. Si tiene per luogo.
  static final Map<String, List<(int, int)>> _giorni = {};
  static final DateTime _inizio = DateTime(2020, 1, 1);

  static List<(int, int)> _finoA(DateTime giorno, LuogoDelGiorno? luogo) {
    final chiave = luogo == null
        ? '-'
        : '${luogo.lat.toStringAsFixed(2)},${luogo.lon.toStringAsFixed(2)}';
    final elenco = _giorni.putIfAbsent(chiave, () => []);
    final quanti = DateTime.utc(giorno.year, giorno.month, giorno.day)
            .difference(DateTime.utc(_inizio.year, _inizio.month, _inizio.day))
            .inDays +
        1;
    while (elenco.length < quanti) {
      final d =
          DateTime(_inizio.year, _inizio.month, _inizio.day + elenco.length);
      elenco.add(lunaAlle(istanteDelGiorno(d, luogo)));
    }
    return elenco;
  }

  /// **QUANTE VOLTE IL CASO DI OGGI E' GIA' CAPITATO**, dal 2020: la
  /// variante del gruppo e' questo numero modulo le varianti, cosi' ogni
  /// giorno in cui lo stesso caso torna si legge l'altra frase (la lezione
  /// della voce ES.08: una variante col solo giorno ripete la frase quando il
  /// caso torna con un passo multiplo delle varianti).
  static int volte(DateTime giorno, LuogoDelGiorno? luogo,
      bool Function(int rashi, int nakshatra) stessoCaso) {
    final elenco = _finoA(giorno, luogo);
    var n = 0;
    for (var i = 0; i < elenco.length - 1; i++) {
      if (stessoCaso(elenco[i].$1, elenco[i].$2)) n++;
    }
    return n;
  }

  static String _hm(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  /// Il Rahu Kalam del giorno civile [giorno] a [luogo], in UTC, arrotondato
  /// al minuto come lo stampa Drik Panchang. [offset] e' lo scarto del fuso
  /// del luogo (quello del telefono se manca): serve solo ad ancorare il
  /// giorno.
  static (DateTime, DateTime)? rahuKalam(DateTime giorno, LuogoDelGiorno luogo,
      {Duration? offset}) {
    final mezzogiorno = DateTime(giorno.year, giorno.month, giorno.day, 12);
    final e = LAlbaEIlTramonto.delGiorno(giorno,
        lat: luogo.lat,
        lon: luogo.lon,
        offset: offset ?? mezzogiorno.timeZoneOffset);
    if (e == null) return null;
    final ottavo = e.tramonto.difference(e.alba) ~/ 8;
    final p = parteDelRahu[giorno.weekday % 7];
    DateTime alMinuto(DateTime t) {
      final u = t.toUtc().add(const Duration(seconds: 30));
      return DateTime.utc(u.year, u.month, u.day, u.hour, u.minute);
    }

    return (
      alMinuto(e.alba.add(ottavo * (p - 1))),
      alMinuto(e.alba.add(ottavo * p)),
    );
  }

  /// Le quattro schede del giorno. [adesso] e' l'ora del telefono: decide il
  /// giorno e se il Rahu Kalam deve venire, e' in corso o e' passato. Null
  /// senza la Luna di nascita.
  static List<HoroscopeCard>? schede({
    required DateTime adesso,
    required NascitaDeiSegni nascita,
    LuogoDelGiorno? luogo,
    CourtesyForm? forma,
    Map<HoroscopeDomain, bool> approfondite = const {},
    String? apertura,
  }) {
    final natale = lunaDiNascita(nascita);
    if (natale == null) return null;
    final (rashiNascita, nakNascita) = natale;
    final giorno = DateTime(adesso.year, adesso.month, adesso.day);
    final (rashiOggi, nakOggi) = lunaAlle(istanteDelGiorno(giorno, luogo));
    final h = casa(rashiNascita, rashiOggi);
    final t = nakNascita == null ? null : tara(nakNascita, nakOggi);
    final (pianeta, colore, numero) = pianetiDelGiorno[giorno.weekday % 7];
    final f = forma;
    String nak(int i) => '${nakshatra[i].$1}, ${nakshatra[i].$2}';
    final valori = {
      'segno_luna': _nelSegno[rashiOggi],
      'casa': _ordinali[h - 1],
      'nakshatra_oggi': nak(nakOggi),
      'nakshatra_nascita': nakNascita == null ? '' : nak(nakNascita),
      'pianeta': pianeta,
      'colore': colore,
      'numero': '$numero',
      'il_numero': numero == 1 || numero == 8 ? 'l\'$numero' : 'il $numero',
      'luogo': luogo?.citta ?? '',
      'inizio': '',
      'fine': '',
    };
    String frase(List<String> varianti, int volta) => LaLetturaCinese.riempi(
        _risolvi(varianti[volta % varianti.length], f)
            .replaceAll('il {numero}', '{il_numero}'),
        valori);
    bool approfondita(HoroscopeDomain d) => approfondite[d] ?? false;

    // GENERALE.
    final dellaLuna = frase(OroscopoVedicoData.chandraBala[h - 1],
        volte(giorno, luogo, (r, _) => casa(rashiNascita, r) == h));
    final dellaStella = t == null
        ? 'Con l\'ora di nascita leggo anche la tua stella, la Tara Bala: '
            'oggi la Luna è in ${nak(nakOggi)}.'
        : frase(OroscopoVedicoData.taraBala[t - 1],
            volte(giorno, luogo, (_, k) => tara(nakNascita!, k) == t));
    String delRahu;
    final rk = luogo == null ? null : rahuKalam(giorno, luogo);
    if (rk == null) {
      delRahu =
          frase(OroscopoVedicoData.rahuSenzaCitta, _giornoGiuliano(giorno));
    } else {
      valori['inizio'] = _hm(rk.$1.toLocal());
      valori['fine'] = _hm(rk.$2.toLocal());
      final gruppo = adesso.isBefore(rk.$1)
          ? OroscopoVedicoData.rahuPrima
          : adesso.isBefore(rk.$2)
              ? OroscopoVedicoData.rahuInCorso
              : OroscopoVedicoData.rahuPassato;
      delRahu = frase(gruppo, _giornoGiuliano(giorno));
    }
    final settimana = _giornoGiuliano(giorno) ~/ 7;
    final righeDelPianeta = [
      OroscopoVedicoData.righeDelGiorno[giorno.weekday % 7],
      ...OroscopoVedicoData.righeDelPianeta,
    ];
    final delPianeta = frase(righeDelPianeta, settimana);
    final esitoLuna = esitoDellaCasa(h);
    final esitoStella = t == null ? null : esitoDellaTara(t);
    final generale = HoroscopeCard(
      domain: HoroscopeDomain.generale,
      title: 'La Luna in ${nakshatra[nakOggi].$1}',
      synthesis: LaLetturaCinese.primaFrase(dellaLuna),
      text: [
        dellaLuna,
        dellaStella,
        delRahu,
        if (approfondita(HoroscopeDomain.generale)) delPianeta,
      ].join(' '),
      indicator: livelloDelGiorno(esitoLuna, t),
      rigaDelLivello: 'Dalla Luna di oggi ${_nelSegno[rashiOggi]}, nella tua '
          '${_ordinali[h - 1]} casa dalla Luna di nascita '
          '(${_nomeEsito(esitoLuna)})'
          '${esitoStella == null ? '' : '; dalla tua tara di oggi, ${_nomiDelleTare[t! - 1]} (${_nomeEsito(esitoStella)})'}.',
      opening: apertura,
      metodo: _metodo(HoroscopeDomain.generale, conStella: t != null),
    );

    HoroscopeCard delDominio(
        HoroscopeDomain d, List<List<String>> gruppi, Set<int> sueCase) {
      final gruppo = gruppi[h - 1];
      final base = frase(
          gruppo,
          volte(giorno, luogo,
              (r, _) => identical(gruppi[casa(rashiNascita, r) - 1], gruppo)));
      final (titolo, livello, come) = _casoDelDominio(h, sueCase);
      final fortuna = d == HoroscopeDomain.fortuna;
      return HoroscopeCard(
        domain: d,
        title: titolo,
        synthesis: LaLetturaCinese.primaFrase(base),
        text: [
          base,
          if (approfondita(d))
            'Oggi la Luna passa ${_nelSegno[rashiOggi]}, nella tua '
                '${_ordinali[h - 1]} casa contata dalla Luna di nascita; '
                '${_temaDelDominio[d]}: $come.',
          if (fortuna && approfondita(d)) delPianeta,
        ].join(' '),
        indicator: livello,
        rigaDelLivello: 'Dalla Luna di oggi nella tua ${_ordinali[h - 1]} '
            'casa dalla Luna di nascita: $come.',
        metodo: _metodo(d, conStella: t != null),
        luckyNumber: fortuna ? numero : null,
        dayColor: fortuna ? colore : null,
        rigaDellaFortuna: fortuna
            ? 'Oggi governa $pianeta: il colore del giorno è il $colore, dal '
                'Brihat Jataka; il numero, $numero, viene dalla numerologia '
                'indiana moderna, non dai testi antichi.'
            : null,
      );
    }

    return [
      generale,
      delDominio(HoroscopeDomain.amore, OroscopoVedicoData.amore, {7, 5}),
      delDominio(HoroscopeDomain.carriera, OroscopoVedicoData.lavoro, {10}),
      delDominio(HoroscopeDomain.fortuna, OroscopoVedicoData.fortuna, {2, 11}),
    ];
  }

  /// La riga del secondo momento della riflessione: dove sta la Luna oggi.
  static String fattoDelGiorno(DateTime adesso, LuogoDelGiorno? luogo) {
    final g = DateTime(adesso.year, adesso.month, adesso.day);
    final (r, k) = lunaAlle(istanteDelGiorno(g, luogo));
    return 'Oggi la Luna è in ${nakshatra[k].$1}, ${_nelSegno[r]}.';
  }

  /// La riga di domani, ordine ES voce 34 letta nella tradizione vedica: dove
  /// sara' la Luna e che casa fara' per te.
  static String? domani(
      DateTime adesso, NascitaDeiSegni nascita, LuogoDelGiorno? luogo) {
    final natale = lunaDiNascita(nascita);
    if (natale == null) return null;
    final d = DateTime(adesso.year, adesso.month, adesso.day + 1);
    final (r, k) = lunaAlle(istanteDelGiorno(d, luogo));
    final h = casa(natale.$1, r);
    return 'Domani la Luna passa ${_nelSegno[r]}, in ${nakshatra[k].$1}: '
        'la tua ${_ordinali[h - 1]} casa dalla Luna di nascita, '
        '${_nomeEsito(esitoDellaCasa(h))}.';
  }

  static String _risolvi(String s, CourtesyForm? f) =>
      LaMarcaDelGenere.risolvi(s, forma: f);

  static int _giornoGiuliano(DateTime g) =>
      DateTime.utc(g.year, g.month, g.day).millisecondsSinceEpoch ~/ 86400000;

  static const List<String> _nomiDelleTare = [
    'Janma', 'Sampat', 'Vipat', 'Kshema', 'Pratyak', 'Sadhana', //
    'Naidhana', 'Mitra', 'Parama Mitra',
  ];

  static String _nomeEsito(EsitoVedico e) => switch (e) {
        EsitoVedico.favorevole => 'favorevole',
        EsitoVedico.attenzione => 'di attenzione',
        EsitoVedico.sfavorevole => 'sfavorevole',
        EsitoVedico.ottava => 'Chandrashtama',
      };

  /// **IL LIVELLO DELLA GENERALE**, dalle due forze insieme (Raman: "These
  /// three should be satisfactorily disposed"): tutte e due favorevoli,
  /// cinque; una favorevole e una di attenzione, quattro; una sfavorevole,
  /// tre; la Luna in ottava o Naidhana, due. Senza la tara, la sola Luna.
  static int livelloDelGiorno(EsitoVedico luna, int? tara) {
    if (luna == EsitoVedico.ottava || tara == 7) return 2;
    int punti(EsitoVedico e) => switch (e) {
          EsitoVedico.favorevole => 1,
          EsitoVedico.attenzione => 0,
          _ => -1,
        };
    if (tara == null) {
      return switch (luna) {
        EsitoVedico.favorevole => 4,
        EsitoVedico.attenzione => 3,
        _ => 2,
      };
    }
    final s = punti(luna) + punti(esitoDellaTara(tara));
    return switch (s) { 2 => 5, 1 => 4, -2 => 2, _ => 3 };
  }

  static const Map<HoroscopeDomain, String> _temaDelDominio = {
    HoroscopeDomain.amore:
        'per l\'amore contano la settima casa, dell\'unione, con la quinta, '
            'del cuore che si apre',
    HoroscopeDomain.carriera:
        'per il lavoro conta la decima casa, del lavoro e del nome',
    HoroscopeDomain.fortuna:
        'per la fortuna contano la seconda casa, dei beni, con '
            'l\'undicesima, dei guadagni',
  };

  /// Il caso di una scheda, con la precedenza della specifica (6.3): il
  /// titolo, il livello e che cosa fa la Luna al dominio.
  static (String, int, String) _casoDelDominio(int h, Set<int> sueCase) {
    final esito = esitoDellaCasa(h);
    if (h == 8) {
      return ('Chandrashtama', 2, 'la Luna in ottava, il giorno più delicato');
    }
    if (sueCase.contains(h)) {
      return (
        'La Luna nella ${_ordinali[h - 1]} casa',
        esito == EsitoVedico.favorevole ? 5 : 4,
        'la Luna attraversa la ${_ordinali[h - 1]}',
      );
    }
    final guardata = (h + 5) % 12 + 1;
    if (sueCase.contains(guardata)) {
      return (
        'La Luna guarda la ${_ordinali[guardata - 1]} casa',
        esito == EsitoVedico.favorevole ? 4 : 3,
        'la Luna guarda la ${_ordinali[guardata - 1]} dalla settima da sé',
      );
    }
    return switch (esito) {
      EsitoVedico.favorevole => ('Una Luna favorevole', 4, 'Luna favorevole'),
      EsitoVedico.attenzione => (
          'Una Luna di attenzione',
          3,
          'Luna di attenzione'
        ),
      _ => ('Una Luna sfavorevole', 2, 'Luna sfavorevole'),
    };
  }

  static String _metodo(HoroscopeDomain d, {required bool conStella}) {
    String voce(String termine) => OroscopoVedicoData.glossario
        .firstWhere((g) => g.$1 == termine, orElse: () => (termine, ''))
        .$2;
    final base = 'La Luna di oggi è siderale, con l\'ayanamsa di Lahiri, '
        'letta all\'alba del luogo. Chandra Bala: ${voce('Chandra Bala')}';
    return switch (d) {
      HoroscopeDomain.generale => '$base Tara Bala: ${voce('Tara Bala')}'
          '${conStella ? '' : ' Senza l\'ora di nascita la tua stella non si sa: la Tara Bala manca.'}'
          ' Rahu Kalam: ${voce('Rahu Kalam')} Si calcola dall\'alba e dal '
          'tramonto del luogo, come Drik Panchang.',
      _ => '$base Le case si contano dalla Luna di nascita (Phaladeepika '
          '26.1); i significati sono quelli del Brihat Parashara Hora '
          'Shastra, cap. 11. La quinta casa come cuore che si apre è una '
          'lettura moderna.',
    };
  }
}
