import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/corpus_neutro.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/services/ai/firebase_maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_persona.dart';
import 'package:flutter_test/flutter_test.dart';

/// IL TEST DI ATTRIBUZIONE CIECA: i tre Maestri sono riconoscibili?
///
/// **Non e' nella suite, ed e' voluto.** Costa chiamate vere a Gemini, quindi
/// vive in `tool/` e si esegue a comando, prima di ogni consegna che tocca le
/// personalita'. `flutter test` guarda solo `test/`, quindi da qui non parte
/// mai da solo.
///
/// ```
/// flutter test tool/attribuzione_cieca.dart
/// ```
///
/// **Cosa misura.** Pone le venti domande neutre di [CorpusNeutro] a tutti e
/// tre i Maestri, con le istruzioni di sistema VERE dell'app, raccoglie
/// sessanta risposte e le mescola. Poi un giudice, cioe' una seconda chiamata
/// a Gemini che non sa chi ha scritto cosa, prova a indovinare l'autore fra
/// tre. Il caso cieco vale 33 per cento, la soglia e' 85.
///
/// **Consegna la MATRICE, non il numero.** Un 85 aggregato puo' nascondere che
/// due voci si scambiano di posto fra loro mentre la terza e' distintissima:
/// il numero direbbe "va bene" e la coppia da correggere resterebbe invisibile.
/// La matrice dice cosa correggere, quindi non e' un semaforo.
void main() {
  const progetto = 'esoteric-circle';
  const regione = 'europe-west1';
  const modelloRisposta = FirebaseMaestroAiProvider.kMaestroChatModel;
  const modelloGiudice = FirebaseMaestroAiProvider.kMaestroChatModel;

  /// La soglia sotto la quale le voci non sono riconoscibili.
  const soglia = 0.85;

  /// Quante chiamate insieme. Basso apposta: la quota conta piu' della fretta.
  const insieme = 6;

  test('Attribuzione cieca dei tre Maestri', () async {
    final gettone = await _gettone();
    if (gettone == null) {
      fail('Nessun gettone di accesso. Serve una sessione gcloud attiva: '
          'gcloud auth login');
    }

    Future<String?> chiama({
      required String modello,
      required String istruzione,
      required String domanda,
      required int tetto,
    }) async {
      final uri = Uri.https(
        '$regione-aiplatform.googleapis.com',
        '/v1/projects/$progetto/locations/$regione/publishers/google/models/'
            '$modello:generateContent',
      );
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
              {'text': domanda}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.9,
          'topP': 0.95,
          'maxOutputTokens': tetto,
          'thinkingConfig': {'thinkingBudget': 0},
        },
      });
      final client = HttpClient();
      try {
        final richiesta = await client.postUrl(uri);
        richiesta.headers.set('Authorization', 'Bearer $gettone');
        richiesta.headers.set('Content-Type', 'application/json');
        richiesta.add(utf8.encode(corpo));
        final risposta = await richiesta.close();
        final testo = await risposta.transform(utf8.decoder).join();
        if (risposta.statusCode != 200) {
          stderr.writeln('HTTP ${risposta.statusCode}: '
              '${testo.substring(0, testo.length.clamp(0, 300))}');
          return null;
        }
        final decodificato = jsonDecode(testo) as Map<String, dynamic>;
        final candidati = decodificato['candidates'] as List?;
        if (candidati == null || candidati.isEmpty) return null;
        final parti = ((candidati.first as Map)['content']
            as Map?)?['parts'] as List?;
        if (parti == null || parti.isEmpty) return null;
        return (parti.first as Map)['text']?.toString().trim();
      } finally {
        client.close(force: true);
      }
    }

    // ---- Primo passo: sessanta risposte, con le istruzioni VERE dell'app.
    final risposte = <_Risposta>[];
    final lavori = <({Maestro maestro, String domanda})>[
      for (final maestro in Maestro.values)
        for (final domanda in CorpusNeutro.domande)
          (maestro: maestro, domanda: domanda),
    ];

    stdout.writeln('Chiedo ${lavori.length} risposte, '
        '${CorpusNeutro.domande.length} domande per tre Maestri...');
    for (var i = 0; i < lavori.length; i += insieme) {
      final lotto = lavori.skip(i).take(insieme).toList();
      final esiti = await Future.wait(lotto.map((l) async {
        final istruzione = MaestroPersona.systemInstruction(
          maestro: l.maestro,
          profile: UserProfile.empty,
          memory: MaestroMemory.empty,
        );
        final testo = await chiama(
          modello: modelloRisposta,
          istruzione: istruzione,
          domanda: l.domanda,
          tetto: FirebaseMaestroAiProvider.kBreveMaxTokens,
        );
        return testo == null
            ? null
            : _Risposta(autore: l.maestro, domanda: l.domanda, testo: testo);
      }));
      risposte.addAll(esiti.whereType<_Risposta>());
      stdout.writeln('  ${risposte.length}/${lavori.length}');
    }

    expect(risposte.length, greaterThan(lavori.length ~/ 2),
        reason: 'meta\' delle chiamate non ha risposto: la misura non vale');

    // Mescolate con un seme FISSO: due esecuzioni si possono confrontare, e
    // l'ordine non e' quello in cui sono state generate, cosi' il giudice non
    // puo' indovinare per posizione.
    risposte.shuffle(_SemeFisso(20260802));

    // ---- Secondo passo: il giudice, che non sa chi ha scritto.
    final istruzioneGiudice = StringBuffer()
      ..writeln(
          'Sei un lettore attento. Ti do una risposta scritta da UNO di tre '
          'guide del cerchio di Esoteric Circle. Devi dire quale.')
      ..writeln();
    for (final maestro in Maestro.values) {
      istruzioneGiudice.writeln(
          '- ${maestro.id}: ${maestro.displayName}, si occupa di '
          '${maestro.domainArtsPhrase}.');
    }
    istruzioneGiudice
      ..writeln()
      ..writeln('Rispondi con UNA sola parola fra: '
          '${Maestro.values.map((m) => m.id).join(', ')}. '
          'Nessuna spiegazione, nessuna punteggiatura.');

    // La matrice: quante volte una risposta di X e' stata attribuita a Y.
    final matrice = <Maestro, Map<Maestro, int>>{
      for (final a in Maestro.values)
        a: {for (final b in Maestro.values) b: 0},
    };
    var nonDeciso = 0;

    stdout.writeln('Faccio giudicare ${risposte.length} risposte...');
    for (var i = 0; i < risposte.length; i += insieme) {
      final lotto = risposte.skip(i).take(insieme).toList();
      final esiti = await Future.wait(lotto.map((r) async {
        final verdetto = await chiama(
          modello: modelloGiudice,
          istruzione: istruzioneGiudice.toString(),
          domanda: 'Risposta da attribuire:\n\n${r.testo}',
          tetto: 8,
        );
        return (risposta: r, verdetto: verdetto);
      }));
      for (final esito in esiti) {
        final indovinato = _leggiVerdetto(esito.verdetto);
        if (indovinato == null) {
          nonDeciso++;
          continue;
        }
        matrice[esito.risposta.autore]![indovinato] =
            matrice[esito.risposta.autore]![indovinato]! + 1;
      }
      stdout.writeln('  ${(i + lotto.length)}/${risposte.length}');
    }

    // ---- La matrice di confusione, per esteso.
    final intestazione = Maestro.values.map((m) => m.id.padLeft(8)).join(' ');
    stdout
      ..writeln()
      ..writeln('MATRICE DI CONFUSIONE, righe: chi ha scritto, '
          'colonne: chi ha indovinato il giudice')
      ..writeln('${' '.padRight(9)}$intestazione     totale   giusti');
    var giustiTotali = 0;
    var totaliTotali = 0;
    for (final autore in Maestro.values) {
      final riga = matrice[autore]!;
      final totale = riga.values.fold<int>(0, (a, b) => a + b);
      final giusti = riga[autore]!;
      giustiTotali += giusti;
      totaliTotali += totale;
      final celle = Maestro.values
          .map((m) => riga[m]!.toString().padLeft(8))
          .join(' ');
      final quota = totale == 0 ? 0.0 : giusti / totale;
      stdout.writeln('${autore.id.padRight(9)}$celle  '
          '${totale.toString().padLeft(7)}  '
          '${(quota * 100).toStringAsFixed(1).padLeft(6)}%');
    }
    final quotaTotale = totaliTotali == 0 ? 0.0 : giustiTotali / totaliTotali;
    stdout
      ..writeln()
      ..writeln('Attribuzione corretta: $giustiTotali su $totaliTotali, '
          'cioe\' ${(quotaTotale * 100).toStringAsFixed(1)} per cento.')
      ..writeln('Caso cieco: '
          '${(100 / Maestro.values.length).toStringAsFixed(1)} per cento. '
          'Soglia: ${(soglia * 100).toStringAsFixed(0)} per cento.')
      ..writeln('Verdetti illeggibili: $nonDeciso.');

    // Le coppie che si scambiano di posto, che il numero aggregato nasconde.
    for (final autore in Maestro.values) {
      for (final altro in Maestro.values) {
        if (autore == altro) continue;
        final scambi = matrice[autore]![altro]!;
        final totale =
            matrice[autore]!.values.fold<int>(0, (a, b) => a + b);
        if (totale > 0 && scambi / totale >= 0.15) {
          stdout.writeln('DA CORREGGERE: ${autore.id} scambiato per '
              '${altro.id} nel ${(scambi / totale * 100).toStringAsFixed(0)} '
              'per cento dei casi.');
        }
      }
    }

    expect(quotaTotale, greaterThanOrEqualTo(soglia),
        reason: 'le tre voci non sono abbastanza riconoscibili: guarda la '
            'matrice qui sopra e correggi la coppia che si scambia, non le '
            'tre voci insieme');
  }, timeout: const Timeout(Duration(minutes: 30)));
}

/// Una risposta, col suo autore vero, che il giudice non vede.
class _Risposta {
  const _Risposta({
    required this.autore,
    required this.domanda,
    required this.testo,
  });
  final Maestro autore;
  final String domanda;
  final String testo;
}

/// Legge il verdetto del giudice, che a volte aggiunge punteggiatura.
Maestro? _leggiVerdetto(String? verdetto) {
  if (verdetto == null) return null;
  final pulito = verdetto.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
  for (final maestro in Maestro.values) {
    if (pulito.contains(maestro.id)) return maestro;
  }
  return null;
}

/// Il gettone di accesso dalla sessione gcloud gia' aperta sul PC.
Future<String?> _gettone() async {
  try {
    final esito = await Process.run(
      Platform.isWindows ? 'gcloud.cmd' : 'gcloud',
      ['auth', 'print-access-token'],
      runInShell: true,
    );
    if (esito.exitCode != 0) return null;
    final testo = (esito.stdout as String).trim();
    return testo.isEmpty ? null : testo;
  } catch (_) {
    return null;
  }
}

/// Un generatore con seme fisso, cosi' due esecuzioni si confrontano.
class _SemeFisso implements Random {
  _SemeFisso(int seme) : _interno = Random(seme);
  final Random _interno;

  @override
  bool nextBool() => _interno.nextBool();

  @override
  double nextDouble() => _interno.nextDouble();

  @override
  int nextInt(int max) => _interno.nextInt(max);
}
