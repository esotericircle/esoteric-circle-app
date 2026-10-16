// **UN BANCO COL MODELLO VERO, NON UNA PROVA DEL RAMO.** Ordine FV aggiunta
// voce FVA.02, 15 ottobre 2026.
//
// Il fondatore, sulla stima del rapporto FU (venti consultazioni, al
// massimo 0,005 euro): *"ok per la prova del modello a pagamento"*. E' il si'
// della regola SPESE per questa sola occasione: venti chiamate vere alla
// porta dell'Oracolo degli Angeli, dieci Brevi e dieci Lunghe, su domande
// diverse e nessuna delicata.
//
// Chiama `LaLetturaDellOracolo.leggi` vera (la stessa funzione della
// schermata), passandole una `chiamata` che parla con Vertex via REST invece
// di `firebase_ai`, cosi' il banco conta i token senza Cloud Monitoring.
//
// Si lancia a mano, col token, una volta sola per questa occasione:
//
//     VERTEX_TOKEN=$(gcloud auth print-access-token) flutter test tool/banchi_col_modello/il_banco_dell_oracolo_degli_angeli_test.dart
//
// **Non entra nel giro automatico di `i_banchi_col_modello.py`**: quel giro
// gira a ogni consegna di una build, e questa chiamata ha il si' del
// fondatore per questa sola occasione (R2, regola SPESE), non per ogni
// consegna futura.
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:esoteric_circle/core/angels/guardian_angels.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/config/la_regione_dei_dati.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/oracolo_angeli/i_ruoli_e_l_estrazione.dart';
import 'package:esoteric_circle/core/oracolo_angeli/il_corpus_dell_oracolo.g.dart';
import 'package:esoteric_circle/core/oracolo_angeli/la_lettura_dell_oracolo.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter_test/flutter_test.dart';

AngelTriad _triade(int seme) => GuardianAngels.forBirth(BirthIdentity(
        birthMoment: DateTime(1988, 3, 4 + seme % 20, 9 + seme % 12, 15),
        hasBirthTime: true)
    .toBirthDetails());

const _breve = <String>[
  'Devo accettare questo nuovo lavoro?',
  'La persona che mi piace sente lo stesso per me?',
  'È il momento giusto per trasferirmi in un\'altra città?',
  'Riuscirò a riconciliarmi con mia sorella?',
  'Devo fidarmi di questa nuova amicizia?',
  'Il mio progetto porterà i frutti che spero?',
  'Sto andando nella direzione giusta nella vita?',
  'Devo lasciare andare questa relazione?',
  'Troverò presto l\'amore?',
  'Questo cambiamento che sto vivendo mi rafforzerà?',
];

const _lunga = <String>[
  'Sto pensando di lasciare il mio lavoro per aprire un\'attività mia, cosa '
      'devo capire di questa scelta?',
  'La mia relazione con mio padre è complicata da anni, come posso '
      'affrontarla adesso?',
  'Ho paura di impegnarmi in una relazione seria, da dove viene questa '
      'paura e cosa posso fare?',
  'Sto valutando di tornare a studiare dopo tanti anni, è la strada giusta '
      'per me?',
  'Un\'amicizia importante si è allontanata, posso recuperarla o devo '
      'lasciarla andare?',
  'Sto cercando di capire se restare nella città dove vivo o tornare dalla '
      'mia famiglia, cosa mi serve vedere?',
  'Vorrei capire come affrontare un periodo di grande cambiamento sul '
      'lavoro.',
  'Sento che sto per prendere una decisione importante sulla mia casa, '
      'cosa devo considerare?',
  'Vorrei capire meglio cosa mi blocca nel realizzare i miei progetti '
      'creativi.',
  'Sto cercando chiarezza su come ricostruire la fiducia in me stessa dopo '
      'una delusione.',
];

const _forme = [
  CourtesyForm.feminine,
  CourtesyForm.masculine,
  CourtesyForm.unknown,
];

void main() {
  final token = Platform.environment['VERTEX_TOKEN'] ?? '';
  _Token.valore = token;

  test('FVA.02: venti consultazioni vere, dieci Brevi e dieci Lunghe',
      () async {
    HttpOverrides.global = null;
    final conto = _Conto();
    var i = 0;
    final righe = <String>[];
    var dalModello = 0;
    Future<void> consulta(String domanda, {required bool profonda}) async {
      final seme = i;
      final forma = _forme[i % _forme.length];
      final triade = _triade(seme);
      final carte = EstrazioneDellOracolo.estrai(triade, Random(seme));
      String? grezzo;
      Future<String?> chiamata(
          String istruzione, String richiesta, Map<String, Schema> campi) async {
        final (testo, ingresso, uscita) =
            await _vertex(istruzione, richiesta, campi);
        grezzo = testo;
        conto.ingresso += ingresso;
        conto.uscita += uscita;
        return testo;
      }

      final risposta = await LaLetturaDellOracolo.leggi(
        domanda: domanda,
        carte: carte,
        corpus: corpusDellOracolo,
        variante: seme,
        profonda: profonda,
        forma: forma,
        chiamata: chiamata,
        entro: const Duration(seconds: 30),
      );
      if (risposta.dalModello) dalModello++;
      righe.add('\n=== ${i + 1}. ${profonda ? 'LUNGA' : 'BREVE'} | '
          '${forma.name} | dal modello: ${risposta.dalModello}\n'
          'DOMANDA: $domanda\n'
          'TITOLO: ${risposta.titolo}\n'
          'RIQUADRO: ${risposta.paragrafi[1]}'
          '${risposta.approfondimento.isEmpty ? '' : '\nAPPROFONDIMENTO 1: '
              '${risposta.approfondimento[0]}\nAPPROFONDIMENTO 2: '
              '${risposta.approfondimento[1]}'}\n'
          'GREZZO: $grezzo');
      i++;
    }

    for (final d in _breve) {
      await consulta(d, profonda: false);
    }
    for (final d in _lunga) {
      await consulta(d, profonda: true);
    }

    // Gemini 2.5 Flash-Lite, prezzi letti il 15 ottobre 2026
    // (docs/ordini/RAPPORTO_ORDINE_FU.md, riga del listino Vertex): 0,10
    // dollari per milione di token in ingresso, 0,40 in uscita.
    final dollari = conto.ingresso * 0.10e-6 + conto.uscita * 0.40e-6;
    final riepilogo = '\n=== RIEPILOGO FVA.02 ===\n'
        'consultazioni ${_breve.length + _lunga.length}, dal modello '
        '$dalModello/${_breve.length + _lunga.length}\n'
        'token in ingresso ${conto.ingresso}, in uscita ${conto.uscita}\n'
        'costo totale: ${dollari.toStringAsFixed(6)} dollari';
    // ignore: avoid_print
    print([...righe, riepilogo].join('\n'));
    expect(dalModello, greaterThan(0),
        reason: 'nessuna risposta e\' arrivata dal modello: il banco misura '
            'il corpus, non il modello');
  },
      skip: token.isEmpty
          ? 'Senza VERTEX_TOKEN il banco non chiama il modello'
          : false,
      timeout: const Timeout(Duration(minutes: 15)));
}

abstract final class _Token {
  static String valore = '';

  static Future<void> rinnova() async {
    final r = await Process.run(
        'cmd', ['/c', 'gcloud', 'auth', 'print-access-token']);
    final t = '${r.stdout}'.trim();
    if (t.isNotEmpty) valore = t;
  }
}

class _Conto {
  int ingresso = 0;
  int uscita = 0;
}

/// La chiamata vera, con la stessa configurazione di
/// `LaLetturaDellOracolo._chiamataVera`: solo il trasporto e' REST invece di
/// `firebase_ai`, per leggere i token dalla risposta senza Cloud Monitoring.
Future<(String?, int, int)> _vertex(
    String istruzione, String richiesta, Map<String, Schema> campi) async {
  const regione = LaRegioneDeiDati.regione;
  final url = Uri.parse('https://$regione-aiplatform.googleapis.com/v1/'
      'projects/esoteric-circle/locations/$regione/publishers/google/models/'
      '${LaLetturaDellOracolo.modello}:generateContent');
  final schema = Schema.object(properties: campi).toJson();
  final profonda = campi.containsKey('approfondimento1');
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
          {'text': richiesta}
        ]
      }
    ],
    'generationConfig': {
      'temperature': 0.8,
      'maxOutputTokens': LaLetturaDellOracolo.tettoDeiGettoni(profonda: profonda),
      'responseMimeType': 'application/json',
      'responseSchema': {...schema, 'required': campi.keys.toList()},
      'thinkingConfig': {'thinkingBudget': 0},
    },
  };
  final client = HttpClient();
  try {
    Future<(int, String)> chiama() async {
      final req = await client.postUrl(url);
      req.headers.set('Authorization', 'Bearer ${_Token.valore}');
      req.headers.contentType = ContentType.json;
      req.write(jsonEncode(corpo));
      final res = await req.close();
      return (res.statusCode, await res.transform(utf8.decoder).join());
    }

    var (stato, testo) = await chiama();
    if (stato == 401) {
      await _Token.rinnova();
      (stato, testo) = await chiama();
    }
    if (stato != 200) throw HttpException('Vertex $stato: $testo');
    final j = jsonDecode(testo) as Map<String, dynamic>;
    final uso = (j['usageMetadata'] as Map?) ?? const {};
    final ingresso = (uso['promptTokenCount'] as int?) ?? 0;
    final uscita = (uso['candidatesTokenCount'] as int?) ?? 0;
    final risposta =
        ((j['candidates'] as List).first['content']['parts'] as List)
            .first['text'] as String?;
    return (risposta, ingresso, uscita);
  } finally {
    client.close();
  }
}
