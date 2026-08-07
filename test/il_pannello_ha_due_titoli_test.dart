import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_screen.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// IL PANNELLO HA DUE TITOLI, E TOCCANDO L'ALTRO L'ELENCO CAMBIA.
///
/// Ordine 2164, voce 7. Con l'ordine 2163 il pannello era diventato un solo
/// scorrevole con le due famiglie una dopo l'altra: Mauro vuole i due titoli
/// selezionabili, come nelle build precedenti. All'apertura e' scelto
/// DOMANDE FREQUENTI; toccando DOMANDE PERSONALI l'elenco sotto CAMBIA.
///
/// La prova gira nei tre domini, perche' le liste sono diverse per Maestro e
/// una sola casa non prova la regola.
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

  /// Le domande a video adesso: si leggono dalle righe dell'elenco.
  List<String> domandeAVideo(WidgetTester tester) {
    final elenco = find.byKey(const Key('elenco_suggerimenti'));
    if (elenco.evaluate().isEmpty) return const [];
    final testi = find.descendant(of: elenco, matching: find.byType(Text));
    return [
      for (var i = 0; i < testi.evaluate().length; i++)
        tester.widget<Text>(testi.at(i)).data ?? '',
    ];
  }

  testWidgets('nei tre domini: si apre sulle frequenti, e l\'altro titolo '
      'cambia l\'elenco', (tester) async {
    silenzia();
    // LA DATA DI NASCITA C'E': senza, le personali che nominano il Sole
    // tacciono per la regola del vero e il secondo titolo non comparirebbe.
    SharedPreferences.setMockInitialValues({
      'onboarding.done': true,
      'profile.birthDate': '1990-08-15',
    });
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final servizi = AppServices.offline();
    await tester.pumpWidget(
        EsotericCircleApp(conIntro: false, services: servizi));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    final nav = tester.state<NavigatorState>(find.byType(Navigator).last);

    final colpe = <String>[];
    for (final maestro in Maestro.values) {
      nav.push(MaestroChatScreen.route(maestro: maestro, services: servizi));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      // L'unica porta rimasta, ordine 2164 voci 3 e 4.
      await tester.tap(find.byKey(const Key('chat_stelline')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final id = maestro.id;
      if (find.byKey(const Key('pannello_suggerimenti')).evaluate().isEmpty) {
        colpe.add('$id: il pannello non si apre');
        continue;
      }
      // I DUE TITOLI CI SONO.
      if (find.byKey(const Key('titolo_frequenti')).evaluate().isEmpty) {
        colpe.add('$id: manca il titolo DOMANDE FREQUENTI');
      }
      if (find.byKey(const Key('titolo_personali')).evaluate().isEmpty) {
        colpe.add('$id: manca il titolo DOMANDE PERSONALI');
      }

      // ALL'APERTURA SONO LE FREQUENTI: si verifica sul CONTENUTO, non su
      // un colore, perche' il contenuto e' cio' che la persona legge.
      final primo = domandeAVideo(tester);
      if (primo.isEmpty) {
        colpe.add('$id: il pannello si apre senza nessuna domanda');
        nav.pop();
        await tester.pump(const Duration(milliseconds: 400));
        continue;
      }
      // Le personali nominano sempre un dato della carta: se in cima ci
      // fossero loro, la prima domanda parlerebbe di Sole, Luna o
      // Ascendente. Le frequenti no.
      final parlaDiCarta = primo.first.toLowerCase().contains('sole') ||
          primo.first.toLowerCase().contains('luna') ||
          primo.first.toLowerCase().contains('ascendente');
      if (parlaDiCarta) {
        colpe.add('$id: all\'apertura non ci sono le frequenti, la prima '
            'domanda e\' "${primo.first}"');
      }

      // SI TOCCA L'ALTRO TITOLO E L'ELENCO CAMBIA.
      await tester.tap(find.byKey(const Key('titolo_personali')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      final secondo = domandeAVideo(tester);
      if (secondo.isEmpty) {
        colpe.add('$id: toccando DOMANDE PERSONALI l\'elenco resta vuoto');
      } else if (secondo.first == primo.first) {
        colpe.add('$id: toccando DOMANDE PERSONALI l\'elenco NON cambia, '
            'resta "${primo.first}"');
      }
      // ignore: avoid_print
      print('PANNELLO $id: frequenti "${primo.first}" -> personali '
          '"${secondo.isEmpty ? "vuoto" : secondo.first}"');

      nav.pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      nav.pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    }
    expect(colpe, isEmpty, reason: colpe.join('\n'));
  });
}
