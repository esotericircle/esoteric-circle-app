import 'dart:io';

import 'package:esoteric_circle/core/astro/sky_location.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/santuario/sky_overview_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// IL CIELO DICE DA DOVE E' CALCOLATO.
///
/// Ordine 2168, voce 4. Sotto il cielo compare il luogo da cui e' stato
/// calcolato: la citta' e le coordinate, quando quel luogo e' la posizione
/// del dispositivo.
///
/// **IL RIPIEGO L'HA DECISO MAURO, ed e' la parte che queste prove
/// sorvegliano piu' da vicino.** Se il nome della citta' non arriva, il nome
/// SPARISCE e restano le sole coordinate: nessun "luogo sconosciuto", nessun
/// trattino, niente al posto suo. Una riga che dichiara di non sapere occupa
/// lo spazio di una riga che dice qualcosa.
///
/// Nessuna prova qui tocca la rete: la geocodifica vive dietro `SkyLocation`
/// e le finte rispondono a memoria.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

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

  Future<void> monta(WidgetTester tester, SkyLocation posizione,
      {SkyPlace? iniziale}) async {
    silenzia();
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    // La schermata del cielo pretende i suoi quattro compagni: senza di loro
    // non arriva nemmeno a costruirsi, e la riga sembrerebbe assente per un
    // motivo che non c'entra niente con quello che si vuole misurare.
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: MaestroScope(child: child!),
        ),
        home: SkyOverviewScreen(
          now: DateTime(2026, 8, 8, 22, 0),
          location: posizione,
          luogoIniziale: iniziale,
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump(const Duration(seconds: 2));
  }

  /// Il testo della riga "da dove", oppure nullo se la riga non c'e'.
  String? rigaDaDove(WidgetTester tester) {
    final f = find.byKey(const Key('sky_da_dove'));
    if (f.evaluate().isEmpty) return null;
    return tester.widget<Text>(f).data;
  }

  testWidgets('con la citta\' e le coordinate, la riga le dice tutte e due',
      (tester) async {
    await monta(
      tester,
      _PosizioneFinta(citta: 'Torino'),
      iniziale:
          const SkyPlace(latitude: 45.0703, longitude: 7.6869, citta: 'Torino'),
    );
    final riga = rigaDaDove(tester);
    expect(riga, isNotNull, reason: 'Il cielo non dice da dove e\' calcolato.');
    expect(riga, contains('Torino'));
    expect(riga, contains('45.07'),
        reason: 'Le coordinate devono restare: sono il dato vero da cui il '
            'cielo si orienta.');
    expect(riga, contains('7.68'));
  });

  testWidgets(
      'SENZA citta\' restano le sole coordinate, e nessun testo al '
      'posto del nome', (tester) async {
    await monta(
      tester,
      _PosizioneFinta(citta: null),
      iniziale: const SkyPlace(latitude: 45.0703, longitude: 7.6869),
    );
    final riga = rigaDaDove(tester);
    expect(riga, isNotNull,
        reason: 'Senza citta\' la riga deve restare: le coordinate ci sono.');
    expect(riga, contains('45.07'));
    // **QUESTA E' LA PROVA DEL RIPIEGO DI MAURO.** Il nome sparisce e non
    // lascia niente dietro di se': nessuna di queste parole deve comparire.
    for (final tappabuchi in const [
      'sconosciut',
      'non disponibile',
      'ignoto',
      '—',
      '--',
      'n.d.',
    ]) {
      expect(riga!.toLowerCase().contains(tappabuchi.toLowerCase()), isFalse,
          reason: 'Al posto del nome del luogo compare "$tappabuchi": il '
              'ripiego deciso da Mauro e\' che il nome SPARISCA, non che '
              'venga sostituito da una scritta che dice di non sapere.');
    }
  });

  testWidgets('senza posizione la riga non compare affatto', (tester) async {
    await monta(tester, const DisabledSkyLocation());
    expect(rigaDaDove(tester), isNull,
        reason: 'Senza posizione non c\'e\' nessun "da dove" da dichiarare: '
            'una riga vuota sarebbe un segnaposto.');
  });

  test('la geocodifica vive in UN punto solo, dietro l\'astrazione', () {
    // Se domani qualcuno chiamasse `placemarkFromCoordinates` da una
    // schermata, la promessa fatta alla persona smetterebbe di essere
    // verificabile in un posto solo.
    final colpe = <String>[];
    for (final f in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      final percorso = f.path.replaceAll('\\', '/');
      if (percorso.endsWith('core/astro/sky_location.dart')) continue;
      final testo = f.readAsStringSync();
      if (testo.contains('placemarkFromCoordinates') ||
          testo.contains("package:geocoding/")) {
        colpe.add(percorso);
      }
    }
    expect(colpe, isEmpty,
        reason: 'La geocodifica e\' chiamata fuori da SkyLocation: $colpe');
  });

  test('la promessa fatta alla persona dice il vero', () {
    // **NESSUNA COSTANTE CHE DICHIARA IL FALSO.** Da quando il nome del
    // luogo passa dai servizi di sistema, "la posizione resta sul
    // dispositivo" e' una promessa che l'app non mantiene piu'. Questa prova
    // la cerca dove la persona la legge: nel pre-avviso, nel testo del
    // permesso e nella chiave di iOS.
    final punti = {
      'il pre-avviso del cielo':
          File('lib/features/santuario/sky_overview_screen.dart')
              .readAsStringSync(),
      'il testo del permesso':
          File('lib/core/permissions/app_permission.dart').readAsStringSync(),
      'la chiave di iOS': File('ios/Runner/Info.plist').readAsStringSync(),
    };
    final colpe = <String>[];
    punti.forEach((dove, testo) {
      // Si guarda la promessa NELLA FORMA IN CUI LA PERSONA LA LEGGE, cioe'
      // riferita alla posizione: la stessa frase sulla FOTO resta vera.
      final righe = testo.split('\n');
      for (final r in righe) {
        final nuda = r.trim();
        if (nuda.startsWith('//')) continue;
        final parlaDiPosizione = nuda.contains('posizione') ||
            nuda.contains('coordinate') ||
            nuda.contains('dove ti trovi');
        if (!parlaDiPosizione) continue;
        if (nuda.contains('resta sul dispositivo') ||
            nuda.contains('Resta sul dispositivo')) {
          colpe.add('$dove: promette che la posizione resta sul dispositivo, '
              'ma il nome del luogo viene chiesto ai servizi di sistema.');
        }
      }
    });
    expect(colpe, isEmpty, reason: colpe.join('\n'));
  });
}

/// Una posizione che risponde a memoria: nessuna rete, nessun permesso.
class _PosizioneFinta extends SkyLocation {
  _PosizioneFinta({required this.citta});

  final String? citta;

  @override
  bool get available => true;

  @override
  Future<SkyPlace?> resolve() async =>
      const SkyPlace(latitude: 45.0703, longitude: 7.6869);

  @override
  Future<SkyPlace?> resolveSeConcesso() async => resolve();

  @override
  Future<String?> nomeDelLuogo(double lat, double lon) async => citta;
}
