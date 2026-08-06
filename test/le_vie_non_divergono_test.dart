import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_screen.dart';
import 'package:esoteric_circle/features/shell/esplora.dart';
import 'package:esoteric_circle/features/shell/santuario_bottom_bar.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LE DUE SUPERFICI CHE PORTANO ALLE STESSE VIE DICONO LE STESSE COSE.
///
/// La barra del guscio e la striscia Esplora sono due superfici diverse dello
/// stesso elenco di destinazioni. Finche' sono state due liste scritte a mano
/// hanno divergiuto: cinque voci contro quattro, e la voce del Cerchio con due
/// icone diverse, la mezzaluna dentro il cerchio nella barra e una mezzaluna
/// di sistema in Esplora.
///
/// Questa prova NON confronta due costanti fra loro, che direbbero sempre la
/// stessa cosa per costruzione: legge cio' che arriva a VIDEO nelle due
/// superfici montate davvero, e cade se una delle due si mette a dire qualcosa
/// di suo.
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

  Future<NavigatorState> monta(WidgetTester tester) async {
    silenzia();
    SharedPreferences.setMockInitialValues({'onboarding.done': true});
    tester.view.physicalSize = const Size(1080, 2391);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
        EsotericCircleApp(conIntro: false, services: AppServices.offline()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    return tester.state<NavigatorState>(find.byType(Navigator).last);
  }

  /// Le etichette che si leggono dentro un sottoalbero, nell'ordine in cui
  /// stanno sullo schermo da sinistra a destra.
  List<String> etichetteDi(WidgetTester tester, Finder radice) {
    final testi = find.descendant(of: radice, matching: find.byType(Text));
    final trovati = <(double, String)>[];
    for (final e in testi.evaluate()) {
      final t = e.widget as Text;
      final dato = t.data;
      if (dato == null || dato.isEmpty) continue;
      trovati.add((tester.getCenter(find.byWidget(t)).dx, dato));
    }
    trovati.sort((a, b) => a.$1.compareTo(b.$1));
    return trovati.map((e) => e.$2).toList();
  }

  testWidgets('la barra del guscio e Esplora portano le stesse vie',
      (tester) async {
    final nav = await monta(tester);

    // Nel Santuario si legge la barra del guscio.
    final dallaBarra =
        etichetteDi(tester, find.byType(SantuarioBottomBar));

    // In chat si legge Esplora aperta, che e' la stessa promessa su un'altra
    // superficie.
    nav.push(MaestroChatScreen.route(
        maestro: Maestro.medora, services: AppServices.offline()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.byKey(const Key('esplora_linguetta')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    final daEsplora = etichetteDi(tester, find.byKey(const Key('esplora_vie')));

    expect(daEsplora, equals(dallaBarra),
        reason: 'Le due superfici divergono. La barra dice $dallaBarra, '
            'Esplora dice $daEsplora. Sono lo stesso elenco di destinazioni '
            'visto da due parti: se una porta una voce che l\'altra non ha, '
            'l\'app dichiara due mappe diverse dello stesso Cerchio.');
  });

  testWidgets('la voce del Cerchio ha lo stesso disegno nelle due superfici',
      (tester) async {
    final nav = await monta(tester);
    Type disegnoDelCerchio(Finder radice) {
      final voce = find.descendant(
          of: radice, matching: find.byKey(const Key('via_icona_cerchio')));
      expect(voce, findsOneWidget,
          reason: 'La voce del Cerchio non porta il disegno dichiarato '
              'dall\'elenco unico.');
      return tester.widget(voce).runtimeType;
    }

    final nellaBarra = disegnoDelCerchio(find.byType(SantuarioBottomBar));

    nav.push(MaestroChatScreen.route(
        maestro: Maestro.medora, services: AppServices.offline()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.byKey(const Key('esplora_linguetta')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    final inEsplora =
        disegnoDelCerchio(find.byKey(const Key('esplora_vie')));

    expect(inEsplora, equals(nellaBarra),
        reason: 'Il Cerchio si disegna in due modi: $nellaBarra nella barra e '
            '$inEsplora in Esplora. La stessa via non puo\' avere due volti.');
  });

  testWidgets('la striscia aperta resta alta quanto dichiara', (tester) async {
    // Con una via in piu' la striscia non deve crescere: EsploraScope usa
    // l'altezza dichiarata per fare posto, e se crescesse in silenzio il
    // contenuto tornerebbe sotto la striscia.
    final nav = await monta(tester);
    nav.push(MaestroChatScreen.route(
        maestro: Maestro.medora, services: AppServices.offline()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.byKey(const Key('esplora_linguetta')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final vera = tester.getSize(find.byType(EsploraStriscia)).height;
    expect((vera - EsploraStriscia.altezzaAperta).abs(), lessThanOrEqualTo(2.0),
        reason: 'Con la via in piu\' la striscia misura '
            '${vera.toStringAsFixed(1)} punti e ne dichiara '
            '${EsploraStriscia.altezzaAperta}: EsploraScope usa il numero '
            'dichiarato per fare posto al contenuto.');
  });
}
