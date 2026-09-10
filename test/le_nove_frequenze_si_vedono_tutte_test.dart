import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/aura/meditation/meditation_audio.dart';
import 'package:esoteric_circle/features/maestri/aura/meditation/meditation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cardinale_minimo.dart';

/// **LE NOVE FREQUENZE SI VEDONO TUTTE.** Ordine DD voce 12, 10 settembre
/// 2026.
///
/// **Il fatto del fondatore**: la Meditazione offriva **tre** frequenze, e le
/// sette dei centri non c'erano. Non mancavano i suoni: i toni li sintetizza
/// `ToneGenerator` e qualunque frequenza si puo' suonare. **Mancavano dalla
/// scelta**, cioe' nessuno le aveva scritte fra i preset.
///
/// **E ADESSO CHE SONO NOVE NASCE IL DIFETTO CHE QUESTA GUARDIA PRENDE.** Le
/// pasticche stavano in una `Row`: tre ci stavano, nove no. Una Row non manda
/// a capo, **spinge fuori dallo schermo**, e chi guarda vede sei frequenze e
/// mezza. Aggiungere le sei mancanti senza guardare dove finiscono e' curare
/// meta' del difetto e crearne un altro.
///
/// **E LA GRANDEZZA MISURATA E' STATA CAMBIATA UNA VOLTA, va detto.** La
/// prima stesura guardava se la pasticca finiva **oltre il bordo dello
/// schermo**, e con nove pasticche era **verde**: dentro una `Row` ogni
/// pasticca e' `Expanded`, quindi non esce affatto, **si stringe**. Le nove
/// etichette stavano tutte fra 25 e 50 punti di larghezza, cioe' larghe un
/// nono di schermo, e `432 Hz` non ci sta in venticinque punti: **andava a
/// capo**. La prova diceva il vero su una domanda che non era quella giusta.
///
/// **Adesso si misura se l'etichetta va a capo**: si calcola con un
/// `TextPainter`, nello stesso stile, quanto e' alta scritta su una riga
/// sola, e la si confronta con quanto e' alta a schermo. Una pasticca che
/// manda a capo `432` e `Hz` e' una pasticca che nessuno legge.
void main() {
  Future<void> apriLaScelta(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        home: MaestroScope(
          child: MeditationScreen(
              player: const SilentTonePlayer(), now: DateTime(2026, 9, 9)),
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 300));
    // La scelta libera e' chiusa di partenza: la porta principale resta Aura
    // che sceglie dal centro del giorno.
    final apre = find.byKey(const Key('meditation_scegli_tu'));
    await tester.scrollUntilVisible(apre, 200);
    await tester.tap(apre);
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('OGNI FREQUENZA SI LEGGE SU UNA RIGA, e sono nove',
      (tester) async {
    await apriLaScelta(tester);

    final etichette = [for (final p in MeditationPreset.values) p.label];
    cardinaleMinimo(etichette.length, 9,
        cosa: 'frequenze offerte nella scelta libera',
        perche: 'Con meno di nove la Meditazione e tornata a offrire una '
            'manciata di toni, e le sette dei centri sono di nuovo assenti '
            'dalla scelta.');

    final spezzate = <String>[];
    for (final testo in etichette) {
      final pasticca = find.text(testo);
      expect(pasticca, findsWidgets,
          reason: 'la frequenza "$testo" non e a schermo affatto');
      final widget = tester.widget<Text>(pasticca.first);
      final r = tester.getRect(pasticca.first);

      // Quanto sarebbe alta e larga su una riga sola, nello stesso stile.
      final misura = TextPainter(
        text: TextSpan(text: testo, style: widget.style),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();

      final righe = r.height / misura.height;
      // ignore: avoid_print
      print('ORDINE DD VOCE 12: "$testo" larga ${r.width.toStringAsFixed(0)} '
          'punti, ne chiede ${misura.width.toStringAsFixed(0)}, alta '
          '${r.height.toStringAsFixed(0)} contro ${misura.height.toStringAsFixed(0)} '
          'di una riga sola, cioe ${righe.toStringAsFixed(1)} righe');
      // Una riga e mezza e gia due righe: sotto quella soglia non ci sono
      // ambiguita di arrotondamento, sopra il testo e andato a capo.
      if (righe > 1.5 || r.width + 0.5 < misura.width) {
        spezzate.add('"$testo" larga ${r.width.toStringAsFixed(0)} su '
            '${misura.width.toStringAsFixed(0)} che ne chiede');
      }
    }
    // ignore: avoid_print
    print('ORDINE DD VOCE 12: frequenze offerte ${etichette.length}, '
        'etichette spezzate ${spezzate.length}');
    expect(spezzate, isEmpty,
        reason: 'queste frequenze sono strette piu di quanto il loro nome '
            'chieda, e il nome va a capo dentro la pasticca: '
            '${spezzate.join(" | ")}');
  });

  testWidgets('REGOLA H: LE SETTE DEI CENTRI CI SONO, e ognuna sa il suo',
      (tester) async {
    // **La meta che prova il contrario.** Che le etichette non vadano a capo
    // sarebbe verde anche con tre sole: qui si prova che le sette
    // frequenze dei centri esistono davvero e che ognuna dichiara **quale**
    // centro serve, altrimenti la Meditazione tornerebbe a dire una
    // frequenza e a suonarne un altra, che e il difetto da cui questa voce e
    // nata.
    await apriLaScelta(tester);
    final centri = <int, String>{};
    for (final p in MeditationPreset.values) {
      if (p.centro != null) centri[p.centro!] = p.label;
    }
    // ignore: avoid_print
    print('ORDINE DD VOCE 12: preset legati a un centro ${centri.length}, '
        'centri coperti ${centri.keys.toList()..sort()}');
    expect(centri.length, 7,
        reason: 'i centri con una frequenza propria sono ${centri.length} '
            'invece di sette: qualche centro resta senza il suo tono');
    for (var i = 0; i < 7; i++) {
      expect(centri.containsKey(i), isTrue,
          reason: 'il centro numero $i non ha nessuna frequenza propria');
      expect(MeditationPreset.perCentro(i)?.label, centri[i],
          reason: 'la porta che sceglie per centro non trova la frequenza del '
              'centro $i');
    }
  });

  testWidgets(
      'DUE FRASI NON DICONO DUE FREQUENZE DIVERSE, scelta una pratica',
      (tester) async {
    // **TROVATO SUL TELEFONO 767f596c il 10 settembre 2026**, dopo la cura
    // della voce DD.12 e con la libreria che finalmente risponde.
    //
    // A schermo si leggevano insieme, a due righe di distanza:
    //
    //     Oggi e acceso il cuore (Anahata) ... i 639 hertz.
    //     E la frequenza di questa sessione.
    //     Senso di insicurezza: Il suono della radice, 5 minuti.
    //
    // Il suono della radice sta a **396**, non a 639. **Due frasi sulla
    // stessa cosa che dicono due numeri diversi**, ed e' la stessa famiglia
    // di difetti da cui questa voce e nata: la schermata diceva 639 e suonava
    // 432.
    //
    // **La riga del centro non e sbagliata: e fuori tempo.** Il suo soggetto
    // e *il centro di oggi*, e resta vera finche la sessione e quella che
    // Aura ha scelto. Quando a scegliere e chi guarda, quella riga tace e
    // parla la riga della pratica.
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        home: MaestroScope(
          child: MeditationScreen(
              player: const SilentTonePlayer(), now: DateTime(2026, 9, 9)),
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 300));

    final riga = find.byKey(const Key('meditation_perche_la_frequenza'));
    expect(riga, findsOneWidget,
        reason: 'la riga del centro di oggi non c e prima di scegliere: '
            'senza di lei questa prova non misura niente');

    // Si apre la libreria e si sceglie la prima pratica.
    final apre = find.byKey(const Key('meditazione_apri_libreria'));
    await tester.scrollUntilVisible(apre, 200);
    await tester.tap(apre);
    await tester.pump(const Duration(milliseconds: 300));
    // La prima voce della libreria, cercata per chiave: `InkWell` ne trova
    // anche altri, e toccare quello sbagliato farebbe cadere questa prova su
    // un gesto che non e' mai arrivato alla libreria.
    final voci = find.byWidgetPredicate((w) =>
        w.key is ValueKey<String> &&
        (w.key as ValueKey<String>).value.startsWith('meditazione_respiro_'));
    expect(voci, findsWidgets,
        reason: 'la libreria aperta non mostra nessuna pratica da toccare');
    await tester.scrollUntilVisible(voci.first, 200);
    await tester.tap(voci.first);
    await tester.pump(const Duration(milliseconds: 400));

    final inCorso = find.byKey(const Key('meditazione_pratica_in_corso'));
    // ignore: avoid_print
    print('ORDINE DD VOCE 12: scelta una pratica, la riga della pratica c e '
        '${inCorso.evaluate().isNotEmpty}, la riga del centro c e '
        '${riga.evaluate().isNotEmpty}');
    expect(inCorso, findsOneWidget,
        reason: 'toccata una pratica, la schermata non dice quale sta '
            'facendo: questa prova non e arrivata al punto che misura');
    expect(riga, findsNothing,
        reason: 'scelta una pratica, la riga del centro di oggi resta a '
            'schermo e dichiara una frequenza che non sta suonando: due frasi '
            'sulla stessa cosa con due numeri diversi');
  });
}
