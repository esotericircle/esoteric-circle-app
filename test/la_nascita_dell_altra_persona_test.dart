import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/synastry/la_nascita_dell_altra_persona.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// FT.03, LA STRADA SEMPLICE: LA NASCITA INSERITA A MANO.
/// L'interruttore del Cerchio prende il colore dal Maestro (FT, la guardia
/// `cosmo_e_interruttori`): il modulo vive sempre dentro lo scope.
Widget _conLoScope(Widget home) => ChangeNotifierProvider(
      create: (_) => MaestroController(),
      child: MaterialApp(
        home: home,
        builder: (context, figlio) => MaestroScope(child: figlio!),
      ),
    );

void main() {
  testWidgets('il pulsante resta spento finche nome e data non ci sono',
      (tester) async {
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));
    await tester
        .pumpWidget(_conLoScope(LaNascitaDellAltraPersona(palette: palette)));
    final pulsante = tester
        .widget<FilledButton>(find.byKey(const Key('nascita_altra_conferma')));
    expect(pulsante.onPressed, isNull);

    await tester.enterText(
        find.byKey(const Key('nascita_altra_nome')), 'Giulia');
    await tester.pump();
    final ancoraSpento = tester
        .widget<FilledButton>(find.byKey(const Key('nascita_altra_conferma')));
    expect(ancoraSpento.onPressed, isNull, reason: 'manca ancora la data');
  });

  testWidgets(
      'con nome e "non conosco l\'ora" accesa, il cielo nasce a mezzogiorno',
      (tester) async {
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));
    NascitaLetta? risultato;
    await tester.pumpWidget(_conLoScope(
      Builder(builder: (context) {
        return ElevatedButton(
          onPressed: () async {
            risultato =
                await LaNascitaDellAltraPersona.chiedi(context, palette);
          },
          child: const Text('apri'),
        );
      }),
    ));
    await tester.tap(find.text('apri'));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byKey(const Key('nascita_altra_nome')), 'Giulia');
    await tester.tap(find.byKey(const Key('nascita_altra_ora_non_nota')));
    await tester.pump();

    // La data: apriamo il selettore e confermiamo quella iniziale (oggi
    // meno venticinque anni), che e' gia' una data valida.
    await tester.tap(find.byKey(const Key('nascita_altra_data')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    final pulsante = tester
        .widget<FilledButton>(find.byKey(const Key('nascita_altra_conferma')));
    expect(pulsante.onPressed, isNotNull);
    await tester.tap(find.byKey(const Key('nascita_altra_conferma')));
    await tester.pumpAndSettle();

    expect(risultato, isNotNull);
    expect(risultato!.nome, 'Giulia');
  });
}
