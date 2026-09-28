// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/synastry/collezione_delle_coppie.dart';
import 'package:esoteric_circle/core/synastry/gemello_astrale.dart';
import 'package:esoteric_circle/design_system/components/vip_frame.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/synastry/porta_della_sinastria.dart';
import 'package:esoteric_circle/features/synastry/schermata_del_gemello.dart';
import 'package:esoteric_circle/features/synastry/sinastria_gallery_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **IL GEMELLO ASTRALE IN UNA SCHERMATA SOLA.** Ordine ER voce 06, 27
/// settembre 2026.
///
/// Parole del fondatore: *"quando lo apro calcola immediatamente il gemello
/// Vip, ma sopra mostra "scegli il tuo vip" e sotto c'è l'elenco delle carte
/// del vip che in questa funzione non hanno senso. [...] La prima e unica
/// schermata che si deve aprire è una schermata semplice con le carte dei vip
/// in orizzontale poco sovrapposte. Al click su un pulsante nuovo "cerca il
/// tuo gemello VIP" le carte iniziano a scorrere velocemente, poi rallentando
/// vengono estratte le 3 carte dei gemelli vip con al centro il gemello più
/// vicino [...] Ma tutto nella stessa schermata Senza bisognondi cliccare
/// sull'immagine della carta del gemello."*
///
/// **Le grandezze misurate**: quanti elementi della galleria compaiono
/// aprendo il Gemello dalla porta (il titolo "Scegli il tuo VIP", la ricerca,
/// la categoria, l'elenco), e quanti gesti servono fra il pulsante e il
/// responso intero.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silenzia() {
    SharedPreferences.setMockInitialValues(const {});
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

  /// Monta la porta e ci tocca "Trova il tuo gemello astrale VIP", come fa
  /// la persona.
  Future<void> dallaPorta(WidgetTester tester, Size schermo) async {
    silenzia();
    tester.view.physicalSize = schermo;
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
        builder: (ctx, child) => MaestroScope(child: child!),
        home: PortaDellaSinastria(
          userSign: Zodiac.taurus,
          userName: 'Mauro',
          userBirth: DateTime(1972, 5, 20),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    final porta = find.byKey(Key(ModoDellaSinastria.gemelloAstrale.chiave));
    await tester.ensureVisible(porta);
    await tester.pump();
    await tester.tap(porta);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  List<String> elementiDellaGalleria() => [
        if (find.text('Scegli il tuo VIP').evaluate().isNotEmpty)
          'il titolo "Scegli il tuo VIP"',
        if (find.byKey(const Key('sinastria_search')).evaluate().isNotEmpty)
          'la ricerca',
        if (find.byKey(const Key('sinastria_categoria')).evaluate().isNotEmpty)
          'la categoria',
        if (find
            .byWidgetPredicate((w) =>
                w.key is ValueKey<String> &&
                (w.key! as ValueKey<String>).value.startsWith('vip_'))
            .evaluate()
            .isNotEmpty)
          'l\'elenco dei VIP',
      ];

  testWidgets(
      'ER.06: dalla porta si apre la schermata del Gemello, semplice: il '
      'nastro delle carte e il pulsante, niente della galleria',
      (tester) async {
    await dallaPorta(tester, const Size(360, 800));
    final galleria = elementiDellaGalleria();
    print('ORDINE ER VOCE 6: elementi della galleria nella schermata del '
        'Gemello ${galleria.length} $galleria');
    expect(find.byType(SchermataDelGemello), findsOneWidget,
        reason: 'la porta non apre la schermata del Gemello');
    expect(find.byType(SinastriaGalleryScreen), findsNothing,
        reason: 'la porta apre ancora la galleria dei VIP');
    expect(galleria, isEmpty,
        reason: 'nella schermata del Gemello ci sono ancora pezzi della '
            'galleria: $galleria');

    // Il pulsante nuovo, con le parole del fondatore.
    expect(find.byKey(const Key('gemello_cerca')), findsOneWidget);
    expect(find.text('Cerca il tuo gemello VIP'), findsOneWidget);

    // **LE CARTE IN ORIZZONTALE, POCO SOVRAPPOSTE.** Si misurano i
    // rettangoli: stanno sulla stessa riga, e ognuna copre la vicina per
    // meno di un terzo.
    final carte = find.byWidgetPredicate((w) =>
        w.key is ValueKey<String> &&
        (w.key! as ValueKey<String>).value.startsWith('gemello_nastro_carta_'));
    final rettangoli = carte
        .evaluate()
        .map((e) => tester.getRect(find.byWidget(e.widget)))
        .where((r) => r.right > 0 && r.left < 360)
        .toList()
      ..sort((a, b) => a.left.compareTo(b.left));
    final alti = rettangoli.map((r) => r.center.dy.round()).toSet();
    final coperture = [
      for (var i = 1; i < rettangoli.length; i++)
        (rettangoli[i - 1].right - rettangoli[i].left) / rettangoli[i].width,
    ];
    print('ORDINE ER VOCE 6: carte a schermo ${rettangoli.length}, righe '
        '${alti.length}, copertura fra vicine '
        '${coperture.map((c) => c.toStringAsFixed(2)).toSet()}');
    expect(rettangoli.length, greaterThanOrEqualTo(4),
        reason: 'il nastro mostra meno di quattro carte');
    expect(alti, hasLength(1), reason: 'le carte non stanno su una riga');
    for (final c in coperture) {
      expect(c > 0 && c < 1 / 3, isTrue,
          reason: 'due carte vicine si coprono per ${c.toStringAsFixed(2)}: '
              'devono essere poco sovrapposte');
    }

    // Prima del tocco il risultato non si vede, e il nastro sta fermo.
    expect(find.byKey(const Key('gemello_podio')), findsNothing);
    expect(find.byKey(const Key('gemello_nome')), findsNothing);
    final primo = tester.getRect(find.byWidget(carte.evaluate().first.widget));
    await tester.pump(const Duration(seconds: 2));
    expect(tester.getRect(find.byWidget(carte.evaluate().first.widget)), primo,
        reason: 'il nastro corre prima che la persona tocchi il pulsante');
  });

  testWidgets(
      'ER.06: dal pulsante al responso intero, nessun gesto in piu\'; la '
      'corsa si ferma sui tre gemelli, il gemello al centro', (tester) async {
    // Una superficie alta: tutto il responso sta a schermo senza scorrere,
    // quindi l'unico gesto misurato e' il tocco sul pulsante.
    await dallaPorta(tester, const Size(390, 3200));
    final g = GemelloAstrale.per(SchermataDelGemello.cieloPer(
        segno: Zodiac.taurus, nascita: DateTime(1972, 5, 20)))!;
    var gesti = 0;
    await tester.tap(find.byKey(const Key('gemello_cerca')));
    gesti++;
    await tester.pump();

    // A meta' corsa le carte corrono: nessun risultato ancora.
    await tester.pump(SchermataDelGemello.corsaDelNastro ~/ 2);
    expect(find.byKey(const Key('gemello_podio')), findsNothing);

    // **A NASTRO FERMO**, le tre carte al centro sono i tre gemelli.
    await tester.pump(SchermataDelGemello.corsaDelNastro ~/ 2);
    String nomeAl(int i) => tester
        .widget<VipFramedPortrait>(find.descendant(
            of: find.byKey(Key('gemello_nastro_carta_$i')),
            matching: find.byType(VipFramedPortrait)))
        .name;
    const arrivo = SchermataDelGemello.cartaDellArrivo;
    final tre = [nomeAl(arrivo - 1), nomeAl(arrivo), nomeAl(arrivo + 1)];
    final centroDelNastro =
        tester.getRect(find.byKey(const Key('gemello_nastro'))).center.dx;
    final centroDelGemello = tester
        .getRect(find.byKey(const Key('gemello_nastro_carta_$arrivo')))
        .center
        .dx;
    print('ORDINE ER VOCE 6: a nastro fermo $tre, il gemello dista dal '
        'centro ${(centroDelGemello - centroDelNastro).abs()} punti');
    expect(tre, [g.secondo.name, g.vip.name, g.terzo.name],
        reason: 'la corsa non si ferma sui tre gemelli nell\'ordine del '
            'podio');
    expect((centroDelGemello - centroDelNastro).abs(), lessThan(1),
        reason: 'il gemello non sta al centro');

    // **POI TUTTO, SENZA UN TOCCO**: il podio con le percentuali, il
    // cerchio, il nome, il titolo, il responso, le barre e il pulsante che
    // porta alla sinastria intera.
    await tester.pump(SchermataDelGemello.ilResponso);
    await tester.pump(const Duration(milliseconds: 100));
    const attese = <String>[
      'gemello_podio',
      'gemello_cerchio_percentuale',
      'gemello_nome',
      'gemello_titolo_meme',
      'gemello_annuncio',
      'gemello_titolo_responso',
      'gemello_perche_tecnica',
      'gemello_perche_evocativa',
      'gemello_responso',
      'gemello_barre',
      'gemello_apri_sinastria',
    ];
    final mancanti = [
      for (final k in attese)
        if (find.byKey(Key(k)).evaluate().isEmpty) k,
    ];
    final percentuali = [
      for (final v in g.podio)
        if (find.text('${v.posto}° · ${v.punteggio}%').evaluate().isNotEmpty)
          v.posto,
    ];
    print('ORDINE ER VOCE 6: gesti fra il pulsante e il responso intero '
        '${gesti - 1}; delle ${attese.length} parti del responso ne mancano '
        '${mancanti.length}; percentuali sul podio ${percentuali.length} su 3');
    expect(mancanti, isEmpty,
        reason: 'dopo il pulsante, senza altri gesti, mancano: $mancanti');
    expect(percentuali, hasLength(3),
        reason: 'le tre carte non portano la loro percentuale');
    expect(find.byKey(const Key('gemello_cerca')), findsNothing,
        reason: 'a racconto finito il pulsante e\' ancora li\'');
  });
}
