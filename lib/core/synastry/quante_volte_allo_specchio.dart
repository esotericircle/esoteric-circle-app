import 'package:shared_preferences/shared_preferences.dart';

/// **QUANTE VOLTE QUESTA PERSONA HA GIÀ APERTO UNA SCHEDA ALLO SPECCHIO.**
/// Ordine DR voce 04, 16 settembre 2026.
///
/// **Il fatto da abbattere**, misurato: in `ResponsoDellaSinastria.fraDueVip`
/// il seme è `primo.sign.index + secondo.sign.index * 3 + percento`. Allo
/// specchio i due segni sono lo stesso e la percentuale è ferma, quindi il
/// seme è sempre identico e il testo pure: chi riprova la stessa coppia
/// rilegge parola per parola quello che ha già letto, e la sorpresa muore
/// alla seconda volta.
///
/// **Il conto si ricorda fra un avvio e l'altro**, come gli altri dati della
/// persona, e avanza a **ogni nuova apertura** di una scheda allo specchio.
/// Insieme all'identità del personaggio è il secondo asse su cui il testo
/// cambia: da un personaggio all'altro, e da una volta alla successiva.
///
/// **Dentro una stessa apertura non si muove.** Chi avanza il conto è la
/// schermata, una volta sola quando la scheda nasce: girare il telefono,
/// uscire e rientrare nello stesso responso rilegge le stesse parole, perché
/// il numero è già stato preso e vive nello stato della schermata. Un testo
/// che cambia sotto gli occhi mentre lo si legge è un guasto, non una
/// sorpresa.
abstract final class QuanteVolteAlloSpecchio {
  /// **IL PUNTO NON E' UN VEZZO.** La verita' unica di cio' che e' tuo,
  /// `CioCheETuo`, conosce le famiglie per prefisso, e la famiglia della
  /// Sinastria e' `sinastria.`. Scritta col trattino basso questa chiave
  /// restava fuori da tutte e due le vie: non la cancellava l'oblio e non
  /// finiva fra i dati consegnati a chi li chiede. **L'ha trovata una prova,
  /// non una persona.**
  static const String chiave = 'sinastria.specchio_volte';

  /// Quante volte finora, senza toccare il conto.
  static Future<int> quante() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(chiave) ?? 0;
  }

  /// **Avanza di uno e torna il valore DA USARE ADESSO**, cioè quello di
  /// prima: la prima apertura in assoluto è la volta zero, e usa la prima
  /// variante del corpus.
  static Future<int> avanza() async {
    final prefs = await SharedPreferences.getInstance();
    final ora = prefs.getInt(chiave) ?? 0;
    await prefs.setInt(chiave, ora + 1);
    return ora;
  }
}
