/// **IL DETTATO CHE CONTINUA OLTRE LA PRIMA PAUSA.** Ordine EQ, difetto
/// trovato sul Realme il 27 settembre 2026.
///
/// Il fatto: una frase detta per 8,7 secondi alla dettatura della chat e'
/// arrivata nel campo come *"vorrei"*, poi la dettatura ha smesso di
/// ascoltare. Due cose la chiudevano. La prima: il `pauseFor` di tre secondi
/// del plugin non misura il silenzio, misura il tempo dall'ultimo risultato
/// CAMBIATO; su un riconoscitore che manda i parziali radi, una frase lunga si
/// chiudeva alle prime parole. La seconda: il riconoscitore Android ascolta
/// un enunciato alla volta e lo chiude alla prima pausa, e la dettatura
/// prendeva quella chiusura come la fine. Padre: ordine CI voce 05, commit
/// `6c21083c`, che ha scritto il `pauseFor` e la chiusura su "done".
///
/// **La regola, qui e in nessun altro posto.** Quando il riconoscitore
/// chiude un enunciato che ha portato parole, la dettatura ne apre un altro e
/// tiene le parole gia' dette: la persona puo' fermarsi a pensare. Si chiude
/// quando un enunciato intero finisce **senza parole** (la persona ha smesso
/// di parlare), quando la persona tocca lo stop, o dopo [tettoDelDettato].
class IlDettatoCheContinua {
  IlDettatoCheContinua({
    required this.parole,
    required this.finito,
    required this.riapri,
    DateTime Function()? adesso,
  }) : _adesso = adesso ?? DateTime.now {
    _inizio = _adesso();
  }

  /// Il tetto di un dettato intero: una domanda, non un racconto.
  static const Duration tettoDelDettato = Duration(minutes: 1);

  /// Il testo intero, a ogni aggiornamento.
  final void Function(String parole) parole;

  /// La dettatura e' finita.
  final void Function() finito;

  /// Chiede al riconoscitore un enunciato nuovo.
  final void Function() riapri;

  final DateTime Function() _adesso;
  late final DateTime _inizio;

  /// Le parole degli enunciati gia' chiusi.
  final _gia = <String>[];

  /// Le parole dell'enunciato in corso.
  String _corrente = '';
  bool _chiuso = false;
  bool _fermatoDallaPersona = false;

  /// Vero quando il dettato e' finito, per qualunque ragione.
  bool get chiuso => _chiuso;

  /// Il testo intero finora.
  String get testo => [..._gia, if (_corrente.isNotEmpty) _corrente].join(' ');

  /// Il riconoscitore ha mandato il testo dell'enunciato in corso.
  void risultato(String dette) {
    if (_chiuso) return;
    _corrente = dette.trim();
    parole(testo);
  }

  /// Il riconoscitore ha chiuso l'enunciato in corso, per fine della voce o
  /// per un errore.
  void enunciatoChiuso() {
    if (_chiuso) return;
    final aveva = _corrente.isNotEmpty;
    if (aveva) _gia.add(_corrente);
    _corrente = '';
    final scaduto = _adesso().difference(_inizio) >= tettoDelDettato;
    if (!aveva || _fermatoDallaPersona || scaduto) {
      _chiudi();
      return;
    }
    riapri();
  }

  /// La persona ha toccato lo stop: quello che e' detto resta.
  void fermatoDallaPersona() {
    _fermatoDallaPersona = true;
    _chiudi();
  }

  void _chiudi() {
    if (_chiuso) return;
    _chiuso = true;
    finito();
  }
}
