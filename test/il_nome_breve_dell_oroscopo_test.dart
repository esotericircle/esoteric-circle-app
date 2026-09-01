import 'dart:math' as math;

import 'package:esoteric_circle/core/arts/art_catalog.dart';
import 'package:esoteric_circle/core/arts/arti_preferite.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/santuario/santuario_screen.dart';
import 'package:esoteric_circle/features/santuario/widgets/tue_arti_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// IL NOME BREVE DELL'OROSCOPO IN HOME. Ordine BK voce 01.
///
/// Parole del fondatore: "la funzionalita' Oroscopo Personalizzato si
/// chiamera' solo oroscopo cosi' il font sara' piu' grande in home".
///
/// **La ragione e' misurabile e non estetica.** Il titolo della bolla vive in
/// un `FittedBox(fit: BoxFit.scaleDown)`, che non ingrandisce mai e
/// rimpicciolisce quello che non ci sta. "Oroscopo Personalizzato" non ci
/// stava, quindi veniva reso in corpo ridotto; "Oroscopo" ci sta, e il corpo
/// resta quello pieno dichiarato dal token.
///
/// Questa prova misura il FATTORE DI SCALA vero applicato dal FittedBox,
/// leggendolo dal render object: il rapporto fra lo spazio che la bolla
/// concede e la larghezza che il testo vorrebbe. Nessun numero e' indovinato:
/// il corpo pieno viene dal token, la larghezza dalla bolla montata a 360
/// punti logici, che e' la misura del telefono su cui l'app si guarda.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// La larghezza del telefono su cui si giudica: 360 punti logici.
  const larghezzaVera = 360.0;

  /// Monta UNA bolla dello scaffale col titolo dato e restituisce le due
  /// misure che decidono la scala: quanta larghezza la bolla concede al
  /// titolo, e quanta ne vorrebbe il titolo al corpo pieno.
  Future<({double concessa, double voluta, double corpoPieno})> misuraLaBolla(
      WidgetTester tester, String titolo) async {
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(larghezzaVera, 797) * 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (ctx, child) => MaestroScope(child: child!),
        home: Material(
          child: Align(
            alignment: Alignment.topCenter,
            child: ShelfCard(
              titolo: titolo,
              anticipo: 'Le quattro schede del tuo giorno.',
              icona: Icons.auto_awesome,
              maestro: Maestro.medora,
              onTap: () {},
            ),
          ),
        ),
      ),
    ));
    await tester.pump();

    final fitted = tester.renderObject<RenderFittedBox>(find.descendant(
      of: find.byType(ShelfCard),
      matching: find.byType(FittedBox),
    ));
    final testo = tester.renderObject<RenderParagraph>(find.text(titolo));
    return (
      concessa: fitted.size.width,
      voluta: fitted.child!.size.width,
      corpoPieno: testo.text.style!.fontSize!,
    );
  }

  /// Il fattore che `BoxFit.scaleDown` applica davvero: rimpicciolisce quando
  /// il testo non ci sta, e non ingrandisce mai.
  double fattoreDi(({double concessa, double voluta, double corpoPieno}) m) =>
      math.min(1.0, m.concessa / m.voluta);

  testWidgets('il nome lungo veniva rimpicciolito, il nome breve no',
      (tester) async {
    // **LA GRANDEZZA MISURATA E' LA CATENA VERA, non un titolo scritto a
    // mano.** La bolla dello scaffale compone il titolo cosi', in
    // `tue_arti_view.dart`: `etichettaBreve(id) ?? arte.title`. Misurare una
    // stringa battuta qui dentro renderebbe questa prova cieca al difetto:
    // resterebbe verde anche togliendo la voce dalla mappa, e una prova che
    // non cade quando il difetto torna non e' una guardia.
    final titoloDelCatalogo =
        ArtCatalog.all.firstWhere((a) => a.id == 'horoscope').title;
    final titoloInHome = ArtiPreferiteController.etichettaBreve('horoscope') ??
        titoloDelCatalogo;

    final lungo = await misuraLaBolla(tester, titoloDelCatalogo);
    final fattoreLungo = fattoreDi(lungo);
    final resaLunga = lungo.corpoPieno * fattoreLungo;

    final breve = await misuraLaBolla(tester, titoloInHome);
    final fattoreBreve = fattoreDi(breve);
    final resaBreve = breve.corpoPieno * fattoreBreve;

    // I numeri, dichiarati: chi legge questa prova deve poterli confrontare
    // con quelli del rapporto senza rieseguirla.
    // ignore: avoid_print
    print('BK.01 MISURA a $larghezzaVera punti logici: '
        'lungo concessa=${lungo.concessa.toStringAsFixed(2)} '
        'voluta=${lungo.voluta.toStringAsFixed(2)} '
        'fattore=${fattoreLungo.toStringAsFixed(4)} '
        'resa=${resaLunga.toStringAsFixed(2)}; '
        'breve concessa=${breve.concessa.toStringAsFixed(2)} '
        'voluta=${breve.voluta.toStringAsFixed(2)} '
        'fattore=${fattoreBreve.toStringAsFixed(4)} '
        'resa=${resaBreve.toStringAsFixed(2)}; '
        'rapporto resa=${(resaBreve / resaLunga).toStringAsFixed(4)}');

    expect(fattoreLungo, lessThan(1.0),
        reason: 'il nome lungo deve risultare RIMPICCIOLITO, altrimenti la '
            'ragione della voce BK.01 non esiste e il numero l\'ha smentita');
    expect(fattoreBreve, 1.0,
        reason: 'il titolo che lo scaffale mostra davvero per l\'Oroscopo '
            '("$titoloInHome") deve stare nella bolla al corpo pieno, cioe\' '
            'con fattore esattamente 1,0');
    expect(resaBreve, breve.corpoPieno,
        reason: 'a fattore 1,0 la misura resa e\' quella del token, intera');
    expect(resaBreve, greaterThan(resaLunga),
        reason: 'la misura del testo a video deve SALIRE: e\' cio\' che il '
            'fondatore ha chiesto');
    // La bolla non deve traboccare: il titolo reso sta dentro lo spazio.
    expect(breve.voluta, lessThanOrEqualTo(breve.concessa),
        reason: 'il titolo breve reso deve stare dentro la larghezza della '
            'bolla a $larghezzaVera punti logici');
  });

  testWidgets(
      'nello scaffale ogni id con etichetta breve mostra l\'etichetta, non il '
      'titolo del catalogo', (tester) async {
    SharedPreferences.setMockInitialValues(const {});
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(larghezzaVera, 797) * 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
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
          child: SingleChildScrollView(child: TueArtiView(onOpen: (_) {})),
        ),
      ),
    ));
    await tester.pump();

    // L'ENUMERAZIONE, e non due casi scelti a mano: per OGNI arte dello
    // scaffale che ha un'etichetta breve, a video si legge l'etichetta e non
    // si legge il titolo del catalogo.
    var conEtichetta = 0;
    for (final arte in ArtCatalog.all) {
      final breve = ArtiPreferiteController.etichettaBreve(arte.id);
      if (breve == null) continue;
      if (find.byType(ShelfCard).evaluate().isEmpty) continue;
      conEtichetta++;
      expect(find.text(breve), findsOneWidget,
          reason: 'lo scaffale deve mostrare l\'etichetta breve "$breve" '
              'per l\'arte ${arte.id}');
      expect(find.text(arte.title), findsNothing,
          reason: 'lo scaffale non deve mostrare il titolo del catalogo '
              '"${arte.title}" per l\'arte ${arte.id}: il nome lungo vive nel '
              'catalogo e in ogni altro posto dell\'app');
    }
    expect(conEtichetta, greaterThanOrEqualTo(2),
        reason: 'dall\'ordine BK le etichette brevi sono almeno due, la stesa '
            'e l\'Oroscopo: se questo numero scende qualcuno ne ha tolta una');
  });

  test('il catalogo continua a dire "Oroscopo Personalizzato"', () {
    final arte = ArtCatalog.all.firstWhere((a) => a.id == 'horoscope');
    expect(arte.title, 'Oroscopo Personalizzato',
        reason: 'BK.01 cambia SOLO il nome sullo scaffale: il catalogo tiene '
            'il nome lungo, che e\' il nome dell\'arte');
  });
}
