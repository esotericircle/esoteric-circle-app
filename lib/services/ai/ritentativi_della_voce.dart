import '../../core/maestro/tempi_dell_attesa.dart';

/// QUANDO SI RITENTA, QUANTE VOLTE, E PER QUANTO.
///
/// **Il dato che ha fatto nascere questo file.** Cinque chiamate ravvicinate a
/// Vertex hanno reso `429 RESOURCE_EXHAUSTED`. Al primo 429 la persona vedeva
/// il ripiego: un rifiuto TEMPORANEO di Google diventava un messaggio d'errore
/// in faccia a chi paga, mentre bastava richiedere.
///
/// **Perche' la politica sta qui e non nel punto di chiamata.** Alla voce dei
/// Maestri si arriva da piu' porte, la chat, il Consulta, la Sintesi e il
/// distillato: numeri scritti dentro ognuna sarebbero quattro politiche che
/// divergono, e la quinta porta che nasce domani non ne avrebbe nessuna.
class RitentativiDellaVoce {
  const RitentativiDellaVoce._();

  /// Quanti tentativi in tutto, cioe' il primo piu' i ritentativi.
  ///
  /// Tre. Non e' un numero scelto per simmetria: un 429 da quota momentanea si
  /// libera in fretta, e chi non passa al terzo colpo non sta incontrando un
  /// picco, sta incontrando un muro. Insistere oltre farebbe aspettare la
  /// persona per un problema che non si sta risolvendo.
  static const int tentativi = 3;

  /// Quanto si aspetta prima di ognuno dei ritentativi, in ordine.
  ///
  /// Crescente, perche' se il primo ritentativo trova ancora occupato vuol dire
  /// che il picco non si e' ancora sfogato, e ripresentarsi allo stesso ritmo
  /// lo peggiora. Sono due attese perche' i ritentativi sono due.
  static const List<Duration> attese = [
    Duration(milliseconds: 300),
    Duration(milliseconds: 900),
  ];

  /// IL TETTO A TUTTA L'ATTESA, e NON e' un numero nuovo.
  ///
  /// E' la durata minima della scena del consulto. La ragione e' che quella
  /// pausa c'e' comunque: finche' i ritentativi finiscono dentro di essa, la
  /// persona non vede niente di diverso, ed e' esattamente cio' che l'ordine
  /// chiede, cioe' che un 429 transitorio sia INVISIBILE. Oltre quel confine il
  /// ritentativo comincerebbe a farsi sentire come lentezza, e allora e'
  /// meglio il ripiego, che almeno dichiara cosa e' successo.
  ///
  /// Inventare qui un secondo numero avrebbe voluto dire due tempi che devono
  /// restare d'accordo con la scena, e prima o poi non lo restano.
  static Duration get tetto => TempiDellAttesa.durataMinima;

  /// I segnali che dicono "riprova fra poco" invece di "non funziona".
  ///
  /// Il pacchetto `firebase_ai` tipizza `QuotaExceeded` sul messaggio che
  /// contiene `RESOURCE_EXHAUSTED`, ma non tipizza gli altri transitori: per
  /// quelli resta il testo, che e' quanto il servizio espone. Sono scritti qui
  /// come DATO invece che dentro un `if`, cosi' aggiungerne uno e' aggiungere
  /// una riga a un elenco e non toccare la logica.
  static const List<String> segnaliTemporanei = [
    'RESOURCE_EXHAUSTED',
    'QuotaExceeded',
    'UNAVAILABLE',
    'DEADLINE_EXCEEDED',
    'INTERNAL',
    '429',
    '503',
    '504',
  ];

  /// Vero se vale la pena riprovare.
  ///
  /// **Solo i transitori.** Una chiave sbagliata, un'API non abilitata o una
  /// richiesta rifiutata per sicurezza non cambiano riprovando: ritentare
  /// significherebbe far aspettare la persona tre volte per lo stesso no.
  static bool eTemporaneo(Object errore) {
    final testo = errore.toString();
    for (final segnale in segnaliTemporanei) {
      if (testo.contains(segnale)) return true;
    }
    return false;
  }

  /// L'attesa prima del ritentativo numero [quale], contato da uno.
  static Duration attesaPrima(int quale) =>
      quale - 1 < attese.length ? attese[quale - 1] : attese.last;
}
