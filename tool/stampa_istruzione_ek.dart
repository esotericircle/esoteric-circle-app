// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/services/ai/maestro_persona.dart';
import 'package:flutter_test/flutter_test.dart';

/// **L'ISTRUZIONE DI SISTEMA COME LA LEGGE GEMINI, ordine EK voce 02.**
/// Stampa per ogni Maestro l'istruzione che l'app compone per la prima
/// risposta e per una successiva, con la persona del collaudo EJ, in
/// `docs/collaudo/EK/risposte/istruzioni/`. Serve a trovare la riga che
/// rende Medora la meno diretta: la si legge intera, non a pezzi.
///
/// ```
/// flutter test tool/stampa_istruzione_ek.dart
/// ```
void main() {
  test('stampa le istruzioni dei tre Maestri', () {
    const natal = NatalContext(
      sunSign: 'Cancro',
      ascendant: 'Gemelli',
      lifeNumber: 3,
      lifeNumberTitle: 'il Creativo',
    );
    final cartella = Directory('docs/collaudo/EK/risposte/istruzioni');
    if (!cartella.existsSync()) cartella.createSync(recursive: true);
    for (final m in Maestro.values) {
      for (final prima in [true, false]) {
        final testo = MaestroPersona.systemInstruction(
          maestro: m,
          profile: UserProfile.empty,
          memory: MaestroMemory.empty,
          natal: natal,
          primaRisposta: prima,
          testiGiaDetti: prima ? const [] : const ['Una risposta di prima.'],
        );
        final nome = '${m.id}_${prima ? 'prima_risposta' : 'seguito'}.txt';
        File('${cartella.path}/$nome').writeAsStringSync(testo);
        print('$nome: ${testo.length} caratteri');
      }
    }
  });
}
