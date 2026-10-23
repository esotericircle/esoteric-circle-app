// ignore_for_file: avoid_print
// **UN BANCO COL MODELLO VERO, NON UNA PROVA DEL RAMO.** Ordine FC voce
// 11.2, 5 ottobre 2026.
//
// Questi casi stavano in `test/il_banco_delle_domande_libere_test.dart` e si saltavano a ogni giro
// senza `VERTEX_TOKEN`: chiamano Gemini davvero, costano, e misurano il
// modello, non il codice del ramo. Il fondatore: *"Il cancello su GitHub
// deve eseguire tutte le prove del ramo, non una parte"*, e *"Nessuna prova
// viene cancellata, disattivata, saltata"*. Un banco che non puo' girare
// senza un token e senza spendere non e' una prova che il cancello possa
// eseguire: e' uno strumento di misura, e sta fra gli strumenti. I casi
// senza rete dello stesso file restano in `test/` e girano a ogni giro.
//
// Si lancia a mano, col token:
//
//     VERTEX_TOKEN=$(gcloud auth print-access-token) flutter test tool/banchi_col_modello/il_banco_delle_domande_libere_col_modello_test.dart
import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/core/viaggio/il_tema_della_domanda_libera.dart';
import 'package:esoteric_circle/core/viaggio/la_domanda_capita.dart';
import 'package:esoteric_circle/core/viaggio/la_domanda_del_viaggio.dart';
import 'package:esoteric_circle/core/viaggio/la_voce_del_mondo_di_sotto.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test/il_banco_delle_domande_libere_test.dart' show banco;

void main() {
  final token = Platform.environment['VERTEX_TOKEN'] ?? '';
  test('CON RETE: il classificatore vero sul banco', () async {
    HttpOverrides.global = null;
    var giuste = 0;
    var giusteTabella = 0;
    var dalModello = 0;
    final sbagliate = <String>[];
    final oggetti = <String>[];
    for (final d in banco) {
      String? grezza;
      final c = await LaDomandaCapita.capisci(d.testo,
          chiamata: (i, t) async => grezza = await _classifica(token, i, t),
          prendiUnaChiamata: () async => true,
          seGuasto: (e) => print('guasto su "${d.testo}": $e'));
      if (c.fonte == FonteDelTema.modello) dalModello++;
      if (c.tema != null && d.accettati.contains(c.tema)) {
        giuste++;
      } else {
        sbagliate.add('${d.testo} -> ${c.tema?.name ?? 'nessuno'} '
            '(${c.fonte.name}), attesi ${d.accettati.map((x) => x.name).join(' o ')}');
      }
      final t = IlTemaDellaDomandaLibera.perParole(d.testo);
      if (t != null && d.accettati.contains(t)) giusteTabella++;
      oggetti.add(
          '${d.testo} -> ${c.oggetto == null ? '(nessun oggetto, vale la categoria; il modello: ${grezza?.replaceAll(RegExp(r'\s+'), ' ')})' : 'La domanda riguardava ${c.oggetto}. / Hai portato giù la domanda ${LaVoceDelMondoDiSotto.suLOggetto(c.oggetto!)}.'}');
    }
    print('BANCO CON RETE: $giuste giuste su ${banco.length}, '
        '${(giuste * 100 / banco.length).toStringAsFixed(1)} per cento; '
        'deciso dal modello $dalModello; la tabella da sola '
        '$giusteTabella');
    for (final s in sbagliate) {
      print('  sbagliata: $s');
    }
    for (final o in oggetti) {
      print('  oggetto: $o');
    }
  },
      skip: token.isEmpty
          ? 'con rete gira solo con VERTEX_TOKEN nell\'ambiente'
          : false,
      timeout: const Timeout(Duration(minutes: 5)));
}

/// **LA CHIAMATA VERA AL CLASSIFICATORE**, per REST, con la configurazione
/// della chiamata dell'app: stesso modello, stessa regione, stesso schema.
Future<String?> _classifica(
    String token, String istruzione, String testo) async {
  const regione = LaDomandaCapita.regione;
  final url = Uri.parse('https://$regione-aiplatform.googleapis.com/v1/'
      'projects/esoteric-circle/locations/$regione/publishers/google/models/'
      '${LaDomandaCapita.modello}:generateContent');
  final corpo = {
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
      'temperature': 0,
      'maxOutputTokens': 96,
      'responseMimeType': 'application/json',
      'responseSchema': {
        'type': 'OBJECT',
        'properties': {
          'tema': {
            'type': 'STRING',
            'enum': [for (final t in TemaDellaDomanda.values) t.name],
          },
          'oggetto': {'type': 'STRING'},
        },
        // Come lo scrive `firebase_ai` da se': ogni campo e' obbligatorio.
        'required': ['tema', 'oggetto'],
      },
      'thinkingConfig': {'thinkingBudget': 0},
    },
  };
  final client = HttpClient();
  try {
    final req = await client.postUrl(url);
    req.headers.set('Authorization', 'Bearer $token');
    req.headers.contentType = ContentType.json;
    req.write(jsonEncode(corpo));
    final res = await req.close();
    final testoRisposta = await res.transform(utf8.decoder).join();
    if (res.statusCode != 200) {
      throw HttpException('Vertex ${res.statusCode}: $testoRisposta');
    }
    final j = jsonDecode(testoRisposta) as Map<String, dynamic>;
    return ((j['candidates'] as List).first['content']['parts'] as List)
        .first['text'] as String?;
  } finally {
    client.close();
  }
}
