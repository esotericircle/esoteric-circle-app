import 'chat_message.dart';

/// QUALE RISPOSTA STA APERTA, e quali si sono raccolte.
///
/// **L'idea e' del fondatore, con una correzione sul momento.** Una risposta
/// che si chiude appena l'hai letta ti toglie di mano quello che ti e' appena
/// stato dato, e nessuno sa dire quando l'hai letta: non esiste un segnale
/// affidabile per "ha finito di leggere". Il momento giusto e' un altro e non
/// ha bisogno di indovinare niente: **le risposte si raccolgono quando ne
/// arriva una NUOVA**. Fino ad allora quella che hai in mano resta in mano.
///
/// Funzioni pure: si provano senza montare uno schermo.
class RaccoltaDelleRisposte {
  const RaccoltaDelleRisposte._();

  /// Dove sta la risposta VIVA, cioe' l'ultima lettura vera. Meno di zero
  /// quando non ce n'e' nessuna.
  ///
  /// Si contano le sole letture vere, non tutte le bolle del Maestro: un
  /// ripiego o il messaggio del limite sono due righe, non c'e' niente da
  /// raccogliere, e farli passare per "l'ultima risposta" richiuderebbe la
  /// lettura vera che sta appena sopra. La regola non e' nuova ed e' gia' nel
  /// dato del messaggio: [ChatMessage.portaUnResponso].
  static int indiceDellaViva(List<ChatMessage> messaggi) {
    for (var i = messaggi.length - 1; i >= 0; i--) {
      if (messaggi[i].isMaestro && messaggi[i].portaUnResponso) return i;
    }
    return -1;
  }

  /// Vero se la risposta in [indice] si puo' raccogliere, cioe' e' una lettura
  /// vera che non e' piu' quella viva.
  ///
  /// **L'ultima non si raccoglie mai**, nemmeno a mano: e' quella che la
  /// persona sta leggendo adesso, e darle un modo di sparire sarebbe
  /// esattamente il difetto che questa regola esiste per evitare.
  static bool siPuoRaccogliere(List<ChatMessage> messaggi, int indice) {
    if (indice < 0 || indice >= messaggi.length) return false;
    final m = messaggi[indice];
    if (!m.isMaestro || !m.portaUnResponso) return false;
    return indice != indiceDellaViva(messaggi);
  }

  /// Vero se la risposta in [indice] e' aperta adesso.
  ///
  /// [riaperte] sono quelle che la persona ha riaperto col tocco. Le chiavi
  /// sono INDICI, e reggono perche' la conversazione si scrive solo in coda:
  /// aggiungere un messaggio non sposta quelli di prima, e sostituire l'ultimo
  /// nemmeno. Se un giorno si potesse cancellare un turno in mezzo, questa
  /// riga andrebbe rifatta, e questo commento e' il posto dove accorgersene.
  static bool eAperta(
    List<ChatMessage> messaggi,
    int indice, {
    required Set<int> riaperte,
  }) {
    if (!siPuoRaccogliere(messaggi, indice)) return true;
    return riaperte.contains(indice);
  }
}
