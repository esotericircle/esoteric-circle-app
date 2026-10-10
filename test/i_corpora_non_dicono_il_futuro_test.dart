// ignore_for_file: avoid_print
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **I CORPORA NON DICONO IL FUTURO A CHI LEGGE.** Ordine EV, EV Aggiunta,
/// 2 ottobre 2026.
///
/// L'Architetto ha controllato i dodici corpora dell'Oroscopo e ha riscritto
/// al presente o all'infinito ogni frase con un verbo al futuro rivolto a chi
/// legge ("vedrai", "saprai", "potrai", "avrai", "farai"): per il conto di
/// Code 54 frasi e 56 parole, per il suo 55. Il futuro della seconda persona
/// singolare finisce in "-rai"; qui si cerca ogni parola che finisce cosi'
/// in ogni riga dei dodici corpora, tranne le parole dichiarate qui sotto una
/// per una, che finiscono in "-rai" senza essere un futuro.
void main() {
  /// Le parole in "-rai" che non sono un futuro, con la ragione.
  const nonFuturi = {
    'distrai': 'presente di distrarre ("ti distrai")',
    'attrai': 'presente di attrarre',
    'estrai': 'presente o imperativo di estrarre',
    'sottrai': 'presente o imperativo di sottrarre',
    'trai': 'presente o imperativo di trarre',
    'ritrai': 'presente o imperativo di ritrarre',
    'contrai': 'presente o imperativo di contrarre',
  };

  test(
      'ORDINE EV AGGIUNTA: nessun futuro rivolto a chi legge nei dodici '
      'corpora', () {
    final corpora = [
      for (final f in Directory('docs/corpus/eu').listSync())
        if (f.path.contains('oroscopo_eu_') && f.path.endsWith('.md'))
          f as File,
    ];
    cardinaleMinimo(corpora.length, 12, cosa: 'corpora dell\'ordine EU');
    final parola = RegExp(r'(?<![a-zàèéìòù])([a-zàèéìòù]+rai)(?![a-zàèéìòù])',
        caseSensitive: false);
    var righe = 0;
    var eccezioni = 0;
    final futuri = <String>[];
    for (final f in corpora) {
      final nome = f.uri.pathSegments.last;
      final testo = f.readAsLinesSync();
      for (var i = 0; i < testo.length; i++) {
        righe++;
        for (final m in parola.allMatches(testo[i])) {
          final w = m.group(1)!.toLowerCase();
          if (nonFuturi.containsKey(w)) {
            eccezioni++;
            continue;
          }
          futuri.add('$nome riga ${i + 1}: «$w» in «${testo[i].trim()}»');
        }
      }
    }
    cardinaleMinimo(righe, 6000, cosa: 'righe dei dodici corpora');
    print('ORDINE EV AGGIUNTA: righe dei dodici corpora $righe, futuri '
        'rivolti a chi legge ${futuri.length}, parole dichiarate non futuri '
        '$eccezioni');
    expect(futuri, isEmpty,
        reason: 'verbi al futuro rivolti a chi legge nei corpora: si '
            'riportano all\'Architetto\n${futuri.take(20).join('\n')}');
  });
}
