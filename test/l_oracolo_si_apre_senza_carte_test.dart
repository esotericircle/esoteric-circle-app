// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:math';

import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/sensi/la_suoneria.dart';
import 'package:esoteric_circle/core/settings/settings_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/angels/oracolo/la_geometria_dell_altare.dart';
import 'package:esoteric_circle/features/angels/oracolo/oracolo_degli_angeli_screen.dart';
import 'package:esoteric_circle/features/scene/la_scena_in_video.dart';
import 'package:esoteric_circle/features/tarot/stesa_fan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'il_giro_dell_oracolo.dart';

/// **L'ORACOLO SI APRE SENZA CARTE IN VISTA.** Ordine GA voce GA.08, 20
/// ottobre 2026. Il fondatore: *"L'oracolo degli angeli non mostra
/// all'inizio, all'apertura, nessuna Carta prima che l'utente le scelga"*;
/// l'ordine: *"All'apertura dell'Oracolo degli Angeli nessuna carta e'
/// visibile in scena: ne' sul tavolo ne' nel video della scena ne' fuori dal
/// ventaglio. Le carte compaiono solo quando la persona le sceglie dal
/// ventaglio."*
///
/// Le carte si contano come si vedono: ogni immagine della famiglia degli
/// angeli (`assets/img/angeli/`, i 72 e il dorso) e ogni `LaCartaDellAngelo`
/// in albero, fuori dal ventaglio della scelta. Il filmato vero si ferma
/// prima che le carte scendano dalla scala e sfuma sulla scena ferma, dove
/// l'altare e' vuoto: i numeri della misura sui fotogrammi stanno in
/// `GeometriaDellAltare` e in `docs/collaudo/GA/ga08_le_carte_nel_filmato.txt`.
/// Vista rossa: `docs/collaudo/GA/oracolo_regola_a.txt`.
class _Lettore implements LettoreDiScena {
  _Lettore({this.fallira = false});
  final bool fallira;
  VoidCallback? _ascolta;
  bool _pronto = false, _fallito = false, _cominciato = false;
  bool _finito = false;

  @override
  bool get pronto => _pronto;
  @override
  bool get fallito => _fallito;
  @override
  bool get cominciato => _cominciato;
  @override
  bool get finito => _finito;
  @override
  void ascolta(VoidCallback? q) => _ascolta = q;
  @override
  Future<void> apri() async {
    fallira ? _fallito = true : _pronto = true;
    _ascolta?.call();
  }

  @override
  Future<void> volume(double q) async {}
  @override
  Future<void> avvia() async {}
  @override
  Future<void> sospendi() async {}
  @override
  Widget disegna() => const ColoredBox(
      key: Key('finta_del_filmato_ga08'), color: Color(0xFF102030));
  @override
  void chiudi() {}

  void comincia() {
    _cominciato = true;
    _ascolta?.call();
  }

  void finisci() {
    _finito = true;
    _ascolta?.call();
  }
}

Future<void> _monta(WidgetTester tester, _Lettore lettore) async {
  SharedPreferences.setMockInitialValues({});
  await tester.pumpWidget(const SizedBox());
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => MaestroController()),
      ChangeNotifierProvider(create: (_) => QualityTierController()),
      ChangeNotifierProvider(
          create: (_) => SettingsController(suonoEVibrazione: false)),
      ChangeNotifierProvider(
          create: (_) => EntitlementService(initial: Tier.tier1)),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (c, figlio) => MaestroScope(child: figlio!),
      home: OracoloDegliAngeliScreen(
        fabbricaDellaScena: () => lettore,
        caso: Random(7),
        adesso: () => DateTime(2026, 10, 15, 10, 5),
        identita: BirthIdentity(
            birthMoment: DateTime(1990, 5, 12, 14, 30), hasBirthTime: true),
        chiamata: (i, r, c) async => jsonFintoDellOracolo(c),
      ),
    ),
  ));
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

String? _asset(ImageProvider p) => switch (p) {
      AssetImage(:final assetName) => assetName,
      ResizeImage(:final imageProvider) => _asset(imageProvider),
      _ => null,
    };

/// Le carte in vista fuori dal ventaglio: le immagini della famiglia degli
/// angeli e le carte dipinte in albero, e i dorsi di Flutter sull'altare.
List<String> _carteInVista(WidgetTester tester) {
  final ventaglio = find.byType(StesaFan);
  bool nelVentaglio(Element e) =>
      ventaglio.evaluate().isNotEmpty &&
      find
          .descendant(of: ventaglio, matching: find.byWidget(e.widget))
          .evaluate()
          .isNotEmpty;
  return [
    for (final e in find.byType(Image).evaluate())
      if (_asset((e.widget as Image).image) case final a?
          when a.startsWith('assets/img/angeli/') && !nelVentaglio(e))
        'immagine $a',
    for (final e in find.byType(LaCartaDellAngelo).evaluate())
      if (!nelVentaglio(e))
        'carta ${(e.widget as LaCartaDellAngelo).angelo.name}',
    for (var i = 0; i < 3; i++)
      if (find.byKey(Key('oracolo_dorso_$i')).evaluate().isNotEmpty)
        'dorso $i sull\'altare',
  ];
}

void main() {
  setUp(() => LaSuoneria.spentaPerLeProve = true);
  tearDown(() => LaSuoneria.spentaPerLeProve = null);

  testWidgets(
      'all\'apertura, a scena ferma, nessuna carta in vista: l\'altare e\' '
      'vuoto e l\'angelo dell\'ora non ha la sua carta', (tester) async {
    await _monta(tester, _Lettore(fallira: true));
    expect(find.byKey(const Key('oracolo_domanda')), findsOneWidget);
    final viste = _carteInVista(tester);
    print('GA.08 MISURA carte in vista all\'apertura (scena ferma): '
        '${viste.length} $viste');
    expect(viste, isEmpty);
    // L'ultimo fotogramma porta i tre dorsi dipinti: l'altare vuoto li copre.
    expect(find.byType(AltareVuoto), findsOneWidget);
    expect(
        find.descendant(
            of: find.byKey(const Key('oracolo_angelo_dell_ora')),
            matching: find.byType(LaCartaDellAngelo)),
        findsNothing);
  });

  testWidgets(
      'il video: a scena ferma il filmato sfuma, e sotto l\'altare e\' vuoto',
      (tester) async {
    final lettore = _Lettore();
    await _monta(tester, lettore);
    lettore.comincia();
    await tester.pump(const Duration(milliseconds: 200));
    final filmato = find.byKey(const Key('oracolo_filmato'));
    expect(tester.widget<IlFilmatoCheSfuma>(filmato).saltato, isFalse);
    lettore.finisci();
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(tester.widget<IlFilmatoCheSfuma>(filmato).saltato, isTrue,
        reason: 'a scena ferma il filmato resta sopra coi suoi dorsi dipinti');
    final viste = _carteInVista(tester);
    print('GA.08 MISURA carte in vista dopo il video: ${viste.length} $viste');
    expect(viste, isEmpty);
  });

  test(
      'il filmato vero si ferma e sfuma prima che le carte compaiano nel '
      'fotogramma', () {
    const passoDelLettore = Duration(milliseconds: 100);
    final fine = GeometriaDellAltare.finoAlleCarte +
        passoDelLettore +
        IlFilmatoCheSfuma.dissolvenza;
    print('GA.08 MISURA la dissolvenza finisce a ${fine.inMilliseconds} ms; '
        'la prima carta nel filmato a '
        '${GeometriaDellAltare.primaCartaNelFilmato.inMilliseconds} ms');
    expect(fine, lessThanOrEqualTo(GeometriaDellAltare.primaCartaNelFilmato));
    final schermata =
        File('lib/features/angels/oracolo/oracolo_degli_angeli_screen.dart')
            .readAsStringSync()
            .replaceAll(RegExp(r'\s+'), ' ');
    expect(
        schermata,
        contains('LettoreDiScena.vero(GeometriaDellAltare.filmato, '
            'finoA: GeometriaDellAltare.finoAlleCarte)'),
        reason: 'il lettore vero dell\'Oracolo non si ferma prima delle carte');
  });

  testWidgets(
      'le carte compaiono solo quando la persona le sceglie, e una domanda '
      'nuova torna all\'altare vuoto', (tester) async {
    await _monta(tester, _Lettore(fallira: true));
    await affidaLaDomanda(tester, 'Devo cambiare lavoro?');
    expect(find.byType(StesaFan), findsOneWidget);
    var viste = _carteInVista(tester);
    print('GA.08 MISURA carte in vista fuori dal ventaglio prima di '
        'scegliere: ${viste.length} $viste');
    expect(viste, isEmpty);
    await toccaIlDorso(tester, dorsiDelGiro[0]);
    // Il dorso scelto si posa sull'altare: e' l'unica carta in vista.
    expect(_carteInVista(tester), [
      'immagine ${GeometriaDellAltare.dorso}',
      'dorso 0 sull\'altare',
    ]);
    await toccaIlDorso(tester, dorsiDelGiro[1]);
    await toccaIlDorso(tester, dorsiDelGiro[2]);
    await avviaLaLettura(tester);
    expect(find.byKey(const Key('oracolo_responso')), findsOneWidget);
    final nuova = find.byKey(const Key('oracolo_nuova_domanda'));
    await Scrollable.ensureVisible(tester.element(nuova), alignment: 0.5);
    await tester.pump();
    await tester.tap(nuova);
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    viste = _carteInVista(tester);
    print('GA.08 MISURA carte in vista dopo una domanda nuova: '
        '${viste.length} $viste');
    expect(viste, isEmpty);
  });
}
