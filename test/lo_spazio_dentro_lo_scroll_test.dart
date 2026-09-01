import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/ask/ask_maestri_screen.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_screen.dart';
import 'package:esoteric_circle/features/maestri/domain_screen.dart';
import 'package:esoteric_circle/features/shell/barra_del_cerchio.dart';
import 'package:esoteric_circle/features/shell/santuario_bottom_bar.dart';
import 'package:esoteric_circle/design_system/components/scena_sopra_la_conversazione.dart';
import 'package:esoteric_circle/features/shell/spazio_della_barra.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'sorgenti_di_lib.dart';

/// LO SPAZIO DELLA BARRA VIVE DENTRO CIO' CHE SCORRE, E IL TITOLO E' D'ORO.
///
/// Decisione di Mauro del 7 agosto 2026, che supera il compromesso della 2156:
/// ovunque il comportamento del dominio, cioe' il contenuto scorre sotto la
/// barra e l'ultimo elemento risale sopra di lei grazie a una coda DENTRO lo
/// scroll. L'eccezione dichiarata e' la chat, il cui fondo e' il campo di
/// scrittura, uno strumento ancorato e non contenuto che scorre.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silenzia() {
    final messenger = binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
      (call) async => null,
    );
    for (final nome in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      messenger.setMockStreamHandler(
        EventChannel(nome),
        MockStreamHandler.inline(onListen: (args, events) {}),
      );
    }
  }

  Future<NavigatorState> monta(WidgetTester tester) async {
    silenzia();
    SharedPreferences.setMockInitialValues({'onboarding.done': true});
    tester.view.physicalSize = const Size(1080, 2391);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
        EsotericCircleApp(conIntro: false, services: AppServices.offline()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    return tester.state<NavigatorState>(find.byType(Navigator).last);
  }

  Future<void> respira(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  Route<void> versoIlConsiglio() => AskMaestriScreen.perLaSintesi(
        starter: Maestro.medora,
        tema: 'una scelta',
        lenti: [
          MaestroLens.strati(
              maestro: Maestro.aura,
              glance: 'respiro',
              reading: 'il corpo sa',
              invite: 'ascolta'),
          MaestroLens.strati(
              maestro: Maestro.caligo,
              glance: 'runa',
              reading: 'il segno parla',
              invite: 'traccia'),
        ],
      );

  /// Lo scorrevole verticale principale della schermata in cima.
  Finder loScorrevole() => find.byWidgetPredicate(
      (w) => w is Scrollable && w.axisDirection == AxisDirection.down);

  group('il contenuto arriva fino in fondo allo schermo', () {
    // La misura: il viewport dello scorrevole tocca il fondo dello schermo,
    // cioe' non esiste piu' uno slot fisso alto quanto la barra che
    // rimpicciolisce la schermata. 2391 pixel a densita' 3 sono 797 punti.
    const fondoSchermo = 797.0;

    testWidgets('nella home', (tester) async {
      await monta(tester);
      final r = tester.getRect(loScorrevole().first);
      expect(r.bottom, greaterThanOrEqualTo(fondoSchermo - 1),
          reason: 'Lo scorrevole della home finisce a ${r.bottom} su '
              '$fondoSchermo: sotto c\'e\' ancora lo slot fisso della barra, '
              'che rimpicciolisce la schermata invece di lasciar scorrere il '
              'contenuto sotto.');
      // E la coda dentro lo scroll c'e', alta quanto lo spazio della barra.
      expect(
          find.descendant(
              of: loScorrevole().first,
              matching: find.byType(SpazioDellaBarraNelloScroll)),
          findsOneWidget,
          reason: 'Manca la coda dentro lo scroll della home: l\'ultimo '
              'scaffale resterebbe sotto la barra.');
    });

    testWidgets('nel Passport', (tester) async {
      await monta(tester);
      await tester.tap(find.byKey(const Key('via_icona_passport')).first);
      await respira(tester);
      final r = tester.getRect(loScorrevole().first);
      expect(r.bottom, greaterThanOrEqualTo(fondoSchermo - 1),
          reason: 'Lo scorrevole del Passport finisce a ${r.bottom}: slot '
              'fisso ancora vivo.');
      // La coda si legge dalla CONFIGURAZIONE degli sliver, non dall'albero:
      // un sliver oltre il viewport non viene costruito finche' non ci si
      // scorre, quindi cercarlo montato direbbe assente anche quando c'e'.
      final slivers =
          tester.widget<CustomScrollView>(find.byType(CustomScrollView).first);
      expect(slivers.slivers.whereType<SliverSpazioDellaBarra>(), isNotEmpty,
          reason: 'Il Passport non ha la coda della barra fra gli sliver.');
    });

    testWidgets('nel dominio', (tester) async {
      final nav = await monta(tester);
      nav.push(DomainScreen.route(
          maestro: Maestro.caligo, services: AppServices.offline()));
      await respira(tester);
      final r = tester.getRect(loScorrevole().first);
      expect(r.bottom, greaterThanOrEqualTo(fondoSchermo - 1));
      // Anche qui: la configurazione, non l'albero, per la ragione scritta
      // sul Passport.
      final slivers =
          tester.widget<CustomScrollView>(find.byType(CustomScrollView).first);
      expect(slivers.slivers.whereType<SliverSpazioDellaBarra>(), isNotEmpty,
          reason: 'Nel dominio manca la coda: l\'ultima carta si fermava '
              'sotto la barra visibile e si leggeva solo a barra ritirata.');
    });

    testWidgets('nel Consiglio', (tester) async {
      final nav = await monta(tester);
      nav.push(versoIlConsiglio());
      await respira(tester);
      final r = tester.getRect(loScorrevole().first);
      expect(r.bottom, greaterThanOrEqualTo(fondoSchermo - 1),
          reason: 'Lo scorrevole del Consiglio finisce a ${r.bottom}: slot '
              'fisso ancora vivo.');
      // Qui la coda e' il padding basso della lista, che include lo spazio
      // della barra: si misura sull'effetto, non sul widget.
      final lista =
          tester.widget<ListView>(find.byKey(const Key('ask_results')));
      final padding = (lista.padding as EdgeInsets?)?.bottom ?? 0;
      expect(padding, greaterThanOrEqualTo(BarraDelCerchio.altezza),
          reason: 'Il fondo della lista del Consiglio e\' di $padding punti: '
              'meno dell\'altezza della barra, l\'ultima carta resta coperta.');
    });

    testWidgets(
        'nella chat l\'eccezione e\' REVOCATA: contenuto fino in '
        'fondo e campo sopra la barra', (tester) async {
      // L'ECCEZIONE DELLA 2158 E' REVOCATA DA MAURO, ordine 2161: anche
      // nella chat il contenuto arriva sotto la barra, e il vetro si legge
      // perche' sotto c'e' qualcosa. Il campo resta ancorato SOPRA la barra
      // come strumento: sotto di lui sta la barra, e sotto la barra scorrono
      // i messaggi, nessuna fascia vuota.
      final nav = await monta(tester);
      nav.push(MaestroChatScreen.route(
          maestro: Maestro.medora, services: AppServices.offline()));
      await respira(tester);
      final regione =
          tester.getRect(find.byType(ScenaSopraLaConversazione).first);
      expect(regione.bottom, greaterThanOrEqualTo(fondoSchermo - 1),
          reason: 'La regione dei messaggi finisce a ${regione.bottom} su '
              '$fondoSchermo: sotto la barra della chat torna una fascia '
              'senza contenuto, cioe\' il rettangolo pieno visto da Mauro.');
      final campo = tester.getRect(find.byType(TextField).first);
      const cimaBarra = fondoSchermo - BarraDelCerchio.altezza;
      expect(campo.bottom, lessThanOrEqualTo(cimaBarra + 1),
          reason: 'Il campo di scrittura finisce a ${campo.bottom}, sotto la '
              'cima della barra ($cimaBarra): uno strumento ancorato sotto la '
              'barra non si puo\' usare.');
    });

    testWidgets(
        'LE CINQUE SCHERMATE, enumerate: sotto la barra sempre '
        'contenuto, la voce giusta accesa, il colore della rotta',
        (tester) async {
      // Una prova sola che le elenca, non una per schermata: se una delle
      // cinque torna a consumare il fondo, o accende la voce sbagliata, o
      // veste il colore di un'altra rotta, cade nominandola. Allargata
      // dall'ordine 2163, voce 6.
      final nav = await monta(tester);
      final colpe = <String>[];

      // La voce accesa si legge dal dato del widget della voce; il colore
      // del fondo dallo scope RISOLTO da cui la barra dipinge.
      String nomeDi(ThemeKey k) => k.maestro?.displayName ?? 'neutro';

      Future<void> guardaLaBarra(String dove,
          {String? vociAccese, ThemeKey? chiaveAttesa}) async {
        // La palette dello scope SFUMA in 850 ms: il colore si legge a
        // transizione finita, come lo vede una persona, non a meta' viraggio.
        await tester.pump(const Duration(milliseconds: 1000));
        for (final id in const [
          'cerchio',
          'medora',
          'caligo',
          'aura',
          'passport'
        ]) {
          final voce = find.byKey(Key('barra_voce_$id'));
          if (voce.evaluate().isEmpty) continue;
          final accesa =
              (tester.widget(voce.first) as dynamic).selected as bool;
          final dovrebbe = vociAccese == id;
          if (accesa != dovrebbe) {
            colpe.add('$dove: la voce $id e\' '
                '${accesa ? 'ACCESA' : 'spenta'} e dovrebbe essere '
                '${dovrebbe ? 'accesa' : 'spenta'}');
          }
        }
        if (chiaveAttesa != null) {
          final barra = find.byType(SantuarioBottomBar);
          if (barra.evaluate().isNotEmpty) {
            final palette = MaestroScope.of(tester.element(barra.first));
            if (palette.key != chiaveAttesa) {
              colpe.add('$dove: il fondo della barra veste '
                  '${nomeDi(palette.key)} invece di '
                  '${nomeDi(chiaveAttesa)}');
            }
          }
        }
      }

      final regioni = <String, double>{};
      regioni['home'] = tester.getRect(loScorrevole().first).bottom;
      await guardaLaBarra('home', vociAccese: 'cerchio');
      await tester.tap(find.byKey(const Key('via_icona_passport')).first);
      await respira(tester);
      regioni['passport'] = tester.getRect(loScorrevole().first).bottom;
      await guardaLaBarra('passport', vociAccese: 'passport');
      nav.push(DomainScreen.route(
          maestro: Maestro.caligo, services: AppServices.offline()));
      await respira(tester);
      regioni['dominio'] = tester.getRect(loScorrevole().first).bottom;
      await guardaLaBarra('dominio di Caligo',
          vociAccese: 'caligo',
          chiaveAttesa: const ThemeKey.of(Maestro.caligo));
      nav.push(MaestroChatScreen.route(
          maestro: Maestro.medora, services: AppServices.offline()));
      await respira(tester);
      regioni['chat'] =
          tester.getRect(find.byType(ScenaSopraLaConversazione).first).bottom;
      // La chat di MEDORA arrivando dal dominio di CALIGO: e' il caso visto
      // da Mauro, il fondo restava rosso.
      await guardaLaBarra('chat di Medora',
          vociAccese: 'medora',
          chiaveAttesa: const ThemeKey.of(Maestro.medora));
      nav.push(versoIlConsiglio());
      await respira(tester);
      regioni['consiglio'] = tester.getRect(loScorrevole().first).bottom;
      // Il Consiglio non e' di nessuno: nessuna voce di Maestro accesa e
      // fondo neutro.
      await guardaLaBarra('consiglio',
          vociAccese: null, chiaveAttesa: const ThemeKey.neutral());

      final colpevoli = regioni.entries
          .where((e) => e.value < fondoSchermo - 1)
          .map((e) => '${e.key} (${e.value})')
          .toList();
      expect(colpevoli, isEmpty,
          reason: 'Sotto la barra torna una fascia senza contenuto in: '
              '$colpevoli. Il vetro si legge solo se sotto scorre qualcosa, '
              'per tutte e cinque senza eccezioni.');
      expect(colpe, isEmpty, reason: colpe.join('\n'));
    });
  });

  group('l\'ultimo elemento risale sopra la barra', () {
    testWidgets('nel dominio, a fine corsa l\'ultima carta sta sopra la barra',
        (tester) async {
      final nav = await monta(tester);
      nav.push(DomainScreen.route(
          maestro: Maestro.caligo, services: AppServices.offline()));
      await respira(tester);
      final scroll = tester.state<ScrollableState>(loScorrevole().first);
      // Si salta alla fine SENZA gesto: un salto non porta il dito, quindi la
      // barra resta in vista, che e' il caso peggiore per la leggibilita'.
      scroll.position.jumpTo(scroll.position.maxScrollExtent);
      await tester.pump();
      final coda = tester.getRect(find.byType(SpazioDellaBarraNelloScroll));
      // La coda sta in fondo al contenuto: se il suo bordo alto e' sopra la
      // cima della barra, tutto cio' che la precede e' sopra la barra.
      const cimaBarra = 797.0 - BarraDelCerchio.altezza;
      expect(coda.top, lessThanOrEqualTo(cimaBarra + 1),
          reason: 'A fine corsa la coda comincia a ${coda.top}, sotto la cima '
              'della barra ($cimaBarra): l\'ultima carta resta coperta anche '
              'scorrendo fino in fondo.');
    });
  });

  group('il titolo della barra', () {
    testWidgets('e\' d\'oro, e l\'oro viene dal punto unico', (tester) async {
      await monta(tester);
      final testo = tester.widget<Text>(find.byKey(const Key('barra_titolo')));
      const palette = MaestroPalette.neutral;
      expect(testo.style?.color, SantuarioBottomBar.coloreDelTitolo(palette),
          reason: 'Il titolo non ha il colore del punto unico: o e\' tornato '
              'grigio, o qualcuno lo ha scritto a mano.');
      expect(testo.style?.color, palette.gold,
          reason: 'Il punto unico non dice piu\' oro: la decisione di Mauro '
              'del 7 agosto 2026 e\' stata ribaltata senza la sua parola.');
    });

    test('nessun altro punto dei sorgenti dipinge il titolo', () {
      // La regola vive in coloreDelTitolo: se una seconda superficie
      // scrivesse ESPLORA con un colore proprio, questa prova la nomina.
      final colpevoli = <String>[];
      for (final f in sorgentiDiLib()) {
        final testo = f.readAsStringSync();
        if (!testo.contains("'ESPLORA'")) continue;
        if (!f.path.endsWith('santuario_bottom_bar.dart')) {
          colpevoli.add(f.path);
        }
      }
      expect(colpevoli, isEmpty,
          reason: 'Il titolo ESPLORA compare anche in: $colpevoli. Il titolo '
              'e il suo colore vivono in santuario_bottom_bar.dart, un punto '
              'solo.');
    });
  });
}
