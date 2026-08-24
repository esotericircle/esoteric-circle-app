import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/rituals/arcano_del_giorno.dart';
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

import 'attorno_al_soffio.dart';

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
      // La BASE resta provvisoria: transito e tradizione arrivano dall'Oroscopo
      // e non da quest'ordine, quindi restano nulli e dichiarati tali.
      expect(gift.source.provisional, isTrue);
      expect(gift.source.transit, isNull);
      expect(gift.source.tradition, isNull);

      // IL CONTENUTO invece non e' piu' un segnaposto, dal 5 agosto 2026: il
      // rito esiste davvero, ha i suoi tre momenti e nomina il cielo di oggi.
      expect(gift.provisional, isFalse,
          reason: 'il dono e\' tornato provvisorio');
      expect(gift.orientation, isNot(DawnGift.provisionalOrientation),
          reason: 'il dono e\' tornato a dire "in arrivo"');
      expect(gift.word, isNotNull, reason: 'manca la parola da portare');
      expect(gift.rito, isNotNull);
      expect(gift.rito!.gesto, isNotEmpty);
      expect(gift.rito!.respiro, isNotEmpty);
      expect(gift.rito!.viaTattile, isNotEmpty);
      expect(gift.rito!.datiNominati, isNotEmpty,
          reason: 'il rito non nomina nessun dato del cielo di stamattina');
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
      expect(find.text('Trascina in alto, oppure tocca'),
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
      // NIENTE MAIUSCOLETTO, ordine P voce 13: l'etichetta del dono e' passata
      // dal ruolo etichetta a quello didascalia, e col maiuscoletto se n'e'
      // andato anche il toUpperCase.
      // **L'ETICHETTA DEL TIPO DI DONO NON SI MOSTRA PIU', ordine AS voce
      // 06**: era la categoria con cui lo chiamiamo noi ("Orientamento del
      // giorno"), non cosa dice alla persona, e sopra c'e' gia' la riga che
      // dice chi parla. Il tipo resta nel dato, dove serve a comporre il
      // dono: la pretesa si sposta sul dono vero, cioe' il suo testo.
      expect(find.text(gift.kind.label), findsNothing);
      expect(find.byKey(const Key('alba_orientamento')), findsOneWidget);
      expect(find.text(gift.orientation), findsOneWidget);
      expect(find.byKey(const Key('gift_base_toggle')), findsOneWidget);

      // La base si apre e mostra l'ancora natale, dato reale.
      expect(find.byKey(const Key('gift_base_panel')), findsNothing);
      // Da quando il dono porta il rito intero, gesto piu' respiro piu' via col
      // dito, il pulsante puo' finire sotto il bordo della scheda: si porta in
      // vista prima di toccarlo, come farebbe un dito.
      await tester.ensureVisible(find.byKey(const Key('gift_base_toggle')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('gift_base_toggle')));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byKey(const Key('gift_base_panel')), findsOneWidget);
      expect(find.text('Ancora natale'), findsOneWidget);
    });

    testWidgets('Soffio del Destino: il ripiego libera i semi e porge il dono',
        (tester) async {
      // Il Soffio porta il cosmo condiviso dalla voce 26: l'impalcatura sta in
      // `attorno_al_soffio.dart`, non riscritta qui.
      await tester.pumpWidget(attornoAlSoffio(BreathDestinyScreen(now: date)));
      await tester.pump();
      // L'invito al soffio e il suo ripiego, il dono non c'e' ancora.
      expect(find.text('Soffia, oppure spazza col dito'), findsOneWidget);
      expect(find.byKey(const Key('ritual_content')), findsNothing);

      // Ripiego a tocco prolungato: disperde i semi e rivela il dono di Aura.
      await tester.longPress(find.byKey(const Key('ritual_gesture')));
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.byKey(const Key('ritual_content')), findsOneWidget);
      final gift = DawnGift.forMaestro(date, Maestro.aura);
      // **L'ETICHETTA DEL TIPO DI DONO NON SI MOSTRA PIU', ordine AS voce
      // 06**: era la categoria con cui lo chiamiamo noi ("Orientamento del
      // giorno"), non cosa dice alla persona, e sopra c'e' gia' la riga che
      // dice chi parla. Il tipo resta nel dato, dove serve a comporre il
      // dono: la pretesa si sposta sul dono vero, cioe' il suo testo.
      expect(find.text(gift.kind.label), findsNothing);
      expect(find.byKey(const Key('alba_orientamento')), findsOneWidget);
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
      // **L'ORACOLO E' DIVENTATO L'ARCANO DEL GIORNO, ordine AS voce 08.**
      // Non e' piu' una riga presa a giro da un elenco: e' una carta degli
      // Arcani Maggiori col suo responso. La pretesa segue il dono nuovo.
      final carta = ArcanoDelGiorno.di(date);
      expect(find.text(carta.name), findsOneWidget);
      expect(find.text(carta.uprightSummary), findsOneWidget);
    });

  });
}
