// IL REAL TIME COSMO SI FERMA QUANDO ESCE DI SCENA. Ordine FG voce 7.8.
//
// Il modello e' cosmos_background.dart (ordine AM voce 01): segue il ciclo di
// vita dell'app (paused, hidden, detached) e la rotta coperta. Qui si misura
// sulla schermata vera: disegna in scena; una rotta sopra la ferma e la
// bussola si spegne davvero; tornando riparte; l'app in pausa la ferma.
//
// E la misura a runtime della guardia 7.1: in un secondo e mezzo di
// fotogrammi la foschia e la Luna non si sono cotte a ogni fotogramma.

import 'dart:async';

import 'package:esoteric_circle/core/astro/sky_location.dart';
import 'package:esoteric_circle/core/motion/l_orientamento_del_telefono.dart';
import 'package:esoteric_circle/features/real_time_cosmo/cielo_reale_screen.dart';
import 'package:esoteric_circle/features/real_time_cosmo/pittore_del_cielo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'le_anteprime_dell_ordine_fg_test.dart' as fg;

bool _disegna(WidgetTester tester) =>
    (tester.state(find.byType(CieloRealeScreen, skipOffstage: false))
            as dynamic).staDisegnando
        as bool;

void main() {
  testWidgets('in scena disegna, coperta o in pausa si ferma', (tester) async {
    final campo = StreamController<MagnetometerEvent>.broadcast();
    addTearDown(campo.close);
    final telefono = OrientamentoDelTelefono(
      gravita: () => (x: 0.0, y: 9.8, z: 0.0),
      bussola: () => campo.stream,
    );
    await fg.monta(
        tester,
        CieloRealeScreen(
          modo: ModoDelCielo.adesso,
          orologio: () => fg.adesso,
          posizione: const DisabledSkyLocation(),
          bussola: telefono,
        ));
    await fg.carica(tester);
    // Un campo magnetico vero, cosi' la bussola e' pronta e non ripiega.
    campo.add(MagnetometerEvent(0, 22, -40, DateTime.now()));
    MisureDelCosmo.foschieCotte = 0;
    MisureDelCosmo.luneCotte = 0;
    await fg.passa(tester, 15);
    expect(_disegna(tester), isTrue, reason: 'in scena il cielo disegna');
    expect(telefono.acceso, isTrue, reason: 'in scena la bussola ascolta');

    // La misura della 7.1 a runtime: quindici fotogrammi, poche cotture.
    expect(MisureDelCosmo.foschieCotte, lessThanOrEqualTo(2));
    expect(MisureDelCosmo.luneCotte, lessThanOrEqualTo(2));

    // Una rotta sopra: si ferma tutto.
    final navigatore = tester.state<NavigatorState>(find.byType(Navigator));
    unawaited(navigatore.push(MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('sopra')))));
    await fg.passa(tester, 6);
    expect(_disegna(tester), isFalse, reason: 'coperta, il cielo e\' fermo');
    expect(telefono.acceso, isFalse, reason: 'coperta, la bussola e\' spenta');

    // Si torna: riparte.
    navigatore.pop();
    await fg.passa(tester, 6);
    expect(_disegna(tester), isTrue);
    expect(telefono.acceso, isTrue);

    // L'app in pausa: si ferma.
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(_disegna(tester), isFalse, reason: 'in pausa il cielo e\' fermo');
    expect(telefono.acceso, isFalse, reason: 'in pausa la bussola e\' spenta');
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(_disegna(tester), isTrue);
  });
}
