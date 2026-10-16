// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/core/chat/la_posizione_della_lettura.dart';
import 'package:esoteric_circle/core/chat/le_certezze_del_maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:flutter_test/flutter_test.dart';

/// **I MOTIVI DEGLI SCARTI.** Ordine EX Aggiunta 4, voce EX.07: quale rete
/// scarta la prima risposta della chat, e con quale frase. Rilegge le
/// risposte scartate salvate dal confronto della correzione corta
/// (`docs/collaudo/EX/qualita/corta.jsonl` e `corta_giro1/corta.jsonl`, o i
/// file dati con FILE=a,b) e le passa dalle stesse reti dell'app.
///
///     flutter test -r expanded tool/i_motivi_degli_scarti.dart
void main() {
  test('i motivi degli scarti', () {
    final file = (Platform.environment['FILE'] ??
            'docs/collaudo/EX/qualita/corta.jsonl,'
                'docs/collaudo/EX/qualita/corta_giro1/corta.jsonl')
        .split(',');
    final conti = <String, int>{};
    for (final f in file) {
      for (final riga in File(f).readAsLinesSync()) {
        if (riga.trim().isEmpty) continue;
        final d = jsonDecode(riga) as Map<String, dynamic>;
        final maestro = Maestro.values.firstWhere((m) => m.id == d['maestro']);
        final domanda = d['domanda'] as String;
        final prima = d['scartata'] as String;
        final motivi = <String>[];
        if (!LaPosizioneDellaLettura.rispetta(maestro, domanda, prima)) {
          motivi.add('posizione');
          print('${d['id']} POSIZIONE [$domanda] prima frase: '
              '«${LaPosizioneDellaLettura.primaFraseDi(prima)}»');
        }
        final certe = LeCertezzeDelMaestro.inQuesteFrasi(prima);
        if (certe.isNotEmpty) {
          motivi.add('certezza');
          print('${d['id']} CERTEZZA [$domanda] ${certe.join(' | ')}');
        }
        for (final m in motivi) {
          conti[m] = (conti[m] ?? 0) + 1;
        }
      }
    }
    print('CONTI: $conti');
  });
}
