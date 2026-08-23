import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/archetypes/archetype.dart';
import 'package:esoteric_circle/core/archetypes/archetype_history.dart';
import 'package:esoteric_circle/core/archetypes/archetype_scoring.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// L'ARCHETIPO NON RESTA COL LUCCHETTO DOPO IL TEST.
///
/// **Il difetto, e la sua causa vera.** Il fondatore ha completato il Test
/// Archetipo, e nel Passaporto la sua figura profonda era ancora grigia e
/// bloccata. Non era un errore di disegno: la tessera era una riga di un elenco
/// FISSO di cose "in arrivo", e non guardava da nessuna parte. Fra cio' che la
/// persona aveva fatto e cio' che la schermata leggeva non c'era nessun
/// collegamento, perche' lo storico del Test viveva dentro la schermata del
/// Test e da nessun'altra parte: chi non era quella schermata non poteva
/// saperne niente.
///
/// **Percio' la prova monta l'app dall'AVVIO VERO.** Un difetto di
/// collegamento fra due pezzi non si vede montandone uno solo: il widget del
/// Passaporto in isolamento, con lo storico che gli si passa a mano, sarebbe
/// passato anche prima, perche' il pezzo che manca e' proprio la strada che
/// porta il dato fin li'. Qui si scrive l'esito nell'archivio come lo scrive il
/// Test, si accende l'app da zero e si va a guardare.
void main() {
  /// L'esito di un Test Archetipo gia' fatto, come sta nell'archivio.
  Future<void> conUnTestFatto(Archetype dominante) async {
    final storico = ArchetypeHistory(clock: () => DateTime(2026, 8, 3, 10));
    await storico.carica();
    await storico.registra(ArchetypeProfile(
      percentuali: {
        for (final a in Archetype.values) a: a == dominante ? 40.0 : 5.0
      },
      dominante: dominante,
    ));
  }

  void silenzia(WidgetTester tester) {
    final messenger = tester.binding.defaultBinaryMessenger;
    for (final name in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      messenger.setMockStreamHandler(
        EventChannel(name),
        MockStreamHandler.inline(onListen: (args, events) {}),
      );
    }
  }

  Future<void> apriIlPassaporto(WidgetTester tester) async {
    silenzia(tester);
    // Finestra da telefono, ordine BD voce 02: sul default 800x600 la barra
    // e la scena degenerano e i tocchi muoiono su geometrie che nessun
    // telefono ha. Vedi la nota estesa in chat_header_test.
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
        EsotericCircleApp(conIntro: false, services: AppServices.offline()));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 400));
    }
    await tester.tap(find.text('Passport').last);
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 400));
    }
  }

  testWidgets('Col Test fatto, il Passaporto mostra la sua figura',
      (tester) async {
    // L'app parte dal Risveglio a chi non l'ha ancora fatto: qui si entra in
    // un'app gia' abitata, che e' il caso del fondatore.
    SharedPreferences.setMockInitialValues(const {'onboarding.done': true});
    await conUnTestFatto(Archetype.creatore);
    await apriIlPassaporto(tester);

    final tessera = find.byKey(const Key('passport_archetipo'));
    await tester.scrollUntilVisible(tessera, 300,
        scrollable: find.byType(Scrollable).last);
    expect(tessera, findsOneWidget,
        reason: 'il Test e\' stato fatto e il Passaporto non lo sa: fra cio\' '
            'che la persona ha fatto e cio\' che la schermata legge non c\'e\' '
            'nessun collegamento');
    // E dice QUALE archetipo, non solo che ce n'e' uno.
    expect(
        find.descendant(
            of: tessera, matching: find.byKey(const Key('passport_archetipo_nome'))),
        findsOneWidget);
    expect(find.textContaining(Archetype.creatore.conArticolo), findsWidgets,
        reason: 'la tessera non nomina la figura trovata dal Test');
  });

  testWidgets('Senza Test resta dietro il velo, ma dice cosa fare',
      (tester) async {
    // IL CONTROLLO NEGATIVO. Senza, una tessera sempre viva passerebbe la
    // prova qui sopra senza guardare niente.
    // L'app parte dal Risveglio a chi non l'ha ancora fatto: qui si entra in
    // un'app gia' abitata, che e' il caso del fondatore.
    SharedPreferences.setMockInitialValues(const {'onboarding.done': true});
    await apriIlPassaporto(tester);

    expect(find.byKey(const Key('passport_archetipo')), findsNothing,
        reason: 'la tessera e\' viva a chi il Test non l\'ha mai fatto');
    // E non promette un futuro: dice che si puo' fare adesso. Promettere come
    // futuro qualcosa che l'app fa gia' e' peggio di non prometterlo.
    // **L'invito ha cambiato parole con l'ordine BC voce 03**: "Fai il Test
    // Archetipo" prometteva senza portare, adesso la tessera porta davvero e
    // dice "Tocca per fare il Test Archetipo". La prova segue le parole vere.
    final invito = find.textContaining('Tocca per fare il Test Archetipo');
    // Sulla finestra da telefono l'invito puo' essere gia' in vista: si
    // scorre solo se serve, e sull'ULTIMO Scrollable, perche' il Passaporto
    // e' una rotta spinta sopra la home e il primo scorrevole e' della home
    // coperta.
    if (invito.evaluate().isEmpty) {
      await tester.scrollUntilVisible(invito, 300,
          scrollable: find.byType(Scrollable).last);
    }
    expect(invito, findsOneWidget);
  });
}
