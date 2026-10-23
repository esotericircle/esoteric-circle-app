import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/sensi/la_suoneria.dart';
import 'package:esoteric_circle/core/settings/settings_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/tarot/il_tavolo_di_medora.dart';
import 'package:esoteric_circle/features/tarot/la_scena_della_stesa_in_video.dart';
import 'package:esoteric_circle/features/tarot/stesa_tre_carte_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'cardinale_minimo.dart';
import 'sopra_il_filmato.dart';

/// **LA SCENA DELLA STESA E' UN FILMATO.** Ordine FS aggiunta, voce FS.A2,
/// 14 ottobre 2026.
///
/// Il fondatore ha scelto *"Il vortice"*: aprendo la Stesa, al posto della
/// scena ferma parte il video, nello stesso riquadro e con lo stesso taglio;
/// si ferma sull'ultimo fotogramma e ci resta; parte una volta per apertura;
/// con Riduci Movimento, o se non si carica, la scena e' ferma con la posa
/// dell'invito; l'audio rispetta le impostazioni dell'app e il silenzioso.
class _Finta implements LettoreDellaScena {
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
  Widget disegna() =>
      const ColoredBox(key: Key('finta_del_filmato'), color: Color(0xFF203040));

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

Future<void> _monta(
  WidgetTester tester, {
  required List<_Finta> lettori,
  bool riduci = false,
  bool suono = true,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final finte = List.of(lettori);
  await tester.pumpWidget(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => MaestroController()),
      ChangeNotifierProvider(create: (_) => ParallaxController()),
      ChangeNotifierProvider(create: (_) => QualityTierController()),
      ChangeNotifierProvider(create: (_) => ZodiacController()),
      ChangeNotifierProvider(
          create: (_) => SettingsController(suonoEVibrazione: suono)),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MediaQuery(
        data: MediaQueryData(
            size: const Size(390, 844), disableAnimations: riduci),
        child: MaestroScope(
          child: StesaTreCarteScreen(
            seed: 2,
            skipIntro: true,
            fabbricaDellaScena: () => finte.removeAt(0),
          ),
        ),
      ),
    ),
  ));
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

String? _posa(WidgetTester tester) {
  final f = find.byKey(const Key('tavolo_medora'));
  if (f.evaluate().isEmpty) return null;
  final img = tester.widget<Image>(f);
  return (img.image as AssetImage).assetName;
}

void main() {
  // Il canale della suoneria in una prova non risponde dentro il tempo finto
  // dei `pump`: la risposta la da' la prova, "suoneria accesa", e il caso del
  // silenzioso la cambia.
  setUp(() => LaSuoneria.spentaPerLeProve = false);
  tearDown(() => LaSuoneria.spentaPerLeProve = null);

  group('il taglio del filmato (P2 dell\'ordine)', () {
    test('il riquadro copre lo sfondo dal pixel 147 al 1370, a tutta larghezza',
        () {
      final larghezze = [360.0, 390.0, 430.0];
      cardinaleMinimo(larghezze.length, 3, cosa: 'larghezze dello schermo');
      for (final w in larghezze) {
        final r = ScenaDellaStesaInVideo.nellaScena(w);
        final s = GeometriaDelTavolo.scala(w);
        expect(r.left, 0);
        expect(r.width, w);
        expect(r.top, closeTo((147 - 418) * s, 1e-9));
        expect(r.height, closeTo(1223 * s, 1e-9));
        // La proporzione del riquadro e' quella del filmato.
        expect(r.width / r.height, closeTo(720 / 1280, 0.001));
        // Il taglio in alto della scena cade al pixel 283,6 del filmato.
        final pixel = -r.top / r.height * 1280;
        expect(pixel, closeTo(283.6, 0.05));
      }
    });

    test('il filmato e le due pose esistono e sono dichiarati', () {
      expect(ScenaDellaStesaInVideo.filmato,
          'brand_assets/tavolo/medora_mazzo_in_vortice_v2.mp4');
      expect(GeometriaDelTavolo.posaDelMazzo,
          'assets/img/tavolo/medora_mazzo_v1.webp');
      expect(GeometriaDelTavolo.posaDellInvito,
          'assets/img/tavolo/medora_invito_v1.webp');
    });
  });

  testWidgets(
      'aprendo la Stesa il filmato parte, prende il posto di Medora ferma e '
      'resta sull\'ultimo fotogramma', (tester) async {
    final finta = _Finta();
    await _monta(tester, lettori: [finta]);
    expect(finta.aperture, 1);
    expect(finta.avvii, 1, reason: 'il filmato non parte all\'apertura');
    expect(finta.volumi, isNotEmpty,
        reason: 'il volume non e\' detto prima di partire');
    expect(finta.volumi.last, 1.0);
    // Prima del primo fotogramma: la posa del mazzo, che e' il primo
    // fotogramma, e nessun filmato.
    expect(_posa(tester), GeometriaDelTavolo.posaDelMazzo);
    expect(find.byKey(const Key('finta_del_filmato')), findsNothing);

    final carteAPrima = tester.getRect(find.byKey(const Key('stesa_slots')));
    finta.comincia();
    await tester.pump();
    expect(find.byKey(const Key('finta_del_filmato')), findsOneWidget);
    expect(_posa(tester), isNull,
        reason: 'col filmato in scena Medora ferma resta sopra');
    // Il filmato sta nel riquadro del taglio.
    final scena = tester.getRect(find.byKey(const Key('stesa_slots')));
    final atteso =
        ScenaDellaStesaInVideo.nellaScena(scena.width).shift(scena.topLeft);
    final filmato = tester.getRect(find.byKey(const Key('tavolo_filmato')));
    expect(filmato.top, closeTo(atteso.top, 0.01));
    expect(filmato.height, closeTo(atteso.height, 0.01));
    expect(filmato.width, closeTo(atteso.width, 0.01));
    // La scena non si e' spostata.
    expect(scena, carteAPrima);

    finta.finisci();
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(find.byKey(const Key('finta_del_filmato')), findsOneWidget,
        reason: 'a filmato finito resta l\'ultimo fotogramma');
    expect(finta.avvii, 1, reason: 'il filmato e\' ripartito');
    expect(finta.chiusa, isFalse);

    await tester.pumpWidget(const SizedBox());
    expect(finta.chiusa, isTrue, reason: 'il lettore non si chiude');
  });

  testWidgets('una volta per apertura: il lettore si costruisce una volta sola',
      (tester) async {
    final prima = _Finta();
    final seconda = _Finta();
    await _monta(tester, lettori: [prima, seconda]);
    prima
      ..comincia()
      ..finisci();
    // La schermata si ricostruisce e rilegge le sue dipendenze molte volte
    // (qui il tier della grafica, che `didChangeDependencies` osserva): il
    // lettore resta quello.
    final tier = Provider.of<QualityTierController>(
        tester.element(find.byType(StesaTreCarteScreen)),
        listen: false);
    for (final t in [
      QualityTier.medium,
      QualityTier.high,
      QualityTier.medium
    ]) {
      tier.setTier(t);
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(seconda.aperture, 0, reason: 'il filmato e\' stato riaperto');
    expect(prima.avvii, 1);
  });

  testWidgets(
      'con Riduci Movimento la scena e\' ferma, con la posa dell\'invito',
      (tester) async {
    final finta = _Finta();
    await _monta(tester, lettori: [finta], riduci: true);
    expect(finta.aperture, 0,
        reason: 'con Riduci Movimento il filmato si apre');
    expect(find.byKey(const Key('finta_del_filmato')), findsNothing);
    // **GC.03**: la scena ferma e' l'ultimo fotogramma del filmato, lo
    // stesso dove il filmato si ferma da solo; la posa scontornata non
    // si posa piu' sopra. LAPIDE: `_posa(tester) == posaDellInvito`.
    expect(find.byKey(const Key('tavolo_fotogramma_di_arrivo')),
        findsOneWidget);
    expect(_posa(tester), isNull);
  });

  testWidgets('se il filmato non si carica la scena e\' ferma, con l\'invito',
      (tester) async {
    final finta = _Finta(falliraAllApertura: true);
    await _monta(tester, lettori: [finta]);
    expect(finta.avvii, 0);
    expect(find.byKey(const Key('finta_del_filmato')), findsNothing);
    // **GC.03**: la scena ferma e' l'ultimo fotogramma del filmato, lo
    // stesso dove il filmato si ferma da solo; la posa scontornata non
    // si posa piu' sopra. LAPIDE: `_posa(tester) == posaDellInvito`.
    expect(find.byKey(const Key('tavolo_fotogramma_di_arrivo')),
        findsOneWidget);
    expect(_posa(tester), isNull);
  });

  testWidgets('a suoni spenti nell\'app il filmato e\' muto', (tester) async {
    final finta = _Finta();
    await _monta(tester, lettori: [finta], suono: false);
    expect(finta.volumi, isNotEmpty);
    expect(finta.volumi.last, 0.0);
  });

  testWidgets('col telefono in silenzioso il filmato e\' muto', (tester) async {
    LaSuoneria.spentaPerLeProve = true;
    final finta = _Finta();
    await _monta(tester, lettori: [finta]);
    expect(finta.volumi, isNotEmpty);
    expect(finta.volumi.last, 0.0);
    expect(finta.avvii, 1, reason: 'muto, ma il filmato parte lo stesso');
  });

  testWidgets(
      'uscendo dall\'app il filmato si ferma, e al ritorno riprende se non e\' '
      'finito', (tester) async {
    final finta = _Finta();
    await _monta(tester, lettori: [finta]);
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
    finta.finisci();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump(const Duration(milliseconds: 200));
    expect(finta.avvii, 2,
        reason: 'a filmato finito il ritorno lo fa ripartire');
  });

  testWidgets(
      'FXA.08: a video in corso sopra la scena si vede solo il video, e il '
      'resto compare in dissolvenza quando finisce', (tester) async {
    final finta = _Finta();
    await _monta(tester, lettori: [finta]);
    finta.comincia();
    await tester.pump(const Duration(milliseconds: 600));
    await soloIlFilmatoFinche(tester,
        scena: 'la Stesa',
        filmato: find.byKey(const Key('finta_del_filmato')),
        finisci: finta.finisci);
  });

  testWidgets(
      'FU.15: un tocco mentre il video gira lo fa sfumare sulla posa finale, '
      'e il tocco non arriva alla scena sotto', (tester) async {
    final finta = _Finta();
    await _monta(tester, lettori: [finta]);
    finta.comincia();
    await tester.pump();
    final velo = find.byKey(const Key('il_tocco_che_salta'));
    expect(velo, findsOneWidget,
        reason: 'col video in corso il tocco che salta non c\'e\'');
    // Il velo copre tutto lo schermo: il tocco, ovunque, e' suo.
    expect(tester.getRect(velo).size, const Size(390, 844));
    final primaDelTocco = finta.sospensioni;
    await tester.tapAt(const Offset(195, 500));
    await tester.pump();
    expect(finta.sospensioni, primaDelTocco + 1,
        reason: 'il tocco non ha fermato il video');
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(velo, findsNothing,
        reason: 'saltato il video, il velo deve sparire: dopo il tocco la '
            'schermata risponde come sempre');
    // **GC.03**: saltato il video, sotto il filmato che sfuma c'e' il suo
    // ultimo fotogramma, Medora con la mano al cuore e l'altra che indica il
    // tavolo. LAPIDE: "la scena ferma e' l'ultima posa" (posaDellInvito).
    expect(find.byKey(const Key('tavolo_fotogramma_di_arrivo')),
        findsOneWidget,
        reason: 'saltato il video, la scena ferma non e\' l\'ultimo '
            'fotogramma del filmato');
    expect(_posa(tester), isNull,
        reason: 'saltato il video, la posa scontornata si posa ancora sopra');
    expect(finta.avvii, 1, reason: 'il video saltato e\' ripartito');
  });
}
