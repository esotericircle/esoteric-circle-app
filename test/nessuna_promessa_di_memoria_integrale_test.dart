/// NESSUN TESTO PROMETTE MEMORIA INTEGRALE. Ordine CG voce 09.
///
/// **Il vincolo che nasce dalla scelta del fondatore.** Lui ha deciso che
/// nell'interfaccia non compare nessuna dichiarazione sulla sfocatura: "non
/// voglio nessuna dichiarazione. l'utente gia' sa che le conversazioni vengono
/// memorizzate per uso dei maestri ale anche suoi, ma non abbiamo mai detto
/// come vengono memorizzate e se vengono memorizzate parola per parola."
///
/// **Da quella scelta nasce un vincolo, e va sorvegliato**: se non si dichiara
/// che la memoria sfuma, allora nessun testo puo' promettere il contrario. Una
/// promessa di memoria integrale diventerebbe falsa il giorno della prima
/// sfocatura, cioe' quattordici giorni dopo la prima conversazione.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Le forme che promettono una memoria che non sfuma.
///
/// **Non e' un elenco di parole vietate**: "ricorda" da solo va benissimo, ed
/// e' anzi cio' che il prodotto vende. Vietato e' il ricorda ASSOLUTO, cioe'
/// quello che promette che niente si perde.
final List<RegExp> _promesse = [
  RegExp(r'ricord[ao]\s+(tutto|sempre|per\s+sempre)', caseSensitive: false),
  RegExp(r'ricord[ao].{0,30}parola\s+per\s+parola', caseSensitive: false),
  RegExp(r'non\s+dimentic[ah]\s+(mai|niente|nulla)', caseSensitive: false),
  RegExp(r'memoria\s+(integrale|completa|infinita|illimitata)',
      caseSensitive: false),
  RegExp(r'ogni\s+parola.{0,20}(conservat|salvat|ricordat)',
      caseSensitive: false),
];

/// Le stringhe che una persona legge, prese dal sorgente.
///
/// **Si guardano le STRINGHE e non i commenti**: un commento che spiega la
/// regola nominandola non e' una promessa fatta a nessuno, ed e' esattamente
/// il modo in cui una guardia diventa cieca al contrario, cioe' cade sulla
/// riga che la dichiara.
List<({String file, String testo})> _stringheMostrate() {
  final fuori = <({String file, String testo})>[];
  final virgolette = RegExp(r"'([^'\\\n]{12,200})'");
  for (final voce in Directory('lib').listSync(recursive: true)) {
    if (voce is! File || !voce.path.endsWith('.dart')) continue;
    for (final riga in voce.readAsLinesSync()) {
      final t = riga.trimLeft();
      if (t.startsWith('//') || t.startsWith('///') || t.startsWith('*')) {
        continue;
      }
      // **IL TRACCIATO NON E' UNA STRINGA MOSTRATA.** Una riga di
      // `debugPrint` la legge chi sviluppa, mai la persona: contarla vorrebbe
      // dire far cadere la guardia sulla riga che dichiara il meccanismo
      // invece che su una promessa fatta a qualcuno.
      if (t.contains('debugPrint(') ||
          t.contains('logger.') ||
          t.startsWith('print(')) {
        continue;
      }
      for (final m in virgolette.allMatches(riga)) {
        fuori.add((file: voce.path, testo: m.group(1)!));
      }
    }
  }
  return fuori;
}

void main() {
  test('CG.09: nessuna stringa dell\'app promette memoria integrale', () {
    final stringhe = _stringheMostrate();
    expect(stringhe.length, greaterThan(200),
        reason: 'il censimento ha letto ${stringhe.length} stringhe: se il '
            'numero crolla, la prova ha smesso di guardare invece di essere '
            'soddisfatta');

    final promesse = <String>[];
    for (final s in stringhe) {
      for (final forma in _promesse) {
        if (forma.hasMatch(s.testo)) {
          promesse.add('${s.file}: "${s.testo}"');
          break;
        }
      }
    }

    // ignore: avoid_print
    print('ORDINE CG VOCE 09: stringhe censite ${stringhe.length}, promesse '
        'di memoria integrale ${promesse.length}');

    expect(promesse, isEmpty,
        reason: 'questi testi promettono una memoria che non sfuma: '
            '$promesse. La voce CG.09 sfoca le conversazioni dopo quattordici '
            'giorni, quindi una promessa del genere diventerebbe falsa da '
            'sola. IL ROSSO SI DIMOSTRA scrivendone una');
  });

  test('CG.09: e nemmeno una dichiarazione della sfocatura', () {
    // **Il fondatore non la vuole**, ed e' il rovescio della stessa medaglia:
    // ne' si promette memoria integrale, ne' si spiega che la memoria sfuma.
    final dichiarazioni = <String>[];
    for (final s in _stringheMostrate()) {
      final t = s.testo.toLowerCase();
      if ((t.contains('sfoc') || t.contains('sfum')) &&
          (t.contains('memoria') || t.contains('ricord'))) {
        dichiarazioni.add('${s.file}: "${s.testo}"');
      }
    }
    expect(dichiarazioni, isEmpty,
        reason: 'questi testi spiegano alla persona che la memoria sfuma: '
            '$dichiarazioni. Parole del fondatore: "non voglio nessuna '
            'dichiarazione"');
  });
}
