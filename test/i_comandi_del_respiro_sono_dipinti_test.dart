import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'sorgenti_di_lib.dart';

/// **I COMANDI DEL RESPIRO SONO DIPINTI.** Ordine FX aggiunta FXA.02, 16
/// ottobre 2026.
///
/// Il fondatore, sull'anteprima della collana composta dal codice: *"Non
/// avevo chiesto di evitare grafica procedurale? [...] tutto quello si puo'
/// fare con nano banana o video, lo facciamo!"*. In tutto il Respiro della
/// Luna ogni pulsante, pannello e finestra usa i pezzi dipinti di
/// `lib/features/respiro_della_luna/i_comandi_dipinti.dart`.
///
/// **COSA CADE.** In `lib/features/respiro_della_luna/` (solo codice, i
/// commenti non contano): `FilledButton`, `ElevatedButton`,
/// `OutlinedButton`, `TextButton`, `ActionChip`, `Chip`, `AlertDialog`,
/// `ListTile` usato come voce di menu', e un `BoxDecoration` con un colore
/// pieno al posto di un pezzo dipinto.
///
/// **LE ECCEZIONI, DICHIARATE.** Nessuna: i comandi comuni della barra in
/// alto (la freccia automatica, `FoglioDelleFonti.bottone`,
/// `AngoloDellaBarra`) vivono fuori da questa cartella, come in tutta l'app,
/// e l'interruttore degli avvisi e' `InterruttoreDelCerchio` del design
/// system, l'interruttore unico della casa.
void main() {
  test('nessun comando standard ne\' riquadro pieno nel Respiro della Luna',
      () {
    final file = sorgentiDiLib()
        .where((f) =>
            f.path.replaceAll(r'\', '/').contains('/respiro_della_luna/'))
        .where((f) => !f.path.endsWith('.g.dart'))
        .toList();
    cardinaleMinimo(file.length, 8,
        cosa: 'sorgenti non generati di lib/features/respiro_della_luna',
        perche: 'la guardia dei comandi dipinti (FXA.02) scorre questi file: '
            'se l\'elenco si svuota diventa verde senza aver guardato '
            'niente.');

    const vietati = [
      'FilledButton',
      'ElevatedButton',
      'OutlinedButton',
      'TextButton',
      'ActionChip',
      'AlertDialog',
      'ListTile(',
    ];
    final colpe = <String>[];
    for (final f in file) {
      final percorso = f.path.replaceAll(r'\', '/');
      // Solo il codice: si toglie cio' che sta dopo `//` su ogni riga.
      final codice = f
          .readAsLinesSync()
          .map((r) => r.split('//').first)
          .join('\n');
      for (final v in vietati) {
        if (codice.contains(v)) colpe.add('$percorso: $v');
      }
      if (RegExp(r'(?<![A-Za-z])Chip\(').hasMatch(codice)) {
        colpe.add('$percorso: Chip');
      }
      // Un BoxDecoration col suo colore pieno e' un riquadro disegnato.
      for (final m in RegExp(r'BoxDecoration\(([^()]|\([^()]*\))*\)')
          .allMatches(codice)) {
        if (m.group(0)!.contains('color:')) {
          colpe.add('$percorso: BoxDecoration con colore pieno');
        }
      }
    }
    expect(colpe, isEmpty,
        reason: 'comandi standard o riquadri pieni al posto dei pezzi '
            'dipinti di i_comandi_dipinti.dart:\n${colpe.join('\n')}');
  });
}
