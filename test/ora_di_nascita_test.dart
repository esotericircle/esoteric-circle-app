import 'dart:io';

import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/identity/profile_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// L'ORA DI NASCITA SI REGISTRA, e si ritrova dopo aver chiuso l'app.
///
/// **La segnalazione.** "Non registra l'ora di nascita." A conferma lo diceva
/// l'app stessa in due punti: "Senza l'ora di nascita l'Ascendente e le Case
/// restano velati" nel Passport, e "Con l'ora di nascita la lettura si fara' piu'
/// precisa" nella Risonanza. Il Risveglio ha i selettori dell'ora, e in un giro
/// precedente erano gia' stati riparati perche' risultavano spenti.
///
/// **Le tre rotture possibili**, che questa prova distingue invece di
/// confonderle: l'ora non entra nel modello, entra e non finisce nell'archivio,
/// oppure c'e' nell'archivio e chi legge non la rilegge. Sono tre prove
/// separate apposta: una sola che dice "l'ora manca" non direbbe DOVE.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  const store = ProfileStore();

  test('Primo anello: l\'ora scelta entra nel modello', () {
    final con = BirthIdentity.fromParts(
      birthDate: DateTime(1975, 7, 6),
      birthHour: 9,
      birthMinute: 30,
    );
    expect(con.hasBirthTime, isTrue,
        reason: 'l\'ora e\' stata scelta e il modello dice di non averla: si '
            'perde prima ancora di essere salvata');
    expect(con.birthMoment.hour, 9);
    expect(con.birthMoment.minute, 30);
  });

  test('Secondo anello: l\'ora finisce nell\'archivio', () async {
    await store.saveIdentity(BirthIdentity.fromParts(
      birthDate: DateTime(1975, 7, 6),
      birthHour: 9,
      birthMinute: 30,
    ));
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('profile.hasBirthTime'), isTrue,
        reason: 'l\'archivio non registra nemmeno CHE l\'ora esiste');
    expect(prefs.getInt('profile.birthHour'), 9,
        reason: 'l\'ora non arriva nell\'archivio');
    expect(prefs.getInt('profile.birthMinute'), 30);
  });

  test('Terzo anello: chi riapre l\'app ritrova l\'ora', () async {
    await store.saveIdentity(BirthIdentity.fromParts(
      birthDate: DateTime(1975, 7, 6),
      birthHour: 9,
      birthMinute: 30,
    ));

    // Si riapre l'app: un archivio nuovo che rilegge le stesse preferenze.
    final riletta = (await store.load()).identity;
    expect(riletta, isNotNull, reason: 'non si rilegge niente');
    expect(riletta!.hasBirthTime, isTrue,
        reason: 'l\'ora era nell\'archivio e chi legge non la rilegge: la '
            'chiave o il formato non combaciano fra scrittura e lettura');
    expect(riletta.birthMoment.hour, 9);
    expect(riletta.birthMoment.minute, 30);
  });

  test('Tutta la catena: il profilo riaperto ha l\'ora', () async {
    // Come il Risveglio: si sceglie l'ora e si sigilla.
    final primo = ProfileController();
    primo.setIdentity(BirthIdentity.fromParts(
      birthDate: DateTime(1975, 7, 6),
      birthHour: 9,
      birthMinute: 30,
    ));
    // Il salvataggio e' asincrono e nessuno lo aspetta: si lascia finire.
    await Future<void>.delayed(Duration.zero);

    // Si chiude e si riapre.
    final secondo = ProfileController();
    await secondo.load();

    expect(secondo.identity.hasBirthTime, isTrue,
        reason: 'chi ha scelto l\'ora nel Risveglio, riaprendo l\'app, si '
            'ritrova senza: l\'Ascendente e le Case restano velati per sempre');
    expect(secondo.identity.birthMoment.hour, 9);
  });

  test('Le porte da cui entra l\'ora sono enumerate', () {
    // La data di nascita entra da DUE strade, e se l'ora la segue le porte sono
    // le stesse due: correggerne una lascerebbe l'altra a riscrivere il
    // difetto. Questa prova le conta invece di visitarne una.
    final porte = <String>[];
    for (final f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      final p = f.path.replaceAll(Platform.pathSeparator, '/');
      if (p.endsWith('profile_controller.dart')) continue;
      if (p.endsWith('birth_identity.dart')) continue;
      if (f.readAsStringSync().contains('birthHour:')) porte.add(p);
    }
    // TRE, e sono tutte volute: l'archivio che la persiste, il Risveglio che la
    // raccoglie, e la schermata dei dati di nascita che la corregge. Quella
    // terza e' nata perche' prima le porte d'ingresso erano una sola, e chi
    // aveva concluso il Risveglio senza ora non poteva piu' darla in nessun
    // modo. Se ne compare una quarta, va guardata: ogni strada in piu' e' un
    // posto dove l'ora puo' perdersi per conto suo.
    expect(porte.length, lessThanOrEqualTo(3),
        reason: 'l\'ora di nascita entra da ${porte.length} strade ($porte): '
            'ogni strada in piu\' e\' un posto dove puo\' perdersi da sola');
  });
}
