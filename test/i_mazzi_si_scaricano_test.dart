// I MAZZI SI SCARICANO QUANDO LI SCEGLI. Ordine FJ voci 9-12, 11 ottobre 2026.
//
// Marsiglia e Thoth stanno sul bucket e si scaricano solo quando la persona
// li sceglie. La guardia pretende, con un bucket finto e una cartella vera:
// - il download riuscito diventa un mazzo installato che resta (un'altra
//   istanza lo ritrova dal telefono, senza rete);
// - un file con l'impronta sbagliata si riscarica una volta, e se torna il
//   mazzo si installa;
// - un file che non torna nemmeno la seconda volta lascia il mazzo non
//   installato e nessuna cartella a meta';
// - chi annulla non installa niente;
// - montata l'app dall'avvio vero e aperta la stesa, nessuna richiesta di
//   rete;
// - scelto un mazzo che non si scarica, la stesa resta sul Rider-Waite e una
//   riga lo dice.

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/tarot/i_mazzi_dei_tarocchi.dart';
import 'package:esoteric_circle/core/tarot/i_mazzi_scaricati.dart';
import 'package:esoteric_circle/core/tarot/tarot_card.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/tarot/il_mazzo_si_scarica.dart';
import 'package:esoteric_circle/features/tarot/stesa_tre_carte_screen.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _base = 'https://finto.bucket/tarocchi/mazzi/';

/// Il bucket finto: un manifest con due carte del Marsiglia, piena e
/// miniatura, e i loro byte. [guasti] dice quante volte ogni percorso
/// risponde con byte sbagliati prima di quelli giusti.
class _Bucket {
  _Bucket({this.guasti = const {}});

  final Map<String, int> guasti;
  final Map<String, int> chiamate = {};
  final Map<String, Uint8List> file = {
    for (final n in const [
      'marsiglia/v1/piene/00.webp',
      'marsiglia/v1/miniature/00.webp',
      'marsiglia/v1/piene/01.webp',
      'marsiglia/v1/miniature/01.webp',
    ])
      n: Uint8List.fromList(utf8.encode('byte di $n')),
  };

  Map<String, dynamic> get manifesto => {
        'formato': 1,
        'base': _base,
        'mazzi': [
          {
            'id': 'marsiglia',
            'nome': 'Marsiglia',
            'versione': 1,
            'piano': 'iniziato',
            'file': [
              for (final (stem, n) in [
                (TarotDeck.cards[0].stem, '00'),
                (TarotDeck.cards[1].stem, '01'),
              ])
                {
                  'carta': stem,
                  for (final misura in const ['piena', 'miniatura'])
                    misura: {
                      'percorso':
                          'marsiglia/v1/${misura == 'piena' ? 'piene' : 'miniature'}/$n.webp',
                      'byte': file[
                              'marsiglia/v1/${misura == 'piena' ? 'piene' : 'miniature'}/$n.webp']!
                          .length,
                      'sha256': sha256
                          .convert(file[
                              'marsiglia/v1/${misura == 'piena' ? 'piene' : 'miniature'}/$n.webp']!)
                          .toString(),
                    },
                },
            ],
          },
        ],
      };

  MockClient get client => MockClient((r) async {
        final u = r.url.toString();
        if (u == IMazziScaricati.manifestoSulBucket) {
          return http.Response(jsonEncode(manifesto), 200);
        }
        final percorso = u.substring(_base.length);
        final n = chiamate[percorso] = (chiamate[percorso] ?? 0) + 1;
        final b = file[percorso];
        if (b == null) return http.Response('no', 404);
        if (n <= (guasti[percorso] ?? 0)) {
          return http.Response.bytes(utf8.encode('guasto'), 200);
        }
        return http.Response.bytes(b, 200);
      });
}

void main() {
  late Directory cartella;
  setUp(() => cartella = Directory.systemTemp.createTempSync('mazzi_'));
  tearDown(() {
    if (cartella.existsSync()) cartella.deleteSync(recursive: true);
  });

  IMazziScaricati servizio(_Bucket b) =>
      IMazziScaricati(client: b.client, cartella: () async => cartella);

  test('il download riuscito installa il mazzo, e il mazzo resta', () async {
    final b = _Bucket();
    final s = servizio(b);
    final avanzamenti = <int>[];
    final esito = await s.scarica(TarotDeckStyle.marsiglia,
        avanzamento: (f, t) => avanzamenti.add(f));
    expect(esito, EsitoDelDownload.installato);
    expect(s.installato(TarotDeckStyle.marsiglia), isTrue);
    expect(s.arteDi(TarotDeckStyle.marsiglia, TarotDeck.cards[0]), isNotNull);
    expect(avanzamenti.last, greaterThan(0));
    // Un'altra istanza, cioe' l'app riaperta, lo ritrova senza rete.
    final dopo = IMazziScaricati(
        client: MockClient((r) async => throw 'niente rete'),
        cartella: () async => cartella);
    await dopo.leggiIInstallati();
    expect(dopo.installato(TarotDeckStyle.marsiglia), isTrue);
    expect(dopo.richiesteFatte, 0);
    final arte =
        dopo.arteDi(TarotDeckStyle.marsiglia, TarotDeck.cards[1]) as FileImage;
    expect(arte.file.readAsStringSync(), 'byte di marsiglia/v1/piene/01.webp');
  });

  test('un\'impronta sbagliata si riscarica una volta', () async {
    final b = _Bucket(guasti: {'marsiglia/v1/piene/01.webp': 1});
    final s = servizio(b);
    expect(
        await s.scarica(TarotDeckStyle.marsiglia), EsitoDelDownload.installato);
    expect(b.chiamate['marsiglia/v1/piene/01.webp'], 2);
  });

  test('un file che non torna nemmeno la seconda volta non installa niente',
      () async {
    final b = _Bucket(guasti: {'marsiglia/v1/miniature/01.webp': 9});
    final s = servizio(b);
    expect(await s.scarica(TarotDeckStyle.marsiglia),
        EsitoDelDownload.nonRiuscito);
    expect(b.chiamate['marsiglia/v1/miniature/01.webp'], 2);
    expect(s.installato(TarotDeckStyle.marsiglia), isFalse);
    final rimasti = cartella
        .listSync(recursive: true)
        .whereType<File>()
        .map((f) => f.path)
        .toList();
    expect(rimasti, isEmpty, reason: 'una cartella a meta\': $rimasti');
  });

  test('chi annulla non installa niente', () async {
    final b = _Bucket();
    final s = servizio(b);
    final annulla = AnnullaDownload();
    final esito = await s.scarica(TarotDeckStyle.marsiglia, annulla: annulla,
        avanzamento: (f, t) {
      if (f > 0) annulla.annulla();
    });
    expect(esito, EsitoDelDownload.annullato);
    expect(s.installato(TarotDeckStyle.marsiglia), isFalse);
    expect(cartella.listSync(recursive: true).whereType<File>(), isEmpty);
  });

  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  void silenzia() {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (c) async => null);
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

  testWidgets('l\'avvio e la stesa non chiedono niente alla rete',
      (tester) async {
    silenzia();
    SharedPreferences.setMockInitialValues(
        const {'onboarding.done': true, 'santuario.greeted': true});
    final b = _Bucket();
    final prima = IMazziScaricati.diCasa;
    final finto = await tester.runAsync(() async =>
        IMazziScaricati(client: b.client, cartella: () async => cartella));
    IMazziScaricati.diCasa = finto!;
    addTearDown(() => IMazziScaricati.diCasa = prima);
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(402, 1600);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
        EsotericCircleApp(conIntro: false, services: AppServices.offline()));
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    nav.push(StesaTreCarteScreen.route());
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 250));
    }
    expect(finto.richiesteFatte, 0,
        reason: 'un mazzo si scarica solo quando lo scegli');
    expect(b.chiamate, isEmpty);
  });

  testWidgets('se il mazzo non si scarica, resta il Rider-Waite e lo dice',
      (tester) async {
    final rotto = IMazziScaricati(
        client: MockClient((r) async => http.Response('no', 503)),
        cartella: () async => cartella);
    bool? usabile;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async => usabile = await scegliIlMazzo(
                context,
                TarotDeckStyle.marsiglia,
                MaestroPalette.forKey(const ThemeKey.of(Maestro.medora)),
                servizio: rotto),
            child: const Text('scegli'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('scegli'));
    await tester.runAsync(() async {
      for (var i = 0; i < 50 && usabile == null; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(usabile, isFalse);
    expect(find.byKey(const Key('mazzo_non_scaricato')), findsOneWidget);
    expect(find.textContaining('resta col Rider-Waite'), findsOneWidget);
    expect(rotto.installato(TarotDeckStyle.marsiglia), isFalse);
  });

  test('i nomi e i numeri dei mazzi seguono la loro tradizione', () {
    final forza = TarotDeck.cards.firstWhere((c) => c.name == 'La Forza');
    final giustizia =
        TarotDeck.cards.firstWhere((c) => c.name == 'La Giustizia');
    expect(TarotDeckStyle.postoDi(forza), 11);
    expect(TarotDeckStyle.postoDi(giustizia), 8);
    expect(TarotDeckStyle.marsiglia.numeraleDi(forza), 'XI');
    expect(TarotDeckStyle.thoth.nomeDi(forza), 'La Lussuria');
    expect(TarotDeckStyle.thoth.numeraleDi(giustizia), 'VIII');
    final re = TarotDeck.cards.firstWhere((c) => c.name == 'Re di Denari');
    expect(TarotDeckStyle.thoth.nomeDi(re), 'Cavaliere di Dischi');
    expect(TarotDeckStyle.postoDi(re), 49);
    final imperatore =
        TarotDeck.cards.firstWhere((c) => c.name == 'L\'Imperatore');
    expect(TarotDeckStyle.marsiglia.numeraleDi(imperatore), 'IIII');
    final posti = {for (final c in TarotDeck.cards) TarotDeckStyle.postoDi(c)};
    expect(posti, hasLength(78));
    expect(posti.reduce((a, b) => a > b ? a : b), 77);
  });
}
