import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/rituals/daily_rituals.dart';
import 'package:esoteric_circle/core/rituals/dawn_gift.dart';
import 'package:esoteric_circle/core/rituals/ritual_streak.dart';
import 'package:esoteric_circle/core/rituals/runes.dart';
import 'package:esoteric_circle/features/rituals/breath_destiny_screen.dart';
import 'package:esoteric_circle/features/rituals/dawn_rite_screen.dart';
import 'package:esoteric_circle/features/rituals/day_oracle_screen.dart';
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
    });

    test('L\'Elder Futhark ha i ventiquattro segni con glifo e significato', () {
      expect(kElderFuthark.length, 24);
      for (final rune in kElderFuthark) {
        expect(rune.glyph, isNotEmpty);
        expect(rune.name, isNotEmpty);
        expect(rune.meaning, isNotEmpty);
      }
    });
  });

  group('Il dono del Rito dell\'Alba', () {
    test('Ogni dono ha per costruzione la sua base', () {
      final gift = DawnGift.forChart(date);
      // Il tipo di dono corrisponde al Maestro di turno.
      final maestro = DailyRituals.dawnMaestro(date);
      final expectedKind = {
        Maestro.medora: DawnGiftKind.orientamento,
        Maestro.aura: DawnGiftKind.intenzione,
        Maestro.caligo: DawnGiftKind.monito,
      }[maestro];
      expect(gift.kind, expectedKind);
      // La base esiste sempre. Senza motore di transiti reali resta provvisoria
      // e non inventa nulla: transito e tradizione nulli, orientamento marcato.
      expect(gift.source, isNotNull);
      expect(gift.provisional, isTrue);
      expect(gift.source.provisional, isTrue);
      expect(gift.source.transit, isNull);
      expect(gift.source.tradition, isNull);
      expect(gift.word, isNull);
      expect(gift.orientation, DawnGift.provisionalOrientation);
    });

    test('La base si collega alla carta natale col segno solare reale', () {
      // Nata il 15 giugno: Sole in Gemelli, dato reale e deterministico.
      final identity = BirthIdentity(birthMoment: DateTime(1990, 6, 15));
      final gift = DawnGift.forChart(date, identity: identity);
      expect(gift.source.natalSunSign, Zodiac.gemini);
      expect(gift.source.natalDescription, contains('Gemelli'));
      // Senza identita', l'ancora natale non c'e' ma la base resta.
      final orphan = DawnGift.forChart(date);
      expect(orphan.source.natalSunSign, isNull);
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

      // Nello stato rivelato compare il dono, col tipo di dono e la base
      // apribile. Senza contenuti verificati, l'orientamento e' provvisorio.
      final gift = DawnGift.forChart(date);
      expect(find.text(gift.kind.label.toUpperCase()), findsOneWidget);
      expect(find.text(gift.orientation), findsOneWidget);
      expect(find.byKey(const Key('gift_base_toggle')), findsOneWidget);

      // La base si apre e mostra l'ancora natale, dato reale.
      expect(find.byKey(const Key('gift_base_panel')), findsNothing);
      await tester.tap(find.byKey(const Key('gift_base_toggle')));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byKey(const Key('gift_base_panel')), findsOneWidget);
      expect(find.text('Ancora natale'.toUpperCase()), findsOneWidget);
    });

    testWidgets('Soffio del Destino: il ripiego libera i semi e porge il dono',
        (tester) async {
      await tester.pumpWidget(MaterialApp(home: BreathDestinyScreen(now: date)));
      await tester.pump();
      // L'invito al soffio e il suo ripiego, il dono non c'e' ancora.
      expect(find.text('Soffia per liberare il tuo destino'), findsOneWidget);
      expect(find.byKey(const Key('ritual_content')), findsNothing);

      // Ripiego a tocco prolungato: disperde i semi e rivela il dono di Aura.
      await tester.longPress(find.byKey(const Key('ritual_gesture')));
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.byKey(const Key('ritual_content')), findsOneWidget);
      final gift = DawnGift.forMaestro(date, Maestro.aura);
      expect(find.text(gift.kind.label.toUpperCase()), findsOneWidget);
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

  });
}
