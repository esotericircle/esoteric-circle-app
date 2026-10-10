import 'package:esoteric_circle/core/horoscope/riflessione_del_cielo.dart';
import 'package:esoteric_circle/features/horoscope/oroscopo_screen.dart';
import 'package:flutter_test/flutter_test.dart';

/// **IL GESTO NELLE PROVE, ordine FC voce 03.**
///
/// Fino all'ordine FC la suite spegneva l'interruttore
/// `InterrogaIlCielo.ancheFuoriDalGiorno`, e le prove dei periodi leggevano la
/// lettura senza toccare il gesto. L'interruttore non c'e' piu': il responso
/// non compare mai da solo. Le prove fanno quello che fa una persona: toccano
/// il gesto, se c'e', e aspettano la riflessione intera (i due momenti pieni,
/// la cascata delle schede e la dissolvenza della corsa).
///
/// Torna vero se il gesto c'era ed e' stato toccato.
Future<bool> interrogaSeCe(WidgetTester tester) async {
  final gesto = find.byType(InterrogaIlCielo);
  if (gesto.evaluate().isEmpty) return false;
  await tester.ensureVisible(gesto.first);
  await tester.pump();
  await tester.tap(gesto.first, warnIfMissed: false);
  await aspettaLaRiflessione(tester);
  return true;
}

/// Il tempo dal tocco alla fine della scena: la riflessione piena, la
/// cascata delle quattro schede, la dissolvenza della corsa, e un margine.
Duration get durataDellaScena =>
    RiflessioneDelCielo.intera(piena: true) +
    RiflessioneDelCielo.passoFraLeSchede * 4 +
    const Duration(milliseconds: 1500);

Future<void> aspettaLaRiflessione(WidgetTester tester) async {
  const passo = Duration(milliseconds: 100);
  for (var t = Duration.zero; t < durataDellaScena; t += passo) {
    await tester.pump(passo);
  }
}
