import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/components/cosmos_background.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/aura/meditation/meditation_audio.dart';
import 'package:esoteric_circle/features/maestri/aura/meditation/meditation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **LA MEDITAZIONE HA IL SUO CIELO.** Ordine DD voce 13, 10 settembre 2026.
///
/// **Il fatto del fondatore**, confermato in ricognizione sul telefono
/// 767f596c: la schermata della Meditazione ha lo sfondo **completamente
/// nero**, senza stelle e senza parallasse. **Non e' il mondo di Aura**, ed era
/// l'unica stanza buia di una casa in cui ogni altra schermata poggia sul
/// cosmo.
///
/// **REGOLA H, e sono due meta'.** Che il cosmo ci sia e' la prima; che porti
/// **il colore di Aura** e' la seconda, e senza di lei un cielo qualunque
/// passerebbe la prova mentre la stanza continua a non essere sua.
void main() {
  Future<void> apri(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        // **LO SCOPE DICHIARA AURA, come fa l app.** La Meditazione vive nel
        // dominio di Aura: senza dirlo, la palette che arriva e quella
        // neutra del Cerchio e questa prova misurerebbe il proprio
        // montaggio invece della schermata.
        home: MaestroScope(
          maestro: Maestro.aura,
          child: MeditationScreen(
              player: const SilentTonePlayer(), now: DateTime(2026, 9, 9)),
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('IL CIELO C E, ed e quello dell app', (tester) async {
    await apri(tester);
    final cielo = find.byType(CosmosBackground);
    // ignore: avoid_print
    print('ORDINE DD VOCE 13: cieli montati nella Meditazione '
        '${cielo.evaluate().length}');
    expect(cielo, findsOneWidget,
        reason: 'la Meditazione non monta nessun cosmo: e di nuovo una stanza '
            'nera in una casa che poggia tutta sul cielo');
  });

  testWidgets('REGOLA H: E IL CIELO E DI AURA, non uno qualunque',
      (tester) async {
    await apri(tester);
    final sfondo = tester.widget<CosmosBackground>(
        find.byType(CosmosBackground).first);
    final palette = sfondo.paletteOverride;
    // ignore: avoid_print
    print('ORDINE DD VOCE 13: il cielo della Meditazione porta la palette '
        '${palette == null ? "di nessuno" : "di un Maestro"}, seme '
        '${sfondo.seed}');
    expect(palette, isNotNull,
        reason: 'il cosmo della Meditazione non porta nessuna palette: prende '
            'quella di chi passa, e la stanza non e di Aura');
    expect(palette!.primary,
        MaestroPalette.forKey(const ThemeKey.of(Maestro.aura)).primary,
        reason: 'il cosmo della Meditazione non porta il colore di Aura: '
            'porta ${palette.primary}, e Aura e '
            '${MaestroPalette.forKey(const ThemeKey.of(Maestro.aura)).primary}');
  });
}
