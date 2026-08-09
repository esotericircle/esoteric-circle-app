import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/onboarding/planisfero.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// IL PUNTO DEL LUOGO PULSA, E SI TROVA A COLPO D'OCCHIO.
///
/// Ordine 2169, voce 9. Prima il luogo scelto era una stella ferma con un
/// alone e quattro raggi corti, in mezzo a undicimila punti che pulsano: una
/// cosa in piu' da cercare, non un segnale. Adesso e' un'onda, cerchi
/// concentrici che partono dal punto, si allargano e si spengono.
///
/// **La misura si prende sui PIXEL RESI, non sul codice del pittore.**
/// Guardare che ci sia una `drawCircle` in piu' non dice niente su cosa si
/// vede: qui si dipinge davvero e si legge il profilo radiale attorno al punto
/// del luogo, cioe' quanta luce c'e' a ogni distanza dal centro.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  /// Il planisfero deriva col giroscopio: senza i sensori finti la prova
  /// muore su un plugin assente, che non c'entra niente con cio' che misura.
  void silenzia() {
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

  const lat = 45.07, lon = 7.69; // Torino
  const larghezza = 360.0, altezza = 190.0;

  /// Il punto del luogo in pixel, con la stessa aritmetica del pittore.
  Offset centroDelLuogo() {
    final n = Planisfero.proietta(lat, lon);
    final w = math.min(larghezza, altezza * 2);
    final h = w / 2;
    final origine = Offset((larghezza - w) / 2, (altezza - h) / 2);
    return origine + Offset(n.dx * w, n.dy * h);
  }

  /// Dipinge davvero e torna il profilo radiale attorno al luogo.
  ///
  /// **`runAsync` non e' un dettaglio**: `toImage` aspetta la GPU finta del
  /// banco di prova, e il tempo di una prova widget e' finto. Senza, la
  /// chiamata resta appesa per sempre invece di fallire, e me l'ha gia'
  /// insegnato `alone_dietro_le_figure_test`.
  Future<List<double>> dipingi(WidgetTester tester,
      {required bool riduciMovimento, int fino = 30}) async {
    silenzia();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ParallaxController()),
      ],
      child: MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: riduciMovimento),
          child: Scaffold(
            backgroundColor: const Color(0xFF05040A),
            body: Center(
              child: RepaintBoundary(
                key: const Key('planisfero_reso'),
                child: SizedBox(
                  width: larghezza,
                  height: altezza,
                  child: Planisfero(
                    palette: MaestroPalette.neutral,
                    reduceMotion: riduciMovimento,
                    luogo: (lat: lat, lon: lon),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(const Key('planisfero_reso')));
    final centro = centroDelLuogo();
    late List<double> profilo;
    await tester.runAsync(() async {
      final img = await boundary.toImage(pixelRatio: 1.0);
      final dati = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
      final somme = List<double>.filled(fino + 1, 0);
      final conti = List<int>.filled(fino + 1, 0);
      for (var y = 0; y < img.height; y++) {
        for (var x = 0; x < img.width; x++) {
          final dx = x - centro.dx, dy = y - centro.dy;
          final d = math.sqrt(dx * dx + dy * dy).round();
          if (d > fino) continue;
          final i = (y * img.width + x) * 4;
          final r = dati!.getUint8(i);
          final g = dati.getUint8(i + 1);
          final b = dati.getUint8(i + 2);
          // Luminosita' percepita, che e' quello che l'occhio nota.
          somme[d] += 0.2126 * r + 0.7152 * g + 0.0722 * b;
          conti[d]++;
        }
      }
      profilo = [
        for (var d = 0; d <= fino; d++) conti[d] == 0 ? 0 : somme[d] / conti[d]
      ];
    });
    return profilo;
  }

  /// La valle e il picco che la segue: dove la luce smette di scendere e dove
  /// torna a salire. E' la firma di un anello, e un punto solo non la puo'
  /// avere.
  ({double minimo, int raggioMinimo, double massimo, int raggioMassimo})
      valleEPicco(List<double> profilo) {
    // Si guarda da quattro pixel in poi: prima c'e' il punto stesso.
    var raggioMinimo = 4;
    for (var d = 4; d <= 14; d++) {
      if (profilo[d] < profilo[raggioMinimo]) raggioMinimo = d;
    }
    var raggioMassimo = raggioMinimo;
    for (var d = raggioMinimo; d <= 26; d++) {
      if (profilo[d] > profilo[raggioMassimo]) raggioMassimo = d;
    }
    return (
      minimo: profilo[raggioMinimo],
      raggioMinimo: raggioMinimo,
      massimo: profilo[raggioMassimo],
      raggioMassimo: raggioMassimo,
    );
  }

  testWidgets('attorno al luogo c\'e\' un\'onda, non un punto solo',
      (tester) async {
    final profilo = await dipingi(tester, riduciMovimento: false);

    // Il fondo, misurato lontano dal luogo: e' la mappa a punti, che pulsa
    // anche lei, quindi il richiamo deve staccare da QUESTO, non dal nero.
    final fondo = profilo.sublist(27).reduce((a, b) => a + b) / 4;
    // ignore: avoid_print
    print('ONDA: profilo radiale ${profilo.map((v) => v.toStringAsFixed(0)).join(" ")}');
    // ignore: avoid_print
    print('ONDA: fondo lontano ${fondo.toStringAsFixed(1)}');

    // Il centro e' acceso: il punto del luogo resta.
    expect(profilo[0], greaterThan(fondo * 3),
        reason: 'il punto del luogo non si distingue dalla mappa');

    // **LA GRANDEZZA E' LA RISALITA, non il massimo.**
    //
    // La prima misura guardava il massimo oltre i sei pixel. Col rosso
    // iniettato, cioe' senza nessuna onda disegnata, quel massimo restava
    // 25,4 contro un fondo di 10,5, e la prova NON cadeva: a sette pixel dal
    // centro c'e' ancora la coda del punto e ci sono i punti della mappa,
    // quindi il massimo li' non parla degli anelli.
    //
    // Quello che un punto solo non puo' produrre e' una RISALITA: la luce
    // scende allontanandosi dal centro, e se torna a salire e' perche' a
    // quella distanza c'e' qualcosa. La soglia non e' stata allentata: e'
    // cambiato cio' che si misura.
    final valle = valleEPicco(profilo);
    // ignore: avoid_print
    print('ONDA: la luce scende a ${valle.minimo.toStringAsFixed(1)} al raggio '
        '${valle.raggioMinimo} e RISALE a ${valle.massimo.toStringAsFixed(1)} '
        'al raggio ${valle.raggioMassimo}');
    // **DUE MISURE PRESE DAVVERO, E LA SOGLIA STA IN MEZZO.** Col codice
    // buono il picco degli anelli vale 6,2 volte il fondo della mappa; col
    // difetto iniettato, cioe' senza disegnare nessuna onda, vale 2,1.
    //
    // Ci sono volute tre grandezze per arrivare qui, e le prime due sono
    // scritte perche' nessuno le riprovi: il massimo oltre i sei pixel non
    // separava (li' c'e' ancora la coda del punto), e la sola risalita
    // nemmeno (i punti della mappa risalgono da soli). Non e' la soglia a
    // essere stata allentata: e' cambiato cio' che si misura.
    final richiamo = valle.massimo / fondo;
    // ignore: avoid_print
    print('ONDA: il richiamo vale ${richiamo.toStringAsFixed(1)} volte il '
        'fondo della mappa');
    expect(richiamo, greaterThan(4.0),
        reason: 'il richiamo attorno al luogo vale solo '
            '${richiamo.toStringAsFixed(1)} volte il fondo della mappa: gli '
            'anelli non ci sono, e il luogo torna a essere una cosa da '
            'cercare in mezzo a undicimila punti');
  });

  testWidgets('con Riduci Movimento i cerchi RESTANO, invece di sparire',
      (tester) async {
    // La regola della casa: chi toglie il moto non perde l'informazione.
    final profilo = await dipingi(tester, riduciMovimento: true);
    final fondo = profilo.sublist(27).reduce((a, b) => a + b) / 4;
    final valle = valleEPicco(profilo);
    // ignore: avoid_print
    print('ONDA FERMA: la luce scende a ${valle.minimo.toStringAsFixed(1)} e '
        'risale a ${valle.massimo.toStringAsFixed(1)}, con un fondo di '
        '${fondo.toStringAsFixed(1)}');

    expect(profilo[0], greaterThan(fondo * 3),
        reason: 'con Riduci Movimento sparisce anche il punto del luogo');
    expect(valle.massimo / fondo, greaterThan(4.0),
        reason: 'con Riduci Movimento gli anelli spariscono: chi ha tolto le '
            'animazioni si ritrova il proprio luogo indistinguibile dal '
            'resto della mappa');
  });

  testWidgets('la scena e\' deterministica: due volte lo stesso disegno',
      (tester) async {
    // Nessun caso nel planisfero, nemmeno nell'onda: lo stesso istante deve
    // dare lo stesso quadro, altrimenti un'anteprima non prova niente.
    final a = await dipingi(tester, riduciMovimento: true);
    final b = await dipingi(tester, riduciMovimento: true);
    for (var i = 0; i < a.length; i++) {
      expect(a[i], closeTo(b[i], 0.001),
          reason: 'a $i pixel dal centro due disegni identici danno luce '
              'diversa: c\'e\' del caso dove non deve essercene');
    }
  });
}
