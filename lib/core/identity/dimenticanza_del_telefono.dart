import 'package:shared_preferences/shared_preferences.dart';
import 'cio_che_e_tuo.dart';

/// COSA IL TELEFONO DIMENTICA QUANDO SI ESCE O SI CANCELLA TUTTO.
/// Ordine AZ, voci 07 e 08.
///
/// **Nasce da due buchi misurati.** Uscire dall'account non esisteva affatto,
/// e cancellare l'account prometteva "qui e sul server" mentre il "qui" non
/// veniva toccato: sul telefono restavano il diario del cammino, i dati di
/// nascita e la preferenza che dice se il rito e' gia' stato fatto.
///
/// **Perche' e' grave e non solo sciatto.** Chi entra dopo troverebbe il
/// cammino di un altro, e la fusione col Cerchio lo manderebbe pure sul
/// server del nuovo arrivato, dove il piu' alto dei contatori vince: i gesti
/// di una persona diventerebbero i traguardi di un'altra.
///
/// **Sta in un posto solo e non e' un vezzo.** L'uscita e la cancellazione
/// devono dimenticare le stesse cose: se ognuna tenesse la sua lista, un
/// giorno una delle due si dimenticherebbe una chiave, e sarebbe proprio la
/// chiave che conta.
class DimenticanzaDelTelefono {
  const DimenticanzaDelTelefono._();

  /// **I PREFISSI DELLE CHIAVI CHE APPARTENGONO A UNA PERSONA, e adesso
  /// vivono in un posto solo.** Ordine BZ voce 01.
  ///
  /// Questa lista era una delle DUE verita' dell'app su cosa e' della
  /// persona, e non coincideva con l'altra: la via dell'Account cancellava
  /// secondo questa, la via delle Impostazioni secondo quella di
  /// `ProfileStore`, e le due promettevano alla persona la stessa cosa.
  /// Adesso non c'e' piu' una lista qui: c'e' `CioCheETuo`, che le due vie e
  /// lo scarico leggono tutte e tre.
  static const List<String> prefissiDaDimenticare = CioCheETuo.prefissi;

  /// Cio' che resta, con la ragione scritta accanto a ognuno: anche questa
  /// viene dalla verita' unica, cosi' non puo' divergere.
  static List<String> get prefissiCheRestano =>
      CioCheETuo.restano.keys.toList(growable: false);

  /// Dimentica cio' che appartiene alla persona che se ne va.
  ///
  /// Torna quante chiavi c'erano davvero: serve alle prove per dire che
  /// qualcosa e' stato dimenticato sul serio, invece di dichiararlo.
  /// [tenendo] sono prefissi che questa volta NON si dimenticano, oltre a
  /// quelli che restano sempre.
  ///
  /// **Serve alla voce "cancella i tuoi dati" dell'ordine BC voce 02**, che
  /// azzera il cammino tenendo l'account: li' la custodia non si tocca,
  /// perche' e' la chiave con cui si rientra, e cancellarla vorrebbe dire
  /// chiudere fuori chi ha chiesto solo di ricominciare.
  static Future<int> dimentica({List<String> tenendo = const []}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var quante = 0;
      for (final chiave in prefs.getKeys().toList()) {
        final resta = prefissiCheRestano.any((p) => chiave.startsWith(p)) ||
            tenendo.any((p) => chiave.startsWith(p));
        if (resta) continue;
        final va = prefissiDaDimenticare.any((p) => chiave.startsWith(p));
        if (!va) continue;
        await prefs.remove(chiave);
        quante++;
      }
      return quante;
    } catch (errore) {
      // Senza persistenza non c'e' niente da dimenticare, e non e' un guasto.
      return 0;
    }
  }
}
