import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/components/cosmos_background.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// IL CIELO NON SI FERMA PIU'. Ordine AO voce 07.
///
/// **Il difetto, dal collaudo della 2182**: il cielo di sfondo si blocca
/// tornando dal background e dopo alcune funzionalita'. Mauro chiede una
/// soluzione DEFINITIVA, senza rinunciare a profondita' e parallasse.
///
/// **La causa strutturale, riverificata sulla testa prima di correggere**: la
/// sospensione era un INTERRUTTORE, il bool `_coperto`, mosso da due eventi
/// OPPOSTI del RouteObserver, `didPushNext` e `didPopNext`. Un interruttore
/// perde lo stato se uno dei due eventi non arriva, e non arriva tornando dal
/// background o in certe uscite di rotta. E c'era un secondo anello debole:
/// il giro si riarmava solo dentro il `build`, quindi bastava che non
/// arrivasse una ricostruzione perche' il cielo restasse fermo con lo stato
/// che diceva di girare.
///
/// **La cura**: la sospensione smette di essere un interruttore e diventa uno
/// STATO CALCOLATO. Il cielo gira se, e solo se, la sua rotta e' in cima E
/// l'app e' in primo piano; lo stato si rivaluta a ogni cambio di rotta, a
/// ogni cambio di ciclo di vita e a ogni ricostruzione. In piu' una
/// SENTINELLA: se il cielo risulta fermo mentre lo stato dice che dovrebbe
/// girare, riparte, e il fatto si registra.
///
/// **Cosa NON cambia, ed e' il vincolo della voce**: piani, scorte, densita'
/// degli elementi, corse della parallasse e rapporti fra i piani restano
/// quelli dell'ordine AM voce 02. Se una cura li muove, la cura e' sbagliata.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget attorno(Widget scena) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
        ],
        child: MaterialApp(
          navigatorObservers: [osservatoreDelCielo],
          builder: (ctx, child) => MaestroScope(child: child!),
          home: scena,
        ),
      );

  /// **COME SI GUARDA SE IL CIELO GIRA, e non e' una parola.** Si prende il
  /// suo AnimationController dallo stato del widget e si chiede se sta
  /// animando: e' la stessa cosa che decide se i fotogrammi cambiano.
  bool giraDavvero(WidgetTester tester) {
    // **SI CERCA ANCHE FUORI SCENA, e questa riga e' una scoperta.** Una
    // rotta coperta da una rotta opaca finisce OFFSTAGE, e senza questo il
    // finder non trovava piu' niente proprio nel caso da misurare.
    final stato = tester.state(
        find.byType(CosmosBackground, skipOffstage: false));
    // ignore: invalid_use_of_protected_member
    final ticker = (stato as dynamic).girDavvero as bool;
    return ticker;
  }

  Future<void> respiro(WidgetTester tester, [int giri = 6]) async {
    for (var i = 0; i < giri; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  testWidgets('CASO 1: si va in background e si torna, e il cielo riparte',
      (tester) async {
    await tester.pumpWidget(attorno(
      const Scaffold(body: CosmosBackground(child: SizedBox.expand())),
    ));
    await respiro(tester);
    expect(giraDavvero(tester), isTrue,
        reason: 'il cielo non gira nemmeno all\'inizio: la prova non ha '
            'niente da misurare');

    // L'app se ne va: il sistema manda `paused`, e il cielo si ferma perche'
    // dipingere un fondale che nessuno vede e' batteria buttata.
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await respiro(tester);
    // ignore: avoid_print
    print('ORDINE AO VOCE 07: in background gira ${giraDavvero(tester)}');
    expect(giraDavvero(tester), isFalse,
        reason: 'in background il cielo continua a girare: e\' batteria '
            'spesa per fotogrammi che non vede nessuno');

    // E si torna.
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await respiro(tester);
    // ignore: avoid_print
    print('ORDINE AO VOCE 07: tornati in primo piano gira '
        '${giraDavvero(tester)}');
    expect(giraDavvero(tester), isTrue,
        reason: 'tornando dal background il cielo resta fermo: e\' il difetto '
            'che Mauro ha visto sulla 2182');
  });

  testWidgets('CASO 2: si apre una funzionalita\' e si torna', (tester) async {
    late BuildContext dentro;
    await tester.pumpWidget(attorno(
      Scaffold(body: Builder(builder: (ctx) {
        dentro = ctx;
        return const CosmosBackground(child: SizedBox.expand());
      })),
    ));
    await respiro(tester);
    expect(giraDavvero(tester), isTrue);

    // Una rotta OPACA sopra: il cielo si sospende, che e' giusto.
    unawaited(Navigator.of(dentro).push(MaterialPageRoute<void>(
      builder: (_) => const Scaffold(body: Text('una funzionalita')),
    )));
    await respiro(tester);
    // ignore: avoid_print
    print('ORDINE AO VOCE 07: sotto una rotta opaca gira '
        '${giraDavvero(tester)}');
    expect(giraDavvero(tester), isFalse,
        reason: 'sotto una rotta opaca il cielo gira a vuoto');

    Navigator.of(dentro).pop();
    await respiro(tester);
    // ignore: avoid_print
    print('ORDINE AO VOCE 07: tornati dalla funzionalita\' gira '
        '${giraDavvero(tester)}');
    expect(giraDavvero(tester), isTrue,
        reason: 'tornando dalla funzionalita\' il cielo resta fermo');
  });

  testWidgets('CASO 3: piu\' rotte aperte e chiuse in fila', (tester) async {
    late BuildContext dentro;
    await tester.pumpWidget(attorno(
      Scaffold(body: Builder(builder: (ctx) {
        dentro = ctx;
        return const CosmosBackground(child: SizedBox.expand());
      })),
    ));
    await respiro(tester);

    for (var giro = 0; giro < 3; giro++) {
      unawaited(Navigator.of(dentro).push(MaterialPageRoute<void>(
        builder: (_) => Scaffold(body: Text('rotta $giro')),
      )));
      await respiro(tester);
    }
    for (var giro = 0; giro < 3; giro++) {
      Navigator.of(dentro).pop();
      await respiro(tester);
    }
    // ignore: avoid_print
    print('ORDINE AO VOCE 07: dopo tre aperture e tre chiusure gira '
        '${giraDavvero(tester)}, sospesi ${CosmosBackground.quantiSospesi}');
    expect(giraDavvero(tester), isTrue,
        reason: 'dopo tre rotte aperte e chiuse in fila il cielo e\' rimasto '
            'fermo: e\' l\'interruttore che ha perso il conto');
  });

  testWidgets('LA SENTINELLA: se il cielo e\' fermo mentre dovrebbe girare, '
      'riparte e lo registra', (tester) async {
    await tester.pumpWidget(attorno(
      const Scaffold(body: CosmosBackground(child: SizedBox.expand())),
    ));
    await respiro(tester);
    final primaDelGuasto = CosmosBackground.ripartenzeDellaSentinella;

    // Si ferma il giro alle spalle dello stato, come farebbe un evento
    // perduto: lo stato dice che deve girare, il ticker e' fermo.
    final stato = tester.state(
        find.byType(CosmosBackground, skipOffstage: false));
    // ignore: avoid_dynamic_calls
    (stato as dynamic).fermaIlGiroPerProva();
    // **SI ASPETTA IL BATTITO DELLA SENTINELLA**, che e' lento apposta: due
    // secondi, dichiarati in `intervalloDellaSentinella`.
    await tester.pump(CosmosBackground.intervalloDellaSentinella +
        const Duration(milliseconds: 200));
    await respiro(tester);

    // ignore: avoid_print
    print('ORDINE AO VOCE 07: dopo il guasto simulato gira '
        '${giraDavvero(tester)}, ripartenze '
        '${CosmosBackground.ripartenzeDellaSentinella}');
    expect(giraDavvero(tester), isTrue,
        reason: 'la sentinella non ha rimesso in moto il cielo');
    expect(CosmosBackground.ripartenzeDellaSentinella,
        greaterThan(primaDelGuasto),
        reason: 'la sentinella e\' intervenuta senza registrarlo: un guasto '
            'che non lascia traccia e\' un guasto che nessuno spieghera\'');
  });
}

/// Lanciare una rotta senza attenderla, come fa l'app.
void unawaited(Future<void> _) {}
