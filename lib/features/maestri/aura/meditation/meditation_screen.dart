import '../../../maestri/widgets/foglio_delle_fonti.dart';
import 'dart:math' as math;

import 'dart:async';

import '../../../sigilli/regia_del_cammino.dart';

import 'package:flutter/material.dart';

import '../../../../design_system/theme/maestro_palette.dart';
import '../../../../design_system/theme/maestro_scope.dart';
import '../../../../design_system/tokens/color_tokens.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';
import '../../../../core/maestro/chakra_del_giorno.dart';
import '../../../../core/maestro/colore_del_centro.dart';
import 'card_del_respiro.dart';
import '../../../../core/maestro/memoria_del_respiro.dart';
import '../../../../core/maestro/cio_che_aura_ricorda.dart';
import '../../../../core/maestro/frequenza_del_giorno.dart';
import '../../../../core/maestro/traccia_del_loto.dart';
import '../../../../core/sensi/respiro_guidato_dal_dito.dart';
import '../../../../core/sensi/palette_sensoriale.dart';
import 'loto_che_respira.dart';
import 'pannello_della_libreria.dart';
import '../../../../core/maestro/sequenza_di_aura.dart';
import 'meditation_audio.dart';
import '../../../../core/maestro/maestro.dart';
import '../../rotta_arte.dart';
import '../../../../../design_system/components/titolo_che_non_si_rompe.dart';
import '../../../../design_system/transizioni/passaggio_del_cerchio.dart';
import '../../../../design_system/typography/paragrafi_di_lettura.dart';

/// Meditazione di Aura con suono e cimatica.
///
/// Tre strati che nascono l'uno dall'altro: uno strato sonoro generato a runtime
/// (toni a 432 e 528 Hz e un battito binaurale, da ascoltare con le cuffie), un
/// visualizzatore a cimatica (un mandala di geometria sacra che nasce dal suono
/// e pulsa col respiro) e una guida al respiro. Fondamento onesto: cornice di
/// benessere e non cura, le frequenze come tradizione culturale, non fatto
/// medico. Il disclaimer completo sta all'ingresso, non si ripete qui.
///
/// La prova dell'audio resta al device, dietro `TonePlayer`: in headless si usa
/// il lettore silenzioso, che genera comunque i toni senza riprodurli.
class MeditationScreen extends StatefulWidget {
  MeditationScreen({super.key, TonePlayer? player, this.now})
      : player = player ?? LettoreToniReale();

  final TonePlayer player;

  /// **IL GIORNO, per la frequenza e per il centro.** Ordine CZ voce 06: la
  /// meditazione di oggi ha una frequenza sola, quella del centro acceso
  /// oggi, e una prova deve poter dire di che giorno si tratta senza
  /// aspettare martedi'.
  final DateTime? now;

  static Route<void> route({TonePlayer? player, DateTime? now}) {
    return PassaggioDelCerchio.rotta<void>((_) => SogliaArte(
        id: 'meditation',
        maestro: Maestro.aura,
        child: MeditationScreen(player: player, now: now)));
  }

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen>
    with TickerProviderStateMixin {
  // Il respiro: inspira, trattieni, espira, in un ciclo lento e continuo.
  static const int _inhaleMs = 4000;
  static const int _holdMs = 2000;
  static const int _exhaleMs = 5000;
  static const int _cycleMs = _inhaleMs + _holdMs + _exhaleMs;

  late final AnimationController _breath;
  MeditationPreset _preset = MeditationPreset.calm432;
  bool _active = false;

  /// **LA MEDITAZIONE HA UNA FINE, ordine BF voce 05.b (ordine P voce 35).**
  /// Prima il respiro girava in cerchio per sempre: la schermata non
  /// arrivava a una chiusura, non accendeva traguardi e non funzionava come
  /// rito. La sessione dura [cicliDellaSessione] cicli di respiro (dodici
  /// da undici secondi, poco piu' di due minuti): al compimento il tono si
  /// ferma, la scena lo dice, e la regia registra il gesto `meditazione`,
  /// che e' cio' che sveglia aur_50 e aur_51. Il tempo lo tiene un Timer e
  /// non l'animazione, cosi' il compimento arriva anche con Riduci
  /// Movimento, dove il respiro visivo sta fermo.
  static const int cicliDellaSessione = 12;
  Timer? _sessione;
  bool _compiuta = false;

  /// **IL RESPIRO VERO DI CHI RESPIRA. Ordine CZ voce 08**, 8 settembre 2026.
  ///
  /// Il dito giu' e' l'inspiro, il dito alzato e' l'espiro, e sono i suoi
  /// tempi a muovere il fiore. Il ritmo guidato resta come **seconda strada
  /// dichiarata**, per chi non vuole tenere il dito: e' `_breath`, quello di
  /// prima, e non e' nascosto.
  final RespiroGuidatoDalDito _dito = RespiroGuidatoDalDito();

  /// La traccia dei giorni, che riempie il fiore. Ordine CZ voce 10.
  final TracciaDelLoto _traccia = TracciaDelLoto();

  /// **CIO' CHE LA MEDITAZIONE RICORDA.** Ordine DB voci 07 e 09.
  final MemoriaDelRespiro _memoria = MemoriaDelRespiro();

  /// **I RITI CHE LA PERSONA SI E' COSTRUITA.** Ordine DB voce 05.
  final SequenzeDiAura _sequenze = SequenzeDiAura();

  /// La frase che Aura dice alla fine, quando la memoria ha qualcosa di vero
  /// da dire. Nulla quando non ce l'ha: **non si inventa niente**.
  String? _cioCheAuraRicorda;

  /// Quando e' cominciata la sessione, per sapere quanto e' durata.
  DateTime? _cominciata;

  /// Il riquadro da cui nasce l'immagine della card del respiro.
  final GlobalKey _boundaryDellaCard = GlobalKey();

  /// Vero quando la persona ha chiesto meno movimento: i petali non si
  /// animano, la fase cambia con uno stato fermo, e la vibrazione resta.
  bool _riduciMovimento = false;

  /// Se la scelta libera della frequenza e' aperta. Chiusa di partenza: la
  /// porta principale la decide Aura.
  bool _sceltaAperta = false;

  /// L'indice del centro acceso oggi, per accenderne il petalo.
  int get _indiceDelCentro {
    final oggi = FrequenzaDelGiorno.centroDi(widget.now ?? DateTime.now());
    final i = ChakraDelGiorno.tutti.indexWhere((c) => c.nome == oggi.nome);
    return i < 0 ? 0 : i;
  }

  @override
  void initState() {
    super.initState();
    _breath = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _cycleMs),
    );
    // La traccia si legge dal disco: il fiore deve gia' portare i giorni
    // quando compare, non riempirsi sotto gli occhi di chi guarda.
    unawaited(_memoria.carica());
    // I riti composti si leggono dal disco: chi ne ha uno deve trovarlo gia'
    // in fondo alla libreria, non vederlo comparire dopo.
    unawaited(_sequenze.carica().then((_) {
      if (mounted) setState(() {});
    }));
    unawaited(_traccia.carica().then((_) {
      if (mounted) setState(() {});
    }));
  }

  /// **IL GIRO PARTE SOLO SENZA RIDUCI MOVIMENTO, ordine AJ voce 01**: il
  /// repeat di `_breath` girava anche per chi ha chiesto meno movimento. La
  /// MediaQuery non si legge in initState, quindi la guardia sta qui e vale
  /// a ogni cambio di dipendenze.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _riduciMovimento = MediaQuery.of(context).disableAnimations;
    if (_riduciMovimento) {
      if (_breath.isAnimating) _breath.stop();
    } else {
      if (!_breath.isAnimating) _breath.repeat();
    }
  }

  @override
  void dispose() {
    // IL TONO SI FERMA QUI. Prima si chiudeva il respiro e basta: il tono suona
    // in ciclo continuo, quindi uscendo dalla schermata restava acceso per
    // sempre. Che fosse una dimenticanza e non una scelta lo diceva il Rito del
    // Sogno, che con lo stesso lettore lo fermava gia'.
    _sessione?.cancel();
    widget.player.stop();
    _breath.dispose();
    super.dispose();
  }

  // Da 0 a 1: quanto e' pieno il respiro adesso, piu' l'etichetta della fase.
  ({double fill, String phase}) _breathState() {
    final ms = _breath.value * _cycleMs;
    if (ms < _inhaleMs) {
      return (
        fill: Curves.easeInOut.transform(ms / _inhaleMs),
        phase: 'Inspira'
      );
    }
    if (ms < _inhaleMs + _holdMs) {
      return (fill: 1.0, phase: 'Trattieni');
    }
    final e = (ms - _inhaleMs - _holdMs) / _exhaleMs;
    return (fill: 1.0 - Curves.easeInOut.transform(e), phase: 'Espira');
  }

  /// **IL DITO SCENDE: inspira.** Ordine CZ voce 08.
  void _inspira() {
    _dito.ditoGiu(DateTime.now());
    // La vibrazione al cambio di fase e' cio' che rende il rito possibile a
    // occhi chiusi: senza, chi chiude gli occhi non sa quando cambiare.
    // **LA VIBRAZIONE PASSA DALLA PORTA UNICA.** `PaletteSensoriale` e' il
    // solo posto dell'app che parla alla piattaforma per suonare o vibrare, e
    // due guardie lo pretendono: chiamare `HapticFeedback` da qui vorrebbe
    // dire una seconda verita' su cosa il telefono fa sotto le dita.
    unawaited(PaletteSensoriale.vibra(context, SchemaAptico.tocco));
    setState(() {});
  }

  /// **IL DITO SI ALZA: espira, e il respiro si chiude.**
  void _espira() {
    final adesso = DateTime.now();
    _dito.ditoSu(adesso);
    // **LA VIBRAZIONE PASSA DALLA PORTA UNICA.** `PaletteSensoriale` e' il
    // solo posto dell'app che parla alla piattaforma per suonare o vibrare, e
    // due guardie lo pretendono: chiamare `HapticFeedback` da qui vorrebbe
    // dire una seconda verita' su cosa il telefono fa sotto le dita.
    unawaited(PaletteSensoriale.vibra(context, SchemaAptico.tocco));
    // Il respiro si chiude quando il fiore e' tornato chiuso, cioe' dopo un
    // espiro lungo quanto l'inspiro: e' la simmetria senza il ritmo imposto.
    setState(() {});
  }

  void _togglePlay() {
    setState(() {
      _active = !_active;
      if (_active) _compiuta = false;
    });
    if (_active) {
      _cominciata = widget.now ?? DateTime.now();
      widget.player.play(_preset);
      _sessione?.cancel();
      _sessione = Timer(
        const Duration(milliseconds: _cycleMs * cicliDellaSessione),
        _alCompimento,
      );
    } else {
      // Fermarsi a meta' non e' compiere: il gesto si registra solo alla
      // fine della sessione, e chi interrompe riparte da capo.
      _sessione?.cancel();
      widget.player.stop();
    }
  }

  void _alCompimento() {
    if (!mounted) return;
    widget.player.stop();
    setState(() {
      _active = false;
      _compiuta = true;
    });
    // IL CAMMINO SE NE ACCORGE: la meditazione e' compiuta, non aperta.
    //
    // **E IL CENTRO VIAGGIA COL GESTO. Ordine DB voce 06**, 9 settembre 2026.
    // Il gesto partiva senza dettagli, e il diario non poteva sapere QUALE
    // centro era stato respirato: le condizioni `VarietaDelDettaglio` e
    // `CoincidenzaDelDettaglio` esistono gia' e sapevano gia' guardare i
    // dettagli, ma qui non ne arrivava nessuno. **Nessun traguardo si monta
    // qui**, che e' cio' che la voce 06 vieta: si apre soltanto la porta,
    // cosi' i traguardi che il fondatore scrivera' non chiedono codice nuovo.
    unawaited(RegiaDelCammino.dopoUnGesto(context, 'meditazione',
        dettagli: {'centro': ChakraDelGiorno.tutti[_indiceDelCentro].nome}));
    // **E LA GOCCIA RESTA NEL LOTO. Ordine CZ voce 10**, 8 settembre 2026.
    //
    // Il centro non si sceglie: e' quello acceso nel giorno in cui si respira,
    // e viene dalla stessa porta che ha deciso la frequenza. Una sorgente
    // sola per il centro, come per il numero.
    unawaited(_traccia
        .unaGoccia(quando: widget.now ?? DateTime.now())
        .then((_) {
      if (mounted) setState(() {});
    }));
    // **E LA MEMORIA SE NE ACCORGE.** Ordine DB voci 07 e 09, 9 settembre
    // 2026. La sessione si scrive PRIMA che nasca la frase, cosi' la frase
    // guarda una memoria che contiene anche oggi: dire *"e' la prima volta
    // che respiri su questo centro"* si puo' soltanto sapendo che oggi c'e'
    // dentro.
    unawaited(_segnaLaSessione());
  }

  /// Scrive la sessione appena chiusa e ne ricava la frase di Aura.
  Future<void> _segnaLaSessione({bool compiuta = true}) async {
    final adesso = widget.now ?? DateTime.now();
    final inizio = _cominciata ?? adesso;
    await _memoria.segna(SessioneDiRespiro(
      quando: inizio,
      centro: _indiceDelCentro,
      durata: adesso.difference(inizio),
      compiuta: compiuta,
      // **GUIDATO O PROPRIO**, ordine DB voce 07: il respiro col dito e' suo,
      // quello che segue il ritmo dell'app e' guidato, e la differenza entra
      // nella memoria e domani nella card.
      guidato: _dito.quantiRespiri == 0,
      mediaDentro: _dito.mediaDentro,
      mediaFuori: _dito.mediaFuori,
      respiri: _dito.quantiRespiri,
    ));
    if (!mounted) return;
    setState(() {
      _cioCheAuraRicorda = compiuta
          ? CioCheAuraRicorda.unaCosaSola(_memoria,
              centroDiOggi: _indiceDelCentro)
          : null;
    });
  }

  /// **CONDIVIDE LA CARD, DAL PUNTO UNICO.** Ordine DB voce 10.
  Future<void> _condividiIlRespiro() async {
    final righe = CardDelRespiro.righeDiAura(
        _dito.figura, widget.now ?? DateTime.now(), false);
    await condividiLaCardDelRespiro(
      boundaryKey: _boundaryDellaCard,
      testo: righe.join(' '),
    );
  }

  void _choose(MeditationPreset preset) {
    setState(() => _preset = preset);
    if (_active) widget.player.play(preset);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

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
        // **IL TITOLO NON SI ROMPE**, ordine S voce 05: a capo fra le
        // parole, la misura scende solo quanto serve, e non si tronca mai.
        // Col borsellino nella riga delle azioni lo spazio del titolo si e'
        // ristretto, e un `Text` nudo qui torna a mettere i puntini.
        title: TitoloCheNonSiRompe(
            testo: 'Meditazione', stile: TypographyTokens.titoloDiSchermata()),
        // IL BORSELLINO, ordine S voce 06: stesso segno, stesso angolo, in
        // ogni schermata della pratica. Un saldo che appare e scompare non
        // si impara.
        // **LA FONTE ARRIVA A CHI LEGGE.** Ordine CS, voce S2 della
        // scansione: la riga sul 432 dice cosa la Meditazione NON e', e non da dove nasce.
        actions: [
          FoglioDelleFonti.bottone(context,
              palette: palette,
              testo: TestiDelleFonti.meditazione,
              chiave: 'meditazione_fonti'),
          const AngoloDellaBarra(),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Il visualizzatore a cimatica, col respiro sovrapposto.
            Expanded(
              child: Center(
                // **IL DITO GUIDA IL RESPIRO. Ordine CZ voce 08.**
                //
                // Giu' si inspira, alzato si espira, e al cambio di fase il
                // telefono vibra piano: cosi' l'esperienza funziona **a occhi
                // chiusi**, che e' l'unico modo in cui una meditazione ha
                // senso. Nessun sensore richiesto: il gesto tattile e' gia' il
                // gesto, quindi la regola di casa sul ripiego e' soddisfatta
                // per costruzione.
                child: GestureDetector(
                  key: const Key('meditation_dito'),
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (_) => _inspira(),
                  onTapUp: (_) => _espira(),
                  onTapCancel: _espira,
                  child: AspectRatio(
                  aspectRatio: 1,
                  child: AnimatedBuilder(
                    animation: _breath,
                    builder: (context, _) {
                      final b = _breathState();
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // **IL LOTO AL POSTO DEL CERCHIO. Ordine CZ voce
                          // 08**, 8 settembre 2026. Parole del fondatore: *"Il
                          // cerchio che si gonfia esce. E' la forma di ogni
                          // altra app di meditazione e non e' la nostra."*
                          //
                          // I petali si aprono col respiro, portano la traccia
                          // dei giorni, e il petalo di un centro mai respirato
                          // resta spento.
                          Positioned.fill(
                            child: LotoCheRespira(
                              key: const Key('meditation_loto'),
                              apertura: _dito.fase == FaseDelRespiro.attesa
                                  ? b.fill
                                  : _dito.aperturaAdesso(DateTime.now()),
                              // **IL COLORE DEL CENTRO DI OGGI, non quello del
                              // Maestro.** Ordine DB voce 04: siccome il
                              // centro cambia ogni giorno, il fiore di domani
                              // e' di un altro colore, ed e' un motivo per
                              // tornare che non costa niente.
                              coloreDelCentro:
                                  ColoreDelCentro.di(widget.now ?? DateTime.now()),
                              gocce: _traccia.gocce,
                              centroDiOggi: _indiceDelCentro,
                              senzaMoto: _riduciMovimento,
                            ),
                          ),
                          _BreathGuide(
                            fill: b.fill,
                            phase: _active
                                ? b.phase
                                : (_compiuta
                                    ? 'Il respiro è compiuto'
                                    : 'Tocca per iniziare'),
                            palette: palette,
                          ),
                        ],
                      );
                    },
                  ),
                ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  SpacingTokens.lg, 0, SpacingTokens.lg, SpacingTokens.md),
              child: Column(
                children: [
                  // **LA FREQUENZA LA ASSEGNA AURA, E LO DICE. Ordine CZ
                  // voce 06**, 8 settembre 2026.
                  //
                  // Parole del fondatore: *"Un menu' di frequenze davanti a
                  // chi non ha criterio per scegliere e' la forma sbagliata:
                  // Aura non e' un lettore multimediale, e' una guida, e una
                  // guida decide."*
                  //
                  // La riga di Aura nomina il centro e il numero, e dice
                  // perche' e' quello. La scelta libera **resta**, sotto,
                  // dietro un tocco: chi vuole scegliere puo', chi non sa
                  // cosa scegliere non deve.
                  // **IL TESTO NARRATO PASSA DALLA PORTA UNICA**, e non si
                  // tinge del colore del Maestro: due guardie lo pretendono,
                  // e hanno ragione. Il colore del Maestro sta nella scena,
                  // negli accenti e nei bordi; il testo che si legge resta
                  // inchiostro, perche' un testo tinto si legge peggio e
                  // cambia significato col Maestro del giorno.
                  ParagrafiDiLettura(
                    testo:
                        FrequenzaDelGiorno.perche(widget.now ?? DateTime.now()),
                    key: const Key('meditation_perche_la_frequenza'),
                    textAlign: TextAlign.center,
                    stile: TypographyTokens.lettura()
                        .copyWith(color: ColorTokens.textPrimary, height: 1.4),
                  ),
                  const SizedBox(height: SpacingTokens.sm),
                  // **LA SCELTA LIBERA SCENDE SOTTO, e non sparisce.** Una
                  // funzione tolta in silenzio e' la cosa che questo progetto
                  // vieta per legge del fondatore: qui si sposta e si dichiara.
                  TextButton(
                    key: const Key('meditation_scegli_tu'),
                    onPressed: () => setState(() => _sceltaAperta = !_sceltaAperta),
                    child: Text(
                      _sceltaAperta
                          ? 'Lascia scegliere Aura'
                          : 'Preferisco scegliere io',
                      style: TypographyTokens.didascalia()
                          .copyWith(color: palette.goldSoft),
                    ),
                  ),
                  if (_sceltaAperta) ...[
                    const SizedBox(height: SpacingTokens.xs),
                    Row(
                      children: [
                        for (final p in MeditationPreset.values) ...[
                          _PresetChip(
                            preset: p,
                            selected: p == _preset,
                            palette: palette,
                            onTap: () => _choose(p),
                          ),
                          if (p != MeditationPreset.values.last)
                            const SizedBox(width: SpacingTokens.sm),
                        ],
                      ],
                    ),
                  ],
                  const SizedBox(height: SpacingTokens.md),
                  // **IL COMPIMENTO SI DICE, ordine BF voce 05.b**: senza
                  // questa riga la sessione finirebbe in silenzio e la
                  // persona non saprebbe di essere arrivata.
                  if (_compiuta) ...[
                    Row(
                      key: const Key('meditazione_compiuta'),
                      children: [
                        Icon(Icons.spa_outlined,
                            size: 16, color: palette.goldSoft),
                        const SizedBox(width: SpacingTokens.xs),
                        Expanded(
                          child: ParagrafiDiLettura(
                            testo: 'La meditazione è portata a compimento: '
                                'porta questa calma con te.',
                            stile: TypographyTokens.lettura()
                                .copyWith(color: palette.goldSoft),
                          ),
                        ),
                      ],
                    ),
                    // **CIO' CHE AURA RICORDA, e nasce solo se e' vero.**
                    // Ordine DB voce 09, 9 settembre 2026: *"e' il momento in
                    // cui l'app dimostra di essersi accorta... una frase, mai
                    // due. E solo quando c'e' qualcosa di vero da dire: se la
                    // memoria non ha niente, non si inventa niente e la
                    // sessione si chiude com'e'."*
                    //
                    // **Una osservazione falsa distrugge in una riga la
                    // fiducia che dieci vere hanno costruito**, ed e' per
                    // questo che ogni frase ha una soglia sotto la quale non
                    // nasce: due sere di fila non sono una striscia, e sei
                    // sessioni sono il minimo per dire che si allungano.
                    if (_cioCheAuraRicorda != null) ...[
                      const SizedBox(height: SpacingTokens.sm),
                      Row(
                        key: const Key('meditazione_aura_ricorda'),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.auto_awesome_rounded,
                              size: 16, color: palette.gold),
                          const SizedBox(width: SpacingTokens.xs),
                          Expanded(
                            child: ParagrafiDiLettura(
                              testo: _cioCheAuraRicorda!,
                              stile: TypographyTokens.lettura()
                                  .copyWith(color: palette.gold),
                            ),
                          ),
                        ],
                      ),
                    ],
                    // **LA CARD DEL RESPIRO.** Ordine DB voce 10, e chiude
                    // la voce CZ.09 rimasta ferma: la figura era calcolata e
                    // provata, il disegno non esisteva.
                    //
                    // **Compare solo se ci sono respiri veri da disegnare**:
                    // una figura di zero respiri e' un cerchio vuoto, e
                    // mostrarlo sarebbe peggio che non mostrare niente.
                    if (_dito.quantiRespiri >= 3) ...[
                      const SizedBox(height: SpacingTokens.md),
                      Center(
                        child: RepaintBoundary(
                          key: _boundaryDellaCard,
                          child: CardDelRespiro(
                            figura: _dito.figura,
                            giorno: widget.now ?? DateTime.now(),
                            guidato: false,
                          ),
                        ),
                      ),
                      const SizedBox(height: SpacingTokens.sm),
                      OutlinedButton.icon(
                        key: const Key('meditazione_condividi_respiro'),
                        onPressed: _condividiIlRespiro,
                        style: OutlinedButton.styleFrom(
                            foregroundColor: palette.goldSoft,
                            side: BorderSide(
                                color: palette.gold.withValues(alpha: 0.6)),
                            minimumSize: const Size.fromHeight(48)),
                        icon: const Icon(Icons.ios_share_rounded, size: 18),
                        label: Text('Condividi il tuo respiro',
                            style: TypographyTokens.etichetta()),
                      ),
                    ],
                    const SizedBox(height: SpacingTokens.md),
                  ],
                  // Play e invito alle cuffie.
                  Row(
                    children: [
                      _PlayButton(
                        active: _active,
                        palette: palette,
                        onTap: _togglePlay,
                      ),
                      const SizedBox(width: SpacingTokens.md),
                      Expanded(
                        child: Text(
                          _preset.binaural
                              ? 'Metti le cuffie: il battito nasce fra i due orecchi.'
                              : 'Con le cuffie l\'ascolto si fa più pieno.',
                          style: TypographyTokens.corpo()
                              .copyWith(color: ColorTokens.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  // **LA LIBRERIA STA SOTTO, E NON DAVANTI.** Ordine DB
                  // voci 01, 02 e 05, 9 settembre 2026. La porta principale
                  // resta quella dell'ordine CZ voce 06: Aura sceglie. Questo
                  // pannello e' chiuso finche' non lo si apre, ed e' per chi
                  // vuole cercare, comporre il proprio rito e leggere le
                  // fonti di ogni pratica.
                  PannelloDellaLibreria(
                    palette: palette,
                    centroDiOggi: _indiceDelCentro,
                    sequenze: _sequenze,
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  // Fondamento onesto, senza ripetere il disclaimer.
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.eco_outlined,
                          size: 14, color: palette.goldSoft),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Cornice di benessere, non cura. Le frequenze Solfeggio '
                          'e il 432 sono tradizione culturale, non un fatto medico.',
                          style: TypographyTokens.corpo().copyWith(
                            color: palette.goldSoft.withValues(alpha: 0.7),
                            letterSpacing: 0.3,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// La guida al respiro: un cerchio che si allarga inspirando e si restringe
/// espirando, con l'etichetta della fase al centro.
class _BreathGuide extends StatelessWidget {
  const _BreathGuide({
    required this.fill,
    required this.phase,
    required this.palette,
  });

  final double fill;
  final String phase;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = math.min(constraints.maxWidth, constraints.maxHeight);
        final d = side * (0.28 + 0.16 * fill);
        return Container(
          width: d,
          height: d,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [
              palette.primary.withValues(alpha: 0.35),
              palette.deepest.withValues(alpha: 0.05),
            ]),
            border: Border.all(
                color: palette.gold.withValues(alpha: 0.5), width: 1.2),
          ),
          child: Text(
            phase,
            textAlign: TextAlign.center,
            style: TypographyTokens.label(size: 12).copyWith(
              color: palette.goldSoft,
              letterSpacing: 1.4,
            ),
          ),
        );
      },
    );
  }
}

/// Un preset sonoro selezionabile.
class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.preset,
    required this.selected,
    required this.palette,
    required this.onTap,
  });

  final MeditationPreset preset;
  final bool selected;
  final MaestroPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        key: Key('meditation_preset_${preset.id}'),
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
            gradient: selected
                ? LinearGradient(colors: [
                    palette.primary.withValues(alpha: 0.6),
                    palette.surfaceElevated.withValues(alpha: 0.6),
                  ])
                : null,
            border: Border.all(
              color: selected
                  ? palette.gold.withValues(alpha: 0.7)
                  : palette.gold.withValues(alpha: 0.22),
            ),
          ),
          child: Column(
            children: [
              Text(
                preset.label,
                textAlign: TextAlign.center,
                style: TypographyTokens.titoloDiRiga().copyWith(
                  color:
                      selected ? palette.goldSoft : ColorTokens.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              // Nessun troncamento: il sottotitolo va a capo per intero.
              Text(
                preset.subtitle,
                textAlign: TextAlign.center,
                style: TypographyTokens.etichetta().copyWith(
                  color: selected
                      ? palette.goldSoft.withValues(alpha: 0.8)
                      : ColorTokens.textSecondary.withValues(alpha: 0.8),
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Il bottone che avvia o ferma il suono e il visualizzatore.
class _PlayButton extends StatelessWidget {
  const _PlayButton({
    required this.active,
    required this.palette,
    required this.onTap,
  });

  final bool active;
  final MaestroPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const Key('meditation_play'),
      onTap: onTap,
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [
            palette.primary.withValues(alpha: 0.7),
            palette.surfaceElevated.withValues(alpha: 0.6),
          ]),
          border: Border.all(color: palette.gold.withValues(alpha: 0.7)),
          boxShadow: [
            BoxShadow(
              color: palette.glow.withValues(alpha: active ? 0.5 : 0.2),
              blurRadius: 18,
              spreadRadius: -2,
            ),
          ],
        ),
        child: Icon(
          active ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: palette.goldSoft,
          size: 30,
        ),
      ),
    );
  }
}

/// **IL CERCHIO CHE SI GONFIA E' USCITO. Ordine CZ voce 08**, 8 settembre
/// 2026. Parole del fondatore: *"E' la forma di ogni altra app di meditazione
/// e non e' la nostra."* Al suo posto c'e' `LotoCheRespira`, e il pittore a
/// cimatica e' stato tolto invece di essere lasciato spento: un componente che
/// nessuno monta e' un componente che qualcuno rimonta.
