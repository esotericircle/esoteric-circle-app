import '../astro/prossimi_eventi.dart';
import '../astro/lingua_degli_eventi.dart';

/// **IL PONTE FRA IL MOTORE DELLE DATE E IL CONTESTO DEI MAESTRI.**
/// Ordine CQ voce 2.15, 4 settembre 2026.
///
/// **Il fatto, e sta scritto nel manifesto dell'ordine CP.** La regola 8 del
/// fondatore dice che i Maestri devono sapere cosa sta arrivando. Il motore
/// delle date esisteva gia', `ProssimiEventi`, con un orizzonte di
/// quattrocento giorni, e lo usavano il Calendario e la barra dell'identita':
/// **il ponte verso il contesto delle chat no.** Chiedere a Medora "cosa mi
/// aspetta" otteneva una risposta che non sapeva niente delle date vere.
///
/// **Cosa passa di qui, e cosa no.**
///
/// - Passano **fino a tre eventi**, i piu' vicini nel tempo, col nome in
///   parole e con quanti giorni mancano. Tre e non dieci: un elenco lungo
///   dentro un'istruzione di sistema diventa rumore che il modello ripete, e
///   la regola dei due strati vuole che il Maestro parli, non che legga un
///   calendario.
/// - Passa **il prossimo gradino del Cammino**, quando c'e', col suo nome e
///   con cosa apre. E' l'altra meta' della domanda "cosa mi aspetta": una
///   riguarda il cielo, l'altra la persona.
/// - **Non passa nessuna promessa.** Le righe dicono che cosa succede e
///   quando, mai che cosa produrra': e' la stessa legge che governa i testi
///   dei Doni, e qui vale doppio perche' un modello che riceve una data
///   accanto a un esito li lega da solo.
///
/// **Se non c'e' niente, non c'e' nessuna riga.** Un blocco vuoto con un
/// titolo insegna al modello che quella sezione esiste e va riempita, ed e' il
/// modo piu' rapido di farsi inventare un evento.
class CioCheArriva {
  const CioCheArriva._();

  /// Quanti eventi entrano nel contesto. Dichiarato qui perche' la guardia lo
  /// legge invece di ricopiarlo.
  static const int quantiEventi = 3;

  /// Il blocco da mettere nell'istruzione di sistema, oppure la stringa vuota.
  ///
  /// [eventi] arrivano gia' ordinati da `ProssimiEventi.da`, che li da' in
  /// ordine cronologico: qui si prendono i primi e non si riordina niente.
  static String blocco({
    List<EventoInArrivo> eventi = const [],
    String? prossimoTraguardo,
    String? cosaApre,
  }) {
    final righe = <String>[];
    for (final e in eventi.take(quantiEventi)) {
      righe.add('- ${LinguaDegliEventi.nomeDi(e.evento)}: ${_quando(e)}.');
    }
    // **COSA APRE NON ARRIVA PIU' AL MAESTRO**, ordine ES voce 18. Il corpus
    // dei Traguardi dice per ogni passo "che cosa apre", ma nell'app nessun
    // traguardo sblocca niente, e su 165 testi 99 descrivono funzioni che
    // non esistono ("il quaderno dei sogni", "la lettura dei sogni
    // ricorrenti", "la croce celtica a dieci carte"), 31 sono dubbi e 35
    // nominano funzioni gia' aperte a tutti. Il Maestro li prometteva alla
    // persona. Il nome del passo basta a dire dove sta andando il suo
    // Cammino; [cosaApre] resta nella firma per chi lo passa e non entra
    // nell'istruzione. L'ordine CQ voce 2.15 lo voleva dentro, sulla
    // premessa che il passo aprisse qualcosa: la premessa era falsa
    // (docs/collaudo/ES/cosa_apre.txt).
    if (prossimoTraguardo != null && prossimoTraguardo.trim().isNotEmpty) {
      righe.add('- Il prossimo passo del suo Cammino si chiama '
          '"$prossimoTraguardo".');
    }
    if (righe.isEmpty) return '';
    return [
      'CIÒ CHE ARRIVA. Lo sai perché è calcolato dal cielo vero e dal '
          'suo Cammino:',
      ...righe,
      'Nominane al massimo uno. Solo se c\'entra con ciò che ti sta '
          'chiedendo. Non promettere nessun esito: di\' che cosa succede e '
          'quando, mai che cosa produrrà.',
    ].join('\n');
  }

  /// Quanti giorni mancano, detto come lo direbbe una persona.
  static String _quando(EventoInArrivo e) {
    if (e.fraQuantiGiorni <= 0) return 'oggi';
    if (e.fraQuantiGiorni == 1) return 'domani';
    if (e.fraQuantiGiorni < 14) return 'fra ${e.fraQuantiGiorni} giorni';
    if (e.fraQuantiGiorni < 60) {
      return 'fra ${(e.fraQuantiGiorni / 7).round()} settimane';
    }
    return 'fra ${(e.fraQuantiGiorni / 30).round()} mesi';
  }
}
