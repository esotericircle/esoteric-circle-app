import 'dart:io';

import 'package:esoteric_circle/core/entitlement/plan_catalog.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:flutter_test/flutter_test.dart';

/// **I LIMITI DELL'ANNUALE. Ordine FE voce 20.**
///
/// Il tetto del 30 per cento sul prezzo tolte IVA e store era stato contato
/// solo sui mensili (ordine EX voce 11): sull'annuale l'Adepto e
/// l'Illuminato stavano al 37 e al 38 per cento. Scelta del fondatore del 6
/// ottobre 2026, *"Domande e minuti insieme"*. Il conto sta in
/// `tool/i_limiti_degli_annuali.py`, e la sua uscita in
/// `docs/costi/i_limiti_degli_annuali.txt`: questa prova pretende che il
/// listino dica, nell'annuale, gli stessi numeri del conto, e che il conto
/// li abbia trovati sotto il tetto.
void main() {
  final strumento = File('tool/i_limiti_degli_annuali.py').readAsStringSync();
  List<int> lista(String nome) {
    final m = RegExp('^$nome = \\[([^\\]]*)\\]', multiLine: true)
        .firstMatch(strumento);
    expect(m, isNotNull, reason: '$nome non c\'e\' piu\' nello strumento');
    return [for (final x in m!.group(1)!.split(',')) int.parse(x.trim())];
  }

  test('FE.20: il listino dell\'annuale dice i numeri del conto', () {
    final domande = lista('DOMANDE_ANNUALE');
    final minuti = lista('MINUTI_ANNUALE');
    const piani = [Tier.tier1, Tier.tier2, Tier.tier3];
    final diversi = <String>[];
    for (final (i, tier) in piani.indexed) {
      final piano = PlanCatalog.plans.firstWhere((p) => p.tier == tier);
      final annuale = piano.highlightsPer(PriceCycle.yearly).join(' | ');
      if (!RegExp('\\b${domande[i]} domande').hasMatch(annuale)) {
        diversi.add('${piano.name}: non dice ${domande[i]} domande');
      }
      if (minuti[i] > 0 && !annuale.contains('${minuti[i]} minuti al mese')) {
        diversi.add('${piano.name}: non dice ${minuti[i]} minuti');
      }
      // Il mensile dice i suoi numeri: dal 6 ottobre 2026 17 e 21 per
      // l'Adepto e l'Illuminato ("Una domanda in meno").
      expect(piano.highlightsPer(PriceCycle.monthly), piano.highlights);
      final mensile = piano.highlightsPer(PriceCycle.monthly).join(' | ');
      final perMese = lista('DOMANDE_MENSILE')[i];
      if (!RegExp('\\b$perMese domande').hasMatch(mensile)) {
        diversi.add('${piano.name}: il mensile non dice $perMese domande');
      }
    }
    // ignore: avoid_print
    print('FE.20 MISURA: piani annuali confrontati col conto ${piani.length}, '
        'diversi ${diversi.length}');
    expect(diversi, isEmpty, reason: diversi.join(' | '));
  });

  // **LE STESE DEL CONTO SONO QUELLE DELLA MATRICE E DELLE CARD. Ordine GA
  // voce 02, 20 ottobre 2026, sera.** Il fondatore: *"Limitiamo la stesa
  // tarocchi a 10 carte: sarà disponibile solo per Tier 2 e 3 e solo 1 al
  // giorno."* Con le carte dal corpus una stesa costa il solo responso
  // principale, e il conto fa entrare 3, 4 e 5 stese nel mensile, 3, 3 e 5
  // nell'annuale. Prima di questa prova il conto e la matrice potevano dire
  // numeri diversi delle stese senza che niente cadesse: la prova qui sopra
  // guardava solo domande e minuti.
  test('GA.02: le stese del conto sono quelle della matrice e delle card', () {
    final stese = lista('STESE');
    final annuale = lista('STESE_ANNUALE');
    final dieci = lista('STESE_DA_DIECI');
    const piani = [Tier.tier1, Tier.tier2, Tier.tier3];
    final diversi = <String>[];
    for (final (i, tier) in piani.indexed) {
      final piano = PlanCatalog.plans.firstWhere((p) => p.tier == tier);
      final matrice =
          PlanCatalog.limiteGiornaliero(PlanCatalog.rigaStese, tier);
      if (matrice != stese[i]) {
        diversi.add('${piano.name}: la matrice dice $matrice stese, il conto '
            '${stese[i]}');
      }
      final aDieci =
          PlanCatalog.limiteGiornaliero(PlanCatalog.rigaStesaDaDieci, tier);
      if (aDieci != dieci[i]) {
        diversi.add('${piano.name}: la matrice dice $aDieci stese a dieci, il '
            'conto ${dieci[i]}');
      }
      // La stesa a dieci sta DENTRO le stese del giorno: mai piu' di loro.
      if (dieci[i] > annuale[i] || dieci[i] > stese[i]) {
        diversi.add('${piano.name}: piu\' stese a dieci che stese');
      }
      final mensile = piano.highlightsPer(PriceCycle.monthly).join(' | ');
      if (!mensile.contains('${stese[i]} stese di tarocchi al giorno')) {
        diversi.add('${piano.name}: il mensile non dice ${stese[i]} stese');
      }
      final perAnno = piano.highlightsPer(PriceCycle.yearly).join(' | ');
      if (!perAnno.contains('${annuale[i]} stese di tarocchi al giorno')) {
        diversi.add('${piano.name}: l\'annuale non dice ${annuale[i]} stese');
      }
    }
    // ignore: avoid_print
    print('GA.02 MISURA: piani confrontati sulle stese ${piani.length}, '
        'diversi ${diversi.length}');
    expect(diversi, isEmpty, reason: diversi.join(' | '));
    final uscita =
        File('docs/costi/i_limiti_degli_annuali.txt').readAsStringSync();
    for (final n in annuale) {
      expect(uscita, contains('$n stese di tarocchi al giorno'),
          reason: 'l\'uscita del conto non e\' quella delle stese di oggi');
    }
  });

  test('FE.20: il conto ha trovato ogni ciclo sotto il tetto', () {
    final uscita =
        File('docs/costi/i_limiti_degli_annuali.txt').readAsStringSync();
    expect(uscita, contains('TUTTI I CICLI SOTTO IL TETTO'),
        reason: 'l\'ultima uscita del conto non trova tutti i cicli sotto il '
            'tetto: rilancia python tool/i_limiti_degli_annuali.py');
    for (final d in lista('DOMANDE_ANNUALE')) {
      expect(uscita, contains('annuale: $d domande al giorno'),
          reason: 'l\'uscita del conto non e\' quella dei numeri di oggi');
    }
  });
}
