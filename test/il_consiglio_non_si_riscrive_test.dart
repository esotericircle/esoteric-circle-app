import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/features/maestri/ask/ask_maestri_screen.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// IL CONSIGLIO: L'ORDINE DELLO STARTER, LA SCRITTURA CHE NON RIPARTE, LA
/// SCHEDA CHE SI ADATTA. Ordine 2163, voce 10.
///
/// L'ipotesi dell'ordine, CONFERMATA sul codice: ListView smonta gli
/// elementi fuori vista anche con la lista di figli, e lo stato della
/// macchina da scrivere viveva nello State del widget: uscita e rientrata,
/// la scheda ripartiva da zero. Lo stato "gia' scritta" adesso vive nel
/// DATO della schermata.
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

  // LA CODA E' UNICA: la prima esca si ripeteva a ogni frase, e il finale
  // compariva gia' nei primi cento caratteri della riscrittura, quindi il
  // rosso non scattava. Si cerca una frase che esiste SOLO in fondo.
  String testoLungo(String seme) =>
      '${List.filled(12, '$seme parla al tuo cammino con voce ferma e ti '
              'accompagna oltre la soglia del dubbio.').join(' ')} '
      'La lanterna resta accesa fino in fondo al sentiero.';

  Route<void> ilConsiglio({required Maestro starter}) =>
      AskMaestriScreen.perLaSintesi(
        starter: starter,
        tema: 'una scelta da fare',
        lenti: [
          for (final m in Maestro.values)
            if (m != starter)
              MaestroLens.strati(
                  maestro: m,
                  glance: 'lo sguardo di ${m.displayName}',
                  reading: testoLungo(m.displayName),
                  invite: 'ascolta'),
        ],
      );

  Future<NavigatorState> monta(WidgetTester tester,
      {double altezza = 900}) async {
    silenzia();
    SharedPreferences.setMockInitialValues({'onboarding.done': true});
    tester.view.physicalSize = Size(430, altezza);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
        EsotericCircleApp(conIntro: false, services: AppServices.offline()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    return tester.state<NavigatorState>(find.byType(Navigator).last);
  }

  testWidgets('la prima scheda e' ' quella del Maestro di partenza, nei tre '
      'casi', (tester) async {
    final nav = await monta(tester);
    final colpe = <String>[];
    for (final starter in Maestro.values) {
      nav.push(ilConsiglio(starter: starter));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 900));
      // La prima carta nell'elenco: quella col bordo alto piu' in alto.
      Rect? primo;
      Maestro? di;
      for (final m in Maestro.values) {
        final carta = find.byKey(Key('ask_card_${m.id}'), skipOffstage: false);
        if (carta.evaluate().isEmpty) continue;
        final r = tester.getRect(carta.first);
        if (primo == null || r.top < primo.top) {
          primo = r;
          di = m;
        }
      }
      if (di != starter) {
        colpe.add('partendo da ${starter.displayName} la prima scheda e\' '
            'di ${di?.displayName ?? 'nessuno'}');
      }
      nav.pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    }
    expect(colpe, isEmpty, reason: colpe.join('\n'));
  });

  testWidgets('scesa in fondo e risalita, la prima scheda resta scritta',
      (tester) async {
    // SCHERMO BASSO APPOSTA: con lo schermo alto la scheda restava nella
    // zona di cache della lista e non veniva mai smontata, quindi il rosso
    // non scattava. La grandezza e' cambiata, non la soglia: e' la regola
    // dei rossi che non scattano.
    final nav = await monta(tester, altezza: 560);
    nav.push(ilConsiglio(starter: Maestro.caligo));
    await tester.pump();
    // La scrittura si esaurisce del tutto, poi si scorre.
    for (var i = 0; i < 26; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
    final lista = find.byKey(const Key('ask_results'));

    // In fondo e poi su, come farebbe il pollice.
    for (var i = 0; i < 14; i++) {
      await tester.drag(lista, const Offset(0, -500), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 120));
    }
    for (var i = 0; i < 14; i++) {
      await tester.drag(lista, const Offset(0, 500), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 120));
    }
    await tester.pump(const Duration(milliseconds: 300));

    // LA SCHEDA DI MEDORA: e' una lente INIZIALE, quindi porta il testo
    // lungo del harness; quella dello starter viene dall'oracolo.
    final carta = find.byKey(const Key('ask_lens_medora'));
    expect(carta, findsOneWidget);
    final testi = find.descendant(of: carta, matching: find.byType(Text));
    // SOLO IL TESTO VISIBILE: la macchina da scrivere tiene una copia
    // INVISIBILE del testo intero (Opacity a zero) per riservare l'altezza,
    // e la prima stesura di questa prova la leggeva come se fosse a video:
    // il rosso non scattava mai. La storia resta scritta qui.
    final corpi = <String>[];
    for (var i = 0; i < testi.evaluate().length; i++) {
      final elemento = tester.element(testi.at(i));
      final velo = elemento.findAncestorWidgetOfExactType<Opacity>();
      if (velo != null && velo.opacity == 0) continue;
      corpi.add(tester.widget<Text>(testi.at(i)).data ?? '');
    }
    final intero = corpi.any((t) =>
        t.contains('La lanterna resta accesa fino in fondo al sentiero.'));
    expect(intero, isTrue,
        reason: 'Risalendo, la scheda di Medora non mostra piu\' il testo '
            'intero: la macchina da scrivere e\' ripartita da capo.');

    // LA SCHEDA SI ADATTA AL TESTO: sotto l'ultimo elemento non resta
    // un'area vuota oltre la soglia dichiarata (i respiri interni della
    // carta). E' il terzo visto della voce: mezzo schermo vuoto dentro il
    // riquadro.
    const vuotoMassimo = 64.0;
    final rCarta = tester.getRect(carta);
    double fondoContenuto = rCarta.top;
    for (var i = 0; i < testi.evaluate().length; i++) {
      final r = tester.getRect(testi.at(i));
      if (r.bottom > fondoContenuto) fondoContenuto = r.bottom;
    }
    final vuoto = rCarta.bottom - fondoContenuto;
    // ignore: avoid_print
    print('CONSIGLIO: area vuota in fondo alla scheda = '
        '${vuoto.toStringAsFixed(1)} punti (massimo $vuotoMassimo)');
    expect(vuoto, lessThanOrEqualTo(vuotoMassimo),
        reason: 'Dentro la scheda restano ${vuoto.toStringAsFixed(1)} punti '
            'vuoti sotto l\'ultimo testo: la scheda non si adatta.');
  });
}
