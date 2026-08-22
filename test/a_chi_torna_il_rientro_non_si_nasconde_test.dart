import 'package:esoteric_circle/core/identity/account_del_cerchio.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/onboarding/onboarding_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/onboarding/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A CHI TORNA IL RIENTRO NON SI NASCONDE. Ordine AZ voce 02, fatti F2 e F3.
///
/// **Il fatto F7 e' esatto, e non e' il difetto.** Il rito si decide su
/// `prefs.getBool('onboarding.done')` e su nient'altro: verificato riga per
/// riga. Ma al primo avvio dopo una reinstallazione **non esiste ancora
/// nessuna identita' da interrogare**, quindi non c'e' nient'altro su cui
/// decidere. Cambiare quella riga non avrebbe curato niente.
///
/// **Il difetto e' un altro.** Quando il telefono propone gia' un account,
/// l'app SA che quella persona e' con ogni probabilita' di ritorno, e le
/// metteva davanti "Inizia il rito" tenendo il rientro in una riga smorzata
/// sotto la chiamata principale. **Chi reinstalla prende la strada grande**,
/// rifa' il rito per intero, e per finirlo inventa dei dati di nascita: sono
/// esattamente i fatti F2 e F3 del fondatore, **e i dati a caso di F6 nascono
/// da li'**.
///
/// **Non si conta uno stile, si guarda il tipo del pulsante**: un richiamo
/// pieno e un `TextButton` smorzato sono due cose diverse anche a colori
/// invertiti.
void main() {
  Future<void> montaIlRisveglio(
    WidgetTester tester, {
    required String? bentornato,
  }) async {
    SharedPreferences.setMockInitialValues(const {});
    tester.view.physicalSize = const Size(1080, 2391);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => OnboardingController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => BirthIdentityController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider<AccountDelCerchio>(
          create: (_) => AccountDelCerchio(
              porta: _PortaCheProponeONo(bentornato: bentornato)),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (ctx, child) => MaestroScope(child: child!),
        home: OnboardingScreen(clock: () => DateTime(2026, 8, 22)),
      ),
    ));
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  testWidgets('senza bentornato la porta resta smorzata, come deve',
      (tester) async {
    // **LA CONTROPROVA VIENE PRIMA.** Chi arriva davvero per la prima volta
    // non deve trovarsi davanti un invito ad accedere: il richiamo e' il rito.
    await montaIlRisveglio(tester, bentornato: null);
    final porta = find.byKey(const Key('onboarding_porta_per_chi_torna'));
    expect(porta, findsOneWidget);
    final tipo = tester.widget(porta).runtimeType.toString();
    // ignore: avoid_print
    print('ORDINE AZ VOCE 02: senza bentornato la porta e un $tipo');
    expect(tester.widget(porta), isA<TextButton>(),
        reason: 'a chi arriva nuovo si sta offrendo un accesso con lo stesso '
            'risalto del rito');
  });

  testWidgets('col bentornato la porta diventa un richiamo pieno',
      (tester) async {
    await montaIlRisveglio(tester, bentornato: 'Mauro');
    final porta = find.byKey(const Key('onboarding_porta_per_chi_torna'));
    expect(porta, findsOneWidget);
    final widget = tester.widget(porta);
    // ignore: avoid_print
    print('ORDINE AZ VOCE 02: col bentornato la porta e un '
        '${widget.runtimeType}');

    expect(widget, isA<FilledButton>(),
        reason: 'il telefono propone gia un account e il rientro resta una '
            'riga smorzata sotto "Inizia il rito": chi ha reinstallato prende '
            'la strada grande e rifa il rito, ed e il fatto F2');

    // **E IL SALUTO C'E'**, se no il risalto sarebbe senza motivo a schermo.
    expect(find.byKey(const Key('onboarding_bentornato')), findsOneWidget,
        reason: 'la porta ha preso risalto ma nessuno dice perche');
  });

  testWidgets('il risalto si misura sul fondo dipinto, non sul nome',
      (tester) async {
    // **LA LARGHEZZA NON DISTINGUE NIENTE, misurato**: la colonna sotto la
    // chiamata principale e' larga 256 punti in tutti e due i casi, perche'
    // tanto la porta quanto la Cta chiedono `width: double.infinity`. La
    // prima versione di questa prova pretendeva una porta piu' larga e
    // cadeva: **cadeva con ragione**, e il criterio sbagliato era il suo.
    //
    // Il risalto vero e' il FONDO: un richiamo pieno ha una tinta dietro, una
    // riga smorzata no.
    //
    // **E si monta una scena sola per prova.** Montarne due nello stesso test
    // dava due `TextButton`: il secondo montaggio non tornava a proporre il
    // nome, e la prova misurava due volte la stessa scena senza accorgersene.
    await montaIlRisveglio(tester, bentornato: 'Mauro');
    final bottone = tester.widget<ButtonStyleButton>(
        find.byKey(const Key('onboarding_porta_per_chi_torna')));
    final fondo = bottone.style?.backgroundColor?.resolve(<WidgetState>{});
    // ignore: avoid_print
    print('ORDINE AZ VOCE 02: col bentornato il fondo della porta e $fondo');

    expect(fondo, isNotNull,
        reason: 'col bentornato la porta non ha nessun fondo dipinto: e '
            'smorzata come prima');
    expect(fondo!.a, greaterThan(0.0),
        reason: 'il fondo c e ma e trasparente, che a schermo e lo stesso che '
            'non averlo');
  });

  testWidgets('senza bentornato la porta non ha nessun fondo', (tester) async {
    await montaIlRisveglio(tester, bentornato: null);
    final bottone = tester.widget<ButtonStyleButton>(
        find.byKey(const Key('onboarding_porta_per_chi_torna')));
    final fondo = bottone.style?.backgroundColor?.resolve(<WidgetState>{});
    // ignore: avoid_print
    print('ORDINE AZ VOCE 02: senza bentornato il fondo della porta e $fondo');
    expect(fondo, isNull,
        reason: 'a chi arriva nuovo la porta si dipinge come a chi torna: il '
            'risalto perde il suo significato');
  });
}

/// Una porta che propone un nome, oppure niente.
class _PortaCheProponeONo implements PortaDellIdentita {
  @override
  Future<void> esci() async {}

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

  _PortaCheProponeONo({this.bentornato});

  final String? bentornato;

  @override
  String? get uid => 'anonimo';

  @override
  bool get anonimo => true;

  @override
  String? get email => null;

  @override
  List<String> get fornitori => const [];

  @override
  IdentitaRiconosciuta? get riconosciuta => null;

  @override
  Future<String?> assicuraUnAccount() async => 'anonimo';

  @override
  Future<void> ricarica() async {}

  @override
  Future<EsitoDellaCustodia> eleva(ViaDellaCustodia via,
          {String? email, String? parola}) async =>
      EsitoDellaCustodia.riuscita;

  @override
  Future<EsitoDellaCustodia> entraDirettamente(ViaDellaCustodia via,
          {String? email, String? parola}) async =>
      EsitoDellaCustodia.riuscita;

  @override
  Future<EsitoDellaCustodia> entraComeRiconosciuto() async =>
      EsitoDellaCustodia.riuscita;

  @override
  Future<String?> nomeGiaProposto() async => bentornato;
}
