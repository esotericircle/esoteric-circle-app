import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/synastry/avvio_sinastria_evolutiva.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'la_tendina_della_sinastria_aiuto.dart';

/// **IL PONTE CONTA LE COPPIE NUOVE.** Ordine FT voce FT.13, 14 ottobre
/// 2026. Il Viandante che ha gia' letto la sua coppia nuova del giorno, col
/// server che conosce il budget, non entra in una seconda lettura: trova
/// l'invito con le due strade (Eos o piano), mai un vicolo cieco.
class _Porta extends PortaDelCerchio {
  @override
  bool get viva => true;

  @override
  Future<StatoDelCerchio?> stato(
          {Object? cammino, bool azzeraIlCammino = false}) async =>
      StatoDelCerchio.daMappa({
        'giorno': '2026-10-14',
        'spesi': const {'domande': 0},
        'saldoEos': 1000,
        'listinoDelRiscatto': {
          'domande': 80,
          'stese': 150,
          'sinastrie': 150,
          'sinastrieEvolutive': 150,
        },
      });

  @override
  Future<int?> muoviGliEos({
    required String causale,
    required String motivo,
    required String idMovimento,
    int? quanti,
  }) async =>
      850;

  @override
  Future<EsitoDelConsumo?> consuma(
          {required String budget, required String idMovimento}) async =>
      null;

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
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets(
      'finite le coppie nuove del giorno, il ponte apre l\'invito e non la '
      'lettura', (tester) async {
    final borsa = QuestionAllowance(porta: _Porta());
    await tester.runAsync(borsa.sincronizza);
    borsa.registraSinastriaEvolutiva(Tier.free);
    expect(borsa.puoiLeggereUnaCoppiaNuova(Tier.free), isFalse);
    // Un telefono, come le altre prove della Sinastria (FY.11).
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider.value(value: borsa),
        ChangeNotifierProvider(
            create: (_) => EntitlementService(initial: Tier.free)),
      ],
      child: MaterialApp(
        builder: (context, child) => MaestroScope(child: child!),
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => Navigator.of(context)
                .push(AvvioSinastriaEvolutiva.route(nomeSuggerito: 'Giulia')),
            child: const Text('apri'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('apri'));
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }

    // **LA NASCITA SI CHIEDE DALLA SCENA, NON PIU' DAL NERO DEL PONTE.**
    // Ordine FY voce FY.11, 16 ottobre 2026: il ponte apriva la nascita
    // dell'altra persona da solo, su uno schermo nero; adesso apre la scena,
    // e la nascita si chiede dalla scelta sotto lo studio. Il conto delle
    // coppie nuove e' lo stesso, ed e' cio' che questa prova misura.
    // **E DALL'ORDINE GD DALLA TENDINA CHE SALE** (GD.14): LAPIDE, qui la
    // prova compilava "La sua nascita" (`nascita_altra_*`).
    await compilaLaTendina(tester);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('upgrade_invite')), findsOneWidget,
        reason: 'le coppie nuove sono finite e il ponte non dice niente');
    expect(find.text('Le coppie nuove di oggi sono finite'), findsOneWidget);
    expect(find.textContaining('150 Eos'), findsWidgets,
        reason: 'il prezzo del riscatto si dice prima del gesto');
  });
}
