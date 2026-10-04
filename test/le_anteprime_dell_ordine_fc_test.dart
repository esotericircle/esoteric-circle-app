// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/amici/amici_offline.dart';
import 'package:esoteric_circle/core/cerchio/il_cerchio_sociale.dart';
import 'package:esoteric_circle/core/cerchio/le_icone_del_cerchio.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:esoteric_circle/core/astro/birth_details.dart';
import 'package:esoteric_circle/core/astro/birth_place.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/design_system/components/zodiac_glyph.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/amici/amici_screen.dart';
import 'package:esoteric_circle/features/horoscope/oroscopo_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'porta_finta_del_cerchio_sociale.dart';

/// **LE ANTEPRIME DELL'ORDINE FC, prima e dopo, a coppie.** A 360 per 797
/// punti logici col rapporto di pixel 3. `--dart-define=STATO=dopo` sul codice
/// dell'ordine; la "prima" si scatta sul codice di partenza (`bcf8eaff`) con
/// una copia di questa prova che monta la schermata dell'amico di allora
/// (`LOroscopoDellAmicoScreen`), perche' `OroscopoScreen.perUnAmico` allora
/// non c'era.
///
/// L'ordine FC chiede le catture dell'oroscopo proprio e di quello di un amico
/// ACCANTO, nella stessa coppia: la cosa da vedere e' che sono la stessa
/// esperienza. Ogni momento esce due volte, `fc_tuo_<momento>` e
/// `fc_amico_<momento>`.
const _stato = String.fromEnvironment('STATO');

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  final radice = GlobalKey();

  final amica = Amico(
      id: 'lucia',
      nome: 'Lucia',
      nascita: DateTime(1990, 1, 12),
      ora: '08:10',
      luogo: 'Roma',
      lat: 41.9,
      lon: 12.5,
      fuso: 'Europe/Rome');

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
      print('FC ANTEPRIMA: ${dir.path}/${nome}_$_stato.png '
          '${img.width}x${img.height}');
      img.dispose();
    });
  }

  Future<void> monta(WidgetTester tester, Widget home) async {
    silenzia();
    SharedPreferences.setMockInitialValues({
      'oroscopo_segno_rivelato': ['cinese', 'vedica'],
    });
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2391);
    addTearDown(tester.view.reset);
    final nascite = BirthIdentityController()
      ..setBirth(
          BirthDetails(
            date: DateTime(1990, 6, 15),
            time: const TimeOfDay(hour: 8, minute: 10),
            place: const BirthPlace(
                label: 'Roma',
                latitude: 41.9,
                longitude: 12.5,
                timezone: 'Europe/Rome'),
          ),
          null);
    final amici = AmiciOffline();
    await tester.runAsync(() async {
      await amici.carica();
      await amici.aggiungi(amica, Tier.tier3);
    });
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(
            create: (_) => EntitlementService(initial: Tier.tier3)),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider.value(value: nascite),
        ChangeNotifierProvider.value(value: amici),
      ],
      child: RepaintBoundary(
        key: radice,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark(),
          builder: (c, figlio) => MediaQuery(
            data: MediaQuery.of(c).copyWith(disableAnimations: true),
            child: MaestroScope(child: figlio!),
          ),
          home: home,
        ),
      ),
    ));
    await passa(tester);
    await tester.runAsync(() async {
      final ctx = radice.currentContext!;
      for (final z in Zodiac.values) {
        await precacheImage(AssetImage(ZodiacArt.emblemPath(z)), ctx);
      }
    });
    await passa(tester, 4);
  }

  Widget schermata(String chi) => chi == 'tuo'
      ? OroscopoScreen(userSign: Zodiac.gemini, now: DateTime(2026, 10, 4, 12))
      : OroscopoScreen(
          userSign: amica.segno, amico: amica, now: DateTime(2026, 10, 4, 12));

  for (final chi in const ['tuo', 'amico']) {
    testWidgets('FC: l\'oroscopo $chi, l\'apertura, il gesto e il responso',
        (tester) async {
      if (_stato.isEmpty) return;
      await monta(tester, schermata(chi));
      await scatta(tester, 'fc_${chi}_apertura');
      final gesto = find.byType(InterrogaIlCielo);
      await tester.ensureVisible(gesto);
      await passa(tester, 2);
      await tester.tap(gesto);
      await tester.pump(const Duration(milliseconds: 1200));
      await scatta(tester, 'fc_${chi}_riflessione');
      for (var i = 0; i < 70; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      final generale = find.byKey(const Key('oroscopo_card_generale'));
      await tester.ensureVisible(generale);
      await passa(tester, 3);
      await scatta(tester, 'fc_${chi}_responso');
    });

    testWidgets('FC: l\'oroscopo $chi, la settimana', (tester) async {
      if (_stato.isEmpty) return;
      await monta(tester, schermata(chi));
      final settimana = find.byKey(const Key('oroscopo_period_settimana'));
      await tester.ensureVisible(settimana);
      await tester.tap(settimana);
      await passa(tester, 4);
      await scatta(tester, 'fc_${chi}_settimana');
    });
  }

  testWidgets('FC: la lista degli amici', (tester) async {
    if (_stato.isEmpty) return;
    await monta(tester, const AmiciScreen());
    await scatta(tester, 'fc_amici_lista');
  });

  // **FC.09, OFFLINE E ONLINE** nella rubrica degli amici, nella forma del
  // fondatore, con le icone del Cerchio caricate prima dello scatto (come
  // nelle anteprime del Cerchio): di default Offline; Online col Cerchio
  // popolato; Online col Cerchio vuoto; Online col tetto raggiunto, che
  // mostra l'ultimo dato noto con la sua ora; Online col Cerchio che non
  // risponde e nessun ultimo dato. E una cattura SENZA le icone caricate, per
  // la prova dell'icona nera (ordine FC voce 09, punto 3 della risposta).
  for (final (caso, conAmici, suOnline, tendina, icone) in const [
    ('offline', true, false, 'arriva', true),
    ('online', true, true, 'arriva', true),
    ('online_nessuno_nel_cerchio', false, true, 'arriva', true),
    ('online_ultimo_dato', true, true, 'tetto', true),
    ('online_non_risponde', true, true, 'muta', true),
    ('online_senza_icone_caricate', true, true, 'arriva', false),
  ]) {
    testWidgets('FC.09: la rubrica, $caso', (tester) async {
      if (_stato.isEmpty) return;
      final finta = _PortaDelleAnteprime(amici: conAmici, tendina: tendina);
      final sociale = IlCerchioSociale(porta: finta);
      await tester.runAsync(() async {
        await sociale.sincronizza(
            identita: BirthIdentity(birthMoment: DateTime(1990, 5, 12, 10)));
        await sociale.caricaIlCerchio();
        // Col tetto: la tendina e' arrivata una volta, e cinque minuti
        // dopo la rubrica la richiede e trova il tetto.
        if (tendina == 'tetto') {
          finta.concedi = true;
          await sociale.caricaLaTendina();
          finta.concedi = false;
        }
      });
      await monta(
          tester,
          MultiProvider(
            providers: [
              ChangeNotifierProvider<IlCerchioSociale>.value(value: sociale),
              Provider<AppServices>.value(
                  value: AppServices.offline(null, finta)),
            ],
            child: AmiciScreen(
                adesso: tendina == 'tetto'
                    ? sociale.tendinaArrivata!.add(const Duration(minutes: 5))
                    : null),
          ));
      if (icone) {
        await tester.runAsync(() async {
          final ctx = radice.currentContext!;
          for (final f in FamigliaDelleIcone.values) {
            for (final i in IconaDelProfilo.di(f)) {
              await precacheImage(AssetImage(i.asset), ctx);
            }
          }
        });
      }
      if (suOnline) {
        await tester.tap(find.byKey(const Key('amici_online')));
      }
      await passa(tester, 6);
      await scatta(tester, 'fc09_rubrica_$caso');
    });
  }
}

/// La porta delle anteprime della FC.09: la tendina arriva, risponde col
/// tetto dopo la prima ([concedi] la lascia passare), o non risponde.
class _PortaDelleAnteprime extends PortaFintaDelCerchioSociale {
  _PortaDelleAnteprime({required super.amici, required this.tendina});

  final String tendina;
  bool concedi = false;

  @override
  Future<EsitoSociale?> sociale(String porta,
      [Map<String, Object?> corpo = const {}]) async {
    if (porta == 'laTendinaDelCerchio' && !concedi) {
      if (tendina == 'tetto') {
        return const EsitoSociale(
            dati: {},
            errore: 'resource-exhausted',
            riga: 'Hai bussato molte volte: riprova fra un minuto.');
      }
      if (tendina == 'muta') throw StateError('la tendina non risponde');
    }
    return super.sociale(porta, corpo);
  }
}
