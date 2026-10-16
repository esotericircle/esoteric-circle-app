import 'dart:convert';

import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/face/face_trait.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/aura/face/face_constellation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **LA SOGLIA CONOSCE I DUE MOMENTI.** Ordine CR voce 08, 6 settembre 2026.
///
/// **Parole dell'ordine**: *"Oggi la Costellazione del Viso si fa una volta: i
/// tratti non cambiano, quindi non c'e' ragione di tornare. Con CR.07 la
/// ragione nasce da sola: i tratti restano, l'espressione cambia ogni
/// giorno"*, e la funzione va ripensata *"in due momenti"*.
///
/// **COSA MISURA QUESTA GUARDIA, e cosa no.** Misura che la soglia offra la
/// porta giusta al momento giusto: una sola porta a chi non ha mai fatto la
/// lettura piena, due a chi ce l'ha. **Non misura la scansione breve davanti a
/// una fotocamera**, perche' in prova la fotocamera non esiste: quella vive
/// nella guardia `il_ritorno_non_e_una_porta_di_servizio_test.dart`, che
/// interroga la macchina pura, e la sua resa a video resta da verificare su un
/// telefono.
void main() {
  Widget host() => MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (_) =>
                  MaestroController(initial: const ThemeKey.of(Maestro.aura))),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => EntitlementService()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
        ],
        child: const MaterialApp(
          home: MaestroScope(child: FaceConstellationScreen()),
        ),
      );

  Future<void> passo(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  /// Una lettura piena gia' fatta, scritta dove la schermata la cerca.
  void conUnaLetturaGiaFatta() {
    final esito = {
      'quando': DateTime(2026, 9, 1).toIso8601String(),
      'letture': [
        for (final c in FaceCategory.values)
          {
            'tratto': FaceTrait.perCategoria(c).first.name,
            'marcatezza': 0.5,
          },
      ],
    };
    SharedPreferences.setMockInitialValues({
      'viso.storico': [jsonEncode(esito)],
    });
  }

  testWidgets('senza una prima volta la soglia offre una porta sola',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(430, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(host());
    await passo(tester);

    expect(find.byKey(const Key('face_start')), findsOneWidget);
    expect(find.byKey(const Key('face_return_start')), findsNothing,
        reason: 'a chi non ha mai fatto la lettura piena viene offerto un '
            'ritorno: un ritorno senza una prima volta non ha niente a cui '
            'tornare, e la propria linea sarebbe vuota');
    expect(find.text('Inquadra il tuo volto'), findsOneWidget,
        reason: 'la porta unica non invita alla prima lettura');
  });

  testWidgets('con una lettura gia\' fatta la soglia offre la porta unica',
      (tester) async {
    conUnaLetturaGiaFatta();
    tester.view.physicalSize = const Size(430, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(host());
    await passo(tester);

    // **IL RITORNO NON ESISTE PIU', E LA GUARDIA LO PRETENDE ASSENTE.**
    // Ordine CX, 8 settembre 2026, parole del fondatore: *"Devi eliminare
    // ovunque leggi il tuo momento: prima di tutto e' difficilissimo e poi non
    // serve a niente. Se l'utente vuole rifare la scansione, la rifa'
    // completa."*
    //
    // Questa guardia pretendeva la SUA PRESENZA, ed era giusta finche' la
    // funzione era voluta. **Una guardia che sorveglia una funzione tolta non
    // si cancella: si rovescia**, altrimenti nessuno si accorgerebbe se
    // qualcuno la rimettesse per abitudine.
    expect(find.byKey(const Key('face_return_start')), findsNothing,
        reason: 'il pulsante del ritorno e\' tornato: chiedeva una posa '
            'difficile da tenere per dare meno di quello che la scansione da\' '
            'in trenta secondi');
    expect(find.byKey(const Key('face_start')), findsOneWidget,
        reason: 'la lettura piena sparisce quando ne esiste gia\' una: '
            'l\'ordine dice che si puo\' rifare quando la persona vuole');
    expect(find.text('Rifai la lettura piena'), findsOneWidget,
        reason: 'la seconda porta continua a invitare come se fosse la prima '
            'volta, e chi legge non capisce la differenza fra le due');
  });
}
