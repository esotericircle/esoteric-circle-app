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

/// **NESSUNA SCHEDA DOPPIA IN VISTA NELLA HOME.** Richiesta del fondatore del
/// 26 settembre 2026, a ordine EO aperto:
///
/// *"dalla apertura della home Senza spostare le categorie verso destra, fai
/// in modo che scorrendo verso il basso non si vedano la stessa scheda
/// funzionalità. Così l'utente non si accorge subito che ci sono doppioni e
/// cmq vedrà a colpo d'occhio più funzionalità tutte di diverse. Se capitasse
/// z cambia ordine di apparizione orizzontale e sposta la scheda doppione
/// fuori dalla vista, cioè verso il fondo orizzontale della categoria."*
///
/// **Si misura sulla resa**: si monta la composizione vera della home, si
/// prendono in ogni riga le schede il cui bordo sinistro cade dentro lo
/// schermo senza scorrere di lato, e si contano le arti gia' viste in una
/// riga sopra. Il solo doppione ammesso e' quello **inevitabile**: una riga
/// che non ha abbastanza arti nuove per riempire la sua vista.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<({int doppioni, int inevitabili, int schede})> misura(
      WidgetTester tester, Size fisica, double scala) async {
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
    var doppioni = 0, inevitabili = 0, schede = 0;
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
      final qui = ids.where(viste.contains).toList();
      doppioni += qui.length;
      // Inevitabili: i posti in vista che le arti nuove della riga non
      // bastano a riempire.
      final nuove = r.arti.where((a) => !viste.contains(a.id)).length;
      final mancano = ids.length - nuove;
      inevitabili += mancano > 0 ? mancano : 0;
      if (qui.isNotEmpty) {
        debugPrint('DOPPIONI IN VISTA in ${r.chiave}: $qui');
      }
      viste.addAll(ids);
    }
    return (doppioni: doppioni, inevitabili: inevitabili, schede: schede);
  }

  for (final (nome, fisica, scala) in const [
    ('360 punti', Size(1080, 2400), 1.0),
    ('390 punti', Size(1170, 2532), 1.0),
    ('412 punti', Size(1236, 2745), 1.0),
    ('360 punti, testo 1,3', Size(1080, 2400), 1.3),
  ]) {
    testWidgets('nessuna scheda doppia in vista, $nome', (tester) async {
      final m = await misura(tester, fisica, scala);
      // ignore: avoid_print
      print('DOPPIONI IN VISTA, $nome: ${m.doppioni} su ${m.schede} schede '
          'in vista, inevitabili ${m.inevitabili}');
      // Almeno una per riga su dieci righe: a testo 1,3 le schede
      // orizzontali sono larghe quasi quanto lo schermo, e in vista ne resta
      // una sola (misurato: 14 schede in vista in tutto).
      cardinaleMinimo(m.schede, 10,
          cosa: 'schede in vista nelle dieci righe',
          perche: 'almeno una per riga, a qualunque larghezza.');
      expect(m.doppioni, m.inevitabili,
          reason: 'in vista ci sono ${m.doppioni} arti gia\' viste in una riga '
              'sopra, e solo ${m.inevitabili} erano inevitabili');
    });
  }

  test('una riga ordinata tiene tutte le sue arti, nessuna in piu\'', () {
    final righe = [
      (
        arti: LeRigheDellaCasa.artiDi(ArtiPreferiteController.seiDellOrdineEO),
        visibili: 2
      ),
      for (final r in LeRigheDellaCasa.righe)
        (arti: LeRigheDellaCasa.artiDi(r.arti), visibili: 2),
    ];
    final ordinate = LeRigheDellaCasa.senzaDoppioniInVista(righe);
    for (var i = 0; i < righe.length; i++) {
      expect(ordinate[i].map((a) => a.id).toSet(),
          righe[i].arti.map((a) => a.id).toSet());
      expect(ordinate[i].length, righe[i].arti.length);
    }
  });
}
