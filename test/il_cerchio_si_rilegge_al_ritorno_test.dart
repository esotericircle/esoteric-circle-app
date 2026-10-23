import 'package:esoteric_circle/core/cerchio/il_cerchio_sociale.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/design_system/components/cosmos_background.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/cerchio/il_tuo_cerchio_screen.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'porta_finta_del_cerchio_sociale.dart';

/// Un server finto in cui il legame nasce a meta' prova: prima il Cerchio
/// e' vuoto, poi l'amico c'e'.
class _IlLegameNasceDopo extends PortaFintaDelCerchioSociale {
  bool legame = false;

  @override
  Future<EsitoSociale?> sociale(String porta,
      [Map<String, Object?> corpo = const {}]) async {
    if (porta == 'ilMioCerchio' && !legame) {
      chieste.add((porta, corpo));
      return const EsitoSociale(dati: {
        'amici': <Object?>[],
        'ricevuti': <Object?>[],
        'inviati': <Object?>[],
      });
    }
    return super.sociale(porta, corpo);
  }
}

/// **IL CERCHIO SI RILEGGE AL RITORNO, ordine FD voce 05.** Nel collaudo
/// sul Realme del 5 ottobre 2026 il legame col secondo account e' nato
/// mentre "Il tuo Cerchio" stava aperto sotto un'altra rotta, e al ritorno
/// l'elenco diceva ancora che il Cerchio era vuoto, con l'amico presente
/// nella tendina sopra (cattura `docs/collaudo/FD/realme/01_*`). Difetto
/// dell'ordine EY, commit af6a327d: il Cerchio si leggeva una volta sola.
void main() {
  Future<_IlLegameNasceDopo> monta(WidgetTester tester) async {
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2391);
    addTearDown(tester.view.reset);
    final finta = _IlLegameNasceDopo();
    final sociale = IlCerchioSociale(porta: finta);
    await sociale.sincronizza(
        identita: BirthIdentity(birthMoment: DateTime(1990, 5, 12, 10)));
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<IlCerchioSociale>.value(value: sociale),
        Provider<AppServices>.value(value: AppServices.offline(null, finta)),
      ],
      child: MaterialApp(
        theme: AppTheme.dark(),
        navigatorObservers: [osservatoreDelCielo],
        builder: (c, figlio) => MediaQuery(
          data: MediaQuery.of(c).copyWith(disableAnimations: true),
          child: MaestroScope(neutro: true, child: figlio!),
        ),
        home: const IlTuoCerchioScreen(),
      ),
    ));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    return finta;
  }

  final vuoto = find.textContaining('Il tuo Cerchio è ancora vuoto');
  final amico = find.text('Stella Lieve');

  testWidgets('chiusa la rotta sopra, il legame nato nel frattempo si vede',
      (tester) async {
    final finta = await monta(tester);
    expect(vuoto, findsOneWidget);
    expect(amico, findsNothing);

    final nav = tester.state<NavigatorState>(find.byType(Navigator));
    nav.push(MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('sopra'))));
    await tester.pumpAndSettle();
    finta.legame = true;
    nav.pop();
    await tester.pumpAndSettle();

    expect(vuoto, findsNothing);
    expect(amico, findsOneWidget);
  });

  testWidgets('tornata in primo piano, l\'app rilegge il Cerchio',
      (tester) async {
    final finta = await monta(tester);
    expect(vuoto, findsOneWidget);
    finta.legame = true;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(vuoto, findsNothing);
    expect(amico, findsOneWidget);
  });
}
