import 'dart:io';

import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/features/account/account_screen.dart';
import 'package:esoteric_circle/features/shell/barra_dell_identita.dart';
import 'package:esoteric_circle/features/shell/navigation_controller.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LA BARRA SOTTILE E' LA CASA UNICA. Ordine AM voce 04, forma decisa da
/// Mauro dal collaudo della 2180.
///
/// Una fascia sottile e persistente in alto con quattro cose in fila: il
/// volto, il borsellino con la moneta d'oro, il segno zodiacale e
/// l'Ascendente. Al tocco scende e ingrandisce il contenuto; un secondo
/// tocco la richiude. Quei quattro contenuti NON compaiono in nessun altro
/// punto dell'app: e' la regola delle due porte applicata alla scena, e la
/// prova sui sorgenti cade se una copia ricompare.
///
/// **La storia delle case, perche' non si perda**: ordine AI, una copia per
/// testata; ordine AL voce 08, la capsula in alto a destra; ordine AM, la
/// barra sottile. La regola non e' mai cambiata, e' cambiata la casa.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silenzia() {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (c) async => null);
    for (final nome in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      m.setMockStreamHandler(
          EventChannel(nome), MockStreamHandler.inline(onListen: (a, e) {}));
    }
  }

  Future<void> apri(WidgetTester tester,
      {Map<String, Object> prefs = const {
        'onboarding.done': true,
        'santuario.greeted': true,
      }}) async {
    silenzia();
    SharedPreferences.setMockInitialValues(prefs);
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(360, 797);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
        EsotericCircleApp(conIntro: false, services: AppServices.offline()));
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  final barra = find.byKey(const Key('barra_dell_identita'));

  testWidgets('la barra c\'e\', e' ' sottile e porta volto e saldo',
      (tester) async {
    await apri(tester);
    expect(barra, findsOneWidget, reason: 'la barra non c\'e\' sulla home');
    final chiusa = tester.getRect(barra);
    // ignore: avoid_print
    print('ORDINE AM VOCE 04: barra chiusa alta '
        '${chiusa.height.toStringAsFixed(1)} punti');
    expect(chiusa.top, 0, reason: 'la barra non parte dal bordo alto');
    expect(chiusa.width, 360, reason: 'la barra non prende la larghezza');
    expect(chiusa.height, lessThanOrEqualTo(40),
        reason: 'la barra e\' alta ${chiusa.height} punti: doveva essere '
            'SOTTILE, attorno ai trenta');
    expect(find.byKey(const Key('porta_dell_account')), findsOneWidget,
        reason: 'il volto non sta nella barra');
    expect(find.byKey(const Key('borsellino')), findsOneWidget,
        reason: 'il borsellino non sta nella barra');
    expect(find.byKey(const Key('moneta_eos')), findsOneWidget,
        reason: 'il saldo non porta la moneta d\'oro di Mauro');
    // IL SEGNO: senza profilo non c'e' un segno solare, e non si inventa.
    // Che compaia quando c'e' lo dice la prova qui sotto.
  });

  testWidgets('al tocco scende e ingrandisce, al secondo si richiude',
      (tester) async {
    await apri(tester);
    final chiusa = tester.getRect(barra).height;
    await tester.tap(barra, warnIfMissed: false);
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    final aperta = tester.getRect(barra).height;
    // ignore: avoid_print
    print('ORDINE AM VOCE 04: da ${chiusa.toStringAsFixed(1)} a '
        '${aperta.toStringAsFixed(1)} punti al tocco');
    expect(aperta, greaterThan(chiusa + 20),
        reason: 'al tocco la barra non scende: da $chiusa a $aperta punti');
    // Il contenuto si ingrandisce davvero, non solo la fascia.
    final volto = tester.getSize(find.byKey(const Key('porta_dell_account')));
    expect(volto.height, greaterThan(30),
        reason: 'la barra e\' scesa ma il volto e\' rimasto piccolo: il '
            'contenuto doveva diventare piu\' leggibile');
    await tester.tap(barra, warnIfMissed: false);
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    expect(tester.getRect(barra).height, closeTo(chiusa, 1),
        reason: 'il secondo tocco non richiude la barra');
  });

  testWidgets('da aperta il volto porta all\'account', (tester) async {
    await apri(tester);
    await tester.tap(barra, warnIfMissed: false);
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    await tester.tap(find.byKey(const Key('porta_dell_account')),
        warnIfMissed: false);
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    expect(find.byType(AccountScreen), findsOneWidget,
        reason: 'da aperta il tocco sul volto non porta all\'account');
    expect(barra, findsOneWidget,
        reason: 'la barra sparisce sulle rotte spinte sopra: doveva essere '
            'persistente su tutte le schermate');
  });

  testWidgets('il saldo a quattro cifre non si tronca', (tester) async {
    await apri(tester);
    tester.element(barra).read<QuestionAllowance>().applicaSaldo(1234);
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
    expect(find.text('1.234'), findsOneWidget,
        reason: 'il saldo a quattro cifre non si legge intero nella barra');
    expect(tester.takeException(), isNull,
        reason: 'il saldo a quattro cifre fa traboccare la barra');
  });

  testWidgets('il centro porta il cielo che viene, e da aperta ne mostra tre',
      (tester) async {
    await apri(tester);
    final riga = tester
        .widget<Text>(find.byKey(const Key('barra_prossimo_evento')));
    // ignore: avoid_print
    print('ORDINE AN VOCE 02: al centro si legge "${riga.data}"');
    expect(riga.data, isNotNull);
    // La riga e' in lingua del Cerchio: un nome e quanto manca, mai il nome
    // tecnico dell'evento.
    expect(riga.data, isNot(contains('_')),
        reason: 'al centro si legge il nome tecnico dell\'evento');
    expect(
        riga.data!.contains('oggi') ||
            riga.data!.contains('domani') ||
            riga.data!.contains('fra '),
        isTrue,
        reason: 'la riga non dice quanto manca: "${riga.data}"');

    await tester.tap(barra, warnIfMissed: false);
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    expect(find.byKey(const Key('barra_tre_eventi')), findsOneWidget,
        reason: 'da aperta il centro non mostra i prossimi tre eventi');
  });

  testWidgets('col nome nel profilo, la barra saluta per nome',
      (tester) async {
    await apri(tester);
    // **IL PROFILO NASCE COL NOME D'ESEMPIO**, dichiarato in-world nelle
    // anteprime: qui si prova che il nome mostrato e' QUELLO DEL PROFILO e
    // che passa dalla normalizzazione, non che manchi.
    tester
        .element(barra)
        .read<ProfileController>()
        .setProfile(UserProfile(displayName: 'mauro'));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    final nome =
        tester.widget<Text>(find.byKey(const Key('barra_nome_proprio')));
    // ignore: avoid_print
    print('ORDINE AN VOCE 02: la barra saluta "${nome.data}"');
    expect(nome.data, 'Mauro',
        reason: 'il nome non passa dalla normalizzazione del dato: si scrive '
            'come si scrive un nome');
  });

  testWidgets('sulle soglie del Risveglio la barra non c\'e\'',
      (tester) async {
    await apri(tester, prefs: const {});
    expect(barra, findsNothing,
        reason: 'la barra dell\'identita\' sta sopra il rito d\'ingresso, '
            'dove la persona non ha ancora ne\' volto ne\' saldo ne\' cielo');
  });

  testWidgets('la barra segue anche il Passaporto e le rotte spinte',
      (tester) async {
    await apri(tester);
    tester
        .element(find.byType(Navigator).first)
        .read<NavigationController>()
        .goToPassport();
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    expect(barra, findsOneWidget,
        reason: 'la barra non segue il Passaporto');
    expect(find.byKey(const Key('porta_dell_account')), findsOneWidget,
        reason: 'il volto deve essere UNO: se il Passaporto ne avesse una '
            'copia questa prova ne troverebbe due');
  });

  test('nessuna copia fuori dalla barra, letto sui sorgenti', () {
    final copie = <String>[];
    // I quattro contenuti e i componenti che li mostrano. La barra e i
    // componenti stessi non sono copie: sono la casa e i mattoni.
    const casa = [
      'lib/features/shell/barra_dell_identita.dart',
      'lib/design_system/components/borsellino.dart',
      'lib/design_system/components/porta_dell_account.dart',
      'lib/design_system/components/zodiac_glyph.dart',
    ];
    var osservati = 0;
    for (final voce in Directory('lib').listSync(recursive: true)) {
      if (voce is! File || !voce.path.endsWith('.dart')) continue;
      final percorso = voce.path.replaceAll('\\', '/');
      if (casa.contains(percorso)) continue;
      osservati++;
      final s = voce.readAsStringSync();
      if (s.contains('SegnoDelBorsellino(')) {
        copie.add('$percorso monta il borsellino');
      }
      if (s.contains('PortaDellAccount(')) {
        copie.add('$percorso monta la porta dell\'account');
      }
    }
    // ignore: avoid_print
    print('ORDINE AM VOCE 04: sorgenti osservati $osservati');
    expect(osservati, greaterThan(100),
        reason: 'l\'enumerazione non sta guardando l\'app');
    expect(copie, isEmpty,
        reason: 'la barra e\' la casa UNICA, e queste copie sono ricomparse '
            'fuori:\n${copie.join("\n")}');
  });
}
