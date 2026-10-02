// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/services/ai/l_etichetta_della_funzione.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'cardinale_minimo.dart';
import 'sorgenti_di_lib.dart';

/// **OGNI CHIAMATA AL MODELLO PORTA L'ETICHETTA DELLA SUA FUNZIONE.** Ordine
/// EW, voce EW.03, 2 ottobre 2026.
///
/// La stima dei costi dei 30 giorni non ha potuto dividere il costo di
/// Gemini fra le funzioni dell'app. Ogni chiamata al modello del telefono
/// (`generativeModel(` in `lib`) passa adesso un [ClientConEtichetta], che
/// mette `labels: {funzione: ...}` nel corpo della richiesta; ogni chiamata
/// di sintesi delle funzioni del server porta `labels` nel corpo. Il report
/// Fatturazione divide cosi' il costo per funzione.
void main() {
  /// Il testo della chiamata che comincia in [inizio], fino alla parentesi
  /// che la chiude.
  String chiamata(String s, int inizio) {
    var livello = 0;
    for (var i = s.indexOf('(', inizio); i < s.length; i++) {
      if (s[i] == '(') livello++;
      if (s[i] == ')' && --livello == 0) return s.substring(inizio, i + 1);
    }
    return s.substring(inizio);
  }

  test(
      'ORDINE EW VOCE 03: ogni generativeModel del telefono porta '
      'l\'etichetta', () {
    var chiamate = 0;
    final senza = <String>[];
    final etichette = <String>{};
    for (final f in sorgentiDiLib()) {
      final s = f.readAsStringSync();
      for (final m in RegExp(r'\.generativeModel\(').allMatches(s)) {
        chiamate++;
        final c = chiamata(s, m.start);
        final e = RegExp(r'httpClient:\s*ClientConEtichetta\(([\s\S]*?)\)\s*,')
            .firstMatch(c);
        if (e == null) {
          senza.add('${f.path}:${s.substring(0, m.start).split('\n').length}');
        } else {
          etichette.addAll(RegExp(r'LeFunzioniDelModello\.(\w+)')
              .allMatches(e.group(1)!)
              .map((x) => x.group(1)!));
        }
      }
    }
    cardinaleMinimo(chiamate, 13, cosa: 'chiamate al modello nel telefono');
    print('ORDINE EW VOCE 03: chiamate al modello nel telefono $chiamate, '
        'con l\'etichetta ${chiamate - senza.length}, etichette diverse '
        '${etichette.length}');
    expect(senza, isEmpty,
        reason: 'chiamate senza etichetta:\n${senza.join('\n')}');
  });

  test(
      'ORDINE EW VOCE 03: le chiamate di sintesi del server portano '
      'l\'etichetta', () {
    final s = File('functions/src/live.ts').readAsStringSync();
    // Le righe di codice che compongono l'indirizzo di Gemini, non i
    // commenti che lo nominano.
    final chiamate = s
        .split('\n')
        .where((r) =>
            !r.trimLeft().startsWith('//') &&
            !r.trimLeft().startsWith('*') &&
            r.contains('enerateContent'))
        .length;
    final conEtichetta = RegExp(r'labels:\s*\{funzione:').allMatches(s).length;
    cardinaleMinimo(chiamate, 2, cosa: 'chiamate a Gemini nel server');
    print('ORDINE EW VOCE 03: chiamate a Gemini nel server $chiamate, con '
        'l\'etichetta $conEtichetta');
    expect(conEtichetta, chiamate);
  });

  test('ORDINE EW VOCE 03: l\'etichetta arriva nel corpo, il resto no',
      () async {
    for (final e in LeFunzioniDelModello.tutte) {
      expect(ClientConEtichetta.valida(e), isTrue, reason: e);
    }
    String? arrivato;
    final finto = _Finto((r) => arrivato = r.body);
    final client =
        ClientConEtichetta(LeFunzioniDelModello.viaggioScena, interno: finto);
    await client.post(Uri.parse('https://esempio/m:generateContent'),
        body: jsonEncode({
          'contents': [],
          'generationConfig': {'temperature': 0.8}
        }));
    final j = jsonDecode(arrivato!) as Map<String, dynamic>;
    print('ORDINE EW VOCE 03: corpo arrivato $j');
    expect(j['labels'], {'funzione': 'viaggio_scena'});
    expect(j['generationConfig'], {'temperature': 0.8});
    expect(ClientConEtichetta.conEtichetta('non json', 'x'), 'non json');
  });
}

class _Finto extends http.BaseClient {
  _Finto(this.vede);
  final void Function(http.Request) vede;
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    vede(request as http.Request);
    return http.StreamedResponse(Stream.value(utf8.encode('{}')), 200);
  }
}
