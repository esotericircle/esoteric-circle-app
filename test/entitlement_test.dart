import 'package:esoteric_circle/core/entitlement/plan_catalog.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:flutter_test/flutter_test.dart';

/// Entitlement: il contatore giornaliero delle domande del Free e i piani.
void main() {
  group('Contatore delle domande', () {
    test('Free ha una domanda al giorno, si azzera il giorno dopo', () {
      var now = DateTime(2026, 7, 13, 10);
      final allowance = QuestionAllowance(clock: () => now);

      expect(allowance.canAsk(Tier.free), isTrue);
      expect(allowance.remaining(Tier.free), 1);

      allowance.record(Tier.free);
      expect(allowance.canAsk(Tier.free), isFalse);
      expect(allowance.remaining(Tier.free), 0);
      expect(allowance.usedToday(), 1);

      // Il giorno dopo il conteggio riparte.
      now = DateTime(2026, 7, 14, 9);
      expect(allowance.canAsk(Tier.free), isTrue);
      expect(allowance.remaining(Tier.free), 1);
    });

    test('Il Tier a pagamento non consuma il contatore', () {
      final allowance = QuestionAllowance(clock: () => DateTime(2026, 7, 13));
      allowance.record(Tier.tier1);
      allowance.record(Tier.tier1);
      expect(allowance.usedToday(), 0);
      expect(allowance.canAsk(Tier.tier1), isTrue);
    });

    test('Il confronto a piu Maestri e riservato al Tier a pagamento', () {
      final allowance = QuestionAllowance(clock: () => DateTime(2026, 7, 13));
      expect(allowance.canCompare(Tier.free), isFalse);
      expect(allowance.canCompare(Tier.tier1), isTrue);
      expect(allowance.canCompare(Tier.tier3), isTrue);
    });
  });

  group('Piani', () {
    test('Ci sono i quattro piani, dal gratuito al terzo livello', () {
      expect(PlanCatalog.plans.length, 4);
      expect(PlanCatalog.plans.first.tier, Tier.free);
      expect(PlanCatalog.plans.last.tier, Tier.tier3);
      // Uno solo e' quello consigliato.
      expect(PlanCatalog.plans.where((p) => p.highlighted).length, 1);
      // Ogni piano ha nome, richiamo e benefici.
      for (final plan in PlanCatalog.plans) {
        expect(plan.name, isNotEmpty);
        expect(plan.tagline, isNotEmpty);
        expect(plan.benefits, isNotEmpty);
      }
    });

    test('forTier restituisce il piano giusto', () {
      expect(PlanCatalog.forTier(Tier.tier2).tier, Tier.tier2);
    });
  });
}
