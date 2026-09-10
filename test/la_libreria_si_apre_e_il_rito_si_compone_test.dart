import 'package:esoteric_circle/core/maestro/libreria_dei_respiri.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/core/maestro/sequenza_di_aura.dart';
import 'package:esoteric_circle/features/maestri/aura/meditation/pannello_della_libreria.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cardinale_minimo.dart';

/// **LA LIBRERIA SI APRE E IL RITO SI COMPONE.** Ordine DB voci 01, 02 e 05,
/// 9 settembre 2026.
///
/// **DA DOVE NASCE.** Le tre voci erano scritte e provate nei loro dati, ma il
/// pannello non esisteva: era la stessa condizione in cui la voce CZ.09 era
/// rimasta ferma, lavoro calcolato e non montato. Questa guardia prova che il
/// pannello c'e' e che dice il vero.
///
/// **REGOLA H, la presenza non basta.** Non si prova solo che la libreria si
/// apra: si prova anche che **resti chiusa di partenza**, perche' la porta
/// principale l'ha decisa la voce CZ.06 e un menu' aperto davanti a chi entra
/// la contraddice, e che **il rifiuto non sia mai muto**.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  /// **LA FINESTRA DI PROVA E QUELLA DI UN TELEFONO.** Il default di
  /// `flutter_test` e 800x600, che non e nessun telefono: la libreria ci sta
  /// tutta in larghezza e i tocchi cadono dove sul telefono vero non
  /// cadrebbero mai. Qui si misura a 390x844.
  void telefono(WidgetTester tester) {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  /// Tocca una riga della libreria **portandola prima sotto gli occhi**: con
  /// dieci pratiche in una lista che scorre, la seconda sta gia fuori
  /// schermo, e un tocco a vuoto passerebbe per un tocco riuscito.
  Future<void> toccaLaPratica(WidgetTester tester, String nome) async {
    final riga = find.textContaining(nome, findRichText: false).first;
    await tester.ensureVisible(riga);
    await tester.pump();
    await tester.tap(riga);
    await tester.pump();
  }

  Widget scena({SequenzeDiAura? sequenze}) => MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: PannelloDellaLibreria(
              palette: MaestroPalette.aura,
              centroDiOggi: 3,
              sequenze: sequenze,
            ),
          ),
        ),
      );

  testWidgets('LA LIBRERIA E CHIUSA DI PARTENZA, e Aura sceglie',
      (tester) async {
    telefono(tester);
    await tester.pumpWidget(scena());
    // Ordine CZ voce 06: *"Un menu di frequenze davanti a chi non ha criterio
    // per scegliere e la forma sbagliata"*. Il pannello si apre a richiesta.
    expect(find.byKey(const Key('meditazione_ampiezza_libreria')), findsNothing,
        reason: 'la libreria e gia aperta quando la scena compare: la porta '
            'principale non e piu quella di Aura');
    expect(find.byKey(const Key('meditazione_apri_libreria')), findsOneWidget);
  });

  testWidgets('APERTA, DICHIARA QUANTE SONO PRONTE E QUANTE PREVISTE',
      (tester) async {
    telefono(tester);
    await tester.pumpWidget(scena());
    await tester.tap(find.byKey(const Key('meditazione_apri_libreria')));
    await tester.pump();
    final riga = tester.widget<Text>(
        find.byKey(const Key('meditazione_ampiezza_libreria')));
    final testo = riga.data ?? '';
    // ignore: avoid_print
    print('ORDINE DB VOCE 01: la libreria dichiara "$testo"');
    // **I DUE NUMERI SONO SEPARATI**, ordine DB voce 01: un numero solo che li
    // somma sarebbe una promessa travestita da conto.
    expect(testo, contains('${LibreriaDeiRespiri.pronte.length}'),
        reason: 'la libreria non dice quante pratiche ci sono');
    // **E NON NOMINA NESSUNA PRATICA FUTURA.** Ordine DC voce 18: le
    // ventisei che non ci sono non si contano e non si mostrano in grigio.
    for (final promessa in const ['previst', 'in arrivo', 'presto', '36']) {
      expect(testo.toLowerCase().contains(promessa), isFalse,
          reason: 'la riga dell ampiezza dice "$promessa": e una promessa che '
              'chi arriva in fondo scopre vuota');
    }
  });

  testWidgets('OGNI PRATICA A SCHERMO PORTA LA SUA FONTE', (tester) async {
    telefono(tester);
    await tester.pumpWidget(scena());
    await tester.tap(find.byKey(const Key('meditazione_apri_libreria')));
    await tester.pump();
    // **SI GUARDA CIO CHE E DAVVERO A SCHERMO**, non la lista in memoria: la
    // voce 02 chiede che la fonte si veda, e una fonte scritta nel corpus e
    // non montata non serve a chi legge.
    final testi = <String>[
      for (final t in tester.widgetList<Text>(find.byType(Text)))
        t.data ?? '',
    ];
    cardinaleMinimo(testi.length, 20,
        cosa: 'testi a schermo nel pannello aperto',
        perche: 'Su un pannello vuoto nessuna fonte manca, e la guardia '
            'sarebbe verde per non aver visto niente.');
    cardinaleMinimo(Tradizione.values.length, 3,
        cosa: 'tradizioni da cercare a schermo',
        perche: 'Con una tradizione sola la guardia direbbe che le fonti ci '
            'sono tutte per non averne quasi cercata nessuna.');
    var conFonte = 0;
    for (final t in Tradizione.values) {
      if (testi.any((s) => s.contains(t.fonte))) conFonte++;
    }
    // ignore: avoid_print
    print('ORDINE DB VOCE 02: testi a schermo ${testi.length}, tradizioni '
        'con la fonte visibile $conFonte su ${Tradizione.values.length}');
    expect(conFonte, Tradizione.values.length,
        reason: 'non tutte le tradizioni mostrano la loro fonte a schermo: '
            'ne mancano ${Tradizione.values.length - conFonte}');
  });

  testWidgets('UNA PRATICA SOLA NON E UNA SEQUENZA, e lo dice', (tester) async {
    final sequenze = SequenzeDiAura();
    telefono(tester);
    await tester.pumpWidget(scena(sequenze: sequenze));
    await tester.tap(find.byKey(const Key('meditazione_apri_libreria')));
    await tester.pump();
    // Si tocca una pratica sola.
    await toccaLaPratica(tester, LibreriaDeiRespiri.pronte.first.nome);
    await tester.enterText(
        find.byKey(const Key('meditazione_nome_del_rito')), 'La mia sera');
    await tester.pump();
    // **IL RIFIUTO NON E MAI MUTO**, ordine DB voce 05: un pulsante spento
    // senza spiegazione lascia chi compone a chiedersi cosa ha sbagliato.
    final perche = find.byKey(const Key('meditazione_perche_il_rito_non_va'));
    expect(perche, findsOneWidget,
        reason: 'con una pratica sola il rito non va, e nessuno dice perche');
    final testo = tester.widget<Text>(perche).data ?? '';
    // ignore: avoid_print
    print('ORDINE DB VOCE 05: il rifiuto dice "$testo"');
    expect(testo, contains('${SequenzeDiAura.minimo}'),
        reason: 'il rifiuto non dice quante ne servono: e un no senza una via '
            'di uscita');
    final pulsante = tester.widget<OutlinedButton>(
        find.byKey(const Key('meditazione_salva_il_rito')));
    expect(pulsante.onPressed, isNull,
        reason: 'il rito si puo salvare con una pratica sola');
  });

  testWidgets('DUE PRATICHE E UN NOME FANNO UN RITO, e si ritrova',
      (tester) async {
    final sequenze = SequenzeDiAura();
    telefono(tester);
    await tester.pumpWidget(scena(sequenze: sequenze));
    await tester.tap(find.byKey(const Key('meditazione_apri_libreria')));
    await tester.pump();
    for (final r in LibreriaDeiRespiri.pronte.take(2)) {
      await toccaLaPratica(tester, r.nome);
    }
    await tester.enterText(
        find.byKey(const Key('meditazione_nome_del_rito')), 'La mia sera');
    await tester.pump();
    expect(find.byKey(const Key('meditazione_perche_il_rito_non_va')),
        findsNothing,
        reason: 'con due pratiche e un nome il rito va, e invece viene '
            'rifiutato');
    final salva = find.byKey(const Key('meditazione_salva_il_rito'));
    await tester.ensureVisible(salva);
    await tester.pump();
    await tester.tap(salva);
    await tester.pumpAndSettle();
    expect(sequenze.mie.length, 1,
        reason: 'il rito non e stato conservato');
    expect(sequenze.mie.first.nome, 'La mia sera');
    // ignore: avoid_print
    print('ORDINE DB VOCE 05: conservato "${sequenze.mie.first.nome}", '
        '${sequenze.mie.first.pratiche.length} pratiche, '
        '${sequenze.mie.first.durata.inMinutes} minuti');
    // **E SI RITROVA A SCHERMO**, che e la ragione per cui esiste: *"chi ha
    // costruito qualcosa dentro non se ne va"*.
    expect(find.textContaining('La mia sera'), findsWidgets,
        reason: 'il rito e stato salvato ma non si vede piu');
  });

  testWidgets('SENZA SEQUENZE LA LIBRERIA SI LEGGE LO STESSO', (tester) async {
    // La libreria e le fonti valgono anche dove il rito non si compone: una
    // funzione che sparisce insieme a un altra e due funzioni legate senza
    // ragione.
    telefono(tester);
    await tester.pumpWidget(scena());
    await tester.tap(find.byKey(const Key('meditazione_apri_libreria')));
    await tester.pump();
    expect(find.byKey(const Key('meditazione_ampiezza_libreria')),
        findsOneWidget);
    expect(find.byKey(const Key('meditazione_il_mio_rito')), findsNothing);
  });
}
