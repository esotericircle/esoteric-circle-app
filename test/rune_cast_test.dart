import 'dart:math';

import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/core/rituals/rune_presage.dart';
import 'package:esoteric_circle/core/rituals/runes.dart';
import 'package:flutter_test/flutter_test.dart';

/// Il cuore deterministico e casuale dell'Estrazione Rune di Caligo.
void main() {
  final commaE = RegExp(r',\s+ed?\b', caseSensitive: false);

  group('Le gettate', () {
    test('Sono quattro, coi numeri giusti e la quarta libera', () {
      expect(gettate.length, 4);
      expect(gettataOdino.numero, 1);
      expect(gettataNorne.numero, 3);
      expect(gettataCroce.numero, 5);
      // La quarta gettata, il getto sul telo, e' la sorte libera di Tacito.
      expect(gettate.last.id, 'telo');
      expect(gettataTelo.libera, isTrue);
      expect(gettataTelo.sparse, greaterThan(3));
      expect(gettataTelo.testoDinamico, contains('Tacito'));
    });

    test('Il testo dinamico c\'e\' e differisce per gettata', () {
      final testi = gettate.map((g) => g.testoDinamico).toSet();
      expect(testi.length, gettate.length);
      for (final g in gettate) {
        expect(g.testoDinamico.trim(), isNotEmpty, reason: g.id);
      }
      // Ogni testo dinamico dichiara il metodo di calcolo.
      for (final g in gettate) {
        expect(g.testoDinamico, contains('Metodo di calcolo'), reason: g.id);
      }
    });

    test('I suggerimenti di domanda sono presenti', () {
      expect(kRuneDomandeSuggerite.length, greaterThanOrEqualTo(5));
      for (final q in kRuneDomandeSuggerite) {
        expect(q.trim(), isNotEmpty);
      }
    });
  });

  group('L\'estrazione', () {
    test('Ogni gettata fissa estrae il numero giusto di rune tutte diverse', () {
      for (final g in gettate.where((g) => !g.libera)) {
        for (var seme = 0; seme < 120; seme++) {
          final esito = RuneCast.getta(g, random: Random(seme));
          expect(esito.rune.length, g.numero, reason: '${g.id} seme $seme');
          final nomi = esito.rune.map((r) => r.rune.name).toSet();
          expect(nomi.length, g.numero,
              reason: 'rune ripetute in ${g.id} seme $seme');
          // Ogni runa sta nella sua posizione, in ordine.
          for (var i = 0; i < g.numero; i++) {
            expect(esito.rune[i].posizione.titolo, g.posizioni[i].titolo);
          }
        }
      }
    });

    test('Le rune simmetriche non escono mai in merkstave', () {
      for (var seme = 0; seme < 400; seme++) {
        final esito = RuneCast.getta(gettataCroce, random: Random(seme));
        for (final r in esito.rune) {
          if (kRuneSimmetriche.contains(r.rune.name)) {
            expect(r.inOmbra, isFalse,
                reason: '${r.rune.name} in merkstave, seme $seme');
          }
        }
      }
    });

    test('La riga letta corrisponde all\'orientamento', () {
      for (var seme = 0; seme < 200; seme++) {
        final esito = RuneCast.getta(gettataNorne, random: Random(seme));
        for (final r in esito.rune) {
          expect(r.riga, r.inOmbra ? r.rune.shadow : r.rune.upright);
        }
      }
    });

    test('L\'aett si ricava dal posto nell\'Elder Futhark', () {
      expect(RuneCast.aett(kElderFuthark.firstWhere((r) => r.name == 'Fehu')),
          'Freyr');
      expect(RuneCast.aett(kElderFuthark.firstWhere((r) => r.name == 'Hagalaz')),
          'Hagal');
      expect(RuneCast.aett(kElderFuthark.firstWhere((r) => r.name == 'Tiwaz')),
          'Tyr');
    });
  });

  group('Il getto sul telo', () {
    const centro = Offset(0.5, 0.5);

    test('Sparge sette rune e le legge TUTTE, ordinate dal centro', () {
      // DALL'ORDINE H sul telo non esistono pietre nude ne' letture a tre:
      // ogni pietra gettata mostra il suo simbolo e ha la sua scheda. La
      // prova vecchia pretendeva "fino a tre in luce": e' stata cambiata di
      // grandezza, non allentata, perche' la regola che sorvegliava non
      // esiste piu'.
      for (var seme = 0; seme < 300; seme++) {
        final esito = RuneCast.getta(gettataTelo, random: Random(seme));
        expect(esito.sparse.length, 7, reason: 'seme $seme');
        final nomiSparse = esito.sparse.map((s) => s.rune.name).toSet();
        expect(nomiSparse.length, 7, reason: 'sparse ripetute seme $seme');
        for (final s in esito.sparse) {
          expect(s.punto, isNotNull);
          expect(s.coperta, isFalse,
              reason: 'seme $seme: una pietra nuda sul telo');
        }
        // TUTTE lette: sette pietre, sette schede.
        expect(esito.rune.length, 7, reason: 'seme $seme');
        // Ordinate per vicinanza al centro, e la prima e' la piu' vicina.
        double d(Offset p) => (p - const Offset(0.5, 0.5)).distance;
        for (var i = 1; i < esito.rune.length; i++) {
          expect(d(esito.rune[i].punto!) >= d(esito.rune[i - 1].punto!), isTrue,
              reason: 'seme $seme: lettura non ordinata dal centro');
        }
        // Dalla quarta in poi la posizione dichiarata e' l'ultima, i margini.
        for (var i = 3; i < esito.rune.length; i++) {
          expect(esito.rune[i].posizione.titolo,
              gettataTelo.posizioni.last.titolo,
              reason: 'seme $seme');
        }
      }
    });

    test('Sul telo i versi escono a sorte, e le simmetriche restano dritte',
        () {
      // Anche questa e' cambiata di grandezza: prima pretendeva tutte
      // diritte, perche' il verso d'ombra era riservato alle gettate a
      // posizioni. Adesso il rovescio esiste anche sul telo, e cio' che resta
      // invariante e' la regola unica delle simmetriche.
      var rovesce = 0;
      for (var seme = 0; seme < 200; seme++) {
        final esito = RuneCast.getta(gettataTelo, random: Random(seme));
        for (final s in esito.sparse) {
          if (kRuneSimmetriche.contains(s.rune.name)) {
            expect(s.inOmbra, isFalse,
                reason: 'seme $seme: una simmetrica rovesciata');
          }
          if (s.inOmbra) rovesce++;
        }
      }
      expect(rovesce, greaterThan(0),
          reason: 'in duecento gettate nessuna runa rovesciata: la sorte del '
              'verso non sta girando');
    });
  });

  group('Il presagio', () {
    test('Non e\' mai vuoto e rispetta la regola di lingua', () {
      for (final g in gettate) {
        for (var seme = 0; seme < 200; seme++) {
          final esito = RuneCast.getta(g, random: Random(seme));
          final p = RunePresagio.componi(esito);
          expect(p.trim(), isNotEmpty, reason: '${g.id} seme $seme');
          expect(commaE.hasMatch(p), isFalse,
              reason: 'virgola piu "e" in ${g.id} seme $seme: $p');
          expect(p.contains('—'), isFalse, reason: 'trattino lungo ${g.id}');
          // Nomina almeno la prima runa uscita, cosi' intreccia il lancio.
          expect(p, contains(esito.rune.first.rune.name));
        }
      }
    });

    test('Il gancio di rifinitura avvolge il presagio base', () {
      final esito = RuneCast.getta(gettataOdino, random: Random(1));
      final base = RunePresagio.componi(esito);
      final rifinito = RunePresagio.componi(esito,
          rifinitura: (b) => 'Caligo aggiunge. $b');
      expect(rifinito, 'Caligo aggiunge. $base');
    });
  });
}
