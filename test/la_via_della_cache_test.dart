import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/services/ai/firebase_maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/l_etichetta_della_funzione.dart';
import 'package:esoteric_circle/services/ai/la_cache_del_contesto.dart';
import 'package:esoteric_circle/services/ai/maestro_persona.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// **LA VIA DELLA CACHE.** Ordine EX Aggiunta 4, voce EX.05.
///
/// Con la cache accesa la prima risposta della chat va al modello con la
/// sola parte comune come istruzione (la tiene la cache) e il resto come
/// testo: la parte della persona, il cielo di oggi, la conversazione e la
/// domanda. Spenta, o per una domanda sul cielo di un periodo, resta la via
/// di sempre. La prova passa dal provider vero con la rete finta, e dalla
/// strada del banco ([LaCacheDelContesto.simulataNelBanco]): il template di
/// Firebase non si puo' chiamare da qui.
void main() {
  final corpi = <Map<String, dynamic>>[];

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    HttpOverrides.global = null;
    setupFirebaseCoreMocks();
    try {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'prova',
          appId: '1:425821975933:android:prova',
          messagingSenderId: '425821975933',
          projectId: 'esoteric-circle',
        ),
      );
    } on FirebaseException catch (e) {
      if (e.code != 'duplicate-app') rethrow;
    }
    ClientConEtichetta.internoDeiBanchi = MockClient((r) async {
      corpi.add(jsonDecode(r.body) as Map<String, dynamic>);
      return http.Response(
          jsonEncode({
            'candidates': [
              {
                'content': {
                  'role': 'model',
                  'parts': [
                    {
                      'text': 'Le carte dicono di sì, se parli prima con lui.'
                          '\n✦ Domattina scrivigli due righe.'
                    }
                  ]
                },
                'finishReason': 'STOP'
              }
            ],
            'usageMetadata': {
              'promptTokenCount': 10,
              'candidatesTokenCount': 10,
              'totalTokenCount': 20
            }
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'});
    });
  });

  tearDownAll(() {
    ClientConEtichetta.internoDeiBanchi = null;
    LaCacheDelContesto.simulataNelBanco = false;
  });

  Future<Map<String, dynamic>> chiedi(String domanda,
      {required bool cache}) async {
    corpi.clear();
    LaCacheDelContesto.simulataNelBanco = cache;
    await FirebaseMaestroAiProvider().reply(
      maestro: Maestro.medora,
      profile: UserProfile(),
      memory: MaestroMemory.empty,
      history: const [],
      userMessage: domanda,
    );
    // Sulla via di sempre la risposta finta, che non chiama la funzione,
    // puo' ricevere il sollecito: conta la prima richiesta.
    expect(corpi, isNotEmpty);
    return corpi.first;
  }

  test('accesa: l\'istruzione e\' la parte comune, il resto e\' testo',
      () async {
    final dalle = LaCacheDelContesto.risposteDallaCache;
    final corpo = await chiedi('Devo accettare il lavoro?', cache: true);
    final istruzione =
        ((corpo['systemInstruction'] as Map)['parts'] as List).first['text'];
    expect(istruzione, MaestroPersona.parteComune(maestro: Maestro.medora));
    expect(corpo['tools'], isNull, reason: 'il template non ha le funzioni');
    final testo = jsonEncode(corpo['contents']);
    expect(testo, contains('LA PERSONA TI SCRIVE ADESSO'));
    expect(testo, contains('IL CIELO DI OGGI'));
    expect(testo, contains('Devo accettare il lavoro?'));
    expect(corpi, hasLength(1));
    expect(LaCacheDelContesto.risposteDallaCache, dalle + 1);
  });

  test('il cielo di un periodo resta sulla via di sempre, con le funzioni',
      () async {
    final corpo = await chiedi('Quando torna diretto Mercurio?', cache: true);
    expect(corpo['tools'], isNotNull);
  });

  test('spenta: la via di sempre', () async {
    LaCacheDelContesto.statoDiProva = {'accesa': false};
    addTearDown(() => LaCacheDelContesto.statoDiProva = null);
    final corpo = await chiedi('Devo accettare il lavoro?', cache: false);
    expect(corpo['tools'], isNotNull);
  });
}
