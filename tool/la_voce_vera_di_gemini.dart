// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/testo_del_responso.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/consult_depth.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_reply.dart';
import 'package:esoteric_circle/core/maestro/misura_della_risposta.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/responsi/anatomia_del_responso.dart';
import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/services/ai/firebase_maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/services/ai/maestro_persona.dart';

/// **LA VOCE VERA DI GEMINI PER I BANCHI.** Estratta il 24 settembre 2026 da
/// `collaudo_dei_maestri.dart`, ordine EJ, perche' il collaudo delle risposte
/// la usi uguale invece di copiarla: due copie dello stesso trasporto
/// divergono al primo ritocco.

// ===========================================================================
// LA VOCE VERA, cioe' il trasporto verso Vertex.
// ===========================================================================

/// **Il provider che parla davvero a Gemini**, con la stessa istruzione di
/// sistema, lo stesso modello, la stessa regione e la stessa configurazione
/// del provider dell'app. Cambia solo il trasporto, ed e' dichiarato in
/// testa a questo file.
/// Una risposta grezza, com'e' tornata da Gemini prima che la rete guardasse,
/// col tempo che e' costata. Serve alle voci ED.02 e ED.03.
class RispostaGrezza {
  RispostaGrezza(this.maestro, this.testo, this.durata);

  final Maestro maestro;
  final String testo;
  final Duration durata;
}

class VoceVeraDiGemini implements MaestroAiProvider {
  int chiamate = 0;

  /// **Ogni risposta che il provider restituisce, in ordine.** La rete della
  /// voce ED.03 sta sopra di lui: quindi qui passa sia la prima risposta sia
  /// quella richiesta, e **il collaudo puo' contare prima e dopo senza
  /// toccare la rete**.
  final List<RispostaGrezza> grezze = [];

  /// Le domande chiuse fatte al modello per giudicare una risposta,
  /// contate a parte: non sono voci dei Maestri.
  int giudizi = 0;
  String? _gettoneInCache;

  static const String _progetto = 'esoteric-circle';
  static const String _regione = 'europe-west1';

  @override
  bool get isReady => true;

  @override
  Future<String> reply({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory memory,
    required List<dynamic> history,
    required String userMessage,
    NatalContext natal = NatalContext.none,
    bool insistiSullAncoraggio = false,
    String? rispostaGiaData,
  }) async {
    final misura = rispostaGiaData == null
        ? MisuraDellaRisposta.perChat
        : MisuraDellaRisposta.perIlSeguito;
    final istruzione = MaestroPersona.systemInstruction(
      maestro: maestro,
      profile: profile,
      memory: memory,
      natal: natal,
      insistiSullAncoraggio: insistiSullAncoraggio,
      rispostaGiaData: rispostaGiaData,
      primaRisposta: !history.cast<ChatMessage>().any((m) => m.isMaestro),
      testiGiaDetti: [
        for (final m in history.cast<ChatMessage>())
          if (m.isMaestro) m.text
      ],
    );
    // La cronologia come la manda l'app: solo i messaggi veri, in ordine.
    final contents = <Map<String, dynamic>>[
      for (final m in history.cast<ChatMessage>())
        if (!m.pending && !m.failed && m.text.trim().isNotEmpty)
          {
            'role': m.isUser ? 'user' : 'model',
            'parts': [
              {'text': m.text}
            ],
          },
      {
        'role': 'user',
        'parts': [
          {'text': userMessage}
        ],
      },
    ];
    final corpo = jsonEncode({
      'systemInstruction': {
        'parts': [
          {'text': istruzione}
        ]
      },
      'contents': contents,
      'generationConfig': {
        'temperature': 0.9,
        'topP': 0.95,
        'maxOutputTokens': misura.tetto,
        'thinkingConfig': {'thinkingBudget': misura.ragionamento},
      },
    });

    // **IL GETTONE SI RINNOVA AL PRIMO RIFIUTO.** `print-access-token` da' il
    // gettone in cache, che in un giro lungo scade: al 401 si rinnova e si
    // riprova una volta sola.
    final cronometro = Stopwatch()..start();
    var risposta = await _chiedi(corpo);
    if (risposta.$1 == 401 || risposta.$1 == 403) {
      _gettoneInCache = null;
      risposta = await _chiedi(corpo);
    }
    chiamate++;
    if (risposta.$1 != 200) {
      throw MaestroAiUnavailable(
          'Vertex ha risposto ${risposta.$1}: ${risposta.$2}');
    }
    final mappa = jsonDecode(risposta.$2) as Map<String, dynamic>;
    final candidati = mappa['candidates'] as List?;
    if (candidati == null || candidati.isEmpty) {
      throw const MaestroAiUnavailable('Nessun candidato nella risposta.');
    }
    final primo = candidati.first as Map<String, dynamic>;
    final parti =
        ((primo['content'] as Map<String, dynamic>?)?['parts'] as List?) ?? [];
    final testo =
        parti.map((p) => ((p as Map)['text'] ?? '') as String).join().trim();
    if (testo.isEmpty) {
      throw const MaestroAiUnavailable('Il Maestro non ha trovato le parole.');
    }
    if (primo['finishReason'] == 'MAX_TOKENS') {
      throw const MaestroAiTroncata();
    }
    // L'ultima riga prima dello schermo, la stessa dell'app.
    final pulito = TestoDelResponso.pulisci(testo);
    cronometro.stop();
    grezze.add(RispostaGrezza(maestro, pulito, cronometro.elapsed));
    return pulito;
  }

  /// **UNA DOMANDA CHIUSA AL MODELLO, per giudicare una risposta libera.**
  ///
  /// Serve dove un elenco di frasi non puo' arrivare: se un testo scritto in
  /// liberta' fa o non fa una certa cosa. Temperatura zero, nessun
  /// ragionamento, una parola sola di risposta: e' un giudice, non una voce.
  ///
  /// **Non giudica il tono e non giudica la qualita'**: quelli restano al
  /// fondatore, che legge le trascrizioni. Qui si risponde a domande con due
  /// sole uscite.
  Future<bool> giudica(String domanda, String testo,
      {int ragionamento = 0}) async {
    final corpo = jsonEncode({
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': '$domanda\n\n---\n\n$testo'}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0,
        // Il ragionamento conta dentro il tetto: senza aggiungerlo, il
        // giudice pensa e resta senza spazio per la parola.
        'maxOutputTokens': 8 + ragionamento,
        'thinkingConfig': {'thinkingBudget': ragionamento},
      },
    });
    var risposta = await _chiedi(corpo);
    if (risposta.$1 == 401 || risposta.$1 == 403) {
      _gettoneInCache = null;
      risposta = await _chiedi(corpo);
    }
    giudizi++;
    if (risposta.$1 != 200) {
      throw MaestroAiUnavailable(
          'Il giudice ha risposto ${risposta.$1}: ${risposta.$2}');
    }
    final mappa = jsonDecode(risposta.$2) as Map<String, dynamic>;
    final parti = (((mappa['candidates'] as List?)?.firstOrNull
            as Map<String, dynamic>?)?['content']
        as Map<String, dynamic>?)?['parts'] as List?;
    final detto = (parti ?? [])
        .map((p) => ((p as Map)['text'] ?? '') as String)
        .join()
        .trim()
        .toUpperCase();
    return detto.startsWith('SI') || detto.startsWith('SÌ');
  }

  /// **UNA DOMANDA APERTA AL GIUDICE**, ordine EJ voce 08: dove serve un
  /// elenco e non un si' o un no, come gli errori di italiano di una
  /// risposta. Temperatura zero, nessun ragionamento.
  Future<String> elenca(String domanda, String testo, {int tetto = 300}) async {
    final corpo = jsonEncode({
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': '$domanda\n\n---\n\n$testo'}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0,
        'maxOutputTokens': tetto,
        'thinkingConfig': {'thinkingBudget': 0},
      },
    });
    var risposta = await _chiedi(corpo);
    if (risposta.$1 == 401 || risposta.$1 == 403) {
      _gettoneInCache = null;
      risposta = await _chiedi(corpo);
    }
    giudizi++;
    if (risposta.$1 != 200) {
      throw MaestroAiUnavailable(
          'Il giudice ha risposto ${risposta.$1}: ${risposta.$2}');
    }
    final mappa = jsonDecode(risposta.$2) as Map<String, dynamic>;
    final parti = (((mappa['candidates'] as List?)?.firstOrNull
            as Map<String, dynamic>?)?['content']
        as Map<String, dynamic>?)?['parts'] as List?;
    return (parti ?? [])
        .map((p) => ((p as Map)['text'] ?? '') as String)
        .join()
        .trim();
  }

  Future<(int, String)> _chiedi(String corpo) async {
    final gettone = _gettoneInCache ??= await _leggiIlGettone();
    final uri = Uri.https(
      '$_regione-aiplatform.googleapis.com',
      '/v1/projects/$_progetto/locations/$_regione/publishers/google/models/'
          '${FirebaseMaestroAiProvider.kMaestroChatModel}:generateContent',
    );
    final client = HttpClient();
    try {
      final richiesta = await client.postUrl(uri);
      richiesta.headers.set('Authorization', 'Bearer $gettone');
      richiesta.headers.set('Content-Type', 'application/json');
      richiesta.add(utf8.encode(corpo));
      final risposta = await richiesta.close();
      final grezzo = await risposta.transform(utf8.decoder).join();
      return (risposta.statusCode, grezzo);
    } finally {
      client.close(force: true);
    }
  }

  static Future<String> _leggiIlGettone() async {
    final esito = await Process.run('gcloud', ['auth', 'print-access-token'],
        runInShell: true);
    final t = (esito.stdout as String).trim();
    if (esito.exitCode != 0 || t.isEmpty) {
      throw const MaestroAiUnavailable(
          'Nessun gettone di accesso: serve una sessione gcloud attiva.');
    }
    return t;
  }

  // --- Le altre vie non servono al collaudo delle chat.
  @override
  Future<Responso> presagioDelleRune({
    required EsitoGettata esito,
    required String domanda,
    required UserProfile profile,
    NatalContext natal = NatalContext.none,
  }) async =>
      throw const MaestroAiUnavailable();

  @override
  Future<MaestroReply> consult({
    required Maestro maestro,
    required String theme,
    required UserProfile profile,
    MaestroMemory memory = MaestroMemory.empty,
    NatalContext? natal,
    ConsultDepth depth = ConsultDepth.breve,
  }) async =>
      throw const MaestroAiUnavailable();

  /// **LA SINTESI COMPARATIVA, CHIESTA A GEMINI VERO.** Ordine EE voce 10.
  ///
  /// Prima qui c'era un rifiuto: il collaudo provava le chat, non il
  /// Consiglio. La seconda meta' della voce 10 dice che la sintesi ripete le
  /// tre letture invece di confrontarle, e **senza una misura prima e dopo
  /// non si sa se una cura ha funzionato**: e' cio' che l'ordine EC voce 03
  /// ha insegnato a questa casa.
  @override
  Future<String> synthesize({
    required String theme,
    required List<MaestroLens> lenses,
    NatalContext? natal,
    UserProfile? profile,
  }) async {
    final corpo = jsonEncode({
      'systemInstruction': {
        'parts': [
          {
            'text': MaestroPersona.synthesisInstruction(
                natal: natal, profilo: profile)
          }
        ]
      },
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': _materialeDellaSintesi(theme, lenses)}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.7,
        'topP': 0.95,
        'maxOutputTokens': MisuraDellaRisposta.sintesi.tetto,
        'thinkingConfig': {
          'thinkingBudget': MisuraDellaRisposta.sintesi.ragionamento
        },
      },
    });
    var risposta = await _chiedi(corpo);
    if (risposta.$1 == 401 || risposta.$1 == 403) {
      _gettoneInCache = null;
      risposta = await _chiedi(corpo);
    }
    chiamate++;
    if (risposta.$1 != 200) {
      throw MaestroAiUnavailable('Vertex ha risposto ${risposta.$1}');
    }
    final mappa = jsonDecode(risposta.$2) as Map<String, dynamic>;
    final candidati = mappa['candidates'] as List?;
    if (candidati == null || candidati.isEmpty) {
      throw const MaestroAiUnavailable('Nessun candidato nella sintesi.');
    }
    final primo = candidati.first as Map<String, dynamic>;
    final parti =
        ((primo['content'] as Map<String, dynamic>?)?['parts'] as List?) ?? [];
    final testo =
        parti.map((p) => ((p as Map)['text'] ?? '') as String).join().trim();
    if (testo.isEmpty) {
      throw const MaestroAiUnavailable('La sintesi non ha trovato le parole.');
    }
    return TestoDelResponso.pulisci(testo);
  }

  /// Il materiale della sintesi, **nella stessa forma del provider vero**:
  /// la domanda e le letture gia' date, una per Maestro.
  String _materialeDellaSintesi(String theme, List<MaestroLens> lenses) {
    final b = StringBuffer('Domanda della persona: «${theme.trim()}».\n\n');
    for (final l in lenses) {
      b
        ..writeln('${l.maestro.displayName} (${l.maestro.domainArtsPhrase}):')
        ..writeln('- Colpo d\'occhio: ${l.glance.trim()}')
        ..writeln('- Lettura: ${l.reading.trim()}')
        ..writeln();
    }
    return b.toString();
  }

  @override
  Future<MemoryDigest?> distill({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory previous,
    required List<dynamic> history,
  }) async =>
      null;
}
