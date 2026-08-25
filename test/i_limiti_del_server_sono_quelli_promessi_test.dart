import 'dart:io';

import 'package:esoteric_circle/core/entitlement/plan_catalog.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:flutter_test/flutter_test.dart';

/// I LIMITI CHE IL SERVER IMPONE SONO QUELLI CHE LA MATRICE PROMETTE.
///
/// **Il pericolo, concreto.** Dall'ordine N i limiti giornalieri vivono in due
/// posti: la matrice dei piani nel client, che e' cio' che si PROMETTE alla
/// persona, e `functions/src/budget.ts`, che e' cio' che il server IMPONE.
/// Due copie della stessa promessa divergono sempre, e a rimetterci e' una
/// sola delle due parti: e' gia' successo il 31 luglio, quando matrice e
/// codice dicevano cose diverse sulle domande del Viandante.
///
/// Questa prova legge il file del server e lo confronta con la matrice, riga
/// per riga e piano per piano. Non e' una prova di stile: e' l'unico modo di
/// accorgersi che qualcuno ha alzato un numero in un posto solo.
void main() {
  const righe = {
    'domande': PlanCatalog.rigaDomande,
    'approfondimenti': PlanCatalog.rigaApprofondimenti,
    'confronti': PlanCatalog.rigaConfronti,
    'gettate': PlanCatalog.rigaGettate,
    // ORDINE BN VOCE 09: le stese complete di tarocchi hanno un budget loro,
    // e la riga che le promette e' quella delle stese COMPLETE, non quella
    // della carta singola. Coperto qui senza nessuna modifica di comodo: il
    // confronto e' lo stesso degli altri quattro, cella per cella.
    'stese': PlanCatalog.rigaStese,
  };
  const ordine = [Tier.free, Tier.tier1, Tier.tier2, Tier.tier3];

  test('la tabella del server dice quello che promette la matrice', () {
    final sorgente = File('functions/src/budget.ts').readAsStringSync();
    final blocco = RegExp(r'const LIMITI[^{]*\{(.*?)\n\};', dotAll: true)
        .firstMatch(sorgente);
    expect(blocco, isNotNull,
        reason: 'la tabella dei limiti del server non si trova piu\' in '
            'functions/src/budget.ts: se e\' stata spostata, questa prova va '
            'portata dietro, non tolta');

    for (final voce in righe.entries) {
      final riga = RegExp('${voce.key}: \\[([^\\]]*)\\]')
          .firstMatch(blocco!.group(1)!);
      expect(riga, isNotNull,
          reason: 'il server non dichiara nessun limite per ${voce.key}');
      final celle = riga!
          .group(1)!
          .split(',')
          .map((c) => c.trim())
          .where((c) => c.isNotEmpty)
          .toList();
      expect(celle, hasLength(4),
          reason: 'i piani sono quattro, il server ne dichiara '
              '${celle.length} per ${voce.key}');

      for (var i = 0; i < 4; i++) {
        final promesso =
            PlanCatalog.limiteGiornaliero(voce.value, ordine[i]);
        final imposto = celle[i] == 'null' ? null : int.parse(celle[i]);
        expect(imposto, promesso,
            reason: 'per ${voce.key} col piano ${ordine[i].name} la matrice '
                'promette $promesso e il server impone $imposto: una delle '
                'due parti sta mentendo, e non si sa quale');
      }
    }
  });

  test('il tetto di correttezza e\' lo stesso dalle due parti', () {
    final sorgente = File('functions/src/budget.ts').readAsStringSync();
    final tetto = RegExp(r'TETTO_DI_CORRETTEZZA = (\d+)').firstMatch(sorgente);
    expect(tetto, isNotNull);
    expect(int.parse(tetto!.group(1)!), 30,
        reason: 'il tetto di correttezza del server non e\' piu\' quello che '
            'il client dichiara in QuestionAllowance');
  });
}
