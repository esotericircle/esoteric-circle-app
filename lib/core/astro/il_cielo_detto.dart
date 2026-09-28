import 'celestial.dart';
import 'effemeridi.dart';
import 'moon_phase.dart';
import 'night_sky.dart';
import 'zodiac.dart';

/// Una frase sul cielo che il calcolo smentisce, col perche'.
class FraseSmentita {
  const FraseSmentita({required this.frase, required this.perche});

  final String frase;
  final String perche;

  @override
  String toString() => '"$frase": $perche';
}

/// **IL CIELO DETTO DEVE ESSERE IL CIELO CALCOLATO.** Ordine DS voce 08, 17
/// settembre 2026.
///
/// **Il fatto**, sulle catture di un fondatore: in una risposta di Medora *"il
/// Primo Quarto di Luna che si avvicina"*, in un'altra *"ripassa quando sarà
/// luna crescente"*. Se il Primo quarto si avvicina la Luna e' gia' crescente:
/// la seconda frase mandava la persona in un momento che era adesso. **E la
/// seconda frase non l'aveva scritta il modello**: era la chiusa composta
/// dall'app, che guardava la fase di domani e la dava per futura anche quando
/// era la stessa di oggi.
///
/// **Cosa fa questa classe.** Legge in un testo le affermazioni sulla Luna
/// che si possono controllare, e le confronta col calcolo di `NightSky` e
/// `MoonPhase`, cioe' con la stessa porta dell'astronomia che usa il resto
/// dell'app:
///
/// 1. **una fase promessa per dopo** (*"quando sara' crescente"*) che e' gia'
///    quella di adesso;
/// 2. **una fase detta per adesso** (*"la Luna e' calante"*) che adesso non
///    e';
/// 3. **un ingresso in un segno** con il suo quando (*"domani la Luna entra in
///    Capricorno"*, *"fra 3 giorni"*) che non cade in quel giorno;
/// 4. **una fase principale** con il suo quando (*"la Luna piena fra 7
///    giorni"*) che non comincia in quel giorno.
///
/// **Non e' un analizzatore della lingua.** Riconosce le forme con cui l'app e
/// il modello parlano davvero della Luna, e cio' che non riconosce non lo
/// giudica: una frase non capita non e' una frase falsa.
abstract final class IlCieloDetto {
  static const _numeri = <String, int>{
    'un': 1,
    'uno': 1,
    'due': 2,
    'tre': 3,
    'quattro': 4,
    'cinque': 5,
    'sei': 6,
    'sette': 7,
    'otto': 8,
    'nove': 9,
    'dieci': 10,
  };

  static const _fasiPrincipali = <String, String>{
    'primo quarto': 'Primo quarto',
    'luna piena': 'Luna piena',
    'ultimo quarto': 'Ultimo quarto',
    'luna nuova': 'Luna nuova',
  };

  /// **IL CIELO DI OGGI, per il modello.** Ordine DS voce 08.
  ///
  /// Al modello arrivava la fase lunare **di nascita** e gli eventi in arrivo,
  /// mai la Luna di oggi: chi voleva parlarne doveva indovinarla. Adesso la
  /// riceve calcolata, e il verificatore sopra controlla cio' che ne dice.
  static String oggiPerIlModello(DateTime adesso) {
    final segno = NightSky.moonSign(adesso).italianName;
    final fase = MoonPhase.comeSiDice(MoonPhase.forDate(adesso).italianName);
    return 'IL CIELO DI OGGI, calcolato: la Luna è in $segno ed è $fase. '
        'Se parli della Luna di oggi, sono la sola posizione e la sola fase '
        'vere. Non dirne altre. Non dare a un evento un giorno diverso da '
        'quello scritto qui o in CIÒ CHE ARRIVA.\n${pianetiDiOggi(adesso)}';
  }

  /// I corpi di cui il cielo di oggi dice il segno, dalle effemeridi dell'app.
  static const List<CorpoCeleste> _pianeti = [
    CorpoCeleste.sole,
    CorpoCeleste.mercurio,
    CorpoCeleste.venere,
    CorpoCeleste.marte,
    CorpoCeleste.giove,
    CorpoCeleste.saturno,
  ];

  static Zodiac _segnoDi(CorpoCeleste corpo, DateTime adesso) {
    if (corpo == CorpoCeleste.luna) return NightSky.moonSign(adesso);
    final jd = Celestial.julianDay(adesso.toUtc());
    return Zodiac
        .values[(Effemeridi.longitudineEclittica(corpo, jd) / 30).floor() % 12];
  }

  static bool _retrogrado(CorpoCeleste corpo, DateTime adesso) =>
      corpo != CorpoCeleste.sole &&
      corpo != CorpoCeleste.luna &&
      Effemeridi.retrogrado(corpo, Celestial.julianDay(adesso.toUtc()));

  /// **I PIANETI DI OGGI, per il modello.** Ordine ET voce 01, 28 settembre
  /// 2026: il modello riceveva la sola Luna di oggi, e nella sonda del banco
  /// delle trenta domande inventava *"Giove in Toro"*, *"Venere in
  /// Capricorno"*, *"Mercurio retrogrado"*. Adesso riceve i pianeti calcolati
  /// e la regola di nominarli solo dove stanno.
  static String pianetiDiOggi(DateTime adesso) {
    final pianeti = [
      for (final c in _pianeti)
        '${c.nome} in ${_segnoDi(c, adesso).italianName}'
            '${_retrogrado(c, adesso) ? (c == CorpoCeleste.venere ? ' retrograda' : ' retrogrado') : ''}',
    ];
    return 'I PIANETI DI OGGI, calcolati: ${pianeti.join(', ')}. Sono le sole '
        'posizioni vere di oggi: se nomini un pianeta di oggi o un suo '
        'transito, lo nomini dove sta qui. Non dire retrogrado un pianeta che '
        'qui non lo è. Non nominare Urano, Nettuno e Plutone. Il cielo di '
        'nascita della persona resta quello scritto sopra.';
  }

  /// Le frasi del testo che il calcolo smentisce, guardando da [adesso].
  static List<FraseSmentita> smentite(String testo,
      {required DateTime adesso, Map<String, String> diNascita = const {}}) {
    final esito = <FraseSmentita>[];
    for (final frase in frasiDi(testo)) {
      final perche =
          _pianeta(frase, adesso, diNascita) ?? _perche(frase, adesso);
      if (perche != null) {
        esito.add(FraseSmentita(frase: frase.trim(), perche: perche));
      }
    }
    return esito;
  }

  /// Il testo senza le frasi che il calcolo smentisce. Le altre restano
  /// com'erano, a capo compresi.
  static String senzaLeSmentite(String testo,
      {required DateTime adesso, Map<String, String> diNascita = const {}}) {
    final via = smentite(testo, adesso: adesso, diNascita: diNascita)
        .map((s) => s.frase)
        .toSet();
    if (via.isEmpty) return testo;
    var fuori = testo;
    for (final f in via) {
      fuori = fuori.replaceFirst(f, '');
    }
    // Nessuna riga comincia con uno spazio dove una frase e' stata tolta
    // (ordine ET voce 01: nella sonda " Il tuo compito...").
    return fuori
        .replaceAll(RegExp(r'[ \t]{2,}'), ' ')
        .replaceAll(RegExp(r' +\n'), '\n')
        .replaceAll(RegExp(r'\n[ \t]+'), '\n')
        .trim();
  }

  /// Le frasi di un testo: si spezza dopo il punto, il punto esclamativo, il
  /// punto interrogativo e i due punti che chiudono una proposizione.
  static List<String> frasiDi(String testo) => testo
      .split(RegExp(r'(?<=[.!?…])\s+|\n+'))
      .where((f) => f.trim().isNotEmpty)
      .toList();

  static String _piano(String s) => s
      .toLowerCase()
      .replaceAll('à', 'a')
      .replaceAll('è', 'e')
      .replaceAll('é', 'e')
      .replaceAll('ì', 'i')
      .replaceAll('ò', 'o')
      .replaceAll('ù', 'u')
      .replaceAll('’', "'");

  /// Il predicato della fase, nella forma in cui la si dice dopo "sara'".
  static String _predicato(MoonPhase fase) =>
      _piano(MoonPhase.comeSiDice(fase.italianName));

  /// Fra quanti giorni di calendario cade [evento], cercato ora per ora.
  static int? _giorniFinoA(DateTime adesso, bool Function(DateTime) comincia) {
    final oggi = DateTime(adesso.year, adesso.month, adesso.day);
    for (var h = 1; h <= 24 * 32; h++) {
      final istante =
          DateTime(adesso.year, adesso.month, adesso.day, adesso.hour + h);
      if (comincia(istante)) {
        final giorno = DateTime(istante.year, istante.month, istante.day);
        return DateTime.utc(giorno.year, giorno.month, giorno.day)
            .difference(DateTime.utc(oggi.year, oggi.month, oggi.day))
            .inDays;
      }
    }
    return null;
  }

  static int? _quando(String frase) {
    if (RegExp(r'\boggi\b').hasMatch(frase)) return 0;
    if (RegExp(r'\bdomani\b').hasMatch(frase)) return 1;
    final fra = RegExp(r'\bfra (\d+|[a-z]+) giorn[oi]\b').firstMatch(frase);
    if (fra == null) return null;
    return int.tryParse(fra.group(1)!) ?? _numeri[fra.group(1)!];
  }

  /// **5. Un pianeta detto in un segno o retrogrado, oggi.** Ordine ET voce
  /// 01. Si guardano le forme "Giove in Toro", "il transito di Venere in
  /// Capricorno", "Mercurio retrogrado". Non si giudicano il cielo di nascita
  /// ("il tuo Sole", o il segno che la persona ha davvero) e le frasi al
  /// futuro ("domani", "fra tre giorni", "entrera'", "quando sara'"), che
  /// dicono un altro momento.
  static String? _pianeta(
      String originale, DateTime adesso, Map<String, String> diNascita) {
    final frase = _piano(originale);
    if (RegExp(r'\b(domani|fra \d+|fra [a-z]+ giorn[oi]|entrer[aà]|sar[aà]|'
            r'quando|prossim[oaie]|arrivera)\b')
        .hasMatch(frase)) {
      return null;
    }
    final nascita = {
      for (final e in diNascita.entries) _piano(e.key): _piano(e.value),
    };
    for (final corpo in [..._pianeti, CorpoCeleste.luna]) {
      final nome = _piano(corpo.nome);
      const possessivo = r'(\b(?:tuo|tua|suo|sua) )?\b';
      const dove = r"\b (?:e |transita |si trova |sta )?(?:nel segno dell'|"
          r"nel segno dello |nel segno del |nell'|nello |nel |in )([a-z]+)";
      final nelSegno = RegExp('$possessivo$nome$dove').allMatches(frase);
      for (final m in nelSegno) {
        if (m.group(1) != null) continue;
        final detto = m.group(2)!;
        Zodiac? segno;
        for (final z in Zodiac.values) {
          if (_piano(z.italianName) == detto) segno = z;
        }
        if (segno == null) continue;
        if (nascita[nome] == detto) continue;
        final vero = _segnoDi(corpo, adesso);
        if (vero != segno) {
          return 'dice ${corpo.nome} in ${segno.italianName}, ma oggi il '
              'calcolo lo dà in ${vero.italianName}';
        }
      }
      const retrogrado = r'\b (?:[eè] |che [eè] )?retrograd[oa]';
      final retro = RegExp('$possessivo$nome$retrogrado').firstMatch(frase);
      if (retro != null &&
          retro.group(1) == null &&
          !_retrogrado(corpo, adesso)) {
        return 'dice ${corpo.nome} retrogrado, ma oggi il calcolo lo dà '
            'diretto';
      }
    }
    return null;
  }

  static String? _perche(String originale, DateTime adesso) {
    final frase = _piano(originale);
    if (!frase.contains('luna') && !frase.contains('quarto')) return null;
    final ora = MoonPhase.forDate(adesso);

    // 1. Una fase promessa per dopo, che e' gia' quella di adesso.
    final promessa = RegExp(
            r"\b(?:quando|finch[eé]) (?:la luna )?sar[aà] (?:luna )?"
            r"(crescente|calante|piena|nuova|al primo quarto|all'ultimo quarto|"
            r'gibbosa crescente|gibbosa calante)\b')
        .firstMatch(frase);
    // 1b. La stessa promessa col suo quando: la fase deve cominciare in quel
    // giorno. Crescente e calante non hanno un giorno d'inizio da dire, e
    // non si giudicano.
    final quandoPromessa = _quando(frase);
    if (promessa != null &&
        quandoPromessa != null &&
        !const {'crescente', 'calante'}.contains(promessa.group(1))) {
      final detta = promessa.group(1)!;
      final giorni = _predicato(ora) == detta
          ? 0
          : _giorniFinoA(
              adesso, (t) => _predicato(MoonPhase.forDate(t)) == detta);
      if (giorni != quandoPromessa) {
        return 'promette la Luna $detta fra $quandoPromessa giorni, ma il '
            'calcolo la dà fra $giorni';
      }
    }
    if (promessa != null && _quando(frase) == null) {
      final detta = promessa.group(1)!;
      final adessoE = _predicato(ora);
      final giaCosi = detta == adessoE ||
          (detta == 'crescente' && ora.waxing && adessoE != 'piena') ||
          (detta == 'calante' && !ora.waxing && adessoE != 'nuova');
      if (giaCosi) {
        return 'promette per dopo una Luna $detta, ma la Luna è già '
            '${ora.italianName.toLowerCase()} adesso';
      }
    }

    // 2. Una fase detta per adesso.
    final presente =
        RegExp(r'\b(?:la )?luna [eè] (crescente|calante|piena|nuova)\b')
            .firstMatch(frase);
    // "Oggi" e' adesso: la frase si giudica. Un altro quando e' un'altra
    // affermazione, e la guardano le regole sotto.
    if (presente != null && (_quando(frase) ?? 0) == 0) {
      final detta = presente.group(1)!;
      final vera = switch (detta) {
        'crescente' => ora.waxing,
        'calante' => !ora.waxing,
        'piena' => ora.italianName == 'Luna piena',
        _ => ora.italianName == 'Luna nuova',
      };
      if (!vera) {
        return 'dice la Luna $detta adesso, ma il calcolo la dà '
            '${ora.italianName.toLowerCase()}';
      }
    }

    // 3. Un ingresso in un segno, con il suo quando.
    final ingresso = RegExp(r'\bluna (?:entra|passa|transita|arriva|sar[aà]) '
            r'(?:nel segno del |nel |in )([a-z]+)\b')
        .firstMatch(frase);
    final quandoIngresso = _quando(frase);
    if (ingresso != null && quandoIngresso != null) {
      Zodiac? segno;
      for (final z in Zodiac.values) {
        if (_piano(z.italianName) == ingresso.group(1)) segno = z;
      }
      if (segno != null) {
        final giorni = NightSky.moonSign(adesso) == segno
            ? 0
            : _giorniFinoA(adesso, (t) => NightSky.moonSign(t) == segno);
        if (giorni != quandoIngresso) {
          return 'dice la Luna in ${segno.italianName} fra $quandoIngresso '
              'giorni, ma il calcolo la dà fra $giorni';
        }
      }
    }

    // 4. Una fase principale, con il suo quando.
    for (final e in _fasiPrincipali.entries) {
      if (!frase.contains(e.key)) continue;
      final quando = _quando(frase);
      if (quando == null) continue;
      final giorni = ora.italianName == e.value
          ? 0
          : _giorniFinoA(
              adesso, (t) => MoonPhase.forDate(t).italianName == e.value);
      if (giorni != quando) {
        return 'dice ${e.value} fra $quando giorni, ma il calcolo la dà fra '
            '$giorni';
      }
    }
    return null;
  }
}
