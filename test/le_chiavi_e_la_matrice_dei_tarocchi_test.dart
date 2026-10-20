// LE QUATTRO CHIAVI E LA MATRICE DEI TAROCCHI. Ordine FI voci 06, 07 e 32,
// 10 ottobre 2026.
//
// Quattro chiavi con la loro tradizione: la Predittiva di Medora a tutti, la
// Riflessione dall'Iniziato, Esoterica e Archetipica dall'Adepto. "Esoterica
// Caligo" sparisce (un nome di casa accanto a una persona reale) e nessuna
// etichetta porta il nome di Jodorowsky. La matrice dell'Architetto approvata
// dal fondatore ("tabella ok"): le righe delle carte al giorno e della stesa
// da dieci restano quelle di prima.

import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/entitlement/plan_catalog.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/tarot/la_lettura_dal_modello.dart';
import 'package:esoteric_circle/features/tarot/tarot_selectors.dart';
import 'package:flutter_test/flutter_test.dart';

const _piani = [Tier.free, Tier.tier1, Tier.tier2, Tier.tier3];

void main() {
  test('quattro chiavi con la loro tradizione', () {
    expect([
      for (final k in ReadingKey.values) k.label
    ], [
      'Predittiva di Medora',
      'Riflessione',
      'Esoterica',
      'Archetipica',
    ]);
    for (final k in ReadingKey.values) {
      expect(k.label, isNot(contains('Caligo')));
      expect(k.label, isNot(contains('Calìgo')));
      expect(k.label, isNot(contains('Jodorowsky')));
    }
    expect(ReadingKey.predittiva.tradizione, contains('Etteilla'));
    expect(ReadingKey.riflessione.tradizione,
        allOf(contains('Jodorowsky'), contains('Costa'), contains('2004')));
    expect(ReadingKey.esoterica.tradizione,
        allOf(contains('Waite'), contains('1911'), contains('Alba Dorata')));
    expect(ReadingKey.archetipica.tradizione,
        allOf(contains('Nichols'), contains('Pollack'), contains('1980')));
    // La nota etica della Riflessione resta.
    expect(ReadingKey.riflessione.note, contains('senza rapporto ufficiale'));
  });

  test(
      'la Predittiva lascia l\'istruzione com\'era, le altre aggiungono la '
      'loro voce', () {
    for (final f in CourtesyForm.values) {
      final base = LaLetturaDellaStesa.istruzione(f);
      expect(LaLetturaDellaStesa.istruzione(f, chiave: ReadingKey.predittiva),
          base);
      expect(base, isNot(contains('LA CHIAVE DI LETTURA')));
      for (final k in ReadingKey.values.where((k) => k.voce != null)) {
        final con = LaLetturaDellaStesa.istruzione(f, chiave: k);
        expect(con, contains(k.voce!));
        // La voce sta prima dell'ultima riga, quella del formato.
        expect(con.trimRight().split('\n').last, startsWith('Rispondi solo'));
      }
    }
    expect(ReadingKey.riflessione.voce,
        allOf(contains('tendenza'), contains('mai come un annuncio')));
  });

  test('chi apre quale chiave', () {
    const attese = {
      ReadingKey.predittiva: [true, true, true, true],
      ReadingKey.riflessione: [false, true, true, true],
      ReadingKey.esoterica: [false, false, true, true],
      ReadingKey.archetipica: [false, false, true, true],
    };
    attese.forEach((k, a) {
      expect([for (final t in _piani) k.apribileDa(t)], a, reason: k.name);
    });
  });

  test('la matrice dei tarocchi dell\'ordine FI', () {
    const sino = {
      RigaDelPiano.stesaACroce: [false, true, true, true],
      // LAPIDE: il ferro di cavallo dall'Adepto, tolto dall'ordine FJ,
      // aggiunta 2.
      RigaDelPiano.stesaDaDieci: [false, false, true, true],
      RigaDelPiano.chiaveRiflessione: [false, true, true, true],
      RigaDelPiano.chiaviEsotericaEArchetipica: [false, false, true, true],
      RigaDelPiano.mazzoDiMarsiglia: [false, true, true, true],
      RigaDelPiano.mazzoThoth: [false, false, true, true],
      RigaDelPiano.profonditaDellaStesa: [false, true, true, true],
      RigaDelPiano.ritornoDellaCarta: [false, false, true, true],
      RigaDelPiano.rileggereLaStesa: [false, false, false, true],
      RigaDelPiano.cardDellaStesa: [true, true, true, true],
    };
    sino.forEach((r, a) {
      expect([for (final t in _piani) PlanCatalog.apre(r, t)], a,
          reason: r.name);
    });
    // Le carte al giorno non si toccano: 3, 6, 10, 15.
    // Ordine GA voce 01: la riga torna a contare le stese, 1, 3, 2 e 3; la
    // stesa da dieci resta dell'Adepto in su.
    expect([
      for (final t in _piani)
        PlanCatalog.limiteGiornaliero(RigaDelPiano.stese, t)
    ], [
      1,
      3,
      2,
      3
    ]);
    expect([for (final t in _piani) PlanCatalog.haLaStesaDaDieci(t)],
        [false, false, true, true]);
  });

  // **LAPIDE: "chiusi per tutti, anche per chi la matrice li apre".** Fino
  // all'ordine FJ Marsiglia e Thoth non c'erano e la prova li voleva chiusi a
  // ogni piano. Dall'ordine FJ voce 12 si scaricano dal bucket, e chi li puo'
  // scegliere lo dice la matrice dell'ordine FI voce 32.
  test('i mazzi seguono la matrice', () {
    for (final t in _piani) {
      expect(TarotDeckStyle.riderWaite.apribileDa(t), isTrue);
      expect(TarotDeckStyle.marsiglia.apribileDa(t),
          PlanCatalog.apre(RigaDelPiano.mazzoDiMarsiglia, t));
      expect(TarotDeckStyle.thoth.apribileDa(t),
          PlanCatalog.apre(RigaDelPiano.mazzoThoth, t));
    }
    expect(TarotDeckStyle.marsiglia.apribileDa(Tier.free), isFalse);
  });
}
