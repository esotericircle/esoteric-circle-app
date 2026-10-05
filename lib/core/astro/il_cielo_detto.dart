import 'meeus/il_cielo_di_meeus.dart';
import 'celestial.dart';
import 'moon_phase.dart';
import 'night_sky.dart';
import 'zodiac.dart';
import 'il_segno_del_cielo.dart';

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
    final segno = IlSegnoDelCielo.dellaLuna(adesso).italianName;
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
    // **E I TRE LENTI, ordine EV voce 03.** Erano fuori perche' le
    // effemeridi non li avevano, e la regola diceva al modello di non
    // nominarli: il 1 ottobre 2026 Medora ha risposto "Non ho tra le mie note
    // che Urano sia retrogrado oggi" a chi l'aveva appena letto
    // nell'Oroscopo. Le effemeridi li hanno, misurati contro il JPL entro
    // due centesimi di grado.
    CorpoCeleste.urano,
    CorpoCeleste.nettuno,
    CorpoCeleste.plutone,
  ];

  static bool _retrogrado(CorpoCeleste corpo, DateTime adesso) =>
      corpo != CorpoCeleste.sole &&
      corpo != CorpoCeleste.luna &&
      IlCieloDiMeeus.retrogrado(corpo, Celestial.julianDay(adesso.toUtc()));

  /// **I PIANETI DI OGGI, per il modello.** Ordine ET voce 01, 28 settembre
  /// 2026: il modello riceveva la sola Luna di oggi, e nella sonda del banco
  /// delle trenta domande inventava *"Giove in Toro"*, *"Venere in
  /// Capricorno"*, *"Mercurio retrogrado"*. Adesso riceve i pianeti calcolati
  /// e la regola di nominarli solo dove stanno.
  static String pianetiDiOggi(DateTime adesso) {
    final pianeti = [
      for (final c in _pianeti)
        '${c.nome} in ${IlSegnoDelCielo.delCorpo(c, adesso).italianName}'
            '${_retrogrado(c, adesso) ? (c == CorpoCeleste.venere ? ' retrograda' : ' retrogrado') : ''}',
    ];
    return 'I PIANETI DI OGGI, calcolati: ${pianeti.join(', ')}. Sono le sole '
        'posizioni vere di oggi: se nomini un pianeta di oggi o un suo '
        'transito, lo nomini dove sta qui. Non dire retrogrado un pianeta che '
        'qui non lo è. Per il cielo di un altro giorno, o per i gradi e '
        'gli aspetti, chiedi la funzione cielo_del_giorno. Il cielo di '
        'nascita della persona resta quello scritto sopra.';
  }

  /// Le frasi del testo che il calcolo smentisce, guardando da [adesso].
  ///
  /// [altriGiorni] sono i giorni di cui il Maestro ha chiesto il cielo in
  /// questo turno (ordine EV voce 03, `LeFunzioniDelCielo`): un pianeta detto
  /// nel segno o nel moto che ha in uno di quei giorni e' vero, anche se oggi
  /// sta altrove. Sul banco del 1 ottobre la rete toglieva "Il transito di
  /// Giove in Vergine" dalla risposta sul 1 gennaio 2028, che era giusta.
  static List<FraseSmentita> smentite(String testo,
      {required DateTime adesso,
      Map<String, String> diNascita = const {},
      List<DateTime> altriGiorni = const []}) {
    final esito = <FraseSmentita>[];
    for (final frase in frasiDi(testo)) {
      // **LA LUNA DI UN GIORNO CHIESTO**, settimo giro dei banchi: "il 9
      // novembre, quando la Luna è nuova in Scorpione" era vera, e la rete
      // della fase la toglieva guardando da oggi. Con una data scritta e il
      // cielo di altri giorni chiesto nel turno, la fase non si giudica.
      final conData = altriGiorni.isNotEmpty &&
          RegExp(r'\b\d{1,2} (gennaio|febbraio|marzo|aprile|maggio|giugno|'
                  r'luglio|agosto|settembre|ottobre|novembre|dicembre)\b|'
                  r'\b\d{4}-\d{2}-\d{2}\b')
              .hasMatch(_piano(frase));
      final perche = _pianeta(frase, adesso, diNascita, altriGiorni) ??
          (conData ? null : _perche(frase, adesso));
      if (perche != null) {
        esito.add(FraseSmentita(frase: frase.trim(), perche: perche));
      }
    }
    return esito;
  }

  /// Il testo senza le frasi che il calcolo smentisce. Le altre restano
  /// com'erano, a capo compresi.
  static String senzaLeSmentite(String testo,
      {required DateTime adesso,
      Map<String, String> diNascita = const {},
      List<DateTime> altriGiorni = const []}) {
    final via = smentite(testo,
            adesso: adesso, diNascita: diNascita, altriGiorni: altriGiorni)
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
  static int? _giorniFinoA(DateTime adesso, bool Function(DateTime) comincia,
      {DateTime? da}) {
    final oggi = DateTime(adesso.year, adesso.month, adesso.day);
    final partenza = da ?? adesso;
    for (var h = 1; h <= 24 * 32; h++) {
      var istante = partenza.add(Duration(hours: h));
      if (comincia(istante)) {
        // **AL MINUTO**, ordine EV voce EV.10: si cercava dall'ora piena e il
        // primo istante cambiato decideva il giorno, quindi un ingresso alle
        // 23:25 contava come il giorno dopo.
        var prima = istante.subtract(const Duration(hours: 1));
        while (istante.difference(prima).inMinutes > 1) {
          final m = prima
              .add(Duration(minutes: istante.difference(prima).inMinutes ~/ 2));
          if (comincia(m)) {
            istante = m;
          } else {
            prima = m;
          }
        }
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
  static String? _pianeta(String originale, DateTime adesso,
      Map<String, String> diNascita, List<DateTime> altriGiorni) {
    final frase = _piano(originale);
    if (RegExp(r'\b(domani|fra \d+|fra [a-z]+ giorn[oi]|entrer[aà]|sar[aà]|'
            r'quando|prossim[oaie]|arrivera)\b')
        .hasMatch(frase)) {
      return null;
    }
    // **UN ALTRO GIORNO NON SI CONFRONTA CON OGGI.** Ordine EV voce 03: il
    // Maestro adesso sa il cielo di qualunque data, e "il 15 marzo 2027
    // Marte e' in Leone" o "nel 2020 Saturno era in Acquario" sono vere per
    // quella data. La rete guarda oggi: le frasi con un'altra data, un anno,
    // un passato o un futuro le lascia stare, salvo che dicano "oggi".
    if (!RegExp(r'\boggi\b', caseSensitive: false).hasMatch(frase) &&
        // "sarà" fuori dai confini di parola: la a accentata non e' una
        // lettera per `\b`, e dopo di lei il confine non c'e'.
        RegExp(
                r'\bsar(?:à|anno)|\b(ieri|domani|dopodomani|prossim[oaie]|era|'
                r'erano|fu|stato|stata|gennaio|febbraio|marzo|aprile|maggio|'
                r'giugno|luglio|agosto|settembre|ottobre|novembre|dicembre|'
                r'1[5-9]\d\d|2\d\d\d)\b',
                caseSensitive: false)
            .hasMatch(frase)) {
      return null;
    }
    final nascita = {
      for (final e in diNascita.entries) _piano(e.key): _piano(e.value),
    };
    // **"IL TUO SEGNO" E' QUELLO DEL SOLE DI NASCITA**, ordine EV voce 03:
    // sul banco "Il Sole, nel tuo segno di Bilancia" a una persona del Cancro.
    final solare = nascita['sole'];
    if (solare != null) {
      final m = RegExp(
              r"\btuo segno (?:di |del |della |dello |dell'|dei |degli )?([a-z]+)")
          .firstMatch(frase);
      final detto = m?.group(1);
      if (detto != null &&
          detto != solare &&
          Zodiac.values.any((z) => _piano(z.italianName) == detto)) {
        return 'dice il segno della persona $detto, ma il suo Sole di nascita '
            'è in $solare';
      }
    }
    for (final corpo in [..._pianeti, CorpoCeleste.luna]) {
      final nome = _piano(corpo.nome);
      const possessivo = r'(\b(?:tuo|tua|suo|sua) )?\b';
      // "oggi" fra il pianeta e il verbo, o dopo il verbo: sul banco
      // dell'ordine EV "La Luna oggi si trova nel segno del Capricorno", con
      // la Luna nei Gemelli, passava.
      const dove = r"\b (?:oggi )?(?:e |transita |si trova |sta )?(?:oggi )?"
          r"(?:nel segno dell'|"
          r"nel segno dello |nel segno del |nell'|nello |nel |in )([a-z]+)";
      final nelSegno = RegExp('$possessivo$nome$dove').allMatches(frase);
      for (final m in nelSegno) {
        final detto = m.group(2)!;
        Zodiac? segno;
        for (final z in Zodiac.values) {
          if (_piano(z.italianName) == detto) segno = z;
        }
        if (segno == null) continue;
        // **"LA TUA LUNA" E' QUELLA DI NASCITA**, ordine EV voce 03: sul
        // banco del 1 ottobre Medora diceva "la tua Luna in Gemelli" a una
        // persona con la Luna di nascita in Bilancia (i Gemelli erano la Luna
        // di quel giorno). Col possessivo si confronta con la nascita, quando
        // la si sa; senza la nascita non si giudica.
        if (m.group(1) != null) {
          final diNascita = nascita[nome];
          if (diNascita != null && diNascita != detto) {
            return 'dice ${corpo.nome} della persona in '
                '${segno.italianName}, ma quella di nascita è in '
                '${diNascita[0].toUpperCase()}${diNascita.substring(1)}';
          }
          continue;
        }
        if (nascita[nome] == detto) continue;
        final vero = IlSegnoDelCielo.delCorpo(corpo, adesso);
        if (vero != segno &&
            !altriGiorni
                .any((g) => IlSegnoDelCielo.delCorpo(corpo, g) == segno)) {
          return 'dice ${corpo.nome} in ${segno.italianName}, ma oggi il '
              'calcolo lo dà in ${vero.italianName}';
        }
      }
      const retrogrado = r'\b (?:[eè] |che [eè] )?retrograd[oa]';
      final retro = RegExp('$possessivo$nome$retrogrado').firstMatch(frase);
      if (retro != null &&
          retro.group(1) == null &&
          !_retrogrado(corpo, adesso) &&
          !altriGiorni.any((g) => _retrogrado(corpo, g))) {
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
        final giorni = IlSegnoDelCielo.dellaLuna(adesso) == segno
            ? 0
            : _giorniFinoA(
                adesso, (t) => IlSegnoDelCielo.dellaLuna(t) == segno);
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
      // La fase che viene e' l'istante esatto (il cambio di quarto), ordine
      // EV voce EV.10: il nome della fase comincia dodici ore prima, e qui
      // si contava da li'.
      // Se la Luna e' gia' in quel quarto, la fase che viene e' quella del
      // ciclo dopo: si parte da quando il quarto finisce.
      final quarto = NightSky.fasiPrincipali.indexOf(e.value);
      var da = adesso;
      for (var h = 0;
          h < 24 * 9 && NightSky.quartoDelCiclo(da) == quarto;
          h++) {
        da = da.add(const Duration(hours: 1));
      }
      final esatta = _giorniFinoA(
          adesso, (t) => NightSky.quartoDelCiclo(t) == quarto,
          da: da);
      // Nelle dodici ore prima dell'istante esatto la fase ha gia' il suo
      // nome: "oggi" e il giorno dell'istante esatto sono veri tutti e due.
      final giorni = ora.italianName == e.value && quando == 0 ? 0 : esatta;
      if (giorni != quando) {
        return 'dice ${e.value} fra $quando giorni, ma il calcolo la dà fra '
            '$giorni';
      }
    }
    return null;
  }
}
