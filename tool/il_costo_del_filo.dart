// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/il_filo_del_consulto.dart';
import 'package:esoteric_circle/core/chat/la_rete_della_coerenza.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/config/la_regione_dei_dati.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/misura_della_risposta.dart';
import 'package:esoteric_circle/services/ai/firebase_maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_persona.dart';
import 'package:flutter_test/flutter_test.dart';

/// **IL COSTO DEL FILO. Ordine FE voci 19 e 20, 6 ottobre 2026.**
///
/// Dieci consulti veri a Gemini 2.5 Flash in europe-west1, con le istruzioni
/// vere dell'app: cinque temi, e per ognuno un consulto che continua con lo
/// stesso Maestro e uno che passa a un secondo Maestro. Per ogni consulto:
///
/// 1. **prima del filo**: il secondo turno con l'istruzione senza il blocco
///    del filo, com'era prima dell'ordine FE;
/// 2. **col filo, senza cache**: lo stesso turno col blocco del filo, a
///    prezzo pieno;
/// 3. **col filo e con la cache**: il turno dopo, col filo, come arriva in
///    un consulto vero, con la cache implicita di Vertex che riusa il
///    prefisso gia' visto; l'ingresso letto dalla cache costa il 10 per
///    cento (prezzo verificato nell'ordine EW, `tool/i_conti_del_costo_ew.py`).
///
/// La cache esplicita (ordine EX voce 05, `LaCacheDelContesto`) resta spenta:
/// alla lettura alla cieca sbagliava il cielo 3 volte su 10, e nessuna
/// risposta deve peggiorare.
///
/// **LA RETE DELLA COERENZA E I TRE MAESTRI.** Dal 6 ottobre 2026 (ordine
/// FE voci 10, 13 e 17) il costo "dopo" comprende la rete della coerenza,
/// che parte nei turni dove ha gia' parlato un altro Maestro: la stessa
/// funzione di `lib`, con Flash-Lite, e la correzione quando la chiede. Un
/// secondo test misura un consulto che passa per tre Maestri, per dire di
/// quanto cresce l'ingresso a ogni Maestro in piu' (voce 13: riceve la
/// scheda, non le battute).
///
/// ```
/// flutter test tool/il_costo_del_filo.dart
/// ```
void main() {
  const temi = [
    'Riceverò la promozione che aspetto al lavoro?',
    'Devo trasferirmi in un\'altra città per ricominciare?',
    'La mia relazione si è raffreddata: posso ancora salvarla?',
    'È il momento giusto per avviare il mio progetto creativo?',
    'Come faccio a fare pace con mia sorella dopo la lite?',
  ];
  // Prezzi di gemini-2.5-flash in dollari per milione di token, ordine DJ
  // voce 03; l'ingresso in cache al 10 per cento, ordine EW.
  const pIn = 0.30, pCache = 0.03, pOut = 2.50;
  // Flash-Lite, la rete: tool/i_conti_del_costo_ew.py, ordine EW.
  const pInLite = 0.10, pCacheLite = 0.01, pOutLite = 0.40;
  double costoDi(_Esito e, {bool lite = false}) => lite
      ? ((e.ingresso - e.cache) * pInLite +
              e.cache * pCacheLite +
              e.uscita * pOutLite) /
          1e6
      : ((e.ingresso - e.cache) * pIn + e.cache * pCache + e.uscita * pOut) /
          1e6;

  /// La rete come nel controllore: torna il costo della rete e della
  /// correzione, se c'e' stata, e la risposta che la persona legge.
  Future<(double, String, bool)> conLaRete(Maestro chi,
      List<ChatMessage> storia, String domanda, String risposta) async {
    var costo = 0.0;
    final correzione = await LaReteDellaCoerenza.controlla(
      chi: chi,
      storia: storia,
      domanda: domanda,
      risposta: risposta,
      chiamata: (istr, testo) async {
        final e = await _rete(istr, testo);
        costo += costoDi(e, lite: true);
        return e.testo;
      },
    );
    if (correzione == null) return (costo, risposta, false);
    final e = await _chiama(
        chi,
        const [],
        'LA DOMANDA DELLA PERSONA:\n$domanda\n\n'
            'LA TUA RISPOSTA DA CORREGGERE:\n$risposta',
        '',
        modello: FirebaseMaestroAiProvider.kMaestroBreveModel,
        istruzione: MaestroPersona.istruzioneDellaCorrezione(
            maestro: chi,
            profile: UserProfile.empty,
            correzione: correzione,
            nelLive: false));
    // La correzione della rete su Flash-Lite, come nel provider (FE.20).
    return (costo + costoDi(e, lite: true), e.testo, true);
  }

  test('il costo del filo su dieci consulti', () async {
    HttpOverrides.global = null;
    final righe = <String>[];
    final stato1 = <int>[], stato2 = <int>[], stato3 = <int>[];
    final costoPrima = <double>[], costoDopo = <double>[];
    final costoRete = <double>[];
    var correzioni = 0;
    for (final (i, tema) in temi.indexed) {
      final primo = Maestro.values[i % 3];
      for (final passa in [false, true]) {
        final secondo = passa ? Maestro.values[(i + 1) % 3] : primo;
        var ora = DateTime(2026, 10, 6, 10);
        IlFiloDelConsulto.dimentica();
        IlFiloDelConsulto.adesso = () => ora;
        // Primo turno, uguale nei tre stati.
        final r1 = await _chiama(primo, const [], tema, '');
        IlFiloDelConsulto.annota(
            maestro: primo, domanda: tema, risposta: r1.testo);
        ora = ora.add(const Duration(minutes: 2));
        final storia = passa
            ? <ChatMessage>[]
            : [
                ChatMessage(role: ChatRole.user, text: tema),
                ChatMessage(role: ChatRole.maestro, text: r1.testo),
              ];
        final d2 = passa ? tema : 'E in pratica, cosa faccio questa settimana?';
        // Stato 1: senza il filo.
        final senza = await _chiama(secondo, storia, d2, '');
        // Stato 2: col filo.
        final filo = IlFiloDelConsulto.bloccoPer(secondo, storia: storia);
        final con = await _chiama(secondo, storia, d2, filo);
        final (rete2, testo2, corretta2) =
            await conLaRete(secondo, storia, d2, con.testo);
        if (corretta2) correzioni++;
        IlFiloDelConsulto.annota(
            maestro: secondo, domanda: d2, risposta: testo2);
        // Stato 3: il turno dopo, col filo, nel consulto vero.
        final storia3 = [
          ...storia,
          ChatMessage(role: ChatRole.user, text: d2),
          ChatMessage(role: ChatRole.maestro, text: testo2),
        ];
        const d3 = 'E se le cose non vanno come speri?';
        final dopo = await _chiama(secondo, storia3, d3,
            IlFiloDelConsulto.bloccoPer(secondo, storia: storia3));
        final (rete3, _, corretta3) =
            await conLaRete(secondo, storia3, d3, dopo.testo);
        if (corretta3) correzioni++;
        costoRete.add(rete2 + rete3);
        // Lo stesso terzo turno senza il filo, sulla catena senza filo.
        final dopoSenza = await _chiama(
            secondo,
            [
              ...storia,
              ChatMessage(role: ChatRole.user, text: d2),
              ChatMessage(role: ChatRole.maestro, text: senza.testo),
            ],
            d3,
            '');
        stato1.add(senza.ingresso);
        stato2.add(con.ingresso);
        stato3.add(dopo.ingresso - dopo.cache);
        double costo(_Esito e, {required bool conCache}) {
          final c = conCache ? e.cache : 0;
          return ((e.ingresso - c) * pIn + c * pCache + e.uscita * pOut) / 1e6;
        }

        // Il costo di un consulto di tre turni, tutti misurati: prima
        // senza filo, dopo col filo, con la cache che Vertex ha dato.
        final prima = costo(r1, conCache: true) +
            costo(senza, conCache: true) +
            costo(dopoSenza, conCache: true);
        final dopoIlFilo = costo(r1, conCache: true) +
            costo(con, conCache: true) +
            costo(dopo, conCache: true) +
            rete2 +
            rete3;
        costoPrima.add(prima);
        costoDopo.add(dopoIlFilo);
        final riga = 'consulto ${righe.length + 1} (${primo.displayName}'
            '${passa ? ' poi ${secondo.displayName}' : ''}): ingresso senza '
            'filo ${senza.ingresso} (cache ${senza.cache}), col filo '
            '${con.ingresso} (cache ${con.cache}), turno dopo ${dopo.ingresso} '
            'di cui ${dopo.cache} dalla cache; costo prima '
            '${prima.toStringAsFixed(5)} dollari, dopo '
            '${dopoIlFilo.toStringAsFixed(5)}, di cui rete e correzioni '
            '${(rete2 + rete3).toStringAsFixed(5)}'
            '${corretta2 || corretta3 ? ' (corretta dalla rete)' : ''}; '
            'uscita (di cui ragionamento) '
            'senza filo ${senza.uscita} (${senza.pensiero}) e '
            '${dopoSenza.uscita} (${dopoSenza.pensiero}), col filo '
            '${con.uscita} (${con.pensiero}) e ${dopo.uscita} '
            '(${dopo.pensiero}); caratteri senza filo '
            '${senza.testo.length + dopoSenza.testo.length}, col filo '
            '${con.testo.length + dopo.testo.length}';
        print(riga);
        righe.add(riga);
      }
    }
    int mediana(List<int> l) => (l.toList()..sort())[l.length ~/ 2];
    double medianaD(List<double> l) => (l.toList()..sort())[l.length ~/ 2];
    final riepilogo = 'ORDINE FE VOCE 19: token di ingresso mediani su '
        '${stato1.length} consulti: prima del filo ${mediana(stato1)}, col '
        'filo senza cache ${mediana(stato2)}, col filo e con la cache '
        '${mediana(stato3)} pagati a prezzo pieno.\n'
        'ORDINE FE VOCE 20: costo mediano per consulto di tre turni: prima '
        '${medianaD(costoPrima).toStringAsFixed(5)} dollari, dopo '
        '${medianaD(costoDopo).toStringAsFixed(5)} dollari; totale dei dieci '
        'prima ${costoPrima.reduce((a, b) => a + b).toStringAsFixed(4)}, '
        'dopo ${costoDopo.reduce((a, b) => a + b).toStringAsFixed(4)}, di '
        'cui rete della coerenza e correzioni '
        '${costoRete.reduce((a, b) => a + b).toStringAsFixed(4)} '
        '($correzioni correzioni).';
    print(riepilogo);
    final cartella = Directory('docs/collaudo/FE/costo')
      ..createSync(recursive: true);
    final nome =
        DateTime.now().toIso8601String().substring(0, 16).replaceAll(':', '');
    File('${cartella.path}/il_costo_del_filo_$nome.txt')
        .writeAsStringSync('${righe.join('\n')}\n\n$riepilogo\n');
  }, timeout: const Timeout(Duration(minutes: 30)));

  test('il costo con uno, due e tre Maestri (ordine FE voce 13)', () async {
    HttpOverrides.global = null;
    final righe = <String>[];
    for (final tema in temi) {
      var ora = DateTime(2026, 10, 6, 10);
      IlFiloDelConsulto.dimentica();
      IlFiloDelConsulto.adesso = () => ora;
      final misure = <String>[];
      for (final (k, chi) in Maestro.values.indexed) {
        final filo = IlFiloDelConsulto.bloccoPer(chi, storia: const []);
        final e = await _chiama(chi, const [], tema, filo);
        var rete = 0.0;
        if (k > 0) {
          final (c, _, _) = await conLaRete(chi, const [], tema, e.testo);
          rete = c;
        }
        IlFiloDelConsulto.annota(
            maestro: chi, domanda: tema, risposta: e.testo);
        misure.add('${chi.displayName} (${k + 1}° Maestro): ingresso '
            '${e.ingresso}, blocco del filo ${filo.length} caratteri, costo '
            '${(costoDi(e) + rete).toStringAsFixed(5)} dollari di cui rete '
            '${rete.toStringAsFixed(5)}');
        ora = ora.add(const Duration(minutes: 2));
      }
      final riga = '«$tema»: ${misure.join('; ')}';
      print(riga);
      righe.add(riga);
    }
    final cartella = Directory('docs/collaudo/FE/costo')
      ..createSync(recursive: true);
    final nome =
        DateTime.now().toIso8601String().substring(0, 16).replaceAll(':', '');
    File('${cartella.path}/i_tre_maestri_$nome.txt')
        .writeAsStringSync('${righe.join('\n')}\n');
  }, timeout: const Timeout(Duration(minutes: 30)));
}

class _Esito {
  _Esito(this.testo, this.ingresso, this.cache, this.uscita, this.pensiero);
  final String testo;
  final int ingresso, cache, uscita;

  /// Di cui ragionamento: l'uscita lo comprende.
  final int pensiero;
}

String _gettone = '';

/// La rete della coerenza: Flash-Lite, temperatura zero, JSON, come
/// `FirebaseMaestroAiProvider.giudicaLaCoerenza`.
Future<_Esito> _rete(String istruzione, String testo) => _posta(
      LaReteDellaCoerenza.modello,
      {
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
          'maxOutputTokens': MisuraDellaRisposta.letturaBreve.tetto,
          'thinkingConfig': {
            'thinkingBudget': MisuraDellaRisposta.letturaBreve.ragionamento
          },
          'responseMimeType': 'application/json',
        },
      },
    );

Future<_Esito> _chiama(
    Maestro chi, List<ChatMessage> storia, String domanda, String filo,
    {String? istruzione, String? modello}) async {
  istruzione ??= MaestroPersona.systemInstruction(
    maestro: chi,
    profile: UserProfile.empty,
    memory: MaestroMemory.empty,
    primaRisposta: !storia.any((m) => m.isMaestro),
    testiGiaDetti: [
      for (final m in storia)
        if (m.isMaestro) m.text
    ],
    filo: filo,
  );
  final misura = MisuraDellaRisposta.perIlTurno(nelLive: false);
  return _posta(modello ?? FirebaseMaestroAiProvider.kMaestroChatModel, {
    'systemInstruction': {
      'parts': [
        {'text': istruzione}
      ]
    },
    'contents': [
      for (final m in storia)
        {
          'role': m.isUser ? 'user' : 'model',
          'parts': [
            {'text': m.text}
          ]
        },
      {
        'role': 'user',
        'parts': [
          {'text': domanda}
        ]
      }
    ],
    'generationConfig': {
      'temperature': 0.9,
      'topP': 0.95,
      'maxOutputTokens': misura.tetto,
      'thinkingConfig': {'thinkingBudget': misura.ragionamento},
    },
  });
}

Future<_Esito> _posta(String modello, Map<String, Object?> richiesta) async {
  if (_gettone.isEmpty) {
    final r = await Process.run('gcloud', ['auth', 'print-access-token'],
        runInShell: true);
    _gettone = '${r.stdout}'.trim();
  }
  const regione = LaRegioneDeiDati.regione;
  final url = Uri.parse('https://$regione-aiplatform.googleapis.com/v1/'
      'projects/esoteric-circle/locations/$regione/publishers/google/models/'
      '$modello:generateContent');
  final corpo = jsonEncode(richiesta);
  final client = HttpClient();
  try {
    var attesa = 2;
    while (true) {
      final req = await client.postUrl(url);
      req.headers.set('Authorization', 'Bearer $_gettone');
      req.headers.contentType = ContentType.json;
      req.add(utf8.encode(corpo));
      final res = await req.close();
      final testo = await res.transform(utf8.decoder).join();
      if ((res.statusCode == 429 || res.statusCode == 503) && attesa <= 32) {
        await Future<void>.delayed(Duration(seconds: attesa));
        attesa *= 2;
        continue;
      }
      if (res.statusCode != 200) {
        throw HttpException('Vertex ${res.statusCode}: $testo');
      }
      final j = jsonDecode(testo) as Map<String, dynamic>;
      final u = (j['usageMetadata'] as Map?) ?? const {};
      final parti = ((j['candidates'] as List).first as Map)['content']
          ?['parts'] as List?;
      return _Esito(
        [
          for (final p in parti ?? const [])
            if ((p as Map)['thought'] != true) '${p['text'] ?? ''}'
        ].join().trim(),
        (u['promptTokenCount'] as num?)?.toInt() ?? 0,
        (u['cachedContentTokenCount'] as num?)?.toInt() ?? 0,
        ((u['candidatesTokenCount'] as num?)?.toInt() ?? 0) +
            ((u['thoughtsTokenCount'] as num?)?.toInt() ?? 0),
        (u['thoughtsTokenCount'] as num?)?.toInt() ?? 0,
      );
    }
  } finally {
    client.close();
  }
}
