import 'dart:io';

import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/identity/birth_place.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LA CATENA DEI DATI DI NASCITA, ENUMERATA.
///
/// Ordine 2169, voce 7. **Non basta che i dati siano scritti sul disco: la
/// 2166 li scriveva e nessuno li leggeva.** Fra chi li raccoglie e chi li usa
/// ci sono tre anelli, e ognuno dei tre si e' gia' rotto almeno una volta in
/// questo progetto: la scrittura (rotta fino alla 2166), la rilettura
/// all'avvio (rotta fino alla 2167), la consegna al singolo consumatore.
///
/// **Queste prove ENUMERANO, non visitano un elenco scritto a mano.** Un
/// elenco a mano dice la verita' il giorno che lo scrivi e comincia a mentire
/// il giorno dopo: il difetto che si vuole prendere e' proprio quello di chi
/// aggiunge una funzionalita' e si dimentica di collegarla.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  /// I file di funzionalita' che chiedono i dati di nascita o la carta.
  List<String> consumatori() {
    final out = <String>[];
    for (final f in Directory('lib/features')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      final testo = f.readAsStringSync();
      if (testo.contains('BirthIdentityController>()') ||
          testo.contains('NatalChartController>()')) {
        out.add(f.path.replaceAll('\\', '/'));
      }
    }
    out.sort();
    return out;
  }

  test('OGNI funzionalita\' che chiede i dati trova chi glieli da\'', () {
    // Il primo anello: il fornitore deve stare sopra tutte le rotte. Se una
    // schermata chiede un controller che nessuno fornisce, l'app non da' un
    // dato sbagliato: si schianta appena quella schermata si apre, e lo fa
    // soltanto sul telefono di chi ci arriva.
    final app = File('lib/app.dart').readAsStringSync();
    final mancanti = <String>[];
    for (final percorso in consumatori()) {
      final testo = File(percorso).readAsStringSync();
      if (testo.contains('BirthIdentityController>()') &&
          !app.contains('BirthIdentityController')) {
        mancanti.add('$percorso chiede BirthIdentityController');
      }
      if (testo.contains('NatalChartController>()') &&
          !app.contains('NatalChartController')) {
        mancanti.add('$percorso chiede NatalChartController');
      }
    }
    // ignore: avoid_print
    print('CATENA: ${consumatori().length} funzionalita\' chiedono i dati di '
        'nascita o la carta');
    expect(mancanti, isEmpty, reason: mancanti.join('\n'));
  });

  test('NESSUNA funzionalita\' si fabbrica i dati di nascita per conto suo',
      () {
    // Il difetto di forma che questo progetto ha gia' pagato nove volte: una
    // verita' che vive in due posti. Se una schermata costruisce da se' un
    // BirthDetails invece di chiederlo alla porta, quel giorno mostrera' una
    // carta di qualcun altro, e non ci sara' nessun modo di accorgersene
    // guardando la porta.
    final colpe = <String>[];
    for (final percorso in consumatori()) {
      final righe = File(percorso)
          .readAsStringSync()
          .split('\n')
          .map((r) => r.replaceAll('\r', ''));
      for (final r in righe) {
        final nuda = r.trim();
        if (nuda.startsWith('//')) continue;
        // `toBirthDetails()` NON e' una costruzione: e' esattamente il
        // contrario, cioe' chiedere i dettagli alla porta che tiene i dati.
        // La prima misura li contava come colpe, e sarebbe stato un rimprovero
        // a chi fa la cosa giusta.
        if (nuda.contains('BirthDetails(') &&
            !nuda.contains('toBirthDetails(') &&
            !nuda.contains('BirthDetails(details')) {
          colpe.add('$percorso: costruisce BirthDetails invece di chiederlo '
              'alla porta ($nuda)');
        }
      }
    }
    expect(colpe, isEmpty, reason: colpe.join('\n'));
  });

  test('la catena regge da capo a fondo, dal Risveglio al consumatore',
      () async {
    // Il percorso intero, misurato invece che supposto: si scrive come fa il
    // Risveglio, si riapre l'app come fa l'avvio, si legge come fa una
    // funzionalita'.
    final identita = BirthIdentity.fromParts(
      birthDate: DateTime(1975, 7, 6),
      birthHour: 9,
      birthMinute: 30,
      birthPlace: const BirthPlace(
        city: 'Torino',
        latitude: 45.07,
        longitude: 7.69,
        timeZoneId: 'Europe/Rome',
        utcOffsetMinutes: 120,
      ),
    );

    // 1. Il Risveglio scrive.
    ProfileController().setIdentity(identita);
    await Future<void>.delayed(Duration.zero);

    // 2. L'app si riapre e rilegge.
    final profilo = ProfileController();
    await profilo.load();
    expect(profilo.identity.birthPlace, isNotNull,
        reason: 'il luogo non e\' sopravvissuto alla chiusura dell\'app');

    // 3. La porta di lettura si riempie da quel profilo.
    final porta = BirthIdentityController()..riprendiDa(profilo.identity);
    final dettagli = porta.details;
    expect(dettagli, isNotNull,
        reason: 'la porta di lettura resta vuota anche col profilo pieno: e\' '
            'il difetto della 2166, dove i dati erano scritti e nessuno li '
            'leggeva');

    // 4. E cio' che arriva al consumatore e' cio' che la persona ha dato,
    //    non un'approssimazione ne' un esempio.
    expect(dettagli!.place, isNotNull,
        reason: 'i dati arrivano senza il luogo: da qui in poi Ascendente e '
            'case non si calcolano, e la persona non sa perche\'');
    expect(dettagli.place!.latitude, closeTo(45.07, 0.001));
    expect(dettagli.hasTime, isTrue,
        reason: 'l\'ora si e\' persa lungo la catena');
    expect(dettagli.time!.hour, 9);
    expect(dettagli.time!.minute, 30);
  });

  test('senza luogo la catena si ferma DICHIARANDOLO, non inventando', () {
    // Il caso della fondatrice: data e ora ci sono, il luogo no. Cio' che non
    // deve succedere e' che qualcuno metta un luogo al posto suo, perche' un
    // Ascendente calcolato su coordinate inventate e' esatto e falso insieme.
    final senzaLuogo = BirthIdentity.fromParts(
      birthDate: DateTime(1975, 7, 6),
      birthHour: 9,
      birthMinute: 30,
    );
    final porta = BirthIdentityController()..riprendiDa(senzaLuogo);
    expect(porta.details, isNotNull);
    expect(porta.details!.place, isNull,
        reason: 'qualcuno ha messo un luogo che la persona non ha dato');
    expect(porta.sunSign, isNotNull,
        reason: 'il segno solare chiede solo la data: senza luogo deve esserci '
            'lo stesso, altrimenti si toglie anche cio\' che si sa');
  });

  test('il conto dei consumatori e\' scritto, e cambiarlo si vede', () {
    // **IL CONTO NON E' UN VEZZO.** Il giorno che qualcuno aggiunge una
    // funzionalita' che legge i dati di nascita, questa prova cade e lo
    // costringe a guardare le altre tre di questo file: sono quelle che
    // dicono se l'ha collegata davvero.
    final elenco = consumatori();
    // ignore: avoid_print
    print('CATENA: ${elenco.map((p) => p.split("/").last).join(", ")}');
    // **UNDICI, ed e' passato da dodici e poi di nuovo da undici in un
    // giorno solo.** Lo Specchio dei dati della voce 8 e' entrato
    // nell'elenco, e a segnalarlo e' stata questa prova, che e' il mestiere
    // per cui esiste. Poi ne e' uscito CompletaIlLuogo: quando ho scoperto
    // che apriva una seconda porta per lo stesso dato l'ho ridotto a un
    // rimando alla schermata che esisteva gia', e un rimando non chiede
    // niente a nessun controller. Il conto torna a undici da una strada
    // diversa, e queste due righe di storia servono a non farlo sembrare un
    // caso.
    // DODICI dall'ordine O del 12 agosto 2026: la regia dei Sigilli del
    // Cammino chiede la carta natale per sapere se un traguardo del cielo si
    // e' acceso, e la chiede alla porta unica come tutti gli altri. E' un
    // consumatore vero, non un passante: entra nel conto.
    // TREDICI dall'ordine AM del 18 agosto 2026: la barra sottile
    // dell'identita' mostra l'Ascendente, che in locale non si calcola e
    // arriva dalla carta. Chiede alla porta unica come tutti gli altri,
    // quindi e' un consumatore vero ed entra nel conto.
    // QUATTORDICI dall'ordine AN del 18 agosto 2026: il Calendario degli
    // Eventi calcola gli appuntamenti TUOI, il ritorno solare e la Luna nel
    // tuo segno, e per farlo chiede la carta alla porta unica, come tutti.
    // Alla stessa porta chiede anche quanto si sa di questa persona, per
    // decidere se invitare a completare il profilo invece di deciderlo da
    // se': e' un consumatore vero ed entra nel conto.
    // TREDICI DALL'ORDINE AO del 18 agosto 2026, e il conto SCENDE per la
    // prima volta: la barra sottile non chiede piu' la carta natale, perche'
    // al suo centro non c'e' piu' il cielo che viene ma la porta degli
    // Eventi Cosmici, che non ha bisogno di sapere chi sei. Un consumatore
    // in meno non e' una perdita: e' una schermata che ha smesso di chiedere
    // cio' che non le serviva.
    // QUATTORDICI DALL'ORDINE AZ del 22 agosto 2026, e il conto risale:
    // l'area account e' diventata un consumatore **perche' adesso da li' si
    // esce**. Uscire deve dimenticare cio' che il telefono ricorda di chi se
    // ne va, e fra quelle cose c'e' la nascita: se restasse, chi entra dopo
    // si troverebbe il cielo di un altro. **Chiede alla porta unica come
    // tutti**, e non tiene nessuna copia sua: chiede per svuotare, non per
    // **TREDICI DALL'ORDINE BC voce 05.** La regia delle chiamate ha smesso
    // di chiedere i dati di nascita: leggeva la carta per calcolare l'alba
    // vera, e adesso i cinque avvisi partono alle ore che i Doni portano
    // scritte dentro. **L'alba vera non e' sparita**: la mette il Rito
    // dell'Alba, che la posizione la chiede quando qualcuno lo apre, e la
    // rimette sullo stesso id senza sdoppiare la chiamata.
    // leggere.
    // DODICI dall'ordine BF del 24 agosto 2026, e il conto scende per la
    // seconda volta: maestro_screen chiedeva la carta dentro _userSign, un
    // metodo che NESSUNO chiamava piu', trovato dalla bonifica analyze
    // (BF.05.g). Un consumatore che nessuno chiama non consuma niente:
    // toglierlo non toglie un dato a nessuno.
    expect(elenco.length, 12,
        reason: 'le funzionalita\' che chiedono i dati di nascita sono '
            '${elenco.length} invece di 13:\n${elenco.join("\n")}\n'
            'Se ne hai aggiunta una, verifica che riceva i dati dalla porta e '
            'aggiorna questo numero. Se ne hai tolta una, idem.');
  });

  test('i dettagli di nascita nascono da un solo posto', () {
    // La conversione da identita' a dettagli e' un punto solo: `toBirthDetails`.
    // Se domani qualcuno ne scrivesse un'altra, le due potrebbero interpretare
    // il fuso in modo diverso, e la carta cambierebbe a seconda di chi la
    // chiede.
    final fonti = <String>[];
    for (final f in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      final t = f.readAsStringSync();
      if (t.contains('astro.BirthDetails(') || t.contains('BirthDetails(\n')) {
        fonti.add(f.path.replaceAll('\\', '/'));
      }
    }
    // ignore: avoid_print
    print('CATENA: i dettagli si costruiscono in ${fonti.length} punti: '
        '${fonti.join(", ")}');
    expect(fonti.length, lessThanOrEqualTo(2),
        reason: 'i dettagli di nascita si costruiscono in ${fonti.length} '
            'punti diversi ($fonti): ogni punto in piu\' e\' un modo in piu\' '
            'di interpretare la stessa nascita');
  });

}
