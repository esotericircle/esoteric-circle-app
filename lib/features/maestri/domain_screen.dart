import 'package:flutter/material.dart';

import '../../core/maestro/maestro.dart';
import '../../design_system/components/cosmos_background.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../services/app_services.dart';
import 'maestro_screen.dart';
import 'widgets/domain_pillars.dart';

/// Il dominio di un Maestro, come route spinta sopra il Santuario.
///
/// E' l'hub minimo: l'ingresso Parla con il Maestro verso la chat, piu' le
/// funzioni del dominio nei loro stati. Ha la sua freccia Indietro che torna al
/// Santuario, nessuna bottom bar, cosi' resta superficie immersiva. Dalla chat,
/// Indietro torna qui; da qui, Indietro torna al Santuario.
class DomainScreen extends StatelessWidget {
  const DomainScreen({super.key, required this.maestro});

  final Maestro maestro;

  static Route<void> route({
    required Maestro maestro,
    required AppServices services,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) => MaestroScope(child: DomainScreen(maestro: maestro)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: palette.deepest.withValues(alpha: 0.35),
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: palette.goldSoft),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Indietro',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        // Il nome del Maestro e, come seconda riga, i tre pilastri del suo
        // dominio: si sa di che cosa e' fatto prima ancora di scorrere.
        toolbarHeight: 74,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(maestro.displayName,
                style: TypographyTokens.display(size: 20)),
            const SizedBox(height: 2),
            DomainPillars(maestro: maestro),
          ],
        ),
      ),
      // Cosmo senza costellazioni anche qui: superficie calma, nessun
      // rettangolo a portale dietro l'header.
      body: CosmosBackground(
        showZodiac: false,
        child: MaestroScreen(maestro: maestro),
      ),
    );
  }
}
