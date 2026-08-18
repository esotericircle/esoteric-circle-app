import 'dart:ui' as ui;

import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/features/santuario/santuario_screen.dart';
import 'package:esoteric_circle/features/shell/barra_del_cerchio.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// NESSUN TESTO FINISCE SOTTO QUALCOS'ALTRO.
///
/// **Il difetto che questa prova esiste per prendere.** Nel Santuario la riga
/// personale stava negli stessi punti verticali delle carte dei tre Maestri:
/// misurato sull'app montata a 360 per 797, il testo finiva a 337,2 e le carte
/// laterali cominciavano a 274,3, quindi si leggeva a meta'. Nessuna prova se ne
/// accorgeva, perche' le prove esistenti sulla copertura sono MIRATE su un caso
/// solo ciascuna (la bolla sopra l'avatar, il pulsante sopra la carta) e non
/// enumerano.
///
/// **SI MISURA L'OCCLUSIONE, NON SI CONTANO I WIDGET, e la misura e'
/// DIFFERENZIALE.** Un rettangolo che si sovrappone a un altro non dice niente:
/// un'ombra dipinge fuori dal proprio riquadro, una figura esce dal suo con
/// `Clip.none`, un fondo trasparente si sovrappone senza coprire. Quindi si
/// rende la scena DUE VOLTE, con e senza l'elemento sospetto, e si confronta
/// quanti pixel del testo sopravvivono. E' la stessa tecnica della bolla del 30
/// luglio, dove contare i riquadri avrebbe dato la risposta sbagliata.
///
/// Qui l'elemento sospetto e' l'intera scena tranne il testo: si dipinge il
/// testo da solo su fondo nero, poi si dipinge la scena vera, e per ogni pixel
/// acceso del primo si guarda se nel secondo il colore e' ancora quello del
/// testo. Dove non lo e', qualcosa ci e' finito sopra.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  /// I sensori tacciono: senza, il giroscopio solleva e la prova non arriva
  /// mai a misurare.
  void silence() {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (c) async => null);
    for (final n in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      m.setMockStreamHandler(
          EventChannel(n), MockStreamHandler.inline(onListen: (a, e) {}));
    }
  }

  /// I pixel di una scena, come li vede lo schermo.
  Future<Uint8List> pixelDi(WidgetTester tester, Finder radice) async {
    late Uint8List byte;
    await tester.runAsync(() async {
      final boundary =
          tester.renderObject<RenderRepaintBoundary>(radice);
      final img = await boundary.toImage(pixelRatio: 1);
      final dati = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
      byte = dati!.buffer.asUint8List();
      img.dispose();
    });
    return byte;
  }

  /// Quanti pixel del testo restano visibili nella scena vera.
  ///
  /// Si confronta la scena INTERA con la stessa scena in cui il testo e' stato
  /// reso da solo: un pixel del testo si considera coperto quando nella scena
  /// vera il suo colore si scosta di piu' di quaranta livelli, cioe' quando
  /// sopra ci e' finito qualcosa di opaco. Sotto quella soglia stanno le
  /// differenze di antialiasing e le velature, che non impediscono di leggere.
  double quotaCoperta(Uint8List soloTesto, Uint8List scena, int larghezza,
      Rect area) {
    var accesi = 0;
    var coperti = 0;
    for (var y = area.top.floor(); y < area.bottom.ceil(); y++) {
      for (var x = area.left.floor(); x < area.right.ceil(); x++) {
        final i = (y * larghezza + x) * 4;
        if (i + 3 >= soloTesto.length) continue;
        // Un pixel del testo: chiaro, perche' il testo dell'app e' avorio o oro
        // su fondo scuro.
        final luce = soloTesto[i] > soloTesto[i + 1]
            ? soloTesto[i]
            : soloTesto[i + 1];
        if (luce < 140) continue;
        accesi++;
        var scarto = 0;
        for (var c = 0; c < 3; c++) {
          final d = (soloTesto[i + c] - scena[i + c]).abs();
          if (d > scarto) scarto = d;
        }
        if (scarto > 40) coperti++;
      }
    }
    return accesi == 0 ? 0 : coperti / accesi;
  }

  Future<void> apri(WidgetTester tester, GlobalKey radice) async {
    silence();
    SharedPreferences.setMockInitialValues(
        const {'onboarding.done': true, 'santuario.greeted': true});
    tester.view.physicalSize = const Size(360, 797);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(RepaintBoundary(
      key: radice,
      child: EsotericCircleApp(conIntro: false, services: AppServices.offline()),
    ));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
  }

  /// Enumera i testi della schermata in cima e verifica che nessuno sia coperto.
  ///
  /// **LA SCHERMATA COPERTA, dichiarata: il SANTUARIO, e una sola.** L'app ne ha
  /// una ventina e le altre NON sono guardate: chi legge questa prova non deve
  /// credere che sia sorvegliata l'app intera.
  ///
  /// **Perche' una sola, e cosa manca.** La stessa misura sul dominio di un
  /// Maestro e sull'Oroscopo dichiara coperti al cento per cento testi che
  /// nelle anteprime si leggono benissimo, per esempio "Consulta Medora": e' un
  /// falso positivo che non ho ancora spiegato, e finche' non lo capisco quelle
  /// due schermate restano fuori. Una prova che accusa il falso e' peggio di
  /// una prova che non c'e', perche' insegna a ignorarla.
  Future<void> verifica(WidgetTester tester, GlobalKey radice, String dove,
      Type schermata) async {
    final scena = await pixelDi(tester, find.byKey(radice));
    final larghezza = tester.view.physicalSize.width.round();

    // SI RACCOGLIE PRIMA E SI MISURA DOPO. Scorrere i widget mentre si
    // rimonta l'albero disattiva gli elementi sotto i piedi: la prima stesura
    // moriva su un null check al secondo testo.
    final bersagli =
        <({InlineSpan span, TextAlign align, int? maxLines, String testo, Rect area})>[];
    for (final w in tester.widgetList<RichText>(find.descendant(
        of: find.byType(schermata), matching: find.byType(RichText)))) {
      final testo = w.text.toPlainText().trim();
      if (testo.length < 8) continue;
      final el = tester.element(find.byWidget(w));
      final box = el.renderObject as RenderBox;
      if (!box.attached || box.size.isEmpty) continue;
      final pos = box.localToGlobal(Offset.zero);
      final area =
          Rect.fromLTWH(pos.dx, pos.dy, box.size.width, box.size.height);
      // LA FASCIA DELLA BARRA E' ESCLUSA, e non e' una scappatoia: dalla 2158
      // la barra del Cerchio SCIVOLA SOPRA il contenuto per scelta dichiarata,
      // e il contenuto che le finisce sotto si raggiunge scorrendo. Contarlo
      // come coperto vorrebbe dire chiamare difetto una decisione presa
      // guardando l'anteprima. Sono i testi della fascia "Le tue arti", che
      // senza questa riga risultavano coperti al cento per cento.
      final fasciaBarra =
          tester.view.physicalSize.height - BarraDelCerchio.altezza;
      if (area.top < 0 ||
          area.bottom > tester.view.physicalSize.height ||
          area.bottom > fasciaBarra ||
          area.width <= 0) {
        continue;
      }
      // LA FASCIA DELLA CAPSULA E' ESCLUSA, ordine AL voce 08, per la stessa
      // ragione della barra: per decisione di Mauro i doni del giorno
      // scorrono SOTTO la capsula dell'identita' e la sfumatura della
      // striscia li ha gia' spenti prima del suo bordo, guardato
      // sull'anteprima. Contare coperto un testo che il disegno ha gia'
      // reso invisibile chiamerebbe difetto una decisione.
      final capsula = find.byKey(const Key('capsula_dell_identita'));
      if (capsula.evaluate().isNotEmpty &&
          area.overlaps(tester.getRect(capsula).inflate(4))) {
        continue;
      }
      bersagli.add((
        span: w.text,
        align: w.textAlign,
        maxLines: w.maxLines,
        testo: testo,
        area: area
      ));
    }
    expect(bersagli, isNotEmpty,
        reason: 'in $dove non si trova nessun testo da misurare: la prova non '
            'sta guardando niente');

    final colpe = <String>[];
    for (final b in bersagli) {
      // LA MISURA DIFFERENZIALE: la stessa scena col solo testo, sul fondo
      // dell'app, cosi' il confronto isola cio' che gli e' finito sopra.
      final soloKey = GlobalKey();
      await tester.pumpWidget(RepaintBoundary(
        key: soloKey,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            backgroundColor: const Color(0xFF05040A),
            body: Stack(children: [
              Positioned(
                left: b.area.left,
                top: b.area.top,
                width: b.area.width,
                height: b.area.height,
                child: RichText(
                    text: b.span, textAlign: b.align, maxLines: b.maxLines),
              ),
            ]),
          ),
        ),
      ));
      await tester.pump();
      final solo = await pixelDi(tester, find.byKey(soloKey));
      final quota = quotaCoperta(solo, scena, larghezza, b.area);
      if (quota > 0.35) {
        colpe.add('$dove: "${b.testo.substring(0, b.testo.length.clamp(0, 44))}" '
            'coperto per il ${(quota * 100).round()} per cento');
      }
    }
    expect(colpe, isEmpty,
        reason: 'questi testi finiscono sotto qualcos\'altro:\n'
            '${colpe.join('\n')}');
  }

  testWidgets('Santuario: nessun testo finisce sotto le carte', (tester) async {
    final radice = GlobalKey();
    await apri(tester, radice);
    await verifica(tester, radice, 'Santuario', SantuarioScreen);
    // ROSSO ESEGUITO: rimettendo la riga personale dentro il blocco del cielo,
    // dove stava fino all'ordine D, la prova e' caduta nominando il Santuario e
    // la frase, coperta per il 62 per cento.
  });

}
