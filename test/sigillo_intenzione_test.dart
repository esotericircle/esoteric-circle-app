import 'package:esoteric_circle/core/magic/intention_sigil.dart';
import 'package:flutter_test/flutter_test.dart';

/// Il Sigillo dell'Intenzione: deterministico, significativo, senza promesse.
void main() {
  group('Deterministico, sempre', () {
    test('La stessa frase da\' cento volte lo stesso sigillo', () {
      const frase = 'Trovo la mia strada con coraggio';
      final primo = IntentionSigil.cammino(frase);
      for (var i = 0; i < 100; i++) {
        expect(IntentionSigil.cammino(frase), primo,
            reason: 'al giro $i il sigillo e\' cambiato');
      }
    });

    test('Anche la via e\' sempre la stessa', () {
      const frase = 'Chiedo protezione per la mia casa';
      final via = LettoreIntenzione.leggi(frase).via;
      for (var i = 0; i < 50; i++) {
        expect(LettoreIntenzione.leggi(frase).via, via);
      }
    });
  });

  group('Il metodo di Spare, applicato davvero', () {
    test('Le lettere ripetute spariscono, l\'ordine resta', () {
      expect(IntentionSigil.lettereUniche('ABBA'), ['A', 'B']);
      expect(
          IntentionSigil.lettereUniche('casa mia'), ['C', 'A', 'S', 'M', 'I']);
    });

    test('Gli accenti tornano alla lettera base', () {
      expect(IntentionSigil.lettereUniche('perché').contains('E'), isTrue);
      expect(IntentionSigil.lettereUniche('città').last, 'A');
    });

    test('Spazi e punteggiatura non stanno sulla ruota', () {
      expect(IntentionSigil.lettereUniche('a, b. c!'), ['A', 'B', 'C']);
      expect(IntentionSigil.lettereUniche('123'), isEmpty);
    });

    test('Con meno di due lettere non c\'e\' cammino', () {
      expect(IntentionSigil.cammino('a'), isEmpty);
      expect(IntentionSigil.cammino('aaa'), isEmpty);
      expect(IntentionSigil.cammino('ab').length, 2);
    });
  });

  group('Significativo: frasi diverse, sigilli diversi', () {
    /// Quanto due cammini si somigliano come DISEGNO, non come parole: si
    /// confrontano i punti toccati, uno per uno, piu' la differenza di
    /// lunghezza del percorso.
    double distanzaDisegno(String a, String b) {
      final ca = IntentionSigil.cammino(a);
      final cb = IntentionSigil.cammino(b);
      if (ca.isEmpty || cb.isEmpty) return 1;
      final n = ca.length < cb.length ? ca.length : cb.length;
      var somma = 0.0;
      for (var i = 0; i < n; i++) {
        somma += (ca[i] - cb[i]).distance;
      }
      final lungo = ca.length > cb.length ? ca.length : cb.length;
      final diff = (ca.length - cb.length).abs() / lungo;
      return somma / n + diff;
    }

    test('Tre coppie molto diverse danno sigilli molto diversi', () {
      const coppie = [
        ('Voglio pace nella mia casa', 'Bruci il fuoco del desiderio'),
        ('Radici profonde nella terra', 'Chiarezza sul mio lavoro'),
        ('Coraggio di dire quello che sento', 'Protezione per chi amo'),
      ];
      for (final (a, b) in coppie) {
        final d = distanzaDisegno(a, b);
        expect(d, greaterThan(0.25),
            reason: '"$a" e "$b" danno sigilli troppo simili: '
                '${d.toStringAsFixed(2)}');
      }
    });

    test('Tre coppie quasi identiche danno sigilli simili', () {
      const coppie = [
        ('Voglio pace', 'Voglio pace vera'),
        ('Trovo la mia strada', 'Trovo la mia strada oggi'),
        ('Chiarezza sul lavoro', 'Chiarezza sul lavoro mio'),
      ];
      for (final (a, b) in coppie) {
        final s = IntentionSigil.somiglianza(a, b);
        expect(s, greaterThan(0.6),
            reason: '"$a" e "$b" dovrebbero somigliarsi: '
                '${s.toStringAsFixed(2)}');
      }
    });

    test('Nessuna coppia diversa collassa sullo stesso cammino', () {
      const frasi = [
        'Voglio pace nella mia casa',
        'Bruci il fuoco del desiderio',
        'Radici profonde nella terra',
        'Chiarezza sul mio lavoro',
        'Coraggio di dire quello che sento',
      ];
      final visti = <String, String>{};
      for (final f in frasi) {
        final chiave = IntentionSigil.cammino(f).toString();
        expect(visti.containsKey(chiave), isFalse,
            reason: '"$f" da\' lo stesso sigillo di "${visti[chiave]}"');
        visti[chiave] = f;
      }
    });
  });

  group('Le tre vie', () {
    test('Ogni via si riconosce dalle sue parole', () {
      expect(LettoreIntenzione.leggi('Apro il mio cuore').via, ViaMagica.rossa);
      expect(
          LettoreIntenzione.leggi('Chiedo protezione').via, ViaMagica.bianca);
      expect(LettoreIntenzione.leggi('Metto radici qui').via, ViaMagica.verde);
    });

    test('La parola va riconosciuta intera, non a frammenti', () {
      // "pace" dentro "capace" non e' la Via Bianca.
      final l = LettoreIntenzione.leggi('Mi sento capace di riuscire');
      expect(l.parolaChiave, isNot('pace'));
    });

    test('Frase non riconosciuta: si dichiara e si usa la Bianca', () {
      final l = LettoreIntenzione.leggi('Zzz qwerty');
      expect(l.riconosciuta, isFalse);
      expect(l.via, ViaMagica.bianca);
      expect(l.parolaChiave, isEmpty);
    });
  });

  group('Il filtro, dove il testo nasce', () {
    test('Le intenzioni sulla volonta\' altrui si riformulano, non si negano',
        () {
      for (final f in const [
        'Fai che lui si innamori di me',
        'Voglio costringere il mio capo a promuovermi',
        'Fai che lei torni da me',
      ]) {
        final l = LettoreIntenzione.leggi(f);
        expect(l.eStataRiformulata, isTrue,
            reason: '"$f" e\' passata cosi\' com\'era');
        expect(l.riformulata.toLowerCase(), isNot(contains('costringere')));
        // La riformulazione parla di chi scrive, non di un altro.
        expect(l.riformulata.toLowerCase(), contains('mio'));
      }
    });

    test('Una intenzione legittima non viene toccata', () {
      const f = 'Apro il mio cuore a un legame vero';
      final l = LettoreIntenzione.leggi(f);
      expect(l.eStataRiformulata, isFalse);
      expect(l.riformulata, f);
    });

    test('Nessun testo del motore promette un esito', () {
      const vietate = [
        'guarir', 'guarigione', 'salute', 'malatt', 'denaro', 'soldi',
        'ricchezz', 'garanti', 'sicuramente', 'vincer', 'ti sposerai',
      ];
      final testi = <String>[
        for (final v in ViaMagica.values) ...[v.nome, v.dominio],
        LettoreIntenzione.leggi('Fai che lui mi ami').riformulata,
      ];
      for (final t in testi) {
        for (final v in vietate) {
          expect(t.toLowerCase().contains(v), isFalse,
              reason: '"$t" promette qualcosa: contiene "$v"');
        }
      }
    });
  });
}
