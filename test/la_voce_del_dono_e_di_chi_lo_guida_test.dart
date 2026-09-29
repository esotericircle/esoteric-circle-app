// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/rituals/daily_elements.dart';
import 'package:esoteric_circle/core/sensi/voce_del_responso.dart';
import 'package:flutter_test/flutter_test.dart';

/// **LA VOCE DEL DONO E' DI CHI LO GUIDA. Ordine ES voce 18, 29 settembre
/// 2026.**
///
/// Il fondatore sul Sigillo del Sogno: "trasparenza, coerenza, verità e
/// funzionalità". Dall'ordine DT voce 15 l'Arcano dell'Alba e il Sigillo del
/// Sogno li guida Medora, e al compimento suonavano la palette di Aura e
/// quella di Caligo: il rito diceva un Maestro e il suono un altro. Qui si
/// pretende che ogni Dono con un responso sonoro parli con la voce del
/// Maestro che lo guida.
void main() {
  test('ogni Dono col suo responso parla con la voce del Maestro che lo guida',
      () {
    // Il gesto del corpus di ogni Dono che ha una voce.
    const gestoDelDono = {
      DailyElement.dawn: 'alba',
      DailyElement.night: 'sogno',
    };
    final diversi = <String>[];
    for (final e in gestoDelDono.entries) {
      final guida = e.key.guide;
      final voce = VoceDelResponso.deiResponsi[e.value];
      expect(voce, isNotNull, reason: '${e.value} non ha una voce');
      if (guida != null && voce != guida) {
        diversi.add('${e.key.title}: guida ${guida.name}, voce ${voce!.name}');
      }
    }
    print('ORDINE ES VOCE 18: Doni che suonano con la voce di un altro '
        'Maestro ${diversi.length} su ${gestoDelDono.length}');
    expect(diversi, isEmpty, reason: diversi.join('\n'));
  });
}
