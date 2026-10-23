// ignore_for_file: avoid_print
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/cerchio/il_cerchio_sociale.dart';
import 'package:esoteric_circle/core/cerchio/le_icone_del_cerchio.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/cerchio/profilo_nel_cerchio_screen.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'cardinale_minimo.dart';
import 'porta_finta_del_cerchio_sociale.dart';

/// **LE CATTURE DELLA VETRINA SONO TRE SCHERMATE DIVERSE, ordine FA voce 03.**
///
/// Il fatto: nell'ordine EZ le catture della vetrina nominate per gli Arcani
/// e per gli archetipi erano la stessa schermata (misura dell'Architetto: lo
/// 0,26 per cento dei pixel diversi, differenza massima 29 su 765). Non era
/// un difetto dell'app, era la cattura: la vetrina era un elenco unico, e
/// trascinare oltre la fine non spostava niente. Con l'ordine FA la vetrina
/// mostra una famiglia alla volta.
///
/// La prova apre la vetrina vera, tocca ogni famiglia, rende la schermata e
/// confronta le tre a coppie con la misura differenziale dell'Architetto.
/// **La soglia, dichiarata**: un pixel e' diverso se la somma delle
/// differenze dei tre canali supera 32 su 765 (l'Architetto misurava 29 come
/// differenza massima fra due catture della stessa schermata); due schermate
/// sono la stessa se meno del 5 per cento dei pixel del rettangolo delle
/// icone e' diverso. La stessa schermata resa due volte ne ha 0 (lo misura
/// la prova stessa).
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silenzia() {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (call) async => null);
    for (final n in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      m.setMockStreamHandler(
          EventChannel(n), MockStreamHandler.inline(onListen: (a, e) {}));
    }
  }

  testWidgets(
      'FA.03: le tre famiglie della vetrina mostrano tre schermate '
      'diverse', (tester) async {
    silenzia();
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(360, 797);
    addTearDown(tester.view.reset);
    final finta = PortaFintaDelCerchioSociale();
    final sociale = IlCerchioSociale(porta: finta);
    await sociale.sincronizza(
        identita: BirthIdentity(birthMoment: DateTime(1990, 5, 12, 10)));
    final radice = GlobalKey();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<IlCerchioSociale>.value(value: sociale),
        Provider<AppServices>.value(value: AppServices.offline(null, finta)),
      ],
      child: RepaintBoundary(
        key: radice,
        child: MaterialApp(
          theme: AppTheme.dark(),
          builder: (c, figlio) => MediaQuery(
            data: MediaQuery.of(c).copyWith(disableAnimations: true),
            child: MaestroScope(neutro: true, child: figlio!),
          ),
          home: const ProfiloNelCerchioScreen(),
        ),
      ),
    ));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.runAsync(() async {
      for (final f in FamigliaDelleIcone.values) {
        for (final i in IconaDelProfilo.di(f)) {
          await precacheImage(AssetImage(i.asset), radice.currentContext!);
        }
      }
    });
    await tester.tap(find.byKey(const Key('profilo_icona')));
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    Future<(Uint8List, int)> rendi() async {
      late Uint8List pixel;
      late int largo;
      await tester.runAsync(() async {
        final rb =
            radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final img = await rb.toImage(pixelRatio: 1.0);
        largo = img.width;
        final dati = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
        pixel = dati!.buffer.asUint8List();
        img.dispose();
      });
      return (pixel, largo);
    }

    // Il rettangolo delle icone: la misura guarda le icone, non il fondo
    // vuoto sotto, che e' uguale in tutte e tre e annacquerebbe il conto.
    Rect? icone;
    double diversi((Uint8List, int) a, (Uint8List, int) b) {
      final (pa, largo) = a;
      final (pb, _) = b;
      final r = icone!;
      var tot = 0, diff = 0;
      for (var y = r.top.floor(); y < r.bottom.ceil(); y++) {
        for (var x = r.left.floor(); x < r.right.ceil(); x++) {
          final o = (y * largo + x) * 4;
          final d = (pa[o] - pb[o]).abs() +
              (pa[o + 1] - pb[o + 1]).abs() +
              (pa[o + 2] - pb[o + 2]).abs();
          tot++;
          if (d > 32) diff++;
        }
      }
      return 100 * diff / tot;
    }

    final catture = <String, (Uint8List, int)>{};
    for (final f in FamigliaDelleIcone.values) {
      await tester.tap(find.byKey(Key('vetrina_famiglia_${f.name}')));
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      final r = tester.getRect(find.byKey(Key('vetrina_icone_${f.name}')));
      icone = icone?.expandToInclude(r) ?? r;
      catture[f.name] = await rendi();
    }
    cardinaleMinimo(catture.length, 3,
        cosa: 'famiglie della vetrina',
        perche: 'Le famiglie sono tre: con una sola non ci sarebbero coppie.');
    // La stessa schermata resa due volte: l'ultima famiglia, ancora aperta.
    final stessa = diversi(catture.values.last, await rendi());
    final nomi = catture.keys.toList();
    final coppie = <String, double>{};
    for (var i = 0; i < nomi.length; i++) {
      for (var j = i + 1; j < nomi.length; j++) {
        coppie['${nomi[i]}/${nomi[j]}'] =
            diversi(catture[nomi[i]]!, catture[nomi[j]]!);
      }
    }
    print('FA.03 LE CATTURE DELLA VETRINA: pixel diversi per coppia '
        '${coppie.map((k, v) => MapEntry(k, v.toStringAsFixed(2)))}; la '
        'stessa schermata due volte ${stessa.toStringAsFixed(2)}');
    final uguali = [
      for (final e in coppie.entries)
        if (e.value < 5) e.key
    ];
    expect(uguali, isEmpty,
        reason: 'queste famiglie mostrano la stessa schermata: $uguali');
  });
}
