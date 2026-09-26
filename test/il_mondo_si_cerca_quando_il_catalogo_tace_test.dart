import 'package:esoteric_circle/core/astro/city_catalog.dart';
import 'package:esoteric_circle/core/astro/il_mondo_intero.dart';
import 'package:esoteric_circle/core/astro/ricerca_del_luogo.dart';
import 'package:flutter_test/flutter_test.dart';

/// IL MONDO SI CHIEDE SOLO QUANDO IL CATALOGO TACE. Ordine DR voce 10.
///
/// **Il fatto del fondatore**: le frazioni e i paesi piccoli non si trovano, e
/// la prova che decide e' "Borgo di Rivalta". Misurato: quel nome **non esiste
/// in GeoNames a nessuna soglia**, quindi nessun catalogo offline lo puo'
/// contenere. La decisione del fondatore, verbatim: *"devi cambiare fonte a
/// Openstreetmap, ci deve essere tutto il mondo perche' un'utente potrebbe
/// vivere ovunque"*.
///
/// Qui non si prova la rete: si prova **cio' che l'app fa con la risposta**, e
/// **quando decide di chiedere**. La chiamata vera e' un campo sostituibile
/// apposta, cosi' queste prove non accendono Firebase e non pesano su un
/// servizio pubblico ogni volta che gira la suite.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// La risposta vera del server, nella forma che manda al telefono. I numeri
  /// sono quelli letti da OpenStreetMap il 16 settembre 2026.
  Map<String, Object?> rispostaDiRivalta() => <String, Object?>{
        'giaSaputo': false,
        'luoghi': <Object?>[
          <String, Object?>{
            'nome': 'Loc. Borgo di Rivalta',
            'area': 'Piacenza',
            'perEsteso': 'Loc. Borgo di Rivalta, Rivalta Trebbia, Gazzola, '
                'Piacenza, Emilia-Romagna, 29010, Italia',
            'latitudine': 44.9502818,
            'longitudine': 9.5909568,
          },
        ],
      };

  setUp(() {
    IlMondoIntero.chiamata = (_) async => null;
  });

  tearDown(() {
    IlMondoIntero.chiamata = (_) async => null;
  });

  test('BORGO DI RIVALTA ARRIVA, ed e\' la prova che decide', () async {
    await CityCatalog.ensureLoaded();
    // **Il catalogo non lo conosce**, ed e' il punto di partenza: se un
    // giorno lo conoscesse, questa riga cadrebbe e direbbe il vero, cioe' che
    // la voce non serve piu'.
    expect(CityCatalog.search('Borgo di Rivalta'), isEmpty,
        reason: 'il catalogo offline conosce il luogo che i fondatori non '
            'trovavano: questa prova sta misurando un altro difetto');

    final luoghi = IlMondoIntero.leggi(rispostaDiRivalta());
    expect(luoghi, hasLength(1));
    final trovato = luoghi.single;
    expect(trovato.name, 'Loc. Borgo di Rivalta');
    expect(trovato.country, 'Piacenza');
    expect(trovato.latitude, closeTo(44.9502818, 1e-6));
    expect(trovato.longitude, closeTo(9.5909568, 1e-6));
  });

  test('IL FUSO LO METTE IL VICINO IN CATALOGO, non OpenStreetMap', () async {
    await CityCatalog.ensureLoaded();
    // OpenStreetMap risponde con un punto e un indirizzo, e **non con un
    // fuso**: senza questa regola il luogo arriverebbe con l'ora di Greenwich
    // e la carta natale sarebbe esatta e falsa insieme.
    final trovato = IlMondoIntero.leggi(rispostaDiRivalta()).single;
    final vicino = CityCatalog.nearest(44.9502818, 9.5909568);
    expect(trovato.timeZoneId, vicino.timeZoneId);
    expect(trovato.timeZoneId, 'Europe/Rome',
        reason: 'il vicino di una frazione piacentina non e\' in un altro '
            'fuso: se questo cambia, e\' cambiato il catalogo');
    expect(trovato.utcOffsetMinutes, vicino.utcOffsetMinutes);
  });

  test('cio\' che non e\' un luogo non entra nell\'elenco', () {
    final luoghi = IlMondoIntero.leggi(<String, Object?>{
      'luoghi': <Object?>[
        <String, Object?>{'nome': '', 'latitudine': 45.0, 'longitudine': 9.0},
        <String, Object?>{'nome': 'Senza punto'},
        <String, Object?>{
          'nome': 'Fuori dal mondo',
          'latitudine': 91.0,
          'longitudine': 9.0,
        },
        <String, Object?>{
          'nome': 'Fuori di lato',
          'latitudine': 45.0,
          'longitudine': 181.0,
        },
        'roba',
        null,
      ],
    });
    expect(luoghi, isEmpty);
  });

  test('una risposta che non e\' una risposta non fa cadere niente', () {
    expect(IlMondoIntero.leggi(null), isEmpty);
    expect(IlMondoIntero.leggi('errore'), isEmpty);
    expect(IlMondoIntero.leggi(<String, Object?>{}), isEmpty);
    expect(IlMondoIntero.leggi(<String, Object?>{'luoghi': 'niente'}), isEmpty);
  });

  test('IL MONDO NON RISPONDE: l\'elenco resta vuoto e nessuno solleva',
      () async {
    IlMondoIntero.chiamata = (_) async => throw StateError('niente rete');
    // Chi chiama sta scrivendo dentro un campo di testo: un errore qui
    // sarebbe un errore per una cosa che non ha chiesto.
    expect(await IlMondoIntero.cerca('borgo di rivalta'), isEmpty);
  });

  test('sotto le tre lettere non si chiede niente a nessuno', () async {
    var chiamate = 0;
    IlMondoIntero.chiamata = (_) async {
      chiamate++;
      return null;
    };
    expect(await IlMondoIntero.cerca('ro'), isEmpty);
    expect(await IlMondoIntero.cerca('  '), isEmpty);
    expect(chiamate, 0,
        reason: 'una domanda di due lettere al mondo intero torna con mezzo '
            'pianeta, e la paga chi risponde');
  });

  test('QUANDO IL CATALOGO SA, LA DOMANDA NON ESCE DI CASA', () async {
    await CityCatalog.ensureLoaded();
    var chiamate = 0;
    IlMondoIntero.chiamata = (_) async {
      chiamate++;
      return rispostaDiRivalta();
    };
    final ricerca = RicercaNelMondo(attesa: const Duration(milliseconds: 1));
    final locali = CityCatalog.search('Roma');
    expect(locali, isNotEmpty, reason: 'il catalogo non conosce Roma');
    var chiamato = false;
    ricerca.chiedi('Roma', gia: locali, quando: (_) => chiamato = true);
    await Future<void>.delayed(const Duration(milliseconds: 40));
    expect(chiamate, 0,
        reason: 'chi scrive Roma non deve far partire nessuna chiamata');
    expect(chiamato, isFalse);
    ricerca.chiudi();
  });

  test('e quando il catalogo tace, la domanda parte una volta sola',
      () async {
    var chiamate = 0;
    final chieste = <String>[];
    IlMondoIntero.chiamata = (dati) async {
      chiamate++;
      chieste.add(dati['query']! as String);
      return rispostaDiRivalta();
    };
    final ricerca = RicercaNelMondo(attesa: const Duration(milliseconds: 20));
    List<City>? arrivati;
    // Le lettere in mezzo a una parola non sono domande: se ogni battuta
    // facesse partire una chiamata, scrivere "Borgo di Rivalta" ne farebbe
    // sedici.
    for (final pezzo in ['bor', 'borg', 'borgo', 'borgo di rivalta']) {
      ricerca.chiedi(pezzo, gia: const [], quando: (t) => arrivati = t);
      await Future<void>.delayed(const Duration(milliseconds: 4));
    }
    await Future<void>.delayed(const Duration(milliseconds: 80));
    expect(chiamate, 1, reason: 'chiamate partite: $chieste');
    expect(chieste.single, 'borgo di rivalta');
    expect(arrivati, isNotNull);
    expect(arrivati!.single.name, 'Loc. Borgo di Rivalta');
    ricerca.chiudi();
  });

  test('SOLO L\'ULTIMA DOMANDA PARLA', () async {
    // Due domande partite in ordine possono tornare nell'ordine contrario: la
    // piu' vecchia riempirebbe l'elenco di chi sta leggendo la piu' nuova.
    IlMondoIntero.chiamata = (dati) async {
      final q = dati['query']! as String;
      await Future<void>.delayed(
          Duration(milliseconds: q == 'prima' ? 60 : 5));
      return <String, Object?>{
        'luoghi': <Object?>[
          <String, Object?>{
            'nome': q,
            'area': 'Finta',
            'latitudine': 45.0,
            'longitudine': 9.0,
          },
        ],
      };
    };
    final ricerca = RicercaNelMondo(attesa: const Duration(milliseconds: 1));
    final arrivati = <String>[];
    ricerca.chiedi('prima', gia: const [], quando: (t) {
      arrivati.addAll(t.map((c) => c.name));
    });
    await Future<void>.delayed(const Duration(milliseconds: 5));
    ricerca.chiedi('dopo', gia: const [], quando: (t) {
      arrivati.addAll(t.map((c) => c.name));
    });
    await Future<void>.delayed(const Duration(milliseconds: 150));
    expect(arrivati, ['dopo'],
        reason: 'ha parlato anche una domanda vecchia: $arrivati');
    ricerca.chiudi();
  });

  test('chiusa la schermata, il rinvio non trova piu\' nessuno', () async {
    var chiamate = 0;
    IlMondoIntero.chiamata = (_) async {
      chiamate++;
      return rispostaDiRivalta();
    };
    final ricerca = RicercaNelMondo(attesa: const Duration(milliseconds: 30));
    var chiamato = false;
    ricerca.chiedi('borgo di rivalta',
        gia: const [], quando: (_) => chiamato = true);
    ricerca.chiudi();
    await Future<void>.delayed(const Duration(milliseconds: 80));
    expect(chiamate, 0);
    expect(chiamato, isFalse);
  });
}
