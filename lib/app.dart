import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/astro/zodiac_controller.dart';
import 'core/entitlement/entitlement_service.dart';
import 'core/feature_flags/feature_flag_service.dart';
import 'core/maestro/maestro_controller.dart';
import 'core/motion/parallax_controller.dart';
import 'core/quality/quality_tier.dart';
import 'design_system/theme/app_theme.dart';
import 'design_system/theme/maestro_scope.dart';
import 'features/shell/app_shell.dart';
import 'features/shell/navigation_controller.dart';

/// Radice dell'app: registra i servizi condivisi e monta lo shell.
///
/// Ordine dei provider: prima i servizi di base (Maestro attivo, entitlement,
/// qualita'), poi quelli che dipendono da essi (navigazione, feature flag).
class EsotericCircleApp extends StatelessWidget {
  const EsotericCircleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => EntitlementService()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(
          create: (ctx) =>
              NavigationController(ctx.read<MaestroController>()),
        ),
        ChangeNotifierProvider(
          create: (ctx) => FeatureFlagService(
            entitlement: ctx.read<EntitlementService>(),
          )..initialize(),
        ),
      ],
      child: MaterialApp(
        title: 'Esoteric Circle',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        // La dissolvenza cromatica del tema riguarda lo sfondo e gli accenti,
        // gestiti da MaestroScope; qui teniamo un solo ThemeData scuro base.
        home: const MaestroScope(child: AppShell()),
      ),
    );
  }
}
