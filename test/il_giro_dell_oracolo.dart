import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// **IL GIRO DELL'ORACOLO DEGLI ANGELI, COME LO FA UNA PERSONA.** Ordine FY
/// voci FY.15 e FY.16, 16 ottobre 2026: la domanda si affida, poi si
/// scelgono le tre carte dal mazzo coperto col ventaglio della Stesa, poi il
/// pulsante dipinto avvia la lettura. Le prove che montano l'Oracolo passano
/// tutte da qui, cosi' il giro e' uno solo.

/// I dorsi che si toccano, nell'ordine: Custode, Cuore, Intelletto. Stanno
/// nella finestra iniziale del ventaglio (il centro e' a meta' dei 72).
const List<int> dorsiDelGiro = [33, 36, 39];

/// Scrive la domanda e la affida: si apre il mazzo coperto.
Future<void> affidaLaDomanda(WidgetTester tester, String domanda) async {
  await tester.enterText(
      find.byKey(const Key('oracolo_campo_domanda')), domanda);
  await tester.pump();
  await tester.tap(find.byKey(const Key('oracolo_affida')));
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Tocca un dorso del ventaglio sul suo lembo sinistro: il dorso accanto,
/// disegnato sopra, ne copre il centro.
Future<void> toccaIlDorso(WidgetTester tester, int indice) async {
  final dorso = find.byKey(Key('stesa_fan_$indice'));
  // Come una persona: si tocca quando la pagina ha smesso di scorrere (uno
  // scorrimento in corso prende il tocco per se').
  final pagina =
      tester.state<ScrollableState>(find.byType(Scrollable).first).position;
  for (var i = 0; i < 30 && pagina.isScrollingNotifier.value; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  // La schermata ha gia' portato il mazzo in fondo alla finestra, con
  // l'altare in vista sopra: si scorre solo se il dorso non si vede, e
  // allora al centro (in cima starebbe sotto la barra del titolo, che prende
  // il tocco).
  final finestra = tester.view.physicalSize / tester.view.devicePixelRatio;
  var r = tester.getRect(dorso);
  if (r.top < 100 || r.bottom > finestra.height) {
    await Scrollable.ensureVisible(tester.element(dorso), alignment: 0.5);
    await tester.pump();
    r = tester.getRect(dorso);
  }
  await tester.tapAt(Offset(r.left + 12, r.center.dy));
  await tester.pump(const Duration(milliseconds: 300));
}

/// Sceglie le tre carte dal mazzo coperto.
Future<void> scegliLeTreCarte(WidgetTester tester,
    [List<int> dorsi = dorsiDelGiro]) async {
  for (final d in dorsi) {
    await toccaIlDorso(tester, d);
  }
}

/// Tocca il pulsante dipinto e lascia andare la lettura fino al responso:
/// le lettere (2,4 s), il giro delle carte (1,5 s) e lo scorrimento.
Future<void> avviaLaLettura(WidgetTester tester) async {
  final pulsante = find.byKey(const Key('oracolo_avvia_la_lettura'));
  await Scrollable.ensureVisible(tester.element(pulsante), alignment: 0.5);
  await tester.pump();
  await tester.tap(pulsante);
  for (var i = 0; i < 50; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Il giro intero: domanda, tre carte, pulsante.
Future<void> consultaLOracolo(WidgetTester tester, String domanda) async {
  await affidaLaDomanda(tester, domanda);
  await scegliLeTreCarte(tester);
  await avviaLaLettura(tester);
}
