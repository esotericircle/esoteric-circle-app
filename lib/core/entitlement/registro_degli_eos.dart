import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// UN MOVIMENTO DI EOS: quanti, quando, e PERCHE'.
///
/// Il perche' e' la parte che conta. Un numero che sale senza una ragione
/// accanto e' indistinguibile da un numero che sale per caso, ed e' esattamente
/// il sospetto che il borsellino deve togliere.
@immutable
class MovimentoDegliEos {
  const MovimentoDegliEos({
    required this.quanti,
    required this.perche,
    required this.quando,
  });

  /// Positivo se sono arrivati, negativo se sono stati spesi.
  final int quanti;

  /// La ragione, in parole della persona: "Primo passo", non "traguardo id_3".
  final String perche;

  final DateTime quando;

  /// **LA CHIAVE SU DISCO NON SI CHIAMA COME LA PAROLA ITALIANA.** Scritta
  /// `'perche'` sarebbe una parola con l'apostrofo al posto dell'accento, e in
  /// questo repository quella forma e' vietata a schermo: una chiave di
  /// archivio non si mostra a nessuno, ma nessuna prova puo' distinguere da
  /// fuori una stringa mostrata da una stringa archiviata. E' lo stesso caso
  /// della chiave `citta` nell'ordine S: si cambia il nome della chiave, non la
  /// regola della lingua.
  Map<String, Object?> get inMappa => {
        'quanti': quanti,
        'ragione': perche,
        'quando': quando.toIso8601String(),
      };

  static MovimentoDegliEos? daMappa(Object? grezzo) {
    if (grezzo is! Map) return null;
    final quanti = grezzo['quanti'];
    final perche = grezzo['ragione'];
    final quando = DateTime.tryParse('${grezzo['quando']}');
    if (quanti is! num || perche is! String || quando == null) return null;
    return MovimentoDegliEos(
      quanti: quanti.toInt(),
      perche: perche,
      quando: quando,
    );
  }
}

/// DA DOVE SONO ARRIVATI GLI ULTIMI EOS, ordine S voce 06.
///
/// **Perche' esiste un registro e non basta il saldo.** Il server dice quanti
/// Eos hai, e quello e' il numero sovrano. Non dice, a chi apre il borsellino,
/// da dove vengono: il diario del cammino tiene i traguardi accesi in un
/// insieme, che per costruzione non ha ordine ne' momento, quindi "gli ultimi"
/// non era una domanda a cui si potesse rispondere. Qui si segna il movimento
/// nell'istante in cui l'app lo compie, ed e' l'unico modo di avere una storia
/// vera invece di una storia ricostruita a stima.
///
/// **Il saldo NON si calcola da qui.** Sommare i movimenti darebbe un secondo
/// numero accanto a quello del server, cioe' la famiglia delle due porte: se i
/// due discordassero, e discorderebbero al primo movimento perso, la persona
/// vedrebbe due saldi diversi nella stessa schermata. Questo registro racconta,
/// non conta.
class RegistroDegliEos extends ChangeNotifier {

  /// **DIMENTICA CHI SE NE VA. Ordine BC voce 02.**
  ///
  /// **Il fatto del fondatore**: "ho provato a cancellare l'account, ma i dati
  /// restano... il borsellino, i traguardi e altri dati attualmente restano
  /// anche dopo la conferma della cancellazione."
  ///
  /// **La causa**: cancellare toglieva le chiavi dal disco e chiudeva la
  /// sessione, ma **i controller vivono per tutta la sessione dell'app** e
  /// nessuno li svuotava. Quello che si vedeva a schermo era la memoria, non
  /// il disco, e alla prima scrittura tornava anche sul disco.
  ///
  /// Non si tocca il server: qui si dimentica soltanto cio' che si ricorda.
  void dimenticaChiSeNeVa() {
    _movimenti.clear();
    notifyListeners();
  }

  static const _chiave = 'borsellino.movimenti';

  /// QUANTI SE NE TENGONO. Il portafoglio ne mostra pochi, e una storia lunga
  /// su un telefono non serve a nessuno: chi vuole tutta la storia guarda il
  /// cammino, che e' il posto dove la storia vive per intero.
  static const int quantiSeNeTengono = 8;

  final List<MovimentoDegliEos> _movimenti = [];

  /// Dal piu' recente al piu' vecchio, che e' l'ordine in cui si leggono.
  List<MovimentoDegliEos> get ultimi => List.unmodifiable(_movimenti);

  bool get vuoto => _movimenti.isEmpty;

  Future<void> carica() async {
    final prefs = await SharedPreferences.getInstance();
    final scritto = prefs.getString(_chiave);
    if (scritto == null || scritto.isEmpty) return;
    try {
      final grezzi = jsonDecode(scritto);
      if (grezzi is! List) return;
      _movimenti
        ..clear()
        ..addAll(grezzi
            .map(MovimentoDegliEos.daMappa)
            .whereType<MovimentoDegliEos>());
      notifyListeners();
    } catch (errore) {
      // Un registro illeggibile si comporta come un registro vuoto: e' una
      // storia, non un saldo, e perderla non deve mai impedire di aprire il
      // borsellino.
      return;
    }
  }

  /// Segna un movimento appena avvenuto. Da chiamare quando il server ha detto
  /// si', non quando lo si spera.
  Future<void> segna({
    required int quanti,
    required String perche,
    DateTime? quando,
  }) async {
    if (quanti == 0) return;
    _movimenti.insert(
      0,
      MovimentoDegliEos(
        quanti: quanti,
        perche: perche,
        quando: quando ?? DateTime.now(),
      ),
    );
    if (_movimenti.length > quantiSeNeTengono) {
      _movimenti.removeRange(quantiSeNeTengono, _movimenti.length);
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _chiave,
      jsonEncode([for (final m in _movimenti) m.inMappa]),
    );
  }
}
