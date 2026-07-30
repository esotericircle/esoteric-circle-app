import 'dart:io';

import 'package:esoteric_circle/features/maestri/aura/meditation/meditation_audio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Un motore audio solo, e l'app non e' piu' muta.
///
/// **Il fatto di partenza.** L'app era MUTA per costruzione: l'unico lettore di
/// toni generava i byte e li scartava, e nel pubspec non esisteva alcuna
/// dipendenza di riproduzione. C'era `record`, che registra soltanto. E' la voce
/// P03 del Registro, e non era rifinitura: era la fondazione che mancava.
///
/// **Perche' un motore solo.** Due motori vogliono dire due volumi, due
/// comportamenti quando l'app va in sottofondo e due modi di fermarsi. Un test
/// fallisce se ne ricompare un secondo.
void main() {
  test('Nel pubspec c\'e\' UNA sola dipendenza di riproduzione', () {
    final pubspec = File('pubspec.yaml').readAsLinesSync()
        .where((r) => !r.trimLeft().startsWith('#'))
        .join('\n');
    // Le librerie di riproduzione piu' diffuse: se ne comparissero due, il
    // progetto avrebbe due motori.
    const candidate = [
      'audioplayers:',
      'just_audio:',
      'soundpool:',
      'flutter_sound:',
      'assets_audio_player:',
      'audio_service:',
    ];
    final presenti = candidate.where(pubspec.contains).toList();
    expect(presenti.length, 1,
        reason: 'le dipendenze di riproduzione sono ${presenti.length} '
            '($presenti): un motore solo, tre consumatori');
  });

  test('Il motore audio vive in un file solo', () {
    final motori = <String>[];
    for (final f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      final righe = f.readAsLinesSync()
          .where((r) => !r.trimLeft().startsWith('//'))
          .join('\n');
      if (righe.contains('AudioPlayer(')) {
        motori.add(f.path.replaceAll('\\', '/'));
      }
    }
    expect(motori.length, 1,
        reason: 'i punti che costruiscono un lettore audio sono '
            '${motori.length} ($motori): deve essere solo il motore unico in '
            'core/sensi/motore_audio.dart');
    expect(motori.single, endsWith('core/sensi/motore_audio.dart'));
  });

  test('Il lettore reale esiste e sta dietro la stessa interfaccia', () {
    // La sostituzione promessa: la schermata non sa se dietro c'e' il silenzio
    // o il suono, perche' il confine TonePlayer non e' cambiato.
    expect(LettoreToniReale(), isA<TonePlayer>());
    expect(const SilentTonePlayer(), isA<TonePlayer>());
  });

  test('Le schermate che suonano non nascono piu\' mute', () {
    // Il difetto non era l'assenza del lettore reale: era che il DEFAULT fosse
    // quello muto. I test iniettavano il lettore e passavano, mentre chi apriva
    // la schermata dall'app non sentiva niente.
    for (final percorso in const [
      'lib/features/maestri/aura/meditation/meditation_screen.dart',
      'lib/features/rituals/dream_rite_screen.dart',
    ]) {
      final codice = File(percorso).readAsLinesSync()
          .where((r) => !r.trimLeft().startsWith('//'))
          .join('\n');
      expect(codice.contains('const SilentTonePlayer()'), isFalse,
          reason: '$percorso nasce ancora col lettore muto come default, quindi '
              'promette un suono che non esce dal telefono');
      expect(codice.contains('LettoreToniReale()'), isTrue,
          reason: '$percorso non usa il lettore reale');
    }
  });
}
