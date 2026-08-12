import 'dart:async';
import 'package:flutter/material.dart';
import '../../../sigilli/regia_del_cammino.dart';
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
import '../../../../design_system/tokens/color_tokens.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';
import '../../../../design_system/typography/paragrafi_di_lettura.dart';
import '../../../../services/app_services.dart';
import '../../chat/chat_openers.dart';
import '../../chat/maestro_chat_screen.dart';
import 'archetype_share_card.dart';
import 'archetype_wheel.dart';
import '../../rotta_arte.dart';
import '../../../../design_system/components/interruttore_del_cerchio.dart';
import '../../../../design_system/components/titolo_che_non_si_rompe.dart';

/// Il Test Archetipo, dominio Aura.
///
/// Il calcolo e' tutto nel cuore deterministico (`ArchetypeScoring`,
/// `ArchetypeTransits`, `ArchetypeAllowance`), qui c'e' solo la messa in scena:
/// nessuna AI, nessuna casualita'. La schermata sta sul cosmo condiviso in
/// parallasse, come i domini, e gli elementi si rivelano scorrendo.
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
      builder: (_) => SogliaArte(
        id: 'archetype_test',
        maestro: Maestro.aura,
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

  /// LO STORICO E' QUELLO DI TUTTI, non uno suo.
  ///
  /// Qui c'era `ArchetypeHistory(clock: _clock)`, cioe' una SECONDA COPIA del
  /// dato. Il Test scriveva nella sua, la chat e il Passaporto leggevano
  /// quella del fornitore, e le due si incontravano solo su disco: fatto il
  /// Test, Aura continuava a mostrare il loto finche' l'app non veniva
  /// riaperta. Il difetto non era nel simbolo ne' nell'emblema, era che il
  /// dato esisteva due volte.
  ///
  /// **E non ne resta una "per comodita' di prova".** Chi monta questa
  /// schermata fornisce lo storico, in produzione come in prova: e' l'unico
  /// modo perche' l'orologio finto delle prove governi lo stesso oggetto che
  /// governa l'app.
  ArchetypeHistory get _storico => context.read<ArchetypeHistory>();

  _Fase _fase = _Fase.soglia;
  int _indice = 0;
  final List<int> _scelte = [];

  ArchetypeProfile? _profilo;
  ArchetypeEsito? _precedente;

  /// La scelta col cielo di oggi: si fa PRIMA delle domande, come impostazione
  /// del test, e poi si puo' ribaltare a vivo sul responso.
  bool _conCielo = false;
  bool _pronto = false;

  @override
  void initState() {
    super.initState();
    _storico.carica().then((_) {
      if (!mounted) return;
      setState(() => _pronto = true);
    });
  }

  // NESSUN dispose dello storico: non e' di questa schermata, e chiuderlo
  // uscendo dal Test spegnerebbe il dato anche per la chat e il Passaporto.

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
    // IL TEST ARCHETIPO ENTRA NEL CAMMINO, ordine P voce 35: il profilo e'
    // calcolato e registrato, il gesto e' compiuto.
    unawaited(RegiaDelCammino.dopoUnGesto(context, 'archetipo'));
  }

  Set<Pianeta> get _pianeti {
    final f = widget.pianetiDelGiorno ?? ArchetypeSky.pianetiDelGiorno;
    return f(_clock());
  }

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.aura));
    // SI ASCOLTA lo storico condiviso: registrato un esito nuovo, la soglia e
    // il conteggio di oggi si rifanno da soli. Prima la copia privata
    // notificava solo questa schermata, e nessun altro sapeva niente.
    context.watch<ArchetypeHistory>();
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: BarraArte(
        // Lo stesso titolo di tutte le arti: va a capo fra le parole e non si
        // rompe, qualunque cosa cresca nelle azioni accanto.
        titolo: TitoloCheNonSiRompe(
            testo: 'Test Archetipo',
            stile: TypographyTokens.titoloScheda()),
        azioni: [
          IconButton(
            key: const Key('archetype_sources'),
            icon: const Icon(Icons.info_outline_rounded),
            tooltip: 'Fonti e metodo',
            onPressed: () => _mostraFonti(context, palette),
          ),
        ],
      ),
      // Il cosmo condiviso in parallasse, non un fondale suo. Verde di Aura.
      body: CosmosBackground(
        seed: 7,
        showZodiac: false,
        child: SafeArea(
          child: !_pronto
              ? const SizedBox.shrink()
              : switch (_fase) {
                  _Fase.soglia => _Soglia(
                      palette: palette,
                      consentito: _consentito,
                      rimanenti: ArchetypeAllowance.rimanenti(
                          fattiOggi: _storico.fattiOggi, tier: _tier),
                      ultimo: _storico.ultimo,
                      conCielo: _conCielo,
                      onCielo: (v) => setState(() => _conCielo = v),
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
                      conCielo: _conCielo,
                      pianeti: _pianeti,
                      onCielo: (v) => setState(() => _conCielo = v),
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
                  style: TypographyTokens.titoloScheda()
                      .copyWith(color: palette.goldSoft)),
              const SizedBox(height: SpacingTokens.sm),
              Text(ArchetypeCorpus.fontiEMetodo,
                  style: TypographyTokens.didascalia().copyWith(
                      color: ColorTokens.textPrimary, height: 1.45)),
              const SizedBox(height: SpacingTokens.lg),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(sheet).pop(),
                  child: Text('Va bene',
                      style: TypographyTokens.etichetta()
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

/// La soglia: si entra da qui, si sceglie il cielo di oggi PRIMA di iniziare, e
/// da qui si vede se il test e' consentito.
class _Soglia extends StatelessWidget {
  const _Soglia({
    required this.palette,
    required this.consentito,
    required this.rimanenti,
    required this.ultimo,
    required this.conCielo,
    required this.onCielo,
    required this.onInizia,
  });

  final MaestroPalette palette;
  final bool consentito;
  final int? rimanenti;
  final ArchetypeEsito? ultimo;
  final bool conCielo;
  final ValueChanged<bool> onCielo;
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
              style: TypographyTokens.cerimoniale()
                  .copyWith(color: palette.goldSoft)),
          const SizedBox(height: SpacingTokens.sm),
          Text(
            'Dodici domande, una alla volta. Rispondi di pancia: non ci sono '
            'risposte giuste, ci sono risposte tue.',
            style: TypographyTokens.corpo()
                .copyWith(color: ColorTokens.textPrimary, height: 1.5),
          ),
          const SizedBox(height: SpacingTokens.lg),
          // La scelta del cielo, PRIMA delle domande, come impostazione del test.
          DepthCard(
            padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.md, vertical: SpacingTokens.xs),
            child: InterruttoreDelCerchio(
              key: const Key('archetype_sky_setting'),
              acceso: conCielo,
              onCambia: onCielo,
              titolo: 'Lega al cielo di oggi',
              sottotitolo: 'I transiti del giorno si accostano al tuo profilo, come '
                  'sincronicità.',
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),
          if (consentito)
            FilledButton.icon(
              key: const Key('archetype_start'),
              style: FilledButton.styleFrom(
                  backgroundColor: palette.primary,
                  foregroundColor: palette.onPrimary),
              onPressed: onInizia,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Comincia'),
            )
          else
            _Bloccato(palette: palette, ultimo: ultimo),
          if (consentito && rimanenti != null) ...[
            const SizedBox(height: SpacingTokens.sm),
            Text(rimanenti == 1 ? 'Ne hai uno oggi.' : 'Ne hai $rimanenti oggi.',
                style: TypographyTokens.etichetta()
                    .copyWith(color: ColorTokens.textSecondary)),
          ],
        ],
      ),
    );
  }
}

/// Limite raggiunto: mai un vicolo cieco, si mostra l'ultimo esito salvato.
class _Bloccato extends StatelessWidget {
  const _Bloccato({required this.palette, required this.ultimo});

  final MaestroPalette palette;
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
                style: TypographyTokens.didascalia()
                    .copyWith(color: ColorTokens.textPrimary, height: 1.4),
              ),
            ),
          ],
        ),
        if (ultimo != null) ...[
          const SizedBox(height: SpacingTokens.lg),
          Text('Il tuo ultimo responso',
              style: TypographyTokens.etichetta()
                  .copyWith(color: palette.goldSoft, letterSpacing: 0.6)),
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
                      Text(ultimo!.dominante.conArticolo,
                          style: TypographyTokens.titoloSezione()
                              .copyWith(color: palette.goldSoft)),
                      const SizedBox(height: 2),
                      Text(ArchetypeCorpus.di(ultimo!.dominante).essenza,
                          style: TypographyTokens.didascalia().copyWith(
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
              style: TypographyTokens.etichetta()
                  .copyWith(color: palette.goldSoft, letterSpacing: 1.0)),
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
              style: TypographyTokens.titoloSezione()
                  .copyWith(color: ColorTokens.textPrimary, height: 1.3)),
          const SizedBox(height: SpacingTokens.lg),
          // Solo il testo della risposta: l'etichetta archetipo non si vede mai,
          // perche' vederla cambierebbe la scelta.
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
                        style: TypographyTokens.corpo()
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
/// freddo. Non e' un'immagine nuova, perche' l'Ombra non e' un personaggio
/// nuovo ma lo stesso archetipo nel suo lato distorto.
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

/// Il responso. L'ordine dall'alto: sottotitolo di modalita', statua, ruota,
/// nome, essenza, co-dominante, Luce, le tre stanze (Amore, Lavoro,
/// Quotidianita'), Ombra, transiti, classifica dei dodici, pulsanti. Il visivo
/// prima del testo.
class _Risultato extends StatefulWidget {
  const _Risultato({
    required this.palette,
    required this.profilo,
    required this.precedente,
    required this.storico,
    required this.conCielo,
    required this.pianeti,
    required this.onCielo,
  });

  final MaestroPalette palette;
  final ArchetypeProfile profilo;
  final ArchetypeEsito? precedente;
  final ArchetypeHistory storico;
  final bool conCielo;
  final Set<Pianeta> pianeti;
  final ValueChanged<bool> onCielo;

  @override
  State<_Risultato> createState() => _RisultatoState();
}

class _RisultatoState extends State<_Risultato>
    with SingleTickerProviderStateMixin {
  late final AnimationController _disegno = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  final GlobalKey _cardBoundary = GlobalKey();

  /// La statua voltata nella sua Ombra al tocco, come rivelazione tattile.
  bool _statuaVoltata = false;
  bool _condividendo = false;
  bool _renderCard = false;

  @override
  void dispose() {
    _disegno.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ScrollReveal.motionOff(context)) {
      _disegno.value = 1.0;
    } else if (!_disegno.isAnimating && _disegno.value == 0) {
      _disegno.forward();
    }
  }

  ArchetypeModulazione? get _modulazione => widget.conCielo
      ? ArchetypeTransits.applica(widget.profilo, widget.pianeti)
      : null;

  Future<void> _condividi(ArchetypeProfile profilo) async {
    setState(() {
      _condividendo = true;
      _renderCard = true;
    });
    try {
      await WidgetsBinding.instance.endOfFrame;
      await Future<void>.delayed(const Duration(milliseconds: 80));
      await shareArchetypeCard(
          boundaryKey: _cardBoundary, dominante: profilo.dominante);
    } finally {
      if (mounted) setState(() => _condividendo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final mod = _modulazione;

    // LA FIGURA E' QUELLA DEL TEST, E IL CIELO NON LA RIELEGGE.
    //
    // Qui c'era `mod?.modulato ?? widget.profilo`, cioe' il dominante
    // RICALCOLATO coi transiti del giorno: acceso l'interruttore, la statua, il
    // nome e il ritratto potevano diventare quelli di un altro archetipo.
    // Intanto lo storico registrava, e ha sempre registrato, il profilo BASE:
    // la stessa persona poteva leggere "sei il Mago" sul responso e trovare
    // l'Eroe nel Passaporto. Non era una svista di visualizzazione, era l'app
    // che le diceva che oggi e' un'altra persona, e nessun documento di
    // identita' funziona cosi'.
    //
    // L'archetipo e' identitario e fisso: cambia quando si rifa' il Test, mai
    // col cielo del giorno. Anche il co-dominante resta quello del Test,
    // perche' sta nella stessa frase che dice chi si e'.
    // Il profilo COME IL TEST LO HA CALCOLATO. Il nome dice da dove
    // viene, e non "identita", che dentro una stringa mostrata verrebbe letto
    // come una parola italiana a cui manca l'accento.
    final delTest = widget.profilo;
    final dom = delTest.dominante;
    final ritratto = ArchetypeCorpus.di(dom);

    // I TRANSITI RESTANO, DOVE GLI COMPETE: nelle percentuali, quindi nella
    // ruota e nella classifica, che raccontano come le corde vibrano oggi.
    // Quello e' il posto giusto, perche' li' si legge un movimento e non
    // un'identita'.
    final percentuali = mod?.modulato ?? widget.profilo;

    return Stack(
      children: [
        SingleChildScrollView(
          key: const Key('archetype_result'),
          padding: const EdgeInsets.all(SpacingTokens.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Il sottotitolo che dichiara la modalita', legato all'interruttore
              // dei transiti: dice solo se il responso e' legato al cielo o no.
              Center(
                child: Text(
                  widget.conCielo
                      ? 'legato ai transiti astrologici di oggi'
                      : 'non legato ai transiti astrologici',
                  key: const Key('archetype_mode_subtitle'),
                  textAlign: TextAlign.center,
                  style: TypographyTokens.etichetta().copyWith(
                      color: palette.goldSoft, letterSpacing: 1.0),
                ),
              ),
              const SizedBox(height: SpacingTokens.md),

              // LA STATUA, sopra la ruota. Al tocco si volta nell'Ombra.
              ScrollReveal(
                child: Center(
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _statuaVoltata = !_statuaVoltata),
                    child: _Statua(
                      archetipo: dom,
                      lato: 180,
                      palette: palette,
                      ombra: _statuaVoltata,
                    ),
                  ),
                ),
              ),

              // LA RUOTA, senza statua dentro.
              ScrollReveal(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _disegno,
                    builder: (context, _) => ArchetypeWheel(
                      profilo: percentuali,
                      palette: palette,
                      avanzamento: _disegno.value,
                      lato: 340,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: SpacingTokens.md),

              // IL NOME con l'articolo, poi l'essenza, poi il co-dominante.
              Center(
                child: Text(dom.conArticolo.toUpperCase(),
                    key: const Key('archetype_name'),
                    style: TypographyTokens.cerimoniale()
                        .copyWith(color: palette.goldSoft)),
              ),
              Center(
                // L'essenza dell'archetipo e' il responso del Test: ruolo
                // lettura e regola comune dei paragrafi.
                child: ParagrafiDiLettura(
                    testo: ritratto.essenza,
                    textAlign: TextAlign.center,
                    stile: TypographyTokens.lettura().copyWith(
                        color: ColorTokens.textSecondary,
                        fontStyle: FontStyle.italic)),
              ),
              if (delTest.secondo != null) ...[
                const SizedBox(height: SpacingTokens.xs),
                Center(
                  child: Text('Accanto, in tono minore, ${delTest.secondo!.conArticolo}.',
                      key: const Key('archetype_second'),
                      textAlign: TextAlign.center,
                      style: TypographyTokens.didascalia()
                          .copyWith(color: ColorTokens.textSecondary)),
                ),
              ],
              const SizedBox(height: SpacingTokens.lg),

              // LA LUCE, testo lungo in una bolla.
              ScrollReveal(
                depth: 1,
                child: DepthCard(
                  key: const Key('archetype_luce'),
                  raised: true,
                  padding: const EdgeInsets.all(SpacingTokens.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('La sua luce',
                          style: TypographyTokens.etichetta().copyWith(
                              color: palette.goldSoft, letterSpacing: 0.6)),
                      const SizedBox(height: SpacingTokens.xs),
                      Text(ritratto.luce,
                          style: TypographyTokens.corpo().copyWith(
                              color: ColorTokens.textPrimary, height: 1.55)),
                    ],
                  ),
                ),
              ),

              // LE TRE STANZE DELLA VITA, sopra l'Ombra: come l'archetipo vive
              // in amore, nel lavoro, nella quotidianita'. Ognuna una bolla con
              // etichetta oro.
              const SizedBox(height: SpacingTokens.md),
              ScrollReveal(
                depth: 1,
                child: _Bolla(
                  chiave: 'archetype_amore',
                  titolo: 'In amore',
                  testo: ritratto.amore,
                  palette: palette,
                ),
              ),
              const SizedBox(height: SpacingTokens.md),
              ScrollReveal(
                depth: 1,
                child: _Bolla(
                  chiave: 'archetype_lavoro',
                  titolo: 'Nel lavoro',
                  testo: ritratto.lavoro,
                  palette: palette,
                ),
              ),
              const SizedBox(height: SpacingTokens.md),
              ScrollReveal(
                depth: 1,
                child: _Bolla(
                  chiave: 'archetype_quotidianita',
                  titolo: 'Nella quotidianità',
                  testo: ritratto.quotidianita,
                  palette: palette,
                ),
              ),

              // L'OMBRA, la stessa statua trattata.
              const SizedBox(height: SpacingTokens.md),
              ScrollReveal(
                depth: 1,
                child: DepthCard(
                  key: const Key('archetype_ombra'),
                  padding: const EdgeInsets.all(SpacingTokens.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Statua(
                          archetipo: dom,
                          lato: 110,
                          palette: palette,
                          ombra: true),
                      const SizedBox(width: SpacingTokens.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('La sua ombra',
                                style: TypographyTokens.etichetta().copyWith(
                                    color: palette.goldSoft, letterSpacing: 0.6)),
                            const SizedBox(height: SpacingTokens.xs),
                            Text(ritratto.ombra,
                                style: TypographyTokens.didascalia().copyWith(
                                    color: ColorTokens.textPrimary, height: 1.45)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: SpacingTokens.lg),
              // L'interruttore vivo: rilegge il profilo col cielo o senza, senza
              // rifare il test, perche' la modulazione e' deterministica.
              _Transiti(
                palette: palette,
                acceso: widget.conCielo,
                onCambia: widget.onCielo,
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

              // La classifica dei dodici, discreta, appena sopra i pulsanti:
              // ogni archetipo con la sua percentuale e la statuina nel cerchio.
              const SizedBox(height: SpacingTokens.lg),
              ScrollReveal(
                depth: 1,
                child: _ClassificaPercentuali(
                    profilo: percentuali, palette: palette),
              ),

              const SizedBox(height: SpacingTokens.lg),
              OutlinedButton.icon(
                key: const Key('archetype_share'),
                style: OutlinedButton.styleFrom(
                    foregroundColor: palette.goldSoft,
                    side: BorderSide(color: palette.gold.withValues(alpha: 0.6))),
                onPressed:
                    _condividendo ? null : () => _condividi(delTest),
                icon: const Icon(Icons.ios_share_rounded),
                label: const Text('Condividi'),
              ),
              const SizedBox(height: SpacingTokens.sm),
              // L'EMBLEMA E' GIA' NEL PASSAPORTO, e lo si dice qui dentro.
              //
              // Dentro la scena e non in un avviso di sistema: un riquadro che
              // scavalca il responso per annunciare un salvataggio tratta la
              // persona come un utente a cui e' andata bene un'operazione. Qui
              // e' l'ultima riga di cio' che ha appena scoperto, e dice dove
              // quella figura la ritrovera' senza rifare niente.
              Center(
                child: Text(
                  'La tua figura è nel Passaporto, con la data di oggi.',
                  key: const Key('archetype_passaporto_aggiornato'),
                  textAlign: TextAlign.center,
                  style: TypographyTokens.didascalia().copyWith(
                      color: ColorTokens.textSecondary,
                      fontStyle: FontStyle.italic),
                ),
              ),
              const SizedBox(height: SpacingTokens.sm),
              // Il pulsante alla Consulta, nel VERDE di Aura.
              FilledButton.icon(
                key: const Key('archetype_consulta'),
                style: FilledButton.styleFrom(
                    backgroundColor: palette.primary,
                    foregroundColor: palette.onPrimary),
                onPressed: () {
                  final services = context.read<AppServices>();
                  Navigator.of(context).push(MaestroChatScreen.route(
                      maestro: Maestro.aura,
                      services: services,
                      initialUserMessage:
                          ChatOpeners.archetipo(dom.conArticolo)));
                },
                icon: const Icon(Icons.forum_outlined),
                label: const Text('Parlane con Aura'),
              ),
              const SizedBox(height: SpacingTokens.xxxl),
            ],
          ),
        ),
        // La card da condividere, fuori campo: si renderizza solo al bisogno.
        if (_renderCard)
          Positioned(
            left: -3000,
            top: 0,
            child: RepaintBoundary(
              key: _cardBoundary,
              child: ArchetypeShareCard(profilo: delTest),
            ),
          ),
      ],
    );
  }
}

/// Una bolla di vita: etichetta oro e testo lungo, come la bolla della Luce.
class _Bolla extends StatelessWidget {
  const _Bolla({
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
    return DepthCard(
      key: Key(chiave),
      raised: true,
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titolo,
              style: TypographyTokens.etichetta()
                  .copyWith(color: palette.goldSoft, letterSpacing: 0.6)),
          const SizedBox(height: SpacingTokens.xs),
          Text(testo,
              style: TypographyTokens.corpo()
                  .copyWith(color: ColorTokens.textPrimary, height: 1.55)),
        ],
      ),
    );
  }
}

/// La classifica dei dodici archetipi, per percentuale decrescente. Sola
/// lettura: nessuna freccia, nessun tap, solo il quadro d'insieme del test. La
/// statuina sta in un cerchio prima del nome, e a destra la percentuale.
class _ClassificaPercentuali extends StatelessWidget {
  const _ClassificaPercentuali({required this.profilo, required this.palette});

  final ArchetypeProfile profilo;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    final ordinati = profilo.graduatoria;
    return Column(
      key: const Key('archetype_ranking'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('I dodici in te',
            style: TypographyTokens.etichetta()
                .copyWith(color: palette.goldSoft, letterSpacing: 0.6)),
        const SizedBox(height: SpacingTokens.sm),
        for (final a in ordinati) ...[
          _RigaClassifica(
            archetipo: a,
            percentuale: profilo.percentualeDi(a).round(),
            dominante: a == profilo.dominante,
            palette: palette,
          ),
          if (a != ordinati.last) const SizedBox(height: SpacingTokens.xs),
        ],
      ],
    );
  }
}

/// Una riga della classifica: cerchio con statuina, nome, percentuale. Riga
/// singola, non interattiva.
class _RigaClassifica extends StatelessWidget {
  const _RigaClassifica({
    required this.archetipo,
    required this.percentuale,
    required this.dominante,
    required this.palette,
  });

  final Archetype archetipo;
  final int percentuale;
  final bool dominante;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return DepthCard(
      key: Key('archetype_rank_${archetipo.name}'),
      padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.sm, vertical: SpacingTokens.xs),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: palette.surface.withValues(alpha: 0.6),
              border: Border.all(
                color: dominante
                    ? palette.goldSoft
                    : palette.gold.withValues(alpha: 0.3),
                width: dominante ? 1.5 : 1,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              archetipo.arteThumb,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Icon(Icons.person_outline_rounded,
                  size: 18, color: palette.goldSoft),
            ),
          ),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: Text(archetipo.nome,
                style: TypographyTokens.didascalia().copyWith(
                    color: dominante
                        ? palette.goldSoft
                        : ColorTokens.textPrimary,
                    fontWeight:
                        dominante ? FontWeight.w700 : FontWeight.w400)),
          ),
          Text('$percentuale%',
              style: TypographyTokens.etichetta().copyWith(
                  color: dominante
                      ? palette.goldSoft
                      : ColorTokens.textSecondary,
                  letterSpacing: 0.5)),
        ],
      ),
    );
  }
}

/// L'interruttore vivo dei transiti, sul responso.
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
        InterruttoreDelCerchio(
          key: const Key('archetype_transits_switch'),
          acceso: acceso,
          onCambia: onCambia,
          titolo: 'Lega ai transiti',
          sottotitolo: 'Il cielo di oggi si accosta al tuo profilo.',
        ),
        if (mod != null) ...[
          Text(ArchetypeTransits.corniceSincronicita,
              key: const Key('archetype_synchronicity'),
              style: TypographyTokens.didascalia().copyWith(
                  color: ColorTokens.textSecondary,
                  height: 1.4,
                  fontStyle: FontStyle.italic)),
          const SizedBox(height: SpacingTokens.sm),
          // LA FIGURA CHE IL CIELO ACCENDE OGGI, in una riga e dentro il testo.
          //
          // E' cio' che resta di una scelta scartata. Prima il transito
          // RIELEGGEVA il dominante e cambiava statua, nome e ritratto; poi si
          // era pensato di mostrare due figure accanto, ciascuna con la sua
          // statua. Anche quella e' stata scartata, perche' due protagonisti
          // nel punto in cui la persona cerca una risposta secca sono la
          // stessa ambiguita' che si voleva togliere. Resta una riga, che
          // dichiara cosa sta succedendo oggi senza toccare chi si e'.
          if (mod.modulato.dominante != mod.base.dominante) ...[
            Text(
              'Oggi il cielo accende in te ${mod.modulato.dominante.conArticolo}, '
              'che non prende il posto della tua figura: la affianca per un giorno.',
              key: const Key('archetype_figura_del_giorno'),
              style: TypographyTokens.didascalia().copyWith(
                  color: palette.goldSoft, height: 1.4),
            ),
            const SizedBox(height: SpacingTokens.sm),
          ],
          for (final r in mod.motivazioni)
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
                        style: TypographyTokens.didascalia().copyWith(
                            color: ColorTokens.textPrimary, height: 1.4)),
                  ),
                ],
              ),
            ),
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
            style: TypographyTokens.etichetta()
                .copyWith(color: palette.goldSoft, letterSpacing: 0.6)),
        const SizedBox(height: SpacingTokens.xs),
        Text(storico.confrontoCon(precedente, adesso) ?? '',
            key: const Key('archetype_comparison'),
            style: TypographyTokens.didascalia()
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
                        style: TypographyTokens.etichetta()
                            .copyWith(color: ColorTokens.textSecondary)),
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
