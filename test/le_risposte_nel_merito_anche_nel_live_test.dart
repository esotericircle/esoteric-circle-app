// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/la_risposta_d_attesa.dart';
import 'package:esoteric_circle/core/chat/la_risposta_nel_merito.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/consult_depth.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_reply.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/maestro/voce_del_maestro.dart';
import 'package:esoteric_circle/core/responsi/anatomia_del_responso.dart';
import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_controller.dart';
import 'package:esoteric_circle/services/ai/la_richiesta_del_turno.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/services/ai/maestro_persona.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// **LE RISPOSTE NEL MERITO, ANCHE NEL LIVE. Ordine EQ voce 03**, 27
/// settembre 2026.
///
/// Nelle catture del fondatore, a *"Ok, le ho scritte e adesso cosa
/// faccio?"* Calìgo risponde nel LIVE *"Il tuo gesto è compiuto. Ora lascia
/// che il tempo faccia il suo corso."*: non dice niente. Il collaudo "prima"
/// (`docs/collaudo/EQ/eq03/prima/`) ha visto le stesse forme su tutti e tre i
/// Maestri: le frasi che andrebbero bene per chiunque, le massime brevi, il
/// passo appena raccontato ignorato, e una riga d'oro ricopiata parola per
/// parola dall'esempio dell'apertura di Medora ("Scrivi stasera a chi ti ha
/// ferito..."), dove nessuno aveva ferito nessuno.
///
/// Il merito lo misura il collaudo con Gemini vero (`tool/collaudo_eq03.dart`);
/// questa guardia tiene al loro posto le regole che il collaudo ha misurato.
void main() {
  group('le regole della risposta nel merito', () {
    test('cio\' che la persona ha appena fatto, nella regola comune', () {
      const blocco = LaRispostaNelMerito.perIlModello;
      expect(blocco,
          contains('QUANDO LA PERSONA TI DICE CHE COSA HA FATTO O CHE COSA'),
          reason: 'la regola non dice di partire da cio\' che la persona ha '
              'appena fatto o raccontato: e\' il difetto delle catture');
      expect(blocco, contains('il passo che viene dopo'),
          reason: 'la regola non chiede il passo dopo quello fatto');
      // Nella sonda, a "Ok, gli ho scritto adesso" tutti e tre i Maestri
      // hanno risposto almeno una volta "attendi la sua risposta" e basta.
      expect(blocco, contains('«aspetta» da solo non è una risposta'),
          reason: 'la regola lascia passare l\'attesa senza misura come '
              'risposta');
    });

    test('Aura: il corpo accompagna il passo, non lo sostituisce', () {
      expect(VoceDelMaestro.di(Maestro.aura).apertura,
          contains('Il corpo accompagna il passo, non lo sostituisce'),
          reason: 'l\'apertura di Aura lascia che il respiro prenda il posto '
              'del passo nella vita della persona');
      // Il registro: la regola che le vietava ogni momento ("Non nomini mai
      // il futuro né una data") le toglieva anche "stasera", e con lui il
      // passo. Il passo si lega a un gesto della persona, mai a un giorno.
      final registro = VoceDelMaestro.di(Maestro.aura).registro;
      expect(registro, contains('rispondi con un passo nella vita di questa'),
          reason: 'il registro di Aura non chiede un passo nella vita della '
              'persona');
      expect(registro, isNot(contains('Non nomini mai il futuro né una data')),
          reason: 'il registro di Aura le vieta di nuovo ogni momento, e con '
              'lui il passo');
    });

    test('il controllo prima di scrivere chiede le due cose nuove', () {
      const controllo = LaRispostaNelMerito.primaDiScrivere;
      expect(controllo, contains('la tua prima frase parte da lì'),
          reason: 'il controllo finale non chiede di partire da cio\' che la '
              'persona ha appena detto');
      expect(controllo, contains('vale per lei sola'),
          reason: 'il controllo finale non chiede di togliere le frasi che '
              'andrebbero bene per chiunque');
    });

    test('nel LIVE, anche in tre frasi, la prima dice che cosa fare', () {
      expect(MaestroPersona.rispostaDettaAVoce,
          contains('la prima dice che cosa fare in concreto'),
          reason: 'la forma del LIVE non chiede una risposta concreta: le '
              'tre frasi diventano sentenze');
      for (final m in Maestro.values) {
        final istr = MaestroPersona.systemInstruction(
          maestro: m,
          profile: UserProfile.empty,
          memory: MaestroMemory.empty,
          nelLive: true,
        );
        expect(istr, contains(MaestroPersona.rispostaDettaAVoce),
            reason: '${m.id}: il LIVE non riceve la sua forma');
        expect(istr, contains(LaRispostaNelMerito.perIlModello),
            reason: '${m.id}: il LIVE non riceve la regola comune');
      }
    });
  });

  group('nell\'apertura dei Maestri, nessun esempio da ricopiare', () {
    // **UN ESEMPIO POSITIVO VIENE RICOPIATO, NON CAPITO.** L'ordine EQ voce
    // 01 l'ha tolto dal consiglio finale; nel collaudo di questa voce
    // Flash-Lite ha ricopiato come riga d'oro l'esempio dell'apertura di
    // Medora tre volte in dodici risposte. Gli esempi fra virgolette restano
    // ammessi solo per dire che cosa NON fare: la frase che li introduce,
    // dalla virgoletta di prima a questa, porta un "non".
    for (final m in Maestro.values) {
      test(m.id, () {
        final apertura = VoceDelMaestro.di(m).apertura;
        final positivi = <String>[];
        final virgolette = RegExp(r'"([^"]*)"').allMatches(apertura).toList();
        var da = 0;
        for (final v in virgolette) {
          final davanti = apertura.substring(da, v.start).toLowerCase();
          if (!RegExp(r'\bnon\b').hasMatch(davanti)) positivi.add(v.group(1)!);
          da = v.end;
        }
        print('ORDINE EQ VOCE 03, ${m.id}: esempi fra virgolette '
            '${virgolette.length}, da ricopiare ${positivi.length}');
        expect(positivi, isEmpty,
            reason: '${m.id}: l\'apertura porta un esempio da imitare, e il '
                'modello lo ricopia: $positivi');
      });
    }
  });

  group('la risposta che dice solo di aspettare, a valle', () {
    // Le due risposte delle catture del fondatore, alla lettera, due delle
    // sonde del collaudo con la regola gia' scritta nell'istruzione, e due
    // varianti del primo giro "dopo", che la rete della prima stesura non
    // conosceva (Medora con Flash, "resta in attesa" e "non forzare gli
    // eventi").
    const vuote = [
      'Il tuo gesto è compiuto. Ora lascia che il tempo faccia il suo corso.'
          '\n\n✦ Scrivi su un foglio di carta bianca tre cose che vorresti '
          'realizzare.',
      'Hai fatto un passo. Ora attendi la sua risposta.\n\n✦ Scrivi su un '
          'foglio di carta bianca tre cose che vorresti realizzare.',
      'Hai scritto. Ora il tuo compito è la pazienza. Non forzare l\'esito, '
          'lascia che il tempo riveli il suo disegno.',
      'Bene. Ora attendi la sua risposta, senza chiedere altro e senza fare '
          'altri gesti in questa fase.',
      'Le hai scritto ed ora resta in attesa, mantenendo la tua mente aperta '
          'a ogni esito.',
      'Il cielo suggerisce un momento di pazienza.',
      'Non forzare gli eventi: lascia fluire ciò che hai mosso.',
    ];
    // L'attesa misurata, un gesto, un'attesa dopo le prime due frasi, e una
    // frase d'attesa nella sola riga con ✦: nessuna e' una risposta vuota.
    const buone = [
      'Ora aspetta sette giorni prima di scrivergli di nuovo: se tace, la '
          'risposta è già quella.',
      'Adesso piegale in tre e mettile sotto una candela bianca accesa '
          'stasera.',
      'Scrivi al tuo capo tre righe col risultato del mese. Chiedigli dieci '
          'minuti venerdì. Poi attendi la sua risposta senza riscrivere.',
      'Il pianto di tua madre è paura di perderti, non un divieto. Stasera '
          'richiamala.\n\n✦ Lascia che il tempo porti consiglio.',
    ];

    test('le frasi delle catture e delle sonde si riconoscono, le buone no',
        () {
      for (final v in vuote) {
        expect(LaRispostaDAttesa.segno(v), isNotNull,
            reason: 'non riconosce come vuota: "$v"');
      }
      for (final b in buone) {
        expect(LaRispostaDAttesa.segno(b), isNull,
            reason: 'prende per vuota una risposta buona: "$b"');
      }
    });

    test('il controller la chiede di nuovo, una volta, nominandola', () async {
      final ai = _Finta([
        vuote.first,
        'Adesso rileggile e scegli quella che ti fa battere il cuore: domani '
            'mattina scrivi il primo passo per realizzarla.',
      ]);
      final c = MaestroChatController(
        maestro: Maestro.caligo,
        ai: ai,
        memory: InMemoryMaestroMemoryRepository(),
        natal: () => NatalContext.none,
        demo: true,
        attesaMinima: Duration.zero,
      )..nelLive = true;
      await c.init();
      await c.send('Ok, le ho scritte e adesso cosa faccio?');
      final detta = c.messages.lastWhere((m) => m.isMaestro).text;
      print('ORDINE EQ VOCE 03, la risposta consegnata: "$detta"');
      expect(detta, isNot(contains('gesto è compiuto')),
          reason: 'la risposta delle catture e\' arrivata alla persona');
      expect(c.rigenerazioniPerAttesa, 1);
      expect(ai.daAttesa.whereType<String>().single, vuote.first,
          reason: 'la richiesta non nomina al modello la risposta da non '
              'ridare');
    });

    test('la nota dice che cosa fare di un\'attesa, e il provider la passa',
        () {
      // "Parole nuove", la nota della risposta ripetuta, non bastava: nel
      // collaudo la seconda risposta diceva di nuovo "ora attendi la sua
      // risposta". La nota dedicata dice che cosa mettere al suo posto.
      final istruzione = MaestroPersona.systemInstruction(
        maestro: Maestro.caligo,
        profile: UserProfile.empty,
        memory: MaestroMemory.empty,
        nelLive: true,
        daAttesa: vuote.first,
      );
      expect(istruzione, contains('DICE SOLO DI ASPETTARE'));
      expect(istruzione, contains(vuote.first.trim()));
      expect(
          istruzione, contains('che cosa fare se tace e dopo quanti giorni'));
      expect(
          File('lib/services/ai/firebase_maestro_ai_provider.dart')
              .readAsStringSync(),
          contains('daAttesa: turno.daAttesa'),
          reason: 'il provider vero non passa la nota al modello');
    });
  });
}

/// Un Maestro finto che risponde in fila le risposte date, e annota che
/// cosa gli chiede il turno.
class _Finta implements MaestroAiProvider {
  _Finta(this.risposte);

  final List<String> risposte;
  final List<String?> daAttesa = [];

  @override
  bool get isReady => true;

  @override
  Future<String> reply({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory memory,
    required List<ChatMessage> history,
    required String userMessage,
    NatalContext natal = NatalContext.none,
    bool insistiSullAncoraggio = false,
    String? rispostaGiaData,
  }) async {
    daAttesa.add(LaRichiestaDelTurno.corrente.daAttesa);
    final i = daAttesa.length - 1;
    return i < risposte.length ? risposte[i] : risposte.last;
  }

  @override
  Future<MaestroReply> consult({
    required Maestro maestro,
    required String theme,
    required UserProfile profile,
    MaestroMemory memory = MaestroMemory.empty,
    NatalContext? natal,
    ConsultDepth depth = ConsultDepth.breve,
  }) async =>
      throw const MaestroAiUnavailable();

  @override
  Future<Responso> presagioDelleRune({
    required EsitoGettata esito,
    required String domanda,
    required UserProfile profile,
    NatalContext natal = NatalContext.none,
  }) async =>
      throw const MaestroAiUnavailable();

  @override
  Future<String> synthesize({
    required String theme,
    required List<MaestroLens> lenses,
    NatalContext? natal,
    UserProfile? profile,
  }) async =>
      throw const MaestroAiUnavailable();

  @override
  Future<MemoryDigest?> distill({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory previous,
    required List<ChatMessage> history,
  }) async =>
      null;
}
