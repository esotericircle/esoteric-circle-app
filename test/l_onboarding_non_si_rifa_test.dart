import 'package:esoteric_circle/core/cammino/cammino_da_custodire.dart';
import 'package:esoteric_circle/core/cammino/ritrovamento.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/onboarding/onboarding_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/onboarding/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// L'ONBOARDING NON SI RIFA', E IL RITROVAMENTO SI VEDE. Ordine AP voce 05.
///
/// **La domanda di Mauro**: rifare l'onboarding quando si e' gia' registrati
/// non ha senso. Chi rientra col suo account ha gia' dato la sua nascita al
/// Cerchio, e richiedergliela e' come se il Cerchio non lo conoscesse.
///
/// **Cosa decide questa regola, e dove vive.** In un punto solo, perche' la
/// stessa domanda arriva da due strade diverse: dalla porta piccola della
/// voce 04 e dal "Continua come" della voce 06. Se ognuna decidesse per
/// conto suo, un giorno una delle due chiederebbe di nuovo la nascita a chi
/// l'aveva gia' data.
void main() {
  IdentitaDaCustodire identita({
    String? nome,
    DateTime? giorno,
    String? ora,
    String? luogo,
  }) =>
      IdentitaDaCustodire(
        nome: nome,
        giorno: giorno,
        ora: ora,
        luogo: luogo,
        latitudine: luogo == null ? null : 41.9,
        longitudine: luogo == null ? null : 12.5,
      );

  test('senza niente dal Cerchio, il rito si fa tutto', () {
    final esito = Ritrovamento.da(null);
    expect(esito.siSalta, isFalse);
    expect(esito.passiDaChiedere, Ritrovamento.tuttiIPassi,
        reason: 'chi arriva per la prima volta deve fare il rito intero');
  });

  test('con l\'identita\' completa il rito non si fa affatto', () {
    final esito = Ritrovamento.da(CamminoDaCustodire(
      identita: identita(
        nome: 'Sofia',
        giorno: DateTime(1990, 4, 12),
        ora: '07:30',
        luogo: 'Roma',
      ),
    ));
    // ignore: avoid_print
    print('ORDINE AP VOCE 05: identita\' completa, si salta '
        '${esito.siSalta}, passi da chiedere ${esito.passiDaChiedere}');
    expect(esito.siSalta, isTrue,
        reason: 'il Cerchio sa gia\' tutto e chiede di nuovo la nascita: e\' '
            'la domanda di Mauro, e la risposta e\' che non ha senso');
    expect(esito.passiDaChiedere, isEmpty);
  });

  test('con l\'ora mancante si chiede SOLO l\'ora', () {
    final esito = Ritrovamento.da(CamminoDaCustodire(
      identita: identita(
        nome: 'Sofia',
        giorno: DateTime(1990, 4, 12),
        luogo: 'Roma',
      ),
    ));
    // ignore: avoid_print
    print('ORDINE AP VOCE 05: senza ora, si chiede ${esito.passiDaChiedere}');
    expect(esito.siSalta, isFalse,
        reason: 'manca l\'ora e il rito e\' stato saltato lo stesso: '
            'l\'Ascendente resterebbe fuori per sempre');
    expect(esito.passiDaChiedere, [PassoDelRito.ora],
        reason: 'si chiede piu\' di cio\' che manca: ${esito.passiDaChiedere}');
  });

  test('col solo giorno si chiedono ora, luogo e nome', () {
    final esito = Ritrovamento.da(CamminoDaCustodire(
      identita: identita(giorno: DateTime(1990, 4, 12)),
    ));
    expect(esito.passiDaChiedere,
        [PassoDelRito.ora, PassoDelRito.luogo, PassoDelRito.nome]);
    expect(esito.passiDaChiedere, isNot(contains(PassoDelRito.data)),
        reason: 'si richiede la data di nascita, che il Cerchio ha gia\'');
  });

  test('il ritrovamento dice cosa e\' tornato, coi numeri veri', () {
    // **I NUMERI VERI E MAI QUELLI D'ESEMPIO**: e' la prova a schermo che la
    // promessa della custodia e' mantenuta, e un numero inventato la
    // trasformerebbe in una bugia.
    final esito = Ritrovamento.da(
      CamminoDaCustodire(
        identita: identita(
          nome: 'Sofia',
          giorno: DateTime(1990, 4, 12),
          ora: '07:30',
          luogo: 'Roma',
        ),
        sigilli: {
          'med_1': DateTime(2026, 8, 1),
          'cal_1': DateTime(2026, 8, 3),
        },
      ),
      saldoEos: 340,
    );
    // ignore: avoid_print
    print('ORDINE AP VOCE 05: ritrovati carta ${esito.cartaRitrovata}, '
        'traguardi ${esito.quantiTraguardi}, Eos ${esito.quantiEos}');
    expect(esito.cartaRitrovata, isTrue);
    expect(esito.quantiTraguardi, 2);
    expect(esito.quantiEos, 340);
    expect(esito.qualcosaDaMostrare, isTrue);
  });

  test('senza niente da mostrare non si mostra niente', () {
    // Chi entra con un account nuovo non deve vedere una scena che celebra
    // il ritrovamento di zero cose.
    final esito = Ritrovamento.da(const CamminoDaCustodire(), saldoEos: 0);
    expect(esito.qualcosaDaMostrare, isFalse);
  });

  test('la carta non si dice ritrovata senza il giorno di nascita', () {
    final esito = Ritrovamento.da(CamminoDaCustodire(
      identita: identita(nome: 'Sofia'),
    ));
    expect(esito.cartaRitrovata, isFalse,
        reason: 'si annuncia una carta natale che non si puo\' calcolare');
  });

  testWidgets('senza ora il rito comincia da quel passo, non da capo',
      (tester) async {
    // **LA PROVA A SCHERMO, e non solo la regola.** Che i passi mancanti
    // siano calcolati bene lo dicono le prove qui sopra; che la schermata li
    // USI lo dice questa, montandola davvero.
    SharedPreferences.setMockInitialValues(const {});
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => OnboardingController()),
        ChangeNotifierProvider(create: (_) => BirthIdentityController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MaestroScope(child: child!),
        home: OnboardingScreen(
          clock: () => DateTime(2026, 8, 19),
          ritrovata: IdentitaDaCustodire(
            nome: 'Sofia',
            giorno: DateTime(1990, 4, 12),
            luogo: 'Roma',
            latitudine: 41.9,
            longitudine: 12.5,
          ),
        ),
      ),
    ));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    // L'accoglienza e' alle spalle: il rito comincia da cio' che manca.
    final testi = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data ?? '')
        .join(' | ');
    // ignore: avoid_print
    print('ORDINE AP VOCE 05: a schermo si legge "${testi.substring(0, testi.length > 160 ? 160 : testi.length)}"');
    expect(testi.toLowerCase(), contains('ora'),
        reason: 'il rito non si e aperto sul passo che manca: "$testi"');
  });
}
