import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/entitlement/entitlement_service.dart';
import '../../../core/entitlement/esito_del_turno.dart';
import '../../../core/entitlement/question_allowance.dart';
import '../../../core/identity/natal_identity.dart';
import '../../../core/identity/profile_controller.dart';
import '../../../core/maestro/consult_depth.dart';
import '../../../core/maestro/frase_di_ripiego.dart';
import '../../../core/maestro/maestro.dart';
import '../../../core/maestro/natal_context.dart';
import '../../../core/maestro/sorgente_natale.dart';
import '../../../design_system/components/consulto_del_cielo_view.dart';
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
import '../widgets/tre_volti.dart';

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
/// COME SI CHIAMA LA SCHERMATA DEL CONFRONTO.
///
/// Sta fuori dalla classe perche' una prova deve poterlo nominare senza
/// montare uno schermo, e perche' una regola dentro una classe privata non si
/// puo' nemmeno citare.
const String titoloDelConsiglio = 'Il Consiglio del Cerchio';

class AskMaestriScreen extends StatefulWidget {
  const AskMaestriScreen({
    super.key,
    required this.starter,
    this.oracle = const MaestroOracle(),
    this.temaIniziale,
    this.lentiIniziali = const [],
  });

  /// La domanda gia' posta nella chat. Con questa la schermata NON riparte da
  /// zero: e' arrivata qui per sintetizzare voci che esistono gia'.
  final String? temaIniziale;

  /// Le voci gia' ottenute nella conversazione, lette nei tre strati.
  final List<MaestroLens> lentiIniziali;

  /// Il Maestro del dominio, primo a rispondere.
  final Maestro starter;

  final MaestroOracle oracle;

  /// LA SINTESI DELLE VOCI GIA' OTTENUTE.
  ///
  /// **Questa schermata non si butta: diventa quello che e' davvero.** Prima
  /// era il posto dove si portava una domanda agli altri Maestri, e per farlo
  /// bisognava riscriverla da capo anche quando era gia' stata fatta. Adesso le
  /// altre voci arrivano nella conversazione, e qui si arriva soltanto quando
  /// ce ne sono almeno due da mettere a confronto, portandosele dietro.
  static Route<void> perLaSintesi({
    required Maestro starter,
    required String tema,
    required List<MaestroLens> lenti,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) => MaestroScope(
        maestro: starter,
        child: AskMaestriScreen(
          starter: starter,
          temaIniziale: tema,
          lentiIniziali: lenti,
        ),
      ),
    );
  }

  // IL COSTRUTTORE DI ROTTA SENZA TEMA E' STATO TOLTO.
  //
  // Apriva questa schermata da zero, con il campo in cima da riempire. Quella
  // porta non esisteva piu' nell'app da quando la bilancia e' sparita
  // dall'intestazione della chat, e teneva in vita meta' schermata che nessuno
  // poteva raggiungere. Si arriva qui in un modo solo, `perLaSintesi`.

  @override
  State<AskMaestriScreen> createState() => _AskMaestriScreenState();
}

class _AskMaestriScreenState extends State<AskMaestriScreen> {
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
  void initState() {
    super.initState();
    // Le voci arrivate dalla conversazione entrano gia' risolte: nessuna
    // chiamata rifatta, nessuna domanda riscritta.
    _theme = widget.temaIniziale;
    for (final lente in widget.lentiIniziali) {
      _responders.add(lente.maestro);
      _lenses[lente.maestro] = lente;
    }
    // LA DOMANDA ARRIVA DA FUORI, e non si riscrive qui.
    //
    // Il campo di scrittura in cima e' stato tolto il 5 agosto 2026: nel
    // confronto non si scrive, si legge e si sceglie con chi proseguire. Un
    // campo che sembra accettare una domanda e apre altro e' una promessa
    // rotta. Se la domanda c'e' ma nessuna voce e' ancora arrivata, la prima
    // se la chiede la schermata invece di aspettare che qualcuno la digiti.
    if (_theme != null && widget.lentiIniziali.isEmpty) {
      _responders.add(widget.starter);
      _loading.add(widget.starter);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        // IL LIMITE SI CONTROLLA ANCHE QUI.
        //
        // Prima lo controllava `_ask`, cioe' il bottone del campo di
        // scrittura: togliendo il campo il controllo sarebbe sparito con lui,
        // e la schermata avrebbe chiesto una voce a chi aveva finito le
        // domande. Il limite non e' del campo, e' della domanda.
        final piano = context.read<EntitlementService>().tier;
        if (!context.read<QuestionAllowance>().canAsk(piano)) {
          setState(() => _loading.remove(widget.starter));
          showUpgradeInvite(
            context,
            title: 'Hai posto le tue domande di oggi',
            message:
                'Col Cerchio le domande ai Maestri sono senza limiti e puoi '
                'metterne a confronto gli sguardi.',
          );
          return;
        }
        _fetchLens(widget.starter, _theme!, countsAgainstAllowance: true);
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Le lenti risolte, nell'ordine fisso del cerchio.
  List<MaestroLens> get _orderedLenses => [
        for (final m in Maestro.fixedOrder)
          if (_lenses[m] != null) _lenses[m]!,
      ];

  /// Il contesto natale reale, dai dati di nascita. Vuoto se la carta manca:
  /// personalizzazione col solo nome.
  NatalContext _natal() =>
      SorgenteNatale.daIdentita(context.read<BirthIdentityController>());

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
    // Si conta solo se il MAESTRO ha risposto davvero. Prima bastava che una
    // lente fosse consegnata, e una lente puo' essere il ripiego dell'oracolo:
    // il Consulta pagava i guasti esattamente come li pagava la chat.
    final esito =
        lens.ripiego ? EsitoDelTurno.ripiego : EsitoDelTurno.rispostaVera;
    if (countsAgainstAllowance && CostoDelTurno.consuma(esito)) {
      allowance.record(tier);
    }
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
        // SI CHIAMA PER QUELLO CHE FA, e non col nome del Maestro che si e'
        // appena lasciato: arrivandoci dalla chat, quel nome diceva di essere
        // tornati da lui mentre qui ci sono tutti e tre.
        //
        // **E non si chiama piu' "Le voci a confronto".** Quel nome conteneva
        // la parola che abbiamo appena tolto dai Maestri, dove "voce" e'
        // l'audio: qui non c'e' nessun audio, ci sono tre pareri. Il nome
        // nuovo dice CHI si esprime, non ruba il nome a nessuno dei tre, e non
        // nomina la voce.
        // IL TITOLO SI LEGGE INTERO, e non si accorcia il nome per farcelo
        // stare. A corpo 20 su schermo da 360 punti diventava "Il Consiglio
        // del Cerc...", cioe' un nome che nessuno riconosce: e' lo stesso
        // difetto gia' pagato con "Sintesi comparat...". Il rimpicciolimento
        // e' l'unica delle due cose che possiamo scegliere senza togliere
        // parole a chi ha scelto il nome.
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(titoloDelConsiglio,
              maxLines: 1, style: TypographyTokens.display(size: 20)),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              // NESSUNO STATO VUOTO: qui si arriva sempre con una domanda gia'
              // fatta, e senza campo per farne una non ci sarebbe niente da
              // invitare a fare. Un invito senza uscita e' un vicolo cieco.
              child: ListView(
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
                            if (_loading.contains(m)) ...[
                              // La stessa scena della chat, dallo stesso
                              // punto: le superfici che aspettano una risposta
                              // sono due, e una seconda copia divergerebbe.
                              ConsultoDelCieloView(natal: _natal(), maestro: m),
                              _LensLoadingCard(maestro: m),
                            ]
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
              // I TRE VOLTI, non una bilancia.
              //
              // Qui c'era `Icons.balance`, tolta dall'intestazione della chat
              // perche' il fondatore ci aveva letto il SEGNO della Bilancia, e
              // rimasta qui con la motivazione che in questo contesto
              // significa confronto. Il significato di un simbolo non lo
              // decide il contesto nella testa di chi disegna: lo decide
              // l'occhio di chi guarda. Su una card che parla di lettura
              // astrologica il rischio e' piu' alto, non piu' basso.
              // La misura non e' un gusto, e' una misura. I tre volti sono
              // piu' larghi di un'icona: a 24 il titolo diventava "Sintesi
              // comparat...", visto nell'anteprima e non dedotto. Lo spazio interno
              // della card e' 262 punti, il titolo ne chiede 206,8, i volti a
              // 18 ne occupano 42 piu' 8 di stacco: restano 212. La prova
              // "Il titolo della Sintesi si legge intero" li rimisura.
              //
              // Via anche i puntini: `maxLines: 1` con l'ellissi tagliava il
              // titolo in silenzio, e in un'altra lingua taglierebbe ancora.
              // Senza, il peggio che puo' capitare e' che vada a capo, cioe'
              // che si legga tutto lo stesso.
              const TreVolti(misura: 18),
              const SizedBox(width: SpacingTokens.xs),
              Expanded(
                child: Text('Sintesi comparativa',
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
          // NON SI DISEGNA CIO' CHE NON C'E'.
          //
          // Gli strati erano disegnati sempre, e con una lente che ne porta
          // meno di tre a schermo restavano una riga bianca e una freccia
          // senza niente accanto. Capita alle voci che arrivano dalla
          // conversazione, dove una risposta breve non ha tre parti da
          // distinguere, e capitava gia' a una lente dell'oracolo con un
          // campo vuoto: e' la stessa correzione per tutte e due.
          if (lens.glance.trim().isNotEmpty) ...[
            const SizedBox(height: SpacingTokens.sm),
            Text(lens.glance,
                style: TypographyTokens.body(size: 15).copyWith(
                  color: palette.goldSoft,
                  fontStyle: FontStyle.italic,
                  height: 1.35,
                )),
          ],
          const SizedBox(height: SpacingTokens.sm),
          Text(lens.reading,
              style: TypographyTokens.body(size: 14)
                  .copyWith(color: ColorTokens.textPrimary, height: 1.4)),
          if (lens.invite.trim().isNotEmpty) ...[
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
                    RipiegoDelMaestro.etichettaDi(lens.maestro),
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
