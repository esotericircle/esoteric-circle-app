@Tags(['ricerca'])
library;

import 'dart:math' as math;

import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// LA TERNA DEL CIELO CHE PARTE SUBITO. Ordine BA voce 01.
///
/// **La ricerca gira sul controller VERO, non su un modello.** E' la lezione
/// dell'ordine AV voce 02: la prima ricerca di allora girava su un modello
/// scritto a parte e dava per buona una terna che sul controller vero non
/// passava. **Un modello del proprio codice e' un secondo codice.**
///
/// **Cosa si cerca.** La zona morta, il fondo corsa e l'esponente che
/// soddisfano insieme quattro cose:
///
/// 1. il cielo si muove **entro due gradi**, che e' l'inclinazione di chi
///    guarda il telefono senza volerlo muovere;
/// 2. il movimento si **vede** entro cinque gradi, cioe' vale almeno due
///    punti;
/// 3. con la mano che trema di mezzo grado il cielo resta **sotto un punto**,
///    se no si torna al tremore che la zona morta era nata per togliere;
/// 4. a quindici gradi resta **corsa da dosare**, cioe' non si e' gia' a fondo
///    corsa: e' l'"incontrollabile" che il fondatore aveva segnalato prima
///    dell'ordine AW.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
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
  });

  double puntiA(double gradi) {
    final c = ParallaxController();
    c.leggiDalSensorePerLaProva(0, 0, 9.81);
    for (var i = 0; i < 40; i++) {
      c.leggiDalSensorePerLaProva(0, 0, 9.81);
      c.avanzaIlFotogrammaPerLaProva(16);
    }
    final seno = math.sin(gradi * math.pi / 180);
    for (var i = 0; i < 100; i++) {
      c.leggiDalSensorePerLaProva(0, seno * 9.81, 9.81);
      c.avanzaIlFotogrammaPerLaProva(16);
    }
    final punti = c.layerOffset(1.0).dy.abs();
    c.dispose();
    return punti;
  }

  double tremoreDellaManoFerma() {
    final c = ParallaxController();
    c.leggiDalSensorePerLaProva(0, 0, 9.81);
    for (var i = 0; i < 40; i++) {
      c.leggiDalSensorePerLaProva(0, 0, 9.81);
      c.avanzaIlFotogrammaPerLaProva(16);
    }
    var massimo = 0.0;
    final caso = math.Random(42);
    for (var i = 0; i < 200; i++) {
      final t = math.sin(0.5 * math.pi / 180) * (caso.nextDouble() - 0.5);
      c.leggiDalSensorePerLaProva(t * 9.81, t * 9.81, 9.81);
      c.avanzaIlFotogrammaPerLaProva(16);
      final p = c.layerOffset(1.0).dy.abs();
      if (p > massimo) massimo = p;
    }
    c.dispose();
    return massimo;
  }

  test('si cerca la terna sul controller vero, e si dichiara quella scelta',
      () {
    final partenza = [
      ParallaxController.zonaMorta,
      ParallaxController.fondoCorsaInGradi,
      ParallaxController.esponenteDellaCurva,
    ];
    addTearDown(() => ParallaxController.tara(
        zona: partenza[0],
        fondoInGradi: partenza[1],
        esponente: partenza[2]));

    final buone = <String>[];
    String? migliore;
    var migliorSoglia = 999.0;
    for (final zona in const [0.008, 0.012, 0.018, 0.026, 0.035]) {
      for (final fondo in const [14.0, 18.0, 22.0, 26.0]) {
        for (final esponente in const [1.0, 1.3, 1.6, 2.0]) {
          ParallaxController.tara(
              zona: zona, fondoInGradi: fondo, esponente: esponente);
          final tremore = tremoreDellaManoFerma();
          if (tremore >= 1.0) continue;
          double? parte;
          double? siVede;
          for (var g = 0.5; g <= 8.0; g += 0.5) {
            final p = puntiA(g);
            if (parte == null && p > 0.01) parte = g;
            if (siVede == null && p >= 2.0) siVede = g;
            if (parte != null && siVede != null) break;
          }
          if (parte == null || siVede == null) continue;
          if (parte > 2.0 || siVede > 5.0) continue;
          // **A QUINDICI GRADI DEVE RESTARE CORSA DA DOSARE.** Sopra i tre
          // quarti si e' quasi a fondo corsa, e da li' in poi il gesto non
          // cambia piu' niente: e' l'"incontrollabile" di prima dell'ordine AW.
          final a15 = puntiA(15) / 80.0;
          if (a15 > 0.75) continue;
          final riga = 'zona ${zona.toStringAsFixed(3)}, fondo $fondo gradi, '
              'esponente $esponente -> parte a $parte, si vede a $siVede, '
              'a 15 gradi ${(a15 * 100).round()} per cento, tremore '
              '${tremore.toStringAsFixed(2)}';
          buone.add(riga);
          if (siVede < migliorSoglia) {
            migliorSoglia = siVede;
            migliore = riga;
          }
        }
      }
    }
    // ignore: avoid_print
    print('ORDINE BA VOCE 01: terne che passano tutte e quattro le pretese: '
        '${buone.length}');
    for (final r in buone.take(8)) {
      // ignore: avoid_print
      print('  ORDINE BA VOCE 01: $r');
    }
    // ignore: avoid_print
    print('ORDINE BA VOCE 01: la migliore e "$migliore"');
    expect(buone, isNotEmpty,
        reason: 'nessuna terna fa partire il cielo entro due gradi tenendo '
            'ferma la mano ferma: le due pretese non stanno insieme, e va '
            'detto invece di scegliere a caso');
  });
  test('le candidate reggono anche una mano che trema il doppio e il triplo',
      () {
    // **IL TREMORE VERO NON LO DECIDO IO.** La ricerca qui sopra usa mezzo
    // grado, che e' una mano ferma da seduti. Chi guarda il telefono
    // camminando, o con le mani fredde, ne fa di piu': scegliere la terna sul
    // caso piu' facile vorrebbe dire riportare il tremore addosso al
    // fondatore e chiamarlo "cielo reattivo".
    final partenza = [
      ParallaxController.zonaMorta,
      ParallaxController.fondoCorsaInGradi,
      ParallaxController.esponenteDellaCurva,
    ];
    addTearDown(() => ParallaxController.tara(
        zona: partenza[0], fondoInGradi: partenza[1], esponente: partenza[2]));

    double tremoreCon(double gradi) {
      final c = ParallaxController();
      c.leggiDalSensorePerLaProva(0, 0, 9.81);
      for (var i = 0; i < 40; i++) {
        c.leggiDalSensorePerLaProva(0, 0, 9.81);
        c.avanzaIlFotogrammaPerLaProva(16);
      }
      var massimo = 0.0;
      final caso = math.Random(7);
      for (var i = 0; i < 300; i++) {
        final t = math.sin(gradi * math.pi / 180) * (caso.nextDouble() - 0.5);
        c.leggiDalSensorePerLaProva(t * 9.81, t * 9.81, 9.81);
        c.avanzaIlFotogrammaPerLaProva(16);
        final p = c.layerOffset(1.0).dy.abs();
        if (p > massimo) massimo = p;
      }
      c.dispose();
      return massimo;
    }

    final candidate = <List<double>>[
      [0.008, 26.0, 1.3],
      [0.008, 26.0, 1.6],
      [0.012, 26.0, 1.6],
      [0.018, 26.0, 1.6],
    ];
    for (final k in candidate) {
      ParallaxController.tara(zona: k[0], fondoInGradi: k[1], esponente: k[2]);
      final mezzo = tremoreCon(0.5);
      final uno = tremoreCon(1.0);
      final unoEMezzo = tremoreCon(1.5);
      final tre = tremoreCon(3.0);
      double? vede;
      for (var g = 0.5; g <= 8.0; g += 0.5) {
        if (puntiA(g) >= 2.0) {
          vede = g;
          break;
        }
      }
      // ignore: avoid_print
      print('ORDINE BA VOCE 01, candidata zona ${k[0]} fondo ${k[1]} '
          'esponente ${k[2]}: si vede a $vede gradi; tremore mezzo grado '
          '${mezzo.toStringAsFixed(2)}, un grado ${uno.toStringAsFixed(2)}, '
          'un grado e mezzo ${unoEMezzo.toStringAsFixed(2)}, tre gradi '
          '${tre.toStringAsFixed(2)} punti');
    }
  });
}
