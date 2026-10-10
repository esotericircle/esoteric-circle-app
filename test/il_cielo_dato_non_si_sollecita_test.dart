import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/services/ai/firebase_maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/l_etichetta_della_funzione.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// **COL CIELO GIA' DATO, LA FUNZIONE NON SI CHIAMA E NON SI SOLLECITA.**
/// Ordine EX Aggiunta 4, voce EX.07. Il giorno scritto nella domanda arriva
/// col suo cielo nell'istruzione, e il turno non chiama funzioni. Al banco
/// della qualita' (giro ex07d) la rete del rimando mandava lo stesso il
/// sollecito "chiama la funzione"; il modello, senza funzione, rispondeva
/// "ho bisogno che tu mi dica quale data", e quella frase prendeva il posto
/// della risposta buona in quattro domande su quattro. Padre: questa voce.
/// La prova passa dal provider vero, con la rete finta sotto l'etichetta.
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
                      'text': 'Domani la Luna è in Cancro, nel tuo segno.\n'
                          '✦ Domattina esci a camminare dieci minuti.'
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

  tearDownAll(() => ClientConEtichetta.internoDeiBanchi = null);

  test('la domanda su domani: una richiesta sola, col cielo e senza funzioni',
      () async {
    corpi.clear();
    final testo = await FirebaseMaestroAiProvider().reply(
      maestro: Maestro.medora,
      profile: UserProfile(),
      memory: MaestroMemory.empty,
      history: const [],
      userMessage: 'Com\'è il cielo domani?',
    );
    expect(corpi, hasLength(1),
        reason: 'col cielo gia\' dato non si manda il sollecito');
    expect(testo, contains('Luna è in Cancro'));
    final istruzione = jsonEncode(corpi.first['systemInstruction']);
    expect(istruzione, contains('IL CIELO DEI GIORNI CHE LA PERSONA NOMINA'));
    expect(jsonEncode(corpi.first['toolConfig']), contains('NONE'));
  });

  test('la domanda senza giorni: le funzioni restano', () async {
    corpi.clear();
    await FirebaseMaestroAiProvider().reply(
      maestro: Maestro.medora,
      profile: UserProfile(),
      memory: MaestroMemory.empty,
      history: const [],
      userMessage: 'Lui tornerà da me?',
    );
    expect(corpi.first['toolConfig'], isNull);
  });
}
