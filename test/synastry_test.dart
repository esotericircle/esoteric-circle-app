import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/synastry/celeb_catalog.dart';
import 'package:esoteric_circle/core/synastry/synastry.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/synastry/sinastria_celeb_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// Sinastria Celeb: calcolo deterministico per elemento, senza AI, e la
/// schermata raggiungibile in un tap col VIP precaricato.
void main() {
  group('Calcolo deterministico', () {
    test('Lo stesso paio di segni da sempre lo stesso esito', () {
      final a = Synastry.between(Zodiac.leo, Zodiac.aries);
      final b = Synastry.between(Zodiac.leo, Zodiac.aries);
      expect(a.percent, b.percent);
      expect(a.title, b.title);
      expect(a.reading, b.reading);
    });

    test('Stesso segno: anime gemelle, affinita alta', () {
      final r = Synastry.between(Zodiac.gemini, Zodiac.gemini);
      expect(r.title, 'Anime gemelle');
      expect(r.percent, greaterThanOrEqualTo(95));
    });

    test('Stesso elemento: intesa naturale', () {
      // Ariete e Leone sono entrambi di Fuoco.
      final r = Synastry.between(Zodiac.aries, Zodiac.leo);
      expect(r.title, 'Stesso elemento');
    });

    test('Fuoco e Aria: complementari', () {
      // Ariete (Fuoco) e Gemelli (Aria) si alimentano.
      final r = Synastry.between(Zodiac.aries, Zodiac.gemini);
      expect(r.title, 'Complementari');
    });

    test('Fuoco e Acqua: tensione feconda', () {
      // Ariete (Fuoco) e Cancro (Acqua) si sfidano.
      final r = Synastry.between(Zodiac.aries, Zodiac.cancer);
      expect(r.title, 'Tensione feconda');
    });

    test('La percentuale resta nel range leggibile', () {
      for (final a in Zodiac.values) {
        for (final b in Zodiac.values) {
          final r = Synastry.between(a, b);
          expect(r.percent, inInclusiveRange(0, 99));
        }
      }
    });
  });

  group('Catalogo VIP', () {
    test('Almeno un VIP e sempre precaricato', () {
      expect(CelebCatalog.vips, isNotEmpty);
      expect(CelebCatalog.first, CelebCatalog.vips.first);
    });
  });

  testWidgets('La schermata mostra il quadrante e i VIP', (tester) async {
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
      ],
      child: const MaterialApp(
        home: MaestroScope(child: SinastriaCelebScreen(userSign: Zodiac.gemini)),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('sinastria_list')), findsOneWidget);
    expect(find.byKey(const Key('sinastria_gauge')), findsOneWidget);
    // Il VIP precaricato in testa e' selezionabile.
    expect(
      find.byKey(Key('vip_${CelebCatalog.first.name}')),
      findsOneWidget,
    );
  });

  testWidgets('Cambiare VIP aggiorna il quadrante', (tester) async {
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
      ],
      child: const MaterialApp(
        home: MaestroScope(child: SinastriaCelebScreen(userSign: Zodiac.gemini)),
      ),
    ));
    await tester.pumpAndSettle();

    final other = CelebCatalog.vips[2];
    await tester.tap(find.byKey(Key('vip_${other.name}')));
    await tester.pumpAndSettle();

    final expected = Synastry.between(Zodiac.gemini, other.sign);
    expect(find.text('${expected.percent}%'), findsOneWidget);
  });
}
