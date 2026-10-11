// LA FONTE DEI SIGNIFICATI NON SI CONFONDE. Ordine FJ, aggiunta A6, 11
// ottobre 2026.
//
// Ventotto carte-verso della posizione lato non si riconoscevano perche' la
// fonte, `lib/core/tarot/tarot_card.dart`, dava a due carte la stessa materia:
// nessuno misurava se due voci dicessero la stessa cosa. Questa guardia lo
// misura sulle 156 carte-verso (sintesi e testo pieno insieme).
//
// **LA GRANDEZZA.** Non la somiglianza di Jaccard sulle parole: misurata
// prima delle correzioni, le collisioni dell'ordine stavano fra 0 e 0,18 e
// altre coppie arrivavano a 0,22 con mediana 0 (docs/collaudo/FJ/
// la_fonte_prima_e_dopo.txt). Si misurano le IMMAGINI RARE IN COMUNE: le
// radici di cinque lettere che compaiono in non piu' di sei delle 156 voci
// (l'onda, lo slancio, le fondamenta, lo scudo), ciascuna pesata con
// ln(156 / quante voci la portano). Una parola che sta ovunque non pesa.
//
// **CIO' CHE NON PUO' VEDERE**, e va detto: due voci che dicono la stessa
// cosa con parole diverse (il Re e la Regina di Coppe, Gli Amanti e i Due)
// hanno zero radici rare in comune. Nessuna soglia lessicale separa le
// tredici collisioni da tutte le altre coppie: per quelle serve un lettore.
//
// Tre regole:
// 1. le coppie che l'ordine FJ ha nominato (FJ.16 e FJ.18) restano sotto
//    5,0: prima delle correzioni erano 11 su 28 (massimo 17,47), dopo 0
//    (massimo 4,36);
// 2. nessuna coppia di carte diverse condivide una frase di sei o piu' parole
//    di fila: oggi la piu' lunga e' di cinque, e sono formule ("e' il momento
//    di prendere");
// 3. nessuna altra coppia sale sopra il massimo misurato dopo le correzioni,
//    23,6 (L'Imperatore dritto e capovolto, che parlano della stessa
//    struttura dai due lati): chi scrive una voce nuova che si avvicina a
//    un'altra piu' di cosi' la vede cadere. E' una soglia contro il
//    peggioramento, non un elenco delle collisioni: sotto stanno anche
//    coppie da guardare, come L'Imperatrice e la Regina di Denari dritte
//    (21,1), che si giudicano leggendo.

import 'dart:math' as math;

import 'package:esoteric_circle/core/tarot/tarot_card.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

const _vuote = {
  'il', 'lo', 'la', 'i', 'gli', 'le', 'un', 'uno', 'una', 'di', 'a', 'da', //
  'in', 'con', 'su', 'per', 'tra', 'fra', 'e', 'ed', 'o', 'od', 'ma', 'se',
  'che', 'chi', 'non', 'ne', 'ci', 'si', 'ti', 'mi', 'vi', 'tu', 'io', 'te',
  'me', 'lui', 'lei', 'noi', 'voi', 'loro', 'del', 'dello', 'della', 'dei',
  'degli', 'delle', 'al', 'allo', 'alla', 'ai', 'agli', 'alle', 'dal',
  'dallo', 'dalla', 'dai', 'dagli', 'dalle', 'nel', 'nello', 'nella', 'nei',
  'negli', 'nelle', 'col', 'coi', 'sul', 'sullo', 'sulla', 'sui', 'sugli',
  'sulle', 'è', 'sei', 'sono', 'era', 'hai', 'ha', 'ho', 'anche', 'come',
  'piu', 'più', 'molto', 'poco', 'qui', 'li', 'là', 'cio', 'ciò', 'questo',
  'questa', 'quello', 'quella', 'tuo', 'tua', 'tuoi', 'tue', 'suo', 'sua',
  'suoi', 'sue', 'gia', 'già', 'ancora', 'quando', 'dove', 'perche',
  'perché', 'cosa', 'ogni', 'tutto', 'tutta', 'tutti', 'tutte', 'solo',
  'senza', 'oppure', 'invece', 'contrario', 'modo',
};

/// Le coppie nominate dall'ordine FJ: le collisioni di FJ.16 e i confini
/// porosi di FJ.18, come carta e verso.
const _coppieNote = [
  ['Re di Coppe|c', 'Regina di Coppe|c'],
  ['Re di Coppe|c', 'Regina di Coppe|d'],
  ['Re di Coppe|c', 'Asso di Coppe|c'],
  ['Cavaliere di Denari|c', 'Quattro di Denari|c'],
  ['Cavaliere di Denari|c', 'Fante di Denari|c'],
  ['Cavaliere di Denari|c', 'Asso di Bastoni|c'],
  ['Fante di Denari|c', 'Otto di Denari|c'],
  ['Tre di Bastoni|c', 'Otto di Bastoni|c'],
  ['Gli Amanti|c', 'Due di Denari|d'],
  ['Gli Amanti|c', 'Due di Spade|d'],
  ['Gli Amanti|c', 'Due di Coppe|d'],
  ['Gli Amanti|c', 'Due di Denari|c'],
  ['Gli Amanti|c', 'Due di Spade|c'],
  ['Gli Amanti|c', 'Due di Coppe|c'],
  ['Dieci di Coppe|c', 'Due di Coppe|c'],
  ['Regina di Denari|c', 'Sei di Denari|d'],
  ['Dieci di Spade|c', 'Cinque di Denari|c'],
  ['Dieci di Spade|c', 'Nove di Spade|c'],
  ['Fante di Bastoni|c', 'Cavaliere di Bastoni|c'],
  ['Nove di Bastoni|c', 'Sette di Bastoni|c'],
  ['La Giustizia|c', 'Sette di Spade|c'],
  ['Dieci di Denari|c', 'Quattro di Bastoni|c'],
  ['Fante di Coppe|c', 'Regina di Coppe|c'],
  ['Dieci di Denari|d', 'Dieci di Denari|c'],
  ['Quattro di Coppe|d', 'Quattro di Coppe|c'],
  ['Dieci di Spade|d', 'Dieci di Spade|c'],
  ['Nove di Bastoni|d', 'Nove di Bastoni|c'],
  ['Nove di Denari|d', 'Nove di Denari|c'],
  // **Le coppie dell'ordine FK** (voci 17, 18 e 19), aggiunte per la decisione
  // FK.10: la guardia tiene le coppie che una persona ha trovato leggendo, e
  // impedisce che tornino a somigliarsi nelle parole.
  ["L'Imperatrice|d", 'Regina di Denari|d'],
  ["L'Imperatrice|c", 'Regina di Denari|c'],
  ['Il Sole|d', 'Regina di Bastoni|d'],
  ['Il Sole|c', 'Regina di Bastoni|c'],
  ['Quattro di Denari|d', 'Quattro di Denari|c'],
  ['Quattro di Denari|c', 'Re di Denari|c'],
  ['Nove di Bastoni|c', 'Sette di Bastoni|c'],
  ['Asso di Coppe|c', 'Due di Coppe|c'],
  ['Sei di Bastoni|c', 'Regina di Bastoni|c'],
];

const double sogliaDelleCoppieNote = 5.0;
const int fraseIntera = 6;
const double tettoDelleAltre = 23.65;
const int raritaMassima = 6;

class _Voce {
  _Voce(this.chiave, this.testo);
  final String chiave;
  final String testo;
}

List<String> _parole(String t) => RegExp('[a-zàèéìòù]+')
    .allMatches(t.toLowerCase())
    .map((m) => m.group(0)!)
    .toList();

Set<String> _radici(String t) => {
      for (final w in _parole(t))
        if (!_vuote.contains(w)) w.length > 5 ? w.substring(0, 5) : w,
    };

int _fraseComune(String a, String b) {
  final x = _parole(a), y = _parole(b);
  var meglio = 0;
  for (var i = 0; i < x.length; i++) {
    for (var j = 0; j < y.length; j++) {
      var k = 0;
      while (i + k < x.length && j + k < y.length && x[i + k] == y[j + k]) {
        k++;
      }
      if (k > meglio) meglio = k;
    }
  }
  return meglio;
}

void main() {
  final voci = [
    for (final c in TarotDeck.cards) ...[
      _Voce('${c.name}|d', '${c.uprightSummary} ${c.upright}'),
      _Voce('${c.name}|c', '${c.reversedSummary} ${c.reversed}'),
    ],
  ];
  final radici = [for (final v in voci) _radici(v.testo)];
  final quante = <String, int>{};
  for (final r in radici) {
    for (final x in r) {
      quante[x] = (quante[x] ?? 0) + 1;
    }
  }
  double punteggio(int i, int j) {
    var s = 0.0;
    for (final x in radici[i].intersection(radici[j])) {
      final n = quante[x]!;
      if (n <= raritaMassima) s += math.log(voci.length / n);
    }
    return s;
  }

  final indice = {for (var i = 0; i < voci.length; i++) voci[i].chiave: i};

  test('le voci sono 156', () {
    cardinaleMinimo(voci.length, 156,
        cosa: 'carte-verso della fonte dei significati',
        perche: 'settantotto carte per due versi');
  });

  test('1. le coppie nominate dall\'ordine FJ restano distinte', () {
    final colpe = <String>[];
    for (final c in _coppieNote) {
      final i = indice[c[0]], j = indice[c[1]];
      expect(i, isNotNull, reason: c[0]);
      expect(j, isNotNull, reason: c[1]);
      final p = punteggio(i!, j!);
      if (p >= sogliaDelleCoppieNote) {
        final comuni = radici[i]
            .intersection(radici[j])
            .where((x) => quante[x]! <= raritaMassima);
        colpe.add('${c[0]} e ${c[1]}: ${p.toStringAsFixed(2)} $comuni');
      }
    }
    cardinaleMinimo(_coppieNote.length, 37,
        cosa: 'coppie nominate', perche: 'FJ.16, FJ.18 e FK.17-FK.19');
    expect(colpe, isEmpty, reason: colpe.join('\n'));
  });

  test('2. nessuna frase intera in comune fra due carte diverse', () {
    final colpe = <String>[];
    var coppie = 0;
    for (var i = 0; i < voci.length; i++) {
      for (var j = i + 1; j < voci.length; j++) {
        if (voci[i].chiave.split('|').first ==
            voci[j].chiave.split('|').first) {
          continue;
        }
        coppie++;
        final n = _fraseComune(voci[i].testo, voci[j].testo);
        if (n >= fraseIntera) {
          colpe.add('${voci[i].chiave} e ${voci[j].chiave}: $n parole');
        }
      }
    }
    cardinaleMinimo(coppie, 12012,
        cosa: 'coppie di carte diverse', perche: '156 per 155 / 2 meno 78');
    expect(colpe, isEmpty, reason: colpe.join('\n'));
  });

  test('3. nessuna altra coppia sale sopra il tetto di oggi', () {
    final note = {
      for (final c in _coppieNote) ...['${c[0]}#${c[1]}', '${c[1]}#${c[0]}'],
    };
    final colpe = <String>[];
    var massimo = 0.0;
    for (var i = 0; i < voci.length; i++) {
      for (var j = i + 1; j < voci.length; j++) {
        if (note.contains('${voci[i].chiave}#${voci[j].chiave}')) continue;
        final p = punteggio(i, j);
        if (p > massimo) massimo = p;
        if (p > tettoDelleAltre) {
          colpe.add('${voci[i].chiave} e ${voci[j].chiave}: '
              '${p.toStringAsFixed(2)}');
        }
      }
    }
    // ignore: avoid_print
    print('FONTE DEI SIGNIFICATI: massimo delle altre coppie '
        '${massimo.toStringAsFixed(2)}, tetto $tettoDelleAltre');
    expect(colpe, isEmpty, reason: colpe.join('\n'));
  });
}
