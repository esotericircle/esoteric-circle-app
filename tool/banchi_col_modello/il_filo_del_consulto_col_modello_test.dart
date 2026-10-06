// **SEI PERCORSI DEL CONSULTO, COL MODELLO VERO. Ordine FE voci 16, 17 e
// 18, 6 ottobre 2026.**
//
// Il fondatore, 5 ottobre 2026: *"bisogna rifare test e simulazioni su lavori
// che ho già chiesto più volte. Questa deve essere definitiva"*.
//
// Ogni percorso porta cinque temi a Gemini 2.5 Flash in europe-west1. Le
// istruzioni dei Maestri sono quelle VERE dell'app (`MaestroPersona`), e
// anche il filo (`IlFiloDelConsulto`), la frase ripresa (`LaFraseRipresa`),
// la finestra della storia e la misura della risposta sono quelli veri.
// Cambia solo il trasporto: REST invece di `firebase_ai`. Le reti che il
// controllore della chat passa sulla risposta (lessico, certezze) qui non
// girano: misurano la forma, non il filo.
//
// Poi un giudice, una seconda chiamata a Gemini, legge ogni consulto in
// sequenza con la regola scritta in [_regola] e dichiara per ogni risposta
// giudicata se CONTRADDICE, IGNORA o PORTA AVANTI ciò che è già stato detto.
// Soglia dell'ordine, FE voce 17: zero contraddizioni, e almeno nove risposte
// su dieci che portano avanti il punto.
//
// Si lancia col comando unico dei banchi, o a mano col token:
//
//     VERTEX_TOKEN=$(gcloud auth print-access-token) flutter test tool/banchi_col_modello/il_filo_del_consulto_col_modello_test.dart
//
// Ogni giro scrive i consulti interi, le risposte del giudice e il riepilogo
// in `docs/collaudo/banchi_col_modello/filo/<data e ora>/`, una cartella
// nuova per giro: il giro di ieri non si sovrascrive.
import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/la_risposta_che_chiede.dart';
import 'package:esoteric_circle/core/chat/la_rete_della_coerenza.dart';
import 'package:esoteric_circle/core/chat/il_filo_del_consulto.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/config/la_regione_dei_dati.dart';
import 'package:esoteric_circle/core/maestro/consiglio_finale.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/misura_della_risposta.dart';
import 'package:esoteric_circle/services/ai/firebase_maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_persona.dart';
import 'package:flutter_test/flutter_test.dart';

/// I cinque temi: domande che una persona fa davvero, su cui un Maestro dà un
/// parere che si può portare avanti o contraddire.
const _temi = [
  'Riceverò la promozione che aspetto al lavoro?',
  'Devo trasferirmi in un\'altra città per ricominciare?',
  'La mia relazione si è raffreddata: posso ancora salvarla?',
  'È il momento giusto per avviare il mio progetto creativo?',
  'Come faccio a fare pace con mia sorella dopo la lite?',
];

/// **LA REGOLA DEL GIUDICE.** La stessa che leggono a mano gli agenti che
/// tarano il giudice: il giudice di Gemini da solo non basta, misurato
/// nell'ordine EQ (fra il 67 e il 77 per cento d'accordo con la lettura a
/// mano).
const _regola = '''
Leggi un consulto fra una persona e una o più guide spirituali. Le risposte
sono numerate. Per ogni risposta segnata [DA GIUDICARE] dichiari una sola
delle tre parole, guardando SOLO le risposte delle guide che vengono prima.

CONTRADDICE: afferma il contrario di un consiglio, di un tempo o di un fatto
già dato in una risposta precedente, senza dire apertamente che cambia
parere e perché. Esempio: prima "aspetta la fine del mese", poi "muoviti
subito" senza spiegare il cambio. Una guida diversa che dice di vedere le
cose in un altro modo e lo dichiara apertamente ("io leggo diversamente")
NON contraddice: diverge dichiarandolo, e conta come PORTA_AVANTI se
riprende il punto prima di divergere.

IGNORA: la risposta non contraddice, ma risponde come se le risposte
precedenti non esistessero: apre un consiglio nuovo e scollegato, senza
riprendere né sviluppare il punto già dato, anche se la persona sta
continuando lo stesso discorso.

PORTA_AVANTI: riprende il consiglio o il punto già dato (anche con parole
diverse, anche in un solo inciso) e lo sviluppa, lo precisa, lo applica alla
nuova domanda o dice in che cosa concorda o diverge.

Se la persona cambia discorso di proposito, la risposta su un tema nuovo non
si giudica. Quando la persona torna al primo tema, la risposta si giudica
rispetto alle risposte sul primo tema.

Rispondi SOLO con un array JSON, un oggetto per risposta giudicata:
[{"n": 2, "verdetto": "PORTA_AVANTI", "perche": "una frase"}]
''';

void main() {
  final token = Platform.environment['VERTEX_TOKEN'] ?? '';
  _Token.valore = token;
  final cartella = Directory('docs/collaudo/banchi_col_modello/filo/'
      '${DateTime.now().toIso8601String().substring(0, 16).replaceAll(':', '')}');
  final conto = _Conto();

  setUpAll(() {
    // Il binding delle prove risponde 400 a ogni richiesta HTTP: il banco
    // parla con la rete vera.
    HttpOverrides.global = null;
    cartella.createSync(recursive: true);
  });

  tearDownAll(() {
    // Prezzi di gemini-2.5-flash dall'ordine DJ voce 03, in dollari per
    // milione di token; l'uscita comprende il ragionamento.
    final dollari = conto.ingresso * 0.30 / 1e6 + conto.uscita * 2.50 / 1e6;
    final riga = 'ORDINE FE VOCE 18, costo dei sei banchi: ${conto.chiamate} '
        'chiamate, ${conto.ingresso} token di ingresso, ${conto.uscita} di '
        'uscita col ragionamento, ${dollari.toStringAsFixed(3)} dollari a '
        'listino';
    // ignore: avoid_print
    print(riga);
    if (cartella.existsSync()) {
      File('${cartella.path}/costo.txt').writeAsStringSync('$riga\n');
    }
  });

  for (final percorso in _Percorso.values) {
    test(percorso.nome, () async {
      final consulti = <List<_Turno>>[];
      for (final (i, tema) in _temi.indexed) {
        for (final giro in percorso.giri(i)) {
          consulti.add(await giro.esegui(tema, conto));
        }
      }
      // Il giudice, un consulto alla volta.
      var giudicate = 0;
      var contraddice = 0;
      var ignora = 0;
      var portaAvanti = 0;
      final testo = StringBuffer();
      final colpe = <String>[];
      for (final (k, c) in consulti.indexed) {
        final verdetti = await _giudica(c, conto);
        testo.writeln('=== CONSULTO ${k + 1}');
        for (final (n, t) in c.indexed) {
          testo
            ..writeln('[${n + 1}] PERSONA: ${t.domanda}')
            ..writeln('[${n + 1}] ${t.maestro.displayName.toUpperCase()}'
                '${t.nelLive ? ' (a voce)' : ''}'
                '${t.corretta ? ' (corretta dalla rete)' : ''}'
                '${t.daGiudicare ? ' [DA GIUDICARE]' : ''}: ${t.risposta}');
          final v = verdetti[n + 1];
          if (!t.daGiudicare) continue;
          giudicate++;
          final verdetto = v?.$1 ?? 'NESSUN VERDETTO';
          testo.writeln('    GIUDICE: $verdetto, ${v?.$2 ?? ''}');
          switch (verdetto) {
            case 'CONTRADDICE':
              contraddice++;
              colpe.add('consulto ${k + 1}, risposta ${n + 1}: ${v?.$2}');
            case 'IGNORA':
              ignora++;
            case 'PORTA_AVANTI':
              portaAvanti++;
            default:
              colpe.add('consulto ${k + 1}, risposta ${n + 1}: il giudice '
                  'non ha dato un verdetto');
          }
        }
        testo.writeln();
      }
      // FE.14: i Maestri dopo il primo lo nominano?
      var secondi = 0;
      var nominano = 0;
      if (percorso == _Percorso.b) {
        for (final c in consulti) {
          for (final (n, t) in c.indexed) {
            if (n == 0) continue;
            secondi++;
            final prima = c.sublist(0, n).map((x) => x.maestro);
            if (prima.every((m) =>
                t.risposta.contains(m.displayName) ||
                t.risposta.contains(m.nomeAVideo))) {
              nominano++;
            }
          }
        }
      }
      final quota = giudicate == 0 ? 0.0 : portaAvanti / giudicate;
      final riepilogo = 'ORDINE FE VOCE 17, percorso '
          '${percorso.name.toUpperCase()}: giudicate $giudicate, porta '
          'avanti $portaAvanti, ignora $ignora, contraddice $contraddice, '
          'quota ${(quota * 100).toStringAsFixed(0)} per cento'
          '${percorso == _Percorso.b ? ', nominano tutti i Maestri di prima '
              'in $nominano risposte su $secondi' : ''}'
          ', corrette dalla rete della coerenza ${conto.correzioni}';
      // ignore: avoid_print
      print(riepilogo);
      testo.writeln(riepilogo);
      File('${cartella.path}/percorso_${percorso.name}.txt')
          .writeAsStringSync(testo.toString());
      expect(giudicate, greaterThanOrEqualTo(10),
          reason: 'meno di dieci risposte giudicate: la misura non vale');
      expect(contraddice, 0, reason: colpe.join('\n'));
      expect(quota, greaterThanOrEqualTo(0.9),
          reason: 'meno di nove risposte su dieci portano avanti il punto: '
              '$riepilogo');
    },
        skip: token.isEmpty
            ? 'Senza VERTEX_TOKEN il banco non chiama il modello'
            : false,
        timeout: const Timeout(Duration(minutes: 30)));
  }
}

/// I sei percorsi dell'ordine FE voce 16.
enum _Percorso {
  a('CON RETE: FE.16 A, tre domande di fila allo stesso Maestro sullo stesso tema'),
  b('CON RETE: FE.16 B, la stessa domanda a Medora, poi a Caligo, poi ad Aura'),
  c('CON RETE: FE.16 C, la persona riprende la frase che il Maestro le ha suggerito'),
  d('CON RETE: FE.16 D, una domanda, un tema diverso, poi il ritorno al primo tema'),
  e('CON RETE: FE.16 E, il consulto comincia scritto e continua a voce sullo stesso tema'),
  f('CON RETE: FE.16 F, il consulto si interrompe e riprende dopo dieci minuti');

  const _Percorso(this.nome);

  /// Il nome della prova, scritto per intero: il comando unico e la sua
  /// guardia lo cercano nel sorgente.
  final String nome;

  /// I consulti del tema [i]: due per il ritorno al tema, che ne giudica
  /// una sola risposta; uno per gli altri, che ne giudicano due.
  List<_Giro> giri(int i) {
    final m = Maestro.values[i % 3];
    final n = Maestro.values[(i + 1) % 3];
    return switch (this) {
      _Percorso.d => [_Giro(this, m), _Giro(this, n)],
      _ => [_Giro(this, m)],
    };
  }
}

class _Turno {
  _Turno(this.maestro, this.domanda, this.risposta,
      {this.daGiudicare = false, this.nelLive = false, this.corretta = false});
  final Maestro maestro;
  final String domanda;
  final String risposta;
  final bool daGiudicare;
  final bool nelLive;

  /// Corretta dalla rete della coerenza: si scrive nel resoconto, mai nel
  /// consulto che legge il giudice.
  final bool corretta;
}

class _Giro {
  _Giro(this.percorso, this.maestro);
  final _Percorso percorso;
  final Maestro maestro;

  Future<List<_Turno>> esegui(String tema, _Conto conto) async {
    var ora = DateTime(2026, 10, 6, 10);
    IlFiloDelConsulto.dimentica();
    IlFiloDelConsulto.adesso = () => ora;
    final turni = <_Turno>[];
    // La storia della conversazione aperta, come la tiene il controllore.
    var storia = <ChatMessage>[];

    Future<String> chiedi(Maestro chi, String domanda,
        {bool nelLive = false, bool giudica = false}) async {
      final finestra = storia.length > FirebaseMaestroAiProvider.kHistoryWindow
          ? storia
              .sublist(storia.length - FirebaseMaestroAiProvider.kHistoryWindow)
          : storia;
      final istruzione = MaestroPersona.systemInstruction(
        maestro: chi,
        profile: UserProfile.empty,
        memory: MaestroMemory.empty,
        primaRisposta: !storia.any((m) => m.isMaestro),
        testiGiaDetti: [
          for (final m in storia)
            if (m.isMaestro) m.text
        ],
        nelLive: nelLive,
        scrittoPrima:
            FirebaseMaestroAiProvider.scrittoPrimaDellaFinestra(storia),
        // Come il provider dall'ordine FE voce 11: la frase si cerca in
        // tutto il consulto, non nella sola ultima risposta.
        filo: IlFiloDelConsulto.bloccoPer(chi,
            storia: finestra,
            fraseRipresa: LaFraseRipresa.fraTutte(
                domanda, LaFraseRipresa.testiDelConsulto(storia))),
      );
      var corretta = false;
      Future<String> unaRisposta() => _vertex(
            modello:
                FirebaseMaestroAiProvider.modelloDelTurno(nelLive: nelLive),
            istruzione: istruzione,
            storia: finestra,
            domanda: domanda,
            misura: MisuraDellaRisposta.perIlTurno(nelLive: nelLive),
            conto: conto,
          );
      // **IL MARCATORE DEL CHIARIMENTO, come nel controllore.** Il prodotto
      // lo toglie e, se resta una risposta vuota, la chiede di nuovo
      // (ordini EI voce 02 ed ET voce 01): al banco del percorso E Medora
      // rispondeva il solo "[[CHIEDO]]", e il giudice lo contava come una
      // risposta che ignora il punto.
      var risposta = LaRispostaCheChiede.senzaIlMarcatore(await unaRisposta());
      if (risposta.trim().isEmpty) {
        risposta = LaRispostaCheChiede.senzaIlMarcatore(await unaRisposta());
      }
      // **LA RETE DELLA COERENZA, come nel controllore.** Ordine FE voci 10
      // e 17: la stessa funzione di `lib`, con Flash-Lite e la correzione
      // corta del provider (`correggi`).
      final correzione = await LaReteDellaCoerenza.controlla(
        chi: chi,
        storia: storia,
        risposta: risposta,
        chiamata: (istr, testo) => _vertex(
          modello: LaReteDellaCoerenza.modello,
          istruzione: istr,
          storia: const [],
          domanda: testo,
          misura: MisuraDellaRisposta.letturaBreve,
          temperatura: 0,
          json: true,
          conto: conto,
        ),
      );
      if (correzione != null) {
        conto.correzioni++;
        corretta = true;
        risposta = await _vertex(
          modello: FirebaseMaestroAiProvider.modelloDelTurno(nelLive: nelLive),
          istruzione: MaestroPersona.istruzioneDellaCorrezione(
            maestro: chi,
            profile: UserProfile.empty,
            correzione: correzione,
            nelLive: nelLive,
          ),
          storia: const [],
          domanda: 'LA DOMANDA DELLA PERSONA:\n$domanda\n\n'
              'LA TUA RISPOSTA DA CORREGGERE:\n$risposta',
          misura: MisuraDellaRisposta.perIlTurno(nelLive: nelLive),
          conto: conto,
        );
      }
      storia = [
        ...storia,
        ChatMessage(role: ChatRole.user, text: domanda, at: ora),
        ChatMessage(
            role: ChatRole.maestro, text: risposta, at: ora, autore: chi),
      ];
      IlFiloDelConsulto.annota(
          maestro: chi, domanda: domanda, risposta: risposta);
      turni.add(_Turno(chi, domanda, risposta,
          daGiudicare: giudica, nelLive: nelLive, corretta: corretta));
      ora = ora.add(const Duration(minutes: 2));
      return risposta;
    }

    /// La frase che il Maestro suggerisce: la riga col consiglio, o l'ultima
    /// frase della risposta.
    String suggerita(String r) {
      final riga = ConsiglioFinale.sintesiDa(r);
      if (riga != null) {
        return riga.replaceAll(ConsiglioFinale.stella, '').trim();
      }
      final frasi = ConsiglioFinale.corpoDa(r)
          .split(RegExp(r'(?<=[.!?])\s+'))
          .where((f) => f.trim().isNotEmpty)
          .toList();
      return frasi.isEmpty ? r.trim() : frasi.last.trim();
    }

    switch (percorso) {
      case _Percorso.a:
        await chiedi(maestro, tema);
        await chiedi(maestro, 'E in pratica, cosa faccio questa settimana?',
            giudica: true);
        await chiedi(maestro, 'E se le cose non vanno come speri?',
            giudica: true);
      case _Percorso.b:
        // Ogni Maestro in una chat sua: riceve la scheda, non i turni.
        await chiedi(Maestro.medora, tema);
        storia = [];
        await chiedi(Maestro.caligo, tema, giudica: true);
        storia = [];
        await chiedi(Maestro.aura, tema, giudica: true);
      case _Percorso.c:
        final r1 = await chiedi(maestro, tema);
        final r2 = await chiedi(maestro, suggerita(r1), giudica: true);
        await chiedi(maestro, suggerita(r2), giudica: true);
      case _Percorso.d:
        await chiedi(maestro, tema);
        await chiedi(maestro,
            'Cambiando discorso: che cristallo mi consigli per dormire meglio?');
        await chiedi(maestro,
            'Torniamo alla mia prima domanda. Allora, cosa mi consigli di fare?',
            giudica: true);
      case _Percorso.e:
        await chiedi(maestro, tema);
        await chiedi(maestro, 'E quindi, cosa devo fare adesso?',
            nelLive: true, giudica: true);
        await chiedi(maestro, 'E quando lo capirò?',
            nelLive: true, giudica: true);
      case _Percorso.f:
        await chiedi(maestro, tema);
        await chiedi(maestro, 'E cosa devo evitare?', giudica: true);
        // Dieci minuti dopo la chat si riapre vuota a schermo, ma il
        // Maestro riceve le battute di prima (FE.12) e la scheda.
        ora = ora.add(const Duration(minutes: 10));
        await chiedi(maestro,
            'Eccomi di nuovo, ci ho pensato. Da dove comincio, allora?',
            giudica: true);
    }
    return turni;
  }
}

/// Il giudice: il consulto in sequenza, i verdetti per numero di risposta.
Future<Map<int, (String, String)>> _giudica(
    List<_Turno> c, _Conto conto) async {
  final consulto = StringBuffer();
  for (final (n, t) in c.indexed) {
    consulto
      ..writeln('[${n + 1}] PERSONA: ${t.domanda}')
      ..writeln('[${n + 1}] GUIDA ${t.maestro.displayName.toUpperCase()}'
          '${t.daGiudicare ? ' [DA GIUDICARE]' : ''}: ${t.risposta}')
      ..writeln();
  }
  final grezzo = await _vertex(
    modello: FirebaseMaestroAiProvider.kMaestroChatModel,
    istruzione: _regola,
    storia: const [],
    domanda: consulto.toString(),
    tetto: 1600,
    ragionamento: 512,
    temperatura: 0,
    json: true,
    conto: conto,
  );
  final verdetti = <int, (String, String)>{};
  await _leggi(grezzo, verdetti);
  // **LA SECONDA LETTURA DELLE CONTRADDIZIONI. Ordine FE voce 17.** Alla
  // taratura (docs/collaudo/FE/taratura_del_giudice/) delle 9 contraddizioni
  // segnate dal giudice nei giri delle 01:43 e 01:49, 3 non le ha confermate
  // nessuno dei due lettori alla cieca. Una contraddizione conta solo se una
  // seconda lettura mirata, con la stessa regola, la conferma; altrimenti vale
  // il verdetto della seconda lettura. La soglia resta zero.
  for (final n in [
    for (final e in verdetti.entries)
      if (e.value.$1 == 'CONTRADDICE') e.key
  ]) {
    final seconda = await _vertex(
      modello: FirebaseMaestroAiProvider.kMaestroChatModel,
      istruzione: _regola,
      storia: const [],
      domanda: "${consulto}Una prima lettura dice che la risposta [$n] "
          "CONTRADDICE, perché: ${verdetti[n]!.$2}\n"
          "Rileggi solo la risposta [$n] contro le risposte delle guide che "
          "vengono prima. Conferma CONTRADDICE solo se un consiglio, un tempo "
          "o una risposta sono davvero opposti a quelli già dati e il cambio "
          "non è dichiarato; un passo successivo o una precisazione non lo "
          "sono. Rispondi con l'array JSON di un solo oggetto, per la "
          "risposta $n.",
      tetto: 800,
      ragionamento: 512,
      temperatura: 0,
      json: true,
      conto: conto,
    );
    final riletta = <int, (String, String)>{};
    await _leggi(seconda, riletta);
    final v = riletta[n];
    if (v != null && v.$1 != 'CONTRADDICE') {
      verdetti[n] = (v.$1, 'seconda lettura: ${v.$2}');
    }
  }
  return verdetti;
}

/// Legge l'array JSON del giudice in [verdetti].
Future<void> _leggi(String grezzo, Map<int, (String, String)> verdetti) async {
  try {
    final inizio = grezzo.indexOf('[');
    final fine = grezzo.lastIndexOf(']');
    final lista = jsonDecode(grezzo.substring(inizio, fine + 1)) as List;
    for (final v in lista) {
      final m = v as Map;
      verdetti[(m['n'] as num).toInt()] =
          ('${m['verdetto']}'.trim().toUpperCase(), '${m['perche'] ?? ''}');
    }
  } catch (_) {
    // Un giudizio illeggibile lascia le risposte senza verdetto, e il banco
    // le conta come colpe: non come portate avanti.
  }
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

  /// Le risposte corrette dalla rete della coerenza (ordine FE voci 10 e
  /// 17), come nel controllore della chat.
  int correzioni = 0;
}

/// La chiamata vera a Vertex in europe-west1, con la misura dell'app. Riprova
/// fino a cinque volte su 429 e 503, con attese da due a trentadue secondi.
Future<String> _vertex({
  required String modello,
  required String istruzione,
  required List<ChatMessage> storia,
  required String domanda,
  required _Conto conto,
  MisuraDellaRisposta? misura,
  int? tetto,
  int? ragionamento,
  double temperatura = 0.9,
  bool json = false,
}) async {
  const regione = LaRegioneDeiDati.regione;
  final url = Uri.parse('https://$regione-aiplatform.googleapis.com/v1/'
      'projects/esoteric-circle/locations/$regione/publishers/google/models/'
      '$modello:generateContent');
  final corpo = {
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
      'temperature': temperatura,
      if (!json) 'topP': 0.95,
      'maxOutputTokens': tetto ?? misura!.tetto,
      if (json) 'responseMimeType': 'application/json',
      'thinkingConfig': {
        'thinkingBudget': ragionamento ?? misura!.ragionamento
      },
    },
  };
  final client = HttpClient();
  try {
    Future<(int, String)> chiama() async {
      final req = await client.postUrl(url);
      req.headers.set('Authorization', 'Bearer ${_Token.valore}');
      req.headers.contentType = ContentType.json;
      req.add(utf8.encode(jsonEncode(corpo)));
      final res = await req.close();
      return (res.statusCode, await res.transform(utf8.decoder).join());
    }

    var attesa = 2;
    while (true) {
      conto.chiamate++;
      var (stato, testo) = await chiama();
      if (stato == 401) {
        await _Token.rinnova();
        (stato, testo) = await chiama();
      }
      if ((stato == 429 || stato == 503) && attesa <= 32) {
        await Future<void>.delayed(Duration(seconds: attesa));
        attesa *= 2;
        continue;
      }
      if (stato != 200) throw HttpException('Vertex $stato: $testo');
      final j = jsonDecode(testo) as Map<String, dynamic>;
      final uso = (j['usageMetadata'] as Map?) ?? const {};
      conto.ingresso += (uso['promptTokenCount'] as int?) ?? 0;
      conto.uscita += ((uso['candidatesTokenCount'] as int?) ?? 0) +
          ((uso['thoughtsTokenCount'] as int?) ?? 0);
      final parti = ((j['candidates'] as List?)?.firstOrNull
          as Map?)?['content']?['parts'] as List?;
      return [
        for (final p in parti ?? const [])
          if ((p as Map)['thought'] != true) '${p['text'] ?? ''}'
      ].join().trim();
    }
  } finally {
    client.close();
  }
}
