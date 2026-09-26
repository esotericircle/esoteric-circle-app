/// LA DETTATURA DEL MESSAGGIO, e i suoi confini. Ordine CI voce 05.
///
/// **Cosa fa e cosa NON fa.** Riempie il campo della domanda con quello che la
/// persona dice. Non invia: la persona resta padrona della domanda e la puo'
/// rileggere, correggere e cancellare, esattamente come per i tre inviti.
///
/// **Non consuma niente.** Dettare e' un modo di SCRIVERE, non una domanda in
/// piu': non tocca nessun contatore. Si paga una risposta, mai un modo di
/// scrivere.
///
/// **Non costa niente e non manda audio da nessuna parte.** Il riconoscimento
/// e' quello della piattaforma, su iOS il framework Speech e su Android il
/// riconoscitore di sistema. Nessun servizio a pagamento, e soprattutto
/// **nessun audio verso i nostri server**.
///
/// **Perche' esiste questa astrazione e non si chiama il plugin dalle
/// schermate.** Per due ragioni misurabili. La prima: il microfono NON deve
/// comparire dove la piattaforma non sa riconoscere la voce, e quel "sa" e'
/// una domanda che va fatta a qualcuno; un comando che non funziona e' peggio
/// di un comando assente. La seconda: le prove montano la chat continuamente,
/// e un plugin che parla col sistema operativo dentro una prova o esplode o
/// resta muto, quindi serve una dettatura spenta che risponda "non ci sono"
/// senza far cadere niente.
library;

/// A che punto sta la dettatura, per chi la mostra.
enum StatoDellaDettatura {
  /// Ferma, pronta a partire.
  ferma,

  /// Sta ascoltando: il microfono si mostra acceso.
  ascolta,
}

/// La porta della dettatura. Una sola, e le schermate conoscono solo questa.
abstract class Dettatura {
  const Dettatura();

  /// **Se il microfono si deve mostrare o no.**
  ///
  /// Va chiesta PRIMA di disegnare il comando, e la risposta decide se il
  /// comando esiste. Non si mostra spento e non si mostra con un avviso:
  /// l'ordine e' esplicito, un comando che non funziona e' peggio di un
  /// comando assente.
  ///
  /// **Non chiede nessun permesso**: sapere se la piattaforma riconosce la
  /// voce e' un'altra domanda dal poter usare il microfono, e il permesso si
  /// chiede al primo tocco e mai prima, come vuole la sezione 25 delle Linee
  /// Guida UX.
  Future<bool> disponibile();

  /// **ACCENDE IL RICONOSCITORE, ed e' QUI che il permesso si chiede.**
  ///
  /// Si chiama al primo tocco sul microfono e mai prima. Torna vero quando il
  /// riconoscitore e' pronto, cioe' quando la persona ha detto di si': e' la
  /// risposta che `PortaDelPermesso` usa per capire se il permesso c'e', e
  /// per questo non deve mai essere un si' di comodo.
  Future<bool> accendi();

  /// Comincia ad ascoltare. [parole] arriva a ogni aggiornamento, anche
  /// parziale, cosi' il campo si riempie mentre si parla.
  ///
  /// Torna falso quando l'ascolto non e' partito, per esempio perche' il
  /// permesso non c'e'.
  Future<bool> ascolta({
    required void Function(String parole) parole,
    required void Function() finito,
  });

  /// Smette di ascoltare. Quello che e' gia' stato scritto resta nel campo.
  Future<void> ferma();
}

/// LA DETTATURA CHE NON C'E'.
///
/// E' il valore di partenza ovunque: nelle prove, e in qualunque punto che
/// non abbia ricevuto quella vera. Dice di non essere disponibile, quindi il
/// microfono non compare e nessuno tocca niente.
class DettaturaSpenta extends Dettatura {
  const DettaturaSpenta();

  @override
  Future<bool> disponibile() async => false;

  @override
  Future<bool> accendi() async => false;

  @override
  Future<bool> ascolta({
    required void Function(String parole) parole,
    required void Function() finito,
  }) async =>
      false;

  @override
  Future<void> ferma() async {}
}
