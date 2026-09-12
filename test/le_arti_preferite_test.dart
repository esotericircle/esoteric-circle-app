import 'package:esoteric_circle/core/arts/arti_preferite.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/santuario/widgets/tue_arti_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LO SCAFFALE E' "LE ARTI PREFERITE". Ordine AK voce 01, voce di Mauro del
/// 17 agosto 2026.
///
/// Tre pretese, misurate sullo scaffale montato SENZA salvataggi su disco
/// (cioe' sul seme): il titolo dice "Le arti preferite"; le bolle sono le
/// SETTE di Mauro nell'ordine esatto suo (horoscope, tarot_spread_three,
/// synastry_vip, rune_draw, guide_animal, meditation, face_constellation);
/// la bolla della stesa porta l'etichetta breve "Tarocchi", che e' un dato
/// del controller e MAI un rinomino del catalogo.
///
/// **DALL'ORDINE BK VOCE 01 le etichette brevi sono DUE**: la stesa e
/// l'Oroscopo. Prima l'Oroscopo non ne aveva, e questa prova pretendeva che
/// non ne avesse: adesso pretende il contrario, perche' la decisione del
/// fondatore l'ha cambiata.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const setteDiMauro = [
    'horoscope',
    'tarot_spread_three',
    'synastry_vip',
    'rune_draw',
    'guide_animal',
    'meditation',
    'face_constellation',
  ];

  test('il seme e\' le sette di Mauro, nell\'ordine suo', () {
    for (final maestro in [null, ...Maestro.values]) {
      final seme = ArtiPreferiteController.semePer(maestro);
      // ignore: avoid_print
      print('ORDINE AK VOCE 01: seme per ${maestro?.id ?? "nessuno"}: $seme');
      expect(seme, setteDiMauro,
          reason: 'il seme per ${maestro?.id ?? "chi non ha Maestro"} non e\' '
              'l\'elenco di Mauro nell\'ordine suo');
    }
  });

  test('l\'etichetta breve della stesa e\' "Tarocchi", nel dato', () {
    expect(ArtiPreferiteController.etichettaBreve('tarot_spread_three'),
        'Tarocchi',
        reason: 'la decisione di Mauro: nello scaffale la stesa si chiama '
            'Tarocchi, senza rinominare il catalogo');
    expect(ArtiPreferiteController.etichettaBreve('horoscope'), 'Oroscopo',
        reason: 'ordine BK voce 01: nello scaffale l\'arte si chiama '
            '"Oroscopo", perche\' il nome lungo veniva rimpicciolito dal '
            'FittedBox');
    expect(ArtiPreferiteController.etichettaBreve('rune_draw'), isNull,
        reason: 'le arti senza etichetta breve tengono il titolo del '
            'catalogo');
  });

  testWidgets('lo scaffale montato: titolo, sette bolle in ordine, Tarocchi',
      (tester) async {
    SharedPreferences.setMockInitialValues(const {});
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ArtiPreferiteController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (ctx, child) => MaestroScope(child: child!),
        home: Material(
          child: SingleChildScrollView(
            child: TueArtiView(onOpen: (_) {}),
          ),
        ),
      ),
    ));
    await tester.pump();
    expect(find.text('Le arti preferite'), findsWidgets,
        reason: 'il titolo dello scaffale deve dire "Le arti preferite"');
    expect(find.text('Le tue arti'), findsNothing,
        reason: 'il titolo vecchio non deve piu\' comparire');
    expect(find.text('Tarocchi'), findsOneWidget,
        reason: 'la bolla della stesa deve dire "Tarocchi", etichetta breve '
            'di Mauro');
    expect(find.text('Stesa di Tarocchi'), findsNothing,
        reason: 'nello scaffale il nome lungo non compare: vive nel catalogo '
            'e in ogni altro posto dell\'app');
  });
}
