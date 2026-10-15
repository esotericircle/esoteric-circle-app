// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/settings/settings_controller.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/angels/oracolo/oracolo_degli_angeli_screen.dart';
import 'package:esoteric_circle/features/scene/la_scena_in_video.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **LE ANTEPRIME DELL'ORACOLO DEGLI ANGELI**, ordine FU voci FU.02, FU.03,
/// FU.04, FU.06, FU.07 e FU.08: la schermata a 360 per 797 punti logici col
/// rapporto di pixel 3, in `docs/preview/FU/`, con `--dart-define=STATO=dopo`.
/// Non c'e' un "prima": l'arte era una card Coming soon.
///
/// La scena e' quella ferma (il lettore finto non si apre): l'ultimo
/// fotogramma con i tre dorsi sull'altare. Il video vero e il giro delle
/// carte in movimento si guardano sul telefono. Il modello e' finto (R2):
/// il titolo e il riquadro sono scritti qui, il resto viene dal corpus vero.
const _stato = String.fromEnvironment('STATO');

class _Ferma implements LettoreDiScena {
  VoidCallback? _ascolta;
  bool _fallito = false;
  @override
  bool get pronto => false;
  @override
  bool get fallito => _fallito;
  @override
  bool get cominciato => false;
  @override
  bool get finito => false;
  @override
  void ascolta(VoidCallback? q) => _ascolta = q;
  @override
  Future<void> apri() async {
    _fallito = true;
    _ascolta?.call();
  }

  @override
  Future<void> volume(double q) async {}
  @override
  Future<void> avvia() async {}
  @override
  Future<void> sospendi() async {}
  @override
  Widget disegna() => const SizedBox.shrink();
  @override
  void chiudi() {}
}

void main() {
  final radice = GlobalKey();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> passa(WidgetTester tester, [int volte = 8]) async {
    for (var i = 0; i < volte; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  Future<void> immagini(WidgetTester tester) async {
    await tester.runAsync(() async {
      for (final e in find.byType(Image).evaluate()) {
        await precacheImage((e.widget as Image).image, e);
      }
    });
    await passa(tester, 3);
  }

  Future<void> scatta(WidgetTester tester, String nome) async {
    await immagini(tester);
    await tester.runAsync(() async {
      final rb =
          radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final img = await rb.toImage(pixelRatio: 3.0);
      final dati = await img.toByteData(format: ui.ImageByteFormat.png);
      final dir = Directory('docs/preview/FU');
      if (!dir.existsSync()) dir.createSync(recursive: true);
      File('${dir.path}/${nome}_$_stato.png')
          .writeAsBytesSync(dati!.buffer.asUint8List());
      print('FU ANTEPRIMA: ${dir.path}/${nome}_$_stato.png '
          '${img.width}x${img.height}');
      img.dispose();
    });
  }

  Future<void> monta(WidgetTester tester, {bool conOra = true}) async {
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2391);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(
            create: (_) => SettingsController(suonoEVibrazione: false)),
        ChangeNotifierProvider(
            create: (_) => EntitlementService(initial: Tier.tier1)),
      ],
      child: RepaintBoundary(
        key: radice,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark(),
          builder: (c, figlio) => MaestroScope(child: figlio!),
          home: OracoloDegliAngeliScreen(
            fabbricaDellaScena: _Ferma.new,
            caso: Random(7),
            adesso: () => DateTime(2026, 10, 15, 10, 5),
            identita: BirthIdentity(
                birthMoment: DateTime(1990, 5, 12, 14, 30),
                hasBirthTime: conOra),
            chiamata: (i, r, c) async => jsonEncode({
              'titolo': 'Gli angeli ti chiedono un passo lento',
              'riquadro': 'Senti dove il cuore si apre e lascia che sia lui '
                  'a scegliere il ritmo di oggi.',
            }),
          ),
        ),
      ),
    ));
    await passa(tester);
  }

  Future<void> affida(WidgetTester tester, String domanda) async {
    await tester.enterText(
        find.byKey(const Key('oracolo_campo_domanda')), domanda);
    await tester.pump();
    await tester.tap(find.byKey(const Key('oracolo_affida')));
    for (var i = 0; i < 50; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('FU: l\'Oracolo, la domanda e il responso', (tester) async {
    if (_stato.isEmpty) return;
    await monta(tester);
    await scatta(tester, 'fu_oracolo_1_domanda');
    await tester.tap(find.byKey(const Key('oracolo_tema_amore')));
    await passa(tester, 3);
    await scatta(tester, 'fu_oracolo_1b_proposte');
    await tester.tap(find.byKey(const Key('oracolo_tema_amore')));
    await passa(tester, 3);
    await tester
        .ensureVisible(find.byKey(const Key('oracolo_angelo_dell_ora')));
    await passa(tester, 3);
    await scatta(tester, 'fu_oracolo_2_angelo_dell_ora');
    await tester.drag(find.byType(ListView).first, const Offset(0, 5000));
    await passa(tester, 3);
    await affida(tester, 'Devo cambiare lavoro?');
    await tester.drag(find.byType(ListView).first, const Offset(0, 5000));
    await passa(tester, 3);
    await scatta(tester, 'fu_oracolo_3_carte_girate');
    await tester.ensureVisible(find.byKey(const Key('oracolo_responso')));
    await passa(tester, 3);
    await scatta(tester, 'fu_oracolo_4_responso');
    await tester.ensureVisible(find.byKey(const Key('oracolo_bolla_custode')));
    await tester.tap(find.byKey(const Key('oracolo_rito_custode')),
        warnIfMissed: false);
    await passa(tester, 4);
    await tester.ensureVisible(find.byKey(const Key('oracolo_bolla_custode')));
    await passa(tester, 3);
    await scatta(tester, 'fu_oracolo_5_bolla_e_rito');
  });

  testWidgets('FU: senza l\'ora la terza carta resta coperta', (tester) async {
    if (_stato.isEmpty) return;
    await monta(tester, conOra: false);
    await affida(tester, 'Sono sulla strada giusta?');
    await tester.ensureVisible(find.byKey(const Key('oracolo_aggiungi_l_ora')));
    await passa(tester, 3);
    await scatta(tester, 'fu_oracolo_6_carta_coperta');
  });

  testWidgets('FU: la domanda delicata riceve la cura', (tester) async {
    if (_stato.isEmpty) return;
    await monta(tester);
    await affida(tester, 'Non voglio più vivere');
    await scatta(tester, 'fu_oracolo_7_cura');
  });
}
