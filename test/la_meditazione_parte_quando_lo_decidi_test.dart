// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/maestro/libreria_dei_respiri.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/aura/meditation/meditation_audio.dart';
import 'package:esoteric_circle/features/maestri/aura/meditation/meditation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **LA MEDITAZIONE PARTE QUANDO LO DECIDI, E DICE QUANTO MANCA.** Ordine DS
/// voce 05, 17 settembre 2026.
///
/// Il fondatore, sulle catture del 16 e del 17 settembre: *"la scelta della
/// frequenza si fa fra molte bolle; il suono parte da solo prima che l'utente
/// abbia deciso qualcosa; e durante la sessione non si sa quanto manchi alla
/// fine"*.
///
/// **Cosa c'era.** All'apertura il suono non partiva, e questo resta: ma
/// toccare un sintomo o una bolla di frequenza **avviava la sessione**, per
/// una regola scritta dall'ordine DD voce 12 (*"scelto il sintomo, Aura fa
/// partire la pratica adatta subito"*). Per chi guarda e' il suono che parte
/// senza che abbia detto comincia. **Questa voce la rovescia**, e vince la voce
/// piu' recente, come l'ordine DD stesso ha fatto con le sue contraddizioni.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<_Lettore> monta(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final lettore = _Lettore();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        home: MaestroScope(
            child: MeditationScreen(
                player: lettore, now: DateTime(2026, 9, 17, 0, 3))),
      ),
    ));
    await tester.pump();
    return lettore;
  }

  /// **Non pumpAndSettle**: il respiro gira sempre, anche a sessione ferma,
  /// e la scena non si assesta mai. Il menu' si apre in trecento millisecondi.
  Future<void> attendiIlMenu(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> apriISintomi(WidgetTester tester) async {
    final porta = find.byKey(const Key('meditazione_apri_libreria'));
    await tester.ensureVisible(porta);
    await tester.tap(porta);
    await tester.pump();
  }

  testWidgets('aprendo la schermata nessuna riproduzione parte',
      (tester) async {
    final lettore = await monta(tester);
    await tester.pump(const Duration(seconds: 5));
    expect(lettore.suonate, isEmpty,
        reason: 'aprire la schermata non e un consenso a sentire un suono');
  });

  testWidgets(
      'scegliere un sintomo o una frequenza non fa partire niente: '
      'parte il play', (tester) async {
    final lettore = await monta(tester);
    await apriISintomi(tester);
    final primo = LibreriaDeiRespiri.pronte.first;
    final voce = find.byKey(Key('meditazione_respiro_${primo.id}'));
    await tester.ensureVisible(voce);
    await tester.tap(voce);
    await tester.pump(const Duration(seconds: 2));
    expect(lettore.suonate, isEmpty,
        reason: 'toccare un sintomo ha fatto partire il suono: la persona ha '
            'scelto, non ha deciso di cominciare');

    final menu = find.byKey(const Key('meditazione_scelta_frequenza'));
    await tester.ensureVisible(menu);
    await tester.tap(menu);
    await attendiIlMenu(tester);
    final voceDelMenu = find.byKey(const Key('meditazione_frequenza_cuore639'));
    await tester.tap(voceDelMenu.last);
    await attendiIlMenu(tester);
    expect(lettore.suonate, isEmpty,
        reason: 'scegliere una frequenza ha fatto partire il suono');

    await tester.ensureVisible(find.byKey(const Key('meditation_play')));
    await tester.tap(find.byKey(const Key('meditation_play')));
    await tester.pump();
    expect(lettore.suonate, [MeditationPreset.cuore639],
        reason: 'al gesto il suono parte, ed e la frequenza scelta');
  });

  testWidgets(
      'la frequenza si sceglie da UN controllo solo: le bolle non ci '
      'sono piu', (tester) async {
    await monta(tester);
    await apriISintomi(tester);
    await tester.pump();
    for (final p in MeditationPreset.values) {
      expect(find.byKey(Key('meditation_preset_${p.id}')), findsNothing,
          reason: 'la bolla della frequenza ${p.label} e tornata');
    }
    expect(
        find.byKey(const Key('meditazione_scelta_frequenza')), findsOneWidget);
    // Il controllo apre un menu a discesa con tutte e nove.
    await tester
        .ensureVisible(find.byKey(const Key('meditazione_scelta_frequenza')));
    await tester.tap(find.byKey(const Key('meditazione_scelta_frequenza')));
    await attendiIlMenu(tester);
    for (final p in MeditationPreset.values) {
      expect(find.byKey(Key('meditazione_frequenza_${p.id}')), findsWidgets,
          reason: 'il menu non porta la frequenza ${p.label}');
    }
  });

  testWidgets(
      'la scheda di ogni sintomo nomina la sua frequenza, prima di '
      'cominciare', (tester) async {
    await monta(tester);
    await apriISintomi(tester);
    final mancanti = <String>[];
    for (final r in LibreriaDeiRespiri.pronte) {
      final scheda = find.byKey(Key('meditazione_respiro_${r.id}'));
      expect(scheda, findsOneWidget);
      final testi = find
          .descendant(of: scheda, matching: find.byType(Text))
          .evaluate()
          .map((e) => (e.widget as Text).data ?? '')
          .join(' ');
      final sua = MeditationPreset.perCentro(r.centro);
      // Senza centro la pratica suona la frequenza scelta: la si legge dal
      // menu', che e' cio' che la persona vede.
      final menu = find
          .descendant(
              of: find.byKey(const Key('meditazione_scelta_frequenza')),
              matching: find.byType(Text))
          .evaluate()
          .map((e) => (e.widget as Text).data ?? '')
          .join(' ');
      final scelta =
          MeditationPreset.values.firstWhere((p) => menu.contains(p.label));
      final attesa = sua?.label ?? scelta.label;
      if (!testi.contains(attesa)) mancanti.add('${r.id}: "$testi"');
      print('ORDINE DS VOCE 05: ${r.sintomo.etichetta} -> $attesa');
    }
    expect(mancanti, isEmpty,
        reason: 'queste schede non dicono che frequenza comportano:\n'
            '${mancanti.join('\n')}');
  });

  testWidgets('una pratica scelta conta la durata che la sua scheda dichiara',
      (tester) async {
    // **La divergenza dichiarata nel manifesto DS.** L'ordine dice cinque
    // minuti, e sette pratiche su dodici lo sono. Le altre dicono due, tre,
    // sette e dieci minuti nella scheda: un 5:00 sotto "10 minuti" direbbe il
    // falso proprio nel numero che questa voce aggiunge.
    _laPraticaDuraQuantoDice();
    await monta(tester);
    await apriISintomi(tester);
    final lunga = LibreriaDeiRespiri.pronte
        .reduce((a, b) => a.durata >= b.durata ? a : b);
    final voce = find.byKey(Key('meditazione_respiro_${lunga.id}'));
    await tester.ensureVisible(voce);
    await tester.tap(voce);
    await tester.pump();
    await tester.ensureVisible(find.byKey(const Key('meditation_play')));
    await tester.tap(find.byKey(const Key('meditation_play')));
    await tester.pump();
    final conto = tester
        .widget<Text>(find.byKey(const Key('meditazione_quanto_manca')))
        .data!;
    final minuti = lunga.durata.inMinutes;
    print('ORDINE DS VOCE 05: ${lunga.nome}, ${lunga.quantoDura}, il conto '
        'dice "$conto"');
    expect(conto, contains('$minuti:00'));
  });

  testWidgets('il conto alla rovescia esiste, parte da 5:00 e arriva a zero',
      (tester) async {
    final lettore = await monta(tester);
    expect(find.byKey(const Key('meditazione_quanto_manca')), findsNothing,
        reason: 'un conto alla rovescia a sessione ferma e un orologio');
    await tester.ensureVisible(find.byKey(const Key('meditation_play')));
    await tester.tap(find.byKey(const Key('meditation_play')));
    await tester.pump();
    String conto() => tester
        .widget<Text>(find.byKey(const Key('meditazione_quanto_manca')))
        .data!;
    expect(conto(), contains('5:00'));
    await tester.pump(const Duration(seconds: 61));
    expect(conto(), contains('3:59'));
    await tester.pump(const Duration(seconds: 238));
    expect(conto(), contains('0:01'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(find.byKey(const Key('meditazione_compiuta')), findsOneWidget,
        reason: 'a zero la sessione non si e compiuta');
    expect(lettore.inSuono, isFalse);
  });
}

/// Una pratica scelta dura quanto la sua scheda dichiara.
void _laPraticaDuraQuantoDice() {}

class _Lettore implements TonePlayer {
  final suonate = <MeditationPreset>[];
  bool inSuono = false;

  @override
  Future<void> play(MeditationPreset preset) async {
    suonate.add(preset);
    inSuono = true;
  }

  @override
  Future<void> stop() async => inSuono = false;
}
