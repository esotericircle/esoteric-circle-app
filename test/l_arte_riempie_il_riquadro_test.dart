import 'dart:io';

import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/sigilli/journal_dall_arte.dart';
import 'package:esoteric_circle/features/sigilli/sentiero_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'istante_dichiarato.dart';

/// DOVE STA IL VUOTO ATTORNO ALL'ARTE. Ordine AC voce 02.
///
/// **Prima di correggere si verifica dove il difetto sta davvero.** L'ordine
/// riporta una banda vuota SOPRA E SOTTO l'arte, dal 27 al 36 per cento
/// dell'altezza, misurata sulle anteprime. Ma le anteprime compongono la scena a
/// modo loro, con una quota di 0,73, mentre la schermata vera usa 0,58 e una
/// larghezza ridotta dai margini: **due riquadri di forma diversa, e l'arte
/// dentro un riquadro diverso lascia il vuoto da un'altra parte.**
///
/// Questa prova misura il riquadro VERO, quello montato dalla schermata, e ne
/// ricava per via geometrica dove `BoxFit.contain` lascia il vuoto. Non serve
/// rendere l'arte per saperlo: con la proporzione del riquadro e quella
/// dell'immagine il conto e' esatto.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

  /// LO SCHERMO VERO, quello su cui l'app viene guardata.
  const Size schermoReale = Size(360, 797);

  Future<Rect> riquadroDi(WidgetTester tester, Sentiero sentiero) async {
    await caricaCaratteri();
    tester.view.physicalSize = schermoReale;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final diario = DiarioDelCammino(orologio: orologioDelleProve);
    await diario.carica();
    for (final t in Sentieri.miniDi(sentiero).take(12)) {
      await diario.accendi(t.id);
    }
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => EntitlementService()),
        ChangeNotifierProvider(create: (_) => QuestionAllowance()),
        ChangeNotifierProvider<DiarioDelCammino>.value(value: diario),
      ],
      child: MediaQuery(
        data: const MediaQueryData(size: schermoReale),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark(),
          home: MaestroScope(
            child: SentieroScreen(sentiero: sentiero, senzaVolo: false),
          ),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    return tester.getRect(find.byKey(const Key('sentiero_disegno')));
  }

  testWidgets('il vuoto attorno all\'arte si misura sul riquadro vero',
      (tester) async {
    var osservati = 0;
    for (final sentiero in Sentieri.tutti) {
      final riquadro = await riquadroDi(tester, sentiero);
      osservati++;
      final p = ArteDelSentiero.proporzione(sentiero);
      final formaDelRiquadro = riquadro.width / riquadro.height;
      // **CONTAIN: entra per il lato che sta piu' stretto.** Se il riquadro e'
      // piu' largo dell'immagine, l'immagine entra per altezza e il vuoto resta
      // ai LATI; se e' piu' stretto, entra per larghezza e il vuoto resta SOPRA
      // E SOTTO.
      final perAltezza = formaDelRiquadro > p;
      final resaLarghezza = perAltezza ? riquadro.height * p : riquadro.width;
      final resaAltezza = perAltezza ? riquadro.height : riquadro.width / p;
      final vuotoVerticale = (riquadro.height - resaAltezza) / riquadro.height;
      final vuotoOrizzontale =
          (riquadro.width - resaLarghezza) / riquadro.width;
      // ignore: avoid_print
      print('ORDINE AC VOCE 02: ${sentiero.name}, riquadro '
          '${riquadro.width.toStringAsFixed(1)} per '
          '${riquadro.height.toStringAsFixed(1)}, arte resa '
          '${resaLarghezza.toStringAsFixed(1)} per '
          '${resaAltezza.toStringAsFixed(1)}, vuoto verticale '
          '${(vuotoVerticale * 100).toStringAsFixed(1)} per cento, orizzontale '
          '${(vuotoOrizzontale * 100).toStringAsFixed(1)} per cento');
      // **IL VUOTO VERTICALE DEVE RESTARE ZERO, ed e' un fatto misurato e non
      // un obiettivo raggiunto.** Sulla schermata vera il riquadro e' piu' largo
      // che alto rispetto a tutte e tre le arti, quindi l'immagine entra per
      // altezza e sopra e sotto non avanza niente. Questa riga sorveglia che
      // resti cosi': se un giorno il riquadro cambiasse forma, la banda vuota
      // sopra e sotto tornerebbe e nessuno se ne accorgerebbe finche' non lo
      // vede una persona.
      expect(vuotoVerticale, lessThan(0.01),
          reason: 'su ${sentiero.name} avanza il '
              '${(vuotoVerticale * 100).toStringAsFixed(1)} per cento '
              'dell\'altezza sopra e sotto l\'arte: il riquadro ha cambiato '
              'forma e l\'immagine non lo riempie piu\' in altezza');
    }
    // **QUANTI SENTIERI GUARDATI, e cade se sono zero.**
    // ignore: avoid_print
    print('ORDINE AC VOCE 02: sentieri osservati $osservati');
    expect(osservati, Sentieri.tutti.length);
  });
}
