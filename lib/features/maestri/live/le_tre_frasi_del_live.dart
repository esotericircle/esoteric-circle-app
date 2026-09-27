import 'il_parlato_del_maestro.dart';

/// **NEL LIVE IL MAESTRO SI FERMA ALLA TERZA FRASE.** Ordine ER voce 12, 27
/// settembre 2026.
///
/// Sul Realme le risposte del LIVE duravano da 20 a 50 secondi di voce
/// (rapporto dell'ordine EQ): la regola delle tre frasi dell'ordine EN sta
/// nell'istruzione, ma con Flash non basta. Il fondatore ha approvato il
/// consiglio dell'Architetto: *"Da 20 a 50 secondi di voce sono un monologo,
/// mentre tre frasi tengono il merito e ti ridanno la parola."*
///
/// **Quali tre.** La forma del LIVE chiede tre frasi e poi la riga col gesto
/// (✦): il gesto e' il passo concreto, e senza di lui la risposta perde la cosa
/// da fare. Quindi, quando c'e' un gesto, si dicono le prime due frasi del
/// corpo e il gesto; quando non c'e', le prime tre frasi. **Sempre a frase
/// intera**: mai un taglio in mezzo a una frase. La regola vale per la voce e
/// per il testo a video, che mostrano le stesse parole; la conversazione
/// scritta tiene la risposta intera.
abstract final class LeTreFrasiDelLive {
  /// Quante frasi dice il Maestro, al massimo.
  static const int quante = 3;

  /// Le frasi di [testo], come la voce le separa.
  static List<String> frasiDi(String testo) => RegExp(
        r'[^.!?…]+[.!?…]+|[^.!?…]+$',
      )
          .allMatches(testo)
          .map((m) => m.group(0)!.trim())
          .where((f) => RegExp(r'[A-Za-zÀ-ÿ0-9]').hasMatch(f))
          .toList();

  /// **Le parole che il Maestro dice nel LIVE**, pronte per la voce e per lo
  /// schermo: senza stella, senza markdown, al massimo tre frasi intere.
  ///
  /// **[inArrivo]**: il testo sta ancora arrivando e la stella puo' non
  /// esserci ancora. Allora ci si ferma alle prime due frasi del corpo, cosi'
  /// quello che si e' gia' scritto a video non sparisce quando arriva il
  /// gesto.
  static String di(String scritto, {bool inArrivo = false}) {
    final stella = scritto.indexOf('✦');
    final corpo = stella < 0 ? scritto : scritto.substring(0, stella);
    final gesto = stella < 0 ? '' : scritto.substring(stella + 1);
    final frasiDelCorpo = frasiDi(IlParlatoDelMaestro.daDire(corpo));
    final frasiDelGesto = frasiDi(IlParlatoDelMaestro.daDire(gesto));
    final List<String> dette;
    if (frasiDelGesto.isNotEmpty) {
      dette = [
        ...frasiDelCorpo.take(quante - 1),
        if (!inArrivo || stella >= 0) frasiDelGesto.first,
      ];
    } else if (inArrivo) {
      dette = frasiDelCorpo.take(quante - 1).toList();
    } else {
      dette = frasiDelCorpo.take(quante).toList();
    }
    return dette.join(' ');
  }
}
