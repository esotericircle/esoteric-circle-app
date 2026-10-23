import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/domande/domande_del_cerchio.dart';
import 'package:esoteric_circle/core/maestro/misura_della_risposta.dart';
import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/core/rituals/runes.dart';
import 'package:esoteric_circle/services/ai/firebase_maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_persona.dart';
import 'package:flutter_test/flutter_test.dart';

/// LA MISURA (a) DEL PRESAGIO: due domande diverse danno due presagi diversi?
///
/// **Ordine S voce 19, punto 6 della decisione D5, riclassificato dalla D5 stessa:
/// questa NON e' una prova della suite, e' una MISURA.** Si esegue una volta contro
/// il modello vero, si riporta col numero nel rapporto, e non e' una guardia verde:
/// e' lo stesso trattamento dell'attribuzione cieca delle tre voci, che sta al 98,3
/// per cento e non e' mai stata un semaforo.
///
/// **Perche' non puo' vivere nella suite.** Serve una chiamata vera a Vertex, quindi
/// serve una sessione `gcloud` attiva e si spende credito. `flutter test` guarda solo
/// `test/`, quindi da qui non parte mai da solo: e' la stessa collocazione, e la
/// stessa ragione, di `tool/attribuzione_cieca.dart`.
///
/// ```
/// flutter test tool/misura_del_presagio.dart
/// ```
///
/// **Cosa misura, in una riga.** A parita' di runa, quanta parte delle PAROLE PIENE
/// condividono fra loro i presagi nati da domande diverse. Se il modello rispondesse
/// alla runa e ignorasse la domanda, i sedici presagi della stessa runa si
/// somiglierebbero quasi al cento per cento: la sovrapposizione alta e' il difetto,
/// quella bassa e' la prova che la domanda conta.
///
/// **IL CAMPIONE E' DICHIARATO, non scelto a occhio**, ed e' quello proposto da
/// Mauro: TRE RUNE FISSE per tutte e SEDICI le domande, cioe' QUARANTOTTO presagi.
/// Le tre rune non sono estratte a caso, e il perche' e' scritto accanto a ognuna.
/// Il precedente in casa e' l'attribuzione cieca, misurata su sessanta risposte.
///
/// **STAMPA ANCHE IL COSTO**, cioe' quante chiamate ha fatto: il credito Blaze
/// finisce il 24 settembre 2026 e ogni numero che si spende va saputo. Quarantotto
/// presagi sono quarantotto chiamate, piu' zero: non c'e' un giudice, perche' qui il
/// confronto e' aritmetico e non serve un secondo modello.
void main() {
  const progetto = 'esoteric-circle';
  const regione = 'europe-west1';

  /// Lo stesso modello che l'app usa per il presagio, non un altro: misurare un
  /// modello diverso da quello che le persone leggono non misura niente.
  const modello = FirebaseMaestroAiProvider.kMaestroBreveModel;

  /// LE TRE RUNE DEL CAMPIONE, e ognuna sta qui per una ragione.
  ///
  /// **Fehu**, la prima dell'Elder Futhark, dritta: e' il caso piu' comune, una
  /// runa di sostanza in verso positivo.
  /// **Hagalaz**, dritta: e' la runa della grandine, cioe' un significato duro, e
  /// serve a vedere se il modello sa portare una domanda leggera dentro un simbolo
  /// severo senza forzare ne' l'una ne' l'altro.
  /// **Othala in merkstave**: un verso d'ombra su una runa di radici, il caso in cui
  /// e' piu' facile che il modello si appoggi al simbolo e lasci cadere la domanda.
  final campione = <({Rune runa, RuneVerso verso, String perche})>[
    (
      runa: kElderFuthark.firstWhere((r) => r.name == 'Fehu'),
      verso: RuneVerso.dritto,
      perche: 'il caso comune: sostanza, verso positivo',
    ),
    (
      runa: kElderFuthark.firstWhere((r) => r.name == 'Hagalaz'),
      verso: RuneVerso.dritto,
      perche: 'significato duro: la domanda leggera dentro il simbolo severo',
    ),
    (
      runa: kElderFuthark.firstWhere((r) => r.name == 'Othala'),
      verso: RuneVerso.merkstave,
      perche: 'verso d\'ombra: il caso in cui il simbolo tende a coprire la '
          'domanda',
    ),
  ];

  /// Le sedici domande della gettata, dal punto unico: otto generiche e otto
  /// personali. Non si sceglie un sottoinsieme, perche' il campione dichiarato dice
  /// tutte e sedici.
  final domande = [
    ...DomandeDelCerchio.generichePerLaGettata,
    ...DomandeDelCerchio.personaliPerLaGettata,
  ];

  /// Quante chiamate insieme. Basso apposta, come nell'attribuzione cieca: la quota
  /// conta piu' della fretta.
  const insieme = 4;

  /// LE PAROLE VUOTE, le stesse della prova (b) in `test/le_sedici_cornici_test.dart`.
  ///
  /// **Stanno scritte due volte, e va detto perche'.** Il punto unico sarebbe
  /// meglio, ma questo strumento non deve poter cambiare il comportamento dell'app:
  /// vive in `tool/`, fuori da `lib/`, e portare qui una dipendenza nuova per un
  /// elenco di articoli e preposizioni sarebbe un prezzo piu' alto della copia. Se
  /// un giorno le due liste divergono, i due numeri diventano incomparabili, e
  /// questa riga e' il posto in cui accorgersene.
  const vuote = {
    'il', 'lo', 'la', 'le', 'gli', 'un', 'una', 'uno', 'del', 'della', 'dei',
    'delle', 'di', 'da', 'in', 'su', 'per', 'con', 'tra', 'fra', 'che', 'chi',
    'cosa', 'come', 'dove', 'quando', 'quale', 'quali', 'mi', 'ti', 'si', 'ci',
    'vi', 'me', 'te', 'se', 'non', 'ma', 'poi', 'anche', 'ancora', 'sono', 'e',
    'ed', 'o', 'al', 'allo', 'alla', 'ai', 'agli', 'alle', 'nel', 'nella',
    'sul', 'sulla', 'mio', 'mia', 'miei', 'mie', 'tuo', 'tua', 'tuoi', 'tue',
    'questo', 'questa', 'questi', 'queste', 'sto', 'stai', 'devo', 'adesso',
    'ora', 'oggi',
  };

  Set<String> paroleP1ene(String testo) => testo
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-zàèéìòóù\s]'), ' ')
      .split(RegExp(r'\s+'))
      .where((p) => p.length >= 4 && !vuote.contains(p))
      .toSet();

  test('MISURA (a): la domanda cambia il presagio', () async {
    final gettone = await _gettone();
    if (gettone == null) {
      fail('Nessun gettone di accesso. Serve una sessione gcloud attiva: '
          'gcloud auth login');
    }

    var chiamate = 0;
    var falliteDelModello = 0;

    Future<String?> chiediIlPresagio({
      required String istruzione,
      required String fatti,
    }) async {
      chiamate++;
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
              {'text': fatti}
            ]
          }
        ],
        // Gli stessi numeri dell'app: temperatura, topP, tetto e ragionamento
        // arrivano dalla stessa misura che usa `FirebaseMaestroAiProvider`.
        'generationConfig': {
          'temperature': 0.9,
          'topP': 0.95,
          'maxOutputTokens': MisuraDellaRisposta.letturaDellaChat.tetto,
          'thinkingConfig': {
            'thinkingBudget': MisuraDellaRisposta.letturaDellaChat.ragionamento,
          },
          'responseMimeType': 'application/json',
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
          falliteDelModello++;
          return null;
        }
        final decodificato = jsonDecode(testo) as Map<String, dynamic>;
        final candidati = decodificato['candidates'] as List?;
        if (candidati == null || candidati.isEmpty) {
          falliteDelModello++;
          return null;
        }
        final parti =
            ((candidati.first as Map)['content'] as Map?)?['parts'] as List?;
        if (parti == null || parti.isEmpty) {
          falliteDelModello++;
          return null;
        }
        final grezzo = (parti.first as Map)['text']?.toString().trim();
        if (grezzo == null || grezzo.isEmpty) {
          falliteDelModello++;
          return null;
        }
        // Le tre parti si rimettono insieme come fa l'app: la misura guarda il
        // presagio intero, cioe' quello che la persona legge.
        try {
          final inizio = grezzo.indexOf('{');
          final fine = grezzo.lastIndexOf('}');
          if (inizio < 0 || fine <= inizio) return grezzo;
          final json = jsonDecode(grezzo.substring(inizio, fine + 1));
          if (json is! Map) return grezzo;
          return [
            json['risposta'],
            json['cosaPuoiFare'],
            json['daDoveViene'],
          ].whereType<String>().join('\n\n');
        } catch (_) {
          return grezzo;
        }
      } finally {
        client.close(force: true);
      }
    }

    final istruzione = MaestroPersona.presagioInstruction(
      profile: UserProfile.empty,
      memory: MaestroMemory.empty,
    );

    stdout.writeln('');
    stdout.writeln('=== MISURA (a) DEL PRESAGIO, ordine S voce 19 ===');
    stdout.writeln('Modello: $modello, progetto $progetto, regione $regione.');
    stdout.writeln('CAMPIONE DICHIARATO: ${campione.length} rune per '
        '${domande.length} domande = ${campione.length * domande.length} '
        'presagi.');
    for (final c in campione) {
      final verso = c.verso == RuneVerso.merkstave ? 'in merkstave' : 'diritta';
      stdout.writeln('  - ${c.runa.name} $verso: ${c.perche}');
    }
    stdout.writeln('');

    // Per ogni runa: i presagi delle sedici domande, poi la sovrapposizione media
    // fra tutte le coppie di domande diverse.
    final perRuna = <String, double>{};
    final massimoPerRuna = <String, ({double quanto, String coppia})>{};
    var condivisePeggiori = 0.0;

    for (final c in campione) {
      final verso = c.verso == RuneVerso.merkstave ? 'in merkstave' : 'diritta';
      final etichetta = '${c.runa.name} $verso';
      final presagi = <String, Set<String>>{};

      // A gruppi di [insieme], per non spingere sulla quota.
      for (var i = 0; i < domande.length; i += insieme) {
        final fetta = domande.skip(i).take(insieme).toList();
        final esiti = await Future.wait(fetta.map((d) async {
          final fatti = 'Gettata: Runa di Odino.\n'
              'Pietre uscite:\n'
              '- ${c.runa.name}, $verso, per il consiglio essenziale: '
              '${c.runa.meaning}\n'
              'Domanda posta dalla persona: «${d.testo}».\n';
          final testo = await chiediIlPresagio(
              istruzione: istruzione, fatti: fatti);
          return (domanda: d.testo, testo: testo);
        }));
        for (final e in esiti) {
          if (e.testo == null) continue;
          presagi[e.domanda] = paroleP1ene(e.testo!);
        }
      }

      // La sovrapposizione di Jaccard fra ogni coppia di domande diverse: quante
      // parole piene hanno in comune sul totale delle parole piene delle due.
      final chiavi = presagi.keys.toList();
      final sovrapposizioni = <double>[];
      var peggiore = 0.0;
      var coppiaPeggiore = '';
      for (var i = 0; i < chiavi.length; i++) {
        for (var j = i + 1; j < chiavi.length; j++) {
          final a = presagi[chiavi[i]]!;
          final b = presagi[chiavi[j]]!;
          final unione = a.union(b).length;
          if (unione == 0) continue;
          final quanto = a.intersection(b).length / unione;
          sovrapposizioni.add(quanto);
          if (quanto > peggiore) {
            peggiore = quanto;
            coppiaPeggiore = '«${chiavi[i]}» e «${chiavi[j]}»';
          }
        }
      }
      if (sovrapposizioni.isEmpty) {
        stdout.writeln('$etichetta: nessun presagio riuscito.');
        continue;
      }
      final media =
          sovrapposizioni.reduce((x, y) => x + y) / sovrapposizioni.length;
      perRuna[etichetta] = media;
      massimoPerRuna[etichetta] = (quanto: peggiore, coppia: coppiaPeggiore);
      condivisePeggiori = max(condivisePeggiori, peggiore);
      stdout.writeln('$etichetta: presagi riusciti ${presagi.length} su '
          '${domande.length}, coppie confrontate ${sovrapposizioni.length}.');
      stdout.writeln('  sovrapposizione MEDIA  '
          '${(media * 100).toStringAsFixed(1)} per cento');
      stdout.writeln('  sovrapposizione MASSIMA '
          '${(peggiore * 100).toStringAsFixed(1)} per cento, fra '
          '$coppiaPeggiore');
    }

    stdout.writeln('');
    if (perRuna.isEmpty) {
      stdout.writeln('NESSUN NUMERO: il modello non ha risposto a nessuna '
          'chiamata. Il costo speso e\' comunque $chiamate chiamate.');
    } else {
      final mediaGenerale =
          perRuna.values.reduce((x, y) => x + y) / perRuna.length;
      stdout.writeln('=== I DUE NUMERI DELLA MISURA (a) ===');
      stdout.writeln('SOVRAPPOSIZIONE MEDIA fra presagi di domande diverse, a '
          'parita\' di runa: ${(mediaGenerale * 100).toStringAsFixed(1)} per '
          'cento.');
      stdout.writeln('SOVRAPPOSIZIONE MASSIMA su tutte le coppie: '
          '${(condivisePeggiori * 100).toStringAsFixed(1)} per cento.');
      stdout.writeln('');
      stdout.writeln('COME SI LEGGONO. Piu\' i numeri sono BASSI, piu\' la '
          'domanda conta: se il modello rispondesse alla runa ignorando la '
          'domanda, i sedici presagi della stessa runa si somiglierebbero quasi '
          'del tutto. Non c\'e\' una soglia dichiarata: la decisione D5 chiede il '
          'NUMERO da riportare, e la soglia la fissa Mauro dopo averlo visto.');
    }
    stdout.writeln('');
    stdout.writeln('=== IL COSTO ===');
    stdout.writeln('Chiamate al modello: $chiamate.');
    stdout.writeln('Chiamate senza risposta utile: $falliteDelModello.');
    stdout.writeln('Nessun giudice: il confronto e\' aritmetico, quindi non c\'e\' '
        'una seconda serie di chiamate.');
    stdout.writeln('');

    // **NON E' UNA GUARDIA, e questa riga lo tiene vero.** Lo strumento fallisce
    // solo se non ha potuto misurare niente: il numero non ha una soglia qui.
    expect(perRuna, isNotEmpty,
        reason: 'nessun presagio e\' arrivato: la misura non esiste, e il '
            'credito speso e\' di $chiamate chiamate');
  }, timeout: const Timeout(Duration(minutes: 20)));
}

/// Il gettone di accesso dalla sessione `gcloud` di chi lancia lo strumento.
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
  } catch (errore) {
    stderr.writeln('gcloud non risponde: $errore');
    return null;
  }
}
