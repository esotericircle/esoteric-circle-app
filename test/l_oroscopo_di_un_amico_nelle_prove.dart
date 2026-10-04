import 'package:esoteric_circle/core/amici/amici_offline.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/horoscope/oroscopo_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// **L'OROSCOPO DI UN AMICO NELLE PROVE, ordine FC voce 02.**
///
/// La schermata dell'amico (`LOroscopoDellAmicoScreen`) non c'e' piu':
/// l'oroscopo di un amico e' l'Oroscopo col soggetto impostato su di lui, e
/// si monta con quello che l'Oroscopo vuole intorno, come nell'app. Lo usano
/// le prove che prima montavano la schermata dell'amico.
Widget lOroscopoDiUnAmico(Amico amico,
        {Tier tier = Tier.tier3,
        DateTime? adesso,
        bool riduciMovimento = true,
        double scala = 1.0}) =>
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(
            create: (_) => EntitlementService(initial: tier)),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => BirthIdentityController()),
        ChangeNotifierProvider(create: (_) => AmiciOffline()),
      ],
      child: MaterialApp(
        theme: AppTheme.dark(),
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(
              disableAnimations: riduciMovimento,
              textScaler: TextScaler.linear(scala)),
          child: MaestroScope(maestro: Maestro.medora, child: child!),
        ),
        home: OroscopoScreen(
            userSign: amico.segno,
            amico: amico,
            now: adesso ?? DateTime(2026, 9, 30, 12)),
      ),
    );
