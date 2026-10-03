import '../../../core/chat/la_lettura_del_giorno.dart';
import '../../../core/maestro/maestro.dart';
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
/// intera**: mai un taglio in mezzo a una frase.
///
/// **QUATTRO FRASI QUANDO LA DOMANDA HA PIU' PARTI. Ordine ET voce 06, 28
/// settembre 2026**, decisione del fondatore sul consiglio dell'Architetto
/// (*"ER.12: quattro frasi quando la domanda ha più parti."*, *"Confermo,
/// dobbiamo risolvere tutto."*). Nel merito alla cieca il taglio a tre perdeva
/// un turno per giro, e tutti e due erano domande con piu' parti: *"Mia madre
/// dice che è una follia partire. Cosa le rispondo?"* perdeva *"Parla del tuo
/// sentiero, non del suo"*, la domanda coi tre desideri la parte sul lavoro.
///
/// **E LA CHAT DICE LE STESSE PAROLE. Ordine ET voce 02.** Il fondatore: *"la
/// trascrizione nella chat era diversa e più corta"*. Prima la voce e il video
/// dicevano il taglio e la conversazione scritta teneva la risposta intera:
/// due testi diversi dello stesso turno. Adesso il controller salva nel LIVE
/// la forma scritta del taglio ([scritta]), e la voce e il video la prendono
/// da li': un testo solo per le tre cose.
abstract final class LeTreFrasiDelLive {
  /// Quante frasi dice il Maestro a una domanda con una parte sola.
  static const int quante = 3;

  /// Quante frasi dice il Maestro a una domanda con piu' parti (ET.06).
  static const int quanteConPiuParti = 4;

  /// **UNA DOMANDA CON PIU' PARTI.** Piu' di una frase di almeno due parole
  /// (un fatto e poi la domanda, o due domande), piu' di un punto
  /// interrogativo, o piu' desideri elencati ("vorrei..., vorrei... e
  /// vorrei..."). Una frase sola con un'alternativa ("scrivergli io o
  /// aspettare?") e' una parte sola; un saluto di una parola non conta.
  static bool haPiuParti(String? domanda) {
    if (domanda == null || domanda.trim().isEmpty) return false;
    final frasi = frasiDi(domanda)
        .where((f) => RegExp(r'[A-Za-zÀ-ÿ]+').allMatches(f).length >= 2)
        .length;
    if (frasi >= 2) return true;
    if ('?'.allMatches(domanda).length >= 2) return true;
    return RegExp(r'\b(vorrei|voglio|desidero)\b', caseSensitive: false)
            .allMatches(domanda)
            .length >=
        2;
  }

  /// Quante frasi dice il Maestro a [domanda].
  static int quanteFrasiPer(String? domanda) =>
      haPiuParti(domanda) ? quanteConPiuParti : quante;

  /// Le frasi di [testo], come la voce le separa.
  static List<String> frasiDi(String testo) => RegExp(
        r'[^.!?…]+[.!?…]+|[^.!?…]+$',
      )
          .allMatches(testo)
          .map((m) => m.group(0)!.trim())
          .where((f) => RegExp(r'[A-Za-zÀ-ÿ0-9]').hasMatch(f))
          .toList();

  /// **Le parole che il Maestro dice nel LIVE**, pronte per la voce e per lo
  /// schermo: senza stella, senza markdown, al massimo tre frasi intere,
  /// quattro se [domanda] ha piu' parti.
  ///
  /// **[inArrivo]**: il testo sta ancora arrivando e la stella puo' non
  /// esserci ancora. Allora ci si ferma alle prime due frasi del corpo, cosi'
  /// quello che si e' gia' scritto a video non sparisce quando arriva il
  /// gesto.
  static String di(String scritto, {bool inArrivo = false, String? domanda}) {
    final t = _taglio(scritto, inArrivo: inArrivo, domanda: domanda);
    return [...t.corpo, if (t.gesto != null) t.gesto!].join(' ');
  }

  /// **LA FORMA SCRITTA DEL TAGLIO**, quella che la chat salva nel LIVE
  /// (ordine ET voce 02): le stesse frasi che la voce dice, col gesto sulla
  /// sua riga con ✦. `di(scritta(x, domanda: d), domanda: d)` e'
  /// `di(x, domanda: d)`: voce, video e chat dicono le stesse parole.
  static String scritta(String scritto, {String? domanda}) {
    final t = _taglio(scritto, domanda: domanda);
    final corpo = t.corpo.join(' ');
    if (t.gesto == null) return corpo;
    return corpo.isEmpty ? '✦ ${t.gesto}' : '$corpo\n✦ ${t.gesto}';
  }

  static ({List<String> corpo, String? gesto}) _taglio(String scritto,
      {bool inArrivo = false, String? domanda}) {
    // **LA LETTURA RIDETTA DICE LA PREMESSA E POI LA LETTURA.** Visto sul
    // Realme il 30 settembre 2026, nel LIVE di Medora: alla domanda gia'
    // fatta la mattina la voce diceva *"Me l'hai già chiesto oggi. Il cielo
    // non si è mosso da allora: la lettura resta questa."* e poi soltanto il
    // gesto, *"Osserva nel tuo cielo..."*: la premessa sono due frasi, e il
    // taglio alle prime due frasi del corpo si fermava li'. La risposta, *"Le
    // carte e il tuo cielo dicono di sì, se..."*, non si sentiva, in 9
    // letture ridette su 16. Padre: ordine ER voce 12 (la voce che si ferma
    // alla terza frase) sopra l'ordine DS voce 08 (la lettura ridetta). La
    // premessa resta intera e non si conta; il taglio si fa sulla lettura.
    final testa = scritto.trimLeft();
    for (final maestro in Maestro.values) {
      final premessa = LaLetturaDelGiorno.premessaDi(maestro);
      if (!testa.startsWith(premessa)) continue;
      final t = _taglio(testa.substring(premessa.length),
          inArrivo: inArrivo, domanda: domanda);
      return (corpo: [premessa, ...t.corpo], gesto: t.gesto);
    }
    final massimo = quanteFrasiPer(domanda);
    final stella = scritto.indexOf('✦');
    final corpo = stella < 0 ? scritto : scritto.substring(0, stella);
    final gesto = stella < 0 ? '' : scritto.substring(stella + 1);
    final frasiDelCorpo = frasiDi(IlParlatoDelMaestro.daDire(corpo));
    final frasiDelGesto = frasiDi(IlParlatoDelMaestro.daDire(gesto));
    if (frasiDelGesto.isNotEmpty) {
      return (
        corpo: frasiDelCorpo.take(massimo - 1).toList(),
        gesto: !inArrivo || stella >= 0 ? frasiDelGesto.first : null,
      );
    }
    return (
      corpo: frasiDelCorpo.take(inArrivo ? massimo - 1 : massimo).toList(),
      gesto: null,
    );
  }
}
