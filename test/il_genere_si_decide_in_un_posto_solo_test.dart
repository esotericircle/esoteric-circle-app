import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'sorgenti_di_lib.dart';

/// **IL GENERE SI DECIDE IN UN POSTO SOLO.** Ordine DL voce 01, 14 settembre
/// 2026.
///
/// **Il fatto.** Prima di quest'ordine l'app sceglieva la parola giusta per
/// una persona in cinque posti: `CourtesyForm.agree`, un secondo enum
/// `AddressForm` con `pick()` e `welcome()`, due `switch` scritti a mano
/// nell'onboarding e un terzo nel blocco di cortesia del prompt. Cinque regole
/// per la stessa cosa: prima o poi una dice un'altra cosa, ed era gia'
/// successo, perche' `AddressForm` non si salvava e ripartiva neutra.
///
/// **Cosa si conta.** Ogni punto di `lib` dove un valore di `CourtesyForm`
/// porta con se' una parola: un ramo di `switch`, un caso, una coppia
/// forma-testo. Deve essercene UNO, `LinguaItaliana.scegli`. Chi ha bisogno di
/// una parola concordata passa da `agree`, dal risolutore della marca o da
/// `LaMarcaDelGenere.scegli`, che sono la stessa decisione.
///
/// **Le eccezioni dichiarate, per nome e perche'.** Un valore della forma che
/// decide qualcosa che non e' una parola: i colori dell'anteprima del tono, e
/// il sesso della carta astrologica. Non parlano alla persona.
void main() {
  const porta = 'lib/core/chat/la_marca_del_genere.dart';

  /// File e ragione di ogni punto che nomina una forma senza decidere una
  /// parola.
  const nonDiLingua = <String, String>{
    'lib/features/onboarding/anteprima_tono.dart':
        'coloriPer: i colori delle onde, non parole',
    'lib/features/onboarding/onboarding_screen.dart':
        '_genderFor e l\'elenco delle scelte: il dato della carta '
            'astrologica e i tre valori da mostrare, le etichette vengono da '
            'vocativeLabel',
  };

  test('una parola secondo il genere si decide in un posto solo', () {
    final nomina = RegExp(r'CourtesyForm\.(masculine|feminine)\b');
    // Una forma seguita, nello stesso ramo, da un testo fra apici.
    final decideUnaParola = RegExp(
        r'''CourtesyForm\.(masculine|feminine)\b[^;{}]{0,12}(=>|:|,)\s*(return\s+)?['"]''');
    final decisioni = <String>[];
    final fuori = <String>[];
    var file = 0;
    var nominate = 0;
    for (final f in sorgentiDiLib()) {
      final percorso = f.path.replaceAll(r'\', '/');
      final testo = f.readAsStringSync();
      final quante = nomina.allMatches(testo).length;
      if (quante == 0) continue;
      file++;
      nominate += quante;
      for (final m in decideUnaParola.allMatches(testo)) {
        decisioni.add('$percorso: ${m.group(0)}');
      }
      if (percorso != porta && !nonDiLingua.containsKey(percorso)) {
        fuori.add('$percorso nomina una forma $quante volte');
      }
    }
    // La porta decide con i nomi dei campi, non con testi fra apici: la sua
    // decisione si conta a parte, ed e' una.
    final laPorta = File(porta).readAsStringSync();
    final nellaPorta =
        RegExp(r'CourtesyForm\.masculine\s*=>').allMatches(laPorta).length;
    // ignore: avoid_print
    print('ORDINE DL VOCE 01: file che nominano una forma $file, volte '
        '$nominate; decisioni di parola fuori dalla porta '
        '${decisioni.length}, nella porta $nellaPorta');
    cardinaleMinimo(file, 3,
        cosa: 'file di lib che nominano una forma di cortesia',
        perche: 'la porta, i colori dell\'anteprima e l\'onboarding la '
            'nominano di sicuro: sotto tre la prova non sta guardando');
    expect(nellaPorta, 1,
        reason: 'la porta del genere deve decidere una volta sola, in '
            'LinguaItaliana.scegli');
    expect(decisioni, isEmpty,
        reason: 'qui una forma di cortesia sceglie un testo da se\', fuori '
            'dalla porta del genere: passa da agree o da una marca. $decisioni');
    expect(fuori, isEmpty,
        reason: 'questi file nominano una forma di cortesia e non sono ne\' '
            'la porta ne\' fra le eccezioni dichiarate: $fuori');
  });

  test('AddressForm non esiste piu\', ne\' come tipo ne\' come metodo', () {
    final resti = <String>[];
    for (final f in sorgentiDiLib()) {
      // I commenti che raccontano perche' e' stato tolto restano: si guarda
      // solo il codice.
      final testo = f
          .readAsLinesSync()
          .where((r) => !r.trimLeft().startsWith('//'))
          .join('\n');
      for (final nome in const ['AddressForm', '.setForm(', '.pick(masculine']) {
        if (testo.contains(nome)) resti.add('${f.path}: $nome');
      }
    }
    expect(resti, isEmpty,
        reason: 'il secondo enum della forma e\' tornato: $resti');
  });

  test('il sesso della carta astrologica non decide come si parla', () {
    // `Gender` serve al calcolo astrologico. Chi lo usasse per scegliere
    // una parola rifarebbe una seconda porta del genere.
    final usi = <String>[];
    for (final f in sorgentiDiLib()) {
      final percorso = f.path.replaceAll(r'\', '/');
      if (percorso == 'lib/core/astro/birth_details.dart') continue;
      final testo = f.readAsStringSync();
      for (final m in RegExp(
              r'''\.gender\b|Gender\.(male|female)\b[^;]{0,20}=>\s*['"]''')
          .allMatches(testo)) {
        usi.add('$percorso: ${m.group(0)}');
      }
    }
    expect(usi, isEmpty, reason: 'il sesso astrologico decide una parola: $usi');
  });
}
