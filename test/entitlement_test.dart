import 'package:esoteric_circle/core/entitlement/plan_catalog.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:flutter_test/flutter_test.dart';

/// Entitlement: il contatore giornaliero delle domande per tier e i piani.
void main() {
  group('Contatore delle domande', () {
    test('Il limite giornaliero segue i tier: 3, 5, 10, illimitate', () {
      final a = QuestionAllowance(clock: () => DateTime(2026, 7, 13));
      // TRE, che e' il numero deciso e approvato dal fondatore.
      //
      // Questa prova diceva UNA, e codificava il valore sbagliato: il 31
      // luglio una divergenza fra matrice e codice era stata risolta facendo
      // vincere la matrice, e la matrice portava uno. La correzione di allora
      // era giusta nel metodo, sbagliata nel valore, e questa prova l'ha
      // cristallizzata. Il 2 agosto il fondatore ha letto "una domanda al
      // giorno" sul telefono.
      expect(a.dailyLimit(Tier.free), 3);
      expect(a.dailyLimit(Tier.tier1), 5);
      expect(a.dailyLimit(Tier.tier2), 10);
      expect(a.dailyLimit(Tier.tier3), isNull);
    });

    test('Viandante ha tre risposte al giorno, si azzerano il giorno dopo',
        () {
      var now = DateTime(2026, 7, 13, 10);
      final allowance = QuestionAllowance(clock: () => now);

      expect(allowance.remaining(Tier.free), 3);
      for (var i = 0; i < 3; i++) {
        expect(allowance.canAsk(Tier.free), isTrue);
        allowance.record(Tier.free);
      }
      expect(allowance.canAsk(Tier.free), isFalse);
      expect(allowance.remaining(Tier.free), 0);

      now = DateTime(2026, 7, 14, 9);
      expect(allowance.canAsk(Tier.free), isTrue);
    });

    test('L\'Iniziato consuma fino a cinque domande al giorno', () {
      var now = DateTime(2026, 7, 13);
      final allowance = QuestionAllowance(clock: () => now);
      for (var i = 0; i < 5; i++) {
        expect(allowance.canAsk(Tier.tier1), isTrue);
        allowance.record(Tier.tier1);
      }
      expect(allowance.canAsk(Tier.tier1), isFalse);
      now = DateTime(2026, 7, 14);
      expect(allowance.canAsk(Tier.tier1), isTrue);
    });

    test('L\'Illuminato non consuma il contatore', () {
      final allowance = QuestionAllowance(clock: () => DateTime(2026, 7, 13));
      allowance.record(Tier.tier3);
      allowance.record(Tier.tier3);
      expect(allowance.usedToday(), 0);
      expect(allowance.canAsk(Tier.tier3), isTrue);
    });

    test('Il confronto a piu Maestri e riservato al Tier a pagamento', () {
      final allowance = QuestionAllowance(clock: () => DateTime(2026, 7, 13));
      expect(allowance.canCompare(Tier.free), isFalse);
      expect(allowance.canCompare(Tier.tier1), isTrue);
      expect(allowance.canCompare(Tier.tier3), isTrue);
    });
  });

  group('Piani', () {
    test('Ci sono i quattro livelli canonici, dal gratuito all\'Illuminato', () {
      expect(PlanCatalog.plans.length, 4);
      expect(PlanCatalog.plans.map((p) => p.name).toList(),
          ['Viandante', 'L\'Iniziato', 'L\'Adepto', 'L\'Illuminato']);
      expect(PlanCatalog.plans.first.tier, Tier.free);
      expect(PlanCatalog.plans.first.price, isNull);
      // Uno solo e' consigliato.
      expect(PlanCatalog.plans.where((p) => p.highlighted).length, 1);
      for (final plan in PlanCatalog.plans) {
        expect(plan.name, isNotEmpty);
        expect(plan.identity, isNotEmpty);
        expect(plan.highlights, isNotEmpty);
      }
    });

    test('I livelli a pagamento hanno i tre cicli col prezzo giusto', () {
      final iniziato = PlanCatalog.forTier(Tier.tier1);
      expect(iniziato.price!.weekly, '2,90 €');
      expect(iniziato.price!.monthly, '9,90 €');
      expect(iniziato.price!.yearly, '89,90 €');
      expect(iniziato.price!.yearlyDiscountPercent, 24);
      // L'Iniziato apre col riepilogo del gratuito, poi la Memoria AI.
      expect(iniziato.highlights.first, contains('Tutto di Viandante'));
      expect(iniziato.highlights.any((h) => h.contains('Memoria AI')), isTrue);

      final adepto = PlanCatalog.forTier(Tier.tier2);
      expect(adepto.price!.monthly, '19,90 €');
      final illuminato = PlanCatalog.forTier(Tier.tier3);
      expect(illuminato.price!.yearly, '269,90 €');
    });

    test('Gli highlights usano solo "Maestri", mai "Guide" o "Guida"', () {
      for (final plan in PlanCatalog.plans) {
        for (final h in plan.highlights) {
          expect(h.contains('Guide'), isFalse, reason: h);
          expect(h.contains('Guida'), isFalse, reason: h);
        }
      }
      // Almeno un piano nomina davvero i "Maestri", cosi' il termine c'e'.
      expect(
        PlanCatalog.plans
            .expand((p) => p.highlights)
            .any((h) => h.contains('Maestri')),
        isTrue,
      );
    });

    test('Gli elenchi sono completi, uno lungo per Tier, senza condensare', () {
      expect(PlanCatalog.forTier(Tier.free).highlights.length, 10);
      expect(PlanCatalog.forTier(Tier.tier1).highlights.length, 12);
      expect(PlanCatalog.forTier(Tier.tier2).highlights.length, 12);
      expect(PlanCatalog.forTier(Tier.tier3).highlights.length, 11);
    });

    test('Gli highlights portano i limiti reali di reset giornaliero', () {
      final viandante = PlanCatalog.forTier(Tier.free).highlights;
      expect(viandante.any((h) => h.contains('Sinastria VIP fino a 3 al giorno')),
          isTrue);
      expect(viandante.any((h) => h.contains('Una carta di tarocchi al giorno')),
          isTrue);
      expect(
          viandante.any((h) => h.contains('Tre domande al giorno a un Maestro')),
          isTrue);

      final iniziato = PlanCatalog.forTier(Tier.tier1).highlights;
      expect(iniziato.first, contains('senza pubblicità'));
      expect(iniziato.any((h) => h.contains('5 domande al giorno ai Maestri')),
          isTrue);

      final adepto = PlanCatalog.forTier(Tier.tier2).highlights;
      expect(adepto.any((h) => h.contains('10 domande al giorno ai Maestri')),
          isTrue);
      expect(
          adepto.any((h) => h.contains('5 stese complete di tarocchi al giorno')),
          isTrue);

      final illuminato = PlanCatalog.forTier(Tier.tier3).highlights;
      expect(illuminato.any((h) => h.contains('Domande ai Maestri illimitate')),
          isTrue);
      expect(
          illuminato.any((h) =>
              h.contains('Una domanda al mese al Maestro reale')),
          isTrue);
    });

    test('La mappa comparativa ha le righe attese con quattro valori', () {
      // Ventiquattro dal 2 agosto 2026: e' entrata la riga "Vai più a fondo",
      // che e' un budget a se' e non una variante delle domande.
      expect(PlanCatalog.matrix.length, 24);
      for (final row in PlanCatalog.matrix) {
        expect(row.values.length, 4, reason: 'riga ${row.label}');
      }
      final memoria = PlanCatalog.matrix
          .firstWhere((r) => r.label == 'Memoria AI dei Maestri');
      expect(memoria.values, ['No', 'Esclusiva', 'Sì', 'Sì']);
      final domande = PlanCatalog.matrix
          .firstWhere((r) => r.label == 'Domande a un Maestro');
      expect(domande.values,
          ['3 al giorno', '5 al giorno', '10 al giorno', 'Illimitate']);
      final voce = PlanCatalog.matrix
          .firstWhere((r) => r.label == 'Voce AI dei Maestri');
      expect(voce.values, ['No', 'No', 'Esclusiva', 'Sì']);
    });
  });
}
