// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/maestro/consiglio_finale.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/maestro/voce_del_maestro.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_controller.dart';
import 'package:esoteric_circle/services/ai/firebase_maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/registro_dei_guasti.dart';
import 'package:esoteric_circle/services/ai/voce_sorvegliata.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'la_voce_vera_di_gemini.dart';

/// **IL COLLAUDO DELLE DOMANDE DI CONFINE, ordine EQ voce 02.** 27 settembre
/// 2026.
///
/// Nelle catture, a *"Beh, vorrei avere una compagna, vorrei andare in
/// Australia e vorrei avessi successo col lavoro che sto facendo."*, Calìgo
/// apre con *"Per i legami e il destino c'è Medora, perciò rivolgi a lei le
/// domande sull'amore."* e dell'Australia non dice niente. Il fondatore ha
/// scelto *"Prima la sua arte"*: il Maestro risponde nel merito con la sua
/// arte a ogni parte della domanda, e l'altro Maestro lo nomina solo in
/// fondo, come consiglio in piu'.
///
/// Si fanno domande di confine a ciascuno dei tre, ognuna in una
/// conversazione nuova, con Gemini vero, e si conta:
///
/// - **le prime frasi che rimandano a un altro Maestro**, a macchina: la
///   prima frase del corpo nomina uno degli altri due;
/// - **le parti della domanda senza risposta**, dal giudice a temperatura
///   zero, a maggioranza su tre, tarato sulla risposta vera delle catture;
/// - **le parole di firma degli altri due** nella risposta, a macchina: la
///   regola nuova non deve farle entrare.
///
/// **Due giri con dati diversi**: la domanda delle catture c'e' in tutti e
/// due, le altre cambiano.
///
/// ```
/// flutter test tool/collaudo_eq02.dart --dart-define=FASE=prima
/// flutter test tool/collaudo_eq02.dart --dart-define=FASE=dopo
/// ```
const String fase = String.fromEnvironment('FASE', defaultValue: 'dopo');

const natal = NatalContext(
  sunSign: 'Cancro',
  ascendant: 'Gemelli',
  lifeNumber: 3,
  lifeNumberTitle: 'il Creativo',
);

/// Una domanda di confine con le sue parti, ciascuna da rispondere.
class DiConfine {
  const DiConfine(this.domanda, this.parti);
  final String domanda;
  final List<String> parti;
}

const _delleCatture = DiConfine(
  'Beh, vorrei avere una compagna, vorrei andare in Australia e vorrei '
  'avessi successo col lavoro che sto facendo.',
  ['trovare una compagna', 'andare in Australia', 'il successo nel lavoro'],
);

const Map<String, Map<Maestro, List<DiConfine>>> giri = {
  'A': {
    Maestro.caligo: [
      _delleCatture,
      DiConfine('Cosa dice il mio oroscopo di questa settimana per l\'amore?',
          ['l\'amore in questa settimana']),
      DiConfine('Sento un peso sul petto da giorni: come posso scioglierlo?',
          ['il peso sul petto']),
    ],
    Maestro.medora: [
      DiConfine('Quale runa mi guida in questo periodo di cambiamenti?',
          ['la guida in questo periodo di cambiamenti']),
      DiConfine('Ho l\'ansia prima di dormire, cosa posso fare?',
          ['l\'ansia prima di dormire']),
      DiConfine(
          'Vorrei fare un rito per attirare denaro e capire se cambiare casa.',
          ['attirare denaro', 'cambiare casa']),
    ],
    Maestro.aura: [
      DiConfine('Quale carta dei tarocchi mi rappresenta oggi?',
          ['che cosa la rappresenta oggi']),
      DiConfine(
          'Mi leggi il mio numero della vita e cosa significa per il lavoro?',
          ['il numero della vita', 'il lavoro']),
      DiConfine('Il mio compagno è distante: torneremo vicini?',
          ['se torneranno vicini']),
    ],
  },
  'B': {
    Maestro.caligo: [
      _delleCatture,
      DiConfine('Mia sorella si sposa a maggio: sarà un buon matrimonio?',
          ['il matrimonio della sorella']),
      DiConfine(
          'Da una settimana ho mal di stomaco quando penso al lavoro. Cosa mi '
          'dice il corpo?',
          ['il mal di stomaco', 'il lavoro']),
    ],
    Maestro.medora: [
      DiConfine('Voglio aprire una bottega: mi fai un rito di buon auspicio?',
          ['aprire la bottega', 'un rito di buon auspicio']),
      DiConfine('Respiro male quando litigo con mio padre, come mi calmo?',
          ['calmarsi', 'il rapporto con il padre']),
      DiConfine('Che numero porta fortuna al mio matrimonio di giugno?',
          ['il numero fortunato', 'il matrimonio di giugno']),
    ],
    Maestro.aura: [
      DiConfine('Cosa dice la mia carta natale sul lavoro nuovo?',
          ['il lavoro nuovo']),
      DiConfine('Mi estrai una runa per sapere se partire per il Portogallo?',
          ['se partire per il Portogallo']),
      DiConfine('Sono innamorato di una collega: faccio il primo passo?',
          ['se fare il primo passo con la collega']),
    ],
  },
};

String _senzaAccenti(String s) => s
    .toLowerCase()
    .replaceAll('ì', 'i')
    .replaceAll('à', 'a')
    .replaceAll('è', 'e')
    .replaceAll('é', 'e')
    .replaceAll('ò', 'o')
    .replaceAll('ù', 'u');

/// L'altro Maestro nominato nella prima frase del corpo, o null.
String? rimandoNellaPrimaFrase(Maestro chi, String risposta) {
  final prima = _senzaAccenti(
      ConsiglioFinale.primaFraseDi(ConsiglioFinale.corpoDa(risposta)));
  for (final altro in Maestro.values) {
    if (altro == chi) continue;
    final nome = _senzaAccenti(VoceDelMaestro.nomeDetto(altro));
    if (RegExp('\\b$nome\\b').hasMatch(prima)) return nome;
  }
  return null;
}

/// Le parole di firma degli altri due che compaiono nella risposta.
List<String> firmeAltrui(Maestro chi, String risposta) {
  final t = _senzaAccenti(risposta);
  return [
    for (final p in VoceDelMaestro.lessicoDegliAltri(chi))
      if (RegExp('\\b${RegExp.escape(_senzaAccenti(p))}').hasMatch(t)) p,
  ];
}

const int _ragionamento = 512;

Future<bool> _aMaggioranza(Future<bool> Function() voto) async {
  var si = 0;
  for (var i = 0; i < 3; i++) {
    if (await voto()) si++;
  }
  return si >= 2;
}

/// **IL GIUDICE DELLA PARTE**: la risposta dice qualcosa di concreto su
/// [parte]? Rimandare a un altro consulente non e' rispondere.
///
/// **Conta la risposta data con l'arte del Maestro**, dalla seconda stesura:
/// la regola del fondatore e' proprio questa ("Calìgo: un rito per
/// l'amore"), e la prima stesura del giudice bocciava Medora che a "Quale
/// runa mi guida" rispondeva col Carro e un'indicazione precisa. Le
/// trascrizioni del prima si rigiudicano con questo stesso giudice,
/// `--dart-define=RIGIUDICA=prima`.
Future<bool> rispondeAllaParte(
        VoceVeraDiGemini voce, String domanda, String parte, String risposta) =>
    _aMaggioranza(() => voce.giudica(
          'Domanda della persona: "$domanda".\n'
          'Qui sotto c\'e\' la risposta di un consulente. Guarda soltanto '
          'questa parte della domanda: "$parte". La risposta ne dice qualcosa '
          'di concreto, cioe\' un\'indicazione, una lettura o un passo che '
          'riguardano proprio quella parte? NON conta rimandare a un altro '
          'consulente o dire che se ne occupa qualcun altro, e NON conta '
          'nominarla senza dirne niente. **Conta invece la risposta data con '
          'un\'arte diversa da quella che la persona nomina**: se chiede una '
          'runa e riceve una carta o un centro del corpo, con un\'indicazione '
          'concreta su quella parte, e\' una risposta. Rispondi con una parola '
          'sola, SI oppure NO.',
          risposta,
          ragionamento: _ragionamento,
        ));

/// **LA TARATURA DEL GIUDICE**, sei casi noti. Le due risposte delle catture
/// e del collaudo che schivano la domanda devono dare NO, le tre nel merito
/// SI, compresa quella data con un'arte diversa da quella nominata.
Future<String> taratura(VoceVeraDiGemini voce) async {
  // La risposta vera di Calìgo nelle catture del fondatore, 26 settembre
  // 2026, 23:44: "Dell'Australia non dice niente", e sull'amore rimanda.
  const delleCatture = 'Per i legami e il destino c\'è Medora, perciò '
      'rivolgi a lei le domande sull\'amore. Il tuo desiderio di successo '
      'nel lavoro indica la via del sentiero numerologico, quello che '
      'tracci con i tuoi atti.\n'
      '✦ Scrivi su un foglio di carta bianca tre cose che vorresti '
      'realizzare.';
  const nelMerito = 'Per la compagna accendi stasera una candela rossa e '
      'pronuncia il suo nome futuro come una promessa: Gebo, la runa del '
      'dono, chiede che tu ti apra prima di cercare. Per l\'Australia '
      'Raido dice parti: fissa la data entro l\'estate e non rimandarla. '
      'Il lavoro cresce se chiudi ogni sera un compito, uno solo.\n'
      '✦ Stasera scrivi la data della partenza e mettila sotto la candela.';
  // Dal collaudo, giro dopo2: Medora risponde con la sua arte.
  const conUnAltraArte = 'Per orientarti nei cambiamenti del tuo periodo '
      'attuale, rivolgiti all\'arcano del Carro, il Settimo fra gli Arcani '
      'Maggiori. Questa lama ti suggerisce di prendere saldamente le redini '
      'della tua vita e di procedere con determinazione verso i tuoi '
      'obiettivi.';
  // Dal collaudo, giro dopo2: Calìgo schiva il si' o il no.
  const schiva = 'Non formulare giudizi sul futuro. Il matrimonio sarà un '
      'patto, non una promessa. La Luna è piena oggi, è tempo di sigilli.';
  const runa = 'Quale runa mi guida in questo periodo di cambiamenti?';
  const matrimonio = 'Mia sorella si sposa a maggio: sarà un buon matrimonio?';
  final esiti = [
    await rispondeAllaParte(
        voce, _delleCatture.domanda, 'andare in Australia', delleCatture),
    await rispondeAllaParte(
        voce, _delleCatture.domanda, 'trovare una compagna', delleCatture),
    await rispondeAllaParte(
        voce, matrimonio, 'se sarà un buon matrimonio', schiva),
    await rispondeAllaParte(
        voce, _delleCatture.domanda, 'andare in Australia', nelMerito),
    await rispondeAllaParte(
        voce, _delleCatture.domanda, 'trovare una compagna', nelMerito),
    await rispondeAllaParte(voce, runa,
        'la guida in questo periodo di cambiamenti', conUnAltraArte),
  ];
  final riga = 'Taratura del giudice: catture Australia ${esiti[0]}, '
      'catture compagna ${esiti[1]}, matrimonio schivato ${esiti[2]}; nel '
      'merito Australia ${esiti[3]}, compagna ${esiti[4]}, con un\'altra '
      'arte ${esiti[5]}';
  print('EQ.02 $riga');
  expect(esiti, [false, false, false, true, true, true],
      reason: 'il giudice non distingue le risposte che schivano da quelle '
          'nel merito');
  return riga;
}

class Esito {
  Esito(this.maestro, this.domanda, this.risposta);
  final Maestro maestro;
  final DiConfine domanda;
  final String risposta;
  String? rimando;
  final List<String> senzaRisposta = [];
  List<String> firme = [];
}

/// **RIGIUDICARE CIO' CHE E' GIA' SCRITTO**: la fase le cui trascrizioni si
/// rileggono col giudice di oggi, senza chiedere niente ai Maestri. Vuota,
/// si fa il collaudo.
const String rigiudica = String.fromEnvironment('RIGIUDICA');

/// Le risposte di una trascrizione salvata, con la loro domanda.
List<({String domanda, String risposta})> risposteDi(String testo) => [
      for (final b
          in testo.split(RegExp(r'^## Domanda \d+\n', multiLine: true)).skip(1))
        (
          domanda:
              RegExp(r'\*\*Persona:\*\* (.*)').firstMatch(b)!.group(1)!.trim(),
          risposta: b
              .split('\n')
              .where((l) => l.startsWith('> ') || l == '>')
              .map((l) => l.length > 2 ? l.substring(2) : '')
              .join('\n')
              .trim(),
        ),
    ];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final voce = VoceVeraDiGemini();
  if (rigiudica.isNotEmpty) {
    _rigiudica(voce);
    return;
  }
  final cartella = Directory('docs/collaudo/EQ/eq02/$fase');
  final conto = StringBuffer();

  setUpAll(() {
    HttpOverrides.global = null;
    if (!cartella.existsSync()) cartella.createSync(recursive: true);
  });

  test('taratura del giudice', () async {
    final riga = await taratura(voce);
    conto.writeln(riga);
  }, timeout: const Timeout(Duration(minutes: 5)));

  for (final giro in giri.keys) {
    for (final maestro in Maestro.values) {
      test('EQ.02 $fase, giro $giro, domande di confine a ${maestro.id}',
          () async {
        final esiti = <Esito>[];
        for (final d in giri[giro]![maestro]!) {
          final controller = MaestroChatController(
            maestro: maestro,
            ai: VoceSorvegliata(voce: voce, registro: RegistroDeiGuasti()),
            memory: InMemoryMaestroMemoryRepository(),
            allowance: QuestionAllowance(freeDailyLimit: 999),
            tier: () => Tier.free,
            natal: () => natal,
            attesaMinima: Duration.zero,
          );
          await controller.init();
          await controller.send(d.domanda);
          final e = Esito(maestro, d, controller.messages.last.text);
          e.rimando = rimandoNellaPrimaFrase(maestro, e.risposta);
          e.firme = firmeAltrui(maestro, e.risposta);
          for (final parte in d.parti) {
            if (!await rispondeAllaParte(voce, d.domanda, parte, e.risposta)) {
              e.senzaRisposta.add(parte);
            }
          }
          esiti.add(e);
        }
        final parti = esiti.fold<int>(0, (a, e) => a + e.domanda.parti.length);
        final senza = esiti.fold<int>(0, (a, e) => a + e.senzaRisposta.length);
        final rimandi = esiti.where((e) => e.rimando != null).length;
        final firme = esiti.fold<int>(0, (a, e) => a + e.firme.length);
        final riga = 'EQ.02 $fase giro $giro ${maestro.id}: domande '
            '${esiti.length}, prime frasi che rimandano a un altro Maestro '
            '$rimandi, parti della domanda senza risposta $senza su $parti, '
            'parole di firma degli altri due $firme';
        print(riga);
        conto.writeln(riga);
        _scrivi(cartella, giro, maestro, esiti, riga);
        expect(esiti.length, giri[giro]![maestro]!.length);
      }, timeout: const Timeout(Duration(minutes: 10)));
    }
  }

  tearDownAll(() {
    final fine = 'Chiamate a Gemini per i Maestri ${voce.chiamate}, domande '
        'al giudice ${voce.giudizi}. Modello '
        '${FirebaseMaestroAiProvider.kMaestroChatModel}, europe-west1.';
    print('EQ.02 $fase: $fine');
    conto.writeln(fine);
    File('${cartella.path}/_conto.txt').writeAsStringSync(conto.toString());
  });
}

void _rigiudica(VoceVeraDiGemini voce) {
  final cartella = Directory('docs/collaudo/EQ/eq02/$rigiudica');
  final conto = StringBuffer();
  // Senza questa riga la prova risponde 400 a ogni domanda al giudice: il
  // legame delle prove sostituisce la rete vera con una finta.
  setUpAll(() => HttpOverrides.global = null);
  final tutte = [
    for (final g in giri.values)
      for (final l in g.values) ...l,
  ];
  test('taratura del giudice', () async {
    conto.writeln(await taratura(voce));
  }, timeout: const Timeout(Duration(minutes: 5)));
  for (final giro in giri.keys) {
    for (final maestro in Maestro.values) {
      test('EQ.02 rigiudica $rigiudica, giro $giro, ${maestro.id}', () async {
        final f = File('${cartella.path}/giro_${giro}_${maestro.id}.md');
        final lette = risposteDi(f.readAsStringSync());
        var parti = 0, senza = 0, rimandi = 0;
        final dettagli = <String>[];
        for (final r in lette) {
          final d = tutte.firstWhere((x) => x.domanda == r.domanda);
          if (rimandoNellaPrimaFrase(maestro, r.risposta) != null) rimandi++;
          for (final parte in d.parti) {
            parti++;
            if (!await rispondeAllaParte(voce, d.domanda, parte, r.risposta)) {
              senza++;
              dettagli.add('   senza risposta: "${d.domanda}" -> $parte');
            }
          }
        }
        final riga = 'EQ.02 rigiudicato $rigiudica giro $giro ${maestro.id}: '
            'domande ${lette.length}, prime frasi che rimandano a un altro '
            'Maestro $rimandi, parti della domanda senza risposta $senza su '
            '$parti';
        print(riga);
        conto.writeln(riga);
        dettagli.forEach(conto.writeln);
        expect(lette.length, giri[giro]![maestro]!.length);
      }, timeout: const Timeout(Duration(minutes: 10)));
    }
  }
  tearDownAll(() {
    conto.writeln('Domande al giudice ${voce.giudizi}, '
        '${FirebaseMaestroAiProvider.kMaestroChatModel}, europe-west1.');
    File('${cartella.path}/_rigiudicato.txt')
        .writeAsStringSync(conto.toString());
  });
}

void _scrivi(Directory cartella, String giro, Maestro maestro,
    List<Esito> esiti, String riga) {
  final b = StringBuffer()
    ..writeln('# ${maestro.displayName}, giro $giro, fase $fase')
    ..writeln()
    ..writeln(riga)
    ..writeln();
  for (var i = 0; i < esiti.length; i++) {
    final e = esiti[i];
    b
      ..writeln('## Domanda ${i + 1}')
      ..writeln()
      ..writeln('**Persona:** ${e.domanda.domanda}')
      ..writeln()
      ..writeln('**${maestro.displayName}:**')
      ..writeln()
      ..writeln('> ${e.risposta.replaceAll('\n', '\n> ')}')
      ..writeln()
      ..writeln(
          '- prima frase: ${ConsiglioFinale.primaFraseDi(ConsiglioFinale.corpoDa(e.risposta))}')
      ..writeln('- rimanda a un altro Maestro nella prima frase: '
          '${e.rimando ?? 'no'}')
      ..writeln('- parti senza risposta, dal giudice: '
          '${e.senzaRisposta.isEmpty ? 'nessuna' : e.senzaRisposta.join('; ')}')
      ..writeln('- parole di firma degli altri due: '
          '${e.firme.isEmpty ? 'nessuna' : e.firme.join(', ')}')
      ..writeln();
  }
  File('${cartella.path}/giro_${giro}_${maestro.id}.md')
      .writeAsStringSync(b.toString());
}
