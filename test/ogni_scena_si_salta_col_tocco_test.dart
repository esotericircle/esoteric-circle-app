// ignore_for_file: avoid_print
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'sorgenti_di_lib.dart';

/// **OGNI SCENA SI SALTA COL TOCCO, DAL PUNTO UNICO.** Ordine FU voce FU.15,
/// 15 ottobre 2026. Il fondatore: *"bisogna fare in modo che con un click il
/// video possa sparire in dissolvenza. Dopo un po' stanca, se qualcuno
/// accede spesso o ripetutamente"*; e il punto deve valere *"per ogni scena
/// futura"*.
///
/// Una scena e' una schermata che apre un lettore di scena: il lettore
/// comune (`LettoreDiScena`, `RegiaDellaScena`) o uno dei due di prima, della
/// Stesa e della Sinastria evolutiva (`LettoreDellaScena...vero`). Ognuna
/// deve montare `IlToccoCheSalta`, il punto unico in
/// `lib/features/scene/la_scena_in_video.dart`. La prova cade col nome della
/// scena che non ci passa.
void main() {
  test('ogni scena dell\'app passa dal tocco che salta', () {
    // Chi APRE un lettore: la fabbrica passata come funzione
    // (`LettoreDellaScena.vero)()`), il lettore comune o la sua regia. Chi ne
    // dichiara soltanto la fabbrica (`factory ... .vero() =`) non e' una
    // scena.
    final apreUnaScena = RegExp(
        r'LettoreDellaScena\w*\.vero\)|RegiaDellaScena\(|LettoreDiScena\.vero\(');
    final scene = <String>[];
    final fuori = <String>[];
    for (final f in sorgentiDiLib()) {
      final p = f.path.replaceAll('\\', '/');
      if (p.endsWith('lib/features/scene/la_scena_in_video.dart')) continue;
      final testo = f.readAsStringSync();
      if (!apreUnaScena.hasMatch(testo)) continue;
      scene.add(p.substring(p.indexOf('lib/')));
      if (!testo.contains('IlToccoCheSalta(')) {
        fuori.add(p.substring(p.indexOf('lib/')));
      }
    }
    scene.sort();
    print('ORDINE FU VOCE FU.15: scene trovate ${scene.length}: $scene');
    cardinaleMinimo(scene.length, 2,
        cosa: 'scene che aprono un lettore',
        perche: 'La Stesa e la Sinastria evolutiva ci sono dall\'ordine FT: '
            'se la prova non le trova, il riconoscimento si e\' rotto e '
            'sarebbe verde senza aver guardato niente.');
    expect(fuori, isEmpty,
        reason: 'queste scene aprono un video e non passano dal tocco che lo '
            'salta, IlToccoCheSalta: $fuori');
  });
}
