import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/corpus_neutro.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/misura_della_risposta.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/maestro/tempi_dell_attesa.dart';
import 'package:esoteric_circle/services/ai/firebase_maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_persona.dart';
import 'package:flutter_test/flutter_test.dart';

/// LA MISURA DELLE RISPOSTE INTERE: quante parole, e quante si fermano al muro.
///
/// **Non e' nella suite, ed e' voluto**, per la stessa ragione di
/// `attribuzione_cieca.dart`: costa chiamate vere a Gemini. `flutter test`
/// guarda solo `test/`, quindi da qui non parte mai da solo.
///
/// ```
/// flutter test tool/risposte_intere.dart
/// ```
///
/// **Cosa misura.** Pone le venti domande neutre di [CorpusNeutro] con le
/// istruzioni di sistema VERE dell'app e la configurazione VERA del provider,
/// tetto e ragionamento presi dalla stessa [MisuraDellaRisposta] che usa la
/// chat. Per ciascuna riporta il `finishReason` grezzo, le parole prodotte e i
/// token del ragionamento.
///
/// **La riga che conta e' una sola: quante risposte si sono fermate al muro.**
/// Deve essere ZERO. Il 2 agosto 2026, prima di questo lavoro, la stessa
/// chiamata dava `finishReason: MAX_TOKENS` con `thoughtsTokenCount: 150` su un
/// tetto di 160 e sei token di testo, cioe' quattro parole a video.
void main() {
  const progetto = 'esoteric-circle';
  const regione = 'europe-west1';
  const insieme = 5;

  test('Venti risposte vere, e nessuna tronca', () async {
    final gettone = await _gettone();
    if (gettone == null) {
      fail('Nessun gettone di accesso. Serve una sessione gcloud attiva: '
          'gcloud auth login');
    }

    final misura = MisuraDellaRisposta.primaRisposta;
    stdout.writeln('Misura chiesta: ${misura.parole} parole '
        '(${misura.inLettere}). Tetto: ${misura.tetto} token. '
        'Ragionamento: ${misura.ragionamento}.');

    Future<_Esito?> chiedi(Maestro maestro, String domanda) async {
      final uri = Uri.https(
        '$regione-aiplatform.googleapis.com',
        '/v1/projects/$progetto/locations/$regione/publishers/google/models/'
            '${FirebaseMaestroAiProvider.kMaestroChatModel}:generateContent',
      );
      final corpo = jsonEncode({
        'systemInstruction': {
          'parts': [
            {
              'text': MaestroPersona.systemInstruction(
                maestro: maestro,
                profile: UserProfile(displayName: 'Sofia'),
                memory: MaestroMemory.empty,
                natal: const NatalContext(
                  sunSign: 'Leone',
                  moonSign: 'Cancro',
                  lifeNumber: 7,
                  lifeNumberTitle: 'il Cercatore',
                ),
              )
            }
          ]
        },
        'contents': [
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
      final cronometro = Stopwatch()..start();
      try {
        final richiesta = await client.postUrl(uri);
        richiesta.headers.set('Authorization', 'Bearer $gettone');
        richiesta.headers.set('Content-Type', 'application/json');
        richiesta.add(utf8.encode(corpo));
        final risposta = await richiesta.close();
        final grezzo = await risposta.transform(utf8.decoder).join();
        if (risposta.statusCode != 200) {
          stderr.writeln('HTTP ${risposta.statusCode}: '
              '${grezzo.substring(0, grezzo.length.clamp(0, 300))}');
          return null;
        }
        final d = jsonDecode(grezzo) as Map<String, dynamic>;
        final candidati = d['candidates'] as List?;
        if (candidati == null || candidati.isEmpty) return null;
        final c = candidati.first as Map<String, dynamic>;
        final parti =
            ((c['content'] as Map?)?['parts'] as List?) ?? const <dynamic>[];
        final testo = parti
            .map((p) => (p as Map)['text']?.toString() ?? '')
            .join()
            .trim();
        final uso = (d['usageMetadata'] as Map?) ?? const {};
        return _Esito(
          maestro: maestro,
          domanda: domanda,
          testo: testo,
          motivo: c['finishReason']?.toString() ?? 'assente',
          // Il tempo di RETE, cioe' quanto la persona aspetta prima che la
          // prima parola possa comparire. E' il numero su cui si tara la durata
          // minima della scena del consulto: una scena piu' corta della rete
          // non serve a niente, una molto piu' lunga fa aspettare per finta.
          millisecondi: cronometro.elapsedMilliseconds,
          parole: testo.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).length,
          tokenTesto: (uso['candidatesTokenCount'] as num?)?.toInt() ?? 0,
          tokenPensiero: (uso['thoughtsTokenCount'] as num?)?.toInt() ?? 0,
        );
      } finally {
        client.close(force: true);
      }
    }

    // Le venti domande distribuite sui tre Maestri a giro, cosi' la misura non
    // vale per una voce sola: le tre hanno lessici diversi e lunghezze diverse.
    final lavori = [
      for (var i = 0; i < CorpusNeutro.domande.length; i++)
        (
          maestro: Maestro.values[i % Maestro.values.length],
          domanda: CorpusNeutro.domande[i],
        ),
    ];

    final esiti = <_Esito>[];
    for (var i = 0; i < lavori.length; i += insieme) {
      final lotto = lavori.skip(i).take(insieme).toList();
      final risultati = await Future.wait(
          lotto.map((l) => chiedi(l.maestro, l.domanda)));
      esiti.addAll(risultati.whereType<_Esito>());
      stdout.writeln('  ${esiti.length}/${lavori.length}');
    }

    expect(esiti.length, lavori.length,
        reason: 'qualche chiamata non e\' tornata: la misura sarebbe parziale');

    stdout.writeln('\n${'-' * 78}');
    for (final e in esiti) {
      stdout.writeln('${e.maestro.displayName.padRight(7)} '
          '${e.parole.toString().padLeft(3)} parole  '
          '${e.motivo.padRight(10)} '
          '${(e.millisecondi / 1000).toStringAsFixed(1)}s  '
          'testo ${e.tokenTesto.toString().padLeft(4)} tok, '
          'pensiero ${e.tokenPensiero}  '
          '«${e.domanda}»');
      stdout.writeln('        ...${e.coda}');
    }

    // UNA RISPOSTA PER INTERO, per Maestro. Le code non bastano a giudicare se
    // una risposta sta in piedi: la si legge tutta, oppure non la si e' letta.
    stdout.writeln('${'-' * 78}\nUNA RISPOSTA INTERA PER CIASCUNO:');
    for (final maestro in Maestro.values) {
      final suo = esiti.where((e) => e.maestro == maestro);
      if (suo.isEmpty) continue;
      final e = suo.first;
      stdout.writeln('\n### ${maestro.displayName}, «${e.domanda}», '
          '${e.parole} parole\n${e.testo}');
    }

    // IL TEMPO DI RETE, MISURATO DA SOLO E IN FILA.
    //
    // Le venti qui sopra partono a cinque per volta, quindi il loro tempo porta
    // dentro la coda dell'una sull'altra: userebbe un numero piu' alto del vero
    // per tarare la scena dell'attesa. Queste dieci partono UNA ALLA VOLTA, ed
    // e' il tempo che aspetta una persona sola col telefono in mano.
    stdout.writeln('${'-' * 78}\nDIECI CHIAMATE IN FILA, per il tempo vero:');
    final tempi = <int>[];
    for (var i = 0; i < 10; i++) {
      final l = lavori[i];
      final e = await chiedi(l.maestro, l.domanda);
      if (e == null) continue;
      tempi.add(e.millisecondi);
      stdout.writeln('  ${(e.millisecondi / 1000).toStringAsFixed(2)}s  '
          '${e.maestro.displayName}, ${e.parole} parole');
    }
    tempi.sort();

    // I CARATTERI VERI, non stimati: il tempo della macchina da scrivere si
    // calcola sui caratteri, e "circa sei per parola" e' una stima che non
    // vale la pena di fare quando il numero si puo' contare.
    final caratteri = esiti.map((e) => e.testo.length).toList()..sort();

    final parole = esiti.map((e) => e.parole).toList()..sort();
    final tronche = esiti.where((e) => e.motivo == 'MAX_TOKENS').toList();
    final pensanti = esiti.where((e) => e.tokenPensiero > 0).toList();

    String ms(int v) => '${(v / 1000).toStringAsFixed(2)}s';
    stdout.writeln('${'-' * 78}\n'
        'RETE    minimo ${ms(tempi.first)}  '
        'mediana ${ms(tempi[tempi.length ~/ 2])}  '
        'massimo ${ms(tempi.last)}   (${tempi.length} chiamate in fila)\n'
        'PAROLE  minimo ${parole.first}  '
        'mediana ${parole[parole.length ~/ 2]}  '
        'massimo ${parole.last}   (chieste ${misura.parole})\n'
        'CARATT. minimo ${caratteri.first}  '
        'mediana ${caratteri[caratteri.length ~/ 2]}  '
        'massimo ${caratteri.last}\n'
        'PRIMA PAROLA  ${ms(TempiDellAttesa.allaPrimaParola(tempi.first).inMilliseconds)}  '
        '${ms(TempiDellAttesa.allaPrimaParola(tempi[tempi.length ~/ 2]).inMilliseconds)}  '
        '${ms(TempiDellAttesa.allaPrimaParola(tempi.last).inMilliseconds)}\n'
        'TESTO COMPLETO  '
        '${ms(_completo(tempi.first, caratteri.first))}  '
        '${ms(_completo(tempi[tempi.length ~/ 2], caratteri[caratteri.length ~/ 2]))}  '
        '${ms(_completo(tempi.last, caratteri.last))}\n'
        'FERMATE AL MURO: ${tronche.length} su ${esiti.length}\n'
        'CON RAGIONAMENTO ACCESO: ${pensanti.length} su ${esiti.length}');

    expect(tronche, isEmpty,
        reason: 'una risposta fermata dal limite e\' un moncone a video');
    expect(pensanti, isEmpty,
        reason: 'il ragionamento e\' dichiarato a zero ma il modello ha '
            'pensato lo stesso: e\' cio' ' che mangiava il tetto');
  }, timeout: const Timeout(Duration(minutes: 10)));
}

class _Esito {
  _Esito({
    required this.maestro,
    required this.domanda,
    required this.testo,
    required this.motivo,
    required this.parole,
    required this.millisecondi,
    required this.tokenTesto,
    required this.tokenPensiero,
  });

  final Maestro maestro;
  final String domanda;
  final String testo;
  final String motivo;
  final int parole;

  /// Quanto e' durata la chiamata, dalla richiesta alla risposta completa.
  final int millisecondi;
  final int tokenTesto;
  final int tokenPensiero;

  /// Le ultime parole, che sono il punto: una risposta tronca finisce senza
  /// punteggiatura, a meta' di una parola o di un pensiero.
  String get coda =>
      testo.length <= 60 ? testo : testo.substring(testo.length - 60);
}

/// Il tempo dalla domanda all'ultima lettera, con la rete e i caratteri veri.
/// Chiama gli stessi conti dell'app, non li rifa': una seconda copia
/// dell'aritmetica finirebbe per misurare se stessa.
int _completo(int reteMs, int caratteri) =>
    TempiDellAttesa.allaPrimaParola(reteMs).inMilliseconds +
    TempiDellAttesa.durataDiScrittura(
            caratteri, TempiDellAttesa.perScrivere(reteMs))
        .inMilliseconds;

/// Il gettone di accesso dalla sessione gcloud gia' attiva sul PC.
Future<String?> _gettone() async {
  try {
    final esito = await Process.run(
        'gcloud', ['auth', 'print-access-token'],
        runInShell: true);
    if (esito.exitCode != 0) return null;
    final t = (esito.stdout as String).trim();
    return t.isEmpty ? null : t;
  } catch (_) {
    return null;
  }
}
