import 'package:esoteric_circle/core/entitlement/plan_catalog.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:flutter_test/flutter_test.dart';

/// Entitlement: il contatore giornaliero delle domande per tier e i piani.
void main() {
  group('Contatore delle domande', () {
    // Ordine EX voce 02: il nome dice i numeri nuovi, erano 3, 5, 10, 50.
    // Ordine EX Aggiunta 3: le domande si alzano a 12, 18 e 22.
    test('Il limite giornaliero segue i tier: 3, 12, 17, 21', () {
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
      // Ordine EX voce 02: sei domande all'Iniziato, erano cinque.
      // Ordine EX Aggiunta 3: dodici all'Iniziato, erano sei.
      expect(a.dailyLimit(Tier.tier1), 12);
      // Ordine FE voce 20, 6 ottobre 2026: 17 e 21, erano 18 e 22 ("Una domanda in meno", il tetto del 30 per cento col filo del consulto).
      expect(a.dailyLimit(Tier.tier2), 17);
      // **NON PIU' NULLO, ordine CE voce 08.** L'illimitato e' uscito
      // dalla matrice e dalla logica: l'Illuminato ha cinquanta domande
      // al giorno, che nessun uso umano intensivo raggiunge.
      // Ordine EX voce 02: tredici domande all'Illuminato, erano cinquanta.
      // Ordine EX Aggiunta 3: ventidue, erano tredici.
      // Ordine FE voce 20, 6 ottobre 2026: 17 e 21, erano 18 e 22 ("Una domanda in meno", il tetto del 30 per cento col filo del consulto).
      expect(a.dailyLimit(Tier.tier3), 21);
    });

    test('Viandante ha tre risposte al giorno, si azzerano il giorno dopo', () {
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

    // Ordine EX Aggiunta 3: dodici domande all'Iniziato, erano sei.
    test('L\'Iniziato consuma fino a dodici domande al giorno', () {
      var now = DateTime(2026, 7, 13);
      final allowance = QuestionAllowance(clock: () => now);
      for (var i = 0; i < 12; i++) {
        expect(allowance.canAsk(Tier.tier1), isTrue);
        allowance.record(Tier.tier1);
      }
      expect(allowance.canAsk(Tier.tier1), isFalse);
      now = DateTime(2026, 7, 14);
      expect(allowance.canAsk(Tier.tier1), isTrue);
    });

    test('L\'Illuminato consuma anche lui, e ha un tetto alto', () {
      // **NON PIU' "non consuma", ordine CE voce 08.** Finche' il piano
      // era illimitato il contatore lo saltava; adesso l'Illuminato ha
      // cinquanta domande al giorno, quindi consuma come tutti. Il tetto
      // e' ampio per scelta: il fondatore voleva un numero che un uso
      // umano intensivo non raggiunge, non un piano senza conto.
      final allowance = QuestionAllowance(clock: () => DateTime(2026, 7, 13));
      allowance.record(Tier.tier3);
      allowance.record(Tier.tier3);
      expect(allowance.usedToday(), 2);
      expect(allowance.canAsk(Tier.tier3), isTrue);
      // Ordine EX Aggiunta 3: ventidue meno due, erano tredici meno due.
      // Ordine FE voce 20: ventuno meno due, erano ventidue meno due.
      expect(allowance.remaining(Tier.tier3), 19);
    });

    test('Il confronto a piu Maestri e riservato al Tier a pagamento', () {
      final allowance = QuestionAllowance(clock: () => DateTime(2026, 7, 13));
      expect(allowance.canCompare(Tier.free), isFalse);
      expect(allowance.canCompare(Tier.tier1), isTrue);
      expect(allowance.canCompare(Tier.tier3), isTrue);
    });
  });

  group('Piani', () {
    test('Ci sono i quattro livelli canonici, dal gratuito all\'Illuminato',
        () {
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
      // LAPIDE, 1 ottobre 2026: il fondatore ha portato i prezzi a 2,99,
      // 9,99, 19,99 e 29,99 ("Gli abbonamenti [...] sono cambiati in 2,99 -
      // 9,99 - 19,99 - 29,99"). Qui si pretendevano 2,90 e 9,90.
      expect(iniziato.price!.weekly, '2,99 €');
      expect(iniziato.price!.monthly, '9,99 €');
      // LAPIDE, ordine EV voce 01, 2 ottobre 2026: "Si, tutto a 99". Qui si
      // pretendeva l'annuale a 99,90.
      expect(iniziato.price!.yearly, '99,99 €');
      // **LO SCONTO SEGUE IL PREZZO, ordine CE voce 07.** Era 24, poi 16 con
      // 9,90 al mese, adesso 17: 99,99 contro 119,88 di dodici mensili.
      expect(iniziato.price!.yearlyDiscountPercent, 17);
      // L'Iniziato apre col riepilogo del gratuito, poi la Memoria AI.
      expect(iniziato.highlights.first, contains('Tutto di Viandante'));
      expect(iniziato.highlights.any((h) => h.contains('Memoria AI')), isTrue);

      final adepto = PlanCatalog.forTier(Tier.tier2);
      expect(adepto.price!.monthly, '19,99 €');
      expect(PlanCatalog.forTier(Tier.tier3).price!.monthly, '29,99 €');
      final illuminato = PlanCatalog.forTier(Tier.tier3);
      expect(illuminato.price!.yearly, '279,99 €');
    });

    // **TUTTI I PREZZI A 99, ordine EV voce 01.** Il fondatore: "Gli
    // abbonamenti e quindi foni riferimento sono cambiati in 2,99 - 9,99 -
    // 19,99 - 29,99", e alla domanda se portare a ,99 anche gli altri: "Si,
    // tutto a 99". Si misura: i nove prezzi dei tre piani a pagamento finiscono
    // in ,99; lo sconto annuale detto a video e' quello del conto
    // `1 - annuale / (mensile * 12)` arrotondato; il prezzo al mese
    // dell'annuale e' l'annuale diviso dodici, arrotondato al centesimo.
    test('EV.01: i nove prezzi finiscono in ,99 e gli sconti tornano', () {
      double numero(String p) =>
          double.parse(p.replaceAll(' €', '').replaceAll(',', '.'));
      final senza99 = <String>[];
      final sconti = <String>[];
      var prezzi = 0;
      for (final t in const [Tier.tier1, Tier.tier2, Tier.tier3]) {
        final p = PlanCatalog.forTier(t).price!;
        for (final v in [p.weekly, p.monthly, p.yearly]) {
          prezzi++;
          if (!v.endsWith(',99 €')) senza99.add('${t.name} $v');
        }
        final conto =
            ((1 - numero(p.yearly) / (numero(p.monthly) * 12)) * 100).round();
        if (conto != p.yearlyDiscountPercent) {
          sconti.add('${t.name}: a video ${p.yearlyDiscountPercent}, conto '
              '$conto');
        }
        final alMese = (numero(p.yearly) / 12 * 100).round() / 100;
        final scritto = '${alMese.toStringAsFixed(2).replaceAll('.', ',')} € '
            'al mese';
        if (p.yearlyPerMonth != scritto) {
          sconti.add('${t.name}: al mese "${p.yearlyPerMonth}", conto '
              '"$scritto"');
        }
      }
      // ignore: avoid_print
      print('ORDINE EV VOCE 01: prezzi che non finiscono in ,99 '
          '${senza99.length} su $prezzi $senza99; sconti o prezzi al mese '
          'diversi dal conto ${sconti.length} $sconti');
      expect(prezzi, 9);
      expect(senza99, isEmpty);
      expect(sconti, isEmpty);
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
      // TREDICI dall'ordine ES voce 08: l'oroscopo cinese del giorno si apre
      // dall'Iniziato, e il piano lo dice.
      // QUATTORDICI dalla voce ES.09: anche l'oroscopo vedico.
      // QUINDICI dalla voce ES.12: gli amici, fino a tre.
      expect(PlanCatalog.forTier(Tier.tier1).highlights.length, 15);
      // TREDICI dalla voce ES.04: l'oroscopo dell'anno dal compleanno.
      // QUATTORDICI dalla voce ES.12: gli amici, fino a dieci.
      expect(PlanCatalog.forTier(Tier.tier2).highlights.length, 14);
      // DIECI dall'ordine DJ voce 09, per ordine del fondatore e non per
      // condensare: la Domanda al Maestro reale non si conta piu' fra cio'
      // che il piano da', perche' nessuna parte dell'app la esegue.
      // UNDICI dall'ordine EX voce 02: i minuti del LIVE dell'Illuminato.
      expect(PlanCatalog.forTier(Tier.tier3).highlights.length, 11);
    });

    test('Gli highlights portano i limiti reali di reset giornaliero', () {
      final viandante = PlanCatalog.forTier(Tier.free).highlights;
      expect(
          viandante.any((h) => h.contains('Sinastria VIP fino a 3 al giorno')),
          isTrue);
      expect(
          viandante.any((h) => h.contains('Tre carte di tarocchi al giorno')),
          isTrue);
      expect(
          viandante
              .any((h) => h.contains('Tre domande al giorno a un Maestro')),
          isTrue);

      final iniziato = PlanCatalog.forTier(Tier.tier1).highlights;
      expect(iniziato.first, contains('senza pubblicità'));
      // Ordine EX voce 02: la matrice nuova.
      // Ordine EX Aggiunta 3: 12, 18 e 22 domande.
      expect(iniziato.any((h) => h.contains('12 domande al giorno ai Maestri')),
          isTrue);

      final adepto = PlanCatalog.forTier(Tier.tier2).highlights;
      // **LAPIDE, ordine FE voce 20**: 17 e 21 domande al mensile, erano 18
      // e 22. Il fondatore: "Una domanda in meno" (il tetto del 30 per cento
      // col filo del consulto).
      expect(adepto.any((h) => h.contains('17 domande al giorno ai Maestri')),
          isTrue);
      expect(adepto.any((h) => h.contains('10 carte di tarocchi al giorno')),
          isTrue);

      final illuminato = PlanCatalog.forTier(Tier.tier3).highlights;
      expect(
          illuminato.any((h) => h.contains('21 domande ai Maestri')), isTrue);
      // **E NON LA DOMANDA AL MAESTRO REALE**, uscita con l'ordine DJ voce 09.
      expect(illuminato.any((h) => h.contains('Maestro reale')), isFalse);
    });

    test('La mappa comparativa ha le righe attese con quattro valori', () {
      // Ventiquattro dal 2 agosto 2026: e' entrata la riga "Vai più a fondo",
      // che e' un budget a se' e non una variante delle domande.
      // VENTICINQUE dal 4 agosto 2026: si e' aggiunta la riga dei confronti
      // nel Cerchio, che e' il tetto separato del Consiglio.
      // VENTISEI dall'11 agosto 2026, ordine I voce 3: la riga delle gettate
      // di rune, tre al giorno per il Viandante e illimitate dal Tier 1.
      // VENTISETTE dall'ordine AN voce 07: la riga della dote in Eos alla
      // sottoscrizione entra nella pagina come valore del piano.
      // VENTOTTO dall'ordine CG voce 16: la riga delle notifiche del Cerchio,
      // premium dal primo piano a pagamento con un mese di prova per chi non
      // paga. Il numero segue il dato.
      // TRENTUNO dall'ordine DI voce 15: le tre righe del Viaggio dello
      // Sciamano, discese, segni chiesti all'animale e nutrimento.
      // TRENTA dall'ordine DJ voce 09: e' uscita la riga della Domanda al
      // Maestro reale, che nessuna parte dell'app esegue.
      // TRENTADUE dall'ordine DO voce 11: i sigilli dell'Intenzione vivi
      // insieme, uno due tre cinque, e la loro carica, sempre aperta.
      // TRENTUNO dall'ordine DT voce 01: le righe del Rito dell'Alba e
      // dell'Arcano del Giorno sono diventate quella dell'Arcano dell'Alba.
      // TRENTADUE dall'ordine ES voce 08: la riga dell'oroscopo cinese del
      // giorno, "Solo il segno" per il Viandante.
      // TRENTATRE dalla voce ES.09: la riga dell'oroscopo vedico.
      // TRENTAQUATTRO dalla voce ES.06: la riga della profondita'
      // dell'oroscopo, Breve per il Viandante.
      // TRENTACINQUE dalla voce ES.04: la riga dell'oroscopo dell'anno.
      // TRENTASEI dalla voce ES.12: la riga degli amici.
      // TRENTASETTE dall'ordine EX voce 02: la carta singola entra nelle
      // carte estratte, ed entrano la stesa da dieci carte e i minuti del
      // LIVE.
      // QUARANTUNO dall'ordine EY: le righe del motore sociale, amici nel
      // Cerchio, segni, confronti del cielo e i doni.
      expect(PlanCatalog.matrix.length, 41);
      final gettate =
          PlanCatalog.matrix.firstWhere((r) => r.label == 'Gettate di rune');
      // UNA al giorno dall'ordine O del 12 agosto 2026, per decisione di
      // Mauro: erano tre dall'ordine I.
      // Ordine EX voce 02: 1, 2, 3 e 3.
      expect(gettate.values,
          ['1 al giorno', '2 al giorno', '3 al giorno', '3 al giorno']);
      for (final row in PlanCatalog.matrix) {
        expect(row.values.length, 4, reason: 'riga ${row.label}');
      }
      final memoria = PlanCatalog.matrix
          .firstWhere((r) => r.label == 'Memoria AI dei Maestri');
      expect(memoria.values, ['No', 'Esclusiva', 'Sì', 'Sì']);
      final domande = PlanCatalog.matrix
          .firstWhere((r) => r.label == 'Domande a un Maestro');
      // Ordine FE voce 20: 17 e 21, erano 18 e 22.
      expect(domande.values,
          ['3 al giorno', '12 al giorno', '17 al giorno', '21 al giorno']);
      final voce = PlanCatalog.matrix
          .firstWhere((r) => r.label == 'Voce AI dei Maestri');
      expect(voce.values, ['No', 'No', 'Esclusiva', 'Sì']);
    });
  });
}
