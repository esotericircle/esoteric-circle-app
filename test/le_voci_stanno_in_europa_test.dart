import 'dart:io';

import 'package:esoteric_circle/core/config/la_regione_dei_dati.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'sorgenti_di_lib.dart';

/// **LE VOCI STANNO IN EUROPA.** Ordine EM voce 02, 25 settembre 2026.
///
/// La regola della regione dei dati ha un'eccezione sola, concessa dal
/// fondatore: le voci Chirp 3 HD sull'endpoint multiregionale "eu", che non
/// esce dall'Unione Europea. **Mai "global"**. La guardia dei modelli,
/// `i_modelli_stanno_nella_regione_dei_dati`, guarda i nomi dei modelli e non
/// gli indirizzi: un indirizzo della voce scritto senza regione le sarebbe
/// sfuggito. Questa guarda gli indirizzi di Text-to-Speech scritti nell'app e
/// nel server, commenti esclusi: ognuno deve stare in
/// [LaRegioneDeiDati.regione] o fra [LaRegioneDeiDati.eccezioniDellaVoce].
void main() {
  test(
      'OGNI INDIRIZZO DELLA VOCE STA NELLA REGIONE O FRA LE ECCEZIONI '
      'DICHIARATE, e nessuno e\' global', () {
    final indirizzo = RegExp(r'(?<![A-Za-z0-9.-])([a-z0-9-]*texttospeech)'
        r'\.googleapis\.com');
    final sorgenti = <File>[
      ...sorgentiDiLib(),
      ...Directory('functions/src')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.ts') && !f.path.contains('.test.')),
    ];
    final trovati = <String, Set<String>>{};
    for (final f in sorgenti) {
      for (final riga in f.readAsLinesSync()) {
        final codice = riga.trimLeft();
        if (codice.startsWith('//') || codice.startsWith('*')) continue;
        for (final m in indirizzo.allMatches(codice)) {
          trovati
              .putIfAbsent('${m.group(1)}.googleapis.com', () => {})
              .add(f.path.replaceAll(r'\', '/'));
        }
      }
    }
    // ignore: avoid_print
    print('ORDINE EM VOCE 02: indirizzi della voce ${trovati.keys.toList()}, '
        'eccezioni ${LaRegioneDeiDati.eccezioniDellaVoce.keys.toList()}');
    cardinaleMinimo(trovati.length, 1,
        cosa: 'indirizzi di Text-to-Speech nel codice',
        perche: 'Senza indirizzi nessuna voce uscirebbe dalla regione, e la '
            'prova sarebbe verde senza aver guardato niente.');
    final fuori = [
      for (final e in trovati.entries)
        if (!e.key.startsWith('${LaRegioneDeiDati.regione}-') &&
            !LaRegioneDeiDati.eccezioniDellaVoce.containsKey(e.key))
          '${e.key} in ${e.value.join(', ')}',
    ];
    expect(fuori, isEmpty,
        reason: 'questi indirizzi della voce non stanno in '
            '${LaRegioneDeiDati.regione} ne\' fra le eccezioni dichiarate: '
            '${fuori.join('; ')}');
  });

  test('L\'ECCEZIONE E\' UNA SOLA, E\' "eu", E VALE PER LE CHIRP 3 HD', () {
    expect(LaRegioneDeiDati.eccezioniDellaVoce.keys,
        ['eu-texttospeech.googleapis.com']);
    final perche =
        LaRegioneDeiDati.eccezioniDellaVoce['eu-texttospeech.googleapis.com']!;
    expect(perche, contains('Chirp 3 HD'));
    expect(perche, contains('ordine EM voce 02'));
    expect(
        LaRegioneDeiDati.eccezioniDellaVoce.keys
            .where((k) => k.startsWith('texttospeech')),
        isEmpty,
        reason: 'global non e\' un\'eccezione ammessa');
  });
}
