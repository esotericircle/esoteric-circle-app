// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/rituals/la_lettura_delle_rune.dart';
import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/core/rituals/runes.dart';
import 'package:esoteric_circle/services/ai/maestro_persona.dart';
import 'package:esoteric_circle/core/maestro/misura_della_risposta.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter_test/flutter_test.dart';

/// **LA SONDA DELLO SCHEMA DELLE RUNE**, ordine ER voce 01, dal Realme alla
/// build 2285: il presagio cadeva sulla lettura di casa in un secondo e mezzo,
/// due chiamate rifiutate. Qui si costruisce la `GenerationConfig` come la
/// costruisce il provider, se ne prende il JSON che `firebase_ai` manda, e la
/// si spedisce a Vertex in europe-west1 per leggere l'errore vero.
void main() {
  test('la richiesta delle rune come la manda firebase_ai', () async {
    final token = Platform.environment['VERTEX_TOKEN'] ?? '';
    if (token.isEmpty) return;
    final config = GenerationConfig(
      temperature: LaLetturaDelleRune.temperatura,
      topP: 0.95,
      maxOutputTokens: MisuraDellaRisposta.letturaDellaChat.tetto,
      thinkingConfig: ThinkingConfig.withThinkingBudget(
          MisuraDellaRisposta.letturaDellaChat.ragionamento),
      responseMimeType: 'application/json',
      responseSchema: Schema.object(properties: {
        'posizione': Schema.enumString(enumValues: LaLetturaDelleRune.posizioni),
        'risposta': Schema.string(),
        'pietre': Schema.array(
            items: Schema.object(properties: {
          'lettura': Schema.string(),
          'sullaDomanda': Schema.string(),
        }, propertyOrdering: const ['lettura', 'sullaDomanda'])),
        'legame': Schema.string(),
        'cosaPuoiFare': Schema.string(),
      }, propertyOrdering: LaLetturaDelleRune.campi),
    );
    final cfg = config.toJson();
    print('CONFIG ${jsonEncode(cfg)}');
    final gettata = gettate.firstWhere((g) => g.id == 'norne');
    Rune runa(String n) => kElderFuthark.firstWhere((x) => x.name == n);
    // La gettata del Realme alla 2285.
    final esito = EsitoGettata(gettata: gettata, rune: [
      RunaGettata(rune: runa('Algiz'), verso: RuneVerso.dritto,
          posizione: gettata.posizioni[0]),
      RunaGettata(rune: runa('Laguz'), verso: RuneVerso.merkstave,
          posizione: gettata.posizioni[1]),
      RunaGettata(rune: runa('Raidho'), verso: RuneVerso.dritto,
          posizione: gettata.posizioni[2]),
    ]);
    final corpo = jsonEncode({
      'systemInstruction': {
        'parts': [
          {
            'text': MaestroPersona.presagioInstruction(
                profile: UserProfile(courtesyForm: CourtesyForm.unknown),
                memory: MaestroMemory.empty)
          }
        ]
      },
      'contents': [
        {
          'role': 'user',
          'parts': [
            {
              'text': LaLetturaDelleRune.richiesta(
                  esito, 'Devo accettare il nuovo lavoro a Torino?')
            }
          ]
        }
      ],
      'generationConfig': cfg,
    });
    final c = HttpClient();
    final r = await c.postUrl(Uri.parse(
        'https://europe-west1-aiplatform.googleapis.com/v1beta1/projects/'
        'esoteric-circle/locations/europe-west1/publishers/google/models/'
        'gemini-2.5-flash:generateContent'));
    r.headers.set('Authorization', 'Bearer $token');
    r.headers.contentType = ContentType.json;
    r.write(corpo);
    final risp = await r.close();
    final testo = await risp.transform(utf8.decoder).join();
    print('STATO ${risp.statusCode}');
    final j = jsonDecode(testo) as Map;
    final cand = (j['candidates'] as List).first as Map;
    print('FINE ${cand['finishReason']} USO ${jsonEncode(j['usageMetadata'])}');
    final uscita = ((cand['content'] as Map)['parts'] as List)
        .map((p) => (p as Map)['text'] ?? '')
        .join();
    print('LUNGHEZZA ${uscita.length}');
    try {
      jsonDecode(uscita);
      print('JSON INTERO');
      final jj = jsonDecode(uscita) as Map;
      print('CHIAVI ${jj.keys.toList()} PIETRE ${(jj['pietre'] as List?)?.length} '
          '${(jj['pietre'] as List?)?.map((p) => (p as Map).keys.toList()).toList()}');
      print('SCARTO ${LaLetturaDelleRune.scarto(jsonDecode(uscita) as Map, esito, domanda: 'Devo accettare il nuovo lavoro a Torino?')}');
      print('USCITA ${uscita.replaceAll(RegExp(r's+'), ' ')}');
    } catch (_) {
      print('JSON TRONCATO: ...${uscita.substring(uscita.length - 120)}');
    }
    c.close();
  }, timeout: const Timeout(Duration(minutes: 2)));
}
