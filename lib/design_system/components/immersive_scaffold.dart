import 'package:flutter/material.dart';

import 'cosmos_background.dart';

/// Scaffold immersivo per i flussi (onboarding, rivelazione): cosmo di sfondo,
/// nessuna bottom bar, coerente con il principio della navigazione immersiva
/// in cui la UI esterna scompare durante i flussi.
class ImmersiveScaffold extends StatelessWidget {
  const ImmersiveScaffold({
    super.key,
    required this.child,
    this.safeBottom = false,
    this.seed = 0,
  });

  final Widget child;
  final bool safeBottom;

  /// Il seme del cielo, inoltrato al cosmo: ogni flusso dichiara il suo,
  /// cosi' due schermate non mostrano mai lo stesso cielo.
  final int seed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: CosmosBackground(
        seed: seed,
        child: SafeArea(
          bottom: safeBottom,
          child: child,
        ),
      ),
    );
  }
}
