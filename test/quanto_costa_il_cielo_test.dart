import 'package:esoteric_circle/core/arts/arti_preferite.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/settings/settings_controller.dart';
import 'package:esoteric_circle/design_system/components/cosmos_background.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/santuario/greeting_controller.dart';
import 'package:esoteric_circle/features/santuario/santuario_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// QUANTO COSTA IL CIELO, misurato e non discusso. Ordine AQ voce 01.
///
/// **Perche' questo file esiste.** Mauro dice che il cosmo va a scatti e che
/// sulla 2181 non lo faceva. Fra la 2181 e oggi il file del cielo e' cambiato
/// UNA volta sola, con l'ordine AO voce 07, che ha aggiunto lo stato calcolato
/// e la sentinella. Questo e' un sospetto, non una causa: qui si misura.
///
/// **Cosa misura, e cosa non puo' misurare.** Il tempo per fotogramma in una
/// prova headless non e' il tempo del telefono: non c'e' la GPU, e il disegno
/// passa dal software. Quello che il numero dice bene e' lo SCARTO fra due
/// teste dello stesso codice misurate nello stesso modo, ed e' esattamente la
/// domanda dell'ordine: la 2181 e oggi.
///
/// Si stampa sempre, anche quando passa: e' uno strumento di misura, e un
/// numero che non si vede non serve a nessuno.
/// **LE SOGLIE NASCONO DAL MISURATO, il 19 agosto 2026, e non da un'idea.**
/// Tre giri per numero, su questa macchina, in microsecondi per fotogramma:
///
/// - cielo da freddo: oggi 1271, 1204, 1210; sulla 2181 1050, 1077, 1216
/// - cielo dopo un giro sotto una rotta opaca: oggi 804, 779, 797; 2181 810,
///   752, 816
/// - home ferma: oggi 8880, 8531, 8758; sulla 2181 8036, 8976, 8557
/// - home mentre si scorre: oggi 12375; sulla 2181 11756
///
/// **Il verdetto: nessuno scarto.** Le due teste misurano lo stesso, e dove
/// c'e' una differenza sta dentro la variazione fra tre giri della STESSA
/// testa. La premessa P3 dell'ordine, che accusava la sentinella, e' falsa:
/// in dieci secondi la sentinella non ha dovuto riaccendere il cielo
/// nemmeno una volta.
///
/// Le soglie qui sotto stanno al doppio abbondante del misurato: servono a
/// far cadere una REGRESSIONE vera, non a fotografare la macchina di oggi,
/// che e' piu' lenta o piu' veloce a seconda di cosa sta facendo.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Il tetto del cielo da solo: misurato 1200, tetto 3000.
  const double tettoDelCielo = 3000;

  /// Il tetto della home ferma: misurato 8700, tetto 20000.
  const double tettoDellaHome = 20000;

  /// Il tetto della home mentre il dito scorre: misurato 12400, tetto 26000.
  const double tettoDelloScorrimento = 26000;

  /// Monta il cielo dentro una rotta vera, perche' `ModalRoute.of` esista:
  /// senza rotta il cielo prende la scorciatoia e la misura direbbe di un
  /// caso che nell'app non capita mai.
  Future<void> montaIlCielo(WidgetTester tester,
      {required bool conRotta}) async {
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(360 * 3, 797 * 3);
    addTearDown(tester.view.reset);
    final cielo = MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MaestroScope(child: child!),
        home: const Scaffold(
          body: CosmosBackground(
            seed: 13,
            child: Center(child: Text('contenuto')),
          ),
        ),
      ),
    );
    await tester.pumpWidget(conRotta
        ? cielo
        : MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => MaestroController()),
              ChangeNotifierProvider(create: (_) => ParallaxController()),
              ChangeNotifierProvider(create: (_) => QualityTierController()),
            ],
            child: const MaestroScope(
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: CosmosBackground(seed: 13, child: SizedBox()),
              ),
            ),
          ));
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// Il tempo medio di un fotogramma, in microsecondi, su `quanti` fotogrammi.
  /// I primi si buttano: il primo giro paga la cache dei teli, che nell'app
  /// si paga una volta sola e non a ogni fotogramma.
  Future<double> microsecondiPerFotogramma(WidgetTester tester,
      {int scaldata = 20, int quanti = 120}) async {
    for (var i = 0; i < scaldata; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    final cronometro = Stopwatch()..start();
    for (var i = 0; i < quanti; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    cronometro.stop();
    return cronometro.elapsedMicroseconds / quanti;
  }

  testWidgets('il fotogramma del cielo, da freddo', (tester) async {
    await montaIlCielo(tester, conRotta: true);
    final us = await microsecondiPerFotogramma(tester);
    // ignore: avoid_print
    print('MISURA AQ.01 freddo: ${us.toStringAsFixed(0)} us per fotogramma');
    expect(us, lessThan(tettoDelCielo),
        reason: 'il cielo da freddo costa ${us.toStringAsFixed(0)} us contro '
            'i 1200 misurati il 19 agosto: nel cammino per fotogramma e\' '
            'entrato qualcosa');
  });

  testWidgets('il fotogramma del cielo, dopo un giro sotto una rotta opaca',
      (tester) async {
    // Il caso di Mauro: si apre un'arte, si torna in home. La rotta opaca
    // sopra ferma il giro, e al ritorno lo stato deve tornare quello di
    // prima: se qualcosa resta acceso, il costo si vede qui.
    await montaIlCielo(tester, conRotta: true);
    final chiave = tester.firstElement(find.byType(CosmosBackground));
    final navigatore = Navigator.of(chiave);
    navigatore.push(MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('un\'arte'))));
    // Niente `pumpAndSettle`: il cielo gira per sempre e non si posa mai,
    // quindi si aspetta a fotogrammi contati, come fa l'app.
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    navigatore.pop();
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    final us = await microsecondiPerFotogramma(tester);
    // ignore: avoid_print
    print('MISURA AQ.01 dopo un giro: ${us.toStringAsFixed(0)} us per '
        'fotogramma');
    expect(us, lessThan(tettoDelCielo),
        reason: 'tornare da una scena aperta lascia il cielo piu\' caro di '
            'prima: ${us.toStringAsFixed(0)} us contro gli 800 misurati');
  });

  testWidgets('quante volte batte la sentinella in dieci secondi',
      (tester) async {
    // La sentinella non deve costare niente quando tutto va bene: se il giro
    // e' gia' acceso non fa nulla, e le ripartenze restano zero.
    CosmosBackground.ripartenzeDellaSentinella = 0;
    await montaIlCielo(tester, conRotta: true);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    // ignore: avoid_print
    print('MISURA AQ.01 ripartenze della sentinella in 10 s: '
        '${CosmosBackground.ripartenzeDellaSentinella}');
    expect(CosmosBackground.ripartenzeDellaSentinella, 0,
        reason: 'la sentinella ha dovuto rimettere in moto il cielo in una '
            'scena dove niente lo ferma: qualcosa lo spegne da solo');
  });

  testWidgets('il fotogramma della HOME, cioe\' quello che Mauro guarda',
      (tester) async {
    // **LA MISURA CHE CONTA.** Il cielo da solo dice poco: la persona guarda
    // la home intera, col carosello, la barra e la striscia dei doni. Qui si
    // monta la home vera e si misura lo stesso numero, cosi' il confronto
    // con la 2181 e' fra due cose uguali.
    SharedPreferences.setMockInitialValues(const {});
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(360 * 3, 797 * 3);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => GreetingController()),
        ChangeNotifierProvider(create: (_) => SettingsController()),
        ChangeNotifierProvider(create: (_) => EntitlementService()),
        ChangeNotifierProvider(create: (_) => QuestionAllowance()),
        ChangeNotifierProvider(create: (_) => ArtiPreferiteController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        // **NIENTE `disableAnimations`**: spegnere il movimento qui vorrebbe
        // dire misurare una home ferma, cioe' non misurare niente.
        builder: (ctx, child) => MaestroScope(child: child!),
        home: const SantuarioScreen(),
      ),
    ));
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    final us = await microsecondiPerFotogramma(tester);
    // ignore: avoid_print
    print('MISURA AQ.01 home: ${us.toStringAsFixed(0)} us per fotogramma');
    expect(us, lessThan(tettoDellaHome),
        reason: 'la home costa ${us.toStringAsFixed(0)} us per fotogramma '
            'contro gli 8700 misurati sulla 2181 e su oggi');
  });

  testWidgets('il fotogramma della home MENTRE SI SCORRE', (tester) async {
    // **LA CONDIZIONE IN CUI MAURO GUARDA DAVVERO.** Una home ferma non dice
    // niente sugli scatti: gli scatti si vedono col dito sullo schermo.
    // Dall'ordine AO voce 02 sopra tutta l'app vivono due ascoltatori, uno
    // per i tocchi e uno per gli scorrimenti, che servono a ritirare la barra
    // sottile: se costano, costano QUI e non da fermi.
    SharedPreferences.setMockInitialValues(const {});
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(360 * 3, 797 * 3);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => GreetingController()),
        ChangeNotifierProvider(create: (_) => SettingsController()),
        ChangeNotifierProvider(create: (_) => EntitlementService()),
        ChangeNotifierProvider(create: (_) => QuestionAllowance()),
        ChangeNotifierProvider(create: (_) => ArtiPreferiteController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (ctx, child) => MaestroScope(child: child!),
        home: const SantuarioScreen(),
      ),
    ));
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    // Il dito scende e risale al centro dello schermo, come chi guarda la
    // home: si misura il tempo dei fotogrammi mentre il dito e' giu'.
    final gesto = await tester.startGesture(const Offset(180, 400));
    await tester.pump(const Duration(milliseconds: 16));
    final cronometro = Stopwatch()..start();
    const passi = 60;
    for (var i = 0; i < passi; i++) {
      // **UNO SCORRIMENTO VERO, non un tremolio.** Alternando su e giu' il
      // dito non supera mai la soglia dello scorrimento, e al rilascio il
      // gesto viene letto come un TOCCO: la prima misura apriva una scheda
      // e cadeva dopo aver stampato il numero.
      await gesto.moveBy(const Offset(0, -3));
      await tester.pump(const Duration(milliseconds: 16));
    }
    cronometro.stop();
    await gesto.up();
    await tester.pump(const Duration(milliseconds: 16));
    final us = cronometro.elapsedMicroseconds / passi;
    // ignore: avoid_print
    print('MISURA AQ.01 home mentre si scorre: ${us.toStringAsFixed(0)} us '
        'per fotogramma');
    expect(us, lessThan(tettoDelloScorrimento),
        reason: 'scorrere la home costa ${us.toStringAsFixed(0)} us per '
            'fotogramma contro i 12400 misurati: i due ascoltatori messi '
            'sopra tutta l\'app sono diventati cari');
  });

  testWidgets('il cielo si ferma anche ad app ancora a schermo',
      (tester) async {
    // **LA MISURA CHE CERCA IL SINTOMO DI MAURO**, cioe' un cielo che si
    // ferma e riparte. Dall'ordine AO voce 07 il giro richiede che il ciclo
    // di vita sia `resumed`. Su Android `inactive` NON vuol dire che l'app e'
    // sparita: arriva a schermo acceso e app visibile, per esempio quando
    // scende il pannello delle notifiche, quando compare un avviso di
    // sistema o durante certe transizioni. Prima di AO.07 il ciclo di vita
    // non entrava nella decisione e il cielo girava lo stesso.
    bool gira() {
      final stato =
          tester.state(find.byType(CosmosBackground, skipOffstage: false));
      // ignore: invalid_use_of_protected_member, avoid_dynamic_calls
      return (stato as dynamic).girDavvero as bool;
    }

    await montaIlCielo(tester, conRotta: true);
    expect(gira(), isTrue, reason: 'il cielo non gira nemmeno da fermo');

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump(const Duration(milliseconds: 16));
    final giraDaInattivo = gira();
    // ignore: avoid_print
    print('MISURA AQ.01 il cielo gira con lo stato inactive: $giraDaInattivo');

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(const Duration(milliseconds: 16));
    final giraDaSospeso = gira();
    // ignore: avoid_print
    print('MISURA AQ.01 il cielo gira con lo stato paused: $giraDaSospeso');

    expect(giraDaSospeso, isFalse,
        reason: 'il cielo gira con la app sospesa: lavoro per nessuno');
    expect(giraDaInattivo, isTrue,
        reason: 'il cielo si ferma mentre la app e ANCORA A SCHERMO: su '
            'Android lo stato inactive arriva col pannello delle notifiche, '
            'con gli avvisi di sistema e in certe transizioni, e ogni volta '
            'il cosmo si inchioda fino al battito successivo della '
            'sentinella, che puo arrivare due secondi dopo. E il fermarsi e '
            'ripartire che Mauro vede');
  });
}
