import 'dart:io';

import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/aura/face/face_constellation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'codice_senza_testo.dart';

/// **LA COSTELLAZIONE DEL VISO SI CAPISCE GUARDANDO, E PARTE SU IPHONE.**
/// Ordine DS voce 06, 17 settembre 2026.
///
/// **Il fatto piu' grave dell'ordine**: sui telefoni dei fondatori, che sono
/// tutti iPhone, il volto non si rilevava. **La causa era nel codice, ed erano
/// tre difetti in fila.** La fotocamera chiedeva i fotogrammi in NV21, che su
/// iOS non esiste e ricade in BGRA; il motore passava quei byte BGRA al
/// lettore NV21; e anche coi byte giusti la rotazione era quella del sensore,
/// mentre su iOS il plugin consegna il fotogramma gia' girato come il
/// dispositivo e gia' specchiato per la frontale, quindi il volto arrivava
/// al modello di lato e specchiato due volte.
///
/// **Cosa si prova qui e cosa no.** MediaPipe non gira sul banco: la prova
/// che il volto si rileva su un iPhone la da' un iPhone. Qui si prova tutto
/// cio' che al banco si puo' provare, cioe' che la catena **sceglie** il
/// formato, la rotazione e lo specchio giusti per la piattaforma, e che la
/// scelta arriva davvero fino al modello e alla maschera.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  final schermo = codiceSenzaTesto(
      File('lib/features/maestri/aura/face/face_constellation_screen.dart')
          .readAsStringSync());
  final motore = codiceSenzaTesto(
      File('lib/core/face/motore_mediapipe.dart').readAsStringSync());

  group('LA CATENA DEL FOTOGRAMMA', () {
    test(
        'il formato della fotocamera viene dalla piattaforma, non e\' NV21 '
        'per tutti', () {
      expect(
          schermo.contains('imageFormatGroup: ImageFormatGroup.nv21'), isFalse,
          reason: 'la fotocamera chiede NV21 a ogni telefono: su iOS NV21 non '
              'esiste, il plugin consegna BGRA e il modello legge byte che non '
              'sono quelli che crede');
      expect(schermo.contains('ImageFormatGroup.bgra8888'), isTrue,
          reason: 'nessuna strada chiede BGRA, che e il formato di iOS');
    });

    test('il motore legge il BGRA come BGRA', () {
      expect(motore.contains('FaceMeshPixelFormat.bgra'), isTrue,
          reason: 'il motore non costruisce mai un fotogramma BGRA');
      expect(RegExp(r'\.process\(').hasMatch(motore), isTrue,
          reason: 'il motore non chiama mai process, che e la porta del '
              'pacchetto per i fotogrammi BGRA');
      expect(motore.contains('processNv21('), isTrue,
          reason: 'la strada di Android e sparita: su Android deve restare '
              'identica');
    });

    test(
        'la rotazione data al modello e quella data alla maschera sono la '
        'stessa, e non sono il sensore nudo', () {
      expect(
          schermo.contains('rotazione: _camera!.description.sensorOrientation'),
          isFalse,
          reason: 'al modello arriva ancora la rotazione del sensore per ogni '
              'piattaforma: su iOS il fotogramma e gia girato, e il volto '
              'arriva di lato');
      expect(
          RegExp(r'giroDispari\s*=\s*\(\s*_camera!\.description\.sensorOrientation')
              .hasMatch(schermo),
          isFalse,
          reason: 'la maschera scambia i lati col sensore mentre il modello '
              'gira con un altro valore: i punti non cadrebbero sul volto');
    });
  });

  group('LA SOGLIA SI CAPISCE GUARDANDO', () {
    Widget host() => MultiProvider(
          providers: [
            ChangeNotifierProvider(
                create: (_) => MaestroController(
                    initial: const ThemeKey.of(Maestro.aura))),
            ChangeNotifierProvider(create: (_) => QualityTierController()),
            ChangeNotifierProvider(create: (_) => EntitlementService()),
            ChangeNotifierProvider(create: (_) => ParallaxController()),
            ChangeNotifierProvider(create: (_) => ZodiacController()),
          ],
          child: MaterialApp(
            theme: AppTheme.dark(),
            home: const MaestroScope(child: FaceConstellationScreen()),
          ),
        );

    Future<void> passo(WidgetTester tester) async {
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 120));
      }
    }

    Future<void> monta(WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(host());
      await passo(tester);
    }

    testWidgets(
        'il riquadro della riservatezza e la bolla del cielo non ci '
        'sono piu', (tester) async {
      await monta(tester);
      expect(find.byKey(const Key('face_privacy')), findsNothing,
          reason: 'il riquadro della riservatezza e tornato');
      expect(find.byKey(const Key('face_sky_setting')), findsNothing,
          reason: 'la bolla "Lega al cielo di oggi" e tornata');
      expect(
          find.textContaining('Tutto resta sul tuo dispositivo'), findsNothing);
      expect(find.text('Lega al cielo di oggi'), findsNothing);
      // **La garanzia resta, il testo se ne va.** Il comando che lega il
      // responso ai transiti vive ancora nel responso, dove si legge.
      expect(
          File('lib/features/maestri/aura/face/face_constellation_screen.dart')
              .readAsStringSync()
              .contains("Key('face_transits_switch')"),
          isTrue,
          reason: 'e sparito anche l interruttore dei transiti nel responso: '
              'togliere la bolla della soglia non doveva togliere il cielo '
              'a chi lo vuole');
    });

    testWidgets(
        'l\'immagine di apertura esiste ed e\' la prima cosa della '
        'schermata', (tester) async {
      await monta(tester);
      final immagine = find.byKey(const Key('face_immagine_apertura'));
      expect(immagine, findsOneWidget,
          reason: 'la soglia non ha nessuna immagine che faccia capire la '
              'funzione senza leggere');
      final alto = tester.getRect(immagine).top;
      // Nessun testo della soglia sta sopra l'immagine.
      final testi = find.descendant(
          of: find.byType(FaceConstellationScreen),
          matching: find.byType(RichText));
      final sopra = <String>[];
      for (final e in testi.evaluate()) {
        final r = tester.getRect(find.byWidget(e.widget));
        final dentroLaBarra = r.bottom <= kToolbarHeight + 1;
        if (!dentroLaBarra && r.top < alto) {
          sopra.add((e.widget as RichText).text.toPlainText());
        }
      }
      expect(sopra, isEmpty,
          reason: 'sopra l immagine di apertura c e del testo: $sopra');
      // E' grande: almeno meta' della larghezza dello schermo.
      expect(tester.getSize(immagine).width, greaterThanOrEqualTo(390 / 2));
      expect(tester.getSize(immagine).height, greaterThanOrEqualTo(200));
    });

    testWidgets(
        'l\'istruzione dei movimenti e\' piu grande di prima: 16 '
        'punti prima, almeno 22 adesso', (tester) async {
      await monta(tester);
      const primaDellOrdine = 16.0;
      final riga = find.byKey(const Key('face_didascalia_piena'));
      expect(riga, findsOneWidget);
      final misura = tester.widget<Text>(riga).style!.fontSize!;
      expect(misura, greaterThanOrEqualTo(22),
          reason: 'l istruzione delle quattro pose misura $misura punti, '
              'prima dell ordine DS ne misurava $primaDellOrdine');
      // E sta PRIMA del pulsante che la fa compiere, non dopo.
      expect(tester.getRect(riga).top,
          lessThan(tester.getRect(find.byKey(const Key('face_start'))).top),
          reason: 'l istruzione dei movimenti sta sotto il pulsante: si legge '
              'dopo aver gia deciso');
    });

    testWidgets(
        'durante la scansione c\'e\' un ovale centrato, e la guida '
        'e\' grande', (tester) async {
      await monta(tester);
      await tester.ensureVisible(find.byKey(const Key('face_start')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('face_start')));
      await passo(tester);
      final ovale = find.byKey(const Key('face_ovale'));
      expect(ovale, findsOneWidget,
          reason: 'durante la scansione niente aiuta a mettere il viso nel '
              'punto giusto');
      final cornice = find.byKey(const Key('face_inquadratura'));
      expect(cornice, findsOneWidget);
      final c1 = tester.getCenter(ovale);
      final c2 = tester.getCenter(cornice);
      expect((c1 - c2).distance, lessThan(1.0),
          reason: 'l ovale non e centrato sull inquadratura: $c1 contro $c2');
      final guida = tester.widget<Text>(find.byKey(const Key('face_guide')));
      expect(guida.style!.fontSize!, greaterThanOrEqualTo(22),
          reason: 'la guida delle pose misura ${guida.style!.fontSize} '
              'punti, prima dell ordine DS ne misurava 16');
    });
  });
}
