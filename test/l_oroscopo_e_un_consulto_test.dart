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
import 'package:esoteric_circle/core/horoscope/riflessione_del_cielo.dart';
import 'package:esoteric_circle/core/horoscope/horoscope.dart';
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
      {bool riduciMovimento = false, Zodiac segno = Zodiac.leo}) async {
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
          data: MediaQuery.of(ctx).copyWith(disableAnimations: riduciMovimento),
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
    // **E NON SI PORTA CON SE' CIO' CHE NON SI E' LETTO.** Trovato guardando
    // l'anteprima rigenerata: sotto la pagina ancora muta c'era "Porta il tuo
    // cielo di oggi con te" col pulsante Condividi, e la card che ne sarebbe
    // uscita portava i quattro responsi mai comparsi a video. Togliere il
    // testo e lasciare il modo di spedirlo non toglie il difetto, lo nasconde.
    // **LA CHIAVE E' CAMBIATA, ordine CG voci 06 e 08.** Il Condividi
    // adesso viene da AzioniDelResponso, che e' la porta sola per tutte e
    // tredici le arti col responso, e accanto ci sono il Custodisci e il
    // Parlane, che prima qui non esistevano. La chiave vecchia era di
    // questa schermata e basta.
    expect(find.byKey(const Key('responso_condividi')), findsNothing,
        reason: 'prima del consulto si puo\' gia\' condividere l\'oroscopo: '
            'si spedirebbe una lettura che nessuno ha chiesto ne\' letto');

    await tester.tap(find.byKey(const Key('oroscopo_interroga')));
    await tester.pump();
    // **ORDINE BK: dopo il tocco c'e' la riflessione, poi le schede si
    // compongono a CASCATA.** Prima bastava attendere la scrittura; adesso
    // il responso arriva quando i due momenti sono passati e l'ultima
    // scheda ha finito. Il numero viene dal dato e non e' battuto qui.
    await tester.pump(RiflessioneDelCielo.finoAllUltimaScheda(
        HoroscopeDomain.values.length,
        piena: true));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(seconds: 3));
    expect(find.byKey(const Key('responso_condividi')), findsOneWidget,
        reason: 'dopo il consulto non si puo\' piu\' condividere: la '
            'correzione ha tolto la funzione invece di rimandarla');
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
    String sottotitolo() =>
        tester.widget<Text>(find.byKey(const Key('oroscopo_heading'))).data!;

    expect(sottotitolo(), 'Oroscopo Personalizzato del giorno');
    // Le altre due strade sono bloccate dal piano, quindi il sottotitolo si
    // misura sul dato, che e' la stessa cosa che la schermata legge.
    expect(HoroscopePeriod.settimana.sottotitolo,
        'Oroscopo Personalizzato della settimana');
    expect(
        HoroscopePeriod.mese.sottotitolo, 'Oroscopo Personalizzato del mese');
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
    // **L'EMBLEMA SI GUARDA SUBITO, ordine BK.** Qui NON si aspetta: la
    // pretesa e' che il segno di "sta succedendo qualcosa" arrivi al tocco,
    // e un'attesa messa prima di questa riga la renderebbe cieca.
    expect(find.byKey(const Key('oroscopo_emblema_pulsa')), findsOneWidget,
        reason: 'al tocco l\'emblema non da\' nessun segno: la persona non '
            'sa se sta succedendo qualcosa');
    expect(find.byKey(const Key('oroscopo_interroga')), findsNothing,
        reason: 'il gesto si puo\' ripetere: il consulto e\' gia\' cominciato');

    // Passata la riflessione e la cascata, i responsi ci sono. Il numero
    // viene dal dato e non e' battuto qui.
    await tester.pump(RiflessioneDelCielo.finoAllUltimaScheda(
        HoroscopeDomain.values.length,
        piena: true));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(TestoCheSiScrive), findsWidgets,
        reason: 'dopo il tocco non compare nessun responso');
    expect(find.byKey(const Key('oroscopo_emblema_pulsa')), findsNothing,
        reason: 'l\'emblema pulsa ancora a interrogazione finita');
  });

  testWidgets('un tocco sul testo lo completa subito', (tester) async {
    await apri(tester);
    await tester.tap(find.byKey(const Key('oroscopo_interroga')));
    await tester.pump();
    // **QUI SI ASPETTA LA RIFLESSIONE E NON LA CASCATA, ordine BK.** Questa
    // prova pretende di cogliere il responso MENTRE si scrive: attendere fino
    // alla fine della composizione lo troverebbe gia' finito, e la prova
    // direbbe "non si sta scrivendo" per il motivo sbagliato. Si arriva
    // all'istante in cui la prima scheda nasce e comincia.
    await tester.pump(RiflessioneDelCielo.intera(piena: true));
    await tester.pump(const Duration(milliseconds: 50));

    final testo = find.byKey(const Key('oroscopo_testo_generale'));
    expect(testo, findsOneWidget);
    // ORDINE A: il responso non e' piu' un blocco solo ma una fila di
    // paragrafi, quindi i widget di scrittura sono tanti quanti loro e si
    // guarda l'insieme. Il primo e' quello che batte.
    await tester.pump(const Duration(milliseconds: 300));
    final scritture = tester
        .stateList<TestoCheSiScriveState>(
            find.descendant(of: testo, matching: find.byType(TestoCheSiScrive)))
        .toList();
    expect(scritture, isNotEmpty,
        reason: 'il responso non ha nessun paragrafo che si scrive');
    expect(scritture.any((s) => s.staScrivendo), isTrue,
        reason: 'il responso e\' gia\' intero dopo tre decimi: non si sta '
            'scrivendo affatto');

    await tester.tap(testo);
    await tester.pump();
    expect(scritture.every((s) => !s.staScrivendo), isTrue,
        reason: 'il tocco non completa il testo: un\'animazione da cui non si '
            'puo\' uscire e\' una gabbia, e con i paragrafi sarebbe una gabbia '
            'con tre porte');
  });

  testWidgets('con Riduci Movimento il responso compare intero, senza moto',
      (tester) async {
    await apri(tester, riduciMovimento: true);
    await tester.tap(find.byKey(const Key('oroscopo_interroga')));
    await tester.pump();
    // **ORDINE BK: dopo il tocco c'e' la riflessione, poi le schede si
    // compongono a CASCATA.** Prima bastava attendere la scrittura; adesso
    // il responso arriva quando i due momenti sono passati e l'ultima
    // scheda ha finito. Il numero viene dal dato e non e' battuto qui.
    await tester.pump(RiflessioneDelCielo.finoAllUltimaScheda(
        HoroscopeDomain.values.length,
        piena: true));
    await tester.pump(const Duration(milliseconds: 200));

    // Nessuna attesa: il testo c'e' subito e per intero.
    final testo = find.descendant(
        of: find.byKey(const Key('oroscopo_testo_generale')),
        matching: find.byType(TestoCheSiScrive));
    expect(testo, findsWidgets,
        reason: 'con Riduci Movimento il responso non compare: chi ha tolto '
            'le animazioni resta senza oroscopo');
    final scritture = tester.stateList<TestoCheSiScriveState>(testo).toList();
    expect(scritture.every((s) => !s.staScrivendo), isTrue,
        reason: 'con Riduci Movimento il testo si sta ancora scrivendo');
  });
}
