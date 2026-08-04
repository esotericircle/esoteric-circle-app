import 'dart:io';

import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/entitlement/plan_catalog.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/maestro/consult_depth.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_reply.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_controller.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// IL SECONDO STRATO E' UN PREMIUM, ED ERA SMESSO DI ESSERLO.
///
/// **Il difetto, misurato.** Nell'ordine 9 il budget era stato spostato a
/// governare la PRODUZIONE invece dell'accesso: a un Viandante si chiedevano
/// cinquanta parole, ma il modello non obbedisce al numero e ci si avvicina da
/// sopra. Con una risposta da settantatre parole il secondo strato esisteva
/// davvero, la freccia compariva, e al tocco si rivelava: nel percorso della
/// rivelazione non c'era **nessun** controllo del piano.
///
/// **La freccia si vede lo stesso, sempre.** Non e' un muro: al tocco porta
/// agli abbonamenti. Un lucchetto muto e' un vicolo cieco.
void main() {
  Future<MaestroChatController> con(
    Tier piano, {
    QuestionAllowance? contatore,
  }) async {
    final memoria = InMemoryMaestroMemoryRepository();
    await memoria
        .saveProfile(UserProfile(disclaimerAcceptedAt: DateTime(2026, 7, 1)));
    final c = MaestroChatController(
      maestro: Maestro.medora,
      ai: _VoceLunga(),
      memory: memoria,
      allowance: contatore ?? QuestionAllowance(),
      tier: () => piano,
      natal: () => const NatalContext(sunSign: 'Cancro'),
    );
    await c.init();
    return c;
  }

  group('Il Viandante non accede, ma non trova un muro', () {
    test('La freccia SI VEDE anche al Viandante', () async {
      final c = await con(Tier.free);
      await c.send('devo cambiare lavoro');
      expect(c.puoiChiedereDiApprofondire, isTrue,
          reason: 'la freccia sparisce per il Viandante invece di portarlo '
              'agli abbonamenti: un lucchetto muto e\' un vicolo cieco');
    });

    test('Ma NON legge il secondo strato', () async {
      final c = await con(Tier.free);
      await c.send('devo cambiare lavoro');
      expect(c.puoiLeggereIlSecondoStrato, isFalse);
      expect(c.ilPianoComprendeIlSecondoStrato, isFalse,
          reason: 'il piano del Viandante comprende il secondo strato, e non '
              'dovrebbe: e\' il difetto da cui questa voce e\' nata');
      await c.approfondisci();
      expect(c.messages.last.approfondita, isFalse,
          reason: 'IL VIANDANTE HA LETTO IL SECONDO STRATO. E\' il difetto '
              'misurato: la rivelazione non guardava nessun piano');
    });

    test('E la porta che si apre e\' quella degli abbonamenti', () {
      // La schermata distingue DUE cose: chi non ce l'ha nel piano riceve
      // l'invito a salire, chi ce l'ha e li ha finiti riceve il numero vero.
      // Qui si verifica che quel ramo esista davvero nel sorgente.
      final s = File('lib/features/maestri/chat/maestro_chat_screen.dart')
          .readAsStringSync();
      expect(s, contains('ilPianoComprendeIlSecondoStrato'),
          reason: 'la chat non distingue piu\' chi non ce l\'ha nel piano');
      expect(s, contains('showUpgradeInvite'),
          reason: 'toccando la freccia il Viandante non arriva da nessuna '
              'parte');
      expect(s, contains('puoiLeggereIlSecondoStrato'),
          reason: 'chi ha finito i suoi non riceve il numero vero');
    });
  });

  group('I tetti governano l\'ACCESSO, non la produzione', () {
    test('Tre, dieci, senza limite, dal listino e non da qui', () {
      // Un solo meccanismo di gating: `PlanCatalog`, la stessa matrice che
      // dice chi ha la memoria dei Maestri.
      expect(
          PlanCatalog.limiteGiornaliero(
              PlanCatalog.rigaApprofondimenti, Tier.free),
          0);
      expect(
          PlanCatalog.limiteGiornaliero(
              PlanCatalog.rigaApprofondimenti, Tier.tier1),
          3);
      expect(
          PlanCatalog.limiteGiornaliero(
              PlanCatalog.rigaApprofondimenti, Tier.tier2),
          10);
      expect(
          PlanCatalog.limiteGiornaliero(
              PlanCatalog.rigaApprofondimenti, Tier.tier3),
          isNull);
      expect(QuestionAllowance.kTettoDiCorrettezza, 30);
    });

    test('Il conto si consuma quando si LEGGE, non quando si scrive', () async {
      final contatore = QuestionAllowance();
      final c = await con(Tier.tier1, contatore: contatore);
      final prima = contatore.approfondimentiRimasti(Tier.tier1);
      await c.send('devo cambiare lavoro');
      expect(contatore.approfondimentiRimasti(Tier.tier1), prima,
          reason: 'il budget e\' stato contato su cio\' che si genera invece '
              'che su cio\' che si legge: chi non tocca mai la freccia '
              'consuma lo stesso');
      await c.approfondisci();
      expect(contatore.approfondimentiRimasti(Tier.tier1), prima - 1,
          reason: 'leggere il secondo strato non consuma niente');
    });

    test('Finiti i tre, non si legge piu\', e non si consuma', () async {
      final contatore = QuestionAllowance();
      for (var i = 0; i < 3; i++) {
        contatore.registraApprofondimento(Tier.tier1);
      }
      final c = await con(Tier.tier1, contatore: contatore);
      await c.send('devo cambiare lavoro');
      expect(c.ilPianoComprendeIlSecondoStrato, isTrue,
          reason: 'l\'Iniziato ce l\'ha nel piano: cio\' che manca e\' il '
              'numero di oggi, ed e\' un messaggio diverso');
      expect(c.puoiLeggereIlSecondoStrato, isFalse);
      await c.approfondisci();
      expect(c.messages.last.approfondita, isFalse);
    });

    test('L\'approfondimento NON consuma una domanda del giorno', () async {
      final contatore = QuestionAllowance();
      final c = await con(Tier.tier1, contatore: contatore);
      await c.send('devo cambiare lavoro');
      final domande = contatore.remaining(Tier.tier1);
      await c.approfondisci();
      expect(contatore.remaining(Tier.tier1), domande,
          reason: 'se consumasse una domanda la persona esiterebbe, e '
              'l\'esitazione uccide l\'intimita\'');
    });
  });

  test('UN SOLO meccanismo di gating, e non due', () {
    // ENUMERA `lib`: chi decide chi puo' leggere il secondo strato deve
    // passare da `PlanCatalog`, che e' il posto dove passano anche la memoria
    // dei Maestri e la profondita' dell'oroscopo. Due sistemi che decidono
    // chi puo' cosa divergono sempre.
    final colpe = <String>[];
    for (final voce in Directory('lib').listSync(recursive: true)) {
      if (voce is! File || !voce.path.endsWith('.dart')) continue;
      final percorso = voce.path.replaceAll(Platform.pathSeparator, '/');
      // Il listino E' il meccanismo: li' dentro i livelli si nominano per
      // forza.
      if (percorso == 'lib/core/entitlement/plan_catalog.dart') continue;
      final righe = voce.readAsLinesSync();
      for (var i = 0; i < righe.length; i++) {
        final r = righe[i];
        if (r.trimLeft().startsWith('//') || r.trimLeft().startsWith('///')) {
          continue;
        }
        // Il segno di un secondo meccanismo: decidere l'approfondimento
        // guardando un livello a mano, invece di chiederlo al listino.
        final parlaDiApprofondire =
            r.contains('pprofondi') || r.contains('SecondoStrato');
        final decideDaSolo = r.contains('Tier.free') ||
            r.contains('Tier.tier1') ||
            r.contains('Tier.tier2') ||
            r.contains('Tier.tier3');
        if (parlaDiApprofondire && decideDaSolo) {
          colpe.add('$percorso riga ${i + 1}: ${r.trim()}');
        }
      }
    }
    expect(colpe, isEmpty,
        reason: 'qualcuno decide chi approfondisce guardando il livello a '
            'mano, invece di chiederlo a PlanCatalog:\n${colpe.join("\n")}');
  });
}

/// Una voce che consegna una lettura lunga, cioe' con un secondo strato dentro.
class _VoceLunga implements MaestroAiProvider {
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
      rispostaGiaData != null
          ? 'Sotto la superficie lavora un movimento più lento, che dura da '
              'mesi senza chiedere il tuo permesso.'
          : 'Il tuo Sole in Cancro chiede riparo prima di chiedere strada. '
      'Quello che senti come confusione è un confine che si sposta. '
      'Sotto la superficie lavora un secondo movimento, più lento, che dura '
      'da mesi senza chiedere il tuo permesso. Non è la scelta a spaventarti, '
      'è quello che la scelta rende definitivo. Aspetta la prossima luna '
      'nuova e rileggi queste stesse parole.';

  @override
  Future<MaestroReply> consult({
    required Maestro maestro,
    required String theme,
    required UserProfile profile,
    MaestroMemory memory = MaestroMemory.empty,
    NatalContext? natal,
    ConsultDepth depth = ConsultDepth.breve,
  }) async =>
      const MaestroReply(glance: 'g', reading: 'r', invite: 'i');

  @override
  Future<String> synthesize({
    required String theme,
    required List<MaestroLens> lenses,
    NatalContext? natal,
  }) async =>
      's';

  @override
  Future<MemoryDigest?> distill({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory previous,
    required List<ChatMessage> history,
  }) async =>
      null;
}
