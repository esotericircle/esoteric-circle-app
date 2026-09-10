import 'chakra_del_giorno.dart';
import 'memoria_del_respiro.dart';

/// **IL RESPIRO DI OGGI, PER CHI CHIUDE LA GIORNATA.** Ordine DA voce 06,
/// 10 settembre 2026.
///
/// **Da dove nasce.** Nel manifesto dell'ordine DB, voce 12, avevo scritto che
/// il Sigillo del Sogno *"e' il rito che chiude la giornata e chiede cosa
/// resta: sapere che quella persona ha respirato stasera, e su quale centro,
/// gli da' la sola cosa che oggi non ha, un fatto della giornata invece di una
/// domanda generica"*. Il fondatore ha detto di procedere.
///
/// **UNA RIGA SOLA, E SOLO SE E' VERA.** E' la stessa legge della voce DB.09:
/// se oggi non si e' respirato, qui non nasce niente e il Sigillo si chiude
/// com'era. **Non si inventa una giornata a chi non l'ha avuta.**
///
/// **E NON CHIEDE NIENTE.** Il Sigillo ha gia' la sua domanda: questa riga
/// porta un fatto, e il fatto e' cio' che rende la domanda meno generica.
abstract final class IlRespiroDiOggi {
  /// La riga da mostrare nel Sigillo del Sogno, o **nulla** quando oggi non
  /// si e' respirato.
  ///
  /// [adesso] e' l'istante da cui si guarda: le prove lo dichiarano invece di
  /// leggere l'orologio, cosi' non c'e' un giorno che cambia sotto la misura.
  static String? laRiga(MemoriaDelRespiro memoria, DateTime adesso) {
    final oggi = _giornoDi(adesso);
    final diOggi = [
      for (final s in memoria.sessioni)
        if (_giornoDi(s.quando) == oggi) s,
    ];
    if (diOggi.isEmpty) return null;
    final compiute = diOggi.where((s) => s.compiuta).length;
    // **Il centro e' quello dell'ultima sessione**, che e' l'ultima cosa che
    // quella persona ha toccato prima di arrivare qui.
    final centro = diOggi.first.centro;
    if (centro < 0 || centro >= ChakraDelGiorno.tutti.length) return null;
    // **Il nome del centro porta gia' il suo articolo**, quindi qui non se ne
    // mette un secondo: la prima stesura diceva "sul il cuore", e l'ha
    // mostrato la guardia stampando la riga invece di limitarsi a contarla.
    final nome = ChakraDelGiorno.tutti[centro].conSu;
    // **Chi ha respirato senza arrivare in fondo non viene corretto.** La
    // riga dice che il respiro c'e' stato, che e' vero, e si ferma li'.
    if (compiute == 0) {
      return 'Oggi ti sei fermato a respirare $nome. Anche quello è '
          'passato per la tua giornata.';
    }
    if (diOggi.length == 1) {
      return 'Oggi hai respirato $nome. Vedi se è rimasto qualcosa.';
    }
    return 'Oggi hai respirato ${diOggi.length} volte, $nome. Vedi se è '
        'rimasto qualcosa.';
  }

  static String _giornoDi(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
