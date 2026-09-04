import '../../../core/sigilli/diario_del_cammino.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shell/spazio_della_barra.dart';

import '../../../core/entitlement/entitlement_service.dart';
import '../../../core/entitlement/esito_del_turno.dart';
import '../../../core/entitlement/question_allowance.dart';
import '../../../core/identity/natal_identity.dart';
import '../../../core/identity/profile_controller.dart';
import '../../../core/maestro/consiglio_finale.dart';
import '../../../core/maestro/consult_depth.dart';
import '../../../core/maestro/frase_di_ripiego.dart';
import '../../../core/maestro/maestro.dart';
import '../../../core/maestro/natal_context.dart';
import '../../../core/maestro/sorgente_natale.dart';
import '../../../core/maestro/tempi_dell_attesa.dart';
import '../../../core/quality/quality_tier.dart';
import '../../../design_system/components/riga_del_consiglio.dart';
import '../../../design_system/components/testo_che_si_scrive.dart';
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
import '../chat/chat_openers.dart';
import '../chat/maestro_chat_screen.dart';
import '../widgets/maestro_bust.dart';
import '../widgets/tre_volti.dart';
import '../../../../design_system/components/titolo_che_non_si_rompe.dart';
import '../rotta_arte.dart';
import '../../../design_system/transizioni/passaggio_del_cerchio.dart';
import '../../../design_system/typography/paragrafi_di_lettura.dart';
import '../../../core/entitlement/budget_del_giorno.dart';
import '../../../design_system/components/riga_del_residuo.dart';
import '../../../core/primo_uso/suggerimenti_di_zona.dart';
import '../../../design_system/components/suggerimento_al_primo_uso.dart';

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
/// COME SI CHIAMA LA SCHERMATA DEL CONFRONTO, in un punto solo.
///
/// Sta fuori dalla classe perche' una prova deve poterlo nominare senza
/// montare uno schermo, e perche' una regola dentro una classe privata non si
/// puo' nemmeno citare.
///
/// **Si chiama Il Consiglio dei Maestri dal 6 agosto 2026**, per decisione di
/// Mauro. Si chiamava Il Consiglio del Cerchio, e il Cerchio e' gia' il nome
/// della home: due cose diverse con la stessa parola in mezzo si confondono, ed
/// e' lo stesso motivo per cui la striscia di navigazione non si e' chiamata
/// Sentieri.
///
/// Nessuna schermata scrive questo nome a mano: `test/il_nome_del_consiglio_test.dart`
/// enumera i sorgenti e cade se qualcuno lo fa.
const String titoloDelConsiglio = 'Il Consiglio dei Maestri';

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
    return PassaggioDelCerchio.rotta<void>((_) => MaestroScope(
          maestro: starter,
          child: AskMaestriScreen(
            starter: starter,
            temaIniziale: tema,
            lentiIniziali: lenti,
          ),
        ));
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

  /// LE SCHEDE GIA' SCRITTE, ordine 2163 voce 10: lo stato della macchina
  /// da scrivere vive QUI, nel dato, non nella scheda. La lista smonta gli
  /// elementi fuori vista, e con lo stato nel widget la prima scheda,
  /// uscita e rientrata, si cancellava e ripartiva da capo. Una risposta
  /// gia' mostrata resta ferma per sempre: quando la sua scrittura si e'
  /// esaurita (il tetto dei tempi piu' un respiro), il Maestro entra qui e
  /// la sua scheda non si riscrive mai piu'.
  final Set<Maestro> _scritte = {};
  final List<Timer> _timerDiScrittura = [];

  void _pianificaLaMarca(Maestro m) {
    _timerDiScrittura.add(Timer(
        TempiDellAttesa.tettoAlTestoCompleto + const Duration(seconds: 1), () {
      if (mounted) setState(() => _scritte.add(m));
    }));
  }

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
      _pianificaLaMarca(lente.maestro);
    }
    // LA DOMANDA ARRIVA DA FUORI, e non si riscrive qui.
    //
    // Il campo di scrittura in cima e' stato tolto il 5 agosto 2026: nel
    // confronto non si scrive, si legge e si sceglie con chi proseguire. Un
    // campo che sembra accettare una domanda e apre altro e' una promessa
    // rotta. Se la domanda c'e' ma nessuna voce e' ancora arrivata, la prima
    // se la chiede la schermata invece di aspettare che qualcuno la digiti.
    // TUTTE E TRE LE CARTE DAL PRIMO ISTANTE.
    //
    // **Il fondatore aveva chiesto una cosa sola: un pulsante che porta al
    // confronto.** Arrivava invece in una stanza con una carta, e le altre due
    // voci andavano chieste una per volta con due chip. La stanza a tre carte
    // esisteva gia', il ciclo qui sotto ne disegna una per ogni Maestro in
    // `_responders`: mancava solo che ci arrivassero tre voci invece di una.
    //
    // Le mancanti entrano subito come "in attesa", quindi la persona vede tre
    // carte dal primo fotogramma, due delle quali stanno pensando.
    if (_theme != null) {
      for (final m in Maestro.fixedOrder) {
        if (_responders.contains(m)) continue;
        _responders.add(m);
        _loading.add(m);
      }
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
          // Si spegne TUTTA l'attesa, non solo quella della voce di partenza:
          // due carte lasciate a pensare per sempre sono due scene che non
          // finiranno mai, e una scena che non finisce non e' un'attesa.
          // Si spegne TUTTO: senza domande da spendere non c'e' nessuna voce
          // da mostrare, e una carta lasciata a pensare per sempre e' una
          // scena che non finisce, cioe' peggio di una schermata vuota.
          setState(() {
            _loading.clear();
            _responders.clear();
          });
          // La strada degli Eos, ordine BG voce 05: una domanda in piu' si
          // riscatta col prezzo del server.
          final riscatto = corredoDelRiscatto(
            context,
            budget: 'domande',
            cosaUna: 'una domanda in più',
          );
          showUpgradeInvite(
            context,
            title: 'Hai posto le tue domande di oggi',
            message: 'Puoi riscattarne una con gli Eos, oppure col Cerchio le '
                'domande ai Maestri sono senza limiti e puoi metterne a '
                'confronto gli sguardi.',
            riscattoLabel: riscatto.label,
            onRiscatta: riscatto.azione,
          );
          return;
        }
        _raccogliLeVoci();
      });
    }
  }

  @override
  void dispose() {
    for (final t in _timerDiScrittura) {
      t.cancel();
    }
    super.dispose();
  }

  /// L'ORDINE DEL CONFRONTO, ordine 2163 voce 10: prima il Maestro da cui
  /// il confronto e' partito, cioe' l'ultimo interpellato, poi gli altri
  /// nell'ordine fisso del cerchio. Prima l'elenco a video partiva sempre
  /// da Medora, chiunque avesse aperto la stanza.
  List<Maestro> get _ordineDelConfronto => [
        widget.starter,
        for (final m in Maestro.fixedOrder)
          if (m != widget.starter) m,
      ];

  /// Le lenti risolte, nell'ordine fisso del cerchio.
  List<MaestroLens> get _orderedLenses => [
        for (final m in Maestro.fixedOrder)
          if (_lenses[m] != null) _lenses[m]!,
      ];

  /// Il contesto natale reale, dai dati di nascita. Vuoto se la carta manca:
  /// personalizzazione col solo nome.
  NatalContext _natal() =>
      SorgenteNatale.daIdentita(context.read<BirthIdentityController>(),
          diario: _forseIlDiario(context));

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
    // La scheda appena arrivata si scrive UNA volta: quando la scrittura si
    // sara' esaurita, la marca la congela per sempre (voce 10).
    _pianificaLaMarca(maestro);
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
      annotaGuastoInnocuo('componendo la sintesi comparativa', errore, traccia);
    }
  }

  /// Chiude il cerchio: salva tema ed esito nella memoria condivisa del Maestro,
  /// cosi' la conversazione ricorda, poi apre la chat col tema gia' in composer.
  /// CONTINUA CON UN MAESTRO, RIPRENDENDO LA CONVERSAZIONE CHE ESISTE.
  ///
  /// **Il difetto che questo metodo corregge.** "Continua con" apriva una
  /// rotta NUOVA, quindi il Maestro ripartiva da zero, disclaimer compreso, e
  /// la conversazione precedente spariva dalla vista. La memoria funziona ed
  /// e' persistente, verificata il 2 agosto 2026: non si perdeva niente, ma
  /// chi guardava vedeva sparire cio' che aveva appena letto.
  ///
  /// **Il tasto indietro in alto lo faceva gia' bene**, ed e' la prova che la
  /// strada giusta c'era: al Consiglio si arriva dalla chat del Maestro di
  /// partenza, che e' rimasta sotto nella pila. Per lui si TORNA, cioe' si
  /// esce da qui. Per gli altri due una chat aperta non c'e', quindi si apre
  /// la loro, che carica da se' la cronologia salvata: e' la stessa
  /// conversazione, non una nuova.
  Future<void> _continuaCon(Maestro maestro) async {
    final services = context.read<AppServices>();
    final navigatore = Navigator.of(context);
    final theme = _theme!;
    final esito = _lenses[maestro]?.reading.trim() ?? '';
    try {
      final mem = await services.memory.loadMemory(maestro);
      final nota = esito.isEmpty
          ? 'Nel Consiglio la persona ti ha chiesto: «$theme».'
          : 'Nel Consiglio la persona ti ha chiesto: «$theme». '
              'In sintesi le hai risposto: $esito';
      final summary = mem.sessionSummary.trim().isEmpty
          ? nota
          : '${mem.sessionSummary.trim()} $nota';
      await services.memory
          .saveMemory(maestro, mem.copyWith(sessionSummary: summary));
    } catch (errore, traccia) {
      // Il salvataggio e' un di piu': un errore non impedisce di continuare.
      annotaGuastoInnocuo(
          'chiudendo il cerchio nella memoria di ${maestro.displayName}',
          errore,
          traccia);
    }
    if (!mounted) return;
    if (maestro == widget.starter) {
      navigatore.pop();
      return;
    }
    // LA CHAT SI APRE SULLA DOMANDA, non su una stanza vuota.
    //
    // E' lo standard che ogni arte usa gia' per "Parlane con il Maestro": la
    // frase nasce da `ChatOpeners`, unico posto dove si scrivono le aperture,
    // e arriva come primo turno della persona. Prima qui non si passava
    // niente, quindi il Maestro apriva col benvenuto e chi entrava doveva
    // riscrivere da capo la domanda a cui la carta aveva appena risposto.
    await navigatore.push(
      MaestroChatScreen.route(
        maestro: maestro,
        services: services,
        initialUserMessage: ChatOpeners.consiglio(theme),
      ),
    );
  }

  /// LE VOCI SI RACCOLGONO UNA ALLA VOLTA, MAI INSIEME.
  ///
  /// Nel codice dell'app la sequenzialita' c'era gia' e una prova la
  /// sorveglia scandendo tutto `lib`: qui non si conserva una correzione, si
  /// ESTENDE quella proprieta' al codice nuovo. Tre chiamate simultanee sono
  /// esattamente il carico che fa scattare il `429 RESOURCE_EXHAUSTED` di
  /// Vertex, misurato il 3 agosto 2026.
  ///
  /// Se una cade, le altre restano: `_fetchLens` non rilancia, consegna il
  /// ripiego dichiarato e la sua carta lo mostra col Riprova.
  Future<void> _raccogliLeVoci() async {
    // IL CONFRONTO E' DEL CERCHIO, e la regola non e' scritta qui: si CHIEDE a
    // `canCompare`, che e' lo stesso dato a cui la chiama la porta d'ingresso.
    //
    // **La rimozione dei chip se l'era portato via.** Il controllo viveva
    // dentro il gesto di aggiungere una voce: tolto quel gesto, le altre due
    // sarebbero arrivate anche a chi non le ha comprate. Il gating non era del
    // chip, e' del confronto.
    // IL CONFRONTO E' DEL CERCHIO, e la regola non e' scritta qui: si CHIEDE a
    // `canCompare`, lo stesso dato a cui la chiede la porta d'ingresso.
    //
    // **La rimozione dei chip se l'era portato via.** Il controllo viveva
    // dentro il gesto di aggiungere una voce: tolto quel gesto, le altre due
    // sarebbero arrivate anche a chi non le ha comprate. Il gating non era del
    // chip, e' del confronto.
    //
    // **E qui NON si apre nessun invito a salire.** Lo apre la porta, prima di
    // entrare: aprirlo di nuovo appena dentro vorrebbe dire accogliere chi
    // arriva con una finestra di vendita, e per due volte di fila.
    final piano = context.read<EntitlementService>().tier;
    final puoConfrontare = context.read<QuestionAllowance>().canCompare(piano);

    for (final m in Maestro.fixedOrder) {
      if (!mounted) return;
      if (_lenses[m] != null) continue;
      if (m != widget.starter && !puoConfrontare) {
        // Fuori del tutto, non una carta vuota: un posto che resta li' senza
        // niente dentro e' un vicolo cieco travestito da attesa.
        setState(() {
          _loading.remove(m);
          _responders.remove(m);
        });
        continue;
      }
      // Solo la voce di partenza conta contro il limite del giorno: le altre
      // due sono il confronto, che ha il suo gating e non intacca le domande.
      await _fetchLens(m, _theme!, countsAgainstAllowance: m == widget.starter);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
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
        // **LA PORTA NON VIVE PIU' QUI, ordine AL voce 08**: il volto sta
        // nella capsula dell'identita', sopra il Navigator.
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
        // **NIENTE FittedBox, ordine S voce 05.** Rimpiccioliva il titolo
        // senza fondo per tenerlo su una riga, quindi poteva scendere sotto il
        // pavimento tipografico dell'app, e non andava a capo mai. La regola e'
        // un'altra: a capo FRA le parole, e la misura scende solo quanto serve,
        // entro un minimo dichiarato.
        title: TitoloCheNonSiRompe(
            testo: titoloDelConsiglio,
            stile: TypographyTokens.titoloDiSchermata()),
        // IL BORSELLINO, ordine S voce 06: stesso segno, stesso angolo, in
        // ogni schermata della pratica. Un saldo che appare e scompare non
        // si impara.
        actions: const [AngoloDellaBarra()],
      ),
      // **LO SPAZIO DELLA BARRA STA DENTRO LA LISTA.** Decisione di Mauro
      // del 7 agosto 2026, ragione intera su SpazioDellaBarraNelloScroll: le
      // carte scorrono sotto la barra e l'ultima risale grazie al fondo della
      // lista qui sotto.
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            Expanded(
              // NESSUNO STATO VUOTO: qui si arriva sempre con una domanda gia'
              // fatta, e senza campo per farne una non ci sarebbe niente da
              // invitare a fare. Un invito senza uscita e' un vicolo cieco.
              child: ListView(
                key: const Key('ask_results'),
                padding: EdgeInsets.fromLTRB(
                    SpacingTokens.lg,
                    0,
                    SpacingTokens.lg,
                    SpacingTokens.xxxl +
                        SpazioDellaBarraNelloScroll.quanto(context)),
                children: [
                  // **LA ZONA SI PRESENTA, la prima volta e una
                  // sola.** Ordine CE voce 12: dentro la lista,
                  // sopra i pareri, e scorre via con loro.
                  const SuggerimentoAlPrimoUso(zona: ZonaDelCerchio.consiglio),
                  // **QUANTI CONFRONTI TI RESTANO, ordine CE voce 04.**
                  // La Consulta spende sul budget dei confronti nel
                  // Cerchio, e questa era una delle cinque porte che
                  // consumavano senza dire niente.
                  const RigaDelResiduo(budget: BudgetDelGiorno.confronti),
                  for (final m in _ordineDelConfronto)
                    if (_responders.contains(m)) ...[
                      // LA CARTA C'E' IN TUTTI E DUE GLI STATI, e porta
                      // la stessa chiave: e' cio' che permette di
                      // provare che le tre carte esistono dal primo
                      // fotogramma, due delle quali stanno pensando.
                      Column(
                        key: Key('ask_card_${m.id}'),
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_loading.contains(m)) ...[
                            // NESSUNA SCENA DI ATTESA DENTRO LA CARTA.
                            //
                            // La scena con l'emblema e le frasi vive
                            // nella chat, dove c'e' una superficie sola
                            // e tutta l'altezza libera. Qui erano tre in
                            // colonna dentro tre carte alte un dito: gli
                            // emblemi cadevano sotto la piega e
                            // restavano tre bolle che scattavano.
                            // Una lista che aspetta si dice stando
                            // ferma.
                            _LensLoadingCard(maestro: m),
                          ] else ...[
                            _LensCard(
                                lens: _lenses[m]!,
                                scriviti: !_scritte.contains(m)),
                            // SOTTO OGNI CARTA, e non solo sotto quella
                            // di partenza: con tre carte, da due delle
                            // tre non si potrebbe proseguire.
                            const SizedBox(height: SpacingTokens.xs),
                            _ContinueInChat(
                              maestro: m,
                              onContinue: () => _continuaCon(m),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: SpacingTokens.sm),
                    ],
                  // LA SINTESI STA IN FONDO, DOPO LE TRE CARTE.
                  //
                  // Una sintesi e' la conclusione di un confronto, e in
                  // cima occupava da sola tutto il primo schermo: chi
                  // apriva il Consiglio non vedeva tre Maestri, vedeva
                  // un muro di testo, e le carte cominciavano dove
                  // finiva lei. Prima si legge chi si e' espresso, poi
                  // cosa se ne ricava.
                  if (synthesis != null) ...[
                    const SizedBox(height: SpacingTokens.sm),
                    _SynthesisCard(synthesis: synthesis),
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

/// Il ponte alla conversazione: chiude il cerchio portando il tema in chat, dove
/// il Maestro riprende da li'.
class _ContinueInChat extends StatelessWidget {
  const _ContinueInChat({required this.maestro, required this.onContinue});

  final Maestro maestro;
  final Future<void> Function() onContinue;

  @override
  Widget build(BuildContext context) {
    // IL COLORE E' DEL SUO MAESTRO, non della schermata.
    //
    // `context.palette` legge il MaestroScope che avvolge tutto il Consiglio,
    // cioe' quello di chi ha fatto la domanda: sotto le tre carte comparivano
    // tre porte identiche, tutte del colore del primo. Blu per Medora, rosso
    // per Caligo, verde per Aura: la porta si tinge di chi ci sta dietro.
    final palette = MaestroPalette.forKey(ThemeKey.of(maestro));
    return GestureDetector(
      key: Key('ask_continue_${maestro.id}'),
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
                  style: TypographyTokens.titoloDiRiga()
                      .copyWith(color: palette.goldSoft)),
            ),
            Icon(Icons.arrow_forward_rounded,
                size: 16, color: palette.goldSoft),
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
              // comparat...", visto nell'anteprima e non dedotto.
              //
              // **QUATTORDICI E NON PIU' DICIOTTO, ordine CE voce 11.** Il
              // titolo e' salito da diciassette a diciotto punti, entrando
              // nella scala dei ruoli, e a diciotto ne chiede 219 invece di
              // 206,8. Lo spazio interno della card e' 262: i volti a diciotto
              // ne occupavano 42 piu' 8 di stacco e ne restavano 212, cioe'
              // sette meno del necessario, e il titolo andava a capo. La cura
              // e' quella che la prova stessa indica, restringere i volti e non
              // accorciare il nome. La prova "Il titolo della Sintesi si legge
              // intero" li rimisura.
              //
              // Via anche i puntini: `maxLines: 1` con l'ellissi tagliava il
              // titolo in silenzio, e in un'altra lingua taglierebbe ancora.
              // Senza, il peggio che puo' capitare e' che vada a capo, cioe'
              // che si legga tutto lo stesso.
              const TreVolti(misura: 14),
              const SizedBox(width: SpacingTokens.xs),
              Expanded(
                child: Text('Sintesi comparativa',
                    style: TypographyTokens.titoloScheda()
                        .copyWith(color: palette.goldSoft)),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.sm),
          ParagrafiDiLettura(
              testo: synthesis,
              stile: TypographyTokens.lettura()
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
/// LA CARTA CHE ASPETTA: la stessa cornice, la stessa testa, nessun moto.
///
/// **Cosa c'era, e perche' e' uscito.** Qui vivevano due cose insieme: la scena
/// del consulto, con l'emblema che si accende e le frasi, e sotto una riga con
/// un'icona che respirava. Tre carte in colonna dentro una lista alta 797
/// punti: gli emblemi cadevano sotto la piega e restavano solo tre puntini che
/// pulsavano due volte al secondo. Una lista che aspetta si dice stando ferma
/// e composta, non muovendosi in tre posti alla volta.
///
/// Senza controllore: non ce n'e' piu' nessuno da fermare a Riduci Movimento,
/// perche' non c'e' piu' niente che si muove.
class _LensLoadingCard extends StatelessWidget {
  const _LensLoadingCard({required this.maestro});

  final Maestro maestro;

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(ThemeKey.of(maestro));
    return Container(
      key: Key('ask_loading_${maestro.id}'),
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
          // LA STESSA TESTA DELLA CARTA RISOLTA, dallo stesso punto: la carta
          // non cambia forma quando la risposta arriva, si riempie.
          _TestaDellaCarta(maestro: maestro, palette: palette),
          const SizedBox(height: SpacingTokens.sm),
          Text(
            '${maestro.displayName} raccoglie il suo sguardo.',
            key: Key('ask_attesa_${maestro.id}'),
            style: TypographyTokens.body(size: 17).copyWith(
              color: palette.goldSoft.withValues(alpha: 0.75),
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// LA TESTA DELLA CARTA: il volto, il nome, il dominio.
///
/// Una sola, cosi' la carta che aspetta e quella risolta non possono
/// divergere, e la carta non cambia forma quando la risposta arriva.
class _TestaDellaCarta extends StatelessWidget {
  const _TestaDellaCarta({required this.maestro, required this.palette});

  final Maestro maestro;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Il volto del Maestro che sfonda il cerchio, al posto dell'icona
        // nuda: qui c'e' spazio, quindi anello pieno.
        MaestroBust(maestro: maestro, ring: 48),
        const SizedBox(width: SpacingTokens.sm),
        // IL DOMINIO STA SOTTO IL NOME, e non piu' di fianco.
        //
        // Di fianco gli restavano 104,84 punti di larghezza, misurati, contro
        // le tre righe che la frase chiede a quella misura: con `maxLines: 2`
        // si leggeva "Astrologia, Cartomanzia e" e Destino spariva. Avevamo
        // tolto la versione accorciata e ottenuto una tagliata, che e' peggio,
        // perche' accorciare almeno lo dichiara. Sotto il nome la frase ha
        // tutta la larghezza della carta meno il volto, e nessun limite di
        // righe: il dato si legge intero, sempre.
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(maestro.displayName, style: TypographyTokens.titoloScheda()),
              const SizedBox(height: 2),
              Text(maestro.domainArtsPhrase,
                  key: Key('ask_dominio_${maestro.id}'),
                  softWrap: true,
                  style: TypographyTokens.etichetta().copyWith(
                    color: palette.goldSoft.withValues(alpha: 0.8),
                    letterSpacing: 0.8,
                  )),
            ],
          ),
        ),
      ],
    );
  }
}

/// La lettura di un Maestro, nella sua palette: colpo d'occhio, testo, invito.
class _LensCard extends StatelessWidget {
  const _LensCard({required this.lens, this.scriviti = true});

  final MaestroLens lens;

  /// Falso quando la scheda e' gia' stata scritta una volta: il testo
  /// compare intero e fermo. La regola vive nel dato della schermata.
  final bool scriviti;

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(ThemeKey.of(lens.maestro));
    // Stesse due condizioni della chat, lette dagli stessi due posti: chi ha
    // chiesto di non vedere movimento, e chi sta su un apparecchio che non ce
    // la fa. Il contenuto non cambia mai: cio' che si toglie e' il tempo che
    // ci mette a comparire.
    final scrive = scriviti &&
        !MediaQuery.of(context).disableAnimations &&
        context.watch<QualityTierController>().tier != QualityTier.low;
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
          _TestaDellaCarta(maestro: lens.maestro, palette: palette),
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
            ParagrafiDiLettura(
                testo: lens.glance,
                stile: TypographyTokens.lettura().copyWith(
                  color: palette.goldSoft,
                  fontStyle: FontStyle.italic,
                  height: 1.35,
                )),
          ],
          const SizedBox(height: SpacingTokens.sm),
          // IL CORPO SI SCRIVE, alla stessa misura e alla stessa velocita'
          // della chat.
          //
          // La misura: 17, che e' quella della bolla. A 14 il testo del
          // Consiglio si leggeva a fatica e, sotto una sintesi lunga, sembrava
          // una nota a pie' di pagina invece della risposta di un Maestro.
          //
          // La velocita' viene da `TempiDellAttesa`, lo stesso punto della
          // chat: una seconda taratura qui divergerebbe dalla prima al primo
          // ritocco. Ferma a Riduci Movimento e a qualita' bassa, come li'.
          TestoCheSiScrive(
            // Il corpo senza la riga del consiglio, che si rimette in fondo.
            testo: ConsiglioFinale.corpoDa(lens.reading),
            attiva: scrive,
            durataMassima: TempiDellAttesa.tettoAlTestoCompleto,
            stile: TypographyTokens.body(size: 17)
                .copyWith(color: ColorTokens.textPrimary, height: 1.5),
          ),
          // LA STELLA AL POSTO DELLA FRECCIA, dal 4 agosto 2026.
          //
          // Qui c'era `lens.invite` preceduto da una freccia orizzontale, e
          // quella freccia NON era toccabile: risalendo gli antenati per
          // rientro, `Row -> Column -> Container -> _LensCard`, non c'era
          // nessun gesto. Prometteva un altrove e non portava da nessuna
          // parte. La stella non promette un altrove, dichiara un dono.
          //
          // L'invito del Maestro resta dentro il suo testo, dove lui l'ha
          // scritto: cio' che cambia e' che la riga finale adesso la compone
          // l'app, sintesi sua piu' un aggancio a cio' che cambia da solo.
          RigaDelConsiglio(
            maestro: lens.maestro,
            testo: lens.reading,
            quando: DateTime.now(),
            palette: palette,
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
                    RipiegoDelMaestro.etichettaDi(lens.maestro),
                    style: TypographyTokens.corpo()
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

/// **IL DIARIO SE C'E'. Ordine CQ voce 2.15**, 4 settembre 2026.
///
/// Il prossimo passo del Cammino entra nel contesto dei Maestri, e il diario
/// vive nel guscio: chi monta questa schermata da sola, cioe' le prove e le
/// anteprime, non ce l'ha. Pretenderlo farebbe cadere quaranta prove altrove,
/// ed e' un difetto che questo progetto ha gia' pagato: si chiede, e se non
/// c'e' il contesto esce senza quella riga.
DiarioDelCammino? _forseIlDiario(BuildContext context) {
  try {
    return context.read<DiarioDelCammino>();
  } catch (_) {
    return null;
  }
}
