import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/raccolta_delle_risposte.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/consult_depth.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_reply.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/components/collasso.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_screen.dart';
import 'package:esoteric_circle/features/maestri/chat/widgets/chat_composer.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// LE RISPOSTE SI RACCOLGONO QUANDO NE ARRIVA UNA NUOVA.
///
/// **L'idea e' del fondatore, con una correzione sul momento.** Una risposta
/// che si chiude appena l'hai letta ti toglie di mano quello che ti e' appena
/// stato dato, e nessuno sa dire quando l'hai letta. Quando ne arriva un'altra,
/// invece, non c'e' niente da indovinare.
void main() {
  ChatMessage domanda(String testo) =>
      ChatMessage(role: ChatRole.user, text: testo);

  ChatMessage risposta(String testo, {Maestro? autore}) =>
      ChatMessage(role: ChatRole.maestro, text: testo, autore: autore);

  group('La regola, senza montare uno schermo', () {
    test('Con una sola risposta non si raccoglie niente', () {
      final messaggi = [domanda('la prima'), risposta('La tua Luna in Pesci.')];
      expect(RaccoltaDelleRisposte.indiceDellaViva(messaggi), 1);
      expect(RaccoltaDelleRisposte.siPuoRaccogliere(messaggi, 1), isFalse,
          reason: 'e\' quella che la persona sta leggendo adesso');
    });

    test('Dopo la seconda domanda, la prima si raccoglie', () {
      final messaggi = [
        domanda('la prima'),
        risposta('La tua Luna in Pesci.'),
        domanda('la seconda'),
        risposta('Il tuo Sole in Cancro.'),
      ];
      expect(RaccoltaDelleRisposte.indiceDellaViva(messaggi), 3);
      expect(RaccoltaDelleRisposte.siPuoRaccogliere(messaggi, 1), isTrue);
      expect(RaccoltaDelleRisposte.eAperta(messaggi, 1, riaperte: const {}),
          isFalse);
      // E l'ULTIMA resta sempre aperta.
      expect(RaccoltaDelleRisposte.siPuoRaccogliere(messaggi, 3), isFalse);
      expect(RaccoltaDelleRisposte.eAperta(messaggi, 3, riaperte: const {}),
          isTrue);
    });

    test('Una raccolta si riapre, e resta aperta', () {
      final messaggi = [
        domanda('la prima'),
        risposta('La tua Luna in Pesci.'),
        domanda('la seconda'),
        risposta('Il tuo Sole in Cancro.'),
      ];
      expect(RaccoltaDelleRisposte.eAperta(messaggi, 1, riaperte: const {1}),
          isTrue);
    });

    test('Un ripiego NON e\' la risposta viva', () {
      // Se lo fosse, l'arrivo di un ripiego richiuderebbe la lettura vera che
      // sta appena sopra, cioe' toglierebbe di mano proprio quello che vale.
      final messaggi = [
        domanda('la prima'),
        risposta('La tua Luna in Pesci.'),
        domanda('la seconda'),
        const ChatMessage(
            role: ChatRole.maestro,
            text: 'Il cielo si è coperto.',
            ripiego: true),
      ];
      expect(RaccoltaDelleRisposte.indiceDellaViva(messaggi), 1);
      expect(RaccoltaDelleRisposte.siPuoRaccogliere(messaggi, 1), isFalse);
    });

    test('Le altre voci arrivate dopo raccolgono la prima', () {
      // Le bolle degli altri Maestri sono risposte a tutti gli effetti: la
      // viva e' l'ultima arrivata, chiunque l'abbia detta.
      final messaggi = [
        domanda('mi sento fermo'),
        risposta('La tua Luna in Pesci.'),
        risposta('Il respiro alla radice.', autore: Maestro.aura),
        risposta('La runa Laguz.', autore: Maestro.caligo),
      ];
      expect(RaccoltaDelleRisposte.indiceDellaViva(messaggi), 3);
      expect(RaccoltaDelleRisposte.siPuoRaccogliere(messaggi, 1), isTrue);
      expect(RaccoltaDelleRisposte.siPuoRaccogliere(messaggi, 2), isTrue);
      expect(RaccoltaDelleRisposte.siPuoRaccogliere(messaggi, 3), isFalse);
    });
  });

  group('A 360 per 797, sullo schermo vero', () {
    testWidgets('Dopo la seconda domanda la prima e\' chiusa e riapribile',
        (tester) async {
      tester.view.devicePixelRatio = 3.0;
      tester.view.physicalSize = const Size(1080, 2392);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const prima = 'La tua Luna in Pesci chiude un ciclo lungo, e il ciclo '
          'torna fra sette giorni con una domanda diversa.';
      const seconda = 'Il tuo Ascendente in Vergine chiede ordine a ciò che '
          'la Luna muove senza chiedere permesso.';

      final memoria = InMemoryMaestroMemoryRepository();
      await memoria
          .saveProfile(UserProfile(disclaimerAcceptedAt: DateTime(2026, 7, 1)));
      final voce = _VoceADueTurni([prima, seconda]);
      final servizi = AppServices(
        ai: voce,
        memory: memoria,
        memoryPersistent: false,
        diagnostics: 'prova del raccoglimento',
      );

      await tester.pumpWidget(MultiProvider(
        providers: [
          Provider<AppServices>.value(value: servizi),
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => QuestionAllowance()),
          ChangeNotifierProvider(create: (_) => EntitlementService()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => ProfileController()),
          ChangeNotifierProvider(create: (_) => BirthIdentityController()),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Navigator(
            onGenerateRoute: (_) => MaestroChatScreen.route(
              maestro: Maestro.medora,
              services: servizi,
            ),
          ),
        ),
      ));

      Future<void> chiedi(String testo) async {
        final campo = find.descendant(
          of: find.byType(ChatComposer),
          matching: find.byType(TextField),
        );
        await tester.enterText(campo, testo);
        await tester.pump();
        await tester.testTextInput.receiveAction(TextInputAction.send);
        for (var i = 0; i < 80; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
      }

      await chiedi('mi sento fermo');
      expect(find.text(prima), findsOneWidget,
          reason: 'la prima risposta e\' quella viva, quindi si legge tutta');
      expect(find.byKey(const Key('chat_raccogli')), findsNothing,
          reason: 'con una sola risposta non c\'e\' niente da raccogliere');

      await chiedi('e adesso');

      // 1. LA PRIMA E' CHIUSA: il suo testo sta su UNA riga sola.
      //
      //    Non si cerca la sua assenza dall'albero: la riga raccolta porta il
      //    testo intero e lo tronca con l'ellissi, che e' il modo giusto di
      //    fare un'anteprima, e cercarlo lo troverebbe comunque. Cio' che
      //    cambia, e che la persona vede, e' quante righe se ne leggono.
      int righeDi(String testo) => tester
          .widgetList<Text>(find.text(testo))
          .map((t) => t.maxLines ?? 0)
          .first;
      expect(righeDi(prima), 1,
          reason: 'la prima risposta doveva raccogliersi all\'arrivo della '
              'seconda');
      // 2. L'ULTIMA E' APERTA, sempre.
      expect(find.text(seconda), findsOneWidget);
      // 3. E SI RIAPRE AL TOCCO.
      final freccette = find.byKey(const Key('chat_raccogli'));
      expect(freccette, findsOneWidget,
          reason: 'la freccetta sta sulla risposta raccolta, e su nessun\'altra');
      await tester.tap(freccette);
      for (var i = 0; i < 8; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(righeDi(prima), 0,
          reason: 'riaperta col tocco, la risposta torna leggibile per intero: '
              'nessun limite di righe');
      expect(find.text(seconda), findsOneWidget,
          reason: 'riaprire una vecchia non chiude quella viva');
    });

    testWidgets('La freccetta ruota di mezzo giro', (tester) async {
      // Il numero sta nel dato condiviso col dominio, non scritto due volte.
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              FreccettaDelCollasso(aperto: false, color: Colors.white),
              FreccettaDelCollasso(aperto: true, color: Colors.white),
            ],
          ),
        ),
      ));
      await tester.pumpAndSettle();
      final giri = tester
          .widgetList<AnimatedRotation>(find.byType(AnimatedRotation))
          .map((r) => r.turns)
          .toList();
      expect(giri, [0.0, FreccettaDelCollasso.giroDellaFreccetta]);
      expect(FreccettaDelCollasso.giroDellaFreccetta, 0.5);
    });

    testWidgets('Con Riduci Movimento non si anima, ma si apre lo stesso',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (ctx) => MediaQuery(
            data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
            child: const Scaffold(
              body: Column(
                children: [
                  FreccettaDelCollasso(aperto: true, color: Colors.white),
                  Collassabile(aperto: true, child: Text('il contenuto')),
                ],
              ),
            ),
          ),
        ),
      ));
      await tester.pump();
      // Nessuna misura da interpolare: il contenuto c'e' e basta.
      expect(find.byType(AnimatedSize), findsNothing,
          reason: 'a movimento spento non si mette nemmeno in mezzo il '
              'riquadro animato');
      expect(find.text('il contenuto'), findsOneWidget,
          reason: 'si toglie il moto, mai l\'informazione');
      final rotazione =
          tester.widget<AnimatedRotation>(find.byType(AnimatedRotation));
      expect(rotazione.duration, Duration.zero);
    });
  });
}

/// Una voce che risponde due cose diverse ai due turni.
class _VoceADueTurni implements MaestroAiProvider {
  _VoceADueTurni(this._risposte);

  final List<String> _risposte;
  int _turno = 0;

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
    bool aDueStrati = true,
  }) async {
    final testo = _risposte[_turno.clamp(0, _risposte.length - 1)];
    _turno++;
    return testo;
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
    required MaestroMemory previous,
    required List<ChatMessage> history,
  }) async =>
      null;
}
