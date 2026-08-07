import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// LE PAROLE DICONO "TIENI PREMUTO", E NESSUNA PARLA PIU' DI TRACCIARE.
///
/// Ordine 2161, voce 7. Decisione di Mauro, da non ribaltare mai piu': il
/// gesto della Runa del Tramonto e' TENERE PREMUTO sulla pietra. Il
/// tracciamento col dito che scorre non esiste e non si costruisce.
///
/// La prova RICOMPONE le stringhe come le legge la persona: unisce i
/// frammenti concatenati (adiacenti o col piu') e le righe adiacenti, e
/// guarda le due forme di virgolette. Una ricerca riga per riga non vede la
/// frase spezzata sul sorgente: e' gia' costato tre volte in questo progetto.
void main() {
  /// Le stringhe vive di un sorgente, ricomposte.
  List<String> stringheRicomposte(String sorgente) {
    final letterale = RegExp(
        "'(?:[^'\\\\\\n]|\\\\.)*'|\"(?:[^\"\\\\\\n]|\\\\.)*\"");
    final pezzi = letterale.allMatches(sorgente).toList();
    final fuori = <String>[];
    var corrente = StringBuffer();
    int? finePrecedente;
    for (final m in pezzi) {
      final testo = m.group(0)!.substring(1, m.group(0)!.length - 1);
      if (finePrecedente != null) {
        final fra = sorgente.substring(finePrecedente, m.start);
        // Adiacenza di Dart (solo spazi e a capo) oppure concatenazione col
        // piu': in tutti e due i casi la persona legge UNA frase.
        final continua = RegExp(r'^[\s+]*$').hasMatch(fra);
        if (!continua) {
          fuori.add(corrente.toString());
          corrente = StringBuffer();
        }
      }
      corrente.write(testo);
      finePrecedente = m.end;
    }
    if (corrente.isNotEmpty) fuori.add(corrente.toString());
    return fuori;
  }

  String normalizza(String s) => s
      .replaceAll(r'\n', ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .toLowerCase();

  test('nel contesto delle rune nessuna stringa viva parla di tracciare', () {
    // Lo scopo e' il Tramonto e l'Estrazione: nel Rito dell'Alba e nel
    // Sigillo il tracciare e' il gesto VOLUTO di quei riti, non un residuo.
    final inAmbito = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .where((f) {
      final p = f.path.replaceAll('\\', '/');
      return p.contains('sunset') || p.contains('caligo/rune');
    });
    final vietato =
        RegExp('tracci|segui il tratto|scorr\\w* il dito');
    final colpe = <String>[];
    for (final f in inAmbito) {
      for (final s in stringheRicomposte(f.readAsStringSync())) {
        final letta = normalizza(s);
        if (vietato.hasMatch(letta)) {
          colpe.add('${f.path}: "$letta"');
        }
      }
    }
    expect(colpe, isEmpty,
        reason: 'Queste stringhe promettono ancora il tracciamento, che '
            'Mauro ha revocato: il gesto e\' tenere premuto.\n'
            '${colpe.join('\n')}');
  });

  test('l\'invito del gesto vive in un punto solo e dice tieni premuto', () {
    final testo =
        File('lib/features/rituals/sunset_rune_screen.dart')
            .readAsStringSync();
    expect(testo.contains('Tieni premuto sulla pietra'), isTrue,
        reason: 'L\'invito dell\'incisione non dice piu\' il gesto vero.');
    var occorrenze = 0;
    for (final f in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      occorrenze +=
          'Tieni premuto sulla pietra'.allMatches(f.readAsStringSync()).length;
    }
    expect(occorrenze, 1,
        reason: 'L\'invito compare $occorrenze volte in lib: deve vivere in '
            'UN punto, mai scritto a mano in due schermate.');
  });
}
