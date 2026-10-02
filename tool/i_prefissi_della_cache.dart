// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/core/maestro/misura_della_risposta.dart';
import 'package:esoteric_circle/services/ai/la_cache_del_contesto.dart';
import 'package:flutter_test/flutter_test.dart';

/// **I PREFISSI DELLA CACHE E IL SUO TEMPLATE.** Ordine EX Aggiunta 4, voce
/// EX.05.
///
/// Scrive `functions/src/la_cache_prefissi.json`: per ogni variante (tre
/// Maestri, chat col seguito e senza) la parte comune dell'istruzione, che la
/// funzione `laCacheDelContesto` mette in cache, e l'impronta che il telefono
/// confronta con la sua. Si rifa' ogni volta che la parte comune cambia: la
/// guardia `test/i_prefissi_della_cache_sono_quelli_dell_app_test.dart`
/// diventa rossa finche' non si rifa'.
///
/// Scrive anche `docs/collaudo/EX/il_template_della_cache.txt`, il testo del
/// template di Firebase AI Logic che il fondatore crea nella console, con
/// la misura della risposta dell'app (il tetto della risposta col seguito e
/// il ragionamento).
///
///     flutter test -r expanded tool/i_prefissi_della_cache.dart
void main() {
  test('i prefissi della cache', () {
    final dati = {
      'impronta': LaCacheDelContesto.impronta(),
      'varianti': LaCacheDelContesto.prefissi(),
    };
    File('functions/src/la_cache_prefissi.json').writeAsStringSync(
        '${const JsonEncoder.withIndent('  ').convert(dati)}\n');
    print('PREFISSI: ${(dati['varianti'] as Map).length} varianti, impronta '
        '${dati['impronta']}');

    final turno = MisuraDellaRisposta.perIlTurno(nelLive: false);
    final tetto = turno.tetto + MisuraDellaRisposta.perIlSeguito.tetto;
    File('docs/collaudo/EX/il_template_della_cache.txt').writeAsStringSync(
        'IL TEMPLATE DELLA CACHE DEL CONTESTO. Ordine EX Aggiunta 4, voce '
        'EX.05.\n'
        'Si crea nella console di Firebase, AI Logic, Prompt templates, '
        'regione europe-west1, con l\'identificativo '
        '"${LaCacheDelContesto.template}" e questo testo:\n\n'
        '---\n'
        'model: ${LaCacheDelContesto.modello}\n'
        'config:\n'
        '  temperature: 0.9\n'
        '  topP: 0.95\n'
        '  maxOutputTokens: $tetto\n'
        '  thinkingConfig:\n'
        '    thinkingBudget: ${turno.ragionamento}\n'
        'input:\n'
        '  schema:\n'
        '    cache: string\n'
        '    richiesta: string\n'
        '---\n'
        '{{cachedContent name=cache}}\n\n'
        '{{role "user"}}\n'
        '{{richiesta}}\n');
    print('TEMPLATE: tetto $tetto, ragionamento ${turno.ragionamento}');
  });
}
