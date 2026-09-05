import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/tarot/tarot_selectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'cardinale_minimo.dart';

/// **LA DOMANDA LIBERA SI TROVA, E STA SUBITO SOTTO LE SUGGERITE.**
/// Ordine CQ voce 1.05, 3 settembre 2026.
///
/// **Il fatto, parole del fondatore:** *"manca il campo per la domanda libera
/// nei tarocchi, subito sotto le domande suggerite."*
///
/// **Il campo c'era**, e la provenienza e' l'ordine CO voce 05, che lo aveva
/// creato. La guardia di allora pretendeva soltanto che la tendina delle
/// suggerite venisse PRIMA del campo, e quella pretesa era vera anche col
/// campo in fondo al pannello, dopo altre cinque tendine. **Una pretesa
/// sull'ordine non e' una pretesa sulla distanza**, e fra le due c'era
/// abbastanza spazio da far credere che il campo non esistesse.
///
/// Qui si misura la distanza, e si misura in riquadri a video.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> monta(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => MaestroController())],
      child: MaterialApp(
        home: Scaffold(
          body: MaestroScope(
            child: Builder(
              builder: (context) => SingleChildScrollView(
                child: TarotSetupPanel(
                  setup: const TarotSetup(),
                  palette: context.palette,
                  aperto: true,
                  onChanged: (_) {},
                  onLocked: (_) {},
                ),
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('il campo libero sta fra le suggerite e la tendina dopo',
      (tester) async {
    await monta(tester);
    final voci = <String, Rect>{};
    for (final chiave in const [
      'stesa_topic',
      'stesa_domanda_scritta',
      'stesa_tipo',
      'stesa_chiave',
      'stesa_mazzo',
    ]) {
      final trovato = find.byKey(Key(chiave));
      if (trovato.evaluate().isNotEmpty) {
        voci[chiave] = tester.getRect(trovato.first);
      }
    }
    // ignore: avoid_print
    print('ORDINE CQ VOCE 1.05: i riquadri del pannello aperto '
        '${voci.map((k, v) => MapEntry(k, '${v.top.round()}..'
            '${v.bottom.round()}'))}');
    cardinaleMinimo(voci.length, 5,
        cosa: 'voci del pannello trovate a video',
        perche: 'Se il pannello non montasse piu le sue voci, questa prova '
            'confronterebbe una mappa vuota e sarebbe verde.');

    final suggerite = voci['stesa_topic']!;
    final libera = voci['stesa_domanda_scritta']!;
    expect(libera.top, greaterThanOrEqualTo(suggerite.top),
        reason: 'il campo libero sta SOPRA le domande suggerite: le sei sono '
            'il punto di partenza per chi non sa da dove cominciare, ed e la '
            'maggioranza delle volte');
    for (final dopo in const ['stesa_tipo', 'stesa_chiave', 'stesa_mazzo']) {
      expect(libera.top, lessThan(voci[dopo]!.top),
          reason: 'il campo libero sta sotto "$dopo": fra le domande '
              'suggerite e la propria c e in mezzo il contorno della stesa, '
              'ed e cosi che il fondatore non lo ha trovato');
    }
  });

  testWidgets('e prende la riga intera, non mezza', (tester) async {
    await monta(tester);
    final pannello = tester.getRect(find.byType(TarotSetupPanel));
    final libera = tester.getRect(find.byKey(const Key('stesa_domanda_scritta')));
    final quota = libera.width / pannello.width;
    // ignore: avoid_print
    print('ORDINE CQ VOCE 1.05: il campo libero occupa '
        '${(quota * 100).round()} per cento della larghezza');
    expect(quota, greaterThan(0.7),
        reason: 'il campo libero sta su mezza riga come una tendina: dentro '
            'ci si scrive una frase, e mezza riga e una feritoia');
  });
}
