import 'cardinale_minimo.dart';
import 'package:flutter_test/flutter_test.dart';

import 'sorgenti_di_lib.dart';

/// **LA GRAFICA E' DIPINTA, NON DISEGNATA (R9).** Ordine FX, 16 ottobre
/// 2026. Il fondatore: *"Usiamo nano banana, video e tutto ciò che serve"*.
/// Scena, perle, fermaglio, catenella, medaglia, scrigno, quadrante, ago e
/// scia sono gli asset dipinti di P1; le Lune sono le foto della NASA (il
/// Dial-A-Moon, o le trenta lune locali di ripiego): Flutter disegna solo
/// testo, posizioni, dissolvenze, opacita', rotazioni e movimenti di quegli
/// asset.
///
/// **La stessa regola del Calendario Lunare (ordine FV), una guardia in
/// più.** `la_grafica_del_lunario_e_dipinta_test.dart` scorre i file il cui
/// percorso contiene `/lunario/`: `lib/core/lunario/` (dove vivono anche i
/// file nuovi di questo ordine: `il_dial_a_moon.dart`,
/// `la_collana_delle_lune.dart`, eccetera) è già coperta da lei. Questa
/// guardia scorre invece `lib/features/respiro_della_luna/`, che non
/// contiene quella sottostringa e sarebbe passata sotto silenzio senza una
/// guardia propria.
void main() {
  test('nessun CustomPainter, nessun cerchio o alone finto, '
      'solo icone di interfaccia dichiarate', () {
    final file = sorgentiDiLib()
        .where((f) =>
            f.path.replaceAll(r'\', '/').contains('/respiro_della_luna/'))
        .where((f) => !f.path.endsWith('.g.dart'))
        .toList();
    cardinaleMinimo(file.length, 6,
        cosa: 'sorgenti non generati di lib/features/respiro_della_luna',
        perche: 'la guardia della grafica dipinta (R9) scorre questi file: '
            'se l\'elenco si svuota diventa verde senza aver guardato '
            'niente.');

    // Nessuna icona di interfaccia dichiarata finora: ogni icona trovata è
    // sospetta per definizione, e la guardia la nomina col file.
    const iconeDiInterfaccia = <String>{};

    final colpeCustomPaint = <String>[];
    final colpeCerchio = <String>[];
    final colpeIcone = <String>[];
    for (final f in file) {
      final percorso = f.path.replaceAll(r'\', '/');
      final testo = f.readAsStringSync();
      if (testo.contains('CustomPaint') || testo.contains('CustomPainter')) {
        colpeCustomPaint.add(percorso);
      }
      if (testo.contains('BoxShape.circle') ||
          testo.contains('RadialGradient')) {
        colpeCerchio.add(percorso);
      }
      for (final m in RegExp(r'Icons\.([a-zA-Z0-9_]+)').allMatches(testo)) {
        final nome = m.group(1)!;
        if (!iconeDiInterfaccia.contains(nome)) {
          colpeIcone.add('$percorso: Icons.$nome');
        }
      }
    }
    expect(colpeCustomPaint, isEmpty,
        reason: 'disegnano con CustomPaint/CustomPainter invece di un '
            'asset dipinto:\n${colpeCustomPaint.join('\n')}');
    expect(colpeCerchio, isEmpty,
        reason: 'un cerchio o un alone finto al posto dell\'asset dipinto:'
            '\n${colpeCerchio.join('\n')}');
    expect(colpeIcone, isEmpty,
        reason: 'un\'icona di Material non dichiarata fra quelle di '
            'interfaccia, forse al posto di un asset dipinto:'
            '\n${colpeIcone.join('\n')}');
  });
}
