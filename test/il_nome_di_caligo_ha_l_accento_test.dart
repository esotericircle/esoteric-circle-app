// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **IL NOME DI CALÌGO HA L'ACCENTO NELLE TESTATE. Ordine ES voce 17, 30
/// settembre 2026.**
///
/// Dal rapporto dell'ordine ET, punto 6: *"Il nome di Caligo senza accento
/// nella testata del dominio e del LIVE"*; la domanda girata al fondatore:
/// *"Il nome Calìgo con l'accento nella testata e nella push lo metto in
/// ogni caso. Confermi?"*, e la risposta: *"Confermo tutto"*. La push lo
/// porta dal server (`functions/src/push.ts`). Qui si guardano le testate
/// del telefono: prendono il nome da [Maestro.nomeAVideo], e il nome che va
/// al modello resta quello di prima, perche' cambiarlo cambierebbe
/// l'impronta dell'istruzione dei tre Maestri.
void main() {
  const testate = [
    'lib/features/maestri/domain_screen.dart',
    'lib/features/maestri/live/schermata_live.dart',
    'lib/features/maestri/maestro_screen.dart',
    'lib/features/maestri/chat/maestro_chat_screen.dart',
    // La home, la scheda dell'arte, la porta del LIVE e la striscia dei Doni.
    'lib/features/santuario/santuario_screen.dart',
    'lib/features/maestri/art_intro_screen.dart',
    'lib/features/maestri/chat/widgets/la_porta_del_vivo.dart',
    'lib/features/santuario/daily_strip.dart',
  ];

  test('il nome a video ha l\'accento, quello del modello no', () {
    expect(Maestro.caligo.nomeAVideo, 'Calìgo');
    expect(Maestro.caligo.displayName, 'Caligo');
    expect(Maestro.medora.nomeAVideo, 'Medora');
    expect(Maestro.aura.nomeAVideo, 'Aura');
  });

  test('le testate prendono il nome a video, mai quello del modello', () {
    cardinaleMinimo(testate.length, 8, cosa: 'schermate con la testata');
    var usi = 0;
    final senzaAccento = <String>[];
    for (final percorso in testate) {
      final righe = File(percorso).readAsLinesSync();
      for (var i = 0; i < righe.length; i++) {
        final r = righe[i];
        if (r.trimLeft().startsWith('//')) continue;
        usi += 'maestro.nomeAVideo'.allMatches(r).length;
        if (r.contains('maestro.displayName')) {
          senzaAccento.add('$percorso riga ${i + 1}');
        }
      }
    }
    print('ORDINE ES VOCE 17: testate che prendono il nome a video $usi, '
        'righe che prendono ancora il nome senza accento '
        '${senzaAccento.length}');
    cardinaleMinimo(usi, 16, cosa: 'usi del nome a video nelle testate');
    expect(senzaAccento, isEmpty, reason: senzaAccento.join('; '));
  });
}
