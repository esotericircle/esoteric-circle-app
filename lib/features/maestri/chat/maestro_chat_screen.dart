import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/maestro/maestro.dart';
import '../../../design_system/components/cosmos_background.dart';
import '../../../design_system/theme/maestro_palette.dart';
import '../../../design_system/theme/maestro_scope.dart';
import '../../../design_system/tokens/color_tokens.dart';
import '../../../design_system/tokens/spacing_tokens.dart';
import '../../../design_system/tokens/typography_tokens.dart';
import '../../../services/app_services.dart';
import 'maestro_chat_controller.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/chat_composer.dart';
import 'widgets/chat_empty_state.dart';
import 'widgets/diagnostics_dialog.dart';
import 'widgets/maestro_disclaimer.dart';

/// La conversazione testuale con un Maestro.
///
/// E' il primo passo di C3: chat con Medora, in italiano, end to end su Gemini
/// via Firebase AI Logic, con memoria persistente per la Demo. Voce, avatar
/// animati e funzioni Coming soon sono i passi successivi.
class MaestroChatScreen extends StatefulWidget {
  const MaestroChatScreen({super.key, required this.maestro});

  final Maestro maestro;

  /// Route pronta all'uso: monta il controller con i servizi e la palette del
  /// Maestro, cosi' la chat vive con il suo tema anche sopra la MaterialApp.
  static Route<void> route({
    required Maestro maestro,
    required AppServices services,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) => ChangeNotifierProvider<MaestroChatController>(
        create: (_) => MaestroChatController(
          maestro: maestro,
          ai: services.ai,
          memory: services.memory,
        )..init(),
        child: MaestroScope(child: MaestroChatScreen(maestro: maestro)),
      ),
    );
  }

  @override
  State<MaestroChatScreen> createState() => _MaestroChatScreenState();
}

class _MaestroChatScreenState extends State<MaestroChatScreen> {
  final ScrollController _scroll = ScrollController();
  bool _disclaimerHandled = false;
  int _lastCount = 0;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _maybeShowDisclaimer(MaestroChatController controller) async {
    if (_disclaimerHandled || controller.loading) return;
    _disclaimerHandled = true;
    if (!controller.needsDisclaimer) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showMaestroDisclaimer(
        context,
        onAccepted: controller.acceptDisclaimer,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MaestroChatController>();
    final services = context.read<AppServices>();
    final palette = context.palette;

    // Mostra il disclaimer una sola volta, appena la memoria e' caricata.
    _maybeShowDisclaimer(controller);

    // Auto scroll quando arrivano nuovi messaggi.
    if (controller.messages.length != _lastCount) {
      _lastCount = controller.messages.length;
      _scrollToEnd();
    }

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: _ChatAppBar(
        maestro: widget.maestro,
        onDiagnostics: () => showChatDiagnostics(
          context,
          aiReady: controller.aiReady,
          memoryPersistent: services.memoryPersistent,
          appCheckDebugToken: services.appCheckDebugToken,
        ),
      ),
      body: CosmosBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(child: _buildBody(controller)),
              if (!controller.aiReady) _ConfigNotice(palette: palette),
              _RetryStrip(controller: controller),
              ChatComposer(
                enabled: controller.aiReady && !controller.sending,
                hintText: 'Scrivi a ${widget.maestro.displayName}',
                onSend: controller.send,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(MaestroChatController controller) {
    if (controller.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.messages.isEmpty) {
      return ChatEmptyState(
        maestro: widget.maestro,
        greeting: _greetingFor(widget.maestro),
        suggestions: _suggestionsFor(widget.maestro),
        onSuggestion: controller.aiReady ? controller.send : (_) {},
      );
    }
    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.md,
        vertical: SpacingTokens.md,
      ),
      itemCount: controller.messages.length,
      itemBuilder: (context, index) {
        return ChatBubble(
          message: controller.messages[index],
          maestro: widget.maestro,
        );
      },
    );
  }

  String _greetingFor(Maestro maestro) {
    switch (maestro) {
      case Maestro.medora:
        return 'Sono Medora. Le stelle e le carte sanno raccontarti, se le '
            'ascolti. Da dove vuoi cominciare?';
      case Maestro.aura:
        return 'Sono Aura. Respira con me. Cosa senti il bisogno di sciogliere?';
      case Maestro.caligo:
        return 'Sono Caligo. Le rune tacciono, finche\' non le interroghi. '
            'Cosa cerchi?';
    }
  }

  List<String> _suggestionsFor(Maestro maestro) {
    switch (maestro) {
      case Maestro.medora:
        return const [
          'Parlami del mio segno',
          'Come sara\' la mia giornata?',
          'Tira una carta per me',
        ];
      case Maestro.aura:
        return const ['Aiutami a rilassarmi', 'Parlami dei chakra'];
      case Maestro.caligo:
        return const ['Estrai una runa', 'Parlami di un simbolo'];
    }
  }
}

/// Barra superiore cerimoniale con il nome del Maestro e il suo dominio.
class _ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ChatAppBar({required this.maestro, required this.onDiagnostics});

  final Maestro maestro;
  final VoidCallback onDiagnostics;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return AppBar(
      backgroundColor: palette.deepest.withValues(alpha: 0.35),
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: palette.goldSoft),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(maestro.displayName, style: TypographyTokens.display(size: 20)),
          Text(
            maestro.domainTitle,
            style: TypographyTokens.body(size: 12)
                .copyWith(color: palette.goldSoft),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: onDiagnostics,
          icon: const Icon(Icons.tune_rounded),
          tooltip: 'Messa a punto',
        ),
      ],
    );
  }
}

/// Avviso in tono quando l'AI non e' ancora configurata: nessun errore crudo,
/// solo una spiegazione discreta.
class _ConfigNotice extends StatelessWidget {
  const _ConfigNotice({required this.palette});

  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.md,
        vertical: SpacingTokens.xs,
      ),
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        color: palette.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
        border: Border.all(color: palette.gold.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.nights_stay_outlined, color: palette.goldSoft, size: 22),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: Text(
              'Il cerchio non e\' ancora acceso. La voce di Medora si attiva '
              'quando la configurazione AI e\' completa.',
              style: TypographyTokens.body(size: 14)
                  .copyWith(color: ColorTokens.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

/// Striscia con l'invito a riprovare, quando l'ultimo turno e' fallito.
class _RetryStrip extends StatelessWidget {
  const _RetryStrip({required this.controller});

  final MaestroChatController controller;

  @override
  Widget build(BuildContext context) {
    final messages = controller.messages;
    final showRetry = messages.isNotEmpty &&
        messages.last.isMaestro &&
        messages.last.failed &&
        !controller.sending;
    if (!showRetry) return const SizedBox.shrink();

    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.xs),
      child: TextButton.icon(
        onPressed: controller.retryLast,
        icon: Icon(Icons.refresh_rounded, color: palette.goldSoft, size: 18),
        label: Text(
          'Riprova',
          style: TypographyTokens.body(size: 14).copyWith(color: palette.goldSoft),
        ),
      ),
    );
  }
}
