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
  });

  final Widget child;
  final bool safeBottom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: CosmosBackground(
        child: SafeArea(
          bottom: safeBottom,
          child: child,
        ),
      ),
    );
  }
}
