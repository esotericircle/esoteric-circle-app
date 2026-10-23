// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:crypto/crypto.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/feature_flags/feature_flag_service.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/la_scena_del_maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/rituals/sunset_rune.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/domain_screen.dart';
import 'package:esoteric_circle/features/santuario/greeting_controller.dart';
import 'package:esoteric_circle/features/scene/la_scena_in_video.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **IL DONO NEL PALMO DEI MAESTRI, ordine GD voci GD.01 e GD.02, 23 ottobre
/// 2026.** Il fondatore: *"Medora alla fine mostra la mano aperta e dovrebbe
/// comparire il segno zodiacale dell'utente, ma non compare"*; *"Per Caligo
/// bisogna scambiare il video introduttivo della chat con quello del dominio
/// e nella sua mano aperta dovrebbe comparire la runa del tramonto del
/// giorno"*.
///
/// Si misura il FATTO, non la presenza di un'immagine: quale arte compare
/// (il segno della persona, la runa di quel giorno), dove cade sul
/// fotogramma dipinto (dentro la mano, contata coi pixel del fotogramma) e
/// quando (mai a video in corso, si' a video finito, saltato, fallito o con
/// Riduci Movimento). Con `--dart-define=CATTURE=si` scrive le catture in
/// `docs/collaudo/GD/catture/`.
const _catture = String.fromEnvironment('CATTURE');

class _Finta implements LettoreDiScena {
  _Finta({this.fallira = false});
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
      key: Key('finta_del_filmato_gd'), color: Color(0xFF102030));
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

final _radice = GlobalKey();

/// Una persona nata in quel giorno, senza ora: dati veri, non d'esempio.
BirthIdentity _natoIl(DateTime giorno) =>
    BirthIdentity.fromParts(birthDate: giorno);

Future<void> _monta(
  WidgetTester tester, {
  required Maestro maestro,
  required _Finta lettore,
  BirthIdentity? identita,
  DateTime? adesso,
  bool riduci = false,
}) async {
  SharedPreferences.setMockInitialValues({});
  tester.view.physicalSize = const Size(1080, 2391);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
  // Un albero vuoto prima: rimontando nella stessa prova, i provider
  // terrebbero il controller della persona precedente.
  await tester.pumpWidget(const SizedBox());
  await tester.pumpWidget(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => MaestroController()),
      ChangeNotifierProvider(create: (_) => QualityTierController()),
      ChangeNotifierProvider(create: (_) => EntitlementService()),
      ChangeNotifierProvider(
          create: (_) => ProfileController(identity: identita)),
      ChangeNotifierProvider(create: (_) => BirthIdentityController()),
      ChangeNotifierProvider(create: (_) => ParallaxController()),
      ChangeNotifierProvider(create: (_) => ZodiacController()),
      ChangeNotifierProvider(create: (_) => GreetingController()),
      ChangeNotifierProvider(
        create: (ctx) =>
            FeatureFlagService(entitlement: ctx.read<EntitlementService>())
              ..initialize(),
      ),
    ],
    child: RepaintBoundary(
      key: _radice,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        home: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: riduci),
            child: MaestroScope(
              maestro: maestro,
              child: DomainScreen(
                  maestro: maestro,
                  fabbricaDellaScena: () => lettore,
                  adesso: adesso),
            ),
          ),
        ),
      ),
    ),
  ));
  await tester.pump(const Duration(milliseconds: 100));
  await tester.runAsync(() async {
    for (final e in find.byType(Image).evaluate()) {
      await precacheImage((e.widget as Image).image, e);
    }
  });
  await tester.pump(const Duration(milliseconds: 600));
}

Finder _dono(Maestro m) => find.byKey(Key('dono_nel_palmo_${m.id}'));

String _arteDel(WidgetTester tester, Maestro m) =>
    (tester.widget<Image>(_dono(m)).image as AssetImage).assetName;

/// L'opacita' VERA con cui il dono si dipinge: il prodotto delle opacita'
/// dei suoi antenati, lette dagli oggetti di resa, non dai widget.
double _opacitaDelDono(WidgetTester tester, Maestro m) {
  var quanto = 1.0;
  RenderObject? su = tester.renderObject(_dono(m));
  while (su != null) {
    if (su is RenderAnimatedOpacity) quanto *= su.opacity.value;
    if (su is RenderOpacity) quanto *= su.opacity;
    su = su.parent;
  }
  return quanto;
}

/// Il centro del dono riportato nei pixel del fotogramma dipinto (1080 per
/// 1920), dal riquadro VERO del fotogramma a schermo (`BoxFit.cover`): cosi'
/// la prova non legge le costanti del codice, rifa' il conto all'indietro.
Offset _nelFotogramma(WidgetTester tester, Maestro m) {
  final f = tester.getRect(find.byKey(const Key('dominio_fotogramma')));
  final scala = math.max(f.width / 1080, f.height / 1920);
  final dx = f.left + (f.width - 1080 * scala) / 2;
  final dy = f.top + (f.height - 1920 * scala) / 2;
  final c = tester.getRect(_dono(m)).center;
  return Offset((c.dx - dx) / scala, (c.dy - dy) / scala);
}

Future<void> _scatta(WidgetTester tester, String nome) async {
  if (_catture.isEmpty) return;
  await tester.runAsync(() async {
    final rb =
        _radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final img = await rb.toImage(pixelRatio: 3.0);
    final dati = await img.toByteData(format: ui.ImageByteFormat.png);
    final dir = Directory('docs/collaudo/GD/catture');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    File('${dir.path}/$nome.png').writeAsBytesSync(dati!.buffer.asUint8List());
    print('GD CATTURA: ${dir.path}/$nome.png ${img.width}x${img.height}');
    img.dispose();
  });
}

String _impronta(String percorso) =>
    sha256.convert(File(percorso).readAsBytesSync()).toString();

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    final messenger = binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
      (call) async => null,
    );
    for (final name in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      messenger.setMockStreamHandler(
        EventChannel(name),
        MockStreamHandler.inline(onListen: (args, events) {}),
      );
    }
  });

  group('GD.01, il segno nel palmo di Medora', () {
    // Due persone di segno diverso: la nascita del 5 luglio e' Cancro, quella
    // del 5 aprile e' Ariete. L'arte attesa e' scritta per esteso, non
    // ricavata dal codice che si prova.
    final casi = {
      'cancro': (
        _natoIl(DateTime(1990, 7, 5)),
        'assets/img/zodiac/zod_cancro.webp'
      ),
      'ariete': (
        _natoIl(DateTime(1990, 4, 5)),
        'assets/img/zodiac/zod_ariete.webp'
      ),
    };

    for (final caso in casi.entries) {
      testWidgets(
          'nata o nato sotto ${caso.key}: nel palmo compare l\'emblema dipinto '
          'del suo segno', (tester) async {
        await _monta(tester,
            maestro: Maestro.medora,
            lettore: _Finta(fallira: true),
            identita: caso.value.$1);
        expect(_dono(Maestro.medora), findsOneWidget,
            reason: 'nel palmo di Medora non compare niente');
        expect(_arteDel(tester, Maestro.medora), caso.value.$2,
            reason: 'il simbolo nel palmo non e\' quello del segno della '
                'persona');
        expect(_opacitaDelDono(tester, Maestro.medora), closeTo(1, 0.01));
        await _scatta(tester, 'gd01_medora_dominio_${caso.key}');
      });
    }

    testWidgets('due persone di segno diverso vedono due simboli diversi',
        (tester) async {
      final visti = <String>{};
      for (final caso in casi.values) {
        await _monta(tester,
            maestro: Maestro.medora,
            lettore: _Finta(fallira: true),
            identita: caso.$1);
        visti.add(_arteDel(tester, Maestro.medora));
      }
      expect(visti, hasLength(2));
    });

    testWidgets('il segno cade nella mano tesa del fotogramma dipinto',
        (tester) async {
      await _monta(tester,
          maestro: Maestro.medora,
          lettore: _Finta(fallira: true),
          identita: casi['cancro']!.$1);
      // La mano tesa di Medora sul fotogramma: dita da x 160, polso a x
      // 330; il segno sopra il palmo, fra y 850 e y 1000 (la mano e' a
      // 970-1060). Misurata sul fermo con un righello a passo venti.
      final c = _nelFotogramma(tester, Maestro.medora);
      expect(c.dx, inInclusiveRange(180, 310), reason: 'centro a $c');
      expect(c.dy, inInclusiveRange(850, 1000), reason: 'centro a $c');
    });

    testWidgets(
        'senza la data di nascita il palmo resta vuoto, non si '
        'inventa un segno', (tester) async {
      await _monta(tester,
          maestro: Maestro.medora, lettore: _Finta(fallira: true));
      expect(_dono(Maestro.medora), findsNothing);
    });
  });

  group('GD.02, i video di Caligo scambiati e la runa del tramonto', () {
    // Le impronte dei due contenuti, per quello che SONO, non per il nome:
    // il cerchio di fuoco col palmo aperto ("la runa della sera") e il
    // vortice, coi loro ultimi fotogrammi.
    const cerchioDiFuoco =
        '5965a25bf8dddd388f2e9194025e8aa586d5c667a7845a0d2f5ca463da6b0b65';
    const cerchioDiFuocoFermo =
        '8c87b79a805260b10962f5c5c5246819678628223f727540f61d3affa2bd0bd4';
    const vortice =
        '05b6636e90b647c8e409104f1f8af5d98fe3952229d7ae74bb86c1c72fb18660';
    const vorticeFermo =
        '83e10a5f1a02a49161f3efa03283fdf8c7a0c0cbe3eb285f9dd854205a0aa263';

    test('il dominio apre col cerchio di fuoco, la chat col vortice', () {
      final dominio = LaScenaDelMaestro.delDominio(Maestro.caligo);
      final chat = LaScenaDelMaestro.dellaChat(Maestro.caligo);
      expect(_impronta(dominio.video), cerchioDiFuoco,
          reason: 'il dominio non apre col video che prima apriva la chat');
      expect(_impronta(dominio.ultimoFotogramma), cerchioDiFuocoFermo);
      expect(_impronta(chat.video), vortice,
          reason: 'la chat non apre col video che prima apriva il dominio');
      expect(_impronta(chat.ultimoFotogramma), vorticeFermo);
    });

    testWidgets('la schermata del dominio mostra il fermo del cerchio di fuoco',
        (tester) async {
      await _monta(tester,
          maestro: Maestro.caligo, lettore: _Finta(fallira: true));
      final fermo = (tester
              .widget<Image>(find.byKey(const Key('dominio_fotogramma')))
              .image as AssetImage)
          .assetName;
      expect(_impronta(fermo), cerchioDiFuocoFermo);
      // **E I BYTE CHE LA SCHERMATA CARICA DAVVERO**, dal pacchetto degli
      // asset e non dal disco: con lo scambio fatto per rinomina i file
      // tengono la data di prima, e un pacchetto costruito prima dello
      // scambio mostrava ancora il fermo vecchio sotto il nome nuovo
      // (trovato guardando la cattura, con la prova sul disco verde).
      final caricati = await tester.runAsync(() => rootBundle.load(fermo));
      expect(sha256.convert(caricati!.buffer.asUint8List()).toString(),
          cerchioDiFuocoFermo,
          reason: 'il pacchetto degli asset porta il fermo di prima dello '
              'scambio: va ricostruito');
    });

    final persona = _natoIl(DateTime(1990, 7, 5));
    final identita = SunsetRune.identitaPer(
        nascita: persona.birthMoment, deviceId: 'mai usato');

    // Due sere con rune diverse per la stessa persona, cercate a partire dal
    // 20 ottobre 2026 alle diciannove.
    (DateTime, DateTime) dueSereDiverse() {
      final prima = DateTime(2026, 10, 20, 19);
      final runaPrima = SunsetRune.estrai(prima, identita: identita).rune.name;
      for (var i = 1; i < 30; i++) {
        final poi = prima.add(Duration(days: i));
        if (SunsetRune.estrai(poi, identita: identita).rune.name != runaPrima) {
          return (prima, poi);
        }
      }
      throw StateError('trenta sere con la stessa runa');
    }

    testWidgets(
        'nel palmo compare la pietra dipinta della runa del tramonto di quel '
        'giorno, e due giorni con rune diverse danno due pietre diverse',
        (tester) async {
      final (prima, poi) = dueSereDiverse();
      final viste = <String>[];
      for (final (i, sera) in [prima, poi].indexed) {
        await _monta(tester,
            maestro: Maestro.caligo,
            lettore: _Finta(fallira: true),
            identita: persona,
            adesso: sera);
        final attesa = SunsetRune.estrai(sera, identita: identita);
        expect(_dono(Maestro.caligo), findsOneWidget,
            reason: 'nel palmo di Caligo non compare niente');
        expect(_arteDel(tester, Maestro.caligo), attesa.rune.fullPath,
            reason: 'la pietra nel palmo non e\' la runa del tramonto del '
                '${SunsetRune.iso(attesa.giornoRituale)}');
        viste.add(_arteDel(tester, Maestro.caligo));
        await _scatta(tester, 'gd02_caligo_dominio_sera_${i + 1}');
      }
      expect(viste.toSet(), hasLength(2), reason: 'pietre viste: $viste');
    });

    testWidgets(
        'prima di mezzogiorno la pietra e\' ancora quella della sera prima, '
        'come nel rituale', (tester) async {
      final (_, poi) = dueSereDiverse();
      final mattinaDopo = DateTime(poi.year, poi.month, poi.day + 1, 9);
      await _monta(tester,
          maestro: Maestro.caligo,
          lettore: _Finta(fallira: true),
          identita: persona,
          adesso: mattinaDopo);
      expect(_arteDel(tester, Maestro.caligo),
          SunsetRune.estrai(poi, identita: identita).rune.fullPath);
    });

    testWidgets('la pietra cade dentro l\'anello di fuoco sopra la mano',
        (tester) async {
      await _monta(tester,
          maestro: Maestro.caligo,
          lettore: _Finta(fallira: true),
          identita: persona,
          adesso: DateTime(2026, 10, 20, 19));
      // Il vuoto dell'anello verde sul fotogramma: x 745-880, y 800-1060.
      final c = _nelFotogramma(tester, Maestro.caligo);
      expect(c.dx, inInclusiveRange(760, 865), reason: 'centro a $c');
      expect(c.dy, inInclusiveRange(820, 1040), reason: 'centro a $c');
    });
  });

  group('il dono compare solo sulla scena ferma', () {
    for (final m in [Maestro.medora, Maestro.caligo]) {
      testWidgets('${m.id}: mai a video in corso, si\' a video finito',
          (tester) async {
        final lettore = _Finta();
        await _monta(tester,
            maestro: m,
            lettore: lettore,
            identita: _natoIl(DateTime(1990, 7, 5)),
            adesso: DateTime(2026, 10, 20, 19));
        lettore.comincia();
        await tester.pump(const Duration(milliseconds: 600));
        expect(find.byKey(const Key('finta_del_filmato_gd')), findsOneWidget);
        expect(_opacitaDelDono(tester, m), lessThan(0.01),
            reason: 'il dono si vede mentre il video gira');
        lettore.finisci();
        await tester.pump();
        await tester.pump(IlFilmatoCheSfuma.dissolvenza);
        await tester.pump(const Duration(milliseconds: 50));
        expect(_opacitaDelDono(tester, m), closeTo(1, 0.01),
            reason: 'a video finito il dono non compare');
      });

      testWidgets('${m.id}: compare anche quando il video si salta',
          (tester) async {
        final lettore = _Finta();
        await _monta(tester,
            maestro: m,
            lettore: lettore,
            identita: _natoIl(DateTime(1990, 7, 5)),
            adesso: DateTime(2026, 10, 20, 19));
        lettore.comincia();
        await tester.pump(const Duration(milliseconds: 600));
        await tester.tapAt(const Offset(200, 400));
        await tester.pump();
        await tester.pump(IlFilmatoCheSfuma.dissolvenza);
        await tester.pump(const Duration(milliseconds: 50));
        expect(_opacitaDelDono(tester, m), closeTo(1, 0.01));
      });

      testWidgets('${m.id}: con Riduci Movimento e\' gia\' nel palmo',
          (tester) async {
        await _monta(tester,
            maestro: m,
            lettore: _Finta(),
            identita: _natoIl(DateTime(1990, 7, 5)),
            adesso: DateTime(2026, 10, 20, 19),
            riduci: true);
        expect(_opacitaDelDono(tester, m), closeTo(1, 0.01));
      });
    }

    testWidgets(
        'aura: nessun simbolo nel palmo finche\' non ci sono i '
        'chakra dipinti (GD.03 aperta)', (tester) async {
      await _monta(tester,
          maestro: Maestro.aura,
          lettore: _Finta(fallira: true),
          identita: _natoIl(DateTime(1990, 7, 5)));
      expect(_dono(Maestro.aura), findsNothing);
      await _scatta(tester, 'gd03_aura_dominio_ferma');
    });
  });
}
