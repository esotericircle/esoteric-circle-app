import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/chat/immersive_intents.dart';
import '../../../core/entitlement/entitlement_service.dart';
import '../../../core/entitlement/tier.dart';
import '../../../core/identity/natal_identity.dart';
import '../../../core/lang/euphonic.dart';
import '../../../core/maestro/maestro.dart';
import '../../../core/maestro/maestro_welcome.dart';
import '../../../core/maestro/natal_context.dart';
import '../../../design_system/components/cosmos_background.dart';
import '../../../design_system/theme/maestro_palette.dart';
import '../../../design_system/theme/maestro_scope.dart';
import '../../../design_system/tokens/color_tokens.dart';
import '../../../design_system/tokens/spacing_tokens.dart';
import '../../../design_system/tokens/typography_tokens.dart';
import '../../../services/app_services.dart';
import '../ask/ask_maestri_screen.dart';
import '../immersive_navigation.dart';
import 'maestro_chat_controller.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/chat_composer.dart';
import 'widgets/chat_empty_state.dart';
import 'widgets/chat_suggestions.dart';
import 'widgets/diagnostics_dialog.dart';
import 'widgets/maestro_disclaimer.dart';
import '../widgets/maestro_bust.dart';

/// La conversazione testuale con un Maestro.
///
/// E' il primo passo di C3: chat con Medora, in italiano, end to end su Gemini
/// via Firebase AI Logic, con memoria persistente per la Demo. Voce, avatar
/// animati e funzioni Coming soon sono i passi successivi.
class MaestroChatScreen extends StatefulWidget {
  const MaestroChatScreen({
    super.key,
    required this.maestro,
    this.initialTheme,
    this.initialUserMessage,
  });

  final Maestro maestro;

  /// Tema con cui si arriva dalla chiusura del cerchio del Consulta: il campo
  /// della domanda si apre gia' scritto, cosi' la conversazione riprende da li'.
  final String? initialTheme;

  /// Una prima domanda contestuale, gia' inviata come turno dell'utente appena
  /// la chat e' pronta: si arriva qui da un pulsante "Parlane con il Maestro" dal
  /// responso di un'arte, e il Maestro risponde subito su quel tema. Se il
  /// Maestro e' offline la chat resta normale, senza rompersi.
  final String? initialUserMessage;

  /// Route pronta all'uso: monta il controller con i servizi e la palette del
  /// Maestro, cosi' la chat vive con il suo tema anche sopra la MaterialApp.
  static Route<void> route({
    required Maestro maestro,
    required AppServices services,
    String? initialTheme,
    String? initialUserMessage,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) => ChangeNotifierProvider<MaestroChatController>(
        create: (_) => MaestroChatController(
          maestro: maestro,
          ai: services.ai,
          memory: services.memory,
        )..init(),
        child: MaestroScope(
          child: MaestroChatScreen(
            maestro: maestro,
            initialTheme: initialTheme,
            initialUserMessage: initialUserMessage,
          ),
        ),
      ),
    );
  }

  @override
  State<MaestroChatScreen> createState() => _MaestroChatScreenState();
}

class _MaestroChatScreenState extends State<MaestroChatScreen> {
  final ScrollController _scroll = ScrollController();
  bool _disclaimerHandled = false;
  bool _initialSent = false;
  int _lastCount = 0;

  /// Contatore delle aperture, persistito, cosi' due benvenuti vicini non
  /// ripetono la stessa formula. Chiave per Maestro.
  static const String _kRotationPrefix = 'maestro.welcome.rotation.';
  int _welcomeRotation = 0;

  @override
  void initState() {
    super.initState();
    _loadWelcomeRotation();
  }

  Future<void> _loadWelcomeRotation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_kRotationPrefix${widget.maestro.id}';
      final current = prefs.getInt(key) ?? 0;
      if (mounted) setState(() => _welcomeRotation = current);
      // Prepara la prossima apertura su una formula diversa.
      await prefs.setInt(key, current + 1);
    } catch (_) {
      // Senza persistenza si resta sulla prima formula, senza crash.
    }
  }

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

  void _maybeSendInitial(MaestroChatController controller) {
    if (_initialSent || controller.loading) return;
    final testo = widget.initialUserMessage?.trim();
    if (testo == null || testo.isEmpty) return;
    _initialSent = true;
    // Solo su una conversazione nuova, cosi' non si sovrascrive uno storico.
    if (controller.messages.isNotEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) controller.send(testo);
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

    // La prima domanda contestuale, inviata una sola volta quando la chat e'
    // pronta e la conversazione e' ancora vuota: si arriva da "Parlane con il
    // Maestro" con la domanda sulla fonte gia' pronta.
    _maybeSendInitial(controller);

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
        // La seconda superficie della Consulta, il confronto a piu' voci, vive
        // qui dentro: una sola voce nel dominio, due modi di consultare. Da qui
        // si porta la domanda anche agli altri Maestri, con la sintesi.
        onCompare: () => Navigator.of(context)
            .push(AskMaestriScreen.route(starter: widget.maestro)),
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
                // A chat vuota, se si arriva dalla chiusura del cerchio, il
                // campo si apre gia' col tema del Consulta.
                initialText: hasMessages ? null : widget.initialTheme,
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
        greeting: _welcomeFor(controller),
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

  Route<void>? _routeFor(ImmersiveTarget target) => immersiveRouteFor(target);

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

  /// Il benvenuto deterministico: vocativo dell'onboarding, un contesto (dati
  /// natali nel Free, sintesi di memoria nel Premium) e una formula a rotazione,
  /// piu' una domanda che spinge all'azione. Nessuna chiamata a Gemini.
  String _welcomeFor(MaestroChatController controller) {
    final birth = context.read<BirthIdentityController>();
    final natal = birth.hasBirth
        ? NatalContext.fromNatal(chart: birth.chart, facts: birth.facts)
        : NatalContext.none;
    final premium = context.read<EntitlementService>().tier != Tier.free;
    return MaestroWelcome.compose(
      maestro: widget.maestro,
      profile: controller.profile,
      natal: natal,
      memory: controller.memory,
      premium: premium,
      rotation: _welcomeRotation,
    );
  }
}

/// Barra superiore cerimoniale con il nome del Maestro e il suo dominio.
class _ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ChatAppBar({
    required this.maestro,
    required this.onDiagnostics,
    required this.onCompare,
    this.showAvatar = false,
    this.speaking = false,
  });

  final Maestro maestro;
  final VoidCallback onDiagnostics;

  /// Apre il confronto a piu' voci sulla stessa domanda.
  final VoidCallback onCompare;

  /// Mostra l'avatar tondo del Maestro accanto al nome, a conversazione avviata.
  final bool showAvatar;

  /// Cenno di speaking: l'aura dell'avatar pulsa mentre il Maestro risponde.
  final bool speaking;

  /// Altezza dell'header: piu' alta quando l'avatar che sfonda il cerchio sta
  /// sopra il nome, cosi' la colonna centrata (avatar, nome, sottotitolo) ci sta
  /// senza tagli; piu' bassa a conversazione vuota, dove ci sono solo nome e
  /// sottotitolo.
  double get _barHeight => showAvatar ? 116 : 68;

  @override
  Size get preferredSize => Size.fromHeight(_barHeight);

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return AppBar(
      backgroundColor: palette.deepest.withValues(alpha: 0.35),
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: 0,
      toolbarHeight: _barHeight,
      centerTitle: true,
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
      // Una sola azione, simmetrica alla freccia: porta la stessa domanda agli
      // altri Maestri e ne mette a confronto gli sguardi. L'header resta
      // bilanciato e il titolo centrato.
      actions: [
        IconButton(
          key: const Key('chat_compare'),
          icon: const Icon(Icons.balance_rounded),
          tooltip: 'Metti a confronto le voci del Cerchio',
          onPressed: onCompare,
        ),
      ],
      // Nessun simbolo da sviluppatore nell'header. La messa a punto (token di
      // debug di App Check) resta raggiungibile con un gesto nascosto: una
      // pressione prolungata sul nome del Maestro. Cosi' l'header e' pulito
      // nella build normale e da Demo.
      title: GestureDetector(
        onLongPress: onDiagnostics,
        behavior: HitTestBehavior.opaque,
        // Tutto centrato in colonna: il volto del Maestro che sfonda il cerchio
        // sopra (a conversazione avviata), poi il nome, poi il sottotitolo con
        // le tre arti. Cosi' l'header resta simmetrico in entrambe le fasi.
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (showAvatar) ...[
              MaestroBust(
                maestro: maestro,
                ring: 40,
                speaking: speaking,
              ),
              const SizedBox(height: 2),
            ],
            Text(maestro.displayName,
                textAlign: TextAlign.center,
                style: TypographyTokens.display(size: 20)),
            Text(
              maestro.domainArtsPhrase,
              textAlign: TextAlign.center,
              style: TypographyTokens.body(size: 12)
                  .copyWith(color: palette.goldSoft),
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
