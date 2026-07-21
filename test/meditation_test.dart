import 'package:esoteric_circle/core/arts/art_catalog.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/rituals/daily_elements.dart';
import 'package:esoteric_circle/core/rituals/daily_rituals.dart';
import 'package:esoteric_circle/features/santuario/daily_strip.dart';
import 'package:esoteric_circle/features/maestri/aura/meditation/meditation_audio.dart';
import 'package:esoteric_circle/features/maestri/aura/meditation/meditation_screen.dart';
import 'package:esoteric_circle/features/maestri/aura/meditation/tone_generator.dart';
import 'package:esoteric_circle/features/maestri/maestro_screen.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/feature_flags/feature_flag_service.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// Meditazione di Aura: toni generati a runtime, cimatica e guida al respiro.
void main() {
  group('Generatore di toni', () {
    const gen = ToneGenerator();

    test('PCM stereo della lunghezza attesa e deterministico', () {
      final a = gen.pcm16Stereo(
          leftHz: 432, rightHz: 432, duration: const Duration(milliseconds: 100));
      // 100 ms a 44100 Hz, stereo: 4410 frame, 8820 campioni.
      expect(a.length, 44100 ~/ 10 * 2);
      final b = gen.pcm16Stereo(
          leftHz: 432, rightHz: 432, duration: const Duration(milliseconds: 100));
      expect(a, b);
    });

    test('Tono puro: i due canali coincidono; binaurale: differiscono', () {
      final pure = gen.pcm16Stereo(
          leftHz: 432, rightHz: 432, duration: const Duration(milliseconds: 50));
      var equal = true;
      for (var i = 0; i < pure.length; i += 2) {
        if (pure[i] != pure[i + 1]) equal = false;
      }
      expect(equal, isTrue);

      final beat = gen.pcm16Stereo(
          leftHz: 210, rightHz: 217, duration: const Duration(milliseconds: 50));
      var differ = false;
      for (var i = 0; i < beat.length; i += 2) {
        if (beat[i] != beat[i + 1]) differ = true;
      }
      expect(differ, isTrue);
    });

    test('La frequenza generata e\' quella chiesta', () {
      final pcm = gen.pcm16Stereo(
          leftHz: 432, rightHz: 432, duration: const Duration(seconds: 1));
      // Cambi di segno sul canale sinistro (solo campioni non nulli): due per
      // ciclo. Cosi' i rari campioni esattamente a zero non contano due volte.
      var crossings = 0;
      int? prevSign;
      for (var i = 0; i < pcm.length; i += 2) {
        final v = pcm[i];
        if (v == 0) continue;
        final s = v > 0 ? 1 : -1;
        if (prevSign != null && s != prevSign) crossings++;
        prevSign = s;
      }
      // 432 Hz per un secondo: circa 864 cambi di segno.
      expect(crossings, closeTo(864, 6));
    });

    test('Il WAV ha un contenitore valido', () {
      final wav = gen.wav(
          leftHz: 528, rightHz: 528, duration: const Duration(milliseconds: 100));
      String tag(int o) => String.fromCharCodes(wav.sublist(o, o + 4));
      expect(tag(0), 'RIFF');
      expect(tag(8), 'WAVE');
      expect(tag(12), 'fmt ');
      expect(tag(36), 'data');
      // 44 byte di intestazione piu' i dati PCM.
      final pcm = gen.pcm16Stereo(
          leftHz: 528, rightHz: 528, duration: const Duration(milliseconds: 100));
      expect(wav.length, 44 + pcm.buffer.asUint8List().length);
    });
  });

  group('Preset', () {
    test('Il battito binaurale nasce dalla differenza dei canali', () {
      expect(MeditationPreset.calm432.binaural, isFalse);
      expect(MeditationPreset.thetaBeat.binaural, isTrue);
      expect(MeditationPreset.thetaBeat.beatHz, 7);
      expect(MeditationPreset.calm432.beatHz, 0);
    });
  });

  group('Schermata di meditazione', () {
    Widget host(TonePlayer player) => ChangeNotifierProvider(
          create: (_) => MaestroController(),
          child: MaterialApp(
            home: MaestroScope(child: MeditationScreen(player: player)),
          ),
        );

    testWidgets('Mostra cimatica, respiro e fondamento onesto', (tester) async {
      await tester.pumpWidget(host(const SilentTonePlayer()));
      await tester.pump();
      expect(find.byKey(const Key('meditation_cymatics')), findsOneWidget);
      expect(find.byKey(const Key('meditation_play')), findsOneWidget);
      // Prima del via, la guida invita a iniziare.
      expect(find.text('Tocca per iniziare'), findsOneWidget);
      // Fondamento onesto, senza ripetere il disclaimer.
      expect(find.textContaining('non un fatto medico'), findsOneWidget);
    });

    testWidgets('Play avvia il suono e il respiro', (tester) async {
      final player = _RecordingPlayer();
      await tester.pumpWidget(host(player));
      await tester.pump();

      await tester.tap(find.byKey(const Key('meditation_play')));
      await tester.pump(const Duration(milliseconds: 500));

      expect(player.played, isNotEmpty);
      // Partito il respiro, l'etichetta non e' piu' l'invito iniziale.
      expect(find.text('Tocca per iniziare'), findsNothing);
    });

    testWidgets('Il preset binaurale invita alle cuffie', (tester) async {
      await tester.pumpWidget(host(const SilentTonePlayer()));
      await tester.pump();
      // Di default 432 Hz: invito morbido alle cuffie.
      expect(find.textContaining('Metti le cuffie'), findsNothing);
      await tester.tap(find.byKey(const Key('meditation_preset_theta')));
      await tester.pump();
      expect(find.textContaining('Metti le cuffie'), findsOneWidget);
    });
  });

  testWidgets('La Meditazione vive nel dominio di Aura, non negli altri',
      (tester) async {
    Widget domain(Maestro m) => MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => MaestroController()),
            ChangeNotifierProvider(create: (_) => QualityTierController()),
            ChangeNotifierProvider(create: (_) => EntitlementService()),
            ChangeNotifierProvider(
              create: (ctx) =>
                  FeatureFlagService(entitlement: ctx.read<EntitlementService>())
                    ..initialize(),
            ),
          ],
          child: MaterialApp(
            home: MaestroScope(child: Scaffold(body: MaestroScreen(maestro: m))),
          ),
        );

    // Nel catalogo la Meditazione sta sotto Aura, in Energia, e solo li'.
    expect(
      ArtCatalog.activeOf(Maestro.aura).map((a) => a.id),
      contains('meditation'),
    );
    for (final altro in [Maestro.medora, Maestro.caligo]) {
      expect(
        ArtCatalog.forMaestro(altro).expand((s) => s.arts).map((a) => a.id),
        isNot(contains('meditation')),
      );
    }

    await tester.pumpWidget(domain(Maestro.aura));
    await tester.pump();
    await tester.scrollUntilVisible(
      find.byKey(const Key('art_meditation')),
      220,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byKey(const Key('art_meditation')), findsOneWidget);

    await tester.pumpWidget(domain(Maestro.medora));
    await tester.pump();
    expect(find.byKey(const Key('art_meditation')), findsNothing);
  });

  testWidgets('I riti del giorno non stanno nel dominio, ne restano orfani',
      (tester) async {
    Widget domain(Maestro m) => MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => MaestroController()),
            ChangeNotifierProvider(create: (_) => QualityTierController()),
            ChangeNotifierProvider(create: (_) => EntitlementService()),
            ChangeNotifierProvider(
              create: (ctx) =>
                  FeatureFlagService(entitlement: ctx.read<EntitlementService>())
                    ..initialize(),
            ),
          ],
          child: MaterialApp(
            home: MaestroScope(child: Scaffold(body: MaestroScreen(maestro: m))),
          ),
        );

    // Il dominio e' il luogo delle arti, non dei riti del giorno: nessuna card
    // di rito ci compare piu', in nessuno dei tre domini.
    for (final m in Maestro.values) {
      await tester.pumpWidget(domain(m));
      await tester.pump();
      for (final k in const [
        'ritual_dawn',
        'ritual_oracle',
        'ritual_rune',
        'ritual_breath',
      ]) {
        expect(find.byKey(Key(k)), findsNothing);
      }
    }

    // Restano pero' raggiungibili, tutti, dalla striscia del giorno nel
    // Santuario: ogni elemento ha ancora la sua rotta viva.
    for (final e in DailyElement.values) {
      expect(dailyElementRoute(e), isNotNull);
    }
    // E il Maestro di turno resta quello del giorno, dove serve.
    expect(DailyRituals.dawnMaestro(DateTime(2026, 7, 20)), isA<Maestro>());
  });
}

/// Lettore finto che annota i preset avviati, per i test.
class _RecordingPlayer implements TonePlayer {
  final List<MeditationPreset> played = [];

  @override
  Future<void> play(MeditationPreset preset) async => played.add(preset);

  @override
  Future<void> stop() async {}
}
