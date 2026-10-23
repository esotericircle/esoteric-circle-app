import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_screen.dart';
import 'package:esoteric_circle/features/maestri/domain_screen.dart';
import 'package:esoteric_circle/features/schede/la_riga_delle_schede.dart';
import 'package:esoteric_circle/features/schede/la_scheda_dell_arte.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/foundation.dart';
import 'package:esoteric_circle/features/santuario/le_righe_della_casa.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **LE SCHEDE, LA HOME E I DOMINI SU IPHONE.** Ordine EO, consegna del
/// fondatore: *"Fai tutti i test su Cell e controlla che tutto funzioni anche
/// su iPhone."*
///
/// **Da Windows un iPhone non si accende**, e la build iOS la lancia il
/// fondatore su Codemagic, che la caricherebbe su TestFlight (*"Non
/// consegnare la versione iPhone, prima devo controllare io"*). Qui si fa la
/// parte vera che si puo' fare da qui: l'app intera montata con la
/// piattaforma iOS, cioe' con la fisica di scorrimento, i gesti e la
/// tipografia di iOS, e le stesse domande che il telefono Android ha avuto.
/// Alla misura di un iPhone 13, 390 per 844 a tre pixel per punto.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> monta(WidgetTester tester) async {
    final messenger = binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (call) async => null);
    for (final nome in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      messenger.setMockStreamHandler(EventChannel(nome),
          MockStreamHandler.inline(onListen: (args, events) {}));
    }
    SharedPreferences.setMockInitialValues({'onboarding.done': true});
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    tester.view.padding = const FakeViewPadding(top: 141, bottom: 102);
    tester.view.viewPadding = const FakeViewPadding(top: 141, bottom: 102);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
        EsotericCircleApp(conIntro: false, services: AppServices.offline()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
  }

  Future<void> aspetta(WidgetTester tester) async {
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  final soloIos = TargetPlatformVariant.only(TargetPlatform.iOS);

  // Ordine ER voce 08: le righe della home sono undici, e l'ultima e' "Il
  // tuo destino" (prima erano dieci, con "La tua energia" in fondo).
  testWidgets('su iPhone la home mostra le undici righe, e una scheda si apre',
      (tester) async {
    await monta(tester);
    expect(defaultTargetPlatform, TargetPlatform.iOS);
    final righe = find.byType(LaRigaDelleSchede, skipOffstage: false);
    expect(righe, findsNWidgets(11));
    // Si scorre la home col dito, con la fisica di iOS, fino all'ultima riga.
    final corpo = find.byWidgetPredicate(
        (w) => w is Scrollable && w.axisDirection == AxisDirection.down);
    // Si scorre finche' la prima scheda dell'ultima riga e' in vista, non il
    // suo titolo: con le schede piu' basse dell'ordine ER il titolo a 600
    // punti lasciava le schede sotto il bordo.
    final primaDellUltima = LeRigheDellaCasa.righe.last.arti.first;
    final primaScheda = find.byKey(Key('riga_il_tuo_destino_$primaDellUltima'),
        skipOffstage: false);
    for (var i = 0; i < 30; i++) {
      if (primaScheda.evaluate().isNotEmpty) {
        final r = tester.getRect(primaScheda);
        if (r.top > 150 && r.bottom < 700) break;
      }
      await tester.drag(corpo.first, const Offset(0, -300));
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(find.byKey(const Key('riga_titolo_il_tuo_destino')), findsOneWidget);
    // Una riga scorre di lato, col dito.
    final riga = find.byKey(const Key('riga_scorre_il_tuo_destino'));
    // La prima scheda della riga, dall'elenco della riga.
    final primaArte = tester
        .widgetList<LaRigaDelleSchede>(find.byType(LaRigaDelleSchede))
        .firstWhere((r) => r.chiave == 'il_tuo_destino')
        .arti
        .first
        .id;
    // La scheda si cerca anche fuori scena: in fondo alla pagina il viewport
    // la conta nella sua fascia di riserva, ma il dito la colpisce.
    final scheda =
        find.byKey(Key('riga_il_tuo_destino_$primaArte'), skipOffstage: false);
    final prima = tester.getTopLeft(scheda).dx;
    // Il dito parte dalla scheda: il centro della riga intera, con le
    // schede basse dell'ordine ER, puo' cadere sotto la fascia in fondo.
    expect(riga, findsOneWidget);
    await tester.dragFrom(tester.getCenter(scheda), const Offset(-200, 0));
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.getTopLeft(scheda).dx, lessThan(prima),
        reason: 'su iPhone la riga non scorre di lato');
  }, variant: soloIos);

  testWidgets('su iPhone la "i" gira la scheda e lo stesso angolo la rigira',
      (tester) async {
    await monta(tester);
    final scheda = find.byKey(const Key('riga_preferite_horoscope'));
    await tester.ensureVisible(scheda);
    await tester.pump(const Duration(milliseconds: 300));
    final r = tester.getRect(find.descendant(
        of: scheda, matching: find.byKey(const Key('scheda_tocco_horoscope'))));
    final angolo = Offset(r.right - 20, r.top + 20);
    LaSchedaDellArteState stato() =>
        tester.state<LaSchedaDellArteState>(find.descendant(
            of: scheda,
            matching: find.byType(LaSchedaDellArte),
            matchRoot: true));
    await tester.tapAt(angolo);
    await aspetta(tester);
    expect(stato().girata, isTrue);
    await tester.tapAt(angolo);
    await aspetta(tester);
    expect(stato().girata, isFalse);
  }, variant: soloIos);

  testWidgets('su iPhone "Consulta" apre la chat e il Maestro apre il dominio',
      (tester) async {
    await monta(tester);
    await tester.tap(find.byKey(const Key('santuario_consulta')));
    await aspetta(tester);
    expect(find.byType(MaestroChatScreen), findsOneWidget);
  }, variant: soloIos);

  testWidgets(
      'su iPhone il dominio mostra le sezioni a schede, senza In arrivo',
      (tester) async {
    await monta(tester);
    await tester.tap(find.byKey(const Key('santuario_central_bust')));
    await aspetta(tester);
    expect(find.byType(DomainScreen), findsOneWidget);
    final righe = tester
        .widgetList<LaRigaDelleSchede>(
            find.byType(LaRigaDelleSchede, skipOffstage: false))
        .where((r) => r.chiave.startsWith('dominio_'))
        .map((r) => r.titolo)
        .toList();
    // ignore: avoid_print
    print('SU IPHONE: righe del dominio $righe');
    // LAPIDE, ordine ER voce 10: l'ultima riga era "In arrivo". Adesso ogni
    // arte sta nella sezione del suo Maestro, la riga "In arrivo" e' vuota e
    // non si mostra.
    expect(righe, isNot(contains('In arrivo')));
    expect(righe.length, greaterThanOrEqualTo(3));
    expect(Maestro.values, isNotEmpty);
  }, variant: soloIos);
}
