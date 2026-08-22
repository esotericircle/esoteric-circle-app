import 'dart:math' as math;

import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// LA MANO FERMA NON MUOVE IL CIELO. Ordine AU voce 04.
///
/// **Il difetto, misurato dal fondatore sulla build 2188.** Riga diagnostica,
/// telefono tenuto in mano fermo: "Inclinazione dal riposo 0.41 e 0.09. Il
/// piano di fondo corre 32.8 in orizzontale e -6.4 in verticale, su 80
/// attesi." Trentadue punti su ottanta con la mano ferma: il cielo tremava di
/// continuo, e con lui i tre Maestri in home.
///
/// **Non era lo zero appreso**, che funziona ed e' la cura dell'ordine AS voce
/// 01: era che vicino al riposo la risposta era ripida quanto a meta' corsa,
/// circa ottanta punti per unita' di inclinazione, quindi il tremore
/// fisiologico della mano bastava a muovere tutto.
///
/// **Le quattro misure di accettazione sono quelle che l'ordine detta**, e si
/// misurano tutte e quattro qui, sulla stessa formula che gira sul telefono.
/// Il gesto vero, quello con la mano di una persona, resta dell'Architetto:
/// qui si prova la matematica, non la percezione.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // **IL SENSORE VERO NON C'E' NELLE PROVE**, e il controller lo cerca in
    // costruzione: senza questo il canale risponde MissingPluginException e
    // la prova cade per un motivo che non c'entra con cio' che misura.
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

  /// **Il rumore della mano ferma, ricostruito dalla misura del fondatore.**
  /// Da `tilt = tanh(dev * 5)` col guadagno di allora si risale alla
  /// deviazione vera: `atanh(0,41) / 5 = 0,0871` g. Non e' una stima: e' il
  /// numero che spiega esattamente i 32,8 punti osservati, ed e' cosi' che si
  /// e' scelta la zona morta.
  const deviazioneDellaManoFerma = 0.0871;

  /// Il piano di fondo corre ottanta punti a corsa piena: e' l'unita' in cui
  /// il fondatore ha riportato la misura, quindi e' l'unita' in cui si
  /// risponde.
  double punti(double tilt) => tilt * 80;

  /// Fa arrivare al controller una sequenza di letture, come farebbe il
  /// sensore. `g` e' la gravita' sull'asse Y di un telefono tenuto per
  /// leggere.
  void leggi(ParallaxController c, int quante,
      {double x = 0, double y = 9.0, double Function(int)? scarto}) {
    for (var i = 0; i < quante; i++) {
      final s = scarto?.call(i) ?? 0.0;
      c.leggiDalSensorePerLaProva(x + s, y, 3.8);
      // **E IL FOTOGRAMMA PASSA.** Ordine AW voce 01: dal cielo fluido il
      // valore dipinto insegue il bersaglio fotogramma per fotogramma, quindi
      // leggere il tilt subito dopo un campione vorrebbe dire leggerlo a meta'
      // strada. Il sensore parla ogni sedici millesimi e lo schermo disegna
      // ogni otto: due fotogrammi per campione.
      c.avanzaIlFotogrammaPerLaProva(8);
      c.avanzaIlFotogrammaPerLaProva(8);
    }
  }

  test('M1, telefono sul tavolo: spostamento zero', () {
    // Sul tavolo la lettura e' identica a se stessa. Non "quasi zero": ZERO.
    final c = ParallaxController();
    leggi(c, 150);
    // ignore: avoid_print
    print('ORDINE AU VOCE 04, M1: sul tavolo il piano di fondo corre '
        '${punti(c.tiltX).abs().toStringAsFixed(3)} punti su 80');
    expect(punti(c.tiltX).abs(), lessThan(0.001));
    expect(punti(c.tiltY).abs(), lessThan(0.001));
    c.dispose();
  });

  test('M2, telefono in mano fermo: sotto 2 punti su 80', () {
    // **DUE FORME DI MANO FERMA, perche' sono due difetti diversi.** Una mano
    // che trema oscilla in fretta attorno a un punto; una mano che si posa
    // resta ferma un poco piu' in la' del riposo appreso. La prima la toglie
    // il filtro, la seconda la zona morta, e servono tutte e due.
    for (final tremore in [true, false]) {
      final c = ParallaxController();
      leggi(c, 20);
      // **SI PRENDE IL PICCO, non il valore finale.** Alla fine di dieci
      // secondi il riposo ha gia' imparato la posa nuova e la deviazione si e'
      // riassorbita da sola: misurare li' darebbe zero anche a una cura che
      // non funziona. Il momento vero e' subito dopo che la mano si e' posata,
      // quando il riposo non sa ancora niente, ed e' quello che il fondatore
      // vede.
      var corsa = 0.0;
      for (var i = 0; i < 150; i++) {
        c.leggiDalSensorePerLaProva(
            tremore
                // Tremore fisiologico: dieci volte al secondo, cioe' un giro
                // ogni due campioni e mezzo a 66 millesimi.
                ? deviazioneDellaManoFerma * 9.8 * math.sin(i * 2.5)
                : deviazioneDellaManoFerma * 9.8,
            9.0,
            3.8);
        final adesso = punti(c.tiltX).abs();
        if (adesso > corsa) corsa = adesso;
      }
      // ignore: avoid_print
      print('ORDINE AU VOCE 04, M2: mano ferma '
          '${tremore ? "che trema" : "posata di lato"}, il piano di fondo '
          'corre ${corsa.toStringAsFixed(2)} punti su 80 (prima erano 32,8)');
      expect(corsa, lessThan(2.0),
          reason: 'con la mano ferma il cielo si muove ancora: il fondatore '
              'lo vede tremare, e con lui i tre Maestri');
      c.dispose();
    }
  });

  test('M5, a quindici gradi si dosa: fra 25 e 40 punti, non a fondo corsa',
      () {
    // **QUESTA MISURA SOSTITUISCE QUELLA VECCHIA, ordine AW voce 01.**
    //
    // Fino a ieri qui si pretendeva **oltre sessanta punti a quindici gradi**,
    // e il fondo corsa stava a sedici: vuol dire che un movimento normale del
    // polso arrivava al massimo e **da li' non c'era piu' controllo**. E' il
    // "incontrollabile" che il fondatore ha descritto, ed e' un fatto letto
    // nella sua riga diagnostica, dove l'inclinazione risultava gia' saturata
    // a 1,00.
    //
    // Adesso il fondo corsa sta a trenta gradi e quindici ne danno una meta'
    // scarsa: **si puo' dosare**, che e' cio' che l'ordine chiede.
    final c = ParallaxController();
    leggi(c, 20);
    final quindici = math.sin(15 * math.pi / 180) * 9.8;
    leggi(c, 40, scarto: (i) => quindici);
    final corsa = punti(c.tiltX).abs();
    // ignore: avoid_print
    print('ORDINE AW VOCE 01, M5: quindici gradi danno '
        '${corsa.toStringAsFixed(1)} punti su 80');
    expect(corsa, inInclusiveRange(25.0, 40.0),
        reason: 'a quindici gradi il cielo corre ${corsa.toStringAsFixed(1)} '
            'punti: fuori dalla fascia in cui si puo dosare');
    c.dispose();
  });

  test('M6, il ritardo fra gesto e movimento sta sotto 120 millesimi', () {
    // **IL RITARDO SI CONTA IN MILLESIMI VERI, non in campioni.** Ordine AW
    // voce 01: dal cielo fluido ogni campione porta con se' due fotogrammi, e
    // contare i campioni per il periodo vecchio dava 2.640 millesimi per un
    // gesto che ne dura seicento. Un numero fuori scala che nessuno aveva
    // chiesto di controllare.
    final c = ParallaxController();
    leggi(c, 20);
    final quindici = math.sin(15 * math.pi / 180) * 9.8;
    leggi(c, 60, scarto: (i) => quindici);
    final pieno = c.tiltX.abs();
    c.dispose();

    final d = ParallaxController();
    leggi(d, 20);
    var millesimi = 0;
    for (var i = 0; i < 60; i++) {
      d.leggiDalSensorePerLaProva(quindici, 9.0, 3.8);
      d.avanzaIlFotogrammaPerLaProva(8);
      d.avanzaIlFotogrammaPerLaProva(8);
      millesimi += ParallaxController.periodoDelSensoreInMillesimi;
      if (d.tiltX.abs() >= pieno / 2) break;
    }
    // ignore: avoid_print
    print('ORDINE AW VOCE 01, M6: meta corsa dopo $millesimi millesimi');
    expect(millesimi, lessThan(120),
        reason: 'il cielo arriva in ritardo sul gesto: si sente scollato '
            'dalla mano');
    d.dispose();
  });

  test('la zona morta non e una scorciatoia: fuori di li il cielo risponde',
      () {
    // Una zona morta larghissima passerebbe M1 e M2 e ammazzerebbe l'app. Qui
    // si pretende che appena oltre la soglia il cielo si muova davvero.
    final c = ParallaxController();
    leggi(c, 20);
    // Il doppio della zona morta: un gesto piccolo ma voluto.
    leggi(c, 40, scarto: (i) => ParallaxController.zonaMorta * 2 * 9.8);
    final corsa = punti(c.tiltX).abs();
    // ignore: avoid_print
    print('ORDINE AU VOCE 04: al doppio della zona morta il cielo corre '
        '${corsa.toStringAsFixed(1)} punti su 80');
    expect(corsa, greaterThan(1.0),
        reason: 'oltre la zona morta il cielo resta fermo lo stesso: la '
            'soglia si e mangiata la risposta');
    c.dispose();
  });

  test('con la mano ferma stanno fermi anche i tre Maestri', () {
    // **L'ORDINE CHIEDE DI MISURARLO E NON DI DARLO PER SCONTATO**, e la
    // ragione e' buona: il cielo e i Maestri potrebbero muoversi per due
    // strade diverse. Qui si conta che strada usano. Il Santuario chiama
    // `depth(0.5)` per la figura centrale e `depth(0.28)` per le due laterali,
    // e `depth` non e' altro che `layerOffset`: stesso tilt, stessa cura. Ma
    // la profondita' e' PIU' ALTA di quella del piano di fondo, quindi il
    // tremore li' si vedrebbe di piu', non di meno, e il numero va letto sul
    // loro piano.
    final c = ParallaxController();
    leggi(c, 20);
    var maestroCentrale = 0.0, maestroDiLato = 0.0;
    for (var i = 0; i < 150; i++) {
      c.leggiDalSensorePerLaProva(deviazioneDellaManoFerma * 9.8, 9.0, 3.8);
      final centro = c.layerOffset(0.5).dx.abs();
      final lato = c.layerOffset(0.28).dx.abs();
      if (centro > maestroCentrale) maestroCentrale = centro;
      if (lato > maestroDiLato) maestroDiLato = lato;
    }
    // ignore: avoid_print
    print('ORDINE AU VOCE 04: con la mano ferma il Maestro centrale si sposta '
        'al piu ${maestroCentrale.toStringAsFixed(2)} pixel, quelli di lato '
        '${maestroDiLato.toStringAsFixed(2)}');
    // Un pixel e' sotto la soglia di visibilita' su un ritratto grande: piu'
    // di cosi' e la figura respira quando dovrebbe stare ferma.
    expect(maestroCentrale, lessThan(1.0),
        reason: 'il Maestro centrale trema ancora con la mano ferma');
    expect(maestroDiLato, lessThan(1.0),
        reason: 'i Maestri di lato tremano ancora con la mano ferma');
    c.dispose();
  });

  test('M1 la continuita: nessun grado vale piu di 8 punti sugli 80', () {
    // **LA MISURA CHE MANCAVA, ed e' per questo che il difetto e' passato.**
    // Ordine AV voce 02.
    //
    // Le accettazioni dell'ordine AU voce 04 erano due punti soli: zero al
    // riposo e oltre sessanta a quindici gradi. **Una curva che salta li
    // rispetta tutti e due**, e infatti quella di ieri li rispettava mentre
    // il fondatore vedeva il cielo immobile e poi scattare di lato. Una
    // risposta si giudica sulla sua FORMA, non su due punti.
    //
    // Qui si tabula grado per grado da zero a venticinque e si guarda il
    // salto piu' grande fra un grado e il successivo. **Questa prova resta nel
    // repository per sempre**: e' l'unica che vede uno scatto.
    double aGradi(int gradi) {
      final c = ParallaxController();
      leggi(c, 20);
      final quanto = math.sin(gradi * math.pi / 180) * 9.8;
      leggi(c, 60, scarto: (i) => quanto);
      final punti = c.tiltX.abs() * 80;
      c.dispose();
      return punti;
    }

    // **DA ZERO A TRENTACINQUE GRADI**, ordine AW voce 01 misura M2: il fondo
    // corsa e' passato da sedici a trenta gradi, e una tabella che si ferma a
    // venticinque non guarderebbe piu' il tratto finale della curva.
    final tabella = <int, double>{for (var g = 0; g <= 35; g++) g: aGradi(g)};
    var salto = 0.0;
    var dove = 0;
    for (var g = 1; g <= 35; g++) {
      final d = tabella[g]! - tabella[g - 1]!;
      if (d > salto) {
        salto = d;
        dove = g;
      }
    }
    // ignore: avoid_print
    print('ORDINE AW VOCE 01, M2: punti per grado '
        '${[0, 5, 10, 15, 20, 25, 30, 35].map((g) => "$g:${tabella[g]!.toStringAsFixed(1)}").join("  ")}');
    // ignore: avoid_print
    print('ORDINE AW VOCE 01, M2: salto massimo ${salto.toStringAsFixed(1)} '
        'punti fra ${dove - 1} e $dove gradi');
    expect(salto, lessThanOrEqualTo(8.0),
        reason: 'fra ${dove - 1} e $dove gradi il cielo salta di '
            '${salto.toStringAsFixed(1)} punti sugli 80: e lo scatto che il '
            'fondatore vede. La corsa non si concentra in una fascia stretta');
    // **E LA CORSA PIENA SI RAGGIUNGE DAVVERO**, se no la continuita si
    // otterrebbe spegnendo la risposta, che e' il difetto opposto e altrettanto
    // vero: il cielo che non si muove.
    //
    // **SI GUARDA A TRENTACINQUE GRADI**, ordine AW voce 01: il fondo corsa
    // sta a trenta, ma il riposo insegue mentre si misura e si riprende
    // qualche punto, cosi' il pieno a schermo arriva qualche grado piu' in
    // la'. Chiedere il pieno esattamente al grado del fondo corsa vorrebbe
    // dire ignorare lo zero appreso, che e' la cura dell'ordine AS voce 01 e
    // non si tocca.
    expect(tabella[35]!, greaterThan(70.0),
        reason: 'a trentacinque gradi la corsa non e piena: la continuita non '
            'si compra spegnendo il cielo');
  });
}
