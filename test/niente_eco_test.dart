import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// L'ECO NON ESISTE PIU', E NON NE RESTANO PEZZI.
///
/// **La decisione del fondatore, del 3 agosto 2026.** Non una rifinitura: la
/// funzione confondeva. In chat produceva "Ti lascio Cancro", cioe' il segno
/// zodiacale della persona offerto come dono, e due righe dorate in fondo alla
/// stessa risposta si contendevano lo stesso significato.
///
/// **Perche' questa prova esiste invece di fidarsi della rimozione.** Una
/// rimozione parziale e' peggio della funzione intera, perche' lascia resti che
/// nessuno sa piu' spiegare: un campo che nessuno riempie, una stringa che non
/// compare, un import che tiene in vita un file morto. Qui si scandisce tutto
/// il progetto, non i punti che mi ricordo di aver toccato.
///
/// **Cosa NON e' stato tolto, e perche'.** `ConfineDelGiorno` resta. Il confine
/// di mezzanotte e' nato dentro l'ordine dell'Eco, ma serve ai contatori delle
/// domande del giorno e agli approfondimenti: toglierlo farebbe tornare a
/// divergere i due confini dell'app, quello d'uso e quello rituale del
/// tramonto, ed e' un difetto gia' pagato una volta.
void main() {
  test('Nessun simbolo dell\'Eco sopravvive nel progetto', () {
    // I NOMI PROPRI DELLA FUNZIONE. Non la parola "eco", che vive dentro
    // "seconda" e "riconosce" e darebbe centinaia di falsi.
    const simboli = [
      'EcoDelMaestro',
      'ArchivioDellEco',
      'NascitaDellEco',
      'SigilloDellEco',
      'fraseDellEco',
      'ecoDellUltima',
      'onApriEco',
      'ecoCon(',
      'chat_eco',
      'core/eco/',
      'sigillo_dell_eco',
    ];

    final colpe = <String>[];
    final da = <FileSystemEntity>[
      Directory('lib'),
      Directory('test'),
      Directory('tool'),
    ];
    while (da.isNotEmpty) {
      final voce = da.removeLast();
      if (voce is Directory) {
        da.addAll(voce.listSync());
        continue;
      }
      if (voce is! File || !voce.path.endsWith('.dart')) continue;
      final percorso = voce.path.replaceAll(Platform.pathSeparator, '/');
      // Questo file NOMINA i simboli per poterli vietare: e' l'unico posto in
      // cui devono comparire.
      if (percorso.endsWith('test/niente_eco_test.dart')) continue;

      final righe = voce.readAsLinesSync();
      for (var i = 0; i < righe.length; i++) {
        for (final simbolo in simboli) {
          if (righe[i].contains(simbolo)) {
            colpe.add('$percorso riga ${i + 1}: ${righe[i].trim()}');
          }
        }
      }
    }

    expect(
      colpe,
      isEmpty,
      reason: 'l\'Eco e\' stata tolta a meta\', e cio\' che resta nessuno '
          'sapra\' piu\' spiegarlo:\n${colpe.join("\n")}',
    );
  });

  test('I file dell\'Eco non esistono piu\'', () {
    for (final morto in const [
      'lib/core/eco',
      'lib/core/eco/archivio_dell_eco.dart',
      'lib/core/eco/eco_del_maestro.dart',
      'lib/features/santuario/widgets/sigillo_dell_eco.dart',
      'test/eco_a_video_test.dart',
      'test/eco_del_maestro_test.dart',
    ]) {
      expect(File(morto).existsSync() || Directory(morto).existsSync(), isFalse,
          reason: '$morto esiste ancora');
    }
  });

  test('Il confine del giorno resta, e serve ai contatori', () {
    // NON si toglie con l'Eco, ed e' scritto qui perche' la prossima pulizia
    // non se lo porti via per associazione: il confine di mezzanotte e' nato
    // in quell'ordine ma vive per le domande del giorno.
    expect(File('lib/core/tempo/confine_del_giorno.dart').existsSync(), isTrue,
        reason: 'il confine del giorno e\' stato tolto con l\'Eco: i due '
            'confini dell\'app tornano a divergere');
    final chiCiConta =
        File('lib/core/entitlement/question_allowance.dart').readAsStringSync();
    expect(chiCiConta, contains('ConfineDelGiorno'),
        reason: 'i contatori non usano piu\' il confine unico');
  });
}
