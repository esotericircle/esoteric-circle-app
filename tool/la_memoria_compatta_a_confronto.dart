// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_controller.dart';
import 'package:esoteric_circle/services/ai/firebase_maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/registro_dei_guasti.dart';
import 'package:esoteric_circle/services/ai/voce_sorvegliata.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'il_banco_del_costo_comune.dart';

/// **LA MEMORIA COMPATTA, A CONFRONTO.** Ordine EX voce 09.
///
/// Il caso che la finestra corta puo' perdere: un dettaglio che la persona
/// ha detto da cinque a nove scambi prima, in questa conversazione, che non
/// sta fra i fatti della memoria ne' nella sintesi, e che la domanda di
/// adesso chiama senza ripeterlo. Dieci conversazioni, il codice vero della
/// chat e Gemini in europe-west1; due giri sullo stesso codice:
/// - "mc_prima": venti messaggi di storia e nessun riassunto, la regola di
///   prima dell'ordine EX (`FINESTRA=20 RIASSUNTO=0`);
/// - "mc_dopo": la regola dell'app, otto messaggi piu' cio' che la persona
///   ha scritto prima della finestra.
///
///     GIRO=mc_prima FINESTRA=20 RIASSUNTO=0 flutter test -r expanded tool/la_memoria_compatta_a_confronto.dart
///     GIRO=mc_dopo flutter test -r expanded tool/la_memoria_compatta_a_confronto.dart
///
/// Scrive `docs/collaudo/EX/qualita/<GIRO>.jsonl`, nella forma del banco
/// della qualita': il dettaglio sta in `fattiDellaMemoria`, perche' chi
/// giudica guardi se la risposta lo usa.

class _Conversazione {
  const _Conversazione(this.id, this.maestro, this.dettaglio, this.scambiPrima,
      this.domanda, this.fatto);
  final String id;
  final Maestro maestro;

  /// Il messaggio della persona che porta il dettaglio.
  final String dettaglio;

  /// Quanti scambi fra il dettaglio e la domanda di adesso.
  final int scambiPrima;
  final String domanda;

  /// Il dettaglio, come fatto di riferimento per chi giudica.
  final String fatto;
}

const _conversazioni = [
  _Conversazione(
      'K01',
      Maestro.medora,
      'Il 14 novembre ho l’esame di abilitazione da avvocata, a Roma.',
      5,
      'Mancano poche settimane: come reggo l’ansia di quel giorno?',
      'ha l’esame di abilitazione da avvocata il 14 novembre a Roma'),
  _Conversazione(
      'K02',
      Maestro.aura,
      'Mio padre è in ospedale, l’hanno operato al cuore martedì.',
      6,
      'Stasera vado a trovarlo. Che cosa posso portargli di buono?',
      'il padre è in ospedale dopo un intervento al cuore'),
  _Conversazione(
      'K03',
      Maestro.caligo,
      'Ho trovato una pietra nera sulla spiaggia di Sperlonga e la tengo sul '
          'comodino da allora.',
      7,
      'Quella pietra di cui ti ho parlato: posso usarla in un rito?',
      'tiene sul comodino una pietra nera trovata sulla spiaggia di Sperlonga'),
  _Conversazione(
      'K04',
      Maestro.medora,
      'Mia figlia Sara compie diciotto anni sabato.',
      8,
      'Che cosa le scrivo nel biglietto?',
      'la figlia Sara compie diciotto anni sabato'),
  _Conversazione(
      'K05',
      Maestro.aura,
      'Faccio il turno di notte in ospedale, tre notti a settimana.',
      9,
      'Qual è il momento giusto della giornata per la mia meditazione?',
      'fa il turno di notte in ospedale tre notti a settimana'),
  _Conversazione(
      'K06',
      Maestro.caligo,
      'Ho chiuso la storia con Andrea dopo sei anni, un mese fa.',
      5,
      'Ieri mi ha scritto lui. Gli rispondo?',
      'ha chiuso un mese fa la storia di sei anni con Andrea'),
  _Conversazione(
      'K07',
      Maestro.medora,
      'Sto per firmare il mutuo per una casa a Bologna, la prima tutta mia.',
      6,
      'Domani firmo. Con che spirito ci vado?',
      'sta per firmare il mutuo della prima casa, a Bologna'),
  _Conversazione(
      'K08',
      Maestro.aura,
      'Sono allergica all’incenso: mi viene l’asma appena lo sento.',
      7,
      'Mi suggerisci un rito di pulizia per la casa nuova?',
      'è allergica all’incenso, le provoca l’asma'),
  _Conversazione(
      'K09',
      Maestro.caligo,
      'Il mio gatto Pepe è morto la settimana scorsa, aveva quindici anni.',
      8,
      'Stanotte l’ho sognato. Che cosa vuol dire?',
      'il gatto Pepe, di quindici anni, è morto la settimana scorsa'),
  _Conversazione(
      'K10',
      Maestro.medora,
      'Insegno musica in una scuola media da dodici anni.',
      9,
      'Mi hanno offerto un posto in conservatorio. Ci vado?',
      'insegna musica in una scuola media da dodici anni'),
];

/// Le domande di mezzo, che non toccano il dettaglio.
const _diMezzo = [
  'Come posso dormire meglio in questi giorni?',
  'Che cosa mi dice la Luna di oggi?',
  'Mi sento stanca senza motivo. Da dove viene?',
  'Come ritrovo la voglia di fare?',
  'Che colore mi conviene indossare questa settimana?',
  'Come gestisco una collega che mi critica sempre?',
  'Che gesto faccio stasera per chiudere bene la giornata?',
  'Perché mi arrabbio così in fretta?',
  'Come mi preparo a un fine settimana pieno di gente?',
];

const _rispostaDiMezzo = 'Guarda con calma ciò che hai davanti: la cosa che '
    'temi è più piccola di come la immagini. Parti da un gesto concreto e '
    'osserva come ti senti dopo.\n✦ Stasera scrivi tre righe su come è '
    'andata la giornata.';

const _natale = NatalContext(
  sunSign: 'Cancro',
  moonSign: 'Bilancia',
  ascendant: 'Scorpione',
  lifeNumber: 7,
  lifeNumberTitle: 'il Cercatore',
);

/// La memoria: sintesi e fatti che non dicono il dettaglio; la conversazione
/// di oggi col dettaglio [c.scambiPrima] scambi prima della domanda.
Future<InMemoryMaestroMemoryRepository> _memoria(
    _Conversazione c, DateTime ora) async {
  final repo = InMemoryMaestroMemoryRepository();
  await repo.saveMemory(
      c.maestro,
      const MaestroMemory(
        sessionSummary: 'La persona cerca un po’ di ordine nelle giornate e '
            'chiede spesso consigli pratici per la sera.',
        facts: ['ha 41 anni', 'vive in un appartamento con il balcone'],
      ));
  final scambi = <String>[
    c.dettaglio,
    for (var i = 0; i < c.scambiPrima - 1; i++) _diMezzo[i % _diMezzo.length],
  ];
  for (var i = 0; i < scambi.length; i++) {
    final quando = ora.subtract(Duration(minutes: 3 * (scambi.length - i)));
    await repo.appendMessage(c.maestro,
        ChatMessage(role: ChatRole.user, text: scambi[i], at: quando));
    await repo.appendMessage(
        c.maestro,
        ChatMessage(
            role: ChatRole.maestro,
            autore: c.maestro,
            text: _rispostaDiMezzo,
            at: quando.add(const Duration(minutes: 1))));
  }
  return repo;
}

void main() {
  setUpAll(preparaIlBanco);

  test('la memoria compatta a confronto', () async {
    final giro = Platform.environment['GIRO'] ?? 'mc_senza_nome';
    final finestra = int.tryParse(Platform.environment['FINESTRA'] ?? '') ??
        FirebaseMaestroAiProvider.kHistoryWindow;
    final conIlRiassunto = Platform.environment['RIASSUNTO'] != '0';
    final adesso = DateTime.now();
    final righe = <String>[];
    for (final c in _conversazioni) {
      final controller = MaestroChatController(
        maestro: c.maestro,
        ai: VoceSorvegliata(
            voce: FirebaseMaestroAiProvider(
                finestraDellaStoria: finestra, conIlRiassunto: conIlRiassunto),
            registro: RegistroDeiGuasti()),
        memory: await _memoria(c, adesso),
        allowance: QuestionAllowance(freeDailyLimit: 999),
        tier: () => Tier.tier3,
        natal: () => _natale,
        attesaMinima: Duration.zero,
      );
      await controller.init();
      final prima = registro.length;
      String? errore;
      try {
        await controller.send(c.domanda);
      } catch (e) {
        errore = '$e';
      }
      final risposta = controller.messages.lastWhere((m) => m.isMaestro,
          orElse: () => const ChatMessage(role: ChatRole.maestro, text: ''));
      final chiamate = registro.sublist(prima);
      righe.add(jsonEncode({
        'giro': giro,
        'id': c.id,
        'maestro': c.maestro.id,
        'tipo': 'memoria',
        'nelLive': false,
        'domanda': c.domanda,
        'risposta': risposta.text,
        'seguito': null,
        'ripiego': risposta.ripiego,
        'errore': errore,
        'scambiPrima': c.scambiPrima,
        'chiamateRisposta': [
          for (final x in chiamate)
            {
              'funzione': x.funzione,
              'modello': x.modello,
              'ingresso': x.ingresso,
              'uscita': x.uscita,
              'ragionamento': x.ragionamento,
              'cache': x.dallaCache,
            }
        ],
        'fattiDellaMemoria': [c.fatto],
        'cieloDelleDate': const [],
      }));
      final ingresso = chiamate.fold<int>(0, (a, x) => a + x.ingresso);
      print('${c.id}: ${c.scambiPrima} scambi prima, chiamate '
          '${chiamate.length}, ingresso $ingresso'
          '${errore == null ? '' : ' ERRORE $errore'}');
    }
    final uscita = File('docs/collaudo/EX/qualita/$giro.jsonl')
      ..parent.createSync(recursive: true);
    uscita.writeAsStringSync('${righe.join('\n')}\n');
    print('MEMORIA COMPATTA giro $giro: finestra $finestra, riassunto '
        '$conIlRiassunto, conversazioni ${righe.length}');
  }, timeout: const Timeout(Duration(minutes: 30)));
}
