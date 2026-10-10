import 'dart:io';

import 'package:esoteric_circle/core/primo_uso/suggerimenti_di_zona.dart';
import 'package:esoteric_circle/design_system/components/suggerimento_al_primo_uso.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:provider/provider.dart';
import 'package:esoteric_circle/features/onboarding/primo_approdo.dart';

/// I SUGGERIMENTI AL PRIMO USO. Ordine CE voce 12.
///
/// **I TRE VINCOLI DEL FONDATORE, e sono quello che questa prova misura.** Si
/// vede una volta sola, non blocca, non e' un popup che si mette in mezzo. Il
/// fondatore ha appena fatto togliere due fogli dal Santuario perche' li
/// considerava un ostacolo: la prova esiste perche' questa voce non rimetta lo
/// stesso ostacolo con un altro nome.
///
/// **LE ZONE SI ENUMERANO, non se ne prova una.** Una prova su un caso vale
/// finche' nessuno aggiunge la quinta zona, e chi la aggiunge non ha modo di
/// sapere che c'era una regola da rispettare. Qui si gira su
/// `ZonaDelCerchio.values`: una zona nuova entra da sola in tutte e tre le
/// misure.
void main() {
  Widget scena(ZonaDelCerchio zona, {VoidCallback? alTocco}) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
        ],
        child: MaterialApp(
          home: MaestroScope(
            child: Scaffold(
              body: Column(
                children: [
                  SuggerimentoAlPrimoUso(zona: zona),
                  // Il gesto della zona, messo SOTTO il suggerimento: e' il
                  // punto in cui un foglio, un velo o una barriera lo
                  // spegnerebbero.
                  FilledButton(
                    key: const Key('gesto_della_zona'),
                    onPressed: alTocco ?? () {},
                    child: const Text('Il gesto'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  testWidgets('armati, ogni zona si presenta una volta e non torna',
      (tester) async {
    for (final zona in ZonaDelCerchio.values) {
      // **IL DISCO SI AZZERA DAVVERO A OGNI GIRO.** `setMockInitialValues`
      // cambia il magazzino ma non l'istanza gia' consegnata: senza questa
      // riga la prima zona passava e le altre tre trovavano il disco della
      // prima, cioe' la prova girava a vuoto su tre casi su quattro.
      SharedPreferences.resetStatic();
      SharedPreferences.setMockInitialValues(
          {MemoriaDeiSuggerimenti.chiaveArmata: true});
      await tester.pumpWidget(scena(zona));
      await tester.pumpAndSettle();
      expect(find.byKey(SuggerimentoAlPrimoUso.chiaveDi(zona)), findsOneWidget,
          reason: 'la zona ${zona.chiave} non si presenta nemmeno la prima '
              'volta');
      // Il ritorno: stessa zona, stesso disco, e adesso deve tacere.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(scena(zona));
      await tester.pumpAndSettle();
      expect(find.byKey(SuggerimentoAlPrimoUso.chiaveDi(zona)), findsNothing,
          reason: 'la zona ${zona.chiave} si ripresenta al ritorno: e\' la '
              'ripetizione che il fondatore ha gia\' rifiutato');
    }
  });

  testWidgets('non armati, nessuna zona dice niente', (tester) async {
    // **NON NASCONO ACCESI.** Un avviso che nascesse acceso comparirebbe in
    // ogni prova e in ogni anteprima, dove il disco e' vuoto: e' la famiglia
    // di guasti che questo progetto ha gia' pagato col velo del tutorial.
    for (final zona in ZonaDelCerchio.values) {
      SharedPreferences.resetStatic();
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(scena(zona));
      await tester.pumpAndSettle();
      expect(find.byKey(SuggerimentoAlPrimoUso.chiaveDi(zona)), findsNothing,
          reason: 'la zona ${zona.chiave} si accende senza che nessuno abbia '
              'armato i suggerimenti');
    }
  });

  testWidgets('mentre si vede, il gesto della zona funziona', (tester) async {
    // **NON BLOCCA: e non si misura leggendo il codice, si misura toccando.**
    // Un velo, una barriera o un `AbsorbPointer` non si vedono in un
    // sorgente che non li nomina: si vedono qui, dove il dito tocca il
    // pulsante mentre il suggerimento e' a video e il conto deve salire.
    for (final zona in ZonaDelCerchio.values) {
      // **IL DISCO SI AZZERA DAVVERO A OGNI GIRO.** `setMockInitialValues`
      // cambia il magazzino ma non l'istanza gia' consegnata: senza questa
      // riga la prima zona passava e le altre tre trovavano il disco della
      // prima, cioe' la prova girava a vuoto su tre casi su quattro.
      SharedPreferences.resetStatic();
      SharedPreferences.setMockInitialValues(
          {MemoriaDeiSuggerimenti.chiaveArmata: true});
      var tocchi = 0;
      await tester.pumpWidget(scena(zona, alTocco: () => tocchi++));
      await tester.pumpAndSettle();
      expect(find.byKey(SuggerimentoAlPrimoUso.chiaveDi(zona)), findsOneWidget);
      await tester.tap(find.byKey(const Key('gesto_della_zona')));
      await tester.pump();
      expect(tocchi, 1,
          reason: 'col suggerimento della zona ${zona.chiave} a video il '
              'gesto non passa: e\' un ostacolo, ed e\' esattamente cio\' che '
              'il fondatore ha fatto togliere');
    }
  });

  testWidgets('la crocetta lo manda via, e non e\' un pedaggio',
      (tester) async {
    // Chi non la tocca ha comunque finito: il suggerimento si segna visto
    // quando COMPARE, non quando si chiude. La crocetta serve a chi lo vuole
    // via subito, e a nessun altro.
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues(
        {MemoriaDeiSuggerimenti.chiaveArmata: true});
    const zona = ZonaDelCerchio.dominio;
    await tester.pumpWidget(scena(zona));
    await tester.pumpAndSettle();
    final p = await SharedPreferences.getInstance();
    expect(p.getBool(zona.chiaveDiMemoria), isTrue,
        reason: 'si segna visto solo se lo chiudi: chi legge e se ne va se lo '
            'ritrova al ritorno');
    await tester.tap(find.byKey(Key('suggerimento_via_${zona.chiave}')));
    await tester.pumpAndSettle();
    expect(find.byKey(SuggerimentoAlPrimoUso.chiaveDi(zona)), findsNothing);
  });

  test('le due meta\' dell\'arrivo si armano insieme', () async {
    // **UNA SPIEGAZIONE SOLA IN DUE TEMPI.** Il tutorial e i suggerimenti sono
    // la stessa decisione del fondatore del 28 agosto 2026, e si accendono
    // dallo stesso gesto: chi finisce il tutorial e' pronto a incontrare le
    // zone. Se domani qualcuno arma solo la prima meta', questa riga cade.
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({});
    await MemoriaDelPrimoApprodo.segnaVisto();
    final p = await SharedPreferences.getInstance();
    expect(p.getBool(MemoriaDeiSuggerimenti.chiaveArmata), isTrue,
        reason: 'finito il tutorial i suggerimenti restano spenti: la seconda '
            'meta\' dell\'arrivo non arriva mai');

    // E chi chiede di rivedere il tutorial rivede anche le zone.
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({
      MemoriaDeiSuggerimenti.chiaveArmata: true,
      ZonaDelCerchio.dominio.chiaveDiMemoria: true,
    });
    await MemoriaDelPrimoApprodo.rivedi();
    final q = await SharedPreferences.getInstance();
    expect(q.getBool(ZonaDelCerchio.dominio.chiaveDiMemoria), isNull,
        reason: 'rivedere meta\' spiegazione non e\' rivedere la spiegazione');
  });

  test('nessuna zona apre un foglio, un velo o una barriera', () {
    // La forma si guarda anche nel sorgente, perche' una barriera aggiunta
    // domani passerebbe le prove di sopra solo se qualcuno le rieseguisse
    // pensando a questo: qui il divieto e' scritto.
    final s =
        File('lib/design_system/components/suggerimento_al_primo_uso.dart')
            .readAsStringSync();
    final vietati = <String>[
      'showModalBottomSheet',
      'showDialog',
      'ModalBarrier',
      'AbsorbPointer',
      'IgnorePointer',
      'Overlay.of',
    ];
    final trovati = <String>[];
    for (final v in vietati) {
      // Si guardano le righe vive, non i commenti che spiegano cosa NON si fa.
      for (final r in s.split('\n')) {
        final t = r.trimLeft();
        if (t.startsWith('//') || t.startsWith('///')) continue;
        if (r.contains(v)) trovati.add(v);
      }
    }
    // ignore: avoid_print
    print('ORDINE CE VOCE 12: zone che si presentano '
        '${ZonaDelCerchio.values.length}, forme che si mettono in mezzo '
        '${trovati.length}');
    expect(trovati, isEmpty,
        reason: 'il suggerimento e\' tornato a essere un ostacolo: $trovati');
  });

  test('i testi sono dichiarati provvisori nel codice', () {
    // **I TESTI DEFINITIVI LI APPROVA IL FONDATORE.** Il vincolo dell'ordine
    // dice che le parole nuove si scrivono provvisorie e si marcano come
    // tali: questa riga lo pretende, cosi' nessuno le prende per approvate.
    final s =
        File('lib/core/primo_uso/suggerimenti_di_zona.dart').readAsStringSync();
    expect(s.contains('TESTO PROVVISORIO'), isTrue,
        reason: 'le parole delle quattro zone non dicono piu\' di essere '
            'provvisorie, e domani qualcuno le credera\' approvate');
    for (final z in ZonaDelCerchio.values) {
      expect(z.titolo.trim(), isNotEmpty);
      expect(z.testo.trim(), isNotEmpty);
    }
  });
}
