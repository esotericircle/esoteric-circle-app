import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/app_flow/app_flow_controller.dart';
import 'core/astro/natal_chart_controller.dart';
import 'core/astro/zodiac_controller.dart';
import 'core/entitlement/entitlement_service.dart';
import 'core/feature_flags/feature_flag_service.dart';
import 'core/maestro/maestro_controller.dart';
import 'core/motion/parallax_controller.dart';
import 'core/quality/quality_tier.dart';
import 'design_system/theme/app_theme.dart';
import 'design_system/theme/maestro_scope.dart';
import 'features/root_flow.dart';
import 'features/shell/navigation_controller.dart';

/// Radice dell'app: registra i servizi condivisi e monta il flusso di ingresso.
///
/// Ordine dei provider: prima i servizi di base (Maestro attivo, entitlement,
/// qualita', flusso), poi quelli che dipendono da essi (navigazione, feature
/// flag).
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
        ChangeNotifierProvider(create: (_) => AppFlowController()),
        ChangeNotifierProvider(create: (_) => NatalChartController()),
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
        locale: const Locale('it'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('it'), Locale('en')],
        // La dissolvenza cromatica del tema riguarda lo sfondo e gli accenti,
        // gestiti da MaestroScope; qui teniamo un solo ThemeData scuro base.
        home: const MaestroScope(child: RootFlow()),
      ),
    );
  }
}
