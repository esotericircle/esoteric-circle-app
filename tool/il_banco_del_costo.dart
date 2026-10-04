// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/magic/il_sigillo_dal_modello.dart';
import 'package:esoteric_circle/core/magic/intention_sigil.dart';
import 'package:esoteric_circle/core/maestro/consult_depth.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/rituals/animal_catalog.dart';
import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/core/ricordi/riassunti_del_tempo.dart';
import 'package:esoteric_circle/services/ricordi/penna_vera_del_mese.dart';
import 'package:esoteric_circle/core/tarot/la_lettura_dal_modello.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:esoteric_circle/core/viaggio/il_segno_dell_animale.dart';
import 'package:esoteric_circle/core/viaggio/la_domanda_capita.dart';
import 'package:esoteric_circle/core/viaggio/la_scena_dal_modello.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_controller.dart';
import 'package:esoteric_circle/services/ai/firebase_maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/services/ai/registro_dei_guasti.dart';
import 'package:esoteric_circle/services/ai/titoli_da_gemini.dart';
import 'package:esoteric_circle/services/ai/voce_sorvegliata.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:esoteric_circle/services/voce/l_orecchio_del_live.dart';
import 'package:flutter_test/flutter_test.dart';

import 'il_banco_del_costo_comune.dart';

/// **IL BANCO DEL COSTO DI OGNI FUNZIONE.** Ordine EW, voce EW.04, 2 ottobre
/// 2026.
///
/// Fa girare il codice VERO dell'app (il controller della chat, il provider
/// dei Maestri, i Tarocchi, le Rune, il Sigillo, il Viaggio, i titoli,
/// l'ascolto del LIVE) con Gemini vero in europe-west1, e da ogni risposta
/// legge i consumi (`usageMetadata`: token in ingresso, in uscita, di
/// ragionamento, dalla cache) con l'etichetta della funzione. La voce del
/// Maestro, che parte dal server, si chiama qui col corpo della funzione
/// `laVoceDelMaestro`. Per ogni uso: le chiamate fatte e il costo in
/// dollari, coi prezzi pubblici letti il 2 ottobre 2026.
///
///     flutter test tool/il_banco_del_costo.dart
///     VOLTE=5 CASI=chat,viaggio flutter test tool/il_banco_del_costo.dart
///
/// Scrive `docs/costi/costo_per_funzione_misure.txt`. Non e' nella suite:
/// costa chiamate vere.

/// I prezzi in dollari per milione di token (europe-west1, livello standard,
/// letti il 2 ottobre 2026). Il ragionamento si paga come l'uscita.
const _prezzi = <String, ({double ingresso, double uscita, double audio})>{
  'gemini-2.5-flash': (ingresso: 0.30, uscita: 2.50, audio: 1.00),
  'gemini-2.5-flash-lite': (ingresso: 0.10, uscita: 0.40, audio: 0.30),
  'gemini-2.5-flash-tts': (ingresso: 0.50, uscita: 10.00, audio: 0.50),
  'gemini-2.5-pro-tts': (ingresso: 1.00, uscita: 20.00, audio: 1.00),
};

double costoDi(UnaChiamata c) {
  final p = _prezzi[c.modello];
  if (p == null) return 0;
  // L'ingresso audio (l'ascolto del LIVE) ha il suo prezzo.
  var audioIn = 0;
  for (final d in (c.uso['promptTokensDetails'] as List?) ?? const []) {
    if (d is Map && d['modality'] == 'AUDIO') {
      audioIn += (d['tokenCount'] as num).toInt();
    }
  }
  // I token dalla cache implicita costano il 10% dell'ingresso ("Implicit
  // caching provides a 90% discount on cached tokens", pagina del context
  // cache di Vertex, letta il 2 ottobre 2026); si contano come testo.
  final testoIn = c.ingresso - audioIn - c.dallaCache;
  return (testoIn * p.ingresso +
          c.dallaCache * p.ingresso * 0.10 +
          audioIn * p.audio +
          (c.uscita + c.ragionamento) * p.uscita) /
      1e6;
}

final int _volte = int.tryParse(Platform.environment['VOLTE'] ?? '') ?? 20;
final Set<String> _casi = {
  ...?Platform.environment['CASI']?.split(',').where((x) => x.isNotEmpty),
};
bool _gira(String caso) => _casi.isEmpty || _casi.contains(caso);

/// Gli usi misurati: per ogni caso, la lista delle chiamate di ogni uso.
final Map<String, List<List<UnaChiamata>>> _usi = {};

/// Gli usi finiti nella riserva dell'app (il modello ha risposto, il testo
/// e' stato scartato): le chiamate si pagano lo stesso e si contano.
final Map<String, int> _allaRiserva = {};

Future<T?> _unUso<T>(String caso, Future<T> Function() uso) async {
  final prima = registro.length;
  T? r;
  try {
    r = await uso();
  } catch (errore) {
    _allaRiserva[caso] = (_allaRiserva[caso] ?? 0) + 1;
    print('ALLA RISERVA in $caso: $errore');
  }
  (_usi[caso] ??= []).add(registro.sublist(prima));
  return r;
}

const _natale = NatalContext(
  sunSign: 'Cancro',
  ascendant: 'Gemelli',
  lifeNumber: 3,
  lifeNumberTitle: 'il Creativo',
);

const _domande = [
  'Mi trasferisco a Berlino per lavoro?',
  'Come posso ritrovare la calma prima di dormire?',
  'Cosa dice il cielo di oggi per me?',
  'Che Luna c\'è stasera e cosa significa?',
  'Devo dire a Marco che mi piace?',
  'Il mio capo mi ha offerto un ruolo nuovo, accetto?',
  'Cosa porterà Saturno nel prossimo mese?',
  'Mia sorella e io non ci parliamo da Natale, cosa faccio?',
  'Ho speso troppo quest\'anno, come rimetto ordine?',
  'Il 15 novembre è un buon giorno per firmare un contratto?',
];

/// La memoria piena: venti turni di conversazione di prima, la sintesi e
/// dodici fatti, come chi parla ogni giorno con lo stesso Maestro.
Future<InMemoryMaestroMemoryRepository> _memoriaPiena(Maestro m) async {
  final repo = InMemoryMaestroMemoryRepository();
  await repo.saveMemory(
      m,
      const MaestroMemory(
        sessionSummary: 'Abbiamo parlato a lungo del trasferimento a Berlino, '
            'della relazione con Marco e del lavoro nuovo: la persona cerca '
            'una conferma prima di ogni scelta e ha paura di sbagliare.',
        facts: [
          'lavora in banca da otto anni',
          'vive a Torino con la sorella',
          'ha un cane che si chiama Ombra',
          'sta pensando di trasferirsi a Berlino',
          'ha conosciuto Marco tre mesi fa',
          'ha litigato con la sorella a Natale',
          'dorme male prima delle scadenze',
          'ama la ceramica e vorrebbe aprire una bottega',
          'ha un colloquio a fine mese',
          'medita la mattina presto',
          'ha paura di deludere la madre',
          'ha 34 anni',
        ],
      ));
  final ora = DateTime.now();
  for (var i = 0; i < 20; i++) {
    final quando = ora.subtract(Duration(days: 13 - i % 14, minutes: 40 - i));
    await repo.appendMessage(
        m,
        ChatMessage(
            role: ChatRole.user,
            text: 'Domanda numero $i: ${_domande[i % _domande.length]} '
                'Te lo chiedo perche\' in questi giorni ci penso spesso.',
            at: quando));
    await repo.appendMessage(
        m,
        ChatMessage(
            role: ChatRole.maestro,
            autore: m,
            text: 'Risposta numero $i. Ti dico di guardare con calma cio\' che '
                'hai davanti, senza correre: la scelta che temi e\' piu\' piccola '
                'di come la immagini. Parti da un gesto concreto, domani mattina, '
                'e osserva come ti senti dopo. Le stelle non decidono al posto '
                'tuo, ma ti indicano un tempo: questo e\' un tempo per ascoltare '
                'prima di agire. Scrivimi di nuovo quando avrai fatto il primo '
                'passo, e vedremo insieme il secondo.\n✦ Domani mattina fai '
                'una telefonata che rimandi da giorni.',
            at: quando.add(const Duration(minutes: 1))));
  }
  return repo;
}

Future<MaestroChatController> _controller(
    Maestro m, InMemoryMaestroMemoryRepository memoria, Tier tier) async {
  final c = MaestroChatController(
    maestro: m,
    ai: VoceSorvegliata(
        voce: FirebaseMaestroAiProvider(), registro: RegistroDeiGuasti()),
    memory: memoria,
    allowance: QuestionAllowance(freeDailyLimit: 999),
    tier: () => tier,
    natal: () => _natale,
    attesaMinima: Duration.zero,
  );
  await c.init();
  return c;
}

/// Il WAV a 16 kHz di una frase detta da Gemini TTS, per l'ascolto del LIVE.
Future<Uint8List?> _audioDi(String frase) async {
  final url = Uri.https('europe-west1-aiplatform.googleapis.com',
      '/v1/projects/esoteric-circle/locations/europe-west1/publishers/google/models/gemini-2.5-flash-tts:generateContent');
  final r = await HttpClient().postUrl(url).then((q) async {
    q.headers.set('Authorization', 'Bearer ${await gettone()}');
    q.headers.contentType = ContentType.json;
    q.write(jsonEncode({
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': frase}
          ]
        }
      ],
      'generationConfig': {
        'responseModalities': ['AUDIO'],
        'speechConfig': {
          'voiceConfig': {
            'prebuiltVoiceConfig': {'voiceName': 'Algenib'}
          }
        }
      },
    }));
    return q.close();
  });
  final t = await r.transform(utf8.decoder).join();
  final j = jsonDecode(t) as Map<String, dynamic>;
  final dati = (((j['candidates'] as List?)?.first as Map?)?['content']
      as Map?)?['parts'] as List?;
  final b64 = (dati?.first as Map?)?['inlineData']?['data'] as String?;
  if (b64 == null) return null;
  // PCM 24 kHz mono 16 bit: si porta a 16 kHz prendendo due campioni su tre.
  final pcm = base64Decode(b64);
  final campioni = pcm.buffer.asInt16List(pcm.offsetInBytes, pcm.length ~/ 2);
  final ridotti = Int16List(campioni.length * 2 ~/ 3);
  for (var i = 0; i < ridotti.length; i++) {
    ridotti[i] = campioni[i * 3 ~/ 2];
  }
  final corpo = ridotti.buffer.asUint8List();
  final h = ByteData(44);
  void s(int o, String x) {
    for (var i = 0; i < 4; i++) {
      h.setUint8(o + i, x.codeUnitAt(i));
    }
  }

  s(0, 'RIFF');
  h.setUint32(4, 36 + corpo.length, Endian.little);
  s(8, 'WAVE');
  s(12, 'fmt ');
  h.setUint32(16, 16, Endian.little);
  h.setUint16(20, 1, Endian.little);
  h.setUint16(22, 1, Endian.little);
  h.setUint32(24, 16000, Endian.little);
  h.setUint32(28, 32000, Endian.little);
  h.setUint16(32, 2, Endian.little);
  h.setUint16(34, 16, Endian.little);
  s(36, 'data');
  h.setUint32(40, corpo.length, Endian.little);
  return Uint8List.fromList([...h.buffer.asUint8List(), ...corpo]);
}

/// La voce del Maestro di una risposta del LIVE, col corpo di
/// `laVoceDelMaestro` (`functions/src/live.ts`): una richiesta a flusso per
/// pezzo, la prima frase da sola e il resto a pezzi.
Future<void> _voceDelMaestro(String risposta) async {
  final frasi = risposta
      .split(RegExp(r'(?<=[.!?])\s+'))
      .where((f) => f.trim().isNotEmpty)
      .toList();
  if (frasi.isEmpty) return;
  final pezzi = <String>[frasi.first];
  var corrente = '';
  for (final f in frasi.skip(1)) {
    if ((corrente + f).length > 220 && corrente.isNotEmpty) {
      pezzi.add(corrente.trim());
      corrente = '';
    }
    corrente += '$f ';
  }
  if (corrente.trim().isNotEmpty) pezzi.add(corrente.trim());
  for (final p in pezzi) {
    final url = Uri.https(
        'europe-west1-aiplatform.googleapis.com',
        '/v1/projects/esoteric-circle/locations/europe-west1/publishers/google/models/gemini-2.5-flash-tts:streamGenerateContent',
        {'alt': 'sse'});
    final q = await HttpClient().postUrl(url);
    q.headers.set('Authorization', 'Bearer ${await gettone()}');
    q.headers.contentType = ContentType.json;
    q.write(jsonEncode({
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': 'Leggi con voce calda e lenta: $p'}
          ]
        }
      ],
      'generationConfig': {
        'responseModalities': ['AUDIO'],
        'speechConfig': {
          'voiceConfig': {
            'prebuiltVoiceConfig': {'voiceName': 'Erinome'}
          }
        }
      },
      'labels': {'funzione': 'voce_maestro'},
    }));
    final r = await q.close();
    final t = await r.transform(utf8.decoder).join();
    Map<String, dynamic>? uso;
    for (final m
        in RegExp(r'"usageMetadata"\s*:\s*(\{[^{}]*(\{[^{}]*\}[^{}]*)*\})')
            .allMatches(t)) {
      try {
        uso = jsonDecode(m.group(1)!) as Map<String, dynamic>;
      } catch (_) {}
    }
    registro
        .add(UnaChiamata('voce_maestro', 'gemini-2.5-flash-tts', uso ?? {}));
  }
}

void main() {
  setUpAll(preparaIlBanco);

  test('il banco del costo', () async {
    final caso = Random(7);
    final righe = <String>[];

    if (_gira('chat')) {
      // La chat, memoria vuota (il Viandante), poi memoria piena.
      for (var i = 0; i < _volte; i++) {
        final m = Maestro.values[i % 3];
        final c =
            await _controller(m, InMemoryMaestroMemoryRepository(), Tier.free);
        await _unUso('chat, memoria vuota', () => c.send(_domande[i % 10]));
      }
      for (var i = 0; i < _volte; i++) {
        final m = Maestro.values[i % 3];
        final c = await _controller(m, await _memoriaPiena(m), Tier.tier3);
        await _unUso('chat, memoria piena (20 turni, sintesi, 12 fatti)',
            () => c.send(_domande[(i + 3) % 10]));
        if (i < _volte ~/ 2) {
          await _unUso('chat, Vai piu\' a fondo (memoria piena)',
              () => c.approfondisci());
        }
      }
    }

    if (_gira('live')) {
      for (var i = 0; i < _volte; i++) {
        final m = Maestro.values[i % 3];
        final c = await _controller(m, await _memoriaPiena(m), Tier.tier3);
        c.nelLive = true;
        await _unUso(
            'LIVE, la risposta del Maestro', () => c.send(_domande[i % 10]));
        final r = c.messages.last.text;
        await _unUso('LIVE, la voce del Maestro della risposta',
            () => _voceDelMaestro(r));
      }
    }

    if (_gira('ascolto')) {
      // Venti frasi ascoltate davvero: la sintesi della frase di prova a
      // volte cade, e allora si riprova (fino a tre volte il numero).
      var fatte = 0;
      for (var i = 0; fatte < _volte && i < _volte * 3; i++) {
        final wav = await _audioDi(_domande[i % 10]);
        if (wav == null) continue;
        fatte++;
        await _unUso('LIVE, l\'ascolto di una frase',
            () => LaTrascrizione.trascrivi(wav));
      }
    }

    if (_gira('complementi')) {
      // I casi che il primo giro ha fatto dieci volte (vengono dopo una
      // risposta): altri dieci, cosi' arrivano a venti. Una domanda con la
      // memoria piena e il suo "Vai piu' a fondo"; la riformulazione e il
      // compimento di un sigillo.
      for (var i = 0; i < 10; i++) {
        final m = Maestro.values[(i + 1) % 3];
        final c = await _controller(m, await _memoriaPiena(m), Tier.tier3);
        await _unUso('chat, memoria piena (20 turni, sintesi, 12 fatti)',
            () => c.send(_domande[(i + 5) % 10]));
        await _unUso(
            'chat, Vai piu\' a fondo (memoria piena)', () => c.approfondisci());
      }
      const altre = [
        'Voglio ritrovare la fiducia in me stessa',
        'Desidero una casa piu\' luminosa',
        'Voglio fare pace con mio padre',
        'Desidero superare l\'esame di settembre',
        'Voglio lasciare andare la rabbia',
      ];
      for (var i = 0; i < 10; i++) {
        final intenzione = altre[i % altre.length];
        await _unUso(
            'Sigillo, la riformulazione',
            () => IlSigilloDalModello.riformula(
                intenzione: intenzione,
                via: ViaMagica.values[i % 3],
                forma: CourtesyForm.neutral));
        await _unUso(
            'Sigillo, il compimento',
            () => IlSigilloDalModello.compimento(
                intenzione: intenzione, forma: CourtesyForm.neutral));
      }
    }

    if (_gira('profonda')) {
      // La consulta Profonda di Interroga (Flash col ragionamento): oggi
      // nessuna strada dell'app la chiede, si misura per sapere quanto
      // costerebbe.
      final p = FirebaseMaestroAiProvider();
      for (var i = 0; i < _volte; i++) {
        await _unUso(
            'Interroga, una lente Profonda (mai chiesta dall\'app)',
            () => p.consult(
                maestro: Maestro.values[i % 3],
                theme: _domande[i % 10],
                profile: UserProfile(),
                natal: _natale,
                depth: ConsultDepth.profonda));
      }
    }

    if (_gira('interroga')) {
      final p = FirebaseMaestroAiProvider();
      for (var i = 0; i < _volte; i++) {
        await _unUso('Interroga i Maestri, tre lenti e la sintesi', () async {
          final lenti = <MaestroLens>[];
          for (final m in Maestro.values) {
            final r = await p.consult(
                maestro: m,
                theme: _domande[i % 10],
                profile: UserProfile(),
                natal: _natale,
                depth: ConsultDepth.breve);
            lenti.add(MaestroLens(maestro: m, reply: r));
          }
          await p.synthesize(
              theme: _domande[i % 10], lenses: lenti, natal: _natale);
        });
      }
    }

    if (_gira('tarocchi')) {
      for (var i = 0; i < _volte; i++) {
        await _unUso(
            'Tarocchi, la lettura della stesa',
            () => LaLetturaDellaStesa.leggi(
                  spread: TarotSpread.draw(seed: caso.nextInt(1 << 31)),
                  domanda: _domande[i % 10],
                  argomento:
                      TarotTopic.values[i % TarotTopic.values.length].label,
                  forma: CourtesyForm.neutral,
                ));
      }
    }

    if (_gira('rune')) {
      final p = FirebaseMaestroAiProvider();
      for (var i = 0; i < _volte; i++) {
        final g = gettate[i % gettate.length];
        await _unUso(
            'Rune, la lettura della gettata',
            () => p.presagioDelleRune(
                  esito: RuneCast.getta(g, random: Random(100 + i)),
                  domanda: _domande[i % 10],
                  profile: UserProfile(),
                ));
      }
    }

    if (_gira('sigillo')) {
      const intenzioni = [
        'Voglio trovare il coraggio di cambiare lavoro',
        'Desidero un amore sincero',
        'Voglio dormire sereno ogni notte',
        'Voglio che mio fratello mi richiami',
        'Desidero aprire la mia bottega di ceramica',
      ];
      for (var i = 0; i < _volte; i++) {
        final intenzione = intenzioni[i % intenzioni.length];
        await _unUso(
            'Sigillo, titolo e responso',
            () => IlSigilloDalModello.scrivi(
                intenzione: intenzione,
                via: ViaMagica.values[i % 3],
                forma: CourtesyForm.neutral));
        if (i < _volte ~/ 2) {
          await _unUso(
              'Sigillo, la riformulazione',
              () => IlSigilloDalModello.riformula(
                  intenzione: intenzione,
                  via: ViaMagica.values[i % 3],
                  forma: CourtesyForm.neutral));
          await _unUso(
              'Sigillo, il compimento',
              () => IlSigilloDalModello.compimento(
                  intenzione: intenzione, forma: CourtesyForm.neutral));
        }
      }
    }

    if (_gira('viaggio')) {
      final animale = AnimalCatalog.animals.first;
      for (var i = 0; i < _volte; i++) {
        final d = _domande[i % 10];
        await _unUso('Viaggio, una discesa con la domanda scritta', () async {
          final capita = await LaDomandaCapita.capisci(d,
              prendiUnaChiamata: () async => true);
          await LaScenaDalModello.chiediTutto(
            CioCheSiSa(
              domanda: d,
              tema: capita.tema?.inLettere,
              animale: animale,
              natale: _natale,
              memoria: '',
              ultimeScene: const [],
              oggetto: capita.oggetto,
              strato: 1 + i % 4,
            ),
            prendiUnaChiamata: () async => true,
          );
        });
        await _unUso(
            'Viaggio, un segno chiesto all\'animale',
            () => GestiDelSegno.chiedi(
                  animale: animale,
                  domanda: d,
                  giorno: DateTime(2026, 10, 2),
                  prendiUnaChiamata: () async => true,
                ));
      }
    }

    if (_gira('titoli')) {
      const t = TitoliDaGemini();
      for (var i = 0; i < _volte; i++) {
        await _unUso(
            'Il titolo della conversazione',
            () => t.scrivi(
                maestro: Maestro.values[i % 3],
                domanda: _domande[i % 10],
                risposta:
                    'Ti dico di guardare con calma cio\' che hai davanti, '
                    'senza correre: la scelta che temi e\' piu\' piccola.'));
      }
    }

    if (_gira('ricordi')) {
      RiassuntoDelTempo r(String chiave, int voci) => RiassuntoDelTempo(
            chiave: chiave,
            quanteVoci: voci,
            perMaestro: {
              'medora': voci ~/ 2,
              'aura': voci ~/ 3,
              'caligo': voci ~/ 6
            },
            perArte: {
              'tarocchi': voci ~/ 3,
              'rune': voci ~/ 4,
              'chat': voci ~/ 3
            },
            quantiTraguardi: voci ~/ 10,
            quantiDoni: voci ~/ 12,
            eosGuadagnati: voci * 5,
          );
      for (var i = 0; i < _volte; i++) {
        await _unUso(
            'Ricordi, la pagina del mese',
            () => const PennaVeraDelMese().scrivi(
                  mese: '2026-09',
                  riassunto: r('2026-09', 40 + i),
                  settimane: [
                    for (var s = 0; s < 4; s++)
                      r('2026-W${36 + s}', 8 + s + i % 3)
                  ],
                  maestro: Maestro.values[i % 3].id,
                ));
      }
    }

    // **IL CONTO**, per caso: chiamate per uso, token, costo medio e massimo.
    var totale = 0.0;
    var chiamate = 0;
    righe
      ..add('ORDINE EW VOCE EW.04, IL COSTO DI OGNI FUNZIONE, misurato il '
          '${DateTime.now()} col codice vero dell\'app e Gemini in '
          'europe-west1; $_volte usi per caso.')
      ..add('Prezzi per milione di token: Flash 0,30 ingresso testo, 1,00 '
          'ingresso audio, 2,50 uscita e ragionamento; Flash-Lite 0,10 e 0,40; '
          'Flash TTS 0,50 testo e 10,00 audio in uscita.')
      ..add('');
    for (final e in _usi.entries) {
      final costi = [
        for (final u in e.value) u.fold<double>(0, (a, c) => a + costoDi(c))
      ];
      final ch = [for (final u in e.value) u.length];
      final ingresso =
          e.value.expand((u) => u).fold<int>(0, (a, c) => a + c.ingresso);
      final uscita =
          e.value.expand((u) => u).fold<int>(0, (a, c) => a + c.uscita);
      final ragion =
          e.value.expand((u) => u).fold<int>(0, (a, c) => a + c.ragionamento);
      final cache =
          e.value.expand((u) => u).fold<int>(0, (a, c) => a + c.dallaCache);
      final funzioni = {
        for (final u in e.value)
          for (final c in u) c.funzione
      };
      final medio =
          costi.isEmpty ? 0 : costi.reduce((a, b) => a + b) / costi.length;
      final massimo = costi.isEmpty ? 0 : costi.reduce(max);
      totale += costi.fold(0.0, (a, b) => a + b);
      chiamate += ch.fold(0, (a, b) => a + b);
      righe.add('${e.key} [${funzioni.join(', ')}]: usi ${e.value.length}'
          '${_allaRiserva[e.key] == null ? '' : ' (alla riserva dopo il modello ${_allaRiserva[e.key]})'}, '
          'chiamate per uso da ${ch.isEmpty ? 0 : ch.reduce(min)} a '
          '${ch.isEmpty ? 0 : ch.reduce(max)} (media '
          '${(ch.fold(0, (a, b) => a + b) / max(1, ch.length)).toStringAsFixed(2)}); '
          'token in ingresso $ingresso, in uscita $uscita, di ragionamento '
          '$ragion, dalla cache $cache; costo per uso medio '
          '${medio.toStringAsFixed(5)} \$, massimo ${massimo.toStringAsFixed(5)} \$');
    }
    righe
      ..add('')
      ..add('IL BANCO: chiamate a Gemini $chiamate (piu\' le sintesi delle '
          'frasi da ascoltare), costo misurato ${totale.toStringAsFixed(4)} \$.');
    if (fuoriRegione.isNotEmpty) {
      righe.add('Chiamate che nell\'app partono fuori da europe-west1, '
          'misurate in europe-west1: ${fuoriRegione.length} '
          '(${fuoriRegione.toSet().join(', ')}).');
    }
    // Ogni chiamata, una riga: la prova da cui si rifanno i conti.
    // Ogni giro si aggiunge, col suo istante.
    final giro = DateTime.now().toIso8601String().substring(0, 19);
    File('docs/costi/costo_per_funzione_chiamate.jsonl').writeAsStringSync(
        mode: FileMode.append,
        [
          for (final e in _usi.entries)
            for (var u = 0; u < e.value.length; u++)
              for (final c in e.value[u])
                jsonEncode({
                  'giro': giro,
                  'caso': e.key,
                  'uso': u,
                  'funzione': c.funzione,
                  'modello': c.modello,
                  'costo': costoDi(c),
                  'usageMetadata': c.uso,
                }),
        ].map((r) => '$r\n').join());
    final f = File('docs/costi/costo_per_funzione_misure.txt');
    final gia = f.existsSync() ? '${f.readAsStringSync()}\n' : '';
    f.writeAsStringSync('$gia${righe.join('\n')}\n');
    print(righe.join('\n'));
  }, timeout: const Timeout(Duration(minutes: 90)));
}
