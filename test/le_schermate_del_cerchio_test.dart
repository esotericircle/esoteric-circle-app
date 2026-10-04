// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/cerchio/il_cerchio_sociale.dart';
import 'package:esoteric_circle/core/cerchio/i_segni_del_cerchio.dart';
import 'package:esoteric_circle/features/cerchio/confronto_del_cielo_screen.dart';
import 'package:esoteric_circle/features/cerchio/il_tuo_cerchio_screen.dart';
import 'package:esoteric_circle/features/cerchio/la_richiesta_di_legame.dart';
import 'package:esoteric_circle/features/cerchio/la_tendina_del_cerchio.dart';
import 'package:esoteric_circle/features/cerchio/profilo_nel_cerchio_screen.dart';
import 'package:esoteric_circle/features/cerchio/scheda_dell_amico_screen.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'porta_finta_del_cerchio_sociale.dart';

/// **LE SCHERMATE DEL CERCHIO SOCIALE, ordine EY.** Montate con la porta
/// finta che risponde come il server, e misurate su cio' che si vede: i
/// semaforini (EY.05), il profilo col sigillo e la vetrina delle icone
/// (EY.03), la tendina coi due piani (EY.08), il confronto (EY.13), la
/// scheda dell'amico coi segni, i doni e il glifo (EY.10, EY.12, EY.14), le
/// reazioni che rispondono a un segno (EY.11), la richiesta di legame (EY.04).
void main() {
  Future<(PortaFintaDelCerchioSociale, IlCerchioSociale)> monta(
      WidgetTester tester, Widget schermata,
      {PortaFintaDelCerchioSociale? porta}) async {
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2391);
    addTearDown(tester.view.reset);
    final finta = porta ?? PortaFintaDelCerchioSociale();
    final sociale = IlCerchioSociale(porta: finta);
    await sociale.sincronizza();
    await sociale.caricaIlCerchio();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<IlCerchioSociale>.value(value: sociale),
        Provider<AppServices>.value(value: AppServices.offline(null, finta)),
      ],
      child: MaterialApp(
        theme: AppTheme.dark(),
        builder: (c, figlio) => MediaQuery(
          data: MediaQuery.of(c).copyWith(disableAnimations: true),
          child: MaestroScope(neutro: true, child: figlio!),
        ),
        home: schermata,
      ),
    ));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    return (finta, sociale);
  }

  testWidgets(
      'EY.05: il semaforino nei quattro stati, e il rosso solo fra i '
      'bloccati', (tester) async {
    await monta(tester, const IlTuoCerchioScreen());
    expect(find.byKey(const Key('semaforino_verde')), findsOneWidget);
    expect(find.byKey(const Key('semaforino_arancionePieno')), findsOneWidget);
    // Chi mi ha invitato: accetta oppure rifiuta.
    expect(find.byKey(const Key('accetta_u-corvo')), findsOneWidget);
    expect(find.byKey(const Key('rifiuta_u-corvo')), findsOneWidget);
    await tester.scrollUntilVisible(
        find.byKey(const Key('semaforino_arancioneChiaro')), 300,
        scrollable: find.byType(Scrollable).first);
    expect(find.byKey(const Key('semaforino_arancioneChiaro')), findsOneWidget);
    // Chi e' bloccato non compare negli elenchi del Cerchio.
    expect(find.text('Velo Nodo Vigile'), findsNothing);
    expect(Semaforo.values.map((s) => s.name), isNot(contains('rosso')));
    // Il sigillo NON si mostra sotto i nomi negli elenchi.
    expect(find.textContaining('M4XR'), findsNothing);
  });

  testWidgets(
      'EY.03: il profilo col nome, il sigillo, la visibilita\' e il '
      'rosso dei bloccati', (tester) async {
    final (finta, _) = await monta(tester, const ProfiloNelCerchioScreen());
    expect(find.text('Lunaria'), findsWidgets);
    expect(find.text('Il tuo sigillo: K7Q2'), findsOneWidget);
    expect(find.byKey(const Key('visibilita_amici')), findsOneWidget);
    expect(find.byKey(const Key('visibilita_invisibile')), findsOneWidget);
    expect(
        find.text('Chi non è tuo amico potrà vedere che sei nel Cerchio e '
            'invitarti.'),
        findsOneWidget);
    await tester.scrollUntilVisible(find.byKey(const Key('bloccata_u-x')), 300,
        scrollable: find.byType(Scrollable).first);
    expect(find.byKey(const Key('sblocca_u-x')), findsOneWidget);
    // La vetrina delle icone: tutte le cinquantotto, le spente con la riga.
    await tester.scrollUntilVisible(
        find.byKey(const Key('profilo_icona')), -300,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.byKey(const Key('profilo_icona')));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byKey(const Key('icona_segno:0')), findsOneWidget);
    await tester.tap(find.byKey(const Key('icona_segno:7')));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    final chiesta =
        finta.chieste.lastWhere((c) => c.$1 == 'aggiornaIlProfiloNelCerchio');
    expect(chiesta.$2['icona'], 'segno:7');
  });

  testWidgets(
      'EY.08: la tendina coi due piani, le arti e i simili col '
      'criterio', (tester) async {
    await monta(
        tester,
        Builder(
            builder: (c) => Scaffold(
                body: Center(
                    child: TextButton(
                        onPressed: () => apriLaTendinaDelCerchio(c),
                        child: const Text('apri'))))));
    await tester.tap(find.text('apri'));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byKey(const Key('la_tendina_del_cerchio')), findsOneWidget);
    expect(find.text('I TUOI AMICI PRESENTI'), findsOneWidget);
    expect(find.text('IL CERCHIO ADESSO'), findsOneWidget);
    expect(find.text('È ai tarocchi'), findsOneWidget);
    expect(find.text('ai tarocchi'), findsOneWidget);
    expect(find.text('Stesso segno'), findsOneWidget);
    expect(find.text('Stesso Maestro'), findsOneWidget);
    // Solo chi accetta inviti da tutti si invita dalla tendina.
    expect(find.byKey(const Key('tendina_invita_u-s1')), findsOneWidget);
    expect(find.byKey(const Key('tendina_invita_u-s2')), findsNothing);
    expect(find.byKey(const Key('tendina_cenno_u-s2')), findsOneWidget);
  });

  testWidgets(
      'EY.13: il confronto col cerchio, le quattro barre e le fonti; '
      'coi confronti finiti, il prezzo dal listino', (tester) async {
    final amico = PersonaDelCerchio.da(PortaFintaDelCerchioSociale.amico);
    await monta(
        tester,
        ConfrontoDelCieloScreen(
            amico: amico, mioSegno: Zodiac.leo, oggi: DateTime(2026, 10, 4)));
    expect(find.byKey(const Key('confronto_percentuale')), findsOneWidget);
    for (final b in [
      'Terra comune',
      'Ritmo',
      'L’aspetto dei segni',
      'Il cielo di oggi'
    ]) {
      expect(find.text(b), findsOneWidget, reason: b);
    }
    expect(find.text('Il confronto è sul segno e non sulla carta intera.'),
        findsOneWidget);
    expect(find.byKey(const Key('confronto_fonti_e_metodo')), findsOneWidget);
  });

  testWidgets('EY.13: confronti finiti', (tester) async {
    final amico = PersonaDelCerchio.da(PortaFintaDelCerchioSociale.amico);
    await monta(
        tester,
        ConfrontoDelCieloScreen(
            amico: amico, mioSegno: Zodiac.leo, oggi: DateTime(2026, 10, 4)),
        porta: PortaFintaDelCerchioSociale(confrontoConcesso: false));
    expect(find.byKey(const Key('confronti_finiti')), findsOneWidget);
    expect(find.text('Un confronto del cielo in più, 30 Eos.'), findsOneWidget);
  });

  testWidgets(
      'EY.10, EY.12, EY.14: la scheda dell\'amico coi segni, i doni '
      'e il glifo', (tester) async {
    final amico = PersonaDelCerchio.da(PortaFintaDelCerchioSociale.amico);
    final (finta, _) = await monta(tester, SchedaDellAmicoScreen(amico: amico));
    expect(find.byKey(const Key('glifo_del_legame')), findsOneWidget);
    expect(find.text('3 tratti accesi su 7'), findsOneWidget);
    final lista = find.byType(Scrollable).first;
    for (final s in ISegniDelCerchio.tutti) {
      await tester.scrollUntilVisible(find.byKey(Key('manda_${s.id}')), 200,
          scrollable: lista);
      expect(find.byKey(Key('manda_${s.id}')), findsOneWidget, reason: s.id);
    }
    await tester.scrollUntilVisible(
        find.byKey(const Key('prezzo_sigillo')), 200,
        scrollable: lista);
    expect(find.byKey(const Key('prezzo_scintilla')), findsOneWidget);
    expect(tester.widget<Text>(find.byKey(const Key('prezzo_scintilla'))).data,
        '30');
    expect(tester.widget<Text>(find.byKey(const Key('prezzo_sigillo'))).data,
        '80');
    expect(find.text('Gratuito'), findsOneWidget);
    await tester.scrollUntilVisible(
        find.byKey(const Key('manda_tiPenso')), -200,
        scrollable: lista);
    await tester.ensureVisible(find.byKey(const Key('manda_tiPenso')));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.byKey(const Key('manda_tiPenso')));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    final mandato = finta.chieste.lastWhere((c) => c.$1 == 'mandaUnSegno');
    expect(mandato.$2, {'a': 'u-stella', 'segno': 'tiPenso'});
  });

  testWidgets('EY.11: le reazioni rispondono a un segno ricevuto, e solo li\'',
      (tester) async {
    final (finta, _) = await monta(tester, const IlTuoCerchioScreen());
    await tester.scrollUntilVisible(
        find.byKey(const Key('reazione_s1_pernacchia')), 300,
        scrollable: find.byType(Scrollable).first);
    // Il segno mandato non porta reazioni: non c'e' niente a cui rispondere.
    expect(find.byKey(const Key('reazione_s2_pernacchia')), findsNothing);
    await tester.ensureVisible(find.byKey(const Key('reazione_s1_pernacchia')));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.byKey(const Key('reazione_s1_pernacchia')));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    final r = finta.chieste.lastWhere((c) => c.$1 == 'rispondiAlSegno');
    expect(r.$2, {'id': 's1', 'reazione': 'pernacchia'});
  });

  testWidgets('EY.04: il codice apre la richiesta, e il legame nasce dal tocco',
      (tester) async {
    final (finta, _) = await monta(
        tester,
        Builder(
            builder: (c) => Scaffold(
                body: Center(
                    child: TextButton(
                        onPressed: () =>
                            mostraLaRichiestaDiLegame(c, 'AB12CD34'),
                        child: const Text('apri'))))));
    await tester.tap(find.text('apri'));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('Stella Lieve ti chiama nel suo Cerchio'), findsOneWidget);
    expect(finta.chieste.where((c) => c.$1 == 'chiediIlLegame'), isEmpty,
        reason: 'il legame e\' nato prima del tocco');
    await tester.tap(find.byKey(const Key('richiesta_accetta')));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    final chiesto = finta.chieste.lastWhere((c) => c.$1 == 'chiediIlLegame');
    expect(chiesto.$2, {'codice': 'AB12CD34'});
  });
}
