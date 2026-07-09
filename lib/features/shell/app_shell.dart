import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/maestro/maestro.dart';
import '../../design_system/components/gradient_background.dart';
import '../home/home_screen.dart';
import '../maestri/maestro_screen.dart';
import 'navigation_controller.dart';
import 'santuario_bottom_bar.dart';

/// Contenitore principale dell'app: sfondo immersivo, schermata attiva e
/// bottom bar dei Maestri. Le schermate restano vive in un IndexedStack, cosi'
/// il ritorno al Santuario e' immediato (cold start percepito nullo).
class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationController>();

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: GradientBackground(
        child: IndexedStack(
          index: nav.index,
          children: const [
            HomeScreen(),
            MaestroScreen(maestro: Maestro.medora),
            MaestroScreen(maestro: Maestro.aura),
            MaestroScreen(maestro: Maestro.caligo),
          ],
        ),
      ),
      bottomNavigationBar: SantuarioBottomBar(
        current: nav.current,
        onSelected: nav.goTo,
      ),
    );
  }
}
