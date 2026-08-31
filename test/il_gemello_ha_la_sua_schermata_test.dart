import 'dart:io';

import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/synastry/cielo_della_sinastria.dart';
import 'package:esoteric_circle/core/synastry/gemello_astrale.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/synastry/schermata_del_gemello.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// IL GEMELLO ASTRALE HA LA SUA SCHERMATA, E SI MUOVE. Ordine CF voce 14.
///
/// **Rilievo del fondatore, verbatim**: "la funzione di trova il tuo gemello
/// astrale non e' assolutamente appagante: serve animazione e responso simile
/// a quello della sinastria, sempre in stile goliardico."
///
/// **Cosa c'era, misurato**: nessuna schermata propria, una sfilata di 1600
/// millesimi, una miniatura da 120 punti e UNA frase sola in due varianti.
///
/// **CIO' CHE SI MUOVE SI PROVA SUL MOVIMENTO, non sulla presenza**, ed e' la
/// regola che l'ordine scrive: qui si confrontano due istanti e si pretende
/// che siano diversi. Una prova che cercasse "c'e' un'animazione" resterebbe
/// verde davanti a un'animazione ferma.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final cielo = CieloDiSinastria.perNascita(
    momentoUtc: DateTime.utc(1972, 5, 20, 12),
    oraNota: false,
    latitudine: null,
    longitudineDelLuogo: null,
    segnoDichiarato: Zodiac.taurus,
  );

  Future<GemelloAstrale> gemello() async => GemelloAstrale.per(cielo)!;

  Future<void> apri(WidgetTester tester, GemelloAstrale g) async {
    SharedPreferences.setMockInitialValues(const {});
    tester.view.physicalSize = const Size(360, 797);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MaestroScope(child: child!),
        home: SchermataDelGemello(
          gemello: g,
          tuoCielo: cielo,
          tuoSegno: Zodiac.taurus,
          adesso: DateTime(2026, 8, 31),
        ),
      ),
    ));
    await tester.pump();
  }

  testWidgets('la sfilata si MUOVE: due istanti mostrano due volti',
      (tester) async {
    final g = await gemello();
    await apri(tester, g);
    String? voltoA;
    String? voltoB;
    await tester.pump(const Duration(milliseconds: 300));
    voltoA = _immagineDellaCornice(tester);
    await tester.pump(const Duration(milliseconds: 900));
    voltoB = _immagineDellaCornice(tester);
    // ignore: avoid_print
    print('ORDINE CF VOCE 14: a 300 millesimi "$voltoA", a 1200 "$voltoB"');
    expect(voltoA, isNotNull,
        reason: 'la cornice non mostra nessuna immagine');
    expect(voltoA == voltoB, isFalse,
        reason: 'a trecento e a milleduecento millesimi la cornice mostra lo '
            'stesso volto: la sfilata non si muove, e un\'animazione ferma '
            'non e\' un\'animazione');
  });

  testWidgets('il racconto ha tre momenti, e arrivano in ordine',
      (tester) async {
    final g = await gemello();
    await apri(tester, g);
    // Durante la sfilata non c'e' ancora ne' il nome ne' il responso.
    await tester.pump(const Duration(milliseconds: 1000));
    final nomePrima = find.byKey(const Key('gemello_nome')).evaluate().length;
    final responsoPrima =
        find.byKey(const Key('gemello_responso')).evaluate().length;
    // Dopo il nome, ma prima del responso.
    await tester.pump(const Duration(milliseconds: 2900));
    final nomeDopo = find.byKey(const Key('gemello_nome')).evaluate().length;
    final responsoInMezzo =
        find.byKey(const Key('gemello_responso')).evaluate().length;
    // Alla fine, tutti e tre. **Ci si scorre**, perche' con il podio e il
    // cerchio la schermata e' diventata alta e la lista non costruisce cio'
    // che sta molto sotto la piega: una prova che non scorresse direbbe
    // che il responso non arriva mai.
    await tester.pump(const Duration(milliseconds: 2200));
    await tester.scrollUntilVisible(
      find.byKey(const Key('gemello_responso')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    final responsoDopo =
        find.byKey(const Key('gemello_responso')).evaluate().length;
    // ignore: avoid_print
    print('ORDINE CF VOCE 14: nome $nomePrima -> $nomeDopo, responso '
        '$responsoPrima -> $responsoInMezzo -> $responsoDopo');
    expect(nomePrima, 0,
        reason: 'il nome c\'e\' gia\' durante la sfilata: non c\'e\' nessuna '
            'rivelazione se il risultato si legge dall\'inizio');
    expect(nomeDopo, 1, reason: 'il nome non arriva mai');
    expect(responsoInMezzo, 0,
        reason: 'il responso arriva insieme al nome: sono due momenti, e '
            'insieme ne fanno uno solo');
    expect(responsoDopo, 1, reason: 'il responso non arriva mai');
  });

  testWidgets('la grafica arriva PRIMA del testo, ed e\' la regola',
      (tester) async {
    // **Richiesta del fondatore del 31 agosto 2026**: "come regola UX, la
    // parte grafica o infografica e' prioritaria". Qui si misura l'ordine:
    // il cerchio e il podio ci sono gia' quando il responso non c'e' ancora.
    final g = await gemello();
    await apri(tester, g);
    await tester.pump(const Duration(milliseconds: 4600));
    final cerchio =
        find.byKey(const Key('gemello_cerchio_percentuale')).evaluate().length;
    // Il podio sta sotto il cerchio, quindi sotto la piega: si scorre.
    await tester.scrollUntilVisible(
      find.byKey(const Key('gemello_podio')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    final podio = find.byKey(const Key('gemello_podio')).evaluate().length;
    final responso =
        find.byKey(const Key('gemello_responso')).evaluate().length;
    // ignore: avoid_print
    print('ORDINE CF VOCE 14: a 4600 millesimi cerchio $cerchio, podio '
        '$podio, responso $responso');
    expect(cerchio, 1, reason: 'il cerchio della percentuale non arriva');
    expect(podio, 1, reason: 'il podio dei tre non arriva');
    expect(responso, 0,
        reason: 'il responso arriva insieme alla grafica: la regola del '
            'progetto dice che il livello visivo viene PRIMA del testo');
  });

  testWidgets('il podio ha tre gradini, e il primo e\' il piu\' alto',
      (tester) async {
    // **Richiesta del fondatore**: "una classifica dei primi 3 risultati con
    // una specie di podio graficamente, come in Formula uno". Un podio in cui
    // i gradini sono uguali non dice niente: la loro altezza E' il fatto.
    final g = await gemello();
    await apri(tester, g);
    await tester.pump(const Duration(milliseconds: 6000));
    await tester.scrollUntilVisible(
      find.byKey(const Key('gemello_podio')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    final altezze = <int, double>{};
    for (final posto in const [1, 2, 3]) {
      final f = find.byKey(Key('gemello_podio_gradino_$posto'));
      expect(f, findsOneWidget, reason: 'manca il gradino del posto $posto');
      altezze[posto] = tester.getSize(f).height;
    }
    // ignore: avoid_print
    print('ORDINE CF VOCE 14: gradini $altezze, e i tre punteggi sono '
        '${g.podio.map((v) => v.punteggio).toList()}');
    expect(altezze[1]! > altezze[2]!, isTrue,
        reason: 'il gradino del primo non e\' piu\' alto di quello del '
            'secondo: non e\' un podio, e\' una fila');
    expect(altezze[2]! > altezze[3]!, isTrue,
        reason: 'il gradino del secondo non e\' piu\' alto di quello del '
            'terzo');
  });

  test('il podio dice i tre veri, in ordine di punteggio', () {
    final g = GemelloAstrale.per(cielo)!;
    final punteggi = g.podio.map((v) => v.punteggio).toList();
    // ignore: avoid_print
    print('ORDINE CF VOCE 14: il podio dice ${g.podio.map((v) => v.vip.name)} '
        'con $punteggi');
    expect(g.podio, hasLength(3), reason: 'il podio non ha tre posti');
    expect(punteggi[0] >= punteggi[1], isTrue,
        reason: 'il primo del podio non ha il punteggio piu\' alto');
    expect(punteggi[1] >= punteggi[2], isTrue,
        reason: 'il secondo del podio sta sotto il terzo');
    // **E i tre sono DIVERSI**: un podio con due volte la stessa faccia
    // vorrebbe dire che l'ordinamento ha perso un pezzo.
    final nomi = g.podio.map((v) => v.vip.name).toSet();
    expect(nomi, hasLength(3), reason: 'sul podio c\'e\' due volte la '
        'stessa persona');
  });

  testWidgets('il titolo, le due risposte e le barre ci sono tutti',
      (tester) async {
    // **Le quattro cose che il fondatore ha chiesto il 31 agosto 2026**, e
    // ognuna ha la sua ragione nella sua sezione del manifesto.
    final g = await gemello();
    await apri(tester, g);
    await tester.pump(const Duration(milliseconds: 6000));
    final mancanti = <String>[];
    const attese = <String, String>{
      'il titolo che si condivide': 'gemello_titolo_meme',
      'la risposta tecnica': 'gemello_perche_tecnica',
      'la risposta evocativa': 'gemello_perche_evocativa',
      'le barre della personalita\'': 'gemello_barre',
    };
    for (final voce in attese.entries) {
      final f = find.byKey(Key(voce.value));
      if (f.evaluate().isEmpty) {
        // Puo\' stare sotto la piega: si scorre prima di dirlo mancante.
        await tester.scrollUntilVisible(
          f,
          300,
          scrollable: find.byType(Scrollable).first,
        );
      }
      if (f.evaluate().isEmpty) mancanti.add(voce.key);
    }
    // ignore: avoid_print
    print('ORDINE CF VOCE 14: delle ${attese.length} cose chieste ne mancano '
        '${mancanti.length}');
    expect(mancanti, isEmpty,
        reason: 'il fondatore ha chiesto queste cose e non ci sono: '
            '$mancanti');
  });

  testWidgets('i cartigli delle carte non restano vuoti', (tester) async {
    // **Rilievo del fondatore del 31 agosto 2026, guardando l'anteprima**:
    // "perche' i cartigli delle carte sono vuoti?"
    //
    // **E' lo stesso difetto che l'ordine CC voce 06i aveva gia' curato sulla
    // carta ingrandita, e l'avevo rifatto io.** Gli artwork dei VIP hanno i
    // cartigli VUOTI di proposito: il nome e la data si posano a runtime,
    // cosi' un set solo di immagini vale per tutte le lingue. Chi monta
    // `Image.asset` nudo monta l'arte senza chi la posa.
    //
    // **La prova guarda il sorgente e non lo schermo**, perche' a schermo i
    // due testi vivono dentro il componente della cornice e un `find` non li
    // distinguerebbe dal disegno.
    const schermate = <String>[
      'lib/features/synastry/schermata_del_gemello.dart',
      'lib/features/synastry/podio_del_gemello.dart',
      'lib/features/synastry/rivelazione_del_gemello.dart',
    ];
    final nude = <String>[];
    for (final percorso in schermate) {
      final sorgente = File(percorso)
          .readAsStringSync()
          .split('\n')
          .where((r) => !r.trimLeft().startsWith('//'))
          .join('\n');
      if (!sorgente.contains('VipFramedPortrait(')) {
        nude.add('$percorso non monta VipFramedPortrait');
      }
      for (final nudo in const [
        'Image.asset(volto.',
        'Image.asset(vip.',
        'Image.asset(voce.vip.',
      ]) {
        if (sorgente.contains(nudo)) {
          nude.add('$percorso monta ancora l\'arte nuda con $nudo');
        }
      }
    }
    // ignore: avoid_print
    print('ORDINE CF VOCE 14: schermate col ritratto ${schermate.length}, '
        'con l\'arte nuda ${nude.length}');
    expect(nude, isEmpty,
        reason: 'qui i cartigli restano bianchi, perche\' l\'arte e\' '
            'montata senza chi le posa il nome e la data: $nude');
  });

  testWidgets('il responso e\' quello della Sinastria, e porta al suo cielo',
      (tester) async {
    final g = await gemello();
    await apri(tester, g);
    await tester.pump(const Duration(milliseconds: 6000));
    // La schermata e' alta: si scorre fino al responso, che sta sotto il
    // podio e sotto il cerchio della percentuale.
    await tester.scrollUntilVisible(
      find.byKey(const Key('gemello_responso')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    final responso = find.byKey(const Key('gemello_responso'));
    expect(responso, findsOneWidget);
    final titolo = find.byKey(const Key('gemello_titolo_responso'));
    expect(titolo, findsOneWidget,
        reason: 'il responso non ha il titolo che la Sinastria gli da\'');
    // **IL GESTO CHE CONSUMA HA IL SUO RESIDUO DAVANTI, voce CF.11.**
    // Sta in fondo alla lettura, quindi ci si scorre: una prova che non
    // scorresse misurerebbe uno schermo dove il pulsante non c'e' ancora.
    await tester.scrollUntilVisible(
      find.byKey(const Key('gemello_apri_sinastria')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();
    expect(find.byKey(const Key('gemello_apri_sinastria')), findsOneWidget,
        reason: 'dalla schermata del Gemello non si arriva alla sinastria '
            'intera: il racconto finisce in un vicolo cieco');
    final sorgente = find
        .byType(SchermataDelGemello)
        .evaluate()
        .isNotEmpty;
    expect(sorgente, isTrue);
  });
}

/// Il percorso dell'immagine che la cornice sta mostrando adesso.
String? _immagineDellaCornice(WidgetTester tester) {
  final dentro = find.descendant(
    of: find.byKey(const Key('gemello_cornice')),
    matching: find.byType(Image),
  );
  if (dentro.evaluate().isEmpty) return null;
  final img = tester.widget<Image>(dentro.first).image;
  return img is AssetImage ? img.assetName : img.toString();
}
