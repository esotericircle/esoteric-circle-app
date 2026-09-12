import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/design_system/components/cosmos_background.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// IL CIELO HA I SUOI LIVELLI. Ordine AM voce 02.
///
/// **La premessa dell'ordine era imprecisa e si dichiara**: il confronto
/// doveva essere con la testa `e5b993f`, "prima delle cure AJ", ma AJ.02
/// (`cdfe0c8`) e' suo ANTENATO e li' le scorte c'erano gia'. Il confronto
/// vero e' col padre di AJ.02, dove i teli erano grandi quanto lo schermo.
///
/// **Cosa si dipinge, enumerato**: polvere sul piano lontano, stelle di
/// campo con costellazioni e aloni sul fondo, nebulose e pianeti sul medio,
/// quattordici particelle vive sul vicino, piu' le stelle cadenti. Nessun
/// pezzo e' sparito rispetto a prima delle cure AJ: quello che era sparito
/// e' la DENSITA' a schermo.
///
/// **La misura che ha nominato il difetto.** Le scorte di AJ.02 hanno
/// allargato i teli e il conto degli elementi e' rimasto quello di prima:
/// su 360x797 il telo del fondo e' 1,95 volte lo schermo e quello del medio
/// 2,73 volte, quindi a schermo restava il 51 per cento delle stelle di
/// campo e il 37 per cento delle nebulose. E' il livello che Mauro vede
/// mancare sulla 2180.
///
/// La cura, per i due casi diversi: le stelle, che nascono a caso, si
/// contano sull'AREA del telo, cosi' coprono anche la scorta e a schermo
/// tornano quante erano; le nebulose e i pianeti, che hanno posizioni curate
/// a mano, restano tre e due e i loro centri mappano la finestra VISIBILE
/// invece di tutto il telo.
void main() {
  // **PERCHE' QUESTA RIGA E' NECESSARIA, E NON E' UN RITO.**
  // Ordine CQ voce 1.10, 3 settembre 2026.
  //
  // **Il fatto:** su quindici esecuzioni identiche questa prova cadeva tre
  // volte, **coi numeri stampati sempre uguali e nessun errore di pretesa**.
  // Non stava fallendo una misura: moriva l'isolato.
  //
  // **La causa.** `ParallaxController` nel suo costruttore fa due cose che
  // vogliono un guscio vivo: si abbona all'accelerometro e accende un
  // `Ticker`. Dentro un `test` nudo non c'e' nessun guscio, il canale del
  // sensore risponde con un errore ASINCRONO, e il ticker resta acceso
  // perche' nessuno chiude il controller. **Chi arriva prima fra l'errore
  // asincrono e la fine della prova decide se il giro e' verde o rosso**, ed
  // e' esattamente la forma di un rosso a intermittenza.
  //
  // **La soglia non si e' toccata**: i rapporti pretesi sono gli stessi di
  // prima. E' cambiato cio' che sta attorno alla misura, che era la cosa
  // rotta.
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  const schermo = Size(360, 797);

  /// I canali del sensore, muti: senza, il primo abbonamento solleva.
  void silenzia() {
    final messaggero = binding.defaultBinaryMessenger;
    messaggero.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (call) async => null);
    for (final nome in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      messaggero.setMockStreamHandler(
          EventChannel(nome), MockStreamHandler.inline(onListen: (a, e) {}));
    }
  }

  test('le stelle si contano sull\'area del telo, non a numero fisso', () {
    final margineFondo = _CosmoPerLaProva.scorta(0.16);
    final teloFondo = Size(
        schermo.width + 2 * margineFondo, schermo.height + 2 * margineFondo);
    final rapporto =
        (teloFondo.width * teloFondo.height) / (schermo.width * schermo.height);
    const base = 140;
    final scalate = quantiSulTelo(base, teloFondo, schermo);
    // ignore: avoid_print
    print('ORDINE AM VOCE 02: telo del fondo ${rapporto.toStringAsFixed(2)} '
        'volte lo schermo, stelle da $base a $scalate');
    expect(rapporto, greaterThan(1.5),
        reason: 'la scorta del fondo e\' sparita: senza di lei il bordo '
            'torna a entrare nell\'inquadratura, ed e\' il difetto di AJ.02');
    // La densita' a schermo e' quella di prima: base per l'area, non base.
    expect(scalate / rapporto, closeTo(base.toDouble(), 1.0),
        reason: 'sul telo grande si dipingono $scalate stelle: a schermo se '
            'ne vedono ${(scalate / rapporto).round()} invece di $base, e '
            'manca il livello di stelle che Mauro ha visto sparire');
    // La porta non inventa niente quando il telo e' lo schermo.
    expect(quantiSulTelo(base, schermo, schermo), base);
  });

  test('i rapporti di corsa fra i piani fanno la profondita\'', () {
    silenzia();
    final parallasse = ParallaxController();
    // **E SI CHIUDE.** Un controller che resta aperto lascia vivi un
    // abbonamento e un ticker per tutta la durata del file di prova.
    addTearDown(parallasse.dispose);
    parallasse.inclinaPerLaProva(1, 0);
    final piani = OffsetDeiPiani.da(parallasse, conDeriva: false, t: 0);
    final corse = {
      'polvere': piani.polvere.dx,
      'fondo': piani.fondo.dx,
      'medio': piani.medio.dx,
      'vicino': piani.vicino.dx,
    };
    // ignore: avoid_print
    print('ORDINE AM VOCE 02: corse a tilt saturo $corse');
    // **TRE PIANI CHE VIAGGIANO INSIEME NON FANNO PROFONDITA'**: fra un
    // piano e il successivo ci vuole uno stacco vero, e questi sono i
    // rapporti che il cosmo ha sempre avuto.
    expect(corse['fondo']! / corse['polvere']!, greaterThan(4),
        reason: 'il fondo e la polvere corrono quasi insieme');
    expect(corse['medio']! / corse['fondo']!, greaterThan(1.25),
        reason: 'il medio e il fondo corrono quasi insieme');
    expect(corse['vicino']! / corse['medio']!, greaterThan(1.5),
        reason: 'il vicino e il medio corrono quasi insieme');
    expect(corse['vicino']! / corse['fondo']!, closeTo(2.07, 0.05),
        reason: 'il rapporto fra il piano piu'
            ' reattivo e quello di fondo '
            'e\' la profondita\' percepita, ed era 2,07');
  });
}

/// La stessa formula della scorta, per non copiarne una seconda.
class _CosmoPerLaProva {
  static double scorta(double depth, {double fattore = 1}) =>
      ParallaxController.tiltRangeDefault *
          ParallaxController.profonditaEfficace(depth) *
          fattore +
      3 * 40 * depth +
      1;
}
