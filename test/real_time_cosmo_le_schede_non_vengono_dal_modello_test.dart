// LE SCHEDE DEL CIELO PROFONDO NON VENGONO DAL MODELLO. Ordine FH voci 10.3,
// 10.5 e 15.6.
//
// 1. Ogni scheda in lib e' il corpus dell'Architetto parola per parola: la
//    prova rilegge docs/corpus/cielo_profondo.md per conto suo (righe di un
//    paragrafo unite da uno spazio) e confronta ogni parte. Se qualcuno
//    riscrive una scheda in lib, o il corpus cambia senza rilanciare il
//    generatore, cade.
// 2. Le cinque schede ci sono tutte, una per oggetto di kCieloProfondo
//    (cardinale minimo dichiarato: 5).
// 3. Nessun file che compone o disegna le schede tocca un modello: niente
//    AiProvider, niente firebase_ai, niente Gemini.
// 4. Nessuna riga promette un esito: ne' salute, ne' fortuna, ne'
//    protezione.

import 'dart:io';

import 'package:esoteric_circle/core/astro/real_time_cosmo/i_bersagli_del_cielo.dart';
import 'package:esoteric_circle/core/astro/real_time_cosmo/le_schede_del_cielo_profondo.dart';
import 'package:flutter_test/flutter_test.dart';

const _cardinale = 5;

/// Il corpus riletto: titolo e paragrafi di ogni scheda.
Map<String, List<String>> _corpus() {
  final testo = File('docs/corpus/cielo_profondo.md')
      .readAsStringSync()
      .replaceAll('\r\n', '\n');
  final fuori = <String, List<String>>{};
  for (final blocco in testo.split('\n## ').skip(1)) {
    final righe = blocco.split('\n');
    final paragrafi = <String>[];
    var corrente = <String>[];
    for (final r in righe.skip(1)) {
      final t = r.trim();
      if (t == '---') break;
      if (t.isEmpty) {
        if (corrente.isNotEmpty) paragrafi.add(corrente.join(' '));
        corrente = [];
      } else {
        corrente.add(t);
      }
    }
    if (corrente.isNotEmpty) paragrafi.add(corrente.join(' '));
    fuori[righe.first.trim()] = paragrafi;
  }
  return fuori;
}

String _parte(List<String> paragrafi, String capo) {
  final p = paragrafi.firstWhere((p) => p.startsWith('**$capo**'));
  return p.substring(capo.length + 4).trim();
}

void main() {
  test('ogni scheda e\' il corpus parola per parola', () {
    final corpus = _corpus();
    expect(kSchedeDelCieloProfondo.length, greaterThanOrEqualTo(_cardinale));
    for (final s in kSchedeDelCieloProfondo) {
      final p = corpus[s.titolo];
      expect(p, isNotNull, reason: '${s.titolo} non sta nel corpus');
      expect(s.apertura, _parte(p!, 'Apertura.'));
      expect(s.fatto, _parte(p, 'Il fatto.'));
      expect(s.fattoUmano, _parte(p, 'Il fatto umano.'));
      expect('${s.forma} ${s.stagione}', _parte(p, 'La riga pratica.'));
    }
  });

  test('una scheda per ognuno dei cinque oggetti', () {
    expect(kCieloProfondo.length, _cardinale);
    for (final o in kCieloProfondo) {
      expect(kSchedeDelCieloProfondo.where((s) => s.id == o.id).length, 1,
          reason: '${o.nome} non ha la sua scheda');
    }
  });

  test('chi compone e disegna le schede non tocca un modello', () {
    const file = [
      'lib/core/astro/real_time_cosmo/le_schede_del_cielo_profondo.dart',
      'lib/features/real_time_cosmo/il_cielo_profondo_in_scena.dart',
      'lib/features/real_time_cosmo/cielo_reale_screen.dart',
    ];
    final modello = RegExp(
        r'AiProvider|firebase_ai|FirebaseMaestroAiProvider|gemini|services/ai/',
        caseSensitive: false);
    for (final f in file) {
      final t = File(f).readAsStringSync();
      expect(modello.hasMatch(t), isFalse,
          reason: '$f nomina un modello: ${modello.firstMatch(t)?.group(0)}');
    }
  });

  test('nessuna riga promette un esito', () {
    final promessa = RegExp(
        r'fortun|salute|guari|protegg|protezion|porta bene|attira|benedi',
        caseSensitive: false);
    for (final s in kSchedeDelCieloProfondo) {
      for (final r in [s.apertura, s.fatto, s.fattoUmano, s.stagione]) {
        expect(promessa.hasMatch(r), isFalse,
            reason: '${s.titolo}: "${promessa.firstMatch(r)?.group(0)}"');
      }
    }
  });
}
