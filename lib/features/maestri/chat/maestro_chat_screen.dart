import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import '../../../core/entitlement/question_allowance.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/chat/immersive_intents.dart';
import '../../../core/entitlement/entitlement_service.dart';
import '../../../core/entitlement/tier.dart';
import '../../../core/identity/natal_identity.dart';
import '../../../core/lang/euphonic.dart';
import '../../../core/maestro/maestro.dart';
import '../../../core/maestro/maestro_welcome.dart';
import '../../../core/maestro/natal_context.dart';
import '../../../core/chat/scorrimento_della_lettura.dart';
import '../../../core/maestro/tempi_dell_attesa.dart';
import '../../../core/maestro/sorgente_natale.dart';
import '../../../design_system/components/consulto_del_cielo_view.dart';
import '../../../design_system/components/cosmos_background.dart';
import '../../../design_system/theme/maestro_palette.dart';
import '../../../design_system/theme/maestro_scope.dart';
import '../../../design_system/tokens/color_tokens.dart';
import '../../../design_system/tokens/spacing_tokens.dart';
import '../../../design_system/tokens/typography_tokens.dart';
import '../../../services/app_services.dart';
import '../../pricing/upgrade_invite.dart';
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
      // Il contesto della rotta, non quello del builder interno: da qui si
      // leggono il contatore delle domande e il piano attivo, che senza
      // questo passaggio la chat non vedrebbe mai.
      builder: (rotta) => ChangeNotifierProvider<MaestroChatController>(
        create: (_) => MaestroChatController(
          maestro: maestro,
          ai: services.ai,
          memory: services.memory,
          allowance: rotta.read<QuestionAllowance>(),
          tier: () => rotta.read<EntitlementService>().tier,
          // Il cielo della persona arriva al Maestro. Una funzione, non un
          // valore: chi completa i dati di nascita mentre la chat e' aperta
          // deve essere riconosciuto al turno dopo.
          natal: () => SorgenteNatale.daIdentita(
              rotta.read<BirthIdentityController>()),
        )..init(),
        // La chat appartiene a UN Maestro, quindi il suo colore e' il suo e non
        // quello di chi era attivo un istante prima. Senza questo `maestro:` lo
        // scope seguiva `MaestroController`, e chi apriva la chat da una strada
        // che non passa dal Santuario vedeva le bolle nel viola della palette
        // neutra invece che nel blu di Medora. E' lo stesso difetto gia'
        // corretto nell'Oroscopo, e la correzione e' la stessa.
        child: MaestroScope(
          maestro: maestro,
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

  /// L'ultima bolla del Maestro, per poterne misurare la posizione vera invece
  /// di stimarla: e' l'oggetto di cui va portato l'INIZIO dentro lo schermo.
  final GlobalKey _chiaveUltimaRisposta = GlobalKey();

  /// La lista stessa, per misurarne la cima senza doverla dedurre.
  ///
  /// **Ipotesi caduta, e vale scriverla.** La cima risultava 321 punti dove la
  /// lista comincia a 89, e l'ipotesi era che la finestra di scorrimento avesse
  /// un'origine diversa dal riquadro visibile. Non era quello: la misura si
  /// prendeva mentre la scena del consulto occupava ancora lo spazio sopra, e
  /// in quel momento la lista cominciava DAVVERO a 321. Con la misura presa a
  /// dissolvenza finita, `RenderAbstractViewport` da' lo stesso numero di
  /// questa chiave, verificato con la prova del rosso. Questa chiave resta
  /// perche' misurare la cosa che si vuole misurare e' piu' chiaro che dedurla,
  /// non perche' l'altra strada sbagliasse.
  final GlobalKey _chiaveDellaLista = GlobalKey();

  /// L'attesa della dissolvenza prima di misurare, tenuta per poterla ANNULLARE.
  ///
  /// Non basta controllare `mounted` dentro: il timer resta pendente lo stesso,
  /// e chiudere la chat mentre una risposta arriva lo lasciava vivo. Se ne e'
  /// accorta la cattura delle anteprime, che non c'entrava niente.
  Timer? _attesaDellaMisura;
  bool _disclaimerHandled = false;
  bool _initialSent = false;

  /// La firma del turno, e non piu' il solo conteggio dei messaggi.
  ///
  /// Col conteggio non funzionava: inviando si aggiungono DUE messaggi, la
  /// domanda e la bolla in sospeso, e quando la risposta arriva **la bolla in
  /// sospeso viene SOSTITUITA**, quindi il numero non cambia. L'arrivo della
  /// risposta, cioe' il momento in cui lo scorrimento conta davvero, era
  /// l'unico che il vecchio controllo non vedeva.
  String _firmaDelTurno = '';

  /// Vero quando l'ultima risposta e' arrivata ADESSO, e quindi va scritta
  /// sotto gli occhi. Falso su una cronologia riaperta: chi torna su una
  /// conversazione di ieri vuole rileggerla, non guardarla riscriversi.
  bool _scriviLUltima = false;

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
    _attesaDellaMisura?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  /// Porta la conversazione sull'ultimo turno.
  ///
  /// La lista e' rovesciata, quindi "la fine" e' l'offset zero e non
  /// `maxScrollExtent`. Vedi la nota sul rovesciamento in `_buildBody`.
  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.minScrollExtent,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOut,
      );
    });
  }

  /// Porta l'INIZIO della risposta appena arrivata dentro lo schermo.
  ///
  /// Si misura la bolla vera con la sua chiave, non si stima: l'altezza di una
  /// risposta dipende da quante parole ha scritto il modello, quindi qualunque
  /// numero scritto a mano sarebbe sbagliato per la maggior parte delle
  /// risposte. Se la bolla non fosse ancora disegnata si torna in fondo, che e'
  /// il comportamento di prima: peggiore, ma dichiarato qui e non silenzioso.
  void _scorriAllInizioDellaRisposta() {
    // SI ASPETTA CHE LA SCENA DEL CONSULTO SIA SPARITA DEL TUTTO.
    //
    // Misurato: calcolando subito, la lista risultava cominciare a 321 punti
    // invece che a 89, perche' la scena dell'attesa stava ancora occupando lo
    // spazio sopra mentre si dissolve. Il conto era giusto su una geometria
    // che stava per cambiare, e la risposta finiva a 417 punti dall'alto
    // invece che a 96. Si misura quando la geometria e' quella definitiva.
    _attesaDellaMisura?.cancel();
    _attesaDellaMisura = Timer(TempiDellAttesa.dissolvenza, () {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      final contesto = _chiaveUltimaRisposta.currentContext;
      final riquadro = contesto?.findRenderObject();
      if (riquadro is! RenderBox || !riquadro.hasSize) {
        _scrollToEnd();
        return;
      }
      final lista = _chiaveDellaLista.currentContext?.findRenderObject();
      if (lista is! RenderBox || !lista.hasSize) {
        _scrollToEnd();
        return;
      }
      _scroll.animateTo(
        ScorrimentoDellaLettura.bersaglio(
          offsetAttuale: _scroll.offset,
          cimaDellaRisposta: riquadro.localToGlobal(Offset.zero).dy,
          cimaDellaLista: lista.localToGlobal(Offset.zero).dy,
          massimo: _scroll.position.maxScrollExtent,
        ),
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOut,
      );
      });
    });
  }

  /// Il tocco su "Vai piu' a fondo".
  ///
  /// Tre esiti, e nessuno dei tre e' un vicolo cieco: chi ha
  /// l'approfondimento nel piano e ne ha ancora scende davvero; chi ce l'ha e
  /// li ha finiti legge il numero vero e quando torna; chi non ce l'ha nel
  /// piano riceve l'invito a salire. Mai un comando che non fa niente.
  Future<void> _approfondisci(
    BuildContext context,
    MaestroChatController controller,
  ) async {
    final piano = context.read<EntitlementService>().tier;
    final contatore = context.read<QuestionAllowance>();

    if (!contatore.pianoConApprofondimento(piano)) {
      await showUpgradeInvite(
        context,
        title: 'Il Maestro può scendere più a fondo',
        message: 'Con il Cerchio puoi chiedergli di riprendere la stessa '
            'lettura e portarla sotto la superficie, dove la prima si era '
            'fermata.',
      );
      return;
    }
    if (!contatore.puoiApprofondire(piano)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Per oggi siamo scesi abbastanza. Domani si riparte da qui.'),
        ),
      );
      return;
    }
    await controller.approfondisci();
  }

  /// Il cielo di questa persona, dalla sorgente unica.
  NatalContext _natalCorrente(BuildContext context) =>
      SorgenteNatale.daIdentita(context.read<BirthIdentityController>());

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

    // CHI NON VUOLE MOVIMENTO NON HA CHIESTO DI ASPETTARE DI PIU'.
    //
    // La pausa minima la governa il turno, che non ha un contesto e non deve
    // averlo: la preferenza arriva da qui, dove MediaQuery esiste.
    controller.riduciMovimento = MediaQuery.of(context).disableAnimations;

    // Mostra il disclaimer una sola volta, appena la memoria e' caricata.
    _maybeShowDisclaimer(controller);

    // La prima domanda contestuale, inviata una sola volta quando la chat e'
    // pronta e la conversazione e' ancora vuota: si arriva da "Parlane con il
    // Maestro" con la domanda sulla fonte gia' pronta.
    _maybeSendInitial(controller);

    // DOVE SI FERMA LA CHAT, e cambia a seconda di CHE COSA e' arrivato.
    //
    // Una domanda appena scritta va in fondo, sotto il pollice, come in
    // qualunque chat. Una RISPOSTA no: e' una lettura, e una lettura si
    // comincia dall'inizio.
    final ultimoMessaggio =
        controller.messages.isEmpty ? null : controller.messages.last;
    final firma = '${controller.messages.length}'
        '|${ultimoMessaggio?.pending}|${ultimoMessaggio?.isMaestro}';
    if (firma != _firmaDelTurno) {
      final primaFirma = _firmaDelTurno;
      _firmaDelTurno = firma;
      final risposta = ultimoMessaggio != null &&
          ultimoMessaggio.isMaestro &&
          !ultimoMessaggio.pending;
      // La cronologia riaperta non si riscrive: `_firmaDelTurno` vuota vuol
      // dire che questa e' la prima volta che si guarda, cioe' che i messaggi
      // arrivano dalla memoria e non dalla rete.
      _scriviLUltima = risposta && primaFirma.isNotEmpty;
      if (risposta) {
        _scorriAllInizioDellaRisposta();
      } else {
        _scrollToEnd();
      }
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
          guasti: services.guasti,
          attestazione: services.attestazione,
          nota: services.diagnostics,
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
        seed: 11,
        showZodiac: false,
        child: SafeArea(
          child: Column(
            children: [
              // L'ATTESA E' IL MAESTRO CHE CONSULTA IL TUO CIELO, e sta sopra
              // la conversazione, cioe' nello spazio che rovesciando la lista
              // era rimasto vuoto. Non e' decorazione: sono i dati veri di chi
              // sta aspettando, a costo di inferenza zero.
              // LA SCENA NON SPARISCE DI COLPO.
              //
              // Prima compariva e spariva con un `if`, quindi al momento
              // giusto, cioe' quando la risposta arriva, faceva un salto. La
              // dissolvenza dura quanto dice il dato, e la stessa uscita vale
              // anche quando la risposta FALLISCE: la scena si chiude e sotto
              // c'e' il ripiego, invece del vuoto improvviso.
              AnimatedSwitcher(
                duration: TempiDellAttesa.dissolvenza,
                transitionBuilder: (figlio, anim) => SizeTransition(
                  sizeFactor: anim,
                  axisAlignment: -1,
                  child: FadeTransition(opacity: anim, child: figlio),
                ),
                child: controller.sending
                    ? ConsultoDelCieloView(
                        key: const ValueKey('consulto'),
                        natal: _natalCorrente(context),
                        maestro: widget.maestro,
                        rotazione: controller.rotazioneDelConsulto,
                      )
                    : const SizedBox.shrink(key: ValueKey('nessun consulto')),
              ),
              Expanded(child: _buildBody(controller)),
              if (!controller.aiReady)
                _ConfigNotice(palette: palette, maestro: widget.maestro),
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
      // Era un CircularProgressIndicator nudo, l'unico punto della chat che
      // sembrava un'app qualunque. Adesso anche l'apertura appartiene al
      // Cerchio: il Maestro sta gia' consultando mentre la memoria si carica.
      return Center(
        child: ConsultoDelCieloView(
                    natal: _natalCorrente(context),
                    maestro: widget.maestro,
                  ),
      );
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
    // ROVESCIATA, e non e' un dettaglio di scorrimento: e' il motivo per cui
    // una conversazione di due turni non legge piu' come una schermata vuota.
    // Ancorata in alto, i due messaggi restavano appesi sotto l'header con
    // mezzo schermo di cosmo fra loro e la barra di scrittura. Rovesciata, i
    // turni si accumulano dal basso come in qualunque chat, e quando sono
    // pochi stanno vicino al pollice invece che lontano dagli occhi.
    final messaggi = controller.messages;
    final ultimo = messaggi.length - 1;
    return ListView.builder(
      key: _chiaveDellaLista,
      controller: _scroll,
      reverse: true,
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.md,
        vertical: SpacingTokens.md,
      ),
      itemCount: messaggi.length,
      itemBuilder: (context, index) {
        // Rovesciata la lista, l'indice zero e' l'ultimo turno.
        final posizione = ultimo - index;
        final messaggio = messaggi[posizione];
        return ChatBubble(
          key: posizione == ultimo && messaggio.isMaestro
              ? _chiaveUltimaRisposta
              : null,
          message: messaggio,
          maestro: widget.maestro,
          // Si scrive SOLO l'ultima, solo se e' appena arrivata, e solo se e'
          // UNA LETTURA VERA.
          //
          // La macchina da scrivere e' il Maestro che scrive: un ripiego non lo
          // scrive lui, lo scrive l'app al posto suo, e farlo comparire lettera
          // per lettera lo spaccerebbe per la sua voce proprio mentre la bolla
          // dichiara il contrario. Vale anche per il messaggio del limite e per
          // un errore, che uno aspetta di leggere subito. La distinzione non e'
          // nuova ed e' gia' nel dato: `portaUnResponso`.
          scriviti:
              posizione == ultimo && _scriviLUltima && messaggio.portaUnResponso,
          durataMassimaDiScrittura: TempiDellAttesa.perScrivere(
            controller.ultimaAttesaMs,
            riduciMovimento: controller.riduciMovimento,
          ),
          onOpenIntent: (id) => _openIntent(context, id),
          // Il Riprova sta attaccato SOTTO la bolla che ha fallito, non in
          // mezzo allo spazio libero: un comando lontano dalla cosa che
          // comanda costringe a indovinare a cosa si riferisce.
          onRetry: posizione == ultimo &&
                  messaggio.isMaestro &&
                  messaggio.failed &&
                  !controller.sending
              ? controller.retryLast
              : null,
          // L'invito si vede SEMPRE sull'ultima risposta vera, anche per il
          // Viandante: al tocco decide `_approfondisci`, che per chi non ha
          // l'approfondimento nel piano apre l'invito a salire invece di un
          // lucchetto muto.
          onApprofondisci:
              posizione == ultimo && controller.puoiChiedereDiApprofondire
                  ? () => _approfondisci(context, controller)
                  : null,
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
    // Dalla sorgente unica, non ricostruito qui: era la seconda copia della
    // stessa riga, e le due copie servivano a due cose diverse.
    final natal = SorgenteNatale.daIdentita(birth);
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
              style: TypographyTokens.body(size: 13)
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
  const _ConfigNotice({required this.palette, required this.maestro});

  final MaestroPalette palette;

  /// Di CHI e' la voce che non si e' accesa. Era scritto "Medora" a mano,
  /// quindi la chat di Aura e quella di Caligo annunciavano il Maestro
  /// sbagliato: il nome viene da `maestro.displayName` e una prova enumera i tre.
  final Maestro maestro;

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
              'Il cerchio non è ancora acceso. La voce di '
              '${maestro.displayName} si attiva '
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
