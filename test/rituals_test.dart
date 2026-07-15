import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/rituals/daily_rituals.dart';
import 'package:esoteric_circle/core/rituals/dawn_gift.dart';
import 'package:esoteric_circle/core/rituals/ritual_streak.dart';
import 'package:esoteric_circle/core/rituals/runes.dart';
import 'package:esoteric_circle/features/rituals/breath_destiny_screen.dart';
import 'package:esoteric_circle/features/rituals/dawn_rite_screen.dart';
import 'package:esoteric_circle/features/rituals/day_oracle_screen.dart';
import 'package:esoteric_circle/features/rituals/sunset_rune_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  group('Il dono del Rito dell\'Alba', () {
    test('Deterministico e coerente col tipo di dono del Maestro', () {
      final gift = DawnGift.of(date);
      expect(gift.word, DawnGift.of(date).word);
      expect(gift.message, DawnGift.of(date).message);
      // Il tipo di dono corrisponde al Maestro di turno.
      final maestro = DailyRituals.dawnMaestro(date);
      final expectedKind = {
        Maestro.medora: DawnGiftKind.orientamento,
        Maestro.aura: DawnGiftKind.intenzione,
        Maestro.caligo: DawnGiftKind.monito,
      }[maestro];
      expect(gift.kind, expectedKind);
    });

    test('Usa il segno se disponibile, con ripiego generico se manca', () {
      final generic = DawnGift.of(date);
      final personal = DawnGift.of(date, sign: Zodiac.leo);
      expect(generic.personalized, isFalse);
      expect(personal.personalized, isTrue);
      // La versione personale nomina il segno; la generica no.
      expect(personal.message.contains('Leone'), isTrue);
      expect(generic.message.contains('Leone'), isFalse);
      // La parola del giorno non cambia con il segno.
      expect(personal.word, generic.word);
    });
  });

  group('La continuita\' del Rito dell\'Alba', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('Giorni consecutivi crescono, un salto riparte da uno', () async {
      const streak = RitualStreak(id: 'dawn');
      final d1 = DateTime(2026, 7, 13);
      expect(await streak.recordToday(d1), 1);
      // Stesso giorno: non aumenta.
      expect(await streak.recordToday(d1), 1);
      // Giorno dopo: due.
      expect(await streak.recordToday(d1.add(const Duration(days: 1))), 2);
      // Un giorno saltato: riparte da uno.
      expect(await streak.recordToday(d1.add(const Duration(days: 3))), 1);
    });

    test('La continuita\' corrente vale solo se oggi o ieri', () async {
      const streak = RitualStreak(id: 'dawn');
      final d = DateTime(2026, 7, 13);
      await streak.recordToday(d);
      expect(await streak.current(d), 1);
      expect(await streak.current(d.add(const Duration(days: 1))), 1);
      // Due giorni dopo la continuita' e' interrotta.
      expect(await streak.current(d.add(const Duration(days: 2))), 0);
    });
  });

  group('Schermate dei rituali', () {
    testWidgets('Rito dell\'Alba: il gesto solleva l\'alba e porge il dono',
        (tester) async {
      await tester.pumpWidget(MaterialApp(home: DawnRiteScreen(now: date)));
      await tester.pump();
      // Prima il livello visivo e l'invito al gesto, il dono non c'e' ancora.
      expect(find.text('Trascina verso l\'alto per sollevare l\'alba'),
          findsOneWidget);
      expect(find.byKey(const Key('ritual_content')), findsNothing);

      // Ripiego tattile universale: il tocco compie il rito. L'alba si solleva
      // con l'animazione, poi lo stato rivelato ricostruisce col dono.
      await tester.tap(find.byKey(const Key('ritual_gesture')));
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.byKey(const Key('ritual_content')), findsOneWidget);

      // Nello stato rivelato compare il dono del giorno, con la parola in
      // risalto e il pulsante di condivisione.
      final gift = DawnGift.of(date);
      expect(find.text(gift.kind.label.toUpperCase()), findsOneWidget);
      expect(find.text(gift.message), findsOneWidget);
      expect(find.text(gift.word), findsOneWidget);
      expect(find.byKey(const Key('dawn_share_word')), findsOneWidget);
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
      // Il ripiego allo scorrimento del dito è comunicato nel suggerimento.
      expect(find.textContaining('ripiego tattile'), findsOneWidget);

      await tester.drag(
          find.byKey(const Key('ritual_gesture')), const Offset(250, 0));
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text(DailyRituals.dayOracle(date)), findsOneWidget);
    });

    testWidgets('La Runa del Tramonto: estrae una runa reale col significato',
        (tester) async {
      await tester.pumpWidget(MaterialApp(home: SunsetRuneScreen(now: date)));
      await tester.pump();
      // Stato chiuso: la pietra velata, non il glifo ne un rettangolo nudo.
      expect(find.byKey(const Key('rune_stone')), findsOneWidget);
      expect(find.byKey(const Key('rune_glyph')), findsNothing);
      expect(find.text('Scuoti per svelare la runa'), findsOneWidget);
      expect(find.byKey(const Key('ritual_content')), findsNothing);

      // Il ripiego tattile (tocco) svela la runa.
      await tester.tap(find.byKey(const Key('ritual_gesture')));
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byKey(const Key('rune_glyph')), findsOneWidget);
      expect(find.byKey(const Key('rune_stone')), findsNothing);
      final rune = DailyRituals.sunsetRune(date);
      expect(find.text(rune.name), findsOneWidget);
      expect(find.text(rune.meaning), findsOneWidget);
    });
  });
}
