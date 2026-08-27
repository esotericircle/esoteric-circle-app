import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:flutter_test/flutter_test.dart';

import 'gli_accenti_del_corpus.dart';

/// I TRE SENTIERI NASCONO DAL DATO. Ordine AR voce 02.
///
/// **Il corpus comanda, il codice e' la conseguenza.** I tre file dei sentieri
/// non si scrivono a mano: li genera `tool/genera_sentieri_dal_corpus.py` da
/// `docs/corpus/Traguardi_165_Revisione_E.json`, che dall ordine AU voce 03 e
/// il corpus vivo. Queste prove confrontano il
/// codice col file, voce per voce: se qualcuno tocca un nome nel Dart senza
/// toccare il corpus, cadono.
///
/// **Perche' si genera invece di trascrivere.** Centosessantacinque voci
/// copiate a mano introducono errori silenziosi, e un errore silenzioso in un
/// traguardo si scopre solo il giorno in cui non si accende.
void main() {
  final corpus = jsonDecode(
      File('docs/corpus/Traguardi_165_Revisione_E.json')
          .readAsStringSync()) as Map<String, dynamic>;
  final voci = <Map<String, dynamic>>[
    for (final s in corpus['sentieri'] as List)
      for (final v in (s as Map)['voci'] as List) v as Map<String, dynamic>,
  ];

  test('sono centosessantacinque, cinquantacinque per sentiero', () {
    expect(voci.length, 165, reason: 'il corpus non ne ha piu 165');
    expect(Sentieri.tuttiITraguardi.length, 165,
        reason: 'il codice ha ${Sentieri.tuttiITraguardi.length} traguardi '
            'invece di 165');
    for (final s in Sentiero.values) {
      expect(Sentieri.di(s).length, 55,
          reason: 'il sentiero ${s.name} ha ${Sentieri.di(s).length} voci');
    }
  });

  test('gli Eos tornano: 2.010 per sentiero e 6.030 in tutto', () {
    var totale = 0;
    for (final s in Sentiero.values) {
      final somma = Sentieri.di(s).fold<int>(0, (a, t) => a + t.eos);
      // ignore: avoid_print
      print('ORDINE AR VOCE 02: ${s.name} somma $somma Eos');
      expect(somma, Sentieri.eosAttesiPerSentiero,
          reason: 'il sentiero ${s.name} somma $somma Eos invece di '
              '${Sentieri.eosAttesiPerSentiero}');
      totale += somma;
    }
    expect(totale, Sentieri.eosAttesiInTutto);
  });

  test('ogni nome e ogni fascia sono quelli del file, verbatim', () {
    final perId = {
      for (final t in Sentieri.tuttiITraguardi) t.id: t,
    };
    final diversi = <String>[];
    for (final v in voci) {
      final mio = perId[v['id'] as String];
      if (mio == null) {
        diversi.add('${v['id']} manca nel codice');
        continue;
      }
      // **VERBATIM VUOL DIRE LE STESSE PAROLE, non gli stessi byte**: vedi
      // gli_accenti_del_corpus.dart. Il corpus scrive "e'", l'app mostra "è".
      if (mio.nome != conGliAccenti(v['nome'] as String)) {
        diversi.add('${v['id']} nome "${mio.nome}" invece di "${v['nome']}"');
      }
      if (mio.fascia != conGliAccenti(v['fascia'] as String)) {
        diversi.add('${v['id']} fascia "${mio.fascia}"');
      }
      if (mio.eos != v['eos']) {
        diversi.add('${v['id']} eos ${mio.eos} invece di ${v['eos']}');
      }
      if (mio.eGrande != (v['grande'] as bool)) {
        diversi.add('${v['id']} grande ${mio.eGrande}');
      }
    }
    // ignore: avoid_print
    print('ORDINE AR VOCE 02: scostamenti dal corpus ${diversi.length}');
    expect(diversi, isEmpty,
        reason: 'il codice si e scostato dal corpus: '
            '${diversi.take(5).join("; ")}');
  });

  test('le posizioni non hanno buchi, da 1 a 55', () {
    for (final s in Sentiero.values) {
      final posizioni = Sentieri.di(s).map((t) => t.posizione).toList()..sort();
      expect(posizioni, [for (var i = 1; i <= 55; i++) i],
          reason: 'le posizioni di ${s.name} hanno un buco o una ripetizione');
    }
  });

  test('i quindici grandi sono quindici, cinque per sentiero', () {
    for (final s in Sentiero.values) {
      expect(Sentieri.grandiDi(s).length, 5,
          reason: '${s.name} ha ${Sentieri.grandiDi(s).length} grandi');
    }
  });

  test('nessun traguardo e la riformulazione di un altro', () {
    // Due condizioni con la stessa firma sono lo stesso traguardo detto in
    // due modi: la persona lo vedrebbe accendersi due volte per un gesto solo.
    final firme = <String, String>{};
    final doppi = <String>[];
    for (final t in Sentieri.tuttiITraguardi) {
      if (t.dormiente) continue;
      final gia = firme[t.condizione.firma];
      if (gia != null) {
        doppi.add('${t.id} dice come $gia: ${t.condizione.firma}');
      } else {
        firme[t.condizione.firma] = t.id;
      }
    }
    // ignore: avoid_print
    print('ORDINE AR VOCE 02: condizioni ripetute ${doppi.length}');
    expect(doppi, isEmpty,
        reason: 'questi traguardi sono lo stesso traguardo detto due volte: '
            '${doppi.take(6).join("; ")}');
  });

  test('i file dei sentieri sono generati, non scritti a mano', () {
    for (final nome in const [
      'sentiero_costellazione',
      'sentiero_albero',
      'sentiero_loto',
    ]) {
      final sorgente =
          File('lib/core/sigilli/$nome.dart').readAsStringSync();
      expect(sorgente.contains('GENERATO DA tool/genera_sentieri_dal_corpus'),
          isTrue,
          reason: '$nome non dichiara piu di essere generato: qualcuno lo ha '
              'scritto a mano, e il corpus ha smesso di comandare');
    }
    expect(File('tool/genera_sentieri_dal_corpus.py').existsSync(), isTrue,
        reason: 'il generatore non esiste piu: il corpus nuovo non si potrebbe '
            'piu applicare');
  });
}
