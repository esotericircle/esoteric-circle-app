// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/services/ai/firebase_maestro_ai_provider.dart';
import 'package:esoteric_circle/services/voce/l_orecchio_del_live.dart';
import 'package:flutter_test/flutter_test.dart';

/// **IL BANCO DELLA TRASCRIZIONE, ordine ES voce 22.**
///
/// La voce: *"Trascrizione sbagliata ("Ma mi ama ancora" diventa "Ma mia, ma
/// ancora"): si corregge in questo ordine. Confermi?"*, *"Confermo tutto"*.
/// Sul Realme, nel DOPO dell'ordine ET, 12 domande su 17 erano trascritte
/// parola per parola giuste. Questo banco manda le venti domande del
/// collaudo, dette da Elsa (`tool/le_domande_dette.py`), pulite e "da
/// stanza", con l'istruzione di prima e con quella di oggi
/// ([LaTrascrizione.istruzione]), allo stesso modello del telefono, due giri;
/// conta le trascrizioni uguali parola per parola e le parole sbagliate.
///
/// **Non e' nella suite**: costa chiamate vere. La prova vera resta il
/// Realme.
///
/// ```
/// flutter test tool/banco_trascrizione_es22.dart --dart-define=CARTELLA=<audio>
/// ```
const String cartella = String.fromEnvironment('CARTELLA');

/// L'istruzione di prima dell'ordine ES voce 22, copiata dal commit
/// 89b4b775: il confronto si fa sugli stessi audio.
String istruzioneDiPrima() =>
    'Trascrivi esattamente, nella lingua in cui parla, ciò che dice la '
    'persona in questa registrazione, dalla prima all\'ultima parola. '
    'Scrivi solo le sue parole, senza commenti e senza virgolette. Se non '
    'si sente nessuna parola, scrivi soltanto ${LaTrascrizione.silenzio}.\n'
    '${LaTrascrizione.sottofondo}\n'
    'La persona parla con tre Maestri di un\'app di astrologia, carte, '
    'rune e chakra: può nominarli o nominare le loro arti. Questi nomi '
    'scrivili esattamente così quando li senti, anche se somigliano a una '
    'parola comune: ${LaTrascrizione.nomiDelleArti.join(', ')}. Non '
    'aggiungerli se la persona non li dice.';

List<String> _parole(String t) => t
    .toLowerCase()
    .split(RegExp(r'[^\p{L}]+', unicode: true))
    .where((p) => p.isNotEmpty)
    .toList();

/// Le parole sbagliate, contate come distanza fra le due sequenze.
int _distanza(List<String> a, List<String> b) {
  final d = List.generate(a.length + 1, (_) => List.filled(b.length + 1, 0));
  for (var i = 0; i <= a.length; i++) {
    d[i][0] = i;
  }
  for (var j = 0; j <= b.length; j++) {
    d[0][j] = j;
  }
  for (var i = 1; i <= a.length; i++) {
    for (var j = 1; j <= b.length; j++) {
      final c = a[i - 1] == b[j - 1] ? 0 : 1;
      d[i][j] = [d[i - 1][j] + 1, d[i][j - 1] + 1, d[i - 1][j - 1] + c]
          .reduce((x, y) => x < y ? x : y);
    }
  }
  return d[a.length][b.length];
}

void main() {
  test('banco della trascrizione', () async {
    expect(cartella, isNotEmpty, reason: 'manca --dart-define=CARTELLA');
    final gettone = await _gettone();
    expect(gettone, isNotNull, reason: 'serve una sessione gcloud attiva');
    final domande = File('$cartella/domande.txt')
        .readAsLinesSync()
        .where((r) => r.trim().isNotEmpty)
        .toList();
    final istruzioni = {
      'prima': istruzioneDiPrima(),
      'oggi': LaTrascrizione.istruzione,
    };
    final righe = <String>[];
    for (final tipo in ['pulita', 'stanza']) {
      for (final e in istruzioni.entries) {
        var uguali = 0;
        var sbagliate = 0;
        var parole = 0;
        var n = 0;
        for (var giro = 1; giro <= 2; giro++) {
          for (var i = 0; i < domande.length; i++) {
            final wav = File(
                    '$cartella/${tipo}_${(i + 1).toString().padLeft(2, '0')}.wav')
                .readAsBytesSync();
            final testo = await _trascrivi(gettone!, e.value, wav);
            final attese = _parole(domande[i]);
            final lette = _parole(testo);
            final d = _distanza(attese, lette);
            n++;
            parole += attese.length;
            sbagliate += d;
            if (d == 0) uguali++;
            final riga = '$tipo ${e.key} giro $giro ${i + 1}: '
                '${d == 0 ? 'uguale' : 'SBAGLIATE $d'}  «$testo»';
            righe.add(riga);
            print(riga);
          }
        }
        final totale = 'TOTALE $tipo ${e.key}: uguali parola per parola '
            '$uguali su $n, parole sbagliate $sbagliate su $parole';
        righe.add(totale);
        print(totale);
      }
    }
    File('$cartella/esito.txt').writeAsStringSync('${righe.join('\n')}\n');
  }, timeout: const Timeout(Duration(minutes: 20)));
}

Future<String> _trascrivi(
    String gettone, String istruzione, List<int> wav) async {
  final uri = Uri.https(
    '${FirebaseMaestroAiProvider.kVertexLocation}-aiplatform.googleapis.com',
    '/v1/projects/esoteric-circle/locations/'
        '${FirebaseMaestroAiProvider.kVertexLocation}/publishers/google/models/'
        '${FirebaseMaestroAiProvider.kMaestroChatModel}:generateContent',
  );
  final corpo = jsonEncode({
    'contents': [
      {
        'role': 'user',
        'parts': [
          {'text': istruzione},
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
      return 'HTTP ${risposta.statusCode}';
    }
    final parti = (((jsonDecode(testo) as Map)['candidates'] as List).first
        as Map)['content']['parts'] as List;
    final uscita = parti.map((p) => (p as Map)['text'] ?? '').join();
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
