// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/services/ai/firebase_maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/la_richiesta_del_turno.dart';
import 'package:flutter_test/flutter_test.dart';

import 'il_banco_del_costo_comune.dart';

/// **LA CACHE A DIECI MINUTI.** Ordine EX voce 05.
///
/// Quanta parte dell'ingresso di una domanda Vertex prende dalla cache
/// implicita quando le domande arrivano da persone DIVERSE a dieci minuti
/// l'una dall'altra, come succede con pochi utenti. Il provider vero della
/// chat (`FirebaseMaestroAiProvider.reply`), Medora, due persone che si
/// alternano (nomi, nascite, memorie e domande diverse); una domanda ogni
/// [PAUSA] minuti per [VOLTE] volte. Per confronto, alla fine, due domande
/// di fila a pochi secondi.
///
///     GIRO=prima VOLTE=6 PAUSA=10 flutter test -r expanded tool/la_cache_a_dieci_minuti.dart
///
/// Scrive `docs/collaudo/EX/cache/<GIRO>.jsonl`.

class _Persona {
  const _Persona(this.nome, this.natale, this.memoria, this.domande);
  final String nome;
  final NatalContext natale;
  final MaestroMemory memoria;
  final List<String> domande;
}

const _persone = [
  _Persona(
    'Sofia',
    NatalContext(
        sunSign: 'Cancro',
        moonSign: 'Bilancia',
        ascendant: 'Scorpione',
        lifeNumber: 7,
        lifeNumberTitle: 'il Cercatore'),
    MaestroMemory(
      sessionSummary: 'Abbiamo parlato del trasferimento a Berlino e di '
          'Marco.',
      facts: [
        'lavora in banca da otto anni',
        'ha un cane che si chiama Ombra',
        'ha litigato con la sorella a Natale',
      ],
    ),
    [
      'Il mio capo mi ha offerto un ruolo nuovo. Accetto?',
      'Come faccio pace con mia sorella?',
      'Devo dire a Marco che mi piace?',
    ],
  ),
  _Persona(
    'Luca',
    NatalContext(
        sunSign: 'Leone',
        moonSign: 'Pesci',
        ascendant: 'Vergine',
        lifeNumber: 3,
        lifeNumberTitle: 'il Creativo'),
    MaestroMemory(
      sessionSummary: 'Abbiamo parlato della sua band e dei soldi che non '
          'bastano.',
      facts: [
        'suona la chitarra in una band',
        'vive a Bologna',
        'ha paura di cambiare lavoro',
      ],
    ),
    [
      'Lascio il lavoro per la musica?',
      'Come gestisco i soldi questo mese?',
      'Il concerto di sabato andrà bene?',
    ],
  ),
];

void main() {
  setUpAll(preparaIlBanco);

  test('la cache a dieci minuti', () async {
    final giro = Platform.environment['GIRO'] ?? 'senza_nome';
    final volte = int.tryParse(Platform.environment['VOLTE'] ?? '') ?? 6;
    final pausa = int.tryParse(Platform.environment['PAUSA'] ?? '') ?? 10;
    final p = FirebaseMaestroAiProvider();
    final righe = <String>[];

    Future<void> chiedi(int i, String quando) async {
      final persona = _persone[i % 2];
      final domanda = persona.domande[(i ~/ 2) % persona.domande.length];
      final prima = registro.length;
      try {
        await LaRichiestaDelTurno(domanda: domanda).per(() => p.reply(
              maestro: Maestro.medora,
              profile: UserProfile(displayName: persona.nome),
              memory: persona.memoria,
              history: const <ChatMessage>[],
              userMessage: domanda,
              natal: persona.natale,
            ));
      } catch (e) {
        print('ERRORE $e');
      }
      final chiamate = registro.sublist(prima);
      final ingresso = chiamate.fold<int>(0, (a, c) => a + c.ingresso);
      final cache = chiamate.fold<int>(0, (a, c) => a + c.dallaCache);
      final riga = {
        'giro': giro,
        'quando': DateTime.now().toIso8601String(),
        'distanza': quando,
        'persona': persona.nome,
        'chiamate': chiamate.length,
        'ingresso': ingresso,
        'dallaCache': cache,
        'quota': ingresso == 0 ? 0 : cache / ingresso,
      };
      righe.add(jsonEncode(riga));
      print('${DateTime.now().toIso8601String().substring(11, 19)} '
          '$quando ${persona.nome}: ingresso $ingresso, dalla cache $cache '
          '(${(100 * (riga['quota'] as num)).toStringAsFixed(0)}%)');
    }

    for (var i = 0; i < volte; i++) {
      await chiedi(i, i == 0 ? 'prima domanda' : 'dopo $pausa minuti');
      if (i < volte - 1) await Future<void>.delayed(Duration(minutes: pausa));
    }
    // Il confronto: due domande di fila, a pochi secondi.
    await chiedi(volte, 'di fila');
    await chiedi(volte + 1, 'di fila');

    final f = File('docs/collaudo/EX/cache/$giro.jsonl');
    f.parent.createSync(recursive: true);
    f.writeAsStringSync('${righe.join('\n')}\n');
  }, timeout: const Timeout(Duration(minutes: 150)));
}
