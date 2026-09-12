import 'dart:io';

import 'package:esoteric_circle/core/identity/account_del_cerchio.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/account/account_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// IL CAMBIO DELL'EMAIL DAL MENU' UTENTE. Ordine CB voce 03.
///
/// **La premessa dell'ordine era vera a meta'.** Diceva che dal menu' utente
/// non si cambiano ne' email ne' password: la password si cambiava gia'
/// (`cambia_parola`, che chiama `updatePassword`), l'email no. In tutto il
/// codice non esisteva nessun `updateEmail` ne' `verifyBeforeUpdateEmail`.
///
/// **Cosa difende questa prova**: che la voce ci sia e solo per chi puo'
/// usarla, che l'indirizzo scritto male non parta, che l'operazione passi
/// dalla VERIFICA e non dalla scrittura secca, e che ognuno dei tre guai abbia
/// la sua frase.
void main() {
  Future<_PortaFinta> montaLAccount(WidgetTester tester,
      {String? email = 'mauro@esempio.it',
      List<String> fornitori = const ['password'],
      EsitoDellaCustodia esito = EsitoDellaCustodia.riuscita}) async {
    SharedPreferences.setMockInitialValues(const {});
    final porta = _PortaFinta(email: email, vie: fornitori, esito: esito);
    tester.view.physicalSize = const Size(1080, 7200);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider<AccountDelCerchio>(
          create: (_) => AccountDelCerchio(porta: porta)..rileggi(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (ctx, child) => MaestroScope(child: child!),
        home: const AccountScreen(),
      ),
    ));
    await tester.pump();
    return porta;
  }

  Future<void> apriIlFoglio(WidgetTester tester) async {
    await tester.tap(find.text('Cambia la tua email'));
    await tester.pumpAndSettle();
  }

  testWidgets('la voce c\'e\' per chi entra con email e parola',
      (tester) async {
    await montaLAccount(tester);
    expect(find.text('Cambia la tua email'), findsOneWidget);
  });

  testWidgets('a chi entra con Google non si offre, e la ragione e\' vera',
      (tester) async {
    // L'indirizzo di chi entra con Google lo governa Google: cambiarlo qui
    // spaccherebbe in due l'identita' della stessa persona.
    await montaLAccount(tester, fornitori: const ['google.com']);
    // ignore: avoid_print
    print('ORDINE CB VOCE 03: con Google la voce del cambio email compare '
        '${find.text('Cambia la tua email').evaluate().length} volte');
    expect(find.text('Cambia la tua email'), findsNothing);
  });

  testWidgets('un indirizzo scritto male non parte', (tester) async {
    final porta = await montaLAccount(tester);
    await apriIlFoglio(tester);
    await tester.enterText(
        find.byKey(const Key('email_nuova_campo')), 'mauro-senza-chiocciola');
    await tester.tap(find.byKey(const Key('email_nuova_conferma')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('email_nuova_form')), findsOneWidget,
        reason: 'il foglio si e\' chiuso su un indirizzo incompleto');
    expect(porta.chiesti, isEmpty,
        reason: 'e\' partita una richiesta con un indirizzo che non e\' un '
            'indirizzo');
    expect(find.textContaining('non sembra completo'), findsOneWidget);
  });

  testWidgets('la propria email di adesso non e\' un cambio', (tester) async {
    final porta = await montaLAccount(tester);
    await apriIlFoglio(tester);
    await tester.enterText(
        find.byKey(const Key('email_nuova_campo')), 'MAURO@esempio.it');
    await tester.tap(find.byKey(const Key('email_nuova_conferma')));
    await tester.pumpAndSettle();
    expect(porta.chiesti, isEmpty,
        reason: 'si e\' mandata una verifica per lasciare tutto com\'era');
    expect(find.textContaining('è già la tua email'), findsOneWidget);
  });

  testWidgets('un indirizzo buono parte, e si dice cosa succede adesso',
      (tester) async {
    final porta = await montaLAccount(tester);
    await apriIlFoglio(tester);
    await tester.enterText(
        find.byKey(const Key('email_nuova_campo')), 'nuova@esempio.it');
    await tester.tap(find.byKey(const Key('email_nuova_conferma')));
    await tester.pumpAndSettle();
    // ignore: avoid_print
    print('ORDINE CB VOCE 03: indirizzi chiesti alla porta ${porta.chiesti}');
    expect(porta.chiesti, ['nuova@esempio.it']);
    expect(find.textContaining('Apri quel messaggio'), findsOneWidget,
        reason: 'non si dice che il cambio non e\' ancora avvenuto');
  });

  testWidgets('i tre guai hanno tre frasi diverse', (tester) async {
    const casi = <EsitoDellaCustodia, String>{
      EsitoDellaCustodia.nonRiconosciuto:
          'Per cambiare email serve un accesso recente',
      EsitoDellaCustodia.giaDiUnAltroCerchio: 'un altro Cerchio',
      EsitoDellaCustodia.nonRiuscita: 'Non è riuscito adesso',
    };
    for (final caso in casi.entries) {
      // **SI SMONTA PRIMA DI RIMONTARE, e non e\' pignoleria.** Rimontando
      // sopra, il messaggero dei fondo schermata resta lo STESSO oggetto e
      // tiene in coda il messaggio del giro prima: il secondo caso leggeva
      // ancora la frase del primo, e la prova diceva il falso su una cosa
      // vera.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await montaLAccount(tester, esito: caso.key);
      await apriIlFoglio(tester);
      await tester.enterText(
          find.byKey(const Key('email_nuova_campo')), 'nuova@esempio.it');
      await tester.tap(find.byKey(const Key('email_nuova_conferma')));
      await tester.pumpAndSettle();
      // Si cerca la frase INTERA del messaggio, non un pezzo: "accesso
      // recente" compare anche nel sottotitolo della voce del cambio parola,
      // e un pezzo troppo corto trova due cose e non dice niente.
      expect(find.textContaining(caso.value), findsOneWidget,
          reason: 'per ${caso.key.name} non si legge "${caso.value}"');
    }
  });

  test('si passa dalla verifica, non dalla scrittura secca', () {
    // **LA DIFFERENZA NON E' FORMALE.** `updateEmail` sposta l'account su un
    // indirizzo qualunque, anche su uno sbagliato di una lettera: da quel
    // momento nessuno entra piu' e nessuno recupera piu' la parola.
    // `verifyBeforeUpdateEmail` scrive PRIMA al nuovo indirizzo e cambia solo
    // quando quel messaggio viene aperto.
    final sorgente =
        File('lib/core/identity/account_del_cerchio.dart').readAsStringSync();
    expect(sorgente.contains('verifyBeforeUpdateEmail'), isTrue,
        reason: 'il cambio email non passa dalla verifica');
    expect(sorgente.contains('utente.updateEmail('), isFalse,
        reason: 'si scrive l\'email nuova senza verificarla: un errore di '
            'battitura porta via il Cerchio a chi lo fa');
  });

  test('il cancello dell\'email e\' uno solo', () {
    // Copiare la regola in due schermate fa due regole che il giorno dopo
    // dicono cose diverse.
    final custodia =
        File('lib/features/account/custodia_del_cielo.dart').readAsStringSync();
    final menu =
        File('lib/features/account/account_screen.dart').readAsStringSync();
    expect(custodia.contains('String? guaioDellEmail(String email)'), isTrue,
        reason: 'il cancello dell\'email non e\' una funzione sola');
    expect(menu.contains('guaioDellEmail('), isTrue,
        reason: 'il menu\' non chiama il cancello comune');
  });
}

/// Una porta che dice sempre lo stesso esito, e ricorda cosa le hanno chiesto.
class _PortaFinta implements PortaDellIdentita {
  // Ordine CI voce 07: il sostituto la data di nascita dell'account non la conosce.
  @override
  DateTime? get natoIl => null;

  _PortaFinta({this.email, required this.vie, required this.esito});

  @override
  final String? email;
  final List<String> vie;
  final EsitoDellaCustodia esito;
  final List<String> chiesti = [];

  @override
  bool get anonimo => false;

  @override
  String? get uid => 'custode';

  @override
  List<String> get fornitori => vie;

  @override
  IdentitaRiconosciuta? get riconosciuta => null;

  @override
  bool? get emailVerificata => true;

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
  Future<EsitoDellaCustodia> mandaLaViaPerLaParola(String email) async =>
      EsitoDellaCustodia.riuscita;

  @override
  Future<EsitoDellaCustodia> mandaLaVerificaDellEmail() async =>
      EsitoDellaCustodia.riuscita;

  @override
  Future<EsitoDellaCustodia> cambiaLaParola(String nuova) async =>
      EsitoDellaCustodia.riuscita;

  @override
  Future<EsitoDellaCustodia> cambiaLEmail(String nuova) async {
    chiesti.add(nuova);
    return esito;
  }
}
