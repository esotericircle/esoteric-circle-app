import '../../../../core/maestro/libreria_dei_respiri.dart';

/// **IL SIGILLO DELLA SESSIONE.** Ordine DD voce 17, 10 settembre 2026.
///
/// **DA DOVE NASCE, ed e' una perdita che va dichiarata.** Fino a oggi la card
/// del respiro disegnava una figura costruita sui **tempi veri** di ogni
/// inspiro e di ogni espiro, misurati mentre il dito stava sullo schermo. Su
/// quella figura la card scriveva *"dodici respiri: nessuno uguale al
/// precedente"*, e la promessa reggeva: due persone non hanno mai la stessa
/// serie di millisecondi.
///
/// **Il fondatore ha tolto il dito**: *"elimina la possibilita' di tenere il
/// dito premuto, solo pulsante play e stop"*. Senza il dito quei
/// millisecondi non esistono piu', e il fiore va col ritmo dell'app, **uguale
/// per tutti**. Tenere quella frase sarebbe stata la prima bugia di questa
/// funzione.
///
/// **COSA RESTA DI VERO, e basta a fare una figura che cambia.** Una sessione
/// porta quattro dati che nessuno ha inventato:
///
/// - il **sintomo** scelto, dodici possibili;
/// - la **frequenza** che ha suonato;
/// - il **centro** acceso quel giorno, che gira di giorno in giorno;
/// - la **durata vera**, che e' un numero continuo: chi si ferma a due minuti e
///   quarantasette non ha la stessa sessione di chi arriva a quattro e dodici.
///
/// **La figura non promette piu' di essere unica al mondo**, e infatti la card
/// non lo scrive: dice che e' **il sigillo di questa sessione**, che e' vero.
abstract final class SigilloDellaSessione {
  /// **QUANTI RAGGI**, cioe' quanti punti ha la corona. Dalla durata vera: un
  /// raggio ogni dieci secondi respirati, fra sei e ventiquattro.
  ///
  /// **Il minimo e' sei** perche' sotto quella soglia la corona non si legge
  /// come una figura, si legge come un errore; il massimo e' ventiquattro
  /// perche' oltre i raggi si toccano e la forma diventa un cerchio.
  static int quantiRaggi(Duration durata) {
    final grezzi = durata.inSeconds ~/ 10;
    if (grezzi < 6) return 6;
    if (grezzi > 24) return 24;
    return grezzi;
  }

  /// **LA FIGURA, un valore per raggio, da zero a uno.**
  ///
  /// **Deterministica**: la stessa sessione da' lo stesso sigillo, e questo e'
  /// voluto. Chi rifa' la stessa pratica per lo stesso tempo ritrova il suo
  /// segno, e chi cambia sintomo, frequenza o durata ne ottiene un altro.
  ///
  /// **Il seme mescola i quattro dati** con numeri primi diversi, cosi' due
  /// sessioni vicine non danno figure vicine: cambiare un solo minuto di
  /// durata sposta tutta la corona, e non solo l'ultimo raggio.
  static List<double> figura({
    required Sintomo? sintomo,
    required int hertz,
    required int centro,
    required Duration durata,
  }) {
    final quanti = quantiRaggi(durata);
    // L'indice del sintomo, oppure un valore suo per la pratica che Aura
    // sceglie dal centro del giorno: anche quella e' una sessione, e deve
    // avere il suo sigillo.
    final s = sintomo == null ? 13 : Sintomo.values.indexOf(sintomo) + 1;
    var seme = (s * 7919) ^ (hertz * 104729) ^ ((centro + 1) * 1299709);
    seme ^= durata.inSeconds * 15485863;
    final fuori = <double>[];
    for (var i = 0; i < quanti; i++) {
      // Un generatore lineare congruente, scritto qui perche' deve dare gli
      // stessi numeri su ogni telefono e in ogni prova: `Random` senza seme
      // no, e con seme e' comunque un dettaglio della piattaforma.
      seme = (seme * 1103515245 + 12345) & 0x7FFFFFFF;
      // Da 0,25 a 1,0: nessun raggio si azzera, o la corona si spezza.
      fuori.add(0.25 + (seme % 1000) / 1000 * 0.75);
    }
    return fuori;
  }
}
