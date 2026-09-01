import 'dart:io';

import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/features/maestri/ask/ask_maestri_screen.dart';
import 'package:flutter_test/flutter_test.dart';

/// UNA PORTA SOLA PER IL CONFRONTO.
///
/// **I due difetti che il fondatore ha visto.** "Chiedi anche agli altri", in
/// fondo a una risposta, INCOLLAVA le risposte degli altri due dentro la chat
/// di Medora: negli screenshot la sua conversazione conteneva bolle rosse di
/// Caligo e verdi di Aura. E separatamente "Metti a confronto le 3 voci" apriva
/// la schermata dedicata. Due porte allo stesso posto, che si comportavano in
/// modo diverso.
///
/// Adesso ne resta una: "Chiedi anche agli altri" apre il Consiglio. Nella chat
/// di un Maestro parla soltanto quel Maestro, sempre, senza eccezioni.
void main() {
  test('Il Consiglio non nomina la voce, e non porta il nome di un Maestro',
      () {
    // NON "Le voci a confronto": quel nome conteneva la parola che abbiamo
    // appena tolto dai Maestri, dove "voce" e' l'audio. Qui non c'e' nessun
    // audio, ci sono tre pareri.
    expect(titoloDelConsiglio.toLowerCase(), isNot(contains('voce')));
    expect(titoloDelConsiglio.toLowerCase(), isNot(contains('voci')));
    for (final maestro in Maestro.values) {
      expect(titoloDelConsiglio, isNot(contains(maestro.displayName)),
          reason: 'il titolo porta il nome di ${maestro.displayName}, e '
              'arrivandoci dalla chat direbbe di essere tornati da lui mentre '
              'qui ci sono tutti e tre');
    }
    expect(titoloDelConsiglio, 'Il Consiglio dei Maestri');
  });

  test('Una porta sola apre il confronto', () {
    // ENUMERA: si cerca in tutto `lib` chi apre quella schermata. Non si
    // campiona, ed e' esattamente cosi' che la Sintesi era sfuggita alla prova
    // della bilancia.
    final aperture = <String>[];
    final da = <FileSystemEntity>[Directory('lib')];
    while (da.isNotEmpty) {
      final voce = da.removeLast();
      if (voce is Directory) {
        da.addAll(voce.listSync());
        continue;
      }
      if (voce is! File || !voce.path.endsWith('.dart')) continue;
      final percorso = voce.path.replaceAll(Platform.pathSeparator, '/');
      if (percorso.endsWith('ask_maestri_screen.dart')) continue;
      final righe = voce.readAsLinesSync();
      for (var i = 0; i < righe.length; i++) {
        if (righe[i].trimLeft().startsWith('//')) continue;
        if (righe[i].contains('AskMaestriScreen.')) {
          aperture.add('$percorso riga ${i + 1}: ${righe[i].trim()}');
        }
      }
    }
    expect(aperture, hasLength(1),
        reason: 'le porte verso il confronto sono ${aperture.length}, e due '
            'porte allo stesso posto si comportano in modo diverso:\n'
            '${aperture.join("\n")}');
  });

  test('Nessun punto aggiunge a una chat il turno di un altro Maestro', () {
    // Il metodo che lo faceva e' stato tolto. Questa prova esiste perche' non
    // torni: un turno di Caligo dentro la conversazione di Medora dice che a
    // parlare e' stato Medora, e non e' vero.
    final colpe = <String>[];
    final da = <FileSystemEntity>[Directory('lib')];
    while (da.isNotEmpty) {
      final voce = da.removeLast();
      if (voce is Directory) {
        da.addAll(voce.listSync());
        continue;
      }
      if (voce is! File || !voce.path.endsWith('.dart')) continue;
      final percorso = voce.path.replaceAll(Platform.pathSeparator, '/');
      final righe = voce.readAsLinesSync();
      for (var i = 0; i < righe.length; i++) {
        final riga = righe[i];
        if (riga.trimLeft().startsWith('//')) continue;
        // Generare un turno PER un Maestro diverso da quello della schermata:
        // e' il parametro che permetteva di incollare le altre voci qui.
        if (riga.contains('per: altro') || riga.contains('chiediAgliAltri()')) {
          colpe.add('$percorso riga ${i + 1}: ${riga.trim()}');
        }
      }
    }
    expect(colpe, isEmpty,
        reason: 'qui si aggiunge a una conversazione il turno di un Maestro '
            'diverso da quello della schermata:\n${colpe.join("\n")}');
  });

  test('Nel confronto non si scrive: nessun campo di domanda', () {
    final sorgente = File('lib/features/maestri/ask/ask_maestri_screen.dart')
        .readAsLinesSync()
        .where((r) => !r.trimLeft().startsWith('//'))
        .join('\n');
    for (final segno in const ['TextField', 'ask_field', 'ask_submit']) {
      expect(sorgente, isNot(contains(segno)),
          reason: 'nel confronto c\'e\' ancora $segno: un campo che sembra '
              'accettare una domanda e apre altro e\' una promessa rotta');
    }
  });
}
