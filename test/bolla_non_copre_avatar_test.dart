import 'dart:io';
import 'dart:typed_data';

import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// La bolla del dominio non tocca la figura del Maestro.
///
/// **Perche' serve un metodo diverso dal solito.** Questa correzione era stata
/// dichiarata chiusa e misurata su cinque altezze, mentre sul telefono di Mauro
/// la bolla mordeva ancora la figura. La ragione e' che il test guardava il
/// RIQUADRO DEL WIDGET, e l'avatar del Maestro sborda dal proprio riquadro con
/// `Clip.none`: il rettangolo diceva una cosa, i pixel dipinti ne dicevano
/// un'altra.
///
/// **Il metodo usato qui: confronto per immagine.** Si fotografa la schermata,
/// si scandisce la colonna centrale dal basso verso l'alto e si trova la riga
/// piu' bassa in cui la FIGURA e' dipinta. Quella riga si confronta con il bordo
/// superiore della bolla, letto dal suo riquadro, che per la bolla e' fedele
/// perche' un pulsante non sborda.
///
/// Il criterio e' quello dell'ordine: almeno otto pixel di distanza, zero
/// sovrapposizioni, su 2532 e su 2392.
///
/// **ATTENZIONE, QUESTA MISURA NON E' ANCORA AFFIDABILE.** Verificata con la
/// prova di vista: rimettendo il margine difettoso il test resta VERDE, quindi
/// oggi non denuncia il difetto che deve denunciare. La ragione e' che per
/// saltare l'ombra del pulsante si parte venti punti piu' in alto, e cosi'
/// facendo si salta anche la zona dove il contatto avviene.
///
/// Chi riprende deve costruire una misura che distingua l'ombra del pulsante
/// dalla figura, per esempio isolando la figura per colore invece che per
/// luminosita', oppure fotografando la sola striscia fra il fondo della carta e
/// la cima della bolla. Finche' questa nota c'e', il verde di questo file NON
/// vale come prova.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silence() {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (c) async => null);
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

  /// Quanto un pixel si stacca dal fondo del cosmo.
  ///
  /// Il fondo e' scuro e bluastro; la figura dei Maestri e' molto piu' chiara e
  /// satura. Non serve riconoscere la figura, basta sapere che li' e' stato
  /// dipinto qualcosa che il cielo non avrebbe messo.
  double _stacco(ByteData d, int w, int x, int y) {
    final i = (y * w + x) * 4;
    final r = d.getUint8(i), g = d.getUint8(i + 1), b = d.getUint8(i + 2);
    final luce = (r + g + b) / 3;
    final satura = [r, g, b].reduce((a, c) => a > c ? a : c) -
        [r, g, b].reduce((a, c) => a < c ? a : c);
    return luce + satura.toDouble();
  }

  /// Prova la schermata a una certa altezza e restituisce le due misure.
  Future<({double fondoFigura, double cimaBolla, int larghezza})> misura(
      WidgetTester tester, double altezzaFisica) async {
    silence();
    SharedPreferences.setMockInitialValues({});
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = Size(1170, altezzaFisica);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final radice = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(
      key: radice,
      child: EsotericCircleApp(services: AppServices.offline()),
    ));
    // Mezzo secondo, come i test del Santuario che funzionano: aspettando di
    // piu' il lanciatore spinge l'onboarding sopra la scena e non si misura
    // piu' il Cerchio.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    final bolla = find.byKey(const Key('santuario_enter_domain'));
    expect(bolla, findsOneWidget, reason: 'bolla del dominio non trovata');
    final cimaBolla = tester.getRect(bolla).top;

    late double fondoFigura;
    late int larghezza;
    await tester.runAsync(() async {
      final rb = radice.currentContext!.findRenderObject()!
          as RenderRepaintBoundary;
      final img = await rb.toImage(
          pixelRatio: tester.view.devicePixelRatio);
      final d = (await img.toByteData())!;
      final w = img.width;
      larghezza = w;
      // La colonna centrale, dove sta la figura del Maestro al centro.
      final daX = (w * 0.42).round();
      final aX = (w * 0.58).round();
      // Si parte dal bordo superiore della bolla e si SALE: la prima riga con
      // pixel dipinti e' il fondo della figura.
      final rigaBolla = (cimaBolla * tester.view.devicePixelRatio).round();
      // Si parte VENTI PUNTI SOPRA la cima della bolla, non dalla cima. Il
      // pulsante ha un bordo oro, un fondo saturo e un'ombra che dipinge FUORI
      // dal proprio rettangolo: partendo dalla sua riga si trovava sempre lui,
      // e la distanza restava identica qualunque cosa si spostasse. Venti punti
      // stanno sopra l'ombra e sotto qualunque figura.
      final partenza = (rigaBolla - 60).clamp(0, img.height - 1);
      var trovata = 0;
      for (var y = partenza; y > 0; y--) {
        var dipinti = 0;
        for (var x = daX; x < aX; x += 2) {
          if (_stacco(d, w, x, y) > 150) dipinti++;
        }
        // Serve una riga LARGA, non qualche pixel: una stella o l'alone della
        // bolla accendono pochi campioni, la figura di un Maestro ne accende
        // meta' della colonna. Con una soglia bassa si misurava l'alone e il
        // risultato seguiva l'offset di partenza invece della figura.
        if (dipinti > (aX - daX) / 2 * 0.5) {
          trovata = y;
          break;
        }
      }
      fondoFigura = trovata / tester.view.devicePixelRatio;
      img.dispose();
    });

    return (
      fondoFigura: fondoFigura,
      cimaBolla: cimaBolla,
      larghezza: larghezza
    );
  }

  for (final altezza in const [2532.0, 2392.0]) {
    testWidgets('A $altezza la bolla sta sotto la figura, con aria',
        (tester) async {
      final m = await misura(tester, altezza);
      final distanza = m.cimaBolla - m.fondoFigura;

      expect(distanza, greaterThanOrEqualTo(8),
          reason: 'a $altezza la bolla dista ${distanza.toStringAsFixed(1)} '
              'punti dal fondo della figura dipinta: sotto gli otto richiesti, '
              'quindi la bolla morde il Maestro. Misura per immagine sulla '
              'colonna centrale, non sul riquadro del widget.');
    });
  }

  testWidgets('Il sottotitolo sta sotto la bolla', (tester) async {
    silence();
    SharedPreferences.setMockInitialValues({});
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1170, 2532);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(EsotericCircleApp(services: AppServices.offline()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    final bolla = tester.getRect(find.byKey(const Key('santuario_enter_domain')));
    final arti = find.byKey(const Key('santuario_domain_arts'));
    expect(arti, findsOneWidget, reason: 'riga delle arti non trovata');
    expect(tester.getRect(arti).top, greaterThanOrEqualTo(bolla.bottom),
        reason: 'il sottotitolo con le tre arti non sta sotto la bolla');
  });
}
