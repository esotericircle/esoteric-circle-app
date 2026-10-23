// ignore_for_file: avoid_print
import 'dart:convert';

import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/viaggio/diario_dei_viaggi.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/caligo/viaggio/viaggio_dello_sciamano_screen.dart';
import 'package:esoteric_circle/services/ai/registro_dei_guasti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// **SI SCENDE DOPO UNA SCELTA, NON PRIMA.** Ordine EE voce 14, 23 settembre
/// 2026.
///
/// **Il fatto del fondatore, verbatim**: *"anche se non seleziono o scrivo
/// una domanda o non seleziono 'solo incontro' il pulsante 'scendi' e' cmq
/// attivo e posso avviare la discesa Senza aver selezionato nulla. il
/// pulsante deve essere attivo solo se faccio una selezione"*.
///
/// **La causa, e non era una svista.** La condizione conteneva `perche ==
/// null`, dove `perche` e' il motivo per cui la domanda scritta **non va
/// bene**: a mani vuote non c'e' nessun motivo, quindi era `null` e il
/// pulsante si accendeva. **Lo faceva per decisione**, ordini DC voce 05 e
/// DQ voce 03: *"la domanda e' facoltativa alla prima discesa di un
/// cammino"*. **Padre dello scarto: ordine DC voce 05**, ripreso da DQ voce
/// 03; la parola del fondatore e' del 23 settembre e prevale.
///
/// **La porta per chi non vuole chiedere resta**, ed e' "Solo incontro":
/// scegliere di non chiedere e' una scelta, non toccare niente non lo e'.
void main() {
  Future<void> apri(WidgetTester tester, DiarioDeiViaggi diario) async {
    await tester.pumpWidget(MultiProvider(
      key: UniqueKey(),
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider.value(value: RegistroDeiGuasti()),
      ],
      child: MaterialApp(
        home: MaestroScope(
          child: ViaggioDelloSciamanoScreen(
            userSign: Zodiac.cancer,
            now: DateTime(2026, 9, 15, 12),
            diario: diario,
            demo: false,
            chiamataDellaDomanda: (_, __) async =>
                jsonEncode({'tema': 'persona', 'oggetto': 'tua sorella'}),
            chiamataDellaScena: (_, __, ___) async => jsonEncode({
              'luogo': 'grotta',
              'cosa': 'chiave',
              'gesto': 'aspetta',
              'momento': 'alba',
              'titolo': 'La grotta',
              'risposta': 'Una risposta.',
              'azione': 'Stasera fai una cosa sola.',
            }),
          ),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// Vero se il pulsante "Scendi" e' toccabile.
  bool scendiEAcceso(WidgetTester tester) {
    final bottone = tester
        .widget<FilledButton>(find.byKey(const Key('viaggio_scendi')).first);
    return bottone.onPressed != null;
  }

  testWidgets('alla prima discesa, senza nessuna scelta, non si scende',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final diario = DiarioDeiViaggi(
        orologio: () => DateTime(2026, 9, 15, 12), archivio: false);
    await apri(tester, diario);

    final acceso = scendiEAcceso(tester);
    print('ORDINE EE VOCE 14, a mani vuote: il pulsante e\' '
        '${acceso ? "acceso" : "spento"}');
    expect(acceso, isFalse,
        reason: 'il pulsante Scendi e\' attivo senza che la persona abbia '
            'scelto o scritto niente: si avvia una discesa su una domanda '
            'che non c\'e\'');
  });

  testWidgets('e con "Solo incontro" si scende, perche\' e\' una scelta',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final diario = DiarioDeiViaggi(
        orologio: () => DateTime(2026, 9, 15, 12), archivio: false);
    await apri(tester, diario);

    // **La meta' che tiene aperta la porta.** Senza questa, spegnere il
    // pulsante sempre farebbe passare la prova qui sopra e chiuderebbe
    // l'unica strada di chi non vuole chiedere niente.
    final segmento = find.text('Solo incontro');
    expect(segmento, findsWidgets,
        reason: 'la porta del solo incontro non c\'e\' piu\': chi non vuole '
            'chiedere niente non ha piu\' nessun modo di scendere');
    await tester.ensureVisible(segmento.first);
    await tester.tap(segmento.first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // La card compare solo dopo la scelta: e' la conferma che il tocco e'
    // arrivato, non un controllo in piu'.
    expect(find.byKey(const Key('viaggio_solo_incontro')), findsWidgets,
        reason: 'il tocco sul segmento non ha scelto la via dell\'incontro: '
            'la prova non starebbe misurando quello che dice');

    final acceso = scendiEAcceso(tester);
    print('ORDINE EE VOCE 14, col solo incontro: il pulsante e\' '
        '${acceso ? "acceso" : "spento"}');
    expect(acceso, isTrue,
        reason: 'chi ha scelto "Solo incontro" ha fatto una scelta, e non '
            'puo\' scendere');
  });
}
