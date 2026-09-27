// ignore_for_file: avoid_print, invalid_use_of_visible_for_testing_member
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/rituals/la_lettura_delle_rune.dart';
import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/core/rituals/rune_presage.dart';
import 'package:esoteric_circle/services/ai/firebase_maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_persona.dart';
import 'package:esoteric_circle/core/maestro/misura_della_risposta.dart';
import 'package:flutter_test/flutter_test.dart';

/// **IL BANCO DELLE RUNE, ORDINE ER VOCE 01.** 27 settembre 2026.
///
/// Venti letture su dieci domande (quattro dell'allegato B, sei scritte a
/// mano su amore, lavoro, denaro, una scelta, la famiglia, un'amicizia), due
/// gettate ciascuna, con le tre gettate dell'ordine (Le tre Norne, la Croce
/// delle Cinque, il Getto sul telo); piu' quattro gettate senza domanda. Le
/// gettate sono le stesse a ogni giro: un seme fisso per lettura.
///
/// **PRIMA** e' la strada dell'app al commit 171f9e4c: l'istruzione di
/// `MaestroPersona.presagioInstruction` e la richiesta del provider, copiata
/// qui riga per riga perche' allora viveva dentro il provider, con Flash-Lite,
/// temperatura 0,9, niente schema. Accanto, la lettura di casa
/// (`RunePresagio.componiIlResponso`), che l'app mostra quando il modello
/// manca.
///
/// **DOPO** (ogni etichetta che non e' "prima") e' la strada dell'app di
/// adesso: la stessa istruzione, `LaLetturaDelleRune.richiesta`, lo schema coi
/// campi obbligatori, le guardie di `LaLetturaDelleRune.scarto` e il secondo
/// tentativo. Con `CENTO=1` si aggiunge la misura dell'ordine DF: cento
/// gettate con la stessa domanda, e quante letture sono uguali.
///
///     VERTEX_TOKEN=$(gcloud auth print-access-token) ETICHETTA=prima \
///       flutter test tool/collaudo_rune_er.dart
const _domande = [
  'Cosa devo sapere sul mio momento?',
  'In amore, dove sto andando?',
  'Nel lavoro, quale passo fare?',
  'Una scelta mi blocca: cosa la scioglie?',
  'Luca mi ha lasciato un mese fa: devo scrivergli?',
  'Il mio capo mi ha offerto un ruolo nuovo ma ho paura di non farcela: accetto?',
  'Ho speso troppo quest\'anno: come rimetto in ordine le mie spese?',
  'Resto nella mia città o provo a cambiare vita?',
  'Mia sorella e io non ci parliamo da Natale: cosa posso fare?',
  'La mia amica più cara mi sembra lontana: cosa sta succedendo tra noi?',
];

String _token = Platform.environment['VERTEX_TOKEN'] ?? '';

Future<(String?, int)> _vertex(
    String modello, String istruzione, String richiesta,
    {required double temperatura,
    required double topP,
    required int tetto,
    required int ragionamento,
    Map<String, Object>? schema}) async {
  final url =
      Uri.parse('https://europe-west1-aiplatform.googleapis.com/v1/projects/'
          'esoteric-circle/locations/europe-west1/publishers/google/models/'
          '$modello:generateContent');
  final corpo = jsonEncode({
    'systemInstruction': {
      'parts': [
        {'text': istruzione}
      ]
    },
    'contents': [
      {
        'role': 'user',
        'parts': [
          {'text': richiesta}
        ]
      }
    ],
    'generationConfig': {
      'temperature': temperatura,
      'topP': topP,
      'maxOutputTokens': tetto,
      'responseMimeType': 'application/json',
      if (schema != null) 'responseSchema': schema,
      'thinkingConfig': {'thinkingBudget': ragionamento},
    },
  });
  for (var tentativo = 0; tentativo < 4; tentativo++) {
    final client = HttpClient();
    final cronometro = Stopwatch()..start();
    try {
      final req = await client.postUrl(url);
      req.headers.set('Authorization', 'Bearer $_token');
      req.headers.contentType = ContentType.json;
      req.write(corpo);
      final res = await req.close();
      final t = await res.transform(utf8.decoder).join();
      if (res.statusCode == 401) {
        final r = await Process.run('gcloud', ['auth', 'print-access-token'],
            runInShell: true);
        _token = (r.stdout as String).trim();
        continue;
      }
      if (res.statusCode == 429 || res.statusCode >= 500) {
        await Future<void>.delayed(Duration(seconds: 4 * (tentativo + 1)));
        continue;
      }
      if (res.statusCode != 200) {
        throw HttpException('Vertex ${res.statusCode}: $t');
      }
      final j = jsonDecode(t) as Map<String, dynamic>;
      final testo =
          ((j['candidates'] as List).first['content']['parts'] as List)
              .map((p) => (p as Map)['text'] ?? '')
              .join();
      return (testo as String?, cronometro.elapsedMilliseconds);
    } finally {
      client.close();
    }
  }
  throw const HttpException('Vertex non risponde');
}

/// La richiesta del provider al commit 171f9e4c, riga per riga.
String _richiestaDiPrima(EsitoGettata esito, String d) {
  final pietre = [
    for (final r in esito.rune)
      '- ${r.rune.name}, ${r.inOmbra ? 'in merkstave' : 'diritta'}, '
          'per ${r.posizione.glossa}: ${r.rune.meaning}',
  ].join('\n');
  final richiesta = StringBuffer()
    ..writeln('Gettata: ${esito.gettata.nome}.')
    ..writeln('Pietre uscite:')
    ..writeln(pietre);
  if (d.isEmpty) {
    richiesta.writeln('La persona non ha scelto nessuna domanda.');
  } else {
    richiesta.writeln('Domanda posta dalla persona: «$d».');
  }
  return richiesta.toString();
}

/// I casi: domanda, gettata, seme.
List<(String, GettataRune, int)> _casi() {
  final tre = [
    gettate.firstWhere((g) => g.id == 'norne'),
    gettate.firstWhere((g) => g.id == 'croce'),
    gettate.firstWhere((g) => g.id == 'telo'),
  ];
  final casi = <(String, GettataRune, int)>[];
  for (var i = 0; i < _domande.length; i++) {
    casi
      ..add((_domande[i], tre[i % 3], 1000 + 2 * i))
      ..add((_domande[i], tre[(i + 1) % 3], 1001 + 2 * i));
  }
  for (var i = 0; i < 4; i++) {
    casi.add(('', tre[i % 3], 2000 + i));
  }
  return casi;
}

String _pietre(EsitoGettata e) => [
      for (final r in e.rune)
        '${r.rune.name} ${r.inOmbra ? '(merkstave)' : '(diritta)'} per '
            '${r.posizione.glossa}',
    ].join('; ');

const _schema = {
  'type': 'OBJECT',
  'properties': {
    'posizione': {
      'type': 'STRING',
      'enum': LaLetturaDelleRune.posizioni,
    },
    'risposta': {'type': 'STRING'},
    'pietre': {
      'type': 'ARRAY',
      'items': {
        'type': 'OBJECT',
        'properties': {
          'lettura': {'type': 'STRING'},
          'sullaDomanda': {'type': 'STRING'},
        },
        'required': ['lettura', 'sullaDomanda'],
        'propertyOrdering': ['lettura', 'sullaDomanda'],
      }
    },
    'legame': {'type': 'STRING'},
    'cosaPuoiFare': {'type': 'STRING'},
  },
  'required': LaLetturaDelleRune.campi,
  'propertyOrdering': LaLetturaDelleRune.campi,
};

/// La lettura di adesso, come la fa il provider: due tentativi, poi nulla.
Future<(String?, String?, int)> _dopo(
    EsitoGettata esito, String domanda) async {
  const misura = MisuraDellaRisposta.letturaDellaChat;
  final istruzione = MaestroPersona.presagioInstruction(
      profile: UserProfile(courtesyForm: CourtesyForm.unknown),
      memory: MaestroMemory.empty,
      conDomanda: domanda.isNotEmpty);
  String? motivo;
  var ms = 0;
  for (var t = 0; t < 2; t++) {
    final (testo, tempo) = await _vertex(
        FirebaseMaestroAiProvider.kMaestroRuneModel,
        istruzione,
        LaLetturaDelleRune.conLaCorrezione(
            LaLetturaDelleRune.richiesta(esito, domanda), motivo),
        temperatura: LaLetturaDelleRune.temperatura,
        topP: 0.95,
        tetto: misura.tetto,
        ragionamento: misura.ragionamento,
        schema: _schema);
    ms += tempo;
    Map<dynamic, dynamic>? j;
    try {
      final d = jsonDecode(testo ?? '');
      j = d is Map ? d : null;
    } catch (_) {
      j = null;
    }
    motivo = LaLetturaDelleRune.scarto(j, esito, domanda: domanda);
    if (motivo == null) {
      return (LaLetturaDelleRune.daJson(j, esito)!.inParole, null, ms);
    }
  }
  return (null, motivo, ms);
}

void main() {
  test('il banco delle rune', () async {
    if (_token.isEmpty) {
      print('senza VERTEX_TOKEN il banco non gira');
      return;
    }
    final etichetta = Platform.environment['ETICHETTA'] ?? 'prova';
    const misura = MisuraDellaRisposta.letturaDellaChat;
    final righe = <String>[
      'ORDINE ER VOCE 01: IL BANCO DELLE RUNE, "$etichetta", ${DateTime.now()}',
      'Strada dell\'app al commit 171f9e4c: presagioInstruction, Flash-Lite, '
          'temperatura 0,9, niente schema. Accanto, la lettura di casa.',
      '',
    ];
    final tempi = <int>[];
    var n = 0;
    for (final (domanda, gettata, seme) in _casi()) {
      n++;
      final esito = RuneCast.getta(gettata, random: Random(seme));
      final istruzione = MaestroPersona.presagioInstruction(
          profile: UserProfile(courtesyForm: CourtesyForm.unknown),
          memory: MaestroMemory.empty,
          conDomanda: domanda.isNotEmpty);
      String? testo;
      String? scartata;
      int ms;
      if (etichetta == 'prima') {
        (testo, ms) = await _vertex('gemini-2.5-flash-lite', istruzione,
            _richiestaDiPrima(esito, domanda),
            temperatura: 0.9,
            topP: 0.95,
            tetto: misura.tetto,
            ragionamento: misura.ragionamento);
      } else {
        (testo, scartata, ms) = await _dopo(esito, domanda);
      }
      tempi.add(ms);
      final casa =
          RunePresagio.componiIlResponso(esito, domanda: domanda).inParole;
      righe
        ..add('[$n] ${gettata.nome}, seme $seme. DOMANDA: '
            '${domanda.isEmpty ? '(nessuna)' : domanda}')
        ..add('    PIETRE: ${_pietre(esito)}')
        ..add(
            '    MODELLO ($ms ms): ${testo?.replaceAll('\n', ' ¶ ') ?? 'SCARTATA DUE VOLTE: $scartata'}')
        ..add('    DI CASA: ${casa.replaceAll('\n', ' ')}')
        ..add('');
      print('[$n] ${gettata.id} ${domanda.isEmpty ? '-' : domanda} $ms ms');
    }
    tempi.sort();
    righe.add('Tempo della chiamata, mediana ${tempi[tempi.length ~/ 2]} ms.');
    if (Platform.environment['CENTO'] == '1' && etichetta != 'prima') {
      // **LA MISURA DELL'ORDINE DF**: cento gettate con la stessa domanda.
      final norne = gettate.firstWhere((g) => g.id == 'norne');
      final viste = <String>{};
      var uguali = 0, cadute = 0;
      final perche = <String, int>{};
      for (var k = 0; k < 100; k++) {
        final e = RuneCast.getta(norne, random: Random(5000 + k));
        final (t, m, _) = await _dopo(e, _domande[1]);
        if (t == null) {
          cadute++;
          perche[m ?? '?'] = (perche[m ?? '?'] ?? 0) + 1;
          continue;
        }
        if (!viste.add(t)) uguali++;
      }
      righe
          .add('Cento gettate delle tre Norne con la domanda "${_domande[1]}": '
              'letture uguali $uguali, cadute sul ripiego $cadute $perche.');
      print('CENTO: uguali $uguali, cadute $cadute');
    }
    Directory('docs/collaudo/ER/rune').createSync(recursive: true);
    File('docs/collaudo/ER/rune/$etichetta.txt')
        .writeAsStringSync('${righe.join('\n')}\n');
  }, timeout: const Timeout(Duration(minutes: 30)));
}
