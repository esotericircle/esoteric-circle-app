import 'dart:async';
import 'dart:io';

import 'package:esoteric_circle/core/identity/account_del_cerchio.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/account/account_screen.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// IL MENU' ACCOUNT NON HA VOCI MORTE. Ordine AL voce 06.
///
/// Tre pretese. Le voci in arrivo, Notifiche e Privacy, al tocco rispondono
/// con l'anticipo elegante del Santuario e con parole LORO, mai il silenzio
/// ne' una frase qualunque. Custodisci il tuo cielo risponde SEMPRE: prima
/// c'era un'attesa nuda su quantiMomenti, sei letture di rete in fila senza
/// tetto, e sul telefono "al tocco non succedeva nulla"; ora due secondi di
/// tetto e poi il foglio si apre comunque, col guasto registrato invece che
/// inghiottito. E per costruzione: ogni voce del menu' o ha un'azione o ha
/// il suo anticipo, la terza possibilita' non esiste.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> monta(WidgetTester tester, {AppServices? servizi}) async {
    SharedPreferences.setMockInitialValues(const {});
    final account = AccountDelCerchio(porta: _PortaIdentitaFinta());
    account.rileggi();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<AccountDelCerchio>.value(value: account),
        ChangeNotifierProvider(create: (_) => MaestroController()),
        Provider<AppServices>.value(value: servizi ?? AppServices.offline()),
      ],
      child: MaterialApp(
        // Il pavimento di AL.04 sopra il Navigator, come nell'app vera: i
        // fogli dal basso vivono la' e senza scope morirebbero.
        builder: (ctx, child) => MaestroScope(child: child!),
        home: MaestroScope(
            maestro: Maestro.medora, child: const AccountScreen()),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 200));
  }

  testWidgets('Privacy risponde con l\'anticipo del Santuario',
      (tester) async {
    // **NOTIFICHE NON E' PIU' QUI, e non e' una perdita.** Ordine BB voce 10:
    // era una voce in arrivo che al tocco raccontava cosa sarebbe arrivato, e
    // il fondatore ha misurato che il pulsante non fa nulla. **Aveva ragione:
    // non era rotta, non esisteva.**
    //
    // Adesso quella voce chiede il permesso e programma davvero le chiamate,
    // quindi non risponde piu' con un anticipo: **risponde facendo**. Il suo
    // comportamento si sorveglia in
    // `test/nessun_invito_a_un_permesso_e_muto_test.dart`, insieme a tutti
    // gli altri punti dell'app che chiedono un permesso.
    //
    // **Privacy resta un anticipo e resta sorvegliata qui**: quella non e'
    // ancora stata fatta, e finche' e' cosi' deve almeno parlare.
    await monta(tester);
    // **LA VOCE VA CERCATA SCORRENDO.** La lista dell'account e' pigra: le
    // voci sotto la piega non vengono nemmeno costruite, e prima questa prova
    // le raggiungeva **per caso**, perche' il tocco su Notifiche apriva un
    // foglio e chiudendolo la lista si era mossa. Tolta quella voce, il caso
    // e' finito.
    await tester.scrollUntilVisible(
      find.byKey(const Key('account_privacy')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('account_privacy')));
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    expect(find.textContaining('i tuoi consensi'), findsOneWidget,
        reason: 'il tocco su Privacy non risponde con l\'anticipo suo');
  });

  testWidgets('la custodia risponde anche quando la memoria non risponde',
      (tester) async {
    // La memoria MUTA: quantiMomenti non completa mai, come una rete che
    // tiene la linea aperta e non dice niente. E' il caso del telefono.
    await monta(
      tester,
      servizi: AppServices(
        ai: const UnavailableMaestroAiProvider(),
        memory: _MemoriaMuta(),
        memoryPersistent: false,
      ),
    );
    // La lista e' pigra e la voce sta sotto la piega: si scorre fino a lei.
    await tester.scrollUntilVisible(
        find.byKey(const Key('account_custodia')), 120,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.byKey(const Key('account_custodia')),
        warnIfMissed: false);
    // Oltre il tetto dei due secondi: il foglio DEVE esserci comunque.
    for (var i = 0; i < 25; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    expect(find.byKey(const Key('invito_a_custodire')), findsOneWidget,
        reason: 'con la memoria muta il tocco sulla custodia non apre '
            'niente: e\' il "non succede nulla" della 2179');
  });

  test('ogni voce del menu\' ha un\'azione oppure il suo anticipo', () {
    final sorgente = File('lib/features/account/account_screen.dart')
        .readAsStringSync();
    final morte = <String>[];
    var osservate = 0;
    for (final m in RegExp(r'_AccountEntry\(').allMatches(sorgente)) {
      var i = m.end - 1;
      var tonde = 0;
      final da = i;
      while (i < sorgente.length) {
        if (sorgente[i] == '(') tonde++;
        if (sorgente[i] == ')') {
          tonde--;
          if (tonde == 0) break;
        }
        i++;
      }
      final blocco = sorgente.substring(da, i);
      if (!blocco.contains('required this.id')) osservate++;
      if (!blocco.contains('required this.id') &&
          !blocco.contains('onTap:') &&
          !blocco.contains('teaser:')) {
        final riga = sorgente.substring(0, m.start).split('\n').length;
        morte.add('riga $riga');
      }
    }
    // ignore: avoid_print
    print('ORDINE AL VOCE 06: voci del menu\' osservate $osservate');
    expect(osservate, greaterThanOrEqualTo(8),
        reason: 'l\'enumerazione ha perso le voci del menu\'');
    expect(morte, isEmpty,
        reason: 'queste voci non hanno ne\' azione ne\' anticipo: '
            '${morte.join(", ")}');
  });
}

class _PortaIdentitaFinta implements PortaDellIdentita {
  @override
  Future<EsitoDellaCustodia> entraDirettamente(
    ViaDellaCustodia via, {
    String? email,
    String? parola,
  }) async =>
      EsitoDellaCustodia.nonRiuscita;

  @override
  String? get uid => 'uid-di-prova';

  @override
  bool get anonimo => true;

  @override
  String? get email => null;

  @override
  List<String> get fornitori => const [];

  @override
  Future<String?> assicuraUnAccount() async => uid;

  @override
  Future<void> ricarica() async {}

  @override
  Future<EsitoDellaCustodia> eleva(
    ViaDellaCustodia via, {
    String? email,
    String? parola,
  }) async =>
      EsitoDellaCustodia.nonRiuscita;

  @override
  IdentitaRiconosciuta? get riconosciuta => null;

  @override
  Future<EsitoDellaCustodia> entraComeRiconosciuto() async =>
      EsitoDellaCustodia.nonRiuscita;

  @override
  Future<String?> nomeGiaProposto() async => null;

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
}

class _MemoriaMuta extends InMemoryMaestroMemoryRepository {
  @override
  Future<int> quantiMomenti() => Completer<int>().future;
}
