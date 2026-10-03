// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/core/astro/il_cielo_detto.dart';
import 'package:esoteric_circle/core/astro/il_cielo_per_il_maestro.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/misura_della_risposta.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/services/ai/firebase_maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/le_funzioni_del_cielo.dart';
import 'package:esoteric_circle/services/ai/maestro_persona.dart';
import 'package:flutter_test/flutter_test.dart';

/// **IL BANCO DI MEDORA E DEL CIELO.** Ordine EV voce 03.
///
/// Venti domande sul cielo (oggi, il passato, il futuro) poste a Medora con
/// l'istruzione VERA dell'app, la configurazione VERA del provider e le
/// funzioni del cielo VERE: quando il modello chiede `cielo_del_giorno` o
/// `cielo_del_periodo`, qui si esegue [LeFunzioniDelCielo] (lo stesso codice
/// che sul telefono esegue `firebase_ai`) e gli si rimanda il risultato. Poi
/// la risposta passa dalla rete del cielo detto, come in chat.
///
/// Accanto a ogni risposta: le chiamate fatte e i fatti delle effemeridi per
/// le date della domanda, perche' chi legge veda in tre secondi se Medora ha
/// detto il vero.
///
/// ```
/// flutter test tool/medora_e_il_cielo.dart
/// ```
///
/// `PRIMA=1` ripete il banco come prima dell'ordine EV: niente funzioni, e
/// il cielo di oggi con i soli sette corpi e la regola di non nominare Urano,
/// Nettuno e Plutone. Le domande dispari hanno una persona con i dati di
/// nascita, le pari una senza: il cielo deve arrivare a tutte e due.
/// Non e' nella suite: costa chiamate vere, in europe-west1.
void main() {
  const progetto = 'esoteric-circle';
  const regione = 'europe-west1';
  final prima = Platform.environment['PRIMA'] == '1';
  // PERSONA=2: un'altra persona, per la seconda esecuzione con dati diversi.
  final seconda = Platform.environment['PERSONA'] == '2';
  final uscita = Platform.environment['USCITA'] ??
      'docs/collaudo/EV/medora_e_il_cielo${prima ? '_prima' : ''}'
          '${seconda ? '_persona2' : ''}.txt';

  test('Medora e il cielo: venti domande', () async {
    var gettone = await _gettone();
    if (gettone == null) fail('Serve una sessione gcloud attiva.');
    final adesso = DateTime.now();
    final oggi = DateTime(adesso.year, adesso.month, adesso.day);
    String g(DateTime d) => '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
    final domani = oggi.add(const Duration(days: 1));

    // La domanda e le date dei fatti da mettere accanto.
    final domande = <(String, List<String>, (String, String)?)>[
      ('Urano è retrogrado oggi? Cosa vuol dire per me?', [g(oggi)], null),
      ('In che segno è la Luna oggi, e in che fase?', [g(oggi)], null),
      ('Quali pianeti sono retrogradi oggi?', [g(oggi)], null),
      ('Dov\'è Venere oggi?', [g(oggi)], null),
      ('Che aspetti ci sono oggi fra i pianeti?', [g(oggi)], null),
      ('Marte oggi in che segno è?', [g(oggi)], null),
      ('Com\'è il cielo di oggi, in generale?', [g(oggi)], null),
      ('Com\'era il cielo il 21 dicembre 2020?', ['2020-12-21'], null),
      ('In che segno era Saturno il primo gennaio 2000?', ['2000-01-01'], null),
      ('Che fase aveva la Luna il 20 luglio 1969?', ['1969-07-20'], null),
      ('L\'8 aprile 2024 c\'è stata un\'eclissi?', ['2024-04-08'], null),
      ('Mercurio era retrogrado ad agosto 2025?', [], ('2025-08-01', '2025-08-31')),
      ('Dov\'era Giove il 14 marzo 1990, il giorno in cui sono nata?',
          ['1990-03-14'], null),
      ('Com\'è il cielo domani?', [g(domani)], null),
      ('Quando torna diretto Urano?', [],
          (g(oggi), g(oggi.add(const Duration(days: 200))))),
      ('Che cosa succede nel cielo a dicembre 2026?', [], ('2026-12-01', '2026-12-31')),
      ('Ci sono eclissi nel 2027?', [], ('2027-01-01', '2027-12-31')),
      ('Quando c\'è la prossima Luna piena?', [],
          (g(oggi), g(oggi.add(const Duration(days: 31))))),
      ('Mercurio sarà retrogrado a novembre 2026?', [], ('2026-11-01', '2026-11-30')),
      ('In che segno sarà Giove il primo gennaio 2028?', ['2028-01-01'], null),
    ];

    final conNascita = NatalContext(
      sunSign: seconda ? 'Leone' : 'Cancro',
      moonSign: seconda ? 'Pesci' : 'Bilancia',
      ascendant: seconda ? 'Vergine' : 'Scorpione',
      lifeNumber: 7,
      lifeNumberTitle: 'il Cercatore',
    );

    final strumenti = [
      for (final t in LeFunzioniDelCielo.perIlMaestro(adesso: adesso))
        t.toJson()
    ];
    final config = FirebaseMaestroAiProvider.configurazionePer(
      MisuraDellaRisposta.perIlTurno(nelLive: false),
      temperature: 0.9,
      topP: 0.95,
    ).toJson();

    String istruzione(NatalContext natal) {
      var s = MaestroPersona.systemInstruction(
        maestro: Maestro.medora,
        profile: UserProfile(displayName: seconda ? 'Marco' : 'Sofia'),
        memory: MaestroMemory.empty,
        natal: natal,
      );
      if (prima) {
        // Il cielo di oggi come lo diceva il codice prima dell'ordine EV.
        s = s
            .replaceAll(
                RegExp(r', Urano in [A-Za-zàèéìòù]+( retrogrado)?'
                    r', Nettuno in [A-Za-zàèéìòù]+( retrogrado)?'
                    r', Plutone in [A-Za-zàèéìòù]+( retrogrado)?'),
                '')
            .replaceAll(
                'Per il cielo di un altro giorno, o per i gradi e gli '
                    'aspetti, chiedi la funzione cielo_del_giorno.',
                'Non nominare Urano, Nettuno e Plutone.');
      }
      return s;
    }

    Future<Map<String, dynamic>?> chiama(Map<String, Object?> corpo) async {
      final uri = Uri.https(
        '$regione-aiplatform.googleapis.com',
        '/v1/projects/$progetto/locations/$regione/publishers/google/models/'
            '${FirebaseMaestroAiProvider.kMaestroChatModel}:generateContent',
      );
      for (var tentativo = 0; tentativo < 4; tentativo++) {
        final client = HttpClient();
        try {
          final r = await client.postUrl(uri);
          r.headers.set('Authorization', 'Bearer $gettone');
          r.headers.set('Content-Type', 'application/json');
          r.add(utf8.encode(jsonEncode(corpo)));
          final risposta = await r.close();
          final grezzo = await risposta.transform(utf8.decoder).join();
          if (risposta.statusCode == 401) {
            gettone = await _gettone();
            continue;
          }
          if (risposta.statusCode == 429 || risposta.statusCode >= 500) {
            await Future<void>.delayed(Duration(seconds: 5 * (tentativo + 1)));
            continue;
          }
          if (risposta.statusCode != 200) {
            stderr.writeln('HTTP ${risposta.statusCode}: $grezzo');
            return null;
          }
          return jsonDecode(grezzo) as Map<String, dynamic>;
        } finally {
          client.close(force: true);
        }
      }
      return null;
    }

    final righe = <String>[
      'BANCO DI MEDORA E DEL CIELO, ordine EV voce 03. '
          '${prima ? 'COME PRIMA DELL\'ORDINE EV (senza funzioni, senza Urano, '
              'Nettuno e Plutone).' : 'CODICE DELL\'ORDINE EV.'}',
      'Eseguito il ${adesso.toIso8601String()} da tool/medora_e_il_cielo.dart: '
          'modello ${FirebaseMaestroAiProvider.kMaestroChatModel} in $regione, '
          'istruzione e configurazione vere dell\'app, funzioni del cielo '
          'eseguite dal codice dell\'app, rete del cielo detto applicata come '
          'in chat.',
      'Domande dispari: persona con i dati di nascita (Sole in '
          '${conNascita.sunSign}). Pari: '
          'persona senza dati di nascita.',
      '',
    ];

    for (var i = 0; i < domande.length; i++) {
      final (domanda, giorni, periodo) = domande[i];
      final natal = i.isEven ? conNascita : NatalContext.none;
      final contenuti = <Map<String, Object?>>[
        {
          'role': 'user',
          'parts': [
            {'text': domanda}
          ]
        }
      ];
      final chiamate = <String>[];
      final giorniDaQui = LeFunzioniDelCielo.giorniChiesti.length;
      String testo = '';
      String motivo = '';
      var sollecitato = false;
      for (var giro = 0; giro < 5; giro++) {
        final d = await chiama({
          'systemInstruction': {
            'parts': [
              {'text': istruzione(natal)}
            ]
          },
          'contents': contenuti,
          if (!prima) 'tools': strumenti,
          'generationConfig': config,
        });
        if (d == null) break;
        final c = (d['candidates'] as List).first as Map<String, dynamic>;
        motivo = '${c['finishReason']}';
        final contenuto = (c['content'] as Map?)?.cast<String, Object?>() ??
            const <String, Object?>{};
        final parti = ((contenuto['parts'] as List?) ?? const [])
            .cast<Map<String, dynamic>>();
        final funzioni = [
          for (final p in parti)
            if (p['functionCall'] != null)
              (p['functionCall'] as Map).cast<String, dynamic>()
        ];
        if (funzioni.isEmpty) {
          testo = parti
              .where((p) => p['thought'] != true)
              .map((p) => '${p['text'] ?? ''}')
              .join()
              .trim();
          // Il sollecito dell'app quando la risposta rimanda (come nel
          // provider, `LeFunzioniDelCielo.rimanda`).
          if (!prima &&
              !sollecitato &&
              chiamate.isEmpty &&
              LeFunzioniDelCielo.rimanda(domanda: domanda, risposta: testo)) {
            sollecitato = true;
            chiamate.add('(sollecito: la prima risposta rimandava: "$testo")');
            contenuti.add({'role': 'model', 'parts': parti});
            contenuti.add({
              'role': 'user',
              'parts': [
                {'text': LeFunzioniDelCielo.sollecito}
              ]
            });
            continue;
          }
          break;
        }
        contenuti.add({'role': 'model', 'parts': parti});
        final risposte = <Map<String, Object?>>[];
        for (final f in funzioni) {
          final nome = '${f['name']}';
          final args = ((f['args'] as Map?) ?? const {}).cast<String, Object?>();
          chiamate.add('$nome(${jsonEncode(args)})');
          final esito = nome == LeFunzioniDelCielo.cieloDelGiorno
              ? LeFunzioniDelCielo.giorno(args)
              : LeFunzioniDelCielo.periodo(args);
          risposte.add({
            'functionResponse': {'name': nome, 'response': esito}
          });
        }
        contenuti.add({'role': 'user', 'parts': risposte});
      }
      final diNascita = {
        if (natal.sunSign case final s?) 'Sole': s,
        if (natal.moonSign case final l?) 'Luna': l,
      };
      final altri = LeFunzioniDelCielo.giorniDa(giorniDaQui);
      final smentite = IlCieloDetto.smentite(testo,
          adesso: adesso, diNascita: diNascita, altriGiorni: altri);
      final aVideo = IlCieloDetto.senzaLeSmentite(testo,
          adesso: adesso, diNascita: diNascita, altriGiorni: altri);
      righe
        ..add('=' * 72)
        ..add('${i + 1}. ${i.isEven ? '[con nascita]' : '[senza nascita]'} '
            '$domanda')
        ..add('Funzioni chiamate: ${chiamate.isEmpty ? 'nessuna' : chiamate.join('; ')}')
        ..add('Fine: $motivo')
        ..add('RISPOSTA DI MEDORA (a video):')
        ..add(aVideo)
        ..add(smentite.isEmpty
            ? 'Frasi tolte dalla rete del cielo detto: nessuna'
            : 'Frasi tolte dalla rete del cielo detto: '
                '${smentite.map((s) => s.frase).join(' | ')}')
        ..add('FATTI DALLE EFFEMERIDI DELL\'APP:');
      for (final giorno in giorni) {
        final p = giorno.split('-').map(int.parse).toList();
        righe.add(IlCieloPerIlMaestro.oggiInRighe(DateTime(p[0], p[1], p[2]))
            .replaceFirst('IL CIELO DI OGGI', 'IL CIELO DEL'));
        final dg = IlCieloPerIlMaestro.delGiorno(DateTime(p[0], p[1], p[2]));
        if (dg['eclissi'] != null) righe.add('Eclissi quel giorno: ${dg['eclissi']}');
        righe.add('Precisione: ${dg['precisione']}');
      }
      if (periodo != null) {
        final (dal, al) = periodo;
        final a = dal.split('-').map(int.parse).toList();
        final b = al.split('-').map(int.parse).toList();
        final pr = IlCieloPerIlMaestro.delPeriodo(
            DateTime(a[0], a[1], a[2]), DateTime(b[0], b[1], b[2]));
        righe.add('Eventi dal $dal al $al: '
            '${(pr['eventi']! as List).join('; ')}');
      }
      righe.add('');
      print('${i + 1}/${domande.length} ${chiamate.length} chiamate');
    }
    File(uscita).writeAsStringSync('${righe.join('\n')}\n');
    print('Scritto $uscita');
  }, timeout: const Timeout(Duration(minutes: 30)));
}

Future<String?> _gettone() async {
  try {
    final esito = await Process.run('gcloud', ['auth', 'print-access-token'],
        runInShell: true);
    if (esito.exitCode != 0) return null;
    final t = (esito.stdout as String).trim();
    return t.isEmpty ? null : t;
  } catch (_) {
    return null;
  }
}
