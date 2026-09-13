import 'package:esoteric_circle/core/entitlement/plan_catalog.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:flutter_test/flutter_test.dart';

import 'sorgenti_di_lib.dart';

/// **IL LISTINO NON PROMETTE LA DOMANDA AL MAESTRO REALE.** Ordine DJ voce 09,
/// 13 settembre 2026.
///
/// *"Il listino promette all'Illuminato una funzione che nessuna parte del
/// codice esegue. Se reale significa una persona in carne e ossa, non e'
/// codice che manca: e' un operatore da ingaggiare, un tempo di risposta da
/// garantire e una responsabilita' su cio' che quella persona scrive. [...]
/// La voce esce dall'elenco dei vantaggi del piano Illuminato e non viene
/// conteggiata fra cio' che il piano da'. [...] Nessuna schermata la offre,
/// nessun pulsante la annuncia."*
///
/// **Si guarda tutta `lib`, e non soltanto il catalogo dei piani**: una
/// schermata o un pulsante che la annunciasse con parole sue sarebbe la
/// stessa promessa. I commenti non contano, perche' non li legge nessuno a
/// schermo; le stringhe si.
void main() {
  test('NESSUNA STRINGA DI lib OFFRE LA DOMANDA AL MAESTRO REALE, e il piano '
      'Illuminato non la conta', () {
    final vietata = RegExp(r'maestr[oi] (reale|in carne)|risposta entro 48',
        caseSensitive: false);
    final stringa = RegExp(r"'([^'\\]|\\.)*'");
    // **DALLA PORTA COMUNE**, che porta con se' il suo cardinale minimo.
    final colpevoli = <String>[];
    for (final f in sorgentiDiLib()) {
      for (final riga in f.readAsLinesSync()) {
        final codice = riga.trimLeft();
        if (codice.startsWith('//')) continue;
        for (final m in stringa.allMatches(codice)) {
          if (vietata.hasMatch(m.group(0)!)) colpevoli.add('${f.path}: $codice');
        }
      }
    }
    final illuminato = PlanCatalog.forTier(Tier.tier3).highlights;
    final righe = PlanCatalog.matrix.map((r) => r.label).toList();
    // ignore: avoid_print
    print('ORDINE DJ VOCE 09: stringhe che la offrono ${colpevoli.length}, '
        'vantaggi dell\'Illuminato ${illuminato.length}, righe della matrice '
        '${righe.length}');
    expect(colpevoli, isEmpty, reason: colpevoli.join('\n'));
    expect(illuminato.where(vietata.hasMatch), isEmpty,
        reason: 'l\'Illuminato conta ancora la Domanda al Maestro reale');
    expect(righe.where(vietata.hasMatch), isEmpty,
        reason: 'la matrice dei piani la mostra ancora');
  });
}
