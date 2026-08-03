import 'package:esoteric_circle/core/astro/celestial.dart';
import 'package:esoteric_circle/core/maestro/consulto_del_cielo.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/components/consulto_del_cielo_view.dart';
import 'package:esoteric_circle/design_system/components/scena_sopra_la_conversazione.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// LA SCENA OCCUPA LO SPAZIO CHE AVANZA, E NON QUELLO DELLA CONVERSAZIONE.
///
/// **Il dato di partenza.** L'emblema stava a 96 punti fissi, cioe' poco piu'
/// di un quarto della larghezza dello schermo del fondatore, dentro una fascia
/// libera alta centinaia di punti.
void main() {
  const natal = NatalContext(
    moonIllumination:
        MoonIllumination(fraction: 0.25, waxing: true, elongationDeg: 60),
  );

  Widget host(Widget figlio) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => MaestroController()),
        ],
        child: MaterialApp(
          home: MaestroScope(child: Scaffold(body: figlio)),
        ),
      );

  /// Il lato del corpo disegnato, misurato a video e non dedotto.
  double? latoDelCorpo(WidgetTester tester) {
    final trovato = find.byKey(const Key('consulto_corpo'));
    if (trovato.evaluate().isEmpty) return null;
    return tester.getSize(trovato).width;
  }

  testWidgets('A conversazione vuota il corpo arriva ad almeno 180 punti',
      (tester) async {
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(360, 797) * 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(host(
      const ScenaSopraLaConversazione(
        scena: ConsultoDelCieloView(natal: natal),
        // Una conversazione vuota: non chiede niente.
        conversazione: SizedBox(height: 0),
      ),
    ));
    await tester.pump();

    final lato = latoDelCorpo(tester);
    expect(lato, isNotNull, reason: 'la scena non disegna nessun corpo');
    expect(lato!, greaterThanOrEqualTo(180.0),
        reason: 'a conversazione vuota il corpo deve arrivare ad almeno meta\' '
            'della larghezza dello schermo, e invece misura $lato punti');
    expect(lato, lessThanOrEqualTo(ConsultoDelCieloView.tettoDelCorpo));
  });

  testWidgets('Con la conversazione piena il corpo scende al pavimento',
      (tester) async {
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(360, 797) * 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // La conversazione si prende quasi tutto: resta appena il minimo. La
    // riserva si chiede alla frase VERA che la scena mostrera', non a una
    // costante che potrebbe non valere per questa frase.
    final frase = ConsultoDelCielo.battutePer(natal).first.frase;
    final restante = ConsultoDelCieloView.liberoMinimoPer(frase, 360);
    await tester.pumpWidget(host(
      LayoutBuilder(
        builder: (context, vincoli) => ScenaSopraLaConversazione(
          scena: const ConsultoDelCieloView(natal: natal),
          conversazione: SizedBox(height: vincoli.maxHeight - restante),
        ),
      ),
    ));
    await tester.pump();

    final lato = latoDelCorpo(tester);
    expect(lato, isNotNull,
        reason: 'al pavimento il corpo deve esserci ancora');
    expect(lato, closeTo(ConsultoDelCieloView.pavimentoDelCorpo, 1.0));
  });

  testWidgets('Sotto il pavimento resta la riga, e il corpo sparisce',
      (tester) async {
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(360, 797) * 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(host(
      LayoutBuilder(
        builder: (context, vincoli) => ScenaSopraLaConversazione(
          scena: const ConsultoDelCieloView(natal: natal),
          // Meno del minimo: non ci sta piu' nemmeno il pavimento.
          conversazione: SizedBox(
              height: vincoli.maxHeight -
                  ConsultoDelCieloView.liberoMinimoPer(
                      ConsultoDelCielo.battutePer(natal).first.frase, 360) +
                  20),
        ),
      ),
    ));
    await tester.pump();

    expect(latoDelCorpo(tester), isNull,
        reason: 'sotto il pavimento il corpo va TOLTO, non schiacciato: un '
            'emblema compresso e\' una macchia che non si riconosce');
    // La riga resta: si toglie il disegno, non l'informazione.
    expect(find.text('Sto consultando'), findsOneWidget);
  });

  testWidgets('La conversazione non si sposta quando la scena compare',
      (tester) async {
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(360, 797) * 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // LA COSA CHE CONTA PIU' DELLA MISURA.
    //
    // Una scena che sposta cio' che stai leggendo e' peggio di una scena
    // piccola. Qui si misura DOVE sta la conversazione con la scena accesa e
    // con la scena spenta: deve stare nello stesso punto.
    Future<double> cimaDellaConversazione({required bool conScena}) async {
      await tester.pumpWidget(host(
        ScenaSopraLaConversazione(
          scena: conScena
              ? const ConsultoDelCieloView(natal: natal)
              : const SizedBox.shrink(),
          conversazione: const SizedBox(
            key: Key('finta_conversazione'),
            height: 200,
            width: double.infinity,
          ),
        ),
      ));
      await tester.pump();
      return tester.getTopLeft(find.byKey(const Key('finta_conversazione'))).dy;
    }

    final senza = await cimaDellaConversazione(conScena: false);
    final con = await cimaDellaConversazione(conScena: true);
    expect(con, senza,
        reason: 'la scena ha spostato la conversazione di ${con - senza} '
            'punti: deve occupare cio\' che avanza, non reclamarlo');

  });

  testWidgets('La scena non copre la conversazione quando lo spazio e poco',
      (tester) async {
    // NON SPOSTARLA NON BASTA.
    //
    // Dando alla scena tutta l'altezza invece del solo avanzo, la
    // conversazione resterebbe al suo posto e la scena le finirebbe SOPRA. La
    // prima stesura della prova qui accanto guardava solo la POSIZIONE, con
    // una conversazione alta 200 punti in una fascia da ottocento: la
    // sovrapposizione non poteva accadere, quindi il guasto la lasciava verde.
    // Il caso va costruito dove il difetto puo' esistere, cioe' con una
    // conversazione che si e' presa quasi tutto.
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(360, 797) * 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(host(
      LayoutBuilder(
        builder: (context, vincoli) => ScenaSopraLaConversazione(
          scena: const ConsultoDelCieloView(natal: natal),
          conversazione: SizedBox(
            key: const Key('finta_conversazione'),
            height: vincoli.maxHeight - 260,
            width: double.infinity,
          ),
        ),
      ),
    ));
    await tester.pump();

    final fondoDellaScena =
        tester.getBottomLeft(find.byKey(const Key('consulto_del_cielo'))).dy;
    final cima =
        tester.getTopLeft(find.byKey(const Key('finta_conversazione'))).dy;
    expect(fondoDellaScena, lessThanOrEqualTo(cima + 0.5),
        reason: 'la scena arriva a $fondoDellaScena e la conversazione '
            'comincia a $cima: si stanno sovrapponendo');
  });

  test('Il corpo cresce con lo spazio, fra pavimento e tetto', () {
    // La scala, non tre casi scelti a mano.
    var precedente = 0.0;
    final riserva = ConsultoDelCieloView.riservaPer(
        ConsultoDelCielo.battutePer(natal).first.frase, 360);
    for (var libero = 0.0; libero <= 600; libero += 10) {
      final lato = ConsultoDelCieloView.corpoPer(libero, riserva);
      expect(lato, greaterThanOrEqualTo(ConsultoDelCieloView.pavimentoDelCorpo));
      expect(lato, lessThanOrEqualTo(ConsultoDelCieloView.tettoDelCorpo));
      expect(lato, greaterThanOrEqualTo(precedente),
          reason: 'a $libero punti liberi il corpo si e\' RISTRETTO: la '
              'misura deve crescere con lo spazio, mai il contrario');
      precedente = lato;
    }
    // E arriva davvero al tetto, altrimenti il tetto sarebbe una bugia.
    expect(ConsultoDelCieloView.corpoPer(600, riserva),
        ConsultoDelCieloView.tettoDelCorpo);
  });

  test('Restano tre battute al massimo, e la scena non allunga l\'attesa', () {
    final battute = ConsultoDelCielo.battutePer(natal, maestro: Maestro.medora);
    expect(battute.length, lessThanOrEqualTo(ConsultoDelCielo.massimoBattute));
  });

  testWidgets('A moto fermo nessun controllore di animazione viene creato',
      (tester) async {
    // L'ASSENZA DI MOVIMENTO SI PROVA QUI, NON IN UN'IMMAGINE.
    //
    // Le due anteprime "con Riduci Movimento" e "senza" pesavano lo stesso
    // numero di byte, cioe' erano lo stesso file: a riposo le due scene sono
    // identiche per costruzione, quindi un'immagine ferma non puo' provare
    // un'assenza di movimento. La prova vera e' che nessun ticker sia in giro.
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(360, 797) * 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(host(
      Builder(
        builder: (ctx) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: const ConsultoDelCieloView(natal: natal),
        ),
      ),
    ));
    await tester.pump();

    expect(tester.binding.transientCallbackCount, 0,
        reason: 'con Riduci Movimento resta registrato un ticker: un '
            'controllore che nessuno fa girare e comunque un moto che esiste');

    // E con il moto acceso invece c'e', altrimenti questa prova passerebbe
    // anche se la scena non si muovesse mai.
    await tester.pumpWidget(host(const ConsultoDelCieloView(natal: natal)));
    await tester.pump();
    expect(tester.binding.transientCallbackCount, greaterThan(0),
        reason: 'a moto acceso la scena non anima niente');
  });
}
