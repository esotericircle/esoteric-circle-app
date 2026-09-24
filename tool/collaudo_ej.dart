// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/maestro/consiglio_finale.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/rituals/sunset_rune.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_controller.dart';
import 'package:esoteric_circle/services/ai/firebase_maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/registro_dei_guasti.dart';
import 'package:esoteric_circle/services/ai/voce_sorvegliata.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'controlli_ej.dart';
import 'giudici_ej.dart';
import 'la_voce_vera_di_gemini.dart';

/// **IL COLLAUDO DELLE RISPOSTE DEI MAESTRI, ordine EJ voci 05, 06, 07 e 08.**
/// 24 settembre 2026.
///
/// Il fondatore: *"Trovo che le risposte siano molto, ma molto generiche e
/// ripetitive"*, e *"le persone VOGLIONO RISPOSTE DIRETTE"*. Qui si fanno
/// conversazioni vere di sei scambi con ciascuno dei tre Maestri, con Gemini
/// vero, e si contano **su cio' che la persona legge**:
///
/// - le chiusure ripetute (la riga d'oro, invito a tornare compreso);
/// - le frasi vietate;
/// - i dati della persona che tornano;
/// - le anticipazioni dei doni;
/// - se la risposta si chiude con un passo concreto, e se dice qualcosa di
///   preciso sulla domanda (domande chiuse al giudice, temperatura zero);
/// - gli errori di lingua: le regole del progetto contate a macchina, e gli
///   errori di grammatica elencati dal giudice.
///
/// **La persona e' quella delle catture**: Ascendente Gemelli, Sole in Cancro,
/// numero della vita 3.
///
/// **Si lancia due volte**, prima e dopo la cura, e vuole una sessione
/// `gcloud` attiva:
///
/// ```
/// flutter test tool/collaudo_ej.dart --dart-define=FASE=prima
/// flutter test tool/collaudo_ej.dart --dart-define=FASE=dopo
/// ```
///
/// Le trascrizioni vanno in `docs/collaudo/EJ/risposte/<fase>/`. **Il tono lo
/// giudica il fondatore leggendole**: i conti non lo misurano.
const String fase = String.fromEnvironment('FASE', defaultValue: 'dopo');

const natal = NatalContext(
  sunSign: 'Cancro',
  ascendant: 'Gemelli',
  lifeNumber: 3,
  lifeNumberTitle: 'il Creativo',
);

/// Sei scambi per Maestro, con dentro la domanda delle catture, *"come mi
/// devo comportare"*.
const Map<Maestro, List<String>> conversazioni = {
  Maestro.medora: [
    'Ciao Medora, da qualche giorno mi sento inquieto e non capisco perché.',
    'Credo sia il lavoro: il mio capo mi mette sotto pressione.',
    'Come mi devo comportare con lui?',
    'Domani ho una riunione con lui, cosa mi consigli?',
    'E se gli dicessi che voglio cambiare reparto?',
    'Va bene. Cosa posso fare già stasera?',
  ],
  Maestro.caligo: [
    'Caligo, sono davanti a una scelta: restare dove sono o cambiare città.',
    'Ho paura di sbagliare e di pentirmene.',
    'Come mi devo comportare con la mia famiglia, che non è d\'accordo?',
    'Cosa mi dicono le rune su questa soglia?',
    'E se aspettassi ancora qualche mese?',
    'Qual è il primo passo che posso fare domani?',
  ],
  Maestro.aura: [
    'Aura, ultimamente sono sempre stanco e agitato.',
    'Faccio fatica a dormire, penso sempre al lavoro.',
    'Come mi devo comportare quando l\'ansia sale?',
    'E durante il giorno, in ufficio?',
    'Ho provato a meditare ma non ci riesco.',
    'Cosa posso fare stasera prima di dormire?',
  ],
};

class EsitoDellaRisposta {
  EsitoDellaRisposta(this.domanda, this.letta);
  final String domanda;
  final RispostaLetta letta;
  List<String> vietate = [];
  List<String> anticipate = [];
  List<String> regole = [];
  List<String> grammatica = [];
  bool passoConcreto = false;
  bool diretta = false;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final voce = VoceVeraDiGemini();
  final cartella = Directory('docs/collaudo/EJ/risposte/$fase');
  final conto = StringBuffer();

  setUpAll(() {
    HttpOverrides.global = null;
    if (!cartella.existsSync()) cartella.createSync(recursive: true);
  });

  for (final maestro in Maestro.values) {
    test('EJ $fase, sei scambi con ${maestro.id}', () async {
      final sorvegliata =
          VoceSorvegliata(voce: voce, registro: RegistroDeiGuasti());
      final controller = MaestroChatController(
        maestro: maestro,
        ai: sorvegliata,
        memory: InMemoryMaestroMemoryRepository(),
        allowance: QuestionAllowance(freeDailyLimit: 999),
        tier: () => Tier.free,
        natal: () => natal,
        attesaMinima: Duration.zero,
      );
      await controller.init();
      final domande = <int, String>{};
      for (final d in conversazioni[maestro]!) {
        await controller.send(d);
        domande[controller.messages.length - 1] = d;
      }

      // **LA RIGA D'ORO SI COMPONE COME NELLA BOLLA**, con la stessa regola
      // su dove va l'invito a tornare.
      final messaggi = controller.messages;
      final ultimaDelMaestro =
          messaggi.lastIndexWhere((m) => !m.isUser && m.portaUnResponso);
      final identita = SunsetRune.identitaPer(
          nascita: DateTime(1970, 7, 1), oraNota: true, deviceId: 'cerchio');
      final esiti = <EsitoDellaRisposta>[];
      for (var i = 0; i < messaggi.length; i++) {
        final m = messaggi[i];
        if (m.isUser || !m.portaUnResponso || !domande.containsKey(i)) {
          continue;
        }
        final letta = RispostaLetta(
          corpo: ConsiglioFinale.corpoDa(m.text),
          riga: ConsiglioFinale.componi(
            maestro,
            testo: m.text,
            quando: m.at ?? DateTime.now(),
            identita: identita,
            conInvito: ConsiglioFinale.invitoSotto(
                posizione: i, ultimaDelMaestro: ultimaDelMaestro),
          ),
        );
        final e = EsitoDellaRisposta(domande[i]!, letta)
          ..vietate = frasiVietate(letta)
          ..anticipate = anticipazioni(letta)
          ..regole = erroriDiRegola(letta);
        e.passoConcreto = await giudicaPasso(voce, letta.intera);
        e.diretta = await giudicaDiretta(voce, domande[i]!, letta.intera);
        e.grammatica = await erroriDiGrammatica(voce, letta.intera);
        esiti.add(e);
      }

      final lette = [for (final e in esiti) e.letta];
      final ripetute = chiusureRipetute(lette);
      final dati = datiRipetuti(lette, datiDellaPersona);
      final vietate = esiti.fold<int>(0, (a, e) => a + e.vietate.length);
      final anticipate = esiti.fold<int>(0, (a, e) => a + e.anticipate.length);
      final senzaPasso = esiti.where((e) => !e.passoConcreto).length;
      final indirette = esiti.where((e) => !e.diretta).length;
      final regole = esiti.fold<int>(0, (a, e) => a + e.regole.length);
      final grammatica = esiti.fold<int>(0, (a, e) => a + e.grammatica.length);
      final riga = 'EJ $fase ${maestro.id}: risposte ${esiti.length}, '
          'chiusure ripetute $ripetute, frasi vietate $vietate, dati '
          'ripetuti $dati, anticipazioni $anticipate, senza passo concreto '
          '$senzaPasso, non dirette $indirette, errori di regola $regole, '
          'errori di grammatica $grammatica';
      print(riga);
      conto.writeln(riga);
      _scrivi(cartella, maestro, esiti, riga);
      expect(esiti.length, conversazioni[maestro]!.length,
          reason: 'ogni domanda deve avere la sua risposta vera');
    }, timeout: const Timeout(Duration(minutes: 10)));
  }

  test('taratura dei giudici della risposta diretta e del passo', () async {
    // La vaga e' vera, dalle trascrizioni del prima. La diretta e' scritta
    // qui apposta: la prima scelta era una risposta vera di Medora che apre
    // con la Luna e risponde alla seconda frase, e il giudice l'ha bocciata.
    // Aveva ragione lui: e' il difetto che il fondatore lamenta.
    const diretta = 'Parlagli domani prima della riunione, a voce e da solo, '
        'e digli che cosa ti serve per lavorare bene. La Luna in Acquario ti '
        'rende lucido nel dire le cose come stanno.\n'
        '✦ Stasera scrivi su un foglio le tre richieste da fargli.';
    const vaga = 'La brace ardente illumina il sentiero. La tua natura, con il '
        'Sole in Cancro, cerca un luogo che risuoni con la tua interiorità. La '
        'runa Raido presagisce un viaggio, un movimento.\n'
        '✦ La tua paura è una soglia, non un muro. Torna domani sera: la '
        'runa che scende è Eihwaz.';
    final d1 = await giudicaDiretta(
        voce, 'Domani ho una riunione con lui, cosa mi consigli?', diretta);
    final d2 = await giudicaDiretta(voce,
        'Sono davanti a una scelta: restare dove sono o cambiare città.', vaga);
    final p1 = await giudicaPasso(voce, diretta);
    final p2 = await giudicaPasso(voce, vaga);
    final riga =
        'Taratura: diretta sulla risposta diretta $d1, sulla vaga $d2; '
        'passo sulla risposta col passo $p1, sulla vaga $p2';
    print('EJ $riga');
    conto.writeln(riga);
    expect([d1, d2, p1, p2], [true, false, true, false],
        reason: 'i giudici non distinguono gli esempi noti');
  }, timeout: const Timeout(Duration(minutes: 3)));

  test('taratura del giudice della grammatica', () async {
    final sbagliato = await erroriDiGrammatica(
        voce, 'Le Rune ti indicano un soglia. Attraversala con calma.');
    final giusto = await erroriDiGrammatica(voce,
        'Il tuo Cancro solare chiede riparo. Domani parla col tuo capo, e ascolta.');
    print('EJ taratura: frase sbagliata ${sbagliato.length} $sbagliato, '
        'frase giusta ${giusto.length} $giusto');
    conto.writeln('Taratura del giudice: "un soglia" -> ${sbagliato.length} '
        'errori, testo corretto -> ${giusto.length}');
    expect(sbagliato, isNotEmpty, reason: 'il giudice non vede "un soglia"');
    expect(giusto, isEmpty,
        reason: 'il giudice vede errori dove non ce ne sono');
  });

  tearDownAll(() {
    final fine = 'Chiamate a Gemini per i Maestri ${voce.chiamate}, domande '
        'al giudice ${voce.giudizi}. Modello '
        '${FirebaseMaestroAiProvider.kMaestroChatModel}, europe-west1.';
    print('EJ $fase: $fine');
    conto.writeln(fine);
    File('${cartella.path}/_conto.txt').writeAsStringSync(conto.toString());
  });
}

void _scrivi(Directory cartella, Maestro maestro,
    List<EsitoDellaRisposta> esiti, String riga) {
  final b = StringBuffer()
    ..writeln('# ${maestro.displayName}, sei scambi, fase $fase')
    ..writeln()
    ..writeln(riga)
    ..writeln();
  for (var i = 0; i < esiti.length; i++) {
    final e = esiti[i];
    b
      ..writeln('## Scambio ${i + 1}')
      ..writeln()
      ..writeln('**Persona:** ${e.domanda}')
      ..writeln()
      ..writeln('**${maestro.displayName}:**')
      ..writeln()
      ..writeln('> ${e.letta.corpo.replaceAll('\n', '\n> ')}')
      ..writeln('>')
      ..writeln('> ✦ ${e.letta.riga}')
      ..writeln()
      ..writeln('- passo concreto: ${e.passoConcreto ? 'si' : 'NO'}')
      ..writeln('- risposta diretta: ${e.diretta ? 'si' : 'NO'}');
    if (e.vietate.isNotEmpty) b.writeln('- frasi vietate: ${e.vietate}');
    if (e.anticipate.isNotEmpty) b.writeln('- anticipazioni: ${e.anticipate}');
    if (e.regole.isNotEmpty) b.writeln('- regole di lingua: ${e.regole}');
    if (e.grammatica.isNotEmpty) {
      b.writeln('- grammatica, dal giudice: ${e.grammatica.join(' | ')}');
    }
    b.writeln();
  }
  File('${cartella.path}/${maestro.id}.md').writeAsStringSync(b.toString());
}
