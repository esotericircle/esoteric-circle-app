import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// **ALZARE IL SOLE, nelle prove.** Ordine EL, 25 settembre 2026.
///
/// L'Arcano dell'Alba si apre col gesto del sole (`IlSoleDellAlba`), e le
/// prove che arrivano alle carte ci passano come la persona, invece di
/// saltarlo: una prova che lo saltasse non vedrebbe piu' l'ingresso vero, ed
/// e' cosi' che l'ingresso si era perso la prima volta senza che nessuna prova
/// se ne accorgesse.
///
/// Prima del gesto si pretende che il sole ci sia e che il tavolo NON ci sia:
/// ogni prova che apre l'Arcano sorveglia anche l'ordine delle due cose. Poi
/// un tocco, il ripiego tattile che compie l'alba; il sole sale in 750
/// millesimi, la scena resta illuminata 450 e si dissolve in 700 sopra il
/// tavolo che entra. Si avanza a passi, perche' il tavolo respira senza fine
/// e `pumpAndSettle` non tornerebbe.
Future<void> alzaIlSole(WidgetTester tester) async {
  final sole = find.byKey(const Key('arcano_alba_sole'));
  expect(sole, findsOneWidget,
      reason: 'l\'Arcano dell\'Alba non si apre col gesto del sole');
  expect(find.byKey(const Key('arcano_alba_carta_0')), findsNothing,
      reason: 'le carte sono in scena prima che il sole sia salito');
  await tester.tap(sole);
  for (var i = 0; i < 24; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(sole, findsNothing,
      reason: 'a sole salito la scena dell\'alba non se ne va');
}
