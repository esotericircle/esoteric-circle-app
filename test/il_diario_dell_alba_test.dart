// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:math';

import 'package:esoteric_circle/core/responsi/scelta_senza_ripetere.dart';
import 'package:esoteric_circle/core/rituals/arcano_dell_alba/diario_dell_alba.dart';
import 'package:esoteric_circle/core/rituals/arcano_dell_alba/lettura_dell_alba.dart';
import 'package:esoteric_circle/core/rituals/arcano_dell_alba/letture_dell_alba_dati.dart';
import 'package:esoteric_circle/core/rituals/arcano_dell_alba/responso_dell_alba.dart';
import 'package:esoteric_circle/core/rituals/arcano_dell_alba/sacchetto_dell_alba.dart';
import 'package:flutter_test/flutter_test.dart';

/// **IL DIARIO DELL'ARCANO DELL'ALBA.** Ordine DT voci 05, 09, 10, 11, 12,
/// 22, 23 e 27, 17 settembre 2026.
///
/// Si misura cio' che una persona vive in giorni e cicli, non una chiamata:
/// una sola estrazione al giorno, un ciclo intero senza parole ne aperture
/// ripetute e senza ripieghi, le letture consumate tutte prima di tornare, il
/// filo con ieri solo quando c'e' una relazione, due persone che nello stesso
/// giorno ricevono lo stesso stato e leggono testi diversi, e un diario che
/// sopravvive alla chiusura e a un salvataggio rotto.
void main() {
  final inizio = DateTime(2026, 9, 18);
  DateTime giorno(int n) => DateTime(inizio.year, inizio.month, inizio.day + n);

  List<ResponsoDellAlba> vivi(String utente, int giorni,
      {int seme = 1,
      List<LetturaDellAlba> corpus = lettureDellAlba,
      void Function(DiarioDellAlba)? dopo}) {
    final caso = Random(seme);
    var diario = DiarioDellAlba.nuovo();
    final responsi = <ResponsoDellAlba>[];
    for (var g = 0; g < giorni; g++) {
      final e = diario.estrai(
          utente: utente, giorno: giorno(g), caso: caso, corpus: corpus);
      diario = e.dopo;
      responsi.add(e.responso);
    }
    dopo?.call(diario);
    return responsi;
  }

  test(
      'UNA SOLA ESTRAZIONE AL GIORNO: riaprire il dono restituisce lo stesso '
      'responso e non tocca il sacchetto', () {
    final caso = Random(5);
    final prima = DiarioDellAlba.nuovo()
        .estrai(utente: 'anna', giorno: inizio, caso: caso);
    final ancora = prima.dopo.estrai(
        utente: 'anna',
        giorno: inizio.add(const Duration(hours: 9)),
        caso: caso);
    expect(ancora.responso.primo, prima.responso.primo);
    expect(ancora.responso.secondo, prima.responso.secondo);
    expect(ancora.responso.terzo, prima.responso.terzo);
    expect(ancora.dopo.sacchetto.rimasti, prima.dopo.sacchetto.rimasti);
    expect(identical(ancora.dopo, prima.dopo), isTrue);
  });

  test(
      'UN CICLO INTERO DI QUARANTAQUATTRO GIORNI, per molte persone: nessuna '
      'parola e nessuna apertura si ripete, e i ripieghi restano a zero', () {
    const persone = 25, cicli = 3;
    for (var p = 0; p < persone; p++) {
      late DiarioDellAlba finale;
      final responsi = vivi('persona $p', SacchettoDellAlba.stati * cicli,
          seme: p, dopo: (d) => finale = d);
      for (var c = 0; c < cicli; c++) {
        final ciclo = responsi.sublist(
            c * SacchettoDellAlba.stati, (c + 1) * SacchettoDellAlba.stati);
        for (final (nome, marca) in [
          (
            'primo movimento',
            (ResponsoDellAlba r) => DiarioDellAlba.apertura(r.primo)
          ),
          ('dono', (ResponsoDellAlba r) => DiarioDellAlba.apertura(r.secondo)),
          ('Medora', (ResponsoDellAlba r) => DiarioDellAlba.apertura(r.terzo)),
        ]) {
          final marche = ciclo.map(marca).toList();
          expect(marche.toSet(), hasLength(marche.length),
              reason: 'persona $p, ciclo ${c + 1}: un\'apertura del $nome si '
                  'ripete');
        }
        final parole = [
          for (final r in ciclo)
            if (r.parola != null) r.parola!,
        ];
        expect(parole.toSet(), hasLength(parole.length),
            reason: 'persona $p, ciclo ${c + 1}: una parola del giorno torna');
        expect(parole, hasLength(24),
            reason: 'le dodici zodiacali nei due versi danno ventiquattro '
                'parole a ciclo');
      }
      expect(finale.ripieghi, 0,
          reason: 'persona $p: il corpus non ha avuto una lettura libera');

      // In tre cicli ogni stato esce tre volte: le sue tre letture, tutte.
      final perStato = <int, List<int>>{};
      for (final r in responsi) {
        perStato.putIfAbsent(r.stato.id, () => []).add(r.lettura.numero);
      }
      for (final e in perStato.entries) {
        expect(e.value.toSet(), {1, 2, 3},
            reason: 'persona $p, stato ${e.key}: letture ${e.value}');
      }
    }
  });

  group('I REGISTRI SCELGONO LA LETTURA, e l\'impianto e uno solo', () {
    test('primoLibero prende il primo candidato senza marche usate', () {
      expect(
          SceltaSenzaRipetere.primoLibero(
              ['a', 'b', 'c'], (String x) => {x}, {'a', 'b'}),
          'c');
      expect(
          SceltaSenzaRipetere.primoLibero(
              ['a', 'b'], (String x) => {x}, {'a', 'b'}),
          isNull);
    });

    // Un corpus costruito apposta: per ogni stato tre letture, e le prime
    // due di OGNI stato aprono il dono con le stesse due parole; la terza e
    // tutto il resto sono unici. Il registro deve saltare le prime due e
    // consegnare la terza finche' ce n'e' una libera.
    List<LetturaDellAlba> corpusStretto() => [
          for (var id = 0; id < SacchettoDellAlba.stati; id++)
            for (var n = 1; n <= 3; n++)
              LetturaDellAlba(
                carta: id ~/ 2,
                rovescio: id.isOdd,
                numero: n,
                parola: id ~/ 2 >= 4 ? 'parola ${lettere(id * 3 + n)}' : null,
                dono: n < 3
                    ? 'Stessa apertura ${lettere(id * 3 + n)}.'
                    : 'Libera ${lettere(id)} apre.',
                medora: 'Chiude ${lettere(id * 3 + n)} Medora.',
              ),
        ];

    test(
        'la lettura che violerebbe il registro si salta, resta in coda, e se '
        'non c\'e nessuna libera si consegna la meno recente e si conta', () {
      late DiarioDellAlba finale;
      final stati = SacchettoDellAlba.stati;
      final due = vivi('carla', stati * 2,
          corpus: corpusStretto(), dopo: (d) => finale = d);
      int stesse(List<ResponsoDellAlba> r) => r
          .where((x) => DiarioDellAlba.apertura(x.secondo) == 'stessa apertura')
          .length;

      // Primo ciclo: "stessa apertura" passa una volta sola, poi il registro
      // la salta e consegna la terza lettura, che e' libera.
      final primo = due.sublist(0, stati);
      expect(stesse(primo), 1);
      // Le letture saltate restano in coda: nessuna e' persa.
      var codeDaDue = 0;
      late DiarioDellAlba dopoIlPrimo;
      vivi('carla', stati,
          corpus: corpusStretto(), dopo: (d) => dopoIlPrimo = d);
      expect(dopoIlPrimo.ripieghi, 0);
      for (final e in dopoIlPrimo.code.entries) {
        expect(e.value.length, 2, reason: 'stato ${e.key}: coda ${e.value}');
        codeDaDue++;
      }
      expect(codeDaDue, stati);

      // Secondo ciclo: le terze sono finite, in coda restano solo letture che
      // aprono allo stesso modo. Si consegnano lo stesso, e ognuna oltre la
      // prima e' un ripiego contato, non un passaggio muto.
      final secondo = due.sublist(stati);
      expect(finale.ripieghi, greaterThan(0));
      expect(finale.ripieghi, stesse(secondo) - 1);
    });
  });

  group('IL FILO CON IERI', () {
    test('il primo giorno non c\'e, e non si nomina l\'ieri che manca', () {
      final r = vivi('dario', 1).single;
      expect(r.ieri, isNull);
      expect(r.terzo, r.lettura.medora);
      expect(r.terzo.toLowerCase(), isNot(contains('ieri')));
    });

    test(
        'nei giorni di fila c\'e solo quando la relazione e documentata, e '
        'nomina la carta di ieri col suo verso', () {
      var conFilo = 0, senza = 0;
      for (var p = 0; p < 10; p++) {
        final responsi = vivi('persona $p', 60, seme: p);
        for (var g = 1; g < responsi.length; g++) {
          final oggi = responsi[g], ieri = responsi[g - 1];
          final relazione =
              ResponsoDellAlba.relazioneFra(oggi.stato, ieri.stato);
          if (relazione == null) {
            senza++;
            expect(oggi.terzo, oggi.lettura.medora);
          } else {
            conFilo++;
            expect(oggi.relazione, relazione);
            expect(oggi.terzo, startsWith(oggi.lettura.medora));
            expect(oggi.terzo,
                contains(ResponsoDellAlba.cartaColVerso(ieri.stato)));
          }
        }
      }
      print('filo: $conFilo giorni con il richiamo, $senza senza');
      expect(conFilo, greaterThan(0));
      expect(senza, greaterThan(0));
    });

    test('un giorno saltato spezza il filo', () {
      final caso = Random(2);
      var d = DiarioDellAlba.nuovo()
          .estrai(utente: 'ettore', giorno: inizio, caso: caso)
          .dopo;
      final r =
          d.estrai(utente: 'ettore', giorno: giorno(2), caso: caso).responso;
      expect(r.ieri, isNull);
      expect(r.terzo, r.lettura.medora);
    });
  });

  group('DUE PERSONE, LO STESSO STATO, LO STESSO GIORNO', () {
    test(
        'due persone con lo stesso sacchetto ricevono lo stesso stato e testi '
        'diversi', () {
      final a = vivi('utente-a', 1, seme: 9).single;
      final b = vivi('utente-b', 1, seme: 9).single;
      expect(a.stato, b.stato, reason: 'lo stesso caso da lo stesso stato');
      expect('${a.primo} ${a.secondo} ${a.terzo}',
          isNot('${b.primo} ${b.secondo} ${b.terzo}'));
    });

    test('LA COLLISIONE MISURATA al variare delle letture per stato', () {
      // Voce 22: la probabilita' che due persone con lo stesso stato nello
      // stesso giorno leggano lo stesso dono. Si misura su corpora finti con
      // n letture per stato e aperture tutte diverse, a un giorno qualunque
      // del loro cammino.
      final righe = <String>[];
      final misurate = <int, double>{};
      for (final n in const [3, 5, 8]) {
        final corpus = [
          for (var id = 0; id < SacchettoDellAlba.stati; id++)
            for (var k = 1; k <= n; k++)
              LetturaDellAlba(
                carta: id ~/ 2,
                rovescio: id.isOdd,
                numero: k,
                parola: id ~/ 2 >= 4 ? lettere(id * 10 + k) : null,
                dono: 'Dono ${lettere(id * 10 + k)} del giorno.',
                medora: 'Medora ${lettere(id * 10 + k)} chiude.',
              ),
        ];
        var stessoDono = 0, stessoTesto = 0, coppie = 0;
        final caso = Random(n);
        for (var coppia = 0; coppia < 300; coppia++) {
          final giorni = 1 + caso.nextInt(SacchettoDellAlba.stati * 2);
          final seme = caso.nextInt(1 << 30);
          final a = vivi('a$coppia', giorni, seme: seme, corpus: corpus).last;
          final b = vivi('b$coppia', giorni, seme: seme, corpus: corpus).last;
          coppie++;
          if (a.secondo == b.secondo) stessoDono++;
          if (a.primo == b.primo &&
              a.secondo == b.secondo &&
              a.terzo == b.terzo) {
            stessoTesto++;
          }
        }
        misurate[n] = stessoDono / coppie;
        righe.add(
            'n=$n: stesso dono ${(100 * stessoDono / coppie).toStringAsFixed(1)} '
            'per cento (atteso ${(100 / n).toStringAsFixed(1)}), stesso testo '
            'intero ${(100 * stessoTesto / coppie).toStringAsFixed(1)} per cento');
      }
      print('COLLISIONE\n${righe.join('\n')}');
      expect(misurate[3]!, inInclusiveRange(0.22, 0.45));
      expect(misurate[8]!, lessThan(misurate[3]!));
    });
  });

  group('IL DIARIO SOPRAVVIVE', () {
    test('salvato a meta ciclo e riletto, continua identico', () {
      final caso = Random(4);
      var d = DiarioDellAlba.nuovo();
      for (var g = 0; g < 30; g++) {
        d = d.estrai(utente: 'franca', giorno: giorno(g), caso: caso).dopo;
      }
      var riletto = DiarioDellAlba.daJson(jsonDecode(jsonEncode(d.toJson())));
      expect(jsonEncode(riletto.toJson()), jsonEncode(d.toJson()));
      final casoA = Random(99), casoB = Random(99);
      for (var g = 30; g < 60; g++) {
        final a = d.estrai(utente: 'franca', giorno: giorno(g), caso: casoA);
        final b =
            riletto.estrai(utente: 'franca', giorno: giorno(g), caso: casoB);
        expect(b.responso.primo, a.responso.primo);
        expect(b.responso.secondo, a.responso.secondo);
        expect(b.responso.terzo, a.responso.terzo);
        d = a.dopo;
        riletto =
            DiarioDellAlba.daJson(jsonDecode(jsonEncode(b.dopo.toJson())));
      }
    });

    for (final (nome, dati) in <(String, Object?)>[
      ('nulla', null),
      ('una lista', [1, 2, 3]),
      ('campi sbagliati', {'sacchetto': 'x', 'code': 7, 'registro': 'y'}),
      (
        'una consegna rotta',
        {
          'ultima': {'giorno': 3, 'stato': 'z'}
        }
      ),
      (
        'una coda con stati inesistenti',
        {
          'code': {
            '99': [1],
            'abc': [2]
          }
        }
      ),
    ]) {
      test('un salvataggio rotto non blocca: $nome', () {
        final d = DiarioDellAlba.daJson(dati);
        final e = d.estrai(utente: 'gino', giorno: inizio, caso: Random(1));
        expect(e.responso.secondo, isNotEmpty);
      });
    }
  });
}

/// Una parola fatta di sole lettere e diversa per ogni [n]: le aperture si
/// misurano sulle lettere, e un numero dentro un testo finto non conta.
String lettere(int n) {
  final b = StringBuffer();
  var x = n + 1;
  while (x > 0) {
    b.write(String.fromCharCode(97 + (x - 1) % 26));
    x = (x - 1) ~/ 26;
  }
  return 'q$b';
}
