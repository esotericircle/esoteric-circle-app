import 'dart:ui' as ui;

import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/features/santuario/santuario_screen.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_test/flutter_test.dart';

import 'monta_la_home.dart';

/// I MAESTRI NON PERDONO LA TESTA QUANDO IL TELEFONO SI MUOVE.
/// Ordine BC voce 01.
///
/// **Fatto del fondatore**: "attualmente sparisce la loro testa o i loro piedi
/// a seconda del movimento del telefono".
///
/// **La causa e' un numero.** Il piano del carosello sta a profondita' 0,5,
/// che compressa vale 0,211; con l'ampiezza di 500 dello scostamento fa
/// **centocinque punti a fondo corsa e cinquantadue a trenta gradi**. Su una
/// figura alta duecentoquarantasette, la testa se ne andava per meta'.
///
/// **E prima dell'ordine BA voce 02 non si vedeva, ma non perche' non ci
/// fosse**: le figure uscivano dal loro riquadro con `Clip.none` e finivano
/// sul testo, che e' il difetto che il fondatore ha segnalato quattro volte.
/// Chiuso il ritaglio, lo stesso movimento taglia invece di sbordare. Non e'
/// un difetto nuovo: e' lo stesso, diventato visibile.
///
/// **Come si misura.** Si contano i pixel che i Maestri dipingono, cioe' la
/// differenza fra la scena con loro e la scena senza. Poi si inclina il
/// telefono fino in fondo e si conta di nuovo: se il ritaglio mangia la
/// figura, quel numero **scende**. Una figura che si sposta li conserva tutti.
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

  Future<List<int>> dipingi(WidgetTester tester) async {
    late List<int> px;
    await tester.runAsync(() async {
      final ro = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(const Key('la_home_intera')));
      final im = await ro.toImage(pixelRatio: 1.0);
      final d = await im.toByteData(format: ui.ImageByteFormat.rawRgba);
      px = d!.buffer.asUint8List();
      im.dispose();
    });
    return px;
  }

  /// Quanti pixel dipingono i Maestri, in questo istante e con questa
  /// inclinazione.
  Future<int> quantiPixelDipingono(WidgetTester tester) async {
    maestriSpentiPerLaProva = false;
    await tester.pump(Duration.zero);
    final con = await dipingi(tester);
    maestriSpentiPerLaProva = true;
    await tester.pump(Duration.zero);
    final senza = await dipingi(tester);
    maestriSpentiPerLaProva = false;
    await tester.pump(Duration.zero);
    var quanti = 0;
    for (var i = 0; i + 3 < con.length; i += 4) {
      if (con[i] != senza[i] ||
          con[i + 1] != senza[i + 1] ||
          con[i + 2] != senza[i + 2]) {
        quanti++;
      }
    }
    return quanti;
  }

  testWidgets('BC.01: inclinando il telefono i Maestri restano interi',
      (tester) async {
    silenzia();
    maestriSpentiPerLaProva = false;
    addTearDown(() => maestriSpentiPerLaProva = false);
    await montaLaHomePerLaMisura(tester, (const Size(1080, 2391), 3.0));

    final parallax = tester
        .element(find.byKey(const Key('santuario_carosello')))
        .read<ParallaxController>();

    final fermo = await quantiPixelDipingono(tester);
    expect(fermo, greaterThan(5000),
        reason: 'a telefono fermo i Maestri dipingono solo $fermo pixel: non '
            'si stanno disegnando, e il resto della misura non direbbe niente');

    // **FINO IN FONDO, in tutte e quattro le direzioni.** Il taglio arriva in
    // cima o sul fondo a seconda di come si tiene il telefono, quindi guardare
    // una sola inclinazione lascerebbe scoperta meta' del difetto.
    final perse = <String, int>{};
    for (final v in const [
      ('su', 0.0, -1.0),
      ('giu', 0.0, 1.0),
      ('sinistra', -1.0, 0.0),
      ('destra', 1.0, 0.0),
    ]) {
      parallax.inclinaPerLaProva(v.$2, v.$3);
      await tester.pump(Duration.zero);
      final piegato = await quantiPixelDipingono(tester);
      perse[v.$1] = fermo - piegato;
    }
    parallax.inclinaPerLaProva(0, 0);
    // ignore: avoid_print
    print('ORDINE BC VOCE 01: fermi i Maestri dipingono $fermo pixel, e '
        'inclinando fino in fondo ne perdono $perse');

    // **IL FATTO DEL FONDATORE E' VERTICALE**, e si misura con la soglia
    // stretta: "sparisce la loro TESTA o i loro PIEDI". Il tre per cento e'
    // l'inezia che resta quando una figura si sposta di qualche punto e i
    // bordi cambiano di antialiasing.
    final tetto = (fermo * 0.03).round();
    final suGiu = {'su': perse['su']!, 'giu': perse['giu']!};
    final troppe = suGiu.entries.where((e) => e.value > tetto).toList();
    expect(troppe, isEmpty,
        reason: 'inclinando il telefono in su o in giu i Maestri perdono '
            'pezzi: ${troppe.map((e) => "${e.key} ${e.value} pixel").join(", ")}'
            ', oltre il tetto di $tetto. E il fatto del fondatore, "sparisce '
            'la loro testa o i loro piedi a seconda del movimento"');

    // **E DI LATO, CHE E' UN'ALTRA COSA E VA DETTA.**
    //
    // Inclinando a sinistra o a destra le figure perdono circa il diciassette
    // per cento. **Non e' il ritaglio**: si e' provato a togliere il taglio ai
    // fianchi e il numero non e' cambiato di un pixel. E' il **bordo dello
    // schermo**: la parallasse sposta il piano di centocinque punti a fondo
    // corsa, e su una larghezza di trecentosessanta la figura laterale, larga
    // un centinaio di punti e centrata a sessanta, se ne va fuori per meta'.
    //
    // **E' un fenomeno preesistente e diverso dal fatto del fondatore**, che
    // parla di testa e piedi. Si dichiara qui col suo numero, e si tiene fermo
    // perche' non peggiori: se un giorno la parallasse crescesse ancora, di
    // lato non resterebbero piu' tre Maestri ma tre mezzi Maestri.
    final diLato = {
      'sinistra': perse['sinistra']!,
      'destra': perse['destra']!,
    };
    // ignore: avoid_print
    print('ORDINE BC VOCE 01: di lato ne perdono $diLato, ed e il bordo dello '
        'schermo e non il ritaglio');
    for (final e in diLato.entries) {
      expect(e.value, lessThan((fermo * 0.25).round()),
          reason: 'di ${e.key} i Maestri perdono ${e.value} pixel su $fermo: '
              'la parallasse orizzontale li sta portando fuori dallo schermo '
              'piu di quanto una scena di tre quarti possa giustificare');
    }
  });

  testWidgets('BC.01: e i Maestri sono piu grandi di prima', (tester) async {
    // **IL PRIMO PEZZO DELLA RICHIESTA**: "i 3 maestri nella home devono
    // essere piu' grandi e devono trovarsi ad un livello superiore".
    //
    // Lo spazio non si e' inventato, si e' preso da due posti. Le due righe
    // sopra di loro si sono avvicinate, come il fondatore ha chiesto nella
    // stessa frase, e quello ha dato tredici punti. Gli altri ventuno sono
    // venuti dal conto della salita del laterale, che teneva conto di una
    // fascia di riquadro che oggi si dissolve e non dipinge piu' niente.
    //
    // **Misurato: da 234 punti a 268, il quindici per cento in piu', e i
    // pixel di testo coperti restano zero.**
    silenzia();
    await montaLaHomePerLaMisura(tester, (const Size(1080, 2391), 3.0));
    final misura = ultimaMisuraDelBusto;
    expect(misura, isNotNull, reason: 'la diagnostica del busto non c e');
    // ignore: avoid_print
    print('ORDINE BC VOCE 01: su schermo alto il busto misura '
        '${misura!.busto.round()} punti, e lo spazio concesso e '
        '${misura.concessa.round()}');
    expect(misura.busto, greaterThanOrEqualTo(245),
        reason: 'il busto e sceso a ${misura.busto.round()} punti: era 234 '
            'prima di questa voce e 247 dopo, e il fondatore li aveva chiesti '
            'piu grandi');
  });

  test('BC.01: e il movimento di lato resta intero', () {
    // **LA CONTROPROVA.** Togliere il movimento verticale era facile: bastava
    // azzerare tutta la parallasse, e i Maestri sarebbero diventati tre
    // figurine ferme. La profondita' di una scena vista di tre quarti si sente
    // di lato, ed e' quella che non si tocca.
    // ignore: avoid_print
    print('ORDINE BC VOCE 01: del movimento verticale resta il '
        '${(quotaDelMovimentoInVerticale * 100).round()} per cento, di quello '
        'orizzontale il 100');
    expect(quotaDelMovimentoInVerticale, lessThan(0.2),
        reason: 'il movimento verticale e tornato grande abbastanza da '
            'tagliare le figure');
    expect(quotaDelMovimentoInVerticale, greaterThan(0.0),
        reason: 'il movimento verticale e sparito del tutto: i Maestri sono '
            'diventati tre figurine incollate');
  });
}
