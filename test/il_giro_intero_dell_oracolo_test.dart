// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/sensi/la_suoneria.dart';
import 'package:esoteric_circle/core/settings/settings_controller.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/angels/oracolo/la_geometria_dell_altare.dart';
import 'package:esoteric_circle/features/angels/oracolo/oracolo_degli_angeli_screen.dart';
import 'package:esoteric_circle/features/scene/la_scena_in_video.dart';
import 'package:esoteric_circle/features/tarot/attesa_di_medora.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'il_giro_dell_oracolo.dart';

/// **IL GIRO INTERO DELL'ORACOLO, COME UNA PERSONA.** Ordine FY voce FY.21,
/// 16 ottobre 2026. Il fondatore: *"Code deve fare simulazione per ogni
/// funzionalita' qui sopra"*.
///
/// Dalla casa si apre l'Oracolo; il video parte (qui il lettore finto
/// mostra il primo fotogramma del filmato vero, il video si guarda sul
/// telefono); finito il video la scena e' ferma; si apre un argomento con le
/// sue dieci domande, se ne sceglie una, la si affida; si scelgono le tre
/// carte dal mazzo coperto; il pulsante avvia la lettura; la domanda sale, le
/// carte si girano sull'altare vuoto; la risposta e' una coppia sola; la
/// bolla dice chi e' l'angelo; la barra resta velata col testo che le scorre
/// sotto; una nuova domanda; la freccia riporta a casa. Ogni passo ha la sua
/// asserzione, e con `--dart-define=CATTURE=si` la sua cattura in
/// `docs/collaudo/FY/oracolo/`, a 360 per 797 punti col rapporto 3.
///
/// **L'ORDINE GA**, voci GA.03, GA.05 e GA.08, 20 ottobre 2026: a scena
/// ferma l'altare e' vuoto (nessun dorso prima della scelta), la risposta ha
/// la forma nuova (il responso principale, con la Lunga dall'Iniziato) e la
/// bolla porta la carta singola breve. I passi restano sedici.
const _catture = String.fromEnvironment('CATTURE');

class _LettoreFinto implements LettoreDiScena {
  VoidCallback? _ascolta;
  bool _pronto = false, _cominciato = false, _finito = false;
  @override
  bool get pronto => _pronto;
  @override
  bool get fallito => false;
  @override
  bool get cominciato => _cominciato;
  @override
  bool get finito => _finito;
  @override
  void ascolta(VoidCallback? q) => _ascolta = q;
  @override
  Future<void> apri() async {
    _pronto = true;
    _ascolta?.call();
  }

  @override
  Future<void> volume(double q) async {}
  @override
  Future<void> avvia() async {}
  @override
  Future<void> sospendi() async {}
  @override
  // Il primo fotogramma mentre gira, l'ultimo quando e' finito: il lettore
  // vero si ferma sull'ultimo fotogramma.
  Widget disegna() => Image.asset(
      _finito
          ? GeometriaDellAltare.ultimoFotogramma
          : GeometriaDellAltare.primoFotogramma,
      key: const Key('lettore_finto_oracolo'),
      fit: GeometriaDellAltare.taglio);
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

void main() {
  final radice = GlobalKey();
  final scattate = <String>[];

  setUp(() {
    LaSuoneria.spentaPerLeProve = true;
    // GC.16: il cosmo dietro l'Oracolo ascolta i sensori.
    silenziaISensoriDelCosmo();
  });
  tearDown(() => LaSuoneria.spentaPerLeProve = null);

  Future<void> passa(WidgetTester tester, [int volte = 6]) async {
    for (var i = 0; i < volte; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> scatta(WidgetTester tester, String nome) async {
    scattate.add(nome);
    if (_catture.isEmpty) return;
    await tester.runAsync(() async {
      for (final e in find.byType(Image).evaluate()) {
        await precacheImage((e.widget as Image).image, e);
      }
    });
    await tester.pump();
    await tester.runAsync(() async {
      final rb =
          radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final img = await rb.toImage(pixelRatio: 3.0);
      final dati = await img.toByteData(format: ui.ImageByteFormat.png);
      final dir = Directory('docs/collaudo/FY/oracolo');
      if (!dir.existsSync()) dir.createSync(recursive: true);
      File('${dir.path}/fy21_$nome.png')
          .writeAsBytesSync(dati!.buffer.asUint8List());
      print('FY.21 CATTURA: ${dir.path}/fy21_$nome.png');
      img.dispose();
    });
  }

  testWidgets('FY.21 il giro intero dell\'Oracolo degli Angeli',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2391);
    addTearDown(tester.view.reset);
    final lettore = _LettoreFinto();
    final chiamate = <String>[];
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(
            create: (_) => SettingsController(suonoEVibrazione: false)),
        ChangeNotifierProvider(
            create: (_) => EntitlementService(initial: Tier.tier1)),
      ],
      child: RepaintBoundary(
        key: radice,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark(),
          builder: (c, figlio) => MaestroScope(child: figlio!),
          home: Builder(
            builder: (context) => Scaffold(
              key: const Key('casa'),
              body: Center(
                child: TextButton(
                  key: const Key('apri_l_oracolo'),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => OracoloDegliAngeliScreen(
                        fabbricaDellaScena: () => lettore,
                        caso: Random(7),
                        adesso: () => DateTime(2026, 10, 15, 10, 5),
                        identita: BirthIdentity(
                            birthMoment: DateTime(1990, 5, 12, 14, 30),
                            hasBirthTime: true),
                        chiamata: (i, r, c) async {
                          chiamate.add(r);
                          return jsonFintoDellOracolo(c,
                              titolo: 'Il passo giusto chiede un cuore '
                                  'che ascolta');
                        },
                      ),
                    ),
                  ),
                  child: const Text('Apri l\'Oracolo degli Angeli'),
                ),
              ),
            ),
          ),
        ),
      ),
    ));
    await passa(tester, 2);
    await scatta(tester, '01_casa');

    // APERTURA E VIDEO.
    await tester.tap(find.byKey(const Key('apri_l_oracolo')));
    await passa(tester, 6);
    lettore.comincia();
    await passa(tester, 3);
    expect(find.byKey(const Key('lettore_finto_oracolo')), findsOneWidget);
    // **LA DOMANDA STA SOTTO IL TAVOLO** (GC.09), montata e trasparente
    // finche' il filmato gira. LAPIDE: "findsNothing", quando stava sopra la
    // scena.
    expect(
        tester
            .widget<AnimatedOpacity>(find
                .ancestor(
                    of: find.byKey(const Key('oracolo_domanda')),
                    matching: find.byType(AnimatedOpacity))
                .first)
            .opacity,
        0,
        reason: 'a video in corso sopra la scena c\'e\' solo il video');
    await scatta(tester, '02_video_in_corso');
    lettore.finisci();
    await passa(tester, 10);
    expect(find.byKey(const Key('oracolo_domanda')), findsOneWidget);
    // GA.08: prima qui i tre dorsi stavano sull'altare (findsOneWidget).
    for (var i = 0; i < 3; i++) {
      expect(find.byKey(Key('oracolo_dorso_$i')), findsNothing);
    }
    await scatta(tester, '03_scena_ferma_e_domanda');

    // SCELTA DELLA DOMANDA: un argomento, le sue dieci domande. La domanda
    // sta sotto il tavolo (GC.09): si porta in vista prima di toccarla.
    await Scrollable.ensureVisible(
        tester.element(find.byKey(const Key('oracolo_tema_lavoro'))),
        alignment: 0.3);
    await passa(tester, 1);
    await tester.tap(find.byKey(const Key('oracolo_tema_lavoro')));
    await passa(tester, 3);
    expect(find.byKey(const Key('oracolo_tema_aperto')), findsOneWidget);
    for (var i = 0; i < 4; i++) {
      expect(find.byKey(Key('oracolo_proposta_$i')), findsOneWidget);
    }
    await scatta(tester, '04_le_dieci_domande');
    await tester.tap(find.byKey(const Key('oracolo_proposta_0')));
    await passa(tester, 2);
    final domanda = tester
        .widget<TextField>(find.byKey(const Key('oracolo_campo_domanda')))
        .controller!
        .text;
    expect(domanda, 'Quale passo devo fare nel mio lavoro?');
    await scatta(tester, '05_la_domanda_scelta');

    // SCELTA DELLE CARTE: scelta la domanda il mazzo si e' acceso da solo
    // (GD.06).
    await passa(tester, 8);
    expect(find.byKey(const Key('oracolo_mazzo_coperto')), findsOneWidget);
    expect(find.byKey(const Key('oracolo_dorso_0')), findsNothing);
    await scatta(tester, '06_il_mazzo_coperto');
    await toccaIlDorso(tester, dorsiDelGiro[0]);
    expect(find.byKey(const Key('oracolo_dorso_0')), findsOneWidget);
    await scatta(tester, '07_la_prima_carta_sull_altare');
    await toccaIlDorso(tester, dorsiDelGiro[1]);
    await toccaIlDorso(tester, dorsiDelGiro[2]);
    expect(chiamate, isEmpty, reason: 'la lettura e\' partita da sola');
    // La terza carta finisce di comparire sull'altare.
    await passa(tester, 5);
    await scatta(tester, '08_tre_carte_e_il_pulsante');

    // AZIONE: il pulsante avvia la lettura.
    final pulsante = find.byKey(const Key('oracolo_avvia_la_lettura'));
    await Scrollable.ensureVisible(tester.element(pulsante), alignment: 0.5);
    await tester.pump();
    await tester.tap(pulsante);
    await passa(tester, 12);
    expect(find.byKey(const Key('oracolo_lettere_di_luce')), findsOneWidget);
    await scatta(tester, '09_la_domanda_sale');
    await passa(tester, 10);
    // GC.13: dopo le lettere Medora riflette, e le carte si girano solo
    // dopo. Si aspetta che la riflessione cominci e che finisca.
    for (var i = 0;
        i < 200 && find.byType(AttesaDiMedora).evaluate().isEmpty;
        i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    await scatta(tester, '09b_medora_riflette');
    for (var i = 0;
        i < 400 && find.byType(AttesaDiMedora).evaluate().isNotEmpty;
        i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    final piatta =
        tester.getRect(find.byKey(const Key('oracolo_dorso_0'))).width;
    var larga = piatta;
    for (var i = 0; i < 200 && larga > piatta / 5; i++) {
      await tester.pump(const Duration(milliseconds: 8));
      for (final k in const ['oracolo_dorso_0', 'oracolo_carta_custode']) {
        final f = find.byKey(Key(k));
        if (f.evaluate().isNotEmpty) larga = tester.getRect(f).width;
      }
    }
    // LAPIDE, FY.17: `AltareVuoto`, la toppa sui dorsi dipinti del v1. Col
    // filmato v2 (GC Aggiunta) l'ultimo fotogramma ha gia' l'altare vuoto.
    expect(
        (tester.widget<Image>(find.byKey(const Key('oracolo_fotogramma'))).image
                as AssetImage)
            .assetName,
        GeometriaDellAltare.ultimoFotogramma);
    await scatta(tester, '10_carta_di_taglio_sull_altare_vuoto');
    // Le tre carte girate sull'altare, prima che la lettura scorra alla
    // risposta.
    bool girate() => [
          for (final r in const ['custode', 'cuore', 'intelletto'])
            find.byKey(Key('oracolo_carta_$r')).evaluate().length,
        ].every((n) => n == 1);
    // Si girano una alla volta (GC.14): tre girate da mezzo secondo.
    for (var i = 0; i < 120 && !girate(); i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(girate(), isTrue, reason: 'le tre carte non si sono girate');
    await scatta(tester, '11_le_carte_girate');

    // RISPOSTA: dopo le carte che si alzano (GC.14) la lettura scorre da
    // se' alla risposta. Si aspetta il responso, non un numero di secondi.
    for (var i = 0;
        i < 200 &&
            find
                .byKey(const Key('oracolo_responso_principale'))
                .evaluate()
                .isEmpty;
        i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await passa(tester, 10);
    expect(chiamate, hasLength(1));
    // GA.03: il responso principale nella forma nuova, col riquadro "Cosa
    // fare adesso" (prima: un riquadro solo, oracolo_riquadro, FY.19).
    expect(
        find.byKey(const Key('oracolo_responso_principale')), findsOneWidget);
    expect(
        find.byKey(const Key('oracolo_principale_cosa_fare')), findsOneWidget);
    await scatta(tester, '12_la_risposta');
    final bolla = find.byKey(const Key('oracolo_bolla_custode'));
    await Scrollable.ensureVisible(tester.element(bolla), alignment: 0.1);
    await passa(tester, 3);
    expect(find.byKey(const Key('oracolo_chi_e_custode')), findsOneWidget);
    await scatta(tester, '13_la_carta_e_chi_e');
    // La barra col testo che scorre sotto.
    await Scrollable.ensureVisible(
        tester.element(find.byKey(const Key('oracolo_principale_cosa_fare'))),
        alignment: 0);
    await tester.drag(find.byType(ListView).first, const Offset(0, 40));
    await passa(tester, 3);
    await scatta(tester, '14_la_barra_sopra_il_testo');

    // UNA NUOVA DOMANDA, POI IL RITORNO.
    final nuova = find.byKey(const Key('oracolo_nuova_domanda'));
    await Scrollable.ensureVisible(tester.element(nuova), alignment: 0.5);
    await tester.pump();
    await tester.tap(nuova);
    await passa(tester, 8);
    expect(find.byKey(const Key('oracolo_responso')), findsNothing);
    expect(find.byKey(const Key('oracolo_domanda')), findsOneWidget);
    await scatta(tester, '15_una_nuova_domanda');
    await tester.tap(find.byType(BackButton));
    await passa(tester, 8);
    expect(find.byKey(const Key('casa')), findsOneWidget);
    expect(find.byType(OracoloDegliAngeliScreen), findsNothing);
    await scatta(tester, '16_il_ritorno');
    print('FY.21 MISURA passi del giro con la loro asserzione: '
        '${scattate.length} (${scattate.join(', ')})');
    // Sedici passi dell'ordine FY e uno dell'ordine GC: dopo l'invio Medora
    // riflette (GC.13, passo 09b) prima che le carte si girino.
    expect(scattate, hasLength(17));
  });
}
