import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/services/ai/firebase_maestro_ai_provider.dart';
import 'package:esoteric_circle/services/voce/l_orecchio_del_live.dart';
import 'package:flutter_test/flutter_test.dart';

/// IL BANCO DELL'ORECCHIO, ordine EK voce 03.
///
/// Sul Realme, con la cura dei nomi, la trascrizione e' passata da 7 a 15
/// nomi giusti su 19, ma un pezzo di frase ancora in ascolto e' tornato
/// *"Medora Aura Calìgo"*: il modello ha scritto l'elenco dell'istruzione
/// invece di cio' che sentiva. Questo banco manda gli stessi audio, con la
/// stessa istruzione del telefono ([LaTrascrizione.istruzione]), a Flash-Lite
/// e a Flash, e conta i nomi giusti, i nomi inventati e il tempo.
///
/// **Non e' nella suite**: costa chiamate vere. Gli audio li scrive la voce
/// sintetica del portatile, puliti: la prova vera resta quella sul Realme.
///
/// ```
/// flutter test tool/banco_orecchio_ek.dart --dart-define=CARTELLA=<audio>
/// ```
const String cartella = String.fromEnvironment('CARTELLA');

/// I nomi che ogni audio contiene davvero.
const Map<String, List<String>> attesi = {
  'frase_1.wav': ['Medora', 'Torre', 'Appeso'],
  'frase_2.wav': ['Calìgo', 'Fehu', 'Thurisaz', 'Algiz'],
  'frase_3.wav': ['Aura', 'Anahata', 'Vishuddha'],
  'frase_4.wav': ['Scorpione', 'Sagittario', 'Capricorno'],
  'frase_5.wav': ['Medora', 'Papessa', 'Imperatrice'],
  'frase_6.wav': ['Calìgo', 'Eihwaz', 'Perthro'],
  'pezzo_3_inizio.wav': ['Aura'],
  'pezzo_3_meta.wav': ['Aura', 'Anahata'],
  'fruscio.wav': [],
};

void main() {
  test('banco dell\'orecchio', () async {
    expect(cartella, isNotEmpty, reason: 'manca --dart-define=CARTELLA');
    final gettone = await _gettone();
    expect(gettone, isNotNull, reason: 'serve una sessione gcloud attiva');
    final nomi = LaTrascrizione.nomiDelleArti;
    const modelli = [
      FirebaseMaestroAiProvider.kMaestroBreveModel,
      FirebaseMaestroAiProvider.kMaestroChatModel,
    ];
    for (final modello in modelli) {
      var giusti = 0;
      var possibili = 0;
      var inventati = 0;
      final tempi = <int>[];
      stdout.writeln('\n=== $modello');
      for (var giro = 1; giro <= 2; giro++) {
        for (final e in attesi.entries) {
          final wav = File('$cartella/${e.key}').readAsBytesSync();
          final orologio = Stopwatch()..start();
          final testo = await _trascrivi(gettone!, modello, wav);
          tempi.add(orologio.elapsedMilliseconds);
          final minuscolo = testo.toLowerCase();
          final trovati = [
            for (final n in e.value)
              if (minuscolo.contains(n.toLowerCase())) n
          ];
          final estranei = [
            for (final n in nomi)
              if (!e.value.contains(n) &&
                  RegExp(
                          '(^|[^\\p{L}])${RegExp.escape(n.toLowerCase())}'
                          '(\$|[^\\p{L}])',
                          unicode: true)
                      .hasMatch(minuscolo))
                n
          ];
          giusti += trovati.length;
          possibili += e.value.length;
          inventati += estranei.length;
          stdout.writeln('giro $giro ${e.key.padRight(20)} '
              '${orologio.elapsedMilliseconds.toString().padLeft(5)} ms  '
              'nomi ${trovati.length}/${e.value.length}'
              '${estranei.isEmpty ? '' : '  INVENTATI $estranei'}  «$testo»');
        }
      }
      tempi.sort();
      stdout.writeln('TOTALE $modello: nomi giusti $giusti su $possibili, '
          'nomi inventati $inventati, tempo mediano '
          '${tempi[tempi.length ~/ 2]} ms, massimo ${tempi.last} ms');
    }
  }, timeout: const Timeout(Duration(minutes: 10)));
}

Future<String> _trascrivi(String gettone, String modello, List<int> wav) async {
  final uri = Uri.https(
    '${FirebaseMaestroAiProvider.kVertexLocation}-aiplatform.googleapis.com',
    '/v1/projects/esoteric-circle/locations/'
        '${FirebaseMaestroAiProvider.kVertexLocation}/publishers/google/models/'
        '$modello:generateContent',
  );
  final corpo = jsonEncode({
    'contents': [
      {
        'role': 'user',
        'parts': [
          {'text': LaTrascrizione.istruzione},
          {
            'inlineData': {'mimeType': 'audio/wav', 'data': base64Encode(wav)}
          },
        ],
      }
    ],
    'generationConfig': {
      'temperature': 0,
      'maxOutputTokens': 600,
      'thinkingConfig': {'thinkingBudget': 0},
    },
  });
  final client = HttpClient();
  try {
    final richiesta = await client.postUrl(uri);
    richiesta.headers.set('Authorization', 'Bearer $gettone');
    richiesta.headers.set('Content-Type', 'application/json');
    richiesta.add(utf8.encode(corpo));
    final risposta = await richiesta.close();
    final testo = await risposta.transform(utf8.decoder).join();
    if (risposta.statusCode != 200) {
      return 'HTTP ${risposta.statusCode}: '
          '${testo.substring(0, testo.length.clamp(0, 200))}';
    }
    final parti = (((jsonDecode(testo) as Map)['candidates'] as List).first
        as Map)['content']['parts'] as List;
    final uscita = parti.map((p) => (p as Map)['text'] ?? '').join();
    // Come l'app: una riga sola, e il segno del silenzio diventa vuoto.
    final riga = uscita.replaceAll(RegExp(r'\s*\n+\s*'), ' ').trim();
    return riga == LaTrascrizione.silenzio ? '' : riga;
  } finally {
    client.close(force: true);
  }
}

Future<String?> _gettone() async {
  final esito = await Process.run(
    Platform.isWindows ? 'gcloud.cmd' : 'gcloud',
    ['auth', 'print-access-token'],
    runInShell: true,
  );
  if (esito.exitCode != 0) return null;
  final testo = (esito.stdout as String).trim();
  return testo.isEmpty ? null : testo;
}
