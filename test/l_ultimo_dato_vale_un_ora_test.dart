// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/amici/amici_offline.dart';
import 'package:esoteric_circle/core/cerchio/il_cerchio_sociale.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/amici/amici_screen.dart';
import 'package:esoteric_circle/features/cerchio/l_ora_del_telefono.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'porta_finta_del_cerchio_sociale.dart';

/// **L'ULTIMO DATO NOTO VALE UN'ORA, E DICE L'ORA COME IL TELEFONO.** Ordine
/// FC, Aggiunta della voce FC.10, parte prima, 5 ottobre 2026.
///
/// Il fondatore: *"L'ultimo dato noto si mostra solo se e' stato preso da
/// meno di un'ora. Oltre l'ora non si mostra piu': niente elenco e niente riga
/// dell'ora, compare il testo 'Il Cerchio non risponde in questo momento.
/// Riprova fra poco.'"*; *"L'ora segue il formato del telefono"*; *"il dato
/// scaduto si cancella dal telefono e non resta a occupare memoria."*
void main() {
  /// Il Cerchio sociale con una tendina arrivata, poi la porta che risponde
  /// col tetto: l'ultimo dato e' quello.
  Future<(_PortaColTetto, IlCerchioSociale)> unCerchio(
      WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final finta = _PortaColTetto();
    final sociale = IlCerchioSociale(porta: finta);
    await tester.runAsync(() async {
      await sociale.sincronizza(
          identita: BirthIdentity(birthMoment: DateTime(1990, 5, 12, 10)));
      await sociale.caricaIlCerchio();
      await sociale.caricaLaTendina();
    });
    finta.tetto = true;
    return (finta, sociale);
  }

  Future<void> monta(
      WidgetTester tester, _PortaColTetto finta, IlCerchioSociale sociale,
      {required DateTime adesso, bool ventiquattro = true}) async {
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
          data: MediaQuery.of(c).copyWith(
              disableAnimations: true, alwaysUse24HourFormat: ventiquattro),
          child: MaestroScope(neutro: true, child: figlio!),
        ),
        home: AmiciScreen(amici: amici, adesso: adesso),
      ),
    ));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.tap(find.byKey(const Key('amici_online')));
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  String? testoDi(WidgetTester tester, String chiave) {
    final f = find.byKey(Key(chiave));
    return f.evaluate().isEmpty ? null : tester.widget<Text>(f).data;
  }

  testWidgets(
      'a) preso cinquantanove minuti prima: l\'elenco e "Il Cerchio come era '
      'alle"', (tester) async {
    final (finta, sociale) = await unCerchio(tester);
    final presa = sociale.tendinaArrivata!;
    await monta(tester, finta, sociale,
        adesso: presa.add(const Duration(minutes: 59)));
    expect(find.text('Stella Lieve'), findsOneWidget);
    final riga = testoDi(tester, 'amici_online_ultimo_dato');
    final hh = presa.hour.toString().padLeft(2, '0');
    final mm = presa.minute.toString().padLeft(2, '0');
    expect(riga, 'Il Cerchio come era alle $hh:$mm.');
    expect(find.byKey(const Key('amici_online_silenzio')), findsNothing);
    print(
        'FC.10 PARTE PRIMA a: a 59 minuti la riga e\' "$riga", con l\'elenco');
  });

  testWidgets(
      'b) preso sessantuno minuti prima: niente elenco, il Cerchio non '
      'risponde', (tester) async {
    final (finta, sociale) = await unCerchio(tester);
    final presa = sociale.tendinaArrivata!;
    await monta(tester, finta, sociale,
        adesso: presa.add(const Duration(minutes: 61)));
    expect(find.text('Stella Lieve'), findsNothing);
    expect(find.byKey(const Key('amici_online_ultimo_dato')), findsNothing);
    final riga = testoDi(tester, 'amici_online_silenzio');
    expect(
        riga, 'Il Cerchio non risponde in questo momento. Riprova fra poco.');
    print('FC.10 PARTE PRIMA b: a 61 minuti nessun elenco, "$riga"');
  });

  testWidgets('c) l\'ora segue il telefono, a ventiquattro e a dodici ore',
      (tester) async {
    late String a24, a12;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (c) {
        final quando = DateTime(2026, 10, 5, 21, 47);
        a24 = rigaDellUltimoDato(c, quando);
        return MediaQuery(
          data: MediaQuery.of(c).copyWith(alwaysUse24HourFormat: false),
          child: Builder(builder: (d) {
            a12 = rigaDellUltimoDato(d, quando);
            return const SizedBox();
          }),
        );
      }),
      builder: (c, figlio) => MediaQuery(
          data: MediaQuery.of(c).copyWith(alwaysUse24HourFormat: true),
          child: figlio!),
    ));
    expect(a24, 'Il Cerchio come era alle 21:47.');
    expect(a12, 'Il Cerchio come era alle 9:47 PM.');
    // E nella schermata vera, col telefono a dodici ore.
    final (finta, sociale) = await unCerchio(tester);
    final presa = sociale.tendinaArrivata!;
    await monta(tester, finta, sociale,
        adesso: presa.add(const Duration(minutes: 5)), ventiquattro: false);
    final riga = testoDi(tester, 'amici_online_ultimo_dato')!;
    expect(riga,
        matches(RegExp(r'^Il Cerchio come era alle \d{1,2}:\d\d (AM|PM)\.$')));
    print('FC.10 PARTE PRIMA c: "$a24" a ventiquattro ore, "$a12" a dodici; '
        'nella rubrica a dodici ore "$riga"');
  });

  testWidgets('d) il dato scaduto si cancella dal telefono e dalla memoria',
      (tester) async {
    final (finta, sociale) = await unCerchio(tester);
    final prefs = await tester.runAsync(SharedPreferences.getInstance);
    final primaSulTelefono =
        prefs!.getString(IlCerchioSociale.chiaveDellUltimaTendina) != null;
    final presa = sociale.tendinaArrivata!;
    await monta(tester, finta, sociale,
        adesso: presa.add(const Duration(minutes: 61)));
    final dopoSulTelefono =
        prefs.getString(IlCerchioSociale.chiaveDellUltimaTendina) != null;
    expect(primaSulTelefono, isTrue);
    expect(dopoSulTelefono, isFalse,
        reason: 'il dato scaduto resta sul telefono');
    expect(sociale.tendina, isNull, reason: 'il dato scaduto resta in memoria');
    print('FC.10 PARTE PRIMA d: ultima tendina sul telefono prima '
        '$primaSulTelefono, dopo l\'ora $dopoSulTelefono; in memoria '
        '${sociale.tendina != null}');
  });
}

/// La porta finta che, dopo la prima tendina, risponde col tetto come il
/// server (`resource-exhausted`).
class _PortaColTetto extends PortaFintaDelCerchioSociale {
  _PortaColTetto() : super(amici: true);

  bool tetto = false;

  @override
  Future<EsitoSociale?> sociale(String porta,
      [Map<String, Object?> corpo = const {}]) async {
    if (porta == 'laTendinaDelCerchio' && tetto) {
      chieste.add((porta, corpo));
      return const EsitoSociale(
          dati: {},
          errore: 'resource-exhausted',
          riga: 'Hai bussato molte volte: riprova fra un minuto.');
    }
    return super.sociale(porta, corpo);
  }
}
