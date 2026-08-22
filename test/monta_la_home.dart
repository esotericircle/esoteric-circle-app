import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// MONTA LA HOME PER LA MISURA SUI PIXEL. Ordine BA voce 02.
///
/// **Sta in un file a parte perche' la misura ha bisogno di una cosa che le
/// prove sorelle non hanno**: un `RepaintBoundary` con una chiave, per poter
/// dipingere la scena in un'immagine. Metterlo dentro `lib` sarebbe stato un
/// pezzo di prova nel prodotto.
Future<void> montaLaHomePerLaMisura(
  WidgetTester tester,
  (Size, double) misura,
) async {
  SharedPreferences.setMockInitialValues(
      const {'onboarding.done': true, 'santuario.greeted': true});
  tester.view.physicalSize = misura.$1;
  tester.view.devicePixelRatio = misura.$2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(RepaintBoundary(
    key: const Key('la_home_intera'),
    child: EsotericCircleApp(conIntro: false, services: AppServices.offline()),
  ));
  await tester.pump();
  await tester.pump(const Duration(seconds: 4));
  // **LA SCENA SI ASSESTA IN PIU' DI UN FOTOGRAMMA**, come nella prova
  // sorella: la misura vera arriva dopo il primo disegno.
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

/// **LA FASCIA DI SCHERMO CHE PORTA IL TESTO SOPRA I MAESTRI.**
///
/// Va dal titolo del cielo alla fine della riga della fase lunare: e' cio' che
/// il fondatore vede coperto. Si prende dai rettangoli **solo per sapere DOVE
/// guardare**: i pixel dentro quella fascia poi si contano uno per uno, ed e'
/// li' che la misura diventa onesta.
Rect fasciaDelTesto(WidgetTester tester) {
  Rect? scatola(Finder f) {
    final trovati = f.evaluate();
    if (trovati.isEmpty) return null;
    final ro = trovati.first.renderObject;
    if (ro is! RenderBox || !ro.hasSize || !ro.attached) return null;
    return ro.localToGlobal(Offset.zero) & ro.size;
  }

  final pezzi = <Rect>[
    for (final f in [
      find.byKey(const Key('santuario_sky_title')),
      find.byKey(const Key('santuario_riga_personale')),
      find.descendant(
          of: find.byKey(const Key('santuario_sky_tap')),
          matching: find.byType(Text)),
    ])
      ...[if (scatola(f) != null) scatola(f)!],
  ];
  if (pezzi.isEmpty) return Rect.zero;
  var fascia = pezzi.first;
  for (final p in pezzi.skip(1)) {
    fascia = fascia.expandToInclude(p);
  }
  return fascia;
}
