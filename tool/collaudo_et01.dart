// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_controller.dart';
import 'package:esoteric_circle/features/maestri/live/le_tre_frasi_del_live.dart';
import 'package:esoteric_circle/services/ai/firebase_maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/registro_dei_guasti.dart';
import 'package:esoteric_circle/services/ai/voce_sorvegliata.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'la_voce_vera_di_gemini.dart';

/// **IL BANCO DELLE TRENTA DOMANDE, ordine ET voci 01, 02, 03 e 06.** 28
/// settembre 2026.
///
/// Il fondatore: *"Bisogna fare delle prove, 30 domande per ogni maestro, con
/// domande classiche q più frequenti. Gli utenti faranno domande personali e
/// anche intime nella maggior parte dei casi. Ma anche per la fortuna e
/// lavoro."* Le trenta domande le ha scritte l'Architetto; le coppie A..E sono
/// domande simili fatte una dopo l'altra (voce ET.03).
///
/// Per ogni Maestro, canale (chat scritta e LIVE) ed esecuzione, una
/// conversazione di trenta domande di seguito, col vero
/// `MaestroChatController` e il vero modello in europe-west1: le reti, le
/// rigenerazioni e la lettura di ripiego sono quelle dell'app. Due esecuzioni
/// con due profili diversi: una donna Scorpione e un uomo Leone.
///
/// Per ogni risposta si scrive la risposta intera (quella che la chat
/// salva), nel LIVE anche quella detta dal Maestro, da dove viene (modello o
/// ripiego), quali reti sono intervenute, il tempo e i gettoni del modello.
///
/// ```
/// VERTEX_TOKEN=... flutter test tool/collaudo_et01.dart \
///   --dart-define=FASE=prima --dart-define=CANALI=chat,live
/// ```
///
/// Le trascrizioni vanno in `docs/collaudo/ET/trenta_domande/<fase>/`.
const String fase = String.fromEnvironment('FASE', defaultValue: 'dopo');
const String canali =
    String.fromEnvironment('CANALI', defaultValue: 'chat,live');
const String esecuzioni =
    String.fromEnvironment('ESECUZIONI', defaultValue: '1,2');
const String maestri =
    String.fromEnvironment('MAESTRI', defaultValue: 'medora,aura,caligo');

/// **QUALE ELENCO DI DOMANDE.** `trenta` (le trenta dell'ordine ET, voce
/// ET.01) oppure `er12`: le dodici domande di seguito del LIVE dell'ordine
/// EQ voce 03, le stesse dei trentasei turni della voce ER.12, per la voce
/// ET.06 (le quattro frasi quando la domanda ha piu' parti). Con `er12` il
/// canale e' il LIVE, il profilo e' l'uomo di [profili] in tutte e due le
/// esecuzioni (le domande parlano di "una compagna" e di "sentirsi solo"),
/// e le trascrizioni vanno in `docs/collaudo/ET/live_quattro_frasi/<fase>/`.
const String quali = String.fromEnvironment('DOMANDE', defaultValue: 'trenta');

/// Le dodici domande del LIVE dell'ordine EQ voce 03
/// (`docs/collaudo/EQ/eq03/dopo_seconda_stesura/`), nell'ordine.
const List<String> domandeEr12 = [
  'Ciao, chi sei? Come puoi aiutarmi?',
  'Beh, vorrei avere una compagna, vorrei andare in Australia e vorrei '
      'avessi successo col lavoro che sto facendo.',
  'Ok, gli ho scritto adesso.',
  'Ok, le ho scritte e adesso cosa faccio?',
  'Da dove comincio, dal lavoro o dal viaggio?',
  'Il mio capo non mi dà mai un riconoscimento. Come glielo chiedo?',
  'Ho paura che in Australia mi senta solo.',
  'Mia madre dice che è una follia partire. Cosa le rispondo?',
  'Ok, ci ho parlato stamattina e ha pianto.',
  'Quanto tempo mi serve per decidere?',
  'Ho scelto: parto a marzo. E adesso?',
  'Grazie. Cosa faccio domani mattina, appena sveglio?',
];

/// L'elenco di questo giro.
/// **LE TRENTA DOMANDE COME LE SCRIVE LA VOCE.** Con `DOMANDE=voce` le
/// trenta domande arrivano senza punto interrogativo, col punto al suo
/// posto: cosi' le ha scritte la trascrizione del LIVE sul Realme in tredici
/// domande su diciassette (ordine ET, 28 settembre 2026). Le trascrizioni
/// vanno in `docs/collaudo/ET/trenta_domande_a_voce/<fase>/`.
List<String> get leDomande => switch (quali) {
      'er12' => domandeEr12,
      'voce' => [
          for (final d in domande)
            d.replaceAll(RegExp(r'\?\s*$'), '.').replaceAll('?', '.')
        ],
      _ => domande,
    };

/// Le trenta domande dell'ordine ET, nell'ordine scritto.
const List<String> domande = [
  // Amore e intimita'.
  'Lui mi ama davvero?',
  'Ma mi ama ancora, dopo tutto quello che è successo?',
  'Il mio ex tornerà da me?',
  'Devo scrivergli io o aspettare che si faccia vivo lui?',
  'Il mio compagno mi tradisce?',
  'Perché non ho più desiderio con la persona che ho accanto?',
  'Troverò l\'amore quest\'anno?',
  'Quando incontrerò la persona giusta?',
  'Sono innamorata di due persone: chi devo scegliere?',
  'Perché attiro sempre persone che mi fanno soffrire?',
  'È giusto che lo sposi?',
  'Mi sento sola anche in coppia: che cosa mi manca?',
  'Mia madre non accetta la persona che amo: come faccio?',
  'Riuscirò ad avere un figlio?',
  'Posso fidarmi di nuovo dopo un tradimento?',
  'Gli piaccio? Mi guarda sempre ma non mi dice niente.',
  'Come faccio a dimenticare chi mi ha lasciata?',
  'Sono felice nella mia relazione o mi sto accontentando?',
  // Fortuna e denaro.
  'Quando cambierà la mia fortuna?',
  'Questa settimana mi conviene giocare?',
  'Riuscirò a uscire dai debiti?',
  'Riuscirò a comprare casa?',
  'Perché i soldi non mi bastano mai?',
  'Come posso guadagnare di più?',
  // Lavoro.
  'Mi prenderanno al colloquio di giovedì?',
  'Il colloquio di giovedì andrà bene?',
  'Devo lasciare il mio lavoro per aprire un\'attività mia?',
  'Il mio capo mi apprezza?',
  'Avrò la promozione quest\'anno?',
  'Qual è il lavoro fatto davvero per me?',
];

/// Le cinque coppie di domande simili di fila: il numero della prima e della
/// seconda, contando da uno (voce ET.03).
const Map<String, (int, int)> coppie = {
  'A': (1, 2),
  'B': (3, 4),
  'C': (7, 8),
  'D': (23, 24),
  'E': (25, 26),
};

/// I due profili delle due esecuzioni.
final Map<int, ({String chi, CourtesyForm forma, NatalContext natal})> profili =
    {
  1: (
    chi: 'una donna Scorpione, ascendente Cancro, Luna in Pesci, numero 7',
    forma: CourtesyForm.feminine,
    natal: const NatalContext(
      sunSign: 'Scorpione',
      moonSign: 'Pesci',
      ascendant: 'Cancro',
      lifeNumber: 7,
      lifeNumberTitle: 'il Cercatore',
    ),
  ),
  2: (
    chi: 'un uomo Leone, ascendente Capricorno, Luna in Toro, numero 4',
    forma: CourtesyForm.masculine,
    natal: const NatalContext(
      sunSign: 'Leone',
      moonSign: 'Toro',
      ascendant: 'Capricorno',
      lifeNumber: 4,
      lifeNumberTitle: 'il Costruttore',
    ),
  ),
};

class Turno {
  Turno(this.n, this.domanda);
  final int n;
  final String domanda;
  String risposta = '';
  String detta = '';
  bool ripiego = false;
  int millesimi = 0;
  int chiamate = 0;
  int ingresso = 0;
  int uscita = 0;
  final List<String> reti = [];

  /// Ogni testo del modello nel turno, nell'ordine delle chiamate: quelli
  /// prima dell'ultimo sono le risposte che una rete ha fatto rifare. Il
  /// rapporto dell'ordine ET chiede quali guardie hanno fermato una risposta
  /// diretta, e senza i testi scartati non si poteva dire.
  final List<String> grezzi = [];
}

/// I contatori pubblici delle reti del controller: la differenza fra prima e
/// dopo un turno dice quali reti sono intervenute.
Map<String, int> contatori(MaestroChatController c) => {
      'ancoraggio': c.rigenerazioniPerAncoraggio,
      'ripetizione': c.rigenerazioniPerRipetizione,
      'programma': c.rigenerazioniPerProgramma,
      'attesa': c.rigenerazioniPerAttesa,
      'riga d\'oro richiesta': c.rigenerazioniPerRigaDOro,
      'riga d\'oro tolta': c.righeDOroTolte,
      'rimando spostato in fondo': c.rimandiSpostatiInFondo,
      'troncatura': c.rigenerazioniPerTroncatura,
      'lettura ridetta': c.lettureRidette,
      'frase del cielo smentita': c.frasiDelCieloSmentite,
      'risposta vuota richiesta': c.rigenerazioniPerVuota,
      'prima frase senza posizione richiesta': c.rigenerazioniPerPosizione,
      'certezza richiesta': c.rigenerazioniPerCertezza,
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final cartella = Directory(switch (quali) {
    'er12' => 'docs/collaudo/ET/live_quattro_frasi/$fase',
    'voce' => 'docs/collaudo/ET/trenta_domande_a_voce/$fase',
    _ => 'docs/collaudo/ET/trenta_domande/$fase',
  });
  final conto = StringBuffer();

  setUpAll(() {
    HttpOverrides.global = null;
    cartella.createSync(recursive: true);
  });

  tearDownAll(() {
    File('${cartella.path}/_conto.txt').writeAsStringSync(
        'Modelli: chat ${FirebaseMaestroAiProvider.kMaestroChatModel}, LIVE '
        '${FirebaseMaestroAiProvider.modelloDelTurno(nelLive: true)}; '
        'europe-west1.\n\n$conto');
  });

  for (final canale in canali.split(',')) {
    for (final k in esecuzioni.split(',').map(int.parse)) {
      for (final id in maestri.split(',')) {
        final maestro = Maestro.values.firstWhere((m) => m.id == id);
        test('ET.01 $fase, $canale, esecuzione $k, $id', () async {
          final profilo = profili[quali == 'er12' ? 2 : k]!;
          LaMarcaDelGenere.formaCorrente = profilo.forma;
          final voce = VoceVeraDiGemini();
          await voce.scaldaIlGettone();
          final controller = MaestroChatController(
            maestro: maestro,
            ai: VoceSorvegliata(voce: voce, registro: RegistroDeiGuasti()),
            memory: InMemoryMaestroMemoryRepository(),
            allowance: QuestionAllowance(freeDailyLimit: 999),
            tier: () => Tier.free,
            natal: () => profilo.natal,
            attesaMinima: Duration.zero,
          )..nelLive = canale == 'live';
          await controller.init();
          final turni = <Turno>[];
          for (var i = 0; i < leDomande.length; i++) {
            final t = Turno(i + 1, leDomande[i]);
            final quante = voce.grezze.length;
            final primaDelTurno = contatori(controller);
            await controller.send(t.domanda);
            final ultima = controller.messages.last;
            if (ultima.role == ChatRole.maestro) {
              t
                ..risposta = ultima.text
                ..ripiego = ultima.ripiego;
            }
            t.detta = canale == 'live'
                ? LeTreFrasiDelLive.di(t.risposta, domanda: t.domanda)
                : '';
            final grezze = voce.grezze.skip(quante).toList();
            t.grezzi.addAll(grezze.map((g) => g.testo));
            t
              ..chiamate = grezze.length
              ..millesimi =
                  grezze.fold<int>(0, (a, g) => a + g.durata.inMilliseconds)
              ..ingresso = grezze.fold<int>(0, (a, g) => a + g.ingresso)
              ..uscita = grezze.fold<int>(0, (a, g) => a + g.uscita);
            final dopoIlTurno = contatori(controller);
            for (final e in dopoIlTurno.entries) {
              final quanti = e.value - primaDelTurno[e.key]!;
              if (quanti > 0) t.reti.add('${e.key} $quanti');
            }
            turni.add(t);
          }
          final ripieghi = turni.where((t) => t.ripiego).length;
          final chiamate = turni.fold<int>(0, (a, t) => a + t.chiamate);
          final ingresso = turni.fold<int>(0, (a, t) => a + t.ingresso);
          final uscita = turni.fold<int>(0, (a, t) => a + t.uscita);
          final riga = 'ET.01 $fase $canale esecuzione $k $id: risposte '
              '${turni.length}, ripieghi $ripieghi, chiamate al modello '
              '$chiamate, gettoni in ingresso $ingresso, in uscita $uscita';
          print(riga);
          conto.writeln(riga);
          _scrivi(cartella, canale, k, maestro, profilo.chi, turni, riga);
          expect(turni.length, leDomande.length);
        }, timeout: const Timeout(Duration(minutes: 30)));
      }
    }
  }
}

void _scrivi(Directory cartella, String canale, int k, Maestro maestro,
    String chi, List<Turno> turni, String riga) {
  final b = StringBuffer()
    ..writeln('# ${maestro.displayName}, $canale, esecuzione $k, fase $fase')
    ..writeln()
    ..writeln('Profilo: $chi.')
    ..writeln(riga)
    ..writeln();
  for (final t in turni) {
    b
      ..writeln('## ${t.n}. ${t.domanda}')
      ..writeln()
      ..writeln('> ${t.risposta.replaceAll('\n', '\n> ')}')
      ..writeln();
    if (canale == 'live') b.writeln('- detta nel LIVE: ${t.detta}');
    b
      ..writeln('- da dove viene: ${t.ripiego ? 'RIPIEGO' : 'modello'}')
      ..writeln('- reti intervenute: '
          '${t.reti.isEmpty ? 'nessuna' : t.reti.join(', ')}')
      ..writeln('- chiamate al modello ${t.chiamate}, tempo ${t.millesimi} ms, '
          'gettoni ${t.ingresso} in ingresso e ${t.uscita} in uscita')
      ..writeln();
    if (t.grezzi.length > 1) {
      b
        ..writeln('- testi del modello rifatti da una rete:')
        ..writeln();
      for (var i = 0; i < t.grezzi.length - 1; i++) {
        b.writeln('  ${i + 1}. «${t.grezzi[i].replaceAll('\n', ' ')}»');
      }
      b.writeln();
    }
  }
  b.writeln('## LE CINQUE COPPIE, AFFIANCATE');
  b.writeln();
  for (final c in quali == 'er12'
      ? const <MapEntry<String, (int, int)>>[]
      : coppie.entries) {
    final a = turni[c.value.$1 - 1];
    final z = turni[c.value.$2 - 1];
    b
      ..writeln('### Coppia ${c.key}')
      ..writeln()
      ..writeln('${a.n}. ${a.domanda}')
      ..writeln('> ${a.risposta.replaceAll('\n', ' ')}')
      ..writeln()
      ..writeln('${z.n}. ${z.domanda}')
      ..writeln('> ${z.risposta.replaceAll('\n', ' ')}')
      ..writeln();
  }
  File('${cartella.path}/${maestro.id}_${canale}_esecuzione_$k.md')
      .writeAsStringSync(b.toString());
}
