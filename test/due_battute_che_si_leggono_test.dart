import 'package:esoteric_circle/core/astro/celestial.dart';
import 'package:esoteric_circle/core/maestro/consulto_del_cielo.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/maestro/tempi_dell_attesa.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/components/consulto_del_cielo_view.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// DUE BATTUTE INVECE DI TRE, E OGNUNA SI LEGGE.
///
/// **Il dato che ha fatto nascere questo file.** Il fondatore ha misurato sul
/// telefono, con la build 2140, che ogni frase di riflessione durava MENO DI UN
/// SECONDO: sembrava un lampo invece di una riflessione.
///
/// La causa era aritmetica, non estetica: tre battute da 900 millisecondi
/// dentro un'attesa che ne durava 1800. La scena chiudeva a meta' della
/// seconda, e la terza non compariva mai.
///
/// **Perche' la correzione non poteva essere allungare l'attesa.** Il tetto
/// alla prima parola resta quattro secondi: oltre, la credibilita' diventa
/// lentezza. Restava l'altra strada, meno battute e piu' lunghe.
void main() {
  const natal = NatalContext(
    moonIllumination:
        MoonIllumination(fraction: 0.25, waxing: true, elongationDeg: 60),
  );

  test('Le battute sono due, e il numero vive in un posto solo', () {
    expect(TempiDellAttesa.battuteDellaScena, 2);
    // Il conto delle battute e il tetto del consulto sono la stessa decisione:
    // se qui divergessero, la scena durerebbe per un numero di battute e ne
    // mostrerebbe un altro.
    expect(ConsultoDelCielo.massimoBattute, TempiDellAttesa.battuteDellaScena,
        reason: 'il consulto conta le battute per conto suo');
    // E il posto per la frase del Maestro resta: senza, la scena tornerebbe un
    // inventario di corpi.
    expect(ConsultoDelCielo.massimeAncorate,
        lessThan(ConsultoDelCielo.massimoBattute),
        reason: 'senza un posto libero la frase del Maestro non entra piu\'');
  });

  test('Ogni battuta resta a schermo almeno 1,6 secondi', () {
    expect(TempiDellAttesa.durataBattuta.inMilliseconds,
        greaterThanOrEqualTo(1600),
        reason: 'una riga che dura meno non si fa in tempo a leggerla, ed e\' '
            'esattamente cio\' che il fondatore ha visto sul telefono');
  });

  test('La scena dura le sue battute intere, e non un pezzo dell\'ultima', () {
    // **NON e' una ripetizione della prova qui sopra.** Quella guarda quanto
    // dura una riga, questa guarda se la scena vive abbastanza da mostrarle
    // tutte: erano proprio queste due cose a non essere d'accordo, tre battute
    // da 900 dentro una scena da 1800.
    expect(
      TempiDellAttesa.durataMinima,
      TempiDellAttesa.durataBattuta * TempiDellAttesa.battuteDellaScena,
      reason: 'la scena si chiude a meta\' di una battuta: chi guarda vede una '
          'frase sparire mentre la sta leggendo',
    );
  });

  test('Il tempo alla prima parola resta sotto i quattro secondi', () {
    // CON LA RETE PEGGIORE MISURATA, non con una rete comoda.
    final peggiore = TempiDellAttesa.allaPrimaParola(
        TempiDellAttesa.reteMassimaMisurataMs);
    expect(peggiore, lessThan(TempiDellAttesa.tettoAllaPrimaParola),
        reason: 'con la rete peggiore misurata si arriva a '
            '${peggiore.inMilliseconds} millisecondi, e il tetto e\' '
            '${TempiDellAttesa.tettoAllaPrimaParola.inMilliseconds}');
    // E anche con una rete che il tetto lo raggiunge da sola non si somma:
    // la scena e la rete corrono insieme, non una dopo l'altra.
    expect(TempiDellAttesa.allaPrimaParola(3000).inMilliseconds,
        TempiDellAttesa.durataMinima.inMilliseconds +
            TempiDellAttesa.dissolvenza.inMilliseconds,
        reason: 'con una rete piu\' corta della scena comanda la scena');
  });

  test('Con Riduci Movimento i tempi si accorciano', () {
    final normale = TempiDellAttesa.allaPrimaParola(1500);
    final ridotto =
        TempiDellAttesa.allaPrimaParola(1500, riduciMovimento: true);
    expect(ridotto, lessThan(normale),
        reason: 'chi ha chiesto di ridurre il movimento sta aspettando '
            'quanto o piu\' di chi non lo ha chiesto');
  });

  testWidgets('A schermo passano DUE battute, e la seconda arriva intera',
      (tester) async {
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(360, 797) * 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => MaestroController()),
      ],
      child: const MaterialApp(
        home: MaestroScope(
          child: Scaffold(
            body: ConsultoDelCieloView(natal: natal, maestro: Maestro.medora),
          ),
        ),
      ),
    ));
    await tester.pump();

    final battute =
        ConsultoDelCielo.battutePer(natal, maestro: Maestro.medora);
    expect(battute.length, 2, reason: 'le battute prodotte non sono due');

    // La prima e' a video subito.
    expect(find.text(battute[0].frase), findsOneWidget);
    expect(find.text(battute[1].frase), findsNothing);

    // A UN CAPELLO PRIMA del passo, la prima c'e' ancora: e' la misura di
    // quanto resta leggibile, e non un controllo che il timer esista.
    await tester.pump(TempiDellAttesa.durataBattuta -
        const Duration(milliseconds: 50));
    expect(find.text(battute[0].frase), findsOneWidget,
        reason: 'la prima battuta e\' gia' ' sparita prima del suo tempo');

    // Passato il tempo, arriva la seconda.
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text(battute[1].frase), findsOneWidget,
        reason: 'la seconda battuta non arriva mai');
  });
}
