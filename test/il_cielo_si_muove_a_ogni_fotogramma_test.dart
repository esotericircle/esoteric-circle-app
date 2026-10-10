import 'dart:math' as math;

import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// IL CIELO SI MUOVE A OGNI FOTOGRAMMA. Ordine AW voce 01, misura M1.
///
/// **E' la misura che mancava, e senza di lei il difetto e' passato per due
/// ordini.** L'ordine AU voce 04 chiedeva due punti, zero al riposo e oltre
/// sessanta a quindici gradi; l'ordine AV voce 02 ha aggiunto la continuita' in
/// GRADI, cioe' che la curva non salti fra un grado e il successivo. **Nessuna
/// delle due guarda il TEMPO**: una risposta perfetta in gradi, ridipinta
/// quindici volte al secondo su uno schermo che ne disegna centoventi, e' otto
/// fotogrammi identici e uno che salta.
///
/// **Qui si misura il tempo.** Si inclina in modo lento e continuo, si guarda
/// il valore dipinto a ogni fotogramma dello schermo e si contano due cose: se
/// cambia, e di quanto salta al massimo.
///
/// **La prova resta nel repository per sempre**, come l'ordine chiede: e' la
/// sola che vede uno scatto nel tempo invece che nello spazio.
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

  /// Ottanta punti e' la corsa piena del piano di fondo: e' l'unita' in cui il
  /// fondatore riporta le misure, quindi e' l'unita' in cui si risponde.
  double punti(double tilt) => tilt * 80;

  /// **UN GESTO LENTO E CONTINUO DI DUE SECONDI**, come l'ordine descrive: il
  /// polso che si inclina piano da zero a venti gradi.
  ///
  /// Lo schermo disegna a 120 al secondo, il sensore parla molto piu' di rado:
  /// qui si simulano tutti e due gli orologi, e a ogni fotogramma si guarda
  /// cosa il cielo mostrerebbe.
  ({
    List<double> perFotogramma,
    int quantiCambiano,
    int quantiGuardati,
    double saltoMassimo
  }) inclinaPiano(ParallaxController c, {required int passoDelSensore}) {
    const millesimiDelFotogramma = 1000 ~/ 120;
    const durata = 2000;
    // Si parte fermi: il riposo si impara.
    for (var i = 0; i < 20; i++) {
      c.leggiDalSensorePerLaProva(0, 9.0, 3.8);
    }
    final dipinti = <double>[];
    var prossimoCampione = 0;
    for (var t = 0; t <= durata; t += millesimiDelFotogramma) {
      if (t >= prossimoCampione) {
        prossimoCampione += passoDelSensore;
        // Da zero a venti gradi in due secondi, lineare.
        final gradi = 20.0 * t / durata;
        c.leggiDalSensorePerLaProva(
            math.sin(gradi * math.pi / 180) * 9.8, 9.0, 3.8);
      }
      c.avanzaIlFotogrammaPerLaProva(millesimiDelFotogramma);
      dipinti.add(punti(c.tiltX.abs()));
    }
    // **SI CONTA DA QUANDO IL CIELO COMINCIA A MUOVERSI**, e non e' una
    // scappatoia: il gesto parte da zero gradi e i primi cinque stanno DENTRO
    // LA ZONA MORTA, dove il cielo deve restare fermo per scelta, ordine AU
    // voce 04. Su due secondi sono circa sessanta fotogrammi su
    // duecentocinquanta, e contarli come "fermi" vorrebbe dire chiamare
    // difetto la cura del tremore. Da quando il movimento comincia in poi,
    // pero', ogni fotogramma deve cambiare.
    final primoVivo = () {
      for (var i = 1; i < dipinti.length; i++) {
        if ((dipinti[i] - dipinti[i - 1]).abs() > 0.001) return i;
      }
      return dipinti.length;
    }();
    var cambiano = 0;
    var salto = 0.0;
    var guardati = 0;
    for (var i = primoVivo; i < dipinti.length; i++) {
      final d = (dipinti[i] - dipinti[i - 1]).abs();
      guardati++;
      if (d > 0.001) cambiano++;
      if (d > salto) salto = d;
    }
    return (
      perFotogramma: dipinti,
      quantiCambiano: cambiano,
      quantiGuardati: guardati,
      saltoMassimo: salto
    );
  }

  tearDown(() => ParallaxController.interpolaSulFotogramma = true);

  test('M1 PRIMA e DOPO, con la stessa formula', () {
    // **LE DUE TABELLE CHE L'ORDINE CHIEDE, misurate nello stesso file.**
    // Spegnendo l'interpolazione il campione del sensore torna a dipingere
    // direttamente, com'era prima di quest'ordine: e' il solo modo di
    // confrontare due comportamenti con lo stesso metro invece che con due
    // rapporti scritti in giorni diversi.
    ParallaxController.interpolaSulFotogramma = false;
    final prima = ParallaxController();
    final vecchio = inclinaPiano(prima, passoDelSensore: 66);
    prima.dispose();
    ParallaxController.interpolaSulFotogramma = true;
    final dopo = ParallaxController();
    final nuovo = inclinaPiano(dopo, passoDelSensore: 16);
    dopo.dispose();

    final quotaPrima = vecchio.quantiCambiano / vecchio.quantiGuardati;
    final quotaDopo = nuovo.quantiCambiano / nuovo.quantiGuardati;
    // ignore: avoid_print
    print('ORDINE AW VOCE 01, M1 PRIMA: cambiano il '
        '${(quotaPrima * 100).toStringAsFixed(1)} per cento dei fotogrammi, '
        'salto massimo ${vecchio.saltoMassimo.toStringAsFixed(2)} punti su 80');
    // ignore: avoid_print
    print('ORDINE AW VOCE 01, M1 DOPO:  cambiano il '
        '${(quotaDopo * 100).toStringAsFixed(1)} per cento dei fotogrammi, '
        'salto massimo ${nuovo.saltoMassimo.toStringAsFixed(2)} punti su 80');
    // **IL PRIMA DEVE FALLIRE**, come l'ordine pretende: se passasse, la causa
    // sarebbe un'altra e questa cura non servirebbe.
    expect(quotaPrima, lessThan(0.90),
        reason: 'il comportamento di prima passa gia la prova della fluidita: '
            'allora la causa dello scatto non e il disegno legato al campione, '
            'ed e da cercare altrove');
    expect(vecchio.saltoMassimo, greaterThan(1.5),
        reason: 'prima della cura nessun fotogramma saltava piu di 1,5 punti: '
            'la causa e un altra');
    expect(quotaDopo, greaterThan(0.90));
    expect(nuovo.saltoMassimo, lessThanOrEqualTo(1.5));
  });

  test(
      'M1 il valore dipinto cambia a ogni fotogramma, e nessuno salta piu di '
      '1,5 punti', () {
    final c = ParallaxController();
    final misura = inclinaPiano(c, passoDelSensore: 16);
    final quanti = misura.quantiGuardati;
    final quota = misura.quantiCambiano / quanti;
    // ignore: avoid_print
    print('ORDINE AW VOCE 01, M1: su $quanti fotogrammi col cielo in moto ne '
        'cambiano '
        '${misura.quantiCambiano}, cioe il ${(quota * 100).toStringAsFixed(1)} '
        'per cento; il salto piu grande vale '
        '${misura.saltoMassimo.toStringAsFixed(2)} punti su 80');
    expect(quota, greaterThan(0.90),
        reason: 'solo il ${(quota * 100).toStringAsFixed(1)} per cento dei '
            'fotogrammi cambia: il cielo resta fermo e poi salta, ed e '
            'esattamente cio che il fondatore vede');
    expect(misura.saltoMassimo, lessThanOrEqualTo(1.5),
        reason: 'un fotogramma sposta il piano di fondo di '
            '${misura.saltoMassimo.toStringAsFixed(2)} punti: si vede come uno '
            'scatto');
    c.dispose();
  });

  test('M1 vale anche col sensore rado, perche a interpolare e il fotogramma',
      () {
    // **LA PROVA CHE DISTINGUE LE DUE CURE.** Infittire il sensore da solo
    // non basta: se il disegno dipendesse ancora dal campione, con un sensore
    // rado il cielo tornerebbe a scattare. Qui il sensore parla ogni 66
    // millesimi, come prima dell'ordine, e il cielo deve restare fluido lo
    // stesso.
    final c = ParallaxController();
    final misura = inclinaPiano(c, passoDelSensore: 66);
    final quanti = misura.quantiGuardati;
    final quota = misura.quantiCambiano / quanti;
    // ignore: avoid_print
    print('ORDINE AW VOCE 01, M1 col sensore rado: cambiano il '
        '${(quota * 100).toStringAsFixed(1)} per cento dei fotogrammi, salto '
        'massimo ${misura.saltoMassimo.toStringAsFixed(2)} punti');
    expect(quota, greaterThan(0.90),
        reason: 'col sensore rado il cielo torna a scattare: vuol dire che a '
            'interpolare non e il fotogramma ma il campione');
    expect(misura.saltoMassimo, lessThanOrEqualTo(1.5));
    c.dispose();
  });

  test('M7 il costo: quanti fotogrammi si spendono, e da fermi nessuno', () {
    // **IL COSTO SI CONTA, non si stima.** Ordine AW voce 01, misura M7.
    //
    // Il cielo fluido spende un fotogramma per ogni fotogramma dello schermo
    // MENTRE si muove: e' il prezzo della cura. Cio' che non deve fare e'
    // spenderne da fermo, e questa e' la misura che lo dice.
    final c = ParallaxController();
    // Dieci secondi di movimento continuo a 120 al secondo.
    var dipinti = 0;
    var precedente = -1.0;
    for (var i = 0; i < 20; i++) {
      c.leggiDalSensorePerLaProva(0, 9.0, 3.8);
    }
    for (var t = 0; t < 10000; t += 8) {
      if (t % 16 == 0) {
        final gradi = 20.0 * (t % 2000) / 2000;
        c.leggiDalSensorePerLaProva(
            math.sin(gradi * math.pi / 180) * 9.8, 9.0, 3.8);
      }
      c.avanzaIlFotogrammaPerLaProva(8);
      if (c.tiltX != precedente) dipinti++;
      precedente = c.tiltX;
    }
    // ignore: avoid_print
    print('ORDINE AW VOCE 01, M7: in dieci secondi di movimento continuo il '
        'cielo si ridipinge $dipinti volte su 1250 fotogrammi');

    // **E DA FERMO SI FERMA, dopo aver finito la strada.** Quando il gesto
    // cessa, il valore dipinto e' ancora a meta' cammino verso il bersaglio e
    // deve arrivarci: sono un paio di decimi, cioe' qualche decina di
    // fotogrammi, e sono la cura che finisce il suo lavoro. **Cio' che non
    // deve succedere e' che continui per sempre**, e quello si vede guardando
    // il secondo tratto, dove il bersaglio e' fermo da un pezzo.
    var arrivo = 0;
    precedente = c.tiltX;
    for (var t = 0; t < 1000; t += 8) {
      c.avanzaIlFotogrammaPerLaProva(8);
      if (c.tiltX != precedente) arrivo++;
      precedente = c.tiltX;
    }
    var poi = 0;
    for (var t = 0; t < 4000; t += 8) {
      c.avanzaIlFotogrammaPerLaProva(8);
      if (c.tiltX != precedente) poi++;
      precedente = c.tiltX;
    }
    // ignore: avoid_print
    print('ORDINE AW VOCE 01, M7: finito il gesto, il cielo si ridipinge '
        '$arrivo volte nel primo secondo per arrivare a destinazione, e $poi '
        'volte nei quattro successivi');
    expect(poi, 0,
        reason: 'a bersaglio raggiunto il cielo continua a ridipingersi $poi '
            'volte: il ticker non si ferma e la batteria paga per niente');
    c.dispose();
  });
}
