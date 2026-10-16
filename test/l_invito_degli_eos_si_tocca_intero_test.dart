import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/pricing/upgrade_invite.dart';
import 'package:esoteric_circle/features/shell/barra_del_cerchio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// L'INVITO DEGLI EOS SI TOCCA INTERO. Ordine EA voce 21.
///
/// **Il fatto, dal fondatore con due catture della 2272**: da *Chiedi anche
/// agli altri*, senza approfondimenti, il foglio degli Eos e dell'abbonamento
/// resta sotto la barra in basso, e *Non ora* e *Vedi i piani* non si toccano.
///
/// **La causa, misurata sulla cattura**: il foglio non era spinto sotto la
/// barra, era TAGLIATO. Un foglio che non puo' crescere ha per tetto 9/16
/// dell'altezza sotto le barre in alto; col titolo su due righe e il riscatto
/// su tre, il contenuto superava il tetto e il fondo, cioe' i due pulsanti,
/// finiva dove disegna la barra. Il bordo alto del foglio in cattura cade
/// esattamente a quel tetto.
///
/// **Si prova nel caso peggiore vero**: il testo di sistema al tetto che
/// l'app concede (1,3), un telefono stretto e il padding che la barra del
/// Cerchio dichiara in basso, come fa sopra il Navigator.
void main() {
  const schermi = <Size>[Size(360, 740), Size(390, 844)];
  const inAlto = 24.0 + 60.0;
  const sistemaInBasso = 24.0;

  for (final schermo in schermi) {
    testWidgets(
        'EA.21: su ${schermo.width.toInt()}x${schermo.height.toInt()} '
        'i due pulsanti stanno sopra la barra', (tester) async {
      tester.view.physicalSize = schermo;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      const inBasso = sistemaInBasso + BarraDelCerchio.altezza;

      await tester.pumpWidget(ChangeNotifierProvider(
          create: (_) => MaestroController(),
          child: MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(1.3),
                padding: const EdgeInsets.only(top: inAlto, bottom: inBasso),
                viewPadding:
                    const EdgeInsets.only(top: inAlto, bottom: inBasso),
              ),
              child: MaestroScope(child: child!),
            ),
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: TextButton(
                    key: const Key('apri'),
                    onPressed: () => showUpgradeInvite(
                      context,
                      title: 'Gli altri sguardi sono del Cerchio',
                      message:
                          'Puoi riscattare un confronto con gli Eos, oppure '
                          'col Cerchio la stessa domanda arriva anche agli altri '
                          'due Maestri, qui dentro, ognuno con la sua lente.',
                      riscattoLabel: 'Riscatta un confronto di sinastria · 150 '
                          'Eos (te ne mancano 120)',
                    ),
                    child: const Text('apri'),
                  ),
                ),
              ),
            ),
          )));
      await tester.tap(find.byKey(const Key('apri')));
      await tester.pumpAndSettle();

      final sopraLaBarra = schermo.height - inBasso;
      for (final chiave in const ['upgrade_see_plans', 'upgrade_non_ora']) {
        final pulsante = find.byKey(Key(chiave));
        expect(pulsante, findsOneWidget,
            reason: 'il pulsante $chiave non c\'e\' nel foglio');
        final r = tester.getRect(pulsante);
        expect(r.bottom, lessThanOrEqualTo(sopraLaBarra + 0.5),
            reason: 'il pulsante $chiave finisce a ${r.bottom} e la barra '
                'comincia a $sopraLaBarra: la persona non lo tocca');
      }
      // Il tocco arriva davvero: il foglio si chiude.
      await tester.tap(find.byKey(const Key('upgrade_non_ora')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('upgrade_invite')), findsNothing,
          reason: 'Non ora si tocca e il foglio resta aperto');
    });
  }
}
