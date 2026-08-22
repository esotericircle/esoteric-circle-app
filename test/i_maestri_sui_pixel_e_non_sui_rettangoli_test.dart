import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:esoteric_circle/features/santuario/santuario_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'monta_la_home.dart';

/// I MAESTRI, MISURATI SUI PIXEL E NON SUI RETTANGOLI.
/// Ordine BA voce 02, e chiude la voce 02 dell'ordine AX.
///
/// **Il fatto del fondatore, alla quarta segnalazione**: "nella home i 3
/// maestri sono troppo in alto coprendo il messaggio che sta subito sopra".
///
/// **Le tre volte precedenti la misura diceva ZERO mentre a schermo il testo
/// si leggeva a meta'**, e la ragione e' scritta nell'ordine AX: le figure
/// escono dal proprio riquadro con `Clip.none`, quindi **confrontare
/// rettangoli di layout non vedra' mai il problema**. Restringere il carosello
/// non sposta di un pixel cio' che si vede.
///
/// **Come si misura qui, ed e' il metodo che l'ordine impone.** Si dipinge la
/// home in un'immagine, si ridipinge la stessa home **senza il carosello**, e
/// si contano i pixel che nelle due immagini differiscono **dentro la fascia
/// del testo**. Un pixel che cambia togliendo i Maestri e' un pixel che i
/// Maestri stavano coprendo: non c'e' modo di discutere il numero.
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

  /// Le tre misure di schermo dell'ordine AV, con i loro rapporti VERI.
  const schermi = <String, (Size, double)>{
    'alto, 360x797': (Size(1080, 2391), 3.0),
    'medio, 375x667': (Size(750, 1334), 2.0),
    'basso, 320x568': (Size(640, 1136), 2.0),
  };

  /// Dipinge la scena montata e torna i pixel grezzi.
  ///
  /// **Dentro `runAsync`, e senza non finisce mai.** `toImage` ha bisogno del
  /// ciclo degli eventi vero: nel tempo finto delle prove il futuro non si
  /// chiude, e la prova muore con "did not complete" invece di dire un
  /// numero. E' lo stesso inciampo gia' incontrato nell'ordine AV voce 01.
  Future<ByteData> dipingi(WidgetTester tester) async {
    late ByteData dati;
    await tester.runAsync(() async {
      final ro = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(const Key('la_home_intera')));
      final immagine = await ro.toImage(pixelRatio: 1.0);
      dati = (await immagine.toByteData(format: ui.ImageByteFormat.rawRgba))!;
      immagine.dispose();
    });
    return dati;
  }

  for (final voce in schermi.entries) {
    testWidgets('su schermo ${voce.key} i Maestri coprono zero pixel di testo',
        (tester) async {
      silenzia();
      maestriSpentiPerLaProva = false;
      addTearDown(() => maestriSpentiPerLaProva = false);

      // **PRIMA CON I MAESTRI**, cioe' la home come la vede il fondatore.
      await montaLaHomePerLaMisura(tester, voce.value);
      final fascia = fasciaDelTesto(tester);
      final con = await dipingi(tester);

      // **POI SENZA**, e nient'altro cambia: stessa scena, stesso istante
      // finto, stessa misura di schermo.
      maestriSpentiPerLaProva = true;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      final senza = await dipingi(tester);

      // **SI CONTANO SOLO I PIXEL DENTRO LA FASCIA DEL TESTO.** Fuori di li'
      // i Maestri devono cambiare i pixel: sono loro, e coprono il cielo, che
      // e' il loro posto.
      final larghezza = tester.view.physicalSize.width ~/
          tester.view.devicePixelRatio;
      var diversi = 0;
      for (var y = fascia.top.floor(); y < fascia.bottom.ceil(); y++) {
        for (var x = fascia.left.floor(); x < fascia.right.ceil(); x++) {
          final i = (y * larghezza + x) * 4;
          if (i < 0 || i + 3 >= con.lengthInBytes) continue;
          if (con.getUint32(i) != senza.getUint32(i)) diversi++;
        }
      }
      // ignore: avoid_print
      print('ORDINE BA VOCE 02: su schermo ${voce.key}, la fascia del testo '
          'va da ${fascia.top.round()} a ${fascia.bottom.round()}, e i pixel '
          'che cambiano togliendo i Maestri sono $diversi');

      expect(diversi, 0,
          reason: 'i Maestri coprono $diversi pixel del testo che sta sopra '
              'di loro. E la quarta segnalazione del fondatore, e le tre volte '
              'precedenti la misura diceva zero perche guardava i rettangoli '
              'invece dei pixel dipinti');
    });
  }
}
