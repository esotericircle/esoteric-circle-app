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

/// I tipi di audio da provare, separati da virgola: `pulita`, `stanza`, e
/// dal 30 settembre 2026 `mic`, le stesse venti domande come le ha sentite
/// il microfono del PC nella stanza durante il collaudo sul Realme (tagliate
/// dalla registrazione della sessione).
const String tipi =
    String.fromEnvironment('TIPI', defaultValue: 'pulita,stanza');

/// Il nome del file dell'esito, per non sovrascrivere quello di un altro giro.
const String esito = String.fromEnvironment('ESITO', defaultValue: 'esito');

/// Una frase da provare in coda all'istruzione di prima (`variante`), e le
/// istruzioni da far girare, separate da virgola (vuoto: tutte).
const String variante = String.fromEnvironment('VARIANTE');
const String soloQueste = String.fromEnvironment('ISTRUZIONI');
const int giri = int.fromEnvironment('GIRI', defaultValue: 2);

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

/// **L'ISTRUZIONE DELLA PRIMA STESURA DELLA ES.22**, copiata dal commit
/// 9deede23: quella di prima piu' la frase di senso compiuto con i due
/// esempi. Sul Realme, il 30 settembre 2026, ha trascritto "Vorrei sapere se
/// lui mi ama ancora" una domanda che diceva tutt'altro: l'esempio e'
/// diventato la frase.
String istruzioneDellaPrimaStesura() => '${istruzioneDiPrima()}\n'
    'Di solito la persona fa una domanda sulla sua vita: l\'amore, il '
    'lavoro, i soldi, la famiglia, la salute. Scrivi la frase che ha detto '
    'davvero, in italiano corretto: quando un suono si può leggere in due '
    'modi, scegli la lettura che fa una frase di senso compiuto (per '
    'esempio "mi ama ancora" e non "mia, ma ancora"; "troverò" e non '
    '"trovo", se la frase parla del futuro).';

/// Le parole scritte che la persona non ha detto: quelle della trascrizione
/// che nella domanda non ci sono.
int _inventate(List<String> attese, List<String> lette) {
  final resto = [...attese];
  var n = 0;
  for (final p in lette) {
    if (!resto.remove(p)) n++;
  }
  return n;
}

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
      'stesura': istruzioneDellaPrimaStesura(),
      'oggi': LaTrascrizione.istruzione,
      // Una frase da provare in coda all'istruzione di prima, senza toccare
      // il codice: serve a scegliere la stesura, non entra nei conti.
      if (variante.isNotEmpty) 'variante': '${istruzioneDiPrima()}\n$variante',
    }..removeWhere((k, _) => soloQueste.isNotEmpty && !soloQueste.contains(k));
    final righe = <String>[];
    for (final tipo in tipi.split(',')) {
      for (final e in istruzioni.entries) {
        var uguali = 0;
        var sbagliate = 0;
        var parole = 0;
        var inventate = 0;
        var conInvenzioni = 0;
        var n = 0;
        for (var giro = 1; giro <= giri; giro++) {
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
            final nuove = _inventate(attese, lette);
            inventate += nuove;
            if (nuove >= 2) conInvenzioni++;
            final riga = '$tipo ${e.key} giro $giro ${i + 1}: '
                '${d == 0 ? 'uguale' : 'SBAGLIATE $d'}'
                '${nuove == 0 ? '' : ', NON DETTE $nuove'}  «$testo»';
            righe.add(riga);
            print(riga);
          }
        }
        final totale = 'TOTALE $tipo ${e.key}: uguali parola per parola '
            '$uguali su $n, parole sbagliate $sbagliate su $parole, parole '
            'scritte e non dette $inventate, domande con almeno due parole '
            'non dette $conInvenzioni su $n';
        righe.add(totale);
        print(totale);
      }
    }
    File('$cartella/$esito.txt').writeAsStringSync('${righe.join('\n')}\n');
  }, timeout: const Timeout(Duration(minutes: 40)));

  // **LA TELEVISIONE RESTA SILENZIO.** L'istruzione nuova dice che la
  // persona fa di solito una domanda: non deve far trascrivere la
  // televisione, che l'ordine EM voce 04 ha insegnato a lasciare fuori. Sei
  // pezzi della televisione finta dell'ordine EM
  // (`tool/la_televisione_da_banco.py`), con le due istruzioni, tre giri.
  test('la televisione resta silenzio', () async {
    expect(cartella, isNotEmpty, reason: 'manca --dart-define=CARTELLA');
    final gettone = await _gettone();
    expect(gettone, isNotNull, reason: 'serve una sessione gcloud attiva');
    final pezzi = Directory(cartella)
        .listSync()
        .whereType<File>()
        .where((f) => f.uri.pathSegments.last.startsWith('tv_'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));
    expect(pezzi, isNotEmpty, reason: 'mancano i pezzi di televisione');
    final righe = <String>[];
    for (final e in {
      'prima': istruzioneDiPrima(),
      'stesura': istruzioneDellaPrimaStesura(),
      'oggi': LaTrascrizione.istruzione,
    }.entries) {
      var trascritti = 0;
      var n = 0;
      for (var giro = 1; giro <= 3; giro++) {
        for (final f in pezzi) {
          final testo =
              await _trascrivi(gettone!, e.value, f.readAsBytesSync());
          n++;
          if (testo.trim().isNotEmpty) trascritti++;
          final riga = 'televisione ${e.key} giro $giro '
              '${f.uri.pathSegments.last}: «$testo»';
          righe.add(riga);
          print(riga);
        }
      }
      final totale = 'TOTALE televisione ${e.key}: pezzi trascritti come '
          'parole della persona $trascritti su $n';
      righe.add(totale);
      print(totale);
    }
    File('$cartella/esito_televisione.txt')
        .writeAsStringSync('${righe.join('\n')}\n');
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
