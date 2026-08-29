import 'package:esoteric_circle/core/identity/account_del_cerchio.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/account/custodia_del_cielo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// IL FOGLIO DELL'EMAIL DICE COSA NON VA. Ordine AZ, voci 05 e 10.
/// Situazioni S14 e S21 del censimento.
///
/// **Il foglio era muto.** Il pulsante "Custodisci" faceva
/// `if (!a.contains('@') || b.length < 6) return;`: **si toccava e non
/// succedeva niente**. Chi sbagliava una lettera nell'indirizzo, o sceglieva
/// una parola di cinque caratteri, restava fermo davanti a un pulsante che
/// non rispondeva, senza sapere cosa correggere. Un vicolo cieco muto in
/// mezzo alla registrazione.
///
/// **E la parola persa non esisteva.** Zero `sendPasswordResetEmail` in tutto
/// `lib/`: chi si era custodito con un'email e aveva dimenticato la parola
/// **era fuori dal proprio Cerchio per sempre**.
void main() {
  Future<void> apriIlFoglio(WidgetTester tester, _PortaCheSegna porta) async {
    final chiave = GlobalKey();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider<AccountDelCerchio>(
          create: (_) => AccountDelCerchio(porta: porta),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (ctx, child) => MaestroScope(child: child!),
        home: Scaffold(body: SizedBox(key: chiave)),
      ),
    ));
    mostraInvitoACustodire(chiave.currentContext!, momenti: 3);
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    await tester.tap(find.byKey(const Key('custodia_email')),
        warnIfMissed: false);
    await tester.pumpAndSettle();
  }

  String? erroreDi(WidgetTester tester, String chiave) =>
      tester.widget<TextField>(find.byKey(Key(chiave))).decoration?.errorText;

  testWidgets('a campi vuoti il foglio dice cosa manca, invece di tacere',
      (tester) async {
    await apriIlFoglio(tester, _PortaCheSegna());
    expect(find.byKey(const Key('custodia_email_form')), findsOneWidget);

    await tester.tap(find.byKey(const Key('custodia_email_conferma')));
    await tester.pump();

    final email = erroreDi(tester, 'custodia_email_campo');
    final parola = erroreDi(tester, 'custodia_parola_campo');
    // ignore: avoid_print
    print('ORDINE AZ VOCE 10: a campi vuoti si legge "$email" e "$parola"');

    expect(email, isNotNull,
        reason: 'il foglio tace su un indirizzo mancante: e il pulsante che '
            'non risponde');
    expect(parola, isNotNull, reason: 'il foglio tace su una parola mancante');
    // **E LA FINESTRA NON SI CHIUDE**: chiudersi senza aver custodito niente
    // sarebbe un altro modo di tacere.
    expect(find.byKey(const Key('custodia_email_form')), findsOneWidget);
  });

  testWidgets('a indirizzo storto lo dice, e dice cosa manca', (tester) async {
    await apriIlFoglio(tester, _PortaCheSegna());
    await tester.enterText(
        find.byKey(const Key('custodia_email_campo')), 'mauro-esempio.it');
    await tester.enterText(
        find.byKey(const Key('custodia_parola_campo')), 'unaparolalunga');
    await tester.tap(find.byKey(const Key('custodia_email_conferma')));
    await tester.pump();
    final email = erroreDi(tester, 'custodia_email_campo');
    // ignore: avoid_print
    print('ORDINE AZ VOCE 10: a indirizzo storto si legge "$email"');
    expect(email, isNotNull);
    expect(email, contains('chiocciola'),
        reason: 'si dice che qualcosa non va senza dire cosa: la persona non '
            'sa dove guardare');
  });

  testWidgets('a parola corta dice QUANTO manca', (tester) async {
    await apriIlFoglio(tester, _PortaCheSegna());
    await tester.enterText(
        find.byKey(const Key('custodia_email_campo')), 'mauro@esempio.it');
    await tester.enterText(find.byKey(const Key('custodia_parola_campo')), 'abc');
    await tester.tap(find.byKey(const Key('custodia_email_conferma')));
    await tester.pump();
    final parola = erroreDi(tester, 'custodia_parola_campo');
    // ignore: avoid_print
    print('ORDINE AZ VOCE 10: con tre caratteri si legge "$parola"');
    // **BI.02**: la regola del fondatore parte dagli otto caratteri, e con
    // tre ne mancano cinque: il guaio dice sempre QUANTO manca.
    expect(parola, contains('5'),
        reason: 'non si dice quanti caratteri mancano: "troppo corta" fa '
            'provare a caso');
  });

  testWidgets('coi campi giusti il foglio si chiude e custodisce',
      (tester) async {
    // **LA CONTROPROVA.** Un foglio che si lamenta sempre sarebbe peggio di
    // uno muto.
    final porta = _PortaCheSegna();
    await apriIlFoglio(tester, porta);
    await tester.enterText(
        find.byKey(const Key('custodia_email_campo')), 'mauro@esempio.it');
    // **BI.02**: la password buona rispetta la regola del fondatore
    // (otto caratteri, maiuscola, numero, carattere speciale).
    await tester.enterText(
        find.byKey(const Key('custodia_parola_campo')), 'Parola1!buona');
    await tester.tap(find.byKey(const Key('custodia_email_conferma')));
    await tester.pumpAndSettle();
    // ignore: avoid_print
    print('ORDINE AZ VOCE 10: coi campi giusti il foglio e ancora a schermo '
        '${find.byKey(const Key('custodia_email_form')).evaluate().length} '
        'volte, elevazioni ${porta.elevazioni}');
    expect(find.byKey(const Key('custodia_email_form')), findsNothing,
        reason: 'con dati validi il foglio resta aperto: si lamenta sempre');
    expect(porta.elevazioni, 1,
        reason: 'con dati validi non si custodisce niente');
  });

  testWidgets('la parola persa c e, e non rivela chi fa parte del Cerchio',
      (tester) async {
    final porta = _PortaCheSegna();
    await apriIlFoglio(tester, porta);
    expect(find.byKey(const Key('custodia_parola_persa')), findsOneWidget,
        reason: 'non c e nessuna via per chi ha perso la parola: e il buco '
            'S14 del censimento');

    await tester.enterText(
        find.byKey(const Key('custodia_email_campo')), 'mauro@esempio.it');
    await tester.tap(find.byKey(const Key('custodia_parola_persa')));
    await tester.pumpAndSettle();

    final detto = tester
        .widget<Text>(find.byKey(const Key('custodia_parola_persa_detto')))
        .data;
    // ignore: avoid_print
    print('ORDINE AZ VOCE 05: vie chieste ${porta.viePerLaParola}, si legge '
        '"$detto"');

    expect(porta.viePerLaParola, ['mauro@esempio.it'],
        reason: 'il tocco non chiede nessuna via per rifare la parola');
    // **NON SI DICE SE QUELL'EMAIL ESISTE**, e non e' pigrizia: dirlo
    // regalerebbe a chiunque un modo per sapere chi fa parte del Cerchio.
    expect(detto, contains('Se'),
        reason: 'la frase afferma che l email esiste: e un modo per scoprire '
            'chi fa parte del Cerchio provando indirizzi altrui');
  });

  testWidgets('la parola persa senza email dice dove scriverla',
      (tester) async {
    final porta = _PortaCheSegna();
    await apriIlFoglio(tester, porta);
    await tester.tap(find.byKey(const Key('custodia_parola_persa')));
    await tester.pumpAndSettle();
    // ignore: avoid_print
    print('ORDINE AZ VOCE 05: senza email si legge "'
        '${erroreDi(tester, 'custodia_email_campo')}", vie chieste '
        '${porta.viePerLaParola.length}');
    expect(erroreDi(tester, 'custodia_email_campo'), isNotNull,
        reason: 'il tocco non dice niente a chi non ha ancora scritto l email');
    expect(porta.viePerLaParola, isEmpty,
        reason: 'si e chiesta una via per un indirizzo che non esiste');
  });
}

/// Una porta che segna cosa le viene chiesto.
class _PortaCheSegna implements PortaDellIdentita {
  final List<String> viePerLaParola = [];
  int elevazioni = 0;

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
  Future<String?> assicuraUnAccount() async => uid;

  @override
  Future<void> ricarica() async {}

  @override
  Future<EsitoDellaCustodia> eleva(ViaDellaCustodia via,
      {String? email, String? parola}) async {
    elevazioni++;
    return EsitoDellaCustodia.riuscita;
  }

  @override
  Future<EsitoDellaCustodia> entraDirettamente(ViaDellaCustodia via,
          {String? email, String? parola}) async =>
      EsitoDellaCustodia.riuscita;

  @override
  Future<EsitoDellaCustodia> entraComeRiconosciuto() async =>
      EsitoDellaCustodia.riuscita;

  @override
  Future<String?> nomeGiaProposto() async => null;

  @override
  Future<void> esci() async {}

  @override
  bool? get emailVerificata => null;

  @override
  Future<EsitoDellaCustodia> mandaLaViaPerLaParola(String email) async {
    viePerLaParola.add(email);
    return EsitoDellaCustodia.riuscita;
  }

  @override
  Future<EsitoDellaCustodia> mandaLaVerificaDellEmail() async =>
      EsitoDellaCustodia.riuscita;

  @override
  Future<EsitoDellaCustodia> cambiaLaParola(String nuova) async =>
      EsitoDellaCustodia.riuscita;

  @override
  Future<EsitoDellaCustodia> cambiaLEmail(String nuova) async =>
      EsitoDellaCustodia.nonRiuscita;
}
