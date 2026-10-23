import 'dart:io';

import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/tarot/il_tavolo_di_medora.dart';
import 'package:esoteric_circle/features/tarot/stesa_tre_carte_screen.dart';
import 'package:esoteric_circle/features/tarot/tarot_selectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// **NESSUNA FASCIA FRA LA BARRA DEL TITOLO E LA SCENA DELLA STESA.** Il
/// fondatore, dal telefono, sulla 2309 e di nuovo sulla 2310: *"sopra la
/// testa di Medora c'e' una barra azzurra piena da eliminare. Sopra c'e' la
/// giusta barra del titolo semitrasparente"*.
///
/// Misurata sul Realme con la 2310: dal pixel 392 al 417 (otto punti) una
/// fascia piatta, piu' chiara della barra. Era il cosmo dello sfondo, senza
/// il velo della barra, nel margine `SpacingTokens.xs` che la lista lasciava
/// fra la barra e la scena (PROVENIENZA: ordine FS, commit dc678e6b). La
/// correzione della 2310 (commit d22d4c8b, la tecnica di posizionamento del
/// filmato) misurava un'altra cosa e non l'ha toccata.
///
/// Si misura la grandezza che il fondatore vede: dove l'immagine della scena
/// diventa piena rispetto al bordo basso della barra. Deve coincidere: la
/// scena sale sotto il velo esattamente quanto la sua sfumatura in alto, e
/// la testa di Medora, che comincia dopo la sfumatura, resta intera.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> caricaCaratteri() async {
    for (final f in const [
      ['Cinzel', 'assets/fonts/Cinzel-variable.ttf'],
      ['EBGaramond', 'assets/fonts/EBGaramond-variable.ttf'],
    ]) {
      final loader = FontLoader(f[0]);
      loader.addFont(
          Future.value(ByteData.view(File(f[1]).readAsBytesSync().buffer)));
      await loader.load();
    }
  }

  // Il Realme del fondatore (360 per 800) e un telefono piu' largo.
  for (final schermo in const [Size(360, 800), Size(390, 844)]) {
    testWidgets(
        'a ${schermo.width.toInt()} punti l\'immagine e\' piena dal bordo '
        'della barra, senza fascia', (tester) async {
      binding.defaultBinaryMessenger.setMockMethodCallHandler(
          const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
          (call) async => null);
      await caricaCaratteri();
      tester.view.physicalSize = schermo;
      tester.view.devicePixelRatio = 1.0;
      // La barra di stato del telefono sopra la barra del titolo.
      tester.view.padding = const FakeViewPadding(top: 24);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
        ],
        child: const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: MaestroScope(
            child: StesaTreCarteScreen(
              seed: 2,
              skipIntro: true,
              topic: TarotTopic.bivio,
            ),
          ),
        ),
      ));
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 300));
      }

      final barra = tester.getRect(find.byType(AppBar)).bottom;
      final scena = tester.getRect(find.byKey(const Key('stesa_slots'))).top;
      final s = GeometriaDelTavolo.scala(schermo.width);
      final pienaDa = scena + GeometriaDelTavolo.sfumaturaInAlto * s;
      expect(pienaDa, closeTo(barra, 0.5),
          reason: 'l\'immagine della scena e\' piena da $pienaDa, la barra '
              'finisce a $barra: in mezzo ci sono '
              '${(pienaDa - barra).toStringAsFixed(1)} punti di cosmo senza '
              'velo, la fascia azzurra');
      // **IL VIDEO CONTINUA SOTTO LA BARRA**, ordine GC voce GC.02, 22
      // ottobre 2026. Il fondatore: *"La barra in alto del titolo deve
      // essere semitrasparente in modo da fare vedere il video animazione
      // sotto"*. L'immagine e il filmato della scena si dipingono dal bordo
      // alto dello schermo, sotto il velo della barra, e la barra resta
      // semitrasparente (R12). Cade se la scena torna a cominciare sotto la
      // barra o se la barra torna piena.
      final dipinta =
          tester.getRect(find.byKey(const Key('tavolo_sfumatura'))).top;
      expect(dipinta, lessThanOrEqualTo(0.5),
          reason: 'la scena comincia a $dipinta, sotto la barra: il video '
              'non passa sotto il velo');
      final velo =
          tester.widget<AppBar>(find.byType(AppBar)).backgroundColor!.a;
      expect(velo, lessThanOrEqualTo(0.6),
          reason: 'la barra del titolo della Stesa e\' tornata piena');
      // La testa di Medora nel filmato comincia otto pixel e mezzo sotto il
      // taglio: sotto la barra, intera.
      expect(scena + 8.5 * s, greaterThanOrEqualTo(barra),
          reason: 'la testa di Medora finisce sotto la barra del titolo');

      // **IL PANNELLO SFIORA IL BORDO BASSO DEL TAVOLO.** Il fondatore, 14
      // ottobre 2026: "Devi far salire la bolla 'scegli la tua stesa' fino a
      // sfiorare il bordo basso del tavolo e tutto quello che sta sotto alla
      // bolla deve risalire con essa". Il bordo basso del piano sullo
      // schermo, e il bordo alto del pannello: coincidono.
      final pianoFinisce = scena +
          (GeometriaDelTavolo.bordoBassoDelPiano -
                  GeometriaDelTavolo.taglioInAlto) *
              s;
      final pannello = tester.getRect(find.byType(TarotSetupPanel)).top;
      expect(pannello, closeTo(pianoFinisce, 0.5),
          reason: 'fra il bordo basso del tavolo ($pianoFinisce) e il '
              'pannello ($pannello) ci sono '
              '${(pannello - pianoFinisce).toStringAsFixed(1)} punti');
      // E sotto il bordo il tavolo non si vede piu': niente drappo dietro
      // il pannello velato.
      expect(GeometriaDelTavolo.fineDellaSfumatura,
          lessThanOrEqualTo(GeometriaDelTavolo.bordoBassoDelPiano),
          reason: 'l\'immagine del tavolo continua sotto il bordo basso, '
              'dietro il pannello');
    });
  }
}
