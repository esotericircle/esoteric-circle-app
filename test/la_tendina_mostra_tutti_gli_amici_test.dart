// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/cerchio/il_cerchio_sociale.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/cerchio/la_tendina_del_cerchio.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'cardinale_minimo.dart';
import 'porta_finta_del_cerchio_sociale.dart';

/// **LA TENDINA MOSTRA TUTTI GLI AMICI PRESENTI, ordine FB voce 01.**
///
/// Il server non ha piu' il tetto dei sei (ordine FA voce 05): la tendina
/// riceve tutti gli amici presenti. Questa prova guarda il telefono: con
/// centocinquanta amici presenti la tendina li mostra tutti, uno per uno,
/// scorrendo, e dopo di loro c'e' ancora il Cerchio per arte. Si contano le
/// righe viste davvero, non la lunghezza della lista ricevuta.
void main() {
  const quanti = 150;

  testWidgets(
      'FB.01: con centocinquanta amici presenti la tendina li mostra '
      'tutti', (tester) async {
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2391);
    addTearDown(tester.view.reset);
    final finta = PortaFintaDelCerchioSociale(amiciPresenti: [
      for (var i = 0; i < quanti; i++)
        {
          'uid': 'u-amico-$i',
          'nome': 'Amico Numero $i',
          'icona': 'segno:${i % 12}',
          'segno': 'leo',
          'maestro': 'aura',
          'arte': 'tarocchi',
        },
    ]);
    final sociale = IlCerchioSociale(porta: finta);
    await sociale.sincronizza(
        identita: BirthIdentity(birthMoment: DateTime(1990, 5, 12, 10)));
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
        home: Builder(
            builder: (c) => Scaffold(
                body: Center(
                    child: TextButton(
                        onPressed: () => apriLaTendinaDelCerchio(c),
                        child: const Text('apri'))))),
      ),
    ));
    await tester.tap(find.text('apri'));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byKey(const Key('la_tendina_del_cerchio')), findsOneWidget);

    // Si scorre la tendina e si raccolgono le righe degli amici viste.
    final viste = <String>{};
    final elenco = find
        .descendant(
            of: find.byKey(const Key('la_tendina_del_cerchio')),
            matching: find.byType(Scrollable))
        .first;
    var fermi = 0;
    while (fermi < 3) {
      final prima = viste.length;
      for (final e in find
          .byWidgetPredicate((w) =>
              w.key is ValueKey<String> &&
              (w.key! as ValueKey<String>)
                  .value
                  .startsWith('tendina_segno_u-amico-'))
          .evaluate()) {
        viste.add((e.widget.key! as ValueKey<String>).value);
      }
      fermi = viste.length == prima ? fermi + 1 : 0;
      await tester.drag(elenco, const Offset(0, -400));
      await tester.pump(const Duration(milliseconds: 100));
    }
    print('FB.01 LA TENDINA SUL TELEFONO: amici presenti ricevuti $quanti, '
        'righe viste scorrendo ${viste.length}');
    cardinaleMinimo(viste.length, quanti,
        cosa: 'righe degli amici presenti viste nella tendina',
        perche: 'Il tetto dei sei e\' tolto: la tendina mostra tutti gli '
            'amici presenti che il server manda.');
    expect(viste.length, quanti);
    for (var i = 0; i < quanti; i++) {
      expect(viste, contains('tendina_segno_u-amico-$i'));
    }
    // Dopo gli amici c'e' ancora il Cerchio per arte: l'elenco lungo non lo
    // spinge fuori dalla tendina.
    expect(find.text('IL CERCHIO ADESSO'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
