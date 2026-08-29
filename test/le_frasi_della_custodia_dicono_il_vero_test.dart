import 'dart:io';

import 'package:esoteric_circle/core/identity/account_del_cerchio.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/onboarding/onboarding_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/account/custodia_del_cielo.dart';
import 'package:esoteric_circle/features/onboarding/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LE FRASI DELLA CUSTODIA DICONO IL VERO. Ordine AP voce 08.
///
/// **Il difetto piu' grave dell'ordine AP non era una schermata, era una
/// frase.** La voce della custodia prometteva "se cambi telefono non perdi
/// nulla" mentre i traguardi accesi si perdevano davvero, e Mauro lo ha
/// misurato reinstallando l'app sulla 2183. Una promessa falsa detta nel
/// momento esatto in cui si chiede fiducia costa piu' di qualunque bug.
///
/// **Perche' queste prove legano la frase al codice invece di fissarla.**
/// Fissare il testo direbbe solo "la frase e' questa", e resterebbe verde il
/// giorno in cui il sistema cambia e la frase resta indietro: e' esattamente
/// cio' che e' successo. Qui invece ogni pretesa ha dietro un fatto del
/// codice: cio' che il Cerchio custodisce, e cio' che la fusione fa.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('la promessa nomina i traguardi, perche\' ora tornano davvero', () {
    // I traguardi accesi sono la cosa che si perdeva. Da quando il cammino e'
    // custodito (voci 01 e 03), la promessa puo' nominarli, e deve: e' cio'
    // che una persona riconosce come suo.
    final voce = File('lib/features/account/account_screen.dart')
        .readAsStringSync()
        .split('\n')
        .where((r) => !r.trimLeft().startsWith('//'))
        .join('\n');
    final inizio = voce.indexOf("id: 'custodia'");
    expect(inizio, greaterThan(0),
        reason: 'la voce della custodia non si trova piu\'');
    final pezzo = voce.substring(inizio, inizio + 400).toLowerCase();
    // ignore: avoid_print
    print('ORDINE AP VOCE 08: la voce della custodia promette "$pezzo"');
    expect(pezzo, contains('traguardi'),
        reason: 'la promessa non nomina i traguardi accesi, che sono la cosa '
            'che si perdeva e che adesso torna');
    expect(pezzo.contains('sigilli') || pezzo.contains('traguardi'), isTrue);
  });

  testWidgets('la riga onesta non nega piu\' un\'unione che ora avviene',
      (tester) async {
    // **IL FATTO DEL CODICE CHE COMANDA QUESTA PRETESA.** Se sul server
    // esiste `fondiCammini`, allora entrare in un altro Cerchio FONDE il
    // cammino di questo telefono, e nessuna frase puo' dire il contrario.
    final server = File('functions/src/cammino.ts').readAsStringSync();
    final fonde = server.contains('export function fondiCammini');
    expect(fonde, isTrue,
        reason: 'la fusione non esiste piu\' sul server: allora questa prova '
            'sta misurando un mondo che non c\'e\'');

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ContinuaComeRiconosciuto(
          account: AccountDelCerchio(porta: _PortaCheRiconosce()),
          suEsito: (_) {},
        ),
      ),
    ));
    await tester.pump();
    final riga = tester
        .widget<Text>(find.byKey(const Key('continua_come_riga_onesta')))
        .data!;
    // ignore: avoid_print
    print('ORDINE AP VOCE 08: la riga onesta dice "$riga"');
    final bassa = riga.toLowerCase();
    expect(bassa, isNot(contains('non si uniscono')),
        reason: 'la riga nega un\'unione che il server esegue davvero: '
            'promette in difetto, e in difetto o in eccesso resta una bugia');
    expect(bassa.contains('si uniscono') || bassa.contains('unisce'), isTrue,
        reason: 'la riga non dice piu\' che i passi si uniscono: "$riga"');
    // Cio' che NON si fonde va continuato a dire, altrimenti si promette in
    // eccesso: Eos e ricordi restano quelli del Cerchio in cui si entra.
    expect(bassa, contains('eos'),
        reason: 'la riga non dice piu\' cosa succede agli Eos');
    expect(bassa, contains('ricordi'),
        reason: 'la riga non dice piu\' cosa succede ai ricordi');
  });

  testWidgets('se il telefono non propone niente, non compare niente',
      (tester) async {
    // **LA MISURA CHE COMANDA LA RIGA.** Il bentornato esiste solo se il
    // telefono risponde un nome. Il silenzio e' la risposta normale, non un
    // guasto, e a un silenzio non si risponde con un saluto a nessuno.
    await _apri(tester, _PortaCheRiconosce());
    expect(find.byKey(const Key('onboarding_bentornato')), findsNothing,
        reason: 'si saluta per nome qualcuno che il telefono non ha mai '
            'nominato');
    expect(find.byKey(const Key('onboarding_porta_per_chi_torna')),
        findsOneWidget,
        reason: 'senza proposta sparisce anche la porta piccola: chi torna '
            'resterebbe senza via');
  });

  testWidgets('se il telefono propone un nome, il saluto compare e basta',
      (tester) async {
    final porta = _PortaCheRiconosce(propone: 'Mauro');
    await _apri(tester, porta);
    final saluto = find.byKey(const Key('onboarding_bentornato'));
    expect(saluto, findsOneWidget,
        reason: 'il telefono ha proposto un nome e nessuno lo saluta');
    // ignore: avoid_print
    print('ORDINE AP VOCE 08: a schermo "${tester.widget<Text>(saluto).data}"');
    // La forma di cortesia qui non e' ancora scelta: vale il neutro,
    // ordine BG voce 03.
    expect(tester.widget<Text>(saluto).data, 'Di nuovo nel Cerchio, Mauro');

    // **NESSUNO ENTRA DA SOLO.** Il saluto prende un nome, non un'identita':
    // entrare all'apertura sarebbe il muro d'accesso che Mauro ha escluso il
    // 18 agosto.
    expect(porta.entrato, isFalse,
        reason: 'il bentornato ha fatto entrare qualcuno da solo: e\' il muro '
            'd\'accesso che la decisione del 18 agosto ha escluso');

    // E le due righe della porta piccola restano quelle decise da Mauro: il
    // saluto sta sopra, non dentro.
    final righe = tester
        .widgetList<Text>(find.descendant(
            of: find.byKey(const Key('onboarding_porta_per_chi_torna')),
            matching: find.byType(Text)))
        .map((t) => t.data)
        .toList();
    expect(righe, [
      'Faccio già parte del Cerchio',
      'Accedi e ritrova il tuo cammino',
    ], reason: 'il saluto e\' entrato dentro la porta e ne ha cambiato le '
        'righe, che sono di Mauro: $righe');
  });

  test('la proposta silenziosa passa dall\'unica porta verso Google', () {
    // Una seconda classe che costruisse un `GoogleSignIn` per conto suo
    // sarebbe la seconda strada per lo stesso dato, e un giorno le due
    // direbbero cose diverse.
    final quanti = <String>[];
    for (final f in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      final codice = f
          .readAsStringSync()
          .split('\n')
          .where((r) => !r.trimLeft().startsWith('//') && !r.trimLeft().startsWith('///'))
          .join('\n');
      if (codice.contains('GoogleSignIn(')) {
        quanti.add(f.path.replaceAll('\\', '/'));
      }
    }
    // ignore: avoid_print
    print('ORDINE AP VOCE 08: chi costruisce GoogleSignIn: $quanti');
    expect(quanti, ['lib/core/identity/account_del_cerchio.dart'],
        reason: 'Google si tocca da piu\' di un posto: $quanti');
  });
}

Future<void> _apri(WidgetTester tester, _PortaCheRiconosce porta) async {
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
      ChangeNotifierProvider(create: (_) => AccountDelCerchio(porta: porta)),
    ],
    child: MaterialApp(
      builder: (ctx, child) => MaestroScope(child: child!),
      home: OnboardingScreen(clock: () => DateTime(2026, 8, 19)),
    ),
  ));
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 120));
  }
}

/// La porta finta: sa dire un nome riconosciuto e sa dire cosa il telefono
/// propone da solo. Non tocca ne' Firebase ne' Google.
class _PortaCheRiconosce implements PortaDellIdentita {
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

  @override
  Future<EsitoDellaCustodia> cambiaLEmail(String nuova) async =>
      EsitoDellaCustodia.nonRiuscita;

  @override
  Future<EsitoDellaCustodia> entraDirettamente(ViaDellaCustodia via,
          {String? email, String? parola}) async =>
      EsitoDellaCustodia.riuscita;

  _PortaCheRiconosce({this.propone});

  final String? propone;
  bool entrato = false;

  @override
  String? get uid => 'uid-di-prova';

  @override
  bool get anonimo => !entrato;

  @override
  String? get email => null;

  @override
  List<String> get fornitori => const [];

  @override
  Future<String?> assicuraUnAccount() async => uid;

  @override
  Future<void> ricarica() async {}

  @override
  IdentitaRiconosciuta? get riconosciuta =>
      const IdentitaRiconosciuta(nome: 'mauro@esempio.it', credenziale: null);

  @override
  Future<EsitoDellaCustodia> eleva(
    ViaDellaCustodia via, {
    String? email,
    String? parola,
  }) async =>
      EsitoDellaCustodia.giaDiUnAltroCerchio;

  @override
  Future<EsitoDellaCustodia> entraComeRiconosciuto() async {
    entrato = true;
    return EsitoDellaCustodia.riuscita;
  }

  @override
  Future<String?> nomeGiaProposto() async => propone;
}
