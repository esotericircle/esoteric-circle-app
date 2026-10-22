// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/entitlement/budget_del_giorno.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'sorgenti_di_lib.dart';

/// **OGNI RISCATTO DICE LA COSA CHE SI COMPRA**, ordine GC aggiunta, 23
/// ottobre 2026. Nella simulazione sul Realme (voce GCA.03) il pulsante per
/// chiedere la stessa domanda agli altri due Maestri diceva *"Riscatta un
/// confronto di sinastria · 150 Eos"*: il budget era quello dei confronti fra
/// i Maestri, la parola era quella di un altro budget. PADRE: ordine BG voce
/// 05 (commit `36a2131a`).
///
/// La guardia legge ogni chiamata a `corredoDelRiscatto` di lib col budget
/// scritto per nome e la cosa scritta per esteso, e pretende che la cosa
/// nomini il proprio budget (la prima parola di `BudgetDelGiorno.uno`) e
/// nessun altro.
void main() {
  test('ogni riscatto nomina il suo budget e nessun altro', () {
    final parola = {
      for (final b in BudgetDelGiorno.values)
        b.name: b.uno.split(' ').first.toLowerCase(),
    };
    final chiamata = RegExp(
        r"corredoDelRiscatto\([^;]*?budget:\s*'(\w+)'[^;]*?cosaUna:\s*'([^']*)'",
        dotAll: true);
    final colpe = <String>[];
    var guardate = 0;
    for (final f in sorgentiDiLib()) {
      final testo = f.readAsStringSync();
      for (final m in chiamata.allMatches(testo)) {
        final budget = m.group(1)!;
        final cosa = m.group(2)!.toLowerCase();
        final sua = parola[budget];
        if (sua == null) continue;
        guardate++;
        if (!cosa.contains(sua)) {
          colpe.add('${f.path}: budget $budget, "$cosa" non dice "$sua"');
        }
        for (final altra in parola.entries) {
          if (altra.key == budget || altra.value == sua) continue;
          if (cosa.contains(altra.value)) {
            colpe.add('${f.path}: budget $budget, "$cosa" dice '
                '"${altra.value}", che e\' il budget ${altra.key}');
          }
        }
      }
    }
    print('GCA: riscatti guardati $guardate, colpe ${colpe.length}');
    cardinaleMinimo(guardate, 6,
        cosa: 'riscatti col budget e la cosa scritti per esteso',
        perche: 'domande due volte, confronti, approfondimenti, gettate, '
            'sinastrie');
    expect(colpe, isEmpty, reason: colpe.join('\n'));
  });
}
