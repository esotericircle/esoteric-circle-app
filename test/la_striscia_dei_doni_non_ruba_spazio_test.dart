import 'dart:io';

import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/santuario/daily_strip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LA STRISCIA DEI DONI NON RUBA SPAZIO. Ordine AO voce 03.
///
/// **Il difetto e la sua misura.** Dal collaudo della 2182: la striscia
/// occupa troppo spazio verticale, e quello che si prende lo toglie al cielo
/// e alla carta del Maestro sotto. Misurata prima di toccarla, montandola a
/// tre larghezze vere: **146,0 punti a 360, 390 e 412**, sempre gli stessi,
/// perche' le due costanti dell'altezza valevano 146 tutte e due.
///
/// **Dove stavano i punti, contati e non stimati.** Novantanove alla fila
/// delle icone, e dentro quei novantanove c'era uno SLOT FISSO DI DODICI per
/// il conto alla rovescia del Tramonto, presente sotto OGNI casella anche
/// quando non c'era niente da scrivere: quattro caselle su quattro pagavano
/// lo spazio di un avviso che ne riguardava una sola. Il resto erano quattro
/// stacchi, otto sopra la riga del titolo, sei sotto, e sei piu' sei attorno
/// alla barra di scorrimento.
///
/// **Cosa NON si tocca, ed e' il vincolo di questa voce**: l'area di tocco.
/// Il cerchio dell'icona resta quarantasei e il bersaglio del punto
/// interrogativo resta quarantaquattro per quarantaquattro, che e' la misura
/// minima con cui un dito colpisce senza sbagliare. Si recuperano gli spazi
/// VUOTI, non i bersagli.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// **LA SOGLIA, dichiarata e non indovinata.** Viene dal misurato: 146
  /// prima, meno i dodici dello slot morto e meno dieci dei quattro stacchi
  /// ridotti. Si scrive il tetto e non il numero esatto, perche' un tetto
  /// regge un ritocco della tipografia mentre un'uguaglianza cadrebbe al
  /// primo punto di differenza fra due versioni di Flutter.
  /// **CENTODODICI DALL\'ORDINE CF VOCE 02.** Valeva 126, ed era una
  /// soglia che non sorvegliava piu' niente: la fascia scende a 108, e un
  /// tetto diciotto punti sopra il vero avrebbe lasciato passare in
  /// silenzio un ritorno all\'altezza vecchia. Quattro sopra il misurato,
  /// come la volta scorsa, che e' il margine di un arrotondamento del
  /// testo e non lo spazio per un ripensamento.
  const tetto = 112.0;

  /// Quanto era prima, per non perdere il confronto: 146 nasceva
  /// dall\'ordine AO, 122 e' quello che l\'ordine CF ha trovato e misurato.
  const primaEra = 122.0;

  Future<double> altezzaA(WidgetTester tester, double larghezza) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = Size(larghezza, 900);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MaestroScope(child: child!),
        home: Scaffold(
          body: Column(children: [
            DailyStrip(clock: () => DateTime(2026, 8, 18, 10, 30)),
            const Expanded(child: SizedBox()),
          ]),
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 300));
    return tester
        .getRect(find.byKey(const Key('santuario_daily_strip')))
        .height;
  }

  for (final larghezza in const [360.0, 390.0, 412.0]) {
    testWidgets('a ${larghezza.toInt()} punti la striscia sta sotto il tetto',
        (tester) async {
      final alta = await altezzaA(tester, larghezza);
      // ignore: avoid_print
      print('ORDINE AO VOCE 03: a ${larghezza.toInt()} la striscia e\' alta '
          '$alta, prima era $primaEra');
      expect(alta, lessThanOrEqualTo(tetto),
          reason: 'la striscia e\' alta $alta punti su una larghezza di '
              '${larghezza.toInt()}: sopra il tetto di $tetto, e lo spazio '
              'che si prende lo toglie al cielo e alla carta sotto');
      expect(tester.takeException(), isNull,
          reason: 'la striscia trabocca: l\'altezza e\' stata tolta senza '
              'togliere quello che ci stava dentro');
    });
  }

  testWidgets('l\'area di tocco resta piena', (tester) async {
    await altezzaA(tester, 360);
    // Il cerchio dell'icona: quarantasei, come prima.
    final cerchi = find.byKey(const Key('daily_element_dawn'));
    expect(cerchi, findsOneWidget);
    final bersaglio = find.byKey(const Key('daily_help_target_dawn'));
    final misura = tester.getSize(bersaglio);
    // ignore: avoid_print
    print('ORDINE AO VOCE 03: bersaglio dell\'aiuto $misura');
    expect(misura.width, greaterThanOrEqualTo(44),
        reason: 'il bersaglio dell\'aiuto e\' stato stretto per far posto: '
            'sotto i quarantaquattro punti il dito lo manca');
    expect(misura.height, greaterThanOrEqualTo(44),
        reason: 'il bersaglio dell\'aiuto e\' stato schiacciato in altezza');
  });

  testWidgets('l\'avviso col conto alla rovescia non c\'e\' piu\'',
      (tester) async {
    // **L'AVVISO CHE SE NE VA, e il perche' sta nella premessa P2.** Sotto la
    // casella del Tramonto compariva "tra 1h 20min", e il suo slot da dodici
    // punti era riservato sotto TUTTE le caselle, anche dove non c'era niente
    // da dire. Mauro lo ha chiesto via dal collaudo della 2182. L'orario
    // preciso resta dove si CHIEDE, cioe' dentro la spiegazione che si apre
    // col punto interrogativo, e la prova qui sotto lo verifica.
    await altezzaA(tester, 360);
    for (final elemento in const ['dawn', 'breath', 'oracle', 'rune', 'night']) {
      expect(find.byKey(Key('daily_conto_$elemento')), findsNothing,
          reason: 'sotto la casella $elemento c\'e\' ancora l\'avviso col '
              'conto alla rovescia');
    }
    // **E SI GUARDA ANCHE IL SORGENTE, perche' a schermo questa prova
    // sarebbe compiacente.** Il conto compariva solo prima del tramonto e
    // solo con la posizione nota: in una prova senza posizione non si vede
    // comunque, quindi la ricerca a video da sola passerebbe anche col
    // codice intatto. Qui si pretende che lo slot sia proprio sparito dal
    // sorgente, ed e' lui che occupava i dodici punti sotto ogni casella.
    final sorgente = File('lib/features/santuario/daily_strip.dart')
        .readAsStringSync()
        .split('\n')
        .where((r) => !r.trimLeft().startsWith('//'))
        .join('\n');
    for (final segno in const ['daily_conto_', '_contoTramonto']) {
      expect(sorgente.contains(segno), isFalse,
          reason: 'nel sorgente della striscia vive ancora $segno: lo slot '
              'del conto alla rovescia occupa il suo spazio anche quando non '
              'scrive niente');
    }
  });

  testWidgets('l\'ora del dono si legge ancora, dove si chiede',
      (tester) async {
    await altezzaA(tester, 360);
    await tester.tap(find.byKey(const Key('daily_help_target_dawn')));
    await tester.pump(const Duration(milliseconds: 400));
    final orario = find.textContaining('Alle ');
    expect(orario, findsOneWidget,
        reason: 'tolto l\'avviso, l\'ora del dono non si legge piu\' da '
            'nessuna parte: doveva restare nella spiegazione');
    // ignore: avoid_print
    print('ORDINE AO VOCE 03: nella spiegazione si legge '
        '"${tester.widget<Text>(orario).data}"');
  });

  /// **CHI VEDE POCO INGRANDISCE IL TESTO, E LA FASCIA DEVE SEGUIRLO.**
  /// Ordine CF voce 02.
  ///
  /// Scendere da 122 a 108 ha reso rosse nove prove che montano il Santuario
  /// a `TextScaler.linear(1.6)`: la casella traboccava di quattordici punti,
  /// e misurando si e' scoperto che a 122 il margine era ESATTAMENTE ZERO.
  /// Il tetto qui sopra vale alla scala normale; questa prova sorveglia
  /// l'altra meta' della cosa, cioe' che ingrandendo il testo la fascia
  /// cresca invece di tagliare.
  for (final scala in const [1.0, 1.3, 1.6, 2.0]) {
    testWidgets('a scala $scala la fascia non taglia la casella',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.devicePixelRatio = 3.0;
      tester.view.physicalSize = const Size(1080, 2392);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
        ],
        child: MaterialApp(
          builder: (ctx, child) => MediaQuery(
            data: MediaQuery.of(ctx)
                .copyWith(textScaler: TextScaler.linear(scala)),
            child: MaestroScope(child: child!),
          ),
          home: Scaffold(
            body: Column(children: [
              DailyStrip(clock: () => DateTime(2026, 8, 18, 10, 30)),
              const Expanded(child: SizedBox()),
            ]),
          ),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 300));
      final alta =
          tester.getRect(find.byKey(const Key('santuario_daily_strip'))).height;
      final cella =
          tester.getRect(find.byKey(const Key('daily_element_dawn'))).height;
      // ignore: avoid_print
      print('ORDINE CF VOCE 02: a scala $scala la fascia e\' alta $alta e la '
          'casella $cella');
      expect(tester.takeException(), isNull,
          reason: 'a scala $scala la fascia alta $alta taglia la casella: chi '
              'ingrandisce il testo perde un pezzo dei Doni');
    });
  }
}
