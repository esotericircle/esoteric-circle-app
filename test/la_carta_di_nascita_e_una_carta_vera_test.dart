import 'dart:io';

import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/rituals/carta_di_nascita_dei_tarocchi.dart';
import 'package:esoteric_circle/core/tarot/tarot_card.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/onboarding/rivelazione_carta_di_nascita.dart';
import 'package:esoteric_circle/features/onboarding/widgets/pulsante_del_risveglio.dart';
import 'package:esoteric_circle/features/tarot/tarot_card_art.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'cardinale_minimo.dart';

/// **LA CARTA DI NASCITA E' UNA CARTA VERA.** Ordine DP voce 01,
/// 15 settembre 2026.
///
/// Parole del fondatore sulla build 2261: *"la carta rivelata NON E' UNA
/// CARTA CHE HO CREATO IO"*, *"non si vede il dorso dei nostri tarocchi"*,
/// manca *"la complessita' ed eleganza e fluidita' di 78 carte che girano"*.
/// La schermata disegnava tutto in un `CustomPainter` e non apriva nessuna
/// delle settantotto arti, ne' il dorso.
void main() {
  final nascita = DateTime(1979, 3, 24);
  final carta = CartaDiNascitaDeiTarocchi.cartaDi(nascita);

  Widget ospite(Widget figlio, {bool senzaMoto = false}) =>
      ChangeNotifierProvider(
        create: (_) => MaestroController(),
        child: MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
                size: const Size(390, 844), disableAnimations: senzaMoto),
            child: MaestroScope(
              child: Scaffold(
                backgroundColor: Colors.black,
                body: figlio,
              ),
            ),
          ),
        ),
      );

  void schermo(WidgetTester tester) {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  test('IL MAZZO DELLA SCENA E\' TUTTO IL MAZZO', () {
    expect(RegiaDellaRivelazione.quanteNelMazzo, TarotDeck.cards.length,
        reason: 'la scena gira un numero di carte diverso dal mazzo vero');
    expect(TarotDeck.cards.length, 78);
  });

  test('IL NUMERO DEL CALCOLO E\' IL NUMERO SCRITTO SULLA CARTA', () {
    // **ORDINE DP VOCE 04**: sul telefono la data si sommava fino a 8 e si
    // girava La Giustizia col suo XI. Si guardano tutte le date di un secolo,
    // un giorno ogni tre, e si pretende di aver visto anche l'8 e l'11.
    final visti = <int>{};
    for (var d = DateTime(1930, 1, 1);
        d.isBefore(DateTime(2030, 1, 1));
        d = d.add(const Duration(days: 3))) {
      final n = CartaDiNascitaDeiTarocchi.numeroDi(d);
      final c = CartaDiNascitaDeiTarocchi.cartaDi(d);
      visti.add(n);
      expect(c.majorNumber, n % 22,
          reason: 'per ${d.day}/${d.month}/${d.year} il calcolo da $n e la '
              'carta porta ${c.numeral}');
    }
    expect(visti.containsAll({8, 11}), isTrue,
        reason: 'le date guardate non danno ne 8 ne 11, dove il difetto era');
  });

  test('LA CARTA CHE SI FERMA STA DAVANTI E AL CENTRO DELL\'ANELLO', () {
    // **Dalla prova sul telefono**: la prima stesura disegnava l'anello con
    // un atlante, e il centro finiva al bordo destro della scena.
    final passi = CartaDiNascitaDeiTarocchi.passiDi(nascita);
    final regia = RegiaDellaRivelazione(
        passi: passi, carta: carta, t: RegiaDellaRivelazione.fineDelGiro);
    const centro = Offset(150, 200);
    final pittore = PittoreDellAnello(
      tempo: const AlwaysStoppedAnimation(0),
      regiaDi: () => regia,
      dorso: null,
      centro: centro,
      rx: 120,
      ry: 40,
      carta: const Size(50, 75),
      visibili: 78,
    );
    final davanti = pittore.carteDaDisegnare().last;
    expect(davanti.indice, TarotDeck.cards.indexOf(carta),
        reason: 'la carta dipinta per ultima, quella davanti, non e la sua');
    expect(davanti.centro.dx, closeTo(centro.dx, 0.01),
        reason: 'la carta davanti non sta al centro dell anello');
    expect(davanti.centro.dy, closeTo(centro.dy + 40, 0.01));
    expect(davanti.scala, closeTo(1.0, 0.001));
  });

  test('TUTTE E SETTANTOTTO PASSANO DAVANTI, E SI FERMA LA SUA', () {
    final campione = [
      DateTime(1979, 3, 24),
      DateTime(1990, 12, 31),
      DateTime(2000, 1, 1),
      DateTime(1966, 7, 7),
      DateTime(1985, 11, 19),
      DateTime(2004, 2, 29),
    ];
    for (final data in campione) {
      final passi = CartaDiNascitaDeiTarocchi.passiDi(data);
      final sua = CartaDiNascitaDeiTarocchi.cartaDi(data);
      final davanti = <int>{};
      const quanti = 40000;
      for (var k = 0; k <= quanti; k++) {
        final t = RegiaDellaRivelazione.fineDelGiro * k / quanti;
        davanti.add(RegiaDellaRivelazione(passi: passi, carta: sua, t: t)
            .indiceDavanti());
      }
      expect(davanti.length, RegiaDellaRivelazione.quanteNelMazzo,
          reason: 'per ${data.day}/${data.month}/${data.year} passano davanti '
              '${davanti.length} carte su 78: il mazzo non gira tutto');
      final ferma = RegiaDellaRivelazione(
              passi: passi, carta: sua, t: RegiaDellaRivelazione.fineDelGiro)
          .indiceDavanti();
      expect(ferma, TarotDeck.cards.indexOf(sua),
          reason: 'l anello si ferma su ${TarotDeck.cards[ferma].name}, il '
              'calcolo dice ${sua.name}');
    }
  });

  testWidgets('IL MAZZO CHE GIRA HA IL DORSO VERO, SETTANTOTTO VOLTE',
      (tester) async {
    schermo(tester);
    await tester
        .pumpWidget(ospite(RivelazioneCartaDiNascita(nascita: nascita)));
    await tester.pump(const Duration(milliseconds: 1500));
    // **L'ANELLO E' UN ATLANTE**, dall'ordine DP voce 01.3: una chiamata di
    // disegno per settantotto carte. Si chiede al pittore cosa disegna e da
    // quale immagine.
    final pittore = tester
        .widget<CustomPaint>(find.byKey(const Key('carta_di_nascita_mazzo')))
        .painter! as PittoreDellAnello;
    expect(PittoreDellAnello.asset, TarotDeck.dorsoThumb,
        reason: 'l anello non disegna il dorso vero del mazzo');
    final dorsi = pittore.carteDaDisegnare().length;
    cardinaleMinimo(dorsi, 78,
        cosa: 'carte col dorso vero nell anello',
        perche: 'La voce DP.01.2 vuole tutto il mazzo nel giro, non una '
            'dozzina ripetuta.');
    expect(dorsi, 78);
    // **LA TELA DELL'ANELLO E' LARGA QUANTO LA SCENA**, a meta' giro: sul
    // telefono era larga zero, e l'anello girava spostato di mezza scena.
    final tela =
        tester.getRect(find.byKey(const Key('carta_di_nascita_mazzo')));
    final scena =
        tester.getRect(find.byKey(const Key('rivelazione_carta_di_nascita')));
    expect(tela.width, closeTo(scena.width, 0.5),
        reason: 'la tela dell anello e larga ${tela.width} su una scena di '
            '${scena.width}');
    expect(tela.left, closeTo(scena.left, 0.5));
    expect(scena.width, greaterThan(300),
        reason: 'la scena e larga ${scena.width}: non occupa la colonna');
    // E il dorso si decodifica davvero: senza, l'anello non disegna niente.
    await tester.runAsync(() async {
      for (var i = 0; i < 50; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
        final p = tester
            .widget<CustomPaint>(
                find.byKey(const Key('carta_di_nascita_mazzo')))
            .painter! as PittoreDellAnello;
        if (p.dorso != null) break;
      }
    });
    await tester.pump();
    final dopo = tester
        .widget<CustomPaint>(find.byKey(const Key('carta_di_nascita_mazzo')))
        .painter! as PittoreDellAnello;
    expect(dopo.dorso, isNotNull,
        reason: 'il dorso del mazzo non si decodifica: l anello resta vuoto');
    await tester.pump(RivelazioneCartaDiNascita.quantoDura);
    await tester.pump();
  });

  testWidgets('LA CARTA RIVELATA E\' IL SUO ARTWORK VERO, E OCCUPA LA SCENA',
      (tester) async {
    schermo(tester);
    await tester
        .pumpWidget(ospite(RivelazioneCartaDiNascita(nascita: nascita)));
    await tester.pump(RivelazioneCartaDiNascita.quantoDura);
    await tester.pump();
    final laCarta = find.byKey(const Key('carta_di_nascita_la_carta'));
    expect(laCarta, findsOneWidget,
        reason: 'a rivelazione finita la carta girata non c e');
    expect(tester.widget<TarotCardArt>(laCarta).card, carta);
    final arte = find.descendant(
        of: laCarta,
        matching: find.byWidgetPredicate((w) =>
            w is Image &&
            w.image is AssetImage &&
            (w.image as AssetImage).assetName == carta.fullPath));
    expect(arte, findsOneWidget,
        reason: 'la carta girata non apre la sua arte a piena risoluzione');
    // **REGOLA I dell'ordine DC voce 14**: almeno il settanta per cento.
    final scena =
        tester.getRect(find.byKey(const Key('rivelazione_carta_di_nascita')));
    final quota = tester.getRect(laCarta).height / scena.height;
    // ignore: avoid_print
    print('ORDINE DP VOCE 01: la carta girata occupa '
        '${(quota * 100).toStringAsFixed(1)} per cento della scena');
    expect(quota, greaterThanOrEqualTo(0.70));
  });

  testWidgets('I NUMERI SI SPIEGANO, E IL ROMANO STA SOLO SULLA CARTA',
      (tester) async {
    schermo(tester);
    await tester
        .pumpWidget(ospite(RivelazioneCartaDiNascita(nascita: nascita)));
    await tester.pump(const Duration(milliseconds: 3000));
    expect(find.byKey(const Key('carta_di_nascita_numero')), findsOneWidget,
        reason: 'a meta del calcolo non si legge nessun numero');
    expect(find.text(RivelazioneCartaDiNascita.laRiga), findsOneWidget,
        reason: 'i numeri si vedono ma nessuno dice cosa sono');
    await tester.pump(RivelazioneCartaDiNascita.quantoDura);
    await tester.pump();
    final fuori = find.byWidgetPredicate(
        (w) => w is Text && (w.data ?? '').trim() == carta.numeral);
    final sullaCarta =
        find.descendant(of: find.byType(TarotCardArt), matching: fuori);
    expect(fuori.evaluate().length, sullaCarta.evaluate().length,
        reason: 'il numero romano ${carta.numeral} compare fuori dalla carta');
  });

  testWidgets('CON RIDUCI MOVIMENTO IL METODO RESTA LEGGIBILE', (tester) async {
    schermo(tester);
    await tester.pumpWidget(ospite(
        RivelazioneCartaDiNascita(nascita: nascita, senzaMoto: true),
        senzaMoto: true));
    await tester.pump();
    final passi = CartaDiNascitaDeiTarocchi.passiDi(nascita);
    expect(find.text('${passi.numero}'), findsOneWidget,
        reason: 'con Riduci Movimento il numero del calcolo non si vede');
    expect(find.text(RivelazioneCartaDiNascita.laRiga), findsOneWidget);
    expect(find.byKey(const Key('carta_di_nascita_la_carta')), findsOneWidget,
        reason: 'con Riduci Movimento la carta non compare');
  });

  testWidgets('IL PULSANTE E\' ORO COME NELLE ALTRE SCHERMATE', (tester) async {
    schermo(tester);
    await tester.pumpWidget(ospite(RivelazioneCartaDiNascita(
      nascita: nascita,
      azione: PulsanteDelRisveglio(
          chiave: const Key('p'), onPressed: () {}, testo: 'Avanti'),
    )));
    await tester.pump(RivelazioneCartaDiNascita.quantoDura);
    await tester.pump(const Duration(milliseconds: 400));
    final contesto = tester.element(find.byKey(const Key('p')));
    final oro = contesto.palette.gold;
    final pulsante = tester.widget<FilledButton>(find.byKey(const Key('p')));
    expect(pulsante.style!.backgroundColor!.resolve({}), oro,
        reason: 'il pulsante della Carta di Nascita non e oro');
  });

  test('UN SOLO PULSANTE PRINCIPALE IN TUTTO L\'ONBOARDING', () {
    // **LA DICHIARATA**: la porta per chi torna, nella prima schermata, e'
    // secondaria per scelta scritta accanto a lei, e resta la sua cornice.
    const dichiarate = {'lib/features/onboarding/onboarding_screen.dart': 1};
    final fuori = <String>[];
    var usi = 0;
    for (final f in Directory('lib/features/onboarding')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      final percorso = f.path.replaceAll('\\', '/');
      if (percorso.endsWith('widgets/pulsante_del_risveglio.dart')) continue;
      final testo = f.readAsStringSync();
      usi += 'PulsanteDelRisveglio('.allMatches(testo).length;
      final pieni = RegExp(r'FilledButton\(').allMatches(testo).length;
      if (pieni > (dichiarate[percorso] ?? 0)) {
        fuori.add('$percorso: $pieni FilledButton scritti a mano');
      }
    }
    cardinaleMinimo(usi, 9,
        cosa: 'pulsanti principali dell onboarding col componente unico',
        perche: 'Con meno usi la guardia non guarda niente.');
    expect(fuori, isEmpty,
        reason: 'pulsanti principali fuori dallo standard: $fuori');
  });
}
