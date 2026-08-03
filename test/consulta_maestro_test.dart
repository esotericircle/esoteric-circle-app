import 'dart:io';

import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/consult_depth.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_welcome.dart';
import 'package:esoteric_circle/core/maestro/misura_della_risposta.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/services/ai/firebase_maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_persona.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test deterministici della funzione Consulta un Maestro: modello e tetto di
/// token per profondita', persona coi dati natali, benvenuto variato. Nessuna
/// rete, nessun asset: solo funzioni pure.
void main() {
  group('Modello, token e ragionamento per profondita\'', () {
    test('Breve usa Flash-Lite, ragionamento spento, misura contenuta', () {
      expect(FirebaseMaestroAiProvider.modelForDepth(ConsultDepth.breve),
          'gemini-2.5-flash-lite');
      final breve = MisuraDellaRisposta.perProfondita(ConsultDepth.breve);
      expect(breve, MisuraDellaRisposta.consultaBreve);
      expect(breve.ragionamento, 0);
      expect(breve.parole, 90);
    });

    // Le due misure sono un valore concordato, non una proporzione: prima
    // questa prova chiedeva solo che la Profonda fosse fra il doppio e il
    // quadruplo della Breve, e 260 contro 780 la soddisfaceva pur essendo il
    // doppio di quanto promesso alla persona. Una banda larga lascia passare
    // qualunque coppia sbagliata purche' sbagliata nella stessa proporzione.
    test('Le due misure sono quelle concordate, novanta e centottanta parole',
        () {
      expect(FirebaseMaestroAiProvider.modelForDepth(ConsultDepth.profonda),
          'gemini-2.5-flash');
      expect(MisuraDellaRisposta.consultaBreve.parole, 90);
      expect(MisuraDellaRisposta.consultaProfonda.parole, 180);
      // La Profonda deve restare distinguibile: se le due misure si
      // avvicinassero, il Premium non si sentirebbe piu'.
      expect(MisuraDellaRisposta.consultaProfonda.parole,
          greaterThanOrEqualTo(MisuraDellaRisposta.consultaBreve.parole * 2));
    });

    test('Nel provider esiste UNA SOLA porta alla configurazione', () {
      // Nel provider la chat aveva un `maxOutputTokens: 800` scritto a mano,
      // cioe' una seconda porta al tetto delle risposte che nessuna prova
      // guardava. Poi la prova si accontentava che i tetti fossero costanti, e
      // cosi' non ha visto il difetto vero: DUE chiamate su quattro, `reply` e
      // `distill`, non dichiaravano affatto il ragionamento, che quindi restava
      // dinamico e si mangiava il tetto prima che il modello scrivesse. Un
      // campo dimenticato non lo prende nessuna prova che guardi i campi
      // scritti: si toglie la porta, e si conta che ne resti una.
      final sorgente = File('lib/services/ai/firebase_maestro_ai_provider.dart')
          .readAsStringSync();
      expect(
        'GenerationConfig('.allMatches(sorgente).length,
        1,
        reason: 'ogni configurazione passa da configurazionePer, che scrive '
            'tetto e ragionamento INSIEME dalla stessa misura: due porte '
            'vogliono dire che una delle due può dimenticarne uno',
      );
      expect(
        RegExp(r'maxOutputTokens:\s*\d').hasMatch(sorgente),
        isFalse,
        reason: 'nessun tetto scritto a mano: il tetto si calcola dalla misura',
      );
    });

    test('eTroncata riconosce il modello che ha finito lo spazio', () {
      GenerateContentResponse con(FinishReason? motivo) =>
          GenerateContentResponse([
            Candidate(Content.model([TextPart('Un velo')]), null, null, motivo,
                null),
          ], null);

      expect(FirebaseMaestroAiProvider.eTroncata(con(FinishReason.maxTokens)),
          isTrue);
      // E NON grida al lupo su cio' che e' finito per davvero: una prova che
      // dice sempre di si' si finisce per allentarla.
      expect(FirebaseMaestroAiProvider.eTroncata(con(FinishReason.stop)),
          isFalse);
      expect(FirebaseMaestroAiProvider.eTroncata(con(null)), isFalse);
      expect(FirebaseMaestroAiProvider.eTroncata(GenerateContentResponse([], null)),
          isFalse);
    });

    test('OGNI risposta che arriva alla persona passa dal controllo', () {
      // ENUMERATA, non campionata, e per una ragione precisa: la prova del
      // rosso su questo controllo restava VERDE, perche' nessun test
      // attraversa quel ramo, cioe' costruire una risposta vera di Gemini
      // richiede un FirebaseAI che in prova non esiste. Quando il caso non
      // attraversa il ramo si enumera: qui si elencano i quattro metodi del
      // provider che restituiscono testo, e si chiede che ciascuno controlli.
      // Toglierlo da uno solo fa cadere questa riga.
      final sorgente = File('lib/services/ai/firebase_maestro_ai_provider.dart')
          .readAsStringSync();
      const metodi = ['reply', 'consult', 'synthesize', 'distill'];
      // Il corpo di ciascuno va dalla sua firma alla firma successiva, e dopo
      // l'ultimo si ferma al primo aiuto privato: senza questo confine il
      // controllo di un metodo passerebbe per merito di un altro.
      const finePrivata = 'List<Content> _toHistory';
      final confini = <int>[
        for (final m in metodi) sorgente.indexOf(' $m({'),
        sorgente.indexOf(finePrivata),
      ];
      for (final confine in confini) {
        expect(confine, greaterThan(0),
            reason: 'firma non trovata: la prova guarda il file sbagliato');
      }
      final ordinati = [...confini]..sort();
      for (final metodo in metodi) {
        final inizio = sorgente.indexOf(' $metodo({');
        final fine = ordinati.firstWhere((c) => c > inizio);
        expect(
          sorgente.substring(inizio, fine),
          contains('eTroncata(response)'),
          reason: 'il metodo $metodo consegna testo senza guardare se il '
              'modello si è fermato per mancanza di spazio: un moncone '
              'arriverebbe a video come una risposta compiuta',
        );
      }
      // E il controllo esiste in quattro punti, uno per metodo: se qualcuno
      // ne aggiunge un quinto senza dirlo, questa riga lo dice.
      expect('eTroncata(response)'.allMatches(sorgente).length, metodi.length);
    });

    test('OGNI testo che arriva alla persona passa dalla ripulitura', () {
      // ENUMERATA per la stessa ragione della troncatura: nessuna prova puo'
      // chiamare il provider vero, perche' costruirlo richiede un FirebaseAI
      // che in prova non esiste. Togliere `pulisci` da `reply` restava VERDE
      // su tutto, quindi si enumerano i punti invece di campionarli.
      //
      // Il vincolo nella persona regge quasi sempre, e "quasi" non basta per
      // una cosa che dipende da un modello: questa e' l'ultima riga prima
      // dello schermo, e il 3 agosto 2026 `**Laguz**` l'ha attraversata.
      final sorgente = File('lib/services/ai/firebase_maestro_ai_provider.dart')
          .readAsStringSync();
      // Le tre uscite che la persona LEGGE: la chat, la sintesi, e i tre
      // strati del Consulta. Il distillato no: e' un JSON di servizio che non
      // legge nessuno.
      expect('TestoDelResponso.pulisci('.allMatches(sorgente).length, 5,
          reason: 'la chat, la sintesi e i tre strati del Consulta: cinque '
              'punti, e se ne manca uno un asterisco arriva a video');
    });

    test('Ogni misura ha un tetto piu\' grande del proprio ragionamento', () {
      // LA PROVA CHE IL CONSULTA PROFONDO NON AVEVA. Il 2 agosto 2026 la
      // Profonda dichiarava un ragionamento di 512 token dentro un tetto di
      // 320: il pensiero era piu' grande di tutta l'uscita, e quel responso
      // non poteva riuscire mai. Misurato sulla strada viva:
      // `finishReason: MAX_TOKENS`, `thoughtsTokenCount: 304`,
      // `candidatesTokenCount: 2`, testo `{`.
      for (final misura in MisuraDellaRisposta.values) {
        expect(
          misura.tetto,
          greaterThan(misura.ragionamento),
          reason: '${misura.name}: il ragionamento mangia il tetto delle '
              'uscite, non ne ha uno suo',
        );
        // E non basta che ci stia: dopo aver pensato deve restare lo spazio
        // per dire cio' che ha pensato.
        expect(
          misura.tetto - misura.ragionamento,
          greaterThanOrEqualTo(
              misura.parole * MisuraDellaRisposta.kTokenPerParola),
          reason: '${misura.name}: dopo il ragionamento non resta spazio '
              'nemmeno per le parole chieste',
        );
      }
    });

    test('Il tetto e\' una rete, non una misura: sta al doppio del richiesto',
        () {
      // Il tetto tagliato al filo della misura riporta il difetto di oggi:
      // basta un elenco un po' piu' lungo e la frase resta a meta'.
      for (final misura in MisuraDellaRisposta.values) {
        expect(
          misura.tetto - misura.ragionamento,
          greaterThanOrEqualTo(misura.parole *
              MisuraDellaRisposta.kTokenPerParola *
              MisuraDellaRisposta.kFattoreDiRete),
          reason: '${misura.name}: il tetto non fa da rete',
        );
      }
      // I due numeri della chat, per esteso, perche' si possano discutere.
      expect(MisuraDellaRisposta.primaRisposta.tetto, 400);
      expect(MisuraDellaRisposta.approfondimento.tetto, 1000);
      expect(MisuraDellaRisposta.consultaBreve.tetto, 400);
      expect(MisuraDellaRisposta.consultaProfonda.tetto, 1300);
      expect(MisuraDellaRisposta.sintesi.tetto, 400);
      expect(MisuraDellaRisposta.distillato.tetto, 500);
    });

    test('La configurazione vera porta il tetto e il ragionamento della misura',
        () {
      // Non si guarda il sorgente, si costruisce l'oggetto che parte davvero e
      // gli si leggono i due campi.
      for (final misura in MisuraDellaRisposta.values) {
        final config = FirebaseMaestroAiProvider.configurazionePer(
          misura,
          temperature: 0.9,
        );
        expect(config.maxOutputTokens, misura.tetto);
        expect(config.thinkingConfig?.thinkingBudget, misura.ragionamento,
            reason: '${misura.name}: il ragionamento non e\' dichiarato, '
                'quindi resta dinamico e si mangia il tetto');
      }
    });

    test('La misura chiesta arriva al Maestro, in lettere', () {
      // Il tetto da solo non basta: un tetto che taglia produce un moncone. La
      // lunghezza si governa CHIEDENDOLA, e il tetto resta la rete.
      final prima = MaestroPersona.systemInstruction(
        maestro: Maestro.medora,
        profile: UserProfile.empty,
        memory: MaestroMemory.empty,
      );
      // Sessanta chieste per settanta ottenute: chiedendone novanta la mediana
      // misurata su venti risposte vere era 94, cioe' il modello sfora, e sfora
      // sempre verso l'alto.
      expect(prima, contains('circa cinquanta parole'));
      expect(prima, contains('Non lasciare mai una frase a metà'));

      final piuGiu = MaestroPersona.systemInstruction(
        maestro: Maestro.medora,
        profile: UserProfile.empty,
        memory: MaestroMemory.empty,
        approfondisci: true,
      );
      expect(piuGiu, contains('circa duecentoquaranta parole'));

      // La cifra non compare mai: un Maestro dice "novanta", non "90".
      for (final misura in MisuraDellaRisposta.values) {
        expect(misura.istruzione, isNot(contains('${misura.parole}')),
            reason: '${misura.name}: la misura si dice in lettere');
      }
    });

    test('Nessuna seconda lunghezza chiesta altrove nella persona', () {
      // Diceva "Poche righe per risposta" nelle regole comuni, e quella riga
      // arrivava al modello INSIEME alla misura vera: nell'approfondimento gli
      // si chiedevano duecentoquaranta parole e poche righe, cioe' due cose
      // diverse nella stessa istruzione. La lunghezza vive in un punto solo.
      final istr = MaestroPersona.systemInstruction(
        maestro: Maestro.caligo,
        profile: UserProfile.empty,
        memory: MaestroMemory.empty,
        approfondisci: true,
      );
      expect(istr, isNot(contains('Poche righe per risposta')));
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
        profile: UserProfile(displayName: 'Sofia'),
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
        profile: UserProfile(
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
    final profileF =
        UserProfile(displayName: 'Sofia', courtesyForm: CourtesyForm.feminine);
    final profileM =
        UserProfile(displayName: 'Marco', courtesyForm: CourtesyForm.masculine);

    test('Il vocativo segue la forma di cortesia, o e\' neutro senza nome', () {
      expect(MaestroWelcome.vocative(profileF), 'Cara Sofia');
      expect(MaestroWelcome.vocative(profileM), 'Caro Marco');
      expect(
          MaestroWelcome.vocative(
              UserProfile(displayName: 'X', courtesyForm: CourtesyForm.neutral)),
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
