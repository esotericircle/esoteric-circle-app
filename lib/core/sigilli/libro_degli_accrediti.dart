import 'package:shared_preferences/shared_preferences.dart';

/// IL LIBRO DEGLI ACCREDITI RIUSCITI. Ordine AL voce 05.
///
/// **Perche' esiste.** L'accredito del premio aveva UN solo chiamante, il
/// momento dell'accensione, e la frase "il premio si riprende alla prossima
/// sincronia" era una promessa senza meccanismo: se la chiamata cadeva, quel
/// premio non lo riprendeva piu' nessuno. Sulla 2179 cadevano TUTTE, respinte
/// alla porta di Cloud Run, e ogni Sigillo acceso di Mauro e' rimasto senza
/// premio per sempre. La ripresa ha bisogno di sapere cosa e' gia' arrivato,
/// ed e' questo libro: un traguardo acceso che non sta qui e' un premio da
/// riprendere.
///
/// Il doppio conto non puo' succedere comunque, perche' ogni movimento porta
/// l'identificativo 'traguardo-<id>' e il server ripete la risposta di
/// allora: il libro non e' la difesa dal doppio pagamento, e' la lista di
/// lavoro della sincronia, per non bussare al server a ogni avvio per premi
/// gia' arrivati.
class LibroDegliAccrediti {
  const LibroDegliAccrediti._();

  static const _chiave = 'cammino.accreditati';

  /// Gli id dei traguardi il cui premio e' arrivato davvero.
  static Future<Set<String>> accreditati() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_chiave) ?? const []).toSet();
  }

  /// Segna che il premio di questo traguardo e' arrivato.
  static Future<void> segna(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final tutti = (prefs.getStringList(_chiave) ?? const []).toSet();
    if (!tutti.add(id)) return;
    await prefs.setStringList(_chiave, tutti.toList());
  }
}
