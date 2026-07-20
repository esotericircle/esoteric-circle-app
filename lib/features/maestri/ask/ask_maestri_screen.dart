import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/entitlement/entitlement_service.dart';
import '../../../core/entitlement/question_allowance.dart';
import '../../../core/identity/profile_controller.dart';
import '../../../core/maestro/maestro.dart';
import '../../../design_system/theme/maestro_palette.dart';
import '../../../design_system/theme/maestro_scope.dart';
import '../../../design_system/tokens/color_tokens.dart';
import '../../../design_system/tokens/spacing_tokens.dart';
import '../../../design_system/tokens/typography_tokens.dart';
import '../../../services/ai/maestro_ai_provider.dart';
import '../../../services/ai/maestro_oracle.dart';
import '../../../services/app_services.dart';
import '../../pricing/upgrade_invite.dart';
import '../widgets/maestro_bust.dart';

/// "Chiedi ai Maestri", dentro il dominio di un Maestro.
///
/// Il chiedere parte singolarmente dal Maestro del dominio: una domanda, la sua
/// risposta. Sotto la risposta, l'invito "Chiedi anche a un altro Maestro" porta
/// lo stesso tema allo sguardo di un secondo o terzo Maestro e mostra in cima la
/// sintesi comparativa degli sguardi. Regole di accesso: il Free ha una sola
/// domanda singola al giorno; il confronto a piu' Maestri e le domande oltre la
/// prima sono del Tier a pagamento, con l'invito gentile all'upgrade quando il
/// limite e' raggiunto. La risposta del Maestro del dominio passa da Gemini su
/// Vertex tramite il provider AI condiviso con la chat; quando l'AI non e'
/// pronta o non trova le parole, si cade sull'oracolo locale deterministico,
/// senza mai un errore a video. Gli eventuali Maestri aggiunti oltre il primo e
/// la sintesi comparativa restano sull'oracolo in questa fetta.
class AskMaestriScreen extends StatefulWidget {
  const AskMaestriScreen({
    super.key,
    required this.starter,
    this.oracle = const MaestroOracle(),
  });

  /// Il Maestro del dominio, primo a rispondere.
  final Maestro starter;

  final MaestroOracle oracle;

  static Route<void> route({required Maestro starter}) {
    return MaterialPageRoute<void>(
      builder: (_) => MaestroScope(child: AskMaestriScreen(starter: starter)),
    );
  }

  @override
  State<AskMaestriScreen> createState() => _AskMaestriScreenState();
}

class _AskMaestriScreenState extends State<AskMaestriScreen> {
  final TextEditingController _composer = TextEditingController();
  final List<Maestro> _responders = [];
  String? _theme;
  MaestriConsultation? _result;

  /// Vero mentre si attende la risposta viva del Maestro del dominio da Gemini.
  bool _loadingStarter = false;

  /// La lente del Maestro del dominio ottenuta da Gemini, quando c'e'. Null se
  /// l'AI non e' pronta o non ha risposto: in quel caso si mostra la lente
  /// dell'oracolo, gia' pronta in [_result].
  MaestroLens? _aiStarterLens;

  @override
  void dispose() {
    _composer.dispose();
    super.dispose();
  }

  void _recompute() {
    _result = widget.oracle.consult(theme: _theme!, maestri: _responders);
  }

  Future<void> _ask() async {
    final theme = _composer.text.trim();
    if (theme.isEmpty) return;
    final tier = context.read<EntitlementService>().tier;
    final allowance = context.read<QuestionAllowance>();

    if (!allowance.canAsk(tier)) {
      // Free: la domanda di oggi e' gia' stata posta.
      FocusScope.of(context).unfocus();
      await showUpgradeInvite(
        context,
        title: 'Hai posto la tua domanda di oggi',
        message:
            'Col Cerchio le domande ai Maestri sono senza limiti e puoi metterne '
            'a confronto gli sguardi.',
      );
      return;
    }

    allowance.record(tier);
    FocusScope.of(context).unfocus();
    // Il ripiego dell'oracolo e' gia' pronto in _result: se l'AI non risponde,
    // la card del Maestro del dominio esce comunque, senza attese ne' errori.
    setState(() {
      _theme = theme;
      _responders
        ..clear()
        ..add(widget.starter);
      _aiStarterLens = null;
      _loadingStarter = true;
      _recompute();
    });
    await _fetchStarter(theme);
  }

  /// Chiede la risposta viva del Maestro del dominio a Gemini. Cade sull'oracolo
  /// (lente gia' in [_result]) se il provider non e' pronto o solleva
  /// [MaestroAiUnavailable], e comunque a ogni imprevisto: mai un errore crudo a
  /// video. Legge provider e profilo prima del primo await, poi si protegge con
  /// [mounted].
  Future<void> _fetchStarter(String theme) async {
    final services = context.read<AppServices>();
    final profile = context.read<ProfileController>().profile;
    MaestroLens? lens;
    if (services.ai.isReady) {
      try {
        final reply = await services.ai.consult(
          maestro: widget.starter,
          theme: theme,
          profile: profile,
        );
        lens = MaestroLens(maestro: widget.starter, reply: reply);
      } on MaestroAiUnavailable {
        lens = null;
      } catch (_) {
        // Qualunque guasto (rete, backend) cade sul ripiego, in silenzio.
        lens = null;
      }
    }
    if (!mounted) return;
    setState(() {
      _loadingStarter = false;
      _aiStarterLens = lens;
    });
  }

  Future<void> _addResponder(Maestro maestro) async {
    final tier = context.read<EntitlementService>().tier;
    final allowance = context.read<QuestionAllowance>();
    if (!allowance.canCompare(tier)) {
      await showUpgradeInvite(
        context,
        title: 'Il confronto è del Cerchio',
        message:
            'Porta la stessa domanda allo sguardo di più Maestri col Cerchio, '
            'con la sintesi che li mette a confronto.',
      );
      return;
    }
    setState(() {
      _responders.add(maestro);
      _recompute();
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final others = [
      for (final m in Maestro.fixedOrder)
        if (!_responders.contains(m)) m,
    ];

    return Scaffold(
      backgroundColor: ColorTokens.neutralDeepest,
      appBar: AppBar(
        backgroundColor: palette.deepest.withValues(alpha: 0.4),
        elevation: 0,
        iconTheme: IconThemeData(color: palette.goldSoft),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Indietro',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text('Chiedi a ${widget.starter.displayName}',
            style: TypographyTokens.display(size: 20)),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(SpacingTokens.lg,
                  SpacingTokens.md, SpacingTokens.lg, SpacingTokens.sm),
              child: _Composer(
                controller: _composer,
                palette: palette,
                starter: widget.starter,
                onChanged: () => setState(() {}),
                onAsk: _ask,
              ),
            ),
            Expanded(
              child: _result == null
                  ? _EmptyState(starter: widget.starter, palette: palette)
                  : ListView(
                      key: const Key('ask_results'),
                      padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, 0,
                          SpacingTokens.lg, SpacingTokens.xxxl),
                      children: [
                        if (_result!.synthesis != null) ...[
                          _SynthesisCard(synthesis: _result!.synthesis!),
                          const SizedBox(height: SpacingTokens.md),
                        ],
                        for (final lens in _result!.lenses) ...[
                          if (lens.maestro == widget.starter &&
                              _loadingStarter)
                            _StarterLoadingCard(maestro: widget.starter)
                          else if (lens.maestro == widget.starter)
                            _LensCard(lens: _aiStarterLens ?? lens)
                          else
                            _LensCard(lens: lens),
                          const SizedBox(height: SpacingTokens.sm),
                        ],
                        if (others.isNotEmpty) ...[
                          const SizedBox(height: SpacingTokens.sm),
                          _AnotherMaestroInvite(
                            others: others,
                            onPick: _addResponder,
                          ),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Il campo della domanda con il bottone Chiedi.
class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.palette,
    required this.starter,
    required this.onChanged,
    required this.onAsk,
  });

  final TextEditingController controller;
  final MaestroPalette palette;
  final Maestro starter;
  final VoidCallback onChanged;
  final VoidCallback onAsk;

  @override
  Widget build(BuildContext context) {
    final canAsk = controller.text.trim().isNotEmpty;
    return Row(
      children: [
        Expanded(
          child: TextField(
            key: const Key('ask_field'),
            controller: controller,
            onChanged: (_) => onChanged(),
            onSubmitted: (_) => onAsk(),
            textInputAction: TextInputAction.send,
            minLines: 1,
            maxLines: 3,
            style: TypographyTokens.body(size: 15)
                .copyWith(color: ColorTokens.textPrimary),
            decoration: InputDecoration(
              hintText: 'Chiedi a ${starter.displayName}...',
              hintStyle: TypographyTokens.body(size: 15)
                  .copyWith(color: ColorTokens.textSecondary),
              filled: true,
              fillColor: palette.surfaceElevated.withValues(alpha: 0.5),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.md, vertical: SpacingTokens.sm),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
                borderSide:
                    BorderSide(color: palette.gold.withValues(alpha: 0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
                borderSide:
                    BorderSide(color: palette.gold.withValues(alpha: 0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
                borderSide:
                    BorderSide(color: palette.gold.withValues(alpha: 0.6)),
              ),
            ),
          ),
        ),
        const SizedBox(width: SpacingTokens.sm),
        IconButton(
          key: const Key('ask_submit'),
          onPressed: canAsk ? onAsk : null,
          icon: const Icon(Icons.auto_awesome),
          color: palette.goldSoft,
          disabledColor: ColorTokens.textSecondary.withValues(alpha: 0.4),
          tooltip: 'Chiedi',
        ),
      ],
    );
  }
}

/// Stato vuoto: invita a porre la prima domanda al Maestro del dominio.
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.starter, required this.palette});

  final Maestro starter;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const Key('ask_empty'),
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(starter.icon,
                size: 44, color: palette.goldSoft.withValues(alpha: 0.7)),
            const SizedBox(height: SpacingTokens.md),
            Text(
              'Scrivi la tua domanda a ${starter.displayName}. Dopo la sua '
              'risposta potrai portarla anche a un altro Maestro.',
              textAlign: TextAlign.center,
              style: TypographyTokens.body(size: 15)
                  .copyWith(color: ColorTokens.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// L'invito a portare la stessa domanda allo sguardo di un altro Maestro.
class _AnotherMaestroInvite extends StatelessWidget {
  const _AnotherMaestroInvite({required this.others, required this.onPick});

  final List<Maestro> others;
  final void Function(Maestro) onPick;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      key: const Key('ask_another_invite'),
      padding: const EdgeInsets.all(SpacingTokens.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
        border: Border.all(color: palette.gold.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Chiedi anche a un altro Maestro',
              style: TypographyTokens.display(size: 16)
                  .copyWith(color: palette.goldSoft)),
          const SizedBox(height: 4),
          Text(
            'Porta la stessa domanda al suo sguardo, con la sintesi a confronto.',
            style: TypographyTokens.body(size: 13)
                .copyWith(color: ColorTokens.textSecondary),
          ),
          const SizedBox(height: SpacingTokens.md),
          Row(
            children: [
              for (final m in others) ...[
                _OtherMaestroChip(maestro: m, onTap: () => onPick(m)),
                if (m != others.last) const SizedBox(width: SpacingTokens.sm),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _OtherMaestroChip extends StatelessWidget {
  const _OtherMaestroChip({required this.maestro, required this.onTap});

  final Maestro maestro;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(ThemeKey.of(maestro));
    return Expanded(
      child: GestureDetector(
        key: Key('ask_add_${maestro.id}'),
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
            gradient: LinearGradient(colors: [
              palette.primary.withValues(alpha: 0.5),
              palette.surfaceElevated.withValues(alpha: 0.5),
            ]),
            border: Border.all(color: palette.gold.withValues(alpha: 0.5)),
          ),
          child: Column(
            children: [
              Icon(maestro.icon, size: 20, color: palette.goldSoft),
              const SizedBox(height: 4),
              Text(maestro.displayName,
                  style: TypographyTokens.label(size: 11).copyWith(
                    color: palette.goldSoft,
                    letterSpacing: 0.8,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

/// La sintesi comparativa degli sguardi, in cima quando i Maestri sono piu' di
/// uno.
class _SynthesisCard extends StatelessWidget {
  const _SynthesisCard({required this.synthesis});

  final String synthesis;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      key: const Key('ask_synthesis'),
      padding: const EdgeInsets.all(SpacingTokens.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            palette.surfaceElevated.withValues(alpha: 0.9),
            palette.deepest.withValues(alpha: 0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
        border: Border.all(color: palette.gold.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.balance, size: 18, color: palette.goldSoft),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
                child: Text('Sintesi comparativa',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TypographyTokens.display(size: 17)
                        .copyWith(color: palette.goldSoft)),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.sm),
          Text(synthesis,
              style: TypographyTokens.body(size: 15)
                  .copyWith(color: ColorTokens.textPrimary, height: 1.4)),
        ],
      ),
    );
  }
}

/// L'attesa in tono mentre il Maestro del dominio compone la risposta viva.
///
/// Nella palette del Maestro, con un cenno di movimento che rispetta Riduci
/// Movimento: se le animazioni sono spente resta un punto fermo, mai un vuoto.
class _StarterLoadingCard extends StatefulWidget {
  const _StarterLoadingCard({required this.maestro});

  final Maestro maestro;

  @override
  State<_StarterLoadingCard> createState() => _StarterLoadingCardState();
}

class _StarterLoadingCardState extends State<_StarterLoadingCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(ThemeKey.of(widget.maestro));
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    // Il respiro parte solo se il movimento e' consentito, cosi' non gira a
    // vuoto quando le animazioni sono spente.
    if (reduceMotion) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
    return Container(
      key: Key('ask_loading_${widget.maestro.id}'),
      padding: const EdgeInsets.all(SpacingTokens.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            palette.primary.withValues(alpha: 0.28),
            palette.deepest.withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
        border: Border.all(color: palette.gold.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          FadeTransition(
            opacity: reduceMotion
                ? const AlwaysStoppedAnimation<double>(0.8)
                : Tween<double>(begin: 0.35, end: 0.9).animate(_controller),
            child: Icon(widget.maestro.icon, size: 22, color: palette.goldSoft),
          ),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Text(
              '${widget.maestro.displayName} raccoglie il suo sguardo...',
              style: TypographyTokens.body(size: 15).copyWith(
                color: palette.goldSoft,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// La lettura di un Maestro, nella sua palette: colpo d'occhio, testo, invito.
class _LensCard extends StatelessWidget {
  const _LensCard({required this.lens});

  final MaestroLens lens;

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(ThemeKey.of(lens.maestro));
    return Container(
      key: Key('ask_lens_${lens.maestro.id}'),
      padding: const EdgeInsets.all(SpacingTokens.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            palette.primary.withValues(alpha: 0.28),
            palette.deepest.withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
        border: Border.all(color: palette.gold.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Il mezzo busto del Maestro che sfonda il cerchio, al posto
              // dell'icona nuda: qui c'e' spazio, quindi anello e sporgenza
              // pieni.
              MaestroBust(maestro: lens.maestro, ring: 46, popFactor: 0.42),
              const SizedBox(width: SpacingTokens.sm),
              Text(lens.maestro.displayName,
                  style: TypographyTokens.display(size: 18)),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
                child: Text(lens.maestro.domainTitle,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TypographyTokens.label(size: 10).copyWith(
                      color: palette.goldSoft.withValues(alpha: 0.8),
                      letterSpacing: 0.8,
                    )),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.sm),
          Text(lens.glance,
              style: TypographyTokens.body(size: 15).copyWith(
                color: palette.goldSoft,
                fontStyle: FontStyle.italic,
                height: 1.35,
              )),
          const SizedBox(height: SpacingTokens.sm),
          Text(lens.reading,
              style: TypographyTokens.body(size: 14)
                  .copyWith(color: ColorTokens.textPrimary, height: 1.4)),
          const SizedBox(height: SpacingTokens.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.arrow_forward, size: 14, color: palette.goldSoft),
              const SizedBox(width: 6),
              Expanded(
                child: Text(lens.invite,
                    style: TypographyTokens.body(size: 14).copyWith(
                      color: palette.goldSoft,
                      height: 1.35,
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
