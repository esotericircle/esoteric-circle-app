import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/corpus_neutro.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/misura_della_risposta.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/services/ai/firebase_maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_persona.dart';
import 'package:flutter_test/flutter_test.dart';

/// LA MISURA DELLE RISPOSTE INTERE: quante parole, e quante si fermano al muro.
///
/// **Non e' nella suite, ed e' voluto**, per la stessa ragione di
/// `attribuzione_cieca.dart`: costa chiamate vere a Gemini. `flutter test`
/// guarda solo `test/`, quindi da qui non parte mai da solo.
///
/// ```
/// flutter test tool/risposte_intere.dart
/// ```
///
/// **Cosa misura.** Pone le venti domande neutre di [CorpusNeutro] con le
/// istruzioni di sistema VERE dell'app e la configurazione VERA del provider,
/// tetto e ragionamento presi dalla stessa [MisuraDellaRisposta] che usa la
/// chat. Per ciascuna riporta il `finishReason` grezzo, le parole prodotte e i
/// token del ragionamento.
///
/// **La riga che conta e' una sola: quante risposte si sono fermate al muro.**
/// Deve essere ZERO. Il 2 agosto 2026, prima di questo lavoro, la stessa
/// chiamata dava `finishReason: MAX_TOKENS` con `thoughtsTokenCount: 150` su un
/// tetto di 160 e sei token di testo, cioe' quattro parole a video.
void main() {
  const progetto = 'esoteric-circle';
  const regione = 'europe-west1';
  const insieme = 5;

  test('Venti risposte vere, e nessuna tronca', () async {
    final gettone = await _gettone();
    if (gettone == null) {
      fail('Nessun gettone di accesso. Serve una sessione gcloud attiva: '
          'gcloud auth login');
    }

    final misura = MisuraDellaRisposta.primaRisposta;
    stdout.writeln('Misura chiesta: ${misura.parole} parole '
        '(${misura.inLettere}). Tetto: ${misura.tetto} token. '
        'Ragionamento: ${misura.ragionamento}.');

    Future<_Esito?> chiedi(Maestro maestro, String domanda) async {
      final uri = Uri.https(
        '$regione-aiplatform.googleapis.com',
        '/v1/projects/$progetto/locations/$regione/publishers/google/models/'
            '${FirebaseMaestroAiProvider.kMaestroChatModel}:generateContent',
      );
      final corpo = jsonEncode({
        'systemInstruction': {
          'parts': [
            {
              'text': MaestroPersona.systemInstruction(
                maestro: maestro,
                profile: UserProfile(displayName: 'Sofia'),
                memory: MaestroMemory.empty,
                natal: const NatalContext(
                  sunSign: 'Leone',
                  moonSign: 'Cancro',
                  lifeNumber: 7,
                  lifeNumberTitle: 'il Cercatore',
                ),
              )
            }
          ]
        },
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': domanda}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.9,
          'topP': 0.95,
          'maxOutputTokens': misura.tetto,
          'thinkingConfig': {'thinkingBudget': misura.ragionamento},
        },
      });
      final client = HttpClient();
      try {
        final richiesta = await client.postUrl(uri);
        richiesta.headers.set('Authorization', 'Bearer $gettone');
        richiesta.headers.set('Content-Type', 'application/json');
        richiesta.add(utf8.encode(corpo));
        final risposta = await richiesta.close();
        final grezzo = await risposta.transform(utf8.decoder).join();
        if (risposta.statusCode != 200) {
          stderr.writeln('HTTP ${risposta.statusCode}: '
              '${grezzo.substring(0, grezzo.length.clamp(0, 300))}');
          return null;
        }
        final d = jsonDecode(grezzo) as Map<String, dynamic>;
        final candidati = d['candidates'] as List?;
        if (candidati == null || candidati.isEmpty) return null;
        final c = candidati.first as Map<String, dynamic>;
        final parti =
            ((c['content'] as Map?)?['parts'] as List?) ?? const <dynamic>[];
        final testo = parti
            .map((p) => (p as Map)['text']?.toString() ?? '')
            .join()
            .trim();
        final uso = (d['usageMetadata'] as Map?) ?? const {};
        return _Esito(
          maestro: maestro,
          domanda: domanda,
          testo: testo,
          motivo: c['finishReason']?.toString() ?? 'assente',
          parole: testo.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).length,
          tokenTesto: (uso['candidatesTokenCount'] as num?)?.toInt() ?? 0,
          tokenPensiero: (uso['thoughtsTokenCount'] as num?)?.toInt() ?? 0,
        );
      } finally {
        client.close(force: true);
      }
    }

    // Le venti domande distribuite sui tre Maestri a giro, cosi' la misura non
    // vale per una voce sola: le tre hanno lessici diversi e lunghezze diverse.
    final lavori = [
      for (var i = 0; i < CorpusNeutro.domande.length; i++)
        (
          maestro: Maestro.values[i % Maestro.values.length],
          domanda: CorpusNeutro.domande[i],
        ),
    ];

    final esiti = <_Esito>[];
    for (var i = 0; i < lavori.length; i += insieme) {
      final lotto = lavori.skip(i).take(insieme).toList();
      final risultati = await Future.wait(
          lotto.map((l) => chiedi(l.maestro, l.domanda)));
      esiti.addAll(risultati.whereType<_Esito>());
      stdout.writeln('  ${esiti.length}/${lavori.length}');
    }

    expect(esiti.length, lavori.length,
        reason: 'qualche chiamata non e\' tornata: la misura sarebbe parziale');

    stdout.writeln('\n${'-' * 78}');
    for (final e in esiti) {
      stdout.writeln('${e.maestro.displayName.padRight(7)} '
          '${e.parole.toString().padLeft(3)} parole  '
          '${e.motivo.padRight(10)} '
          'testo ${e.tokenTesto.toString().padLeft(4)} tok, '
          'pensiero ${e.tokenPensiero}  '
          '«${e.domanda}»');
      stdout.writeln('        ...${e.coda}');
    }

    // UNA RISPOSTA PER INTERO, per Maestro. Le code non bastano a giudicare se
    // una risposta sta in piedi: la si legge tutta, oppure non la si e' letta.
    stdout.writeln('${'-' * 78}\nUNA RISPOSTA INTERA PER CIASCUNO:');
    for (final maestro in Maestro.values) {
      final suo = esiti.where((e) => e.maestro == maestro);
      if (suo.isEmpty) continue;
      final e = suo.first;
      stdout.writeln('\n### ${maestro.displayName}, «${e.domanda}», '
          '${e.parole} parole\n${e.testo}');
    }

    final parole = esiti.map((e) => e.parole).toList()..sort();
    final tronche = esiti.where((e) => e.motivo == 'MAX_TOKENS').toList();
    final pensanti = esiti.where((e) => e.tokenPensiero > 0).toList();

    stdout.writeln('${'-' * 78}\n'
        'PAROLE  minimo ${parole.first}  '
        'mediana ${parole[parole.length ~/ 2]}  '
        'massimo ${parole.last}   (chieste ${misura.parole})\n'
        'FERMATE AL MURO: ${tronche.length} su ${esiti.length}\n'
        'CON RAGIONAMENTO ACCESO: ${pensanti.length} su ${esiti.length}');

    expect(tronche, isEmpty,
        reason: 'una risposta fermata dal limite e\' un moncone a video');
    expect(pensanti, isEmpty,
        reason: 'il ragionamento e\' dichiarato a zero ma il modello ha '
            'pensato lo stesso: e\' cio' ' che mangiava il tetto');
  }, timeout: const Timeout(Duration(minutes: 10)));
}

class _Esito {
  _Esito({
    required this.maestro,
    required this.domanda,
    required this.testo,
    required this.motivo,
    required this.parole,
    required this.tokenTesto,
    required this.tokenPensiero,
  });

  final Maestro maestro;
  final String domanda;
  final String testo;
  final String motivo;
  final int parole;
  final int tokenTesto;
  final int tokenPensiero;

  /// Le ultime parole, che sono il punto: una risposta tronca finisce senza
  /// punteggiatura, a meta' di una parola o di un pensiero.
  String get coda =>
      testo.length <= 60 ? testo : testo.substring(testo.length - 60);
}

/// Il gettone di accesso dalla sessione gcloud gia' attiva sul PC.
Future<String?> _gettone() async {
  try {
    final esito = await Process.run(
        'gcloud', ['auth', 'print-access-token'],
        runInShell: true);
    if (esito.exitCode != 0) return null;
    final t = (esito.stdout as String).trim();
    return t.isEmpty ? null : t;
  } catch (_) {
    return null;
  }
}
