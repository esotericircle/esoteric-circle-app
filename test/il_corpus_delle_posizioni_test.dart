// IL CORPUS DELLE POSIZIONI E I REGISTRI. Ordine FI voci 39 e 40, con
// l'aggiunta A3, A4, A6, A7 e A9 dell'11 ottobre 2026.
//
// I testi li scrive l'Architetto e arrivano a ondate, una posizione per
// volta. Questa guardia non pretende che ci siano tutti oggi: pretende che lo
// stato dichiarato qui sotto sia quello vero, che ogni testo che c'e' sia
// intero e diverso dagli altri, che il Dart sia quello della fonte, e che
// nessuna stesa si apra con una posizione senza fonte. A ogni ondata si
// aggiorna la dichiarazione, e il cardinale sale da solo.
//
// Il cardinale finale e' quello della voce FI.39, riportato alle quattordici
// posizioni dall'ordine FJ, aggiunta 2 (il ferro di cavallo tolto con le sue
// tre posizioni orfane): quattordici posizioni per centocinquantasei
// carte-verso per tre varianti, 6.552 scheletri (erano 7.956); e dall'ordine
// FK voce 8 quindici, con `dietro`, 7.020 scheletri; piu' i 468
// registri della voce FI.40.

import 'dart:io';

import 'package:esoteric_circle/core/tarot/le_carte_nella_posizione.dart';
import 'package:esoteric_circle/core/tarot/le_carte_nella_posizione_dati.dart';
import 'package:esoteric_circle/core/tarot/tarot_card.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread_type.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **LO STATO DICHIARATO**: quante varianti piene ha oggi ogni posizione.
/// Le tre della stesa a tre carte hanno la variante 1 del corpus del 27
/// settembre; il lato ha le tre varianti dall'ordine FJ (la prima ondata
/// dell'Architetto, commit 65fceaae); le altre tredici aspettano. Quando
/// arriva un'ondata, il numero di quella posizione passa a 3.
const Map<SpreadPosition, int> variantiDichiarate = {
  SpreadPosition.passato: 3,
  SpreadPosition.presente: 3,
  SpreadPosition.futuro: 3,
  SpreadPosition.cartaSola: 3,
  SpreadPosition.consultante: 3,
  SpreadPosition.lato: 3,
  SpreadPosition.esito: 3,
  SpreadPosition.copre: 3,
  SpreadPosition.attraversa: 3,
  SpreadPosition.corona: 3,
  SpreadPosition.sotto: 3,
  SpreadPosition.dietro: 0,
  SpreadPosition.seStesso: 3,
  SpreadPosition.laCasa: 3,
  SpreadPosition.speranzeOTimori: 3,
};

/// I registri: veri dall'ordine FM, 12 ottobre 2026, scritti da Code coi tre
/// gruppi pieni (prima falso, finche' l'Architetto non li consegnava).
const bool registriConsegnati = true;

const _versi = ['dritta', 'capovolta'];
const _fonte = 'docs/corpus/tarocchi_posizione';

/// Il nome del file della fonte per la posizione [p], come nel tool.
String fileDi(SpreadPosition p) =>
    p.name.replaceAllMapped(RegExp('[A-Z]'), (m) => '_${m[0]!.toLowerCase()}');

/// Le righe di un file della fonte: {carta|verso: {chiave: testo}}.
Map<String, Map<String, String>> leggiLaFonte(String percorso) {
  final dati = <String, Map<String, String>>{};
  String? carta, verso;
  for (final riga in File(percorso).readAsLinesSync()) {
    final c = RegExp(r'^## (.+)$').firstMatch(riga);
    if (c != null) {
      carta = c[1]!.trim();
      continue;
    }
    final v = RegExp(r'^### (dritta|capovolta)$').firstMatch(riga);
    if (v != null) {
      verso = v[1];
      dati['$carta|$verso'] = {};
      continue;
    }
    final t = RegExp(r'^- (\w+):(.*)$').firstMatch(riga);
    if (t != null && verso != null) {
      dati['$carta|$verso']![t[1]!] = t[2]!.trim();
    }
  }
  return dati;
}

void main() {
  test('FI.39: lo stato dichiarato e\' quello vero, e ogni testo c\'e\'', () {
    final colpe = <String>[];
    var testi = 0;
    for (final p in SpreadPosition.values) {
      final attese = variantiDichiarate[p];
      if (attese == null) {
        colpe.add('${p.name}: posizione non dichiarata');
        continue;
      }
      for (final c in TarotDeck.cards) {
        for (final v in _versi) {
          final varianti = scheletriDelleCarte['${p.name}|${c.name}|$v'];
          final n = varianti?.length ?? 0;
          if (n != attese) {
            colpe.add('${p.name}|${c.name}|$v: $n varianti, dichiarate '
                '$attese');
          }
          for (final t in varianti ?? const <String>[]) {
            if (t.trim().isEmpty) {
              colpe.add('${p.name}|${c.name}|$v: un testo vuoto');
            }
            testi++;
          }
        }
      }
    }
    final dichiarati = variantiDichiarate.values.fold(0, (a, n) => a + n) *
        TarotDeck.cards.length *
        _versi.length;
    cardinaleMinimo(testi, dichiarati,
        cosa: 'scheletri del corpus delle posizioni',
        perche: 'le varianti dichiarate per centocinquantasei carte-verso; '
            'a corpus intero sono 7.020');
    expect(colpe.take(10).toList(), isEmpty,
        reason: '${colpe.length} scostamenti dalla dichiarazione');
    expect(SpreadPosition.values, hasLength(15));
  });

  test('FI.39: nessun testo uguale a un altro', () {
    final visti = <String, String>{};
    final doppi = <String>[];
    scheletriDelleCarte.forEach((chiave, varianti) {
      for (var i = 0; i < varianti.length; i++) {
        final dove = '$chiave, variante ${i + 1}';
        final prima = visti[varianti[i]];
        if (prima != null) doppi.add('$dove e $prima');
        visti[varianti[i]] = dove;
      }
    });
    cardinaleMinimo(visti.length, 468,
        cosa: 'testi diversi del corpus',
        perche: 'almeno quelli della '
            'stesa a tre carte');
    expect(doppi, isEmpty, reason: 'testi uguali: $doppi');
  });

  test('FI.39: una terna non comincia tre volte con la stessa parola', () {
    final colpe = <String>[];
    scheletriDelleCarte.forEach((chiave, varianti) {
      if (varianti.length < 3) return;
      final prime = {
        for (final t in varianti)
          t.split(' ').first.toLowerCase().replaceAll(RegExp(r"[,.']"), ''),
      };
      if (prime.length < varianti.length) colpe.add(chiave);
    });
    expect(colpe, isEmpty,
        reason: 'terne che cominciano con la stessa parola: $colpe');
  });

  test('FI.39: il Dart e\' quello della fonte, e la fonte ha le 15 posizioni',
      () {
    final colpe = <String>[];
    var righe = 0;
    for (final p in SpreadPosition.values) {
      final percorso = '$_fonte/${fileDi(p)}.md';
      if (!File(percorso).existsSync()) {
        colpe.add('manca $percorso');
        continue;
      }
      final fonte = leggiLaFonte(percorso);
      for (final c in TarotDeck.cards) {
        for (final v in _versi) {
          final r = fonte['${c.name}|$v'];
          if (r == null || r.length != 3) {
            colpe.add('$percorso: ${c.name}, $v senza le tre righe');
            continue;
          }
          righe += 3;
          final piene = [
            for (final k in const ['1', '2', '3'])
              if (r[k]!.isNotEmpty) r[k]!,
          ];
          final nelDart =
              scheletriDelleCarte['${p.name}|${c.name}|$v'] ?? const [];
          if (piene.join('\n') != nelDart.join('\n')) {
            colpe.add('${p.name}|${c.name}|$v: il Dart non e\' la fonte, '
                'rilanciare tool/genera_carte_nella_posizione.py');
          }
        }
      }
    }
    cardinaleMinimo(righe, 7020,
        cosa: 'righe della fonte, piene o da riempire',
        perche: 'quindici posizioni per centocinquantasei carte-verso per '
            'tre varianti (aggiunta A4)');
    expect(colpe.take(10).toList(), isEmpty,
        reason: '${colpe.length} scostamenti fra fonte e Dart');
  });

  // **LA PROVENIENZA NON SI PERDE.** Ordine FJ voce 4: una posizione che porta
  // testi dice in testa da dove vengono e con quale misura sono stati scelti.
  // Senza quel paragrafo, fra un mese nessuno sa piu' da dove vengono 468 testi.
  // `prepara` non riscrive mai un file che esiste; questa prova prende chi lo
  // toglie a mano.
  test('FJ.4: ogni posizione con testi dice da dove vengono', () {
    final senza = <String>[];
    var guardate = 0;
    for (final p in SpreadPosition.values) {
      if ((variantiDichiarate[p] ?? 0) == 0) continue;
      guardate++;
      final testa = File('$_fonte/${fileDi(p)}.md')
          .readAsStringSync()
          .split(RegExp(r'^## ', multiLine: true))
          .first;
      final provenienza = RegExp(
          r'^\*\*(La variante 1 viene|Le tre varianti vengono)',
          multiLine: true);
      if (!provenienza.hasMatch(testa)) senza.add(fileDi(p));
    }
    cardinaleMinimo(guardate, 7,
        cosa: 'posizioni con testi',
        perche: 'passato, presente, futuro, lato, consultante, esito e carta '
            'sola');
    expect(senza, isEmpty, reason: 'senza la provenienza: $senza');
  });

  test('FI.40: ogni carta ha i suoi tre registri, oppure nessuna', () {
    final fonte = leggiLaFonte('$_fonte/registri.md');
    var righe = 0;
    final colpe = <String>[];
    for (final c in TarotDeck.cards) {
      for (final v in _versi) {
        final r = fonte['${c.name}|$v'];
        final gruppi = TarotTopicGroup.values.map((g) => g.name).toList();
        if (r == null || !gruppi.every(r.containsKey)) {
          colpe.add('registri.md: ${c.name}, $v senza le tre righe');
          continue;
        }
        righe += 3;
        final nelDart = registriDelleCarte['${c.name}|$v'];
        if (registriConsegnati) {
          if (nelDart == null ||
              nelDart.length != 3 ||
              nelDart.any((t) => t.trim().isEmpty)) {
            colpe.add('${c.name}|$v: non ha i suoi tre registri');
          } else if (nelDart.join('\n') != gruppi.map((g) => r[g]).join('\n')) {
            colpe.add('${c.name}|$v: il Dart non e\' la fonte');
          }
        }
      }
    }
    cardinaleMinimo(righe, 468,
        cosa: 'righe dei registri nella fonte',
        perche: 'settantotto carte per due versi per tre gruppi');
    if (registriConsegnati) {
      cardinaleMinimo(registriDelleCarte.length, 156,
          cosa: 'carte-verso coi registri', perche: 'il corpus intero');
    } else {
      expect(registriDelleCarte, isEmpty,
          reason: 'i registri sono arrivati: dichiararli consegnati');
    }
    expect(colpe, isEmpty, reason: colpe.join('\n'));
  });

  test('A6 e A7: nessuna stesa si apre con una posizione senza fonte', () {
    final colpe = <String>[];
    for (final t in TarotSpreadType.values) {
      final senza = [
        for (final p in t.posizioni)
          if (!LeCarteNellaPosizione.haLaFonte(p)) p.name,
      ];
      if (t.disponibile && senza.isNotEmpty) {
        colpe.add('${t.name} si apre senza la fonte di $senza');
      }
    }
    expect(colpe, isEmpty, reason: colpe.join('\n'));
    expect(TarotSpreadType.treCarte.disponibile, isTrue,
        reason: 'la stesa a tre carte resta viva (aggiunta A6)');
    for (final p in SpreadPosition.values) {
      expect(LeCarteNellaPosizione.haLaFonte(p), variantiDichiarate[p]! > 0,
          reason: '${p.name}: la fonte non e\' quella dichiarata');
    }
  });

  test('il montaggio: scheletro, poi registro del gruppo', () {
    final d = DrawnCard(
        card: TarotDeck.cards.first,
        position: SpreadPosition.presente,
        reversed: false);
    final scheletro = LeCarteNellaPosizione.di(d);
    expect(scheletro,
        scheletriDelleCarte[LeCarteNellaPosizione.chiaveDi(d)]!.first);
    for (final g in TarotTopicGroup.values) {
      final registro = LeCarteNellaPosizione.registroDi(d, g);
      expect(LeCarteNellaPosizione.letturaDiCasa(d, g),
          registro == null ? scheletro : '$scheletro $registro');
    }
  });
}
