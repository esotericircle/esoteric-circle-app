import 'dart:math' as math;

import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// IL CIELO PARTE DA SUBITO. Ordine BA voce 01.
///
/// **Il fatto del fondatore, sulla 2195**: "resta il problema dello sfondo che
/// non e' fluido, sembra partire in ritardo rispetto al movimento che applico
/// al cellulare".
///
/// **Non e' un ritardo di tempo: e' una soglia di angolo**, e la riga
/// diagnostica del fondatore lo diceva gia' senza che nessuno la leggesse come
/// una misura. Col telefono in mano: "Mano: -2.0 e 4.8 gradi dal riposo, su 30
/// a fondo corsa. Risposta dopo la curva 0.00 e 0.00." **Quattro virgola otto
/// gradi, e il piano si muove di zero punti.**
///
/// **PERCHE' L'ORDINE AW NON LO AVEVA TROVATO, e le sue misure restano vere.**
/// Quelle guardavano il TEMPO: quanti fotogrammi cambiano, e quanto salta il
/// valore dipinto fra l'uno e l'altro. **Nessuna guardava quanti gradi servono
/// perche' il cielo cominci a muoversi.** Un cielo che si ridipinge
/// perfettamente a ogni fotogramma, ma solo dopo cinque gradi, passa tutte
/// quelle prove **e sembra comunque in ritardo**. Questa prova copre proprio
/// il buco fra le due famiglie di misura.
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

  /// I punti che il piano di fondo percorre inclinando di [gradi].
  ///
  /// **Si legge il valore DIPINTO**, non il bersaglio: si fanno passare
  /// abbastanza fotogrammi perche' l'interpolazione arrivi in fondo, se no si
  /// misurerebbe cio' che il cielo vorrebbe fare invece di cio' che fa.
  double puntiA(double gradi, {double profondita = 1.0}) {
    final c = ParallaxController();
    // Il riposo si impara sul primo campione: si parte da fermi.
    c.leggiDalSensorePerLaProva(0, 0, 9.81);
    for (var i = 0; i < 60; i++) {
      c.leggiDalSensorePerLaProva(0, 0, 9.81);
      c.avanzaIlFotogrammaPerLaProva(16);
    }
    final seno = math.sin(gradi * math.pi / 180);
    for (var i = 0; i < 120; i++) {
      c.leggiDalSensorePerLaProva(0, seno * 9.81, 9.81);
      c.avanzaIlFotogrammaPerLaProva(16);
    }
    final punti = c.layerOffset(profondita).dy.abs();
    c.dispose();
    return punti;
  }

  test('LA MISURA CHE MANCAVA: quanti gradi servono perche il cielo parta', () {
    // **LA SOGLIA, cercata mezzo grado alla volta.** E' il numero che il
    // fondatore sente come "ritardo" e che nessuna prova aveva mai preso.
    double? sogliaVisibile;
    double? sogliaQualunque;
    final tabella = <String>[];
    for (var g = 0.5; g <= 20.0; g += 0.5) {
      final punti = puntiA(g);
      if (sogliaQualunque == null && punti > 0.01) sogliaQualunque = g;
      // **UN PUNTO SOLO NON SI VEDE.** Su uno schermo a tre pixel per punto,
      // sotto i due punti il movimento e' sotto la soglia di cio' che un
      // occhio nota su uno sfondo stellato.
      if (sogliaVisibile == null && punti >= 2.0) sogliaVisibile = g;
      if (g == 2.0 || g == 5.0 || g == 8.0 || g == 10.0 || g == 15.0) {
        tabella.add('$g gradi -> ${punti.toStringAsFixed(1)} punti');
      }
    }
    // ignore: avoid_print
    print('ORDINE BA VOCE 01: il cielo si muove di qualcosa da '
        '$sogliaQualunque gradi, e di due punti da $sogliaVisibile gradi. '
        '${tabella.join(', ')}');

    expect(sogliaQualunque, isNotNull,
        reason: 'il cielo non si muove nemmeno a venti gradi');
    expect(sogliaQualunque!, lessThanOrEqualTo(2.0),
        reason: 'servono $sogliaQualunque gradi perche il cielo si muova di '
            'qualcosa: chi guarda il telefono lo inclina di meno, e non vede '
            'partire niente. E il fatto del fondatore');
    expect(sogliaVisibile!, lessThanOrEqualTo(5.0),
        reason: 'servono $sogliaVisibile gradi perche il movimento si veda: '
            'troppi per un gesto naturale');
  });

  test('e la mano ferma resta ferma, che e la ragione della soglia', () {
    // **LA CONTROPROVA, e senza di lei la cura sarebbe un peggioramento.** La
    // zona morta esiste per un motivo vero: senza, il tremore della mano fa
    // vibrare il cielo. Ordine AV voce 02, misura M3 e M4.
    final c = ParallaxController();
    c.leggiDalSensorePerLaProva(0, 0, 9.81);
    for (var i = 0; i < 60; i++) {
      c.leggiDalSensorePerLaProva(0, 0, 9.81);
      c.avanzaIlFotogrammaPerLaProva(16);
    }
    // Il tremore di una mano ferma: mezzo grado di ampiezza, avanti e
    // indietro, come misurato sul dispositivo negli ordini precedenti.
    var massimo = 0.0;
    final caso = math.Random(42);
    for (var i = 0; i < 240; i++) {
      final tremore = math.sin(0.5 * math.pi / 180) * (caso.nextDouble() - 0.5);
      c.leggiDalSensorePerLaProva(tremore * 9.81, tremore * 9.81, 9.81);
      c.avanzaIlFotogrammaPerLaProva(16);
      final p = c.layerOffset(1.0).dy.abs();
      if (p > massimo) massimo = p;
    }
    // ignore: avoid_print
    print('ORDINE BA VOCE 01: con la mano che trema di mezzo grado, il cielo '
        'si muove al massimo di ${massimo.toStringAsFixed(2)} punti');
    expect(massimo, lessThan(1.0),
        reason: 'il cielo vibra con la mano ferma: la soglia e stata abbassata '
            'troppo e il tremore e tornato');
    c.dispose();
  });

  test('quanto ci mette ad arrivare a meta strada', () {
    // **IL RITARDO DI TEMPO, che e' l'altra meta' della domanda.** Qui si
    // misura in millesimi, non in gradi.
    final c = ParallaxController();
    c.leggiDalSensorePerLaProva(0, 0, 9.81);
    for (var i = 0; i < 60; i++) {
      c.leggiDalSensorePerLaProva(0, 0, 9.81);
      c.avanzaIlFotogrammaPerLaProva(16);
    }
    final seno = math.sin(20 * math.pi / 180);
    // Prima si trova dove arriva a regime.
    for (var i = 0; i < 200; i++) {
      c.leggiDalSensorePerLaProva(0, seno * 9.81, 9.81);
      c.avanzaIlFotogrammaPerLaProva(16);
    }
    final aRegime = c.layerOffset(1.0).dy.abs();
    c.dispose();

    final d = ParallaxController();
    d.leggiDalSensorePerLaProva(0, 0, 9.81);
    for (var i = 0; i < 60; i++) {
      d.leggiDalSensorePerLaProva(0, 0, 9.81);
      d.avanzaIlFotogrammaPerLaProva(16);
    }
    int? quando;
    for (var i = 0; i < 200; i++) {
      d.leggiDalSensorePerLaProva(0, seno * 9.81, 9.81);
      d.avanzaIlFotogrammaPerLaProva(16);
      if (quando == null && d.layerOffset(1.0).dy.abs() >= aRegime / 2) {
        quando = (i + 1) * 16;
      }
    }
    // ignore: avoid_print
    print('ORDINE BA VOCE 01: a venti gradi il cielo arriva a $aRegime punti, '
        'e fa meta strada in $quando millesimi');
    expect(quando, isNotNull);
    expect(quando!, lessThanOrEqualTo(120),
        reason: 'il cielo ci mette $quando millesimi per fare meta strada: '
            'sopra i centoventi il gesto e finito prima che il cielo arrivi');
    d.dispose();
  });
}
