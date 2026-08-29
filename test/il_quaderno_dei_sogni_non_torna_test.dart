import 'dart:io';

import 'package:esoteric_circle/core/identity/dimenticanza_del_telefono.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:flutter_test/flutter_test.dart';

/// IL QUADERNO DEI SOGNI NON TORNA. Ordine CB voce 01.
///
/// **Cosa il fondatore ha ordinato**, con parole sue: "elimina tutta sta roba
/// che non so cosa sia", "cancella il diario dei sogni", "non c'e' nessun
/// diario di sogni o simile". Il Rito del Sogno resta, e resta Coming soon
/// l'Interpretazione dei Sogni, che e' la cosa che serve davvero.
///
/// **Da dove era nato, che e' la ragione per cui questa guardia esiste.** Il
/// quaderno non l'ha chiesto nessuno: e' nato dall'ordine BX voce 10 per
/// svegliare tre gradini del corpus dei Traguardi che parlavano di sogni
/// ANNOTATI. Una funzione costruita per far tornare un conto interno tende a
/// ritornare per la stessa strada, e questa prova e' lo sbarramento su quella
/// strada.
///
/// **Cosa sorveglia.** Che in `lib/` non ricompaiano il quaderno, le sue
/// funzioni, il suo pulsante e i suoi due gesti; che i tre gradini restino
/// dormienti col perche' scritto; e che la cancellazione porti via lo stesso
/// la chiave rimasta sui telefoni.
void main() {
  final dentroLib = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();

  test('nessun file del quaderno esiste piu', () {
    for (final morto in const [
      'lib/core/rituals/diario_dei_sogni.dart',
      'lib/features/rituals/annota_il_sogno.dart',
    ]) {
      expect(File(morto).existsSync(), isFalse,
          reason: '$morto e tornato: il fondatore aveva ordinato di '
              'eliminarlo, non di nasconderlo');
    }
  });

  test('nessun pezzo del quaderno vive dentro lib', () {
    // Ogni voce e un pezzo che il quaderno non poteva non avere: la classe,
    // i due gesti che mandava alla regia, il pulsante del rito e la funzione
    // che apriva il foglio.
    const pezzi = <String, String>{
      'DiarioDeiSogni': 'la classe del quaderno',
      'sogno_annotato': 'il gesto del sogno annotato',
      'sogno_riletto': 'il gesto del sogno riletto',
      'dream_annota': 'il pulsante Annota il tuo sogno',
      'dream_rileggi': 'il pulsante della rilettura',
      'annotaIlSogno': 'la funzione che apriva il foglio del sogno',
      'sogni.annotati': 'la chiave dei sogni sul disco',
    };
    final trovati = <String>[];
    for (final f in dentroLib) {
      final testo = f.readAsStringSync();
      for (final pezzo in pezzi.keys) {
        if (testo.contains(pezzo)) {
          trovati.add('${pezzi[pezzo]} ($pezzo) in ${f.path}');
        }
      }
    }
    // ignore: avoid_print
    print('ORDINE CB VOCE 01: file dart in lib ${dentroLib.length}, pezzi del '
        'quaderno trovati ${trovati.length}');
    expect(trovati, isEmpty,
        reason: 'il quaderno dei sogni e rientrato in lib: $trovati');
  });

  test('i tre gradini dormono, e dicono perche', () {
    for (final id in const ['cal_17', 'cal_31', 'cal_32']) {
      final voce = Sentieri.tuttiITraguardi.firstWhere((t) => t.id == id);
      expect(voce.dormiente, isTrue,
          reason: '$id e sveglio, ma il gesto che chiede non esiste piu: '
              'nessuno potra accenderlo, e nessuno sapra perche');
      expect(voce.condizione, isA<Dormiente>(),
          reason: '$id e marcato dormiente ma porta una condizione vera');
      final perche = (voce.condizione as Dormiente).perche;
      expect(perche, contains('quaderno dei sogni'),
          reason: '$id dorme senza dire che dorme per il quaderno tolto: '
              '"$perche"');
    }
    final eos = const ['cal_17', 'cal_31', 'cal_32']
        .map((id) => Sentieri.tuttiITraguardi.firstWhere((t) => t.id == id).eos)
        .reduce((a, b) => a + b);
    // ignore: avoid_print
    print('ORDINE CB VOCE 01: i tre gradini valevano $eos Eos, che oggi '
        'nessuno raggiunge sull Albero');
    expect(eos, 80, reason: 'il conto degli Eos non raggiungibili e cambiato');
  });

  test('la chiave rimasta sui telefoni se ne va lo stesso', () {
    // **IL CODICE NON LA SCRIVE PIU, IL DISCO CE L HA ANCORA.** Chi ha una
    // build da meta agosto in poi si porta dietro `sogni.annotati`. Se il
    // prefisso uscisse dall elenco della cancellazione, quel dato resterebbe
    // sul telefono per sempre, e la cancellazione direbbe il falso.
    expect(DimenticanzaDelTelefono.prefissiDaDimenticare, contains('sogni.'),
        reason: 'la cancellazione non porta piu via i sogni annotati che '
            'stanno gia sui telefoni');
  });
}
