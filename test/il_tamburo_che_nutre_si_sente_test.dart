import 'dart:io';

import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/rituals/guide_animal_derivation.dart';
import 'package:esoteric_circle/core/sensi/catalogo_suoni.dart';
import 'package:esoteric_circle/core/sensi/palette_sensoriale.dart';
import 'package:esoteric_circle/core/settings/settings_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/maestri/caligo/viaggio/il_tamburo_che_nutre.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// **IL TAMBURO CHE NUTRE SI SENTE.** Ordine DL voce 11, 14 settembre 2026.
///
/// Il fondatore, dopo la prova della build 2250: *"il tamburo non si sente
/// quando l'app chiede l'azione"*. Il nutrimento faceva partire il battito
/// continuo della discesa e, al tocco, vibrava soltanto. Adesso a ogni tocco
/// suona il colpo del tamburo insieme alla vibrazione, al volume degli
/// effetti; il colpo di prima si ferma quando parte il nuovo; e il battito
/// continuo non parte piu', perche' due tamburi insieme si pestano i piedi.
void main() {
  tearDown(() {
    PaletteSensoriale.spiaDelColpo = null;
    PaletteSensoriale.spiaDelTamburo = null;
    PaletteSensoriale.colpoPresenteNelleProve = null;
    PaletteSensoriale.volumiChiestiNelleProve = null;
  });

  Future<void> apri(WidgetTester tester, SettingsController impostazioni,
      {bool riconosciuto = true}) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: impostazioni,
      child: MaterialApp(
        home: Scaffold(
          body: IlTamburoCheNutre(
            animale: GuideAnimalDerivation.forSign(Zodiac.cancer),
            palette: MaestroPalette.caligo,
            quandoHaiFinito: () {},
            quandoTorni: () {},
            riconosciuto: riconosciuto,
          ),
        ),
      ),
    ));
    await tester.pump();
  }

  Future<void> tocca(WidgetTester tester, int volte) async {
    for (var i = 0; i < volte; i++) {
      await tester.tap(find.byKey(const Key('viaggio_tamburo_che_nutre')));
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump(const Duration(milliseconds: 250));
    }
  }

  testWidgets(
      'A OGNI TOCCO UN COLPO, al volume degli effetti, e nessun '
      'battito continuo sotto', (tester) async {
    final colpi = <double>[];
    final battiti = <bool>[];
    final volumi = <double>[];
    PaletteSensoriale.spiaDelColpo = colpi.add;
    PaletteSensoriale.spiaDelTamburo = battiti.add;
    PaletteSensoriale.colpoPresenteNelleProve = true;
    PaletteSensoriale.tamburoPresenteNelleProve = true;
    PaletteSensoriale.volumiChiestiNelleProve = volumi;
    await apri(
        tester,
        SettingsController(
            suonoEVibrazione: true, volumeEffetti: 0.4, volumeMusica: 0.9));
    await tester.pump(const Duration(seconds: 1));
    expect(battiti, isEmpty,
        reason: 'il nutrimento fa partire il battito continuo della discesa');
    await tocca(tester, 3);
    expect(colpi, hasLength(3), reason: 'tre tocchi, ${colpi.length} colpi');
    expect(
        volumi,
        [
          for (var i = 0; i < 3; i++)
            closeTo(IlColpoDelTamburo.volume * 0.4, 1e-9),
        ],
        reason: 'il colpo non segue il cursore degli effetti');
    // Il nutrimento dura quaranta secondi: si lascia finire.
    await tester.pump(IlTamburoCheNutre.quantoDura);
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets(
      'SENZA IL FILE IL TOCCO VIBRA SOLTANTO, senza errori e senza '
      'abbassare la musica', (tester) async {
    final colpi = <double>[];
    final volumi = <double>[];
    PaletteSensoriale.spiaDelColpo = colpi.add;
    PaletteSensoriale.colpoPresenteNelleProve = false;
    PaletteSensoriale.volumiChiestiNelleProve = volumi;
    await apri(tester, SettingsController(suonoEVibrazione: true));
    await tocca(tester, 2);
    expect(tester.takeException(), isNull);
    expect(colpi, hasLength(2), reason: 'il colpo si chiede a ogni tocco');
    expect(volumi, isEmpty,
        reason: 'senza file la musica si abbasserebbe sotto un silenzio');
    await tester.pump(IlTamburoCheNutre.quantoDura);
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('A EFFETTI SPENTI IL COLPO TACE', (tester) async {
    final colpi = <double>[];
    PaletteSensoriale.spiaDelColpo = colpi.add;
    PaletteSensoriale.colpoPresenteNelleProve = true;
    await apri(tester,
        SettingsController(suonoEVibrazione: true, effettiSonori: false));
    await tocca(tester, 2);
    expect(colpi, isEmpty,
        reason: 'l interruttore degli effetti e spento e il colpo suona');
    await tester.pump(IlTamburoCheNutre.quantoDura);
    await tester.pump(const Duration(seconds: 2));
  });

  test('IL COLPO STA DOVE DICE L ORDINE, ed e un suono diverso dal battito',
      () {
    expect(IlColpoDelTamburo.nelPacchetto,
        'assets/audio/mondo_di_sotto/tamburo_colpo.mp3');
    expect(IlColpoDelTamburo.nelPacchetto,
        isNot(IlTamburoDellaDiscesa.nelPacchetto));
    expect(IlColpoDelTamburo.volume, SuonoDelCerchio.volumeDegliEffetti);
    expect(File('assets/audio/mondo_di_sotto/LEGGIMI.md').readAsStringSync(),
        contains('tamburo_colpo.mp3'));
  });

  testWidgets(
      'PRIMA DEL RICONOSCIMENTO SI AVVICINA L OMBRA, e il nome non si dice. '
      'Ordine DN voce 06', (tester) async {
    // Il tamburo si apre anche dall'avviso della distanza, che c'e' solo
    // prima della quarta discesa: li' mostrava l'illustrazione intera e
    // diceva il nome. **Il nome non si dice prima della quarta**, ordine DC.
    final animale = GuideAnimalDerivation.forSign(Zodiac.cancer);
    await apri(tester, SettingsController(suonoEVibrazione: false),
        riconosciuto: false);
    expect(
        find.byKey(const Key('viaggio_ombra_che_si_avvicina')), findsOneWidget);
    bool illustrazione() => tester
        .widgetList<Image>(find.byType(Image))
        .any((i) => '${i.image}'.contains(animale.fullPath));
    expect(illustrazione(), isFalse,
        reason: 'prima del riconoscimento si vede l illustrazione intera');
    // Quaranta secondi di battito, un colpo ogni sette decimi.
    for (var i = 0; i < 62; i++) {
      await tester.tap(find.byKey(const Key('viaggio_tamburo_che_nutre')));
      await tester.pump(const Duration(milliseconds: 700));
    }
    await tester.pump(const Duration(seconds: 1));
    final riga = tester
        .widget<Text>(find.byKey(const Key('viaggio_istruzione_del_tamburo')))
        .data!;
    expect(riga, "L'animale è vicino a te.");
    expect(find.textContaining(animale.name), findsNothing,
        reason: 'il nome dell animale si legge prima della quarta discesa');
  });
}
