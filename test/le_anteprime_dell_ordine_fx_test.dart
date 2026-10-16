// LE ANTEPRIME DELL'ORDINE FX, "Il Respiro della Luna".
//
// A 360 per 797 punti logici, rapporto di pixel 3 (la stessa misura delle
// altre anteprime dell'ordine, docs/collaudo convenzione di casa), nella
// stessa ora di prova delle altre prove della voce (16 ottobre 2026, ore 9
// e mezzogiorno locali). Le immagini vanno in docs/preview/FX/ solo con
// AGGIORNA_ANTEPRIME=1; senza, la prova monta e basta, per restare nella
// suite normale senza scrivere file.

import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/lunario/il_dial_a_moon.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/respiro_della_luna/il_respiro_della_luna_screen.dart';
import 'package:esoteric_circle/features/respiro_della_luna/la_collana_delle_lune_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const bool _scrivi = bool.fromEnvironment('AGGIORNA_ANTEPRIME');

IlDialAMoon _dialAMoonOffline() =>
    IlDialAMoon(client: MockClient((request) async => http.Response('', 503)));

Widget _host(Widget scena) => MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => MaestroController())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MaestroScope(child: scena),
      ),
    );

Future<void> _monta(WidgetTester tester, GlobalKey radice, Widget widget) async {
  tester.view.physicalSize = const Size(1080, 2391);
  tester.view.devicePixelRatio = 3.0;
  await tester.pumpWidget(RepaintBoundary(key: radice, child: widget));
}

/// **LE IMMAGINI VOGLIONO IL LORO TEMPO VERO PER DECODIFICARSI.** Senza
/// `precacheImage` la cattura arriva prima che `Image.asset`/`Image` abbiano
/// finito di decodificare, e lo scatto mostra un riquadro vuoto al posto
/// della foto: il difetto vero trovato guardando la prima cattura di questo
/// stesso file (`docs/preview/FX/fx0234_respiro_scena_ferma.png`, la scena
/// e la Luna completamente nere). Stesso rimedio di
/// `test/le_anteprime_del_lunario_test.dart`.
Future<void> _precaricaImmagini(WidgetTester tester) async {
  await tester.runAsync(() async {
    for (final e in find.byType(Image).evaluate()) {
      try {
        await precacheImage((e.widget as Image).image, e);
      } catch (_) {
        // Un ripiego (AssetImage locale) che manca davvero nel binario di
        // prova non deve far fallire la cattura: l'errorBuilder della
        // schermata lo gestisce gia' a schermo.
      }
    }
  });
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(milliseconds: 100));
}

Future<void> _scatta(WidgetTester tester, GlobalKey radice, String nome) async {
  if (!_scrivi) return;
  await _precaricaImmagini(tester);
  // **toImage() VUOLE IL TEMPO VERO, non quello finto della prova.** Senza
  // `runAsync` la rasterizzazione resta in sospeso per sempre (il blocco
  // vero trovato qui: dieci minuti di timeout su entrambe le prove), come
  // fa gia' `le_anteprime_dell_ordine_fh_test.dart` per la stessa chiamata.
  await tester.runAsync(() async {
    final rb =
        radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final img = await rb.toImage(pixelRatio: 1.0);
    final dati = await img.toByteData(format: ui.ImageByteFormat.png);
    final dir = Directory('docs/preview/FX');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    File('${dir.path}/$nome.png').writeAsBytesSync(dati!.buffer.asUint8List());
    img.dispose();
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('FX.02-03-04: il Respiro della Luna, scena ferma col pannello',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final radice = GlobalKey();
    await _monta(
        tester,
        radice,
        _host(IlRespiroDellaLunaScreen(
            now: DateTime(2026, 10, 16, 12), dialAMoon: _dialAMoonOffline())));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 500));
    await _scatta(tester, radice, 'fx0234_respiro_scena_ferma');
  });

  testWidgets('FX.05: la Collana delle Lune, il ciclo in corso', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final radice = GlobalKey();
    await _monta(tester, radice,
        _host(LaCollanaDelleLuneScreen(now: DateTime(2026, 10, 16, 9))));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 500));
    await _scatta(tester, radice, 'fx05_collana_in_corso');
  });
}
