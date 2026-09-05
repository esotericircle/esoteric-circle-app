import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// I MAESTRI GRANDI, CON LA SOVRAPPOSIZIONE VOLUTA. Ordine BD voci 01 e 04.
///
/// **Parole del fondatore, build 2198**: "i maestri sono troppo piccoli,
/// bisogna ingrandirli tanto che lateralmente si devono sovrapporre un
/// pochino, cosi' da rendere la profondita' tra l'avatar davanti e quelli
/// dietro".
///
/// Le chiavi dei tre posti stanno sulle COLONNE DELLA CORNICE VISIBILE, non
/// sulla scatola con i margini trasparenti: i rettangoli misurati qui sono
/// quelli che l'occhio vede e che il dito tocca.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> monta(WidgetTester tester, Size misura) async {
    SharedPreferences.setMockInitialValues(
        const {'onboarding.done': true, 'santuario.greeted': true});
    tester.view.physicalSize = misura * 3.0;
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
        EsotericCircleApp(conIntro: false, services: AppServices.offline()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  Rect di(WidgetTester tester, String chiave) =>
      tester.getRect(find.byKey(Key(chiave)));

  testWidgets(
      'BD.01: la centrale copre un poco le laterali, da entrambi i lati',
      (tester) async {
    await monta(tester, const Size(360, 797));
    final centro = di(tester, 'santuario_central_bust');
    final sinistra = di(tester, 'santuario_side_left');
    final destra = di(tester, 'santuario_side_right');
    final aSinistra = sinistra.right - centro.left;
    final aDestra = centro.right - destra.left;
    // ignore: avoid_print
    print('ORDINE BD VOCE 01: la centrale copre ${aSinistra.round()} punti '
        'della laterale sinistra e ${aDestra.round()} della destra, su '
        'cornici laterali larghe ${sinistra.width.round()}');
    for (final v in [(aSinistra, 'sinistra'), (aDestra, 'destra')]) {
      expect(v.$1, greaterThan(4),
          reason: 'la centrale non si sovrappone alla ${v.$2}: la '
              'profondita\' chiesta dal fondatore non si vede');
      expect(v.$1, lessThan(sinistra.width * 0.55),
          reason: 'la centrale copre ${v.$1.round()} punti della ${v.$2}, '
              'piu\' di meta\' cornice: non e\' piu\' "un pochino"');
    }
  });

  testWidgets('BD.01: i Maestri sono piu\' grandi della 2198', (tester) async {
    await monta(tester, const Size(360, 797));
    final centro = di(tester, 'santuario_central_bust');
    final sinistra = di(tester, 'santuario_side_left');
    // ignore: avoid_print
    print('ORDINE BD VOCE 01: il centrale e\' alto ${centro.height.round()} '
        'punti (era 247), il laterale ${sinistra.height.round()} (era 169)');
    expect(centro.height, greaterThanOrEqualTo(260),
        reason: 'il centrale e\' sceso sotto i 260 punti: sulla 2198 ne '
            'faceva 247 e il fondatore li ha chiesti piu\' grandi');
    expect(sinistra.height, greaterThanOrEqualTo(195),
        reason: 'il laterale e\' sceso: la scala da dietro era 0,685 ed e\' '
            'stata portata a 0,775 apposta');
  });

  testWidgets('BD.04: sullo schermo piccolo i Maestri si vedono davvero',
      (tester) async {
    await monta(tester, const Size(320, 568));
    final centro = di(tester, 'santuario_central_bust');
    final sinistra = di(tester, 'santuario_side_left');
    final titolo = di(tester, 'santuario_sky_title');
    // ignore: avoid_print
    print('ORDINE BD VOCE 04: a 320x568 il centrale e\' alto '
        '${centro.height.round()} (era 150), il laterale parte da '
        '${sinistra.top.round()} e il titolo finisce a '
        '${titolo.bottom.round()}');
    expect(centro.height, greaterThanOrEqualTo(165),
        reason: 'sullo schermo piccolo il centrale e\' tornato francobollo');
    // **IL TITOLO NON SI BUCA.** Misurato: con l\'innalzamento pieno la testa
    // del laterale saliva fino a 153 e il titolo si leggeva a pezzi.
    expect(sinistra.top, greaterThan(titolo.bottom),
        reason: 'la testa del laterale buca il titolo del cielo: '
            'l\'innalzamento smorzato dei posti stretti non sta agendo');
  });
}
