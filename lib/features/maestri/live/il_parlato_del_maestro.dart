/// **COME UNA RISPOSTA SCRITTA DIVENTA VOCE.** Ordine EG voci 01 e 02, 23
/// settembre 2026.
///
/// La risposta del Maestro nel LIVE e' la stessa della chat scritta: stesso
/// cervello, stessa memoria, stesse regole. Ma una risposta scritta porta
/// cose che non si dicono ad alta voce: la stella del gesto, i grassetti, gli
/// a capo. Qui la si prepara per la voce, **fuori dal widget**, perche' una
/// prova la possa raggiungere: e' la lezione dell'ordine EI, dove una frase
/// chiusa in uno `State` privato non era sorvegliata da niente.
///
/// **Perche' a pezzi.** La voce si chiede al server una frase alla volta: il
/// primo pezzo parte mentre il secondo si sta ancora componendo, e la persona
/// sente il Maestro cominciare in un secondo invece di aspettare che l'intera
/// risposta diventi audio.
abstract final class IlParlatoDelMaestro {
  /// Quanto puo' essere lungo un pezzo, in caratteri. Abbastanza per una
  /// frase piena, poco perche' il primo pezzo arrivi presto.
  static const pezzoMassimo = 220;

  /// La risposta scritta, pulita di cio' che non si pronuncia.
  static String daDire(String scritto) {
    var t = scritto;
    // La stella del gesto resta, ma senza il segno: il gesto si dice.
    t = t.replaceAll(RegExp('[✦✧✴★☆]'), '');
    // I grassetti e i corsivi del markdown non si leggono.
    t = t.replaceAll(RegExp(r'[*_#`>]'), '');
    // Gli a capo diventano pause di frase.
    t = t.replaceAll(RegExp(r'\s*\n+\s*'), ' ');
    return t.replaceAll(RegExp(r'\s{2,}'), ' ').trim();
  }

  /// **SI DICE CALÌGO.** Ordine EJ voce 04, 24 settembre 2026. Il
  /// fondatore: *"l'accento del nome di Caligo è errata: è Calìgo e non
  /// Càligo"*. A video il nome resta com'e'; alla voce arriva con l'accento
  /// scritto, che Gemini-TTS segue. **Un'indicazione nel modo di parlare non
  /// funziona**: provata lo stesso giorno, la voce la leggeva ad alta voce.
  static String pronunciato(String testo) =>
      testo.replaceAll(RegExp(r'\bCaligo\b'), 'Calìgo');

  /// I pezzi da chiedere alla voce, nell'ordine in cui si dicono.
  ///
  /// Si taglia **alla fine delle frasi**, mai a meta': una frase spezzata in
  /// due chiamate si sentirebbe con due intonazioni diverse. Le frasi brevi
  /// si uniscono fino al tetto, cosi' una risposta di dieci frasi non costa
  /// dieci chiamate.
  static List<String> pezzi(String scritto) {
    final pulito = pronunciato(daDire(scritto));
    if (pulito.isEmpty) return const [];
    final frasi = RegExp(r'[^.!?…]+[.!?…]+|[^.!?…]+$')
        .allMatches(pulito)
        .map((m) => m.group(0)!.trim())
        .where((f) => f.isNotEmpty)
        .toList();
    final fuori = <String>[];
    var corrente = '';
    for (final f in frasi) {
      if (corrente.isEmpty) {
        corrente = f;
      } else if (corrente.length + 1 + f.length <= pezzoMassimo) {
        corrente = '$corrente $f';
      } else {
        fuori.add(corrente);
        corrente = f;
      }
    }
    if (corrente.isNotEmpty) fuori.add(corrente);
    return fuori;
  }
}
