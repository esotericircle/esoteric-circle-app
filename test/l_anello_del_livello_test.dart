import 'dart:ui' as ui;

import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:esoteric_circle/features/shell/anello_del_livello.dart';
import 'package:esoteric_circle/features/shell/barra_dell_identita.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'istante_dichiarato.dart';

/// L'ANELLO DEL LIVELLO SI VEDE E SI RIEMPIE. Ordine CF voce 01.
///
/// **Cosa pretende questa guardia, e perche' queste grandezze.** L'ordine
/// chiede una prova che misuri l'altezza vera della barra e la grandezza vera
/// a cui l'anello viene dipinto, e che cada se l'anello non e' distinguibile
/// fra vuoto e pieno.
///
/// **Le tre grandezze sono misurate, non dichiarate.** L'altezza si legge dal
/// riquadro reso, non dalla costante; il diametro si legge dal riquadro
/// dell'anello reso; e il riempimento si conta sui PIXEL DIPINTI, catturando
/// l'anello due volte, a Cammino spento e a Cammino acceso. **Contare i pixel
/// e non guardare la frazione e' il punto**: un anello con la frazione giusta
/// e il tratto trasparente passerebbe qualunque prova che legga il numero, e
/// sul telefono non si vedrebbe niente.
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
      m.setMockStreamHandler(EventChannel(nome),
          MockStreamHandler.inline(onListen: (a, e) {}));
    }
  }

  testWidgets('la barra e\' alta quanto dichiara, e ci sta l\'anello',
      (tester) async {
    silenzia();
    SharedPreferences.setMockInitialValues(const {
      'onboarding.done': true,
      'santuario.greeted': true,
    });
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(360, 797);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
        EsotericCircleApp(conIntro: false, services: AppServices.offline()));
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    final barra = find.byKey(const Key('barra_dell_identita'));
    expect(barra, findsOneWidget,
        reason: 'la barra sottile non c\'e\' in home');
    final altaDavvero = tester.getRect(barra).height;
    final anello = find.byKey(const Key('anello_del_livello'));
    expect(anello, findsOneWidget,
        reason: 'l\'anello del livello non e\' montato nella barra');
    final diametro = tester.getSize(anello);
    // ignore: avoid_print
    print('ORDINE CF VOCE 01: barra alta $altaDavvero (dichiarata '
        '${BarraDellIdentita.altezzaChiusa} piu\' l\'area di sistema), '
        'anello $diametro');
    expect(altaDavvero, BarraDellIdentita.altezzaChiusa,
        reason: 'la barra resa non e\' alta quanto la costante che le '
            'schermate usano per farle spazio: una testata finisce coperta');
    // **SI PRETENDE IL TONDO, non che ci stia dentro.** La prima stesura
    // chiedeva soltanto che l'anello fosse alto non piu' della barra, e con
    // la barra rimessa a trenta punti restava VERDE: la riga lo schiacciava
    // a ventinove e la prova era contenta, mentre a video l'anello diventava
    // un'ellisse tagliata sopra e sotto. La grandezza misurata e' cambiata,
    // non la soglia.
    expect(diametro.width, AnelloDelLivello.diametroPer(22),
        reason: 'l\'anello non e\' dipinto alla grandezza che dichiara');
    expect(diametro.height, AnelloDelLivello.diametroPer(22),
        reason: 'l\'anello e\' stato schiacciato a ${diametro.height} punti '
            'invece dei ${AnelloDelLivello.diametroPer(22)} che dichiara: la '
            'barra che lo contiene e\' alta $altaDavvero e non gli lascia '
            'posto, quindi a video e\' un\'ellisse tagliata');
    expect(find.byKey(const Key('barra_numero_del_livello')), findsOneWidget,
        reason: 'accanto al volto manca il numero del livello');
  });

  /// Quanti pixel accesi dipinge l'anello con quei traguardi accesi.
  Future<int> pixelAccesi(WidgetTester tester, List<String> accesi) async {
    SharedPreferences.setMockInitialValues({
      'cammino.accesi': accesi,
      'cammino.generazione': 2,
    });
    final diario = DiarioDelCammino(orologio: orologioDelleProve);
    await diario.carica();
    await diario.pronto;
    final chiave = GlobalKey();
    await tester.pumpWidget(ChangeNotifierProvider<DiarioDelCammino>.value(
      value: diario,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: RepaintBoundary(
            key: chiave,
            child: const AnelloDelLivello(
              misuraDelVolto: 22,
              child: SizedBox(width: 22, height: 22),
            ),
          ),
        ),
      ),
    ));
    await tester.pump();
    var quanti = 0;
    await tester.runAsync(() async {
      final ro =
          chiave.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final immagine = await ro.toImage(pixelRatio: 3);
      final dati =
          await immagine.toByteData(format: ui.ImageByteFormat.rawRgba);
      final b = dati!.buffer.asUint8List();
      for (var i = 3; i < b.length; i += 4) {
        if (b[i] > 128) quanti++;
      }
    });
    return quanti;
  }

  testWidgets('l\'anello vuoto e l\'anello pieno non si somigliano',
      (tester) async {
    final vuoto = await pixelAccesi(tester, const []);
    final pieno = await pixelAccesi(
        tester, [for (final t in Sentieri.raggiungibili) t.id]);
    // ignore: avoid_print
    print('ORDINE CF VOCE 01: pixel accesi dell\'anello, vuoto $vuoto, pieno '
        '$pieno, su ${Sentieri.raggiungibili.length} traguardi raggiungibili '
        'dei ${Sentieri.tuttiITraguardi.length} scritti');
    expect(pieno, greaterThan(vuoto * 4 + 100),
        reason: 'fra l\'anello vuoto e l\'anello pieno si vedono $vuoto e '
            '$pieno pixel accesi: la differenza non si vede a occhio, e un '
            'anello che non cambia non rappresenta niente');
  });

  test(
      'il progresso ha una porta sola, e il denominatore non promette '
      'l\'irraggiungibile', () {
    // **DUE CONTEGGI DELLA STESSA COSA sono la famiglia di difetti piu'
    // numerosa del progetto, e il fondatore lo ha scritto nell'ordine.**
    final dormienti = Sentieri.tuttiITraguardi.where((t) => t.dormiente).length;
    // ignore: avoid_print
    print('ORDINE CF VOCE 01: traguardi scritti '
        '${Sentieri.tuttiITraguardi.length}, dormienti $dormienti, '
        'raggiungibili ${Sentieri.raggiungibili.length}');
    expect(Sentieri.raggiungibili.length,
        Sentieri.tuttiITraguardi.length - dormienti,
        reason: 'il raggiungibile non e\' il totale meno i dormienti');
    expect(dormienti, greaterThan(0),
        reason: 'se non ci fossero dormienti questa distinzione sarebbe '
            'inutile, e allora l\'anello potrebbe tornare a contare i 165');
  });
}
