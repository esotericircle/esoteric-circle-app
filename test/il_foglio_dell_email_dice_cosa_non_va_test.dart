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
///
/// **LA PAROLA NON C'E' PIU'. Ordine EA voce 19, 20 settembre 2026.** Il
/// fondatore ha scelto il link: si scrive l'indirizzo, arriva un messaggio,
/// si tocca e si e' dentro. Con la parola sono uscite le prove che la
/// misuravano, e con loro la via per la parola persa, che senza parole non
/// ha piu' niente da recuperare. **Resta intera la legge di questo foglio**,
/// che e' la ragione per cui esiste: un pulsante che si tocca deve fare
/// qualcosa o dire perche' no.
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

  testWidgets('a indirizzo vuoto il foglio dice cosa manca, invece di tacere',
      (tester) async {
    final porta = _PortaCheSegna();
    await apriIlFoglio(tester, porta);
    expect(find.byKey(const Key('custodia_email_form')), findsOneWidget);
    await tester.tap(find.byKey(const Key('custodia_email_conferma')));
    await tester.pumpAndSettle();
    final detto = erroreDi(tester, 'custodia_email_campo');
    // ignore: avoid_print
    print('ORDINE EA VOCE 19, a vuoto: "$detto"');
    expect(detto, isNotNull,
        reason: 'il foglio tace: si tocca e non succede niente');
    expect(detto!.toLowerCase(), contains('indirizzo'));
    expect(find.byKey(const Key('custodia_email_form')), findsOneWidget,
        reason: 'il foglio si e\' chiuso su un indirizzo che non c\'e\'');
  });

  testWidgets('a indirizzo storto lo dice, e dice cosa manca', (tester) async {
    final porta = _PortaCheSegna();
    await apriIlFoglio(tester, porta);
    await tester.enterText(
        find.byKey(const Key('custodia_email_campo')), 'mauro-esempio.it');
    await tester.tap(find.byKey(const Key('custodia_email_conferma')));
    await tester.pumpAndSettle();
    final detto = erroreDi(tester, 'custodia_email_campo');
    // ignore: avoid_print
    print('ORDINE EA VOCE 19, storto: "$detto"');
    expect(detto, isNotNull);
    expect(detto!.toLowerCase(), contains('chiocciola'),
        reason: 'si dice cosa manca, non "non valido"');
  });

  testWidgets('con l\'indirizzo giusto il foglio chiede il link',
      (tester) async {
    // **E NON CUSTODISCE ADESSO. Ordine EA voce 19**: col link non c'e'
    // niente da collegare finche' la persona non lo tocca. Prima qui si
    // pretendeva un'elevazione immediata, che era la legge di allora.
    final porta = _PortaCheSegna();
    await apriIlFoglio(tester, porta);
    await tester.enterText(
        find.byKey(const Key('custodia_email_campo')), 'mauro@esempio.it');
    await tester.tap(find.byKey(const Key('custodia_email_conferma')));
    await tester.pumpAndSettle();
    // ignore: avoid_print
    print('ORDINE EA VOCE 19: link chiesti ${porta.linkMandati}, '
        'elevazioni ${porta.elevazioni}');
    expect(find.byKey(const Key('custodia_email_form')), findsNothing,
        reason: 'il foglio resta aperto su un indirizzo giusto');
    expect(porta.linkMandati, ['mauro@esempio.it'],
        reason: 'il link non e\' stato chiesto per quell\'indirizzo');
    expect(porta.elevazioni, 0,
        reason: 'si e\' provato a collegare un\'identita\' che nessuno ha '
            'ancora dimostrato di avere');
  });

  testWidgets('e a video si dice che il link e\' partito', (tester) async {
    final porta = _PortaCheSegna();
    await apriIlFoglio(tester, porta);
    await tester.enterText(
        find.byKey(const Key('custodia_email_campo')), 'mauro@esempio.it');
    await tester.tap(find.byKey(const Key('custodia_email_conferma')));
    await tester.pumpAndSettle();
    final riga = find.byKey(const Key('link_mandato'));
    expect(riga, findsOneWidget,
        reason: 'la persona tocca, non succede niente a schermo, e va a '
            'cercare un messaggio che non sa se esiste');
    expect(tester.widget<Text>(riga).data, contains('mauro@esempio.it'),
        reason: 'non si dice a quale indirizzo e\' partito');
  });
}

/// Una porta che segna cosa le viene chiesto.
class _PortaCheSegna implements PortaDellIdentita {
  // Ordine CI voce 07: il sostituto la data di nascita dell'account non la conosce.
  @override
  DateTime? get natoIl => null;

  /// Gli indirizzi a cui il link e' stato chiesto. Ordine EA voce 19.
  final List<String> linkMandati = [];
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

  // **I TRE DEL LINK D'INGRESSO. Ordine EA voce 19.** Questo finto non manda
  // messaggi e non riceve link: risponde di no, che e' la verita'.
  @override
  Future<EsitoDellaCustodia> mandaIlLinkDIngresso(String email) async {
    linkMandati.add(email);
    return EsitoDellaCustodia.riuscita;
  }

  @override
  bool eUnLinkDIngresso(String link) => false;

  @override
  Future<EsitoDellaCustodia> entraColLink(
          {required String link, required String email}) async =>
      EsitoDellaCustodia.nonRiuscita;
}
