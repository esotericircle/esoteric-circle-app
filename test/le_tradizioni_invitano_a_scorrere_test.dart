// ignore_for_file: avoid_print
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/horoscope/astro_tradition.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/horoscope/oroscopo_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cardinale_minimo.dart';

/// **LA RIGA DELLE TRADIZIONI INVITA A SCORRERE.** Il fondatore, 1 ottobre
/// 2026: *"Nella riga di selezione della tipologia di oroscopo, non si
/// capisce che dopo "cinese" ci sono altre tipologie e l'utente non viene
/// automaticamente invitato a scorrere per vedere gli altri. Trova
/// soluzione, magari allungando leggermente le bolle o altra soluzione
/// migliore"*.
///
/// Si misura, sull'Oroscopo montato a 360 e a 390 punti, al carattere
/// normale e a quello massimo (1,3): quanto si vede della prima bolla che il
/// bordo destro taglia (al carattere normale fra un quarto e tre quarti, al
/// massimo almeno un decimo), e che sul bordo da cui la riga continua il
/// cielo sfumi; scorsa la riga fino in fondo, la sfumatura passa a sinistra.
void main() {
  final colpe = <String>[];
  var guardate = 0;

  for (final larghezza in const [360.0, 390.0]) {
    for (final scala in const [1.0, 1.3]) {
      testWidgets('a $larghezza punti alla scala $scala', (tester) async {
        // I sensori del cielo che si inclina non esistono nella prova.
        final messenger = tester.binding.defaultBinaryMessenger;
        messenger.setMockMethodCallHandler(
            const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
            (call) async => null);
        for (final name in const [
          'dev.fluttercommunity.plus/sensors/accelerometer',
          'dev.fluttercommunity.plus/sensors/user_accel',
          'dev.fluttercommunity.plus/sensors/gyroscope',
          'dev.fluttercommunity.plus/sensors/magnetometer',
        ]) {
          messenger.setMockStreamHandler(EventChannel(name),
              MockStreamHandler.inline(onListen: (args, events) {}));
        }
        SharedPreferences.setMockInitialValues({});
        tester.view.physicalSize = Size(larghezza, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => MaestroController()),
            ChangeNotifierProvider(create: (_) => EntitlementService()),
            ChangeNotifierProvider(create: (_) => QualityTierController()),
            ChangeNotifierProvider(create: (_) => ParallaxController()),
            ChangeNotifierProvider(create: (_) => ZodiacController()),
            ChangeNotifierProvider(create: (_) => ProfileController()),
            ChangeNotifierProvider(create: (_) => BirthIdentityController()),
          ],
          child: MaterialApp(
            builder: (ctx, child) => MediaQuery(
              data: MediaQuery.of(ctx).copyWith(
                  disableAnimations: true,
                  textScaler: TextScaler.linear(scala)),
              child: MaestroScope(child: child!),
            ),
            home: OroscopoScreen(
                userSign: Zodiac.gemini, now: DateTime(2026, 10, 1, 10, 0)),
          ),
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));
        // La riga che si vede e' la parte che scorre: la freccia ha il suo
        // posto accanto.
        final riga = tester.getRect(find
            .descendant(
                of: find.byKey(const Key('oroscopo_tradition_tabs')),
                matching: find.byType(Scrollable))
            .first);
        String? tagliata;
        double? quota;
        for (final t in AstroTradition.values) {
          final r =
              tester.getRect(find.byKey(Key('oroscopo_tradition_${t.name}')));
          if (r.right > riga.right + 0.5) {
            tagliata = t.label;
            quota = ((riga.right - r.left) / r.width).clamp(0, 1).toDouble();
            break;
          }
        }
        guardate++;
        print('LE TRADIZIONI INVITANO A SCORRERE: riga '
            '${riga.left.toStringAsFixed(0)}-${riga.right.toStringAsFixed(0)}, '
            'bolle ${[
          for (final t in AstroTradition.values.take(4))
            () {
              final r = tester
                  .getRect(find.byKey(Key('oroscopo_tradition_${t.name}')));
              return '${r.left.toStringAsFixed(0)}+${r.width.toStringAsFixed(0)}';
            }()
        ].join(' ')}');
        final sfumaADestra = find
            .byKey(const Key('oroscopo_tradition_sfuma_dx'))
            .evaluate()
            .isNotEmpty;
        print('LE TRADIZIONI INVITANO A SCORRERE: a $larghezza alla scala '
            '$scala si vede il ${((quota ?? 0) * 100).round()} per cento di '
            '$tagliata; sfumatura a destra $sfumaADestra');
        // Dove la riga lascia spazio, la bolla tagliata si vede a meta'
        // circa; dove le tre aperte la riempiono gia' (360 punti) parla la
        // freccia, e la bolla tagliata non deve mai riempire la riga intera.
        if (quota == null || quota > 0.85 || quota < 0.25) {
          colpe.add('a $larghezza e $scala la bolla tagliata ($tagliata) si '
              'vede per ${((quota ?? 0) * 100).round()} per cento');
        }
        if (!sfumaADestra) {
          colpe.add('a $larghezza e $scala il bordo destro non sfuma');
        }
        // **LA SFUMATURA SI MISURA SUI PIXEL**: sull'ultima colonna della
        // riga che scorre passano il bordo d'oro e il nome della bolla
        // tagliata; sfumata, quella colonna non ha piu' niente di chiaro.
        final fotografia = tester.renderObject<RenderRepaintBoundary>(find
            .ancestor(
                of: find.byKey(const Key('oroscopo_tradition_tabs')),
                matching: find.byType(RepaintBoundary))
            .first);
        final origine = fotografia.localToGlobal(Offset.zero);
        late ByteData dati;
        late int larghezzaFoto;
        await tester.runAsync(() async {
          final img = await fotografia.toImage();
          larghezzaFoto = img.width;
          dati = (await img.toByteData(format: ui.ImageByteFormat.rawRgba))!;
        });
        var chiari = 0;
        final x = (riga.right - 2 - origine.dx).round();
        for (var y = (riga.top - origine.dy).round();
            y < (riga.bottom - origine.dy).round();
            y++) {
          final i = (y * larghezzaFoto + x) * 4;
          if (dati.getUint8(i) > 150 && dati.getUint8(i + 1) > 120) chiari++;
        }
        print('LE TRADIZIONI INVITANO A SCORRERE: pixel chiari sull\'ultima '
            'colonna della riga $chiari');
        if (chiari > 0) {
          colpe.add('a $larghezza e $scala sull\'ultima colonna restano '
              '$chiari pixel chiari: il bordo non sfuma');
        }
        final avanti = find.byKey(const Key('oroscopo_tradition_avanti'));
        if (avanti.evaluate().isEmpty) {
          colpe.add('a $larghezza e $scala manca la freccia che invita');
        } else {
          final prima = tester
              .getRect(find.byKey(const Key('oroscopo_tradition_occidentale')))
              .left;
          await tester.tap(avanti);
          await tester.pump(const Duration(milliseconds: 400));
          final dopo = tester
              .getRect(find.byKey(const Key('oroscopo_tradition_occidentale')))
              .left;
          print('LE TRADIZIONI INVITANO A SCORRERE: il tocco sulla freccia '
              'sposta la riga di ${(prima - dopo).toStringAsFixed(0)} punti');
          if (prima - dopo < 50) {
            colpe.add('a $larghezza e $scala la freccia non fa scorrere');
          }
        }
        // Scorsa fino in fondo: la sfumatura e la freccia passano a
        // sinistra.
        await tester.drag(find.byKey(const Key('oroscopo_tradition_tabs')),
            const Offset(-2000, 0));
        await tester.pump(const Duration(milliseconds: 400));
        bool c(String k) => find.byKey(Key(k)).evaluate().isNotEmpty;
        if (!c('oroscopo_tradition_sfuma_sx') ||
            c('oroscopo_tradition_sfuma_dx') ||
            c('oroscopo_tradition_avanti') ||
            !c('oroscopo_tradition_indietro')) {
          colpe.add('a $larghezza e $scala, in fondo alla riga, la sfumatura '
              'e la freccia non sono a sinistra sola');
        }
      });
    }
  }

  test('i conti', () {
    cardinaleMinimo(guardate, 4, cosa: 'righe guardate');
    print('LE TRADIZIONI INVITANO A SCORRERE: difetti ${colpe.length} su '
        '$guardate righe');
    expect(colpe, isEmpty, reason: colpe.join('\n'));
  });
}
