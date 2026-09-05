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
        '- Il testo qui sopra RESTA SULLO SCHERMO mentre tu scrivi: la persona '
            'lo sta leggendo adesso e quello che scrivi tu si aggiunge sotto. '
            'Quindi non ricominciare e non riprendere il filo dall\'inizio: '
            'scrivi solo le frasi NUOVE, quelle che sotto ancora non ci sono.',
        '- Riparti dallo stesso ancoraggio e dallo stesso simbolo che hai già '
            'consegnato, la runa o la carta o il transito: quello è già stato '
            'dato e non si cambia. Se ne nominassi un altro, la lettura si '
            'contraddirebbe.',
        '- Non riscrivere la riga finale col carattere speciale: quella resta '
            'quella di prima. Sta in fondo.',
        '- Attacca direttamente col contenuto, senza aperture del tipo '
            '"come dicevo" o "riprendendo".',
      ].join('\n');

  /// LE PAROLE DI UNA FRASE, per confrontarne il senso invece della forma.
  static Set<String> paroleDi(String frase) =>
      impronta(frase).split(' ').where((p) => p.isNotEmpty).toSet();

  /// QUANTO DUE FRASI DICONO LA STESSA COSA, da 0 a 1.
  ///
  /// **Perche' il confronto esatto non bastava.** Il filtro di prima teneva
  /// un'impronta per frase e scartava le identiche: contro un modello che
  /// riscrive la stessa cosa con altre parole non serviva a niente, perche' la
  /// parafrasi ha un'impronta diversa e passava intera. E' misurato, non
  /// supposto: vedi la calibrazione in [sogliaDiRipetizione].
  ///
  /// La misura e' il rapporto fra le parole in comune e le parole in tutto.
  /// Frasi con parole quasi tutte in comune dicono quasi la stessa cosa,
  /// comunque siano girate.
  static double somiglianza(String a, String b) {
    final pa = paroleDi(a);
    final pb = paroleDi(b);
    if (pa.isEmpty || pb.isEmpty) return 0;
    return pa.intersection(pb).length / pa.union(pb).length;
  }

  /// LA SOGLIA OLTRE LA QUALE DUE FRASI SONO LA STESSA FRASE.
  ///
  /// **CALIBRATA SU CHIAMATE VERE**, non scelta a occhio. Il 4 agosto 2026,
  /// con `flutter test tool/risposte_intere.dart` e `QUANTE_DOMANDE=6`, sono
  /// state prese sei coppie vere (primo strato, seguito) e sono state misurate
  /// tutte e quarantaquattro le frasi di seguito contro tutte le frasi del
  /// primo strato. I due estremi che decidono:
  ///
  /// - la piu' alta fra due frasi che dicono cose DIVERSE e' 0,286: "Per te io
  ///   leggo la runa Raido, il viaggio e il suo ritmo" contro "Per te io leggo
  ///   il presagio di un nuovo inizio, che attende oltre la nebbia";
  /// - la piu' bassa fra due che dicono la STESSA cosa e' 0,348: "il tuo
  ///   Cancro lunare puo' sentirsi smarrito, ma il Leone solare non cede il
  ///   suo trono" contro "il tuo Cancro lunare sente il richiamo del rifugio,
  ///   ma il Leone solare cerca la sua via".
  ///
  /// La soglia sta in mezzo, arrotondata al centesimo.
  ///
  /// **E LE DUE POPOLAZIONI SI TOCCANO QUASI**, va detto: sessantadue
  /// millesimi di distanza, non un abisso. Sotto 0,286 restano parafrasi
  /// deboli che passano, e questa soglia non le prende. Prende quelle che si
  /// vedono a occhio nudo, e quelle bastano a togliere la sensazione di
  /// rileggere. Sulle sei coppie vere ha tolto 156 parole che il filtro per
  /// identita' esatta lasciava passare intere, senza mai svuotare un seguito:
  /// il piu' corto restava di 85 parole.
  static const double sogliaDiRipetizione = 0.32;

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
    final viste = frasiDi(gia).toList();
    final tenute = <String>[];
    for (final frase in frasiDi(senzaLaRigaDelConsiglio(seguito))) {
      if (impronta(frase).isEmpty) continue;
      if (_giaDetta(frase, viste)) continue;
      tenute.add(frase);
      viste.add(frase);
    }
    return tenute.join(' ').trim();
  }

  /// Vero se [frase] dice quello che una delle [viste] dice gia'.
  static bool _giaDetta(String frase, List<String> viste) {
    for (final vista in viste) {
      if (somiglianza(frase, vista) >= sogliaDiRipetizione) return true;
    }
    return false;
  }

  /// IL SEGUITO SENZA LA RIGA DEL CONSIGLIO.
  ///
  /// Il consiglio in oro e' gia' in fondo alla bolla e non si scrive due
  /// volte. Se il modello lo riscrive, la sua riga si toglie qui: il seguito
  /// deve entrare FRA la prima parte e la stella, non dopo.
  static String senzaLaRigaDelConsiglio(String seguito) => seguito
      .split('\n')
      .where((riga) => !riga.contains('\u2726'))
      .join('\n')
      .trim();

  /// Quante frasi del seguito ripetevano il primo strato. Serve alla prova e
  /// al pannello di diagnostica: un numero che cresce dice che l'istruzione
  /// non sta reggendo, e va corretta nel prompt invece che qui.
  static int quanteRipetute({required String gia, required String seguito}) {
    final viste = frasiDi(gia).toList();
    var quante = 0;
    for (final frase in frasiDi(senzaLaRigaDelConsiglio(seguito))) {
      if (_giaDetta(frase, viste)) quante++;
    }
    return quante;
  }
}
