import 'package:esoteric_circle/core/astro/night_sky.dart';
import 'package:esoteric_circle/design_system/components/zodiac_figures.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/rituals/daily_rituals.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/rituals/dream_rite_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// IL SIGILLO DEL SOGNO NOMINA UN MAESTRO SOLO. Ordine CW, voce 02.
///
/// **Il fatto.** Negli screenshot del fondatore il responso apre con una frase
/// in blu attribuita a Medora, e subito sotto il pulsante dice "parlane con
/// Caligo".
///
/// **MISURATO PRIMA DI CORREGGERE, e delle due ipotesi dell'ordine e' vera la
/// prima: la rotazione esiste davvero.** Il testo e la firma venivano da
/// `DailyRituals.nightMaestro`, che ruota sui tre Maestri per giorno
/// dell'anno; il pulsante veniva da `Maestro.caligo`, **una costante scritta a
/// mano**. Due sorgenti per lo stesso fatto, e una era un valore fisso: **due
/// giorni su tre** il saluto portava la voce di un Maestro e il pulsante ne
/// nominava un altro.
///
/// **DALL'ORDINE DT VOCE 15 IL SIGILLO E' DI MEDORA, e non ruota piu'.** La
/// pretesa della voce CW.02 resta intera, un Maestro solo fra testo e
/// pulsante; cambia quale: sempre Medora.
///
/// **Cio' che si misura qui non e' un giorno, sono tre.** Si prendono tre date
/// che la vecchia rotazione del giorno assegnava a tre Maestri diversi: se la
/// rotazione tornasse nel Sigillo, almeno due di quei giorni nominerebbero un
/// altro Maestro.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silenzio() {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
      (call) async => null,
    );
    for (final n in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      m.setMockStreamHandler(
          EventChannel(n), MockStreamHandler.inline(onListen: (a, e) {}));
    }
    for (final n in const [
      'xyz.luan/audioplayers',
      'xyz.luan/audioplayers.global'
    ]) {
      m.setMockMethodCallHandler(MethodChannel(n), (c) async => null);
    }
  }

  /// Tre date che la rotazione del giorno assegna a tre Maestri diversi,
  /// trovate contando e non scelte a occhio.
  Map<Maestro, DateTime> treGiorniTreMaestri() {
    final trovati = <Maestro, DateTime>{};
    for (var g = 0; g < 12; g++) {
      final data = DateTime(2026, 9, 1 + g, 22);
      trovati.putIfAbsent(DailyRituals.dawnMaestro(data), () => data);
      if (trovati.length == Maestro.values.length) break;
    }
    return trovati;
  }

  test('le tre date danno davvero tre Maestri di turno', () {
    expect(treGiorniTreMaestri().length, Maestro.values.length);
  });

  for (final voce in {'medora', 'aura', 'caligo'}) {
    testWidgets('Nel giorno di turno di $voce il Sigillo nomina Medora e basta',
        (tester) async {
      silenzio();
      final tre = treGiorniTreMaestri();
      final diTurno = Maestro.values.firstWhere((m) => m.id == voce);
      final data = tre[diTurno];
      expect(data, isNotNull,
          reason: 'nessuno dei dodici giorni provati tocca a $voce');
      const maestro = Maestro.medora;

      tester.view.physicalSize = const Size(430, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
        ],
        child: MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: MaestroScope(child: DreamRiteScreen(now: data)),
          ),
        ),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      // **IL RITO SI COMPIE, altrimenti il saluto non esiste ancora.** La
      // nebbia si dirada col ripiego tattile e le stelle si uniscono in
      // ordine: e' la stessa strada di dream_rite_screen_test.
      await tester.tap(find.byKey(const Key('dream_fog_skip')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      final segno = NightSky.moonSign(data!);
      final figura = kZodiacConstellations.firstWhere((c) => c.sign == segno);
      for (var i = 0; i < figura.points.length; i++) {
        await tester.tap(find.byKey(Key('dream_star_$i')));
        await tester.pump(const Duration(milliseconds: 60));
      }
      await tester.pump(const Duration(milliseconds: 1200));
      await tester.pump(const Duration(milliseconds: 600));

      // **IL SALUTO PORTA IL SUO NOME**, ed e' la sorgente che ruotava gia'.
      expect(
          find.textContaining(
              'IL SALUTO DI ${maestro.displayName.toUpperCase()}'),
          findsOneWidget,
          reason: 'il saluto non e\' attribuito a ${maestro.displayName}, '
              'cioe\' la sorgente del testo non e\' quella che ruota');

      // **E NESSUN ALTRO MAESTRO COMPARE A VIDEO.** E' la pretesa che la
      // costante faceva cadere: il pulsante nominava sempre lo stesso.
      final altri = Maestro.values.where((m) => m != maestro);
      for (final estraneo in altri) {
        expect(find.textContaining(estraneo.displayName), findsNothing,
            reason: 'il rito di ${maestro.displayName} nomina anche '
                '${estraneo.displayName}: il testo e il pulsante leggono due '
                'sorgenti diverse, ed e\' esattamente cio\' che il fondatore '
                'ha visto negli screenshot');
      }
    });
  }
}
