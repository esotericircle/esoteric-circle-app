/// I RICORDI HANNO UNA ROTTA SOLA, E TRE PORTE. Ordine CG voci 01, 04 e 07.
///
/// **La pretesa che vale piu' di tutte in questo file.** Ogni punto di `lib/`
/// che apre i Ricordi deve passare da `RicordiScreen.route`: due schermate che
/// mostrano le stesse cose sono la famiglia di difetti piu' numerosa di questo
/// progetto, e il fondatore l'ha scritto nell'ordine CF.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:esoteric_circle/design_system/typography/paragrafi_di_lettura.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/ricordi/registro_dei_ricordi.dart';
import 'package:esoteric_circle/core/ricordi/ricordo_custodito.dart';
import 'package:esoteric_circle/core/ricordi/scrigno_dei_custoditi.dart';
import 'package:esoteric_circle/core/ricordi/voce_del_ricordo.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/ricordi/ricordi_screen.dart';

import 'sorgenti_di_lib.dart';

/// Tutti i file di `lib/` che nominano la schermata dei Ricordi.
List<File> _fileCheNominanoIRicordi() {
  final fuori = <File>[];
  for (final voce in sorgentiDiLib()) {
    if (voce.path
        .replaceAll('\\', '/')
        .endsWith('lib/features/ricordi/ricordi_screen.dart')) {
      continue;
    }
    if (voce.readAsStringSync().contains('RicordiScreen')) fuori.add(voce);
  }
  return fuori;
}

Widget _scena(
    Widget figlio, RegistroDeiRicordi registro, ScrignoDeiCustoditi scrigno) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<RegistroDeiRicordi>.value(value: registro),
      ChangeNotifierProvider<ScrignoDeiCustoditi>.value(value: scrigno),
    ],
    // **IL MAESTROSCOPE SERVE, e non e' un dettaglio della prova.** La
    // schermata legge la palette del Maestro attivo: senza lo scope la
    // costruzione muore, che e' esattamente cio' che deve succedere se
    // qualcuno la monta fuori dalla rotta, perche' la rotta lo mette.
    child: MaterialApp(
      // Il Maestro si passa esplicito: senza, lo scope lo cerca nel
      // controller, che in una prova che monta una schermata sola non c'e'.
      home: MaestroScope(maestro: Maestro.caligo, child: figlio),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues(const {}));

  test('CG.01: ogni punto che apre i Ricordi passa dalla rotta unica', () {
    final file = _fileCheNominanoIRicordi();
    expect(file, isNotEmpty,
        reason: 'nessun punto apre i Ricordi: e\' la prova a essere rotta, '
            'non il codice');

    final fuoriRotta = <String>[];
    for (final f in file) {
      final sorgente = f.readAsStringSync();
      // Chi nomina la schermata deve passare dalla rotta, mai costruirla.
      if (sorgente.contains('RicordiScreen(') &&
          !sorgente.contains('RicordiScreen.route')) {
        fuoriRotta.add(f.path);
      }
    }
    // ignore: avoid_print
    print('ORDINE CG VOCE 01: punti di lib che aprono i Ricordi '
        '${file.length}, fuori rotta ${fuoriRotta.length}');
    expect(fuoriRotta, isEmpty,
        reason: 'questi punti costruiscono la schermata per conto loro invece '
            'di passare dalla rotta: $fuoriRotta. IL ROSSO SI DIMOSTRA '
            'creando un secondo punto che monta RicordiScreen a mano, e la '
            'prova deve cadere nominando il file');
  });

  test('CG.01: le tre porte ci sono tutte, e sono quelle dell\'ordine', () {
    // Il menu' utente sotto il nome, il rimando dal Passaporto accanto ai
    // traguardi, la riga in cima a ogni chat.
    const porte = {
      'lib/features/account/account_screen.dart':
          'il menu\' utente sotto il nome',
      'lib/features/passport/cosmic_passport_screen.dart':
          'il rimando del Passaporto accanto ai traguardi',
      'lib/features/maestri/chat/maestro_chat_screen.dart':
          'la riga in cima a ogni chat',
    };
    final mancanti = <String>[];
    for (final voce in porte.entries) {
      final f = File(voce.key);
      if (!f.existsSync() || !f.readAsStringSync().contains('RicordiScreen')) {
        mancanti.add('${voce.value} (${voce.key})');
      }
    }
    expect(mancanti, isEmpty,
        reason: 'queste porte non aprono i Ricordi: $mancanti');
  });

  testWidgets('CG.01: la levetta ha due viste, e si passa da una all\'altra',
      (tester) async {
    final registro = RegistroDeiRicordi(orologio: () => DateTime(2026, 8, 31));
    await registro.carica();
    final scrigno = ScrignoDeiCustoditi();
    await scrigno.carica();

    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(_scena(
        RicordiScreen(
            vistaIniziale: VistaDelJournal.cammino,
            orologio: () => DateTime(2026, 8, 31)),
        registro,
        scrigno));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('ricordi_levetta')), findsOneWidget);
    expect(find.byKey(const Key('ricordi_vista_cammino')), findsOneWidget,
        reason: 'si e\' aperta sul Cammino, come chiesto');
    expect(find.byKey(const Key('ricordi_vista_ricordi')), findsNothing);

    await tester.tap(find.text('I Ricordi'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('ricordi_vista_ricordi')), findsOneWidget);
    expect(find.byKey(const Key('ricordi_vista_cammino')), findsNothing,
        reason: 'le due viste stanno nella STESSA schermata, e una alla volta');
  });

  testWidgets('CG.02: si scende dai mesi al giorno e si risale',
      (tester) async {
    final registro = RegistroDeiRicordi(orologio: () => DateTime(2026, 8, 31));
    await registro.carica();
    await registro.segna(VoceDelRicordo(
      quando: DateTime(2026, 8, 12, 9),
      arte: 'gettata',
      maestro: 'caligo',
      titolo: 'Una gettata di rune',
      tipo: TipoDelRicordo.gesto,
    ));
    final scrigno = ScrignoDeiCustoditi();
    await scrigno.carica();

    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(_scena(
        RicordiScreen(orologio: () => DateTime(2026, 8, 31)),
        registro,
        scrigno));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('ricordi_anno')), findsOneWidget,
        reason: 'si apre sull\'anno, che e\' il colpo d\'occhio');
    expect(find.byKey(const Key('ricordi_mese_8')), findsOneWidget);

    await tester.tap(find.byKey(const Key('ricordi_mese_8')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('ricordi_mese')), findsOneWidget);

    // La settimana che contiene il 12 agosto 2026.
    final settimana = find.byWidgetPredicate((w) =>
        w.key is ValueKey<String> &&
        (w.key as ValueKey<String>).value.startsWith('ricordi_settimana_'));
    expect(settimana, findsWidgets);

    // E si risale.
    await tester.tap(find.byKey(const Key('ricordi_torna_su')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('ricordi_anno')), findsOneWidget,
        reason: 'dal mese si torna all\'anno');
  });

  testWidgets('CG.07: Le tue Carte e\' una pastiglia, non una schermata',
      (tester) async {
    final registro = RegistroDeiRicordi(orologio: () => DateTime(2026, 8, 31));
    await registro.carica();
    final scrigno = ScrignoDeiCustoditi();
    await scrigno.carica();
    await scrigno.custodisci(RicordoCustodito(
      quando: DateTime(2026, 8, 12, 9),
      arte: 'gettata',
      maestro: 'caligo',
      titolo: 'La tua gettata',
      testo: 'Uruz ti chiede di non trattenere la forza che hai.',
      comeENato: ComeENato.gesto,
    ));

    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(_scena(
        RicordiScreen(orologio: () => DateTime(2026, 8, 31)),
        registro,
        scrigno));
    await tester.pumpAndSettle();

    // **LA PASTIGLIA E' LA SESTA, quindi fuori dalla piega orizzontale a 390
    // punti.** Un tocco su una pastiglia che non e' a schermo non arriva, ed
    // e' la trappola di casa: si scorre fino a lei prima di toccarla.
    await tester.scrollUntilVisible(
      find.byKey(const Key('ricordi_pastiglia_custoditi')),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('ricordi_pastiglia_custoditi')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('ricordi_le_tue_carte')), findsOneWidget,
        reason: 'la pastiglia mostra la griglia delle carte dentro i Ricordi. '
            'IL ROSSO SI DIMOSTRA scrivendo in un secondo magazzino, e la '
            'carta custodita non compare qui');
    final chiave =
        '${DateTime(2026, 8, 12, 9).millisecondsSinceEpoch ~/ 60000}.gettata';
    expect(find.byKey(Key('ricordi_carta_$chiave')), findsOneWidget,
        reason: 'la carta si trova con la sua chiave vera, non con la sua '
            'posizione nella griglia');
  });

  testWidgets('CG.04: un responso custodito si riapre com\'era',
      (tester) async {
    final custodito = RicordoCustodito(
      quando: DateTime(2026, 8, 12, 9),
      arte: 'gettata',
      maestro: 'caligo',
      titolo: 'La tua gettata',
      testo: 'Uruz ti chiede di non trattenere la forza che hai.',
      comeENato: ComeENato.condivisione,
    );
    final registro = RegistroDeiRicordi(orologio: () => DateTime(2026, 8, 31));
    await registro.carica();
    final scrigno = ScrignoDeiCustoditi();
    await scrigno.carica();

    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
        _scena(RicordoApertoScreen(custodito: custodito), registro, scrigno));
    await tester.pumpAndSettle();

    // **IL TESTO DEL RICORDO PASSA DA ParagrafiDiLettura**, non da un
    // Text nudo: e' la porta sola del ruolo lettura, e questa prova
    // ancora chiedeva un Text. Cadeva col tipo sbagliato, non sul fatto.
    expect(
        tester
            .widget<ParagrafiDiLettura>(
                find.byKey(const Key('ricordo_aperto_testo')))
            .testo,
        'Uruz ti chiede di non trattenere la forza che hai.',
        reason: 'il ricordo torna nella sua forma originale, col suo testo');
    expect(find.byKey(const Key('ricordo_aperto_quando')), findsOneWidget,
        reason: 'un ricordo senza il giorno in cui e\' nato e\' una carta '
            'senza data');
  });
}
