import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/tarot/medora_stage.dart';
import 'package:esoteric_circle/features/tarot/stesa_choreography.dart';
import 'package:esoteric_circle/features/tarot/stesa_fan.dart';
import 'package:esoteric_circle/features/tarot/stesa_handoff.dart';
import 'package:esoteric_circle/features/tarot/stesa_tre_carte_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// La coreografia della Stesa: apertura dal bianco, carte che nascono dal
/// cosmo, respiro, taglio, vortice, volo. Qui si controllano gli stati della
/// regia, non l'estetica: che ogni scena esista, che i gesti valgano solo
/// quando devono e che con Riduci Movimento tutto arrivi fermo allo stato
/// finale.
void main() {
  /// Monta la schermata con tutti i controller che il cosmo richiede.
  Future<void> pump(
    WidgetTester tester, {
    bool skipIntro = true,
    bool reduceMotion = false,
    bool revealAll = false,
    double altezza = 2600,
  }) async {
    tester.view.physicalSize = Size(390, altezza);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: reduceMotion),
          child: MaestroScope(child: child!),
        ),
        home: StesaTreCarteScreen(
          seed: 2,
          skipIntro: skipIntro,
          revealAll: revealAll,
        ),
      ),
    ));
    await tester.pump();
  }

  group('Le scene', () {
    test('Solo la scena di riposo accetta i gesti', () {
      for (final s in StesaScene.values) {
        expect(s.accettaGesti, s == StesaScene.riposo,
            reason: 'la scena ${s.name} sbaglia sui gesti');
      }
    });

    test('Ogni scena ha il suo tempo', () {
      for (final d in const [
        StesaTiming.handoff,
        StesaTiming.ingresso,
        StesaTiming.respiro,
        StesaTiming.taglio,
        StesaTiming.mescolamento,
        StesaTiming.volo,
        StesaTiming.flip,
      ]) {
        expect(d.inMilliseconds, greaterThan(0));
        // Nessuna attesa che sembri un blocco.
        expect(d.inMilliseconds, lessThan(4000));
      }
    });
  });

  group('La spirale d\'ingresso', () {
    test('Parte lontana e finisce esattamente nella sua sede', () {
      const centro = Offset(0, -180);
      for (final i in [0, 4, 8]) {
        final inizio =
            SpiralPose.of(index: i, count: 9, t: 0, centro: centro);
        final fine = SpiralPose.of(index: i, count: 9, t: 1, centro: centro);
        // All'inizio e' piccola, trasparente e lontana.
        expect(inizio.scale, lessThan(0.5));
        expect(inizio.offset.distance, greaterThan(50));
        // Alla fine e' nella sua sede, piena e dritta.
        expect(fine.offset, Offset.zero);
        expect(fine.scale, 1);
        expect(fine.opacity, 1);
        expect(fine.angle, 0);
      }
    });

    test('Le carte non partono tutte insieme', () {
      const centro = Offset(0, -180);
      final prima = SpiralPose.of(index: 0, count: 9, t: 0.3, centro: centro);
      final ultima = SpiralPose.of(index: 8, count: 9, t: 0.3, centro: centro);
      // A meta' strada la prima e' gia' avanti, l'ultima e' ancora indietro.
      expect(prima.scale, greaterThan(ultima.scale));
    });
  });

  group('Vortice e taglio', () {
    test('Il vortice torna sempre a casa', () {
      for (final i in [0, 3, 7]) {
        expect(VortexPose.offsetOf(index: i, count: 9, t: 0), Offset.zero);
        expect(VortexPose.offsetOf(index: i, count: 9, t: 1), Offset.zero);
        expect(VortexPose.angleOf(index: i, count: 9, t: 1), 0);
        // A meta' vortice le carte sono davvero in aria.
        expect(VortexPose.offsetOf(index: i, count: 9, t: 0.5).distance,
            greaterThan(10));
      }
    });

    test('Il taglio separa le due meta in versi opposti', () {
      const taglioA = 4;
      final bassa =
          CutPose.offsetOf(index: 1, count: 9, taglioA: taglioA, t: 0.5);
      final alta =
          CutPose.offsetOf(index: 7, count: 9, taglioA: taglioA, t: 0.5);
      expect(bassa.dx.sign, isNot(alta.dx.sign),
          reason: 'le due meta vanno dalla stessa parte');
      // E si ricompongono.
      expect(CutPose.offsetOf(index: 1, count: 9, taglioA: taglioA, t: 1),
          Offset.zero);
    });
  });

  group('Arco sfogliabile', () {
    test('Si costruiscono solo le carte in vista, non tutte e settantotto', () {
      // La finestra si muove, il costo resta lo stesso: e' questo che tiene
      // l'arco fluido con un mazzo intero dentro.
      for (final centro in [0.0, 12.0, 39.0, 77.0]) {
        final visibili = StesaFan.indiciVisibili(centro, 78);
        expect(visibili.length,
            lessThanOrEqualTo(StesaFan.inVista + StesaFan.margine * 2 + 1));
        expect(visibili.length, greaterThan(3));
        // Restano dentro il mazzo, mai indici inventati.
        expect(visibili.first, greaterThanOrEqualTo(0));
        expect(visibili.last, lessThan(78));
      }
    });

    test('Sfogliando si arriva a coprire tutto il mazzo', () {
      // Scorrendo la finestra da un capo all'altro si tocca ogni carta.
      final visti = <int>{};
      for (var c = 0.0; c <= 77; c += 1) {
        visti.addAll(StesaFan.indiciVisibili(c, 78));
      }
      expect(visti.length, 78, reason: 'qualche carta non si raggiunge mai');
    });

    test('Resta curvo, non una striscia piatta', () {
      // Al centro la carta e' alla sua quota, ai lati scende lungo la curva.
      expect(StesaFan.arcoDi(0), 0);
      expect(StesaFan.arcoDi(1), lessThan(StesaFan.arcoDi(0.5)));
      expect(StesaFan.arcoDi(-1), StesaFan.arcoDi(1));
      // E si inclina verso l'esterno, in versi opposti ai due capi.
      expect(StesaFan.inclinazioneDi(1).sign,
          isNot(StesaFan.inclinazioneDi(-1).sign));
    });
  });

  group('Medora in scena', () {
    test('Ogni espressione ha il suo ritratto, col ripiego pronto', () {
      for (final e in MedoraExpression.values) {
        final asset = MedoraStage.assetFor(e);
        expect(asset, isNotEmpty);
        expect(asset, endsWith('.png'));
      }
      // I tre ritratti sono distinti fra loro.
      expect(
          MedoraExpression.values
              .map(MedoraStage.assetFor)
              .toSet()
              .length,
          3);
      // E il ripiego, quello che c'e' gia', resta a disposizione.
      expect(MedoraStage.placeholderAsset,
          'assets/avatars_webp/Medora-1.webp');
    });
  });

  group('La scena nella schermata', () {
    testWidgets('Senza intro il bianco non copre la scena', (tester) async {
      await pump(tester, skipIntro: true);
      await tester.pump(const Duration(milliseconds: 50));
      final velo = tester.widget<HandoffVeil>(
          find.byKey(const Key('stesa_handoff')));
      expect(velo.opacity, 0,
          reason: 'saltando l\'intro il bianco non deve comparire');
    });

    testWidgets('Con l\'intro si parte dal bianco pieno', (tester) async {
      await pump(tester, skipIntro: false);
      final velo = tester.widget<HandoffVeil>(
          find.byKey(const Key('stesa_handoff')));
      expect(velo.opacity, 1, reason: 'la scena non parte dal bianco');
      // E il bianco se ne va da solo.
      await tester.pump(StesaTiming.handoff);
      await tester.pump(const Duration(milliseconds: 50));
      final dopo = tester.widget<HandoffVeil>(
          find.byKey(const Key('stesa_handoff')));
      expect(dopo.opacity, lessThan(0.2));
      // Non si usa pumpAndSettle: a riposo il ventaglio respira per sempre,
      // quindi la scena non si ferma mai davvero. Si avanza a battiti.
      await tester.pump(StesaTiming.ingresso);
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('I gesti del mazzo ci sono sempre', (tester) async {
      await pump(tester, reduceMotion: true);
      await tester.pump();
      // Taglia e Mischia restano in campo anche senza accelerometro: sono il
      // ripiego tattile, non un di piu'.
      expect(find.byKey(const Key('stesa_taglia')), findsOneWidget);
      expect(find.byKey(const Key('stesa_mischia')), findsOneWidget);
      expect(find.byKey(const Key('stesa_suggerimento_gesto')), findsOneWidget);
    });

    testWidgets('Con Riduci Movimento si arriva subito al riposo',
        (tester) async {
      await pump(tester, reduceMotion: true);
      await tester.pump();
      // Nessuna animazione in corso: la scena e' gia' ferma e usabile.
      expect(find.byKey(const Key('stesa_fan')), findsOneWidget);
      final velo = tester.widget<HandoffVeil>(
          find.byKey(const Key('stesa_handoff')));
      expect(velo.opacity, 0);
      // Il ventaglio risponde subito al tocco. Si tocca una carta al centro
      // dell'arco: l'arco parte centrato sul mazzo, quindi la prima carta non
      // e' fra quelle costruite.
      await tester.tap(find.byKey(const Key('stesa_fan_38')));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('Il taglio e il mescolamento tornano al riposo',
        (tester) async {
      await pump(tester, reduceMotion: true);
      await tester.pump();
      await tester.tap(find.byKey(const Key('stesa_taglia')));
      await tester.pump();
      await tester.pump(StesaTiming.taglio);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byKey(const Key('stesa_mischia')));
      await tester.pump();
      await tester.pump(StesaTiming.mescolamento);
      expect(tester.takeException(), isNull);
      // Dopo i due gesti il ventaglio e' ancora li', pronto.
      expect(find.byKey(const Key('stesa_fan')), findsOneWidget);
    });

    testWidgets('Il seme resta deterministico anche con la coreografia',
        (tester) async {
      // La regia non tocca il pescaggio: la stessa stesa esce identica.
      final atteso = TarotSpread.draw(seed: 2);
      await pump(tester, reduceMotion: true, revealAll: true);
      await tester.pump(const Duration(seconds: 2));
      for (final drawn in atteso.cards) {
        expect(find.byKey(Key('stesa_name_${drawn.position.name}')),
            findsOneWidget);
      }
    });
  });

  group('La composizione verticale', () {
    testWidgets('Medora e il ventaglio si vedono insieme, senza scorrere',
        (tester) async {
      await pump(tester, reduceMotion: true);
      await tester.pump();
      // Il ventaglio deve stare dentro la prima schermata, non oltre la
      // piega: se la configurazione lo spingesse giu', per pescare si
      // dovrebbe scorrere oltre un muro di controlli.
      final schermo = tester.view.physicalSize.height /
          tester.view.devicePixelRatio;
      final medora = tester.getRect(find.byKey(const Key('medora_stage')));
      final ventaglio = tester.getRect(find.byKey(const Key('stesa_fan')));
      expect(medora.top, lessThan(schermo));
      expect(ventaglio.bottom, lessThan(schermo),
          reason: 'il ventaglio finisce sotto la piega');
    });

    testWidgets('Gli slot stanno sopra il ventaglio mentre si pesca',
        (tester) async {
      await pump(tester, reduceMotion: true);
      await tester.pump();
      final slots = tester.getRect(find.byKey(const Key('stesa_slots')));
      final ventaglio = tester.getRect(find.byKey(const Key('stesa_fan')));
      // Partenza e arrivo del volo nello stesso campo visivo, con gli slot
      // sopra: cosi' la carta non vola mai verso uno slot fuori schermo.
      expect(slots.bottom, lessThanOrEqualTo(ventaglio.top + 1),
          reason: 'gli slot non stanno sopra il ventaglio');
      final schermo = tester.view.physicalSize.height /
          tester.view.devicePixelRatio;
      expect(slots.top, greaterThanOrEqualTo(0));
      expect(ventaglio.bottom - slots.top, lessThan(schermo),
          reason: 'slot e ventaglio non stanno nello stesso campo visivo');
    });

    testWidgets('Mentre si pesca Medora e piu raccolta', (tester) async {
      await pump(tester, reduceMotion: true);
      await tester.pump();
      final pescando =
          tester.widget<MedoraStage>(find.byType(MedoraStage));
      // Ritaglio piu' stretto e scena piu' bassa: il ventaglio che Medora
      // tiene in mano resta un dettaglio del ritratto, non un secondo invito
      // in gara col ventaglio interattivo.
      expect(pescando.bustoFactor, lessThan(MedoraStage.bustoPieno));
      expect(pescando.height, lessThan(300));
    });

    testWidgets('A stesa fatta Medora torna in primo piano', (tester) async {
      // Test a se': rimontare nello stesso test riuserebbe lo State, e
      // revealAll si legge una volta sola alla nascita.
      await pump(tester, reduceMotion: true, revealAll: true);
      await tester.pump();
      final completa = tester.widget<MedoraStage>(find.byType(MedoraStage));
      expect(completa.bustoFactor, MedoraStage.bustoPieno);
      expect(completa.height, 300);
    });


    testWidgets('Il ventaglio resta a portata anche dopo il secondo pescaggio',
        (tester) async {
      // Su uno schermo di telefono vero, non su una finestra alta da test:
      // e' li' che il ventaglio rischia di scendere fuori campo.
      await pump(tester, reduceMotion: true, altezza: 844);
      await tester.pump();
      final schermo =
          tester.view.physicalSize.height / tester.view.devicePixelRatio;

      // Si pescano due carte: sotto gli slot si accumulano nome e sintesi, e
      // il ventaglio rischia di scendere fuori campo proprio mentre serve.
      for (final indice in [38, 39]) {
        await tester.tap(find.byKey(Key('stesa_fan_$indice')));
        await tester.pump();
        await tester.pump(StesaTiming.volo);
        await tester.pump(const Duration(milliseconds: 100));
      }

      final ventaglio = tester.getRect(find.byKey(const Key('stesa_fan')));
      expect(ventaglio.top, lessThan(schermo),
          reason: 'dopo due pescaggi il ventaglio comincia fuori campo');
      expect(ventaglio.bottom, lessThan(schermo),
          reason: 'dopo due pescaggi il ventaglio finisce fuori campo');
    });

    testWidgets('La configurazione parte richiusa', (tester) async {
      await pump(tester, reduceMotion: true);
      await tester.pump();
      expect(find.byKey(const Key('stesa_setup_riga')), findsOneWidget);
      expect(find.byKey(const Key('stesa_setup')), findsNothing);
      // Al tocco si apre, senza perdere nulla.
      await tester.tap(find.byKey(const Key('stesa_setup_riga')));
      await tester.pump();
      expect(find.byKey(const Key('stesa_setup')), findsOneWidget);
      expect(find.byKey(const Key('stesa_topic')), findsOneWidget);
    });
  });
}
