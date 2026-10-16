// LA BUSSOLA DELLA LUNA. Ordine FX voce FX.06, 16 ottobre 2026.
//
// Due prove, come chiede la voce: che l'ago punti nella direzione giusta
// per un azimut noto del telefono, e che il ripiego tattile compaia quando
// il sensore non risponde. L'orientamento del telefono e' finto: la stessa
// "posa verticale che guarda a nord" gia' stabilita in
// `real_time_cosmo_il_telefono_orizzontale_test.dart`, qui iniettata dentro
// un vero `OrientamentoDelTelefono` con una gravita' finta e un
// magnetometro finto (un `StreamController`, non il sensore vero).

import 'dart:async';
import 'dart:math' as math;

import 'package:esoteric_circle/core/astro/celestial.dart';
import 'package:esoteric_circle/core/astro/luogo_attuale.dart';
import 'package:esoteric_circle/core/motion/l_orientamento_del_telefono.dart';
import 'package:esoteric_circle/features/respiro_della_luna/la_bussola_della_luna.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sensors_plus/sensors_plus.dart';

void main() {
  // La stessa posa "verticale, guarda a nord" di
  // real_time_cosmo_il_telefono_orizzontale_test.dart: il campo magnetico
  // mondiale e la gravita' mondiale decomposti sugli assi del telefono
  // (asse x del telefono verso est, asse y verso l'alto, camera verso
  // nord). Con `declinazioneGradi` a zero (il default), il telefono
  // riporta azimut 0 (nord) e altezza 0 (in bolla).
  const nordMondo = [0.0, 22.5, -39.0];
  const altoMondo = [0.0, 0.0, 9.81];
  double p(List<double> u, List<double> w) =>
      u[0] * w[0] + u[1] * w[1] + u[2] * w[2];
  const assex = [1.0, 0.0, 0.0];
  const assey = [0.0, 0.0, 1.0];
  const assez = [0.0, -1.0, 0.0]; // assex × assey

  const luogo = LuogoAttuale(
      lat: 45.0526, lon: 9.6930, citta: 'Piacenza', origine: OrigineDelLuogo.scelto);
  final adesso = DateTime.utc(2026, 10, 16, 20, 0, 0);

  testWidgets('con un azimut noto del telefono, l\'ago ruota dello scarto '
      'giusto verso la Luna vera', (tester) async {
    final magnete = StreamController<MagnetometerEvent>();
    addTearDown(magnete.close);
    final telefono = OrientamentoDelTelefono(
      gravita: () => (
        x: p(assex, altoMondo),
        y: p(assey, altoMondo),
        z: p(assez, altoMondo),
      ),
      bussola: () => magnete.stream,
    );
    magnete.add(MagnetometerEvent(
      p(assex, nordMondo),
      p(assey, nordMondo),
      p(assez, nordMondo),
      adesso,
    ));

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: LaBussolaDellaLuna(
          luogo: luogo,
          telefono: telefono,
          adesso: () => adesso,
        ),
      ),
    ));
    // Un fotogramma lascia arrivare l'evento accodato nello stream, un
    // secondo fa scattare il primo giro del timer del sensore (sessanta
    // millisecondi, virtualizzati da flutter_test).
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Il telefono punta a nord (azimut zero): niente ripiego, c'e' l'ago.
    expect(find.byKey(const ValueKey('la_bussola_della_luna.ripiego')), findsNothing);
    final agoFinder = find.byKey(const ValueKey('la_bussola_della_luna.ago'));
    expect(agoFinder, findsOneWidget);

    // La posizione vera della Luna, calcolata con la stessa porta che usa
    // il widget: l'oracolo indipendente di questa prova.
    final jd = Celestial.julianDay(adesso.toUtc());
    final lst = Celestial.localSiderealDegrees(jd, luogo.lon);
    final eq = Celestial.moonEquatorial(jd);
    final hor = Celestial.equatorialToHorizontal(
        raDeg: eq.raDeg, decDeg: eq.decDeg, latDeg: luogo.lat, lstDeg: lst);
    final scartoAtteso = scartoAzimutGradi(0, hor.azDeg);
    final angoloAtteso = rotazioneAgoRadianti(scartoAtteso);

    final transform = tester.widget<Transform>(agoFinder);
    final m = transform.transform.storage;
    final angoloVero = math.atan2(m[1], m[0]);
    expect(angoloVero, closeTo(angoloAtteso, 1e-6),
        reason: 'scarto atteso $scartoAtteso gradi, azimut vero della Luna '
            '${hor.azDeg}');
  });

  testWidgets('senza una lettura del sensore, compare il ripiego tattile '
      'con direzione e altezza in parole', (tester) async {
    // Nessun `telefono` iniettato: senza un `ParallaxController` nella
    // pila e senza un plugin vero, la gravita' e il magnetometro restano
    // muti (il canale della piattaforma non esiste nelle prove), e dopo
    // due secondi il widget dichiara il ripiego da solo.
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: LaBussolaDellaLuna(luogo: luogo, adesso: () => adesso),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 100));

    final ripiegoFinder =
        find.byKey(const ValueKey('la_bussola_della_luna.ripiego'));
    expect(ripiegoFinder, findsOneWidget);

    final jd = Celestial.julianDay(adesso.toUtc());
    final lst = Celestial.localSiderealDegrees(jd, luogo.lon);
    final eq = Celestial.moonEquatorial(jd);
    final hor = Celestial.equatorialToHorizontal(
        raDeg: eq.raDeg, decDeg: eq.decDeg, latDeg: luogo.lat, lstDeg: lst);
    final direzioneAttesa = direzioneCardinale(hor.azDeg);

    final testo = tester.widget<Text>(ripiegoFinder).data!;
    expect(testo, contains(direzioneAttesa));
    expect(testo, contains('otto nell\'aria'));
  });
}
