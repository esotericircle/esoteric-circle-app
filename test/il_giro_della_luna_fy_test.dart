import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/lunario/il_dial_a_moon.dart';
import 'package:esoteric_circle/core/lunario/il_respiro_della_luna.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/lunario/calendario_lunare_screen.dart';
import 'package:esoteric_circle/features/respiro_della_luna/il_respiro_della_luna_screen.dart';
import 'package:esoteric_circle/features/respiro_della_luna/la_collana_delle_lune_screen.dart';
import 'package:esoteric_circle/features/scene/la_scena_in_video.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **IL GIRO DELLA LUNA, COME UNA PERSONA.** Ordine FY voci FY.21 e FY.07,
/// 16 ottobre 2026. Il fondatore: "Code deve fare simulazione per ogni
/// funzionalità qui sopra"; e "Nessun collegamento al calendario lunare".
///
/// Un giro intero nel Respiro della Luna, coi margini di un telefono vero:
/// l'apertura col video in corso, la scena ferma coi dati, lo scorrimento
/// con la Luna fissa in cima, la riga "Trova il giorno giusto nel mese" che
/// apre il Calendario Lunare, il ritorno, la voce Respiro col rito fino alla
/// perla accesa, la Collana. Con `--dart-define=GIRO=true` ogni passo lascia la
/// sua cattura in `docs/collaudo/FY/giro_della_luna/`.
const bool _scrivi = bool.fromEnvironment('GIRO');

class _VideoCheGira implements LettoreDiScena {
  VoidCallback? _ascolta;
  bool _pronto = false;
  bool _finito = false;
  void finisci() {
    _finito = true;
    _ascolta?.call();
  }

  @override
  bool get pronto => _pronto;
  @override
  bool get fallito => false;
  @override
  bool get cominciato => _pronto;
  @override
  bool get finito => _finito;
  @override
  void ascolta(VoidCallback? q) => _ascolta = q;
  @override
  Future<void> apri() async {
    _pronto = true;
    _ascolta?.call();
  }

  @override
  Future<void> volume(double q) async {}
  @override
  Future<void> avvia() async {}
  @override
  Future<void> sospendi() async {}
  @override
  Widget disegna() => Image.asset(
      'assets/img/respiro_della_luna/respiro_primo_fotogramma_v1.webp',
      fit: BoxFit.cover);
  @override
  void chiudi() {}
}

void main() {
  final adesso = DateTime(2026, 10, 16, 21);
  final radice = GlobalKey();
  var passo = 0;

  Future<void> scatta(WidgetTester tester, String nome) async {
    passo++;
    if (!_scrivi) return;
    await tester.runAsync(() async {
      for (final e in find.byType(Image).evaluate()) {
        try {
          await precacheImage((e.widget as Image).image, e);
        } catch (_) {
          // Un'immagine che manca davvero la gestisce gia' l'errorBuilder.
        }
      }
    });
    await tester.pump(const Duration(milliseconds: 100));
    await tester.runAsync(() async {
      final rb =
          radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final img = await rb.toImage(pixelRatio: 1.0);
      final dati = await img.toByteData(format: ui.ImageByteFormat.png);
      final dir = Directory('docs/collaudo/FY/giro_della_luna');
      if (!dir.existsSync()) dir.createSync(recursive: true);
      File('${dir.path}/${passo.toString().padLeft(2, '0')}_$nome.png')
          .writeAsBytesSync(dati!.buffer.asUint8List());
      img.dispose();
    });
  }

  testWidgets('il giro intero del Respiro della Luna', (tester) async {
    SharedPreferences.setMockInitialValues({'respiro.primaAperturaVista': true});
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    tester.view.padding = const FakeViewPadding(top: 75 * 3, bottom: 48 * 3);
    addTearDown(tester.view.reset);
    late _VideoCheGira video;
    await tester.pumpWidget(RepaintBoundary(
      key: radice,
      child: MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => MaestroController())],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: MaestroScope(
            child: IlRespiroDellaLunaScreen(
              now: adesso,
              dialAMoon: IlDialAMoon(
                  client: MockClient((_) async => http.Response('', 503))),
              fabbricaDellaScena: () => video = _VideoCheGira(),
            ),
          ),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // 1. L'apertura: il video gira, sopra non c'e' niente.
    expect(find.byKey(const Key('luna_barra_in_basso')), findsNothing);
    await scatta(tester, 'apertura_video_in_corso');

    // 2. Il video finisce: la Luna, i dati, la barra.
    video.finisci();
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byKey(const Key('respiro_luna_vera')), findsOneWidget);
    expect(find.byKey(const Key('luna_barra_in_basso')), findsOneWidget);
    await scatta(tester, 'scena_ferma_coi_dati');

    // 3. Si scorre: la scena esce, la Luna resta fissa in cima.
    await tester.drag(
        find.byKey(const Key('respiro_tutto_scorre')), const Offset(0, -500));
    await tester.pump(const Duration(milliseconds: 400));
    await scatta(tester, 'scorre_e_la_luna_resta');

    // 4. La riga del Calendario, in fondo ai dati, apre il Calendario.
    await tester.scrollUntilVisible(
        find.byKey(const Key('respiro_vai_al_calendario')), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.pump(const Duration(milliseconds: 300));
    await scatta(tester, 'la_riga_del_calendario');
    await tester.tap(find.byKey(const Key('respiro_vai_al_calendario')));
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byType(CalendarioLunareScreen), findsOneWidget,
        reason: 'la riga del Calendario non apre il Calendario Lunare');
    expect(tester.takeException(), isNull,
        reason: 'il Calendario si apre su un\'eccezione');
    await scatta(tester, 'il_calendario_lunare');

    // 5. Il ritorno, e la voce Respiro: Medora torna, il rito si fa.
    Navigator.of(tester.element(find.byType(CalendarioLunareScreen))).pop();
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.tap(find.byKey(const Key('luna_voce_respiro')));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await scatta(tester, 'il_rito_davanti_a_medora');

    final tempi = TempiDelRespiroDellaLuna.diOggi(adesso);
    for (var i = 0; i < tempi.cicliPerUnMinuto; i++) {
      final dito = await tester.startGesture(
          tester.getCenter(find.byKey(const Key('respiro_la_luna_si_tocca'))));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(tempi.inspiro + const Duration(milliseconds: 100));
      if (i == 0) await scatta(tester, 'inspira');
      await dito.up();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(tempi.espiro + const Duration(milliseconds: 100));
    }
    await tester.pump(const Duration(milliseconds: 300));
    expect(
        tester
            .widget<Text>(find.byKey(const Key('respiro_gesto_del_momento')))
            .data,
        'Respiro compiuto');
    await scatta(tester, 'respiro_compiuto');

    // 6. La Collana, con la perla di oggi accesa.
    await tester.scrollUntilVisible(
        find.byKey(const Key('respiro_vai_alla_collana')), 200,
        scrollable: find.byType(Scrollable).first);
    // Ancora un poco, come una persona: il pulsante sale sopra la barra in
    // basso, che gli sta davanti appena entra nella vista.
    await tester.drag(
        find.byKey(const Key('respiro_tutto_scorre')), const Offset(0, -300));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.byKey(const Key('respiro_vai_alla_collana')));
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byType(LaCollanaDelleLuneScreen), findsOneWidget);
    expect(find.text('1 di 30'), findsOneWidget,
        reason: 'la perla di oggi non risulta accesa nella Collana');
    await scatta(tester, 'la_collana_con_la_perla_di_oggi');
  });
}
