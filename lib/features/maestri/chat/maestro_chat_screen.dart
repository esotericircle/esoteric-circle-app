import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/entitlement/question_allowance.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/archetypes/archetype_history.dart';
import '../../../core/chat/altre_voci.dart';
import '../../../core/chat/chat_message.dart';
import '../../../core/chat/immersive_intents.dart';
import '../../../core/chat/raccolta_delle_risposte.dart';
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
import '../../../design_system/components/scena_sopra_la_conversazione.dart';
import '../../../design_system/components/cosmos_background.dart';
import '../../shell/spazio_della_barra.dart';
import '../../../design_system/theme/maestro_palette.dart';
import '../../../design_system/theme/maestro_scope.dart';
import '../../../design_system/tokens/color_tokens.dart';
import '../../../design_system/tokens/spacing_tokens.dart';
import '../../../design_system/tokens/typography_tokens.dart';
import '../../../services/ai/maestro_oracle.dart';
import '../../../services/app_services.dart';
import '../../pricing/upgrade_invite.dart';
import '../ask/ask_maestri_screen.dart';
import '../immersive_navigation.dart';
import 'maestro_chat_controller.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/chat_composer.dart';
import 'widgets/chat_empty_state.dart';
import 'widgets/chat_suggestions.dart';
import '../../../services/ai/voce_sorvegliata.dart';
import 'widgets/diagnostics_dialog.dart';
import '../widgets/maestro_bust.dart';

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

  /// Le risposte che la persona ha RIAPERTO col tocco.
  ///
  /// Le chiavi sono indici, e reggono perche' la conversazione si scrive solo
  /// in coda: la ragione per esteso sta in `RaccoltaDelleRisposte.eAperta`,
  /// dove vive la regola.
  final Set<int> _riaperte = {};

  /// Contatore delle aperture, persistito, cosi' due benvenuti vicini non
  /// ripetono la stessa formula. Chiave per Maestro.
  static const String _kRotationPrefix = 'maestro.welcome.rotation.';
  int _welcomeRotation = 0;

  /// IL COMPOSITORE SI MISURA, NON SI STIMA. La lista scorre sotto di lui e
  /// sotto la barra, quindi il suo fondo interno deve valere l'altezza vera
  /// del campo, che cresce fino a cinque righe: una costante mentirebbe alla
  /// prima riga in piu'. Si misura a fotogramma disegnato e si aggiorna solo
  /// quando cambia davvero.
  final GlobalKey _chiaveComposer = GlobalKey();
  double _altezzaComposer = 88;

  void _misuraComposer() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final resa = _chiaveComposer.currentContext?.findRenderObject();
      if (resa is RenderBox && resa.hasSize) {
        if ((resa.size.height - _altezzaComposer).abs() > 0.5) {
          setState(() => _altezzaComposer = resa.size.height);
        }
      }
    });
  }

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

  /// Il tocco su "Chiedi anche agli altri".
  ///
  /// **Il gating resta quello di oggi, non si allarga ne' si stringe.** Il
  /// confronto a piu' voci e' del Cerchio: per il Viandante si apre lo stesso
  /// invito a salire che apre oggi la schermata del confronto, e mai un
  /// comando muto. E non intacca il limite del giorno, esattamente come oggi.
  Future<void> _chiediAgliAltri(
    BuildContext context,
    MaestroChatController controller,
  ) async {
    final piano = context.read<EntitlementService>().tier;
    final contatore = context.read<QuestionAllowance>();
    // IL TETTO DEL GIORNO, dal 4 agosto 2026.
    //
    // Il confronto non consuma domande in piu' di quella gia' pagata nella
    // chat, ed e' misurato: aprendo il Consiglio dalla conversazione la lente
    // di partenza arriva gia' pronta e le altre due non contano, quindi il
    // numero e' ZERO e non tre. Senza un tetto suo, pero', il gesto sarebbe
    // gratuito e ripetibile all'infinito, mentre ogni tocco sono due chiamate
    // al modello.
    if (contatore.canCompare(piano) && !contatore.puoiConfrontare(piano)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Per oggi il Cerchio si è espresso abbastanza. '
              'Domani si riapre.'),
        ),
      );
      return;
    }
    if (!contatore.canCompare(piano)) {
      await showUpgradeInvite(
        context,
        title: 'Gli altri sguardi sono del Cerchio',
        message: 'Col Cerchio la stessa domanda arriva anche agli altri due '
            'Maestri, qui dentro, ognuno con la sua lente.',
      );
      return;
    }
    // UNA PORTA SOLA, dal 5 agosto 2026.
    //
    // Prima questo INCOLLAVA le risposte degli altri due dentro la chat di
    // Medora: negli screenshot del fondatore la sua conversazione conteneva
    // bolle rosse di Caligo e verdi di Aura. Nella chat di un Maestro parla
    // soltanto quel Maestro, sempre. Adesso si apre il Consiglio, che e'
    // il posto dove i tre si esprimono.
    // IL CONFRONTO SI CONTA QUI, dove il gesto avviene: uno per tocco, non
    // uno per lettura che arriva.
    contatore.registraConfronto(piano);
    _apriIlConsiglio(context, controller);
  }

  /// Apre il Consiglio dei Maestri, portandosi dietro cio' che c'e' gia'.
  void _apriIlConsiglio(
    BuildContext context,
    MaestroChatController controller,
  ) {
    final tema = controller.ultimaDomanda;
    if (tema == null) return;
    final lenti = <MaestroLens>[];
    for (final voce in controller.vociDelCerchio) {
      final suo = controller.messages.lastWhere(
        (m) =>
            m.isMaestro &&
            m.portaUnResponso &&
            m.autoreEffettivo(widget.maestro) == voce,
        orElse: () => const ChatMessage(role: ChatRole.maestro, text: ''),
      );
      if (suo.text.trim().isEmpty) continue;
      lenti.add(MaestroLens(
        maestro: voce,
        reply: AltreVoci.treStratiDa(suo.text),
      ));
    }
    Navigator.of(context).push(AskMaestriScreen.perLaSintesi(
      starter: widget.maestro,
      tema: tema,
      lenti: lenti,
    ));
  }

  /// IL TOCCO SULLA FRECCIA: rivela, oppure porta agli abbonamenti.
  ///
  /// **La freccia si vede sempre, e non e' mai un muro.** Chi non ha il
  /// secondo strato nel cammino arriva alla schermata degli abbonamenti; chi
  /// ce l'ha e li ha finiti per oggi legge il numero vero e quando torna. Un
  /// lucchetto muto sarebbe un vicolo cieco, e questa e' la stessa porta che
  /// c'era prima dell'ordine 9: li' era sparita insieme alla seconda chiamata,
  /// e con lei era sparito il fatto che il secondo strato e' un Premium.
  Future<void> _approfondisci(
    BuildContext context,
    MaestroChatController controller,
  ) async {
    if (!controller.ilPianoComprendeIlSecondoStrato) {
      await showUpgradeInvite(
        context,
        title: 'Il Maestro può scendere più a fondo',
        message: 'Con il Cerchio puoi chiedergli di riprendere la stessa '
            'lettura e portarla sotto la superficie, dove la prima si era '
            'fermata.',
      );
      return;
    }
    if (!controller.puoiLeggereIlSecondoStrato) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Per oggi siamo scesi abbastanza. Domani si riparte da qui.'),
        ),
      );
      return;
    }
    controller.approfondisci();
  }

  /// Il cielo di questa persona, dalla sorgente unica.
  NatalContext _natalCorrente(BuildContext context) =>
      SorgenteNatale.daIdentita(context.read<BirthIdentityController>());

  /// LE DUE FAMIGLIE DI DOMANDE, DA UNA PORTA SOLA: le frequenti intere, le
  /// personali filtrate sul dato VERO della persona e ruotate sul giorno.
  /// Le leggono il primo schermo e il pannello: se la regola vivesse in due
  /// punti, prima o poi uno dei due mostrerebbe una domanda su un dato che
  /// non c'e'. Ordine 2163, voce 3.
  ({List<String> frequenti, List<String> personali}) _famiglieCorrenti(
      BuildContext context) {
    final natale = _natalCorrente(context);
    return (
      frequenti: SuggestionSets.frequent(widget.maestro),
      personali: SuggestionSets.ruotaPerGiorno(
        SuggestionSets.personalDisponibili(
          widget.maestro,
          sunSign: natale.sunSign,
          moonSign: natale.moonSign,
          ascendant: natale.ascendant,
        ),
        natale.sunSign ?? 'viandante',
        DateTime.now(),
      ),
    );
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

    // IL DISCLAIMER ALL'APERTURA DELLA CHAT E' USCITO, ed era il settimo.
    //
    // Era l'unico dei sette a essere una finestra modale, cioe' l'unico che
    // bisognava chiudere per poter parlare col Maestro: una porta sbarrata
    // messa davanti alla prima cosa che l'app promette. Adesso il disclaimer
    // vive in un posto solo, nell'area privacy dell'utente.

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
    // LA RIVELAZIONE ENTRA NELLA FIRMA, e non e' un dettaglio.
    //
    // Rivelando il secondo strato la bolla diventa molto piu' alta, e la lista
    // della chat e' rovesciata, cioe' ancorata in basso: senza questa riga il
    // testo che si stava leggendo veniva spinto fuori dalla cima e si finiva a
    // guardare la fine di un testo di cui non si era letto l'inizio. La regola
    // che riporta l'INIZIO della risposta sotto gli occhi esiste gia' ed e' la
    // stessa che vale quando la risposta arriva: qui si fa in modo che veda
    // anche questo momento.
    final firma = '${controller.messages.length}'
        '|${ultimoMessaggio?.pending}|${ultimoMessaggio?.isMaestro}'
        '|${ultimoMessaggio?.approfondita}';
    if (firma != _firmaDelTurno) {
      final primaFirma = _firmaDelTurno;
      _firmaDelTurno = firma;
      final risposta = ultimoMessaggio != null &&
          ultimoMessaggio.isMaestro &&
          !ultimoMessaggio.pending;
      // La cronologia riaperta non si riscrive: `_firmaDelTurno` vuota vuol
      // dire che questa e' la prima volta che si guarda, cioe' che i messaggi
      // arrivano dalla memoria e non dalla rete.
      // E il secondo strato NON si riscrive: e' gia' scritto, quindi compare.
      _scriviLUltima = risposta &&
          primaFirma.isNotEmpty &&
          !(ultimoMessaggio?.approfondita ?? false);
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
          // La voce sorvegliata sa quante volte ha ritentato: la persona non
          // lo vede, e non deve, ma chi sviluppa si'.
          voce: services.ai is VoceSorvegliata
              ? services.ai as VoceSorvegliata
              : null,
          attestazione: services.attestazione,
          nota: services.diagnostics,
          appCheckDebugToken: services.appCheckDebugToken,
        ),
      ),
      // La chat e' una superficie di lettura: cosmo senza costellazioni, cosi'
      // nessuna forma stilizzata ne' rettangolo a portale trapela dietro
      // l'header. Restano stelle e nebulose.
      body: CosmosBackground(
        seed: 11,
        showZodiac: false,
        // **QUI IL SAFEAREA CONSUMA ANCHE IL FONDO, ED E' L'ECCEZIONE
        // DICHIARATA.** La decisione del 7 agosto 2026, lo spazio della barra
        // dentro cio' che scorre, vale per le altre quattro schermate: nella
        // chat il fondo e' il campo di scrittura, che non e' contenuto che
        // scorre, e' uno strumento ancorato. Sotto la barra sarebbe
        // inutilizzabile, e la 2156 ha misurato cosa succede a farlo saltare:
        // 123 punti in un fotogramma. I messaggi scorrono gia' dietro il
        // campo, che e' il comportamento del dominio applicato alla parte che
        // scorre. La ragione intera sta su SpazioDellaBarraNelloScroll.
        // **L'ECCEZIONE SULLA CHAT E' REVOCATA DA MAURO, ordine 2161.** Il
        // fondo non si consuma piu' qui: i messaggi scorrono sotto il
        // compositore e sotto la barra, il vetro della barra si legge
        // perche' sotto c'e' contenuto, e il compositore resta ancorato
        // SOPRA la barra come strumento, senza fascia vuota sotto di lui:
        // sotto c'e' la barra, e sotto la barra scorrono i messaggi.
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Column(
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
              // LA SCENA STA SOPRA LA CONVERSAZIONE, E PRENDE CIO' CHE
              // AVANZA.
              //
              // Prima era un fratello della lista dentro la stessa colonna,
              // quindi il suo spazio lo TOGLIEVA alla conversazione: con un
              // emblema grande avrebbe spinto giu' i messaggi a ogni consulto.
              // `ScenaSopraLaConversazione` rovescia l'ordine di misurazione:
              // la conversazione si dispone per prima e prende cio' che le
              // serve, poi alla scena si dice quanto e' rimasto. **Con la
              // conversazione piena non restava ZERO e la scena spariva da
              // tutte le chat col passare della storia**: dal 7 agosto 2026
              // la scena VIVA pretende la sua altezza minima e si stende
              // sopra la cima della conversazione, che non si muove. La
              // ragione intera sta su ScenaSopraLaConversazione.
              Expanded(
                child: ScenaSopraLaConversazione(
                  altezzaMinimaDellaScena: controller.mostraLaScenaDiAttesa
                      ? ScenaSopraLaConversazione.altezzaDelConsulto
                      : 0,
                  scena: AnimatedSwitcher(
                    // A MOTO FERMO LA SCENA NON COMPARE, C'E'.
                    //
                    // La dissolvenza e' movimento quanto un'animazione, e chi
                    // ha chiesto di ridurlo non ha chiesto un movimento piu'
                    // lento. E' anche la ragione per cui le due anteprime
                    // pesavano lo stesso numero di byte: a riposo le due scene
                    // sono identiche, e la differenza vive solo DURANTE la
                    // comparsa.
                    duration: controller.riduciMovimento
                        ? Duration.zero
                        : TempiDellAttesa.dissolvenza,
                    // UNA DISSOLVENZA, non uno scorrimento laterale. Il corpo
                    // si posa dove sta, non entra da un lato: entrare da un
                    // lato lo farebbe leggere come una carta che passa, e qui
                    // non passa niente, si guarda.
                    transitionBuilder: (figlio, anim) =>
                        FadeTransition(opacity: anim, child: figlio),
                    child: controller.mostraLaScenaDiAttesa
                        ? DecoratedBox(
                            // IL VELO: quando la scena si stende sopra la
                            // conversazione piena, sotto ci sono messaggi, e
                            // frasi sopra frasi non si leggono. Sul vuoto il
                            // velo scurisce appena il cosmo e non si nota.
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  palette.deepest.withValues(alpha: 0.94),
                                  palette.deepest.withValues(alpha: 0.86),
                                  palette.deepest.withValues(alpha: 0.0),
                                ],
                                stops: const [0.0, 0.82, 1.0],
                              ),
                            ),
                            child: ConsultoDelCieloView(
                            // La chiave porta CHI si consulta: cambiando voce
                            // la scena si rifa' con le battute di quel Maestro
                            // invece di restare su quelle di prima.
                            key: ValueKey(
                                'consulto ${controller.maestroInAscolto?.id}'),
                            natal: _natalCorrente(context),
                            maestro:
                                controller.maestroInAscolto ?? widget.maestro,
                            // L'ARCHETIPO GIA' SCOPERTO, che e' il simbolo di
                            // Aura. Dallo storico condiviso, che l'app carica
                            // all'avvio: nullo vuol dire "non ancora
                            // scoperto", e la scena lo dice invece di
                            // mostrare al posto suo un simbolo che direbbe
                            // una cosa falsa.
                            archetipo:
                                context.watch<ArchetypeHistory>().ultimo?.dominante,
                            rotazione: controller.rotazioneDelConsulto,
                          ))
                        : const SizedBox.shrink(
                            key: ValueKey('nessun consulto')),
                  ),
                  conversazione: _buildBody(controller),
                ),
              ),
              // LA SINTESI SI RAGGIUNGE SOLO QUANDO C'E' QUALCOSA DA
              // SINTETIZZARE.
              //
              // Prima si raggiungeva sempre, da un'icona nell'intestazione, e
              // apriva un confronto fra una voce sola e nessun'altra. La
              // regola sta nel dato, `AltreVoci.siPuoSintetizzare`, e conta le
              // letture VERE: due ripieghi non sono due voci.
            ],
              ),
              _composerSospeso(controller),
            ],
          ),
        ),
      ),
    );
  }

  /// Il compositore, sopra la barra, con la sua misura presa a ogni
  /// fotogramma: la lista scorre sotto di lui e sotto la barra.
  Widget _composerSospeso(MaestroChatController controller) {
    final spazioBarra = SpazioDellaBarraNelloScroll.quanto(context);
    final hasMessages = controller.messages.isNotEmpty;
    _misuraComposer();
    return Positioned(
      left: 0,
      right: 0,
      bottom: spazioBarra,
      child: KeyedSubtree(
        key: _chiaveComposer,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // L'avviso di configurazione e' uno strumento come il campo:
            // sta sopra di lui, non in fondo alla colonna del contenuto,
            // altrimenti torna la fascia piena sotto la barra.
            if (!controller.aiReady)
              _ConfigNotice(
                  palette: context.palette, maestro: widget.maestro),
            ChatComposer(
          enabled: controller.aiReady && !controller.sending,
          hintText: 'Scrivi ${aEuphonic(widget.maestro.displayName)} '
              '${widget.maestro.displayName}',
          // A chat vuota, se si arriva dalla chiusura del cerchio, il
          // campo si apre gia' col tema del Consulta.
          initialText: hasMessages ? null : widget.initialTheme,
          onSend: controller.send,
          // Il pannello e' raggiungibile in QUALUNQUE momento, anche a chat
          // vuota: ordine 2163, voce 3. Le famiglie gli arrivano gia'
          // filtrate sul vero dalla porta unica _famiglieCorrenti.
          onSuggestions: () {
            final famiglie = _famiglieCorrenti(context);
            showSuggestionsPanel(
              context,
              maestro: widget.maestro,
              onSend: controller.send,
              frequenti: famiglie.frequenti,
              personali: famiglie.personali,
            );
          },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(MaestroChatController controller) {
    if (controller.loading) {
      // IL LAMPO ALL'APERTURA, tolto il 5 agosto 2026.
      //
      // Qui si montava la scena del consulto mentre la memoria si caricava.
      // Toccando "Consulta Medora" il fondatore vedeva comparire per una
      // frazione di secondo un emblema, che poi spariva da solo: una scena che
      // si monta e si smonta non e' una scena, e' un residuo. Aprire una
      // schermata non deve mostrare niente che poi sparisce.
      //
      // Non torna nemmeno lo spinner che c'era prima: era l'unico punto della
      // chat che sembrava un'app qualunque. Resta il cosmo, che c'e' comunque,
      // e la chat compare quando c'e' davvero qualcosa da mostrare.
      return const SizedBox.shrink();
    }
    if (controller.messages.isEmpty) {
      // LE DUE FAMIGLIE, INTERE E DIVISE, sulla prima schermata: le
      // frequenti tutte, le personali filtrate sul dato vero e ruotate in
      // modo deterministico su persona e giorno. Il tre scritto a mano dei
      // soli starters e' la riduzione del 12 luglio che Mauro ha revocato.
      final famiglie = _famiglieCorrenti(context);
      return ChatEmptyState(
        maestro: widget.maestro,
        greeting: _welcomeFor(controller),
        starters: famiglie.frequenti,
        personali: famiglie.personali,
        onStarter: controller.send,
        enabled: controller.aiReady,
        // La stessa misura del fondo della lista dei messaggi: il primo
        // schermo scorre sotto il compositore e sotto la barra, ma da fermo
        // le famiglie si leggono sopra il vetro, non dietro.
        spazioInFondo: _altezzaComposer +
            SpazioDellaBarraNelloScroll.quanto(context),
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
      // LA LISTA DICE QUANTO E' ALTA, invece di prendersi tutto.
      //
      // Senza questo la conversazione riempirebbe sempre l'altezza che le si
      // offre, anche con due messaggi, e alla scena non avanzerebbe mai
      // niente: e' il motivo per cui l'emblema stava a 96 punti in mezzo a una
      // fascia vuota. Con la misura vera, una chat corta lascia libero cio'
      // che non usa, e una chat lunga non lascia niente.
      shrinkWrap: true,
      // IL FONDO INTERNO PORTA IL COMPOSITORE E LA BARRA: la lista scorre
      // sotto tutti e due, e l'ultimo messaggio risale sopra il compositore
      // grazie a questa misura, presa dal campo vero e non da una costante.
      padding: EdgeInsets.fromLTRB(
        SpacingTokens.md,
        SpacingTokens.md,
        SpacingTokens.md,
        SpacingTokens.md +
            _altezzaComposer +
            SpazioDellaBarraNelloScroll.quanto(context),
      ),
      itemCount: messaggi.length,
      itemBuilder: (context, index) {
        // Rovesciata la lista, l'indice zero e' l'ultimo turno.
        final posizione = ultimo - index;
        final messaggio = messaggi[posizione];
        // OGNI BOLLA PORTA IL SUO MAESTRO, e con lui la sua palette.
        //
        // Prima il volto e il colore li dava la schermata, che ne conosce uno
        // solo: adesso che gli altri due rispondono qui dentro, una bolla di
        // Caligo sarebbe uscita col volto e col blu di Medora. Lo scope si
        // riavvolge attorno alla singola bolla, che e' l'unico punto dove la
        // voce cambia.
        final autore = messaggio.autoreEffettivo(widget.maestro);
        return MaestroScope(
          maestro: autore,
          child: ChatBubble(
          key: posizione == ultimo && messaggio.isMaestro
              ? _chiaveUltimaRisposta
              : null,
          message: messaggio,
          maestro: autore,
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
          // LE ALTRE VOCI, sotto la lettura a cui si riferiscono.
          //
          // Sull'ULTIMA lettura vera, come "Vai piu' a fondo": la riga porta
          // agli altri l'ULTIMA domanda, e metterla anche sotto le risposte
          // vecchie lascerebbe indovinare quale domanda parte.
          onChiediAgliAltri:
              posizione == ultimo && controller.puoiChiedereAgliAltri
                  ? () => _chiediAgliAltri(context, controller)
                  : null,
          // IL RESIDUO SI VEDE PRIMA DEL TOCCO: chi tocca deve sapere cosa
          // spende prima di spenderlo. La formula la compone chi sa contare,
          // cioe' il contatore del giorno, e qui si passa e basta.
          residuoDeiConfronti: posizione == ultimo &&
                  controller.puoiChiedereAgliAltri
              ? context.watch<QuestionAllowance>().residuoDeiConfronti(
                  context.watch<EntitlementService>().tier)
              : null,
          // LE RISPOSTE SI RACCOLGONO QUANDO NE ARRIVA UNA NUOVA.
          //
          // Non appena l'hai letta, che nessuno sa quando succede: quando ne
          // arriva un'altra. Fino ad allora quella che hai in mano resta in
          // mano. La regola sta in `RaccoltaDelleRisposte`, qui si chiede.
          siPuoRaccogliere:
              RaccoltaDelleRisposte.siPuoRaccogliere(messaggi, posizione),
          aperta: RaccoltaDelleRisposte.eAperta(messaggi, posizione,
              riaperte: _riaperte),
          onApriChiudi: () => setState(() {
            if (!_riaperte.remove(posizione)) _riaperte.add(posizione);
          }),
          altreVoci: [
            for (final altro in AltreVoci.altriDi(widget.maestro))
              if (!controller.vociDelCerchio.contains(altro)) altro,
          ],
        ),
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
    this.showAvatar = false,
    this.speaking = false,
  });

  final Maestro maestro;
  final VoidCallback onDiagnostics;

  /// Apre il confronto a piu' voci sulla stessa domanda.

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
      // NESSUNA AZIONE NELL'INTESTAZIONE.
      //
      // Qui c'era un'icona a bilancia, dorata. In una schermata di astrologia
      // si legge come il SEGNO della Bilancia, e portava a una schermata dove
      // la conversazione ricominciava da zero: la domanda era gia' stata
      // fatta, e per sentire gli altri due bisognava riscriverla. Le altre
      // voci adesso si chiamano da SOTTO la risposta a cui si riferiscono, e
      // la sintesi si raggiunge solo quando c'e' qualcosa da sintetizzare.
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
              // "La voce di Medora" faceva pensare all'audio, che nell'app
              // e' un'altra cosa e si compra col piano. Qui si parla del
              // Maestro, e allora si dice il Maestro.
              'Il cerchio non è ancora acceso. '
              '${maestro.displayName} risponde '
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
