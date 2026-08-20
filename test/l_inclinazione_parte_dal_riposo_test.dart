import 'dart:math' as math;

import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// L'INCLINAZIONE SI MISURA DAL RIPOSO. Ordine AS voce 01.
///
/// **Il difetto, e perche' nessuna prova lo vedeva.** Il tilt era la gravita'
/// stessa. Un telefono tenuto in mano per leggere porta quasi tutta la gravita'
/// sull'asse Y, quindi `tiltY` valeva 0,98 in permanenza: saturo, cioe' meta'
/// della parallasse gia' finita prima di cominciare. Sull'asse X la scala era
/// tarata su novanta gradi, e quindici gradi veri valevano 21 punti sugli 80.
/// Le prove dicevano 80 e 165 esatti perche' usavano `inclinaPerLaProva(1, 1)`,
/// che impone il tilt saturo: misuravano la formula dei piani, non il telefono.
///
/// **Cosa misura questa prova, e la differenza e' tutta qui.** Entra dalla
/// porta del sensore, `leggiDalSensorePerLaProva`, con una sequenza di letture:
/// prima una postura qualunque tenuta ferma, poi un'inclinazione di quindici
/// gradi. E' il gesto di una persona, non un numero imposto.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  // I canali del sensore non esistono in prova, e il costruttore del
  // controllore prova ad aprirli: senza questo silenziatore ogni prova cade
  // con MissingPluginException prima ancora di misurare qualcosa.
  setUp(() {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (call) async => null);
    m.setMockStreamHandler(
        const EventChannel('dev.fluttercommunity.plus/sensors/accelerometer'),
        MockStreamHandler.inline(onListen: (a, e) {}));
  });

  /// Una postura: quanto pesa la gravita' sui tre assi quando il telefono sta
  /// inclinato di [gradi] rispetto al piano, sull'asse [asse].
  ///
  /// Il telefono tenuto per leggere sta quasi verticale: la gravita' e' quasi
  /// tutta su Y. E' la postura da cui parte tutto.
  (double, double, double) postura({
    double inclinazioneY = 80,
    double inclinazioneX = 0,
  }) {
    final ry = inclinazioneY * math.pi / 180;
    final rx = inclinazioneX * math.pi / 180;
    return (-math.sin(rx) * 9.8, math.sin(ry) * 9.8, math.cos(ry) * 9.8);
  }

  void tieniFermo(ParallaxController p, (double, double, double) g,
      {int campioni = 200}) {
    for (var i = 0; i < campioni; i++) {
      p.leggiDalSensorePerLaProva(g.$1, g.$2, g.$3);
    }
  }

  double corsaDelFondo(ParallaxController p) =>
      p.layerOffset(ParallaxController.depthPianoPrincipale).dx.abs();

  double corsaDelFondoY(ParallaxController p) =>
      p.layerOffset(ParallaxController.depthPianoPrincipale).dy.abs();

  test('tenendo il telefono fermo il cielo sta fermo, su tutti e due gli assi',
      () {
    final p = ParallaxController();
    // La postura di chi legge: verticale, gravita' quasi tutta su Y.
    tieniFermo(p, postura());
    // ignore: avoid_print
    print('ORDINE AS VOCE 01: fermo nella postura di lettura, tilt '
        '${p.tiltX.toStringAsFixed(3)} e ${p.tiltY.toStringAsFixed(3)}, '
        'corse ${corsaDelFondo(p).toStringAsFixed(1)} e '
        '${corsaDelFondoY(p).toStringAsFixed(1)} punti');
    expect(p.tiltX.abs(), lessThan(0.05),
        reason: 'da fermo l asse X non e a zero: il cielo si muove da solo');
    expect(p.tiltY.abs(), lessThan(0.05),
        reason: 'da fermo l asse Y non e a zero. E il difetto vero: prima '
            'valeva 0,98 in permanenza, cioe meta della parallasse era gia a '
            'fondo corsa e non poteva andare oltre');
    p.dispose();
  });

  test('quindici gradi dal riposo danno piu di 60 punti sugli 80', () {
    final p = ParallaxController();
    // Prima la persona tiene il telefono come le viene, e il riposo lo impara.
    tieniFermo(p, postura());
    // Poi lo inclina di quindici gradi. Il gesto dura circa un secondo, cioe'
    // una quindicina di campioni a 66 millisecondi: il riposo non fa in tempo
    // a seguirlo, ed e' esattamente il punto.
    tieniFermo(p, postura(inclinazioneX: 15), campioni: 30);
    final corsa = corsaDelFondo(p);
    // ignore: avoid_print
    print('ORDINE AS VOCE 01: a quindici gradi dal riposo il piano di fondo '
        'corre ${corsa.toStringAsFixed(1)} punti sugli 80 attesi a fondo '
        'corsa (tilt ${p.tiltX.toStringAsFixed(3)})');
    expect(corsa, greaterThan(60),
        reason: 'quindici gradi danno solo ${corsa.toStringAsFixed(1)} punti: '
            'e la parallasse che si sposta di pochi millimetri, cioe il '
            'difetto che questa voce doveva chiudere');
    p.dispose();
  });

  test('a fondo corsa restano 80 punti, mai di piu', () {
    final p = ParallaxController();
    tieniFermo(p, postura());
    // Novanta gradi: il telefono coricato. La saturazione e' morbida, quindi
    // ci si arriva vicino senza mai sfondare.
    tieniFermo(p, postura(inclinazioneX: 90), campioni: 60);
    final corsa = corsaDelFondo(p);
    // ignore: avoid_print
    print('ORDINE AS VOCE 01: a fondo corsa il piano di fondo corre '
        '${corsa.toStringAsFixed(1)} punti');
    expect(corsa, lessThanOrEqualTo(80.5),
        reason: 'la corsa ha sfondato gli 80 punti dichiarati: i rapporti fra '
            'i piani non valgono piu');
    expect(corsa, greaterThan(70),
        reason: 'a fondo corsa non si arriva nemmeno vicino agli 80');
    p.dispose();
  });

  test('i rapporti fra i piani non sono cambiati', () {
    // **LA CORSA DEI PIANI E CONGELATA, ordine AR voce 01**, e questa voce
    // tocca il controllore: quindi si rimisura contro la tabella F3, che e' la
    // condizione dichiarata per poterlo toccare.
    final p = ParallaxController();
    p.inclinaPerLaProva(1, 1);
    final attesi = {'polvere': 30.0, 'fondo': 80.0, 'medio': 105.5, 'vicino': 165.5};
    final misurati = {
      'polvere': p.layerOffset(0.06).dx.abs(),
      'fondo': p.layerOffset(0.16).dx.abs(),
      'medio': p.layerOffset(0.5).dx.abs(),
      'vicino': p.layerOffset(1.3).dx.abs(),
    };
    // ignore: avoid_print
    print('ORDINE AS VOCE 01: corsa dei piani a tilt imposto '
        '${misurati.map((k, v) => MapEntry(k, v.toStringAsFixed(1)))}');
    for (final piano in attesi.keys) {
      expect((misurati[piano]! - attesi[piano]!).abs(), lessThan(0.6),
          reason: 'il piano $piano corre ${misurati[piano]} invece di '
              '${attesi[piano]}: la tabella F3 non vale piu');
    }
    p.dispose();
  });

  test('la postura nuova diventa il riposo nuovo, ma non subito', () {
    // Chi si sdraia sul divano tiene il telefono in un altro modo, e dopo un
    // po' quello deve diventare il suo zero. Ma non dopo due secondi, se no
    // ogni inclinazione voluta si mangerebbe da sola.
    final p = ParallaxController();
    tieniFermo(p, postura());
    tieniFermo(p, postura(inclinazioneX: 30), campioni: 30);
    final subito = corsaDelFondo(p);
    tieniFermo(p, postura(inclinazioneX: 30), campioni: 900);
    final dopo = corsaDelFondo(p);
    // ignore: avoid_print
    print('ORDINE AS VOCE 01: tenuto inclinato, la corsa passa da '
        '${subito.toStringAsFixed(1)} a ${dopo.toStringAsFixed(1)} punti');
    expect(subito, greaterThan(60),
        reason: 'l inclinazione appena fatta non muove il cielo');
    expect(dopo, lessThan(20),
        reason: 'tenendo il telefono cosi per un minuto il cielo resta '
            'spostato: quella postura e diventata la normalita e il cielo '
            'dovrebbe tornare a casa');
    p.dispose();
  });
}
