import '../maestro/consiglio_finale.dart';

/// **UN MAESTRO NON RIPETE UNA RISPOSTA GIA' DATA.** Ordine EN voce 06, 25
/// settembre 2026.
///
/// **Il fatto, dalle catture del fondatore**: alla richiesta *"Prova ancora a
/// rispondergli su via moglie."* Medora ha restituito la stessa risposta
/// parola per parola. La regola c'era, nell'istruzione di sistema da tre
/// ordini (*"Non ripetere una frase che hai già detto in questa
/// conversazione"*), e il modello l'ha ignorata: una regola che dipende da un
/// modello regge quasi sempre, e il fondatore ha trovato il quasi.
///
/// **Qui la si guarda a valle**, come la voce che non si confonde e
/// l'ancoraggio: la risposta nuova si confronta con quelle gia' date nella
/// stessa conversazione, e se ne ricalca una il controller chiede di nuovo,
/// una volta sola, nominando al modello la risposta da non ripetere.
///
/// **La grandezza misurata e' quanta parte della risposta nuova c'era gia'
/// in una vecchia**, parola per parola, contando le parole di quattro lettere
/// o piu': gli articoli e le preposizioni ci sono in ogni risposta e non
/// dicono niente. La riga d'oro si toglie prima, perche' la sorveglia gia'
/// `ConsiglioFinale.righeGiaScritte`.
abstract final class LaRispostaRipetuta {
  /// Oltre questa parte in comune la risposta e' una ripetizione. **Misurata
  /// sul collaudo dell'ordine EN**, `docs/collaudo/EN/risposte/prima/`: nelle
  /// sei conversazioni sulla moglie la seconda risposta, alla richiesta di
  /// riprovare, divideva con la prima dallo 0 al 23 per cento delle parole;
  /// la risposta ricalcata delle catture del fondatore sta al cento. Settanta
  /// sta lontano da tutte e due.
  static const double soglia = 0.7;

  /// Sotto queste parole la risposta non si confronta. **La suite intera
  /// l'ha mostrato alla prima stesura**: due prove di casa rispondono con
  /// *"Una risposta a testo, la numero 2."*, che conta tre parole ed e'
  /// uguale alla numero 1 in tutte e tre; la rete la chiedeva di nuovo, e il
  /// giorno dopo la stessa domanda chiamava il modello due volte. Una
  /// risposta breve che ridice un fatto (*"Il tuo cane si chiama Argo."*,
  /// tre parole) non e' la lettura ricalcata delle catture del fondatore,
  /// che ne contava decine.
  static const int paroleMinime = 8;

  static Set<String> _parole(String testo) => {
        for (final p in ConsiglioFinale.corpoDa(testo)
            .toLowerCase()
            .split(RegExp(r'[^a-zàèéìíòóùú]+')))
          if (p.length > 3) p,
      };

  /// Quanta parte di [nuova] c'era gia' in [vecchia], da zero a uno.
  static double inComune(String nuova, String vecchia) {
    final pn = _parole(nuova);
    if (pn.isEmpty) return 0;
    final pv = _parole(vecchia);
    return pn.where(pv.contains).length / pn.length;
  }

  /// La risposta gia' data che [nuova] ripete, o null se non ne ripete
  /// nessuna.
  ///
  /// Con [domanda] e [domandaPrima] guarda anche la seconda cosa
  /// ([ridiceLaPrecedente]): la risposta di prima, data alla domanda di
  /// prima, ridetta con altre parole.
  static String? quale(String nuova, Iterable<String> giaDate,
      {String domanda = '', String domandaPrima = ''}) {
    if (_parole(nuova).length < paroleMinime) return null;
    String? peggiore;
    var massimo = soglia;
    for (final vecchia in giaDate) {
      final c = inComune(nuova, vecchia);
      if (c >= massimo) {
        massimo = c;
        peggiore = vecchia;
      }
    }
    if (peggiore != null || giaDate.isEmpty || domanda.isEmpty) {
      return peggiore;
    }
    final precedente = giaDate.last;
    return ridiceLaPrecedente(
            domandaPrima: domandaPrima,
            precedente: precedente,
            domanda: domanda,
            nuova: nuova)
        ? precedente
        : null;
  }

  // ---------------------------------------------------------------------------
  // LA RISPOSTA DI PRIMA RIDETTA CON ALTRE PAROLE
  // ---------------------------------------------------------------------------

  /// **LA RISPOSTA NON RIDICE QUELLA DI PRIMA. Ordine ES voce 21.**
  ///
  /// Il fondatore: *"Ho provato a fare Domande simili consecutive e le
  /// risposte, non solo non erano adeguate [...]"*. Al banco delle trenta
  /// domande ci sono cinque coppie di domande simili di fila, e alla lettura
  /// alla cieca le seconde che ripetevano la prima erano 10 su 60 alla
  /// partenza e 6 al giro 5. La misura di sopra non le vede: non ricalcano
  /// parola per parola, ridicono la stessa cosa con altre parole.
  ///
  /// **La misura e' tarata sui giudizi, non inventata.** Sulle 240 seconde di
  /// coppia giudicate alla cieca in quattro fasi del banco
  /// (`docs/collaudo/ES/coppie_ripetute.json`), confrontando le prime tre
  /// frasi delle due risposte senza le parole delle due domande (che due
  /// domande simili condividono per forza) e senza le parole di tutti i
  /// giorni dei Maestri, la soglia di 0,4 prende 13 ripetizioni su 26 e
  /// sbaglia 2 volte su 214. Una soglia piu' bassa ne prendeva di piu' e
  /// sbagliava cinque volte tanto: chiedere di nuovo una risposta buona costa
  /// un'attesa a chi ascolta.
  static const double sogliaDellaPrecedente = 0.4;

  /// Quante frasi di ogni risposta si confrontano.
  static const int frasiDellaPrecedente = 3;

  static const Set<String> _diTuttiIGiorni = {
    'della',
    'delle',
    'dello',
    'degli',
    'nella',
    'nelle',
    'nello',
    'negli',
    'sulla',
    'sulle',
    'dalla',
    'dalle',
    'alla',
    'alle',
    'allo',
    'agli',
    'questa',
    'questo',
    'quella',
    'quello',
    'quelle',
    'quelli',
    'sono',
    'come',
    'dove',
    'quale',
    'quando',
    'mentre',
    'prima',
    'dopo',
    'perché',
    'anche',
    'ancora',
    'sempre',
    'molto',
    'tutto',
    'tutti',
    'tutte',
    'tuoi',
    'essere',
    'avere',
    'fare',
    'cosa',
    'carte',
    'carta',
    'cielo',
    'dicono',
    'leggo',
    'pietre',
    'pietra',
    'centri',
    'centro',
    'energia',
    'corpo',
    'segno',
    'segni',
    'lettura',
    'tempo',
    'momento',
    'parte',
    'senza',
    'dentro',
    'verso',
    'oltre',
    'invece',
    'però',
    'quindi',
    'allora',
  };

  static Set<String> _radici(String testo, [Set<String> via = const {}]) {
    final t = testo.toLowerCase().replaceAll('’', "'");
    return {
      for (final m in RegExp(r'\p{L}+', unicode: true).allMatches(t))
        if (m.group(0)!.length >= 5 && !_diTuttiIGiorni.contains(m.group(0)))
          m.group(0)!.length > 6 ? m.group(0)!.substring(0, 6) : m.group(0)!,
    }.difference(via);
  }

  /// Le prime frasi del corpo, senza la riga col segno.
  static String _inizio(String testo) => testo
      .split('\n')
      .where((r) => r.trim().isNotEmpty && !r.trimLeft().startsWith('✦'))
      .join(' ')
      .split(RegExp(r'(?<=[.!?])\s+'))
      .take(frasiDellaPrecedente)
      .join(' ');

  /// Quanto [nuova] ha in comune con [precedente], da 0 a 1, tolte le parole
  /// delle due domande.
  static double quantoDellaPrecedente({
    required String domandaPrima,
    required String precedente,
    required String domanda,
    required String nuova,
  }) {
    final delleDomande = {..._radici(domanda), ..._radici(domandaPrima)};
    final a = _radici(_inizio(precedente), delleDomande);
    final b = _radici(_inizio(nuova), delleDomande);
    if (a.length < 3 || b.length < 3) return 0;
    return a.intersection(b).length /
        (a.length < b.length ? a.length : b.length);
  }

  /// Vero se [nuova] ridice [precedente] con altre parole.
  static bool ridiceLaPrecedente({
    required String domandaPrima,
    required String precedente,
    required String domanda,
    required String nuova,
  }) =>
      quantoDellaPrecedente(
          domandaPrima: domandaPrima,
          precedente: precedente,
          domanda: domanda,
          nuova: nuova) >=
      sogliaDellaPrecedente;
}
