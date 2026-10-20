import 'dart:io';

import 'package:esoteric_circle/core/entitlement/il_consenso_della_spesa.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/plan_catalog.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/tarot/stesa_tre_carte_screen.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:esoteric_circle/design_system/components/riga_del_residuo.dart';
import 'package:esoteric_circle/core/entitlement/budget_del_giorno.dart';

/// IL GATING DELLA STESA. Ordine BN voce 09.
///
/// **La premessa dell'ordine era falsa su un punto, e la prova misura il
/// vero.** L'ordine chiedeva "uno al giorno per il Viandante, senza limite
/// dagli altri piani", citando dal Briefing Progetto la frase "una carta di
/// tarocchi al giorno". Quella frase e' la riga `Tarocchi carta singola`. La
/// stesa a tre carte sta sull'ALTRA riga, `Stese complete tarocchi`, perche'
/// il briefing dice "carta singola quotidiana e stese complete, dalla tre
/// carte alla Croce Celtica": la tre carte e' la piu' piccola delle stese
/// complete. Quella riga promette Eos pieno, Eos scontati, cinque al giorno,
/// illimitate. Le due misure dell'ordine che dipendevano dal numero sbagliato
/// (la prima gratis per il Viandante, nessun conto dall'Iniziato) sono qui
/// nella forma che il listino regge davvero, e la sostituzione e' dichiarata.
///
/// Quello che NON cambia e' la macchina: budget proprio, consumo una volta
/// sola a stesa compiuta, conto dichiarato prima, due strade a riserva finita,
/// riscatto che conosce il budget nuovo.
///
/// **ORDINE GA VOCE 02, 20 ottobre 2026, sera.** Il fondatore: *"Limitiamo
/// la stesa tarocchi a 10 carte: sarà disponibile solo per Tier 2 e 3 e solo
/// 1 al giorno."* Con la scelta "Carte dal corpus" (in ogni stesa il modello
/// scrive il solo responso principale) una stesa costa circa 0,0020 dollari,
/// e nel 30 per cento del netto entrano 1, 3, 4 e 5 stese al giorno
/// (`tool/i_limiti_degli_annuali.py`). Con la decisione del 20 ottobre 2026
/// l'Adepto ne ha tre, perche' il server ha un tetto solo per il mensile e
/// per l'annuale: 1, 3, 3 e 5. I numeri di questa prova seguono; la
/// stesa a dieci, una al giorno, ha la sua prova,
/// `test/la_croce_celtica_una_al_giorno_test.dart`.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  void silenzia() {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (call) async => null);
    for (final nome in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      m.setMockStreamHandler(
          EventChannel(nome), MockStreamHandler.inline(onListen: (a, e) {}));
    }
  }

  // --- IL DATO: il budget, il conto, il consumo, il riscatto ---

  // **LA CARTA SINGOLA E' UNA CARTA ESTRATTA, ordine EX voce 02.** Questa
  // prova pretendeva che le due righe fossero diverse (1, 3, 30, 50 contro 1,
  // 4, 7, 20). La riga "Tarocchi carta singola" non esiste piu': la carta
  // singola e' una stesa da una carta e conta fra le carte estratte. La
  // pretesa equivalente e' che sia UNA riga sola, quella delle carte, e che
  // la stesa la legga dal listino.
  //
  // **LE STESE, NON LE CARTE, ordine GA voce 01**, 20 ottobre 2026: il
  // fondatore, "bisogna tornare a conteggio per stesa e non per numero di
  // carte". La riga resta una sola, e adesso conta le stese: 1, 3, 2 e 3 al
  // giorno, i numeri che entrano nel 30 per cento (voce GA.02).
  test(
      'la stesa e la carta singola leggono la stessa riga, quella delle '
      'stese di tarocchi', () {
    const ordine = [Tier.free, Tier.tier1, Tier.tier2, Tier.tier3];
    final singola = [
      for (final t in ordine)
        PlanCatalog.limiteGiornaliero(PlanCatalog.rigaCartaSingola, t)
    ];
    final complete = [
      for (final t in ordine)
        PlanCatalog.limiteGiornaliero(PlanCatalog.rigaStese, t)
    ];
    // Ordine GA voce 01: le stese, 1, 3, 2 e 3 (dall'ordine EX voce 02 erano
    // le carte estratte, 3, 6, 10 e 15; prima ancora le stese 1, 4, 7 e 20).
    // Ordine GA voce 02: 1, 3, 4 e 5, col solo responso principale.
    // Ordine GA, decisione del 20 ottobre 2026: 1, 3, 3 e 5, perche' il
    // server ha un tetto solo per i due cicli, e con quattro l'annuale
    // dell'Adepto saliva al 30,08 per cento del netto.
    expect(complete, [1, 3, 3, 5],
        reason: 'la riga delle stese non promette piu\' quello che il conto '
            'del 30 per cento regge: una, tre, quattro e cinque stese, e '
            'niente di illimitato');
    // Ordine EX voce 02: la carta singola non ha piu' un numero suo.
    expect(PlanCatalog.rigaCartaSingola, PlanCatalog.rigaStese,
        reason: 'la carta singola ha di nuovo una riga a se\': sarebbe un '
            'secondo conto delle stesse carte');
    expect(singola, complete);
    expect(PlanCatalog.matrix.where((r) => r.label == 'Tarocchi carta singola'),
        isEmpty,
        reason: 'la riga della carta singola e\' tornata nella matrice');
    expect(
        PlanCatalog.matrix
            .firstWhere((r) => r.chiave == RigaDelPiano.stese)
            .label,
        // Ordine GA voce 01: era 'Carte estratte nelle stese'.
        'Stese di tarocchi',
        reason: 'la riga dice carte mentre conta le stese');

    final borsa = QuestionAllowance();
    for (var i = 0; i < 4; i++) {
      expect(borsa.limiteStese(ordine[i]), complete[i],
          reason: 'il borsellino non legge il limite dal listino');
    }
  });

  // Ordine EX voce 02: il consumo non e' piu' uno per stesa ma una unita' per
  // carta, e il cancello vuole tutte le carte della stesa.
  //
  // **Ordine GA voce 01: il consumo torna a una stesa per stesa.** La prova
  // misura che ogni stesa toglie esattamente uno, che il cancello si chiude
  // sull'ultima e non prima, e che a zero non si apre piu' niente.
  test('il consumo e\' a stese, e il conto cala solo quando cala', () async {
    final borsa = QuestionAllowance();
    // L'Adepto ha tre stese al giorno, ordine GA, decisione del 20 ottobre
    // 2026, in entrambi i cicli (quattro dalla voce GA.02, due dalla voce
    // GA.01, dieci carte dall'ordine EX voce 02, sette stese dall'ordine BV
    // voce 03).
    expect(borsa.steseRimaste(Tier.tier2), 3);
    expect(borsa.puoiStendere(Tier.tier2), isTrue);
    // Una stesa consuma una stesa, non le sue carte.
    borsa.registraStesa(Tier.tier2);
    expect(borsa.steseRimaste(Tier.tier2), 2,
        reason: 'una stesa ha tolto piu\' o meno di una stesa');
    borsa.registraStesa(Tier.tier2);
    expect(borsa.steseRimaste(Tier.tier2), 1);
    expect(borsa.puoiStendere(Tier.tier2), isTrue,
        reason: 'con una stesa rimasta il cancello e\' gia\' chiuso');
    borsa.registraStesa(Tier.tier2);
    expect(borsa.steseRimaste(Tier.tier2), 0);
    expect(borsa.puoiStendere(Tier.tier2), isFalse,
        reason: 'a stese finite il cancello si apre lo stesso');
    // Il conto non va sotto zero: una stesa in piu' registrata per sbaglio
    // non mostra un residuo negativo.
    borsa.registraStesa(Tier.tier2);
    expect(borsa.steseRimaste(Tier.tier2), 0);
    expect(borsa.riscattiPerLaStesa(Tier.tier2), 1,
        reason: 'a stese finite serve un riscatto, uno solo');
  });

  // Ordine EX voce 02: quindici carte all'Illuminato, erano venti stese.
  // Ordine GA voce 01: tre stese all'Illuminato. Ordine GA voce 02: cinque.
  test('l\'Illuminato ha cinque stese, e niente e\' piu\' illimitato', () {
    // **L'ILLIMITATO E' SPARITO, ordine BV voce 03**, ed e' un principio del
    // fondatore prima che un numero: non fare nulla di illimitato. Prima
    // l'Illuminato non aveva ne' conto ne' cancello; adesso ha un numero al
    // giorno e lo vede scendere come tutti.
    final borsa = QuestionAllowance();
    expect(borsa.limiteStese(Tier.tier3), 5);
    expect(borsa.steseRimaste(Tier.tier3), 5);
    borsa.registraStesa(Tier.tier3);
    // Ordine GA voce 01: una stesa ne toglie una (dall'ordine EX una stesa a
    // tre carte ne toglieva tre).
    expect(borsa.steseRimaste(Tier.tier3), 4);
    expect(borsa.puoiStendere(Tier.tier3), isTrue);
    for (var i = 0; i < 4; i++) {
      borsa.registraStesa(Tier.tier3);
    }
    expect(borsa.puoiStendere(Tier.tier3), isFalse,
        reason: 'l\'Illuminato ha un tetto, e alla quinta stesa ci arriva');
  });

  test('le stese e le gettate sono due budget che non si toccano', () async {
    // Le due strade nello stesso giorno, sullo stesso Viandante: la stesa la
    // compra con gli Eos, la gettata ce l'ha gratis. Consumarne una non deve
    // togliere l'altra.
    final porta = _PortaDelDenaro(saldoIniziale: 400);
    final borsa = QuestionAllowance(porta: porta);
    await borsa.sincronizza();

    // **LA STESA DEL GIORNO PRIMA, POI GLI EOS.** Ordine BU voce 04: il
    // Viandante ne ha una compresa, e il cancello si apre dopo quella.
    expect(borsa.puoiStendere(Tier.free), isTrue,
        reason: 'il Viandante ha una stesa al giorno, e questa e\' la sua');
    borsa.registraStesa(Tier.free);
    expect(borsa.puoiStendere(Tier.free), isFalse,
        reason: 'finita la stesa del giorno il Viandante le compra');
    expect(
        await borsa.riscatta('stese',
            consenso: ConsensoDellaSpesa.perLeProve(150)),
        150);
    expect(borsa.puoiStendere(Tier.free), isTrue);

    // La gettata di rune del giorno: e' l'altro budget.
    borsa.registraGettata(Tier.free);
    expect(borsa.puoiGettare(Tier.free), isFalse);
    expect(borsa.puoiStendere(Tier.free), isTrue,
        reason: 'la gettata ha mangiato la stesa riscattata: sono finite '
            'sullo stesso contatore');

    // E nell'altro verso: consumare la stesa non ridà né toglie gettate.
    borsa.registraStesa(Tier.free);
    expect(borsa.puoiStendere(Tier.free), isFalse,
        reason: 'il credito comprato non si e\' consumato: sarebbe infinito');
    expect(borsa.puoiGettare(Tier.free), isFalse);
  });

  test('il riscatto della stesa paga il prezzo del server', () async {
    final porta = _PortaDelDenaro(saldoIniziale: 400);
    final borsa = QuestionAllowance(porta: porta);
    await borsa.sincronizza();
    expect(borsa.prezzoDelRiscatto('stese'), 150,
        reason: 'il prezzo della stesa non arriva piu\' dal listino del '
            'server: una cifra scritta nel client non e\' un prezzo');
    expect(
        await borsa.riscatta('stese',
            consenso: ConsensoDellaSpesa.perLeProve(150)),
        150);
    expect(borsa.saldoEos, 250);
  });

  // --- LA SCENA: il conto detto prima, e le due strade ---

  Widget attorno(Widget scena,
          {required Tier piano, required QuestionAllowance borsa}) =>
      MultiProvider(
        // **LA CHIAVE SUL GUSCIO, e non solo sulla scena.** Rimontando lo
        // stesso albero con un piano diverso, Flutter aggiorna gli elementi
        // gia' vivi invece di crearne di nuovi: il `create` del provider non
        // viene chiamato una seconda volta e il piano resta quello di prima.
        // Trovato eseguendo: la prova leggeva il conto dell'Adepto mentre
        // chiedeva quello dell'Illuminato.
        key: ValueKey(piano),
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
          ChangeNotifierProvider(
              create: (_) => EntitlementService(initial: piano)),
          ChangeNotifierProvider<QuestionAllowance>.value(value: borsa),
        ],
        child: MediaQuery(
          data: const MediaQueryData(),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: MaestroScope(child: scena),
          ),
        ),
      );

  Future<void> monta(WidgetTester tester,
      {required Tier piano, required QuestionAllowance borsa}) async {
    silenzia();
    tester.view.physicalSize = const Size(360, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(attorno(
      StesaTreCarteScreen(
        key: UniqueKey(),
        seed: 2,
        skipIntro: true,
        topic: TarotTopic.bivio,
      ),
      piano: piano,
      borsa: borsa,
    ));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
  }

  /// **IL CANCELLO STA SUL PULSANTE, E IL PULSANTE STA DOPO LE CARTE.**
  /// Ordine CQ voce 1.03, 3 settembre 2026, e ribalta l'ordine CO voce 07.
  ///
  /// CO.07 aveva spostato il cancello dal primo tocco al pulsante, e il
  /// pulsante stava PRIMA delle carte. Adesso il ventaglio e' vivo da subito e
  /// il pulsante sta DOPO: si sceglie senza pagare, si paga per leggere. Il
  /// cancello resta uno solo e si guarda qui.
  ///
  /// Torna vero se la lettura si e' aperta. Falso vuol dire che il cancello ha
  /// sbarrato, ed e' un esito legittimo che alcune di queste prove
  /// pretendono.
  Future<bool> apri(WidgetTester tester) async {
    final pulsante = find.byKey(const Key('stesa_inizia'));
    for (var i = 0; i < 40; i++) {
      if (pulsante.evaluate().isNotEmpty &&
          tester.widget<FilledButton>(pulsante).onPressed != null) {
        break;
      }
      await tester.pump(const Duration(milliseconds: 200));
    }
    if (pulsante.evaluate().isEmpty) return true;
    await tester.tap(pulsante, warnIfMissed: false);
    await tester.pump();
    // **SI ASPETTA CHE MEDORA ABBIA FINITO DI PENSARE.** Il responso non
    // arriva col tocco: fra il pulsante e le carte a video c'e' la scena
    // dell'attesa, e tre secondi non bastano. Il ciclo si ferma appena la
    // scena e' arrivata, cosi' non costa tempo quando non serve.
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.byKey(const Key('stesa_blocco_carte')).evaluate().isNotEmpty ||
          find.byKey(const Key('upgrade_invite')).evaluate().isNotEmpty) {
        break;
      }
    }
    return find.byKey(const Key('stesa_inizia')).evaluate().isEmpty;
  }

  Future<void> pesca(WidgetTester tester, int indice) async {
    final carta = find.byKey(Key('stesa_fan_$indice'));
    expect(carta, findsOneWidget,
        reason: 'la carta $indice non e\' nell\'arco');
    final r = tester.getRect(carta);
    await tester.tapAt(Offset(r.left + 6, r.center.dy));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
  }

  /// Le tre carte, e poi il pulsante. Torna cio' che torna [apri].
  Future<bool> stendiEApri(WidgetTester tester) async {
    for (final indice in const [38, 39, 40]) {
      await pesca(tester, indice);
    }
    return apri(tester);
  }

  /// **IL CONTO ADESSO E' LA RIGA COMUNE, ordine CF voce 11.** La stesa
  /// aveva un contatore scritto per lei sola, `_ContoDelleStese`, che
  /// diceva la stessa cosa con parole sue e non conosceva la legge del
  /// silenzio. Adesso monta `RigaDelResiduo`, come tutti gli altri cinque
  /// budget, e la sua chiave e' quella comune.
  String contoAVideo(WidgetTester tester) {
    final conto = find.byKey(RigaDelResiduo.chiaveDi(BudgetDelGiorno.stese));
    if (conto.evaluate().isEmpty) return '';
    final testi = find
        .descendant(of: conto, matching: find.byType(Text))
        .evaluate()
        .map((e) => (e.widget as Text).data ?? '')
        .where((t) => t.isNotEmpty);
    return testi.isEmpty ? '' : testi.first;
  }

  testWidgets('il conto e\' quello del listino, e cambia col piano',
      (tester) async {
    await monta(tester,
        piano: Tier.tier2, borsa: QuestionAllowance()..ilServerHaParlato());
    // **LA DOTAZIONE E NON IL RESIDUO, ordine CO voce 11.** A giornata
    // appena aperta la riga dice quanto hai, non quanto ti resta: il
    // fondatore ha letto "Ti restano 50 su 50" e restare davanti a un
    // budget intero e' una tautologia. Il numero che il listino promette
    // e' lo stesso, ed e' quello che questa riga sorveglia.
    //
    // Ordine EX voce 02: il conto e' di CARTE, e la riga deve dirlo. Dire
    // "Oggi hai 10 stese" a chi ha dieci carte, cioe' tre stese a tre carte,
    // e' il falso; al Viandante "3 stese" quando ne ha una.
    //
    // Ordine GA voce 01: il conto torna di STESE, e la riga dice stese. Dire
    // "Oggi hai 2 carte" a chi ha due stese da stendere come vuole e' il
    // falso di adesso.
    // Ordine GA voce 02: quattro stese all'Adepto (erano due). Ordine GA,
    // decisione del 20 ottobre 2026: tre, in entrambi i cicli.
    expect(contoAVideo(tester), 'Oggi hai 3 stese',
        reason: 'il numero, o la cosa contata, non e\' quello che la matrice '
            'promette all\'Adepto');

    // Stessa schermata, stesso codice, piano diverso: il testo cambia da solo.
    await monta(tester,
        piano: Tier.tier3, borsa: QuestionAllowance()..ilServerHaParlato());
    // Ordine GA voce 01: tre stese (quindici carte dall'ordine EX voce 02,
    // venti stese prima). Ordine GA voce 02: cinque.
    expect(contoAVideo(tester), 'Oggi hai 5 stese',
        reason: 'l\'Illuminato non legge piu\' il suo conto: dall\'ordine BV '
            'voce 03 niente e\' illimitato, quindi anche lui ha un numero');

    await monta(tester,
        piano: Tier.free, borsa: QuestionAllowance()..ilServerHaParlato());
    // Ordine GA voce 01: una stesa al Viandante, al singolare (tre carte
    // dall'ordine EX voce 02).
    expect(contoAVideo(tester), 'Oggi hai 1 stesa',
        reason: 'il Viandante non legge piu\' la sua stesa del giorno, o la '
            'legge al plurale: ordine GA voce 01');
  });

  testWidgets('il conto si dichiara PRIMA, e sparisce a stesa cominciata',
      (tester) async {
    await monta(tester,
        piano: Tier.tier2, borsa: QuestionAllowance()..ilServerHaParlato());
    expect(contoAVideo(tester), isNotEmpty);
    await pesca(tester, 38);
    expect(find.byKey(RigaDelResiduo.chiaveDi(BudgetDelGiorno.stese)),
        findsNothing,
        reason: 'a stesa cominciata il conto e\' rumore');
  });

  testWidgets(
      'una stesa compiuta consuma una volta sola, e una abbandonata '
      'non consuma niente', (tester) async {
    final borsa = QuestionAllowance();
    await monta(tester, piano: Tier.tier2, borsa: borsa);
    // Ordine GA voce 01: due stese all'Adepto (dieci carte dall'ordine EX
    // voce 02, sette stese prima). Ordine GA voce 02: quattro. Ordine GA,
    // decisione del 20 ottobre 2026: tre, in entrambi i cicli.
    final intere = borsa.limiteStese(Tier.tier2)!;
    expect(intere, 3);
    expect(borsa.steseRimaste(Tier.tier2), intere);

    // Una carta sola: la stesa e' cominciata e non e' compiuta.
    await pesca(tester, 38);
    expect(borsa.steseRimaste(Tier.tier2), intere,
        reason: 'una stesa cominciata ha gia\' consumato: chi cambia idea '
            'alla prima carta paga per niente');

    // La seconda e la terza: le carte sono posate e ancora non si paga.
    // **Ordine CQ voce 1.03**: il conto e' del pulsante, non delle carte.
    // Ordine EX voce 02: si paga a carte, ma tutte insieme al pulsante.
    // Ordine GA voce 01: si paga una stesa, al pulsante.
    await pesca(tester, 39);
    expect(borsa.steseRimaste(Tier.tier2), intere,
        reason: 'la seconda carta posata ha consumato prima del pulsante');
    await pesca(tester, 40);
    await tester.pump(const Duration(seconds: 5));
    expect(borsa.steseRimaste(Tier.tier2), intere,
        reason: 'tre carte posate hanno gia\' consumato la stesa: chi ci '
            'ripensa prima di leggere paga per niente, ed e\' cio\' che '
            'l\'ordine CQ voce 1.03 chiude');

    // Il pulsante: e' questo il gesto che si paga.
    await apri(tester);
    await tester.pump(const Duration(seconds: 5));
    // Ordine GA voce 01: la stesa a tre carte consuma UNA stesa, una volta
    // sola: quattro meno uno (ordine GA voce 02). Se consumasse le sue tre
    // carte il conto sarebbe a uno, se consumasse due volte a due.
    expect(borsa.steseRimaste(Tier.tier2), intere - 1,
        reason: 'la lettura e\' aperta e non ha consumato la sua stesa, o '
            'ne ha consumata piu\' di una (le tre carte, o due volte)');
  });

  testWidgets('a riserva finita il tocco non e\' muto, e nomina le stese',
      (tester) async {
    final borsa = QuestionAllowance();
    await monta(tester, piano: Tier.tier2, borsa: borsa);
    // Ordine EX voce 02: le dieci carte dell'Adepto tutte estratte (erano
    // sette stese da una unita' ciascuna). Ordine GA voce 01: le due stese
    // dell'Adepto tutte fatte. Ordine GA voce 02: le quattro.
    for (var i = 0; i < 4; i++) {
      borsa.registraStesa(Tier.tier2);
    }
    expect(borsa.steseRimaste(Tier.tier2), 0);
    await tester.pump();

    await stendiEApri(tester);
    expect(find.byKey(const Key('upgrade_invite')), findsOneWidget,
        reason: 'il pulsante e\' muto a riserva finita: e\' un vicolo cieco');
    // La carta posata si misura dal BLOCCO delle carte uscite, che esiste
    // solo da una carta in poi: la chiave dello slot c'e' anche quando lo
    // slot e' vuoto, e chiederla direbbe il falso.
    expect(find.byKey(const Key('stesa_blocco_carte')), findsNothing,
        reason: 'la carta e\' stata posata lo stesso: il cancello non tiene');

    final testo = tester
        .widgetList<Text>(find.descendant(
            of: find.byKey(const Key('upgrade_invite')),
            matching: find.byType(Text)))
        .map((t) => t.data ?? '')
        .join(' ')
        .toLowerCase();
    expect(testo.contains('stes'), isTrue,
        reason: 'l\'invito non nomina le stese');
    // Ordine EX voce 02: a finire sono le carte, e l'invito deve dirlo.
    // Ordine GA voce 01: a finire sono le stese, coi numeri della matrice:
    // le due dell'Adepto, e le tre dell'Illuminato al livello dopo.
    // Ordine GA voce 02: le quattro dell'Adepto e le cinque dell'Illuminato.
    // Ordine GA, decisione del 20 ottobre 2026: le tre dell'Adepto.
    expect(testo.contains('le stese di oggi sono finite'), isTrue,
        reason: 'l\'invito non dice che le stese del giorno sono finite');
    expect(testo.contains('le 3 stese del giorno sono state fatte.'), isTrue,
        reason: 'l\'invito non dice quante stese l\'Adepto ha fatto oggi');
    expect(testo.contains('dal livello successivo le stese del giorno sono 5.'),
        isTrue,
        reason: 'l\'invito non dice le stese del livello dopo, lette dalla '
            'matrice');
    expect(testo.contains('cart'), isFalse,
        reason: 'l\'invito conta ancora le carte: il limite e\' di stese');
    expect(testo.contains('senza limit'), isFalse,
        reason: 'l\'invito promette un piano senza limiti, che non esiste');
    expect(testo.contains('gettat'), isFalse,
        reason: 'l\'invito nomina le gettate: manderebbe la persona a '
            'cercare il residuo dalla parte sbagliata dell\'app');
  });
  testWidgets(
      'il Viandante ha la sua stesa del giorno, e poi la strada degli '
      'Eos', (tester) async {
    // **PRIMA LA STESA DEL GIORNO, POI IL CANCELLO.** Ordine BU voce 04,
    // decisione del fondatore: "il viandante ha una stesa al giorno". Prima di
    // questo ordine il cancello si apriva al primo tocco, perche' il Viandante
    // aveva zero stese comprese.
    final borsa = QuestionAllowance(porta: _PortaDelDenaro(saldoIniziale: 400));
    await borsa.sincronizza();
    await monta(tester, piano: Tier.free, borsa: borsa);

    await stendiEApri(tester);
    expect(find.byKey(const Key('upgrade_invite')), findsNothing,
        reason: 'la PRIMA stesa del giorno chiede gli Eos al Viandante: e\' '
            'quella compresa nel piano');
    expect(find.byKey(const Key('stesa_blocco_carte')), findsOneWidget,
        reason: 'la prima stesa del giorno non e\' partita');

    // Consumata quella, il cancello si apre e nomina il prezzo.
    final dopo = QuestionAllowance(porta: _PortaDelDenaro(saldoIniziale: 400));
    await dopo.sincronizza();
    dopo.registraStesa(Tier.free);
    await monta(tester, piano: Tier.free, borsa: dopo);
    await stendiEApri(tester);
    expect(find.byKey(const Key('upgrade_invite')), findsOneWidget,
        reason: 'finita la stesa del giorno il Viandante non trova nessuna '
            'strada: e\' il vicolo cieco che il gating a due strade vieta');
    // Ordine GA voce 01: il riscatto ridà UNA stesa, e il pulsante lo dice
    // cosi' (dall'ordine EX diceva "una stesa completa", tre carte).
    final riscatta = find.text('Riscatta una stesa · 150 Eos');
    expect(riscatta, findsOneWidget,
        reason: 'la strada degli Eos non c\'e\', o non dice il prezzo');
    expect(find.textContaining('150 Eos'), findsOneWidget,
        reason: 'il prezzo mostrato non e\' quello del server');
    // Il Viandante ha una stesa sola, e la frase la dice al singolare; al
    // livello dopo le stese sono tre.
    expect(
        find.textContaining('La stesa del giorno è stata fatta. Puoi '
            'riscattare una stesa con gli Eos, oppure salire di livello nel '
            'Cerchio: dal livello successivo le stese del giorno sono 3.'),
        findsOneWidget,
        reason: 'l\'invito del Viandante non dice la sua stesa al singolare, '
            'o non dice le tre stese dell\'Iniziato');

    await tester.tap(riscatta);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    // **PRIMA DEL RISCATTO LA CONFERMA**, ordine FD voce 01: costo e saldo,
    // e niente si spende finche' non si tocca "Procedi".
    expect(
        find.text('Questa richiesta costa 150 Eos. Nel tuo borsellino ce '
            'ne sono 400.'),
        findsOneWidget,
        reason: 'il riscatto non e\' passato dalla conferma');
    await tester.tap(find.byKey(const Key('conferma_spesa_procedi')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    // **A RISCATTO AVVENUTO IL RESPONSO SI APRE DA SOLO.**
    // Ordine CQ voce 1.03, 3 settembre 2026, e la legge resta quella
    // dell'ordine BN voce 09: a riscatto avvenuto non si chiede un secondo
    // gesto per rifare quello appena sbarrato. Cambia quale gesto era stato
    // sbarrato: prima era il tocco sulla carta, con l'ordine CO voce 07 era il
    // pulsante che apriva la scelta, adesso e' il pulsante che apre la
    // lettura. Le tre carte erano gia' posate quando il cancello ha sbarrato,
    // quindi cio' che riprende e' la lettura, e si vede subito.
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 400));
    }
    expect(find.byKey(const Key('stesa_inizia')), findsNothing,
        reason: 'a riscatto avvenuto la lettura non e\' partita: chiede di '
            'premere di nuovo il pulsante che era appena stato sbarrato');
    expect(find.byKey(const Key('stesa_blocco_carte')), findsOneWidget,
        reason: 'col riscatto fatto il responso non si apre');
  });

  // --- LE GUARDIE STRUTTURALI ---

  test('la schermata della stesa chiede il permesso, consuma e riscatta', () {
    final s = File('lib/features/tarot/stesa_tre_carte_screen.dart')
        .readAsStringSync();
    expect(s.contains('puoiStendere('), isTrue,
        reason: 'la stesa non guarda piu\' la riserva prima di cominciare');
    expect(s.contains('registraStesa('), isTrue,
        reason: 'la stesa non consuma piu\' niente');
    // LAPIDE: `s.contains("budget: 'stese'")`, il testo letterale. Dal 14
    // ottobre 2026 (ordine FS, la Croce Celtica a 400 Eos) il budget del
    // riscatto e' scelto: la stesa intera oppure le stese. Si pretende che le
    // stese restino il budget del riscatto.
    expect(RegExp(r"budget:[^;]*'stese'").hasMatch(s), isTrue,
        reason: 'la stesa non offre piu\' il riscatto del budget giusto');
    expect(s.contains("budget: 'gettate'"), isFalse,
        reason: 'la stesa riscatta le GETTATE: e\' il budget delle rune');
    // **IL NUMERO NON SI SCRIVE A MANO, e adesso non si legge nemmeno qui.**
    // Ordine CF voce 11: la schermata aveva due getter suoi, `_steseRimaste`
    // e `_steseLimite`, che leggevano la borsa per passarli a un contatore
    // scritto per lei sola. Quei tre pezzi sono spariti insieme, e al loro
    // posto c'e' la riga comune: il numero lo legge lei, da una porta sola,
    // e tace quando il server non ha parlato.
    expect(s.contains('RigaDelResiduo('), isTrue,
        reason: 'la stesa non monta piu\' la riga comune del residuo');
    expect(s.contains('budget: BudgetDelGiorno.stese'), isTrue,
        reason: 'la riga del residuo non dichiara il budget delle stese');
    expect(s.contains('_ContoDelleStese'), isFalse,
        reason: 'il contatore scritto per questa schermata sola e\' tornato: '
            'due porte sullo stesso numero');
    // **UNA STESA VALE UNA STESA, ordine GA voce 01.** Nessun cancello e
    // nessun consumo della schermata guarda piu' il numero delle carte:
    // dall'ordine EX li chiamava con `carte:`.
    expect(RegExp(r'(puoiStendere|registraStesa)\([^;]*carte:').hasMatch(s),
        isFalse,
        reason: 'la schermata conta di nuovo le carte della stesa');
  });

  test('il guscio dell\'app porta il denaro sopra la rotta dei tarocchi', () {
    // La scena tollera l'assenza dei due servizi, perche' anteprime e prove
    // la montano da sola. Questa guardia e' cio' che impedisce a quella
    // tolleranza di diventare un modo per perdere il gating nell'app vera.
    final app = File('lib/app.dart').readAsStringSync();
    expect(app.contains('EntitlementService()'), isTrue,
        reason: 'l\'app non offre piu\' il piano: il gating della stesa '
            'sparirebbe in silenzio');
    expect(app.contains('QuestionAllowance('), isTrue,
        reason: 'l\'app non offre piu\' il borsellino: il gating della stesa '
            'sparirebbe in silenzio');
  });

  test('il server conosce il budget delle stese e il suo prezzo', () {
    final budget = File('functions/src/budget.ts').readAsStringSync();
    // Ordine EX voce 02: le carte estratte, erano 1, 4, 7 e 20 stese.
    // Ordine GA voce 01: di nuovo le stese, 1, 3, 2 e 3.
    // Ordine GA voce 02: 1, 3, 4 e 5, e la stesa a dieci una al giorno.
    // Ordine GA, decisione del 20 ottobre 2026: 1, 3, 3 e 5.
    expect(budget.contains('stese: [1, 3, 3, 5]'), isTrue,
        reason: 'il server non impone piu\' i limiti del listino');
    expect(budget.contains('steseDaDieci: [0, 0, 1, 1]'), isTrue,
        reason: 'il server non tiene la stesa a dieci a una al giorno');
    // Ordine EX voce 02: il riscatto ridà le carte di una stesa a tre, dalle
    // due parti lo stesso numero. Ordine GA voce 01: ridà una stesa, dalle
    // due parti lo stesso numero.
    final unita = RegExp(r'UNITA_DEL_RISCATTO[^{]*\{\s*stese:\s*(\d+)')
        .firstMatch(budget);
    expect(unita, isNotNull,
        reason: 'il server non dice piu\' quante stese ridà il riscatto');
    expect(int.parse(unita!.group(1)!), QuestionAllowance.kSteseDelRiscatto,
        reason: 'il riscatto ridà stese diverse dalle due parti');
    expect(QuestionAllowance.kSteseDelRiscatto, 1,
        reason: 'il riscatto non ridà piu\' una stesa');
    final borsellino = File('functions/src/borsellino.ts').readAsStringSync();
    expect(RegExp(r'stese: 150').hasMatch(borsellino), isTrue,
        reason: 'il server non conosce piu\' il prezzo della stesa: senza '
            'prezzo il riscatto non si puo\' nemmeno offrire');
  });

  test('CE.08: sul server non resta piu\' niente di illimitato', () {
    // **IL FONDATORE AVEVA CHIESTO IL CONTO, e adesso ha chiesto la cura.**
    // Con l\'ordine BV voce 03 questa prova contava cosa restava senza tetto
    // e stampava l\'elenco; con l\'ordine CE voce 08 quell\'elenco deve
    // essere VUOTO, sul server prima ancora che nell\'app: chi chiama la
    // callable direttamente non passa da nessuna schermata.
    const piani = ['Viandante', 'Iniziato', 'Adepto', 'Illuminato'];
    final server = File('functions/src/budget.ts').readAsStringSync();
    final righe = RegExp(r'^\s{2}(\w+):\s*\[([^\]]+)\],', multiLine: true)
        .allMatches(server);
    final senzaTetto = <String>[];
    var quanteRighe = 0;
    for (final m in righe) {
      quanteRighe++;
      final nome = m.group(1)!;
      final celle = m.group(2)!.split(',').map((c) => c.trim()).toList();
      for (var i = 0; i < celle.length && i < piani.length; i++) {
        if (celle[i] == 'null') senzaTetto.add('$nome per ${piani[i]}');
      }
    }
    // ignore: avoid_print
    print('ORDINE CE VOCE 08: righe di budget sul server $quanteRighe, '
        'celle senza tetto ${senzaTetto.length}');
    expect(quanteRighe, greaterThan(0),
        reason: 'la prova non ha letto nessuna riga: sta guardando altrove');
    expect(senzaTetto, isEmpty,
        reason: 'queste celle del SERVER restano senza tetto, e il server '
            'il sovrano: $senzaTetto');
  });
}

/// Una porta che risponde come il server vero: listino, saldo, movimenti.
class _PortaDelDenaro extends PortaDelCerchio {
  _PortaDelDenaro({required this.saldoIniziale});

  final int saldoIniziale;
  int _saldo = 0;
  final List<Map<String, Object?>> movimenti = [];

  static const _listino = {
    'domande': 80,
    'approfondimenti': 60,
    'confronti': 150,
    'gettate': 60,
    'stese': 150,
  };

  @override
  bool get viva => true;

  @override
  Future<StatoDelCerchio?> stato(
      {Object? cammino, bool azzeraIlCammino = false}) async {
    _saldo = saldoIniziale;
    return StatoDelCerchio.daMappa({
      'giorno': '2026-08-25',
      'spesi': const {'domande': 0},
      'saldoEos': saldoIniziale,
      'listinoDelRiscatto': _listino,
    });
  }

  @override
  Future<int?> muoviGliEos({
    required String causale,
    required String motivo,
    required String idMovimento,
    int? quanti,
  }) async {
    movimenti.add({'causale': causale, 'motivo': motivo, 'id': idMovimento});
    _saldo -= _listino[motivo.replaceFirst('riscatto_', '')] ?? 0;
    return _saldo;
  }

  @override
  Future<EsitoDelConsumo?> consuma(
          {required String budget, required String idMovimento}) async =>
      null;

  @override
  Future<bool> scriviLaMemoria({
    required String operazione,
    String? maestro,
    Map<String, Object?> campi = const {},
  }) async =>
      false;

  @override
  Future<bool> cancellaIlCerchio() async => false;
}
