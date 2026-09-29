// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/astro/night_sky.dart';
import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/rituals/dream_rite_corpus.dart';
import 'package:esoteric_circle/features/maestri/chat/chat_openers.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_controller.dart';
import 'package:esoteric_circle/services/ai/registro_dei_guasti.dart';
import 'package:esoteric_circle/services/ai/voce_sorvegliata.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'la_voce_vera_di_gemini.dart';

/// **LE RISPOSTE DI MEDORA DOPO IL SIGILLO DEL SOGNO.** Ordine ES voce 18.
///
/// Il fondatore: "code deve controllare ancora tutto il funzionamento del
/// sigillo del sogno e le risposte!". Il Sigillo apre la chat con
/// `ChatOpeners.sogno(saluto)`: qui quattro notti diverse per due nascite
/// diverse, col saluto vero del corpus e il controller vero della chat, e le
/// risposte si scrivono in `docs/collaudo/ES/sigillo_risposte.md` per
/// leggerle a mano.
///
/// Uso: VERTEX_TOKEN=$(gcloud auth print-access-token) flutter test
/// tool/collaudo_sigillo_es18.dart
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => HttpOverrides.global = null);

  final notti = [
    DateTime(2026, 10, 2, 23),
    DateTime(2026, 10, 9, 22, 40),
    DateTime(2026, 10, 16, 23, 30),
    DateTime(2026, 10, 23, 22, 50),
  ];
  final nascite = [
    (
      chi: 'una donna nata il 14 marzo 1975, Pesci',
      data: DateTime(1975, 3, 14),
      forma: CourtesyForm.feminine,
      natal: NatalContext(
          sunSign: 'Pesci',
          moonSign: NightSky.moonSign(DateTime(1975, 3, 14, 12)).italianName),
    ),
    (
      chi: 'un uomo nato il 2 luglio 1990, Cancro',
      data: DateTime(1990, 7, 2),
      forma: CourtesyForm.masculine,
      natal: NatalContext(
          sunSign: 'Cancro',
          moonSign: NightSky.moonSign(DateTime(1990, 7, 2, 12)).italianName),
    ),
  ];

  test('Medora risponde al saluto della notte', () async {
    final b = StringBuffer('# Le risposte di Medora dopo il Sigillo del '
        'Sogno, ordine ES voce 18\n\n');
    for (var p = 0; p < nascite.length; p++) {
      final n = nascite[p];
      for (var i = 0; i < notti.length; i++) {
        // Due persone, quattro notti: la prima persona le notti pari, la
        // seconda le dispari, cosi' i saluti sono otto diversi.
        final notte = notti[(i + p) % notti.length];
        LaMarcaDelGenere.formaCorrente = n.forma;
        final voce = VoceVeraDiGemini();
        await voce.scaldaIlGettone();
        final c = MaestroChatController(
          maestro: Maestro.medora,
          ai: VoceSorvegliata(voce: voce, registro: RegistroDeiGuasti()),
          memory: InMemoryMaestroMemoryRepository(),
          allowance: QuestionAllowance(freeDailyLimit: 999),
          tier: () => Tier.tier1,
          natal: () => n.natal,
          attesaMinima: Duration.zero,
          // Il cielo della chat e' quello della stessa notte del saluto.
          orologio: () => notte,
        );
        await c.init();
        final saluto = DreamRiteCorpus.saluto(notte, nascita: n.data);
        final apertura = ChatOpeners.sogno(saluto);
        await c.send(apertura);
        final ultima = c.messages.last;
        final risposta = ultima.role == ChatRole.maestro ? ultima.text : '';
        b
          ..writeln('## ${n.chi}, notte del $notte')
          ..writeln()
          ..writeln('**Saluto del Sigillo:** $saluto')
          ..writeln()
          ..writeln('**Apertura della chat:** $apertura')
          ..writeln()
          ..writeln('**Medora:** $risposta')
          ..writeln(
              ultima.ripiego ? '\n(RIPIEGO: il modello non ha risposto)' : '')
          ..writeln();
        print('${n.chi}, $notte: ${risposta.length} caratteri');
      }
    }
    File('docs/collaudo/ES/sigillo_risposte.md')
        .writeAsStringSync(b.toString());
  }, timeout: const Timeout(Duration(minutes: 20)));
}
