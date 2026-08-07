import 'dart:io';

import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_screen.dart';
import 'package:esoteric_circle/features/maestri/chat/widgets/chat_suggestions.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LE DUE FAMIGLIE DI DOMANDE, INTERE E DIVISE, SULLA PRIMA SCHERMATA.
///
/// La regressione: il 12 luglio 2026, commit 93e1481, il pannello coi due
/// segmenti fu sostituito da TRE chip senza famiglie, col resto dietro un
/// bottone discreto. Mauro le rivuole a video, divise in frequenti e
/// personali. Le personali dicono il vero: una domanda che nomina un dato
/// assente non compare, e la rotazione nel giorno e' deterministica.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silenzia() {
    final messenger = binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
      (call) async => null,
    );
    for (final nome in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      messenger.setMockStreamHandler(
        EventChannel(nome),
        MockStreamHandler.inline(onListen: (args, events) {}),
      );
    }
  }

  testWidgets('i tre domini, enumerati: due famiglie, conti pieni',
      (tester) async {
    silenzia();
    SharedPreferences.setMockInitialValues({
      'onboarding.done': true,
      // La data di nascita c'e': il Sole si calcola dalla data, quindi le
      // personali sul Sole devono comparire. Luna e Ascendente chiedono la
      // carta, che qui non c'e': quelle domande NON devono comparire.
      'profile.birthDate': '1990-08-15',
    });
    tester.view.physicalSize = const Size(1080, 2391);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    final servizi = AppServices.offline();
    await tester.pumpWidget(
        EsotericCircleApp(conIntro: false, services: servizi));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    final nav = tester.state<NavigatorState>(find.byType(Navigator).last);

    final colpe = <String>[];
    for (final maestro in Maestro.fixedOrder) {
      nav.push(
          MaestroChatScreen.route(maestro: maestro, services: servizi));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      final frequenti =
          find.byKey(const Key('chat_famiglia_frequenti')).evaluate();
      final personali =
          find.byKey(const Key('chat_famiglia_personali')).evaluate();
      if (frequenti.isEmpty) {
        colpe.add('${maestro.displayName}: manca la famiglia delle '
            'frequenti');
      }
      if (personali.isEmpty) {
        colpe.add('${maestro.displayName}: manca la famiglia delle '
            'personali');
      }
      // Il conto: le frequenti TUTTE, non un tre scritto a mano.
      final attese = SuggestionSets.frequent(maestro).length;
      var visti = 0;
      for (final domanda in SuggestionSets.frequent(maestro)) {
        if (find.text(domanda).evaluate().isNotEmpty) visti++;
      }
      if (visti < attese) {
        colpe.add('${maestro.displayName}: frequenti a video $visti su '
            '$attese, il taglio a tre e\' tornato');
      }
      // Le personali disponibili con la sola data: quelle sul Sole, tutte.
      // Quelle su Luna e Ascendente non devono esserci: direbbero il falso.
      for (final domanda in SuggestionSets.personal(maestro)) {
        final b = domanda.toLowerCase();
        final visibile = find.text(domanda).evaluate().isNotEmpty;
        if ((b.contains('luna') || b.contains('ascendente')) && visibile) {
          colpe.add('${maestro.displayName}: "$domanda" nomina un dato '
              'assente ed e\' comparsa lo stesso');
        }
        if (b.contains('sole') &&
            !b.contains('luna') &&
            !b.contains('ascendente') &&
            !visibile) {
          colpe.add('${maestro.displayName}: "$domanda" ha il suo dato '
              'e non compare');
        }
      }
      nav.pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    }
    expect(colpe, isEmpty, reason: colpe.join('\n'));
  });

  test('la prima schermata non monta piu\' i soli starters', () {
    final testo =
        File('lib/features/maestri/chat/maestro_chat_screen.dart')
            .readAsStringSync();
    expect(testo.contains('SuggestionSets.starters('), isFalse,
        reason: 'La prima schermata e\' tornata ai tre chip senza famiglie: '
            'e\' la riduzione del 12 luglio che Mauro ha revocato.');
  });

  test('la rotazione e\' deterministica su persona e giorno', () {
    final a = SuggestionSets.ruotaPerGiorno(
        SuggestionSets.personal(Maestro.medora), 'x', DateTime(2026, 8, 7));
    final b = SuggestionSets.ruotaPerGiorno(
        SuggestionSets.personal(Maestro.medora), 'x', DateTime(2026, 8, 7));
    expect(a, b, reason: 'Stessa persona e stesso giorno, ordine diverso: '
        'c\'e\' un caso vero nella rotazione.');
    final c = SuggestionSets.ruotaPerGiorno(
        SuggestionSets.personal(Maestro.medora), 'x', DateTime(2026, 8, 9));
    expect(a, isNot(c),
        reason: 'Due giorni diversi, stesso ordine: la rotazione non ruota.');
  });
}
