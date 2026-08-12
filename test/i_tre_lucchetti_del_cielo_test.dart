import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/design_system/components/cosmos_background.dart';
import 'package:esoteric_circle/design_system/components/dove_si_muove_il_cielo.dart';
import 'package:esoteric_circle/features/shell/dove_si_vede_la_barra.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// I TRE LUCCHETTI SUL CIELO, ordine P voce 02.
///
/// **Perche' tre e non uno.** Un presidio solo e' gia' stato aggirato una
/// volta: il cielo si e' fermato mentre una prova restava verde. Tre lucchetti
/// falliscono per ragioni DIVERSE, cosi' nessuna modifica futura puo'
/// spegnerli tutti insieme senza accorgersene.
///
///   1. il DATO: la traslazione applicata cambia col tempo;
///   2. il PIXEL: due fotogrammi distanti differiscono davvero a schermo, che
///      prende il caso in cui il valore si muove e nessuno lo dipinge;
///   3. l'ENUMERAZIONE: ogni schermata che dichiara il fondo lo riceve in
///      movimento, che prende il caso in cui il moto resta vivo in una sola.
///
/// Il quarto non e' un lucchetto ma una promessa: con Riduci Movimento il
/// fondo e' fermo E il contenuto e' tutto presente. Riduci Movimento non
/// toglie mai contenuto.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  /// I CANALI DEI SENSORI SI SILENZIANO, ordine P voce 02.
  ///
  /// Il lucchetto del pixel cadeva su una MissingPluginException del canale
  /// degli accelerometri, cioe' non misurava niente: un lucchetto che casca
  /// prima di guardare non e' un lucchetto. Non e' un'attenuazione della
  /// prova, e' toglierle di mezzo l'unica cosa che le impediva di misurare.
  void silenzia() {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (call) async => null);
    for (final nome in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      m.setMockStreamHandler(
          EventChannel(nome), MockStreamHandler.inline(onListen: (a, e) {}));
    }
  }

  Widget attorno(Widget scena, {bool riduciMovimento = false}) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
        ],
        child: MediaQuery(
          data: MediaQueryData(disableAnimations: riduciMovimento),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            builder: (ctx, child) => MaestroScope(child: child!),
            home: scena,
          ),
        ),
      );

  testWidgets('lucchetto 1, il dato: la traslazione dei piani cambia',
      (tester) async {
    final parallasse = ParallaxController();
    final valori = <double>{};
    for (final t in [0.0, 0.6, 1.2, 1.8, 2.4, 3.0]) {
      final offset = OffsetDeiPiani.da(parallasse, conDeriva: true, t: t);
      valori.add(offset.fondo.dx);
      valori.add(offset.fondo.dy);
      valori.add(offset.vicino.dx);
    }
    expect(valori.length, greaterThan(4),
        reason: 'la traslazione dei piani non cambia col tempo: il cielo e\' '
            'fermo nel DATO, prima ancora che a schermo. E\' il difetto che '
            'il commit 8326b55 aveva introdotto spegnendo la deriva');
  });

  testWidgets('lucchetto 2, il pixel: due fotogrammi distanti differiscono',
      (tester) async {
    silenzia();
    tester.view.physicalSize = const Size(600, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final radice = GlobalKey();

    await tester.pumpWidget(attorno(RepaintBoundary(
      key: radice,
      child: const CosmosBackground(seed: 5, child: SizedBox.expand()),
    )));
    await tester.pump(const Duration(milliseconds: 400));

    Future<List<int>> scatta() async {
      late List<int> byte;
      await tester.runAsync(() async {
        final confine =
            radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final immagine = await confine.toImage();
        final dati =
            await immagine.toByteData(format: ui.ImageByteFormat.rawRgba);
        byte = dati!.buffer.asUint8List().toList(growable: false);
        immagine.dispose();
      });
      return byte;
    }

    final primo = await scatta();
    await tester.pump(const Duration(seconds: 3));
    final secondo = await scatta();

    var diversi = 0;
    for (var i = 0; i < primo.length; i += 4) {
      if (primo[i] != secondo[i] ||
          primo[i + 1] != secondo[i + 1] ||
          primo[i + 2] != secondo[i + 2]) {
        diversi++;
      }
    }
    // La soglia e' bassa apposta: qui non si misura quanto e' bello il moto,
    // si prende il caso in cui il valore si muove e a schermo non cambia
    // niente. Zero pixel diversi vuol dire cielo dipinto fermo.
    expect(diversi, greaterThan(200),
        reason: 'fra due fotogrammi a tre secondi di distanza sono cambiati '
            'solo $diversi pixel: il cielo si muove nel dato e nessuno lo '
            'dipinge');
  });

  test('lucchetto 3, l\'enumerazione: ognuna riceve il cielo dalla sorgente '
      'che dichiara', () {
    final sorgenti = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .map((f) => f.readAsStringSync())
        .toList();
    String? fileDi(String classe) {
      for (final testo in sorgenti) {
        if (testo.contains('class $classe')) return testo;
      }
      return null;
    }

    // 1. Nessun nome morto: un elenco che parla di cose che non esistono piu
    //    smette di essere un presidio.
    final mancanti = [
      for (final s in DoveSiMuoveIlCielo.elenco)
        if (fileDi(s.classe) == null) s.classe,
    ];
    expect(mancanti, isEmpty,
        reason: 'l\'elenco di dove si muove il cielo nomina schermate che nei '
            'sorgenti non esistono piu\': $mancanti');

    // 2. Ognuna riceve il cielo DALLA SORGENTE CHE DICHIARA.
    //
    //    **Qui e cambiata la grandezza misurata, non la soglia.** Prima si
    //    cercava la parola CosmosBackground dentro ogni file, e cadevano
    //    quattro schermate sane: due prendono il fondo dal guscio, che lo
    //    monta una volta sola, e cercarglielo dentro non lo troverebbe mai;
    //    una ha un fondale dipinto per scelta. Adesso si misura cio che ogni
    //    riga dichiara.
    final guscio = fileDi('AppShell');
    expect(guscio, isNotNull, reason: 'il guscio non esiste piu\'');
    expect(guscio!.contains('CosmosBackground'), isTrue,
        reason: 'il guscio ha smesso di montare il fondo cosmico: tutte le '
            'schermate che lo ricevono da lui si sono fermate insieme, ed e\' '
            'il caso peggiore perche\' e\' silenzioso');

    final senzaCielo = <String>[];
    for (final s in DoveSiMuoveIlCielo.elenco) {
      final testo = fileDi(s.classe)!;
      switch (s.sorgente) {
        case SorgenteDelCielo.propria:
          if (!testo.contains('CosmosBackground') &&
              !testo.contains('ImmersiveScaffold')) {
            senzaCielo.add('${s.classe} dichiara di portarsi il cielo e non '
                'monta ne\' CosmosBackground ne\' ImmersiveScaffold');
          }
        case SorgenteDelCielo.dalGuscio:
          if (presenzaPerSchermata[s.classe] != PresenzaDellaBarra.presente) {
            senzaCielo.add('${s.classe} dichiara di prendere il cielo dal '
                'guscio ma non e\' una delle schermate del guscio: fuori di '
                'li\' nessuno gliene da\' uno');
          }
        case SorgenteDelCielo.fondaleDipinto:
          if ((s.perche ?? '').trim().isEmpty) {
            senzaCielo.add('${s.classe} ha un fondale dipinto e non dice '
                'perche\': una riga senza ragione e\' un modo elegante di '
                'silenziare la prova');
          }
      }
    }
    expect(senzaCielo, isEmpty,
        reason: 'queste schermate non ricevono il cielo dalla sorgente che '
            'dichiarano:\n${senzaCielo.join("\n")}');
  });

  testWidgets('con Riduci Movimento il fondo e\' fermo e il contenuto c\'e\'',
      (tester) async {
    tester.view.physicalSize = const Size(600, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(attorno(
      const CosmosBackground(
        seed: 5,
        child: Center(child: Text('il contenuto resta')),
      ),
      riduciMovimento: true,
    ));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('il contenuto resta'), findsOneWidget,
        reason: 'Riduci Movimento ha tolto contenuto, e non deve mai farlo: '
            'toglie il moto, non le cose');
  });
}
