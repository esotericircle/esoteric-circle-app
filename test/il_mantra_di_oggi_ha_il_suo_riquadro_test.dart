import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/rituals/daily_elements.dart';
import 'package:esoteric_circle/core/rituals/dawn_gift.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/rituals/ritual_gift_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// IL MANTRA DI OGGI HA IL SUO RIQUADRO. Ordine CW, voce 07.
///
/// **Cosa chiede l'ordine, alla lettera:** il rituale da compiere evidenziato,
/// col titolo esatto in maiuscolo **IL MANTRA DI OGGI**, e sotto il titolo
/// tutto il rituale dentro un riquadro visibile. **Il riquadro contiene solo
/// il rituale**: non ci finiscono dentro il responso, la firma del Maestro,
/// i pulsanti di condivisione.
///
/// **Non e' il ritorno di cio' che l'ordine CQ aveva tolto.** Li' uscivano le
/// tre righe "Cosa fai, Perche', Cosa ti resta" dalla CIMA del responso,
/// perche' la prima cosa che si leggeva era un compito invece di una risposta.
/// Qui il rituale sta DOPO la risposta, e questa formulazione sostituisce
/// quella chiesta il due settembre.
void main() {
  final giorno = DateTime(2026, 9, 7, 7, 30);

  Widget veste(Widget figlio) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
        ],
        child: MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: MaestroScope(
                child: Scaffold(
                    body: SingleChildScrollView(child: figlio))),
          ),
        ),
      );

  Future<void> monta(WidgetTester tester, DailyElement dono) async {
    tester.view.physicalSize = const Size(390, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final gift = dono == DailyElement.dawn
        ? DawnGift.forChart(giorno)
        : DawnGift.forMaestro(giorno, Maestro.aura);
    await tester.pumpWidget(veste(RitualGiftCard(
      gift: gift,
      dono: dono,
      giorno: giorno,
      streak: 1,
      onShare: () {},
    )));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets('Il titolo e\' esatto, e in maiuscolo', (tester) async {
    await monta(tester, DailyElement.dawn);
    final titolo = find.byKey(const Key('alba_titolo_del_mantra'));
    expect(titolo, findsOneWidget,
        reason: 'il riquadro del rituale non ha nessun titolo');
    final testo = tester.widget<Text>(titolo).data;
    expect(testo, 'IL MANTRA DI OGGI',
        reason: 'il titolo e\' "$testo": l\'ordine lo chiede alla lettera, in '
            'maiuscolo, e una formulazione diversa e\' una formulazione '
            'diversa');
  });

  testWidgets('Il testo del rituale e\' dentro il riquadro', (tester) async {
    await monta(tester, DailyElement.dawn);
    final riquadro = find.byKey(const Key('alba_riquadro_del_mantra'));
    expect(riquadro, findsOneWidget,
        reason: 'il rituale non sta dentro nessun riquadro visibile');

    // **DISCENDENTE, non solo vicino.** Un testo posato accanto a un bordo
    // sembra dentro e non lo e': al primo cambio di spaziatura si stacca.
    for (final chiave in const [
      'alba_titolo_del_mantra',
      'alba_testo_del_mantra',
      'alba_via_tattile_del_mantra',
    ]) {
      expect(
          find.descendant(of: riquadro, matching: find.byKey(Key(chiave))),
          findsOneWidget,
          reason: '$chiave non e\' discendente del riquadro del rituale');
    }
  });

  testWidgets('Il riquadro NON contiene il responso ne\' la condivisione',
      (tester) async {
    await monta(tester, DailyElement.dawn);
    final riquadro = find.byKey(const Key('alba_riquadro_del_mantra'));

    // L'ordine lo dice per nome: dentro ci va solo il rituale.
    for (final estraneo in const [
      'alba_titolo_risposta',
      'alba_risposta',
      'gift_word',
      'gift_share_word',
    ]) {
      expect(
          find.descendant(of: riquadro, matching: find.byKey(Key(estraneo))),
          findsNothing,
          reason: '$estraneo e\' finito DENTRO il riquadro del rituale: il '
              'riquadro deve contenere solo il rituale, altrimenti dice che '
              'anche il responso e\' una cosa da fare');
    }

    // E il responso c'e' ancora, fuori: la voce evidenzia il rituale, non
    // sostituisce la risposta.
    expect(find.byKey(const Key('alba_titolo_risposta')), findsOneWidget,
        reason: 'il titolo della risposta e\' sparito dalla scheda');
  });

  testWidgets('Il riquadro sta DOPO il responso, non prima', (tester) async {
    await monta(tester, DailyElement.dawn);
    final risposta = tester.getRect(find.byKey(const Key('alba_risposta')));
    final riquadro =
        tester.getRect(find.byKey(const Key('alba_riquadro_del_mantra')));
    expect(riquadro.top, greaterThan(risposta.top),
        reason: 'il rituale sta sopra la risposta, a '
            '${riquadro.top.toStringAsFixed(1)} contro '
            '${risposta.top.toStringAsFixed(1)}: e\' il difetto che l\'ordine '
            'CQ voce 2.03 ha tolto, cioe\' un compito come prima cosa che si '
            'legge');
  });

  testWidgets('Negli altri Doni il riquadro non compare', (tester) async {
    // L'ordine dice "nel Rito dell'Alba". Gli altri quattro montano la stessa
    // scheda e non hanno questo rituale da compiere.
    await monta(tester, DailyElement.breath);
    expect(find.byKey(const Key('alba_riquadro_del_mantra')), findsNothing,
        reason: 'il riquadro del rituale compare anche nel Soffio, dove il '
            'gesto da compiere e\' il respiro e non questo');
  });
}
