import 'dart:ui' as ui;

import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:esoteric_circle/design_system/components/cosmos_background.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/sigilli/disegno_del_sentiero.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// I TRE SENTIERI SI DISEGNANO DAVVERO, ordine P voce 33.
///
/// **Cosa misurano queste prove, e perche' due e non una.**
///
/// La prima e' DIFFERENZIALE A PIXEL contro il solo fondo cosmico: si monta il
/// disegno sopra il fondo, si cattura, si monta lo stesso fondo senza il
/// disegno, si cattura di nuovo, e la differenza in pixel dipinti deve
/// superare una soglia dichiarata. Prende il caso che l'ordine O non aveva
/// preso: una schermata dove non disegniamo niente e tutto quel che si vede
/// viene dal framework.
///
/// La seconda confronta i TRE DISEGNI FRA LORO **dopo aver neutralizzato la
/// palette**, cioe' montandoli tutti e tre sotto lo stesso Maestro. Se i tre
/// fossero lo stesso disegno ricolorato, a palette uguale diventerebbero
/// identici e la differenza crollerebbe a zero. E' la prova che i tre disegni
/// sono tre disegni.
///
/// **Le soglie sono dichiarate qui e non indovinate**: sono frazioni dei pixel
/// della tela, e la ragione di ciascuna sta accanto al numero.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

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

  /// La tela della cattura. Quadrata come il disegno nella schermata vera.
  const lato = 420.0;
  const pixelDellaTela = lato * lato;

  Widget attorno(Widget scena, {Maestro? forzando}) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
        ],
        child: MediaQuery(
          // RIDUCI MOVIMENTO ACCESO NELLE CATTURE: il fondo cosmico si ferma,
          // quindi le due catture confrontano lo stesso fondo e la differenza
          // e' tutta e sola nostra. E vale anche come promessa: il disegno c'e'
          // pure con Riduci Movimento, perche' Riduci Movimento non toglie mai
          // contenuto.
          data: const MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            // LA PALETTE SI NEUTRALIZZA DALLO SCOPE, non da un aggancio nel
            // codice di produzione: montare i tre sentieri sotto lo stesso
            // Maestro rende identico l'oro senza che il disegno sappia di
            // essere in prova.
            builder: (ctx, child) =>
                MaestroScope(maestro: forzando, child: child!),
            home: Scaffold(body: scena),
          ),
        ),
      );

  Future<List<int>> cattura(WidgetTester tester, GlobalKey radice) async {
    late List<int> byte;
    await tester.runAsync(() async {
      final confine =
          radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final immagine = await confine.toImage();
      final dati = await immagine.toByteData(format: ui.ImageByteFormat.rawRgba);
      byte = dati!.buffer.asUint8List().toList(growable: false);
      immagine.dispose();
    });
    return byte;
  }

  int quantiDiversi(List<int> a, List<int> b) {
    var diversi = 0;
    for (var i = 0; i < a.length && i < b.length; i += 4) {
      if (a[i] != b[i] || a[i + 1] != b[i + 1] || a[i + 2] != b[i + 2]) {
        diversi++;
      }
    }
    return diversi;
  }

  Future<List<int>> scena(
    WidgetTester tester, {
    required Widget dentro,
    Maestro? forzando,
  }) async {
    silenzia();
    tester.view.physicalSize = const Size(lato, lato);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final radice = GlobalKey();
    await tester.pumpWidget(attorno(
      RepaintBoundary(
        key: radice,
        child: SizedBox(
          width: lato,
          height: lato,
          child: CosmosBackground(seed: 19, child: dentro),
        ),
      ),
      forzando: forzando,
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    return cattura(tester, radice);
  }

  /// Metà dei traguardi accesi: un disegno a meta' cammino ha sia acceso sia
  /// spento, che e' il caso che si vede davvero.
  Set<String> aMeta(Sentiero sentiero) {
    final tutti = Sentieri.di(sentiero);
    return {
      for (final t in tutti)
        if (t.posizione <= 25) t.id,
    };
  }

  // LA SOGLIA, dichiarata. Il disegno occupa la tela con cinquantacinque
  // punti, le loro linee e la struttura sempre visibile: sotto l'uno per cento
  // dei pixel della tela non si sta disegnando un sentiero, si sta mettendo
  // un'icona. Un per cento di 420 per 420 fa 1.764 pixel.
  const sogliaDelDisegno = pixelDellaTela * 0.01;

  for (final sentiero in Sentieri.tutti) {
    testWidgets(
        'prova a guardia, ${sentiero.name}: il disegno cambia la tela rispetto '
        'al solo fondo cosmico', (tester) async {
      final conDisegno = await scena(
        tester,
        dentro: DisegnoDelSentiero(
          sentiero: sentiero,
          accesi: aMeta(sentiero),
        ),
      );
      final soloFondo = await scena(tester, dentro: const SizedBox.expand());

      final dipinti = quantiDiversi(conDisegno, soloFondo);
      expect(dipinti, greaterThan(sogliaDelDisegno),
          reason: 'sul sentiero ${sentiero.name} fra la schermata e il solo '
              'fondo cosmico cambiano $dipinti pixel su ${pixelDellaTela.toInt()}, '
              'sotto la soglia di ${sogliaDelDisegno.toInt()}. Vuol dire che '
              'in questa schermata non disegniamo niente e tutto cio\' che si '
              'vede viene dal framework o dal fondo: e\' esattamente il difetto '
              'della voce 33');
    });
  }

  testWidgets(
      'i tre disegni restano diversi anche a palette neutralizzata',
      (tester) async {
    // TUTTI E TRE SOTTO LO STESSO MAESTRO: cosi' l'oro e' lo stesso e la
    // differenza che resta e' geometria, non colore.
    final catture = <Sentiero, List<int>>{};
    for (final sentiero in Sentieri.tutti) {
      catture[sentiero] = await scena(
        tester,
        forzando: Maestro.medora,
        dentro: DisegnoDelSentiero(
          sentiero: sentiero,
          accesi: aMeta(sentiero),
        ),
      );
    }

    // Due disegni diversi devono differire almeno quanto un disegno differisce
    // dal fondo vuoto: se differissero meno, sarebbero lo stesso disegno con
    // uno scarto di dettaglio.
    const sogliaFraDue = pixelDellaTela * 0.01;
    final coppie = [
      (Sentiero.costellazione, Sentiero.albero),
      (Sentiero.costellazione, Sentiero.loto),
      (Sentiero.albero, Sentiero.loto),
    ];
    for (final (uno, altro) in coppie) {
      final diversi = quantiDiversi(catture[uno]!, catture[altro]!);
      expect(diversi, greaterThan(sogliaFraDue),
          reason: 'con la stessa palette, ${uno.name} e ${altro.name} '
              'differiscono per soli $diversi pixel su ${pixelDellaTela.toInt()}: '
              'non sono due disegni, sono lo stesso disegno ricolorato, che e\' '
              'proprio cio\' che i tre sentieri facevano prima della voce 33');
    }
  });

  for (final sentiero in Sentieri.tutti) {
    testWidgets('il disegno di ${sentiero.name} non esce dalla tela',
        (tester) async {
      // **UNA GUARDIA NATA DALL'ANTEPRIMA.** Il primo Loto aveva i petali
      // delle corone esterne che uscivano dal riquadro e venivano tagliati di
      // netto dal bordo: nessuna prova lo vedeva, perche' tutte guardavano
      // quanto si dipinge e non DOVE. Qui si guarda la cornice: se il disegno
      // tocca l'ultimo anello di pixel, sta uscendo.
      final conDisegno = await scena(
        tester,
        dentro: DisegnoDelSentiero(
          sentiero: sentiero,
          accesi: aMeta(sentiero),
        ),
      );
      final soloFondo = await scena(tester, dentro: const SizedBox.expand());

      // **SI GUARDANO TRE LATI SU QUATTRO, e si cambia la grandezza misurata,
      // non la soglia.** Il tronco dell'Albero e lo stelo del Loto ESCONO dal
      // bordo basso di proposito: la radice sta fuori campo, com'e' giusto che
      // sia. Il taglio che non deve esistere e' quello ai fianchi e in cima,
      // dove un petalo o una stella troncati si leggono come un errore.
      const spessore = 3;
      final lar = lato.toInt();
      var sulBordo = 0;
      for (var y = 0; y < lar; y++) {
        for (var x = 0; x < lar; x++) {
          final suiTreLati =
              x < spessore || y < spessore || x >= lar - spessore;
          if (!suiTreLati) continue;
          final i = (y * lar + x) * 4;
          if (i + 2 >= conDisegno.length) continue;
          if (conDisegno[i] != soloFondo[i] ||
              conDisegno[i + 1] != soloFondo[i + 1] ||
              conDisegno[i + 2] != soloFondo[i + 2]) {
            sulBordo++;
          }
        }
      }
      expect(sulBordo, 0,
          reason: 'il disegno di ${sentiero.name} dipinge $sulBordo pixel '
              'sui fianchi o in cima alla tela: sta uscendo dal riquadro e '
              'viene tagliato di netto, come i petali del primo Loto');
    });
  }

  test('la geometria copre tutti e 55 i traguardi di ogni sentiero, una volta '
      'sola', () {
    for (final sentiero in Sentieri.tutti) {
      final punti = GeometriaDelSentiero.punti(sentiero);
      final identificativi = punti.map((p) => p.traguardo.id).toSet();
      expect(punti, hasLength(55),
          reason: 'il disegno di ${sentiero.name} ha ${punti.length} punti '
              'invece di 55: un traguardo senza punto e\' un traguardo che nel '
              'disegno non esiste');
      expect(identificativi, hasLength(55),
          reason: 'due punti di ${sentiero.name} portano lo stesso traguardo');
      expect(identificativi,
          equals(Sentieri.di(sentiero).map((t) => t.id).toSet()),
          reason: 'il disegno di ${sentiero.name} non copre gli stessi '
              'traguardi del sentiero');
      expect(punti.where((p) => p.eGrande), hasLength(5),
          reason: 'i grandi disegnati su ${sentiero.name} non sono cinque');
      // E ogni punto deve stare dentro la tela, altrimenti un traguardo
      // esisterebbe nel dato e non si vedrebbe.
      for (final punto in punti) {
        expect(punto.dove.dx, inInclusiveRange(0.02, 0.98),
            reason: '${punto.traguardo.id} esce dalla tela in orizzontale');
        expect(punto.dove.dy, inInclusiveRange(0.02, 0.98),
            reason: '${punto.traguardo.id} esce dalla tela in verticale');
      }
    }
  });
}
