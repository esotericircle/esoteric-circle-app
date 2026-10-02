// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/core/astro/il_cielo_per_il_maestro.dart';
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
import 'package:esoteric_circle/services/ai/la_cache_del_contesto.dart';
import 'package:flutter_test/flutter_test.dart';

import 'il_banco_del_costo_comune.dart';

/// **IL BANCO DELLA QUALITA'.** Ordine EX, regola NESSUNA RISPOSTA
/// PEGGIORA, 2 ottobre 2026.
///
/// Trenta casi fissi fatti girare col codice VERO della chat
/// (`MaestroChatController`, il provider, le reti, le funzioni del cielo) e
/// Gemini in europe-west1, come il banco del costo dell'ordine EW. Per ogni
/// caso si salvano la risposta che la persona legge, il "Vai piu' a fondo"
/// (nella chat), le chiamate fatte coi loro consumi, e i fatti di
/// riferimento che servono a chi giudica: i fatti della memoria che la
/// domanda chiama, il cielo delle effemeridi dell'app per le date della
/// domanda.
///
/// Gli stessi casi girano prima e dopo ogni voce che cambia il modo in cui
/// nasce una risposta (EX.04, EX.05, EX.07, EX.08, EX.09); i giudizi si
/// fanno alla cieca, sui due giri mescolati nello stesso fascicolo
/// (`tool/il_fascicolo_della_qualita.py`).
///
///     GIRO=prima flutter test -r expanded tool/il_banco_della_qualita.dart
///
/// Scrive `docs/collaudo/EX/qualita/<GIRO>.jsonl`. Non e' nella suite: costa
/// chiamate vere.

/// Un caso: il Maestro, la domanda, il tipo, se e' detta nel LIVE, e i
/// fatti di riferimento (per la memoria) o le date del cielo.
class Caso {
  const Caso(this.id, this.maestro, this.domanda, this.tipo,
      {this.nelLive = false, this.fatti = const [], this.date = const []});
  final String id;
  final Maestro maestro;
  final String domanda;

  /// memoria, cielo_oggi, cielo_data, merito.
  final String tipo;
  final bool nelLive;
  final List<String> fatti;

  /// Le date del cielo da mettere accanto, "aaaa-mm-gg".
  final List<String> date;
}

String _g(DateTime d) => '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

List<Caso> casi(DateTime oggi) {
  final g = _g(oggi);
  final domani = _g(oggi.add(const Duration(days: 1)));
  return [
    // **MEMORIA**: la risposta giusta ha bisogno di un fatto che la persona
    // ha detto in passato e non ripete.
    const Caso(
        'M1',
        Maestro.aura,
        'Mi sento in colpa per come sono andate le cose con lei a Natale. '
            'Da dove riparto?',
        'memoria',
        fatti: [
          'ha litigato con la sorella a Natale',
          'vive a Torino con la sorella'
        ]),
    const Caso(
        'M2',
        Maestro.medora,
        'Il colloquio si avvicina e ho lo stomaco chiuso. Come mi preparo?',
        'memoria',
        fatti: [
          'ha un colloquio a fine mese',
          'dorme male prima delle scadenze'
        ]),
    const Caso(
        'M3',
        Maestro.caligo,
        'Ombra non mangia da due giorni e io sono agitata. Che cosa faccio?',
        'memoria',
        fatti: ['ha un cane che si chiama Ombra']),
    const Caso(
        'M4',
        Maestro.medora,
        'Sto pensando di nuovo al trasferimento. Mi conviene davvero?',
        'memoria',
        fatti: [
          'sta pensando di trasferirsi a Berlino',
          'lavora in banca da otto anni'
        ]),
    const Caso('M5', Maestro.aura,
        'Lui mi ha chiesto di vederci sabato. Ci vado?', 'memoria',
        fatti: ['ha conosciuto Marco tre mesi fa']),
    const Caso(
        'M6',
        Maestro.caligo,
        'Quella cosa con le mani che sogno da anni: e\' il momento di '
            'provarci?',
        'memoria',
        fatti: ['ama la ceramica e vorrebbe aprire una bottega']),
    const Caso(
        'M7',
        Maestro.aura,
        'Ho paura che mia madre resti delusa da me. Come la gestisco?',
        'memoria',
        fatti: ['ha paura di deludere la madre']),
    const Caso('M8', Maestro.medora,
        'Domattina ho un\'ora libera prima del lavoro. Come la uso?', 'memoria',
        fatti: ['medita la mattina presto', 'lavora in banca da otto anni']),
    // **CIELO DI OGGI**: le date della prova EV.03, oggi.
    Caso('C1', Maestro.medora, 'In che segno è la Luna oggi, e in che fase?',
        'cielo_oggi',
        date: [g]),
    Caso('C2', Maestro.medora, 'Quali pianeti sono retrogradi oggi?',
        'cielo_oggi',
        date: [g]),
    Caso('C3', Maestro.medora, 'Dov\'è Venere oggi?', 'cielo_oggi', date: [g]),
    Caso('C4', Maestro.medora, 'Com\'è il cielo di oggi per me?', 'cielo_oggi',
        date: [g]),
    Caso('C5', Maestro.medora, 'Com\'è il cielo domani?', 'cielo_data',
        date: [domani]),
    // **CIELO DI ALTRE DATE**, dalla prova EV.03.
    const Caso('C6', Maestro.medora,
        'In che segno era Saturno il primo gennaio 2000?', 'cielo_data',
        date: ['2000-01-01']),
    const Caso('C7', Maestro.medora,
        'Che fase aveva la Luna il 20 luglio 1969?', 'cielo_data',
        date: ['1969-07-20']),
    const Caso('C8', Maestro.medora,
        'In che segno sarà Giove il primo gennaio 2028?', 'cielo_data',
        date: ['2028-01-01']),
    // **NEL MERITO**: domande di vita.
    const Caso(
        'R1',
        Maestro.medora,
        'Il mio capo mi ha offerto un ruolo nuovo con più responsabilità ma '
            'meno tempo libero. Accetto?',
        'merito'),
    const Caso(
        'R2',
        Maestro.aura,
        'Ho speso troppo quest\'anno e mi vergogno. Da dove comincio a '
            'rimettere ordine?',
        'merito'),
    const Caso(
        'R3',
        Maestro.caligo,
        'Devo scegliere fra due offerte di casa: una in centro piccola, una '
            'in periferia grande. Quale?',
        'merito'),
    const Caso('R4', Maestro.aura,
        'Non riesco a dormire prima delle due. Cosa faccio stasera?', 'merito'),
    const Caso('R5', Maestro.medora,
        'Il 15 novembre è un buon giorno per firmare un contratto?', 'merito',
        date: ['2026-11-15']),
    const Caso('R6', Maestro.caligo,
        'Un amico mi ha chiesto dei soldi in prestito. Glieli do?', 'merito'),
    const Caso(
        'R7', Maestro.aura, 'Ciao, chi sei? Come puoi aiutarmi?', 'merito'),
    const Caso(
        'R8',
        Maestro.medora,
        'Mi hanno lasciata ieri sera dopo due anni. Come sopravvivo a '
            'questa settimana?',
        'merito'),
    // **NEL LIVE**: la stessa catena, detta a voce.
    const Caso(
        'L1',
        Maestro.medora,
        'Medora, il mio capo mi ha offerto un nuovo ruolo in un\'altra città. '
            'Devo accettare?',
        'merito',
        nelLive: true),
    Caso('L2', Maestro.medora, 'E che cosa dice la Luna di stasera per me?',
        'cielo_oggi',
        nelLive: true, date: [g]),
    const Caso(
        'L3',
        Maestro.aura,
        'Mia sorella e io non ci parliamo da Natale. Come posso fare il primo '
            'passo?',
        'memoria',
        nelLive: true,
        fatti: ['ha litigato con la sorella a Natale']),
    const Caso(
        'L4',
        Maestro.aura,
        'Grazie. Un\'ultima cosa: come ritrovo la calma prima di dormire?',
        'memoria',
        nelLive: true,
        fatti: ['dorme male prima delle scadenze']),
    const Caso(
        'L5',
        Maestro.caligo,
        'Calìgo, ho una scelta da fare entro venerdì e non dormo. Aiutami.',
        'merito',
        nelLive: true),
    const Caso(
        'L6',
        Maestro.caligo,
        'Il colloquio di fine mese mi spaventa. Che cosa porto con me?',
        'memoria',
        nelLive: true,
        fatti: ['ha un colloquio a fine mese']),
  ];
}

const _natale = NatalContext(
  sunSign: 'Cancro',
  moonSign: 'Bilancia',
  ascendant: 'Scorpione',
  lifeNumber: 7,
  lifeNumberTitle: 'il Cercatore',
);

const _fatti = [
  'lavora in banca da otto anni',
  'vive a Torino con la sorella',
  'ha un cane che si chiama Ombra',
  'sta pensando di trasferirsi a Berlino',
  'ha conosciuto Marco tre mesi fa',
  'ha litigato con la sorella a Natale',
  'dorme male prima delle scadenze',
  'ama la ceramica e vorrebbe aprire una bottega',
  'ha un colloquio a fine mese',
  'medita la mattina presto',
  'ha paura di deludere la madre',
  'ha 34 anni',
];

/// La memoria piena, uguale per tutti i giri: sintesi, dodici fatti e
/// venti turni di conversazione nei quattordici giorni della finestra.
Future<InMemoryMaestroMemoryRepository> _memoria(
    Maestro m, DateTime ora) async {
  final repo = InMemoryMaestroMemoryRepository();
  await repo.saveMemory(
      m,
      const MaestroMemory(
        sessionSummary: 'Abbiamo parlato a lungo del trasferimento a Berlino, '
            'della relazione con Marco e del lavoro nuovo: la persona cerca '
            'una conferma prima di ogni scelta e ha paura di sbagliare.',
        facts: _fatti,
      ));
  const domande = [
    'Mi trasferisco a Berlino per lavoro?',
    'Come posso ritrovare la calma prima di dormire?',
    'Devo dire a Marco che mi piace?',
    'Mia sorella e io abbiamo litigato a Natale, cosa faccio?',
    'Ho un colloquio a fine mese, come mi preparo?',
  ];
  for (var i = 0; i < 20; i++) {
    final quando = ora.subtract(Duration(days: 13 - i % 14, minutes: 40 - i));
    await repo.appendMessage(
        m,
        ChatMessage(
            role: ChatRole.user,
            text: domande[i % domande.length],
            at: quando));
    await repo.appendMessage(
        m,
        ChatMessage(
            role: ChatRole.maestro,
            autore: m,
            text: 'Ti dico di guardare con calma cio\' che hai davanti: la '
                'scelta che temi e\' piu\' piccola di come la immagini. '
                'Parti da un gesto concreto e osserva come ti senti dopo.\n'
                '✦ Domani mattina fai la telefonata che rimandi.',
            at: quando.add(const Duration(minutes: 1))));
  }
  return repo;
}

void main() {
  setUpAll(preparaIlBanco);
  // I guasti innocui (reti, frasi del cielo smentite) a video, col caso.
  setUp(() => GuastiVersoIlCruscotto.inoltro =
      (cosa, errore, traccia) => print('GUASTO INNOCUO: $cosa'));

  test('il banco della qualita', () async {
    final giro = Platform.environment['GIRO'] ?? 'senza_nome';
    // Ordine EX Aggiunta 4, voce EX.05: CACHE=simulata manda la prima
    // risposta della chat dalla strada della cache, senza cache.
    LaCacheDelContesto.simulataNelBanco =
        Platform.environment['CACHE'] == 'simulata';
    final soli = {
      ...?Platform.environment['CASI']?.split(',').where((x) => x.isNotEmpty)
    };
    final adesso = DateTime.now();
    final oggi = DateTime(adesso.year, adesso.month, adesso.day);
    final uscita = File('docs/collaudo/EX/qualita/$giro.jsonl');
    uscita.parent.createSync(recursive: true);
    final righe = <String>[];
    for (final c in casi(oggi)) {
      if (soli.isNotEmpty && !soli.contains(c.id)) continue;
      final sorvegliata = VoceSorvegliata(
          voce: FirebaseMaestroAiProvider(), registro: RegistroDeiGuasti());
      final controller = MaestroChatController(
        maestro: c.maestro,
        ai: sorvegliata,
        memory: await _memoria(c.maestro, adesso),
        allowance: QuestionAllowance(freeDailyLimit: 999),
        tier: () => Tier.tier3,
        natal: () => _natale,
        attesaMinima: Duration.zero,
      );
      await controller.init();
      controller.nelLive = c.nelLive;
      final prima = registro.length;
      final dallaCachePrima = LaCacheDelContesto.risposteDallaCache;
      String? errore;
      try {
        await controller.send(c.domanda);
      } catch (e) {
        errore = '$e';
      }
      final dopoRisposta = registro.length;
      final risposta = controller.messages.lastWhere((m) => m.isMaestro,
          orElse: () => const ChatMessage(role: ChatRole.maestro, text: ''));
      String? seguito;
      if (!c.nelLive) {
        try {
          await controller.approfondisci();
        } catch (e) {
          errore = '${errore ?? ''} seguito: $e';
        }
        final ultima = controller.messages.lastWhere((m) => m.isMaestro,
            orElse: () => const ChatMessage(role: ChatRole.maestro, text: ''));
        seguito = ultima.seguito ??
            (identical(ultima, risposta) ? null : ultima.text);
      }
      Map<String, Object?> chiamata(UnaChiamata x) => {
            'funzione': x.funzione,
            'modello': x.modello,
            'ingresso': x.ingresso,
            'uscita': x.uscita,
            'ragionamento': x.ragionamento,
            'cache': x.dallaCache,
          };
      righe.add(jsonEncode({
        'giro': giro,
        'quando': DateTime.now().toIso8601String(),
        'id': c.id,
        'maestro': c.maestro.id,
        'tipo': c.tipo,
        'nelLive': c.nelLive,
        'domanda': c.domanda,
        'risposta': risposta.text,
        'ripiego': risposta.ripiego,
        'seguito': seguito,
        'errore': errore,
        'chiamateRisposta': [
          for (final x in registro.sublist(prima, dopoRisposta)) chiamata(x)
        ],
        'chiamateSeguito': [
          for (final x in registro.sublist(dopoRisposta)) chiamata(x)
        ],
        // Le reti che hanno chiesto di nuovo la risposta, coi contatori del
        // controller.
        'reti': {
          'troncatura': controller.rigenerazioniPerTroncatura,
          'posizione': controller.rigenerazioniPerPosizione,
          'certezza': controller.rigenerazioniPerCertezza,
          'ancoraggio': controller.rigenerazioniPerAncoraggio,
          'programma': controller.rigenerazioniPerProgramma,
          'attesa': controller.rigenerazioniPerAttesa,
          'ripetizione': controller.rigenerazioniPerRipetizione,
          'rigaDOro': controller.rigenerazioniPerRigaDOro,
          'vuota': controller.rigenerazioniPerVuota,
          'cieloSmentito': controller.frasiDelCieloSmentite,
          'correzioniCorte': controller.correzioniCorte,
          // Ordine EX Aggiunta 4, voce EX.07: la rete del lessico, che
          // rifa' la risposta da capo e prima non si contava.
          'voceConfusa': sorvegliata.confusioni,
        },
        'dallaCache': LaCacheDelContesto.risposteDallaCache - dallaCachePrima,
        'paroleConfuse': sorvegliata.paroleConfuse,
        'scartate': [
          for (final x in controller.risposteScartate)
            {'risposta': x.risposta, 'correzione': x.correzione}
        ],
        // Ordine EX Aggiunta 4, voce EX.04: il seguito preparato in
        // sottofondo, quello aspettato dal tocco e quello chiesto al tocco.
        'seguitoInSottofondo': {
          'preparati': controller.seguitiPreparati,
          'attesi': controller.seguitiAttesi,
          'chiestiAlTocco': controller.seguitiChiestiAlTocco,
        },
        'fattiDellaMemoria': c.fatti,
        'cieloDelleDate': [
          for (final d in c.date)
            IlCieloPerIlMaestro.oggiInRighe(DateTime.parse(d))
        ],
      }));
      print('${c.id}: chiamate ${dopoRisposta - prima} + '
          '${registro.length - dopoRisposta}'
          '${errore == null ? '' : ' ERRORE $errore'}');
    }
    uscita.writeAsStringSync('${righe.join('\n')}\n');
    print('BANCO DELLA QUALITA\' giro $giro: casi ${righe.length}, chiamate '
        '${registro.length}');
  }, timeout: const Timeout(Duration(minutes: 60)));
}
