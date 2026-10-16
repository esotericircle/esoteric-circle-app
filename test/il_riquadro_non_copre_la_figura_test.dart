// ignore_for_file: avoid_print
import 'package:esoteric_circle/features/rituals/breath_destiny_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'attorno_al_soffio.dart';
import 'cardinale_minimo.dart';

/// **IL RIQUADRO DEL RESPIRO NON COPRE LA FIGURA, SU NESSUNO SCHERMO.**
/// Ordine EF voce 01, 23 settembre 2026.
///
/// **Il fatto del fondatore**, sulla cattura della build 2276: il riquadro
/// *"Preparati a respirare"* stava appoggiato sopra la figura e ne lasciava
/// vedere solo un dito sopra il proprio bordo.
///
/// **PERCHE' NESSUNA GUARDIA POTEVA VEDERLO FINO A OGGI, e vale piu' del
/// difetto.** La figura la dipinge un pittore, il riquadro lo dispone il
/// layout, e le due meta' non si sono mai incontrate in nessuna misura:
///
/// - le guardie del layout, da `la_scheda_non_sale_mai_sul_respiro` in giu',
///   misurano riquadri contro riquadri e **della figura non sanno niente**,
///   perche' un dipinto non ha un `RenderBox` da interrogare;
/// - la guardia del pittore, `il_soffione_respira`, dipinge il pittore da
///   solo e **del riquadro non sa niente**, perche' il riquadro non sta nel
///   pittore.
///
/// E c'era un secondo muro, tolto dalla voce 03: il pittore usciva subito
/// quando l'immagine del soffione mancava, e sotto `flutter test` un asset
/// PNG non si carica mai. **Nelle prove la figura non esisteva affatto**:
/// non c'era niente da coprire, quindi nessun difetto da trovare.
///
/// **Cosa rende possibile questa prova.** Da quest'ordine la geometria della
/// figura e' dichiarata in `SuperficiDelSoffio`, e la leggono **sia il
/// pittore sia il layout**. Quindi il fondo della figura e' un numero che una
/// prova puo' chiedere, e confrontarlo col tetto del riquadro e' finalmente
/// una domanda sola invece di due.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// La griglia, la stessa forma di `la_scheda_non_sale_mai_sul_respiro`: una
  /// geometria sola dice com'e' andata su un telefono, una griglia dice se la
  /// forma regge.
  const altezze = <double>[640, 750, 797, 914];
  const barre = <EdgeInsets>[
    EdgeInsets.zero,
    EdgeInsets.only(top: 40, bottom: 24),
    EdgeInsets.only(top: 48, bottom: 48),
  ];
  const scale = <double>[1.0, 1.3];

  Future<void> monta(
    WidgetTester tester, {
    required double altezza,
    required EdgeInsets rientri,
    required double scala,
  }) async {
    SharedPreferences.setMockInitialValues({});
    final finestra = Size(411, altezza);
    tester.view.physicalSize = finestra;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(attornoAlSoffio(
      BreathDestinyScreen(now: DateTime(2026, 8, 7, 10, 30)),
      finestra: finestra,
      rientri: rientri,
      scala: scala,
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    // Il rito: prima si soffia, e solo a soffio finito compare la guida del
    // respiro. Il ripiego tattile e' la strada che una prova puo' percorrere.
    await tester.longPress(find.byKey(const Key('ritual_gesture')));
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  testWidgets('IL TETTO DEL RIQUADRO STA SOTTO IL FONDO DELLA FIGURA',
      (tester) async {
    final guasti = <String>[];
    var geometrieGuardate = 0;
    var peggiore = double.infinity;

    for (final altezza in altezze) {
      for (final rientri in barre) {
        for (final scala in scale) {
          await monta(tester, altezza: altezza, rientri: rientri, scala: scala);

          final scena = tester
              .renderObject<RenderBox>(find.byKey(const Key('soffio_scena')));
          final guida = find.byKey(const Key('guida_respiro'));
          if (guida.evaluate().isEmpty) {
            guasti.add('${altezza.toStringAsFixed(0)} / $rientri / $scala: '
                'la guida del respiro non c\'e\': il rito non e\' arrivato '
                'fino al respiro e questa geometria non e\' stata misurata');
            continue;
          }
          final riquadro = tester.renderObject<RenderBox>(guida);
          final tetto =
              scena.globalToLocal(riquadro.localToGlobal(Offset.zero)).dy;
          final fondoFigura = SuperficiDelSoffio.fondoDelDono(scena.size);
          final margine = tetto - fondoFigura;
          geometrieGuardate++;
          if (margine < peggiore) peggiore = margine;
          // **E LA FIGURA NON DEVE ESSERE TAGLIATA IN CIMA.** Alzarla per
          // dare spazio alla bolla ha un limite: portato il centro a 0,165
          // dell'altezza, la testa al culmine usciva di tredici punti sopra
          // il bordo. **"Per intero" vale anche di sopra.**
          for (final (nome, cima) in [
            ('il dono', SuperficiDelSoffio.cimaDelDono(scena.size)),
            ('il soffione', SuperficiDelSoffio.cimaDelSoffione(scena.size)),
          ]) {
            // Mezzo punto di tolleranza: la stretta porta la figura
            // ESATTAMENTE sul bordo, e uno zero negativo di virgola mobile
            // non e' un taglio. Sotto il pixel fisico non si vede niente.
            if (cima < -0.5) {
              guasti.add('${altezza.toStringAsFixed(0)} / $rientri / $scala: '
                  '$nome esce dal bordo di sopra per '
                  '${(-cima).toStringAsFixed(1)} punti');
            }
          }
          if (margine < 0) {
            guasti.add('${altezza.toStringAsFixed(0)} / $rientri / $scala: '
                'il riquadro copre la figura per '
                '${(-margine).toStringAsFixed(1)} punti');
          }
        }
      }
    }

    // **IL CARDINALE, perche' questa gira su una griglia costruita a
    // esecuzione.** Se il rito non arrivasse mai al respiro, il ciclo
    // girerebbe a vuoto e la prova sarebbe verde senza aver guardato niente.
    cardinaleMinimo(
        geometrieGuardate, altezze.length * barre.length * scale.length,
        cosa: 'geometrie in cui il riquadro del respiro e\' stato misurato',
        perche: 'Sono tutte le combinazioni della griglia: se una non arriva '
            'al respiro, quella geometria non e\' stata guardata.');
    print('ORDINE EF VOCE 01: geometrie guardate $geometrieGuardate, '
        'margine peggiore fra figura e riquadro '
        '${peggiore.toStringAsFixed(1)} punti');
    expect(guasti, isEmpty, reason: guasti.join('\n'));
  });

  /// **E NEANCHE L'INVITO AL GESTO COPRE IL SOFFIONE.** Ordine EF voce 01.
  ///
  /// **Difetto trovato guardando una cattura, non leggendo il codice, e
  /// l'ordine non lo nominava.** Curato il riquadro del respiro, la prima
  /// cattura del banco ha mostrato la pastiglia *"Soffia, oppure spazza col
  /// dito"* appoggiata in mezzo alla testa del soffione: stessa malattia,
  /// fase diversa. Prima di quest'ordine nessuno poteva vederla, perche' il
  /// soffione nelle prove non esisteva.
  testWidgets('E L\'INVITO AL GESTO STA SOTTO IL SOFFIONE', (tester) async {
    final guasti = <String>[];
    var geometrieGuardate = 0;
    var peggiore = double.infinity;

    for (final altezza in altezze) {
      for (final rientri in barre) {
        for (final scala in scale) {
          SharedPreferences.setMockInitialValues({});
          final finestra = Size(411, altezza);
          tester.view.physicalSize = finestra;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.reset);
          await tester.pumpWidget(attornoAlSoffio(
            BreathDestinyScreen(now: DateTime(2026, 8, 7, 10, 30)),
            finestra: finestra,
            rientri: rientri,
            scala: scala,
          ));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 600));
          // **Niente gesto: qui si guarda la fase PRIMA del soffio**, che e'
          // l'unica in cui il soffione e' a schermo.
          final scena = tester
              .renderObject<RenderBox>(find.byKey(const Key('soffio_scena')));
          final invito = find.byKey(const Key('soffio_invito_al_gesto'));
          if (invito.evaluate().isEmpty) {
            guasti.add('${altezza.toStringAsFixed(0)} / $rientri / $scala: '
                'l\'invito al gesto non c\'e\'');
            continue;
          }
          final pastiglia = tester.renderObject<RenderBox>(invito);
          final tetto =
              scena.globalToLocal(pastiglia.localToGlobal(Offset.zero)).dy;
          final fondo = SuperficiDelSoffio.fondoDelSoffione(scena.size);
          final margine = tetto - fondo;
          geometrieGuardate++;
          if (margine < peggiore) peggiore = margine;
          if (margine < 0) {
            guasti.add('${altezza.toStringAsFixed(0)} / $rientri / $scala: '
                'l\'invito copre il soffione per '
                '${(-margine).toStringAsFixed(1)} punti');
          }
        }
      }
    }

    cardinaleMinimo(
        geometrieGuardate, altezze.length * barre.length * scale.length,
        cosa: 'geometrie in cui l\'invito al gesto e\' stato misurato',
        perche: 'Sono tutte le combinazioni della griglia: se in una l\'invito '
            'non compare, quella geometria non e\' stata guardata.');
    print('ORDINE EF VOCE 01: geometrie guardate $geometrieGuardate, '
        'margine peggiore fra soffione e invito '
        '${peggiore.toStringAsFixed(1)} punti');
    expect(guasti, isEmpty, reason: guasti.join('\n'));
  });
}
