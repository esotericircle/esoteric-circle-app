import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/components/testo_che_si_scrive.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/horoscope/oroscopo_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// L'OROSCOPO E' UN CONSULTO, NON UNA PAGINA GIA' SCRITTA.
///
/// Ordine 2171, voce 5. La schermata si apriva con l'oroscopo gia' composto:
/// sembrava uscito da una macchina, senza studio ne' interpretazione. Un
/// consulto comincia quando qualcuno lo chiede, e mentre il cielo si interroga
/// si vede che sta accadendo qualcosa.
void main() {
  Future<void> apri(WidgetTester tester,
      {bool riduciMovimento = false,
      Zodiac segno = Zodiac.leo}) async {
    tester.view.physicalSize = const Size(440, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => EntitlementService()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => BirthIdentityController()),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx)
              .copyWith(disableAnimations: riduciMovimento),
          child: MaestroScope(child: child!),
        ),
        home: OroscopoScreen(userSign: segno, now: DateTime(2026, 7, 10)),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  testWidgets('all\'apertura l\'oroscopo NON si vede, e c\'e\' il gesto',
      (tester) async {
    await apri(tester);

    expect(find.byKey(const Key('oroscopo_interroga')), findsOneWidget,
        reason: 'manca il gesto che apre il consulto: la schermata torna a '
            'darsi gia\' fatta');
    expect(find.byType(TestoCheSiScrive), findsNothing,
        reason: 'prima del tocco c\'e\' gia\' un responso a schermo: e\' la '
            'pagina uscita dalla macchina, senza nessuno che l\'abbia chiesta');
  });

  testWidgets('il titolo e\' il nome del segno, e sta sopra l\'emblema',
      (tester) async {
    await apri(tester, segno: Zodiac.scorpio);

    final nome = find.byKey(const Key('oroscopo_sign_name'));
    expect(nome, findsOneWidget);
    expect(tester.widget<Text>(nome).data, 'Scorpione');
    final stile = tester.widget<Text>(nome).style!;
    // ignore: avoid_print
    print('OROSCOPO: il nome del segno e\' a ${stile.fontSize} punti');
    expect(stile.fontSize, greaterThanOrEqualTo(30),
        reason: 'il nome del segno non e\' un titolo grande: e\' scritto a '
            '${stile.fontSize} punti');
    expect(tester.getRect(nome).top,
        lessThan(tester.getRect(find.byKey(const Key('oroscopo_emblem'))).top),
        reason: 'il nome del segno sta sotto l\'emblema invece che sopra');
  });

  testWidgets('il sottotitolo SEGUE il periodo scelto', (tester) async {
    await apri(tester);
    String sottotitolo() => tester
        .widget<Text>(find.byKey(const Key('oroscopo_heading')))
        .data!;

    expect(sottotitolo(), 'Oroscopo Personalizzato del giorno');
    // Le altre due strade sono bloccate dal piano, quindi il sottotitolo si
    // misura sul dato, che e' la stessa cosa che la schermata legge.
    expect(HoroscopePeriod.settimana.sottotitolo,
        'Oroscopo Personalizzato della settimana');
    expect(HoroscopePeriod.mese.sottotitolo, 'Oroscopo Personalizzato del mese');
    for (final p in HoroscopePeriod.values) {
      expect(p.sottotitolo.contains(p.label.toLowerCase()), isTrue,
          reason: 'il sottotitolo di ${p.label} non nomina il suo periodo: '
              'una riga che non guarda la scelta prima o poi dice il falso');
    }
  });

  testWidgets('al tocco l\'emblema pulsa, e poi il responso si scrive',
      (tester) async {
    await apri(tester);

    expect(find.byKey(const Key('oroscopo_emblema_pulsa')), findsNothing,
        reason: 'l\'emblema pulsa prima che qualcuno abbia chiesto niente');

    await tester.tap(find.byKey(const Key('oroscopo_interroga')));
    await tester.pump();

    expect(find.byKey(const Key('oroscopo_emblema_pulsa')), findsOneWidget,
        reason: 'al tocco l\'emblema non da\' nessun segno: la persona non '
            'sa se sta succedendo qualcosa');
    expect(find.byKey(const Key('oroscopo_interroga')), findsNothing,
        reason: 'il gesto si puo\' ripetere: il consulto e\' gia\' cominciato');

    // Passata la pulsazione dichiarata, i responsi ci sono e si stanno
    // scrivendo.
    await tester.pump(const Duration(seconds: 3));
    expect(find.byType(TestoCheSiScrive), findsWidgets,
        reason: 'dopo il tocco non compare nessun responso');
    expect(find.byKey(const Key('oroscopo_emblema_pulsa')), findsNothing,
        reason: 'l\'emblema pulsa ancora a interrogazione finita');
  });

  testWidgets('un tocco sul testo lo completa subito', (tester) async {
    await apri(tester);
    await tester.tap(find.byKey(const Key('oroscopo_interroga')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));

    final testo = find.byKey(const Key('oroscopo_testo_generale'));
    expect(testo, findsOneWidget);
    // A meta' scrittura il testo non e' ancora intero.
    await tester.pump(const Duration(milliseconds: 300));
    final scrittura = tester.state<TestoCheSiScriveState>(
        find.descendant(of: testo, matching: find.byType(TestoCheSiScrive)));
    expect(scrittura.staScrivendo, isTrue,
        reason: 'il responso e\' gia\' intero dopo tre decimi: non si sta '
            'scrivendo affatto');

    await tester.tap(testo);
    await tester.pump();
    expect(scrittura.staScrivendo, isFalse,
        reason: 'il tocco non completa il testo: un\'animazione da cui non si '
            'puo\' uscire e\' una gabbia');
  });

  testWidgets('con Riduci Movimento il responso compare intero, senza moto',
      (tester) async {
    await apri(tester, riduciMovimento: true);
    await tester.tap(find.byKey(const Key('oroscopo_interroga')));
    await tester.pump();

    // Nessuna attesa: il testo c'e' subito e per intero.
    final testo = find.descendant(
        of: find.byKey(const Key('oroscopo_testo_generale')),
        matching: find.byType(TestoCheSiScrive));
    expect(testo, findsOneWidget,
        reason: 'con Riduci Movimento il responso non compare: chi ha tolto '
            'le animazioni resta senza oroscopo');
    final scrittura = tester.state<TestoCheSiScriveState>(testo);
    expect(scrittura.staScrivendo, isFalse,
        reason: 'con Riduci Movimento il testo si sta ancora scrivendo');
  });
}
