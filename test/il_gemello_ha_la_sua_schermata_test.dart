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
    // Alla fine, tutti e tre.
    await tester.pump(const Duration(milliseconds: 1200));
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

  testWidgets('il responso e\' quello della Sinastria, e porta al suo cielo',
      (tester) async {
    final g = await gemello();
    await apri(tester, g);
    await tester.pump(const Duration(milliseconds: 5000));
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
