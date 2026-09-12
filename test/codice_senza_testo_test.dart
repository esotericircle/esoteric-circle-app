import 'package:flutter_test/flutter_test.dart';

import 'codice_senza_testo.dart';

/// Le prove della porta che distingue una chiamata da una citazione.
///
/// **Queste non sono guardie**, e la differenza conta: chiamano una funzione
/// con un valore e ne guardano il risultato, quindi non possono diventare
/// verdi su un insieme vuoto. Se la funzione sparisce, non compilano.
void main() {
  test('una citazione dentro una stringa non e\' una chiamata', () {
    const sorgente = '''
void main() {
  if (testo.contains('sorgentiDiLib(')) print('ok');
}
''';
    final nudo = codiceSenzaTesto(sorgente);
    expect(nudo.contains('sorgentiDiLib('), isFalse,
        reason: 'il nome stava dentro una stringa: non e\' una chiamata');
    expect(nudo.contains('testo.contains('), isTrue,
        reason: 'il codice intorno deve restare leggibile');
  });

  test('una chiamata vera resta', () {
    const sorgente = 'final f = sorgentiDiLib();';
    expect(codiceSenzaTesto(sorgente).contains('sorgentiDiLib('), isTrue);
  });

  test('il nome dentro un commento non conta', () {
    const sorgente = '// qui si potrebbe usare sorgentiDiLib()\nvar a = 1;';
    final nudo = codiceSenzaTesto(sorgente);
    expect(nudo.contains('sorgentiDiLib'), isFalse);
    expect(nudo.contains('var a = 1;'), isTrue);
  });

  test('un commento a blocco, anche annidato, sparisce tutto', () {
    const sorgente = 'var a = 1; /* fuori /* dentro sorgentiDiLib() */ */ '
        'var b = 2;';
    final nudo = codiceSenzaTesto(sorgente);
    expect(nudo.contains('sorgentiDiLib'), isFalse);
    expect(nudo.contains('var b = 2;'), isTrue);
  });

  test('l\'apice sfuggito non chiude la stringa in anticipo', () {
    const sorgente = 'const a = '
        "'"
        'non e'
        r'\'
        "'"
        ' vero '
        'sorgentiDiLib('
        "'"
        '; var b = 3;';
    final nudo = codiceSenzaTesto(sorgente);
    expect(nudo.contains('sorgentiDiLib('), isFalse,
        reason: 'la stringa continua dopo l\'apice sfuggito: quel nome e\' '
            'ancora dentro il testo');
    expect(nudo.contains('var b = 3;'), isTrue,
        reason: 'e il codice dopo la stringa deve tornare fuori');
  });

  test('la stringa grezza finisce dove finisce, barra o non barra', () {
    const sorgente = 'final s = r' "'" r'\' "'" '; sorgentiDiLib();';
    expect(codiceSenzaTesto(sorgente).contains('sorgentiDiLib('), isTrue,
        reason: 'in una stringa grezza la barra non sfugge niente: la stringa '
            'e\' finita, e la chiamata dopo e\' una chiamata vera');
  });

  test('le triple virgolette non si confondono con le singole', () {
    const sorgente = '''
final a = """
  sorgentiDiLib()
""";
final b = 1;
''';
    final nudo = codiceSenzaTesto(sorgente);
    expect(nudo.contains('sorgentiDiLib'), isFalse);
    expect(nudo.contains('final b = 1;'), isTrue);
  });
}
