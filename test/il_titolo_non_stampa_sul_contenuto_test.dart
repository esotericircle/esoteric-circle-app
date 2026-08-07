import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/features/maestri/ask/ask_maestri_screen.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_screen.dart';
import 'package:esoteric_circle/features/maestri/domain_screen.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LA SCRITTA ESPLORA RESTA LEGGIBILE SU CIO' CHE LE PASSA SOTTO.
///
/// **LA GRANDEZZA MISURATA E' CAMBIATA, E VA DETTO PERCHE'.** Fino all'ordine
/// 2163 questa prova era differenziale a pixel: nel rettangolo del titolo NON
/// doveva cambiare niente mentre il contenuto scorreva dietro, e teneva ferma
/// una fascia opaca dietro la scritta. Con l'ordine 2164 voce 1 Mauro ha
/// deciso che la barra torna TRASPARENTE: da adesso dietro il titolo il
/// contenuto si vede e si muove, quindi i pixel CAMBIANO per costruzione e
/// quella misura direbbe sempre di no. Non si allenta la soglia, si cambia
/// cio' che si misura: adesso si misura il CONTRASTO delle lettere contro il
/// fondo peggiore che passa dietro di loro, che e' la cosa che davvero conta
/// per chi legge.
///
/// Il metodo: dentro il rettangolo del titolo si separano i pixel chiari
/// (le lettere dorate) da quelli del fondo, e si confronta la luminanza
/// mediana delle lettere col fondo PIU' CHIARO che si trova li' dietro, cioe'
/// il caso peggiore. Il rapporto e' quello delle WCAG.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  /// La soglia dichiarata: il minimo WCAG per il testo piccolo. Il titolo e'
  /// una nota di servizio, ma resta testo, e sotto questo numero non e'
  /// leggibile su cio' che gli passa dietro.
  const contrastoMinimo = 4.5;

  void silenzia() {
    final messenger = binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
      (call) async => null,
    );
    for (final nome in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      messenger.setMockStreamHandler(
        EventChannel(nome),
        MockStreamHandler.inline(onListen: (args, events) {}),
      );
    }
  }

  Future<Uint8List> pixelDi(WidgetTester tester, GlobalKey radice) async {
    final rb =
        radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final img = await rb.toImage(pixelRatio: 1.0);
    final dati = (await img.toByteData(format: ui.ImageByteFormat.rawRgba))!;
    final byte = dati.buffer.asUint8List();
    img.dispose();
    return byte;
  }

  /// La luminanza relativa delle WCAG, da un pixel RGB.
  double luminanza(int r, int g, int b) {
    double canale(int v) {
      final c = v / 255.0;
      return c <= 0.03928 ? c / 12.92 : _pow((c + 0.055) / 1.055, 2.4);
    }

    return 0.2126 * canale(r) + 0.7152 * canale(g) + 0.0722 * canale(b);
  }

  double contrastoFra(double l1, double l2) {
    final chiaro = l1 > l2 ? l1 : l2;
    final scuro = l1 > l2 ? l2 : l1;
    return (chiaro + 0.05) / (scuro + 0.05);
  }

  // **IL ROSSO, E COSA HA INSEGNATO.** Tolta la sola OMBRA, questa prova
  // resta verde nelle quattro schermate di oggi (il Consiglio scendeva da
  // 5,34 a 5,25): li' a tenere il contrasto e' la sfumatura del piede. Il
  // rosso vero e' stato eseguito togliendo TUTTA la protezione, cioe'
  // portando la sfumatura ad alpha zero e l'ombra a lista vuota: il
  // Consiglio e' sceso a 3,88 e la prova e' caduta nominando il danno.
  // L'ombra resta perche' e' la difesa LOCALE, quella che serve quando
  // dietro il titolo passa una scheda chiara piu' su della sfumatura, e la
  // sua esistenza la sorveglia la prova sul sorgente qui sotto.
  testWidgets('nelle quattro schermate il titolo si legge su cio\' che gli '
      'passa dietro', (tester) async {
    silenzia();
    SharedPreferences.setMockInitialValues({'onboarding.done': true});
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final servizi = AppServices.offline();
    final radice = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(
      key: radice,
      child: EsotericCircleApp(conIntro: false, services: servizi),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    final nav = tester.state<NavigatorState>(find.byType(Navigator).last);

    final colpe = <String>[];

    Future<double> misuraQui() async {
      final titolo =
          tester.getRect(find.byKey(const Key('barra_titolo')).first);
      final zona = titolo.inflate(2);
      final byte = (await tester.runAsync(() => pixelDi(tester, radice)))!;
      final larghezza = tester.view.physicalSize.width.round();

      // La griglia delle luminanze del rettangolo, che serve a distinguere
      // il fondo VICINO alle lettere da quello lontano.
      final x0 = zona.left.ceil();
      final y0 = zona.top.ceil();
      final larghezzaZona = zona.right.floor() - x0;
      final altezzaZona = zona.bottom.floor() - y0;
      if (larghezzaZona < 8 || altezzaZona < 4) {
        // Un rettangolo vuoto non si misura: torna il peggior voto
        // possibile, e la colpa la scrive chi ha chiesto la misura.
        return 0.0;
      }
      final griglia = <List<double>>[];
      final luci = <double>[];
      for (var y = 0; y < altezzaZona; y++) {
        final riga = <double>[];
        for (var x = 0; x < larghezzaZona; x++) {
          final i = ((y0 + y) * larghezza + (x0 + x)) * 4;
          final l = luminanza(byte[i], byte[i + 1], byte[i + 2]);
          riga.add(l);
          luci.add(l);
        }
        griglia.add(riga);
      }
      final ordinate = [...luci]..sort();
      // LE LETTERE sono i pixel piu' chiari (oro su fondale scuro).
      final lettereChiare =
          ordinate.sublist((ordinate.length * 0.90).floor());
      final lettera = lettereChiare[lettereChiare.length ~/ 2];

      // **IL FONDO E' IL PEGGIORE DENTRO IL RETTANGOLO DEL TITOLO, e una
      // seconda stesura e' stata scartata.** Avevo provato a guardare solo
      // il fondo ENTRO CINQUE PUNTI dalle lettere, pensando che il pixel
      // chiaro in un angolo non disturbasse la lettura: quella misura
      // rispondeva 2,0 ovunque, anche dove a video si legge benissimo,
      // perche' raccoglieva l'antialiasing delle lettere stesse, cioe' i
      // loro bordi sfumati, e li chiamava fondo. Una misura che guarda la
      // cosa sbagliata e' come una misura che non c'e'. Resta questa: tutto
      // cio' che sta dentro il rettangolo del titolo gli passa dietro, e il
      // punto peggiore decide.
      // Si scarta il sesto piu' chiaro e non solo il decimo: fra la soglia
      // delle lettere e il fondo vero ci sono i BORDI SFUMATI delle lettere,
      // che sono lettera anche loro. Contandoli come fondo la misura
      // rispondeva 2,0 ovunque, anche dove a video si legge benissimo.
      final fondoPeggiore = ordinate[(ordinate.length * 0.84).floor()];
      return contrastoFra(lettera, fondoPeggiore);
    }

    Future<void> misura(String dove) async {
      // **IL PUNTO DI MISURA E' DETERMINISTICO, e va detto perche'.** La
      // prima stesura scorreva di settanta punti e misurava subito: nel
      // Consiglio, dove le schede si SCRIVONO una lettera per volta, la
      // quantita' di testo chiaro sotto il titolo cambiava da corsa a
      // corsa, e la stessa prova ha misurato 5,34 e poi 2,42 senza che il
      // codice cambiasse. Una misura che non si ripete non e' una misura.
      // Adesso si aspetta che la scrittura finisca e si va a FONDO CORSA,
      // che e' un punto solo e sempre lo stesso.
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 500));
      }
      // **SI CERCA IL PUNTO PEGGIORE, non uno qualsiasi, e la grandezza e'
      // cambiata due volte.** A fondo corsa la misura era stabile ma NON
      // mordeva: dietro il titolo non capitava niente di chiaro e il rosso
      // (protezione tolta) restava verde. Adesso si guardano cinque quote
      // FISSE dello scorrimento e si tiene la peggiore: fisse, quindi la
      // misura si ripete; cinque, quindi il contenuto chiaro che passa
      // dietro il titolo viene trovato dove c'e'.
      final scorrevole = find.byWidgetPredicate(
          (w) => w is Scrollable && w.axisDirection == AxisDirection.down);
      final quote = <double>[0.0, 0.25, 0.5, 0.75, 1.0];
      var peggiore = double.infinity;
      for (final q in quote) {
        if (scorrevole.evaluate().isNotEmpty) {
          final posizione =
              tester.state<ScrollableState>(scorrevole.first).position;
          // Senza dito: un drag ritirerebbe la barra seguendolo (regola
          // della 2158) e sposterebbe il titolo stesso.
          posizione.jumpTo(posizione.maxScrollExtent * q);
          await tester.pump(Duration.zero);
        }
        final c = await misuraQui();
        if (c < peggiore) peggiore = c;
        if (scorrevole.evaluate().isEmpty) break;
      }
      // ignore: avoid_print
      print('TITOLO $dove: contrasto peggiore fra le cinque quote = '
          '${peggiore.toStringAsFixed(2)} (minimo $contrastoMinimo)');
      if (peggiore < contrastoMinimo) {
        colpe.add('$dove: il titolo si legge a '
            '${peggiore.toStringAsFixed(2)} di contrasto contro cio\' che '
            'gli passa dietro, sotto il $contrastoMinimo che serve');
      }
    }

    await misura('home');

    nav.push(DomainScreen.route(maestro: Maestro.caligo, services: servizi));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await misura('dominio');

    nav.push(
        MaestroChatScreen.route(maestro: Maestro.medora, services: servizi));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await misura('chat');

    nav.push(AskMaestriScreen.perLaSintesi(
      starter: Maestro.caligo,
      tema: 'una scelta',
      lenti: [
        MaestroLens.strati(
            maestro: Maestro.medora,
            glance: 'stelle',
            reading: 'il cielo tiene aperta la domanda',
            invite: 'guarda'),
        MaestroLens.strati(
            maestro: Maestro.aura,
            glance: 'respiro',
            reading: 'il corpo conosce il suo passo',
            invite: 'ascolta'),
      ],
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    await misura('consiglio');

    expect(colpe, isEmpty, reason: colpe.join('\n'));
  });

  test('la barra NON ha piu\' un fondo pieno, e l\'ombra del titolo esiste',
      () {
    // ORDINE 2164 VOCE 1, la regola scritta dove vive: il sorgente della
    // barra non deve piu' comporre un fondale opaco con alphaBlend, e il
    // titolo deve prendere la sua ombra. E' l'unica prova che vede la
    // DECISIONE e non solo il suo effetto: senza di lei, qualcuno potrebbe
    // rimettere la fascia e cercare di far tornare i conti altrove.
    final sorgente =
        File('lib/features/shell/santuario_bottom_bar.dart').readAsStringSync();
    expect(sorgente.contains('ombraDelTitolo'), isTrue,
        reason: 'L\'ombra del titolo non esiste piu\': senza fascia e senza '
            'ombra il titolo resta nudo sopra il contenuto.');
    expect(sorgente.contains('Color.alphaBlend'), isFalse,
        reason: 'La barra ha di nuovo un fondo composto opaco: Mauro l\'ha '
            'voluta trasparente con l\'ordine 2164 voce 1.');
  });
}

double _pow(double x, double e) => math.pow(x, e).toDouble();
