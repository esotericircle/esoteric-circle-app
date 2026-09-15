import 'dart:math';

import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/domande/cornici_del_presagio.dart';
import 'package:esoteric_circle/core/domande/domande_del_cerchio.dart';
import 'package:esoteric_circle/core/maestro/consult_depth.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_reply.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/responsi/anatomia_del_responso.dart';
import 'package:esoteric_circle/core/responsi/confine_del_responso.dart';
import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/core/rituals/rune_presage.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/services/ai/maestro_persona.dart';
import 'package:flutter_test/flutter_test.dart';

/// IL PRESAGIO PASSA DAL MODELLO, E IL RIPIEGO NON SI DICHIARA.
/// Ordine S voce 19, punto 3 della decisione D5.
///
/// **Cosa si puo' misurare senza rete e cosa no.** Che il modello scriva BENE non
/// lo dice nessuna prova: quella e' la misura (a) della decisione D5, che si esegue
/// una volta contro il modello vero e si riporta col numero. Qui si misura la
/// PLUMBERIA, che e' l'altra meta' e cade in silenzio se si rompe: che l'istruzione
/// porti il confine e l'anatomia, che i fatti arrivino al modello, e che quando il
/// modello tace resti un presagio intero senza un solo avviso.
void main() {
  test('l\'istruzione del presagio porta il confine, una volta sola', () {
    // Punto 5 della D5, sulla porta nuova: `presagioInstruction` passa da
    // `_commonRules` come tutte le altre, quindi il confine arriva senza che
    // questa istruzione lo nomini. Se un giorno qualcuno la scrivesse da zero,
    // questa riga cadrebbe.
    final istruzione = MaestroPersona.presagioInstruction(
      profile: UserProfile.empty,
      memory: MaestroMemory.empty,
    );
    final apertura = ConfineDelResponso.perIlModello.split(':').first;
    expect(istruzione.split(apertura).length - 1, 1,
        reason: 'il confine non arriva al presagio, o vi arriva due volte');
    for (final r in ConfineDelResponso.nonSiPuoMai) {
      expect(istruzione, contains(r));
    }
  });

  test('l\'istruzione porta l\'anatomia e la regola del simbolo', () {
    final istruzione = MaestroPersona.presagioInstruction(
      profile: UserProfile.empty,
      memory: MaestroMemory.empty,
    );
    // Le tre parti arrivano da `ParteDelResponso`, non riscritte a mano: se
    // l'anatomia cambia, l'istruzione cambia con lei.
    for (final p in ParteDelResponso.nelResponso) {
      expect(istruzione, contains(p.nome),
          reason: 'manca la parte "${p.nome}" nell\'istruzione del presagio');
    }
    expect(istruzione, contains('SOLO NELLA TERZA PARTE'),
        reason: 'l\'istruzione non dice al modello che il simbolo arriva per '
            'ultimo, che e\' la regola dell\'anatomia');
    // E la tradizione NON entra nel responso: la quarta parte non si chiede.
    expect(istruzione.contains(ParteDelResponso.tradizione.nome), isFalse);
  });

  test('senza domanda l\'istruzione lo dice, e non ne inventa una', () {
    final con = MaestroPersona.presagioInstruction(
        profile: UserProfile.empty, memory: MaestroMemory.empty);
    final senza = MaestroPersona.presagioInstruction(
        profile: UserProfile.empty,
        memory: MaestroMemory.empty,
        conDomanda: false);
    expect(con, contains('LA DOMANDA POSTA'));
    expect(senza, contains('NON HA SCELTO NESSUNA DOMANDA'));
    expect(senza, contains('Non inventare una domanda che non ha posto'));
  });

  test('quando il modello tace resta un presagio intero, e non lo dichiara',
      () async {
    // **LA MISURA CHE CONTA DAVVERO QUI.** Se il modello non risponde, la persona
    // deve leggere un presagio intero: cornice dell'allegato B piu' la frase della
    // runa. E non deve trovare da nessuna parte una parola che dica che quello e'
    // un ripiego.
    const muto = _VoceMuta();
    final esito = RuneCast.getta(gettataNorne, random: Random(5));
    final domanda = DomandeDelCerchio.generichePerLaGettata.first.testo;

    await expectLater(
      muto.presagioDelleRune(
          esito: esito, domanda: domanda, profile: UserProfile.empty),
      throwsA(isA<MaestroAiUnavailable>()),
      reason:
          'una voce che non c\'e\' deve sollevare, cosi\' chi chiama cade sul '
          'ripiego invece di mostrare il vuoto',
    );

    // Il ripiego, che e' cio' che la schermata mostra in quel caso.
    final presagio = RunePresagio.componiIlResponso(esito, domanda: domanda);
    expect(presagio.eIntero, isTrue);
    final cornice = CorniciDelPresagio.perDomanda(domanda)!;
    expect(presagio.risposta.startsWith(cornice.apertura), isTrue);
    expect(presagio.cosaPuoiFare, cornice.chiusura);
    // **NESSUNA PAROLA CHE LO DICHIARI**, e si nominano una per una perche' non
    // rientrino per distrazione.
    for (final parola in const [
      'ripiego',
      'offline',
      'non disponibile',
      'riprova',
      'errore',
      'generato',
    ]) {
      expect(presagio.inParole.toLowerCase().contains(parola), isFalse,
          reason: 'il ripiego si dichiara con la parola "$parola"');
    }
  });
}

/// Una voce che non risponde mai: e' il caso senza rete, e in quel caso la
/// schermata deve cadere sul ripiego.
class _VoceMuta implements MaestroAiProvider {
  const _VoceMuta();

  @override
  bool get isReady => true;

  @override
  Future<Responso> presagioDelleRune({
    required EsitoGettata esito,
    required String domanda,
    required UserProfile profile,
    NatalContext natal = NatalContext.none,
  }) async =>
      throw const MaestroAiUnavailable();

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
      throw const MaestroAiUnavailable();

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
  Future<String> synthesize({
    required String theme,
    required List<MaestroLens> lenses,
    NatalContext? natal,
  }) async =>
      throw const MaestroAiUnavailable();

  @override
  Future<MemoryDigest?> distill({
    required Maestro maestro,
    required UserProfile profile,
    required List<ChatMessage> history,
    required MaestroMemory previous,
  }) async =>
      null;
}
