import 'dart:io';

import 'package:esoteric_circle/core/lunario/il_dial_a_moon.dart';
import 'package:esoteric_circle/core/lunario/il_respiro_della_luna.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/respiro_della_luna/il_respiro_della_luna_screen.dart';
import 'package:esoteric_circle/features/respiro_della_luna/medora_che_respira.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **IL VIDEO DI MEDORA SEGUE IL RESPIRO.** Ordine GD voce GD.24, 23 ottobre
/// 2026. Il fondatore: *"eravamo d'accordo se non sbaglio, che il video di
/// Medora doveva andare avanti e indietro seguendo «espira e inspira» e per
/// questo avevamo creato il video apposta con Medora che inspira ed espira"*.
///
/// Un lettore finto registra ogni posizione che la schermata gli chiede. La
/// misura e' il fotogramma chiesto in tre istanti del ciclo, col dito
/// sempre premuto: a meta' dell'inspiro, in cima all'inspiro, a meta'
/// dell'espiro. Deve salire e poi scendere. Poi il dito si solleva e per tre
/// secondi nessuna posizione nuova: il video resta dov'e'.

/// Il lettore finto: pronto subito, si ricorda le posizioni chieste.
class _LettoreFinto implements LettoreDelRespiro {
  final List<Duration> posizioni = [];
  bool _pronto = false;
  bool chiuso = false;

  @override
  bool get pronto => _pronto;

  @override
  Future<void> apri() async => _pronto = true;

  @override
  Future<void> vaiA(Duration posizione) async => posizioni.add(posizione);

  @override
  Widget disegna() => const SizedBox.expand(key: Key('lettore_finto'));

  @override
  void chiudi() => chiuso = true;
}

IlDialAMoon _offline() =>
    IlDialAMoon(client: MockClient((_) async => http.Response('', 503)));

void main() {
  final adesso = DateTime(2026, 10, 16, 21);
  final tempi = TempiDelRespiroDellaLuna.diOggi(adesso);

  test('il video del respiro esiste e ha i fotogrammi dichiarati', () {
    final f = File(MedoraCheRespira.filmato);
    expect(f.existsSync(), isTrue, reason: 'manca ${MedoraCheRespira.filmato}');
    expect(f.lengthSync(), greaterThan(1000000),
        reason: 'il file del respiro e\' troppo leggero per essere il video');
    // Il fotogramma piu' alto e' l'ultimo del tratto dell'inspiro.
    expect(MedoraCheRespira.fotogrammaDi(1), MedoraCheRespira.fotogrammi - 1);
    expect(MedoraCheRespira.fotogrammaDi(0), 0);
  });

  testWidgets(
      'col dito premuto il video va avanti sull\'inspiro e indietro '
      'sull\'espiro; col dito sollevato si ferma', (tester) async {
    SharedPreferences.setMockInitialValues(
        {'respiro.primaAperturaVista': true});
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final lettore = _LettoreFinto();
    await tester.pumpWidget(MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => MaestroController())],
      child: MaterialApp(
        home: MaestroScope(
          child: IlRespiroDellaLunaScreen(
              now: adesso,
              dialAMoon: _offline(),
              fabbricaDelRespiro: () => lettore),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.tap(find.byKey(const Key('luna_voce_respiro')));
    await tester.pump(const Duration(milliseconds: 600));

    // Medora che respira e' sulla scena, e la Luna dipinta e' coperta.
    expect(find.byKey(const Key('respiro_medora_che_respira')), findsOneWidget,
        reason: 'nel rito Medora che respira non e\' sulla scena');
    expect(
        find.byKey(const Key('respiro_luna_dipinta_coperta')), findsOneWidget);
    expect(find.byKey(const Key('respiro_luna_vera')), findsOneWidget,
        reason: 'la Luna vera deve restare una sola sopra il video');

    Duration ultima() => lettore.posizioni.last;
    Future<void> passa(Duration d) async {
      for (var i = 0; i < d.inMilliseconds ~/ 50; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
    }

    final dito = await tester.startGesture(
        tester.getCenter(find.byKey(const Key('respiro_la_luna_si_tocca'))));
    await passa(tempi.inspiro ~/ 2);
    final aMetaInspiro = ultima();
    await passa(tempi.inspiro ~/ 2 - const Duration(milliseconds: 50));
    final inCima = ultima();
    await passa(tempi.espiro ~/ 2 + const Duration(milliseconds: 50));
    final aMetaEspiro = ultima();

    // I numeri della misura finiscono nel motivo, cosi' il rosso li dice.
    final misura = 'meta\' inspiro ${aMetaInspiro.inMilliseconds} ms, cima '
        '${inCima.inMilliseconds} ms, meta\' espiro '
        '${aMetaEspiro.inMilliseconds} ms';
    debugPrint('GD.24, la misura: $misura');
    expect(inCima, greaterThan(aMetaInspiro),
        reason: 'sull\'inspiro il video non va avanti: $misura');
    expect(aMetaEspiro, lessThan(inCima),
        reason: 'sull\'espiro il video non torna indietro: $misura');
    // La cima dell'inspiro e' vicina all'ultimo fotogramma del tratto.
    expect(inCima.inMilliseconds,
        greaterThan(MedoraCheRespira.istanteDi(90).inMilliseconds),
        reason: 'in cima all\'inspiro il video e\' rimasto indietro: $misura');

    // Il dito si solleva: nessuna posizione nuova per tre secondi.
    await dito.up();
    await tester.pump(const Duration(milliseconds: 50));
    final chiesteAlRilascio = lettore.posizioni.length;
    final fermaA = ultima();
    await passa(const Duration(seconds: 3));
    expect(lettore.posizioni.length, chiesteAlRilascio,
        reason: 'col dito sollevato il video continua a muoversi');
    expect(ultima(), fermaA);

    // Uscendo dalla schermata il lettore si chiude.
    await tester.pumpWidget(const SizedBox());
    expect(lettore.chiuso, isTrue,
        reason: 'il lettore del respiro resta aperto');
  });
}
