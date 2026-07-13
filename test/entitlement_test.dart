import 'package:esoteric_circle/core/entitlement/plan_catalog.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:flutter_test/flutter_test.dart';

/// Entitlement: il contatore giornaliero delle domande per tier e i piani.
void main() {
  group('Contatore delle domande', () {
    test('Il limite giornaliero segue i tier: 1, 5, 10, illimitate', () {
      final a = QuestionAllowance(clock: () => DateTime(2026, 7, 13));
      expect(a.dailyLimit(Tier.free), 1);
      expect(a.dailyLimit(Tier.tier1), 5);
      expect(a.dailyLimit(Tier.tier2), 10);
      expect(a.dailyLimit(Tier.tier3), isNull);
    });

    test('Viandante ha una domanda al giorno, si azzera il giorno dopo', () {
      var now = DateTime(2026, 7, 13, 10);
      final allowance = QuestionAllowance(clock: () => now);

      expect(allowance.canAsk(Tier.free), isTrue);
      expect(allowance.remaining(Tier.free), 1);
      allowance.record(Tier.free);
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
      // La Memoria AI e' la prima leva dell'Iniziato.
      expect(iniziato.highlights.first, contains('Memoria AI'));

      final adepto = PlanCatalog.forTier(Tier.tier2);
      expect(adepto.price!.monthly, '19,90 €');
      final illuminato = PlanCatalog.forTier(Tier.tier3);
      expect(illuminato.price!.yearly, '269,90 €');
    });

    test('La mappa comparativa ha le righe attese con quattro valori', () {
      expect(PlanCatalog.matrix.length, 23);
      for (final row in PlanCatalog.matrix) {
        expect(row.values.length, 4, reason: 'riga ${row.label}');
      }
      final memoria = PlanCatalog.matrix
          .firstWhere((r) => r.label == 'Memoria AI dei Maestri');
      expect(memoria.values, ['No', 'Esclusiva', 'Sì', 'Sì']);
      final domande = PlanCatalog.matrix
          .firstWhere((r) => r.label == 'Domande a un Maestro');
      expect(domande.values,
          ['1 al giorno', '5 al giorno', '10 al giorno', 'Illimitate']);
      final voce = PlanCatalog.matrix
          .firstWhere((r) => r.label == 'Voce AI dei Maestri');
      expect(voce.values, ['No', 'No', 'Esclusiva', 'Sì']);
    });
  });
}
