/// **LE RISPOSTE DEL VIAGGIO SEGUONO LE REGOLE, COME TUTTE LE ALTRE.**
/// Ordine DG voce 07, 11 settembre 2026.
///
/// **Parole del fondatore:** *"le risposte fanno cagare, scarne e non seguono
/// le regole delle risposte"*.
///
/// **Il difetto era misurabile dal codice prima ancora che a schermo.** La
/// risposta era **una frase sola**: apertura piu' corpo piu' chiusura, e
/// dentro non c'era ne' la domanda con cui si era scesi, ne' un gesto da fare,
/// ne' la fonte dichiarata.
///
/// Qui si misura che ci siano tutte e quattro le cose, e che **cento discese
/// con la stessa domanda** stiano dentro le quattro soglie del motore
/// dell'ordine DF voce 02.
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:esoteric_circle/core/viaggio/la_domanda_del_viaggio.dart';
import 'package:esoteric_circle/core/viaggio/la_voce_del_mondo_di_sotto.dart';
import 'package:esoteric_circle/core/viaggio/scena_del_viaggio.dart';

import 'motore_della_ripetizione.dart';

/// I due a capo che separano i paragrafi.
const dueACapo = '\n\n';

void main() {
  /// Cento discese con la stessa domanda, una al giorno.
  EsitoDellaRipetizione cento(String idDomanda, String tema) {
    final testi = <String>[];
    final composti = <String>[];
    final nomi = <List<String>>[];
    final simboli = <Set<String>>[];
    for (var i = 0; i < 100; i++) {
      final giorno = DateTime(2026, 1, 1).add(Duration(days: i));
      final scena = ScenaSenzaModello.componi(
        domanda: idDomanda,
        giorno: giorno,
        nitidezza: 1,
        discesa: i % 4,
      );
      final righe = LaVoceDelMondoDiSotto.paragrafi(
        scena: scena,
        temaDomanda: idDomanda,
        temaInLettere: tema,
        giornoDellaDiscesa: giorno,
      );
      testi.add([
        LaVoceDelMondoDiSotto.titolo(scena, idDomanda, giornoDellaDiscesa: giorno),
        ...righe,
      ].join(dueACapo));
      // **IL TITOLO NON E' UN PARAGRAFO COMPOSTO.** E' una riga scelta da un
      // elenco chiuso, come il testo di corpus di una carta nella Stesa: su
      // cento discese con otto titoli per tema la ripetizione e' matematica.
      // La misura D conta cio' che l'app **mette insieme**.
      composti.add(righe.join(dueACapo));
      // **I NOMI CHE LO SCHELETRO TOGLIE**: i pezzi della scena, che sono i
      // simboli di questa funzione come le carte lo sono della Stesa.
      nomi.add([
        scena.luogo.nome,
        scena.cosa.nome,
        scena.gesto.nome,
        scena.momento.nome,
      ]);
      simboli.add(scena.idDeiPezzi.toSet());
    }
    return MotoreDellaRipetizione.misura(
      funzione: 'Viaggio dello Sciamano, la voce del Mondo di Sotto',
      testi: testi,
      nomiPerTesto: nomi,
      testiComposti: composti,
      simboliPerTesto: simboli,
    );
  }

  test('LE QUATTRO GRANDEZZE, su cento discese con la stessa domanda', () {
    for (final d in LaDomandaDelViaggio.gliaScritte) {
      final m = cento(d.id, d.tema);
      // ignore: avoid_print
      print('ORDINE DG VOCE 07, domanda "${d.tema}": '
          'A ${m.testiDistinti} su 100, '
          'B ${m.scheletriDistinti} su 100, '
          'C ${(m.somiglianzaFraDiverse * 100).toStringAsFixed(1)} per cento '
          '(la peggiore in assoluto '
          '${(m.somiglianzaMassima * 100).toStringAsFixed(1)}), '
          'D ${m.quanteVolteIlParagrafo}');
      if (m.somiglianzaFraDiverse >= 0.30) {
        // ignore: avoid_print
        print('  i due piu simili senza simboli in comune:\n'
            '  UNO: ${m.testoDiverseUno}\n'
            '  DUE: ${m.testoDiverseDue}');
      }
      expect(m.testiDistinti, 100,
          reason: '${d.tema}: due discese hanno dato lo stesso identico testo');
      expect(m.scheletriDistinti, greaterThanOrEqualTo(95),
          reason: '${d.tema}: gli scheletri sono troppo pochi');
      expect(m.somiglianzaFraDiverse, lessThan(0.40),
          reason: '${d.tema}: due discese senza simboli in comune si '
              'somigliano troppo');
      expect(m.quanteVolteIlParagrafo, lessThanOrEqualTo(2),
          reason: '${d.tema}: un paragrafo torna troppe volte');
    }
  });

  test("L'ANATOMIA C'E' TUTTA: risposta, gesto, fonte", () {
    // **Ordine S voce 16**: la risposta, cosa puoi fare, da dove viene.
    for (final d in LaDomandaDelViaggio.gliaScritte) {
      final scena = ScenaSenzaModello.componi(
          domanda: d.id, giorno: DateTime(2026, 3, 3), nitidezza: 1);
      final righe = LaVoceDelMondoDiSotto.paragrafi(
        scena: scena,
        temaDomanda: d.id,
        temaInLettere: d.tema,
      );
      expect(righe.length, 3,
          reason: '${d.tema}: i paragrafi non sono tre');
      // 1. **LA RISPOSTA NOMINA LA DOMANDA**, per esteso o in due parole.
      // Vedi `temaInDueParole`: meta' delle riprese usano la forma corta, e
      // la domanda resta nominata lo stesso.
      final breve = LaVoceDelMondoDiSotto.temaInDueParole[d.id]!;
      final riga = righe.first.toLowerCase();
      expect(
          riga.contains(d.tema.toLowerCase()) ||
              riga.contains(breve.toLowerCase()),
          isTrue,
          reason: '${d.tema}: la risposta non nomina la domanda, ne per '
              'esteso ne in breve: "${righe.first}"');
      // 2. il gesto e' uno di quelli scritti.
      // **IL GESTO E' COMPOSTO**: cosa fare piu' quando, ordine DG voce 07.
      final gesto = LaVoceDelMondoDiSotto.cosaPuoiFare
          .where((g) => righe[1].contains(g));
      expect(gesto, isNotEmpty,
          reason: '${d.tema}: manca il gesto da fare in "${righe[1]}"');
      final tempo = LaVoceDelMondoDiSotto.quando
          .where((q) => righe[1].endsWith(q));
      expect(tempo, isNotEmpty,
          reason: '${d.tema}: il gesto non dice quando');
      // 3. la fonte porta dentro la scena.
      expect(righe[2], contains(scena.testo),
          reason: '${d.tema}: la fonte non dichiara la scena');
    }
  });

  test('IL TITOLO E GIA UNA RISPOSTA, e non nomina la scena', () {
    // **Gerarchia dettata dal fondatore il 3 settembre**: *"titolo diretto
    // che a colpo d'occhio e' gia' una risposta"*. Un titolo che nominasse il
    // luogo del sogno sarebbe un titolo sulla scena, e la scena e' la fonte,
    // non la risposta.
    final titoli = <String>{};
    for (final d in LaDomandaDelViaggio.gliaScritte) {
      for (var i = 0; i < 40; i++) {
        final scena = ScenaSenzaModello.componi(
            domanda: d.id,
            giorno: DateTime(2026, 1, 1).add(Duration(days: i)),
            nitidezza: 1);
        final t = LaVoceDelMondoDiSotto.titolo(scena, d.id);
        titoli.add(t);
        expect(t.length, lessThan(46),
            reason: 'titolo troppo lungo per essere un colpo d occhio: $t');
        for (final pezzo in [scena.luogo.nome, scena.cosa.nome]) {
          expect(t.toLowerCase(), isNot(contains(pezzo.toLowerCase())),
              reason: 'il titolo nomina la scena invece della risposta: $t');
        }
      }
    }
    // ignore: avoid_print
    print('ORDINE DG VOCE 07: i titoli distinti sono ${titoli.length}');
    expect(titoli.length, greaterThanOrEqualTo(20));
  });
}
