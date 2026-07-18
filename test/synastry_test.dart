import 'dart:io';

import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/synastry/synastry_report.dart';
import 'package:esoteric_circle/core/synastry/vip_catalog.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/synastry/sinastria_vip_screen.dart';
import 'package:esoteric_circle/features/synastry/user_photo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// Sinastria VIP: responso e quattro barre deterministici per coppia, senza AI,
/// piu' la schermata avvolta nel cosmo, il ritratto del VIP sul polo destro, la
/// foto opzionale dell'utente e la card condivisibile.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

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

  Vip vipBySign(Zodiac sign) =>
      VipCatalog.vips.firstWhere((v) => v.sign == sign);

  group('Responso deterministico', () {
    test('La stessa coppia da sempre lo stesso esito', () {
      final vip = VipCatalog.first;
      final a = SynastryReport.forPair(Zodiac.leo, vip);
      final b = SynastryReport.forPair(Zodiac.leo, vip);
      expect(a.overall, b.overall);
      expect(a.reading, b.reading);
      expect(a.love, b.love);
      expect(a.mental, b.mental);
      expect(a.sparks, b.sparks);
      expect(a.meetingPercent, b.meetingPercent);
    });

    test('Stesso segno: anime gemelle, cerchio alto', () {
      // Angelina Jolie e Gemelli: utente Gemelli e coppia dello stesso segno.
      final vip = vipBySign(Zodiac.gemini);
      final r = SynastryReport.forPair(Zodiac.gemini, vip);
      expect(r.band, 'Anime gemelle');
      expect(r.overall, greaterThanOrEqualTo(80));
    });

    test('Il cerchio e le tre barre restano nel range leggibile', () {
      for (final user in Zodiac.values) {
        for (final vip in VipCatalog.vips) {
          final r = SynastryReport.forPair(user, vip);
          expect(r.overall, inInclusiveRange(0, 99));
          expect(r.love, inInclusiveRange(0, 100));
          expect(r.mental, inInclusiveRange(0, 100));
          expect(r.sparks, inInclusiveRange(0, 100));
        }
      }
    });

    test('La possibilita di incontro resta minima, tra 0,2 e 4 per cento', () {
      for (final user in Zodiac.values) {
        for (final vip in VipCatalog.vips) {
          final r = SynastryReport.forPair(user, vip);
          expect(r.meetingPercent, inInclusiveRange(0.2, 4.0));
          expect(r.meetingQuip, isNotEmpty);
        }
      }
    });

    test('Le quattro barre ci sono tutte, nell ordine di layout', () {
      final r = SynastryReport.forPair(Zodiac.aries, VipCatalog.first);
      expect(r.bars, hasLength(4));
      expect(r.bars[0].label, contains('amore'));
      expect(r.bars[1].label, contains('mentale'));
      expect(r.bars[2].label, 'Scintille');
      expect(r.bars[3].label, contains('incontro'));
      // Solo l ultima barra porta la micro battuta.
      expect(r.bars[3].quip, isNotEmpty);
      expect(r.bars[0].quip, isEmpty);
    });

    test('Il testo concatena relazione, nome del VIP e chiusura', () {
      final vip = VipCatalog.first; // Angelina Jolie, Gemelli
      final r = SynastryReport.forPair(Zodiac.gemini, vip);
      expect(r.reading, contains('Stesso segno'));
      expect(r.reading, contains('Angelina Jolie'));
      // Una delle quattro chiusure ironiche.
      expect(r.reading.trim().endsWith('.'), isTrue);
    });

    test('Ogni VIP ha un carattere agganciato allo stem', () {
      for (final vip in VipCatalog.vips) {
        final r = SynastryReport.forPair(Zodiac.aries, vip);
        // Nessun ripiego generico: il nome del VIP compare nel testo.
        expect(r.reading, contains(vip.name),
            reason: 'Carattere mancante per ${vip.name} (${vip.stem})');
      }
    });

    test('Nessuna virgola seguita da e nei testi composti', () {
      final vietato = RegExp(r',\s+ed?\b');
      for (final user in Zodiac.values) {
        for (final vip in VipCatalog.vips) {
          final r = SynastryReport.forPair(user, vip);
          expect(vietato.hasMatch(r.reading), isFalse,
              reason: 'Virgola con e in: ${r.reading}');
        }
      }
    });

    test('La percentuale minima usa la virgola decimale', () {
      final r = SynastryReport.forPair(Zodiac.aries, VipCatalog.first);
      expect(r.meetingLabel, contains(','));
      expect(r.meetingLabel.endsWith('%'), isTrue);
    });
  });

  group('Catalogo VIP', () {
    test('Almeno un VIP e sempre precaricato', () {
      expect(VipCatalog.vips, isNotEmpty);
      expect(VipCatalog.first, VipCatalog.vips.first);
    });

    test('I cinquanta VIP portano tutti il loro stem', () {
      expect(VipCatalog.vips, hasLength(50));
      for (final vip in VipCatalog.vips) {
        expect(vip.hasImage, isTrue, reason: 'Stem mancante per ${vip.name}');
      }
    });

    test('Il modello VIP risolve il ritratto bundlato dallo stem', () {
      const senza = Vip(name: 'X', sign: Zodiac.leo, note: 'n');
      expect(senza.hasImage, isFalse);
      expect(senza.thumbPath, isNull);
      expect(senza.fullPath, isNull);
      const con = Vip(
          name: 'Y',
          sign: Zodiac.leo,
          note: 'n',
          stem: 'vip_angelina-jolie_v1');
      expect(con.hasImage, isTrue);
      expect(con.thumbPath,
          'assets/img_thumb/ritratti-vip/vip_angelina-jolie_v1.webp');
      expect(con.fullPath,
          'assets/img/ritratti-vip/vip_angelina-jolie_v1.webp');
    });

    test('Ogni ritratto agganciato esiste come file, piena e miniatura', () {
      for (final vip in VipCatalog.vips) {
        if (vip.hasImage) {
          expect(File(vip.thumbPath!).existsSync(), isTrue,
              reason: 'Miniatura mancante per ${vip.name}: ${vip.thumbPath}');
          expect(File(vip.fullPath!).existsSync(), isTrue,
              reason: 'Ritratto pieno mancante per ${vip.name}: ${vip.fullPath}');
        }
      }
    });
  });

  group('Foto utente, solo in memoria', () {
    test('Scegliere una foto la porta in memoria, toglierla la azzera',
        () async {
      final controller =
          UserPhotoController(service: _FakePhotoService(Uint8List.fromList([1, 2, 3])));
      expect(controller.hasPhoto, isFalse);
      final ok = await controller.pickFrom(UserPhotoSource.gallery);
      expect(ok, isTrue);
      expect(controller.hasPhoto, isTrue);
      controller.clear();
      expect(controller.hasPhoto, isFalse);
    });

    test('Un errore o un rifiuto resta al segnaposto, senza schianti', () async {
      final controller = UserPhotoController(service: _FakePhotoService(null));
      final ok = await controller.pickFrom(UserPhotoSource.camera);
      expect(ok, isFalse);
      expect(controller.hasPhoto, isFalse);
    });
  });

  Future<void> pumpScreen(WidgetTester tester,
      {Zodiac userSign = Zodiac.gemini, UserPhotoController? photo}) async {
    silenceSensors();
    // Superficie alta, cosi' l'intera colonna scorrevole (barre, tasto, picker)
    // e' costruita e trovabile senza scroll manuale.
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
        home: SinastriaVipScreen(userSign: userSign, photoController: photo),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('La schermata mostra il cerchio, il polo VIP e i VIP',
      (tester) async {
    await pumpScreen(tester);
    expect(find.byKey(const Key('sinastria_list')), findsOneWidget);
    expect(find.byKey(const Key('sinastria_gauge')), findsOneWidget);
    expect(find.byKey(const Key('sinastria_pole_vip')), findsOneWidget);
    expect(find.byKey(const Key('sinastria_reading')), findsOneWidget);
    expect(find.byKey(const Key('sinastria_share')), findsOneWidget);
    expect(
        find.byKey(Key('vip_${VipCatalog.first.name}')), findsOneWidget);
  });

  testWidgets('Il responso viene prima delle barre', (tester) async {
    await pumpScreen(tester);
    final readingY = tester
        .getTopLeft(find.byKey(const Key('sinastria_reading')))
        .dy;
    final barsY = tester.getTopLeft(find.text('Scintille')).dy;
    expect(readingY, lessThan(barsY));
  });

  testWidgets('Cambiare VIP aggiorna il cerchio', (tester) async {
    await pumpScreen(tester);
    final other = VipCatalog.vips[2];
    final chip = find.byKey(Key('vip_${other.name}'));
    await tester.ensureVisible(chip);
    await tester.pumpAndSettle();
    await tester.tap(chip);
    await tester.pumpAndSettle();

    final expected = SynastryReport.forPair(Zodiac.gemini, other);
    expect(
      find.descendant(
        of: find.byKey(const Key('sinastria_gauge')),
        matching: find.text('${expected.overall}%'),
      ),
      findsOneWidget,
    );
  });
}

/// Sorgente foto finta per i test: niente camera ne galleria, byte prefissati.
class _FakePhotoService implements UserPhotoService {
  _FakePhotoService(this._bytes);
  final Uint8List? _bytes;

  @override
  Future<Uint8List?> pick(UserPhotoSource source) async => _bytes;
}
