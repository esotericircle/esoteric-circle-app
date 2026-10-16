// ignore_for_file: avoid_print, invalid_use_of_visible_for_testing_member
import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/rituals/guide_animal_derivation.dart';
import 'package:esoteric_circle/core/viaggio/la_domanda_capita.dart';
import 'package:esoteric_circle/core/viaggio/la_domanda_del_viaggio.dart';
import 'package:esoteric_circle/core/viaggio/la_scena_dal_modello.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **LA SONDA DEL PRIMO STRATO, ORDINE EV.** 1 ottobre 2026.
///
/// Il fondatore: dopo la prima discesa con la domanda scritta e il primo
/// pezzo dell'animale grattato, "Risali" porta a "Oggi il Mondo di Sotto non
/// ha parlato". Qui la stessa strada dell'app (`LaDomandaCapita`,
/// `LaScenaDalModello.chiediTutto`) per la PRIMA discesa, strato 1, prima
/// del riconoscimento: si conta quante discese finirebbero nel silenzio
/// (nessuna risposta che regge, e almeno una scartata) e perche'.
///
///     VERTEX_TOKEN=$(gcloud auth print-access-token) \
///       flutter test tool/sonda_viaggio_primo_strato.dart
const _domande = [
  'Mi trasferisco a Berlino per lavoro?',
  'Quando mi sposerò?',
  'Devo lasciare il mio lavoro?',
  'Mio fratello non mi parla da mesi, lo chiamo io?',
  'Riuscirò a superare il concorso di ottobre?',
  'Come va la mia relazione con Laura?',
];

String _token = Platform.environment['VERTEX_TOKEN'] ?? '';

Future<String?> _vertex(
    String modello, String istruzione, String testo, Map<String, Object> schema,
    {required double temperatura, required int tetto}) async {
  final url =
      Uri.parse('https://europe-west1-aiplatform.googleapis.com/v1/projects/'
          'esoteric-circle/locations/europe-west1/publishers/google/models/'
          '$modello:generateContent');
  final proprieta = schema['properties'] as Map;
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
          {'text': testo}
        ]
      }
    ],
    'generationConfig': {
      'temperature': temperatura,
      'maxOutputTokens': tetto,
      'responseMimeType': 'application/json',
      'responseSchema': {
        ...schema,
        'required': [for (final k in proprieta.keys) '$k'],
      },
      'thinkingConfig': {'thinkingBudget': 0},
    },
  });
  for (var tentativo = 0; tentativo < 4; tentativo++) {
    final client = HttpClient();
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
      return ((j['candidates'] as List).first['content']['parts'] as List)
          .first['text'] as String?;
    } finally {
      client.close();
    }
  }
  throw const HttpException('Vertex non risponde');
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('la sonda del primo strato', () async {
    if (_token.isEmpty) {
      print('senza VERTEX_TOKEN la sonda non gira');
      return;
    }
    final volte = int.tryParse(Platform.environment['VOLTE'] ?? '') ?? 2;
    final righe = <String>[];
    var silenzi = 0;
    var discese = 0;
    for (final d in _domande) {
      for (var v = 0; v < volte; v++) {
        final animale = GuideAnimalDerivation.forSign(Zodiac.cancer);
        final capita = await LaDomandaCapita.capisci(d,
            chiamata: (i, t) => _vertex(
                LaDomandaCapita.modello,
                i,
                t,
                {
                  'type': 'OBJECT',
                  'properties': {
                    'tema': {
                      'type': 'STRING',
                      'enum': [for (final t in TemaDellaDomanda.values) t.name],
                    },
                    'oggetto': {'type': 'STRING'},
                  },
                },
                temperatura: 0,
                tetto: 96),
            prendiUnaChiamata: () async => true);
        final scarti = <String>[];
        final scritta = await LaScenaDalModello.chiediTutto(
          CioCheSiSa(
            domanda: d,
            strato: 1,
            tema: capita.tema?.inLettere,
            animale: animale,
            natale: const NatalContext(sunSign: 'Cancro'),
            memoria: '',
            ultimeScene: const [],
            oggetto: capita.oggetto,
            forma: CourtesyForm.unknown,
            titoliGiaDati: const [],
            azioniGiaDate: const [],
          ),
          chiamata: (i, r, a) => _vertex(
              LaScenaDalModello.modello,
              i,
              r,
              {
                'type': 'OBJECT',
                'properties': {
                  'luogo': {'type': 'STRING', 'enum': a.luoghi},
                  'cosa': {'type': 'STRING', 'enum': a.cose},
                  'gesto': {'type': 'STRING', 'enum': a.gesti},
                  'momento': {'type': 'STRING', 'enum': a.momenti},
                  'posizione': {
                    'type': 'STRING',
                    'enum': LaScenaDalModello.posizioni
                  },
                  'titolo': {'type': 'STRING'},
                  'risposta': {'type': 'STRING'},
                  'azione': {'type': 'STRING'},
                },
              },
              temperatura: 0.8,
              tetto: 640),
          prendiUnaChiamata: () async => true,
          seScartata: (r) =>
              scarti.add('${r.pezzo} ${r.motivo.name}: ${r.testo}'),
        );
        discese++;
        final silenzio = scritta.testi.risposta == null && scarti.isNotEmpty;
        if (silenzio) silenzi++;
        righe
          ..add('[$discese] $d ${silenzio ? 'SILENZIO' : ''}')
          ..add('    RISPOSTA: ${scritta.testi.risposta}')
          ..add('    PEZZI: ${scritta.pezzi != null}')
          ..add('    SCARTI: ${scarti.join(' ; ')}');
      }
    }
    print(righe.join('\n'));
    print('SONDA: discese $discese, silenzi $silenzi');
  }, timeout: const Timeout(Duration(minutes: 20)));
}
