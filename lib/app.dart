import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/astro/zodiac_controller.dart';
import 'core/entitlement/entitlement_service.dart';
import 'core/feature_flags/feature_flag_service.dart';
import 'core/maestro/maestro_controller.dart';
import 'core/motion/parallax_controller.dart';
import 'core/quality/quality_tier.dart';
import 'core/settings/settings_controller.dart';
import 'design_system/theme/app_theme.dart';
import 'design_system/theme/maestro_scope.dart';
import 'features/shell/app_shell.dart';
import 'features/shell/navigation_controller.dart';
import 'services/app_services.dart';

/// Radice dell'app: registra i servizi condivisi e monta lo shell.
///
/// Ordine dei provider: prima i servizi a runtime (AI e memoria) e quelli di
/// base (Maestro attivo, entitlement, qualita'), poi quelli che dipendono da
/// essi (navigazione, feature flag).
class EsotericCircleApp extends StatelessWidget {
  const EsotericCircleApp({super.key, this.services});

  /// Servizi a runtime montati all'avvio. Se assenti (test, anteprima) si usa
  /// una configurazione offline che non tocca la rete.
  final AppServices? services;

  @override
  Widget build(BuildContext context) {
    final runtime = services ?? AppServices.offline();
    return MultiProvider(
      providers: [
        Provider<AppServices>.value(value: runtime),
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => EntitlementService()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => SettingsController()..load()),
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
        home: Consumer<SettingsController>(
          builder: (context, settings, _) {
            // Modalita' semplice: abbassa la qualita' grafica. Applicata fuori
            // dal build per non scrivere stato durante la costruzione.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final q = context.read<QualityTierController>();
              final target =
                  settings.simpleMode ? QualityTier.low : QualityTier.high;
              if (q.tier != target) q.setTier(target);
            });
            // Riduci animazioni: si riversa su disableAnimations, cosi' tutto
            // il codice che rispetta Riduci Movimento lo onora.
            final mq = MediaQuery.of(context);
            return MediaQuery(
              data: mq.copyWith(
                disableAnimations:
                    mq.disableAnimations || settings.reduceAnimations,
              ),
              child: const MaestroScope(child: AppShell()),
            );
          },
        ),
      ),
    );
  }
}
