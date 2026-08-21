import 'dart:ui' as ui;

import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/santuario/greeting_controller.dart';
import 'package:esoteric_circle/features/santuario/santuario_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// La bolla del dominio non copre la figura del Maestro.
///
/// **Le quattro strade sbagliate, per non riprovarle.** La correzione era stata
/// dichiarata chiusa e misurata su cinque altezze mentre sul telefono la bolla
/// mordeva ancora, perche' il test guardava il RIQUADRO del widget e la figura
/// sborda dal proprio con `Clip.none`. Poi:
///
/// 1. Cercare pixel dipinti dalla riga della bolla trova il suo bordo oro.
/// 2. Sei pixel sopra si trova l'OMBRA del pulsante, che dipinge fuori dal
///    proprio rettangolo. Il segnale che ha smascherato il tentativo: la
///    distanza restava identica anche spostando il carosello di cento pixel.
/// 3. Sessanta pixel sopra si salta l'ombra e anche la zona del contatto.
/// 4. Fotografare la striscia fra carta e bolla ha lo stesso buco, perche'
///    l'ombra contamina anche la striscia.
///
/// 5. Il differenziale a DUE rese, con e senza bolla, confrontato dentro il
///    rettangolo della carta: verde col difetto dentro, perche' la figura sborda
///    fuori da quel rettangolo e l'occlusione avviene dove non si guardava.
///
/// **La misura che funziona ha TRE rese.** Si guarda la zona che la bolla
/// occupa e si chiede: senza la bolla, li' c'e' la figura? Lo si scopre
/// confrontando la resa senza bolla con quella senza bolla NE trio. Se
/// differiscono, la figura arriva fin dentro quella zona, quindi la bolla la
/// copre. Non serve riconoscere cosa sia un pixel, e il metodo regge con le
/// ombre perche' ogni elemento c'e' in una resa e manca nell'altra.
///
/// L'ingombro resta in tutte le rese, con `Visibility` che mantiene la misura:
/// togliere un elemento dal layout farebbe muovere gli altri, e le immagini
/// differirebbero per intero invece che per la sola occlusione.
///
/// **DUE CONDIZIONI SENZA LE QUALI OGNI MISURA E' CIECA.** Ci sono volute sei
/// prove per trovarle, e sono la parte utile di questo file.
///
/// La prima: l'avatar va PRECARICATO. Senza `precacheImage` non c'e' nessuna
/// figura da coprire, quindi qualunque misura di occlusione risulta verde per
/// forza. Non erano le misure a sbagliare, era la scena a essere vuota.
///
/// La seconda, che e' quella decisiva: serve il TESTO DI SISTEMA INGRANDITO. Con
/// il testo a scala uno la bolla non raggiunge la figura nemmeno col margine
/// difettoso, quindi il difetto non si riproduce e ogni test passa. A scala 1,6
/// il difetto compare, perche' `entryZone` si MISURA a runtime: col testo grande
/// la zona d'ingresso cresce, sale, e va a mordere la figura. E' la condizione
/// del telefono di Mauro, e spiega perche' cinque misure in fila davano verde
/// mentre lui vedeva il difetto.
///
/// Da qui in avanti la scala 1,6 e' parte della prova, non un dettaglio.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

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

  /// Rende il Santuario e restituisce l'immagine piu' i rettangoli che servono.
  ///
  /// Si monta la sola schermata e non l'app intera: cosi' l'onboarding non entra
  /// in scena e non serve rincorrere i tempi di pump.
  Future<({ui.Image img, Rect carta, Rect bolla, Rect arti, Rect striscia})>
      rendi(WidgetTester tester,
          {required double altezzaFisica,
          required bool disegnaIngresso,
          double larghezzaFisica = 1170,
          bool disegnaTrio = true}) async {
    silence();
    SharedPreferences.setMockInitialValues({});
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = Size(larghezzaFisica, altezzaFisica);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final radice = GlobalKey();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => GreetingController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (ctx, child) => MediaQuery(
          // Fermo: una parallasse che respira farebbe differire le due rese per
          // conto proprio, e la differenza non sarebbe piu' l'occlusione.
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true, textScaler: const TextScaler.linear(1.6)),
          child: MaestroScope(child: child!),
        ),
        home: RepaintBoundary(
          key: radice,
          child: SantuarioScreen(
            clock: () => DateTime(2026, 7, 30, 21),
            disegnaIngresso: disegnaIngresso,
            disegnaTrio: disegnaTrio,
          ),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // L'AVATAR VA PRECARICATO, altrimenti non c'e' nessuna figura da coprire e
    // qualunque misura di occlusione risulta verde. E' il motivo per cui cinque
    // tentativi di misura in fila sono nati ciechi: non era la misura a
    // sbagliare, era la scena a essere vuota. Le anteprime mostrano gli avatar
    // proprio perche' li precaricano.
    await tester.runAsync(() async {
      final elemento = tester.element(find.byType(MaterialApp));
      for (final m in Maestro.values) {
        await precacheImage(AssetImage(m.avatarAsset), elemento);
      }
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final carta =
        tester.getRect(find.byKey(const Key('santuario_central_bust')));
    final bolla =
        tester.getRect(find.byKey(const Key('santuario_enter_domain')));
    final arti = tester.getRect(find.byKey(const Key('santuario_domain_arts')));
    final striscia =
        tester.getRect(find.byKey(const Key('santuario_daily_strip')));

    late ui.Image img;
    await tester.runAsync(() async {
      final rb =
          radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      img = await rb.toImage(pixelRatio: 3.0);
    });
    return (
      img: img,
      carta: carta,
      bolla: bolla,
      arti: arti,
      striscia: striscia
    );
  }

  /// Quanti pixel differiscono fra due immagini, dentro un rettangolo.
  Future<int> pixelDiversi(ui.Image a, ui.Image b, Rect zona) async {
    final da = (await a.toByteData())!;
    final db = (await b.toByteData())!;
    final w = a.width;
    var diversi = 0;
    final y0 = (zona.top * 3).round().clamp(0, a.height - 1);
    final y1 = (zona.bottom * 3).round().clamp(0, a.height - 1);
    final x0 = (zona.left * 3).round().clamp(0, w - 1);
    final x1 = (zona.right * 3).round().clamp(0, w - 1);
    for (var y = y0; y < y1; y++) {
      for (var x = x0; x < x1; x++) {
        final i = (y * w + x) * 4;
        // Una differenza di pochi livelli e' rumore di antialias: si conta solo
        // cio' che l'occhio vedrebbe.
        if ((da.getUint8(i) - db.getUint8(i)).abs() > 6 ||
            (da.getUint8(i + 1) - db.getUint8(i + 1)).abs() > 6 ||
            (da.getUint8(i + 2) - db.getUint8(i + 2)).abs() > 6) {
          diversi++;
        }
      }
    }
    return diversi;
  }

  // LA MISURA REALE VIENE PRIMA: 1080 per 2392 fisici, cioe' 360 per 797
  // logici. E' quella su cui l'app viene guardata, quindi e' quella su cui si
  // giudica. Le altre due restano come controprova.
  for (final (larghezza, altezza) in const [
    (1080.0, 2392.0),
    (1170.0, 2532.0),
    (1080.0, 2532.0),
  ]) {
    testWidgets('A ${larghezza.round()} per ${altezza.round()} la bolla non copre la figura', (tester) async {
      // TRE rese. Confrontare "con bolla" e "senza bolla" dentro il rettangolo
      // della carta non basta, ed e' stato provato: la figura sborda FUORI da
      // quel rettangolo, quindi l'occlusione avviene dove il confronto non
      // guarda, e il test restava verde anche col difetto dentro.
      //
      // Qui si guarda la ZONA DELLA BOLLA e si chiede: senza la bolla, li' c'e'
      // la figura? Lo si scopre confrontando la resa senza bolla con quella
      // senza bolla ne trio. Se differiscono, la figura arriva fin li', quindi
      // la bolla la sta coprendo.
      final senzaBolla =
          await rendi(tester,
              altezzaFisica: altezza,
              larghezzaFisica: larghezza,
              disegnaIngresso: false);
      final zona = senzaBolla.bolla;
      final nuda = await rendi(tester,
          altezzaFisica: altezza,
          larghezzaFisica: larghezza,
          disegnaIngresso: false,
          disegnaTrio: false);

      expect(nuda.bolla, zona,
          reason: 'il layout e cambiato fra le due rese: il confronto non '
              'misurerebbe l occlusione');

      late int figuraNellaZona;
      await tester.runAsync(() async {
        figuraNellaZona = await pixelDiversi(senzaBolla.img, nuda.img, zona);
        senzaBolla.img.dispose();
        nuda.img.dispose();
      });

      expect(figuraNellaZona, 0,
          reason: 'a ${larghezza.round()} per ${altezza.round()} la figura del Maestro dipinge $figuraNellaZona '
              'pixel dentro la zona che la bolla occupa, quindi la bolla la '
              'copre. Misura differenziale a tre rese.');
    });

    testWidgets('A ${larghezza.round()} per ${altezza.round()} la bolla sta sotto la carta con otto punti d\'aria',
        (tester) async {
      final r =
          await rendi(tester,
              altezzaFisica: altezza,
              larghezzaFisica: larghezza,
              disegnaIngresso: true);
      await tester.runAsync(() async => r.img.dispose());

      final distanza = r.bolla.top - r.carta.bottom;
      expect(distanza, greaterThanOrEqualTo(8),
          reason: 'a ${larghezza.round()} per ${altezza.round()} fra il fondo della carta e la cima della bolla ci '
              'sono ${distanza.toStringAsFixed(1)} punti, meno degli otto '
              'richiesti');
      // **LE ARTI STANNO SOPRA LA BOLLA, ordine AS voce 11.** Questa riga
      // pretendeva il contrario, ed era giusta finche' le tre arti erano un
      // sottotitolo del pulsante. Adesso sono la prima cosa che si legge dopo
      // il nome del Maestro, perche' chi arriva cerca un'arte e non conosce i
      // Maestri: la pretesa si rovescia insieme alla gerarchia, e continua a
      // sorvegliare che le due cose non si accavallino.
      expect(r.bolla.top, greaterThanOrEqualTo(r.arti.bottom),
          reason: 'le tre arti sono tornate sotto la bolla, oppure la bolla '
              'le si e sovrapposta');
    });

    testWidgets('A ${larghezza.round()} per ${altezza.round()} il trio non finisce sotto la striscia dei Doni',
        (tester) async {
      final r =
          await rendi(tester,
              altezzaFisica: altezza,
              larghezzaFisica: larghezza,
              disegnaIngresso: true);
      await tester.runAsync(() async => r.img.dispose());

      expect(r.carta.top, greaterThanOrEqualTo(r.striscia.bottom),
          reason: 'la carta centrale risale sotto la striscia dei Doni: il trio '
              'e\' salito troppo');
    });
  }
}
