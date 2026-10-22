// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/astro/il_cielo_per_il_maestro.dart';
import 'package:esoteric_circle/core/lunario/il_motore_lunare.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **IL MAESTRO DICE LA LUNA NEL GIORNO DEL PICCO**, ordine GC aggiunta voce
/// GCA.02, 22 ottobre 2026. GB.11 ha messo la Luna piena e la Luna nuova nel
/// giorno del picco esatto (`IlMotoreLunare`) nel Calendario degli eventi,
/// nel Respiro e nella Collana; il cielo di un periodo che il Maestro legge
/// (`IlCieloPerIlMaestro.delPeriodo`) le datava ancora al primo giorno in cui
/// il nome della fase cambiava, che comincia dodici ore prima del picco.
///
/// La prova legge un anno intero di eventi e pretende che ogni Luna piena e
/// ogni Luna nuova del Maestro cada nel giorno civile del picco, e che ogni
/// picco dell'anno abbia la sua riga.
void main() {
  test(
      'in un anno ogni Luna piena e nuova del Maestro cade nel giorno del '
      'picco', () {
    final dal = DateTime(2026, 11, 1);
    final al = DateTime(2027, 10, 31);
    final eventi = (IlCieloPerIlMaestro.delPeriodo(dal, al)['eventi']! as List)
        .cast<String>();
    String giorno(DateTime t) => '${t.year.toString().padLeft(4, '0')}-'
        '${t.month.toString().padLeft(2, '0')}-'
        '${t.day.toString().padLeft(2, '0')}';
    final attesi = <String>{
      for (final t in IlMotoreLunare.lunePieneFra(
          DateTime(2026, 11, 2), DateTime(2027, 11, 1)))
        '${giorno(t)}: Luna piena',
      for (final t in IlMotoreLunare.luneNuoveFra(
          DateTime(2026, 11, 2), DateTime(2027, 11, 1)))
        '${giorno(t)}: Luna nuova',
    };
    final detti = {
      for (final e in eventi)
        if (e.contains('Luna piena') || e.contains('Luna nuova'))
          e.substring(0, e.indexOf(' in ')),
    };
    final fuori = detti.difference(attesi).toList()..sort();
    final mancanti = attesi.difference(detti).toList()..sort();
    print('GCA.02: lune del Maestro ${detti.length}, picchi dell\'anno '
        '${attesi.length}, fuori dal picco ${fuori.length}, mancanti '
        '${mancanti.length}');
    cardinaleMinimo(attesi.length, 24,
        cosa: 'lune piene e nuove in un anno',
        perche: 'dodici o tredici di ciascuna');
    expect(fuori, isEmpty,
        reason: 'il Maestro data queste lune fuori dal '
            'picco: $fuori');
    expect(mancanti, isEmpty,
        reason: 'il Maestro non dice queste lune: '
            '$mancanti');
  });
}
