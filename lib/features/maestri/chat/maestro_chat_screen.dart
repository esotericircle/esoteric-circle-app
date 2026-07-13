import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/chat/immersive_intents.dart';
import '../../../core/lang/euphonic.dart';
import '../../../core/maestro/maestro.dart';
import '../../../design_system/components/cosmos_background.dart';
import '../../../design_system/theme/maestro_palette.dart';
import '../../../design_system/theme/maestro_scope.dart';
import '../../../design_system/tokens/color_tokens.dart';
import '../../../design_system/tokens/spacing_tokens.dart';
import '../../../design_system/tokens/typography_tokens.dart';
import '../../../services/app_services.dart';
import '../../rituals/day_oracle_screen.dart';
import '../../rituals/sunset_rune_screen.dart';
import '../../synastry/sinastria_celeb_screen.dart';
import '../aura/meditation/meditation_screen.dart';
import 'maestro_chat_controller.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/chat_composer.dart';
import 'widgets/chat_empty_state.dart';
import 'widgets/chat_suggestions.dart';
import 'widgets/diagnostics_dialog.dart';
import 'widgets/maestro_avatar.dart';
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

    final hasMessages = controller.messages.isNotEmpty;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: _ChatAppBar(
        maestro: widget.maestro,
        // Il volto appare nell'header a conversazione avviata: il mezzo busto
        // dello stato vuoto si e' rimpicciolito qui. Pulsa quando risponde.
        showAvatar: hasMessages,
        speaking: controller.sending,
        onDiagnostics: () => showChatDiagnostics(
          context,
          aiReady: controller.aiReady,
          memoryPersistent: services.memoryPersistent,
          appCheckDebugToken: services.appCheckDebugToken,
        ),
      ),
      // La chat e' una superficie di lettura: cosmo senza costellazioni, cosi'
      // nessuna forma stilizzata ne' rettangolo a portale trapela dietro
      // l'header. Restano stelle e nebulose.
      body: CosmosBackground(
        showZodiac: false,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(child: _buildBody(controller)),
              if (!controller.aiReady) _ConfigNotice(palette: palette),
              _RetryStrip(controller: controller),
              ChatComposer(
                enabled: controller.aiReady && !controller.sending,
                hintText: 'Scrivi ${aEuphonic(widget.maestro.displayName)} '
                    '${widget.maestro.displayName}',
                onSend: controller.send,
                // A conversazione avviata, un solo controllo discreto apre il
                // pannello dei suggerimenti. A chat vuota gli spunti sono i chip
                // d'avvio al centro, quindi qui non serve.
                onSuggestions: hasMessages
                    ? () => showSuggestionsPanel(
                          context,
                          maestro: widget.maestro,
                          onSend: controller.send,
                        )
                    : null,
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
        starters: SuggestionSets.starters(widget.maestro),
        onStarter: controller.send,
        enabled: controller.aiReady,
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
          onOpenIntent: (id) => _openIntent(context, id),
        );
      },
    );
  }

  // Apre la funzione immersiva instradata. Se esiste gia' la schermata, la
  // spinge (deep link interno); se e' ancora dietro il velo, un invito
  // elegante, mai un vicolo cieco.
  void _openIntent(BuildContext context, String intentId) {
    final target = ImmersiveTarget.values.firstWhere((t) => t.name == intentId);
    final route = _routeFor(target);
    if (route != null) {
      Navigator.of(context).push(route);
      return;
    }
    _showComingSoon(context, intentId);
  }

  Route<void>? _routeFor(ImmersiveTarget target) {
    switch (target) {
      case ImmersiveTarget.oroscopoGiorno:
        return DayOracleScreen.route();
      case ImmersiveTarget.meditazione:
      case ImmersiveTarget.breathwork:
      case ImmersiveTarget.frequenze:
        return MeditationScreen.route();
      case ImmersiveTarget.lancioRune:
        return SunsetRuneScreen.route();
      case ImmersiveTarget.sinastriaCeleb:
        return SinastriaCelebScreen.route();
      case ImmersiveTarget.tarocchiStesa:
      case ImmersiveTarget.cartaNatale:
      case ImmersiveTarget.costellazioneViso:
      case ImmersiveTarget.scanChakra:
      case ImmersiveTarget.sigilloMagico:
      case ImmersiveTarget.iChing:
      case ImmersiveTarget.pendolo:
      case ImmersiveTarget.ritualeCandela:
        return null; // ancora dietro il velo
    }
  }

  void _showComingSoon(BuildContext context, String intentId) {
    final intent = ImmersiveIntents.all.firstWhere((i) => i.id == intentId);
    final palette = context.palette;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        key: const Key('intent_coming_soon'),
        padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, SpacingTokens.md,
            SpacingTokens.lg, SpacingTokens.xl),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [palette.surfaceElevated, palette.deepest],
          ),
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(SpacingTokens.radiusXl)),
          border: Border.all(color: palette.gold.withValues(alpha: 0.3)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(intent.buttonLabel,
                  style: TypographyTokens.display(size: 19)
                      .copyWith(color: palette.goldSoft)),
              const SizedBox(height: SpacingTokens.sm),
              Text(
                'Questa esperienza sta per aprirsi nel cerchio. Arriva presto, '
                'con tutta la sua immersione.',
                style: TypographyTokens.body(size: 15)
                    .copyWith(color: ColorTokens.textSecondary),
              ),
              const SizedBox(height: SpacingTokens.lg),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: Text('Va bene',
                      style: TypographyTokens.label(size: 13)
                          .copyWith(color: palette.goldSoft)),
                ),
              ),
            ],
          ),
        ),
      ),
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
        return 'Sono Caligo. Le rune tacciono, finché non le interroghi. '
            'Cosa cerchi?';
    }
  }
}

/// Barra superiore cerimoniale con il nome del Maestro e il suo dominio.
class _ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ChatAppBar({
    required this.maestro,
    required this.onDiagnostics,
    this.showAvatar = false,
    this.speaking = false,
  });

  final Maestro maestro;
  final VoidCallback onDiagnostics;

  /// Mostra l'avatar tondo del Maestro accanto al nome, a conversazione avviata.
  final bool showAvatar;

  /// Cenno di speaking: l'aura dell'avatar pulsa mentre il Maestro risponde.
  final bool speaking;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return AppBar(
      backgroundColor: palette.deepest.withValues(alpha: 0.35),
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: 0,
      iconTheme: IconThemeData(color: palette.goldSoft),
      // Freccia Indietro esplicita che riavvolge la pila. Nessuna X, nessuna
      // freccia Avanti. Il tasto di sistema Android e lo scorrimento dal bordo
      // popano comunque la route, la chat resta superficie immersiva senza
      // barra di navigazione.
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        tooltip: 'Indietro',
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      // Nessun simbolo da sviluppatore nell'header. La messa a punto (token di
      // debug di App Check) resta raggiungibile con un gesto nascosto: una
      // pressione prolungata sul nome del Maestro. Cosi' l'header e' pulito
      // nella build normale e da Demo.
      title: GestureDetector(
        onLongPress: onDiagnostics,
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Slot dell'avatar tondo di Medora accanto al nome. Segnaposto.
            if (showAvatar) ...[
              MaestroAvatar(maestro: maestro, size: 38, speaking: speaking),
              const SizedBox(width: SpacingTokens.sm),
            ],
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(maestro.displayName,
                    style: TypographyTokens.display(size: 20)),
                Text(
                  maestro.domainTitle,
                  style: TypographyTokens.body(size: 12)
                      .copyWith(color: palette.goldSoft),
                ),
              ],
            ),
          ],
        ),
      ),
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
              'Il cerchio non è ancora acceso. La voce di Medora si attiva '
              'quando la configurazione AI è completa.',
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
