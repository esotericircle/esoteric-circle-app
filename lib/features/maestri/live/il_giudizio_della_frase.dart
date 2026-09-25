/// **COSA FARE DI UNA FRASE APERTA SU UN SUONO CONTINUO.** Ordine EM voce 04,
/// secondo giro, 25 settembre 2026.
///
/// Il fondatore: *"Io uso "Ok Google" giornalmente con TV accesa e gemini
/// riconosce la mia voce Senza problemi. Ho bisogno dello stesso livello di
/// accuratezza e tolleranza"*. Sul Realme una televisione ha tenuto aperta
/// una frase per 141,6 secondi: il livello da solo non basta a distinguere
/// chi parla al telefono da una voce che non si ferma mai. Quando una frase
/// resta aperta su un suono continuo, `IlSilenzioVero` chiede un controllo,
/// la schermata fa trascrivere cio' che e' stato detto finora, e qui si
/// decide:
///
/// - **niente parole**: era solo sottofondo. La frase si scarta, e la stanza
///   impara il suo livello: la televisione non apre piu' frasi;
/// - **parole che crescono**: la persona sta ancora parlando, si aspetta;
/// - **parole che non crescono piu'** da un controllo all'altro: la persona
///   ha finito, e la televisione sotto teneva aperta la frase. Si chiude e
///   si manda, con la trascrizione gia' pronta.
///
/// Le pause di pensiero in una stanza silenziosa non chiedono controlli,
/// perche' tornano vicino al fondo: una persona che dice "ehm" e poi tace non
/// viene mai chiusa da qui.
class IlGiudizioDellaFrase {
  int? _frase;
  int _parolePrima = -1;
  int _controlloPrima = 0;

  /// Il controllo numero [controllo] della frase [frase] e' tornato con
  /// [testo], la trascrizione gia' ripulita.
  CosaFareDellaFrase giudica({
    required int frase,
    required int controllo,
    required String testo,
  }) {
    final parole = contaLeParole(testo);
    if (parole == 0) {
      _frase = null;
      _parolePrima = -1;
      _controlloPrima = 0;
      return CosaFareDellaFrase.scarta;
    }
    final stessa = _frase == frase;
    // Un controllo vecchio tornato dopo uno piu' nuovo non conta: con meno
    // parole sembrerebbe una persona che ha finito.
    if (stessa && controllo <= _controlloPrima) {
      return CosaFareDellaFrase.aspetta;
    }
    final ferme = stessa && _parolePrima >= 0 && parole <= _parolePrima;
    _frase = frase;
    _parolePrima = parole;
    _controlloPrima = controllo;
    return ferme && controllo >= 2
        ? CosaFareDellaFrase.chiudi
        : CosaFareDellaFrase.aspetta;
  }

  /// Le parole di un testo: le sequenze di lettere.
  static int contaLeParole(String testo) =>
      RegExp(r'\p{L}+', unicode: true).allMatches(testo).length;
}

/// Le tre decisioni di [IlGiudizioDellaFrase].
enum CosaFareDellaFrase {
  /// Solo sottofondo: la frase si butta e la stanza impara.
  scarta,

  /// La persona sta ancora parlando.
  aspetta,

  /// La persona ha finito: la frase parte.
  chiudi,
}
