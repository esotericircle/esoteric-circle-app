import 'package:esoteric_circle/core/rituals/daily_rituals.dart';
import 'package:esoteric_circle/core/rituals/runes.dart';
import 'package:esoteric_circle/features/rituals/breath_destiny_screen.dart';
import 'package:esoteric_circle/features/rituals/dawn_rite_screen.dart';
import 'package:esoteric_circle/features/rituals/day_oracle_screen.dart';
import 'package:esoteric_circle/features/rituals/sunset_rune_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// I quattro rituali del giorno: contenuti deterministici e reali, livello
/// visivo prima del testo, ogni sensore con ripiego tattile universale.
void main() {
  final date = DateTime(2026, 7, 13);

  group('Contenuti deterministici', () {
    test('Il Rito dell\'Alba ruota tra i tre Maestri', () {
      final maestri = {
        for (var d = 0; d < 3; d++)
          DailyRituals.dawnMaestro(DateTime(2026).add(Duration(days: d)))
      };
      expect(maestri.length, 3);
    });

    test('Stesso giorno, stesso responso', () {
      expect(DailyRituals.dawnMessage(date), DailyRituals.dawnMessage(date));
      expect(DailyRituals.destinyFragment(date),
          DailyRituals.destinyFragment(date));
      expect(DailyRituals.dayOracle(date), DailyRituals.dayOracle(date));
      expect(DailyRituals.sunsetRune(date).name,
          DailyRituals.sunsetRune(date).name);
    });

    test('L\'Elder Futhark ha i ventiquattro segni con glifo e significato', () {
      expect(kElderFuthark.length, 24);
      for (final rune in kElderFuthark) {
        expect(rune.glyph, isNotEmpty);
        expect(rune.name, isNotEmpty);
        expect(rune.meaning, isNotEmpty);
      }
      // La runa del giorno viene dal Futhark.
      expect(kElderFuthark.contains(DailyRituals.sunsetRune(date)), isTrue);
    });
  });

  group('Schermate dei rituali', () {
    testWidgets('Rito dell\'Alba: visivo, poi il testo col tocco',
        (tester) async {
      await tester.pumpWidget(MaterialApp(home: DawnRiteScreen(now: date)));
      await tester.pump();
      // Prima il livello visivo e l'invito, il testo non c'e' ancora.
      expect(find.text('Tocca per ricevere il rito'), findsOneWidget);
      expect(find.byKey(const Key('ritual_content')), findsNothing);

      await tester.tap(find.byKey(const Key('ritual_gesture')));
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byKey(const Key('ritual_content')), findsOneWidget);
      expect(find.text(DailyRituals.dawnMessage(date)), findsOneWidget);
    });

    testWidgets('Soffio del Destino: ripiego tattile tenendo premuto',
        (tester) async {
      await tester.pumpWidget(MaterialApp(home: BreathDestinyScreen(now: date)));
      await tester.pump();
      // La riga dichiara il microfono e il ripiego tattile.
      expect(find.textContaining('microfono'), findsWidgets);
      expect(find.byKey(const Key('ritual_content')), findsNothing);

      await tester.longPress(find.byKey(const Key('ritual_gesture')));
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text(DailyRituals.destinyFragment(date)), findsOneWidget);
    });

    testWidgets('Oracolo del Giorno: ripiego allo scorrimento del dito',
        (tester) async {
      await tester.pumpWidget(MaterialApp(home: DayOracleScreen(now: date)));
      await tester.pump();
      expect(find.textContaining('giroscopio'), findsOneWidget);

      await tester.drag(
          find.byKey(const Key('ritual_gesture')), const Offset(250, 0));
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text(DailyRituals.dayOracle(date)), findsOneWidget);
    });

    testWidgets('La Runa del Tramonto: estrae una runa reale col significato',
        (tester) async {
      await tester.pumpWidget(MaterialApp(home: SunsetRuneScreen(now: date)));
      await tester.pump();
      // Il glifo runico e' gia' sulla scena (testo Unicode vero).
      expect(find.byKey(const Key('rune_glyph')), findsOneWidget);
      expect(find.byKey(const Key('ritual_content')), findsNothing);

      await tester.tap(find.byKey(const Key('ritual_gesture')));
      await tester.pump(const Duration(milliseconds: 600));
      final rune = DailyRituals.sunsetRune(date);
      expect(find.text(rune.name), findsOneWidget);
      expect(find.text(rune.meaning), findsOneWidget);
    });
  });
}
