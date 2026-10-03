import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/rituals/guide_animal_derivation.dart';
import 'package:esoteric_circle/core/viaggio/la_domanda_del_viaggio.dart';
import 'package:esoteric_circle/core/viaggio/la_voce_del_mondo_di_sotto.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/design_system/typography/paragrafi_di_lettura.dart';
import 'package:esoteric_circle/features/maestri/caligo/viaggio/viaggio_dello_sciamano_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'la_soglia_si_guarda_prima_di_leggerla_test.dart'
    show DiarioDelloSciamanoDiProva;

/// **IL TEMA DELLA DOMANDA ARRIVA ALLA RISPOSTA, per tutte e sei le domande.**
/// Ordine DI voce 01, 12 settembre 2026.
///
/// **IL DIFETTO CAPITALE DEL VIAGGIO.** Toccando una delle sei domande lo
/// schermo scriveva nel tema l'**etichetta** per esteso, *"Una scelta da
/// fare"*, e la voce del Mondo di Sotto il tema lo cercava per
/// **identificatore**, `scelta`. Non combaciavano mai: per tutte e tre le vie
/// il tema arrivava nullo, e ogni discesa dell'app cadeva sul ramo scritto per
/// chi non ha chiesto niente. Un utente che aveva chiesto *"mia sorella
/// diventera' presto mamma?"* si e' sentito rispondere *"Questa volta il
/// viaggio era il viaggio"*.
///
/// **PERCHE' LA GUARDIA DI PRIMA NON LO VEDEVA.** Quella dell'ordine DG voce
/// 07 misurava le risposte chiamando il compositore **direttamente, con l'id
/// giusto in mano**: le risposte erano diverse fra loro, varie, dentro le
/// quattro soglie di casa, e nessuna persona le ha mai lette. **Misurava il
/// contenuto, non la strada.** E' la stessa famiglia della schermata finita
/// che nessuno monta.
///
/// **QUESTA PROVA FA LA STRADA INTERA.** Monta il Viaggio vero, tocca la
/// domanda sullo schermo, tiene premuto per scendere, passa la mano nella
/// nebbia, segue l'ombra, risale dalla lente, e **legge la risposta come
/// arriva a schermo**, nei paragrafi che lo schermo stesso ha composto. Pretende
/// in ognuna una delle dodici riprese della domanda.
///
/// **VISTA ROSSA** rimettendo `_temaScelto = d.tema` al posto di `d.chiave`:
/// non compila piu', ed e' la cura. Rimettendo invece il tema nullo nella
/// chiamata alla voce, la prova ha detto sei cadute su sei.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  /// Una ripresa della domanda, riconosciuta dalla sua forma: il testo fisso
  /// com'e', e i due posti del tema che accettano qualunque cosa.
  final riprese = [
    for (final forma in LaVoceDelMondoDiSotto.riprendeLaDomanda)
      RegExp(RegExp.escape(forma)
          .replaceAll(RegExp.escape('{tema}'), '.+?')
          .replaceAll(RegExp.escape('{breve}'), '.+?')),
  ];

  /// Tocca una delle sei domande scritte.
  Future<void> tocca(WidgetTester tester, DomandaScritta domanda) async {
    final laSua = find.byKey(Key('viaggio_domanda_${domanda.id}'));
    await tester.ensureVisible(laSua);
    await tester.pump();
    await tester.tap(laSua);
    await tester.pump();
  }

  /// Sceglie "Scrivila tu" e scrive la domanda nel campo, come una persona.
  Future<void> scrivi(WidgetTester tester, String domanda) async {
    await tester.tap(find.text('Scrivila tu'));
    await tester.pump(const Duration(milliseconds: 300));
    final campo = find.byKey(const Key('viaggio_domanda'));
    await tester.ensureVisible(campo);
    await tester.pump();
    await tester.enterText(campo, domanda);
    await tester.pump();
  }

  Future<List<String>> laRispostaA(WidgetTester tester, String chiave,
      Future<void> Function(WidgetTester) poniLaDomanda) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
      ],
      child: MaterialApp(
        home: MaestroScope(
          child: ViaggioDelloSciamanoScreen(
            key: ValueKey(chiave),
            userSign: Zodiac.gemini,
            now: DateTime(2026, 9, 12, 12),
            diario: DiarioDelloSciamanoDiProva(0),
          ),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // **1. LA DOMANDA SI PONE SULLO SCHERMO**, che e' il punto dove nasceva
    // il difetto.
    await poniLaDomanda(tester);

    // **2. SI SCENDE**, col dito premuto per tutta la discesa.
    await tester.ensureVisible(find.byKey(const Key('viaggio_scendi')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('viaggio_scendi')));
    await tester.pump();
    final dito = await tester
        .startGesture(tester.getCenter(find.byKey(const Key('viaggio_dito'))));
    for (var t = 0;
        t < 400 && find.byKey(const Key('viaggio_dito')).evaluate().isNotEmpty;
        t++) {
      await tester.pump(const Duration(milliseconds: 60));
    }
    await dito.up();

    // **3. LA NEBBIA SI APRE COL MOVIMENTO DELLA MANO.**
    // L'ombra e' quella del SUO animale, derivato dal segno come fa l'app:
    // `viaggio_ombra_vera` e' l'immagine dentro, e non va toccata.
    final suo = GuideAnimalDerivation.forSign(Zodiac.gemini).name;
    final ombra = find.byKey(Key('viaggio_ombra_$suo'));
    for (var t = 0; t < 200 && ombra.evaluate().isEmpty; t++) {
      if (find.byKey(const Key('viaggio_nebbia')).evaluate().isNotEmpty) {
        await tester.drag(find.byKey(const Key('viaggio_nebbia')),
            Offset(t.isEven ? 180 : -180, 60));
      }
      await tester.pump(const Duration(milliseconds: 60));
    }
    expect(ombra, findsOneWidget,
        reason: 'LA NEBBIA NON SI E APERTA, e questa prova non arriva alla '
            'risposta: sta misurando un altro guasto');

    // **4. SI SEGUE L'OMBRA, E SI RISALE DALLA LENTE.**
    await tester.tap(ombra);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.ensureVisible(find.byKey(const Key('viaggio_risali')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('viaggio_risali')));
    for (var t = 0; t < 20; t++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // **5. LA RISPOSTA, COME ARRIVA A SCHERMO.**
    expect(find.byKey(const Key('viaggio_titolo_della_risposta')),
        findsOneWidget,
        reason: 'NON SI E ARRIVATI ALLA RISPOSTA');
    return [
      for (final e in find.byType(ParagrafiDiLettura).evaluate())
        (e.widget as ParagrafiDiLettura).testo,
    ];
  }

  final cadute = <String>[];
  var guardate = 0;

  for (final domanda in LaDomandaDelViaggio.gliaScritte) {
    testWidgets('la domanda "${domanda.tema}" arriva alla risposta',
        (tester) async {
      final testi = await laRispostaA(
          tester, domanda.id, (t) => tocca(t, domanda));
      final tutto = testi.join('\n');
      guardate++;
      final ripresa =
          riprese.any((r) => testi.any((t) => r.hasMatch(t)));
      // ignore: avoid_print
      print('ORDINE DI VOCE 01, "${domanda.tema}": '
          '${ripresa ? "la risposta riprende la domanda" : "NESSUNA RIPRESA"}'
          '\n  ${testi.isEmpty ? "(nessun paragrafo)" : testi.first}');
      if (!ripresa) cadute.add(domanda.tema);
      expect(ripresa, isTrue,
          reason: 'LA RISPOSTA A "${domanda.tema}" NON RIPRENDE LA DOMANDA.\n'
              'A schermo:\n$tutto\n\n'
              'E\' il difetto capitale del Viaggio: il tema toccato sullo '
              'schermo non arriva alla voce del Mondo di Sotto, e ogni '
              'discesa cade sul ramo scritto per chi non ha chiesto niente.');
    });
  }

  tearDownAll(() {
    // ignore: avoid_print
    print('ORDINE DI VOCE 01: domande percorse fino alla risposta $guardate '
        'su ${LaDomandaDelViaggio.gliaScritte.length}, senza ripresa '
        '${cadute.length}');
  });

  /// **LA DOMANDA SCRITTA A MANO ARRIVA ALLA RISPOSTA.** Ordine DI voce 02.
  ///
  /// E' la domanda vera che il fondatore ha visto ricevere *"Questa volta il
  /// viaggio era il viaggio"*, la frase scritta per chi non ha chiesto niente.
  /// Al banco Firebase non c'e', quindi il modello fallisce e decide la
  /// tabella delle parole: e' **esattamente il caso senza rete**, e deve
  /// bastare.
  ///
  /// **VISTA ROSSA** togliendo la classificazione dal tocco di Scendi: la
  /// risposta e' tornata la frase senza domanda, *"Non hai chiesto niente. Hai
  /// visto lo stesso."*, detta a chi aveva chiesto di sua sorella.
  testWidgets('la domanda scritta a mano arriva alla risposta, anche senza rete',
      (tester) async {
    const laSua = 'Mia sorella diventerà presto mamma?';
    final testi =
        await laRispostaA(tester, 'scritta', (t) => scrivi(t, laSua));
    final ripresa = riprese.any((r) => testi.any((t) => r.hasMatch(t)));
    // ignore: avoid_print
    print('ORDINE DI VOCE 02, "$laSua":\n  '
        '${testi.isEmpty ? "(nessun paragrafo)" : testi.first}');
    expect(ripresa, isTrue,
        reason: 'LA DOMANDA SCRITTA A MANO NON ARRIVA ALLA RISPOSTA.\n'
            'A schermo:\n${testi.join('\n')}\n\n'
            'Il fondatore ha visto questa domanda ricevere la frase scritta per '
            'chi non ha chiesto niente.');
  });
}
