import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/synastry/collezione_delle_coppie.dart';
import 'package:esoteric_circle/core/synastry/vip_catalog.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/design_system/tokens/color_tokens.dart';
import 'package:esoteric_circle/design_system/tokens/typography_tokens.dart';
import 'package:esoteric_circle/features/synastry/sinastria_gallery_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// LA GALLERIA VIP SI CAPISCE. Ordine del fondatore del 28 agosto 2026.
///
/// **Parole sue, sette rilievi in un messaggio solo**: "elimina la sezione Vip
/// in evidenza che non serve a nulla"; "anziche' usare un pulsante per ogni
/// categoria, usa un unico selettore menu' a tendina Categoria VIP con tutte
/// le opzioni"; "il confronto tra 2 vip lo da' sempre con Angelina Jolie e non
/// ha senso, l'utente fa click sulla carta e puo' cambiare il vip"; "quando
/// l'utente e' in modalita' confronto tra 2 VIP, come fa a tornare a mettere
/// se stesso?"; "la visualizzazione dei vip come le carte mischiate senza
/// ordine e con dimensioni diverse non va bene, non si vedono i nomi dei vip,
/// ma non si riconoscono nemmeno i volti"; il gemello astrale "e' una funzione
/// potenzialmente virale e deve risaltare"; e il confronto fra due VIP "deve
/// essere anche una funzione ben visibile".
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silenzia() {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (c) async => null);
    for (final n in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      m.setMockStreamHandler(
          EventChannel(n), MockStreamHandler.inline(onListen: (a, e) {}));
    }
  }

  Future<void> monta(WidgetTester tester) async {
    silenzia();
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => CollezioneDelleCoppie()),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: MaestroScope(child: child!),
        ),
        home: const SinastriaGalleryScreen(
          userSign: Zodiac.leo,
          userName: 'Mauro',
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('I volti stanno in fila, della stessa misura, col nome leggibile',
      (tester) async {
    // **LA GRANDEZZA MISURATA E' LA DIFFERENZA FRA LE LARGHEZZE**, ed e' cio'
    // che il fondatore ha visto: i ritratti stavano su tre piani di
    // profondita', quindi tre misure diverse, e il nome scendeva fino al 55
    // per cento di opacita' sul piano piu' lontano.
    await monta(tester);
    final larghezze = <double>[];
    final righe = <double>{};
    for (final vip in VipCatalog.vips.take(12)) {
      final f = find.byKey(Key('vip_${vip.name}'));
      if (f.evaluate().isEmpty) continue;
      final r = tester.getRect(f);
      larghezze.add(r.width);
      righe.add(r.top.roundToDouble());
    }
    expect(larghezze.length, greaterThanOrEqualTo(6),
        reason: 'in scena ci sono solo ${larghezze.length} ritratti: la '
            'prova non sta guardando la griglia');
    final piuLarga = larghezze.reduce((a, b) => a > b ? a : b);
    final piuStretta = larghezze.reduce((a, b) => a < b ? a : b);
    // ignore: avoid_print
    print('ORDINE DEL 28 AGOSTO: ${larghezze.length} ritratti in scena, il '
        'piu\' largo ${piuLarga.toStringAsFixed(1)} e il piu\' stretto '
        '${piuStretta.toStringAsFixed(1)} punti, su ${righe.length} righe');
    expect(piuLarga - piuStretta, lessThan(1.0),
        reason: 'i ritratti hanno misure diverse, dal '
            '${piuStretta.toStringAsFixed(1)} al '
            '${piuLarga.toStringAsFixed(1)}: e\' la galleria mischiata che il '
            'fondatore ha fermato');

    // I nomi si leggono: colore pieno, non una velatura.
    final nome = tester.widget<Text>(find.descendant(
        of: find.byKey(Key('vip_${VipCatalog.first.name}')),
        matching: find.text(VipCatalog.first.name)));
    // ignore: avoid_print
    print('ORDINE DEL 28 AGOSTO: il nome del VIP e\' scritto in '
        '${nome.style!.color}');
    expect(nome.style!.color, ColorTokens.textPrimary,
        reason: 'il nome del VIP non e\' a pieno contrasto: e\' per questo '
            'che non si leggeva');
  });

  testWidgets('Le due funzioni virali sono porte grandi, non righe di testo',
      (tester) async {
    // **LA GRANDEZZA MISURATA E' L'ALTEZZA DELLA PORTA E IL CORPO DEL SUO
    // TITOLO.** Erano due pulsanti di testo alti quarantotto punti con
    // l'etichetta a dodici; una funzione che deve risaltare non si scrive
    // cosi'.
    await monta(tester);
    for (final porta in const [
      ('sinastria_cerca_gemello', 'Trova il tuo gemello astrale VIP'),
      ('sinastria_due_vip', 'Confronta 2 VIP'),
    ]) {
      final f = find.byKey(Key(porta.$1));
      expect(f, findsOneWidget, reason: 'la porta ${porta.$1} non c\'e\'');
      final r = tester.getRect(f);
      final titolo = tester.widget<Text>(find.descendant(
          of: f, matching: find.text(porta.$2)));
      // ignore: avoid_print
      print('ORDINE DEL 28 AGOSTO: la porta "${porta.$2}" e\' alta '
          '${r.height.toStringAsFixed(1)} punti e il titolo e\' scritto a '
          '${titolo.style!.fontSize}');
      expect(r.height, greaterThanOrEqualTo(64),
          reason: 'la porta "${porta.$2}" e\' alta '
              '${r.height.toStringAsFixed(1)} punti: non risalta');
      expect(titolo.style!.fontSize,
          greaterThanOrEqualTo(TypographyTokens.titoloScheda().fontSize!),
          reason: 'il titolo di "${porta.$2}" e\' scritto a '
              '${titolo.style!.fontSize}, cioe\' come un\'etichetta');
    }
  });

  testWidgets('Il confronto fra due VIP non parte da un VIP scelto dall\'app',
      (tester) async {
    // **IL DIFETTO ERA UNA RIGA SOLA**: il pulsante chiamava
    // `_sostituisciLaPrimaCasella(VipCatalog.first)`, e il primo del catalogo
    // e' Angelina Jolie. Adesso il tocco apre la scelta.
    await monta(tester);
    await tester.tap(find.byKey(const Key('sinastria_due_vip')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    // ignore: avoid_print
    print('ORDINE DEL 28 AGOSTO: dopo il tocco su "Confronta 2 VIP" la '
        'schermata chiede di scegliere? '
        '${find.text('Scegli il primo dei due VIP').evaluate().isNotEmpty}');
    expect(find.text('Scegli il primo dei due VIP'), findsOneWidget,
        reason: 'il confronto non chiede chi mettere per primo');
    expect(find.byKey(const Key('sinastria_gauge')), findsNothing,
        reason: 'il confronto e\' partito da solo su un VIP che nessuno ha '
            'scelto: era sempre Angelina Jolie');
    // E la via del ritorno a se stessi c'e', in quel momento.
    expect(find.byKey(const Key('sinastria_torna_a_te')), findsOneWidget,
        reason: 'da qui non si torna a mettere se stessi');
  });
}
