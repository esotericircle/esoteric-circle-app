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
      id: 'scelta',
      tema: 'Una scelta da fare',
      testo: 'Ho una scelta davanti e non so da che parte guardare.',
    ),
    DomandaScritta(
      id: 'persona',
      tema: 'Una persona',
      testo: 'C\'è una persona di cui non so che posto ha per me.',
    ),
    DomandaScritta(
      id: 'blocco',
      tema: 'Un blocco che non si supera',
      testo: 'C\'è qualcosa che non riesco a superare e ci torno sopra.',
    ),
    DomandaScritta(
      id: 'attesa',
      tema: 'Un tempo che non arriva',
      testo: 'Sto aspettando qualcosa che non arriva.',
    ),
    DomandaScritta(
      id: 'direzione',
      tema: 'Una direzione da prendere',
      testo: 'Non so dove sto andando e vorrei una direzione.',
    ),
    DomandaScritta(
      id: 'finito',
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
      // Dal secondo viaggio in poi la domanda e' la porta.
      return 'Dal secondo viaggio si scende con una domanda. Scrivila, '
          'sceglila fra quelle qui sotto, oppure scendi solo per incontrarlo.';
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
    required this.id,
    required this.tema,
    required this.testo,
  });

  /// L'id stabile, che finisce nel Diario e nella memoria.
  final String id;

  /// Il tema, cioe' l'etichetta breve che si legge nell'elenco.
  final String tema;

  /// La domanda per esteso, che e' quella che scende.
  final String testo;
}
