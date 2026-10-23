import 'package:esoteric_circle/core/cammino/cammino_da_custodire.dart';
import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/chat/widgets/chat_bubble.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **IL MESSAGGIO DEL LIMITE HA UNA USCITA. Ordine GB voce 06, 22 ottobre
/// 2026.** Il rapporto dell'ordine GA, punto 6: *"il messaggio non ha
/// pulsante ne' il prezzo (80 Eos) ne' un invito ai piani, e ogni Maestro
/// dice una frase diversa"*. La frase resta diversa per Maestro
/// ([FraseDelLimite], non toccata da questa voce); questa prova pretende
/// che sotto quella frase compaia, per ogni Maestro, lo stesso pulsante col
/// prezzo vero letto dal server e l'invito ai piani.
class _PortaDelListino extends PortaDelCerchio {
  @override
  bool get viva => true;

  @override
  Future<StatoDelCerchio?> stato(
          {CamminoDaCustodire? cammino, bool azzeraIlCammino = false}) async =>
      const StatoDelCerchio(
          giorno: '2026-10-22',
          piano: 'free',
          spesi: {},
          saldoEos: 300,
          listinoDelRiscatto: {'domande': 80});

  @override
  Future<EsitoDelConsumo?> consuma(
          {required String budget, required String idMovimento}) async =>
      null;

  @override
  Future<int?> muoviGliEos({
    required String causale,
    required String motivo,
    required String idMovimento,
    int? quanti,
  }) async =>
      300;

  @override
  Future<bool> scriviLaMemoria({
    required String operazione,
    String? maestro,
    Map<String, Object?> campi = const {},
  }) async =>
      false;

  @override
  Future<bool> cancellaIlCerchio() async => false;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<QuestionAllowance> borsaConPrezzo() async {
    final borsa = QuestionAllowance(porta: _PortaDelListino());
    await borsa.sincronizza();
    return borsa;
  }

  Widget host(Widget child, Maestro maestro, QuestionAllowance borsa) =>
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (_) => MaestroController()..selectMaestro(maestro)),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ProfileController()),
          ChangeNotifierProvider(create: (_) => BirthIdentityController()),
          ChangeNotifierProvider(create: (_) => EntitlementService()),
          ChangeNotifierProvider<QuestionAllowance>.value(value: borsa),
        ],
        child: MaterialApp(
          home: MaestroScope(child: Scaffold(body: child)),
        ),
      );

  for (final maestro in Maestro.values) {
    testWidgets(
        'sotto il messaggio del limite di ${maestro.name} c\'e\' il '
        'pulsante con il prezzo vero', (tester) async {
      final borsa = await borsaConPrezzo();
      const message = ChatMessage(
        role: ChatRole.maestro,
        text: 'Per oggi ci siamo detti abbastanza.',
        tipo: TipoDiMessaggio.limiteRaggiunto,
      );
      await tester.pumpWidget(host(
        ChatBubble(message: message, maestro: maestro),
        maestro,
        borsa,
      ));
      await tester.pump();

      final pulsante = find.byKey(const Key('limite_raggiunto_uscita'));
      expect(pulsante, findsOneWidget,
          reason: 'il messaggio del limite di ${maestro.name} non ha '
              'nessuna uscita');
      expect(find.textContaining('80 Eos'), findsOneWidget,
          reason: 'il prezzo non e\' quello letto dal server');

      await tester.tap(pulsante);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('upgrade_invite')), findsOneWidget,
          reason: 'il tocco non apre l\'invito ai piani');
      expect(find.byKey(const Key('upgrade_see_plans')), findsOneWidget);
      expect(find.byKey(const Key('invito_riscatto')), findsOneWidget);
    });
  }
}
