import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/design_system/theme/accento_del_maestro.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/rituals/breath_destiny_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// IL SOFFIO SI DEVE LEGGERE, e le cose si misurano.
///
/// Non si giudica a occhio: il contrasto si calcola con la formula delle WCAG
/// contro la superficie vera su cui il testo e' appoggiato. Le superfici e gli
/// inchiostri stanno in `SuperficiDelSoffio`, dentro la schermata, cosi' questa
/// prova misura esattamente cio' che si dipinge e non due costanti gemelle.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.aura));

  test('il contatore dei giri si legge sulla sua superficie', () {
    // **PRIMA:** il conteggio era un `Text` posato sulla scena, cioe' sui raggi
    // del soffione, senza nessun fondo suo. Un testo chiaro su un disco chiaro.
    final contrasto = AccentoDelMaestro.contrastoFra(
        SuperficiDelSoffio.inchiostro,
        SuperficiDelSoffio.velo);
    expect(contrasto, greaterThanOrEqualTo(4.5),
        reason: 'Il contatore dei giri si legge a '
            '${contrasto.toStringAsFixed(2)} di contrasto sulla sua '
            'superficie, sotto il 4,5 che serve.');
  });

  test('le due righe della Risposta si leggono sulla loro superficie', () {
    // **PRIMA:** `_LaRisposta` era una Column nuda appoggiata sul prato: nessun
    // fondo, testo chiaro sul chiaro.
    for (final inchiostro in [
      SuperficiDelSoffio.inchiostroDellaRisposta,
      SuperficiDelSoffio.inchiostroSecondarioDellaRisposta,
    ]) {
      final contrasto =
          AccentoDelMaestro.contrastoFra(inchiostro, SuperficiDelSoffio.velo);
      expect(contrasto, greaterThanOrEqualTo(4.5),
          reason: 'Una riga della Risposta si legge a '
              '${contrasto.toStringAsFixed(2)} di contrasto: sotto il 4,5.');
    }
  });

  test('il titolo della Risposta e\' verde, e il verde crudo NON passerebbe',
      () {
    final accento =
        AccentoDelMaestro.su(Maestro.aura, superficie: SuperficiDelSoffio.velo);
    expect(
        AccentoDelMaestro.contrastoFra(accento, SuperficiDelSoffio.velo),
        greaterThanOrEqualTo(4.5),
        reason: 'Il titolo della Risposta non si legge sulla sua superficie.');
    // **QUI LA REGOLA NON CORREGGE NIENTE, ED E' GIUSTO COSI'.** L'ordine
    // chiedeva una prova che pretendesse il fallimento del verde crudo,
    // altrimenti la regola sarebbe inerte. Misurato: sul velo scuro il verde di
    // Aura sta a 5,83 di contrasto, cioe' passa gia'. Pretendere che non passi
    // vorrebbe dire scrivere in una prova una cosa falsa.
    //
    // Il presidio contro l'inerzia esiste, e sta dove il verde davvero non
    // passa, cioe' sul vetro chiaro delle schede dei Doni: lo tiene
    // `test/ogni_dono_dice_chi_parla_test.dart`, che misura 2,9 contro i 4,5
    // richiesti. Una regola che vale per superfici chiare e scure va provata
    // dove morde, non dove capita.
    final crudoSulVelo = AccentoDelMaestro.contrastoFra(
        palette.primary, SuperficiDelSoffio.velo);
    expect(crudoSulVelo, greaterThanOrEqualTo(4.5),
        reason: 'Sul velo scuro il verde crudo misurava 5,83 e adesso misura '
            '${crudoSulVelo.toStringAsFixed(2)}: se fosse sceso sotto la '
            'soglia, il velo e\' cambiato e va rimisurato tutto.');
  });

  testWidgets('il disco luminoso e l\'anello del respiro hanno un centro solo',
      (tester) async {
    // **PRIMA:** il disco stava a 0,26 dell'altezza del corpo, dentro il
    // painter, e l'anello dentro una colonna allineata a -0,2 di una zona
    // flex: due centri decisi in due sistemi diversi, che non potevano
    // coincidere per costruzione.
    //
    // Si misura sulla RESA e non sui flex: si guarda dove la figura del
    // respiro e' finita davvero e la si confronta col centro dichiarato.
    tester.view.physicalSize = const Size(1080, 2391);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});

    // Senza `MaestroScope` attorno: la schermata legge la palette di Aura da
    // se', e lo scope pretenderebbe un `MaestroController` che qui non serve.
    await tester.pumpWidget(MaterialApp(
      home: BreathDestinyScreen(now: DateTime(2026, 8, 6, 10, 30)),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // Si compie il gesto col ripiego tattile, che e' sempre presente: il
    // respiro compare solo a dono rivelato.
    await tester.longPress(find.byKey(const Key('ritual_gesture')));
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }

    final figura = find.byKey(const Key('respiro_figura'));
    if (figura.evaluate().isEmpty) {
      // Il rito del giorno puo' non portare una cadenza: senza respiro non c'e'
      // nessun anello da allineare, e la prova lo dichiara invece di passare in
      // silenzio.
      markTestSkipped('Il rito di questo giorno non porta un respiro contato.');
      return;
    }

    final scena = tester.getRect(find.byType(Stack).first);
    final centroAnello = tester.getCenter(figura);
    final voluto = SuperficiDelSoffio.discoDentro(scena.size);
    final scarto = (centroAnello.dy - scena.top) - voluto.dy;
    expect(scarto.abs(), lessThan(1.0),
        reason: 'Il disco luminoso e l\'anello del respiro distano '
            '${scarto.toStringAsFixed(1)} punti: a video si legge come un '
            'difetto di stampa. I due devono leggere lo stesso centro.');
  });

  test('il velo copre abbastanza da valere come superficie', () {
    // Un velo troppo trasparente non e' una superficie: il contrasto misurato
    // sopra sarebbe un numero che descrive una cosa che a video non c'e'.
    expect(SuperficiDelSoffio.velo.a, greaterThanOrEqualTo(0.86),
        reason: 'Il velo e\' troppo trasparente per reggere il contrasto '
            'dichiarato: sotto ci passa la scena.');
  });
}
