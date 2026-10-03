// ignore_for_file: avoid_print, invalid_use_of_visible_for_testing_member
import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/chat/il_passo_da_non_dare.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/rituals/guide_animal_derivation.dart';
import 'package:esoteric_circle/core/viaggio/diario_dei_viaggi.dart';
import 'package:esoteric_circle/core/viaggio/il_responso_del_viaggio.dart';
import 'package:esoteric_circle/core/viaggio/la_domanda_capita.dart';
import 'package:esoteric_circle/core/viaggio/la_domanda_del_viaggio.dart';
import 'package:esoteric_circle/core/viaggio/la_scena_dal_modello.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **IL BANCO DEL VIAGGIO, ORDINE ER VOCI 02 E 15.** 27 settembre 2026.
///
/// Venti discese dopo il riconoscimento dell'animale, dieci domande due volte
/// ciascuna (fra cui quelle delle catture dell'ordine DN), e dieci discese di
/// seguito della stessa persona, una domanda al giorno. La strada e' quella
/// dell'app: `LaDomandaCapita`, `LaScenaDalModello.chiediTutto` e
/// `IlResponsoDelViaggio.componi`, col Diario vero; cambia solo il trasporto,
/// REST invece della libreria di Firebase. Il modello, la regione,
/// l'istruzione e la configurazione sono quelli dell'app.
///
///     VERTEX_TOKEN=$(gcloud auth print-access-token) ETICHETTA=prima \
///       flutter test tool/collaudo_viaggio_er.dart
///
/// Scrive `docs/collaudo/ER/viaggio/<etichetta>.txt`. Il giudizio "prende
/// posizione nella prima frase" si legge alla cieca, fuori da qui.
const _domande = [
  'Mi trasferisco a Berlino per lavoro?',
  'Lascio il lavoro in banca per aprire la mia bottega di ceramica?',
  'Il mio cane è malato, cosa devo fare?',
  'Cosa pensa di me la mia collega?',
  'Mia madre non accetta la mia compagna, cosa faccio?',
  'Mio fratello non mi parla da mesi, lo chiamo io?',
  'Accetto l\'offerta di lavoro a Milano anche se guadagno meno?',
  'Riuscirò a superare il concorso di ottobre?',
  'Come faccio a sentirmi meno sola la sera?',
  'Devo dire a Marco che mi piace?',
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

Future<(IlResponsoDelViaggio, String)> _discesa(
    DiarioDeiViaggi diario, String domandaScritta, DateTime oggi) async {
  final animale = GuideAnimalDerivation.forSign(Zodiac.cancer);
  final capita = await LaDomandaCapita.capisci(domandaScritta,
      chiamata: (i, d) => _vertex(
          LaDomandaCapita.modello,
          i,
          d,
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
      domanda: domandaScritta,
      tema: capita.tema?.inLettere,
      animale: animale,
      natale: const NatalContext(sunSign: 'Cancro'),
      memoria: diario.riassuntoPerIMaestri,
      ultimeScene: [for (final v in diario.viaggi) v.pezzi],
      oggetto: capita.oggetto,
      // Le due domande scritte da una donna ("meno sola", "Marco mi piace")
      // hanno la forma femminile, come nell'app chi le scrive l'avrebbe
      // scelta: col profilo neutro le guardie del genere scartavano le
      // risposte del modello per un difetto del banco, non dell'app.
      forma: RegExp(r'meno sola|Marco').hasMatch(domandaScritta)
          ? CourtesyForm.feminine
          : CourtesyForm.unknown,
      titoliGiaDati: LaScenaDalModello.titoliDalDiario(diario.viaggi),
      // Come la schermata dall'ordine ER voce 15: le azioni gia' date.
      azioniGiaDate: LaScenaDalModello.azioniDalDiario(diario.viaggi),
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
            // Come la chiamata dell'app dall'ordine ER voce 02.
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
    seScartata: (r) => scarti.add('${r.pezzo} ${r.motivo.name}: ${r.testo}'),
  );
  final domanda = LaDomandaDelViaggio.oppureIlMomento(domandaScritta);
  final responso = IlResponsoDelViaggio.componi(
    dalModello: scritta.pezzi,
    domanda: domanda,
    giorno: oggi,
    nitidezza: 1,
    discesa: diario.quanteDiscese,
    giaOggi: 0,
    animale: animale,
    tema: capita.tema,
    storia: diario.viaggi,
    scritti: scritta.testi,
    oggetto: capita.oggetto,
    apparizioniPrima: 5,
  );
  await diario.segna(responso.comeSiConserva(
    quando: oggi,
    domanda: domanda,
    temaDellaDomanda: capita.tema?.name ?? '',
    animaleSeguito: animale.name,
    nitidezza: 1,
  ));
  return (responso, scarti.join(' ; '));
}

bool _chiedeIlFoglio(String azione) =>
    RegExp(r'\b(foglio|fogli|foglietto|biglietto|quaderno|carta|pagina)\b',
            caseSensitive: false)
        .hasMatch(azione);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('il banco del Viaggio', () async {
    if (_token.isEmpty) {
      print('senza VERTEX_TOKEN il banco non gira');
      return;
    }
    final etichetta = Platform.environment['ETICHETTA'] ?? 'prova';
    final righe = <String>[
      'ORDINE ER VOCI 02 E 15: IL BANCO DEL VIAGGIO, "$etichetta", '
          '${DateTime.now()}',
      'Modello ${LaScenaDalModello.modello}, regione europe-west1. Discese '
          'dopo il riconoscimento dell\'animale, profilo neutro.',
      '',
      '== VENTI DISCESE: DIECI DOMANDE, DUE VOLTE CIASCUNA ==',
    ];
    var foglio = 0;
    var numero = 0;
    for (final d in _domande) {
      for (var volta = 1; volta <= 2; volta++) {
        final oggi = DateTime(2026, 9, 28 + volta, 12);
        final diario = DiarioDeiViaggi(orologio: () => oggi);
        final (r, scarti) = await _discesa(diario, d, oggi);
        numero++;
        if (_chiedeIlFoglio(r.gesto)) foglio++;
        righe
          ..add('[$numero] DOMANDA: $d')
          ..add('    TITOLO: ${r.titolo}')
          ..add('    RISPOSTA: ${r.risposta}')
          ..add('    AZIONE: ${r.gesto}')
          ..add('    FONTI: ${r.fonti}')
          ..add(scarti.isEmpty ? '    SCARTI: nessuno' : '    SCARTI: $scarti');
        print('[$numero] $d -> ${r.risposta.split('.').first}');
      }
    }
    righe
      ..add('')
      ..add('Azioni che chiedono di scrivere su un foglio (o su un biglietto, '
          'un quaderno, una carta): $foglio su 20.')
      ..add('')
      ..add('== DIECI DISCESE DI SEGUITO DELLA STESSA PERSONA ==');
    var oggi = DateTime(2026, 10, 1, 12);
    final diario = DiarioDeiViaggi(orologio: () => oggi);
    final azioni = <String>[];
    var foglioSeguito = 0;
    for (var g = 0; g < 10; g++) {
      oggi = DateTime(2026, 10, 1 + g, 12);
      final (r, scarti) = await _discesa(diario, _domande[g], oggi);
      azioni.add(r.gesto);
      if (_chiedeIlFoglio(r.gesto)) foglioSeguito++;
      righe
        ..add('[giorno ${g + 1}] DOMANDA: ${_domande[g]}')
        ..add('    RISPOSTA: ${r.risposta}')
        ..add('    AZIONE: ${r.gesto}')
        ..add('    FONTI: ${r.fonti}')
        ..add(scarti.isEmpty ? '    SCARTI: nessuno' : '    SCARTI: $scarti');
    }
    final simili = <String>[];
    for (var i = 0; i < azioni.length; i++) {
      for (var j = i + 1; j < azioni.length; j++) {
        if (IlPassoDaNonDare.simili(azioni[i], azioni[j])) {
          simili.add('giorno ${i + 1} e giorno ${j + 1}');
        }
      }
    }
    righe
      ..add('')
      ..add('Coppie di azioni uguali o simili fra le dieci discese della '
          'stessa persona (IlPassoDaNonDare.simili, la misura della voce '
          'EQ.01): ${simili.length} $simili.')
      ..add('Azioni col foglio fra le dieci: $foglioSeguito su 10.');
    // La cartella dell'ordine che il banco serve (ordine ET voce 08:
    // `CARTELLA=docs/collaudo/ET/viaggio`).
    final cartella =
        Platform.environment['CARTELLA'] ?? 'docs/collaudo/ER/viaggio';
    Directory(cartella).createSync(recursive: true);
    File('$cartella/$etichetta.txt').writeAsStringSync('${righe.join('\n')}\n');
    print('BANCO DEL VIAGGIO $etichetta: foglio $foglio su 20; simili '
        '${simili.length}; foglio nel seguito $foglioSeguito su 10');
  }, timeout: const Timeout(Duration(minutes: 30)));
}
