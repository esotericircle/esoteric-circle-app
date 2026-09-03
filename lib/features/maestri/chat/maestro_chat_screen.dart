import 'dart:math' as math;
import 'dart:async';
import '../../ricordi/ricordi_screen.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/entitlement/question_allowance.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/archetypes/archetype_history.dart';
import '../rotta_arte.dart';
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
import '../../../design_system/transizioni/velo_del_cerchio.dart';
import '../../../design_system/typography/paragrafi_di_lettura.dart';
import '../../../core/ricordi/registro_dei_ricordi.dart';
import '../../../core/ricordi/voce_del_ricordo.dart';
import '../../../core/voce/dettatura.dart';
import '../../../services/voce/dettatura_vera.dart';
import '../../shell/corsa_della_barra.dart';
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
import '../../../core/config/app_flags.dart';
import '../../../design_system/transizioni/passaggio_del_cerchio.dart';
import '../../../core/entitlement/budget_del_giorno.dart';
import '../../../design_system/components/riga_del_residuo.dart';
import '../../../core/primo_uso/suggerimenti_di_zona.dart';
import '../../../design_system/components/suggerimento_al_primo_uso.dart';

class MaestroChatScreen extends StatefulWidget {
  const MaestroChatScreen({
    super.key,
    required this.maestro,
    this.initialTheme,
    this.initialUserMessage,
    this.dettatura,
  });

  final Maestro maestro;

  /// **LA DETTATURA, e si passa da fuori per una ragione sola: le
  /// anteprime.** Ordine CI voce 05. Nell'app resta nulla e la schermata
  /// costruisce quella vera; il banco delle catture ne passa una viva, cosi'
  /// il microfono si puo' GUARDARE invece che dedurre dal codice. Senza
  /// questo, l'unico modo di vederlo sarebbe un telefono.
  final Dettatura? dettatura;

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
    Dettatura? dettatura,
  }) {
    return PassaggioDelCerchio.rotta<void>(
        // Il contesto della rotta, non quello del builder interno: da qui si
        // leggono il contatore delle domande e il piano attivo, che senza
        // questo passaggio la chat non vedrebbe mai.
        (rotta) => ChangeNotifierProvider<MaestroChatController>(
              create: (_) => MaestroChatController(
                maestro: maestro,
                // **I TURNI ENTRANO NEI RICORDI, ordine CI voce 06.** Qui,
                // dove il registro c'e' gia': il controllore non conosce
                // Firestore e non deve conoscerlo.
                segnaNeiRicordi: (domanda) {
                  try {
                    rotta.read<RegistroDeiRicordi>().segna(VoceDelRicordo(
                          quando: domanda.at ?? DateTime.now(),
                          arte: 'chat',
                          maestro: maestro.id,
                          titolo: domanda.text,
                          tipo: TipoDelRicordo.conversazione,
                        ));
                  } catch (errore) {
                    debugPrint('Chat: il turno non entra nei Ricordi. $errore');
                  }
                },
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
                  dettatura: dettatura,
                ),
              ),
            ));
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

  /// **LA DETTATURA SI COSTRUISCE UNA VOLTA SOLA**, e non a ogni fotogramma:
  /// il motore del riconoscimento chiede al sistema operativo di accendersi,
  /// e rifarlo a ogni ricostruzione vorrebbe dire rifare quel giro mentre la
  /// persona sta scrivendo.
  late final Dettatura _dettatura = widget.dettatura ?? DettaturaVera();
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
    if (!contatore.puoiConfrontare(piano)) {
      // Il cancello guarda i rimasti e non il piano (ordine BG voce 05):
      // chi ha riscattato un confronto con gli Eos passa di qui col suo
      // credito, e chi non ne ha riceve le due strade.
      final riscatto = corredoDelRiscatto(
        context,
        budget: 'confronti',
        cosaUna: 'un confronto di sinastria',
      );
      await showUpgradeInvite(
        context,
        title: 'Gli altri sguardi sono del Cerchio',
        message: 'Puoi riscattare un confronto con gli Eos, oppure col '
            'Cerchio la stessa domanda arriva anche agli altri due Maestri, '
            'qui dentro, ognuno con la sua lente.',
        riscattoLabel: riscatto.label,
        onRiscatta: riscatto.azione,
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
    // **PRIMA SI GUARDA SE SI PUO', ordine BG voce 05**: il cancello conta
    // i rimasti, quindi anche il credito riscattato fuori piano apre. Solo
    // a porta chiusa si offrono le due strade, Eos oppure Cerchio.
    if (controller.puoiLeggereIlSecondoStrato) {
      controller.approfondisci();
      return;
    }
    final riscatto = corredoDelRiscatto(
      context,
      budget: 'approfondimenti',
      cosaUna: 'un approfondimento',
    );
    await showUpgradeInvite(
      context,
      title: 'Il Maestro può scendere più a fondo',
      message: controller.ilPianoComprendeIlSecondoStrato
          ? 'Per oggi siamo scesi abbastanza: puoi riscattare un '
              'approfondimento con gli Eos, oppure domani si riparte da qui.'
          : 'Puoi riscattare un approfondimento con gli Eos, oppure con il '
              'Cerchio chiedergli di riprendere la stessa lettura e portarla '
              'sotto la superficie, dove la prima si era fermata.',
      riscattoLabel: riscatto.label,
      onRiscatta: riscatto.azione,
    );
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
      _scriviLUltima =
          risposta && primaFirma.isNotEmpty && !ultimoMessaggio.approfondita;
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
        // **LA SCALA ARRIVA DA QUI, ordine CO voce 10**: la barra deve sapere
        // quanto sono grandi le lettere PRIMA di costruirsi, e da dentro se
        // stessa non puo' chiederlo a nessuno.
        scalaDelTesto: MediaQuery.textScalerOf(context).scale(1),
        // Lo schermo meno i due angoli, dove stanno la freccia e il pulsante.
        larghezzaDelTitolo: MediaQuery.sizeOf(context).width - 112,
        // Il volto appare nell'header a conversazione avviata: il mezzo busto
        // dello stato vuoto si e' rimpicciolito qui. Pulsa quando risponde.
        showAvatar: hasMessages,
        speaking: controller.sending,
        mostraRicomincia: hasMessages,
        onRicomincia: () => _ConversazioneNuova.chiedi(context, controller),
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
                  // **I GIORNI PRIMA, ordine CG voce 01.** Terza porta delle tre
                  // che aprono i Ricordi, e l'unica che arriva gia' filtrata su
                  // questo Maestro: chi sta parlando con Caligo e vuole rivedere
                  // cosa si erano detti non deve prima passare dal menu' e poi
                  // accendere una pastiglia.
                  _IGiorniPrima(maestro: widget.maestro),
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
                            ? Padding(
                                key: const Key('riquadro_attesa'),
                                padding: const EdgeInsets.fromLTRB(
                                    SpacingTokens.md,
                                    SpacingTokens.sm,
                                    SpacingTokens.md,
                                    SpacingTokens.sm),
                                child: ConsultoDelCieloView(
                                  // La chiave porta CHI si consulta: cambiando voce
                                  // la scena si rifa' con le battute di quel Maestro
                                  // invece di restare su quelle di prima.
                                  key: ValueKey(
                                      'consulto ${controller.maestroInAscolto?.id}'),
                                  natal: _natalCorrente(context),
                                  maestro: controller.maestroInAscolto ??
                                      widget.maestro,
                                  // L'ARCHETIPO GIA' SCOPERTO, che e' il simbolo di
                                  // Aura. Dallo storico condiviso, che l'app carica
                                  // all'avvio: nullo vuol dire "non ancora
                                  // scoperto", e la scena lo dice invece di
                                  // mostrare al posto suo un simbolo che direbbe
                                  // una cosa falsa.
                                  archetipo: context
                                      .watch<ArchetypeHistory>()
                                      .ultimo
                                      ?.dominante,
                                  rotazione: controller.rotazioneDelConsulto,
                                ))
                            : _PresenzaARiposo(
                                key: const ValueKey('nessun consulto'),
                                maestro: controller.maestroInAscolto ??
                                    widget.maestro,
                              ),
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
      // **IL CAMPO SEGUE LA BARRA, DIPINGENDOSI ALTROVE.** Ordine CI voce 03.
      //
      // Il fatto: quando la barra si ritira, sotto il campo restava una
      // fascia vuota alta quanto lei e il campo sembrava sospeso a mezz'aria.
      // Lo spazio riservato NON si tocca, cioe' la regola del 6 agosto 2026
      // resta: qui si sposta solo il disegno, con la stessa durata e la
      // stessa curva della barra, cosi' i due si muovono insieme e niente
      // viene rilayato. Chi sta sotto non si sposta, perche' sotto non c'e'
      // piu' niente.
      child: ValueListenableBuilder<CorsaBersaglio>(
        valueListenable: CorsaDellaBarra.di(context),
        builder: (context, corsa, figlio) => TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: corsa.discesa, end: corsa.discesa),
          duration:
              corsa.perUnTocco && !MediaQuery.of(context).disableAnimations
                  ? const Duration(milliseconds: 220)
                  : Duration.zero,
          curve: Curves.easeOut,
          builder: (context, quanto, dentro) =>
              Transform.translate(offset: Offset(0, quanto), child: dentro),
          child: figlio,
        ),
        child: KeyedSubtree(
          key: _chiaveComposer,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // **LA ZONA SI PRESENTA, la prima volta e una sola.** Ordine CE
              // voce 12. Sta qui e non dentro la lista dei messaggi perche' la
              // lista e' ROVESCIATA: un suggerimento infilato li' comparirebbe
              // in fondo alla conversazione invece che davanti agli occhi.
              // Sopra il campo e' il punto in cui si sta per scrivere, cioe'
              // il momento in cui quel che dice serve. Il compositore misura la
              // propria altezza a ogni fotogramma e la lista si accorcia di
              // conseguenza, quindi non copre niente.
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
                child: SuggerimentoAlPrimoUso(zona: ZonaDelCerchio.chat),
              ),
              // **QUANTO TI RESTA, DETTO PRIMA DI SCRIVERE.** Ordine CE voce 04:
              // "l'utente deve Sapere quante ne mancano". Le due righe stanno
              // sopra il campo e non dentro un foglio, perche' sono
              // un'informazione e non un ostacolo, e stanno insieme perche' la
              // chat spende su due budget: la domanda e l'approfondimento. La
              // riprova non e' un terzo budget, spende sulle domande come la
              // domanda che ha sostituito.
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RigaDelResiduo(budget: BudgetDelGiorno.domande),
                    RigaDelResiduo(budget: BudgetDelGiorno.approfondimenti),
                  ],
                ),
              ),
              // L'avviso di configurazione e' uno strumento come il campo:
              // sta sopra di lui, non in fondo alla colonna del contenuto,
              // altrimenti torna la fascia piena sotto la barra.
              if (!controller.aiReady)
                _ConfigNotice(
                    palette: context.palette, maestro: widget.maestro),
              ChatComposer(
                // **LA DETTATURA VERA, e questo e' l'unico punto che la
                // costruisce.** Ordine CI voce 05: le prove e chiunque monti
                // il compositore altrove ricevono quella spenta, quindi il
                // microfono non compare dove non puo' funzionare.
                dettatura: _dettatura,
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
      // IL SOLO BENVENUTO, ordine 2164 voci 3 e 4: qui passavano anche
      // l'assaggio di tre domande e il pulsante che apriva il pannello.
      // Sono spariti, e con loro le due porte in piu': resta l'icona a
      // stelline accanto al campo.
      return ChatEmptyState(
        maestro: widget.maestro,
        greeting: _welcomeFor(controller),
        spazioInFondo:
            _altezzaComposer + SpazioDellaBarraNelloScroll.quanto(context),
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
      // **UNA VOCE IN PIU', ED E' LA PRESENZA DEL MAESTRO. Ordine CO voce
      // 12**, 3 settembre 2026.
      //
      // Fatto del fondatore: fra il benvenuto e cio' che sta sotto c'e' mezzo
      // schermo di vuoto. **Misurato con la sonda su un telefono da 844
      // punti: duecentosessantanove punti di nulla fra la barra e la prima
      // bolla**, quasi un terzo dello schermo.
      //
      // **Dove sta il vuoto, e perche' non e' dove sembrava.** La fascia che
      // `ScenaSopraLaConversazione` riserva alla scena misura ZERO: la lista
      // si prende tutta l'altezza che le si offre, quindi non avanza niente.
      // Il vuoto e' DENTRO il riquadro della lista, sopra i messaggi, che
      // stanno in basso perche' la lista e' rovesciata. E' stata la sonda a
      // dirlo: la prima stesura di questa voce metteva la presenza nella
      // fascia della scena, e la presenza non compariva mai.
      //
      // **Rovesciata la lista, l'ultima voce si disegna in cima**, cioe'
      // esattamente dentro il vuoto. Scorre via coi messaggi, come deve: non
      // e' un'intestazione fissa, e' la presenza che sta li' finche' c'e'
      // posto.
      itemCount: messaggi.length + 1,
      itemBuilder: (context, index) {
        if (index == messaggi.length) {
          return _PresenzaARiposo(maestro: widget.maestro);
        }
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
            scriviti: posizione == ultimo &&
                _scriviLUltima &&
                messaggio.portaUnResponso,
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
            residuoDeiConfronti:
                posizione == ultimo && controller.puoiChiedereAgliAltri
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
    foglioDelCerchio<void>(
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
                  style: TypographyTokens.titoloScheda()
                      .copyWith(color: palette.goldSoft)),
              const SizedBox(height: SpacingTokens.sm),
              Text(
                'Questa esperienza sta per aprirsi nel cerchio. Arriva presto, '
                'con tutta la sua immersione.',
                style: TypographyTokens.didascalia()
                    .copyWith(color: ColorTokens.textSecondary),
              ),
              const SizedBox(height: SpacingTokens.lg),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
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

  /// Il benvenuto deterministico: vocativo dell'onboarding, un contesto (dati
  /// natali nel Free, sintesi di memoria nel Premium) e una formula a rotazione,
  /// piu' una domanda che spinge all'azione. Nessuna chiamata a Gemini.
  String _welcomeFor(MaestroChatController controller) {
    final birth = context.read<BirthIdentityController>();
    // Dalla sorgente unica, non ricostruito qui: era la seconda copia della
    // stessa riga, e le due copie servivano a due cose diverse.
    final natal = SorgenteNatale.daIdentita(birth);
    // In demo il benvenuto riprende la memoria come per il premium: la
    // demo mostra il prodotto vero. Ordine BG voce 03.
    final premium =
        AppFlags.isDemo || context.read<EntitlementService>().tier != Tier.free;
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
    this.mostraRicomincia = false,
    this.onRicomincia,
    this.scalaDelTesto = 1,
    this.larghezzaDelTitolo = 248,
  });

  /// **QUANTO SONO GRANDI LE LETTERE DI CHI GUARDA. Ordine CO voce 10**, 3
  /// settembre 2026.
  ///
  /// Arriva da fuori e non si legge qui dentro, e la ragione e' tecnica:
  /// `preferredSize` deve rispondere PRIMA che questo widget si costruisca,
  /// quindi non ha nessun contesto da interrogare. Chi monta la barra il
  /// contesto ce l'ha, e glielo passa.
  final double scalaDelTesto;

  /// **QUANTO E' LARGO IL TITOLO, cioe' dove le due righe vanno a capo.**
  ///
  /// Lo schermo meno i due angoli della barra, dove stanno la freccia Indietro
  /// e il pulsante Ricomincia. Serve insieme alla scala, e per la stessa
  /// ragione: **la riga delle tre arti di Medora va a capo prima delle altre
  /// due**, e una barra che non lo sapesse la taglierebbe di una riga intera.
  final double larghezzaDelTitolo;

  final Maestro maestro;
  final VoidCallback onDiagnostics;

  /// Apre il confronto a piu' voci sulla stessa domanda.

  /// Mostra l'avatar tondo del Maestro accanto al nome, a conversazione avviata.
  final bool showAvatar;

  /// Cenno di speaking: l'aura dell'avatar pulsa mentre il Maestro risponde.
  final bool speaking;

  /// **A conversazione vuota non c'e' niente da ricominciare**, e un comando
  /// che non fa niente e' peggio di un comando assente.
  final bool mostraRicomincia;
  final VoidCallback? onRicomincia;

  /// Altezza dell'header: piu' alta quando l'avatar che sfonda il cerchio sta
  /// sopra il nome, cosi' la colonna centrata (avatar, nome, sottotitolo) ci sta
  /// senza tagli; piu' bassa a conversazione vuota, dove ci sono solo nome e
  /// sottotitolo.
  /// **CRESCE CON LE LETTERE, e prima era un numero fisso.** Ordine CO voce
  /// 10, 3 settembre 2026.
  ///
  /// Fatto del fondatore: scorrendo la chat la testa del Maestro si vede
  /// tagliata. **Non era lo scorrimento**: era la scala del testo. La barra
  /// misurava centosedici punti sempre, e dentro ci stanno in colonna il volto
  /// che sfonda il cerchio, il nome e la riga delle tre arti. Il volto ha una
  /// misura sua, in punti, e non cresce; le due righe di testo crescono con la
  /// scala di chi guarda, fino a 1,3 per il tetto dichiarato dell'app. A quel
  /// punto la colonna sfora i centosedici, **e una AppBar ritaglia il suo
  /// titolo: taglia dall'alto, cioe' esattamente dove sta la testa.**
  ///
  /// Il conto: quaranta di anello piu' due di stacco, e le due righe alla loro
  /// misura vera, ventidue e sedici punti con l'interlinea di un terzo,
  /// moltiplicate per la scala. Piu' sei punti di respiro sotto, che sono
  /// quelli che il fondatore vedrebbe mancare per primi.
  ///
  /// **Il numero non e' piu' scritto: e' calcolato.** Un numero scritto per la
  /// scala di chi lo scrive vale per lui solo.
  double get _barHeight {
    const respiro = 6.0;
    final righe = _quantoMisuranoLeDueRighe();
    if (!showAvatar) return righe + respiro * 2;
    const anello = 40.0;
    const stacco = 2.0;
    return anello + stacco + righe + respiro;
  }

  /// **LE DUE RIGHE SI MISURANO, non si stimano.** Ordine CO voce 10.
  ///
  /// La prima stesura di questa voce aveva una formula: ventidue e sedici
  /// punti, per l'interlinea, per la scala. **Era sbagliata di ventitre punti
  /// e tre**, e l'ha detto la sua stessa guardia: la riga delle tre arti di
  /// Medora e' piu' lunga delle altre due e alla scala massima **va a capo**,
  /// quindi vale due righe e non una. Una formula che moltiplica non sa niente
  /// di dove il testo andra' a capo.
  ///
  /// `TextPainter` e' lo stesso che dipinge a schermo, quindi questa misura e'
  /// la misura vera, interlinea e ritorno a capo compresi. Costa due
  /// impaginazioni di due righe per costruzione della barra.
  double _quantoMisuranoLeDueRighe() {
    double alta(String testo, TextStyle stile) {
      final p = TextPainter(
        text: TextSpan(text: testo, style: stile),
        textDirection: TextDirection.ltr,
        textScaler: TextScaler.linear(scalaDelTesto),
        textAlign: TextAlign.center,
      )..layout(maxWidth: larghezzaDelTitolo);
      return p.height;
    }

    return alta(maestro.displayName, TypographyTokens.titoloSezione()) +
        alta(maestro.domainArtsPhrase, TypographyTokens.didascalia());
  }

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
      // **LA PORTA NON VIVE PIU' QUI, ordine AL voce 08**: il volto sta
      // nella capsula dell'identita', sopra il Navigator.
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        tooltip: 'Indietro',
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      // LE AZIONI SONO LA PILLOLA E BASTA, ordine AI. La storia della
      // bilancia resta scritta: qui c'era un'icona a bilancia, dorata, che in
      // una schermata di astrologia si leggeva come il SEGNO della Bilancia e
      // portava a ricominciare la conversazione; le altre voci si chiamano da
      // SOTTO la risposta e nessun simbolo da sviluppatore vive qui (la messa
      // a punto resta nella pressione prolungata sul nome). La pillola non e'
      // un simbolo da sviluppatore: e' il borsellino, che dev'essere sempre
      // visibile per decisione di Mauro del 17 agosto.
      // **RICOMINCIA STA FRA LE AZIONI, ordine CI voce 06.** Prima era in
      // cima al corpo, accanto a "I giorni prima": due comandi con la loro
      // etichetta su una riga sola facevano traboccare la riga di 39 punti a
      // caratteri grandi, misurato su 48 prove. Le azioni dell'intestazione
      // sono il posto dei comandi di schermata, e li' la misura non e' in
      // discussione.
      actions: [
        if (mostraRicomincia)
          IconButton(
            key: const Key('chat_conversazione_nuova'),
            icon: const Icon(Icons.add_comment_outlined),
            tooltip: 'Ricomincia da capo',
            onPressed: onRicomincia,
          ),
        const AngoloDellaBarra(),
      ],
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
                style: TypographyTokens.titoloSezione()),
            Text(
              maestro.domainArtsPhrase,
              textAlign: TextAlign.center,
              style: TypographyTokens.didascalia()
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
              style: TypographyTokens.didascalia()
                  .copyWith(color: ColorTokens.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

/// Striscia con l'invito a riprovare, quando l'ultimo turno e' fallito.

/// COMINCIARE UNA CONVERSAZIONE NUOVA. Ordine CI voce 06.
///
/// **Questo comando non cancella e non dimentica, e va detto a chi lo tocca.**
/// Aprire una conversazione nuova lascia dove sono tutti i messaggi di prima,
/// che restano leggibili dai Ricordi, e **non azzera la memoria del Maestro**,
/// che e' la cosa per cui l'abbonato paga. Il Maestro perde il filo del
/// discorso, non la persona.
///
/// **Non consuma nessuna domanda del giorno**: cominciare a parlare non e'
/// parlare.
///
/// **Perche' chiede conferma.** Non perche' sia pericoloso, ma perche' a
/// schermo la chat si svuota, e una schermata che si svuota sembra sempre una
/// cancellazione: la conferma e' il posto in cui si dice che non lo e'.
/// LA CONFERMA DI "RICOMINCIA". Ordine CI voce 06.
///
/// **Questo comando non cancella e non dimentica, e va detto a chi lo tocca.**
/// Aprire una conversazione nuova lascia dove sono tutti i messaggi di prima,
/// che restano leggibili dai Ricordi, e **non azzera la memoria del Maestro**,
/// che e' la cosa per cui l'abbonato paga. Il Maestro perde il filo del
/// discorso, non la persona.
///
/// **Non consuma nessuna domanda del giorno**: cominciare a parlare non e'
/// parlare.
///
/// **Perche' chiede conferma.** Non perche' sia pericoloso, ma perche' a
/// schermo la chat si svuota, e una schermata che si svuota sembra sempre una
/// cancellazione: la conferma e' il posto in cui si dice che non lo e'.
class _ConversazioneNuova {
  const _ConversazioneNuova._();

  static Future<void> chiedi(
      BuildContext context, MaestroChatController controller) async {
    // **DAL VELO DEL CERCHIO, non da showDialog.** Un dialogo aperto per conto
    // suo arriva su un fondo che non e' il nostro, e la guardia
    // `il_velo_e_uno_solo` lo ha preso subito.
    final si = await dialogoDelCerchio<bool>(
      context: context,
      builder: (context) => AlertDialog(
        key: const Key('chat_conferma_conversazione_nuova'),
        backgroundColor: context.palette.surface,
        title:
            Text('Cominciamo da capo?', style: TypographyTokens.titoloScheda()),
        content: ParagrafiDiLettura(
          testo: 'Quello che vi siete detti finora resta dov\'è. Lo '
              'ritrovi nei Ricordi. Anche quello che il Maestro sa di te '
              'resta: dimentica solo il filo di questa conversazione. Non ti '
              'costa nessuna domanda.',
          stile: TypographyTokens.lettura(),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
                foregroundColor: ColorTokens.textSecondary),
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Continua così'),
          ),
          FilledButton(
            key: const Key('chat_conferma_si'),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Ricomincia'),
          ),
        ],
      ),
    );
    if (si == true) controller.iniziaUnaConversazioneNuova();
  }
}

/// LA RIGA "I GIORNI PRIMA", in cima a ogni chat. Ordine CG voce 01.
///
/// **Apre i Ricordi gia' filtrati su questo Maestro.** E' la terza delle tre
/// porte, e porta alla stessa rotta delle altre due: due schermate che
/// mostrano le stesse cose sono la famiglia di difetti piu' numerosa di questo
/// progetto.
class _IGiorniPrima extends StatelessWidget {
  const _IGiorniPrima({required this.maestro});

  final Maestro maestro;

  @override
  Widget build(BuildContext context) {
    // **IL COLORE VIENE DALLA TAVOLOZZA DEL MAESTRO, e prima non veniva da
    // nessuna parte.** Ordine CI voci 02 e 08.
    //
    // Il fatto: questa riga si leggeva in viola scuro sul cosmo, e a schermo
    // era quasi invisibile. La causa NON era una tinta sbagliata scelta qui,
    // era che qui non se ne sceglieva nessuna: un `TextButton` nudo prende il
    // primario dello schema Material, che in `AppTheme.dark()` e' il primario
    // della tavolozza NEUTRA. Per questo il viola era identico su Medora, su
    // Aura e su Caligo, misurato sulle tre anteprime: non e' il colore di
    // nessuno dei tre, e' il colore di nessuno.
    //
    // L'oro tenue del Maestro e' la tinta che questa app usa per i comandi
    // secondari sopra il cosmo, la stessa dell'etichetta ESPLORA, e passa da
    // `context.palette`, che e' la porta sola: qui non c'e' nessun valore
    // scritto a mano, e cambiando la tavolozza cambia anche questa riga.
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.md),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          key: const Key('chat_i_giorni_prima'),
          style: TextButton.styleFrom(foregroundColor: palette.goldSoft),
          onPressed: () =>
              Navigator.of(context).push(RicordiScreen.route(maestro: maestro)),
          icon: const Icon(Icons.history_rounded, size: 16),
          label: const Text('I giorni prima'),
        ),
      ),
    );
  }
}

/// **CIO' CHE STA NELLA FASCIA QUANDO NON SI ASPETTA NIENTE.**
/// Ordine CO voce 12, 3 settembre 2026.
///
/// Fatto del fondatore: fra il benvenuto e cio' che sta sotto c'e' mezzo
/// schermo di vuoto. **Misurato su un telefono da 844 punti: duecentosessanta-
/// nove punti di nulla fra la barra e la prima bolla**, cioe' quasi un terzo
/// dello schermo.
///
/// **Non si toglie spostando il messaggio.** La conversazione sta ancorata in
/// basso per una decisione presa e scritta: ancorata in alto, due messaggi
/// restavano appesi sotto la barra con mezzo schermo fra loro e il campo di
/// scrittura. Sono lo stesso vuoto visto dall'altro lato: **muoverlo non lo
/// toglie, lo sposta.** Si toglie riempiendolo.
///
/// **E cio' che ci va e' gia' stato deciso.** La chat vuota mostrava il mezzo
/// busto del Maestro grande, e a conversazione avviata quel busto si e'
/// rimpicciolito nella barra. Giusto: a conversazione piena la fascia non
/// esiste. Ma fra le due c'e' lo stato in cui il fondatore e' entrato, la
/// conversazione APPENA cominciata, dove la fascia c'e' tutta e non la occupa
/// piu' nessuno.
///
/// Quindi la presenza resta finche' la fascia e' larga abbastanza da ospitarla,
/// e si toglie da sola quando la conversazione cresce. **Non pulsa e non
/// parla**: e' una presenza a riposo, non una scena.
class _PresenzaARiposo extends StatelessWidget {
  const _PresenzaARiposo({super.key, required this.maestro});

  final Maestro maestro;

  /// Sotto questa altezza il volto non ci sta senza schiacciarsi, e mezzo
  /// volto e' peggio di nessun volto: si toglie.
  ///
  /// **Centodieci e non centocinquanta, e il numero e' misurato.** Con la
  /// prima soglia la presenza non compariva mai: sul telefono da 844 punti,
  /// con una bolla sola, la fascia che avanza sopra la conversazione misura
  /// centotrenta punti. Centocinquanta e' un numero scelto a occhio che
  /// escludeva proprio il caso per cui questa classe esiste, e a trovarlo e'
  /// stata la sonda che stampa i rettangoli veri.
  static const double quandoCiSta = 110;

  /// **QUANTA PARTE DELLO SCHERMO PUO' PRENDERSI.**
  ///
  /// Un quinto: abbastanza da riempire il vuoto che il fondatore ha visto,
  /// poco abbastanza da non spingere il primo messaggio sotto la piega quando
  /// la conversazione cresce. Dentro una lista non c'e' un vincolo di altezza
  /// da cui dedurlo, quindi si dichiara in frazione dello schermo, che e'
  /// l'unica misura vera che qui dentro si conosca.
  static const double quotaDelloSchermo = 0.2;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, vincoli) {
        // **QUANTO SPAZIO RESTA SOPRA I MESSAGGI, e non quanto ne ha la
        // fascia.** Dentro una lista i vincoli sono senza fondo: la misura
        // che conta e' quella del riquadro che la lista occupa, meno quello
        // che i messaggi hanno gia' preso, e la porta l'altezza dello schermo
        // meno cio' che sta sopra e sotto la lista.
        final schermo = MediaQuery.sizeOf(context).height;
        final alta = schermo * quotaDelloSchermo;
        if (!alta.isFinite || alta < quandoCiSta) {
          return const SizedBox.shrink();
        }
        // **CENTO PUNTI E NON PIU', E IL TETTO LO DA' LA TELA DELL'AVATAR.**
        // Ordine CO voce 20, coda del 3 settembre 2026.
        //
        // Non e' una scelta di gusto: `nessuno_disegna_oltre_la_tela` misura
        // quanti pixel FISICI ogni avatar occupa a schermo e pretende che non
        // superino i millesettecento della sua tela. Oltre quel numero
        // l'immagine viene ingrandita sopra la propria risoluzione, cioe' si
        // sgrana, ed e' il difetto che quella guardia sorveglia da sempre.
        //
        // **Con l'anello a centoquaranta la mia presenza disegnava a
        // millesettecentocinquanta**, e la guardia mi ha preso. Il conto:
        // l'immagine cresce di circa quattro pixel e sedici per ogni punto di
        // anello, moltiplicati per la densita' dello schermo, che sui
        // telefoni fitti arriva a quattro. Cento punti danno milleseicento-
        // sessantasei nel caso peggiore, e ci stanno.
        final anello = math.min(100.0, alta - 30);
        // **L'ALTEZZA SI DICHIARA, e dentro una lista e' obbligatorio.** Qui
        // i vincoli verticali sono senza fondo: un volto che si misurasse dal
        // genitore verrebbe alto zero, ed e' esattamente cio' che la sonda ha
        // visto alla prima stesura, un rettangolo da 148 a 148.
        return SizedBox(
          height: alta,
          child: Center(
            child: Opacity(
              opacity: 0.75,
              child: MaestroBust(
                key: const Key('chat_presenza_a_riposo'),
                maestro: maestro,
                ring: anello,
              ),
            ),
          ),
        );
      },
    );
  }
}
