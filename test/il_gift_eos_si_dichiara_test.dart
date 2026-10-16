// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/cerchio/il_cerchio_sociale.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/cerchio/scheda_dell_amico_screen.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'cardinale_minimo.dart';
import 'porta_finta_del_cerchio_sociale.dart';

/// **IL GIFT EOS SI DICHIARA, INVECE DI FALLIRE, ordine EZ voce 05.**
///
/// Oggi nessuna porta del server accredita Eos regalabili: ne' un acquisto,
/// che non esiste, ne' la dote del piano, che si accreditera' quando gli
/// abbonamenti saranno acquistabili. Il saldo regalabile vale zero per tutti
/// per costruzione, e la voce si presenta dichiarata non attiva: si vede,
/// dice da cosa si apre, e nessun tocco prova a spendere (regola R15: un
/// controllo o e' collegato o e' dichiarato inattivo).
void main() {
  test('EZ.05: nessuna porta del server alza gli Eos regalabili', () {
    // Se un giorno una porta li accredita, il gift va aperto: questa prova
    // lo dice prima che la persona trovi un pulsante che non fa niente.
    final alzano = <String>[];
    var guardati = 0;
    var scritture = 0;
    // **La grandezza misurata, dopo la Regola A (A11).** La prima forma
    // cercava le scritture che non cominciavano per "r", per lasciar passare
    // `regalabili - quanti`: cosi' era cieca anche a `regalabili + quanti`.
    // Adesso ogni scrittura del campo e' sospetta, e passa soltanto quella
    // che SOTTRAE dal valore stesso; la dichiarazione del tipo non scrive.
    final scrittura = RegExp(r'regalabili:\s*(?!number\b)\S');
    final toglie = RegExp(r'regalabili:\s*regalabili\s*-\s*\w');
    for (final f in Directory('functions/src').listSync().whereType<File>()) {
      if (!f.path.endsWith('.ts') || f.path.endsWith('.test.ts')) continue;
      guardati++;
      final righe = f.readAsLinesSync();
      for (var i = 0; i < righe.length; i++) {
        final r = righe[i];
        if (r.trimLeft().startsWith('*') || r.trimLeft().startsWith('//')) {
          continue;
        }
        if (!scrittura.hasMatch(r)) continue;
        scritture++;
        if (!toglie.hasMatch(r)) alzano.add('${f.path}:${i + 1}: ${r.trim()}');
      }
    }
    cardinaleMinimo(guardati, 20,
        cosa: 'file del server',
        perche: 'Il 4 ottobre 2026 functions/src porta piu\' di venti file: '
            'su una cartella vuota nessuna porta alzerebbe niente.');
    cardinaleMinimo(scritture, 1,
        cosa: 'scritture del campo regalabili',
        perche: 'Il gift che li toglie esiste: se la prova non lo trova, non '
            'sta guardando il campo giusto.');
    print('EZ.05 LE PORTE CHE ALZANO GLI EOS REGALABILI: ${alzano.length} '
        '$alzano, su $scritture scritture del campo in $guardati file; il '
        'gift aperto ${IlCerchioSociale.ilGiftEosEAperto}');
    expect(alzano, isEmpty,
        reason: 'una porta accredita Eos regalabili: il gift va aperto, '
            'cambiando IlCerchioSociale.ilGiftEosEAperto');
    expect(IlCerchioSociale.ilGiftEosEAperto, isFalse);
  });

  testWidgets(
      'EZ.05: la voce del gift si vede, si dichiara, e il tocco non '
      'spende', (tester) async {
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2391);
    addTearDown(tester.view.reset);
    final finta = PortaFintaDelCerchioSociale();
    final sociale = IlCerchioSociale(porta: finta);
    await sociale.sincronizza(
        identita: BirthIdentity(birthMoment: DateTime(1990, 5, 12, 10)));
    final amico = PersonaDelCerchio.da(PortaFintaDelCerchioSociale.amico);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<IlCerchioSociale>.value(value: sociale),
        Provider<AppServices>.value(value: AppServices.offline(null, finta)),
      ],
      child: MaterialApp(
        theme: AppTheme.dark(),
        home: MaestroScope(
            neutro: true, child: SchedaDellAmicoScreen(amico: amico)),
      ),
    ));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    final velo = find.byKey(const Key('amico_regala_eos_dietro_il_velo'));
    await tester.scrollUntilVisible(velo, 300,
        scrollable: find.byType(Scrollable).first);
    await tester.pump();
    expect(find.byKey(const Key('amico_regala_eos')), findsNothing,
        reason: 'il pulsante che tenta e fallisce e\' tornato');
    expect(find.text(IlCerchioSociale.rigaDelGiftEos), findsOneWidget);
    expect(find.text('Dietro il velo'), findsOneWidget);
    await tester.tap(velo, warnIfMissed: false);
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    final chieste = finta.chieste.map((c) => c.$1).toList();
    print('EZ.05 DOPO IL TOCCO: porte chieste $chieste');
    expect(chieste, isNot(contains('regalaGliEos')));
    expect(find.byKey(const Key('regala_conferma')), findsNothing,
        reason: 'il tocco ha aperto il foglio che spende');
  });
}
