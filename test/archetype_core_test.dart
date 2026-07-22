import 'package:esoteric_circle/core/archetypes/archetype.dart';
import 'package:esoteric_circle/core/archetypes/archetype_allowance.dart';
import 'package:esoteric_circle/core/archetypes/archetype_corpus.dart';
import 'package:esoteric_circle/core/archetypes/archetype_quiz.dart';
import 'package:esoteric_circle/core/archetypes/archetype_scoring.dart';
import 'package:esoteric_circle/core/archetypes/archetype_transits.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:flutter_test/flutter_test.dart';

/// Il cuore del Test Archetipo: dati e logica, senza una riga di schermata.
///
/// Qui si prova la promessa che regge tutta la funzione: stesse risposte,
/// stesso risultato, su ogni dispositivo e a ogni esecuzione. Niente AI,
/// niente casualita', niente dipendenza dalla data.
void main() {
  group('Dati', () {
    test('Dodici domande, quattro risposte, identificativi unici', () {
      expect(ArchetypeQuiz.tutte.length, ArchetypeQuiz.domande);
      final id = <String>{};
      for (var i = 0; i < ArchetypeQuiz.tutte.length; i++) {
        final d = ArchetypeQuiz.tutte[i];
        expect(d.id, 'D${i + 1}');
        expect(id.add(d.id), isTrue, reason: 'id doppio ${d.id}');
        expect(d.risposte.length, ArchetypeQuiz.rispostePerDomanda,
            reason: d.id);
        expect(d.testo.trim(), isNotEmpty, reason: d.id);
        for (final r in d.risposte) {
          expect(r.testo.trim(), isNotEmpty, reason: d.id);
          expect(r.pesi, isNotEmpty, reason: '${d.id} risposta senza peso');
          for (final p in r.pesi.values) {
            expect(p, greaterThan(0), reason: '${d.id} peso non positivo');
          }
        }
      }
    });

    test('Ogni archetipo e\' toccato da almeno una risposta', () {
      final toccati = <Archetype>{};
      for (final d in ArchetypeQuiz.tutte) {
        for (final r in d.risposte) {
          toccati.addAll(r.pesi.keys);
        }
      }
      expect(toccati.length, Archetype.values.length);
    });

    test('Il corpus copre tutti e dodici, con tutti i campi pieni', () {
      expect(ArchetypeCorpus.tutti.length, 12);
      for (final a in Archetype.values) {
        final r = ArchetypeCorpus.di(a);
        expect(r.archetipo, a);
        for (final campo in [r.essenza, r.luce, r.ombra, r.amore, r.lavoro]) {
          expect(campo.trim(), isNotEmpty, reason: a.name);
        }
      }
      // L'ordine canonico e' quello dichiarato, e non e' decorativo: scioglie
      // i pareggi, quindi se cambia cambiano i risultati.
      expect(Archetype.values.map((a) => a.nome), [
        'Innocente', 'Esploratore', 'Saggio', 'Eroe', 'Ribelle', 'Mago',
        'Realista', 'Amante', 'Giullare', 'Custode', 'Sovrano', 'Creatore',
      ]);
    });

    test('Ogni archetipo ha la sua arte, piena e in miniatura', () {
      for (final a in Archetype.values) {
        expect(a.stem, 'arc_${a.name}_v1');
        expect(a.artePiena, 'assets/img/archetipi/${a.stem}.webp');
        expect(a.arteThumb, 'assets/img_thumb/archetipi/${a.stem}.webp');
      }
    });
  });

  group('Punteggio', () {
    test('Casi noti: le risposte portano al dominante atteso', () {
      // Un percorso costruito sull'azione: affronto, agisco, reagisco, combatto.
      final eroe = ArchetypeScoring.calcola([0, 0, 0, 1, 0, 3, 0, 0, 0, 1, 0, 0]);
      expect(eroe.dominante, Archetype.eroe);
      expect(eroe.percentualeDi(Archetype.eroe), closeTo(33.3, 0.1));

      // Un percorso sulla cura: penso a chi e' colpito, includo, proteggo.
      final custode =
          ArchetypeScoring.calcola([3, 3, 2, 3, 1, 1, 2, 3, 2, 2, 3, 1]);
      expect(custode.dominante, Archetype.custode);
      expect(custode.percentualeDi(Archetype.custode), closeTo(32.1, 0.1));
    });

    test('Determinismo: stesse risposte, stesso risultato', () {
      const scelte = [2, 1, 0, 3, 2, 1, 0, 3, 2, 1, 0, 3];
      final a = ArchetypeScoring.calcola(scelte);
      final b = ArchetypeScoring.calcola([...scelte]);
      expect(b.dominante, a.dominante);
      expect(b.secondo, a.secondo);
      for (final x in Archetype.values) {
        expect(b.percentualeDi(x), a.percentualeDi(x), reason: x.name);
      }
      // e a distanza di chiamate, senza stato che si porti dietro nulla
      for (var i = 0; i < 5; i++) {
        expect(ArchetypeScoring.calcola(scelte).dominante, a.dominante);
      }
    });

    test('Le percentuali sommano a cento', () {
      for (final scelte in [
        List.filled(12, 0),
        List.filled(12, 1),
        List.filled(12, 2),
        List.filled(12, 3),
        [0, 1, 2, 3, 0, 1, 2, 3, 0, 1, 2, 3],
      ]) {
        final p = ArchetypeScoring.calcola(scelte);
        final somma = Archetype.values
            .map(p.percentualeDi)
            .reduce((x, y) => x + y);
        expect(somma, closeTo(100.0, 0.0001));
      }
    });

    test('I pareggi si sciolgono con l\'ordine canonico', () {
      // Rispondendo sempre per prima, quattro archetipi finiscono a pari
      // merito: vince chi viene prima nell'ordine canonico, e il secondo e'
      // quello subito dopo fra i pari.
      final p = ArchetypeScoring.calcola(List.filled(12, 0));
      final pari = Archetype.values
          .where((a) => (p.percentualeDi(a) - p.percentualeDi(p.dominante)).abs() < 0.001)
          .toList();
      expect(pari.length, greaterThan(1), reason: 'il caso deve essere un pareggio');
      expect(p.dominante, Archetype.innocente);
      expect(p.secondo, Archetype.esploratore);
      expect(pari.first, Archetype.innocente);

      // Un altro pareggio, su archetipi diversi: vale la stessa regola.
      final q = ArchetypeScoring.calcola(List.filled(12, 2));
      expect(q.percentualeDi(Archetype.mago),
          closeTo(q.percentualeDi(Archetype.amante), 0.001));
      expect(q.dominante, Archetype.mago);
    });

    test('Il secondo compare solo se sta entro la soglia', () {
      expect(ArchetypeScoring.sogliaSecondo, 10.0);

      // Sopra la soglia: il dominante e' staccato di 14,8 punti e resta solo.
      final solo = ArchetypeScoring.calcola([0, 0, 0, 1, 0, 3, 0, 0, 0, 1, 0, 0]);
      final scarto = solo.percentualeDi(solo.dominante) -
          solo.percentualeDi(solo.graduatoria[1]);
      expect(scarto, greaterThan(ArchetypeScoring.sogliaSecondo));
      expect(solo.secondo, isNull);

      // Entro la soglia: 7,4 punti di scarto, il secondo si affianca.
      final coppia = ArchetypeScoring.calcola(List.filled(12, 3));
      expect(coppia.dominante, Archetype.realista);
      expect(coppia.secondo, Archetype.ribelle);
      final scarto2 = coppia.percentualeDi(Archetype.realista) -
          coppia.percentualeDi(Archetype.ribelle);
      expect(scarto2, lessThanOrEqualTo(ArchetypeScoring.sogliaSecondo));
    });

    test('La graduatoria e\' ordinata e completa', () {
      final p = ArchetypeScoring.calcola([1, 2, 3, 0, 1, 2, 3, 0, 1, 2, 3, 0]);
      final g = p.graduatoria;
      expect(g.length, 12);
      expect(g.toSet().length, 12);
      expect(g.first, p.dominante);
      for (var i = 1; i < g.length; i++) {
        expect(p.percentualeDi(g[i - 1]),
            greaterThanOrEqualTo(p.percentualeDi(g[i])));
      }
    });

    test('Un input malformato solleva, invece di dare un profilo sbagliato', () {
      expect(() => ArchetypeScoring.calcola(const []), throwsArgumentError);
      expect(() => ArchetypeScoring.calcola(List.filled(11, 0)),
          throwsArgumentError);
      expect(() => ArchetypeScoring.calcola(List.filled(12, 4)),
          throwsArgumentError);
      expect(() => ArchetypeScoring.calcola(List.filled(12, -1)),
          throwsArgumentError);
    });
  });

  group('Transiti', () {
    test('La tabella lega dieci pianeti a due archetipi ciascuno', () {
      expect(ArchetypeTransits.tabella.length, Pianeta.values.length);
      for (final p in Pianeta.values) {
        final coppia = ArchetypeTransits.tabella[p];
        expect(coppia, isNotNull, reason: p.name);
        expect(coppia!.length, 2, reason: p.name);
        expect(coppia.toSet().length, 2, reason: p.name);
      }
      expect(ArchetypeTransits.tabella[Pianeta.marte],
          [Archetype.eroe, Archetype.ribelle]);
      expect(ArchetypeTransits.tabella[Pianeta.saturno],
          [Archetype.sovrano, Archetype.realista]);
    });

    test('La motivazione segue il template deterministico', () {
      expect(
        ArchetypeTransits.motivazione(Pianeta.marte, Archetype.eroe),
        'Oggi Marte accende il tuo Eroe: il coraggio prima della paura.',
      );
      // La chiusa viene dal corpus, non da un secondo elenco da tenere
      // allineato: per ogni pianeta e ogni archetipo la riga e' coerente.
      for (final p in Pianeta.values) {
        for (final a in ArchetypeTransits.tabella[p]!) {
          final riga = ArchetypeTransits.motivazione(p, a);
          expect(riga, startsWith('Oggi ${p.nome} accende il tuo ${a.nome}: '));
          expect(riga, endsWith(
              ArchetypeCorpus.di(a).essenza.substring(1)));
        }
      }
    });

    test('Senza pianeti attivi il profilo non si muove', () {
      final base = ArchetypeScoring.calcola(List.filled(12, 3));
      final m = ArchetypeTransits.applica(base, const {});
      expect(m.motivazioni, isEmpty);
      expect(m.modulato.dominante, base.dominante);
      expect(m.modulato.secondo, base.secondo);
      for (final a in Archetype.values) {
        expect(m.modulato.percentualeDi(a),
            closeTo(base.percentualeDi(a), 0.0001), reason: a.name);
      }
    });

    test('Un insieme noto di pianeti da\' la modulazione attesa', () {
      final base = ArchetypeScoring.calcola(List.filled(12, 3));
      final m = ArchetypeTransits.applica(base, {Pianeta.marte, Pianeta.urano});

      // Marte spinge Eroe e Ribelle, Urano spinge Ribelle e Mago: il Ribelle
      // prende la spinta due volte ed e' lui che le due righe nominano.
      expect(m.motivazioni.map((r) => r.pianeta), [Pianeta.marte, Pianeta.urano]);
      expect(m.motivazioni.map((r) => r.archetipo),
          [Archetype.ribelle, Archetype.ribelle]);
      expect(m.motivazioni.first.testo,
          'Oggi Marte accende il tuo Ribelle: rompere per liberare.');

      // La spinta e' piccola per costruzione: il dominante delle risposte
      // resta il dominante, il cielo non ribalta il test.
      expect(m.modulato.dominante, Archetype.realista);
      expect(m.base.dominante, base.dominante);

      // Il Ribelle sale, chi non e' toccato scende in quota.
      expect(m.modulato.percentualeDi(Archetype.ribelle),
          greaterThan(base.percentualeDi(Archetype.ribelle)));
      expect(m.modulato.percentualeDi(Archetype.custode),
          lessThan(base.percentualeDi(Archetype.custode)));

      final somma = Archetype.values
          .map(m.modulato.percentualeDi)
          .reduce((x, y) => x + y);
      expect(somma, closeTo(100.0, 0.0001));
    });

    test('Le righe seguono l\'ordine dei pianeti, non quello di arrivo', () {
      final base = ArchetypeScoring.calcola(List.filled(12, 0));
      final a = ArchetypeTransits.applica(
          base, {Pianeta.urano, Pianeta.luna, Pianeta.giove});
      final b = ArchetypeTransits.applica(
          base, {Pianeta.giove, Pianeta.urano, Pianeta.luna});
      expect(a.motivazioni.map((r) => r.pianeta),
          [Pianeta.luna, Pianeta.giove, Pianeta.urano]);
      expect(b.motivazioni.map((r) => r.testo),
          a.motivazioni.map((r) => r.testo));
    });

    test('La modulazione e\' deterministica quanto il punteggio', () {
      final base = ArchetypeScoring.calcola([1, 1, 2, 2, 3, 3, 0, 0, 1, 1, 2, 2]);
      const pianeti = {Pianeta.venere, Pianeta.nettuno};
      final a = ArchetypeTransits.applica(base, pianeti);
      final b = ArchetypeTransits.applica(base, pianeti);
      expect(b.modulato.dominante, a.modulato.dominante);
      expect(b.motivazioni.map((r) => r.testo), a.motivazioni.map((r) => r.testo));
      for (final x in Archetype.values) {
        expect(b.modulato.percentualeDi(x), a.modulato.percentualeDi(x));
      }
    });

    test('La cornice della sincronicita\' dice significato, non causa', () {
      expect(ArchetypeTransits.corniceSincronicita, contains('sincronicità'));
      expect(ArchetypeTransits.corniceSincronicita, contains('non causa'));
    });
  });

  group('Limite per livello', () {
    test('Il limite giornaliero segue il livello', () {
      expect(ArchetypeAllowance.limite(Tier.free), 1);
      expect(ArchetypeAllowance.limite(Tier.tier1), 3);
      expect(ArchetypeAllowance.limite(Tier.tier2), isNull);
      expect(ArchetypeAllowance.limite(Tier.tier3), isNull);
    });

    test('Il primo test di troppo e\' bloccato, per ogni livello', () {
      // Viandante: uno solo.
      expect(ArchetypeAllowance.consentito(fattiOggi: 0, tier: Tier.free), isTrue);
      expect(ArchetypeAllowance.consentito(fattiOggi: 1, tier: Tier.free), isFalse);

      // Iniziato: fino a tre, il quarto no.
      expect(ArchetypeAllowance.consentito(fattiOggi: 2, tier: Tier.tier1), isTrue);
      expect(ArchetypeAllowance.consentito(fattiOggi: 3, tier: Tier.tier1), isFalse);

      // Adepto e Illuminato: sempre.
      for (final t in [Tier.tier2, Tier.tier3]) {
        for (final n in [0, 3, 99]) {
          expect(ArchetypeAllowance.consentito(fattiOggi: n, tier: t), isTrue,
              reason: '${t.label} con $n');
        }
      }
    });

    test('Quanti ne restano, e un contatore sporco non regala nulla', () {
      expect(ArchetypeAllowance.rimanenti(fattiOggi: 0, tier: Tier.free), 1);
      expect(ArchetypeAllowance.rimanenti(fattiOggi: 1, tier: Tier.free), 0);
      expect(ArchetypeAllowance.rimanenti(fattiOggi: 5, tier: Tier.free), 0);
      expect(ArchetypeAllowance.rimanenti(fattiOggi: 1, tier: Tier.tier1), 2);
      expect(ArchetypeAllowance.rimanenti(fattiOggi: 0, tier: Tier.tier2), isNull);
      // Un valore negativo vale zero: non deve diventare un tentativo in piu'.
      expect(ArchetypeAllowance.consentito(fattiOggi: -3, tier: Tier.free), isTrue);
      expect(ArchetypeAllowance.rimanenti(fattiOggi: -3, tier: Tier.free), 1);
    });
  });
}
