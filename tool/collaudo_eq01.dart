// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/il_passo_da_non_dare.dart';
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

/// **IL COLLAUDO DELLA RIGA D'ORO, ordine EQ voce 01.** 27 settembre 2026.
///
/// Il fondatore, sulle catture della chat di Calìgo: la stessa riga d'oro
/// sotto la presentazione, sotto la domanda sull'amore e il lavoro, nel LIVE
/// dopo *"Ok, gli ho scritto adesso."* e sotto *"Ok, le ho scritte e adesso
/// cosa faccio?"*. Qui si rifanno conversazioni di sei scambi con ciascuno
/// dei tre Maestri, con Gemini vero, e si contano **su cio' che arriva a
/// schermo** e **su cio' che il modello ha scritto prima delle reti**:
///
/// - le righe d'oro uguali o simili a una gia' data nella conversazione;
/// - le presentazioni con una riga d'oro;
/// - le righe che chiedono di rifare il passo che la persona ha appena detto
///   di aver fatto, cercando il verbo del passo dichiarato.
///
/// **Due giri con dati diversi**, come vuole il protocollo della chiusura per
/// i testi generati: il giro A con le parole del fondatore, il giro B con
/// altre domande e un altro passo fatto. Il terzo scambio del giro A si fa
/// nel LIVE, come nelle catture.
///
/// ```
/// flutter test tool/collaudo_eq01.dart --dart-define=FASE=prima
/// flutter test tool/collaudo_eq01.dart --dart-define=FASE=dopo
/// ```
///
/// Vuole una sessione `gcloud` attiva. Le trascrizioni vanno in
/// `docs/collaudo/EQ/eq01/<fase>/`.
const String fase = String.fromEnvironment('FASE', defaultValue: 'dopo');

const natal = NatalContext(
  sunSign: 'Cancro',
  ascendant: 'Gemelli',
  lifeNumber: 3,
  lifeNumberTitle: 'il Creativo',
);

/// Uno scambio del collaudo, con cio' che la sua domanda e' per costruzione.
class Scambio {
  const Scambio(this.domanda,
      {this.presentazione = false, this.fatto, this.nelLive = false});

  final String domanda;

  /// La domanda e' una presentazione: nessuna riga d'oro deve arrivare.
  final bool presentazione;

  /// Il verbo del passo che la persona dice fatto: una riga d'oro che lo
  /// contiene chiede di rifarlo.
  final RegExp? fatto;

  /// Lo scambio si fa nel LIVE.
  final bool nelLive;
}

final _scrivere = RegExp(r'\bscriv\w*', caseSensitive: false);
final _accendere = RegExp(r'\baccend\w*', caseSensitive: false);

/// **IL GIRO A, le parole del fondatore**, dalle catture della chat di
/// Calìgo, nell'ordine in cui le ha scritte.
List<Scambio> giroA(Maestro m) => [
      const Scambio('Ciao, chi sei? Come puoi aiutarmi?', presentazione: true),
      const Scambio('Beh, vorrei avere una compagna, vorrei andare in '
          'Australia e vorrei avessi successo col lavoro che sto facendo.'),
      Scambio('Ok, gli ho scritto adesso.', fatto: _scrivere, nelLive: true),
      Scambio('Ok, le ho scritte e adesso cosa faccio?', fatto: _scrivere),
      const Scambio('Chi sono gli altri Maestri oltre a te?',
          presentazione: true),
      const Scambio('E domani cosa posso fare?'),
    ];

/// **IL GIRO B, dati diversi**: un'altra presentazione, una domanda della
/// materia del Maestro, due passi fatti con due verbi.
List<Scambio> giroB(Maestro m) => [
      const Scambio('Buonasera. Tu chi sei e cosa fai?', presentazione: true),
      Scambio(switch (m) {
        Maestro.medora =>
          'Il mio compagno è distante da settimane e non so cosa pensare.',
        Maestro.caligo =>
          'Devo decidere se lasciare il lavoro per aprire una bottega mia.',
        Maestro.aura => 'Da giorni ho un nodo allo stomaco e dormo male.',
      }),
      Scambio('Fatto, ho scritto quello che mi hai detto. E ora?',
          fatto: _scrivere),
      Scambio('Ho acceso una candela come mi hai detto. Cosa faccio adesso?',
          fatto: _accendere),
      const Scambio('E chi sono gli altri Maestri?', presentazione: true),
      const Scambio('Cosa posso fare domani mattina?'),
    ];

class Esito {
  Esito(this.scambio, {required this.grezza, required this.aSchermo});
  final Scambio scambio;

  /// Cio' che il modello ha scritto, prima delle reti del controller.
  final String grezza;

  /// Cio' che il controller ha consegnato alla bolla.
  final String aSchermo;

  String? get rigaGrezza => ConsiglioFinale.sintesiDa(grezza);
  String? get rigaASchermo => ConsiglioFinale.sintesiDa(aSchermo);
}

/// I tre conti su una conversazione, sulle righe date da [riga].
({int righe, int ripetute, int presentazioni, int rifare}) conta(
    List<Esito> esiti, String? Function(Esito) riga) {
  final gia = <String>[];
  var righe = 0, ripetute = 0, presentazioni = 0, rifare = 0;
  for (final e in esiti) {
    final r = riga(e);
    if (r == null) continue;
    righe++;
    if (gia.any((g) => IlPassoDaNonDare.simili(r, g))) ripetute++;
    if (e.scambio.presentazione) presentazioni++;
    if (e.scambio.fatto?.hasMatch(r) ?? false) rifare++;
    gia.add(r);
  }
  return (
    righe: righe,
    ripetute: ripetute,
    presentazioni: presentazioni,
    rifare: rifare
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final voce = VoceVeraDiGemini();
  final cartella = Directory('docs/collaudo/EQ/eq01/$fase');
  final conto = StringBuffer();

  setUpAll(() {
    HttpOverrides.global = null;
    if (!cartella.existsSync()) cartella.createSync(recursive: true);
  });

  for (final giro in ['A', 'B']) {
    for (final maestro in Maestro.values) {
      test('EQ.01 $fase, giro $giro, sei scambi con ${maestro.id}', () async {
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
        final scambi = giro == 'A' ? giroA(maestro) : giroB(maestro);
        final esiti = <Esito>[];
        for (final s in scambi) {
          final prima = voce.grezze.length;
          controller.nelLive = s.nelLive;
          await controller.send(s.domanda);
          controller.nelLive = false;
          final ultima = controller.messages.last;
          final grezza =
              voce.grezze.length > prima ? voce.grezze.last.testo : '';
          esiti.add(Esito(s,
              grezza: grezza,
              aSchermo: ultima.role == ChatRole.maestro ? ultima.text : ''));
        }
        final g = conta(esiti, (e) => e.rigaGrezza);
        final a = conta(esiti, (e) => e.rigaASchermo);
        final riga = 'EQ.01 $fase giro $giro ${maestro.id}: A SCHERMO righe '
            'd\'oro ${a.righe}, uguali o simili a una già data ${a.ripetute}, '
            'sotto una presentazione ${a.presentazioni}, che chiedono di '
            'rifare il passo fatto ${a.rifare}; DAL MODELLO righe ${g.righe}, '
            'uguali o simili ${g.ripetute}, sotto una presentazione '
            '${g.presentazioni}, da rifare ${g.rifare}';
        print(riga);
        conto.writeln(riga);
        _scrivi(cartella, giro, maestro, esiti, riga);
        expect(esiti.where((e) => e.aSchermo.trim().isNotEmpty).length,
            scambi.length,
            reason: 'ogni domanda deve avere la sua risposta');
      }, timeout: const Timeout(Duration(minutes: 10)));
    }
  }

  tearDownAll(() {
    final fine = 'Chiamate a Gemini ${voce.chiamate}. Modello della chat '
        '${FirebaseMaestroAiProvider.kMaestroChatModel}, del LIVE '
        '${FirebaseMaestroAiProvider.modelloDelTurno(nelLive: true)}, '
        'europe-west1.';
    print('EQ.01 $fase: $fine');
    conto.writeln(fine);
    File('${cartella.path}/_conto.txt').writeAsStringSync(conto.toString());
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
      ..writeln('## Scambio ${i + 1}${e.scambio.nelLive ? ', nel LIVE' : ''}'
          '${e.scambio.presentazione ? ', presentazione' : ''}'
          '${e.scambio.fatto != null ? ', passo fatto' : ''}')
      ..writeln()
      ..writeln('**Persona:** ${e.scambio.domanda}')
      ..writeln()
      ..writeln('**A schermo:**')
      ..writeln()
      ..writeln('> ${e.aSchermo.replaceAll('\n', '\n> ')}')
      ..writeln()
      ..writeln('- riga d\'oro a schermo: ${e.rigaASchermo ?? 'NESSUNA'}')
      ..writeln('- riga d\'oro del modello: ${e.rigaGrezza ?? 'NESSUNA'}')
      ..writeln();
  }
  File('${cartella.path}/giro_${giro}_${maestro.id}.md')
      .writeAsStringSync(b.toString());
}
