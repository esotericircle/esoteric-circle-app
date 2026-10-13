import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread_type.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/tarot/stesa_tre_carte_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// **LA CROCE CELTICA GIA' RIVELATA, PER MISURARE LO SCORRIMENTO.** Ordine
/// FS, 13 ottobre 2026.
///
/// Il fondatore: sulla Croce Celtica, rivelate le dieci carte, lo scorrimento
/// va a scatti. Per misurarlo sul telefono vero senza consumare le carte del
/// giorno ne' gli Eos di un account, questo ingresso monta soltanto la
/// schermata della stesa, con le dieci carte gia' uscite, come fanno le
/// prove del tavolo (`test/il_tavolo_di_medora_test.dart`). Non entra
/// nell'app: si costruisce a parte.
///
/// ```
/// flutter build apk --release -t tool/la_croce_celtica_per_la_misura.dart
/// ```
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => MaestroController()),
      ChangeNotifierProvider(create: (_) => ParallaxController()),
      ChangeNotifierProvider(create: (_) => QualityTierController()),
      ChangeNotifierProvider(create: (_) => ZodiacController()),
    ],
    child: const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MaestroScope(
        child: StesaTreCarteScreen(
          seed: 2,
          revealAll: true,
          skipIntro: true,
          topic: TarotTopic.momentoCheVivo,
          tipo: TarotSpreadType.dieciCarte,
        ),
      ),
    ),
  ));
}
