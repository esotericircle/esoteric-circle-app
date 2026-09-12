import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/synastry/cielo_della_sinastria.dart';
import 'package:esoteric_circle/core/synastry/synastry_report.dart';
import 'package:esoteric_circle/core/synastry/vip_catalog.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/synastry/sinastria_vip_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// Accenti veri ovunque nella Sinastria VIP: nessun apostrofo al posto
/// dell'accento ("AFFINITA'", "e'", "piu'") ne nelle etichette del codice ne
/// nei dati composti a runtime. Se una stringa a video porta un apostrofo-accento
/// questo test cade.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  // Una vocale seguita da apostrofo di fine parola e' un accento scritto male,
  // salvo i troncamenti legittimi (po', mo', be') e l'elisione (l'amore, c'è),
  // dove l'apostrofo e' seguito da una lettera.
  final vowelApostrophe = RegExp("[aeiou]'", caseSensitive: false);
  final letter = RegExp('[a-zA-Zàèéìòù]');

  String? offendingWord(String s) {
    for (final m in vowelApostrophe.allMatches(s)) {
      final apostrophe = m.end - 1;
      if (apostrophe + 1 < s.length && letter.hasMatch(s[apostrophe + 1])) {
        continue; // elisione
      }
      final vowel = m.start;
      final prev = vowel > 0 ? s[vowel - 1].toLowerCase() : '';
      final pair = '$prev${s[vowel].toLowerCase()}';
      if (pair == 'po' || pair == 'mo' || pair == 'be') continue; // troncamenti
      final start = (vowel - 10).clamp(0, s.length);
      final end = (apostrophe + 2).clamp(0, s.length);
      return s.substring(start, end);
    }
    return null;
  }

  void expectClean(String text, String where) {
    expect(offendingWord(text), isNull,
        reason: 'Accento con apostrofo in $where: "$text"');
  }

  // Ordine BO voce 02: il responso vuole un cielo e non piu' un segno. Una
  // persona per segno, nata a mezzogiorno tre giorni dentro il segno.
  final cieli = <Zodiac, CieloDiSinastria>{};
  CieloDiSinastria cieloDi(Zodiac segno) => cieli.putIfAbsent(segno, () {
        final (mese, giorno) = segno.from;
        return CieloDiSinastria.perIdentita(BirthIdentity.fromParts(
            birthDate:
                DateTime(1990, mese, giorno).add(const Duration(days: 3))));
      });

  test('I dati composti del responso usano accenti veri', () {
    for (final user in Zodiac.values) {
      for (final vip in VipCatalog.vips) {
        final r = SynastryReport.perCieli(tuo: cieloDi(user), vip: vip);
        expectClean(r.reading, 'reading ${user.id}/${vip.stem}');
        expectClean(r.band, 'band');
        expectClean(r.meetingQuip, 'meetingQuip');
        expectClean(r.meetingLabel, 'meetingLabel');
        for (final bar in r.bars) {
          expectClean(bar.label, 'bar label');
          expectClean(bar.quip, 'bar quip');
        }
      }
      expectClean(SynastryReport.challengeLine('X'), 'challenge');
    }
  });

  test('I nomi e le date dei VIP usano accenti veri', () {
    for (final vip in VipCatalog.vips) {
      expectClean(vip.name, 'nome VIP');
      expectClean(vip.note, 'data VIP');
    }
  });

  void silenceSensors() {
    final messenger = binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
      (call) async => null,
    );
    for (final name in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      messenger.setMockStreamHandler(
        EventChannel(name),
        MockStreamHandler.inline(onListen: (args, events) {}),
      );
    }
  }

  testWidgets('Nessuna stringa a video porta un apostrofo-accento',
      (tester) async {
    silenceSensors();
    tester.view.physicalSize = const Size(440, 1700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: MaestroScope(child: child!),
        ),
        home: const SinastriaVipScreen(userSign: Zodiac.gemini),
      ),
    ));
    await tester.pumpAndSettle();

    for (final element in find.byType(Text).evaluate()) {
      final data = (element.widget as Text).data;
      if (data != null) expectClean(data, 'Text a video');
    }
  });
}
