/// **LE PARTI DI UNA FRASE DEL CORPUS.** Ordine ES, 30 settembre 2026.
///
/// Il fondatore, davanti alle letture dell'Oroscopo: *"all'utente non gliene
/// frega un cazzo dei transiti, quante volte devo scriverlo e chiederlo?
/// Vuole sapere come andrà in generale, in amore, in lavoro, ecc. Se vuoi
/// inserire i transiti, li inserisci dopo giusto per motivare da dove arriva
/// la risposta."* E le Linee Guida, sezione 2: la risposta, che cosa puoi
/// fare, da dove viene; *"il simbolo non apre mai"*, *"il nome arriva nella
/// parte 3"*.
///
/// I corpora della lettura cinese, della vedica e dell'annuale scrivono
/// percio' ogni frase in due pezzi, separati da [separatore]:
///
/// ```
/// TESTO || DA DOVE VIENE
/// ```
///
/// Il **testo** e' la risposta e che cosa fare, in parole di tutti i giorni,
/// senza simboli: e' cio' che la scheda mostra come lettura. Il **da dove
/// viene** nomina il simbolo e la regola della tradizione: la scheda lo mette
/// sotto la lettura, nella riga "Da dove viene". Chi compone una scheda
/// passa da qui, cosi' i due pezzi non si rimescolano.
abstract final class LePartiDelResponso {
  /// Il separatore fra il testo e il "da dove viene", com'e' nei corpora.
  static const String separatore = ' || ';

  /// Il testo e il "da dove viene" di una frase. Una frase senza separatore
  /// e' tutta testo.
  static (String testo, String daDove) di(String frase) {
    final i = frase.indexOf(separatore);
    if (i < 0) return (frase.trim(), '');
    return (
      frase.substring(0, i).trim(),
      frase.substring(i + separatore.length).trim(),
    );
  }

  /// Piu' pezzi in fila, separati da uno spazio, senza i vuoti.
  static String insieme(Iterable<String?> pezzi) => pezzi
      .where((p) => p != null && p.trim().isNotEmpty)
      .map((p) => p!.trim())
      .join(' ');
}
