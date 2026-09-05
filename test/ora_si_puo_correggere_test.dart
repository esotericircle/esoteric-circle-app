import 'dart:io';

import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/identity/birth_place.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/identity/profile_store.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/account/dati_di_nascita_screen.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'sorgenti_di_lib.dart';

/// L'ORA DI NASCITA SI PUO' DARE ANCHE DOPO IL RISVEGLIO.
///
/// **La domanda decisiva, e la sua risposta.** Il fondatore ha segnalato tre
/// volte che l'ora non si registra. La catena di persistenza regge in ogni suo
/// anello, e c'e' una prova per ciascuno. Il fatto che mancava e' piu' semplice
/// e piu' grave: `setIdentity` era chiamato in UN SOLO punto di tutto il
/// progetto, l'onboarding, quindi chi aveva gia' concluso il Risveglio senza
/// dare l'ora **non poteva piu' darla in nessun modo**. Nessuna correzione a
/// valle poteva servirgli, ed e' esattamente il suo caso.
///
/// Un dato che si raccoglie una volta sola, e mai piu', non e' un dato: e' una
/// trappola.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  /// Il cosmo di sfondo respira in ciclo continuo, quindi l'albero non si posa
  /// mai e `pumpAndSettle` scade: si fanno passare pochi fotogrammi a mano.
  Future<void> posa(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  Future<ProfileController> apri(WidgetTester tester,
      {required BirthIdentity partenza}) async {
    final profilo = ProfileController(identity: partenza);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<ProfileController>.value(value: profilo),
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
      ],
      child: const MaterialApp(
        home: MaestroScope(child: DatiDiNascitaScreen()),
      ),
    ));
    await tester.pump();
    return profilo;
  }

  testWidgets('Esiste un posto dove dare l ora dopo il Risveglio',
      (tester) async {
    // Chi ha concluso il Risveglio dando solo il giorno: nessuna ora.
    final senzaOra = BirthIdentity.fromParts(birthDate: DateTime(1975, 7, 6));
    expect(senzaOra.hasBirthTime, isFalse);

    final profilo = await apri(tester, partenza: senzaOra);

    // Si sceglie l'ora, come farebbe una persona.
    await tester.tap(find.byKey(const Key('nascita_ora')));
    await posa(tester);
    await tester.tap(find.text('09').last);
    await posa(tester);
    // **PRIMA SI PORTA SOTTO GLI OCCHI, ordine CF voce 13.** La schermata
    // ha un campo in piu', "Dove vivi adesso", e il pulsante e' sceso
    // sotto la piega: un tocco su un riquadro fuori campo non arriva, e la
    // prova vedeva l'ora non salvata credendo che il salvataggio fosse
    // rotto.
    await tester.ensureVisible(find.byKey(const Key('nascita_salva')));
    await posa(tester);
    await tester.tap(find.byKey(const Key('nascita_salva')));
    await posa(tester);

    expect(profilo.identity.hasBirthTime, isTrue,
        reason: 'non c\'e\' modo di dare l\'ora dopo il Risveglio: chi l\'ha '
            'concluso senza si rivede per sempre "l\'Ascendente e le Case '
            'restano velati", e nessuna correzione a valle puo\' aiutarlo');
    expect(profilo.identity.birthMoment.hour, 9);
  });

  testWidgets('L ora data qui sopravvive alla chiusura dell app',
      (tester) async {
    final profilo = await apri(tester,
        partenza: BirthIdentity.fromParts(birthDate: DateTime(1975, 7, 6)));

    await tester.tap(find.byKey(const Key('nascita_ora')));
    await posa(tester);
    await tester.tap(find.text('09').last);
    await posa(tester);
    // **PRIMA SI PORTA SOTTO GLI OCCHI, ordine CF voce 13.** La schermata
    // ha un campo in piu', "Dove vivi adesso", e il pulsante e' sceso
    // sotto la piega: un tocco su un riquadro fuori campo non arriva, e la
    // prova vedeva l'ora non salvata credendo che il salvataggio fosse
    // rotto.
    await tester.ensureVisible(find.byKey(const Key('nascita_salva')));
    await posa(tester);
    await tester.tap(find.byKey(const Key('nascita_salva')));
    await posa(tester);
    // Il salvataggio non lo aspetta nessuno: si lascia finire.
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    expect(profilo.identity.hasBirthTime, isTrue);

    // SI RIAPRE L'APP: un archivio nuovo che rilegge le stesse preferenze. Non
    // si rilegge lo stesso oggetto in memoria, che direbbe di si' comunque.
    final riletta = (await const ProfileStore().load()).identity;
    expect(riletta, isNotNull, reason: 'non si rilegge niente');
    expect(riletta!.hasBirthTime, isTrue,
        reason: 'l\'ora data dopo il Risveglio non sopravvive alla chiusura '
            'dell\'app');
    expect(riletta.birthMoment.hour, 9);
  });

  testWidgets('Il luogo gia dato non si perde correggendo l ora',
      (tester) async {
    // Questa schermata corregge giorno e ora: non deve poter cancellare in
    // silenzio un dato che non ha toccato. Senza il luogo la carta natale
    // ripiega, quindi perderlo qui romperebbe il cielo di chi corregge l'ora.
    final conLuogo = BirthIdentity.fromParts(
      birthDate: DateTime(1975, 7, 6),
      birthPlace: const BirthPlace(
        city: 'Torino',
        latitude: 45.07,
        longitude: 7.69,
        timeZoneId: 'Europe/Rome',
        utcOffsetMinutes: 120,
      ),
    );
    final profilo = await apri(tester, partenza: conLuogo);

    await tester.tap(find.byKey(const Key('nascita_ora')));
    await posa(tester);
    await tester.tap(find.text('09').last);
    await posa(tester);
    // **PRIMA SI PORTA SOTTO GLI OCCHI, ordine CF voce 13.** La schermata
    // ha un campo in piu', "Dove vivi adesso", e il pulsante e' sceso
    // sotto la piega: un tocco su un riquadro fuori campo non arriva, e la
    // prova vedeva l'ora non salvata credendo che il salvataggio fosse
    // rotto.
    await tester.ensureVisible(find.byKey(const Key('nascita_salva')));
    await posa(tester);
    await tester.tap(find.byKey(const Key('nascita_salva')));
    await posa(tester);

    expect(profilo.identity.birthPlace, isNotNull,
        reason: 'correggendo l\'ora si e\' perso il luogo di nascita, e senza '
            'luogo la carta natale ripiega sul cielo essenziale');
  });

  testWidgets('Anche il LUOGO si puo dare da qui, e sopravvive',
      (tester) async {
    // Senza latitudine e longitudine la funzione della carta natale rifiuta
    // prima di chiamare il motore: pretende otto campi e due sono questi. Chi
    // aveva concluso il Risveglio senza luogo non poteva piu' darlo, quindi
    // correggere la sola ora non lo avrebbe sbloccato.
    final profilo = await apri(tester,
        partenza: BirthIdentity.fromParts(birthDate: DateTime(1975, 7, 6)));
    expect(profilo.identity.birthPlace, isNull);

    await tester.enterText(
        find.byKey(const Key('nascita_luogo_field')), 'Torino');
    await tester.pump(const Duration(milliseconds: 400));
    await posa(tester);
    final citta = find.byKey(const Key('citta_Torino_Italia'));
    expect(citta, findsOneWidget,
        reason: 'da questa schermata non si puo scegliere una citta, quindi il '
            'luogo non si puo dare e la carta natale non arrivera mai');
    await tester.tap(citta);
    await posa(tester);
    // **PRIMA SI PORTA SOTTO GLI OCCHI, ordine CF voce 13.** La schermata
    // ha un campo in piu', "Dove vivi adesso", e il pulsante e' sceso
    // sotto la piega: un tocco su un riquadro fuori campo non arriva, e la
    // prova vedeva l'ora non salvata credendo che il salvataggio fosse
    // rotto.
    await tester.ensureVisible(find.byKey(const Key('nascita_salva')));
    await posa(tester);
    await tester.tap(find.byKey(const Key('nascita_salva')));
    await posa(tester);
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));

    expect(profilo.identity.birthPlace, isNotNull,
        reason: 'il luogo scelto non viene registrato');
    final riletta = (await const ProfileStore().load()).identity;
    expect(riletta!.birthPlace, isNotNull,
        reason: 'il luogo non sopravvive alla chiusura dell app');
  });

  test('Le porte che scrivono i dati di nascita sono enumerate', () {
    // Era UNA, l'onboarding, ed e' esattamente il difetto: bastava averlo
    // concluso perche' il dato diventasse immodificabile per sempre.
    final porte = <String>[];
    for (final f in sorgentiDiLib()) {
      final p = f.path.replaceAll(Platform.pathSeparator, '/');
      if (p.endsWith('profile_controller.dart')) continue;
      if (f.readAsStringSync().contains('setIdentity(')) porte.add(p);
    }
    expect(porte.length, 2,
        reason: 'le porte che scrivono i dati di nascita sono ${porte.length} '
            '($porte): se e\' tornata una sola, il dato e\' di nuovo '
            'irreversibile per chi ha gia\' concluso il Risveglio');
  });
}
