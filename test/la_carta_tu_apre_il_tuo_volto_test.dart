// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/synastry/collezione_delle_coppie.dart';
import 'package:esoteric_circle/core/synastry/vip_catalog.dart';
import 'package:esoteric_circle/design_system/components/vip_frame.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/synastry/porta_della_sinastria.dart';
import 'package:esoteric_circle/features/synastry/sinastria_gallery_screen.dart';
import 'package:esoteric_circle/features/synastry/sinastria_vip_screen.dart';
import 'package:esoteric_circle/features/synastry/user_photo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// **LA CARTA "TU" APRE IL TUO VOLTO, NON UN VIP.** Ordine ER voce 04, 27
/// settembre 2026.
///
/// Parole del fondatore: *"se faccio click sulla mia carta, mi fa scegliere un
/// vip anziché farmi scegliere un avatar o di inserire una mia foto o
/// immagine"*.
///
/// **La grandezza misurata e' cosa apre il tocco sulla propria carta**, e poi
/// dove arriva l'immagine scelta: nella carta della porta, nel profilo (che
/// e' il posto dove la scelta si scrive) e nel polo della persona nel
/// responso, che e' lo stesso controller da cui la card da condividere prende
/// la foto.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  // Un PNG vero di un punto: con byte finti la cornice proverebbe a
  // decodificarli e la prova cadrebbe per un'altra ragione.
  final foto = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=');

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

  Future<ProfileController> monta(WidgetTester tester,
      {Uint8List? fotoGiaNelProfilo}) async {
    silenzia();
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final profilo = ProfileController();
    if (fotoGiaNelProfilo != null) profilo.setAvatarPhoto(fotoGiaNelProfilo);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider.value(value: profilo),
        ChangeNotifierProvider(create: (_) => CollezioneDelleCoppie()),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: MaestroScope(child: child!),
        ),
        home: PortaDellaSinastria(
          userSign: Zodiac.leo,
          userName: 'Mauro',
          servizioDelleFoto: _FotoFinta(foto),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    return profilo;
  }

  Future<void> aspetta(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Uint8List? fotoNellaCartaTua(WidgetTester tester) => tester
      .widget<VipFramedPortrait>(find.descendant(
          of: find.byKey(const Key('sinastria_carta_tua'), skipOffstage: false),
          matching: find.byType(VipFramedPortrait),
          skipOffstage: false))
      .photo;

  testWidgets(
      'ER.04: il tocco sulla carta "Tu" apre il volto, e la foto scelta '
      'arriva nella carta, nel profilo e nel responso', (tester) async {
    final profilo = await monta(tester);

    await tester.tap(find.byKey(const Key('sinastria_carta_tua')));
    await aspetta(tester);
    final apreUnVip = find.byType(SinastriaGalleryScreen).evaluate().length;
    print('ORDINE ER VOCE 4: tocchi sulla propria carta che aprono la scelta '
        'di un VIP: $apreUnVip');
    expect(apreUnVip, 0,
        reason: 'toccando la propria carta si apre ancora la galleria dei '
            'VIP: e\' il difetto che il fondatore ha visto');
    expect(find.byKey(const Key('il_foglio_del_tuo_volto')), findsOneWidget,
        reason: 'il tocco sulla propria carta non apre la scelta del volto');
    expect(find.byKey(const Key('photo_camera')), findsOneWidget);
    expect(find.byKey(const Key('photo_gallery')), findsOneWidget);
    expect(find.byKey(const Key('photo_clear')), findsOneWidget,
        reason: 'fra le scelte manca l\'avatar');

    await tester.tap(find.byKey(const Key('photo_gallery')));
    await aspetta(tester);
    expect(fotoNellaCartaTua(tester), foto,
        reason: 'la foto scelta non compare nella carta della porta');
    expect(profilo.avatarPhoto, foto,
        reason: 'la foto scelta non e\' finita nel profilo, e le altre '
            'schermate non la vedrebbero');
    expect(find.text('Cambia la tua foto'), findsOneWidget);
    final nellaPorta = fotoNellaCartaTua(tester);

    // **E ARRIVA NEL RESPONSO.** Si sceglie il VIP e si apre il confronto.
    await tester.tap(find.byKey(const Key('sinastria_carta_da_scegliere')));
    await aspetta(tester);
    final carta = find.byKey(Key('vip_${VipCatalog.vips[4].name}'));
    await tester.scrollUntilVisible(carta, 150,
        scrollable: find.byType(Scrollable).last);
    await tester.tap(carta);
    await aspetta(tester);
    await tester.tap(find.byKey(const Key('sinastria_fai_il_confronto')));
    await aspetta(tester);
    expect(find.byType(SinastriaVipScreen), findsOneWidget,
        reason: 'il responso non si e\' aperto');
    final nelResponso = tester
        .widget<VipFramedPortrait>(find.descendant(
            of: find.byKey(const Key('sinastria_pole_user')),
            matching: find.byType(VipFramedPortrait)))
        .photo;
    print('ORDINE ER VOCE 4: foto nella porta ${nellaPorta != null}'
        ', nel profilo ${profilo.hasAvatarPhoto}, nel responso '
        '${nelResponso != null}');
    expect(nelResponso, foto,
        reason: 'la foto scelta nella porta non compare nel responso');
  });

  testWidgets('ER.04: l\'avatar si sceglie, e toglie la foto ovunque',
      (tester) async {
    final profilo = await monta(tester, fotoGiaNelProfilo: foto);
    expect(fotoNellaCartaTua(tester), foto,
        reason: 'la porta non parte dalla foto del profilo');
    await tester.tap(find.byKey(const Key('sinastria_carta_tua')));
    await aspetta(tester);
    expect(find.text('Togli la foto, torna al tuo avatar'), findsOneWidget);
    await tester.tap(find.byKey(const Key('photo_clear')));
    await aspetta(tester);
    expect(fotoNellaCartaTua(tester), isNull,
        reason: 'scelto l\'avatar, la carta porta ancora la foto');
    expect(profilo.hasAvatarPhoto, isFalse,
        reason: 'scelto l\'avatar, il profilo tiene ancora la foto');
  });

  test('ER.04: la card da condividere prende la foto dal volto del responso',
      () {
    final sorgente = File('lib/features/synastry/sinastria_vip_screen.dart')
        .readAsStringSync();
    expect(sorgente, contains('userPhoto: _photo.bytes'),
        reason: 'la card da condividere non riceve piu\' la foto del polo');
    expect(sorgente, contains('IlFoglioDelTuoVolto.scegliERicorda('),
        reason: 'il responso ha un foglio suo, e una foto scelta li\' non '
            'tornerebbe nella porta');
  });
}

class _FotoFinta implements UserPhotoService {
  _FotoFinta(this._bytes);
  final Uint8List _bytes;

  @override
  Future<Uint8List?> pick(UserPhotoSource source) async => _bytes;
}
