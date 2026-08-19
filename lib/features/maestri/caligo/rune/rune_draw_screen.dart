import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/astro/zodiac.dart';
import '../../../../core/entitlement/entitlement_service.dart';
import '../../../../core/entitlement/question_allowance.dart';
import '../../../../core/maestro/maestro.dart';
import '../../../../core/rituals/rune_cast.dart';
import '../../../../core/rituals/sunset_rune_corpus.dart';
import '../../../../core/rituals/rune_lore.g.dart';
import '../../../../core/rituals/rune_presage.dart';
import '../../../../core/rituals/rune_voce.dart';
import '../../../../design_system/components/cosmos_background.dart';
import '../../../../design_system/components/depth_card.dart';
import '../../../../design_system/components/scroll_reveal.dart';
import '../../../../design_system/theme/maestro_palette.dart';
import '../../../../design_system/tokens/color_tokens.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';
import '../../../../design_system/typography/paragrafi_di_lettura.dart';
import '../../../../services/app_services.dart';
import '../../../../services/regia_delle_chiamate.dart';
import '../../../sigilli/regia_del_cammino.dart';
import '../../../../core/rituals/runes.dart';
import '../../../rituals/rune_strokes.dart';
import '../../../rituals/retro_della_runa.dart';
import '../../chat/chat_openers.dart';
import '../../chat/maestro_chat_screen.dart';
import 'bindrune.dart';
import 'rune_share_card.dart';
import 'fisica_della_gettata.dart';
import '../../../pricing/upgrade_invite.dart';
import '../../rotta_arte.dart';
import '../../../../core/sensi/ascoltatore_scuotimento.dart';
import '../../../../core/sensi/catalogo_suoni.dart';
import '../../../../core/sensi/palette_sensoriale.dart';
import '../../../../design_system/components/titolo_che_non_si_rompe.dart';
import '../../../../core/domande/domande_del_cerchio.dart';
import '../../../../core/rituals/filo_del_giorno.dart';
import '../../../../core/rituals/sunset_rune_memory.dart';
import '../../../../core/responsi/anatomia_del_responso.dart';
import '../../../../services/ai/registro_dei_guasti.dart';

/// L'Estrazione Rune, dominio Caligo: lettura a richiesta e ripetibile, col
/// selettore del tipo di gettata. Il caso e' voluto e autentico, e' gettare le
/// sorti a ogni lancio. Deterministico solo il presagio, zero AI a runtime.
class RuneDrawScreen extends StatefulWidget {
  const RuneDrawScreen({
    super.key,
    required this.userSign,
    this.userBirth,
    this.random,
    this.scuotimento,
  });

  /// L'ascoltatore di scuotimento, iniettabile nelle prove: a runtime resta
  /// null e la schermata usa la porta unica dell'app.
  final AscoltatoreScuotimento? scuotimento;

  final Zodiac userSign;

  /// La data di nascita, se nota. Non usata ora: e' il gancio per la futura
  /// personalizzazione del presagio sul cielo della persona.
  final DateTime? userBirth;

  /// Sorgente del caso, iniettabile nei test e nelle catture per un lancio
  /// riproducibile. A runtime resta null, un vero lancio senza seme.
  final math.Random? random;

  /// LA SOGLIA DI QUESTA ARTE, dichiarata una volta sola. Ordine P voce 27.
  ///
  /// **Perche' esiste.** L'identificativo dell'arte e il suo Maestro erano
  /// scritti dentro `route`, cioe' in un punto che solo l'app attraversa. Le
  /// anteprime montavano la schermata NUDA, con un `MaestroScope` costruito a
  /// mano: senza `ArteCorrente` e senza `ConCuore`, quindi senza il cuore delle
  /// arti preferite nella barra, e con la palette presa dal controller invece
  /// che dichiarata dal proprietario. Provavano una scena che l'app non monta.
  ///
  /// Adesso la soglia si chiede da qui, e la chiedono tutti e due: la rotta
  /// dell'app e la cattura dell'anteprima. Un solo punto dichiara chi e' il
  /// proprietario di quest'arte.
  static Widget conLaSoglia(Widget schermata) => SogliaArte(
        id: 'rune_draw',
        maestro: Maestro.caligo,
        child: schermata,
      );

  static Route<void> route({
    required Zodiac userSign,
    DateTime? userBirth,
    math.Random? random,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) => conLaSoglia(RuneDrawScreen(
            userSign: userSign, userBirth: userBirth, random: random)),
    );
  }

  @override
  State<RuneDrawScreen> createState() => _RuneDrawScreenState();
}

enum _Fase { preparazione, responso }

class _RuneDrawScreenState extends State<RuneDrawScreen> {
  final TextEditingController _domanda = TextEditingController();

  /// Il presagio composto dal modello, quando arriva. Nullo prima e nullo se il
  /// modello non risponde: in quel caso vale il ripiego, che non si dichiara.
  Responso? _presagioDelModello;

  /// Vero mentre il modello sta scrivendo. Serve alla bolla per non mostrare un
  /// testo che fra un istante viene sostituito da un altro: uno scambio a video
  /// direbbe alla persona che il primo era un ripiego.
  bool _presagioInArrivo = false;
  /// I DATI CHE LE DOMANDE PERSONALI CHIEDONO, e solo quelli che ci sono davvero.
  ///
  /// Ordine S voce 21, decisione D4: le personali nascono da CARTA E CAMMINO. Il
  /// segno c'e' sempre; il Sole lo si sa quando c'e' la data di nascita; la runa di
  /// ieri sera e la parola di stamattina arrivano dal filo fra i riti e si leggono
  /// dal disco.
  ///
  /// **Luna, Ascendente, animale guida e archetipo NON sono qui, e va detto.** Le
  /// loro domande esistono nel punto unico e non si mostrano ancora, perche' questa
  /// schermata non riceve la carta natale ne' il risultato del Test: agganciarle
  /// vorrebbe dire passare qui altri quattro dati, ed e' un lavoro che si fa quando
  /// le loro voci servono, non prima. Meglio quattro voci in meno che quattro voci
  /// che nominano cio' che l'app non sa.
  Set<DatoPerLaDomanda> _datiDisponibili = const {DatoPerLaDomanda.segno};

  Future<void> _leggiIDatiDelleDomande() async {
    final trovati = <DatoPerLaDomanda>{DatoPerLaDomanda.segno};
    if (widget.userBirth != null) trovati.add(DatoPerLaDomanda.sole);
    final parola = await FiloDelGiorno.parolaDiStamattina(DateTime.now());
    if (parola != null && parola.trim().isNotEmpty) {
      trovati.add(DatoPerLaDomanda.parolaDiStamattina);
    }
    final ieriSera = await SunsetRuneMemory.ultimaPerCerniera();
    if (ieriSera != null) trovati.add(DatoPerLaDomanda.runaDiIeriSera);
    if (!mounted) return;
    setState(() => _datiDisponibili = trovati);
  }

  GettataRune _gettata = gettate.first;
  _Fase _fase = _Fase.preparazione;
  EsitoGettata? _esito;
  bool _animazioni = true;

  /// LO SCUOTIMENTO PASSA DALLA PORTA UNICA, e NON SI SPEGNE MAI qui dentro.
  ///
  /// La versione precedente apriva il proprio flusso col samplingPeriod
  /// vietato e CANCELLAVA la sottoscrizione alla prima gettata senza che
  /// nessuno la riarmasse: lo scuotimento valeva una volta per vita della
  /// schermata, ed e' il "non funziona" visto da Mauro. Adesso l'ascoltatore
  /// vive quanto la schermata, l'antirimbalzo sta nella porta unica, e dopo
  /// una gettata lo scuotimento getta ancora.
  late final AscoltatoreScuotimento _scuotimento =
      widget.scuotimento ?? AscoltatoreScuotimento();

  @override
  void initState() {
    super.initState();
    unawaited(_leggiIDatiDelleDomande());
    _scuotimento.onScuotimento = _dalloScuotimento;
    _scuotimento.start();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _animazioni = !ScrollReveal.motionOff(context);
  }

  @override
  void dispose() {
    // Se l'ascoltatore e' iniettato dalle prove, a spegnerlo e' chi lo ha
    // creato: qui si stacca solo il passo.
    _scuotimento.onScuotimento = null;
    if (widget.scuotimento == null) _scuotimento.dispose();
    _domanda.dispose();
    super.dispose();
  }

  void _dalloScuotimento() {
    if (!mounted) return;
    // In preparazione getta; nel responso getta ancora: e' il riarmo.
    if (_fase == _Fase.preparazione) {
      _getta();
    } else {
      _gettaAncora();
    }
  }

  void _cambiaGettata(GettataRune g) {
    if (g.id == _gettata.id) return;
    setState(() => _gettata = g);
  }

  /// IL LIMITE DELLE GETTATE, ordine I voce 3. Il numero vive nella matrice
  /// dei piani (tre al giorno per il Viandante, illimitate dal Tier 1) e il
  /// conteggio sta in `QuestionAllowance`, col reset giornaliero gia' in uso
  /// per le altre arti. Esaurite le gettate il pulsante e' grigio e il tocco
  /// apre l'invito del gating: mai un blocco muto.
  bool _consumaUnaGettata() {
    final piano = context.read<EntitlementService>().tier;
    final borsa = context.read<QuestionAllowance>();
    if (!borsa.puoiGettare(piano)) {
      showUpgradeInvite(
        context,
        title: 'Le gettate di oggi sono finite',
        message: 'Le tre gettate del giorno sono state fatte. Puoi '
            'riscattarne una con gli Eos, quando il borsellino arriva '
            'nell\'app, oppure salire di livello nel Cerchio: dall\'Iniziato '
            'in su le gettate sono senza limiti.',
      );
      return false;
    }
    borsa.registraGettata(piano);
    // IL CAMMINO SE NE ACCORGE, ordine O: il gesto e' compiuto adesso, non
    // quando la scena si e' aperta.
    // **IL MODO DELLA GETTATA VIAGGIA COL GESTO, ordine AR voce 11.** La
    // scena sa quale delle quattro gettate si sta facendo: senza questo
    // dettaglio la condizione "tutti i modi provati" non potrebbe esistere.
    // Le rune uscite NON si passano da qui: in questo punto la gettata e'
    // solo autorizzata e le pietre non sono ancora state estratte.
    unawaited(RegiaDelCammino.dopoUnGesto(
      context,
      'gettata',
      dettagli: {'modo': _gettata.id},
    ));
    // LA CHIAMATA DEL RITORNO, ordine M voce 2e: chi consuma qui l'ultima
    // gettata del giorno riceve domattina l'avviso che sono tornate. Si
    // riprogramma adesso, perche' domattina l'app potrebbe non aprirsi.
    if (borsa.gettateRimaste(piano) == 0) {
      unawaited(RegiaDelleChiamate.riprogramma(context));
    }
    return true;
  }

  void _getta() {
    if (_fase == _Fase.responso) return;
    if (!_consumaUnaGettata()) return;
    PaletteSensoriale.eseguiSchema(SchemaAptico.conferma);
    setState(() {
      _esito = RuneCast.getta(_gettata, random: widget.random);
      _fase = _Fase.responso;
    });
    _chiediIlPresagio();
  }

  void _gettaAncora() {
    if (!_consumaUnaGettata()) return;
    PaletteSensoriale.eseguiSchema(SchemaAptico.tocco);
    setState(() => _esito = RuneCast.getta(_gettata, random: widget.random));
    _chiediIlPresagio();
  }

  /// IL PRESAGIO DEL MODELLO, e il ripiego che non si dichiara.
  ///
  /// **Ordine S voce 19, punto 3 della decisione D5.** Il presagio e' l'unica bolla
  /// che deve davvero rispondere alla domanda, ed e' una sola per gettata: la
  /// compone il modello dai due dati che non puo' inventare, la runa col suo
  /// significato dal corpus e la domanda scelta.
  ///
  /// **UNA GENERAZIONE AL GIORNO NEL PIANO GRATUITO, senza un contatore nuovo.** Si
  /// chiede una volta per gettata, e le gettate del giorno le limita gia' il tier:
  /// nel piano gratuito e' una. Un secondo contatore qui sarebbe la stessa cosa
  /// contata due volte, e al primo ritocco i due direbbero numeri diversi.
  ///
  /// **IL RIPIEGO NON SI DICHIARA MAI.** Se il modello non c'e', non risponde o
  /// risponde male, resta il presagio deterministico: cornice dell'allegato B piu'
  /// la frase della runa dal corpus. La persona non deve poter capire quale dei due
  /// sta leggendo, quindi non c'e' nessun avviso e nessuna icona.
  void _chiediIlPresagio() {
    final esito = _esito;
    if (esito == null) return;
    // **LA LETTURA E' NULLABILE apposta:** questa schermata si monta anche da sola
    // nelle prove e nelle catture, dove `AppServices` non c'e'. Senza il punto di
    // domanda il getto schianterebbe la' dentro.
    final servizi = Provider.of<AppServices?>(context, listen: false);
    final ai = servizi?.ai;
    if (ai == null || !ai.isReady) return;
    setState(() {
      _presagioDelModello = null;
      _presagioInArrivo = true;
    });
    final domanda = _domanda.text.trim();
    unawaited(() async {
      try {
        // Il profilo arriva dalla memoria, che e' la sua casa: serve al modello
        // per il nome e la forma di cortesia, e non lo ricopia nessuno qui.
        final profilo = await servizi!.memory.loadProfile();
        if (!mounted || !identical(_esito, esito)) return;
        final responso = await ai.presagioDelleRune(
          esito: esito,
          domanda: domanda,
          profile: profilo,
        );
        if (!mounted || !identical(_esito, esito)) return;
        setState(() {
          _presagioDelModello = responso;
          _presagioInArrivo = false;
        });
      } catch (errore, traccia) {
        // **QUI L'ERRORE SI IGNORA DI PROPOSITO, e va detto due volte.** Alla
        // PERSONA non si dice niente: il ripiego e' un presagio a tutti gli
        // effetti, e un avviso lo declasserebbe. A NOI si dice tutto: il guasto e'
        // gia' nel registro, perche' la chiamata passa dalla `VoceSorvegliata`, e
        // qui lo si annota una seconda volta come guasto innocuo per avere il
        // punto esatto in cui la schermata ha deciso di cadere sul ripiego.
        annotaGuastoInnocuo(
            'chiedendo il presagio delle rune al modello', errore, traccia);
        if (!mounted || !identical(_esito, esito)) return;
        setState(() => _presagioInArrivo = false);
      }
    }());
  }

  /// IL SEME DELLA FISICA: persona, giorno, domanda e rune uscite.
  ///
  /// L'estrazione resta un caso vero e dichiarato, sta scritto perfino nel
  /// testo a video di Fonti e metodo: "a richiesta e casuale". Ma la CADUTA
  /// non inventa niente: a parita' di questi dati la disposizione finale e'
  /// identica al decimo di punto. E' la stessa distinzione dell'Oroscopo,
  /// sopra un fatto si apre un ventaglio di dizione e mai di sostanza: qui
  /// sopra una sorte si apre una caduta, e la caduta non e' una seconda
  /// sorte.
  int _semeDellaGettata(EsitoGettata esito) {
    final persona =
        widget.userBirth?.toIso8601String() ?? widget.userSign.name;
    return FisicaDellaGettata.semeDa(
      persona,
      DateTime.now(),
      _domanda.text.trim(),
      [
        for (final r in esito.gettata.libera ? esito.sparse : esito.rune)
          r.rune.name
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.caligo));
    // Il pulsante del getto si spegne quando le gettate del giorno sono
    // finite: si guarda il contatore, cosi' il grigio arriva da solo.
    final piano = context.watch<EntitlementService>().tier;
    final borsa = context.watch<QuestionAllowance>();
    final gettateFinite = !borsa.puoiGettare(piano);
    // Il conto del giorno: nullo per chi non ha limite, perche' un contatore
    // a infinito e' rumore. Cala nello stesso istante della gettata, perche'
    // qui si guarda il contatore vero.
    final gettateRimaste = borsa.gettateRimaste(piano);
    final gettateLimite = borsa.limiteGettate(piano);
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: BarraArte(
        // **NIENTE FittedBox.** Rimpiccioliva il titolo senza fondo per
        // tenerlo su una riga, quindi poteva scendere sotto il pavimento
        // tipografico dell'app, e non andava a capo mai. La regola e'
        // un'altra: a capo FRA le parole, e la misura scende solo quanto
        // serve, entro un minimo dichiarato.
        titolo: TitoloCheNonSiRompe(
            testo: 'Estrazione Rune', stile: TypographyTokens.titoloScheda()),
        azioni: [
          IconButton(
            key: const Key('rune_sources'),
            icon: const Icon(Icons.info_outline_rounded),
            tooltip: 'Fonti e metodo',
            onPressed: () => _mostraFonti(context, palette),
          ),
        ],
      ),
      body: CosmosBackground(
        seed: 10,
        showZodiac: false,
        child: SafeArea(
          child: _fase == _Fase.preparazione
              ? _Preparazione(
                  palette: palette,
                  gettata: _gettata,
                  domanda: _domanda,
                  datiDisponibili: _datiDisponibili,
                  animazioni: _animazioni,
                  onGettata: _cambiaGettata,
                  onGetta: _getta,
                  gettateFinite: gettateFinite,
                  gettateRimaste: gettateRimaste,
                  gettateLimite: gettateLimite,
                  statoScuotimento: _scuotimento.stato,
                )
              : _Responso(
                  palette: palette,
                  esito: _esito!,
                  seme: _semeDellaGettata(_esito!),
                  domanda: _domanda.text.trim(),
                  presagioDelModello: _presagioDelModello,
                  presagioInArrivo: _presagioInArrivo,
                  persona: widget.userBirth?.toIso8601String() ??
                      widget.userSign.name,
                  giorno: DateTime.now(),
                  animazioni: _animazioni,
                  onAncora: _gettaAncora,
                  gettateFinite: gettateFinite,
                  gettateRimaste: gettateRimaste,
                  gettateLimite: gettateLimite,
                ),
        ),
      ),
    );
  }

  void _mostraFonti(BuildContext context, MaestroPalette palette) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheet) => Container(
        key: const Key('rune_sources_sheet'),
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fonti e metodo',
                    style: TypographyTokens.titoloScheda()
                        .copyWith(color: palette.goldSoft)),
                const SizedBox(height: SpacingTokens.sm),
                Text(kRuneFontiEMetodo,
                    style: TypographyTokens.didascalia().copyWith(
                        color: ColorTokens.textPrimary, height: 1.45)),
                const SizedBox(height: SpacingTokens.sm),
                // L'ESTENSIONE DEL 7 AGOSTO 2026: le strofe dei tre poemi
                // runici col loro conto esatto, e la Voce della Runa
                // dichiarata come curatela. Vive in kRuneFontiPoemi.
                Text(kRuneFontiPoemi,
                    key: const Key('rune_fonti_poemi'),
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
      ),
    );
  }
}

/// La soglia: la voce di Caligo, il selettore col testo dinamico, il disclaimer,
/// la domanda coi suggerimenti, poi il Pozzo di Urdhr in attesa del lancio.
class _Preparazione extends StatelessWidget {
  const _Preparazione({
    required this.palette,
    required this.gettata,
    required this.domanda,
    required this.datiDisponibili,
    required this.animazioni,
    required this.onGettata,
    required this.onGetta,
    required this.gettateFinite,
    required this.gettateRimaste,
    required this.gettateLimite,
    required this.statoScuotimento,
  });

  final MaestroPalette palette;
  final GettataRune gettata;
  final TextEditingController domanda;

  /// Quali dati le domande personali possono nominare, ordine S voce 21.
  final Set<DatoPerLaDomanda> datiDisponibili;
  final bool animazioni;
  final ValueChanged<GettataRune> onGettata;
  final VoidCallback onGetta;

  /// Vero quando le gettate del giorno sono esaurite: il pulsante si spegne
  /// nel colore, ma resta toccabile perche' il tocco spiega, mai muto.
  final bool gettateFinite;

  /// Quante gettate restano oggi e quante ne promette il piano. Nulli per
  /// chi non ha limite: il conto non si mostra, un infinito e' rumore.
  final int? gettateRimaste;
  final int? gettateLimite;

  /// Lo stato del sensore, dalla porta unica: quando dice assente, la riga
  /// dell'aiuto dichiara il ripiego invece di promettere lo scuotimento.
  final ValueNotifier<StatoScuotimento> statoScuotimento;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const Key('rune_preparazione'),
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: SpacingTokens.sm),
          Text(
            'Sono Caligo, custode delle soglie. Le rune non comandano il tuo '
            'domani, lo rischiarano: gettale con una domanda nel cuore e ascolta '
            'il segno.',
            key: const Key('rune_intro'),
            textAlign: TextAlign.center,
            style: TypographyTokens.corpo()
                .copyWith(color: ColorTokens.textPrimary, height: 1.5),
          ),
          const SizedBox(height: SpacingTokens.lg),
          // LE PIETRE COPERTE, prima che la sorte le scopra.
          _PietreCoperte(
              palette: palette,
              quante: gettata.libera ? gettata.sparse : gettata.numero),
          const SizedBox(height: SpacingTokens.lg),
          // IL SELETTORE delle gettate.
          _SelettoreGettate(
              corrente: gettata, palette: palette, onSelect: onGettata),
          const SizedBox(height: SpacingTokens.md),
          // L'ANIMAZIONE E IL GESTO STANNO IN ALTO, dall'ordine H: il pozzo
          // col bottone del getto era in fondo, dopo la domanda e i
          // suggerimenti, e per gettare si scorreva oltre cio' che si era
          // gia' letto. Il gesto sta subito sotto la scena che lo mostra.
          const SizedBox(height: SpacingTokens.lg),
          // **LA DOMANDA SI PONE PRIMA, E STA SOPRA IL PULSANTE.** Ordine S voce
          // 21, decisione D4 di Mauro del 13 agosto 2026. Stava sotto il getto,
          // cioe' dopo: si gettava e poi si trovava il campo di una domanda che
          // non aveva piu' modo di entrare nella gettata. Adesso e' una tendina a
          // due famiglie, GENERICHE e PERSONALI, e sotto resta il campo libero per
          // chi la vuole scrivere con parole sue.
          //
          // **Le domande vengono dal punto unico**, `DomandeDelCerchio`: prima
          // stavano qui cinque suggerimenti e nella chat altre sessanta, cioe' due
          // elenchi della stessa cosa. Le personali si mostrano solo se il loro
          // dato c'e'.
          Text('La tua domanda',
              style: TypographyTokens.etichetta()
                  .copyWith(color: palette.goldSoft, letterSpacing: 0.6)),
          const SizedBox(height: SpacingTokens.xs),
          _TendinaDelleDomande(
            palette: palette,
            datiDisponibili: datiDisponibili,
            onScelta: (testo) => domanda.text = testo,
          ),
          const SizedBox(height: SpacingTokens.xs),
          TextField(
            key: const Key('rune_question_field'),
            controller: domanda,
            maxLines: 2,
            minLines: 1,
            style: TypographyTokens.didascalia()
                .copyWith(color: ColorTokens.textPrimary),
            decoration: InputDecoration(
              hintText: 'Oppure scrivila con le tue parole.',
              hintStyle: TypographyTokens.didascalia()
                  .copyWith(color: ColorTokens.textSecondary),
              filled: true,
              fillColor: palette.deepest.withValues(alpha: 0.4),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
                borderSide:
                    BorderSide(color: palette.gold.withValues(alpha: 0.4)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
                borderSide:
                    BorderSide(color: palette.gold.withValues(alpha: 0.8)),
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          // **SI PUO' GETTARE SENZA DOMANDA**, e la riga lo dice: in quel caso il
          // responso parla alla giornata, come chiede la legge del responso.
          Text(
              'Puoi anche gettare senza domanda: il responso parlerà alla '
              'tua giornata.',
              key: const Key('rune_senza_domanda'),
              style: TypographyTokens.didascalia()
                  .copyWith(color: ColorTokens.textSecondary)),
          const SizedBox(height: SpacingTokens.lg),
          // **IL POZZO IN ATTESA NON C'E' PIU', ordine S voce 22.**
          //
          // Stavano qui 140 punti di pozzo vuoto fra la domanda e il pulsante.
          // L'ordine L voce 2a li aveva scelti di proposito, portandoli da 300 a
          // 140: "il telo in attesa e' un accenno, non una scena vuota". **La
          // misura sulla resa dice che quell'accenno non viene dipinto:** nella
          // banda di 140 punti l'inchiostro sta su 8 righe su 140, con al massimo
          // 4 pixel chiari per riga, e sono le stelle del fondale che passano
          // dietro. Un accenno che non si vede non e' un accenno, e' spazio.
          //
          // Il pozzo compare col getto, dove ha le pietre da mostrare: e' anche
          // il modo in cui il getto diventa un fatto invece di un cambio di testo.
          // **Se un giorno si vuole un accenno prima del getto, va DIPINTO**, e la
          // prova `il_pozzo_in_attesa_non_e_un_vuoto_test` misura la banda sulla
          // resa: un accenno vero la fa passare, 140 punti di niente no.
          FilledButton.icon(
            key: const Key('rune_cast_button'),
            // ESAURITE LE GETTATE IL PULSANTE E' GRIGIO, ordine I voce 3:
            // il tocco resta vivo e apre l'invito del gating, mai un blocco
            // muto e mai un pulsante che sembra rotto.
            style: FilledButton.styleFrom(
                backgroundColor: gettateFinite
                    ? ColorTokens.textSecondary.withValues(alpha: 0.25)
                    : palette.primary,
                foregroundColor: gettateFinite
                    ? ColorTokens.textSecondary
                    : palette.onPrimary,
                minimumSize: const Size.fromHeight(52)),
            onPressed: onGetta,
            icon: Icon(gettateFinite
                ? Icons.lock_outline_rounded
                : Icons.casino_outlined),
            label: const Text('Getta le rune'),
          ),
          _ContoDelleGettate(
              rimaste: gettateRimaste,
              limite: gettateLimite,
              palette: palette),

          // IL TESTO DINAMICO, che cambia con la scelta.
          DepthCard(
            key: const Key('rune_dynamic_text'),
            padding: const EdgeInsets.all(SpacingTokens.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${gettata.nome} · ${gettata.sottotitolo}',
                    style: TypographyTokens.corpo().copyWith(
                        color: palette.goldSoft, letterSpacing: 0.6)),
                const SizedBox(height: SpacingTokens.xs),
                // Il responso di Caligo e' testo che si LEGGE, quindi il ruolo
                // e' lettura e la regola dei paragrafi e' quella comune: qui
                // non se ne scrive una seconda.
                ParagrafiDiLettura(
                    testo: gettata.testoDinamico,
                    stile: TypographyTokens.lettura()
                        .copyWith(color: ColorTokens.textPrimary)),
              ],
            ),
          ),
            // IL DISCLAIMER E' USCITO DA QUI, ed era uno di SETTE.
            //
            // Le linee guida dicevano da sempre "una volta sola", e per
            // sette volte ognuno ha pensato che il proprio fosse quella
            // volta. Un disclaimer ripetuto smette di essere letto e
            // diventa un modo di scaricare la responsabilita' invece di
            // dirla. Adesso sta in un posto solo, nell'area privacy.
          const SizedBox(height: SpacingTokens.xs),
          // IL RIPIEGO TATTILE, DICHIARATO A SCHERMO. Quando il sensore
          // non c'e', la riga smette di promettere lo scuotimento e dice
          // la strada che resta: mai lasciare la persona senza la sua arte.
          ValueListenableBuilder<StatoScuotimento>(
            valueListenable: statoScuotimento,
            builder: (context, stato, _) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                    stato == StatoScuotimento.assente
                        ? Icons.touch_app_outlined
                        : Icons.vibration,
                    size: 13,
                    color: palette.goldSoft),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                      stato == StatoScuotimento.assente
                          ? 'Questo telefono non offre lo scuotimento: '
                              'getta col tocco, che vale sempre.'
                          : 'Scuoti il telefono, oppure tocca: il ripiego '
                              'vale sempre.',
                      key: const Key('rune_ripiego_riga'),
                      style: TypographyTokens.etichetta().copyWith(
                          color: palette.goldSoft.withValues(alpha: 0.7),
                          letterSpacing: 0.3)),
                ),
              ],
            ),
          ),
          const SizedBox(height: SpacingTokens.xxxl),
        ],
      ),
    );
  }
}

/// Il responso: la gettata posata nel Pozzo, la domanda, la rivelazione a
/// scorrimento, il presagio, Getta ancora, poi Condividi e Parlane con Caligo.
class _Responso extends StatelessWidget {
  const _Responso({
    required this.palette,
    required this.esito,
    required this.seme,
    required this.domanda,
    required this.presagioDelModello,
    required this.presagioInArrivo,
    required this.persona,
    required this.giorno,
    required this.animazioni,
    required this.onAncora,
    required this.gettateFinite,
    required this.gettateRimaste,
    required this.gettateLimite,
  });

  final MaestroPalette palette;
  final EsitoGettata esito;
  final int seme;
  final String domanda;

  /// Il presagio composto dal modello, quando c'e'. Nullo vuol dire ripiego, e il
  /// ripiego non si dichiara: la persona legge un presagio, non un avviso.
  final Responso? presagioDelModello;

  /// Vero mentre il modello scrive. La bolla mostra l'attesa invece di un testo
  /// che fra un istante verrebbe sostituito: uno scambio a video direbbe alla
  /// persona che il primo era un ripiego.
  final bool presagioInArrivo;
  final String persona;
  final DateTime giorno;
  final bool animazioni;
  final VoidCallback onAncora;

  /// Vero quando le gettate del giorno sono esaurite: Getta ancora si spegne
  /// nel colore, e il tocco apre l'invito del gating.
  final bool gettateFinite;

  /// Il conto del giorno, nullo per chi non ha limite.
  final int? gettateRimaste;
  final int? gettateLimite;

  @override
  Widget build(BuildContext context) {
    // **IL PRESAGIO RISPONDE ALLA DOMANDA POSTA, ordine S voce 19.** Prima non la
    // riceveva nemmeno: la domanda entrava nel seme della gettata e nell'eco
    // della singola runa, ma la lettura d'insieme parlava come se nessuno avesse
    // chiesto niente.
    // **IL MODELLO SE C'E', il ripiego altrimenti, e nessuno dei due si annuncia.**
    // Ordine S voce 19, punto 3 della D5: quando il modello risponde il presagio
    // e' suo; quando non risponde e' la cornice dell'allegato B piu' la frase della
    // runa dal corpus, e la persona non deve poter capire quale sta leggendo.
    final responso = presagioDelModello ??
        RunePresagio.componiIlResponso(esito, domanda: domanda);
    final presagio = responso.inParole;
    // LA VOCE DELLA RUNA: la runa dentro la domanda e dentro il giorno,
    // agganciata al cielo vero. Il perche' sta su RuneVoce.
    final voci = [
      for (final r in esito.rune)
        RuneVoce.voce(
            runa: r, persona: persona, giorno: giorno, domanda: domanda),
    ];
    // IL VERSO DELLE NORNE: le tre letture legate da giunture che variano
    // su giorno E posizione, mai su un asse solo.
    final giunture = esito.gettata.id == 'norne'
        ? RuneVoce.giuntureNorne(giorno)
        : null;
    return SingleChildScrollView(
      key: const Key('rune_result'),
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: SpacingTokens.sm),
          Center(
            child: Text(esito.gettata.nome.toUpperCase(),
                key: const Key('rune_result_title'),
                style: TypographyTokens.cerimoniale()
                    .copyWith(color: palette.goldSoft)),
          ),
          const SizedBox(height: SpacingTokens.md),
          // IL POZZO con le rune posate, i cerchi e i fili delle Norne.
          _PozzoUrdhr(
            palette: palette,
            gettata: esito.gettata,
            esito: esito,
            seme: seme,
            animazioni: animazioni,
          ),
          // GETTA ANCORA STA QUI, subito sotto la scena, dall'ordine H: era in
          // fondo, dopo presagio e sigillo, e per rigettare si attraversava
          // tutta la lettura.
          const SizedBox(height: SpacingTokens.md),
          OutlinedButton.icon(
            key: const Key('rune_recast'),
            // GRIGIO A GETTATE ESAURITE, ordine I voce 3, e il tocco spiega.
            style: OutlinedButton.styleFrom(
                foregroundColor: gettateFinite
                    ? ColorTokens.textSecondary
                    : palette.goldSoft,
                side: BorderSide(
                    color: gettateFinite
                        ? ColorTokens.textSecondary.withValues(alpha: 0.4)
                        : palette.gold.withValues(alpha: 0.6))),
            onPressed: onAncora,
            icon: Icon(gettateFinite
                ? Icons.lock_outline_rounded
                : Icons.casino_outlined),
            label: const Text('Getta ancora'),
          ),
          _ContoDelleGettate(
              rimaste: gettateRimaste,
              limite: gettateLimite,
              palette: palette),

          if (domanda.isNotEmpty) ...[
            const SizedBox(height: SpacingTokens.md),
            DepthCard(
              key: const Key('rune_question_shown'),
              padding: const EdgeInsets.all(SpacingTokens.md),
              child: Row(
                children: [
                  Icon(Icons.help_outline_rounded,
                      size: 16, color: palette.goldSoft),
                  const SizedBox(width: SpacingTokens.xs),
                  Expanded(
                    child: Text(domanda,
                        style: TypographyTokens.didascalia().copyWith(
                            color: ColorTokens.textPrimary,
                            fontStyle: FontStyle.italic)),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: SpacingTokens.lg),
          // **IL PRESAGIO E' LA PRIMA BOLLA, ordine S voce 19.** Stava in fondo,
          // dopo le rune una per una: la persona leggeva tre frammenti e doveva
          // montarli da sola, e la lettura che li tiene insieme arrivava quando
          // aveva gia' finito di interpretare. Adesso e' la prima cosa che si
          // legge dopo la gettata, e le rune singole vengono dopo, come dettaglio
          // di cio' che il presagio ha gia' detto.
          //
          // **La sua lunghezza non si tocca**, e l'ordine lo dichiara perche'
          // nessuno la accorci per uniformita' con le bolle brevi delle rune: e'
          // l'unica misura gia' giusta di tutta la sezione.
          // IL PRESAGIO, la lettura sola che intreccia le rune.
          ScrollReveal(
            depth: 1,
            child: DepthCard(
              key: const Key('rune_presage'),
              raised: true,
              padding: const EdgeInsets.all(SpacingTokens.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, size: 16, color: palette.goldSoft),
                      const SizedBox(width: SpacingTokens.xs),
                      Text('Il presagio di Caligo',
                          style: TypographyTokens.etichetta().copyWith(
                              color: palette.goldSoft, letterSpacing: 0.6)),
                    ],
                  ),
                  const SizedBox(height: SpacingTokens.xs),
                  // **L'ATTESA NON MOSTRA UN TESTO CHE POI CAMBIA.** Mentre il
                  // modello scrive, la bolla tiene tre righe di respiro invece del
                  // ripiego: se mostrasse il ripiego e poi lo sostituisse, la
                  // persona vedrebbe lo scambio e capirebbe che il primo era un
                  // ripiego, che e' esattamente cio' che l'ordine vieta.
                  if (presagioInArrivo)
                    Padding(
                      key: const Key('rune_presage_attesa'),
                      padding:
                          const EdgeInsets.symmetric(vertical: SpacingTokens.md),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                                strokeWidth: 1.6, color: palette.goldSoft),
                          ),
                          const SizedBox(width: SpacingTokens.sm),
                          Text('Caligo sta leggendo le pietre',
                              style: TypographyTokens.didascalia()
                                  .copyWith(color: ColorTokens.textSecondary)),
                        ],
                      ),
                    )
                  else ...[
                  // **LE TRE PARTI SI VEDONO, ordine S voce 19 sull'anatomia
                  // della voce S.16.** Erano un paragrafo unico, e in un
                  // paragrafo unico la cosa da fare si perde in mezzo: e' la
                  // parte che fa tornare, quindi ha la sua superficie.
                  ParagrafiDiLettura(
                      key: const Key('rune_presage_text'),
                      testo: responso.risposta,
                      oro: palette.goldSoft,
                      stile: TypographyTokens.lettura()
                          .copyWith(color: ColorTokens.textPrimary)),
                  const SizedBox(height: SpacingTokens.sm),
                  Container(
                    key: const Key('rune_presage_azione'),
                    padding: const EdgeInsets.all(SpacingTokens.sm),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(SpacingTokens.radiusMd),
                      border:
                          Border.all(color: palette.gold.withValues(alpha: 0.4)),
                      color: palette.deepest.withValues(alpha: 0.35),
                    ),
                    // **ANCHE QUI SI PASSA DALLA PORTA UNICA**, e a dirlo e'
                    // stata la prova `etichette_e_lettura`: un Text diretto nel
                    // ruolo lettura e' la famiglia delle due porte, e da quella
                    // porta il muro di testo rientra.
                    child: ParagrafiDiLettura(
                        testo: responso.cosaPuoiFare,
                        oro: palette.goldSoft,
                        stile: TypographyTokens.lettura()
                            .copyWith(color: ColorTokens.textPrimary)),
                  ),
                  const SizedBox(height: SpacingTokens.sm),
                  // DA DOVE VIENE, e qui compaiono le rune: non prima.
                  Text(responso.daDoveViene,
                      key: const Key('rune_presage_fonte'),
                      style: TypographyTokens.didascalia()
                          .copyWith(color: ColorTokens.textSecondary)),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          // LE RUNE UNA PER UNA, il dettaglio dopo la lettura d'insieme.
          for (var i = 0; i < esito.rune.length; i++) ...[
            _LetturaRuna(
                runa: esito.rune[i],
                indice: i,
                palette: palette,
                libera: esito.gettata.libera,
                voce: i < voci.length ? voci[i] : null,
                giuntura: giunture != null && i < giunture.length
                    ? giunture[i]
                    : null),
            const SizedBox(height: SpacingTokens.md),
          ],
          const SizedBox(height: SpacingTokens.md),
          // IL SIGILLO DEL GIORNO, la bindrune che intreccia le rune uscite.
          ScrollReveal(
            depth: 1,
            child: DepthCard(
              key: const Key('rune_sigillo'),
              raised: true,
              padding: const EdgeInsets.all(SpacingTokens.md),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.workspaces_outline,
                          size: 16, color: palette.goldSoft),
                      const SizedBox(width: SpacingTokens.xs),
                      Text('Il sigillo del giorno',
                          style: TypographyTokens.etichetta().copyWith(
                              color: palette.goldSoft, letterSpacing: 0.6)),
                    ],
                  ),
                  const SizedBox(height: SpacingTokens.sm),
                  // AL MASSIMO TRE RUNE NEL SIGILLO, dichiarato: col getto
                  // sul telo le lette sono sette, e sette segni intrecciati
                  // sono un groviglio, non una bindrune. Si intrecciano le
                  // tre piu' vicine al centro, cioe' le prime della lettura,
                  // e la didascalia sotto lo dice.
                  BindruneSigillo(
                    runeNames: [
                      for (final r in esito.rune.take(3)) r.rune.name
                    ],
                    oro: palette.gold,
                    alone: palette.goldSoft,
                    lato: 176,
                  ),
                  if (esito.rune.length > 3) ...[
                    const SizedBox(height: SpacingTokens.xs),
                    Text(
                      'Intreccia le tre rune più vicine al centro.',
                      textAlign: TextAlign.center,
                      style: TypographyTokens.corpo()
                          .copyWith(color: ColorTokens.textSecondary),
                    ),
                  ],
                  const SizedBox(height: SpacingTokens.sm),
                  Text(kRuneBindruneNota,
                      textAlign: TextAlign.center,
                      style: TypographyTokens.corpo().copyWith(
                          color: ColorTokens.textSecondary, height: 1.4)),
                ],
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          _Azioni(palette: palette, esito: esito, presagio: presagio),
          const SizedBox(height: SpacingTokens.xxxl),
        ],
      ),
    );
  }
}

/// La lettura di una runa: la pietra che brilla, il nome, la posizione con la
/// sua glossa, il verso, la parola chiave e la riga dal corpus.
class _LetturaRuna extends StatelessWidget {
  const _LetturaRuna(
      {required this.runa,
      required this.indice,
      required this.palette,
      this.libera = false,
      this.voce,
      this.giuntura});

  final RunaGettata runa;
  final int indice;
  final MaestroPalette palette;

  /// Nel getto libero le rune lette sono in luce, non hanno il verso d'ombra.
  final bool libera;

  /// La Voce della Runa: la runa dentro la domanda e dentro il giorno.
  final String? voce;

  /// La giuntura del Verso delle Norne, quando la stesa e' a tre.
  final String? giuntura;

  @override
  Widget build(BuildContext context) {
    return ScrollReveal(
      depth: 1,
      child: DepthCard(
        key: Key('rune_card_$indice'),
        raised: true,
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LA GIUNTURA DELLE NORNE: il filo che lega le tre letture,
            // prima della carta, cosi' i tre blocchi diventano un verso.
            if (giuntura != null) ...[
              Text(giuntura!,
                  key: Key('rune_giuntura_$indice'),
                  style: TypographyTokens.didascalia().copyWith(
                      color: palette.goldSoft,
                      fontStyle: FontStyle.italic,
                      height: 1.4)),
              const SizedBox(height: SpacingTokens.xs),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PietraRuna(runa: runa, palette: palette),
                const SizedBox(width: SpacingTokens.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(runa.rune.name,
                          style: TypographyTokens.titoloSezione()
                              .copyWith(color: palette.goldSoft)),
                      // **LA GLOSSA UNA VOLTA SOLA, ordine S voce 24.** Quando
                      // c'e' la giuntura, la riga in corsivo sopra la scheda
                      // dice gia' di che posizione si tratta ("Dal fondo del
                      // pozzo, cio' che fu:"): ripeterla qui sotto la faceva
                      // leggere due volte in tre centimetri. Senza giuntura,
                      // cioe' in tutte le gettate che non sono le Norne, la
                      // glossa resta qui, perche' altrimenti non la direbbe
                      // nessuno.
                      Text(
                          giuntura == null
                              ? '${runa.posizione.titolo} · '
                                  '${runa.posizione.glossa}'
                              : runa.posizione.titolo,
                          style: TypographyTokens.corpo().copyWith(
                              color: palette.goldSoft.withValues(alpha: 0.8),
                              letterSpacing: 0.4)),
                      const SizedBox(height: 2),
                      // **LE SIMMETRICHE LO DICHIARANO ANCHE QUI**, ordine
                      // 2171 voce 4: "diritta" su una runa che diritta lo
                      // e' sempre non e' falso, ma lascia credere che
                      // sarebbe potuta uscire al contrario.
                      // DALL'ORDINE H anche sul telo il verso esce a
                      // sorte: "in luce" direbbe il falso su una runa
                      // rovesciata, quindi la scheda dice il verso come
                      // nelle altre gettate. E LA NOTA LUNGA NON E'
                      // MAIUSCOLETTO: accanto alla miniatura la colonna e'
                      // stretta, la nota delle simmetriche andava su due
                      // righe di lettere larghe, vista sull'anteprima.
                      // Un'etichetta che supera una riga passa a corpo,
                      // regola dell'ordine H voce 1.
                      if (kRuneSimmetriche.contains(runa.rune.name))
                        Text(SunsetRuneCorpus.noteSimmetrica,
                            style: TypographyTokens.didascalia().copyWith(
                                color: ColorTokens.textSecondary))
                      else
                        Text(runa.inOmbra ? 'in merkstave' : 'diritta',
                            style: TypographyTokens.etichetta().copyWith(
                                color: ColorTokens.textSecondary,
                                letterSpacing: 0.6)),
                      const SizedBox(height: 2),
                      Text(runa.rune.keyword,
                          style: TypographyTokens.didascalia().copyWith(
                              color: ColorTokens.textPrimary,
                              fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: SpacingTokens.sm),
            // La lettura della scheda passa dalla porta unica dei paragrafi:
            // sotto cinque righe non divide, quindi le righe brevi restano
            // come sono e quelle lunghe respirano.
            ParagrafiDiLettura(
                testo: runa.riga,
                stile: TypographyTokens.lettura()
                    .copyWith(color: ColorTokens.textPrimary)),
            // LA VOCE DELLA RUNA, di Caligo: la runa nel tuo giorno. E'
            // curatela dichiarata, mai tradizione, e per questo NON sta
            // accanto alla strofa con la fonte.
            if (voce != null) ...[
              const SizedBox(height: SpacingTokens.sm),
              ParagrafiDiLettura(
                  key: Key('rune_voce_$indice'),
                  testo: voce!,
                  stile: TypographyTokens.lettura()
                      .copyWith(color: palette.goldSoft)),
            ],
            // LA STROFA ATTESTATA, con la fonte nominata: la materia vera
            // della runa. Quando la strofa norrena non esiste, qui compare
            // comunque l'anglosassone, che copre tutte e ventiquattro.
            if (kRuneLore[runa.rune.name] != null) ...[
              const SizedBox(height: SpacingTokens.sm),
              Text(
                  '${kRuneLore[runa.rune.name]!.strofe.first.fonte}: '
                  '«${kRuneLore[runa.rune.name]!.strofe.first.traduzione}»',
                  key: Key('rune_strofa_$indice'),
                  style: TypographyTokens.corpo().copyWith(
                      color: ColorTokens.textSecondary, height: 1.45)),
            ],
          ],
        ),
      ),
    );
  }
}

/// La pietra incisa di una runa, che brilla, capovolta se in merkstave.
class _PietraRuna extends StatelessWidget {
  const _PietraRuna({required this.runa, required this.palette});

  final RunaGettata runa;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    final img = runa.rune.hasImage
        ? Image.asset(runa.rune.fullPath!,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => CustomPaint(
                  painter: RunePainter(
                      runeName: runa.rune.name,
                      color: Colors.white,
                      glow: palette.goldSoft,
                      intensity: 1.0),
                ))
        : CustomPaint(
            painter: RunePainter(
                runeName: runa.rune.name,
                color: Colors.white,
                glow: palette.goldSoft,
                intensity: 1.0),
          );
    return Container(
      width: 78,
      height: 94,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [
          palette.gold.withValues(alpha: 0.22),
          palette.gold.withValues(alpha: 0.0),
        ]),
      ),
      child: runa.inOmbra ? Transform.rotate(angle: math.pi, child: img) : img,
    );
  }
}

/// Condividi e Parlane con Caligo, piu' la card fuori campo per lo scatto.
class _Azioni extends StatefulWidget {
  const _Azioni(
      {required this.palette, required this.esito, required this.presagio});

  final MaestroPalette palette;
  final EsitoGettata esito;
  final String presagio;

  @override
  State<_Azioni> createState() => _AzioniState();
}

class _AzioniState extends State<_Azioni> {
  final GlobalKey _cardBoundary = GlobalKey();
  bool _condividendo = false;
  bool _renderCard = false;

  Future<void> _condividi() async {
    setState(() {
      _condividendo = true;
      _renderCard = true;
    });
    try {
      await WidgetsBinding.instance.endOfFrame;
      await Future<void>.delayed(const Duration(milliseconds: 80));
      await shareRuneCard(boundaryKey: _cardBoundary, esito: widget.esito);
    } finally {
      if (mounted) setState(() => _condividendo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OutlinedButton.icon(
                key: const Key('rune_share'),
                style: OutlinedButton.styleFrom(
                    foregroundColor: palette.goldSoft,
                    side:
                        BorderSide(color: palette.gold.withValues(alpha: 0.6))),
                onPressed: _condividendo ? null : _condividi,
                icon: const Icon(Icons.ios_share_rounded),
                label: const Text('Condividi'),
              ),
              const SizedBox(height: SpacingTokens.sm),
              FilledButton.icon(
                key: const Key('rune_consulta'),
                style: FilledButton.styleFrom(
                    backgroundColor: palette.primary,
                    foregroundColor: palette.onPrimary),
                onPressed: () {
                  final services = context.read<AppServices>();
                  final nomi =
                      widget.esito.rune.map((r) => r.rune.name).toList();
                  Navigator.of(context).push(MaestroChatScreen.route(
                      maestro: Maestro.caligo,
                      services: services,
                      initialUserMessage: ChatOpeners.runa(
                          widget.esito.gettata.nome, nomi)));
                },
                icon: const Icon(Icons.forum_outlined),
                label: const Text('Parlane con Caligo'),
              ),
            ],
          ),
        ),
        if (_renderCard)
          Positioned(
            left: -3000,
            top: 0,
            child: RepaintBoundary(
              key: _cardBoundary,
              child: RuneShareCard(
                  esito: widget.esito, presagio: widget.presagio),
            ),
          ),
      ],
    );
  }
}

/// Il selettore delle gettate, a pillole che vanno a capo. Estensibile: legge da
/// [gettate], una quarta gettata compare da sola. Ogni pillola e' dimensionata
/// sul suo contenuto, cosi' il nome si legge sempre per intero, mai troncato.
class _SelettoreGettate extends StatelessWidget {
  const _SelettoreGettate(
      {required this.corrente, required this.palette, required this.onSelect});

  final GettataRune corrente;
  final MaestroPalette palette;
  final ValueChanged<GettataRune> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      key: const Key('rune_selector'),
      alignment: WrapAlignment.center,
      spacing: SpacingTokens.xs,
      runSpacing: SpacingTokens.xs,
      children: [
        for (final g in gettate)
          GestureDetector(
            key: Key('rune_segment_${g.id}'),
            behavior: HitTestBehavior.opaque,
            onTap: () => onSelect(g),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.md, vertical: SpacingTokens.sm),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
                color: g.id == corrente.id
                    ? palette.gold.withValues(alpha: 0.2)
                    : palette.deepest.withValues(alpha: 0.4),
                border: Border.all(
                    color: palette.gold
                        .withValues(alpha: g.id == corrente.id ? 0.7 : 0.3)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Nome per intero, senza ellissi: la pillola cresce col testo.
                  Text(g.nome,
                      textAlign: TextAlign.center,
                      style: TypographyTokens.etichetta().copyWith(
                        color: g.id == corrente.id
                            ? palette.goldSoft
                            : ColorTokens.textSecondary,
                        letterSpacing: 0.2,
                      )),
                  Text(g.sottotitolo,
                      textAlign: TextAlign.center,
                      style: TypographyTokens.etichetta().copyWith(
                        color: g.id == corrente.id
                            ? palette.goldSoft.withValues(alpha: 0.8)
                            : ColorTokens.textSecondary.withValues(alpha: 0.7),
                      )),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Un suggerimento di domanda tappabile, a pillola.
class _ContoDelleGettate extends StatelessWidget {
  const _ContoDelleGettate({
    required this.rimaste,
    required this.limite,
    required this.palette,
  });

  final int? rimaste;
  final int? limite;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    if (rimaste == null || limite == null) return const SizedBox.shrink();
    final testo = rimaste! > 0
        ? 'Gettate di oggi: $rimaste di $limite'
        : 'Le gettate di oggi sono finite: si riparte domani.';
    return Padding(
      padding: const EdgeInsets.only(top: SpacingTokens.xs),
      child: Text(
        testo,
        key: const Key('rune_conto_gettate'),
        textAlign: TextAlign.center,
        style: TypographyTokens.didascalia().copyWith(
            color: rimaste! > 0
                ? ColorTokens.textSecondary
                : palette.goldSoft),
      ),
    );
  }
}

class _PozzoUrdhr extends StatefulWidget {
  const _PozzoUrdhr({
    required this.palette,
    required this.gettata,
    required this.esito,
    required this.seme,
    required this.animazioni,
  });

  final MaestroPalette palette;
  final GettataRune gettata;
  final EsitoGettata? esito;

  /// Il seme della fisica, da persona, giorno, domanda e rune uscite: la
  /// caduta e' deterministica, mai un caso vero. Vedi FisicaDellaGettata.
  final int seme;
  final bool animazioni;

  @override
  State<_PozzoUrdhr> createState() => _PozzoUrdhrState();
}

class _PozzoUrdhrState extends State<_PozzoUrdhr>
    with TickerProviderStateMixin {
  late final AnimationController _onde = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  /// LA CADUTA. Milletrecento millisecondi per l'intera cascata: le pietre
  /// scendono, rimbalzano due volte smorzate, si fermano storte. Con Riduci
  /// Movimento diventa una dissolvenza breve sulle posizioni finali: il
  /// risultato non si perde, si perde solo il moto.
  late final AnimationController _caduta = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  );

  /// La fisica della gettata in corso, costruita quando si conosce la
  /// larghezza vera del pozzo. Nulla in preparazione.
  FisicaDellaGettata? _fisica;
  double _larghezzaFisica = 0;

  /// Le pietre che hanno gia' toccato: a ogni contatto la vibrazione, al
  /// primo anche il suono, dietro l'interruttore unico che gia' esiste.
  final Set<int> _toccate = {};

  @override
  void initState() {
    super.initState();
    _caduta.addListener(_alPassoDellaCaduta);
    _caduta.addStatusListener((s) {
      // L'acqua si increspa quando le pietre sono POSATE, non prima: i
      // cerchi nascono dal contatto, e prima del contatto non c'e' niente
      // che li generi.
      if (s == AnimationStatus.completed && widget.animazioni) {
        _onde.forward(from: 0);
      }
    });
    if (widget.esito != null) _parteLaCaduta();
  }

  @override
  void didUpdateWidget(_PozzoUrdhr old) {
    super.didUpdateWidget(old);
    if (widget.esito != null && !identical(widget.esito, old.esito)) {
      _parteLaCaduta();
    }
  }

  void _parteLaCaduta() {
    _fisica = null; // si ricostruisce con la larghezza vera al primo build
    _toccate.clear();
    if (widget.animazioni) {
      _caduta.duration = const Duration(milliseconds: 1300);
      _caduta.forward(from: 0);
    } else {
      // Riduci Movimento: la dissolvenza breve, senza perdere il risultato.
      _caduta.duration = const Duration(milliseconds: 250);
      _caduta.forward(from: 0);
    }
  }

  void _alPassoDellaCaduta() {
    final f = _fisica;
    if (f == null || !widget.animazioni || !mounted) return;
    for (var i = 0; i < f.quante; i++) {
      if (!_toccate.contains(i) && _caduta.value >= f.primoContatto(i)) {
        _toccate.add(i);
        if (_toccate.length == 1) {
          // Il primo sasso che tocca: vibrazione piena e il suono della
          // pietra, dietro l'interruttore di silenzio che gia' esiste.
          PaletteSensoriale.momento(context,
              aptica: SchemaAptico.conferma, suono: SuonoDelCerchio.pietra);
        } else {
          // Gli altri: un tick leggero ciascuno, il contatto si sente ma
          // non diventa una raffica.
          PaletteSensoriale.vibra(context, SchemaAptico.tocco);
        }
      }
    }
  }

  @override
  void dispose() {
    _onde.dispose();
    _caduta.dispose();
    super.dispose();
  }

  /// Le posizioni normalizzate delle rune nel pozzo, per gettata.
  List<Offset> _punti(GettataRune g) {
    switch (g.id) {
      case 'norne':
        return const [Offset(0.2, 0.5), Offset(0.5, 0.5), Offset(0.8, 0.5)];
      case 'croce':
        return const [
          Offset(0.5, 0.5), // Cuore
          Offset(0.5, 0.82), // Radice
          Offset(0.2, 0.5), // Ostacolo
          Offset(0.8, 0.5), // Consiglio
          Offset(0.5, 0.18), // Esito
        ];
      default:
        return const [Offset(0.5, 0.5)];
    }
  }

  @override
  Widget build(BuildContext context) {
    final libera = widget.gettata.libera;
    final esito = widget.esito;
    // Le pietre da posare con la loro posizione, piu' i punti di lettura per i
    // fili e i cerchi: le posizioni fisse, oppure lo scatter libero sul telo.
    final pietre = <MapEntry<RunaGettata, Offset>>[];
    final puntiLettura = <Offset>[];
    if (esito != null) {
      if (libera) {
        for (final s in esito.sparse) {
          if (s.punto != null) pietre.add(MapEntry(s, s.punto!));
        }
        for (final r in esito.rune) {
          if (r.punto != null) puntiLettura.add(r.punto!);
        }
      } else {
        final punti = _punti(widget.gettata);
        for (var i = 0; i < esito.rune.length && i < punti.length; i++) {
          pietre.add(MapEntry(esito.rune[i], punti[i]));
          puntiLettura.add(punti[i]);
        }
      }
    }
    return SizedBox(
      key: const Key('rune_well'),
      // PRIMA DEL GETTO NIENTE RIQUADRO RISERVATO, ordine L voce 2a: il telo
      // in attesa e' un accenno di 140 punti, non una scena vuota da 300. I
      // 300 servono solo quando le pietre ci sono davvero.
      height: esito == null ? 140 : 300,
      child: LayoutBuilder(
        builder: (context, box) {
          final w = box.maxWidth;
          final h = box.maxHeight;
          // LA FISICA SI COSTRUISCE QUI, dove la larghezza e' quella vera:
          // le semiestensioni normalizzate delle pietre, 52 per 64 punti,
          // dipendono dal telo reale e non da una stima. E' una costruzione
          // pura e costa una manciata di conti, quindi puo' vivere nel build.
          if (esito != null &&
              (_fisica == null || _larghezzaFisica != w) &&
              pietre.isNotEmpty) {
            _fisica = FisicaDellaGettata(
              seme: widget.seme,
              arrivi: [for (final e in pietre) e.value],
              semiLarghezza: 26 / w,
              semiAltezza: 32 / h,
            );
            _larghezzaFisica = w;
          }
          final fisica = _fisica;
          return AnimatedBuilder(
            animation: Listenable.merge([_onde, _caduta]),
            builder: (context, _) {
              final t = _caduta.value;
              final inVolo =
                  widget.animazioni && fisica != null && !_caduta.isCompleted;
              // I punti di lettura seguono le pietre SEPARATE: i fili delle
              // Norne e i cerchi devono toccare le pietre dove stanno
              // davvero, non dove il caso le aveva ammucchiate.
              final lettura = <Offset>[];
              if (esito != null && fisica != null) {
                if (libera) {
                  for (final r in esito.rune) {
                    for (var i = 0; i < pietre.length; i++) {
                      if (pietre[i].key.rune.name == r.rune.name) {
                        lettura.add(fisica.arrivi[i]);
                        break;
                      }
                    }
                  }
                } else {
                  lettura.addAll(fisica.arrivi);
                }
              }
              return Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _PozzoPainter(
                        palette: widget.palette,
                        punti: lettura.isNotEmpty ? lettura : puntiLettura,
                        posato: esito != null && !inVolo,
                        libera: libera,
                        onda: (esito != null && _onde.isAnimating)
                            ? _onde.value
                            : -1,
                      ),
                    ),
                  ),
                  if (fisica != null)
                    for (var i = 0; i < pietre.length; i++)
                      ..._pietraConOmbra(fisica, i, pietre[i].key, t, w, h),
                ],
              );
            },
          );
        },
      ),
    );
  }

  /// La pietra [i] al tempo [t] della caduta, con la sua ombra a terra.
  ///
  /// L'ombra sta sul telo nel punto di caduta: larga e chiara quando la
  /// pietra e' in aria, stretta e scura al contatto, e il piccolo rimbalzo
  /// dell'ombra viene da se', perche' segue la quota che rimbalza.
  List<Widget> _pietraConOmbra(FisicaDellaGettata fisica, int i,
      RunaGettata runa, double t, double w, double h) {
    final StatoPietra stato;
    if (widget.animazioni) {
      stato = fisica.a(i, t);
    } else {
      // Riduci Movimento: gia' posata, la dissolvenza la fa l'opacita'.
      stato = StatoPietra(
        posizione: fisica.arrivi[i],
        rotazione: fisica.inclinazioniFinali[i],
        quota: 0,
        visibile: true,
      );
    }
    if (!stato.visibile) return const [];
    final suolo = Offset(stato.posizione.dx * w, stato.posizione.dy * h);
    // Quanto la pietra si alza dal telo, in punti, alla quota massima.
    const alzata = 70.0;
    final scalaOmbra = 1 + 0.8 * stato.quota;
    final opacita = widget.animazioni ? 1.0 : t.clamp(0.0, 1.0);
    return [
      Positioned(
        left: suolo.dx - 22 * scalaOmbra,
        top: suolo.dy + 22 - 6 * scalaOmbra,
        child: IgnorePointer(
          child: Opacity(
            opacity: opacita,
            child: Container(
              width: 44 * scalaOmbra,
              height: 12 * scalaOmbra,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.elliptical(
                    22 * scalaOmbra, 6 * scalaOmbra)),
                color: Colors.black
                    .withValues(alpha: 0.30 * (1 - 0.55 * stato.quota)),
              ),
            ),
          ),
        ),
      ),
      Positioned(
        left: suolo.dx - 26,
        top: suolo.dy - 32 - alzata * stato.quota,
        child: Opacity(
          opacity: opacita,
          child: Transform.rotate(
            angle: stato.rotazione,
            child: _PietraPosata(
                key: Key('runa_posata_$i'),
                runa: runa,
                palette: widget.palette,
                coperta: runa.coperta),
          ),
        ),
      ),
    ];
  }
}

/// Una pietra posata, piccola, capovolta se in merkstave.
///
/// **Se coperta, mostra IL RETRO VERGINE della SUA pietra**, dalla porta
/// unica RetroDellaRuna. Prima mostrava la miniatura del FRONTE a opacita'
/// 0,35: il fronte velato, peggio di uno slot, perche' anticipava la runa che
/// la persona doveva ancora scoprire. Visto da Mauro sul telefono, ordine del
/// 7 agosto 2026.
class _PietraPosata extends StatelessWidget {
  const _PietraPosata(
      {super.key,
      required this.runa,
      required this.palette,
      this.coperta = false});

  final RunaGettata runa;
  final MaestroPalette palette;
  final bool coperta;

  @override
  Widget build(BuildContext context) {
    if (coperta) {
      // La runa non si e' ancora mostrata: si vede il retro della sua
      // pietra, mai il fronte, nemmeno velato. Il retro non si capovolge:
      // un dorso non ha un verso leggibile.
      return RetroDellaRuna(
        stem: runa.rune.stem,
        width: 52,
        height: 64,
        ripiego: (_) => _sassoDelTelo(),
      );
    }
    final img = SizedBox(
      width: 52,
      height: 64,
      child: runa.rune.hasImage
          ? Image.asset(runa.rune.thumbPath!,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => CustomPaint(
                    painter: RunePainter(
                        runeName: runa.rune.name,
                        color: Colors.white,
                        glow: palette.goldSoft,
                        intensity: 1.0),
                  ))
          : CustomPaint(
              painter: RunePainter(
                  runeName: runa.rune.name,
                  color: Colors.white,
                  glow: palette.goldSoft,
                  intensity: 1.0),
            ),
    );
    return runa.inOmbra ? Transform.rotate(angle: math.pi, child: img) : img;
  }

  /// Il sasso dipinto del telo, quando l'asset del retro manca.
  Widget _sassoDelTelo() => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const RadialGradient(colors: [
            Color(0xFFE8DFC9),
            Color(0xFFCFC3A6),
          ]),
          border: Border.all(color: palette.gold.withValues(alpha: 0.25)),
        ),
      );
}


/// I cerchi concentrici dai punti di caduta, i fili delle Norne e, nel getto
/// libero, il panno di Tacito. Statico quando le onde sono spente.
///
/// L'ACQUA ROSSA DEL POZZO NON C'E' PIU', ordine 2161 voce 6: era un
/// `drawRect` col rosso di Caligo sotto le pietre, un fondale bespoke
/// squadrato contro la regola del cosmo condiviso. Nelle stese fisse le
/// pietre cadono sul cosmo, che c'e' gia'.
class _PozzoPainter extends CustomPainter {
  _PozzoPainter({
    required this.palette,
    required this.punti,
    required this.posato,
    required this.onda,
    this.libera = false,
  });

  final MaestroPalette palette;
  final List<Offset> punti;
  final bool posato;

  /// Vero per il getto sul telo: il fondo e' un panno bianco, i fili partono dal
  /// centro verso le rune lette per vicinanza.
  final bool libera;

  /// Avanzamento dell'onda, da zero a uno, negativo se ferma.
  final double onda;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Solo il getto libero ha un fondo suo, il panno di Tacito, che e' la
    // fonte del rito e non decorazione. Le stese fisse non dipingono fondo:
    // il rettangolo rosso dell'acqua e' quello che Mauro ha bocciato.
    if (libera) {
      _telo(canvas, size, rect);
    }

    if (!posato) return;

    final centri = [
      for (final p in punti) Offset(p.dx * size.width, p.dy * size.height),
    ];

    // I fili sottili delle Norne. Sul telo partono dal centro verso le rune
    // lette; nelle stese fisse dal primo punto verso gli altri.
    final filo = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = palette.goldSoft.withValues(alpha: libera ? 0.55 : 0.4);
    if (libera) {
      final centro = Offset(size.width / 2, size.height / 2);
      for (final c in centri) {
        canvas.drawLine(centro, c, filo);
      }
    } else if (centri.length > 1) {
      for (var i = 1; i < centri.length; i++) {
        canvas.drawLine(centri.first, centri[i], filo);
      }
    }

    // I cerchi concentrici dove ogni runa tocca l'acqua.
    for (final c in centri) {
      // Anelli fermi, sempre presenti, come pietre gia' posate.
      for (var k = 1; k <= 2; k++) {
        canvas.drawCircle(
          c,
          14.0 * k,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2
            ..color = palette.goldSoft.withValues(alpha: 0.18 / k),
        );
      }
      // Onde vive che si propagano, solo mentre l'animazione gira.
      if (onda >= 0) {
        for (var k = 0; k < 3; k++) {
          final fase = (onda - k * 0.18).clamp(0.0, 1.0);
          if (fase <= 0) continue;
          canvas.drawCircle(
            c,
            fase * size.shortestSide * 0.32,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.2 * (1 - fase)
              ..color = palette.goldSoft.withValues(alpha: 0.5 * (1 - fase)),
          );
        }
      }
    }
  }

  /// Il panno bianco di Tacito: un telo chiaro e caldo con una trama leggera e
  /// un segno d'oro al centro, dove la vicinanza pesa.
  ///
  /// NON E' UN RETTANGOLO, dall'ordine 2161 voce 6: un panno gettato a terra
  /// non ha angoli retti ne' bordi dritti. La sagoma e' un superellisse con
  /// quattro armoniche di ondulazione, fisse e dichiarate: stessa forma a
  /// ogni apertura, perche' il panno e' un oggetto del rito, non una sorte.
  /// Il bordo e' morbido per la sfumatura sul riempimento; la trama e i
  /// segni del centro restano ritagliati dentro la sagoma viva.
  ///
  /// Il panno resta perche' E' LA FONTE: Tacito, Germania, capitolo dieci,
  /// le sorti incise gettate sopra un candido panno. E' nominato nel
  /// pannello Fonti e metodo (kRuneFontiEMetodo).
  void _telo(Canvas canvas, Size size, Rect rect) {
    final sagoma = _sagomaDelPanno(size);
    canvas.drawPath(
      sagoma,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF0E7D3), Color(0xFFD2C09B)],
        ).createShader(rect)
        // Il bordo morbido: la stoffa non taglia l'aria come una lama.
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.save();
    canvas.clipPath(sagoma);
    // Trama del tessuto, righe tenui nelle due direzioni, dentro la sagoma.
    final trama = Paint()
      ..strokeWidth = 1
      ..color = const Color(0xFF7A6A4A).withValues(alpha: 0.08);
    for (var i = 1; i < 10; i++) {
      final y = size.height * i / 10;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), trama);
      final x = size.width * i / 10;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), trama);
    }
    // Il centro del telo, dove la vicinanza pesa di piu'.
    final c = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(
      c,
      size.shortestSide * 0.06,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = palette.gold.withValues(alpha: 0.5),
    );
    canvas.drawCircle(
        c, 2.5, Paint()..color = palette.gold.withValues(alpha: 0.6));
    canvas.restore();
  }

  /// La sagoma del panno: un superellisse (esponente 2,6, che gonfia verso
  /// gli angoli piu' di un'ellisse senza mai farli retti) modulato da
  /// quattro armoniche fisse. Le fasi sono scelte perche' le derivate non si
  /// annullino insieme in nessun punto: e' cio' che impedisce al bordo di
  /// tenere la stessa quota per una corsa lunga, cioe' di tornare dritto.
  Path _sagomaDelPanno(Size size) {
    const passi = 96;
    const p = 2.6;
    final cx = size.width / 2, cy = size.height / 2;
    final rx = size.width * 0.475, ry = size.height * 0.465;
    final path = Path();
    for (var i = 0; i <= passi; i++) {
      final t = i / passi * 2 * math.pi;
      final onda = 1 +
          0.045 * math.sin(2 * t + 0.9) +
          0.030 * math.sin(5 * t + 2.2) +
          0.024 * math.sin(9 * t + 4.1) +
          0.017 * math.sin(13 * t + 1.3);
      final c = math.cos(t), s = math.sin(t);
      final x = cx + rx * onda * c.sign * math.pow(c.abs(), 2 / p);
      final y = cy + ry * onda * s.sign * math.pow(s.abs(), 2 / p);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(_PozzoPainter old) =>
      old.onda != onda ||
      old.posato != posato ||
      old.punti != punti ||
      old.libera != libera;
}

/// LE PIETRE COPERTE, cioe' il sacchetto prima della sorte.
///
/// **Perche' esiste.** Senza un retro non si puo' mostrare una pietra coperta,
/// e senza pietre coperte il lancio non ha un prima: la schermata passava dal
/// pulsante alle rune gia' scoperte, e la sorte non si vedeva accadere.
///
/// **Il retro e' quello della SUA pietra.** Non c'e' un dorso unico: ogni runa
/// ha il proprio osso, con la sua forma e la sua venatura, e coperta si vede
/// quello. Qui la sorte non e' ancora stata gettata, quindi le pietre mostrate
/// sono le prime del catalogo e non anticipano niente: un retro non dice quale
/// runa sia, ed e' esattamente il motivo per cui serve.
class _PietreCoperte extends StatelessWidget {
  const _PietreCoperte({required this.palette, required this.quante});

  final MaestroPalette palette;
  final int quante;

  @override
  Widget build(BuildContext context) {
    // Al massimo cinque: oltre, in una riga da telefono, diventano francobolli.
    final n = quante.clamp(1, 5);
    return SizedBox(
      key: const Key('rune_pietre_coperte'),
      height: 96,
      // **RIENTRANO INVECE DI SFORARE.** Cinque pietre da sessantadue punti
      // piu' i margini fanno trecentocinquanta su una larghezza utile di
      // trecentododici: la riga sforava di trentotto pixel, e l'ha preso la
      // cattura. Si rimpiccioliscono, come fanno le tessere delle arti.
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < n; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.rotate(
                // Un filo di inclinazione alternata: pietre allineate in
                // riga sembrano un menu, non un pugno di sassi.
                angle: (i.isEven ? 1 : -1) * 0.06 * (i + 1),
                // LA PORTA UNICA DEL RETRO: ragione su RetroDellaRuna.
                child: RetroDellaRuna(
                    stem: kElderFuthark[i % kElderFuthark.length].stem,
                    width: 62,
                    height: 76),
              ),
            ),
        ],
        ),
      ),
    );
  }
}

/// LA TENDINA DELLE DOMANDE, due famiglie in un menu solo. Ordine S voce 21.
///
/// **Perche' un menu e non due elenchi affiancati.** La domanda si pone prima di
/// gettare, quindi sta sopra il pulsante, e sopra il pulsante lo spazio e' quello
/// che e': due elenchi aperti spingerebbero il getto sotto la piega, cioe'
/// rifarebbero il difetto che questa voce chiude. Il menu porta le due famiglie
/// come sezioni, coi loro nomi, quelli che la chat mostra da sempre.
///
/// **Le personali che non hanno il loro dato non compaiono.** Una voce che nomina
/// la tua Luna quando l'app non sa la tua Luna e' una promessa che nessuno
/// mantiene, ed e' la stessa famiglia dell'etichetta che diceva "In arrivo".
class _TendinaDelleDomande extends StatelessWidget {
  const _TendinaDelleDomande({
    required this.palette,
    required this.datiDisponibili,
    required this.onScelta,
  });

  final MaestroPalette palette;
  final Set<DatoPerLaDomanda> datiDisponibili;
  final void Function(String testo) onScelta;

  @override
  Widget build(BuildContext context) {
    final generiche = DomandeDelCerchio.perLaGettata(
        FamigliaDellaDomanda.generiche,
        datiDisponibili: datiDisponibili);
    final personali = DomandeDelCerchio.perLaGettata(
        FamigliaDellaDomanda.personali,
        datiDisponibili: datiDisponibili);
    return PopupMenuButton<String>(
      key: const Key('rune_tendina_domande'),
      tooltip: 'Scegli una domanda',
      color: palette.surfaceElevated,
      onSelected: onScelta,
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          enabled: false,
          child: Text(FamigliaDellaDomanda.generiche.etichetta,
              style: TypographyTokens.etichetta()
                  .copyWith(color: palette.goldSoft, letterSpacing: 0.6)),
        ),
        for (final d in generiche)
          PopupMenuItem<String>(
            value: d.testo,
            child: Text(d.testo,
                style: TypographyTokens.didascalia()
                    .copyWith(color: ColorTokens.textPrimary)),
          ),
        if (personali.isNotEmpty) ...[
          const PopupMenuDivider(),
          PopupMenuItem<String>(
            enabled: false,
            child: Text(FamigliaDellaDomanda.personali.etichetta,
                style: TypographyTokens.etichetta()
                    .copyWith(color: palette.goldSoft, letterSpacing: 0.6)),
          ),
          for (final d in personali)
            PopupMenuItem<String>(
              value: d.testo,
              child: Text(d.testo,
                  style: TypographyTokens.didascalia()
                      .copyWith(color: ColorTokens.textPrimary)),
            ),
        ],
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.md, vertical: SpacingTokens.sm),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
          border: Border.all(color: palette.gold.withValues(alpha: 0.4)),
          color: palette.deepest.withValues(alpha: 0.4),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text('Scegli una domanda',
                  style: TypographyTokens.didascalia()
                      .copyWith(color: palette.goldSoft)),
            ),
            // **IL TRIANGOLO E NON LA FRECCIA IN GIU'.** La prova
            // `ogni_freccia_mantiene` lo ha preso al volo: una freccia in giu'
            // promette "qui sotto c'e' altro testo, te lo mostro", e questa
            // tendina non apre del testo, apre delle scelte. Il triangolo pieno
            // e' l'affordance del selettore, e la prova lo dichiara come
            // famiglia diversa di proposito.
            Icon(Icons.arrow_drop_down, size: 22, color: palette.goldSoft),
          ],
        ),
      ),
    );
  }
}
