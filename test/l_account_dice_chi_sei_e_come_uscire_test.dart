import 'package:esoteric_circle/core/identity/account_del_cerchio.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/account/account_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// L'ACCOUNT DICE CHI SEI, E COME USCIRE. Ordine AZ, voci 07 e 09.
///
/// **Si guarda cio' che c'e' a schermo**, non cosa fa il dominio: le prove del
/// dominio stanno in `test/si_esce_si_cancella_e_si_sa_chi_si_e_test.dart`, e
/// una cura che funzionasse solo li' sarebbe invisibile al fondatore.
void main() {
  Future<void> montaLAccount(WidgetTester tester,
      {required bool anonimo,
      String? email,
      bool? emailVerificata,
      List<String> fornitori = const ['google.com']}) async {
    SharedPreferences.setMockInitialValues(const {});
    // **UNO SCHERMO ALTO, e non e' un trucco.** La lista dell'account e'
    // pigra: le voci sotto la piega non vengono nemmeno costruite, quindi una
    // prova su schermo normale direbbe "non c'e'" di una voce che c'e'
    // eccome. Qui interessa che le voci esistano e dicano il vero; che stiano
    // a schermo su un telefono vero e' un'altra misura.
    tester.view.physicalSize = const Size(1080, 7200);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider<AccountDelCerchio>(
          create: (_) => AccountDelCerchio(
              porta: _PortaCosiComeE(
                  anonimo: anonimo,
                  email: email,
                  verificata: emailVerificata,
                  vie: fornitori))
            ..rileggi(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (ctx, child) => MaestroScope(child: child!),
        home: const AccountScreen(),
      ),
    ));
    await tester.pump();
  }

  testWidgets('chi ha custodito legge la propria email in cima',
      (tester) async {
    await montaLAccount(tester, anonimo: false, email: 'mauro@esempio.it');
    final testi = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
    // ignore: avoid_print
    print('ORDINE AZ VOCE 09: in cima si legge "${testi.take(3).join(' / ')}"');
    expect(find.text('mauro@esempio.it'), findsOneWidget,
        reason: 'in nessuna schermata dell app si legge con quale account si '
            'e entrati: chi ha scelto quello sbagliato non puo accorgersene');
    expect(find.textContaining('custodito'), findsWidgets,
        reason: 'non si dice se il cielo e custodito');
  });

  testWidgets('chi non ha custodito lo legge, invece di dedurlo',
      (tester) async {
    await montaLAccount(tester, anonimo: true);
    // ignore: avoid_print
    print('ORDINE AZ VOCE 09: da anonimo la prima riga dice "'
        '${tester.widgetList<Text>(find.byType(Text)).map((t) => t.data).where(
            (s) => s != null && s.isNotEmpty).first}"');
    expect(find.textContaining('non è ancora custodito'), findsOneWidget,
        reason: 'chi non ha custodito deve leggerlo, non dedurlo dal fatto '
            'che una certa voce ci sia o non ci sia');
  });

  testWidgets('a chi ha custodito la via per uscire c e', (tester) async {
    // **UNA SCENA SOLA PER PROVA.** Montarne due nello stesso test dava zero
    // in tutti e due i casi: il secondo montaggio non ricostruiva la lista, e
    // la prova accusava una voce che c'era.
    await montaLAccount(tester, anonimo: false, email: 'mauro@esempio.it');
    // ignore: avoid_print
    print('ORDINE AZ VOCE 07: a chi ha custodito la voce "Esci dal Cerchio" '
        'compare ${find.text('Esci dal Cerchio').evaluate().length} volte');
    expect(find.text('Esci dal Cerchio'), findsOneWidget,
        reason: 'non c e nessuna via per uscire dal proprio account: e il '
            'buco S23 del censimento');
  });

  testWidgets('a un anonimo non si offre di uscire', (tester) async {
    // Non avrebbe dove rientrare: il suo cammino non e' mai stato messo al
    // sicuro, e uscire vorrebbe dire buttarlo per sbaglio.
    await montaLAccount(tester, anonimo: true);
    // ignore: avoid_print
    print('ORDINE AZ VOCE 07: a chi e anonimo la voce compare '
        '${find.text('Esci dal Cerchio').evaluate().length} volte');
    expect(find.text('Esci dal Cerchio'), findsNothing,
        reason: 'si offre di uscire a chi non e mai entrato: butterebbe il '
            'proprio cammino senza averlo mai custodito');
  });

  testWidgets('uscire chiede conferma, e dice cosa resta', (tester) async {
    await montaLAccount(tester, anonimo: false, email: 'mauro@esempio.it');
    await tester.tap(find.text('Esci dal Cerchio'));
    await tester.pumpAndSettle();
    final avviso = find.byKey(const Key('uscita_conferma'));
    expect(avviso, findsOneWidget,
        reason: 'si esce al primo tocco, senza chiedere niente');
    // ignore: avoid_print
    print('ORDINE AZ VOCE 07: la conferma dice "'
        '${tester.widgetList<Text>(find.descendant(of: avviso, matching: find.byType(Text))).map((t) => t.data).join(' | ')}"');
    expect(
        find.descendant(
            of: avviso, matching: find.textContaining('resta custodito')),
        findsOneWidget,
        reason: 'la conferma non dice che il cammino resta: "esci" da solo '
            'suona come "perdi tutto"');
  });

  testWidgets('la promessa dell oblio nomina il telefono e il server',
      (tester) async {
    // Ordine AZ voce 08: il testo prometteva "qui e sul server" mentre il
    // "qui" non veniva toccato. Adesso viene toccato, e la riga finale lo
    // dice tutte e due le volte.
    await montaLAccount(tester, anonimo: false, email: 'mauro@esempio.it');
    // **BH.06**: la voce dell'oblio vive nel sottomenu Privacy e dati, in
    // fondo: ci si arriva dalla porta, come fa la persona.
    await tester.tap(find.byKey(const Key('account_privacy_e_dati')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Cancella il tuo account'), findsOneWidget);
    // ignore: avoid_print
    print('ORDINE AZ VOCE 08: il sottotitolo dell oblio dice "'
        '${tester.widgetList<Text>(find.byType(Text)).map((t) => t.data).firstWhere((s) => s != null && s.contains('dimentica'), orElse: () => 'niente')}"');
    expect(find.textContaining('qui e sul server'), findsWidgets,
        reason: 'la promessa dell oblio non nomina piu tutte e due le meta');
  });

  testWidgets('la verifica dell email compare solo a chi ne ha bisogno',
      (tester) async {
    // Ordine AZ voce 06, situazione S18. A chi entra con Google o con Apple
    // l'indirizzo lo ha gia' verificato il fornitore: chiederglielo sarebbe
    // un compito inventato.
    await montaLAccount(tester,
        anonimo: false,
        email: 'mauro@esempio.it',
        emailVerificata: false,
        fornitori: const ['password']);
    // ignore: avoid_print
    print('ORDINE AZ VOCE 06: con email non verificata la voce compare '
        '${find.text('Verifica la tua email').evaluate().length} volte');
    expect(find.text('Verifica la tua email'), findsOneWidget,
        reason: 'chi ha un email non verificata non ha modo di verificarla: e '
            'il buco S18');
  });

  testWidgets('a chi entra con Google non si chiede di verificare niente',
      (tester) async {
    await montaLAccount(tester,
        anonimo: false, email: 'mauro@esempio.it', emailVerificata: null);
    // ignore: avoid_print
    print('ORDINE AZ VOCE 06: con Google la voce compare '
        '${find.text('Verifica la tua email').evaluate().length} volte');
    expect(find.text('Verifica la tua email'), findsNothing,
        reason: 'si chiede di verificare un indirizzo che ha gia verificato '
            'il fornitore');
  });

  testWidgets('il cambio della parola c e solo per chi ha una parola',
      (tester) async {
    await montaLAccount(tester,
        anonimo: false,
        email: 'mauro@esempio.it',
        emailVerificata: true,
        fornitori: const ['password']);
    // ignore: avoid_print
    print('ORDINE AZ VOCE 12: con la via email la voce del cambio compare '
        "${find.text('Cambia la Password').evaluate().length} volte");
    expect(find.text('Cambia la Password'), findsOneWidget,
        reason: 'non c e nessun modo di cambiare la parola: e il buco S20');
  });

  testWidgets('a chi entra con Google non si offre di cambiare una parola che '
      'non ha', (tester) async {
    await montaLAccount(tester, anonimo: false, email: 'mauro@esempio.it');
    // ignore: avoid_print
    print('ORDINE AZ VOCE 12: con Google la voce del cambio compare '
        "${find.text('Cambia la Password').evaluate().length} volte");
    expect(find.text('Cambia la Password'), findsNothing,
        reason: 'si offre di cambiare una parola che non esiste');
  });
}

/// Una porta ferma nello stato che la prova le chiede.
class _PortaCosiComeE implements PortaDellIdentita {
  _PortaCosiComeE({
    required this.anonimo,
    this.email,
    this.verificata,
    this.vie = const ['google.com'],
  });

  final bool? verificata;
  final List<String> vie;
  int verificheMandate = 0;

  @override
  final bool anonimo;

  @override
  final String? email;

  @override
  String? get uid => anonimo ? 'anonimo' : 'custode';

  @override
  List<String> get fornitori => anonimo ? const [] : vie;

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
  bool? get emailVerificata => verificata;

  @override
  Future<EsitoDellaCustodia> mandaLaViaPerLaParola(String email) async =>
      EsitoDellaCustodia.riuscita;

  @override
  Future<EsitoDellaCustodia> mandaLaVerificaDellEmail() async {
    verificheMandate++;
    return EsitoDellaCustodia.riuscita;
  }

  @override
  Future<EsitoDellaCustodia> cambiaLaParola(String nuova) async =>
      EsitoDellaCustodia.riuscita;

  @override
  Future<EsitoDellaCustodia> cambiaLEmail(String nuova) async =>
      EsitoDellaCustodia.nonRiuscita;
}
