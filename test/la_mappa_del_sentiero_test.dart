import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:esoteric_circle/features/sigilli/la_mappa_del_sentiero.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'istante_dichiarato.dart';

/// LA MAPPA DEL SENTIERO. Ordine AU voce 13.
///
/// **Tre cose e basta**: dove sei, cosa manca, da dove si comincia. La prova
/// pretende che ci siano tutte e tre e che siano TRE, perche' un aiuto che
/// diventa un elenco smette di aiutare.
///
/// **Non e' la bolla che il fondatore ha fatto eliminare**: quella stava in
/// home e arrivava senza che nessuno la chiedesse. Questa sta dentro il
/// sentiero e la si chiede. Anche questo si misura: al secondo ingresso non
/// deve comparire da sola.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> monta(WidgetTester tester, Sentiero sentiero,
      DiarioDelCammino diario) async {
    tester.view.physicalSize = const Size(1080, 2391);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider<DiarioDelCammino>.value(value: diario),
      ],
      child: MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () =>
                    LaMappaDelSentiero.mostra(context, sentiero),
                child: const Text('apri'),
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('apri'));
    await tester.pumpAndSettle();
  }

  for (final sentiero in Sentiero.values) {
    testWidgets('su ${sentiero.name} la mappa dice le tre cose',
        (tester) async {
      SharedPreferences.setMockInitialValues(const {});
      final diario = DiarioDelCammino(orologio: orologioDelleProve);
      await diario.carica();
      // Due perle accese, per non guardare il caso vuoto.
      for (final t in Sentieri.miniDi(sentiero).take(2)) {
        await diario.accendi(t.id);
      }
      await monta(tester, sentiero, diario);

      final doveSei =
          tester.widget<Text>(find.byKey(const Key('mappa_dove_sei'))).data!;
      final cosaManca =
          tester.widget<Text>(find.byKey(const Key('mappa_cosa_manca'))).data!;
      final daDove = find.byKey(const Key('mappa_da_dove_si_comincia'));
      // ignore: avoid_print
      print('ORDINE AU VOCE 13: ${sentiero.name}\n  dove sei: "$doveSei"\n'
          '  cosa manca: "$cosaManca"');
      expect(doveSei, contains('2 perle accese su 55'),
          reason: 'la prima riga non dice dove sei');
      expect(doveSei.toLowerCase(), contains('fascia'),
          reason: 'la prima riga non dice in che fascia stai');
      expect(cosaManca, isNotEmpty,
          reason: 'la seconda riga non dice cosa manca');
      expect(daDove, findsOneWidget,
          reason: 'manca la porta dell arte, che deve essere toccabile');
    });
  }

  testWidgets('le righe sono tre, non un elenco', (tester) async {
    SharedPreferences.setMockInitialValues(const {});
    final diario = DiarioDelCammino(orologio: orologioDelleProve);
    await diario.carica();
    await monta(tester, Sentiero.loto, diario);
    // Dentro il foglio: il segno, le due righe COI LORO TITOLI, e il
    // pulsante. Nessun altro testo, se no l'aiuto e' diventato una pagina.
    //
    // **IL CONTO E' PASSATO DA TRE A CINQUE, per decisione del fondatore.**
    // Ordine BC voce 06: "prima di tutto dovrebbe esserci il titolo 'I
    // traguardi raggiunti' e sotto 'il tuo prossimo traguardo'". Le due
    // righe erano due informazioni diverse incolonnate senza dire quale
    // fosse quale, e chi legge le prendeva per una sola.
    //
    // **La regola non si allenta, cambia di numero.** Cinque e' esatto e non
    // e' un tetto comodo: due titoli, due contenuti, e nient'altro. Se
    // domani ne comparisse un sesto, questa riga lo direbbe come prima.
    final testi = find
        .descendant(
            of: find.byType(BottomSheet), matching: find.byType(Text))
        .evaluate()
        .map((e) => (e.widget as Text).data ?? '')
        .where((s) => s.trim().isNotEmpty)
        .toList();
    // ignore: avoid_print
    print('ORDINE AU VOCE 13, poi BC VOCE 06: nel foglio ci sono '
        '${testi.length} testi: '
        '$testi');
    expect(testi.length, lessThanOrEqualTo(5),
        reason: 'la mappa dice ${testi.length} cose invece di cinque: un '
            'aiuto che diventa un elenco smette di aiutare');
  });

  test('la mappa si apre una volta sola da sola', () async {
    SharedPreferences.setMockInitialValues(const {});
    expect(await LaMappaDelSentiero.eIlPrimoIngresso(Sentiero.albero), isTrue,
        reason: 'al primo ingresso la mappa deve comparire');
    await LaMappaDelSentiero.segnaLIngresso(Sentiero.albero);
    expect(await LaMappaDelSentiero.eIlPrimoIngresso(Sentiero.albero), isFalse,
        reason: 'la mappa torna da sola al secondo ingresso: e la bolla che il '
            'fondatore ha fatto eliminare, con un altro nome');
    // Gli altri due sentieri restano al loro primo ingresso: il conto e' per
    // sentiero, non per app.
    expect(await LaMappaDelSentiero.eIlPrimoIngresso(Sentiero.loto), isTrue);
  });

  test('ogni gesto del corpus sa dire da dove si comincia', () {
    // **NESSUN VICOLO CIECO**: per ogni traguardo dei tre sentieri la terza
    // riga deve avere un nome da mostrare, o quello dell'arte o quello della
    // casa del Maestro.
    var senzaNome = 0;
    final gestiSenzaArte = <String>{};
    for (final sentiero in Sentiero.values) {
      for (final traguardo in Sentieri.di(sentiero)) {
        final nome = PortaDellArte.comeSiChiama(traguardo, sentiero);
        if (nome.trim().isEmpty) senzaNome++;
        final gesto = PortaDellArte.gestoDi(traguardo);
        if (gesto != null && !PortaDellArte.nomeDellArte.containsKey(gesto)) {
          gestiSenzaArte.add(gesto);
        }
      }
    }
    // ignore: avoid_print
    print('ORDINE AU VOCE 13: traguardi senza una porta da nominare '
        '$senzaNome; gesti che non hanno un nome d arte: $gestiSenzaArte');
    expect(senzaNome, 0,
        reason: 'questi traguardi non sanno dire da dove si comincia');
  });
}
