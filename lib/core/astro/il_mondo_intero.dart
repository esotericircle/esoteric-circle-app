import 'package:cloud_functions/cloud_functions.dart';

import 'city_catalog.dart';

/// IL MONDO INTERO, QUANDO IL CATALOGO NON BASTA. Ordine DR voce 10.
///
/// **Il fatto del fondatore**: le frazioni e i paesi piccoli non si trovano, e
/// la prova che decide e' "Borgo di Rivalta". Misurato il 16 settembre 2026:
/// quel nome **non esiste in GeoNames a nessuna soglia di abitanti**, perche'
/// GeoNames quella localita' non ce l'ha. Abbassare la soglia del catalogo
/// avrebbe pesato l'app di otto megabyte per non trovarlo lo stesso. La leva
/// era la fonte, ed e' la decisione del fondatore, verbatim: *"devi cambiare
/// fonte a Openstreetmap, ci deve essere tutto il mondo perche' un'utente
/// potrebbe vivere ovunque"*.
///
/// **IL CATALOGO OFFLINE NON SE NE VA, ed e' importante.** Risponde per primo,
/// senza rete e in un battito, e copre i luoghi che quasi tutti scrivono. Il
/// mondo si chiede solo quando lui non conosce il nome: chi nasce a Roma non
/// fa partire nessuna chiamata, e chi e' nato in una frazione la trova.
///
/// **IL FUSO NON ARRIVA DA OPENSTREETMAP**, che risponde con un punto e un
/// indirizzo e non con un fuso orario. Lo mette il catalogo: si prende il fuso
/// del luogo in elenco piu' vicino a quel punto. Non e' un ripiego travestito,
/// e' la risposta giusta: un fuso orario e' un'area larga centinaia di
/// chilometri, e il luogo del catalogo piu' vicino a una frazione italiana e'
/// un comune a pochi chilometri. **Il caso in cui sbaglierebbe**, cioe' un
/// punto a cavallo di un confine di fuso con il vicino dall'altra parte, e'
/// reale e raro, e l'ora esatta la ricalcolera' comunque il motore a
/// effemeridi dalle coordinate.
class IlMondoIntero {
  const IlMondoIntero._();

  /// Il nome della porta sul server, in europe-west1 come tutte le altre.
  static const String laPorta = 'cercaIlLuogoNelMondo';

  /// Sotto questa lunghezza non si chiede niente al mondo: il catalogo
  /// risponde gia', e una domanda di due lettere torna con mezzo pianeta.
  /// Lo stesso numero sta nel server, che e' l'unico che lo impone davvero.
  static const int lunghezzaMinima = 3;

  /// Quanto si aspetta prima di lasciar perdere e restare sul catalogo.
  static const Duration attesaMassima = Duration(seconds: 12);

  /// La chiamata vera, sostituibile nelle prove: qui non si accende Firebase.
  static Future<Object?> Function(Map<String, Object?> dati) chiamata =
      _dallaCallable;

  static Future<Object?> _dallaCallable(Map<String, Object?> dati) async {
    final porta = FirebaseFunctions.instanceFor(region: 'europe-west1')
        .httpsCallable(laPorta,
            options: HttpsCallableOptions(timeout: attesaMassima));
    final res = await porta.call<Object?>(dati);
    return res.data;
  }

  /// Cerca [query] nel mondo intero e traduce cio' che torna in luoghi che
  /// l'app sa gia' maneggiare.
  ///
  /// **Non solleva mai.** Chi chiama sta scrivendo dentro un campo di testo:
  /// se il mondo non risponde, l'elenco resta quello del catalogo e nessuno
  /// vede un errore per una cosa che non ha chiesto. Un elenco vuoto vuol
  /// dire "non ho trovato", ed e' tutto quello che serve sapere li'.
  static Future<List<City>> cerca(String query) async {
    final pulita = query.trim();
    if (pulita.length < lunghezzaMinima) return const <City>[];
    Object? risposta;
    try {
      risposta = await chiamata(<String, Object?>{'query': pulita});
    } catch (errore) {
      // **PERCHE' QUESTO ERRORE SI IGNORA, ed e' l'unico posto dove lo
      // faccio.** Chi chiama sta battendo lettere dentro un campo di testo e
      // non ha chiesto niente al mondo: la ricerca online e' una cortesia che
      // parte da sola quando il catalogo tace. Un messaggio di errore qui
      // sarebbe un errore **per una cosa che la persona non ha chiesto**, e
      // arriverebbe mentre sta ancora scrivendo il nome del suo paese.
      //
      // **E non si perde niente**: l'elenco resta quello del catalogo
      // offline, che e' esattamente cio' che si vedeva prima di quest'ordine.
      // Il guasto, quando c'e', lo registra il server, che e' l'unico dei due
      // che sa distinguere una rete assente da un servizio rotto.
      return const <City>[];
    }
    return leggi(risposta);
  }

  /// La traduzione della risposta in luoghi. Separata dalla chiamata apposta:
  /// e' la parte che si puo' provare senza rete, ed e' dove si sbaglia.
  static List<City> leggi(Object? risposta) {
    if (risposta is! Map) return const <City>[];
    final righe = risposta['luoghi'];
    if (righe is! List) return const <City>[];
    final fatti = <City>[];
    for (final riga in righe) {
      if (riga is! Map) continue;
      final nome = riga['nome'];
      final lat = riga['latitudine'];
      final lon = riga['longitudine'];
      if (nome is! String || nome.isEmpty) continue;
      final latitudine = (lat is num) ? lat.toDouble() : null;
      final longitudine = (lon is num) ? lon.toDouble() : null;
      if (latitudine == null || longitudine == null) continue;
      if (latitudine < -90 || latitudine > 90) continue;
      if (longitudine < -180 || longitudine > 180) continue;
      final area = riga['area'];
      fatti.add(daPunto(
        nome: nome,
        area: area is String ? area : '',
        latitudine: latitudine,
        longitudine: longitudine,
      ));
    }
    return fatti;
  }

  /// Il luogo che nasce da un punto sul pianeta, col fuso del vicino.
  static City daPunto({
    required String nome,
    required String area,
    required double latitudine,
    required double longitudine,
  }) {
    final vicino = CityCatalog.nearest(latitudine, longitudine);
    return City(
      name: nome,
      country: area.isEmpty ? vicino.country : area,
      latitude: latitudine,
      longitude: longitudine,
      timeZoneId: vicino.timeZoneId,
      utcOffsetMinutes: vicino.utcOffsetMinutes,
    );
  }
}
