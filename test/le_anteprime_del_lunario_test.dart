// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/lunario/il_giorno_lunare.dart';
import 'package:esoteric_circle/core/lunario/il_segno_del_giorno_tuo.dart';
import 'package:esoteric_circle/core/lunario/le_attivita_del_lunario.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/rituals/avvisi_del_rito.dart';
import 'package:esoteric_circle/core/settings/settings_controller.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/lunario/calendario_lunare_screen.dart';
import 'package:esoteric_circle/features/lunario/la_card_del_mese.dart';
import 'package:esoteric_circle/features/scene/la_scena_in_video.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **LE ANTEPRIME DEL CALENDARIO LUNARE**, ordine FV voce FV.14: la
/// schermata a 360 per 797 punti logici col rapporto di pixel 3, in
/// `docs/preview/FV/`, con `--dart-define=STATO=dopo`. Non c'e' un "prima":
/// l'arte era una card Coming soon (come l'Oracolo nell'ordine FU).
///
/// Cinque catture, le cinque che l'ordine nomina: il mese di trenta lune,
/// "Trova il giorno" con gli aloni, un foglio del giorno, i giorni tuoi (gia'
/// visibili nella griglia del mese: non esiste una schermata separata), la
/// card del mese.
const _stato = String.fromEnvironment('STATO');

class _Ferma implements LettoreDiScena {
  VoidCallback? _ascolta;
  @override
  bool get pronto => false;
  @override
  bool get fallito => true;
  @override
  bool get cominciato => false;
  @override
  bool get finito => false;
  @override
  void ascolta(VoidCallback? q) => _ascolta = q;
  @override
  Future<void> apri() async => _ascolta?.call();
  @override
  Future<void> volume(double q) async {}
  @override
  Future<void> avvia() async {}
  @override
  Future<void> sospendi() async {}
  @override
  Widget disegna() => const SizedBox.shrink();
  @override
  void chiudi() {}
}

class _Telefono extends ServizioAvvisi {
  @override
  bool get disponibile => true;
  @override
  Future<bool> chiediPermesso() async => true;
  @override
  Future<bool> permessoConcesso() async => true;
  @override
  Future<void> programma(
          {required int id,
          required DateTime quando,
          required String titolo,
          required String testo,
          String canale = 'rito_alba',
          String carico = ''}) async =>
      {};
  @override
  Future<void> annulla(int id) async {}
  @override
  Future<List<int>> inAttesa() async => const [];
  @override
  Future<void> mostraAdesso(
      {required String titolo, required String testo}) async {}
  @override
  Future<void> mostraDelDono(
          {required int id,
          required String titolo,
          required String testo,
          required String canale,
          String carico = ''}) async =>
      {};
}

/// Un ottobre 2026, con un giorno d'oro (il 12), uno da evitare (il 5) e i
/// quattro giorni tuoi (3, 7, 8, 22), come nella prova a video della voce.
List<GiornoLunare> _ottobre(int anno, int mese) {
  final n = DateTime(anno, mese + 1, 0).day;
  return [
    for (var d = 1; d <= n; d++)
      GiornoLunare(
        giorno: DateTime(anno, mese, d),
        elongazione: ((d - 10) * 12.2) % 360,
        illuminazione: 0.5,
        crescente: d >= 10 && d < 26,
        fase: d == 10
            ? FaseLunare.nuova
            : d == 26
                ? FaseLunare.piena
                : FaseLunare.crescente,
        segno: Zodiac.leo,
        cambiDiSegno: const [],
        fuoriCorso: const [],
        giornoLunare: ((d - 10) % 30) + 1,
        tipoBiodinamico: d.isEven ? TipoBiodinamico.frutto : null,
        lunaNuova: d == 10,
        lunaPiena: d == 26,
      ),
  ];
}

EsitoDelGiorno _valuta(AttivitaDelLunario a, GiornoLunare g) {
  final d = g.giorno.day;
  if (d == 12 || d == 20) {
    return const EsitoDelGiorno(
        grado: GradoDelGiorno.oro,
        perche: ['Luna crescente', 'in Leone'],
        fonti: ['prova']);
  }
  if (d == 5 || d == 28) {
    return const EsitoDelGiorno(
        grado: GradoDelGiorno.evitare, perche: ['Luna calante'], fonti: []);
  }
  return const EsitoDelGiorno(
      grado: GradoDelGiorno.neutro, perche: [], fonti: []);
}

List<SegnoDelGiornoTuo> _giorniTuoi(BirthIdentity b, int anno, int mese) => [
      SegnoDelGiornoTuo(
          giorno: DateTime(anno, mese, 3),
          tipo: TipoDelGiornoTuo.ritornoLunare,
          titolo: 'Torna la tua Luna',
          testo: 'La Luna torna al grado della tua nascita.'),
      SegnoDelGiornoTuo(
          giorno: DateTime(anno, mese, 7),
          tipo: TipoDelGiornoTuo.lunaSulTuoSole,
          titolo: 'La Luna sul tuo Sole',
          testo: 'La Luna incontra il grado del tuo Sole.'),
      SegnoDelGiornoTuo(
          giorno: DateTime(anno, mese, 8),
          tipo: TipoDelGiornoTuo.lunaNelTuoSegno,
          titolo: 'La Luna nel tuo segno',
          testo: 'La Luna attraversa il tuo segno solare.'),
      SegnoDelGiornoTuo(
          giorno: DateTime(anno, mese, 22),
          tipo: TipoDelGiornoTuo.faseDiNascita,
          titolo: 'Torna la fase della tua nascita',
          testo: 'La Luna torna alla fase di quando sei nata.'),
    ];

void main() {
  final radice = GlobalKey();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> passa(WidgetTester tester, [int volte = 10]) async {
    for (var i = 0; i < volte; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> immagini(WidgetTester tester) async {
    await tester.runAsync(() async {
      for (final e in find.byType(Image).evaluate()) {
        await precacheImage((e.widget as Image).image, e);
      }
    });
    await passa(tester, 3);
  }

  Future<void> scatta(WidgetTester tester, String nome) async {
    await immagini(tester);
    await tester.runAsync(() async {
      final rb =
          radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final img = await rb.toImage(pixelRatio: 3.0);
      final dati = await img.toByteData(format: ui.ImageByteFormat.png);
      final dir = Directory('docs/preview/FV');
      if (!dir.existsSync()) dir.createSync(recursive: true);
      File('${dir.path}/${nome}_$_stato.png')
          .writeAsBytesSync(dati!.buffer.asUint8List());
      print('FV ANTEPRIMA: ${dir.path}/${nome}_$_stato.png '
          '${img.width}x${img.height}');
      img.dispose();
    });
  }

  Future<void> monta(WidgetTester tester, Widget schermata) async {
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2391);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(
            create: (_) => SettingsController(suonoEVibrazione: false)),
        ChangeNotifierProvider(
            create: (_) => EntitlementService(initial: Tier.tier2)),
      ],
      child: RepaintBoundary(
        key: radice,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark(),
          builder: (c, figlio) => MaestroScope(child: figlio!),
          home: schermata,
        ),
      ),
    ));
    await passa(tester);
  }

  Future<void> montaCalendario(WidgetTester tester) => monta(
        tester,
        CalendarioLunareScreen(
          fabbricaDellaScena: _Ferma.new,
          adesso: () => DateTime(2026, 10, 15, 10, 5),
          identita: BirthIdentity(
              birthMoment: DateTime(1990, 5, 12, 14, 30), hasBirthTime: true),
          latitudine: 45.4,
          delMese: _ottobre,
          valuta: _valuta,
          giorniTuoi: _giorniTuoi,
          avvisi: _Telefono(),
        ),
      );

  testWidgets('FV: il mese di trenta lune e i giorni tuoi', (tester) async {
    if (_stato.isEmpty) return;
    await montaCalendario(tester);
    await passa(tester, 30);
    await scatta(tester, 'fv_lunario_1_mese_e_giorni_tuoi');
  });

  testWidgets('FV: "Trova il giorno" con gli aloni', (tester) async {
    if (_stato.isEmpty) return;
    await montaCalendario(tester);
    await passa(tester, 30);
    await tester.tap(find.byKey(const Key('lunario_emblema_orto')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('lunario_attivita_semina')));
    await passa(tester, 20);
    await scatta(tester, 'fv_lunario_2_trova_il_giorno_aloni');
  });

  testWidgets('FV: il foglio di un giorno', (tester) async {
    if (_stato.isEmpty) return;
    await montaCalendario(tester);
    await passa(tester, 30);
    await tester.tap(find.byKey(const Key('lunario_giorno_20')));
    await passa(tester, 6);
    await scatta(tester, 'fv_lunario_3_foglio_del_giorno');
  });

  testWidgets('FV: la card del mese', (tester) async {
    if (_stato.isEmpty) return;
    await monta(
      tester,
      Scaffold(
        body: Center(
          child: LaCardDelMese(
            anno: 2026,
            mese: 10,
            giorni: _ottobre(2026, 10),
            ruota: false,
            attivita: AttivitaDelLunario.semina,
            giorniDOro: const {12, 20},
            width: 360,
          ),
        ),
      ),
    );
    await passa(tester, 10);
    await scatta(tester, 'fv_lunario_4_la_card_del_mese');
  });
}
