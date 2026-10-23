import 'cardinale_minimo.dart';
import 'package:flutter_test/flutter_test.dart';

import 'sorgenti_di_lib.dart';

/// **LA GRAFICA E' DIPINTA, NON DISEGNATA (R9).** Ordine FV, 15 ottobre
/// 2026. Il fondatore: *"vorrei evitare il più possibile la grafica
/// procedurale"*. Lune, emblemi, sigilli, aloni, scia, castone, seme e
/// sfondo della card del Calendario Lunare sono gli asset dipinti di P1 e
/// P2 e le foto della voce FV.03: Flutter disegna solo testo, posizioni,
/// dissolvenze, opacita' e movimenti di quegli asset.
///
/// La guardia scorre `lib/features/lunario/` e `lib/core/lunario/` (fuori i
/// `.g.dart`, generati, mai scritti a mano) e cade se un sorgente:
/// - disegna con un `CustomPainter` o monta un `CustomPaint`, la via diretta
///   per dipingere una forma col codice al posto di un asset;
/// - posa un `BoxShape.circle` o un `RadialGradient`, il modo piu' comune di
///   fingere un alone o una Luna senza l'asset vero;
/// - mostra un'icona di Material fuori dall'elenco dichiarato degli
///   [iconeDiInterfaccia]: quelle sono chrome dell'interfaccia (il lucchetto
///   Premium di tutta la casa, le spunte di selezione, la chiave del
///   consenso alla nascita, l'icona "scegli amici"), non un sostituto di un
///   sigillo o di una Luna dipinta. Un'icona nuova, non dichiarata qui, e'
///   sospetta per definizione: la guardia la nomina col file.
///
/// **TROVATO IL 15 OTTOBRE 2026, PRIMA DI SCRIVERE QUESTA GUARDIA**: la
/// casella del giorno di "Trova il giorno insieme" segnava con una stella
/// di Material (`Icons.star_rounded`) il giorno che era anche un giorno tuo
/// di qualcuno del gruppo, al posto del sigillo dipinto del tipo
/// (`SegnoDelGiornoTuo.sigillo`, lo stesso della griglia del mese). Padre:
/// la voce FV.10 stessa, scritta prima che questa guardia esistesse.
/// Corretto in `trova_il_giorno_insieme.dart` prima di questo commit:
/// `_GiornoInsieme` mostra ora i sigilli veri, fino a tre, deduplicati.
void main() {
  test('nessun CustomPainter, nessun cerchio o alone finto, '
      'solo icone di interfaccia dichiarate', () {
    final file = sorgentiDiLib()
        .where((f) => f.path.replaceAll(r'\', '/').contains('/lunario/'))
        .where((f) => !f.path.endsWith('.g.dart'))
        .toList();
    cardinaleMinimo(file.length, 15,
        cosa: 'sorgenti non generati di lib/features/lunario e '
            'lib/core/lunario',
        perche: 'la guardia della grafica dipinta (R9) scorre questi file: '
            'se l\'elenco si svuota diventa verde senza aver guardato '
            'niente.');

    const iconeDiInterfaccia = {
      'lock_rounded', // Premium bloccata, come in tutta la casa.
      'people_alt_rounded', // Il pulsante "scegli amici".
      'check_circle_rounded', // La spunta di selezione di un amico.
      'radio_button_unchecked', // La spunta non scelta.
      'key_rounded', // Il consenso alla nascita dato.
      'key_off_rounded', // Il consenso alla nascita non dato.
    };

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
