// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/arts/arti_preferite.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/santuario/le_righe_della_casa.dart';
import 'package:esoteric_circle/features/schede/la_riga_delle_schede.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cardinale_minimo.dart';

/// **I DOPPIONI DELLA HOME SONO VOLUTI.** Ordine ER voce 08, 27 settembre
/// 2026.
///
/// **LAPIDE.** Questo file si chiamava `nessun_doppione_in_vista_test.dart` e
/// sorvegliava la richiesta del fondatore del 26 settembre 2026: *"fai in
/// modo che scorrendo verso il basso non si vedano la stessa scheda
/// funzionalità [...] sposta la scheda doppione fuori dalla vista"*. La regola
/// stava in `LeRigheDellaCasa.senzaDoppioniInVista`.
///
/// **Il fondatore l'ha tolta**: *"Ok, togli regola del 26 settembre"*, e
/// *"le categorie della home sono create per duplicare o triplicare alcune
/// arti, le più virali, per dar loro maggiore visibilità"*. Adesso ogni riga
/// mostra le sue arti nell'ordine scritto, anche quando un'arte si vede gia'
/// in una riga piu' su.
///
/// **La grandezza misurata e' l'ordine in vista**: in ogni riga, le schede il
/// cui bordo sinistro cade dentro lo schermo devono essere le prime arti
/// dell'elenco della riga, nel suo ordine. Un'arte spostata in fondo perche'
/// gia' vista e' il difetto che questa prova cerca.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<({int spostate, int doppioni, int schede, List<String> esempi})>
      misura(WidgetTester tester, Size fisica, double scala) async {
    SharedPreferences.setMockInitialValues(const {});
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = fisica;
    addTearDown(tester.view.reset);
    final pref = ArtiPreferiteController();
    addTearDown(pref.dispose);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider<ArtiPreferiteController>.value(value: pref),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (ctx, child) => MediaQuery(
          data:
              MediaQuery.of(ctx).copyWith(textScaler: TextScaler.linear(scala)),
          child: MaestroScope(child: child!),
        ),
        home: const Scaffold(
          body: SingleChildScrollView(
              child: LeRigheDellaCasaView(sensore: false)),
        ),
      ),
    ));
    await tester.pump();
    final larghezza = fisica.width / 3.0;
    final righe = tester
        .widgetList<LaRigaDelleSchede>(find.byType(LaRigaDelleSchede))
        .toList();
    final viste = <String>{};
    final esempi = <String>[];
    var spostate = 0, doppioni = 0, schede = 0;
    for (final r in righe) {
      final prefisso = 'riga_${r.chiave}_';
      final inVista = <(double, String)>[];
      for (final e in find
          .byWidgetPredicate((w) =>
              w.key is ValueKey<String> &&
              (w.key! as ValueKey<String>).value.startsWith(prefisso))
          .evaluate()) {
        final id = (e.widget.key! as ValueKey<String>)
            .value
            .substring(prefisso.length);
        final sinistra = tester.getTopLeft(find.byKey(Key('$prefisso$id'))).dx;
        if (sinistra < larghezza) inVista.add((sinistra, id));
      }
      inVista.sort((a, b) => a.$1.compareTo(b.$1));
      final ids = [for (final (_, id) in inVista) id];
      schede += ids.length;
      final attese = [for (final a in r.arti.take(ids.length)) a.id];
      for (var k = 0; k < ids.length; k++) {
        if (ids[k] != attese[k]) spostate++;
      }
      for (final id in ids) {
        if (viste.contains(id)) {
          doppioni++;
          if (esempi.length < 4) esempi.add('$id in ${r.chiave}');
        }
      }
      viste.addAll(ids);
    }
    return (
      spostate: spostate,
      doppioni: doppioni,
      schede: schede,
      esempi: esempi
    );
  }

  for (final (nome, fisica, scala) in const [
    ('360 punti', Size(1080, 2400), 1.0),
    ('390 punti', Size(1170, 2532), 1.0),
    ('412 punti', Size(1236, 2745), 1.0),
    ('360 punti, testo 1,3', Size(1080, 2400), 1.3),
  ]) {
    testWidgets('ER.08: nessuna arte spostata dalla regola dei doppioni, $nome',
        (tester) async {
      final m = await misura(tester, fisica, scala);
      print('ORDINE ER VOCE 8, $nome: arti spostate dalla regola dei doppioni '
          '${m.spostate} su ${m.schede} schede in vista; doppioni voluti in '
          'vista ${m.doppioni} ${m.esempi}');
      cardinaleMinimo(m.schede, 11,
          cosa: 'schede in vista nelle undici righe',
          perche: 'almeno una per riga, a qualunque larghezza.');
      expect(m.spostate, 0,
          reason: 'in vista ci sono arti fuori dall\'ordine della loro riga: '
              'la regola dei doppioni e\' tornata');
    });
  }

  test('ER.08: la regola dei doppioni non vive piu\' nel codice della home',
      () {
    final sorgente = File('lib/features/santuario/le_righe_della_casa.dart')
        .readAsStringSync()
        .split('\n')
        .where((r) => !r.trimLeft().startsWith('//'))
        .join('\n');
    expect(sorgente, isNot(contains('senzaDoppioniInVista(')),
        reason: 'la regola del 26 settembre e\' ancora nel codice');
  });
}
