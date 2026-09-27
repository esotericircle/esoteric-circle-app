// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/maestro/consiglio_finale.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_controller.dart';
import 'package:esoteric_circle/services/ai/firebase_maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/registro_dei_guasti.dart';
import 'package:esoteric_circle/services/ai/voce_sorvegliata.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'la_voce_vera_di_gemini.dart';

/// **IL COLLAUDO DELLE RISPOSTE NEL MERITO, ANCHE NEL LIVE, ordine EQ voce
/// 03.** 27 settembre 2026.
///
/// Nelle catture, a *"Ok, le ho scritte e adesso cosa faccio?"* Calìgo
/// risponde *"Il tuo gesto è compiuto. Ora lascia che il tempo faccia il suo
/// corso."*: non dice niente. L'ordine: una risposta dice qualcosa di
/// concreto sulla domanda e tiene conto di cio' che la persona ha appena
/// detto; si misurano le stesse domande in chat e nel LIVE, con Flash e con
/// Flash-Lite, e per il LIVE resta il modello che risponde nel merito, fra
/// due che lo fanno il piu' veloce.
///
/// **Dodici domande di seguito per Maestro**, nella stessa conversazione, con
/// dentro quelle delle catture. Per ogni risposta:
///
/// - **nel merito**, dal giudice a temperatura zero, a maggioranza su tre,
///   con lo scambio di prima davanti: dice qualcosa di concreto sulla domanda
///   e tiene conto di cio' che la persona ha appena detto;
/// - **che cosa risponde, in una riga**, scritta dal giudice;
/// - **il tempo del modello**, dalla richiesta alla risposta intera: il LIVE
///   comincia a parlare solo quando la risposta e' intera e ha passato le
///   reti, quindi e' questo il pezzo dell'attesa che il modello decide.
///
/// ```
/// flutter test tool/collaudo_eq03.dart --dart-define=FASE=prima \
///   --dart-define=MODI=live-lite,chat
/// flutter test tool/collaudo_eq03.dart --dart-define=FASE=dopo \
///   --dart-define=MODI=live-lite,live-flash,chat
/// ```
///
/// Due giri per modo, `GIRI=2`. Le trascrizioni vanno in
/// `docs/collaudo/EQ/eq03/<fase>/`.
const String fase = String.fromEnvironment('FASE', defaultValue: 'dopo');
const String modi =
    String.fromEnvironment('MODI', defaultValue: 'live-lite,live-flash,chat');
const int giri = int.fromEnvironment('GIRI', defaultValue: 2);

const natal = NatalContext(
  sunSign: 'Cancro',
  ascendant: 'Gemelli',
  lifeNumber: 3,
  lifeNumberTitle: 'il Creativo',
);

/// Le dodici domande, di seguito: quelle delle catture nell'ordine in cui il
/// fondatore le ha scritte, poi il seguito di una persona vera che torna sul
/// suo passo.
const List<String> domande = [
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

/// Il modo: dove e con quale modello risponde il Maestro.
class Modo {
  const Modo(this.nome, {required this.nelLive, this.modello});
  final String nome;
  final bool nelLive;

  /// Il modello, se il modo lo sceglie al posto dell'app.
  final String? modello;
}

const Map<String, Modo> tuttiIModi = {
  'live-lite': Modo('LIVE con Flash-Lite',
      nelLive: true, modello: FirebaseMaestroAiProvider.kMaestroBreveModel),
  'live-flash': Modo('LIVE con Flash',
      nelLive: true, modello: FirebaseMaestroAiProvider.kMaestroChatModel),
  'chat': Modo('chat con Flash', nelLive: false),
};

const int _ragionamento = 512;

Future<bool> _aMaggioranza(Future<bool> Function() voto) async {
  var si = 0;
  for (var i = 0; i < 3; i++) {
    if (await voto()) si++;
  }
  return si >= 2;
}

/// **IL GIUDICE DEL MERITO**, con lo scambio di prima davanti.
Future<bool> nelMerito(VoceVeraDiGemini voce,
        {required String prima, required String domanda, required String risposta}) =>
    _aMaggioranza(() => voce.giudica(
          'Scambio precedente della conversazione:\n$prima\n\n'
          'Ultima cosa detta dalla persona: "$domanda".\n'
          'Qui sotto c\'e\' la risposta del consulente. E\' NEL MERITO se dice '
          'qualcosa di concreto e specifico su quello che la persona ha appena '
          'detto o chiesto, tenendo conto di cio\' che ha detto: un\'indicazione '
          'precisa, una lettura, un passo che parte da li\'. NON e\' nel merito '
          'se dice frasi che andrebbero bene per chiunque ("il tuo gesto e\' '
          'compiuto", "lascia che il tempo faccia il suo corso", "ascolta te '
          'stesso"), se ignora quello che la persona ha appena detto, o se '
          'rimanda altrove senza dire niente. Rispondi con una parola sola, SI '
          'oppure NO.',
          risposta,
          ragionamento: _ragionamento,
        ));

/// Che cosa risponde, in una riga, dal giudice.
Future<String> inUnaRiga(VoceVeraDiGemini voce, String domanda,
        String risposta) async =>
    (await voce.elenca(
      'Domanda della persona: "$domanda".\n'
      'Scrivi in UNA riga, in italiano, al massimo quindici parole, che cosa '
      'risponde il consulente qui sotto, cioe\' che cosa dice di fare o che '
      'cosa afferma. Niente premesse.',
      risposta,
      tetto: 80,
    ))
        .replaceAll('\n', ' ')
        .trim();

class Esito {
  Esito(this.domanda, this.risposta, this.millesimi);
  final String domanda;
  final String risposta;
  final int millesimi;
  bool merito = false;
  String riga = '';
}

int mediana(List<int> valori) {
  if (valori.isEmpty) return 0;
  final v = [...valori]..sort();
  return v.length.isOdd
      ? v[v.length ~/ 2]
      : ((v[v.length ~/ 2 - 1] + v[v.length ~/ 2]) / 2).round();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final cartella = Directory('docs/collaudo/EQ/eq03/$fase');
  final conto = StringBuffer();
  final tempiPerModo = <String, List<int>>{};
  final meritoPerModo = <String, List<int>>{};

  setUpAll(() {
    HttpOverrides.global = null;
    if (!cartella.existsSync()) cartella.createSync(recursive: true);
  });

  for (final chiave in modi.split(',')) {
    final modo = tuttiIModi[chiave]!;
    for (var giro = 1; giro <= giri; giro++) {
      for (final maestro in Maestro.values) {
        test('EQ.03 $fase, ${modo.nome}, giro $giro, ${maestro.id}', () async {
          final voce = VoceVeraDiGemini(modello: modo.modello);
          final controller = MaestroChatController(
            maestro: maestro,
            ai: VoceSorvegliata(voce: voce, registro: RegistroDeiGuasti()),
            memory: InMemoryMaestroMemoryRepository(),
            allowance: QuestionAllowance(freeDailyLimit: 999),
            tier: () => Tier.free,
            natal: () => natal,
            attesaMinima: Duration.zero,
          )..nelLive = modo.nelLive;
          await controller.init();
          final esiti = <Esito>[];
          var prima = '(nessuno: e\' la prima domanda)';
          for (final d in domande) {
            final quante = voce.grezze.length;
            await controller.send(d);
            final ultima = controller.messages.last;
            final testo = ultima.role == ChatRole.maestro ? ultima.text : '';
            // Il tempo del modello: la somma delle chiamate di questo turno,
            // rigenerazioni comprese, perche' la persona le aspetta tutte.
            final ms = voce.grezze
                .skip(quante)
                .fold<int>(0, (a, g) => a + g.durata.inMilliseconds);
            final e = Esito(d, testo, ms);
            e.merito = await nelMerito(voce,
                prima: prima, domanda: d, risposta: testo);
            e.riga = await inUnaRiga(voce, d, testo);
            esiti.add(e);
            prima = 'Persona: "$d"\nConsulente: "${ConsiglioFinale.corpoDa(testo)}"';
          }
          final nel = esiti.where((e) => e.merito).length;
          final tempi = [for (final e in esiti) e.millesimi];
          tempiPerModo.putIfAbsent(modo.nome, () => []).addAll(tempi);
          meritoPerModo.putIfAbsent(modo.nome, () => [0, 0])
            ..[0] += nel
            ..[1] += esiti.length;
          final riga = 'EQ.03 $fase ${modo.nome} giro $giro ${maestro.id}: '
              'nel merito $nel su ${esiti.length}, tempo del modello mediano '
              '${mediana(tempi)} ms';
          print(riga);
          conto.writeln(riga);
          _scrivi(cartella, modo, giro, maestro, esiti, riga);
          expect(esiti.length, domande.length);
        }, timeout: const Timeout(Duration(minutes: 20)));
      }
    }
  }

  tearDownAll(() {
    conto.writeln();
    for (final m in tempiPerModo.keys) {
      final nel = meritoPerModo[m]!;
      final r = 'TOTALE ${m.toUpperCase()}: nel merito ${nel[0]} su ${nel[1]}, '
          'tempo del modello mediano ${mediana(tempiPerModo[m]!)} ms su '
          '${tempiPerModo[m]!.length} risposte';
      print('EQ.03 $fase $r');
      conto.writeln(r);
    }
    conto.writeln('Modelli: chat ${FirebaseMaestroAiProvider.kMaestroChatModel}'
        ', LIVE dell\'app '
        '${FirebaseMaestroAiProvider.modelloDelTurno(nelLive: true)}; '
        'europe-west1.');
    File('${cartella.path}/_conto.txt').writeAsStringSync(conto.toString());
  });
}

void _scrivi(Directory cartella, Modo modo, int giro, Maestro maestro,
    List<Esito> esiti, String riga) {
  final b = StringBuffer()
    ..writeln('# ${maestro.displayName}, ${modo.nome}, giro $giro, fase $fase')
    ..writeln()
    ..writeln(riga)
    ..writeln();
  for (var i = 0; i < esiti.length; i++) {
    final e = esiti[i];
    b
      ..writeln('## ${i + 1}. ${e.domanda}')
      ..writeln()
      ..writeln('> ${e.risposta.replaceAll('\n', '\n> ')}')
      ..writeln()
      ..writeln('- nel merito: ${e.merito ? 'si' : 'NO'}')
      ..writeln('- in una riga: ${e.riga}')
      ..writeln('- tempo del modello: ${e.millesimi} ms')
      ..writeln();
  }
  final nomeModo = modo.nome.replaceAll(' ', '_').replaceAll('-', '_');
  File('${cartella.path}/${nomeModo}_giro_${giro}_${maestro.id}.md')
      .writeAsStringSync(b.toString());
}
