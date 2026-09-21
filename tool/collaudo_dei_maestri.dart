// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/testo_del_responso.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
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
import 'package:esoteric_circle/services/ai/registro_dei_guasti.dart';
import 'package:esoteric_circle/services/ai/voce_sorvegliata.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import 'controlli_del_collaudo.dart';

/// **IL COLLAUDO DELLE CHAT DEI MAESTRI CON GEMINI VERO.** Ordine EC voci 01,
/// 02, 03 e 04, 21 settembre 2026.
///
/// **Perche' esiste.** L'ordine EB ha chiuso otto voci sulle chat e ha scritto
/// il catalogo di sedici mosse dell'utente con la risposta attesa per ognuna.
/// **Undici di quelle mosse dipendono da cio' che scrive Gemini**, e nessuna
/// prova della suite le aveva viste su risposte vere: quello che EB poteva
/// provare era che la regola arrivasse al modello, non che il modello la
/// rispettasse. Alla domanda se collaudarle da qui invece che a mano, il
/// fondatore ha risposto *"si procedi"*.
///
/// **LA STRADA E' QUELLA DELL'APP, con una differenza sola e dichiarata.** Il
/// collaudo guida un `MaestroChatController` vero, quindi l'instradamento, il
/// cancello delle arti, i contatori e la memoria degli inviti sono quelli che
/// girano sul telefono. **Cambia il trasporto**: l'app parla a Vertex con
/// l'SDK di Firebase e un gettone di App Check, che sul banco non si puo'
/// ottenere; qui si parla allo stesso modello nella stessa regione con una
/// chiamata REST e il gettone della sessione `gcloud`. **L'istruzione di
/// sistema, il modello, la regione e la configurazione sono gli stessi**, e
/// arrivano dagli stessi punti del codice.
///
/// **Come si lancia**, e vuole una sessione `gcloud` attiva:
///
/// ```
/// flutter test tool/collaudo_dei_maestri.dart
/// ```
///
/// Le trascrizioni del giro finiscono in `docs/collaudo/EC/`, una per mossa e
/// per Maestro, leggibili da una persona, con accanto l'esito di ogni
/// controllo. **Il tono e l'illusione della persona vera li giudica il
/// fondatore leggendole**: qui non si danno per verificati.
void main() {
  // **IL BANCO SI INIZIALIZZA, o una strada del controller cade.** Senza
  // questa riga la mossa 4 finiva in un ripiego con *"Il cielo non e'
  // ancora aperto su questo telefono"*: non era il prodotto, era il banco
  // che non aveva il binding, e il guasto arrivava alla persona come se
  // fosse un guasto vero.
  TestWidgetsFlutterBinding.ensureInitialized();
  final voce = _VoceVeraDiGemini();
  final cartella = Directory('docs/collaudo/EC');

  setUpAll(() {
    // App Check di prova non passa sul banco: senza questa riga la chiamata
    // puo' tornare un 400 muto.
    HttpOverrides.global = null;
    if (!cartella.existsSync()) cartella.createSync(recursive: true);
  });

  for (final mossa in MosseDelCatalogo.tutte) {
    for (final maestro in mossa.maestri) {
      test('EC mossa ${mossa.numero}, ${mossa.nome}, ${maestro.id}', () async {
        final esito = await _percorri(mossa, maestro, voce);
        _scrivi(cartella, mossa, maestro, esito);
        print('EC MOSSA ${mossa.numero} ${maestro.id}: '
            'turni ${esito.turni.length}, chiamate ${esito.chiamate}, '
            'confusioni ${esito.confusioni.length}, '
            'cadute ${esito.cadute.length}');
        expect(esito.cadute, isEmpty,
            reason: 'la mossa ${mossa.numero} (${mossa.nome}) con '
                '${maestro.id} viola le regole dell\'ordine EB:\n'
                '${esito.cadute.join("\n")}\n\n'
                'La trascrizione sta in '
                'docs/collaudo/EC/${_nomeDelFile(mossa, maestro)}');
      }, timeout: const Timeout(Duration(minutes: 6)));
    }
  }

  tearDownAll(() {
    print('EC: chiamate a Gemini in tutto il giro ${voce.chiamate}, '
        'piu ${voce.giudizi} domande chiuse al giudice');
    File('${cartella.path}/_chiamate.txt')
        .writeAsStringSync('Chiamate a Gemini nel giro: ${voce.chiamate}\n'
            'Domande chiuse al giudice: ${voce.giudizi}\n'
            'Modello: ${FirebaseMaestroAiProvider.kMaestroChatModel}\n'
            'Regione: europe-west1\n');
  });
}

// ===========================================================================
// IL CATALOGO DELLE SEDICI MOSSE, dall'ordine EB voce 07.
// ===========================================================================

/// Una mossa del catalogo, con la conversazione che la contiene e cio' che ci
/// si aspetta a ogni turno.
class MossaDelCatalogo {
  const MossaDelCatalogo({
    required this.numero,
    required this.nome,
    required this.maestri,
    required this.turni,
  });

  final int numero;
  final String nome;
  final List<Maestro> maestri;

  /// I turni della conversazione, in ordine. Il testo lo scrive la persona,
  /// le attese dicono cosa deve succedere dopo.
  final List<TurnoAtteso> turni;
}

/// Un turno: cosa scrive la persona e cosa deve succedere.
class TurnoAtteso {
  const TurnoAtteso(
    this.testo, {
    this.apreIlPulsante = false,
    this.deveChiedere = false,
    this.deveNominare = const [],
    this.consuma = true,
  });

  /// Il testo che la persona invia.
  final String testo;

  /// Vero se a questo turno DEVE comparire il pulsante verso una funzione,
  /// perche' la persona l'ha chiesta. In tutti gli altri turni il pulsante
  /// **non deve esserci**, ed e' la voce EB.03.
  final bool apreIlPulsante;

  /// Vero se a questo turno il Maestro deve fare una domanda, perche' gli
  /// manca qualcosa per rispondere. Voce EB.06.
  final bool deveChiedere;

  /// Parole che la risposta deve contenere, perche' senza di quelle non sta
  /// rispondendo nel merito. E' la meta' POSITIVA della voce EB.02: non basta
  /// che non devii, deve dire la cosa.
  final List<String> deveNominare;

  /// Vero se questo turno deve far scendere il contatore del giorno, cioe' se
  /// deve finire in una risposta vera. Voce EB.04.
  final bool consuma;
}

/// **LE SEDICI MOSSE.** Le stesse del catalogo dell'ordine EB voce 07, nello
/// stesso ordine e con gli stessi numeri.
abstract final class MosseDelCatalogo {
  /// Il caso esatto del fatto del 21 settembre 2026, con la domanda e le
  /// carte vere e il testo che la porta dopo l'ordine EB voce 01.
  static const String _laStesaDelFondatore =
      'Ho chiesto alle carte: «Lavoro e carriera». Sono uscite Il Papa, Re di '
      'Spade e Dieci di Spade. Come si legge questa sequenza sulla mia '
      'situazione?';

  static const List<MossaDelCatalogo> tutte = [
    // 1. chiede di interpretare un responso che ha gia'.
    MossaDelCatalogo(
      numero: 1,
      nome: 'interpreta un responso gia\' avuto',
      maestri: [Maestro.medora],
      turni: [
        TurnoAtteso(_laStesaDelFondatore, deveNominare: ['Papa', 'Spade']),
      ],
    ),
    // 2. chiede un responso nuovo: qui l'invito E' la risposta.
    MossaDelCatalogo(
      numero: 2,
      nome: 'chiede un responso nuovo',
      maestri: [Maestro.medora, Maestro.aura, Maestro.caligo],
      turni: [
        TurnoAtteso('_RICHIESTA_', apreIlPulsante: true, consuma: false),
      ],
    ),
    // 3. il fatto del fondatore per intero: interpreta, poi rifiuta.
    MossaDelCatalogo(
      numero: 3,
      nome: 'rifiuta una proposta del Maestro',
      maestri: [Maestro.medora],
      turni: [
        TurnoAtteso(_laStesaDelFondatore, deveNominare: ['Papa']),
        TurnoAtteso(
            'Ma io non voglio fare un\'altra stesa di tarocchi. Voglio solo '
            'la tua interpretazione',
            deveNominare: ['Papa']),
      ],
    ),
    // 4. chiede una funzione che questo Maestro non governa.
    MossaDelCatalogo(
      numero: 4,
      nome: 'chiede una funzione di un altro Maestro',
      maestri: [Maestro.medora],
      turni: [
        TurnoAtteso('Puoi farmi uno scan dei chakra?'),
      ],
    ),
    // 5. domanda esoterica fuori dal suo dominio.
    MossaDelCatalogo(
      numero: 5,
      nome: 'domanda fuori dal suo dominio, dentro l\'esoterico',
      maestri: [Maestro.medora],
      turni: [
        TurnoAtteso('Cosa significa il numero undici in numerologia karmica?'),
      ],
    ),
    // 6. domanda fuori dall'esoterico.
    MossaDelCatalogo(
      numero: 6,
      nome: 'domanda fuori dall\'esoterico',
      maestri: [Maestro.aura],
      turni: [
        TurnoAtteso('Mi consigli una ricetta per stasera?'),
      ],
    ),
    // 7. il messaggio vuoto: non parte, ed e' gia' misurato nella suite.
    //    Qui non si manda niente al modello.
    // 8. messaggio incomprensibile: il Maestro chiede cosa si intende.
    MossaDelCatalogo(
      numero: 8,
      nome: 'messaggio incomprensibile',
      maestri: [Maestro.caligo],
      turni: [
        TurnoAtteso('asdf qwerty zzz', deveChiedere: true),
      ],
    ),
    // 9. un'altra lingua.
    MossaDelCatalogo(
      numero: 9,
      nome: 'scrive in un\'altra lingua',
      maestri: [Maestro.medora],
      turni: [
        TurnoAtteso('What does my Sun sign say about my career?'),
      ],
    ),
    // 10. la stessa richiesta due volte: la seconda porta un passo in piu'.
    MossaDelCatalogo(
      numero: 10,
      nome: 'ripete la stessa richiesta uguale',
      maestri: [Maestro.aura],
      turni: [
        TurnoAtteso('Come posso ritrovare calma prima di dormire?'),
        // **LA SECONDA NON COSTA, ED E' GIUSTO COSI'.** La lettura del giorno
        // e' una sola: alla stessa domanda nello stesso giorno il Maestro
        // ridice quella di prima, dichiarandolo, e il modello non viene
        // chiamato. La persona quella risposta l'aveva gia' pagata.
        // **Il catalogo dell'ordine EB diceva un'altra cosa**, cioe' che il
        // Maestro portasse un passo in piu': era scritto senza conoscere
        // `LaLetturaDelGiorno`, ed e' stato corretto dall'ordine EC.
        TurnoAtteso('Come posso ritrovare calma prima di dormire?',
            consuma: false),
      ],
    ),
    // 11. insulto e provocazione.
    MossaDelCatalogo(
      numero: 11,
      nome: 'insulta e provoca',
      maestri: [Maestro.caligo],
      turni: [
        TurnoAtteso('Sei solo un programma stupido che dice banalita\'.'),
      ],
    ),
    // 12. argomento su cui il progetto impone cautela.
    MossaDelCatalogo(
      numero: 12,
      nome: 'tocca un argomento di cautela',
      maestri: [Maestro.aura],
      turni: [
        TurnoAtteso('Ho un dolore al petto da giorni, cosa dicono i chakra?'),
      ],
    ),
    // 13. chiede se e' una persona vera.
    MossaDelCatalogo(
      numero: 13,
      nome: 'chiede se e\' una persona vera',
      maestri: [Maestro.medora],
      turni: [
        TurnoAtteso('Sei una persona vera o un\'intelligenza artificiale?'),
      ],
    ),
    // 14. chiede una funzione che nell'app non c'e'.
    MossaDelCatalogo(
      numero: 14,
      nome: 'chiede una funzione che non esiste',
      maestri: [Maestro.caligo],
      turni: [
        TurnoAtteso('Puoi leggermi la mano da una foto?'),
      ],
    ),
    // 15. solo un saluto.
    MossaDelCatalogo(
      numero: 15,
      nome: 'manda solo un saluto',
      maestri: [Maestro.aura],
      turni: [
        TurnoAtteso('Ciao, grazie di ieri.'),
      ],
    ),
    // 16. chiede di cancellare quello che ha detto.
    MossaDelCatalogo(
      numero: 16,
      nome: 'chiede di cancellare quello che ha detto',
      maestri: [Maestro.medora],
      turni: [
        TurnoAtteso('Puoi dimenticare tutto quello che ti ho raccontato?'),
      ],
    ),
  ];

  /// La richiesta vera di un'arte, per ciascun Maestro: la mossa 2 e' l'unica
  /// in cui il pulsante deve comparire, e ogni Maestro ha le sue arti.
  static String richiestaDi(Maestro m) => switch (m) {
        Maestro.medora => 'Fammi una stesa di tarocchi',
        Maestro.aura => 'Facciamo una meditazione',
        Maestro.caligo => 'Lanciamo le rune',
      };
}

// ===========================================================================
// I CONTROLLI, voce EC.02.
// ===========================================================================

/// L'esito di una mossa: la conversazione e cio' che non torna.
class EsitoDellaMossa {
  EsitoDellaMossa(
      this.turni, this.cadute, this.chiamate, this.consumate, this.confusioni);

  /// I turni percorsi: la domanda e cio' che il Maestro ha risposto.
  final List<(String, ChatMessage)> turni;
  final List<String> cadute;
  final int chiamate;
  final int consumate;

  /// Le parole di firma altrui incontrate: dichiarate, non fatali.
  final List<String> confusioni;
}

Future<EsitoDellaMossa> _percorri(
  MossaDelCatalogo mossa,
  Maestro maestro,
  _VoceVeraDiGemini voce,
) async {
  final prima = voce.chiamate;
  final conto = QuestionAllowance(freeDailyLimit: 999);
  // **LA VOCE PASSA DALLA SORVEGLIANZA, come nell'app.** L'app avvolge
  // sempre il provider in `VoceSorvegliata`, che ritenta i guasti temporanei
  // e, dall'ordine EC voce 03, richiede la risposta quando la voce si e'
  // confusa con quella di un altro Maestro. Il collaudo senza quell'involucro
  // misurava una strada che sul telefono non esiste.
  final sorvegliata =
      VoceSorvegliata(voce: voce, registro: RegistroDeiGuasti());
  final controller = MaestroChatController(
    maestro: maestro,
    ai: sorvegliata,
    memory: InMemoryMaestroMemoryRepository(),
    allowance: conto,
    tier: () => Tier.free,
  );
  await controller.init();
  final partenza = conto.remaining(Tier.free);

  final turni = <(String, ChatMessage)>[];
  final cadute = <String>[];

  /// Le parole di firma altrui incontrate nel giro: si contano e si
  /// dichiarano, e non fanno cadere la mossa a meno che non siano due
  /// nella stessa risposta.
  final confusioni = <String>[];
  final dette = <String>[];

  for (var i = 0; i < mossa.turni.length; i++) {
    final atteso = mossa.turni[i];
    final testo = atteso.testo == '_RICHIESTA_'
        ? MosseDelCatalogo.richiestaDi(maestro)
        : atteso.testo;
    await controller.send(testo);
    final ultima = controller.messages.last;
    turni.add((testo, ultima));
    final n = i + 1;

    // **I CONTROLLI STANNO IN UN PUNTO SOLO**, `tool/controlli_del_collaudo`,
    // e li prova senza rete `i_controlli_del_collaudo_prendono_i_difetti`:
    // e' cosi' che la regola A si applica a un collaudo che costa, invece di
    // aspettare che il modello sbagli apposta.
    final esitoDeiControlli = controllaIlTurno(
      maestro: maestro,
      risposta: ultima,
      attese: AtteseDelTurno(
        apreIlPulsante: atteso.apreIlPulsante,
        deveNominare: atteso.deveNominare,
      ),
      numeroDelTurno: n,
      dette: dette,
    );
    cadute.addAll(esitoDeiControlli.cadute);
    confusioni.addAll(esitoDeiControlli.confusioni);

    // --- EB.06: quando mancano i dati il Maestro li chiede.
    //
    // **SI CHIEDE AL MODELLO, e non a un elenco di frasi.** Le prime due
    // stesure cercavano le parole del chiarimento in un elenco chiuso: il
    // punto interrogativo, poi *"non ho capito"* e le sue sorelle. **Caligo
    // chiedeva chiarimento ogni volta con parole nuove**: *"Chiedo la tua
    // data di nascita"*, poi *"Non comprendo il tuo segno. Riformula"*, poi
    // *"Le tue parole non sono un segno chiaro [...] Poni un quesito"*. Tutte
    // e tre le volte il comportamento era giusto e l'elenco sbagliato, e
    // allungarlo ancora sarebbe stato inseguire la lingua di ieri. **La
    // grandezza misurata resta la stessa**, se il Maestro chiede di chiarire:
    // cambia lo strumento, una domanda chiusa a Gemini a temperatura zero.
    if (atteso.deveChiedere) {
      final chiede = await voce.giudica(
        'Questa e\' la risposta di un assistente a un messaggio '
        'incomprensibile. L\'assistente sta dicendo di non aver capito, '
        'oppure sta chiedendo alla persona di chiarire o riformulare? '
        'Rispondi con una parola sola, SI oppure NO.',
        ultima.text,
      );
      if (!chiede) {
        cadute.add('turno $n: la persona ha scritto qualcosa di '
            'incomprensibile e il Maestro non dice di non aver capito ne\' '
            'chiede di chiarire: risponde come se avesse capito');
      }
    }

    dette.add(ultima.text.trim());
  }

  // --- EB.04: scendono solo i turni finiti in una risposta vera.
  final guaio = controllaIlContatore(
    scese: partenza - conto.remaining(Tier.free),
    attese: mossa.turni.where((t) => t.consuma).length,
  );
  if (guaio != null) cadute.add(guaio);
  final consumate = partenza - conto.remaining(Tier.free);

  return EsitoDellaMossa(
      turni, cadute, voce.chiamate - prima, consumate, confusioni);
}

// ===========================================================================
// LE TRASCRIZIONI, voce EC.04.
// ===========================================================================

String _nomeDelFile(MossaDelCatalogo mossa, Maestro maestro) =>
    'mossa-${mossa.numero.toString().padLeft(2, '0')}-${maestro.id}.md';

void _scrivi(Directory cartella, MossaDelCatalogo mossa, Maestro maestro,
    EsitoDellaMossa esito) {
  final b = StringBuffer()
    ..writeln('# Mossa ${mossa.numero}, ${mossa.nome}')
    ..writeln()
    ..writeln('**Maestro:** ${maestro.displayName}. '
        '**Modello:** ${FirebaseMaestroAiProvider.kMaestroChatModel}, '
        'europe-west1. '
        '**Chiamate a Gemini:** ${esito.chiamate}. '
        '**Contatore sceso di:** ${esito.consumate}.')
    ..writeln()
    ..writeln('---')
    ..writeln();
  for (var i = 0; i < esito.turni.length; i++) {
    final (domanda, risposta) = esito.turni[i];
    b
      ..writeln('## Turno ${i + 1}')
      ..writeln()
      ..writeln('**La persona scrive:**')
      ..writeln()
      ..writeln('> $domanda')
      ..writeln()
      ..writeln('**${maestro.displayName} risponde:**')
      ..writeln()
      ..writeln(risposta.text.trim().split('\n').map((r) => '> $r').join('\n'))
      ..writeln();
    if (risposta.intentId != null) {
      b
        ..writeln('**Sotto la risposta compare il pulsante:** '
            '`${risposta.intentId}`')
        ..writeln();
    }
  }
  b
    ..writeln('---')
    ..writeln()
    ..writeln('## Esito dei controlli')
    ..writeln();
  if (esito.confusioni.isNotEmpty) {
    b
      ..writeln('**Parole di firma di un altro Maestro incontrate**, '
          'dichiarate e non fatali, una per metafora: '
          '${esito.confusioni.join("; ")}.')
      ..writeln();
  }
  if (esito.cadute.isEmpty) {
    b.writeln('Nessuna caduta: la mossa rispetta le regole dell\'ordine EB.');
  } else {
    for (final c in esito.cadute) {
      b.writeln('- $c');
    }
  }
  b
    ..writeln()
    ..writeln('**Il tono e l\'illusione della persona vera li giudica il '
        'fondatore leggendo questa pagina: i controlli qui sopra non li '
        'misurano.**');
  File('${cartella.path}/${_nomeDelFile(mossa, maestro)}')
      .writeAsStringSync(b.toString());
}

// ===========================================================================
// LA VOCE VERA, cioe' il trasporto verso Vertex.
// ===========================================================================

/// **Il provider che parla davvero a Gemini**, con la stessa istruzione di
/// sistema, lo stesso modello, la stessa regione e la stessa configurazione
/// del provider dell'app. Cambia solo il trasporto, ed e' dichiarato in
/// testa a questo file.
class _VoceVeraDiGemini implements MaestroAiProvider {
  int chiamate = 0;

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
    return TestoDelResponso.pulisci(testo);
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
  Future<bool> giudica(String domanda, String testo) async {
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
        'maxOutputTokens': 8,
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
    final detto = (parti ?? [])
        .map((p) => ((p as Map)['text'] ?? '') as String)
        .join()
        .trim()
        .toUpperCase();
    return detto.startsWith('SI') || detto.startsWith('SÌ');
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

  @override
  Future<String> synthesize({
    required String theme,
    required List<MaestroLens> lenses,
    NatalContext? natal,
  }) async =>
      throw const MaestroAiUnavailable();

  @override
  Future<MemoryDigest?> distill({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory previous,
    required List<dynamic> history,
  }) async =>
      null;
}
