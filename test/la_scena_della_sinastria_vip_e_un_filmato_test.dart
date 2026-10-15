// ignore_for_file: avoid_print
import 'dart:math' as math;

import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/sensi/la_suoneria.dart';
import 'package:esoteric_circle/core/settings/settings_controller.dart';
import 'package:esoteric_circle/core/synastry/collezione_delle_coppie.dart';
import 'package:esoteric_circle/design_system/components/riga_del_residuo.dart';
import 'package:esoteric_circle/design_system/components/vip_frame.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/scene/la_scena_in_video.dart';
import 'package:esoteric_circle/features/synastry/porta_della_sinastria.dart';
import 'package:esoteric_circle/features/synastry/sinastria_gallery_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// **LA SCENA DELLA SINASTRIA VIP E' UN FILMATO, IL SIPARIO DELLE STELLE.**
/// Ordine FU voce FU.14, 15 ottobre 2026. Il fondatore: *"Si le lasciamo
/// sotto come alone. I volti all'interno delle carte sono già piccoli e
/// servono carte più grandi possibili"*.
///
/// Stessa forma delle guardie gemelle della Stesa e della Sinastria
/// evolutiva: il video parte all'apertura della porta, una volta per
/// apertura, e si ferma sull'ultimo fotogramma, che resta come sfondo;
/// l'interfaccia di prima compare sopra solo a video finito o saltato, o
/// subito con la scena ferma; l'audio rispetta le impostazioni e il
/// silenzioso; un tocco salta il video e non arriva a niente di cio' che sta
/// sotto. E la geometria: le due carte sulle due cornici di luce, dentro lo
/// schermo, senza toccare titolo, cuore e pulsante, a tre larghezze.
class _Finta implements LettoreDiScena {
  _Finta({this.falliraAllApertura = false});

  final bool falliraAllApertura;
  VoidCallback? _ascolta;
  bool _pronto = false;
  bool _fallito = false;
  bool _cominciato = false;
  bool _finito = false;
  int aperture = 0;
  int avvii = 0;
  int sospensioni = 0;
  bool chiusa = false;
  final volumi = <double>[];

  @override
  bool get pronto => _pronto;
  @override
  bool get fallito => _fallito;
  @override
  bool get cominciato => _cominciato;
  @override
  bool get finito => _finito;
  @override
  void ascolta(VoidCallback? quandoCambia) => _ascolta = quandoCambia;

  @override
  Future<void> apri() async {
    aperture++;
    if (falliraAllApertura) {
      _fallito = true;
    } else {
      _pronto = true;
    }
    _ascolta?.call();
  }

  @override
  Future<void> volume(double quanto) async => volumi.add(quanto);

  @override
  Future<void> avvia() async {
    if (_finito) return;
    avvii++;
  }

  @override
  Future<void> sospendi() async => sospensioni++;

  @override
  Widget disegna() => const ColoredBox(
      key: Key('finta_del_sipario_vip'), color: Color(0xFF203040));

  @override
  void chiudi() => chiusa = true;

  void comincia() {
    _cominciato = true;
    _ascolta?.call();
  }

  void finisci() {
    _finito = true;
    _ascolta?.call();
  }
}

/// Le cornici e il cuore misurati con Python sull'ultimo fotogramma
/// (`docs/collaudo/FU/fu14_scena_vip.txt`), in pixel del video 1080 per
/// 1920. **Scritti qui una seconda volta, e non letti dal codice**: se il
/// codice spostasse le sue misure, la prova se ne accorgerebbe.
const _video = Size(1080, 1920);
const _corniceSinistra = Rect.fromLTRB(167, 736, 465, 1232);
const _corniceDestra = Rect.fromLTRB(614, 736, 912, 1232);
const _cuoreDipinto = Offset(541, 961);

/// Il taglio `BoxFit.cover` centrato, rifatto a mano.
Rect _sulloSchermo(Rect r, Size s) {
  final k = math.max(s.width / _video.width, s.height / _video.height);
  final dx = (s.width - _video.width * k) / 2;
  final dy = (s.height - _video.height * k) / 2;
  return Rect.fromLTRB(
      dx + r.left * k, dy + r.top * k, dx + r.right * k, dy + r.bottom * k);
}

/// La larghezza della carta prima dell'ordine FU, a 360 punti: la riga
/// divisa a meta' col cuore in mezzo, misurata sulla cattura
/// `docs/preview/FU/fu14_porta_vip_prima.png`.
const _larghezzaDiPrimaA360 = 144.0;

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silenzia() {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (call) async => null);
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

  Widget app({
    required List<_Finta> lettori,
    required Size schermo,
    bool riduci = false,
    bool suono = true,
    bool grafica = true,
    double scalaDelTesto = 1.0,
    bool sopraUnaPagina = false,
  }) {
    // La stessa lista per tutte le aperture: ognuna prende il lettore dopo.
    final finte = lettori;
    final porta = PortaDellaSinastria(
      userSign: Zodiac.leo,
      userName: 'Mauro',
      userBirth: DateTime(1972, 8, 10),
      fabbricaDellaScena: () => finte.removeAt(0),
    );
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) {
          final q = QualityTierController();
          if (!grafica) q.setTier(QualityTier.low);
          return q;
        }),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => CollezioneDelleCoppie()),
        ChangeNotifierProvider(
            create: (_) => SettingsController(suonoEVibrazione: suono)),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(
              disableAnimations: riduci,
              textScaler: TextScaler.linear(scalaDelTesto)),
          child: MaestroScope(child: child!),
        ),
        home: sopraUnaPagina
            ? Builder(
                builder: (context) => Scaffold(
                  body: Center(
                    child: TextButton(
                      key: const Key('apri_la_porta'),
                      onPressed: () => Navigator.of(context)
                          .push(MaterialPageRoute<void>(builder: (_) => porta)),
                      child: const Text('apri'),
                    ),
                  ),
                ),
              )
            : porta,
      ),
    );
  }

  Future<void> monta(
    WidgetTester tester, {
    required List<_Finta> lettori,
    Size schermo = const Size(390, 844),
    bool riduci = false,
    bool suono = true,
    bool grafica = true,
  }) async {
    silenzia();
    tester.view.physicalSize = schermo;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(app(
        lettori: lettori,
        schermo: schermo,
        riduci: riduci,
        suono: suono,
        grafica: grafica));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  final interfaccia = find.byKey(const Key('sinastria_vip_interfaccia'));
  final filmato = find.byKey(const Key('finta_del_sipario_vip'));
  final velo = find.byKey(const Key('il_tocco_che_salta'));

  String? sfondo(WidgetTester tester) {
    final f = find.byKey(const Key('sinastria_vip_sfondo'));
    if (f.evaluate().isEmpty) return null;
    return (tester.widget<Image>(f).image as AssetImage).assetName;
  }

  setUp(() => LaSuoneria.spentaPerLeProve = false);
  tearDown(() => LaSuoneria.spentaPerLeProve = null);

  test('il filmato e i due fotogrammi sono quelli dell\'ordine', () {
    expect(IlPalcoDellaSinastriaVip.filmato,
        'brand_assets/vip_scena/medora_sipario_delle_stelle_v1.mp4');
    expect(IlPalcoDellaSinastriaVip.ultimoFotogramma,
        'assets/img/vip_scena/vip_ultimo_fotogramma_v1.webp');
    expect(IlPalcoDellaSinastriaVip.primoFotogramma,
        'assets/img/vip_scena/vip_primo_fotogramma_v1.webp');
  });

  testWidgets(
      'aprendo la porta il Sipario parte, senza interfaccia sopra, e a video '
      'finito resta l\'ultimo fotogramma con l\'interfaccia', (tester) async {
    final finta = _Finta();
    await monta(tester, lettori: [finta]);
    expect(finta.aperture, 1);
    expect(finta.avvii, 1, reason: 'il Sipario non parte all\'apertura');
    expect(finta.volumi.last, 1.0);
    expect(interfaccia, findsNothing,
        reason: 'col video che si prepara l\'interfaccia c\'e\' gia\'');
    expect(sfondo(tester), IlPalcoDellaSinastriaVip.primoFotogramma,
        reason: 'prima del video si vede il sipario chiuso');

    finta.comincia();
    await tester.pump();
    expect(filmato, findsOneWidget, reason: 'il video non e\' in scena');
    expect(interfaccia, findsNothing,
        reason: 'col video in corso l\'interfaccia non deve esserci');
    expect(sfondo(tester), IlPalcoDellaSinastriaVip.ultimoFotogramma);

    finta.finisci();
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(interfaccia, findsOneWidget,
        reason: 'a video finito l\'interfaccia non compare');
    expect(sfondo(tester), IlPalcoDellaSinastriaVip.ultimoFotogramma,
        reason: 'a video finito lo sfondo non e\' l\'ultimo fotogramma');
    expect(finta.avvii, 1, reason: 'il Sipario e\' ripartito');
    expect(finta.chiusa, isFalse);
    expect(find.byKey(const Key('sinastria_titolo_confronto')), findsOneWidget);
    expect(find.byKey(const Key('sinastria_fai_il_confronto')), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    expect(finta.chiusa, isTrue, reason: 'il lettore non si chiude');
  });

  testWidgets(
      'una volta per apertura: le dipendenze che cambiano non lo fanno '
      'ripartire, una nuova apertura si', (tester) async {
    silenzia();
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final prima = _Finta();
    final seconda = _Finta();
    final lettori = [prima, seconda];
    await tester.pumpWidget(app(
        lettori: lettori, schermo: const Size(390, 844), sopraUnaPagina: true));
    await tester.tap(find.byKey(const Key('apri_la_porta')));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(prima.aperture, 1);
    // La scala del testo cambia: didChangeDependencies gira di nuovo.
    await tester.pumpWidget(app(
        lettori: lettori,
        schermo: const Size(390, 844),
        sopraUnaPagina: true,
        scalaDelTesto: 1.2));
    await tester.pump(const Duration(milliseconds: 200));
    expect(prima.aperture, 1,
        reason: 'il Sipario si e\' riaperto nella stessa apertura');
    expect(prima.avvii, 1);
    expect(lettori, [seconda],
        reason: 'nella stessa apertura e\' stato chiesto un secondo lettore: '
            'il Sipario si e\' riaperto');

    // Si esce e si rientra: e' una nuova apertura.
    final indietro = tester.state<NavigatorState>(find.byType(Navigator));
    indietro.pop();
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(prima.chiusa, isTrue);
    await tester.tap(find.byKey(const Key('apri_la_porta')));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(seconda.aperture, 1, reason: 'rientrando il Sipario non riparte');
    expect(seconda.avvii, 1);
  });

  for (final caso in const ['riduci', 'grafica', 'fallisce']) {
    testWidgets(
        'scena ferma ($caso): nessun video, l\'ultimo fotogramma e '
        'l\'interfaccia subito', (tester) async {
      final finta = _Finta(falliraAllApertura: caso == 'fallisce');
      await monta(tester,
          lettori: [finta],
          riduci: caso == 'riduci',
          grafica: caso != 'grafica');
      if (caso != 'fallisce') expect(finta.aperture, 0);
      expect(finta.avvii, 0);
      expect(filmato, findsNothing);
      expect(velo, findsNothing);
      expect(interfaccia, findsOneWidget,
          reason: 'con la scena ferma l\'interfaccia deve esserci subito');
      expect(sfondo(tester), IlPalcoDellaSinastriaVip.ultimoFotogramma);
    });
  }

  testWidgets('a suoni spenti nell\'app il Sipario e\' muto', (tester) async {
    final finta = _Finta();
    await monta(tester, lettori: [finta], suono: false);
    expect(finta.volumi, isNotEmpty);
    expect(finta.volumi.last, 0.0);
  });

  testWidgets('col telefono in silenzioso il Sipario e\' muto, ma parte',
      (tester) async {
    LaSuoneria.spentaPerLeProve = true;
    final finta = _Finta();
    await monta(tester, lettori: [finta]);
    expect(finta.volumi, isNotEmpty);
    expect(finta.volumi.last, 0.0);
    expect(finta.avvii, 1);
  });

  testWidgets(
      'uscendo dall\'app il Sipario si ferma, e al ritorno riprende se non '
      'e\' finito', (tester) async {
    final finta = _Finta();
    await monta(tester, lettori: [finta]);
    finta.comincia();
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(finta.sospensioni, greaterThanOrEqualTo(1));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump(const Duration(milliseconds: 200));
    expect(finta.avvii, 2);
  });

  testWidgets(
      'FU.15: il tocco fa sfumare il Sipario, l\'interfaccia compare subito, '
      'e il tocco non arriva a cio\' che sta sotto', (tester) async {
    silenzia();
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final finta = _Finta();
    await tester.pumpWidget(app(
        lettori: [finta], schermo: const Size(390, 844), sopraUnaPagina: true));
    await tester.tap(find.byKey(const Key('apri_la_porta')));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    finta.comincia();
    await tester.pump();
    expect(velo, findsOneWidget,
        reason: 'col video in corso il tocco che salta non c\'e\'');
    expect(tester.getRect(velo).size, const Size(390, 844),
        reason: 'il velo non copre tutto lo schermo');

    // Il tocco cade sulla freccia della barra, che altrimenti chiuderebbe la
    // porta: e' il gesto che il velo deve consumare.
    final freccia = tester.getCenter(find.byType(BackButton));
    final primaDelTocco = finta.sospensioni;
    await tester.tapAt(freccia);
    await tester.pump();
    expect(finta.sospensioni, primaDelTocco + 1,
        reason: 'il tocco non ha fermato il video');
    expect(interfaccia, findsOneWidget,
        reason: 'saltato il video l\'interfaccia deve comparire subito');
    expect(find.byType(PortaDellaSinastria), findsOneWidget,
        reason: 'il tocco che salta e\' arrivato alla freccia e ha chiuso '
            'la porta');

    await tester.pump(IlFilmatoCheSfuma.dissolvenza);
    await tester.pump(const Duration(milliseconds: 100));
    final opacita = tester
        .widget<AnimatedOpacity>(
            find.ancestor(of: filmato, matching: find.byType(AnimatedOpacity)))
        .opacity;
    expect(opacita, 0, reason: 'il Sipario saltato non sfuma');
    expect(velo, findsNothing, reason: 'saltato il video il velo deve sparire');
    expect(sfondo(tester), IlPalcoDellaSinastriaVip.ultimoFotogramma);
    expect(finta.avvii, 1, reason: 'il video saltato e\' ripartito');
    expect(find.byType(SinastriaGalleryScreen), findsNothing);

    // Dopo il salto la schermata risponde come sempre.
    await tester.tap(find.byKey(const Key('sinastria_carta_da_scegliere')));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
    expect(find.byType(SinastriaGalleryScreen), findsOneWidget,
        reason: 'dopo il salto la carta non risponde');
  });

  for (final schermo in const [
    Size(360, 797),
    Size(390, 844),
    Size(430, 932)
  ]) {
    testWidgets(
        'a ${schermo.width.toInt()}x${schermo.height.toInt()} le carte stanno '
        'sulle cornici, dentro lo schermo, senza toccare titolo, cuore e '
        'pulsante, e sono le piu\' grandi possibile', (tester) async {
      await monta(tester, lettori: [_Finta()], schermo: schermo, riduci: true);
      Rect carta(String chiave) => tester.getRect(find.descendant(
          of: find.byKey(Key(chiave)),
          matching: find.byType(VipFramedPortrait)));
      final tua = carta('sinastria_carta_tua');
      final vip = carta('sinastria_carta_da_scegliere');
      final cuore =
          tester.getRect(find.byKey(const Key('sinastria_vip_cuore')));
      final titolo =
          tester.getRect(find.byKey(const Key('sinastria_titolo_confronto')));
      final residuo = tester.getRect(find.byType(RigaDelResiduo));
      final bottone =
          tester.getRect(find.byKey(const Key('sinastria_fai_il_confronto')));
      final cs = _sulloSchermo(_corniceSinistra, schermo);
      final cd = _sulloSchermo(_corniceDestra, schermo);
      final cuoreDipinto = _sulloSchermo(
              Rect.fromCenter(center: _cuoreDipinto, width: 0, height: 0),
              schermo)
          .center;
      print('ORDINE FU VOCE FU.14 a ${schermo.width.toInt()}x'
          '${schermo.height.toInt()}: carta tua $tua, carta VIP $vip, '
          'cornici $cs e $cd, cuore $cuore, titolo ${titolo.bottom}, '
          'residuo ${residuo.bottom}, pulsante ${bottone.top}');

      final colpe = <String>[];
      // Centrate sulle cornici.
      for (final (nome, c, f) in [('tua', tua, cs), ('VIP', vip, cd)]) {
        if ((c.center - f.center).distance > 0.5) {
          colpe.add('la carta $nome ha il centro a ${c.center}, la cornice a '
              '${f.center}');
        }
        // Le cornici restano sotto come alone: la carta le copre.
        if (c.width < f.width || c.height < f.height) {
          colpe.add('la carta $nome e\' piu\' piccola della sua cornice');
        }
        // Dentro lo schermo.
        if (c.left < 0 ||
            c.right > schermo.width ||
            c.top < 0 ||
            c.bottom > schermo.height) {
          colpe.add('la carta $nome esce dallo schermo: $c');
        }
        // Non tocca il titolo, il residuo, il pulsante.
        if (c.top <= titolo.bottom || c.top <= residuo.bottom) {
          colpe.add('la carta $nome tocca il titolo');
        }
        if (c.bottom >= bottone.top) {
          colpe.add('la carta $nome tocca il pulsante');
        }
        if (c.overlaps(cuore)) colpe.add('la carta $nome tocca il cuore');
      }
      // R10: il titolo resta dov'era prima dell'ordine FU, sotto la barra
      // e la sua altezza ancora (la barra e' alta kToolbarHeight, e il
      // corpo la porta nei suoi margini): 112 punti, misurati anche sulla
      // cattura `fu14_porta_vip_prima.png`.
      if ((titolo.top - 2 * kToolbarHeight).abs() > 0.5) {
        colpe.add('il titolo e\' a ${titolo.top}, prima era a '
            '${2 * kToolbarHeight}');
      }
      if ((cuore.center - cuoreDipinto).distance > 0.5) {
        colpe.add('il cuore e\' a ${cuore.center}, quello dipinto a '
            '$cuoreDipinto');
      }
      // Le piu' grandi possibile: almeno un limite e' raggiunto, cioe' una
      // carta e' a non piu' di cinque punti dal cuore o dal bordo.
      final margini = [
        cuore.left - tua.right,
        vip.left - cuore.right,
        tua.left,
        schermo.width - vip.right,
      ];
      final stretto = margini.reduce(math.min);
      if (stretto > 5) {
        colpe.add('le carte potevano crescere: il margine piu\' stretto e\' '
            '$stretto punti');
      }
      if ((tua.width - vip.width).abs() > 0.01) {
        colpe.add('le due carte hanno grandezze diverse');
      }
      if ((tua.width / tua.height - VipFrame.aspect).abs() > 0.01) {
        colpe.add('la carta non e\' piu\' 2:3');
      }
      if (schermo.width == 360 && tua.width <= _larghezzaDiPrimaA360) {
        colpe.add('la carta e\' larga ${tua.width}, prima era '
            '$_larghezzaDiPrimaA360: non e\' cresciuta');
      }
      expect(tester.takeException(), isNull);
      expect(colpe, isEmpty, reason: colpe.join('; '));
    });
  }
}
