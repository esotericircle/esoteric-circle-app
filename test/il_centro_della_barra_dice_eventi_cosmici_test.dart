import 'dart:io';

import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/features/calendario/calendario_degli_eventi_screen.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:esoteric_circle/features/sigilli/celebrazione.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// IL CENTRO DELLA BARRA DICE "EVENTI COSMICI". Ordine AO voce 01.
///
/// **Cosa c'era prima, e perche' cambia.** Il centro mostrava il PROSSIMO
/// EVENTO col conto alla rovescia, da chiusa una riga e da aperta tre. E'
/// una notizia che cambia da sola, e in una fascia alta trenta punti si
/// leggeva a fatica: Mauro, dal collaudo della 2182, ha deciso che al centro
/// ci sta una PORTA e non un bollettino. La scritta e' sempre la stessa,
/// "Eventi Cosmici", e il conto alla rovescia torna a casa sua, il
/// Calendario, che lo mostra gia' per ogni evento.
///
/// **Cosa NON cambia, ed e' scritto qui perche' nessuno lo tocchi per
/// sbaglio**: il motore della prossima data, `ProssimiEventi` dell'ordine AN
/// voce 01, resta intero e al suo posto. Serve al Calendario, ai promemoria
/// e ai Maestri: toglierlo perche' la barra non lo usa piu' sarebbe buttare
/// il calcolo insieme alla sua vetrina.
///
/// **Perche' la scritta si prova a video e non nel sorgente.** Una prova che
/// cercasse la stringa dentro `barra_dell_identita.dart` passerebbe anche con
/// il testo nascosto sotto un altro widget o dentro un ramo mai preso. Qui si
/// monta l'app vera, si legge cio' che c'e' a schermo e si tocca.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silenzia() {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (c) async => null);
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

  Future<void> apri(WidgetTester tester) async {
    silenzia();
    SharedPreferences.setMockInitialValues(
        const {'onboarding.done': true, 'santuario.greeted': true});
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(360, 797);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
        EsotericCircleApp(conIntro: false, services: AppServices.offline()));
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  final barra = find.byKey(const Key('barra_dell_identita'));
  final centro = find.byKey(const Key('barra_eventi_cosmici'));

  testWidgets('a barra chiusa il centro dice Eventi Cosmici', (tester) async {
    await apri(tester);
    expect(centro, findsOneWidget,
        reason: 'il centro della barra non porta la porta degli Eventi '
            'Cosmici');
    final scritta = tester.widget<Text>(
        find.descendant(of: centro, matching: find.byType(Text)));
    // ignore: avoid_print
    print('ORDINE AO VOCE 01: a barra chiusa si legge "${scritta.data}"');
    expect(scritta.data, 'Eventi Cosmici',
        reason: 'al centro si legge "${scritta.data}" invece di "Eventi '
            'Cosmici"');
  });

  testWidgets('anche da aperta dice la stessa cosa', (tester) async {
    await apri(tester);
    await tester.tap(barra, warnIfMissed: false);
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    final scritte = tester
        .widgetList<Text>(
            find.descendant(of: centro, matching: find.byType(Text)))
        .map((t) => t.data)
        .toList();
    // ignore: avoid_print
    print('ORDINE AO VOCE 01: a barra aperta si legge $scritte');
    expect(scritte, ['Eventi Cosmici'],
        reason: 'da aperta il centro dice altro: $scritte. La scritta e\' '
            'SEMPRE quella, chiusa e aperta');
  });

  testWidgets('il tocco al centro apre il Calendario degli Eventi',
      (tester) async {
    await apri(tester);
    await tester.tap(centro, warnIfMissed: false);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    expect(find.byType(CalendarioDegliEventiScreen), findsOneWidget,
        reason: 'toccando "Eventi Cosmici" il Calendario non si apre: una '
            'porta che non porta da nessuna parte e\' la violazione piu\' '
            'cara che esista in questo progetto');
  });

  test('il conto alla rovescia e\' uscito dalla barra, e il motore e\' '
      'rimasto', () {
    // **L'ENUMERAZIONE, e guarda due cose opposte.** La prima: nel sorgente
    // della barra non deve piu' comparire il modo di scrivere il conto alla
    // rovescia, altrimenti sarebbe rimasto un ramo che lo mostra ancora. La
    // seconda: il motore della prossima data deve essere ancora vivo e usato
    // dal Calendario, perche' una voce che ripulisce la vetrina non ha il
    // diritto di portarsi via il calcolo.
    // **SI GUARDA IL CODICE, NON I COMMENTI.** Il commento della porta
    // NOMINA `ProssimiEventi` apposta, per dire che il motore resta vivo e
    // dove: una misura che cadesse su quella riga costringerebbe a
    // cancellare proprio la spiegazione che serve a non buttarlo. Le righe
    // di commento si tolgono prima di cercare, come fa gia' la guardia della
    // catena dei dati di nascita.
    final barra =
        File('lib/features/shell/barra_dell_identita.dart')
            .readAsStringSync()
            .split('\n')
            .where((r) => !r.trimLeft().startsWith('//'))
            .join('\n');
    for (final segno in const [
      'ProssimiEventi',
      'rigaDellaBarra',
      'LinguaDegliEventi',
    ]) {
      expect(barra.contains(segno), isFalse,
          reason: 'la barra nomina ancora $segno: il conto alla rovescia non '
              'e\' uscito davvero');
    }

    final motore = File('lib/core/astro/prossimi_eventi.dart');
    expect(motore.existsSync(), isTrue,
        reason: 'il motore della prossima data e\' stato cancellato: serve al '
            'Calendario, ai promemoria e ai Maestri');
    final calendario =
        File('lib/features/calendario/calendario_degli_eventi_screen.dart')
            .readAsStringSync();
    expect(calendario.contains('ProssimiEventi.da('), isTrue,
        reason: 'il Calendario non chiede piu\' le date al motore unico');
  });

  testWidgets('BX.07: durante una festa la barra sparisce', (tester) async {
    // **IL FONDATORE HA LETTO QUESTA ETICHETTA SOPRA QUATTRO FESTE** e l'ha
    // presa per l'intestazione della celebrazione: ci ha scritto sopra un
    // ordine intero, su una famiglia di traguardi che non esiste. La causa non
    // era il velo, che non c'entra: questa barra sta SOPRA il Navigator,
    // quindi si dipinge su ogni rotta e nessun velo le sta davanti.
    await apri(tester);
    expect(centro, findsOneWidget,
        reason: 'la barra non si vede nemmeno prima della festa: la '
            'prova non sta misurando niente');

    // **IL CONTESTO DEVE STARE DENTRO IL NAVIGATOR**, e la barra sta sopra:
    // chiedendo la festa dal contesto della barra, `Navigator.maybeOf` guarda
    // in su e non trova niente, quindi la festa non parte affatto. Lo ha detto
    // la prova stampando "feste partite 0".
    final dentro = tester.element(find.byType(Scaffold).last);
    final traguardo = Sentieri.tuttiITraguardi.firstWhere((t) => !t.dormiente);
    unawaited(Celebrazione.festeggiaInsieme(
      dentro,
      traguardi: [traguardo],
      sentieri: const [Sentiero.costellazione],
      primoInAssoluto: false,
    ));
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    // ignore: avoid_print
    print('ORDINE BX VOCE 7: feste partite ${Celebrazione.partite}, una '
        'in scena ${FesteInCorso.unaCeGia}, etichetta visibile '
        '${centro.evaluate().isNotEmpty}');
    expect(centro, findsNothing,
        reason: 'durante la festa si legge ancora l\'etichetta della barra: '
            'e\' quella che il fondatore ha preso per l\'intestazione '
            'della festa');
  });
}
