// ignore_for_file: avoid_print
import 'dart:convert';

import 'package:esoteric_circle/core/amici/amici_offline.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/listino_degli_eos.dart';
import 'package:esoteric_circle/core/entitlement/plan_catalog.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/amici/amici_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **GLI AMICI OFFLINE HANNO UN NUMERO ANCHE ALL'ILLUMINATO, ordine EZ voce
/// 06.** Il fondatore il 29 agosto 2026: "illimitato mi espone all'abuso o
/// uso incontrollato o bot". Viandante 0, Iniziato 3, Adepto 10, Illuminato
/// 50: il numero vive nella matrice dei piani, il listino non dice piu'
/// "senza tetto", e chi aveva gia' piu' schede non ne perde nessuna.
void main() {
  const ordine = [Tier.free, Tier.tier1, Tier.tier2, Tier.tier3];

  test('EZ.06: zero "senza limite" su quattro piani, nella matrice e nel '
      'listino', () async {
    SharedPreferences.setMockInitialValues({});
    final riga =
        PlanCatalog.matrix.where((r) => r.chiave == RigaDelPiano.amici).single;
    final a = AmiciOffline();
    await a.carica();
    final senzaLimite = [
      for (var i = 0; i < 4; i++)
        if (riga.values[i].toLowerCase() != 'no' &&
            int.tryParse(riga.values[i]) == null)
          'matrice ${ordine[i].name}: ${riga.values[i]}',
      for (final t in ordine)
        if (ListinoDegliEos.amicoInPiu.gratisAlGiorno[t] == null)
          'listino ${t.name}: nullo',
      for (final t in ordine)
        if (a.posti(t) == null) 'posti ${t.name}: nullo',
    ];
    print('EZ.06 GLI AMICI OFFLINE: matrice ${riga.values}, posti '
        '${[for (final t in ordine) a.posti(t)]}, senza limite '
        '${senzaLimite.length} $senzaLimite');
    expect(senzaLimite, isEmpty);
    expect([for (final t in ordine) a.posti(t)], [0, 3, 10, 50]);
    expect(ListinoDegliEos.amicoInPiu.costo, 100,
        reason: 'il posto in piu\' resta la voce che esisteva, a 100 Eos');
  });

  testWidgets('EZ.06: chi ha gia\' piu\' di cinquanta schede le tiene, non ne '
      'aggiunge, e la riga glielo dice', (tester) async {
    final schede = [
      for (var i = 0; i < 55; i++)
        Amico(
            id: 'a$i',
            nome: 'Amico $i',
            nascita: DateTime(1980 + i % 30, 1 + i % 12, 1 + i % 27)),
    ];
    SharedPreferences.setMockInitialValues({
      'amici_offline': jsonEncode([for (final s in schede) s.toJson()]),
    });
    final a = AmiciOffline();
    await a.carica();
    expect(a.tutti.length, 55, reason: 'qualcuno ha perso delle schede');
    expect(await a.aggiungi(schede.first, Tier.tier3), isFalse);
    expect(a.tutti.length, 55);
    tester.view.physicalSize = const Size(1080, 2391);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => EntitlementService(initial: Tier.tier3)),
      ],
      child: MaterialApp(
          home: MaestroScope(
              maestro: Maestro.medora, child: AmiciScreen(amici: a))),
    ));
    await tester.pump();
    final riga = find.byKey(const Key('amici_posti'));
    await tester.scrollUntilVisible(riga, 500,
        scrollable: find.byType(Scrollable).first);
    final testo = tester.widget<Text>(riga).data!;
    print('EZ.06 OLTRE IL NUMERO: "$testo"');
    expect(testo, contains('restano tutti'));
    expect(find.byKey(const Key('amici_aggiungi')), findsNothing);
  });
}
