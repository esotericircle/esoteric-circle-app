import 'dart:io';

import 'package:esoteric_circle/core/identity/account_del_cerchio.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/features/account/custodia_del_cielo.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// "CONTINUA COME [NOME]". Ordine AL voce 07.
///
/// Quando la custodia risponde che l'identita' vive gia' in un altro
/// Cerchio, la persona non finisce piu' in un vicolo: il rifiuto porta con
/// se' CHI e' stato riconosciuto, e la scena offre "Continua come [nome]"
/// con, PRIMA del tocco, la riga onesta su cosa succede al cammino di questo
/// telefono. La riga dichiara la verita' di oggi, nessuna unione esiste e
/// nessuna si promette: la vecchia frase "scrivici e uniremo i due" era una
/// promessa vuota ed e' sparita dai sorgenti, con la prova che vieta il suo
/// ritorno. Le due scene, il foglio dell'account e il passo del Risveglio,
/// usano UN componente solo.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('il rifiuto offre Continua come [nome], con la riga onesta, e '
      'il tocco entra', (tester) async {
    final porta = _PortaCheRiconosce();
    final account = AccountDelCerchio(porta: porta);
    account.rileggi();
    final chiave = GlobalKey();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<AccountDelCerchio>.value(value: account),
        ChangeNotifierProvider(create: (_) => MaestroController()),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MaestroScope(child: child!),
        home: Scaffold(body: SizedBox(key: chiave)),
      ),
    ));
    final aperto = mostraInvitoACustodire(chiave.currentContext!, momenti: 3);
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    await tester.tap(find.byKey(const Key('custodia_google')),
        warnIfMissed: false);
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    expect(find.byKey(const Key('continua_come')), findsOneWidget,
        reason: 'il Cerchio riconosciuto non offre la via in avanti: e\' il '
            'vicolo cieco della 2179');
    expect(find.textContaining('Continua come mauro@esempio.it'),
        findsOneWidget,
        reason: 'il pulsante non porta il nome riconosciuto');
    expect(find.byKey(const Key('continua_come_riga_onesta')), findsOneWidget,
        reason: 'manca la riga onesta prima del tocco');
    expect(find.textContaining('non si uniscono'), findsOneWidget,
        reason: 'la riga non dichiara la verita\' sui due Cerchi');
    // "Piu' tardi" resta.
    expect(find.byKey(const Key('invito_piu_tardi')), findsOneWidget);

    await tester.tap(find.byKey(const Key('continua_come')),
        warnIfMissed: false);
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    expect(porta.entrato, isTrue,
        reason: 'il tocco su Continua come non entra nel Cerchio');
    expect(await aperto, isTrue,
        reason: 'a ingresso riuscito il foglio deve chiudersi da vincitore');
  });

  test('nessuna promessa di unione sta nei sorgenti', () {
    final colpevoli = <String>[];
    for (final file in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      if (file.readAsStringSync().contains('uniremo')) {
        colpevoli.add(file.path);
      }
    }
    expect(colpevoli, isEmpty,
        reason: 'la promessa di un\'unione che non esiste e\' tornata: '
            '${colpevoli.join(", ")}');
  });

  test('le due scene usano lo stesso componente, non due copie', () {
    for (final percorso in const [
      'lib/features/account/custodia_del_cielo.dart',
      'lib/features/onboarding/custodia_del_cielo_step.dart',
    ]) {
      expect(
          File(percorso)
              .readAsStringSync()
              .contains('ContinuaComeRiconosciuto('),
          isTrue,
          reason: '$percorso non usa il componente unico: alla prima modifica '
              'le due promesse divergono');
    }
  });
}

class _PortaCheRiconosce implements PortaDellIdentita {
  bool entrato = false;
  bool _anonimo = true;
  IdentitaRiconosciuta? _riconosciuta;

  @override
  String? get uid => entrato ? 'uid-riconosciuto' : 'uid-anonimo';

  @override
  bool get anonimo => _anonimo;

  @override
  String? get email => entrato ? 'mauro@esempio.it' : null;

  @override
  List<String> get fornitori => const [];

  @override
  Future<String?> assicuraUnAccount() async => uid;

  @override
  Future<void> ricarica() async {}

  @override
  IdentitaRiconosciuta? get riconosciuta => _riconosciuta;

  @override
  Future<EsitoDellaCustodia> eleva(
    ViaDellaCustodia via, {
    String? email,
    String? parola,
  }) async {
    _riconosciuta = const IdentitaRiconosciuta(
        nome: 'mauro@esempio.it', credenziale: null);
    return EsitoDellaCustodia.giaDiUnAltroCerchio;
  }

  @override
  Future<EsitoDellaCustodia> entraComeRiconosciuto() async {
    if (_riconosciuta == null) return EsitoDellaCustodia.nonRiuscita;
    entrato = true;
    _anonimo = false;
    _riconosciuta = null;
    return EsitoDellaCustodia.riuscita;
  }
}
