// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/amici/amici_offline.dart';
import 'package:esoteric_circle/core/cerchio/il_cerchio_sociale.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/amici/amici_screen.dart';
import 'package:esoteric_circle/features/amici/il_ponte_verso_il_cerchio.dart';
import 'package:esoteric_circle/features/cerchio/il_tuo_cerchio_screen.dart';
import 'package:esoteric_circle/features/cerchio/invita_nel_cerchio_screen.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'porta_finta_del_cerchio_sociale.dart';

/// **IL CERCHIO SI VEDE DALLA RUBRICA DEGLI AMICI. Ordine FC voce 09, 4
/// ottobre 2026.**
///
/// Il fondatore: *"in amico vorrei che comparissero anche gli amici
/// online"*. In cima alla rubrica una riga sola, che porta al Cerchio, nei
/// tre casi dichiarati in `il_ponte_verso_il_cerchio.dart`; e nessuna
/// chiamata al server in piu' all'apertura della rubrica: il numero dei
/// presenti viene solo da una tendina gia' arrivata e fresca.
void main() {
  /// Il Cerchio sociale con la porta finta, caricato come in una sessione
  /// vera: i legami gia' letti e, se [conLaTendina], la tendina appena
  /// arrivata.
  Future<(PortaFintaDelCerchioSociale, IlCerchioSociale)> unCerchio(
      WidgetTester tester,
      {required bool conAmici,
      bool conLaTendina = false}) async {
    final finta = PortaFintaDelCerchioSociale(amici: conAmici);
    final sociale = IlCerchioSociale(porta: finta);
    await tester.runAsync(() async {
      await sociale.sincronizza(
          identita: BirthIdentity(birthMoment: DateTime(1990, 5, 12, 10)));
      await sociale.caricaIlCerchio();
      if (conLaTendina) await sociale.caricaLaTendina();
    });
    return (finta, sociale);
  }

  Future<void> monta(WidgetTester tester, PortaFintaDelCerchioSociale finta,
      IlCerchioSociale sociale,
      {DateTime? adesso}) async {
    SharedPreferences.setMockInitialValues({});
    // Ogni montaggio da capo: il Navigator del montaggio di prima, col
    // Cerchio aperto sopra la rubrica, non resta.
    await tester.pumpWidget(const SizedBox());
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2391);
    addTearDown(tester.view.reset);
    final amici = AmiciOffline();
    await tester.runAsync(amici.carica);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<IlCerchioSociale>.value(value: sociale),
        ChangeNotifierProvider(
            create: (_) => EntitlementService(initial: Tier.tier3)),
        Provider<AppServices>.value(value: AppServices.offline(null, finta)),
      ],
      child: MaterialApp(
        theme: AppTheme.dark(),
        builder: (c, figlio) => MediaQuery(
          data: MediaQuery.of(c).copyWith(disableAnimations: true),
          child: MaestroScope(neutro: true, child: figlio!),
        ),
        home: AmiciScreen(amici: amici, adesso: adesso),
      ),
    ));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  String testo(WidgetTester tester) =>
      tester.widget<Text>(find.byKey(const Key('amici_ponte_testo'))).data!;

  testWidgets(
      'FC.09: la riga del Cerchio nei tre casi, e nessuna chiamata in piu\' '
      'all\'apertura', (tester) async {
    final visti = <String>[];
    final chiamate = <String, int>{};

    // 1. Amici nel Cerchio e la tendina appena arrivata: quanti e quanti qui.
    var (finta, sociale) =
        await unCerchio(tester, conAmici: true, conLaTendina: true);
    var prima = finta.chieste.length;
    await monta(tester, finta, sociale);
    chiamate['con i presenti'] = finta.chieste.length - prima;
    expect(find.byKey(const Key('amici_ponte_conIPresenti')), findsOneWidget);
    visti.add(testo(tester));
    expect(testo(tester), contains('c\'è 1 persona'));
    expect(testo(tester), contains('1 è qui adesso'));

    // 2a. Amici nel Cerchio, e la tendina mai arrivata in questa sessione.
    (finta, sociale) = await unCerchio(tester, conAmici: true);
    prima = finta.chieste.length;
    await monta(tester, finta, sociale);
    chiamate['senza tendina'] = finta.chieste.length - prima;
    expect(find.byKey(const Key('amici_ponte_senzaIPresenti')), findsOneWidget);
    visti.add(testo(tester));
    expect(testo(tester), isNot(contains('qui')),
        reason: 'senza la tendina non si inventa un numero di presenti');

    // 2b. Amici nel Cerchio, e la tendina vecchia di due minuti.
    (finta, sociale) =
        await unCerchio(tester, conAmici: true, conLaTendina: true);
    await monta(tester, finta, sociale,
        adesso: sociale.tendinaArrivata!.add(const Duration(minutes: 2)));
    expect(find.byKey(const Key('amici_ponte_senzaIPresenti')), findsOneWidget,
        reason: 'una tendina vecchia di due minuti vale ancora');

    // 3. Nessun amico nel Cerchio: il Cerchio ti aspetta.
    (finta, sociale) = await unCerchio(tester, conAmici: false);
    prima = finta.chieste.length;
    await monta(tester, finta, sociale);
    chiamate['nessun amico'] = finta.chieste.length - prima;
    expect(find.byKey(const Key('amici_ponte_ilCerchioTiAspetta')),
        findsOneWidget);
    visti.add(testo(tester));

    // La riga non elenca nessuno: nessun nome del Cerchio nella rubrica.
    expect(find.text('Stella Lieve'), findsNothing);

    print('ORDINE FC VOCE 09: i tre casi a schermo: ${visti.join(' | ')}; '
        'chiamate al server all\'apertura della rubrica $chiamate');
    expect(chiamate.values.every((n) => n == 0), isTrue,
        reason: 'la rubrica degli amici chiama il server: $chiamate');
  });

  testWidgets('FC.09: il tocco porta al Cerchio, o all\'invito',
      (tester) async {
    var (finta, sociale) = await unCerchio(tester, conAmici: true);
    await monta(tester, finta, sociale);
    await tester.tap(find.byKey(const Key('amici_ponte_senzaIPresenti')));
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byType(IlTuoCerchioScreen), findsOneWidget);

    (finta, sociale) = await unCerchio(tester, conAmici: false);
    await monta(tester, finta, sociale);
    await tester.tap(find.byKey(const Key('amici_ponte_ilCerchioTiAspetta')));
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byType(InvitaNelCerchioScreen), findsOneWidget);
    print('ORDINE FC VOCE 09: il tocco con amici apre il tuo Cerchio, senza '
        'amici apre l\'invito');
  });

  test('FC.09: i casi si leggono dai dati, senza chiamate', () {
    // La freschezza e' un minuto, scritta in un posto solo.
    expect(IlPonteVersoIlCerchio.freschezzaDellaTendina,
        const Duration(minutes: 1));
    expect(IlPonteVersoIlCerchio.testo(CasoDelPonte.senzaIPresenti, 3, null),
        'Nel tuo Cerchio ci sono 3 persone.');
  });
}
