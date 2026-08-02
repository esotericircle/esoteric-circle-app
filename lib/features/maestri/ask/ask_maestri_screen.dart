import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/entitlement/entitlement_service.dart';
import '../../../core/entitlement/question_allowance.dart';
import '../../../core/identity/natal_identity.dart';
import '../../../core/identity/profile_controller.dart';
import '../../../core/maestro/consult_depth.dart';
import '../../../core/maestro/frase_di_ripiego.dart';
import '../../../core/maestro/maestro.dart';
import '../../../core/maestro/natal_context.dart';
import '../../../core/maestro/sorgente_natale.dart';
import '../../../design_system/theme/maestro_palette.dart';
import '../../../design_system/theme/maestro_scope.dart';
import '../../../design_system/tokens/color_tokens.dart';
import '../../../design_system/tokens/spacing_tokens.dart';
import '../../../design_system/tokens/typography_tokens.dart';
import '../../../services/ai/maestro_ai_provider.dart';
import '../../../services/ai/maestro_oracle.dart';
import '../../../services/ai/registro_dei_guasti.dart';
import '../../../services/app_services.dart';
import '../../pricing/upgrade_invite.dart';
import '../chat/maestro_chat_screen.dart';
import '../widgets/maestro_bust.dart';

/// "Consulta un Maestro", a domanda singola dentro il dominio di un Maestro.
///
/// Il consultare parte dal Maestro del dominio: una domanda, la sua risposta.
/// Sotto la risposta, l'invito "Consulta anche un altro Maestro" porta lo stesso
/// tema allo sguardo di un secondo o terzo Maestro e mostra in cima la sintesi
/// comparativa degli sguardi. Regole di accesso: il Free ha tre risposte Breve
/// al giorno, spendibili anche su Maestri diversi; il confronto a piu' Maestri e
/// le domande oltre il limite sono del Tier a pagamento, con l'invito gentile
/// all'upgrade. Ogni risposta, quella del dominio e ogni lente aggiunta, passa
/// da Gemini su Vertex tramite il provider AI condiviso con la chat, con la
/// personalizzazione natale; quando l'AI non e' pronta o non trova le parole, si
/// cade sull'oracolo locale deterministico, senza mai un errore a video. La
/// sintesi comparativa si compone in modo deterministico dalle lenti gia'
/// ottenute, senza una chiamata Gemini in piu'.
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
      // Il colore della Consulta e' quello del Maestro da cui si parte, non di
      // chi era attivo un istante prima: senza questo `maestro:` lo scope
      // seguiva `MaestroController` e le carte uscivano nel viola della palette
      // neutra. Stesso difetto della chat, stessa correzione.
      builder: (_) => MaestroScope(
        maestro: starter,
        child: AskMaestriScreen(starter: starter),
      ),
    );
  }

  @override
  State<AskMaestriScreen> createState() => _AskMaestriScreenState();
}

class _AskMaestriScreenState extends State<AskMaestriScreen> {
  final TextEditingController _composer = TextEditingController();

  /// I Maestri interpellati, nell'ordine in cui sono stati aggiunti.
  final List<Maestro> _responders = [];

  /// La lente risolta per ciascun Maestro, viva da Gemini o di ripiego.
  final Map<Maestro, MaestroLens> _lenses = {};

  /// I Maestri per cui si sta ancora attendendo la risposta.
  final Set<Maestro> _loading = {};

  /// La Sintesi comparativa generata da Gemini dalle lenti gia' ottenute. Null
  /// finche' non arriva o se il provider non e' pronto: allora si mostra la
  /// sintesi deterministica di ripiego (`MaestroOracle.synthesisFor`).
  String? _aiSynthesis;

  String? _theme;

  @override
  void dispose() {
    _composer.dispose();
    super.dispose();
  }

  bool get _hasAsked => _theme != null;

  /// Le lenti risolte, nell'ordine fisso del cerchio.
  List<MaestroLens> get _orderedLenses => [
        for (final m in Maestro.fixedOrder)
          if (_lenses[m] != null) _lenses[m]!,
      ];

  /// Il contesto natale reale, dai dati di nascita. Vuoto se la carta manca:
  /// personalizzazione col solo nome.
  NatalContext _natal() =>
      SorgenteNatale.daIdentita(context.read<BirthIdentityController>());

  Future<void> _ask() async {
    final theme = _composer.text.trim();
    if (theme.isEmpty) return;
    final tier = context.read<EntitlementService>().tier;
    final allowance = context.read<QuestionAllowance>();

    if (!allowance.canAsk(tier)) {
      // Free: le risposte di oggi sono esaurite.
      FocusScope.of(context).unfocus();
      await showUpgradeInvite(
        context,
        title: 'Hai posto le tue domande di oggi',
        message:
            'Col Cerchio le domande ai Maestri sono senza limiti e puoi metterne '
            'a confronto gli sguardi.',
      );
      return;
    }

    FocusScope.of(context).unfocus();
    // La domanda si conta solo a risposta consegnata: si registra dentro
    // _fetchLens, quando la lente (viva o di ripiego) e' pronta.
    setState(() {
      _theme = theme;
      _responders
        ..clear()
        ..add(widget.starter);
      _lenses.clear();
      _aiSynthesis = null;
      _loading
        ..clear()
        ..add(widget.starter);
    });
    await _fetchLens(widget.starter, theme, countsAgainstAllowance: true);
  }

  /// Ottiene la lente di un Maestro sul tema: prova Gemini con profilo e dati
  /// natali, e cade sull'oracolo locale se il provider non e' pronto o solleva
  /// [MaestroAiUnavailable], e comunque a ogni imprevisto. Mai un errore a video.
  /// La domanda si conta solo qui, a risposta consegnata.
  Future<void> _fetchLens(
    Maestro maestro,
    String theme, {
    required bool countsAgainstAllowance,
  }) async {
    final services = context.read<AppServices>();
    final profile = context.read<ProfileController>().profile;
    final tier = context.read<EntitlementService>().tier;
    final allowance = context.read<QuestionAllowance>();
    final natal = _natal();

    MaestroLens? lens;
    if (services.ai.isReady) {
      try {
        final reply = await services.ai.consult(
          maestro: maestro,
          theme: theme,
          profile: profile,
          natal: natal,
          depth: ConsultDepth.breve,
        );
        lens = MaestroLens(maestro: maestro, reply: reply);
      } on MaestroAiUnavailable {
        lens = null;
      } catch (errore, traccia) {
        // Il guasto lo ha gia' scritto `VoceSorvegliata`. Qui resta
        // l'annotazione: prima questo ramo non lasciava niente dietro di se',
        // e il Consulta e' il posto dove il silenzio si nota meno, perche' una
        // risposta arriva comunque.
        annotaGuastoInnocuo(
            'consultando ${maestro.displayName} sul tema scelto',
            errore,
            traccia);
        lens = null;
      }
    }
    // Ripiego deterministico dall'oracolo, sempre disponibile e DICHIARATO:
    // la lente porta con se' il fatto di non venire dal Maestro.
    lens ??= widget.oracle
        .consult(theme: theme, maestri: [maestro])
        .lenses
        .single
        .comeRipiego();

    if (!mounted) return;
    // La risposta e' consegnata: solo ora si conta la domanda del giorno.
    if (countsAgainstAllowance) allowance.record(tier);
    setState(() {
      _lenses[maestro] = lens!;
      _loading.remove(maestro);
    });
    // Quando gli sguardi sono piu' di uno, la Sintesi comparativa in cima la
    // genera Gemini dalle lenti gia' ottenute, con ripiego deterministico.
    if (_orderedLenses.length > 1) {
      await _fetchSynthesis();
    }
  }

  /// Chiede a Gemini la Sintesi comparativa dalle lenti gia' ottenute; su
  /// provider non pronto o errore resta null e il build usa la deterministica.
  Future<void> _fetchSynthesis() async {
    final services = context.read<AppServices>();
    final lenses = _orderedLenses;
    final theme = _theme!;
    final natal = _natal();
    if (!services.ai.isReady || lenses.length < 2) return;
    try {
      final text = await services.ai.synthesize(
        theme: theme,
        lenses: lenses,
        natal: natal,
      );
      if (!mounted) return;
      // Vale solo se le lenti nel frattempo non sono cambiate di numero.
      if (_orderedLenses.length == lenses.length) {
        setState(() => _aiSynthesis = text);
      }
    } on MaestroAiUnavailable {
      // Ripiego sulla sintesi deterministica, nessun errore a video.
    } catch (errore, traccia) {
      // Il ripiego resta silenzioso per la persona, non per chi legge i log.
      annotaGuastoInnocuo(
          'componendo la sintesi comparativa', errore, traccia);
    }
  }

  /// Chiude il cerchio: salva tema ed esito nella memoria condivisa del Maestro,
  /// cosi' la conversazione ricorda, poi apre la chat col tema gia' in composer.
  Future<void> _openChat() async {
    final services = context.read<AppServices>();
    final maestro = widget.starter;
    final theme = _theme!;
    final esito = _lenses[maestro]?.reading.trim() ?? '';
    try {
      final mem = await services.memory.loadMemory(maestro);
      final nota = esito.isEmpty
          ? 'Nel Consulta la persona ti ha chiesto: «$theme».'
          : 'Nel Consulta la persona ti ha chiesto: «$theme». In sintesi le hai risposto: $esito';
      final summary = mem.sessionSummary.trim().isEmpty
          ? nota
          : '${mem.sessionSummary.trim()} $nota';
      await services.memory.saveMemory(
          maestro, mem.copyWith(sessionSummary: summary));
    } catch (errore, traccia) {
      // Il salvataggio e' un di piu': un errore non impedisce di continuare.
      annotaGuastoInnocuo(
          'chiudendo il cerchio nella memoria di ${maestro.displayName}',
          errore,
          traccia);
    }
    if (!mounted) return;
    await Navigator.of(context).push(
      MaestroChatScreen.route(
        maestro: maestro,
        services: services,
        initialTheme: theme,
      ),
    );
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
      _loading.add(maestro);
      // La sintesi va ricalcolata sulle nuove lenti: intanto ripiego.
      _aiSynthesis = null;
    });
    // Anche la lente aggiunta viene da Gemini, con lo stesso ripiego. Il
    // confronto non intacca il limite giornaliero delle risposte singole.
    await _fetchLens(maestro, _theme!, countsAgainstAllowance: false);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final others = [
      for (final m in Maestro.fixedOrder)
        if (!_responders.contains(m)) m,
    ];
    final resolved = _orderedLenses;
    // La Sintesi comparativa: viva da Gemini quando c'e', altrimenti la
    // deterministica di ripiego.
    final synthesis = resolved.length > 1
        ? (_aiSynthesis ?? widget.oracle.synthesisFor(_theme!, resolved))
        : null;

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
        title: Text('Consulta ${widget.starter.displayName}',
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
              child: !_hasAsked
                  ? _EmptyState(starter: widget.starter, palette: palette)
                  : ListView(
                      key: const Key('ask_results'),
                      padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, 0,
                          SpacingTokens.lg, SpacingTokens.xxxl),
                      children: [
                        if (synthesis != null) ...[
                          _SynthesisCard(synthesis: synthesis),
                          const SizedBox(height: SpacingTokens.md),
                        ],
                        for (final m in Maestro.fixedOrder)
                          if (_responders.contains(m)) ...[
                            if (_loading.contains(m))
                              _LensLoadingCard(maestro: m)
                            else if (_lenses[m] != null)
                              _LensCard(lens: _lenses[m]!),
                            const SizedBox(height: SpacingTokens.sm),
                          ],
                        // Chiusura del cerchio: porta il tema in conversazione.
                        if (_lenses[widget.starter] != null) ...[
                          const SizedBox(height: SpacingTokens.xs),
                          _ContinueInChat(
                            maestro: widget.starter,
                            onContinue: _openChat,
                          ),
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
              hintText: 'Consulta ${starter.displayName}...',
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
          tooltip: 'Consulta',
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
          Text('Consulta anche un altro Maestro',
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

/// Il ponte alla conversazione: chiude il cerchio portando il tema in chat, dove
/// il Maestro riprende da li'.
class _ContinueInChat extends StatelessWidget {
  const _ContinueInChat({required this.maestro, required this.onContinue});

  final Maestro maestro;
  final Future<void> Function() onContinue;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return GestureDetector(
      key: const Key('ask_continue_chat'),
      onTap: onContinue,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.lg, vertical: SpacingTokens.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
          gradient: LinearGradient(colors: [
            palette.primary.withValues(alpha: 0.55),
            palette.surfaceElevated.withValues(alpha: 0.55),
          ]),
          border: Border.all(color: palette.gold.withValues(alpha: 0.55)),
        ),
        child: Row(
          children: [
            Icon(Icons.forum_rounded, size: 18, color: palette.goldSoft),
            const SizedBox(width: SpacingTokens.sm),
            Expanded(
              child: Text('Continua con ${maestro.displayName}',
                  style: TypographyTokens.display(size: 16)
                      .copyWith(color: palette.goldSoft)),
            ),
            Icon(Icons.arrow_forward_rounded, size: 16, color: palette.goldSoft),
          ],
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
class _LensLoadingCard extends StatefulWidget {
  const _LensLoadingCard({required this.maestro});

  final Maestro maestro;

  @override
  State<_LensLoadingCard> createState() => _LensLoadingCardState();
}

class _LensLoadingCardState extends State<_LensLoadingCard>
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
              // Il volto del Maestro che sfonda il cerchio, al posto dell'icona
              // nuda: qui c'e' spazio, quindi anello pieno.
              MaestroBust(maestro: lens.maestro, ring: 48),
              const SizedBox(width: SpacingTokens.sm),
              Text(lens.maestro.displayName,
                  style: TypographyTokens.display(size: 18)),
              const SizedBox(width: SpacingTokens.sm),
              // Il dominio entra per intero: si rimpicciolisce fin dove serve e
              // va a capo, mai troncato con l'ellissi.
              Expanded(
                child: Text(lens.maestro.domainTitle,
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    softWrap: true,
                    style: TypographyTokens.label(size: 11).copyWith(
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
          // Stessa dichiarazione della chat, stessa etichetta: se questa
          // lettura non viene dal Maestro, la carta lo dice.
          if (lens.ripiego) ...[
            const SizedBox(height: SpacingTokens.sm),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_outlined,
                    size: 13, color: ColorTokens.textMuted),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    RipiegoDelMaestro.etichetta,
                    style: TypographyTokens.body(size: 13)
                        .copyWith(color: ColorTokens.textMuted),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
