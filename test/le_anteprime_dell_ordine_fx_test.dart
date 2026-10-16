// LE ANTEPRIME DELL'ORDINE FX, "Il Respiro della Luna".
//
// A 360 per 797 punti logici, rapporto di pixel 3 (la stessa misura delle
// altre anteprime dell'ordine, docs/collaudo convenzione di casa), nella
// stessa ora di prova delle altre prove della voce (16 ottobre 2026, ore 9
// e mezzogiorno locali). Le immagini vanno in docs/preview/FX/ solo con
// AGGIORNA_ANTEPRIME=1; senza, la prova monta e basta, per restare nella
// suite normale senza scrivere file.

import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/astro/sky_location.dart';
import 'package:esoteric_circle/core/cerchio/il_cerchio_sociale.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/lunario/il_dial_a_moon.dart';
import 'package:esoteric_circle/core/lunario/il_respiro_della_luna.dart';
import 'package:esoteric_circle/core/lunario/la_collana_delle_lune.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/design_system/tokens/typography_tokens.dart';
import 'package:esoteric_circle/features/respiro_della_luna/i_comandi_dipinti.dart';
import 'package:esoteric_circle/features/respiro_della_luna/il_respiro_della_luna_screen.dart';
import 'package:esoteric_circle/features/respiro_della_luna/la_collana_delle_lune_screen.dart';
import 'package:esoteric_circle/features/scene/la_scena_in_video.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'porta_finta_del_cerchio_sociale.dart';

/// La posizione del telefono a Piacenza, per l'anteprima del Respiro (FXA.06).
class _PiacenzaFinta extends SkyLocation {
  const _PiacenzaFinta();
  static const _p = SkyPlace(latitude: 45.0526, longitude: 9.693);
  @override
  bool get available => true;
  @override
  Future<SkyPlace?> resolve() async => _p;
  @override
  Future<RispostaPosizione> chiedi() async =>
      const RispostaPosizione(EsitoPosizione.concessa, _p);
  @override
  Future<SkyPlace?> resolveSeConcesso() async => _p;
  @override
  Future<String?> nomeDelLuogo(double latitudine, double longitudine) async =>
      'Piacenza';
}

const bool _scrivi = bool.fromEnvironment('AGGIORNA_ANTEPRIME');

IlDialAMoon _dialAMoonOffline() =>
    IlDialAMoon(client: MockClient((request) async => http.Response('', 503)));

Widget _host(Widget scena) => MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => MaestroController())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MaestroScope(child: scena),
      ),
    );

Future<void> _monta(
    WidgetTester tester, GlobalKey radice, Widget widget) async {
  tester.view.physicalSize = const Size(1080, 2391);
  tester.view.devicePixelRatio = 3.0;
  await tester.pumpWidget(RepaintBoundary(key: radice, child: widget));
}

/// **LE IMMAGINI VOGLIONO IL LORO TEMPO VERO PER DECODIFICARSI.** Senza
/// `precacheImage` la cattura arriva prima che `Image.asset`/`Image` abbiano
/// finito di decodificare, e lo scatto mostra un riquadro vuoto al posto
/// della foto: il difetto vero trovato guardando la prima cattura di questo
/// stesso file (`docs/preview/FX/fx0234_respiro_scena_ferma.png`, la scena
/// e la Luna completamente nere). Stesso rimedio di
/// `test/le_anteprime_del_lunario_test.dart`.
Future<void> _precaricaImmagini(WidgetTester tester) async {
  await tester.runAsync(() async {
    for (final e in find.byType(Image).evaluate()) {
      try {
        await precacheImage((e.widget as Image).image, e);
      } catch (_) {
        // Un ripiego (AssetImage locale) che manca davvero nel binario di
        // prova non deve far fallire la cattura: l'errorBuilder della
        // schermata lo gestisce gia' a schermo.
      }
    }
  });
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(milliseconds: 100));
}

Future<void> _scatta(WidgetTester tester, GlobalKey radice, String nome) async {
  if (!_scrivi) return;
  await _precaricaImmagini(tester);
  // **toImage() VUOLE IL TEMPO VERO, non quello finto della prova.** Senza
  // `runAsync` la rasterizzazione resta in sospeso per sempre (il blocco
  // vero trovato qui: dieci minuti di timeout su entrambe le prove), come
  // fa gia' `le_anteprime_dell_ordine_fh_test.dart` per la stessa chiamata.
  await tester.runAsync(() async {
    final rb =
        radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final img = await rb.toImage(pixelRatio: 1.0);
    final dati = await img.toByteData(format: ui.ImageByteFormat.png);
    final dir = Directory('docs/preview/FX');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    File('${dir.path}/$nome.png').writeAsBytesSync(dati!.buffer.asUint8List());
    img.dispose();
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('FX.02-03-04: il Respiro della Luna, scena ferma col pannello',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final radice = GlobalKey();
    await _monta(
        tester,
        radice,
        _host(IlRespiroDellaLunaScreen(
            now: DateTime(2026, 10, 16, 12),
            dialAMoon: _dialAMoonOffline(),
            posizione: const _PiacenzaFinta())));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 500));
    await _scatta(tester, radice, 'fx0234_respiro_scena_ferma');
  });

  testWidgets('FX.05: la Collana delle Lune, il ciclo in corso',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final radice = GlobalKey();
    await _monta(tester, radice,
        _host(LaCollanaDelleLuneScreen(now: DateTime(2026, 10, 16, 9))));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 500));
    await _scatta(tester, radice, 'fx05_collana_in_corso');
  });

  /// I giorni respirati del ciclo che contiene [oggi], dal primo all'n-esimo.
  Future<Map<String, Object>> respirati(DateTime oggi, int n) async {
    SharedPreferences.setMockInitialValues({});
    final r = IlRespiroDellaLuna();
    await r.leggi();
    final ciclo = LaCollanaDelleLune(respiro: r).cicloDi(oggi);
    final giorni = [
      for (var i = 0; i < n; i++)
        IlRespiroDellaLuna.data(ciclo.inizio.add(Duration(days: i))),
    ];
    return {'respiro.giorniRespirati': jsonEncode(giorni)};
  }

  testWidgets('FXA.01: la Collana dipinta con cinque perle accese',
      (tester) async {
    final oggi = DateTime(2026, 10, 16, 9);
    SharedPreferences.setMockInitialValues(await respirati(oggi, 5));
    final radice = GlobalKey();
    await _monta(tester, radice, _host(LaCollanaDelleLuneScreen(now: oggi)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(seconds: 1));
    await _scatta(tester, radice, 'fxa01_collana_cinque_perle');
  });

  testWidgets('FXA.01: la Collana dipinta completa', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final r = IlRespiroDellaLuna();
    await r.leggi();
    final ciclo =
        LaCollanaDelleLune(respiro: r).cicloDi(DateTime(2026, 10, 16, 9));
    final n =
        LaCollanaDelleLune(respiro: r).numeroDiPerle(ciclo.inizio, ciclo.fine);
    final ultimo = ciclo.inizio.add(Duration(days: n - 1, hours: 21));
    SharedPreferences.setMockInitialValues(await respirati(ultimo, n));
    final radice = GlobalKey();
    await _monta(tester, radice, _host(LaCollanaDelleLuneScreen(now: ultimo)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(seconds: 1));
    await _scatta(tester, radice, 'fxa01_collana_completa');
  });

  testWidgets('FXA.03: la ricucitura, l\'ago col filo e la conferma',
      (tester) async {
    final oggi = DateTime(2026, 10, 16, 9);
    SharedPreferences.setMockInitialValues(await respirati(oggi, 2));
    final borsa = QuestionAllowance();
    await borsa.applicaSaldo(120);
    final sociale = IlCerchioSociale(porta: PortaFintaDelCerchioSociale());
    final radice = GlobalKey();
    await _monta(
        tester,
        radice,
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => MaestroController()),
            ChangeNotifierProvider<QuestionAllowance>.value(value: borsa),
            ChangeNotifierProvider<IlCerchioSociale>.value(value: sociale),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: MaestroScope(child: LaCollanaDelleLuneScreen(now: oggi)),
          ),
        ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final ieri = DateTime(2026, 10, 15);
    await tester.tap(
        find.byKey(Key('collana_ricuci_${IlRespiroDellaLuna.data(ieri)}')),
        warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(const Duration(milliseconds: 400));
    await _scatta(tester, radice, 'fxa03_ricucitura_conferma');
    // Si chiude la conferma senza spendere, per lasciare la prova pulita.
    await tester.tap(find.byKey(const Key('conferma_spesa_non_ora')));
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('FXA.02: il pulsante dipinto a due larghezze e il pannello',
      (tester) async {
    final radice = GlobalKey();
    await _monta(
        tester,
        radice,
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            backgroundColor: const Color(0xFF0A1028),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  PulsanteDipinto(testo: 'Altro', altezza: 38, onTap: () {}),
                  const SizedBox(height: 16),
                  SizedBox(
                      width: 170,
                      child: PulsanteDipinto(
                          testo: 'Condividi',
                          larghezzaPiena: true,
                          onTap: () {})),
                  const SizedBox(height: 16),
                  PulsanteDipinto(
                      testo: 'Comincia una nuova collana',
                      larghezzaPiena: true,
                      onTap: () {}),
                  const SizedBox(height: 16),
                  const PulsanteDipinto(
                      testo: 'Spento, senza azione',
                      larghezzaPiena: true,
                      onTap: null),
                  const SizedBox(height: 16),
                  PannelloDipinto(
                    child: Text(
                        'Il pannello dipinto: si allunga solo in altezza, la '
                        'falce in cima resta intera.',
                        textAlign: TextAlign.center,
                        style: TypographyTokens.corpo()
                            .copyWith(color: coloreSulVelluto)),
                  ),
                ],
              ),
            ),
          ),
        ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    // Il pulsante largo premuto: si tiene il dito sopra mentre si scatta.
    final gesto = await tester.startGesture(
        tester.getCenter(find.text('Comincia una nuova collana')));
    await tester.pump(const Duration(milliseconds: 100));
    await _scatta(tester, radice, 'fxa02_pulsante_dipinto');
    await gesto.up();
    await tester.pump();
  });

  // **FXA.09, LA LUNA DI QUEST'ORA, A DUE MISURE E IN QUATTRO MOMENTI.**
  // "le anteprime a 360 per 797 e a 430 per 932 della schermata intera
  // adesso, a tempo spostato, con la Superluna e con la Luna fuori corso".
  final momenti = <String, (DateTime, double)>{
    // La sera del 16 ottobre 2026 a Piacenza: la Luna tramonta alle 21:49.
    'adesso': (DateTime(2026, 10, 16, 21), 0),
    // La stessa sera, il righello trascinato di mezza giornata in avanti.
    'tempo_spostato': (DateTime(2026, 10, 16, 21), -120),
    // Il 24 dicembre 2026 alle 11 la Luna e' a 356.655 km: Superluna.
    'superluna': (DateTime(2026, 12, 24, 11), 0),
    // Il 16 ottobre 2026 alle 10 la Luna e' fuori corso fino alle 14:57.
    'fuori_corso': (DateTime(2026, 10, 16, 10), 0),
  };
  for (final misura in const [Size(360, 797), Size(430, 932)]) {
    for (final m in momenti.entries) {
      testWidgets(
          'FXA.09: la Luna di questa ora, ${m.key}, '
          '${misura.width.toInt()} per ${misura.height.toInt()}',
          (tester) async {
        SharedPreferences.setMockInitialValues(
            {'respiro.primaAperturaVista': true});
        final radice = GlobalKey();
        tester.view.physicalSize = misura * 3;
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(RepaintBoundary(
            key: radice,
            child: _host(IlRespiroDellaLunaScreen(
                now: m.value.$1,
                dialAMoon: _dialAMoonOffline(),
                posizione: const _PiacenzaFinta()))));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(seconds: 2));
        if (m.value.$2 != 0) {
          await tester.drag(find.byKey(const Key('luna_righello_del_tempo')),
              Offset(m.value.$2, 0));
          await tester.pump(const Duration(milliseconds: 400));
        }
        // La riga che il momento vuole mostrare, portata a vista: i dati
        // scorrono sotto la scena, e il sigillo sta piu' in basso.
        final riga = {
          'superluna': 'luna_dato_distanza',
          'fuori_corso': 'luna_dato_fuori_corso',
        }[m.key];
        if (riga != null) {
          await tester.scrollUntilVisible(find.byKey(Key(riga)), 200,
              scrollable: find.byType(Scrollable).first);
          await tester.drag(
              find.byType(Scrollable).first, const Offset(0, -150));
          await tester.pump(const Duration(milliseconds: 400));
        }
        await _scatta(
            tester, radice, 'fxa09_luna_${m.key}_${misura.width.toInt()}');
      });
    }
  }

  /// Monta il Respiro a 360 per 797 alle 21 del 16 ottobre 2026.
  Future<void> respiro(WidgetTester tester, GlobalKey radice,
      {Map<String, Object> preferenze = const {},
      FabbricaDiScena? scena}) async {
    SharedPreferences.setMockInitialValues(preferenze);
    tester.view.physicalSize = const Size(1080, 2391);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(RepaintBoundary(
        key: radice,
        child: _host(IlRespiroDellaLunaScreen(
            now: DateTime(2026, 10, 16, 21),
            dialAMoon: _dialAMoonOffline(),
            posizione: const _PiacenzaFinta(),
            fabbricaDellaScena: scena))));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(seconds: 2));
  }

  testWidgets('FXA.07: la prima apertura', (tester) async {
    final radice = GlobalKey();
    await respiro(tester, radice);
    await _scatta(tester, radice, 'fxa07_prima_apertura');
  });

  testWidgets('FXA.07: prima del respiro', (tester) async {
    final radice = GlobalKey();
    await respiro(tester, radice,
        preferenze: {'respiro.primaAperturaVista': true});
    await tester.tap(find.byKey(const Key('luna_voce_respiro')));
    await tester.pump(const Duration(milliseconds: 300));
    await _scatta(tester, radice, 'fxa07_prima_del_respiro');
  });

  testWidgets('FXA.07: dopo il respiro', (tester) async {
    final radice = GlobalKey();
    await respiro(tester, radice,
        preferenze: {'respiro.primaAperturaVista': true});
    await tester.tap(find.byKey(const Key('luna_voce_respiro')));
    await tester.pump(const Duration(milliseconds: 300));
    final tempi = TempiDelRespiroDellaLuna.diOggi(DateTime(2026, 10, 16, 21));
    for (var i = 0; i < tempi.cicliPerUnMinuto; i++) {
      final dito = await tester.startGesture(
          tester.getCenter(find.byKey(const Key('respiro_luna_vera'))));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(tempi.inspiro + const Duration(milliseconds: 100));
      await dito.up();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(tempi.espiro + const Duration(milliseconds: 100));
    }
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const Key('respiro_riga_dopo')), findsOneWidget);
    await _scatta(tester, radice, 'fxa07_dopo_il_respiro');
  });

  testWidgets('FXA.08: il Respiro a meta video e dopo', (tester) async {
    final radice = GlobalKey();
    await respiro(tester, radice,
        preferenze: {'respiro.primaAperturaVista': true},
        scena: () => _VideoDellaScena());
    await _scatta(tester, radice, 'fxa08_respiro_a_meta_video');
    await tester.tapAt(const Offset(180, 400));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await _scatta(tester, radice, 'fxa08_respiro_dopo_il_video');
  });
}

/// Un video di scena che gira: al posto dei fotogrammi del video, il primo
/// fotogramma dipinto della scena, quello che il video mostra mentre
/// comincia.
class _VideoDellaScena implements LettoreDiScena {
  VoidCallback? _ascolta;
  bool _pronto = false;

  @override
  bool get pronto => _pronto;
  @override
  bool get fallito => false;
  @override
  bool get cominciato => _pronto;
  @override
  bool get finito => false;
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
  Widget disegna() => Image.asset(
      'assets/img/respiro_della_luna/respiro_primo_fotogramma_v1.webp',
      fit: BoxFit.cover);
  @override
  void chiudi() {}
}
