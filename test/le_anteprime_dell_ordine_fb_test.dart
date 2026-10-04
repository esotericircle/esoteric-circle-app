// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/cerchio/il_cerchio_sociale.dart';
import 'package:esoteric_circle/core/cerchio/le_icone_del_cerchio.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/cerchio/il_tuo_cerchio_screen.dart';
import 'package:esoteric_circle/features/cerchio/la_tendina_del_cerchio.dart';
import 'package:esoteric_circle/features/cerchio/profilo_nel_cerchio_screen.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'porta_finta_del_cerchio_sociale.dart';

/// **LE ANTEPRIME DELL'ORDINE FB, prima e dopo.** A 360 per 797 punti logici
/// col rapporto di pixel 3, catturate dentro `tester.runAsync` coi `pump`.
/// `--dart-define=STATO=prima` sul codice di partenza (6d0ba515), `dopo` sul
/// codice dell'ordine, in `docs/preview/prima_dopo/`.
///
/// **La tendina con dodici amici presenti.** Il tetto dei sei stava nel
/// server, non nel telefono: la porta finta, per la cattura "prima", manda
/// i primi sei come faceva il server dell'ordine FA, e per la "dopo" tutti e
/// dodici come fa il server dell'ordine FB. E' dichiarato qui perche' la
/// cattura "prima" non e' il telefono che taglia, e' la risposta di allora.
const _stato = String.fromEnvironment('STATO');

class _PortaDellOrdineFb extends PortaFintaDelCerchioSociale {
  static const quantiPresenti = 12;

  @override
  Future<EsitoSociale?> sociale(String porta,
      [Map<String, Object?> corpo = const {}]) async {
    final e = await super.sociale(porta, corpo);
    if (e == null) return e;
    if (porta == 'ilMioCerchio') {
      return EsitoSociale(dati: {
        ...e.dati,
        // Due nomi uguali per l'occhio nel tuo Cerchio: il sigillo accanto,
        // che dall'ordine FB non si taglia piu'.
        'ricevuti': const [
          {
            'uid': 'u-corvo',
            'nome': 'Eco Corvo Mite',
            'icona': 'animale:3',
            'sigillo': 'R7KQ',
            'semaforo': 'arancionePieno',
          },
        ],
        'amici': [
          {
            ...PortaFintaDelCerchioSociale.amico,
            'uid': 'u-corvo-2',
            'nome': 'eco corvo mite',
            'sigillo': 'M4XR',
          },
        ],
        'bloccati': const [
          {'uid': 'u-x', 'nome': 'Velo Nodo Vigile', 'sigillo': 'Z9P0'},
          {'uid': 'u-y', 'nome': 'Brina Lupo Quieto', 'sigillo': 'H3TW'},
          {'uid': 'u-z', 'nome': 'Fiamma Cervo Lento', 'sigillo': 'Q8LM'},
        ],
      });
    }
    if (porta == 'laTendinaDelCerchio') {
      const nomi = [
        'Stella Lieve',
        'Eco Corvo Mite',
        'Luce di Scorpione',
        'Ala Falco Chiaro',
        'Onda Gufo Serale',
        'Brace Leone Audace',
        'Rugiada Cervo Calmo',
        'Vento Lupo Saggio',
        'Ombra Gatto Lento',
        'Radice Orso Buono',
        'Lampo Volpe Viva',
        'Seme Airone Quieto',
      ];
      const arti = ['tarocchi', 'rune', 'oroscopo', 'viaggio'];
      final tutti = [
        for (var i = 0; i < quantiPresenti; i++)
          {
            'uid': 'u-amico-$i',
            'nome': nomi[i],
            'icona': i.isEven ? 'segno:${i % 12}' : 'animale:${i % 12}',
            'segno': 'leo',
            'maestro': 'aura',
            'arte': arti[i % arti.length],
          },
      ];
      return EsitoSociale(dati: {
        ...e.dati,
        'amiciPresenti': _stato == 'prima' ? tutti.take(6).toList() : tutti,
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
      print('FB ANTEPRIMA: ${dir.path}/${nome}_$_stato.png '
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
    final finta = _PortaDellOrdineFb();
    final sociale = IlCerchioSociale(porta: finta);
    await tester.runAsync(() async {
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

  testWidgets('FB.01: la tendina con dodici amici presenti', (tester) async {
    if (_stato.isEmpty) return;
    await monta(
        tester,
        Builder(
            builder: (c) => Scaffold(
                backgroundColor: Colors.black,
                body: Center(
                    child: TextButton(
                        onPressed: () => apriLaTendinaDelCerchio(c),
                        child: const Text('apri'))))));
    await tester.tap(find.text('apri'));
    await passa(tester, 10);
    await scatta(tester, 'fb01_tendina_dodici_amici');
    // In fondo all'elenco degli amici: chi c'e' dopo il sesto.
    final elenco = find
        .descendant(
            of: find.byKey(const Key('la_tendina_del_cerchio')),
            matching: find.byType(Scrollable))
        .first;
    await tester.drag(elenco, const Offset(0, -500));
    await passa(tester, 4);
    await scatta(tester, 'fb01_tendina_dodici_amici_in_fondo');
  });

  testWidgets('FB.02: due nomi uguali, il sigillo accanto e intero',
      (tester) async {
    if (_stato.isEmpty) return;
    await monta(tester, const IlTuoCerchioScreen());
    await scatta(tester, 'fb02_due_nomi_uguali');
  });

  testWidgets('FB.02: le persone bloccate, col sigillo', (tester) async {
    if (_stato.isEmpty) return;
    await monta(tester, const ProfiloNelCerchioScreen());
    await tester.scrollUntilVisible(find.byKey(const Key('bloccata_u-z')), 300,
        scrollable: find.byType(Scrollable).first);
    await passa(tester, 3);
    await scatta(tester, 'fb02_bloccati_col_sigillo');
  });
}
