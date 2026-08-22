import 'package:esoteric_circle/core/cammino/cammino_da_custodire.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/identity/account_del_cerchio.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/onboarding/onboarding_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/onboarding/onboarding_screen.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'istante_dichiarato.dart';

/// IL RIENTRO INTERO, TOCCO PER TOCCO. Ordine AZ, fatto F2.
///
/// **Perche' questa prova esiste, e perche' doveva esistere prima.** Il fatto
/// F2 e' stato segnalato dal fondatore per piu' giri di seguito, e ogni volta
/// la cura veniva ragionata invece che riprodotta. **Le prove che esistevano
/// guardavano i pezzi**: che il Ritrovamento sappia cosa manca, che il
/// Risveglio costruito con l'identita' riparta dal passo giusto. Tutti e due
/// verdi, **e il difetto stava nel tratto in mezzo**, che nessuna prova
/// percorreva.
///
/// Qui si percorre la strada intera come la percorre una persona: si apre il
/// Risveglio, si tocca "Faccio gia' parte del Cerchio", si sceglie una via, si
/// tocca "Entra nel Cerchio", **e si guarda dove si finisce**.
void main() {
  BuildContext? radiceDellaProva;

  Future<void> montaIlRisveglio(
    WidgetTester tester, {
    required CamminoDaCustodire? custodito,
  }) async {
    SharedPreferences.setMockInitialValues(const {});
    tester.view.physicalSize = const Size(1080, 2392);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    final diario = DiarioDelCammino(orologio: orologioDelleProve);
    await diario.carica();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => OnboardingController()),
        ChangeNotifierProvider(create: (_) => BirthIdentityController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider<DiarioDelCammino>.value(value: diario),
        ChangeNotifierProvider(
          create: (_) =>
              QuestionAllowance(porta: _PortaCheCustodisce(custodito)),
        ),
        ChangeNotifierProvider<AccountDelCerchio>(
          create: (_) => AccountDelCerchio(porta: _PortaCheEntra()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (ctx, child) => MaestroScope(child: child!),
        // **COME LO MONTA L'APP VERA, e non come faceva comodo.** In
        // `lib/app.dart` il Risveglio non e' la home: viene SPINTO sopra il
        // guscio da `_OnboardingLauncher`. La differenza conta, perche' la
        // cura del rientro tocca proprio la pila delle schermate: una prova
        // che monta il Risveglio come home misura una strada che nell'app non
        // esiste.
        home: Builder(builder: (ctx) {
          radiceDellaProva = ctx;
          return const Scaffold(
              body: Center(child: Text('IL GUSCIO SOTTO IL RITO')));
        }),
      ),
    ));
    await tester.pump();
    Navigator.of(radiceDellaProva!)
        .push(OnboardingScreen.route(clock: () => DateTime(2026, 8, 22)));
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
  }

  Future<void> faiIlRientro(WidgetTester tester) async {
    // **NIENTE `pumpAndSettle` QUI**: il cielo del Risveglio si muove per
    // sempre, quindi non si ferma mai e l'attesa scade invece di dire
    // qualcosa. Si fanno passare fotogrammi a mano.
    await tester.tap(find.byKey(const Key('onboarding_porta_per_chi_torna')));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
    await tester.tap(find.byKey(const Key('custodia_google')),
        warnIfMissed: false);
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
    // La scena del ritrovamento, se c'e', si chiude col suo pulsante.
    final prosegui = find.textContaining('Entra nel Cerchio');
    if (prosegui.evaluate().isNotEmpty) {
      await tester.tap(prosegui.first, warnIfMissed: false);
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 150));
      }
    }
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
  }

  String cosaSiVede(WidgetTester tester) => tester
      .widgetList<Text>(find.byType(Text))
      .map((t) => t.data ?? '')
      .where((s) => s.isNotEmpty)
      .join(' | ');

  testWidgets('col Cerchio che sa TUTTO, il rito non si vede piu',
      (tester) async {
    await montaIlRisveglio(tester,
        custodito: CamminoDaCustodire(
          identita: IdentitaDaCustodire(
            giorno: DateTime(1975, 3, 14),
            ora: '07:30',
            luogo: 'Milano',
            nome: 'Mauro',
          ),
        ));
    await faiIlRientro(tester);
    final visto = cosaSiVede(tester);
    // ignore: avoid_print
    print('ORDINE AZ, F2: col Cerchio che sa tutto si vede "$visto"');
    expect(visto, isNot(contains('Sei sulla soglia del Cerchio')),
        reason: 'chi ha dato tutto si rivede l accoglienza del Risveglio: e '
            'il fatto F2');
    expect(visto, contains('IL GUSCIO SOTTO IL RITO'),
        reason: 'chi ha dato tutto non e uscito dal rito: doveva tornare al '
            'guscio, cioe alla home');
  });

  testWidgets('col Cerchio che sa a META, si riprende dal passo che manca',
      (tester) async {
    // **IL CASO VERO DEL FONDATORE**, quello riprodotto sul suo telefono: il
    // Cerchio gli restituiva la carta natale, sei Sigilli e settecentoquindici
    // Eos, e subito dopo il rito ripartiva dall'accoglienza.
    await montaIlRisveglio(tester,
        custodito: CamminoDaCustodire(
          identita: IdentitaDaCustodire(
            giorno: DateTime(1975, 3, 14),
            nome: 'Mauro',
          ),
        ));
    await faiIlRientro(tester);
    final visto = cosaSiVede(tester);
    // ignore: avoid_print
    print('ORDINE AZ, F2: col Cerchio che sa a meta si vede "$visto"');

    expect(visto, isNot(contains('Sei sulla soglia del Cerchio')),
        reason: 'il rito riparte dall accoglienza invece che dal passo che '
            'manca: e il fatto F2, segnalato per piu giri di seguito');
  });
}

/// Una porta del Cerchio che custodisce cio' che la prova le dice.
class _PortaCheCustodisce extends PortaDelCerchio {
  _PortaCheCustodisce(this.custodito);

  final CamminoDaCustodire? custodito;

  @override
  bool get viva => true;

  @override
  Future<StatoDelCerchio?> stato(
      {CamminoDaCustodire? cammino, bool azzeraIlCammino = false}) async {
    final identita = custodito?.identita;
    return StatoDelCerchio.daMappa({
      'giorno': '2026-08-22',
      'spesi': const {'domande': 0},
      'saldoEos': 715,
      if (identita != null)
        'cammino': {
          'versione': 1,
          'identita': {
            if (identita.nome != null) 'nome': identita.nome,
            if (identita.giorno != null)
              'giorno': identita.giorno!.toIso8601String().split('T').first,
            if (identita.ora != null) 'ora': identita.ora,
            if (identita.luogo != null) 'luogo': identita.luogo,
          },
        },
    });
  }

  @override
  Future<EsitoDelConsumo?> consuma(
          {required String budget, required String idMovimento}) async =>
      null;

  @override
  Future<int?> muoviGliEos({
    required String causale,
    required String motivo,
    required String idMovimento,
    int? quanti,
  }) async =>
      null;

  @override
  Future<bool> scriviLaMemoria({
    required String operazione,
    String? maestro,
    Map<String, Object?> campi = const {},
  }) async =>
      false;

  @override
  Future<bool> cancellaIlCerchio() async => false;
}

/// Una porta dell'identita' che fa entrare, come fa quella vera dopo AX.01.
class _PortaCheEntra implements PortaDellIdentita {
  bool _dentro = false;

  @override
  String? get uid => _dentro ? 'chi-torna' : 'anonimo';

  @override
  bool get anonimo => !_dentro;

  @override
  String? get email => _dentro ? 'mauro@esempio.it' : null;

  @override
  List<String> get fornitori => _dentro ? const ['google.com'] : const [];

  @override
  IdentitaRiconosciuta? get riconosciuta => null;

  @override
  Future<String?> assicuraUnAccount() async => uid;

  @override
  Future<void> ricarica() async {}

  @override
  Future<EsitoDellaCustodia> eleva(ViaDellaCustodia via,
          {String? email, String? parola}) async =>
      EsitoDellaCustodia.riuscita;

  @override
  Future<EsitoDellaCustodia> entraDirettamente(ViaDellaCustodia via,
      {String? email, String? parola}) async {
    _dentro = true;
    return EsitoDellaCustodia.riuscita;
  }

  @override
  Future<EsitoDellaCustodia> entraComeRiconosciuto() async =>
      EsitoDellaCustodia.riuscita;

  @override
  Future<String?> nomeGiaProposto() async => null;

  @override
  Future<void> esci() async => _dentro = false;

  @override
  bool? get emailVerificata => null;

  @override
  Future<EsitoDellaCustodia> mandaLaViaPerLaParola(String email) async =>
      EsitoDellaCustodia.riuscita;

  @override
  Future<EsitoDellaCustodia> mandaLaVerificaDellEmail() async =>
      EsitoDellaCustodia.riuscita;

  @override
  Future<EsitoDellaCustodia> cambiaLaParola(String nuova) async =>
      EsitoDellaCustodia.riuscita;
}
