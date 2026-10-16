// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/maestro/consiglio_finale.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/rituals/sunset_rune.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_controller.dart';
import 'package:esoteric_circle/services/ai/registro_dei_guasti.dart';
import 'package:esoteric_circle/services/ai/voce_sorvegliata.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'collaudo_ej.dart' show conversazioni, natal;
import 'controlli_ej.dart';
import 'giudici_ej.dart';
import 'la_voce_vera_di_gemini.dart';

/// **PERCHE' MEDORA E' LA MENO DIRETTA: LA PROVA PER ESCLUSIONE.** Ordine EK
/// voce 02, 24 settembre 2026.
///
/// Il fondatore: *"le persone VOGLIONO RISPOSTE DIRETTE, NON VOGLIONO GIRI DI
/// PAROLE DOVE ALLA FINE NON VIENE DETTO NULLA!"*, e l'ordine chiede la causa
/// con il file e la riga. La stessa conversazione del collaudo EJ gira con
/// l'istruzione dell'app e con varianti che cambiano UNA riga sospetta alla
/// volta; gli stessi giudici contano le risposte non dirette e quelle senza
/// passo concreto. La riga la cui assenza le fa scendere e' la causa.
///
/// **La prima stesura girava tutte le varianti in parallelo insieme al
/// collaudo**, e la quota di Vertex ha risposto 429: due giri su tre persi.
/// Adesso gira da sola, e la voce vera aspetta e riprova sul 429.
///
/// ```
/// flutter test tool/esclusione_medora_ek.dart --dart-define=GIRI=3
/// ```
const int giri = int.fromEnvironment('GIRI', defaultValue: 3);

// Le righe dell'istruzione di oggi, com'e' composta dall'app.
const _registroMedora =
    'Il tuo asse è il TEMPO: qualunque cosa dici la collochi in un momento. '
    'Frasi ampie e distese, mai concitate. ';
const _lenteMedora =
    'LA TUA LENTE SUL DATO: nomina il corpo e il suo MOTO NEL TEMPO, cioè il '
    'ciclo che lo riporta, la fase che sta finendo, la stagione che si '
    'apre. Il tempo è la tua materia e degli altri due non è di nessuno. ';
const _chiusuraMedora = '- Chiudi con UN passo concreto da fare e QUANDO '
    'farlo: una data o una finestra ricavata dal cielo di questa persona, '
    'mai inventata. Se il cielo non te la offre, dille quando tornare a '
    'guardare.';
const _verdettoCaligo = 'La tua prima sentenza è '
    'un verdetto sulla domanda, netto ("Parti.", "Non aspettare.", '
    '"Diglielo stasera."), mai una frase che ripete la domanda con '
    'altre parole.';
const _chiusuraCaligo = 'Lo accompagna la runa o il sigillo, chiamato per '
    'nome.';

// Le righe proposte.
const _registroMedoraDiretto =
    'Il tuo asse è il TEMPO: il consiglio lo dai subito, con parole semplici, '
    'e il tempo dice QUANDO metterlo in pratica. Frasi chiare, mai '
    'concitate. ';
const _lenteMedoraAlServizio =
    'LA TUA LENTE SUL DATO: il tempo è la tua materia e degli altri due non è '
    'di nessuno, e serve a dire QUANDO fare ciò che consigli: il ciclo che '
    'si chiude, la fase che si apre. ';
const _chiusuraMedoraPrecisa = '- Chiudi con UN passo concreto: un\'azione '
    'precisa da fare nel mondo, con una persona, un oggetto o un luogo '
    'nominati, e QUANDO farla, ricavato dal cielo di questa persona e mai '
    'inventato. Riflettere, esaminare, visualizzare o immaginare non sono '
    'azioni.';
const _verdettoCaligoPreciso = 'La tua prima sentenza dice che cosa fare di '
    'preciso su QUESTA domanda, con la persona, la cosa o il momento '
    'nominati ("Diglielo stasera, a cena.", "Parti a gennaio."), mai un '
    'invito che vale per chiunque come "non indugiare" o "non temere"; la '
    'seconda non è una massima.';
const _chiusuraCaligoSenzaOggetti = 'La runa o il sigillo lo accompagnano per '
    'nome, dentro la frase: mai un oggetto da cercare, da preparare o da '
    'portare con sé.';

// La terza stesura, dopo aver letto le prime frasi vere: le otto aperture
// non dirette di Medora nei tre giri "prima" sono premesse o massime sulla
// situazione ("La pressione che senti dal tuo capo e' una sfida, non una
// condanna"), nessuna comincia dal cielo; e il suo esempio "giusto" e' lui
// stesso un consiglio per chiunque, ricopiato due volte alla lettera.
const _aperturaMedora = '- Apri rispondendo alla domanda in una frase: il '
    'consiglio prima del cielo. Non "Domani la Luna in Pesci muove le '
    'emozioni", ma "Domani ascolta più di quanto parli: la Luna in Pesci '
    'amplifica ogni emozione". L\'immagine celeste viene subito dopo, una '
    'sola riga, a dire perché.';
const _aperturaMedoraSpecifica = '- Apri con UN\'AZIONE PRECISA per questa '
    'persona, in una frase sola: che cosa fare, con chi, quando. Non un '
    'commento sulla sua situazione ("La pressione che senti è una sfida, non '
    'una condanna"), non un consiglio che vale per chiunque ("Domani ascolta '
    'più di quanto parli") e non il cielo ("Domani la Luna in Pesci muove le '
    'emozioni"), ma "Domani chiedi al tuo capo dieci minuti a quattr\'occhi e '
    'digli quali scadenze non reggi". Il cielo viene subito dopo, una sola '
    'riga, a dire perché.';
const _frasiAmpie = 'Frasi ampie e distese, mai concitate. ';
const _frasiLimpide = 'Frasi limpide, mai concitate. ';
const _verdettoCaligoMirato = 'La tua prima sentenza è un verdetto sulla '
    'domanda, netto ("Parti.", "Non aspettare.", "Diglielo stasera."), mai '
    'una frase che ripete la domanda con altre parole e mai un invito che '
    'vale per chiunque ("Non indugiare nel timore.").';

/// **Le varianti della seconda stesura**, gia' misurate: i conti e le
/// risposte stanno in `docs/collaudo/EK/risposte/esclusione_seconda/`.
/// Restano scritte qui perche' quei conti dicano a quali righe appartengono.
const laSecondaStesura = [
  (_registroMedora, _registroMedoraDiretto),
  (_lenteMedora, _lenteMedoraAlServizio),
  (_chiusuraMedora, _chiusuraMedoraPrecisa),
  (_verdettoCaligo, _verdettoCaligoPreciso),
  (_chiusuraCaligo, _chiusuraCaligoSenzaOggetti),
];

typedef Variante = ({Maestro maestro, List<(String, String)> cambi});

final Map<String, Variante> varianti = {
  'medora_oggi': (maestro: Maestro.medora, cambi: []),
  'medora_apertura_specifica': (
    maestro: Maestro.medora,
    cambi: [(_aperturaMedora, _aperturaMedoraSpecifica)]
  ),
  'medora_cura': (
    maestro: Maestro.medora,
    cambi: [
      (_aperturaMedora, _aperturaMedoraSpecifica),
      (_frasiAmpie, _frasiLimpide),
      (_chiusuraMedora, _chiusuraMedoraPrecisa),
    ]
  ),
  'caligo_oggi': (maestro: Maestro.caligo, cambi: []),
  'caligo_verdetto_mirato': (
    maestro: Maestro.caligo,
    cambi: [(_verdettoCaligo, _verdettoCaligoMirato)]
  ),
  'aura_oggi': (maestro: Maestro.aura, cambi: []),
};

String applica(String istruzione, List<(String, String)> cambi) {
  var fuori = istruzione;
  for (final (via, messo) in cambi) {
    // Un cambio che non entra falserebbe la prova: la variante misurerebbe
    // l'istruzione di oggi col nome di un'altra.
    if (!fuori.contains(via)) {
      throw StateError('la riga da togliere non c\'e\': "$via"');
    }
    fuori = fuori.replaceFirst(via, messo);
  }
  return fuori;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final cartella = Directory('docs/collaudo/EK/risposte/esclusione');
  final dirette = <String, List<int>>{};
  final passi = <String, List<int>>{};

  setUpAll(() {
    HttpOverrides.global = null;
    if (cartella.existsSync()) cartella.deleteSync(recursive: true);
    cartella.createSync(recursive: true);
  });

  for (var giro = 1; giro <= giri; giro++) {
    test('esclusione, giro $giro', () async {
      await Future.wait([
        for (final v in varianti.entries)
          _unGiro(v.key, v.value, giro, cartella, dirette, passi),
      ]);
    }, timeout: const Timeout(Duration(minutes: 30)));
  }

  tearDownAll(() {
    final b = StringBuffer()
      ..writeln('PROVA PER ESCLUSIONE, ordine EK voce 02.')
      ..writeln('Su 6 risposte per giro, stessi giudici del collaudo EJ.')
      ..writeln();
    for (final nome in varianti.keys) {
      final d = dirette[nome] ?? [];
      final p = passi[nome] ?? [];
      int somma(List<int> l) => l.fold<int>(0, (a, b) => a + b);
      b.writeln('${nome.padRight(26)} non dirette ${d.join(', ')} = '
          '${somma(d)} su ${d.length * 6};  senza passo ${p.join(', ')} = '
          '${somma(p)} su ${p.length * 6}');
    }
    print(b);
    File('${cartella.path}/_conto.txt').writeAsStringSync(b.toString());
  });
}

Future<void> _unGiro(String nome, Variante v, int giro, Directory cartella,
    Map<String, List<int>> dirette, Map<String, List<int>> passi) async {
  final voce = VoceVeraDiGemini(
    ritocco: (m, istruzione) =>
        m == v.maestro ? applica(istruzione, v.cambi) : istruzione,
  );
  final controller = MaestroChatController(
    maestro: v.maestro,
    ai: VoceSorvegliata(voce: voce, registro: RegistroDeiGuasti()),
    memory: InMemoryMaestroMemoryRepository(),
    allowance: QuestionAllowance(freeDailyLimit: 999),
    tier: () => Tier.free,
    natal: () => natal,
    attesaMinima: Duration.zero,
  );
  await controller.init();
  final domande = <int, String>{};
  for (final d in conversazioni[v.maestro]!) {
    await controller.send(d);
    domande[controller.messages.length - 1] = d;
  }
  final messaggi = controller.messages;
  // **Si giudica lo stesso testo del collaudo EJ**, il corpo e la riga d'oro
  // composta dall'app: la seconda stesura giudicava il solo corpo, e Medora
  // di oggi usciva 3 su 18 qui e 8 su 18 nel collaudo.
  final ultimaDelMaestro =
      messaggi.lastIndexWhere((m) => !m.isUser && m.portaUnResponso);
  final identita = SunsetRune.identitaPer(
      nascita: DateTime(1970, 7, 1), oraNota: true, deviceId: 'cerchio');
  final giudizi = <Future<(String, String, String, bool, bool)>>[];
  for (var i = 0; i < messaggi.length; i++) {
    final m = messaggi[i];
    if (m.isUser || !m.portaUnResponso || !domande.containsKey(i)) continue;
    final letta = RispostaLetta(
      corpo: ConsiglioFinale.corpoDa(m.text),
      riga: ConsiglioFinale.componi(
        v.maestro,
        testo: m.text,
        quando: m.at ?? DateTime.now(),
        identita: identita,
        conInvito: ConsiglioFinale.invitoSotto(
            posizione: i, ultimaDelMaestro: ultimaDelMaestro),
      ),
    );
    giudizi.add(Future.wait([
      giudicaDiretta(voce, domande[i]!, letta.intera),
      giudicaPasso(voce, letta.intera),
    ]).then((e) => (domande[i]!, letta.corpo, letta.riga, e[0], e[1])));
  }
  final esiti = await Future.wait(giudizi);
  final b = StringBuffer(
      '# ${v.maestro.displayName}, variante $nome, giro $giro\n\n');
  var indirette = 0;
  var senzaPasso = 0;
  for (final (domanda, corpo, riga, diretta, passo) in esiti) {
    if (!diretta) indirette++;
    if (!passo) senzaPasso++;
    b
      ..writeln('**Persona:** $domanda')
      ..writeln()
      ..writeln('> ${frasiDi(corpo).take(2).join(' ')}')
      ..writeln('>')
      ..writeln('> ${riga.trim()}')
      ..writeln()
      ..writeln(
          '- diretta: ${diretta ? 'si' : 'NO'}; passo: ${passo ? 'si' : 'NO'}')
      ..writeln();
  }
  (dirette[nome] ??= []).add(indirette);
  (passi[nome] ??= []).add(senzaPasso);
  if (esiti.length != 6) {
    print('esclusione $nome giro $giro: SOLO ${esiti.length} risposte su 6');
  }
  print('esclusione $nome giro $giro: non dirette $indirette, senza passo '
      '$senzaPasso su ${esiti.length}');
  File('${cartella.path}/${nome}_giro$giro.md').writeAsStringSync(b.toString());
}
