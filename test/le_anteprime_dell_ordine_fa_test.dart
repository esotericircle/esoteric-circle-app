// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/cerchio/il_cerchio_sociale.dart';
import 'package:esoteric_circle/core/cerchio/le_icone_del_cerchio.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/cerchio/il_tuo_cerchio_screen.dart';
import 'package:esoteric_circle/features/cerchio/profilo_nel_cerchio_screen.dart';
import 'package:esoteric_circle/features/cerchio/scheda_dell_amico_screen.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'porta_finta_del_cerchio_sociale.dart';

/// **LE ANTEPRIME DELL'ORDINE FA, prima e dopo.** A 360 per 797 punti logici
/// col rapporto di pixel 3, catturate dentro `tester.runAsync` coi `pump`.
/// `--dart-define=STATO=prima` sul codice di partenza (31821ce2), `dopo` sul
/// codice dell'ordine, in `docs/preview/prima_dopo/`.
///
/// **La vetrina, famiglia per famiglia.** Se la vetrina ha le sue scelte di
/// famiglia (ordine FA voce 03) si tocca la scelta; se non le ha (il codice
/// di prima) si porta l'intestazione della famiglia in cima, fin dove
/// l'elenco scorre. Le tre catture devono essere tre schermate diverse: lo
/// pretende `le_catture_della_vetrina_sono_diverse_test.dart`.
const _stato = String.fromEnvironment('STATO');

/// Il profilo di chi aveva scelto un Arcano, due persone che si chiamano allo
/// stesso modo, e il segno "Hai fatto molta strada" ricevuto.
class _PortaDellOrdineFa extends PortaFintaDelCerchioSociale {
  @override
  Future<EsitoSociale?> sociale(String porta,
      [Map<String, Object?> corpo = const {}]) async {
    final e = await super.sociale(porta, corpo);
    if (e == null) return e;
    if (porta == 'ilMioProfiloNelCerchio') {
      return EsitoSociale(dati: {...e.dati, 'icona': 'arcano:1'});
    }
    if (porta == 'ilMioCerchio') {
      final segni = [
        for (final s in (e.dati['segni'] as List? ?? const []))
          if (s is Map && s['id'] == 's1')
            {...s, 'segno': 'coraggio'}
          else
            s,
      ];
      return EsitoSociale(dati: {
        ...e.dati,
        'ricevuti': [
          {
            'uid': 'u-corvo',
            'nome': 'Eco Corvo Mite',
            'icona': 'animale:3',
            'segno': 'scorpio',
            'maestro': 'caligo',
            'sigillo': 'R7KQ',
            'semaforo': 'arancionePieno',
          },
        ],
        'amici': [
          {
            ...PortaFintaDelCerchioSociale.amico,
            'uid': 'u-corvo-2',
            'nome': 'eco corvo mite',
            'icona': 'animale:6',
            'sigillo': 'M4XR',
          },
          PortaFintaDelCerchioSociale.amico,
        ],
        'segni': segni,
      });
    }
    return e;
  }
}

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  final radice = GlobalKey();

  void silenzia() {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (call) async => null);
    for (final n in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      m.setMockStreamHandler(
          EventChannel(n), MockStreamHandler.inline(onListen: (a, e) {}));
    }
  }

  Future<void> passa(WidgetTester tester, [int volte = 8]) async {
    for (var i = 0; i < volte; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  Future<void> scatta(WidgetTester tester, String nome) async {
    await tester.runAsync(() async {
      final rb =
          radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final img = await rb.toImage(pixelRatio: 3.0);
      final dati = await img.toByteData(format: ui.ImageByteFormat.png);
      final dir = Directory('docs/preview/prima_dopo');
      if (!dir.existsSync()) dir.createSync(recursive: true);
      File('${dir.path}/${nome}_$_stato.png')
          .writeAsBytesSync(dati!.buffer.asUint8List());
      print('FA ANTEPRIMA: ${dir.path}/${nome}_$_stato.png '
          '${img.width}x${img.height}');
      img.dispose();
    });
  }

  Future<void> precarica(WidgetTester tester) async {
    await tester.runAsync(() async {
      final ctx = radice.currentContext!;
      for (final f in FamigliaDelleIcone.values) {
        for (final i in IconaDelProfilo.di(f)) {
          await precacheImage(AssetImage(i.asset), ctx);
        }
      }
    });
    await passa(tester, 3);
  }

  Future<void> monta(WidgetTester tester, Widget schermata) async {
    silenzia();
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2391);
    addTearDown(tester.view.reset);
    final finta = _PortaDellOrdineFa();
    final sociale = IlCerchioSociale(porta: finta);
    await tester.runAsync(() async {
      // Una persona dei Pesci: chi aveva un Arcano riceve il suo segno.
      await sociale.sincronizza(
          identita: BirthIdentity(birthMoment: DateTime(1990, 3, 5, 10)),
          oggi: DateTime(2026, 10, 4));
      await sociale.caricaIlCerchio();
    });
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<IlCerchioSociale>.value(value: sociale),
        Provider<AppServices>.value(value: AppServices.offline(null, finta)),
      ],
      child: RepaintBoundary(
        key: radice,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark(),
          builder: (c, figlio) => MediaQuery(
            data: MediaQuery.of(c).copyWith(disableAnimations: true),
            child: MaestroScope(neutro: true, child: figlio!),
          ),
          home: schermata,
        ),
      ),
    ));
    await passa(tester);
    await precarica(tester);
  }

  testWidgets('FA.01 e FA.03: la vetrina, una famiglia alla volta, e il '
      'profilo di chi aveva un Arcano', (tester) async {
    if (_stato.isEmpty) return;
    await monta(tester, const ProfiloNelCerchioScreen());
    await scatta(tester, 'fa01_profilo_da_arcano_al_segno');
    await tester.tap(find.byKey(const Key('profilo_icona')));
    await passa(tester, 8);
    await precarica(tester);
    for (final (chiave, titolo, nome) in const [
      ('segno', 'I SEGNI', 'fa03_vetrina_i_segni'),
      ('animale', 'GLI ANIMALI GUIDA', 'fa03_vetrina_gli_animali'),
      ('archetipo', 'GLI ARCHETIPI', 'fa03_vetrina_gli_archetipi'),
    ]) {
      final scelta = find.byKey(Key('vetrina_famiglia_$chiave'));
      if (scelta.evaluate().isNotEmpty) {
        await tester.tap(scelta);
      } else {
        // Il codice di prima: l'intestazione in cima, fin dove si scorre.
        final foglio = find.byType(Scrollable).last;
        await tester.scrollUntilVisible(find.text(titolo), 200,
            scrollable: foglio);
        await tester.drag(foglio, const Offset(0, -160));
      }
      await passa(tester, 4);
      await scatta(tester, nome);
    }
  });

  testWidgets('FA.02: il segno 15 fra le richieste', (tester) async {
    if (_stato.isEmpty) return;
    final amico = PersonaDelCerchio.da(PortaFintaDelCerchioSociale.amico);
    await monta(tester, SchedaDellAmicoScreen(amico: amico));
    await tester.scrollUntilVisible(
        find.byKey(const Key('manda_facciamoLaSinastria')), 300,
        scrollable: find.byType(Scrollable).first);
    await passa(tester, 3);
    await scatta(tester, 'fa02_le_richieste_col_segno_15');
  });

  testWidgets('FA.04 e FA.06: due nomi uguali, e il segno ricevuto',
      (tester) async {
    if (_stato.isEmpty) return;
    await monta(tester, const IlTuoCerchioScreen());
    await scatta(tester, 'fa04_due_nomi_uguali');
    await tester.scrollUntilVisible(find.byKey(const Key('segno_s1')), 300,
        scrollable: find.byType(Scrollable).first);
    await passa(tester, 3);
    await scatta(tester, 'fa06_hai_fatto_molta_strada_ricevuto');
  });
}
