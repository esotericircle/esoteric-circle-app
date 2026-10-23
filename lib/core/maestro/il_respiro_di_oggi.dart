import '../rituals/filo_del_giorno.dart';
import 'chakra_del_giorno.dart';
import 'memoria_del_respiro.dart';
import '../../core/chat/user_profile.dart';

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
    // **IL GIORNO E' QUELLO DEL RITO**, ordine ES voce 18: fra mezzanotte e
    // le cinque il Sigillo sta ancora chiudendo la sera di ieri, e la riga
    // del respiro spariva proprio li'. Lo stesso confine della parola
    // dell'Alba, `FiloDelGiorno.giornoRituale`.
    final oggi = FiloDelGiorno.giornoRituale(adesso);
    final diOggi = [
      for (final s in memoria.sessioni)
        if (FiloDelGiorno.giornoRituale(s.quando) == oggi) s,
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
      // **CON AURA**, ordine ES voce 18: il respiro viene dalla meditazione
      // di Aura, e dentro il Sigillo di Medora la riga lo dice.
      return LaMarcaDelGenere.risolvi('[Oggi ti sei fermato a respirare|'
          'Oggi ti sei fermata a respirare|Oggi hai respirato] con Aura '
          '$nome. Anche quello è passato per la tua giornata.');
    }
    if (diOggi.length == 1) {
      return 'Oggi hai respirato con Aura $nome. Vedi se è rimasto qualcosa.';
    }
    return 'Oggi hai respirato con Aura ${diOggi.length} volte, $nome. Vedi '
        'se è rimasto qualcosa.';
  }
}
