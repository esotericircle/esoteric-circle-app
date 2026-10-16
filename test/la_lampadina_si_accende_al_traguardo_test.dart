import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/sigilli/ancoraggi_dei_sentieri.dart';
import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:esoteric_circle/features/sigilli/journal_dall_arte.dart';
import 'package:esoteric_circle/features/sigilli/regia_del_cammino.dart';
import 'package:esoteric_circle/features/sigilli/sentiero_screen.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LA LAMPADINA SI ACCENDE DAVVERO AL TRAGUARDO. Ordine AF voce 03.
///
/// **Non basta che il disegno sappia accendersi: deve accendersi QUANDO il
/// traguardo matura.** Questa e' una prova di CABLAGGIO, e monta l'app
/// dall'avvio vero, come vuole il Protocollo sui difetti di collegamento: il
/// gesto passa dal registro (`RegiaDelCammino.dopoUnGesto`), la maturazione
/// accende il diario, il Journal legge il diario, e la perla di QUEL sigillo
/// deve brillare SUI PIXEL. Ogni anello provato da solo era gia' verde: e' la
/// catena intera che nessuna prova percorreva, ed e' sulla catena che i difetti
/// di collegamento vivono.
///
/// **Due sentieri, non uno**: il Loto con `aur_1` (la Costellazione del
/// Viso) e la Costellazione con `med_1` (la carta natale), per non provare
/// una porta sola.
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

  Future<void> caricaCaratteri() async {
    for (final f in const [
      ['Cinzel', 'assets/fonts/Cinzel-variable.ttf'],
      ['EBGaramond', 'assets/fonts/EBGaramond-variable.ttf'],
    ]) {
      final loader = FontLoader(f[0]);
      loader.addFont(
          Future.value(ByteData.view(File(f[1]).readAsBytesSync().buffer)));
      await loader.load();
    }
  }

  /// Il cielo anima senza fine, quindi si avanza a passi fissi.
  Future<void> respiro(WidgetTester tester, [int passi = 10]) async {
    for (var i = 0; i < passi; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  Future<void> provaSu(
    WidgetTester tester, {
    required Sentiero sentiero,
    required String gesto,
    required String sigillo,
  }) async {
    silenzia();
    await caricaCaratteri();
    tester.view.physicalSize = const Size(1080, 2391);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues(
        const {'onboarding.done': true, 'santuario.greeted': true});

    // **L'AVVIO VERO**: l'app intera coi suoi servizi offline, non una scena
    // montata a mano coi provider scelti dalla prova.
    await tester.pumpWidget(
        EsotericCircleApp(conIntro: false, services: AppServices.offline()));
    await respiro(tester);

    // **IL DIARIO NASCE PRIMA DEL GESTO**, perche' il provider e' PIGRO: il
    // diario nasce alla prima lettura e il suo `carica()` parte in quel
    // momento.
    //
    // **QUI C'ERA UN AGGIRAMENTO, e adesso non serve piu'. Ordine AO voce
    // 04.** Il commento di prima diceva: "se la prima lettura e' il gesto
    // stesso, il caricamento atterra DURANTE il salvataggio del gesto e
    // ripulisce la mappa portandoselo via. Misurato: e' successo". Quel
    // difetto era vero, ed era la causa dei premi che non arrivavano tutti:
    // era stato aggirato QUI, dentro una prova, invece che curato nel
    // codice. Adesso il diario aspetta di aver letto il disco prima di
    // scrivere, quindi l'ordine e' garantito da lui e non dalla prova; qui
    // basta un respiro perche' il caricamento atterri, e il gesto puo'
    // arrivare quando vuole.
    final contesto = tester.element(find.byType(Navigator).first);
    contesto.read<DiarioDelCammino>();
    await respiro(tester);

    // **IL GESTO PASSA DAL REGISTRO**, che e' il tratto sotto prova: la stessa
    // porta che i riti chiamano quando il gesto e' compiuto davvero.
    await tester.runAsync(() => RegiaDelCammino.dopoUnGesto(contesto, gesto));
    await respiro(tester);

    final diario = contesto.read<DiarioDelCammino>();
    expect(diario.eAcceso(sigillo), isTrue,
        reason: 'il gesto "$gesto" e\' stato registrato ma il traguardo '
            '$sigillo non risulta acceso nel diario: il tratto fra registro e '
            'maturazione e\' scollegato');

    // Una celebrazione puo' essere comparsa: si chiude cio' che si puo'
    // chiudere, con la prosecuzione della festa se c'e'.
    for (var giro = 0; giro < 3; giro++) {
      final prosegui = find.byKey(const Key('celebrazione_prosegui'));
      final chiudi = find.byKey(const Key('celebrazione_chiudi'));
      if (prosegui.evaluate().isNotEmpty) {
        await tester.tap(prosegui.first, warnIfMissed: false);
      } else if (chiudi.evaluate().isNotEmpty) {
        await tester.tap(chiudi.first, warnIfMissed: false);
      } else {
        break;
      }
      await respiro(tester, 5);
    }

    // SI APRE IL JOURNAL di quel sentiero.
    Navigator.of(contesto).push(SentieroScreen.route(sentiero));
    await respiro(tester);

    // LA PERLA DI QUEL SIGILLO, SUI PIXEL. La cattura sta dentro runAsync.
    final tela = tester
        .renderObject<RenderBox>(find.byKey(const Key('sentiero_disegno')));
    final origine = tela.localToGlobal(Offset.zero);
    final confine = tester.renderObject<RenderRepaintBoundary>(
        find.byType(RepaintBoundary).first);
    final immagine =
        await tester.runAsync(() => confine.toImage(pixelRatio: 1.0));
    final px = (await tester.runAsync(
            () => immagine!.toByteData(format: ui.ImageByteFormat.rawRgba)))!
        .buffer
        .asUint8List();
    final larghezzaResa = immagine!.width;

    final ordinati = Sentieri.di(sentiero).toList()
      ..sort((a, b) =>
          Sentieri.ordineNelCammino(a).compareTo(Sentieri.ordineNelCammino(b)));
    final ancoraggi = AncoraggiDeiSentieri.di(sentiero)!;
    final wArte = ArteDelSentiero.larghezzaArte(sentiero).toDouble();
    final hArte = ArteDelSentiero.altezzaArte(sentiero).toDouble();
    final scala = math.min(tela.size.width / wArte, tela.size.height / hArte);
    final dxA = (tela.size.width - wArte * scala) / 2;
    final dyA = (tela.size.height - hArte * scala) / 2;

    double lumeDi(int indice) {
      final centro = origine +
          Offset(dxA + ancoraggi[indice].x * wArte * scala,
              dyA + ancoraggi[indice].y * hArte * scala);
      final valori = <int>[];
      for (var oy = -5; oy <= 5; oy++) {
        for (var ox = -5; ox <= 5; ox++) {
          if (ox * ox + oy * oy > 25) continue;
          final x = (centro.dx + ox).round(), y = (centro.dy + oy).round();
          if (x < 0 || y < 0 || x >= larghezzaResa || y >= immagine.height) {
            continue;
          }
          final k = (y * larghezzaResa + x) * 4;
          valori.add((px[k] * 299 + px[k + 1] * 587 + px[k + 2] * 114) ~/ 1000);
        }
      }
      valori.sort();
      return valori.isEmpty ? 0 : valori[valori.length ~/ 2].toDouble();
    }

    final indiceAcceso = ordinati.indexWhere((t) => t.id == sigillo);
    expect(indiceAcceso, greaterThanOrEqualTo(0));
    final lumeAcceso = lumeDi(indiceAcceso);
    final spenti = <double>[];
    for (var i = 0; i < ancoraggi.length; i++) {
      if (diario.eAcceso(ordinati[i].id)) continue;
      spenti.add(lumeDi(i));
    }
    spenti.sort();
    final lumeSpento = spenti[spenti.length ~/ 2];
    // ignore: avoid_print
    print('ORDINE AF VOCE 03: ${sentiero.name}, $sigillo acceso a '
        '${lumeAcceso.toStringAsFixed(0)}, spenti mediana '
        '${lumeSpento.toStringAsFixed(0)} su ${spenti.length} dischi');
    expect(lumeAcceso, greaterThan(lumeSpento + 40),
        reason: 'il traguardo $sigillo e\' maturato nel diario ma la sua perla '
            'NON brilla sul Journal: acceso ${lumeAcceso.toStringAsFixed(0)} '
            'contro spenti ${lumeSpento.toStringAsFixed(0)}. Il tratto fra '
            'registro e Journal e\' scollegato');
  }

  // **IL GESTO SEGUE IL CORPUS, ordine CP voce 05.** Nella revisione F un
  // solo gradino per sentiero si chiude con un gesto solo, ed e' il primo:
  // sul Loto e' `aur_1`, la Costellazione del Viso letta. Il Soffio adesso ne
  // chiede due in giorni diversi, quindi un soffio solo non accendeva niente
  // e la prova cadeva dicendo che la lampadina non brilla. **La pretesa non
  // cambia**: un gesto registrato deve accendere il suo gradino, e la
  // lampadina deve vedersi sui pixel.
  testWidgets('il viso accende la perla di aur_1 sul Loto', (tester) async {
    await provaSu(tester,
        sentiero: Sentiero.loto, gesto: 'viso', sigillo: 'aur_1');
  });

  // Sulla Costellazione il gradino da un gesto solo e' `med_1`, la carta
  // natale calcolata. Ordine CP voce 05, stessa ragione della riga sopra.
  testWidgets('la carta natale accende l\'orbo di med_1 sulla Costellazione',
      (tester) async {
    await provaSu(tester,
        sentiero: Sentiero.costellazione,
        gesto: 'carta_natale',
        sigillo: 'med_1');
  });
}
