import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/core/chat/le_forme_del_genere.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/config/la_regione_dei_dati.dart';
import 'package:esoteric_circle/core/magic/il_sigillo_dal_modello.dart';
import 'package:esoteric_circle/core/magic/intention_sigil.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter_test/flutter_test.dart';

/// **LA SONDA DEL SIGILLO.** Ordine DO voci 10, 11 e 12, 15 settembre 2026.
///
/// Chiamate vere a Gemini 2.5 Flash in europe-west1, con le istruzioni, lo
/// schema e le guardie dell'app: cambia solo il trasporto, REST invece di
/// `firebase_ai`. Per ogni intenzione le tre chiamate di un sigillo completo,
/// cioe' il titolo col responso, la riformulazione e il testo del
/// compimento. Stampa ogni testo, accettato o scartato, e il costo.
///
/// **Gira solo con un token**: `VERTEX_TOKEN=$(gcloud auth
/// print-access-token) flutter test test/la_sonda_del_sigillo_test.dart`.
/// Nella suite si salta, perche' costa e dipende dalla rete.
void main() {
  final token = Platform.environment['VERTEX_TOKEN'] ?? '';
  _Token.valore = token;

  const casi = <(String, ViaMagica)>[
    ('Trovo il coraggio di dire quello che sento', ViaMagica.rossa),
    ('Voglio che Marco torni da me', ViaMagica.rossa),
    ('Apro il mio cuore a un amore che mi somiglia', ViaMagica.rossa),
    ('Voglio smettere di avere paura di parlare in pubblico', ViaMagica.rossa),
    ('Ritrovo la passione per il mio lavoro', ViaMagica.rossa),
    ('Voglio fare pace con mia sorella', ViaMagica.rossa),
    ('Desidero un figlio', ViaMagica.rossa),
    ('Voglio vincere la causa contro il mio ex socio', ViaMagica.rossa),
    ('Mi innamoro di nuovo della mia vita', ViaMagica.rossa),
    ('Voglio che mia madre guarisca', ViaMagica.rossa),
    ('Chiedo chiarezza sulla mia strada', ViaMagica.bianca),
    ('Proteggo la quiete della mia casa', ViaMagica.bianca),
    ('Voglio capire se lasciare Roma', ViaMagica.bianca),
    ('Mi libero dall\'ansia prima degli esami', ViaMagica.bianca),
    ('Metto un confine con il mio capo', ViaMagica.bianca),
    ('Dormo sereno ogni notte', ViaMagica.bianca),
    ('Ritrovo la calma dopo il lutto di mio padre', ViaMagica.bianca),
    ('Voglio guarire dalla depressione', ViaMagica.bianca),
    ('Proteggo i miei figli', ViaMagica.bianca),
    ('Smetto di rimandare le decisioni', ViaMagica.bianca),
    ('Metto radici dove sono adesso', ViaMagica.verde),
    ('Faccio crescere il mio lavoro con pazienza', ViaMagica.verde),
    ('Voglio guadagnare diecimila euro entro Natale', ViaMagica.verde),
    ('Trovo una casa con un giardino', ViaMagica.verde),
    ('Il mio orto dà frutti', ViaMagica.verde),
    ('Voglio un lavoro nuovo', ViaMagica.verde),
    ('Mi prendo cura del mio corpo', ViaMagica.verde),
    ('La mia attività cresce', ViaMagica.verde),
    ('Imparo a suonare il pianoforte', ViaMagica.verde),
    ('Ritrovo la salute', ViaMagica.verde),
  ];
  const forme = [
    CourtesyForm.feminine,
    CourtesyForm.masculine,
    CourtesyForm.unknown,
  ];

  test('Tre chiamate vere per ogni sigillo, lette tutte', () async {
    // Il binding delle prove risponde 400 a ogni richiesta HTTP: la sonda
    // parla con la rete vera, come la prova a cento discese.
    HttpOverrides.global = null;
    final conto = _Conto();
    final scartiPerMotivo = <String, int>{};
    var titoliDalModello = 0;
    var responsiDalModello = 0;
    var compimentiDalModello = 0;
    var riformulate = 0;
    final genereSbagliato = <String>[];
    for (final (i, (intenzione, via)) in casi.indexed) {
      final forma = forme[i % forme.length];
      final grezzi = <String, String>{};
      Future<String?> chiamata(
          String istruzione, String richiesta, Map<String, Schema> campi) async {
        try {
          final t = await _vertex(istruzione, richiesta, campi, conto);
          grezzi[campi.keys.join(',')] = t ?? '';
          return t;
        } catch (errore) {
          // Un errore del trasporto si stampa: una sonda che cade in silenzio
          // sulla voce di casa misurerebbe la casa e non il modello.
          // ignore: avoid_print
          print('ERRORE DELLA CHIAMATA: $errore');
          rethrow;
        }
      }

      final testi = await IlSigilloDalModello.scrivi(
          intenzione: intenzione, via: via, forma: forma, chiamata: chiamata);
      final riformulata = await IlSigilloDalModello.riformula(
          intenzione: intenzione, via: via, forma: forma, chiamata: chiamata);
      final compimento = await IlSigilloDalModello.compimento(
          intenzione: intenzione, forma: forma, chiamata: chiamata);
      if (testi.titoloDalModello) titoliDalModello++;
      if (testi.responsoDalModello) responsiDalModello++;
      if (compimento.dalModello) compimentiDalModello++;
      if (riformulata != null) riformulate++;
      for (final s in testi.scarti) {
        scartiPerMotivo['${s.pezzo} ${s.motivo.name}'] =
            (scartiPerMotivo['${s.pezzo} ${s.motivo.name}'] ?? 0) + 1;
      }
      // **IL GENERE, CONTATO SUI TESTI CHE ARRIVANO A SCHERMO.**
      for (final t in [testi.titolo, testi.responso, compimento.testo]) {
        final f = formeDelGenere(t);
        final sbagliate = f.where((x) => switch (forma) {
              CourtesyForm.feminine => !x.endsWith('a'),
              CourtesyForm.masculine => !x.endsWith('o'),
              _ => true,
            });
        if (sbagliate.isNotEmpty) {
          genereSbagliato.add('${forma.name}: "$t" $sbagliate');
        }
      }
      if (riformulata != null &&
          !IlSigilloDalModello.generePermesso(
              IlSigilloDalModello.genereDellaPrimaPersona(riformulata),
              forma)) {
        genereSbagliato.add('${forma.name} riformulata: "$riformulata"');
      }
      // ignore: avoid_print
      print('\n=== ${i + 1}. "$intenzione" | ${via.nome} | ${forma.name}\n'
          'TITOLO ${testi.titoloDalModello ? 'modello' : 'CASA'}: '
          '${testi.titolo}\n'
          'RESPONSO ${testi.responsoDalModello ? 'modello' : 'CASA'}: '
          '${testi.responso}\n'
          'RIFORMULATA: ${riformulata ?? '(nessuna) grezza: '
              '${grezzi['riformulata']}'}\n'
          'COMPIMENTO ${compimento.dalModello ? 'modello' : 'CASA'}: '
          '${compimento.testo}'
          '${compimento.dalModello ? '' : '\n   grezzo: ${grezzi['testo']}'}'
          '${testi.scarti.isEmpty ? '' : '\nSCARTI: ${testi.scarti.join(' | ')}'}');
    }
    final n = casi.length;
    // Gemini 2.5 Flash, ai prezzi dell'ordine DJ voce 03: 0,30 dollari per
    // milione di token in ingresso, 2,50 in uscita.
    final dollari = conto.ingresso * 0.30e-6 + conto.uscita * 2.50e-6;
    // ignore: avoid_print
    print('\n=== RIEPILOGO DO ===\n'
        'sigilli $n, chiamate ${conto.chiamate}, token in ingresso '
        '${conto.ingresso}, in uscita ${conto.uscita}\n'
        'costo di un sigillo completo: '
        '${(dollari / n).toStringAsFixed(5)} dollari\n'
        'titoli dal modello $titoliDalModello/$n, responsi $responsiDalModello/$n, '
        'compimenti $compimentiDalModello/$n, riformulazioni $riformulate/$n\n'
        'scarti per motivo: $scartiPerMotivo\n'
        'genere sbagliato arrivato a schermo: ${genereSbagliato.length} '
        '$genereSbagliato');
    expect(genereSbagliato, isEmpty);
  },
      skip: token.isEmpty
          ? 'Senza VERTEX_TOKEN la sonda non chiama il modello'
          : false,
      timeout: const Timeout(Duration(minutes: 20)));
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
  int chiamate = 0;
  int ingresso = 0;
  int uscita = 0;
}

/// La chiamata vera, con la configurazione di `_chiamataVera` dell'app.
Future<String?> _vertex(String istruzione, String richiesta,
    Map<String, Schema> campi, _Conto conto) async {
  const regione = LaRegioneDeiDati.regione;
  final url = Uri.parse('https://$regione-aiplatform.googleapis.com/v1/'
      'projects/esoteric-circle/locations/$regione/publishers/google/models/'
      '${IlSigilloDalModello.modello}:generateContent');
  final schema = Schema.object(properties: campi).toJson();
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
      'maxOutputTokens': 320,
      'responseMimeType': 'application/json',
      // `Schema.object` di firebase_ai scrive `required` da se'.
      'responseSchema': {...schema, 'required': campi.keys.toList()},
      'thinkingConfig': {'thinkingBudget': 0},
    },
  };
  final client = HttpClient();
  try {
    conto.chiamate++;
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
    conto.ingresso += (uso['promptTokenCount'] as int?) ?? 0;
    conto.uscita += (uso['candidatesTokenCount'] as int?) ?? 0;
    return ((j['candidates'] as List).first['content']['parts'] as List)
        .first['text'] as String?;
  } finally {
    client.close();
  }
}
