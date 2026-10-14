import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/settings/settings_controller.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread_type.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/tarot/stesa_tre_carte_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// **LA STESA COL VIDEO DEL VORTICE, PER GUARDARLA SUL TELEFONO.** Ordine FS
/// aggiunta, voce FS.A2, 14 ottobre 2026.
///
/// Monta soltanto la schermata della Stesa, appena aperta, come la apre la
/// persona: il video della scena parte, si ferma sull'ultimo fotogramma, e
/// le carte si scelgono sopra. Serve a guardare e a misurare il video sul
/// Realme senza consumare le stese del giorno ne' gli Eos di un account,
/// come `tool/la_croce_celtica_per_la_misura.dart`. Non entra nell'app: si
/// costruisce a parte.
///
/// ```
/// flutter build apk --profile -t tool/la_stesa_col_vortice_per_la_prova.dart
/// ```
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => MaestroController()),
      ChangeNotifierProvider(create: (_) => ParallaxController()),
      ChangeNotifierProvider(create: (_) => QualityTierController()),
      ChangeNotifierProvider(create: (_) => ZodiacController()),
      ChangeNotifierProvider(create: (_) => SettingsController()),
    ],
    child: const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MaestroScope(
        child: StesaTreCarteScreen(
          seed: 2,
          skipIntro: true,
          topic: TarotTopic.momentoCheVivo,
          // **LA CROCE CELTICA, dieci carte gia' uscite.** Ordine del 14
          // ottobre 2026: e' li' che il fondatore ha visto la banda sotto
          // la barra del titolo. `revealAll` porta la fila in piedi senza
          // dover scegliere dieci carte a mano.
          tipo: TarotSpreadType.dieciCarte,
          revealAll: true,
        ),
      ),
    ),
  ));
}
