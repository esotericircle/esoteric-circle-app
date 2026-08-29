import 'dart:io';

import 'package:esoteric_circle/features/account/riscatta_l_invito.dart';
import 'package:esoteric_circle/features/onboarding/domanda_dell_invito.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// L'INVITO PORTA IL SUO PREMIO. Ordine CC voce 08.
///
/// **Cosa difende questa prova.** Che la domanda venga fatta a chi arriva
/// invece di aspettarlo dentro un menu'; che gli appunti si leggano solo sul
/// tocco della persona e solo per prenderne un codice nostro; e che le tre
/// difese del server siano ancora tutte e tre al loro posto, perche' il
/// vincolo della voce dice che non si indeboliscono.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('le tre difese del server sono ancora tutte e tre', () {
    final server = File('functions/src/cerchio.ts').readAsStringSync();
    final pezzo = server.substring(server.indexOf('export const riscattaLInvito'),
        server.indexOf('export const muoviGliEos'));
    final difese = <String, bool>{
      // 1. Non ci si invita da soli.
      'non ci si invita da soli': pezzo.contains('codice === uid'),
      // 2. Non si riscatta due volte: chi ha gia' un invitante non ne prende
      //    un secondo, e il controllo sta dentro una transazione.
      'non si riscatta due volte': pezzo.contains('gia.invitatoDa') &&
          pezzo.contains('runTransaction'),
      // 3. Il premio e' idempotente: il movimento porta un identificativo
      //    fisso, e se esiste gia' non si paga.
      'il premio e\' idempotente':
          pezzo.contains('`invito-\${uid}`') && pezzo.contains('giaPagato.exists'),
    };
    // ignore: avoid_print
    print('ORDINE CC VOCE 08: difese del server in piedi '
        '${difese.values.where((v) => v).length} su ${difese.length}');
    final cadute = difese.entries.where((e) => !e.value).map((e) => e.key);
    expect(cadute, isEmpty,
        reason: 'il vincolo della voce dice che le tre difese non si '
            'indeboliscono, e queste non ci sono piu\': $cadute');
  });

  test('la domanda si fa a chi arriva, e una volta sola', () {
    final casa = File('lib/features/santuario/santuario_screen.dart')
        .readAsStringSync();
    expect(casa.contains('DomandaDellInvito.chiedi'), isTrue,
        reason: 'nessuno chiede piu\' a chi arriva se lo ha invitato '
            'qualcuno, e il premio resta nel menu\' Account');
    expect(casa.contains('MemoriaDellInvito.giaChiesto()'), isTrue,
        reason: 'la domanda tornerebbe a ogni apertura');
    // **L'INVITO VIENE PRIMA DELLA MISURA**, e una domanda per apertura: due
    // fogli in fila si rispondono a caso.
    expect(casa.indexOf('_forseChiediLInvito()') <
        casa.indexOf('_forseChiediLaMisura()'), isTrue,
        reason: 'la misura, che non scade, passa davanti all\'invito, che sta '
            'negli appunti solo per pochi giorni');
  });

  test('la chiave della domanda se ne va con la cancellazione', () {
    expect(MemoriaDellInvito.chiave.startsWith('avvisi.'), isTrue,
        reason: 'chi cancella tutto si porterebbe dietro la domanda gia\' '
            'fatta, e al rientro non gliela si farebbe piu\'');
  });

  test('dagli appunti entra solo cio\' che ha la forma di un codice', () {
    // I limiti sono gli stessi del server, 8 e 200: due regole diverse sullo
    // stesso dato prima o poi divergono.
    expect(sembraUnCodiceDInvito('abc'), isFalse);
    expect(sembraUnCodiceDInvito('a' * 201), isFalse);
    expect(sembraUnCodiceDInvito('la mia password segreta'), isFalse,
        reason: 'una frase qualunque degli appunti finirebbe nel campo');
    expect(sembraUnCodiceDInvito('kJ3nX9aQ2b.medora'), isTrue);
    // E dal link intero si prende solo il codice.
    expect(
        codiceDaCioCheEStatoIncollato(
            'https://esotericircle.app?invito=kJ3nX9aQ2b.medora'),
        'kJ3nX9aQ2b.medora');
  });

  testWidgets('gli appunti si leggono solo sul tocco, mai da soli',
      (tester) async {
    SharedPreferences.setMockInitialValues(const {});
    var quanteLetture = 0;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform, (chiamata) async {
      if (chiamata.method == 'Clipboard.getData') {
        quanteLetture++;
        return <String, dynamic>{
          'text': 'https://esotericircle.app?invito=kJ3nX9aQ2b.medora',
        };
      }
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));

    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: DomandaDellInvito()),
    ));
    await tester.pumpAndSettle();
    // ignore: avoid_print
    print('ORDINE CC VOCE 08: letture degli appunti prima del tocco '
        '$quanteLetture');
    expect(quanteLetture, 0,
        reason: 'l\'app guarda gli appunti da sola, e li\' dentro c\'e\' '
            'quello che la persona ha copiato per altro');

    await tester.tap(find.byKey(const Key('invito_incolla')));
    await tester.pumpAndSettle();
    expect(quanteLetture, 1);
    final campo = tester.widget<TextField>(
        find.byKey(const Key('invito_campo')));
    expect(campo.controller!.text, 'kJ3nX9aQ2b.medora',
        reason: 'il tocco su Incolla non porta dentro il codice');
  });

  testWidgets('cio\' che non e\' un codice non entra, e non si mostra',
      (tester) async {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform, (chiamata) async {
      if (chiamata.method == 'Clipboard.getData') {
        return <String, dynamic>{'text': 'la mia password segreta'};
      }
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));

    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: DomandaDellInvito()),
    ));
    await tester.tap(find.byKey(const Key('invito_incolla')));
    await tester.pumpAndSettle();
    final campo = tester.widget<TextField>(
        find.byKey(const Key('invito_campo')));
    expect(campo.controller!.text, isEmpty);
    // E soprattutto: cio' che c'era negli appunti non finisce a video.
    expect(find.textContaining('password'), findsNothing,
        reason: 'l\'app rimette a schermo quello che aveva negli appunti chi '
            'legge, e non e\' roba nostra');
    expect(find.byKey(const Key('invito_avviso')), findsOneWidget);
  });

  testWidgets('la via d\'uscita c\'e\', e non chiede niente', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: DomandaDellInvito()),
    ));
    final uscita = find.byKey(const Key('invito_nessuno'));
    expect(uscita, findsOneWidget);
    expect(tester.getRect(uscita).height, greaterThanOrEqualTo(48.0),
        reason: 'la via d\'uscita e\' piu\' bassa del bersaglio del dito');
  });
}
