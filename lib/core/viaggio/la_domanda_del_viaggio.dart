/// **LA DOMANDA CON CUI SI SCENDE.** Ordine DC voce 05, 10 settembre 2026.
///
/// **Il principio**: *"nello sciamanesimo non si scende per curiosita'"*. Ogni
/// viaggio si apre con una domanda, e la domanda e' cio' che rende la scena
/// una risposta invece che un'immagine.
///
/// **TRE VIE, TUTTE PRESENTI, e nessuna e' la via povera.**
///
/// **Il campo libero** e' per chi ha una domanda sua, ed e' una riga sola: una
/// domanda che non sta in una riga non e' ancora una domanda.
///
/// **Le sei gia' scritte** sono per chi non sa cosa chiedere, che e' la
/// maggioranza delle volte in cui una persona apre un'app come questa. Non
/// sono esempi: sono le domande vere.
///
/// **"Scendo soltanto per incontrarlo"** e' la terza via, e non e' una
/// rinuncia: in quel caso la scena riguarda il momento che la persona sta
/// vivendo, letto dalla memoria.
///
/// **Al primo viaggio la domanda e' facoltativa. Dal secondo in poi e' la
/// porta**, e l'ordine lo dice per nome.
abstract final class LaDomandaDelViaggio {
  /// **LE SEI DOMANDE GIA' SCRITTE.**
  ///
  /// L'ordine le detta per tema, e i temi *"tornano sempre"*: una scelta da
  /// fare, una persona, un blocco che non si supera, un tempo che non arriva,
  /// una direzione da prendere, qualcosa che e' finito.
  ///
  /// **Sono scritte in prima persona e senza promettere una risposta**: chi
  /// scende porta giu' la sua domanda, non ne riceve una gia' risolta.
  static const List<DomandaScritta> gliaScritte = [
    DomandaScritta(
      chiave: TemaDellaDomanda.scelta,
      tema: 'Una scelta da fare',
      testo: 'Ho una scelta davanti e non so da che parte guardare.',
    ),
    DomandaScritta(
      chiave: TemaDellaDomanda.persona,
      tema: 'Una persona',
      testo: 'C\'è una persona di cui non so che posto ha per me.',
    ),
    DomandaScritta(
      chiave: TemaDellaDomanda.blocco,
      tema: 'Un blocco che non si supera',
      testo: 'C\'è qualcosa che non riesco a superare e ci torno sopra.',
    ),
    DomandaScritta(
      chiave: TemaDellaDomanda.attesa,
      tema: 'Un tempo che non arriva',
      testo: 'Sto aspettando qualcosa che non arriva.',
    ),
    DomandaScritta(
      chiave: TemaDellaDomanda.direzione,
      tema: 'Una direzione da prendere',
      testo: 'Non so dove sto andando e vorrei una direzione.',
    ),
    DomandaScritta(
      chiave: TemaDellaDomanda.finito,
      tema: 'Qualcosa che è finito',
      testo: 'Qualcosa è finito e non so cosa farne.',
    ),
  ];

  /// **LA TERZA VIA**, che non e' una rinuncia.
  static const String soloPerIncontrarlo = 'Scendo soltanto per incontrarlo.';

  /// L'id della terza via, per il Diario.
  static const String idSoloPerIncontrarlo = 'incontro';

  /// **QUANTO PUO' ESSERE LUNGA UNA DOMANDA SCRITTA A MANO.**
  ///
  /// Centoquaranta caratteri, che e' una riga vera su un telefono. Non e' un
  /// limite tecnico: **una domanda che non sta in una riga e' un racconto**, e
  /// chi scende con un racconto non ha ancora deciso cosa chiedere.
  static const int quantoPuoEssereLunga = 140;

  /// Se la domanda scritta va, o **perche' no**. Mai un rifiuto muto.
  static String? perCheNonVa(String domanda, {required bool primoViaggio}) {
    final pulita = domanda.trim();
    if (pulita.isEmpty) {
      if (primoViaggio) return null;
      // Dal secondo viaggio in poi la domanda e' la porta. **Senza dire
      // dove stanno le sei**: la riga e' sotto di loro, e con la via scritta
      // non si vedono. Diceva *"fra quelle qui sotto"*, e *"incontrarlo"*
      // anche della Volpe: ordine DN voce 06.
      return 'Dal secondo viaggio si scende con una domanda. Scrivila, '
          "scegline una delle sei, oppure scendi solo per l'incontro.";
    }
    if (pulita.length > quantoPuoEssereLunga) {
      return 'Tienila in una riga: una domanda che non ci sta è ancora un '
          'racconto.';
    }
    return null;
  }

  /// La domanda con cui la scena verra' composta, quando il campo e' vuoto.
  ///
  /// **Al primo viaggio si scende anche senza**, e allora la scena riguarda il
  /// momento che la persona sta vivendo.
  static String oppureIlMomento(String domanda) {
    final pulita = domanda.trim();
    return pulita.isEmpty ? soloPerIncontrarlo : pulita;
  }
}

/// Una delle sei domande gia' scritte.
class DomandaScritta {
  const DomandaScritta({
    required this.chiave,
    required this.tema,
    required this.testo,
  });

  /// **IL TEMA, COME TIPO.** Ordine DI voce 01, 12 settembre 2026.
  final TemaDellaDomanda chiave;

  /// L'id stabile, che finisce nel Diario e nella memoria.
  ///
  /// **Non si scrive piu' a mano: si legge dall'enum**, cosi' l'id di una
  /// domanda e il tema che le risposte cercano sono la stessa cosa per
  /// costruzione e non per disciplina.
  String get id => chiave.name;

  /// Il tema, cioe' l'etichetta breve che si legge nell'elenco.
  final String tema;

  /// La domanda per esteso, che e' quella che scende.
  final String testo;
}

/// **I SEI TEMI DELLA DOMANDA, COME TIPO E NON COME STRINGA.** Ordine DI voce
/// 01, 12 settembre 2026.
///
/// **Il difetto che chiude, ed e' il difetto capitale del Viaggio.** Lo
/// schermo teneva il tema scelto in una `String`, e toccando una domanda ci
/// scriveva l'**etichetta** per esteso, *"Una scelta da fare"*. La voce del
/// Mondo di Sotto il tema lo cercava per **identificatore**, `scelta`. Le due
/// non combaciavano mai, e il tema arrivava nullo per tutte e tre le vie: le
/// quarantotto forme del titolo, le settantadue risposte e le dodici riprese
/// della domanda **non sono mai state lette da nessun utente**. Chi aveva
/// chiesto *"mia sorella diventera' presto mamma?"* si e' sentito rispondere
/// con la frase scritta per chi non ha chiesto niente.
///
/// **Un tipo non ammette etichette.** Con `TemaDellaDomanda?` al posto di
/// `String`, scrivere l'etichetta dove va il tema **non compila**: il difetto
/// esce dalla categoria di quelli che non danno errori, ed era quella la sua
/// forza.
///
/// I nomi dei sei valori **sono** gli id del Diario e delle risposte:
/// cambiarne uno vuol dire cambiare un dato salvato, e una guardia li tiene
/// fermi.
enum TemaDellaDomanda {
  scelta,
  persona,
  blocco,
  attesa,
  direzione,
  finito;

  /// Il tema che porta questo id, o nullo se l'id non e' uno dei sei.
  ///
  /// **L'unica porta da una stringa al tipo.** Accetta solo un id: passarle
  /// un'etichetta restituisce nullo, e non un tema a caso.
  static TemaDellaDomanda? daId(String? id) {
    for (final t in values) {
      if (t.name == id) return t;
    }
    return null;
  }

  /// L'etichetta per esteso, quella che si legge nell'elenco.
  String get inLettere => LaDomandaDelViaggio.gliaScritte
      .firstWhere((d) => d.chiave == this)
      .tema;
}
