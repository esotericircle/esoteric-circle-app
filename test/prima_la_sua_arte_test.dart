import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/il_rimando_in_fondo.dart';
import 'package:esoteric_circle/core/chat/la_risposta_nel_merito.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/consiglio_finale.dart';
import 'package:esoteric_circle/core/maestro/consult_depth.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_reply.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/maestro/voce_del_maestro.dart';
import 'package:esoteric_circle/core/responsi/anatomia_del_responso.dart';
import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_controller.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/services/ai/maestro_persona.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// **PRIMA LA SUA ARTE.** Ordine EQ voce 02, 27 settembre 2026.
///
/// Nelle catture, a *"Beh, vorrei avere una compagna, vorrei andare in
/// Australia e vorrei avessi successo col lavoro che sto facendo."*, Calìgo
/// ha aperto con *"Per i legami e il destino c'è Medora"* e dell'Australia
/// non ha detto niente: lo pretendeva la regola del cerchio dell'ordine EN,
/// *"la tua prima frase lo dice e lo chiama per nome"*. Il fondatore:
/// *"Risponde sempre nel merito con la sua arte (Calìgo: un rito per
/// l'amore). L'altro Maestro lo nomina solo in fondo, come consiglio in
/// più."*
///
/// **Qui si guarda l'istruzione che parte davvero**, per ciascuno dei tre. Il
/// collaudo con Gemini vero sta in `tool/collaudo_eq02.dart`, le trascrizioni
/// in `docs/collaudo/EQ/eq02/`.
void main() {
  String istruzioneDi(Maestro m) => MaestroPersona.systemInstruction(
        maestro: m,
        profile: UserProfile.empty,
        memory: MaestroMemory.empty,
      );

  test('ogni Maestro riceve la regola nuova, e nessuno la vecchia', () {
    final vecchie = <String>[];
    for (final m in Maestro.values) {
      final istr = istruzioneDi(m);
      expect(
          istr,
          contains('Rispondi sempre nel merito, con la tua arte, a ogni parte '
              'della domanda'),
          reason: '${m.id} non riceve la regola nuova del cerchio');
      expect(istr, contains('Quella frase non è mai la prima'),
          reason: '${m.id} non sa che il rimando non apre la risposta');
      for (final vecchia in const [
        'la tua prima frase lo dice',
        'esce dal tuo dominio, riconoscilo',
        'riconoscilo e indica con garbo',
      ]) {
        if (istr.contains(vecchia)) vecchie.add('${m.id}: "$vecchia"');
      }
    }
    expect(vecchie, isEmpty,
        reason: 'la regola dell\'ordine EN, che faceva aprire la risposta col '
            'nome di un altro Maestro, arriva ancora al modello: $vecchie');
  });

  test('la risposta nel merito non comincia da cio\' che non si puo\' fare',
      () {
    const blocco = LaRispostaNelMerito.perIlModello;
    expect(blocco, isNot(contains('dillo in UNA frase sola e passa subito')));
    expect(
        blocco,
        contains('Non cominciare mai dicendo che cosa non puoi fare, che non '
            'è la tua arte o chi altro se ne occupa'));
  });

  test('una domanda con piu\' parti ha una risposta per ciascuna', () {
    // **LA PRIMA STESURA NON BASTAVA, e il collaudo l'ha detto.** Tolto il
    // rimando in apertura, Calìgo rispondeva alla domanda delle catture con
    // "Scegli un obiettivo su cui concentrarti": nessuna delle tre parti
    // aveva la sua risposta (`docs/collaudo/EQ/eq02/dopo1/`).
    const blocco = LaRispostaNelMerito.perIlModello;
    expect(blocco, contains('UNA DOMANDA CON PIÙ PARTI HA PIÙ RISPOSTE'));
    expect(blocco, contains('non sceglierne una sola'));
    expect(blocco,
        contains('la tua prima frase risponde sì, no o a quali condizioni'));
    // E chi chiede la carta o la runa a un altro Maestro riceve il segno
    // della sua arte, per nome.
    for (final m in Maestro.values) {
      expect(istruzioneDi(m),
          contains('rispondi con ciò che la tua arte vede al suo posto'),
          reason: m.id);
    }
  });

  test('il controllo prima di scrivere e\' l\'ultima cosa che il modello legge',
      () {
    // **ULTIMO, E NON SOLO PRESENTE.** Le stesse regole stavano gia' in mezzo
    // al blocco della risposta nel merito e il collaudo le ha viste ignorate
    // (`docs/collaudo/EQ/eq02/dopo3/`): qui si pretende il posto.
    for (final m in Maestro.values) {
      for (final live in [false, true]) {
        final istr = MaestroPersona.systemInstruction(
          maestro: m,
          profile: UserProfile.empty,
          memory: MaestroMemory.empty,
          nelLive: live,
        );
        expect(istr.trimRight(), endsWith(LaRispostaNelMerito.primaDiScrivere),
            reason: '${m.id}, nel LIVE $live');
      }
    }
    expect(LaRispostaNelMerito.primaDiScrivere,
        contains('Non dirle mai di concentrarsi su una sola'));
  });

  test('restano le regole che non c\'entrano: firme, arti degli altri due', () {
    for (final m in Maestro.values) {
      final istr = istruzioneDi(m);
      // Le parole di firma degli altri due restano vietate.
      expect(istr, contains(VoceDelMaestro.titoloDelLessicoVietato));
      for (final p in VoceDelMaestro.lessicoDegliAltri(m)) {
        expect(istr, contains(p), reason: '${m.id}: firma altrui "$p"');
      }
      // Le arti degli altri due non si usano.
      expect(istr, contains('Non le usi mai'),
          reason: '${m.id} non sa piu\' che le arti degli altri non si usano');
      // E gli altri due si nominano, in fondo, per nome.
      for (final altro in Maestro.values) {
        if (altro == m) continue;
        expect(istr, contains('c\'è ${VoceDelMaestro.nomeDetto(altro)}'),
            reason: '${m.id} non sa a chi indirizzare in fondo');
      }
    }
  });

  group('il rimando in fondo, a valle', () {
    // La risposta vera di Calìgo nelle catture del fondatore.
    const delleCatture = 'Per i legami e il destino c\'è Medora, perciò '
        'rivolgi a lei le domande sull\'amore. Il tuo desiderio di successo '
        'nel lavoro indica la via del sentiero numerologico, quello che '
        'tracci con i tuoi atti.\n'
        '✦ Scrivi su un foglio il nome del lavoro che desideri.';

    test('la risposta delle catture: Medora va in fondo, il resto resta', () {
      expect(IlRimandoInFondo.chiNominaInApertura(delleCatture, Maestro.caligo),
          Maestro.medora);
      final spostata =
          IlRimandoInFondo.conIlRimandoInFondo(delleCatture, Maestro.caligo);
      final corpo = ConsiglioFinale.corpoDa(spostata);
      expect(ConsiglioFinale.primaFraseDi(corpo),
          startsWith('Il tuo desiderio di successo'));
      expect(corpo.trim(), endsWith('le domande sull\'amore.'));
      expect(ConsiglioFinale.sintesiDa(spostata),
          'Scrivi su un foglio il nome del lavoro che desideri.',
          reason: 'la riga d\'oro resta l\'ultima');
    });

    test('la tua aura non e\' la Maestra, e chi chiede non si tocca', () {
      expect(
          IlRimandoInFondo.chiNominaInApertura(
              'La tua aura oggi è limpida. Parti.', Maestro.medora),
          isNull);
      expect(
          IlRimandoInFondo.chiNominaInApertura(
              'Io sono Aura, e il corpo mi parla.', Maestro.aura),
          isNull);
      const chiede = '[[CHIEDO]]\nPer i riti c\'è Calìgo. Di che rito parli?';
      expect(
          IlRimandoInFondo.conIlRimandoInFondo(chiede, Maestro.medora), chiede);
    });

    test('nel controller la frase del rimando arriva in fondo', () async {
      final c = MaestroChatController(
        maestro: Maestro.caligo,
        ai: _Risponde(delleCatture),
        memory: InMemoryMaestroMemoryRepository(),
        natal: () => NatalContext.none,
        demo: true,
        attesaMinima: Duration.zero,
      );
      await c.init();
      await c.send('Beh, vorrei avere una compagna, vorrei andare in '
          'Australia e vorrei avessi successo col lavoro che sto facendo.');
      final testo = c.messages.last.text;
      // ignore: avoid_print
      print('EQ.02 MISURA: rimandi spostati in fondo '
          '${c.rimandiSpostatiInFondo}, a schermo "$testo"');
      expect(
          IlRimandoInFondo.chiNominaInApertura(testo, Maestro.caligo), isNull,
          reason: 'la prima frase a schermo nomina ancora un altro Maestro');
      expect(c.rimandiSpostatiInFondo, 1);
    });
  });
}

/// Un modello finto che risponde sempre con [testo].
class _Risponde implements MaestroAiProvider {
  _Risponde(this.testo);
  final String testo;

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
  }) async =>
      testo;

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
