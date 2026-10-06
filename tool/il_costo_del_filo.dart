// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/il_filo_del_consulto.dart';
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

  test('il costo del filo su dieci consulti', () async {
    HttpOverrides.global = null;
    final righe = <String>[];
    final stato1 = <int>[], stato2 = <int>[], stato3 = <int>[];
    final costoPrima = <double>[], costoDopo = <double>[];
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
        IlFiloDelConsulto.annota(
            maestro: secondo, domanda: d2, risposta: con.testo);
        // Stato 3: il turno dopo, col filo, nel consulto vero.
        final storia3 = [
          ...storia,
          ChatMessage(role: ChatRole.user, text: d2),
          ChatMessage(role: ChatRole.maestro, text: con.testo),
        ];
        const d3 = 'E se le cose non vanno come speri?';
        final dopo = await _chiama(secondo, storia3, d3,
            IlFiloDelConsulto.bloccoPer(secondo, storia: storia3));
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
            costo(dopo, conCache: true);
        costoPrima.add(prima);
        costoDopo.add(dopoIlFilo);
        final riga = 'consulto ${righe.length + 1} (${primo.displayName}'
            '${passa ? ' poi ${secondo.displayName}' : ''}): ingresso senza '
            'filo ${senza.ingresso} (cache ${senza.cache}), col filo '
            '${con.ingresso} (cache ${con.cache}), turno dopo ${dopo.ingresso} '
            'di cui ${dopo.cache} dalla cache; costo prima '
            '${prima.toStringAsFixed(5)} dollari, dopo '
            '${dopoIlFilo.toStringAsFixed(5)}; uscita (di cui ragionamento) '
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
        'dopo ${costoDopo.reduce((a, b) => a + b).toStringAsFixed(4)}.';
    print(riepilogo);
    final cartella = Directory('docs/collaudo/FE/costo')
      ..createSync(recursive: true);
    final nome =
        DateTime.now().toIso8601String().substring(0, 16).replaceAll(':', '');
    File('${cartella.path}/il_costo_del_filo_$nome.txt')
        .writeAsStringSync('${righe.join('\n')}\n\n$riepilogo\n');
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

Future<_Esito> _chiama(
    Maestro chi, List<ChatMessage> storia, String domanda, String filo) async {
  if (_gettone.isEmpty) {
    final r = await Process.run('gcloud', ['auth', 'print-access-token'],
        runInShell: true);
    _gettone = '${r.stdout}'.trim();
  }
  final istruzione = MaestroPersona.systemInstruction(
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
  const regione = LaRegioneDeiDati.regione;
  final url = Uri.parse('https://$regione-aiplatform.googleapis.com/v1/'
      'projects/esoteric-circle/locations/$regione/publishers/google/models/'
      '${FirebaseMaestroAiProvider.kMaestroChatModel}:generateContent');
  final corpo = jsonEncode({
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
