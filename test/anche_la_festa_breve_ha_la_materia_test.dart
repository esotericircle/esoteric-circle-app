import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/sigilli/celebrazione.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'istante_dichiarato.dart';

/// ANCHE LA FESTA BREVE HA LA MATERIA DEL SUO MAESTRO. Ordine AS voce 02.
///
/// **Il fatto di Mauro**: "nella maggior parte dei casi vedo la celebrazione
/// vecchia, senza stelle, rune o petali".
///
/// **L'ENUMERAZIONE, che e' cio' che l'ordine chiedeva.** Le strade che portano
/// a una celebrazione sono DUE, e le sceglie una riga sola dentro
/// `Celebrazione.festeggiaInsieme`: un traguardo GRANDE, oppure il primo Sigillo
/// in assoluto, apre la scena a schermo pieno; tutti gli altri aprono la fascia.
/// I grandi sono quindici su centosessantacinque, quindi **la fascia e' il caso
/// normale**, cioe' la festa che una persona vede quasi sempre. E la fascia
/// mostrava il solo glifo del Maestro: nessuna particella, nessuna materia.
/// "La maggior parte dei casi" era, alla lettera, il novanta per cento.
///
/// **Come si misura, e perche' non basta cercare il widget.** Un CustomPaint
/// nell'albero non prova che qualcosa si veda: la prova monta la fascia vera,
/// la fotografa a due istanti e conta i pixel che cambiano nella fascia ALTA
/// dello schermo, dove non c'e' testo. Se fra due istanti non cambia niente,
/// non vola niente.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silenziaISensori() {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
      (call) async => null,
    );
    for (final nome in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      m.setMockStreamHandler(
        EventChannel(nome),
        MockStreamHandler.inline(onListen: (args, events) {}),
      );
    }
  }

  Future<Uint8List> pixel(WidgetTester tester, GlobalKey chiave) async {
    late Uint8List byte;
    await tester.runAsync(() async {
      final confine =
          chiave.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final immagine = await confine.toImage();
      final dati = await immagine.toByteData(format: ui.ImageByteFormat.rawRgba);
      byte = dati!.buffer.asUint8List();
      immagine.dispose();
    });
    return byte;
  }

  /// Quanti pixel su mille cambiano nella FASCIA ALTA, dove la scena non
  /// scrive niente: li' cio' che cambia sono solo le particelle.
  int cambiatiInAlto(Uint8List a, Uint8List b, int larghezza, int altezza) {
    final finoA = (altezza * 0.28).round() * larghezza;
    var diversi = 0, guardati = 0;
    for (var p = 0; p < finoA; p++) {
      final i = p * 4;
      if (i + 2 >= a.length || i + 2 >= b.length) break;
      guardati++;
      if (a[i] != b[i] || a[i + 1] != b[i + 1] || a[i + 2] != b[i + 2]) {
        diversi++;
      }
    }
    return guardati == 0 ? 0 : (diversi * 1000 / guardati).round();
  }

  for (final sentiero in Sentiero.values) {
    testWidgets('nella festa breve di ${sentiero.name} vola la sua materia',
        (tester) async {
      silenziaISensori();
      SharedPreferences.setMockInitialValues(const {});
      tester.view.physicalSize = const Size(1080, 2391);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);
      final diario = DiarioDelCammino(orologio: orologioDelleProve);
      await diario.carica();
      final chiave = GlobalKey();
      // **UN MINI, cioe' il caso normale.** Un grande aprirebbe la scena a
      // schermo pieno, che le particelle le ha sempre avute: misurarla non
      // direbbe niente sul difetto.
      final mini = Sentieri.di(sentiero).firstWhere((t) => !t.eGrande);
      expect(mini.eGrande, isFalse);

      late BuildContext dove;
      // **LA SCATOLA DA FOTOGRAFARE STA ATTORNO A TUTTA L'APP, e non attorno
      // alla home.** La fascia entra nell'Overlay del Navigator, che vive
      // SOPRA `home`: fotografando la home si fotografava la scena senza la
      // festa, e la misura diceva zero pixel cambiati per il motivo
      // sbagliato.
      await tester.pumpWidget(
        RepaintBoundary(
          key: chiave,
          child: MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => MaestroController()),
              ChangeNotifierProvider(create: (_) => QualityTierController()),
              ChangeNotifierProvider(create: (_) => ParallaxController()),
              ChangeNotifierProvider<DiarioDelCammino>.value(value: diario),
            ],
            child: MaterialApp(
              builder: (ctx, child) => MaestroScope(child: child!),
              home: Builder(builder: (ctx) {
                dove = ctx;
                return const Scaffold(body: SizedBox.expand());
              }),
            ),
          ),
        ),
      );
      final comparsa = mostraLaSovrimpressione(dove,
          traguardi: [mini], sentieri: [sentiero]);
      expect(comparsa, isTrue,
          reason: 'la festa breve non e comparsa: non c e niente da misurare');
      // **SI ASPETTA CHE IL VELO SIA FERMO, e il primo tentativo era verde per
      // il motivo sbagliato.** Il velo entra in 420 millesimi: misurando a 260
      // e 500 cambiavano 998 pixel su mille, ma erano lo sfondo che si stava
      // ancora scurendo, non le particelle. Da 500 in poi il velo e' a regime,
      // e cio' che cambia in alto e' solo la materia che vola.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 520));
      final primo = await pixel(tester, chiave);
      await tester.pump(const Duration(milliseconds: 220));
      final secondo = await pixel(tester, chiave);
      final cambio = cambiatiInAlto(primo, secondo, 1080, 2391);
      // ignore: avoid_print
      print('ORDINE AS VOCE 02: festa breve di ${sentiero.name}, pixel '
          'cambiati in alto $cambio su mille');
      // **LA SOGLIA E TARATA SUI DUE STATI, non scelta a occhio.** Col pittore
      // vivo si misurano 28, 11 e 24 pixel su mille per i tre sentieri; col
      // pittore congelato, cioe la prova del rosso, si scende a 4, 3 e 5, che
      // sono il glifo che pulsa e il bagliore attorno. Otto sta in mezzo e
      // separa i due casi anche per l albero, che ha le quaranta rune ed e il
      // piu magro dei tre.
      expect(cambio, greaterThan(8),
          reason: 'fra due istanti della festa breve di ${sentiero.name} '
              'cambiano $cambio pixel su mille nella fascia alta: non vola '
              'niente, ed e la celebrazione vecchia che Mauro vede nella '
              'maggior parte dei casi');
      // La fascia si ritira da sola: si lascia finire, se no l'albero muore
      // con un timer vivo dentro.
      await tester.pump(const Duration(seconds: 7));
    });
  }
}
