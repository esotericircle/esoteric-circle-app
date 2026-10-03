// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/services/ai/l_etichetta_della_funzione.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

/// **IL BANCO DEL COSTO, LA PARTE COMUNE.** Ordine EW, voci EW.03 ed EW.04.
///
/// Fa girare sul PC il codice VERO dell'app che chiama Gemini: un'app
/// Firebase finta (`setupFirebaseCoreMocks`) e, sotto ogni
/// [ClientConEtichetta], un client che prende la richiesta che la libreria
/// `firebase_ai` avrebbe mandato al passaggio di Firebase AI Logic e la manda
/// invece a Vertex AI in europe-west1 col gettone di `gcloud`, uguale, con la
/// sua etichetta. Dalla risposta si leggono i consumi (`usageMetadata`), per
/// funzione.
class UnaChiamata {
  UnaChiamata(this.funzione, this.modello, this.uso);
  final String funzione;
  final String modello;

  /// `usageMetadata` della risposta (per lo streaming, l'ultimo pezzo).
  final Map<String, dynamic> uso;

  int get ingresso => (uso['promptTokenCount'] as num?)?.toInt() ?? 0;
  int get uscita => (uso['candidatesTokenCount'] as num?)?.toInt() ?? 0;
  int get ragionamento => (uso['thoughtsTokenCount'] as num?)?.toInt() ?? 0;
  int get dallaCache => (uso['cachedContentTokenCount'] as num?)?.toInt() ?? 0;
}

final List<UnaChiamata> registro = [];

/// Le regioni diverse da europe-west1 da cui l'app avrebbe chiamato.
final List<String> fuoriRegione = [];
String _gettone = Platform.environment['VERTEX_TOKEN'] ?? '';

Future<String> gettone() async {
  if (_gettone.isNotEmpty) return _gettone;
  final r = await Process.run('gcloud', ['auth', 'print-access-token'],
      runInShell: true);
  return _gettone = (r.stdout as String).trim();
}

/// Il client che sta sotto l'etichetta durante il banco.
class VersoVertex extends http.BaseClient {
  final http.Client _vero = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final r = request as http.Request;
    // firebasevertexai.googleapis.com/v1beta/projects/P/locations/L/
    // publishers/google/models/M:generateContent -> aiplatform v1beta1.
    // L'app finta dei finti di Firebase ha il suo progetto: si rimette il
    // progetto vero, nel percorso e nel campo `model` del corpo.
    // Il banco chiama solo nella regione dei dati: una chiamata che nell'app
    // parte altrove (la penna dei Ricordi, senza regione, va a us-central1)
    // si misura in europe-west1, e il banco lo scrive.
    final originale =
        RegExp(r'/locations/([^/]+)/').firstMatch(r.url.path)?[1] ?? '?';
    if (originale != 'europe-west1') fuoriRegione.add(originale);
    final percorso = r.url.path
        .replaceFirst('/v1beta/', '/v1beta1/')
        .replaceFirst(RegExp(r'/projects/[^/]+/'), '/projects/esoteric-circle/')
        .replaceFirst(RegExp(r'/locations/[^/]+/'), '/locations/europe-west1/');
    final corpoGiusto = r.body.replaceFirst(
        RegExp(r'"model":"projects/[^/]+/locations/[^/]+/'),
        '"model":"projects/esoteric-circle/locations/europe-west1/');
    const regione = 'europe-west1';
    final url = Uri.https('$regione-aiplatform.googleapis.com', percorso,
        r.url.queryParameters.isEmpty ? null : r.url.queryParameters);
    final corpo = jsonDecode(r.body) as Map<String, dynamic>;
    final funzione =
        (corpo['labels'] as Map?)?['funzione'] as String? ?? 'SENZA_ETICHETTA';
    final modello = RegExp(r'/models/([^:]+):').firstMatch(percorso)?[1] ?? '?';
    for (var tentativo = 0; tentativo < 4; tentativo++) {
      final nuova = http.Request('POST', url)
        ..headers['Authorization'] = 'Bearer ${await gettone()}'
        ..headers['Content-Type'] = 'application/json'
        ..body = corpoGiusto;
      final risposta = await _vero.send(nuova);
      final testo = await risposta.stream.bytesToString();
      if (risposta.statusCode == 401) {
        _gettone = '';
        continue;
      }
      if (risposta.statusCode == 429 || risposta.statusCode >= 500) {
        await Future<void>.delayed(Duration(seconds: 4 * (tentativo + 1)));
        continue;
      }
      // I consumi: nella risposta intera, o nell'ultimo pezzo dello stream.
      Map<String, dynamic>? uso;
      for (final m
          in RegExp(r'"usageMetadata"\s*:\s*(\{[^{}]*(\{[^{}]*\}[^{}]*)*\})')
              .allMatches(testo)) {
        try {
          uso = jsonDecode(m.group(1)!) as Map<String, dynamic>;
        } catch (_) {}
      }
      if (risposta.statusCode == 200) {
        registro.add(UnaChiamata(funzione, modello, uso ?? {}));
      } else {
        print('VERTEX ${risposta.statusCode} per $funzione: '
            '${testo.length > 300 ? testo.substring(0, 300) : testo}');
      }
      return http.StreamedResponse(
          Stream.value(utf8.encode(testo)), risposta.statusCode,
          headers: risposta.headers, request: request);
    }
    throw const HttpException('Vertex non risponde');
  }
}

/// L'app Firebase finta e il client del banco sotto le etichette.
Future<void> preparaIlBanco() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = null;
  setupFirebaseCoreMocks();
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'banco',
        appId: '1:425821975933:android:banco',
        messagingSenderId: '425821975933',
        projectId: 'esoteric-circle',
      ),
    );
  } on FirebaseException catch (e) {
    // I finti di Firebase hanno gia' l'app di base: va bene quella.
    if (e.code != 'duplicate-app') rethrow;
  }
  ClientConEtichetta.internoDeiBanchi = VersoVertex();
}
