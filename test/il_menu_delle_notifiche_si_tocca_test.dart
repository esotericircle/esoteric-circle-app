import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/rituals/avvisi_del_rito.dart';
import 'package:esoteric_circle/core/rituals/daily_elements.dart';
import 'package:esoteric_circle/core/rituals/scelta_degli_avvisi.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/account/notifiche_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// IL MENU' DELLE NOTIFICHE SI TOCCA, E FA QUELLO CHE DICE.
/// Ordine BC voce 05.
///
/// **Parole del fondatore**: "sara' proprio l'utente che potra' gestire e
/// attivare o disattivare i singoli orari delle notifiche nel menu'
/// notifiche."
///
/// Le regole degli avvisi, cioe' quante partono e a che ora, si misurano in
/// `test/cinque_avvisi_uno_per_dono_test.dart`. Qui si guarda **cio' che la
/// persona vede e tocca**: cinque righe con la loro ora, cinque interruttori,
/// e un tocco che cambia davvero la scelta invece di muovere una levetta.
/// Una porta che dice di si a tutto: serve perche senza permesso gli
/// interruttori restano spenti apposta, e la prova guarderebbe cinque levette
/// ferme credendo di guardare cinque scelte.
class _AvvisiCheDicono extends ServizioAvvisi {
  @override
  bool get disponibile => true;
  @override
  Future<bool> chiediPermesso() async => true;
  @override
  Future<bool> permessoConcesso() async => true;
  @override
  Future<void> programma({
    required int id,
    required DateTime quando,
    required String titolo,
    required String testo,
    String canale = 'rito_alba',
    String carico = '',
  }) async {}
  @override
  Future<void> annulla(int id) async {}
  @override
  Future<List<int>> inAttesa() async => const [];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<SceltaDegliAvvisi> apri(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(const {});
    final scelta = SceltaDegliAvvisi();
    await scelta.carica();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => BirthIdentityController()),
        ChangeNotifierProvider<SceltaDegliAvvisi>.value(value: scelta),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MaestroScope(child: child!),
        home: NotificheScreen(avvisi: _AvvisiCheDicono()),
      ),
    ));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    return scelta;
  }

  testWidgets('BC.05: ci sono cinque righe, ognuna con la sua ora',
      (tester) async {
    await apri(tester);
    final ore = <String>[];
    for (final d in DailyElement.values) {
      final riga = find.byKey(Key('notifiche_dono_${d.name}'));
      expect(riga, findsOneWidget,
          reason: 'manca la riga del Dono ${d.name}');
      final ora = tester
          .widget<Text>(find.byKey(Key('notifiche_ora_${d.name}')));
      ore.add('${d.shortLabel} ${ora.data}');
      expect(ora.data, AvvisiDelRito.oraDetta(d),
          reason: 'la riga di ${d.name} dichiara un ora che non e la sua');
    }
    // ignore: avoid_print
    print('ORDINE BC VOCE 05: nel menu si leggono $ore');
    expect(find.byType(Switch), findsNWidgets(5),
        reason: 'gli interruttori non sono cinque');
  });

  testWidgets('BC.05: e toccare un interruttore cambia davvero la scelta',
      (tester) async {
    final scelta = await apri(tester);
    // **Di partenza chiamano tutti e cinque**, per decisione del fondatore:
    // quindi il tocco che conta e' quello che SPEGNE. Toccare per accendere
    // cio' che e' gia' acceso non direbbe niente.
    expect(scelta.chiama(DailyElement.night), isTrue);

    await tester.ensureVisible(
        find.byKey(const Key('notifiche_interruttore_night')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('notifiche_interruttore_night')));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    // ignore: avoid_print
    print('ORDINE BC VOCE 05: dopo il tocco sul Sigillo del Sogno, chiamano '
        '${scelta.quelliCheChiamano.map((d) => d.name).toList()}');
    expect(scelta.chiama(DailyElement.night), isFalse,
        reason: 'la levetta si e mossa e la scelta e rimasta com era: e un '
            'interruttore che non spegne niente');

    // **E GLI ALTRI NON SI TOCCANO**: il fondatore ha chiesto che ognuno si
    // gestisca per conto suo.
    expect(scelta.chiama(DailyElement.breath), isTrue,
        reason: 'spegnendo un Dono se ne e spento un altro');
    expect(scelta.chiama(DailyElement.dawn), isTrue,
        reason: 'spegnendo un Dono se ne e spento un altro');
  });

  testWidgets('BC.05 coda: e l ora si tocca e si cambia', (tester) async {
    // **Richiesta del fondatore, arrivata dopo l ordine**: "nel menu
    // notifiche, l utente deve poter cambiare anche l orario di ogni
    // notifica."
    final scelta = await apri(tester);
    expect(scelta.minutiDi(DailyElement.oracle),
        DailyElement.oracle.anchorMinutes);

    await tester.ensureVisible(
        find.byKey(const Key('notifiche_tocco_ora_oracle')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('notifiche_tocco_ora_oracle')));
    // **PUMP RIPETUTI E NON `pumpAndSettle`**: il cielo di questa schermata
    // pulsa senza fine, e aspettare che si fermi vuol dire aspettare per
    // sempre. E' la stessa ragione per cui tutto il progetto lo evita sulle
    // scene animate.
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }

    // **L OROLOGIO DI SISTEMA SI E APERTO**, che e la cosa che si puo
    // guardare senza dipendere da come lo si usa: dentro quel foglio ci sono
    // i comandi di Material, e provarli uno per uno vorrebbe dire provare
    // Flutter invece della nostra schermata.
    expect(find.byType(TimePickerDialog), findsOneWidget,
        reason: 'toccando l ora non si apre nessun orologio: l ora e rimasta '
            'un etichetta');
    // ignore: avoid_print
    print('ORDINE BC VOCE 05 coda: toccando l ora dell Arcano si apre '
        'l orologio di sistema');

    // E si esce senza cambiare niente: chi apre per sbaglio non deve
    // ritrovarsi un ora nuova.
    await tester.tap(find.text('Lascia com\'è'));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    expect(scelta.minutiDi(DailyElement.oracle),
        DailyElement.oracle.anchorMinutes,
        reason: 'chiudendo l orologio senza confermare l ora e cambiata lo '
            'stesso');
  });

  testWidgets('BC.05 coda: e l ora mostrata e quella scelta', (tester) async {
    // **La riga deve dire l ora VERA, non quella di casa.** Se mostrasse
    // sempre l ancora, chi ha spostato l Arcano alle nove leggerebbe le
    // tredici e crederebbe che il cambiamento non abbia funzionato.
    SharedPreferences.setMockInitialValues({
      SceltaDegliAvvisi.chiaveDellOraDi(DailyElement.oracle): 9 * 60 + 5,
    });
    final scelta = SceltaDegliAvvisi();
    await scelta.carica();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => BirthIdentityController()),
        ChangeNotifierProvider<SceltaDegliAvvisi>.value(value: scelta),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MaestroScope(child: child!),
        home: NotificheScreen(avvisi: _AvvisiCheDicono()),
      ),
    ));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    final mostrata =
        tester.widget<Text>(find.byKey(const Key('notifiche_ora_oracle')));
    // ignore: avoid_print
    print('ORDINE BC VOCE 05 coda: con l Arcano spostato, la riga mostra '
        '"${mostrata.data}"');
    expect(mostrata.data, '09:05',
        reason: 'la riga mostra l ora di casa invece di quella scelta');
  });

  testWidgets('BC.05: e spegnere quello acceso lo spegne', (tester) async {
    // **LA CONTROPROVA.** Un interruttore che sa solo accendere non e' un
    // interruttore: il fondatore ha chiesto di poter "attivare O
    // DISATTIVARE" i singoli orari.
    final scelta = await apri(tester);
    expect(scelta.chiama(DailyElement.dawn), isTrue);
    await tester.ensureVisible(
        find.byKey(const Key('notifiche_interruttore_dawn')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('notifiche_interruttore_dawn')));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    // ignore: avoid_print
    print('ORDINE BC VOCE 05: spenta l Alba, chiamano '
        '${scelta.quelliCheChiamano.map((d) => d.name).toList()}');
    expect(scelta.chiama(DailyElement.dawn), isFalse,
        reason: 'l interruttore acceso non si spegne');
  });
}
