import 'rune_cast.dart';

/// **IL TITOLO DEL PRESAGIO DI UNA GETTATA.** Ordine FK, aggiunta voce A1, 11
/// ottobre 2026.
///
/// Il fondatore: *"ogni risposta doveva partire da un titolo"*. Il presagio
/// delle rune apriva con l'etichetta "Il presagio di Calìgo", che dice di chi
/// e' la voce e non che cosa dice. Il titolo e' la riga della runa che sta al
/// centro della gettata, nel suo verso (`RunaGettata.riga`): e' la riga con
/// cui la Runa del Tramonto apre il suo responso dall'ordine EH, e non c'e'
/// una parola nuova da scrivere. Al centro perche' nelle gettate a tre rune
/// (le Norne) il centro e' il presente, cioe' quello su cui si chiede; le rune
/// coperte non contano, perche' a video non si leggono.
class IlTitoloDellaGettata {
  const IlTitoloDellaGettata._();

  static String di(EsitoGettata esito) {
    final scoperte = [
      for (final r in esito.rune)
        if (!r.coperta) r,
    ];
    if (scoperte.isEmpty) return '';
    return scoperte[scoperte.length ~/ 2].riga.trim();
  }
}
