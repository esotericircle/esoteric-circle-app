// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/horoscope/horoscope.dart';
import 'package:esoteric_circle/core/horoscope/i_testi_eu.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **I TESTI SONO QUELLI DELL'ARCHITETTO.** EU Aggiunta, 1 ottobre 2026.
///
/// *"Il codice li legge carattere per carattere e una prova lo confronta con
/// la fonte (Linee Guida, sezione 8). Code non cambia una virgola."* Qui i
/// dodici file di `docs/corpus/eu/` si leggono con un lettore scritto nella
/// prova, indipendente dal generatore, e ogni titolo, ogni paragrafo e ogni
/// apertura si confronta col testo che il codice porta: le differenze devono
/// essere zero. Si contano anche le voci di ogni fascia, quelle che la EU
/// Aggiunta dichiara: Giorno 30, 24 e 15; Settimana 14; Mese 4; Anno 2;
/// aperture del Giorno 30, 24 e 15.
void main() {
  const attese = {
    PeriodoEu.giorno: [30, 24, 15],
    PeriodoEu.settimana: [14, 14, 14],
    PeriodoEu.mese: [4, 4, 4],
    PeriodoEu.anno: [2, 2, 2],
  };
  const nomiDelleFasce = ['favorevole', 'equilibrio', 'salita'];

  test('ogni testo del codice e\' il testo del corpus, carattere per carattere',
      () {
    final differenze = <String>[];
    var voci = 0, aperture = 0, file = 0;
    for (final t in TradizioneEu.values) {
      for (final p in PeriodoEu.values) {
        final f = File('docs/corpus/eu/oroscopo_eu_${t.name}_${p.name}.md');
        final righe = f.readAsStringSync().replaceAll('\r\n', '\n').split('\n');
        file++;
        // Le voci: "#### <Dominio>, <fascia>, voce N: <Titolo>" e le quattro
        // righe che la seguono.
        for (var i = 0; i < righe.length; i++) {
          final m = RegExp(r'^#### (\w+), (\w+), voce (\d+): (.+)$')
              .firstMatch(righe[i]);
          if (m == null) continue;
          final d =
              HoroscopeDomain.values.firstWhere((x) => x.label == m.group(1));
          final fascia = FasciaEu.values[nomiDelleFasce.indexOf(m.group(2)!)];
          final n = int.parse(m.group(3)!) - 1;
          final campi = <String, String>{};
          var j = i + 1;
          while (j < righe.length && !righe[j].startsWith('#')) {
            final c = RegExp(r'^- ([^:]+): (.+)$').firstMatch(righe[j]);
            if (c != null) campi[c.group(1)!] = c.group(2)!;
            j++;
          }
          final codice = ITestiEu.fascia(t, p, d, fascia);
          final dove = '${t.name} ${p.name} ${d.label} ${fascia.name} ${n + 1}';
          if (n >= codice.length) {
            differenze.add('$dove: manca nel codice');
            continue;
          }
          final v = codice[n];
          voci++;
          for (final (nome, corpus, nelCodice) in [
            ('titolo', m.group(4), v.titolo),
            ('Risposta', campi['Risposta'], v.risposta),
            ('Che cosa fare', campi['Che cosa fare'], v.cosaFare),
            ('Risposta, Lunga', campi['Risposta, Lunga'], v.rispostaLunga),
            (
              'Che cosa fare, Lunga',
              campi['Che cosa fare, Lunga'],
              v.cosaFareLunga
            ),
          ]) {
            if (corpus != nelCodice) differenze.add('$dove, $nome');
          }
        }
        // Le aperture del Giorno.
        if (p == PeriodoEu.giorno) {
          var fascia = -1;
          var n = 0;
          for (final r in righe) {
            final testa = RegExp(r'^### Aperture, ').firstMatch(r);
            if (testa != null) {
              fascia++;
              n = 0;
              continue;
            }
            if (r.startsWith('## ') && fascia >= 0) break;
            final a = RegExp(r'^(\d+)\. (.+)$').firstMatch(r);
            if (a == null || fascia < 0) continue;
            final atteso = a.group(2)!;
            final nelCodice = ITestiEu.apertura(
                t, FasciaEu.values[fascia], n, ITestiEu.segnapostoDelNome);
            if (atteso != nelCodice) {
              differenze.add('${t.name} apertura ${fascia + 1}.${n + 1}');
            }
            n++;
            aperture++;
          }
        }
      }
    }
    // Le voci per fascia, come le dichiara la EU Aggiunta.
    for (final t in TradizioneEu.values) {
      for (final p in PeriodoEu.values) {
        for (final d in HoroscopeDomain.values) {
          for (final f in FasciaEu.values) {
            final n = ITestiEu.fascia(t, p, d, f).length;
            if (n != attese[p]![f.index]) {
              differenze.add('${t.name} ${p.name} ${d.label} ${f.name}: $n '
                  'voci invece di ${attese[p]![f.index]}');
            }
          }
        }
      }
    }
    cardinaleMinimo(file, 12, cosa: 'corpora letti');
    cardinaleMinimo(voci, 3 * 4 * (69 + 42 + 12 + 6), cosa: 'voci confrontate');
    cardinaleMinimo(aperture, 3 * 69, cosa: 'aperture confrontate');
    print('EU AGGIUNTA: $file corpora, $voci voci e $aperture aperture '
        'confrontate, differenze ${differenze.length}');
    expect(differenze, isEmpty, reason: differenze.take(20).join('\n'));
  });
}
