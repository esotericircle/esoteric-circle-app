/// IL SEGUITO: cio' che il Maestro scrive SOTTO la risposta gia' data.
///
/// **Perche' si genera al tocco e non prima.** Se un Premium non tocca mai la
/// freccia, la spesa per il testo lungo e' gia' stata sostenuta per niente.
/// I numeri: ingresso 1807 token mediani, uscita breve 116, uscita intera
/// circa 350. Generare sempre intero costa 2157 a risposta, sempre. Generare
/// il seguito al tocco costa 1923 subito, piu' una seconda chiamata solo per
/// chi approfondisce. Il pareggio sta intorno all'11,5 per cento di risposte
/// approfondite, e quel numero non lo sappiamo: nessuno ha mai misurato quante
/// volte quella freccia viene toccata.
///
/// **Il seguito NON e' la risposta rifatta.** Il modello riceve cio' che ha
/// gia' detto e continua da li'. Se la persona rilegge due volte la stessa
/// cosa, l'approfondimento sembra una truffa.
///
/// **E resta coerente con l'elemento oracolare gia' consegnato**, la runa o la
/// carta, che e' deterministico e non si ripesca: sta dentro il testo che si
/// passa al modello, quindi lui lo vede e ci lavora sopra invece di estrarne
/// un altro.
library;

abstract final class SeguitoDellaLettura {
  /// L'istruzione che accompagna la seconda chiamata.
  ///
  /// [gia] e' cio' che la persona ha gia' letto: il modello lo riceve per
  /// intero, perche' non si continua un discorso che non si e' visto.
  static String istruzione(String gia) => [
        'LA PERSONA HA CHIESTO DI SCENDERE PIÙ A FONDO.',
        'Questo è ciò che le hai già detto e che lei ha già letto:',
        '"""',
        gia.trim(),
        '"""',
        'ADESSO SCRIVI SOLTANTO IL SEGUITO:',
        '- Continua da dove ti sei fermato. Non riassumere, non riformulare, '
            'non ripetere con altre parole ciò che hai già detto: chi rilegge '
            'due volte la stessa cosa si sente preso in giro.',
        '- Riparti dallo stesso ancoraggio e dallo stesso simbolo che hai già '
            'consegnato, la runa o la carta o il transito: quello è già stato '
            'dato e non si cambia. Se ne nominassi un altro, la lettura si '
            'contraddirebbe.',
        '- Non riscrivere la riga finale col carattere speciale: quella resta '
            'quella di prima. Sta in fondo.',
        '- Attacca direttamente col contenuto, senza aperture del tipo '
            '"come dicevo" o "riprendendo".',
      ].join('\n');

  /// LE FRASI DI UN TESTO, tagliate a fine frase.
  static List<String> frasiDi(String testo) {
    final fuori = <String>[];
    final t = testo.trim();
    var da = 0;
    for (var i = 0; i < t.length; i++) {
      if (!const ['.', '!', '?', '…'].contains(t[i])) continue;
      final dopo = i + 1 < t.length ? t[i + 1] : ' ';
      if (dopo != ' ' && dopo != '\n') continue;
      final frase = t.substring(da, i + 1).trim();
      if (frase.isNotEmpty) fuori.add(frase);
      da = i + 1;
    }
    final coda = t.substring(da).trim();
    if (coda.isNotEmpty) fuori.add(coda);
    return fuori;
  }

  /// La forma con cui si confrontano due frasi: minuscole, senza punteggiatura
  /// e senza spazi doppi. Due frasi che dicono la stessa cosa con una virgola
  /// in piu' sono la stessa frase per chi legge.
  static String impronta(String frase) => frase
      .toLowerCase()
      .replaceAll(RegExp(r'[^\wàèéìòùÀÈÉÌÒÙ ]'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  /// IL SEGUITO RIPULITO DA CIO' CHE LA PERSONA HA GIA' LETTO.
  ///
  /// **Perche' l'app controlla invece di fidarsi.** L'istruzione dice al
  /// Maestro di non ripetersi, e un'istruzione non e' una garanzia. Qui le
  /// frasi che compaiono gia' nel primo strato vengono tolte, e non e' un
  /// ripiego muto: e' l'unica cosa onesta da fare con un testo che ripete, e
  /// la prova che sorveglia questa regola conta quante frasi sono state tolte.
  static String pulisci({required String gia, required String seguito}) {
    final viste = frasiDi(gia).map(impronta).toSet();
    final tenute = <String>[];
    for (final frase in frasiDi(seguito)) {
      final f = impronta(frase);
      if (f.isEmpty || viste.contains(f)) continue;
      tenute.add(frase);
      viste.add(f);
    }
    return tenute.join(' ').trim();
  }

  /// Quante frasi del seguito ripetevano il primo strato. Serve alla prova e
  /// al pannello di diagnostica: un numero che cresce dice che l'istruzione
  /// non sta reggendo, e va corretta nel prompt invece che qui.
  static int quanteRipetute({required String gia, required String seguito}) {
    final viste = frasiDi(gia).map(impronta).toSet();
    var quante = 0;
    for (final frase in frasiDi(seguito)) {
      if (viste.contains(impronta(frase))) quante++;
    }
    return quante;
  }
}
