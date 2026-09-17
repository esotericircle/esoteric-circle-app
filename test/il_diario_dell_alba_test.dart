// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:math';

import 'package:esoteric_circle/core/responsi/scelta_senza_ripetere.dart';
import 'package:esoteric_circle/core/rituals/arcano_dell_alba/diario_dell_alba.dart';
import 'package:esoteric_circle/core/rituals/arcano_dell_alba/lettura_dell_alba.dart';
import 'package:esoteric_circle/core/rituals/arcano_dell_alba/letture_dell_alba_dati.dart';
import 'package:esoteric_circle/core/rituals/arcano_dell_alba/responso_dell_alba.dart';
import 'package:esoteric_circle/core/rituals/arcano_dell_alba/stato_dell_alba.dart';
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
      'responso e non consuma una seconda lettura', () {
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
    expect(ancora.dopo.consegne, prima.dopo.consegne);
    expect(identical(ancora.dopo, prima.dopo), isTrue);
  });

  test(
      'LA FINESTRA DEL REGISTRO, per molte persone: dentro le ultime '
      'quarantaquattro consegne nessuna apertura e nessuna parola tornano, e '
      'i ripieghi restano a zero', () {
    // **L'estrazione non ha piu' cicli**, ordine DU voce 11: quarantaquattro
    // giorni non sono piu' quarantaquattro stati diversi, e la stessa carta
    // puo' tornare il giorno dopo. Cio' che non torna sono i TESTI, voce 12, e
    // la grandezza che lo misura e' la finestra scorrevole: ogni consegna si
    // confronta con le quarantatre che la precedono, non col suo ciclo.
    const persone = 25;
    final finestra = DiarioDellAlba.finestraDelRegistro;
    final giorni = finestra * 3;
    var diFila = 0, ripieghiTotali = 0, ritorni = 0, consegne = 0;
    for (var p = 0; p < persone; p++) {
      // Il giorno per giorno serve intero: per sapere se una marca che torna
      // e' coperta, bisogna sapere quanti ripieghi il motore aveva contato
      // fino al giorno prima.
      final caso = Random(p);
      var diario = DiarioDellAlba.nuovo();
      final responsi = <ResponsoDellAlba>[];
      final ripieghiAlGiorno = <int>[];
      for (var g = 0; g < giorni; g++) {
        final e =
            diario.estrai(utente: 'persona $p', giorno: giorno(g), caso: caso);
        diario = e.dopo;
        responsi.add(e.responso);
        ripieghiAlGiorno.add(diario.ripieghi);
      }
      consegne += responsi.length;
      ripieghiTotali += diario.ripieghi;

      for (final (nome, marca) in [
        (
          'primo movimento',
          (ResponsoDellAlba r) => DiarioDellAlba.apertura(r.primo)
        ),
        ('dono', (ResponsoDellAlba r) => DiarioDellAlba.apertura(r.secondo)),
        ('Medora', (ResponsoDellAlba r) => DiarioDellAlba.apertura(r.terzo)),
        ('parola', (ResponsoDellAlba r) => r.parola ?? ''),
      ]) {
        for (var i = 1; i < responsi.length; i++) {
          final mia = marca(responsi[i]);
          if (mia.isEmpty) continue;
          final da = i - finestra + 1 < 0 ? 0 : i - finestra + 1;
          for (var k = da; k < i; k++) {
            if (marca(responsi[k]) != mia) continue;
            ritorni++;
            // **Una marca torna soltanto quando il motore ha ripiegato quel
            // giorno**, e il ripiego e' contato: un ritorno muto sarebbe il
            // difetto vero, perche' nessuno saprebbe che il corpus si e'
            // stretto.
            expect(ripieghiAlGiorno[i], greaterThan(ripieghiAlGiorno[i - 1]),
                reason: 'persona $p: la marca "$mia" del $nome torna al giorno '
                    '$i dopo il giorno $k, dentro la finestra di $finestra, e '
                    'nessun ripiego e\' stato contato');
          }
        }
      }

      // **Uno stato che torna non porta la stessa lettura** finche' le sue
      // dodici non sono finite: la coda si consuma prima di rifornirsi.
      for (var i = 1; i < responsi.length; i++) {
        if (responsi[i].stato == responsi[i - 1].stato) diFila++;
      }
      final perStato = <int, List<int>>{};
      for (final r in responsi) {
        perStato.putIfAbsent(r.stato.id, () => []).add(r.lettura.numero);
      }
      for (final e in perStato.entries) {
        if (e.value.length > 12) continue;
        expect(e.value.toSet(), hasLength(e.value.length),
            reason: 'persona $p, stato ${e.key}: letture ${e.value}');
      }
    }
    // **QUANTO COSTA L'ESTRAZIONE LIBERA**, in numeri e non a sensazione: col
    // sacchetto i ripieghi erano zero, perche' il sacchetto garantiva uno
    // stato nuovo ogni giorno. Restano rari, e il tetto e' un venticinquesimo
    // delle consegne: sopra quello il corpus e' troppo stretto e si allarga.
    print('ORDINE DU voce 12: consegne $consegne, ripieghi $ripieghiTotali, '
        'marche tornate dentro la finestra $ritorni');
    expect(ripieghiTotali, lessThan(consegne / 25),
        reason: 'i ripieghi sono $ripieghiTotali su $consegne consegne');
    // **La prova che l'estrazione e' davvero libera**: su venticinque persone
    // e centotrentadue giorni lo stesso stato si ripete il giorno dopo, e
    // nessuna riga qui sopra lo vieta.
    print('ORDINE DU voce 11: lo stesso stato due giorni di fila $diFila volte '
        'su ${persone * (giorni - 1)} coppie di giorni');
    expect(diFila, greaterThan(0),
        reason: 'in tremilaeduecento coppie di giorni la stessa carta non e\' '
            'mai tornata il giorno dopo: qualcosa lo sta vietando');
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
          for (var id = 0; id < StatoDellAlba.quanti; id++)
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
      final finestra = DiarioDellAlba.finestraDelRegistro;
      final tutti = vivi('carla', finestra * 3,
          corpus: corpusStretto(), dopo: (d) => finale = d);
      int stesse(List<ResponsoDellAlba> r) => r
          .where((x) => DiarioDellAlba.apertura(x.secondo) == 'stessa apertura')
          .length;

      // **Dentro la prima finestra** l'apertura comune passa una volta sola:
      // dalla seconda in poi il registro la vede usata e consegna la lettura
      // libera di quello stato.
      // La prima volta l'apertura comune e' libera e passa. Ogni altra volta
      // il registro la vede usata: passa soltanto quando quello stato non ha
      // piu' nessuna lettura libera in coda, e allora e' un ripiego contato.
      expect(stesse(tutti), greaterThan(1));

      // **Le letture saltate restano in coda**: non si perde niente. Con
      // l'estrazione libera uno stato torna anche tre volte in quarantaquattro
      // giorni, quindi la coda si svuota e si rifornisce: cio' che si misura
      // e' che nessuna lettura sparisca, non che la coda resti piena.
      late DiarioDellAlba dopoLaPrima;
      final prima = vivi('carla', finestra,
          corpus: corpusStretto(), dopo: (d) => dopoLaPrima = d);
      final consegnate = <int, Set<int>>{};
      for (final r in prima) {
        consegnate.putIfAbsent(r.stato.id, () => {}).add(r.lettura.numero);
      }
      for (final e in consegnate.entries) {
        final coda = dopoLaPrima.code[e.key] ?? const <int>[];
        expect({...e.value, ...coda}, {1, 2, 3},
            reason: 'stato ${e.key}: consegnate ${e.value}, in coda $coda');
      }

      // **Quando le libere finiscono si consegna lo stesso**, e ogni consegna
      // che riusa una marca in vigore e' un ripiego contato, non un passaggio
      // muto: e' l'unico modo di sapere che il corpus si sta stringendo.
      expect(finale.ripieghi, greaterThan(0),
          reason: 'con tre letture per stato e centotrentadue giorni i '
              'ripieghi non possono restare zero');
      expect(stesse(tutti) - 1, lessThanOrEqualTo(finale.ripieghi),
          reason: 'l\'apertura comune e\' passata piu\' volte di quanti '
              'ripieghi il motore ha contato');
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
        'due persone con lo stesso caso ricevono lo stesso stato e testi '
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
          for (var id = 0; id < StatoDellAlba.quanti; id++)
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
          final giorni = 1 + caso.nextInt(StatoDellAlba.quanti * 2);
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
