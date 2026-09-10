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
}
