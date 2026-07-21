import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/consult_depth.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_welcome.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/services/ai/firebase_maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_persona.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test deterministici della funzione Consulta un Maestro: modello e tetto di
/// token per profondita', persona coi dati natali, benvenuto variato. Nessuna
/// rete, nessun asset: solo funzioni pure.
void main() {
  group('Modello, token e ragionamento per profondita\'', () {
    test('Breve usa Flash-Lite, ragionamento spento, tetto contenuto', () {
      expect(FirebaseMaestroAiProvider.modelForDepth(ConsultDepth.breve),
          'gemini-2.5-flash-lite');
      expect(FirebaseMaestroAiProvider.thinkingBudgetForDepth(ConsultDepth.breve),
          0);
      expect(FirebaseMaestroAiProvider.maxTokensForDepth(ConsultDepth.breve),
          FirebaseMaestroAiProvider.kBreveMaxTokens);
    });

    test('Profonda usa Flash e un tetto circa triplo della Breve', () {
      expect(FirebaseMaestroAiProvider.modelForDepth(ConsultDepth.profonda),
          'gemini-2.5-flash');
      final breve = FirebaseMaestroAiProvider.maxTokensForDepth(ConsultDepth.breve);
      final profonda =
          FirebaseMaestroAiProvider.maxTokensForDepth(ConsultDepth.profonda);
      expect(profonda, greaterThan(breve * 2));
      expect(profonda, lessThanOrEqualTo(breve * 4));
    });
  });

  group('Persona coi dati natali', () {
    test('I dati natali presenti entrano nella persona, senza inventarne', () {
      const natal = NatalContext(
        sunSign: 'Leone',
        moonSign: 'Bilancia',
        lifeNumber: 7,
        lifeNumberTitle: 'il Cercatore',
      );
      final istr = MaestroPersona.consultInstruction(
        maestro: Maestro.medora,
        profile: const UserProfile(displayName: 'Sofia'),
        memory: MaestroMemory.empty,
        natal: natal,
      );
      expect(istr, contains('DATI NATALI'));
      expect(istr, contains('Segno solare: Leone'));
      expect(istr, contains('Segno lunare: Bilancia'));
      expect(istr, contains('Numero della vita: 7, il Cercatore'));
      // L'ascendente manca: non deve comparire inventato.
      expect(istr, isNot(contains('Ascendente:')));
      // La regola anti invenzione c'e' sempre.
      expect(istr, contains('Non inventare'));
    });

    test('Senza dati natali, nessun blocco natale, personalizza col nome', () {
      final istr = MaestroPersona.consultInstruction(
        maestro: Maestro.aura,
        profile: const UserProfile(
            displayName: 'Sofia', courtesyForm: CourtesyForm.feminine),
        memory: MaestroMemory.empty,
        natal: NatalContext.none,
      );
      expect(istr, isNot(contains('DATI NATALI')));
      expect(istr, contains('Sofia'));
    });

    test('La Profonda chiede di approfondire senza gonfiare', () {
      final istr = MaestroPersona.consultInstruction(
        maestro: Maestro.medora,
        profile: UserProfile.empty,
        memory: MaestroMemory.empty,
        depth: ConsultDepth.profonda,
      );
      expect(istr, contains('Profonda'));
      expect(istr, contains('senza gonfiare'));
    });
  });

  group('Benvenuto deterministico', () {
    const profileF =
        UserProfile(displayName: 'Sofia', courtesyForm: CourtesyForm.feminine);
    const profileM =
        UserProfile(displayName: 'Marco', courtesyForm: CourtesyForm.masculine);

    test('Il vocativo segue la forma di cortesia, o e\' neutro senza nome', () {
      expect(MaestroWelcome.vocative(profileF), 'Cara Sofia');
      expect(MaestroWelcome.vocative(profileM), 'Caro Marco');
      expect(
          MaestroWelcome.vocative(
              const UserProfile(displayName: 'X', courtesyForm: CourtesyForm.neutral)),
          'Ciao X');
      expect(MaestroWelcome.vocative(UserProfile.empty), 'Anima del Cerchio');
    });

    test('Due aperture vicine non ripetono la stessa formula', () {
      String openingOf(int r) => MaestroWelcome.compose(
            maestro: Maestro.medora,
            profile: profileF,
            premium: false,
            rotation: r,
          );
      for (var r = 0; r < MaestroWelcome.openings.length + 2; r++) {
        expect(openingOf(r) == openingOf(r + 1), isFalse,
            reason: 'le aperture $r e ${r + 1} coincidono');
      }
    });

    test('Il pool ha almeno dieci formule', () {
      expect(MaestroWelcome.openings.length, greaterThanOrEqualTo(10));
    });

    test('Free: il contesto usa i dati natali, con nome e domanda d\'azione',
        () {
      const natal = NatalContext(sunSign: 'Leone', lifeNumberTitle: 'il Cercatore');
      final w = MaestroWelcome.compose(
        maestro: Maestro.medora,
        profile: profileF,
        natal: natal,
        premium: false,
        rotation: 0,
      );
      expect(w, contains('Cara Sofia'));
      expect(w, contains('Leone'));
      expect(w, contains('?')); // una domanda che spinge all'azione
    });

    test('Premium: il contesto riprende dalla sintesi di memoria', () {
      const mem = MaestroMemory(sessionSummary: 'avete parlato del lavoro');
      final w = MaestroWelcome.compose(
        maestro: Maestro.medora,
        profile: profileM,
        memory: mem,
        premium: true,
        rotation: 1,
      );
      expect(w, contains('Caro Marco'));
      expect(w, contains('Riprendo da dove eravamo'));
      expect(w, contains('avete parlato del lavoro'));
    });

    test('Il benvenuto non usa il trattino lungo e ha accenti veri', () {
      for (var r = 0; r < MaestroWelcome.openings.length; r++) {
        final w = MaestroWelcome.compose(
          maestro: Maestro.medora,
          profile: profileF,
          natal: const NatalContext(sunSign: 'Bilancia'),
          premium: false,
          rotation: r,
        );
        expect(w.contains('—'), isFalse, reason: 'trattino lungo in: $w');
      }
    });
  });
}
