import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/archetypes/archetype.dart';
import '../../../../core/archetypes/archetype_allowance.dart';
import '../../../../core/archetypes/archetype_corpus.dart';
import '../../../../core/archetypes/archetype_history.dart';
import '../../../../core/archetypes/archetype_quiz.dart';
import '../../../../core/archetypes/archetype_scoring.dart';
import '../../../../core/archetypes/archetype_sky.dart';
import '../../../../core/archetypes/archetype_transits.dart';
import '../../../../core/entitlement/entitlement_service.dart';
import '../../../../core/entitlement/tier.dart';
import '../../../../core/maestro/maestro.dart';
import '../../../../design_system/components/cosmos_background.dart';
import '../../../../design_system/components/depth_card.dart';
import '../../../../design_system/components/scroll_reveal.dart';
import '../../../../design_system/theme/maestro_palette.dart';
import '../../../../design_system/theme/maestro_scope.dart';
import '../../../../design_system/tokens/color_tokens.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';
import '../../../../services/app_services.dart';
import '../../chat/maestro_chat_screen.dart';
import 'archetype_wheel.dart';

/// Il Test Archetipo, dominio Aura.
///
/// Dodici domande una alla volta, poi il responso: prima la ruota e la statua,
/// poi le parole. Il calcolo e' tutto nel cuore deterministico
/// (`ArchetypeScoring`, `ArchetypeTransits`, `ArchetypeAllowance`), qui c'e'
/// solo la messa in scena: nessuna AI, nessuna casualita'.
class ArchetypeTestScreen extends StatefulWidget {
  const ArchetypeTestScreen({
    super.key,
    this.clock,
    this.pianetiDelGiorno,
  });

  /// Orologio iniettabile per i test.
  final DateTime Function()? clock;

  /// I pianeti attivi, iniettabili per i test. Di default li chiede al cielo
  /// vero, che oggi sa calcolare Sole e Luna.
  final Set<Pianeta> Function(DateTime)? pianetiDelGiorno;

  static Route<void> route({
    DateTime Function()? clock,
    Set<Pianeta> Function(DateTime)? pianetiDelGiorno,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) => MaestroScope(
        child: ArchetypeTestScreen(
          clock: clock,
          pianetiDelGiorno: pianetiDelGiorno,
        ),
      ),
    );
  }

  @override
  State<ArchetypeTestScreen> createState() => _ArchetypeTestScreenState();
}

enum _Fase { soglia, domande, risultato }

class _ArchetypeTestScreenState extends State<ArchetypeTestScreen> {
  late final DateTime Function() _clock = widget.clock ?? DateTime.now;
  late final ArchetypeHistory _storico = ArchetypeHistory(clock: _clock);

  _Fase _fase = _Fase.soglia;
  int _indice = 0;
  final List<int> _scelte = [];

  ArchetypeProfile? _profilo;
  ArchetypeEsito? _precedente;
  bool _transiti = false;
  bool _pronto = false;

  @override
  void initState() {
    super.initState();
    _storico.carica().then((_) {
      if (mounted) setState(() => _pronto = true);
    });
  }

  @override
  void dispose() {
    _storico.dispose();
    super.dispose();
  }

  Tier get _tier => context.read<EntitlementService>().tier;

  bool get _consentito => ArchetypeAllowance.consentito(
        fattiOggi: _storico.fattiOggi,
        tier: _tier,
      );

  void _inizia() {
    if (!_consentito) return;
    setState(() {
      _precedente = _storico.ultimo;
      _scelte.clear();
      _indice = 0;
      _profilo = null;
      _transiti = false;
      _fase = _Fase.domande;
    });
  }

  Future<void> _rispondi(int scelta) async {
    _scelte.add(scelta);
    if (_scelte.length < ArchetypeQuiz.tutte.length) {
      setState(() => _indice = _scelte.length);
      return;
    }
    final profilo = ArchetypeScoring.calcola(_scelte);
    await _storico.registra(profilo);
    if (!mounted) return;
    setState(() {
      _profilo = profilo;
      _fase = _Fase.risultato;
    });
  }

  Set<Pianeta> get _pianeti {
    final f = widget.pianetiDelGiorno ?? ArchetypeSky.pianetiDelGiorno;
    return f(_clock());
  }

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.aura));
    return Scaffold(
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
        title: Text('Test Archetipo',
            style: TypographyTokens.display(size: 19)),
        actions: [
          IconButton(
            key: const Key('archetype_sources'),
            icon: const Icon(Icons.info_outline_rounded),
            tooltip: 'Fonti e metodo',
            onPressed: () => _mostraFonti(context, palette),
          ),
        ],
      ),
      body: CosmosBackground(
        showZodiac: false,
        child: SafeArea(
          child: !_pronto
              ? const SizedBox.shrink()
              : switch (_fase) {
                  _Fase.soglia => _Soglia(
                      palette: palette,
                      consentito: _consentito,
                      tier: _tier,
                      rimanenti: ArchetypeAllowance.rimanenti(
                          fattiOggi: _storico.fattiOggi, tier: _tier),
                      ultimo: _storico.ultimo,
                      onInizia: _inizia,
                    ),
                  _Fase.domande => _Domande(
                      palette: palette,
                      indice: _indice,
                      onRisposta: _rispondi,
                    ),
                  _Fase.risultato => _Risultato(
                      palette: palette,
                      profilo: _profilo!,
                      precedente: _precedente,
                      storico: _storico,
                      transiti: _transiti,
                      pianeti: _pianeti,
                      onTransiti: (v) => setState(() => _transiti = v),
                    ),
                },
        ),
      ),
    );
  }

  void _mostraFonti(BuildContext context, MaestroPalette palette) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheet) => Container(
        key: const Key('archetype_sources_sheet'),
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
              Text('Fonti e metodo',
                  style: TypographyTokens.display(size: 19)
                      .copyWith(color: palette.goldSoft)),
              const SizedBox(height: SpacingTokens.sm),
              Text(ArchetypeCorpus.fontiEMetodo,
                  style: TypographyTokens.body(size: 15).copyWith(
                      color: ColorTokens.textPrimary, height: 1.45)),
              const SizedBox(height: SpacingTokens.lg),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(sheet).pop(),
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
}

/// La soglia: si entra da qui, e da qui si vede se oggi il test e' consentito.
class _Soglia extends StatelessWidget {
  const _Soglia({
    required this.palette,
    required this.consentito,
    required this.tier,
    required this.rimanenti,
    required this.ultimo,
    required this.onInizia,
  });

  final MaestroPalette palette;
  final bool consentito;
  final Tier tier;
  final int? rimanenti;
  final ArchetypeEsito? ultimo;
  final VoidCallback onInizia;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: SpacingTokens.xl),
          Text('Quale dei dodici archetipi ti guida?',
              style: TypographyTokens.display(size: 24)
                  .copyWith(color: palette.goldSoft)),
          const SizedBox(height: SpacingTokens.sm),
          Text(
            'Dodici domande, una alla volta. Rispondi di pancia: non ci sono '
            'risposte giuste, ci sono risposte tue.',
            style: TypographyTokens.body(size: 16)
                .copyWith(color: ColorTokens.textPrimary, height: 1.5),
          ),
          const SizedBox(height: SpacingTokens.xl),
          if (consentito)
            FilledButton.icon(
              key: const Key('archetype_start'),
              onPressed: onInizia,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Comincia'),
            )
          else
            _Bloccato(palette: palette, tier: tier, ultimo: ultimo),
          if (consentito && rimanenti != null) ...[
            const SizedBox(height: SpacingTokens.sm),
            Text(
              rimanenti == 1
                  ? 'Ne hai uno oggi.'
                  : 'Ne hai $rimanenti oggi.',
              style: TypographyTokens.label(size: 12)
                  .copyWith(color: ColorTokens.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

/// Limite raggiunto: mai un vicolo cieco, si mostra l'ultimo esito salvato.
class _Bloccato extends StatelessWidget {
  const _Bloccato(
      {required this.palette, required this.tier, required this.ultimo});

  final MaestroPalette palette;
  final Tier tier;
  final ArchetypeEsito? ultimo;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('archetype_blocked'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.lock_rounded, size: 18, color: palette.goldSoft),
            const SizedBox(width: SpacingTokens.xs),
            Expanded(
              child: Text(
                'Per oggi hai già guardato dentro di te. Il Cerchio ne apre di più.',
                style: TypographyTokens.body(size: 15)
                    .copyWith(color: ColorTokens.textPrimary, height: 1.4),
              ),
            ),
          ],
        ),
        if (ultimo != null) ...[
          const SizedBox(height: SpacingTokens.lg),
          Text('Il tuo ultimo responso',
              style: TypographyTokens.label(size: 12).copyWith(
                  color: palette.goldSoft, letterSpacing: 0.6)),
          const SizedBox(height: SpacingTokens.sm),
          DepthCard(
            key: const Key('archetype_last_saved'),
            padding: const EdgeInsets.all(SpacingTokens.md),
            child: Row(
              children: [
                _Statua(
                    archetipo: ultimo!.dominante, lato: 84, palette: palette),
                const SizedBox(width: SpacingTokens.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ultimo!.dominante.nome,
                          style: TypographyTokens.display(size: 20)
                              .copyWith(color: palette.goldSoft)),
                      const SizedBox(height: 2),
                      Text(ArchetypeCorpus.di(ultimo!.dominante).essenza,
                          style: TypographyTokens.body(size: 14).copyWith(
                              color: ColorTokens.textSecondary, height: 1.35)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Una domanda alla volta, con l'avanzamento in chiaro.
class _Domande extends StatelessWidget {
  const _Domande({
    required this.palette,
    required this.indice,
    required this.onRisposta,
  });

  final MaestroPalette palette;
  final int indice;
  final ValueChanged<int> onRisposta;

  @override
  Widget build(BuildContext context) {
    final d = ArchetypeQuiz.tutte[indice];
    final quante = ArchetypeQuiz.tutte.length;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: SpacingTokens.lg),
          Text('${indice + 1} di $quante',
              key: const Key('archetype_progress'),
              style: TypographyTokens.label(size: 12).copyWith(
                  color: palette.goldSoft, letterSpacing: 1.0)),
          const SizedBox(height: SpacingTokens.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
            child: LinearProgressIndicator(
              value: (indice + 1) / quante,
              minHeight: 4,
              backgroundColor: palette.surface.withValues(alpha: 0.5),
              valueColor: AlwaysStoppedAnimation(palette.goldSoft),
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),
          Text(d.testo,
              key: const Key('archetype_question'),
              style: TypographyTokens.display(size: 22)
                  .copyWith(color: ColorTokens.textPrimary, height: 1.3)),
          const SizedBox(height: SpacingTokens.lg),
          // Solo il testo della risposta: l'etichetta archetipo non si vede
          // mai, perche' vederla cambierebbe la scelta.
          for (var i = 0; i < d.risposte.length; i++) ...[
            if (i > 0) const SizedBox(height: SpacingTokens.sm),
            DepthCard(
              key: Key('archetype_answer_$i'),
              onTap: () => onRisposta(i),
              padding: const EdgeInsets.all(SpacingTokens.md),
              child: Row(
                children: [
                  Expanded(
                    child: Text(d.risposte[i].testo,
                        style: TypographyTokens.body(size: 16)
                            .copyWith(color: ColorTokens.textPrimary)),
                  ),
                  Icon(Icons.chevron_right_rounded, color: palette.goldSoft),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// La statua dell'archetipo, dalla famiglia gia' bundlata.
///
/// Con [ombra] vera e' la STESSA statua trattata: patina scurita e virata al
/// freddo, con un velo di eclissi. Non e' un'immagine nuova, perche' l'Ombra
/// non e' un personaggio nuovo ma lo stesso archetipo nel suo lato distorto.
class _Statua extends StatelessWidget {
  const _Statua({
    required this.archetipo,
    required this.lato,
    required this.palette,
    this.ombra = false,
  });

  final Archetype archetipo;
  final double lato;
  final MaestroPalette palette;
  final bool ombra;

  @override
  Widget build(BuildContext context) {
    final img = Image.asset(
      archetipo.artePiena,
      height: lato,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Icon(Icons.person_outline_rounded,
          size: lato * 0.6, color: palette.goldSoft),
    );
    if (!ombra) {
      return SizedBox(
        key: Key('archetype_statue_${archetipo.name}'),
        height: lato,
        child: img,
      );
    }
    return SizedBox(
      key: Key('archetype_shadow_statue_${archetipo.name}'),
      height: lato,
      child: ColorFiltered(
        // Matrice deterministica: si abbassa la luce e si spegne il caldo,
        // cosi' il bronzo diventa una patina scura. Nessun asset in piu'.
        colorFilter: const ColorFilter.matrix(<double>[
          0.30, 0.10, 0.10, 0, -14,
          0.10, 0.28, 0.12, 0, -14,
          0.12, 0.14, 0.34, 0, -6,
          0, 0, 0, 1, 0,
        ]),
        child: img,
      ),
    );
  }
}

/// Il responso: prima la ruota e la statua, poi le parole.
class _Risultato extends StatefulWidget {
  const _Risultato({
    required this.palette,
    required this.profilo,
    required this.precedente,
    required this.storico,
    required this.transiti,
    required this.pianeti,
    required this.onTransiti,
  });

  final MaestroPalette palette;
  final ArchetypeProfile profilo;
  final ArchetypeEsito? precedente;
  final ArchetypeHistory storico;
  final bool transiti;
  final Set<Pianeta> pianeti;
  final ValueChanged<bool> onTransiti;

  @override
  State<_Risultato> createState() => _RisultatoState();
}

class _RisultatoState extends State<_Risultato>
    with SingleTickerProviderStateMixin {
  late final AnimationController _disegno = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void dispose() {
    _disegno.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Il profilo si disegna una volta sola. Con Riduci Movimento o Quality Tier
    // basso e' gia' tutto in posizione, senza animazione.
    if (ScrollReveal.motionOff(context)) {
      _disegno.value = 1.0;
    } else if (!_disegno.isAnimating && _disegno.value == 0) {
      _disegno.forward();
    }
  }

  ArchetypeModulazione? get _modulazione => widget.transiti
      ? ArchetypeTransits.applica(widget.profilo, widget.pianeti)
      : null;

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final mod = _modulazione;
    final mostrato = mod?.modulato ?? widget.profilo;
    final dom = mostrato.dominante;
    final ritratto = ArchetypeCorpus.di(dom);

    return SingleChildScrollView(
      key: const Key('archetype_result'),
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IL VISIVO PRIMA DEL TESTO: la ruota e la statua, poi il nome.
          Center(
            child: AnimatedBuilder(
              animation: _disegno,
              builder: (context, _) => Stack(
                alignment: Alignment.center,
                children: [
                  ArchetypeWheel(
                    profilo: mostrato,
                    palette: palette,
                    avanzamento: _disegno.value,
                    lato: 320,
                  ),
                  _Statua(archetipo: dom, lato: 150, palette: palette),
                ],
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          Center(
            child: Text(dom.nome,
                key: const Key('archetype_name'),
                style: TypographyTokens.display(size: 30)
                    .copyWith(color: palette.goldSoft)),
          ),
          Center(
            child: Text(ritratto.essenza,
                textAlign: TextAlign.center,
                style: TypographyTokens.body(size: 16).copyWith(
                    color: ColorTokens.textSecondary,
                    fontStyle: FontStyle.italic)),
          ),
          if (mostrato.secondo != null) ...[
            const SizedBox(height: SpacingTokens.sm),
            Center(
              child: Text(
                'Accanto a lui, in tono minore, ${mostrato.secondo!.nome}.',
                key: const Key('archetype_second'),
                textAlign: TextAlign.center,
                style: TypographyTokens.body(size: 14)
                    .copyWith(color: ColorTokens.textSecondary),
              ),
            ),
          ],
          const SizedBox(height: SpacingTokens.lg),

          _Paragrafo(
            chiave: 'archetype_luce',
            titolo: 'La sua luce',
            testo: ritratto.luce,
            palette: palette,
          ),

          // L'Ombra: la stessa statua, trattata.
          const SizedBox(height: SpacingTokens.md),
          DepthCard(
            key: const Key('archetype_ombra'),
            padding: const EdgeInsets.all(SpacingTokens.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Statua(
                    archetipo: dom, lato: 110, palette: palette, ombra: true),
                const SizedBox(width: SpacingTokens.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('La sua ombra',
                          style: TypographyTokens.label(size: 12).copyWith(
                              color: palette.goldSoft, letterSpacing: 0.6)),
                      const SizedBox(height: SpacingTokens.xs),
                      Text(ritratto.ombra,
                          style: TypographyTokens.body(size: 15).copyWith(
                              color: ColorTokens.textPrimary, height: 1.45)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: SpacingTokens.md),
          _Paragrafo(
            chiave: 'archetype_amore',
            titolo: 'In amore',
            testo: ritratto.amore,
            palette: palette,
          ),
          const SizedBox(height: SpacingTokens.md),
          _Paragrafo(
            chiave: 'archetype_lavoro',
            titolo: 'Nel lavoro',
            testo: ritratto.lavoro,
            palette: palette,
          ),

          const SizedBox(height: SpacingTokens.lg),
          _Transiti(
            palette: palette,
            acceso: widget.transiti,
            onCambia: widget.onTransiti,
            modulazione: mod,
          ),

          if (widget.precedente != null) ...[
            const SizedBox(height: SpacingTokens.lg),
            _Confronto(
              palette: palette,
              storico: widget.storico,
              precedente: widget.precedente!,
              adesso: widget.profilo,
            ),
          ],

          const SizedBox(height: SpacingTokens.lg),
          FilledButton.icon(
            key: const Key('archetype_consulta'),
            onPressed: () {
              final services = context.read<AppServices>();
              Navigator.of(context).push(MaestroChatScreen.route(
                  maestro: Maestro.aura, services: services));
            },
            icon: const Icon(Icons.forum_outlined),
            label: const Text('Parlane con Aura'),
          ),
          const SizedBox(height: SpacingTokens.xxxl),
        ],
      ),
    );
  }
}

class _Paragrafo extends StatelessWidget {
  const _Paragrafo({
    required this.chiave,
    required this.titolo,
    required this.testo,
    required this.palette,
  });

  final String chiave;
  final String titolo;
  final String testo;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: Key(chiave),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titolo,
            style: TypographyTokens.label(size: 12)
                .copyWith(color: palette.goldSoft, letterSpacing: 0.6)),
        const SizedBox(height: SpacingTokens.xs),
        Text(testo,
            style: TypographyTokens.body(size: 16)
                .copyWith(color: ColorTokens.textPrimary, height: 1.5)),
      ],
    );
  }
}

/// L'interruttore dei transiti, spento di partenza.
class _Transiti extends StatelessWidget {
  const _Transiti({
    required this.palette,
    required this.acceso,
    required this.onCambia,
    required this.modulazione,
  });

  final MaestroPalette palette;
  final bool acceso;
  final ValueChanged<bool> onCambia;
  final ArchetypeModulazione? modulazione;

  @override
  Widget build(BuildContext context) {
    final mod = modulazione;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          key: const Key('archetype_transits_switch'),
          value: acceso,
          onChanged: onCambia,
          contentPadding: EdgeInsets.zero,
          activeThumbColor: palette.goldSoft,
          title: Text('Lega ai transiti',
              style: TypographyTokens.display(size: 16)
                  .copyWith(color: ColorTokens.textPrimary)),
          subtitle: Text('Il cielo di oggi si accosta al tuo profilo.',
              style: TypographyTokens.body(size: 13)
                  .copyWith(color: ColorTokens.textSecondary)),
        ),
        if (mod != null) ...[
          Text(ArchetypeTransits.corniceSincronicita,
              key: const Key('archetype_synchronicity'),
              style: TypographyTokens.body(size: 13).copyWith(
                  color: ColorTokens.textSecondary,
                  height: 1.4,
                  fontStyle: FontStyle.italic)),
          const SizedBox(height: SpacingTokens.sm),
          for (final r in mod.motivazioni) ...[
            Padding(
              key: Key('archetype_transit_${r.pianeta.name}'),
              padding: const EdgeInsets.only(bottom: SpacingTokens.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.brightness_1, size: 7, color: palette.goldSoft),
                  const SizedBox(width: SpacingTokens.sm),
                  Expanded(
                    child: Text(r.testo,
                        style: TypographyTokens.body(size: 15).copyWith(
                            color: ColorTokens.textPrimary, height: 1.4)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ],
    );
  }
}

/// Il confronto con la volta prima, piu' la piccola timeline dei dominanti.
class _Confronto extends StatelessWidget {
  const _Confronto({
    required this.palette,
    required this.storico,
    required this.precedente,
    required this.adesso,
  });

  final MaestroPalette palette;
  final ArchetypeHistory storico;
  final ArchetypeEsito precedente;
  final ArchetypeProfile adesso;

  @override
  Widget build(BuildContext context) {
    final righe = storico.timeline;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Nel tempo',
            style: TypographyTokens.label(size: 12)
                .copyWith(color: palette.goldSoft, letterSpacing: 0.6)),
        const SizedBox(height: SpacingTokens.xs),
        Text(storico.confrontoCon(precedente, adesso) ?? '',
            key: const Key('archetype_comparison'),
            style: TypographyTokens.body(size: 15)
                .copyWith(color: ColorTokens.textPrimary, height: 1.45)),
        if (righe.length > 1) ...[
          const SizedBox(height: SpacingTokens.sm),
          SizedBox(
            key: const Key('archetype_timeline'),
            height: 74,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: righe.length,
              separatorBuilder: (_, __) => const SizedBox(width: SpacingTokens.sm),
              itemBuilder: (context, i) {
                final e = righe[i];
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _Statua(archetipo: e.dominante, lato: 44, palette: palette),
                    const SizedBox(height: 2),
                    Text('${e.quando.day}/${e.quando.month}',
                        style: TypographyTokens.label(size: 10).copyWith(
                            color: ColorTokens.textSecondary)),
                  ],
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
