import 'dart:async';
import 'dart:io';

import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/ricordi/registro_dei_ricordi.dart';
import 'package:esoteric_circle/core/ricordi/ricordo_custodito.dart';
import 'package:esoteric_circle/core/ricordi/vista_dei_ricordi.dart';
import 'package:esoteric_circle/core/ricordi/voce_del_ricordo.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/ricordi/ricordi_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cardinale_minimo.dart';
import 'il_diario_finto.dart';

/// **IL DIARIO COSMICO SUL SERVER. Ordine FE voce 22**, aggiunta del
/// fondatore del 6 ottobre 2026: le prove f), g), h) e k), e le voci 22.10 e
/// 22.15.
///
/// Le prove d) ed e) (il responso entra da se', una stella sola) stanno in
/// `custodisci_e_parlane_test`; la i) (una porta sola per le conversazioni)
/// in `la_porta_delle_conversazioni_e_una_test`; la j) (il cestino) in
/// `chat_initial_message_test`, EA.07, e nelle prove del server.
void main() {
  final adesso = DateTime(2026, 10, 6, 21);

  setUp(() => SharedPreferences.setMockInitialValues({}));

  VoceDelRicordo responso(DateTime quando, String arte,
          {bool stella = false}) =>
      VoceDelRicordo(
        quando: quando,
        arte: arte,
        maestro: 'caligo',
        titolo: 'La tua $arte',
        tipo: TipoDelRicordo.responso,
        riferimento: '${quando.millisecondsSinceEpoch ~/ 60000}.$arte',
        chiaveDelDiario: '${quando.millisecondsSinceEpoch ~/ 60000}.$arte',
        stella: stella,
      );

  Widget scena(Widget figlio, RegistroDeiRicordi registro) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider<RegistroDeiRicordi>.value(value: registro),
        ],
        child: MaterialApp(
          home: MaestroScope(maestro: Maestro.caligo, child: figlio),
        ),
      );

  test(
      'FE.22.13: una conversazione toccata prima di aprire il Diario non '
      'nasconde i mesi del server', () async {
    // Visto sul Realme con la build 2299, 6 ottobre 2026: il Diario su
    // Aura segnava settembre a 0 e il menu' ne mostrava due conversazioni.
    final porta = PortaFintaDelDiario();
    for (final g in [26, 27]) {
      porta.metti(laConversazione(Maestro.aura,
          id: 'c$g', titolo: 'Settembre $g', quando: DateTime(2026, 9, g, 10)));
    }
    final registro = RegistroDeiRicordi(orologio: () => adesso, porta: porta);
    await registro.carica();
    // La persona parla con Aura, e solo dopo apre il Diario.
    registro.toccaLaConversazione(
        maestro: 'aura',
        conversazione: 'c1',
        tema: 'Devo chiedere la promozione?',
        quando: adesso);
    await registro.apri();
    // ignore: avoid_print
    print('FE.22.13 MISURA: conversazioni di Aura a settembre nel Diario '
        '${registro.contoDelMese('2026-09', 'aura')}, sul server 2');
    expect(registro.contoDelMese('2026-09', 'aura'), 2,
        reason: 'il riassunto del server non e\' stato letto: la '
            'conversazione di oggi lo ha coperto');
  });

  test('f) FE.22.8: il giorno eredita la stella, e la perde', () async {
    final porta = PortaFintaDelDiario();
    final registro = RegistroDeiRicordi(orologio: () => adesso, porta: porta);
    // Il mese si legge dal server, come all'apertura del Diario: la stella
    // del giorno si guarda allora sulle righe del mese, non sul riassunto.
    await registro.apri();
    final v = responso(DateTime(2026, 10, 3, 9), 'gettata');
    await registro.annotaIlResponso(
        chiave: v.chiave,
        quando: v.quando,
        arte: v.arte,
        maestro: v.maestro,
        titolo: v.titolo,
        contenuto: const {});
    expect(registro.giornoConStella('2026-10-03'), isFalse);

    await registro.mettiLaStella(registro.tutte.single, true);
    expect(registro.giornoConStella('2026-10-03'), isTrue,
        reason: 'una voce con la stella e il giorno non la porta');
    expect(registro.giornoConStella('2026-10-04'), isFalse,
        reason: 'la stella e\' passata a un giorno che non la contiene');

    await registro.mettiLaStella(registro.tutte.single, false);
    expect(registro.giornoConStella('2026-10-03'), isFalse,
        reason: 'tolta l\'ultima stella, il giorno la tiene ancora');
  });

  testWidgets('f) FE.22.8: la settimana mostra la stella sul suo giorno',
      (tester) async {
    final porta = PortaFintaDelDiario();
    porta.metti(responso(DateTime(2026, 10, 3, 9), 'gettata', stella: true));
    // Nella STESSA settimana del 3: senza stella, e la settimana mostra
    // tutti e due i giorni.
    porta.metti(responso(DateTime(2026, 10, 1, 9), 'oroscopo'));
    final registro = RegistroDeiRicordi(orologio: () => adesso, porta: porta);
    tester.view.physicalSize = const Size(360, 797);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester
        .pumpWidget(scena(RicordiScreen(orologio: () => adesso), registro));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('ricordi_mese_10')));
    await tester.pumpAndSettle();
    final settimana = find.byWidgetPredicate((w) =>
        w.key is ValueKey<String> &&
        (w.key as ValueKey<String>).value.startsWith('ricordi_settimana_'));
    await tester.tap(settimana.first);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('ricordi_giorno_con_stella_2026-10-03')),
        findsOneWidget,
        reason: 'il 3 ottobre ha una voce con la stella e non la mostra');
    expect(find.text('1 momento, 0 traguardi'), findsWidgets,
        reason: 'un momento solo si dice al singolare');
    expect(find.byKey(const Key('ricordi_giorno_2026-10-01')), findsOneWidget,
        reason: 'il primo ottobre non e\' nella settimana aperta: la prova '
            'guarderebbe un giorno che non c\'e\'');
    expect(find.byKey(const Key('ricordi_giorno_con_stella_2026-10-01')),
        findsNothing,
        reason: 'il primo ottobre non ha stelle e ne mostra una');
  });

  test('g) FE.22.10: la riga della persona non va a nessun modello', () {
    // **Si guarda dove la riga puo' andare.** La riga viaggia col nome
    // `nota`: chi la legge o la scrive sta in un elenco chiuso, e nessuno di
    // quei file arriva a un modello (provider dei Maestri, persona, servizi
    // dell'AI). IL ROSSO SI DIMOSTRA leggendo `['nota']` in un file del
    // provider, e la prova lo nomina.
    final ammessi = {
      'lib/core/ricordi/registro_dei_ricordi.dart',
      'lib/features/ricordi/ricordi_screen.dart',
      'lib/services/ricordi/porta_vera_dei_ricordi.dart',
    };
    final lettori = <String>{};
    final file = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .toList();
    cardinaleMinimo(file.length, 500, cosa: 'file di lib');
    final nota = RegExp(r"\[\s*'nota'\s*\]|'nota'\s*:|\bnota:\s*conLaStella");
    for (final f in file) {
      final percorso = f.path.replaceAll('\\', '/');
      final righe = f
          .readAsLinesSync()
          .where((r) => !r.trimLeft().startsWith('//'))
          .join('\n');
      if (nota.hasMatch(righe)) lettori.add(percorso);
    }
    // ignore: avoid_print
    print('FE.22.10 MISURA: file che toccano la riga della persona '
        '${lettori.length}: $lettori');
    // Il cielo per il Maestro ha un suo campo `nota`, che e' un'altra cosa:
    // una frase dell'app sul cielo del giorno, non della persona.
    lettori.remove('lib/core/astro/il_cielo_per_il_maestro.dart');
    expect(lettori.difference(ammessi), isEmpty,
        reason: 'questi file toccano la riga della persona: '
            '${lettori.difference(ammessi)}');
    for (final a in ammessi) {
      final testo = File(a).readAsStringSync();
      for (final vietato in const [
        'services/ai/',
        'maestro_persona',
        'MaestroAiProvider',
        'GenerativeModel',
      ]) {
        expect(testo.contains(vietato), isFalse,
            reason: '$a tocca la riga della persona e porta a un modello '
                '($vietato)');
      }
    }
  });

  testWidgets(
      'FE.22.10: su una voce con la stella c\'e\' la riga, col suo '
      'segnaposto, e si salva una volta', (tester) async {
    final porta = PortaFintaDelDiario();
    final carta = RicordoCustodito(
      quando: DateTime(2026, 10, 3, 9),
      arte: 'gettata',
      maestro: 'caligo',
      titolo: 'La tua gettata',
      testo: 'Uruz ti chiede di non trattenere la forza che hai.',
      comeENato: ComeENato.gesto,
    );
    final voce = responso(carta.quando, 'gettata', stella: true);
    porta.metti(voce, contenuto: {'v': 1, 'c': carta.aMappa()});
    final registro = RegistroDeiRicordi(orologio: () => adesso, porta: porta);
    await registro.carica();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider<RegistroDeiRicordi>.value(value: registro),
      ],
      child: MaterialApp(
        onGenerateRoute: (_) => RicordoApertoScreen.dallaVoce(voce),
      ),
    ));
    await tester.pumpAndSettle();

    final campo = find.byKey(const Key('ricordo_aperto_riga'));
    expect(campo, findsOneWidget,
        reason: 'la voce con la stella non ha la riga');
    expect(find.text('Perché vuoi ricordarlo?'), findsOneWidget,
        reason: 'il segnaposto non e\' quello dell\'ordine');
    await tester.enterText(campo, 'Il giorno in cui ho deciso di partire');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    // Si torna nel campo senza cambiare niente, e si tocca fuori: il tocco
    // fuori arriva solo a un campo col fuoco.
    await tester.tap(campo);
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    final stelle = porta.chiamate.where((c) => c.containsKey('stella'));
    expect([for (final c in stelle) c['nota']],
        ['Il giorno in cui ho deciso di partire'],
        reason: 'la riga si salva una volta: un tocco fuori senza '
            'cambiamenti non manda niente');
  });

  test(
      'FE.22.13: una risposta vuota del server non cancella la copia del '
      'telefono', () async {
    // La porta risponde vuoto anche quando la rete manca. Una voce di tre
    // giorni fa, sul telefono e non ancora rivista dal server, deve restare.
    // IL ROSSO SI DIMOSTRA togliendo il controllo della risposta vuota: la
    // copia del mese si sostituisce con niente.
    final registro = RegistroDeiRicordi(orologio: () => adesso);
    await registro.carica();
    final v = responso(DateTime(2026, 10, 3, 9), 'gettata');
    await registro.segna(v);
    await registro.ripesca('2026-10');
    expect(registro.tutte.map((x) => x.chiave), [v.chiave],
        reason: 'il mese e\' sparito dal telefono dopo una lettura vuota');
  });

  test(
      'FE.22: le settimane di ottobre 2026 sono cinque anche col cambio '
      'd\'ora, e il singolare dice momento', () async {
    // Il 25 ottobre 2026 torna l'ora solare e quel giorno dura 25 ore. Con
    // la settimana contata in blocchi di 24 ore il Diario mostrava "Dal 20
    // al 25" dopo "Dal 19 al 25" (anteprima FE.22). Misura il calendario
    // del fuso dove gira la prova: su una macchina in UTC il difetto non si
    // vede, ed e' dichiarato.
    final registro = RegistroDeiRicordi(orologio: () => adesso);
    await registro.carica();
    final vista = VistaDeiRicordi(registro: registro, orologio: () => adesso)
      ..scendiA(LivelloDeiRicordi.mese, quando: DateTime(2026, 10, 15));
    final chiavi = [for (final s in vista.leSettimaneDelMese) s.chiave];
    // ignore: avoid_print
    print('FE.22 MISURA: settimane di ottobre 2026 ${chiavi.length}: $chiavi');
    expect(chiavi, [
      '2026-09-28..2026-10-04',
      '2026-10-05..2026-10-11',
      '2026-10-12..2026-10-18',
      '2026-10-19..2026-10-25',
      '2026-10-26..2026-11-01',
    ]);
    vista.scendiA(LivelloDeiRicordi.settimana, quando: DateTime(2026, 10, 25));
    expect([for (final g in vista.iGiorniDellaSettimana) g.chiave].last,
        '2026-10-25');
  });

  test('h) FE.22.12: una voce del formato 0 si ridisegna come una dell\'1', () {
    // Il formato 0 e' quello piatto dello scrigno dei custoditi, coi campi in
    // cima; il formato 1 li tiene sotto `c`. Lo stesso responso, scritto nei
    // due modi, deve tornare uguale. IL ROSSO SI DIMOSTRA leggendo sempre
    // `c`: la voce del formato 0 torna nulla.
    final carta = RicordoCustodito(
      quando: DateTime(2025, 3, 2, 18, 30),
      arte: 'stesa',
      maestro: 'medora',
      titolo: 'La tua stesa a tre carte',
      testo: 'Il Matto apre la strada.',
      comeENato: ComeENato.condivisione,
      dati: const {'carte': 'Il Matto,La Papessa,Il Mago'},
    );
    final zero = RicordoCustodito.dallaVoceDelDiario(carta.aMappa());
    final uno = RicordoCustodito.dallaVoceDelDiario(
        {'v': 1, 'k': 'responso', 'c': carta.aMappa()});
    for (final r in [zero, uno]) {
      expect(r, isNotNull);
      expect(r!.chiave, carta.chiave);
      expect(r.testo, carta.testo);
      expect(r.dati, carta.dati);
      expect(r.comeENato, carta.comeENato);
    }
  });

  for (final quante in const [100, 1000]) {
    testWidgets(
        'k) FE.22.18: aprire il Diario con $quante voci costa al massimo '
        'dieci letture', (tester) async {
      final porta = PortaFintaDelDiario();
      for (var i = 0; i < quante; i++) {
        // Sparse sui dieci mesi dell'anno, a ore diverse.
        porta.metti(responso(
            DateTime(2026, 1 + i % 10, 1 + (i ~/ 10) % 28, 8 + i % 12, i % 60),
            'gettata${i % 7}',
            stella: i % 9 == 0));
      }
      final registro = RegistroDeiRicordi(orologio: () => adesso, porta: porta);
      tester.view.physicalSize = const Size(360, 797);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester
          .pumpWidget(scena(RicordiScreen(orologio: () => adesso), registro));
      await tester.pumpAndSettle();

      // ignore: avoid_print
      print('FE.22.18 MISURA: Diario aperto con $quante voci, letture '
          '${porta.letture}, voci sul telefono ${registro.tutte.length}');
      expect(porta.letture, lessThanOrEqualTo(10),
          reason: 'aprire il Diario con $quante voci costa ${porta.letture} '
              'letture. IL ROSSO SI DIMOSTRA leggendo i dodici mesi '
              'all\'apertura');
      expect(porta.letture, 2,
          reason: 'il riassunto dell\'anno e il mese corrente: due letture, '
              'con cento voci come con mille');
      expect(find.byKey(const Key('ricordi_anno')), findsOneWidget);
    });
  }

  testWidgets(
      'FE.22.15: una voce di oltre dodici mesi dice "Sto riprendendo questo '
      'giorno." mentre torna', (tester) async {
    final arriva = Completer<Map<String, Object?>?>();
    final porta = _PortaLenta(arriva.future);
    final voce = responso(DateTime(2025, 6, 1, 9), 'gettata');
    final registro = RegistroDeiRicordi(orologio: () => adesso, porta: porta);
    await registro.carica();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider<RegistroDeiRicordi>.value(value: registro),
      ],
      child: MaterialApp(
        onGenerateRoute: (_) => RicordoApertoScreen.dallaVoce(voce),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Sto riprendendo questo giorno.'), findsOneWidget,
        reason: 'la voce che torna dall\'archivio non dice cosa sta '
            'succedendo');
    arriva.complete({
      'v': 1,
      'c': RicordoCustodito(
        quando: voce.quando,
        arte: 'gettata',
        maestro: 'caligo',
        titolo: 'La tua gettata',
        testo: 'Uruz ti chiede di non trattenere la forza che hai.',
        comeENato: ComeENato.gesto,
      ).aMappa(),
    });
    await tester.pumpAndSettle();
    expect(find.text('Sto riprendendo questo giorno.'), findsNothing);
    expect(find.byKey(const Key('ricordo_aperto_testo')), findsOneWidget,
        reason: 'arrivato il contenuto, la voce non si e\' ridisegnata');
  });
}

/// Una porta il cui contenuto arriva quando la prova lo decide.
class _PortaLenta extends PortaFintaDelDiario {
  _PortaLenta(this._contenuto);
  final Future<Map<String, Object?>?> _contenuto;

  @override
  Future<Map<String, Object?>?> leggiVoce(String chiave) async {
    letture++;
    return _contenuto;
  }
}
