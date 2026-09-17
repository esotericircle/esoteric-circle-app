import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/astro/sky_location.dart';
import '../../core/astro/solar_time.dart';
import '../../core/maestro/maestro.dart';
import '../../core/rituals/arcano_dell_alba/archivio_dell_alba.dart';
import '../../core/rituals/arcano_dell_alba/responso_dell_alba.dart';
import '../../core/rituals/arcano_dell_alba/stato_dell_alba.dart';
import '../../core/rituals/avvisi_del_rito.dart';
import '../../core/rituals/rito_alba.dart';
import '../../core/rituals/daily_elements.dart';
import '../../core/rituals/ritual_streak.dart';
import '../../core/rituals/scelta_degli_avvisi.dart';
import '../../core/sigilli/ora_rituale.dart';
import '../../core/tarot/tarot_card.dart';
import '../../core/tarot/tarot_spread.dart';
import '../../design_system/components/cosmos_background.dart';
import '../../design_system/components/riga_del_dono.dart';
import '../../design_system/components/titolo_che_non_si_rompe.dart';
import '../../design_system/theme/abito_del_responso.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../design_system/transizioni/passaggio_del_cerchio.dart';
import '../../design_system/typography/paragrafi_di_lettura.dart';
import '../../services/avvisi_locali.dart';
import '../sigilli/regia_del_cammino.dart';
import '../tarot/medora_stage.dart';
import '../tarot/stesa_choreography.dart';
import '../tarot/stesa_fan.dart';
import '../tarot/tarot_card_art.dart';

/// **L'ARCANO DELL'ALBA, il dono del mattino di Medora.** Ordine DT voci 01,
/// 02, 03 e 04; **rifatto in scena dall'ordine DU**, 17 settembre 2026.
///
/// **IL FATTO CHE HA FATTO NASCERE L'ORDINE DU**, nelle parole del fondatore
/// davanti alla 2267: *"un compitino, superficialita'"*. Tre carte coperte su
/// un fondo nero, nessuna animazione, Medora assente. Aveva ragione.
///
/// **ADESSO E' UNA SCENA, e la scena non e' nuova**: e' quella della Stesa dei
/// Tarocchi, che gia' gira e che gia' e' provata. Il fondo stellato
/// (`CosmosBackground`), Medora che presiede (`MedoraStage`), le carte che
/// nascono dal fondo, le girano intorno e scendono a ventaglio
/// (`StesaScene.ingresso` e `StesaFan`). Cambia una cosa sola: **i dorsi sono
/// ventidue**, gli arcani maggiori, invece dei settantotto del mazzo intero.
/// Scrivere un secondo ventaglio sarebbe stata la seconda porta che questo
/// progetto paga piu' cara di ogni altra cosa.
///
/// **UN GESTO SOLO.** Si sfoglia l'arco, si sceglie un dorso, la carta sale e
/// si gira. Nessun altro comando, nessuna opzione, nessun disclaimer (voce
/// DU.10), **nessuna voce e nessun Protoface** (voce DU.06): Medora e' in
/// scena e tace.
///
/// **IL VERSO LO DECIDE IL SISTEMA, e il dorso toccato non conta** (voce
/// DU.07). I ventidue dorsi sono lo stesso disegno; lo stato si estrae dal
/// caso sicuro nel momento del tocco, e il dorso del mazzo e' simmetrico al
/// mezzo giro: una carta coperta non puo' dire niente.
///
/// **Solo i ventidue arcani maggiori, e il limite delle stese non si tocca**
/// (voce DU.13): questo dono non passa da `QuestionAllowance`.
///
/// **Nel cammino valgono tutti e due i gesti**, `alba` e `oracolo`: decisione
/// di Mauro del 17 settembre 2026, cosi' nessuno dei traguardi che li
/// nominano cambia.
class ArcanoDellAlbaScreen extends StatefulWidget {
  const ArcanoDellAlbaScreen({
    super.key,
    this.now,
    this.location = const DisabledSkyLocation(),
    this.avvisi = const AvvisiSpenti(),
    this.caso,
  });

  final DateTime? now;
  final SkyLocation location;
  final ServizioAvvisi avvisi;

  /// Solo per le prove: il caso dell'estrazione. Nell'app e' quello sicuro.
  final math.Random? caso;

  /// **Quanti dorsi si offrono alla mano: tutti e ventidue.** Ordine DU voce
  /// 02. Non e' il numero dei doni ne' quello del mazzo intero: sono gli
  /// arcani maggiori, e l'arco li sfoglia tutti.
  static int get dorsi => StatoDellAlba.carte;

  static Route<void> route(
          {DateTime? now, SkyLocation? location, ServizioAvvisi? avvisi}) =>
      PassaggioDelCerchio.rotta<void>((_) => MaestroScope(
            child: ArcanoDellAlbaScreen(
              now: now,
              location: location ?? const GeolocatorSkyLocation(),
              avvisi: avvisi ?? avvisiDelCerchio,
            ),
          ));

  @override
  State<ArcanoDellAlbaScreen> createState() => _ArcanoDellAlbaScreenState();
}

class _ArcanoDellAlbaScreenState extends State<ArcanoDellAlbaScreen>
    with TickerProviderStateMixin {
  /// Il responso di oggi, quando la carta e' stata scelta.
  ResponsoDellAlba? _responso;

  /// Vero finche' non si sa se oggi la carta e' gia' stata scelta.
  bool _caricando = true;

  /// La scena della Stesa, riusata: ingresso, riposo, completa.
  StesaScene _scena = StesaScene.ingresso;

  /// **I tre tempi della scena.** L'ingresso e' il volo che gira attorno a
  /// Medora; il respiro e' il battito del ventaglio fermo; la rivelazione e'
  /// la carta scelta che sale e si gira.
  late final AnimationController _ingresso;
  late final AnimationController _respiro;
  late final AnimationController _rivelazione;

  DateTime get _adesso => widget.now ?? DateTime.now();

  static final MaestroPalette _palette =
      MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));

  @override
  void initState() {
    super.initState();
    _ingresso = AnimationController(
        vsync: this, duration: StesaTiming.ingresso); // 2,2 secondi
    _respiro = AnimationController(vsync: this, duration: StesaTiming.respiro);
    _rivelazione =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    unawaited(_riprendi());
  }

  @override
  void dispose() {
    _ingresso.dispose();
    _respiro.dispose();
    _rivelazione.dispose();
    super.dispose();
  }

  bool get _ridotto => MediaQuery.maybeOf(context)?.disableAnimations ?? false;

  /// Se oggi la carta e' gia' stata scelta, si torna al responso: **la scena
  /// si rivede domani**, decisione di Mauro del 17 settembre 2026. Chi riapre
  /// vuole rileggere il suo dono, non ripetere il gesto.
  Future<void> _riprendi() async {
    final gia = await ArchivioDellAlba.diOggi(_adesso);
    if (!mounted) return;
    setState(() {
      _responso = gia;
      _caricando = false;
      if (gia != null) {
        _scena = StesaScene.completa;
        _rivelazione.value = 1;
        _ingresso.value = 1;
      }
    });
    if (gia != null) return;
    await _entrataInScena();
  }

  /// Le carte entrano, poi il ventaglio respira e aspetta la mano.
  Future<void> _entrataInScena() async {
    if (!mounted) return;
    if (_ridotto) {
      // **Riduci Movimento toglie il moto, non il contenuto**: il ventaglio
      // c'e' gia' tutto, fermo, e si puo' sfogliare subito.
      _ingresso.value = 1;
      setState(() => _scena = StesaScene.riposo);
      return;
    }
    await _ingresso.forward(from: 0);
    if (!mounted) return;
    setState(() => _scena = StesaScene.riposo);
    _respiro.repeat();
  }

  /// **Chi tocca mentre le carte entrano non aspetta**: l'ingresso si chiude
  /// subito e il ventaglio e' pronto. Nessuno deve guardare un'animazione che
  /// non ha chiesto.
  void _saltaLIngresso() {
    if (_scena != StesaScene.ingresso) return;
    _ingresso.value = 1;
    setState(() => _scena = StesaScene.riposo);
    if (!_ridotto) _respiro.repeat();
  }

  Future<void> _scegli(int quale) async {
    if (_responso != null || _caricando || _scena == StesaScene.completa) {
      return;
    }
    setState(() => _scena = StesaScene.completa);
    _respiro.stop();
    final responso =
        await ArchivioDellAlba.estraiOggi(_adesso, caso: widget.caso);
    if (!mounted) return;
    setState(() => _responso = responso);
    if (_ridotto) {
      _rivelazione.value = 1;
    } else {
      await _rivelazione.forward(from: 0);
    }
    if (!mounted) return;
    setState(() {});
    unawaited(_segnaIlDono(responso));
  }

  /// Il dono ricevuto entra nel cammino, nella serie e negli avvisi.
  Future<void> _segnaIlDono(ResponsoDellAlba responso) async {
    final adesso = _adesso;
    await const RitualStreak(id: 'dawn').recordToday(adesso);
    if (!mounted) return;
    final luogo = await widget.location.resolveSeConcesso();
    if (!mounted) return;
    final posizione = PosizioneDiStamattina.da(luogo, adesso.timeZoneOffset);
    final sorgere = SunsetTime.albaPerData(adesso,
        lat: posizione.lat, lon: posizione.lon, offset: adesso.timeZoneOffset);
    final primaDelSole = sorgere != null && adesso.isBefore(sorgere);
    // **TUTTI E DUE I GESTI.** L'alba porta ancora il sorgere vero, per il
    // traguardo "prima che il sole sorga davvero"; l'oracolo porta l'arcano
    // uscito, per i traguardi che contano le carte nella settimana. Uno dopo
    // l'altro e non insieme: scrivono tutti e due nello stesso diario.
    await RegiaDelCammino.dopoUnGesto(context, 'alba',
        oraRituale: OraRituale.diAdesso(adesso: adesso),
        dettagli: primaDelSole
            ? const {
                'prima_del_sole': ['si']
              }
            : const <String, Object?>{});
    if (!mounted) return;
    await RegiaDelCammino.dopoUnGesto(context, 'oracolo',
        oraRituale: OraRituale.diAdesso(adesso: adesso),
        dettagli: {
          'arcano': [responso.carta.stem]
        });
    final scelta = SceltaDegliAvvisi();
    await scelta.carica();
    await AvvisiDelRito.programmaProssimo(
      servizio: widget.avvisi,
      adesso: adesso,
      posizione: posizione,
      minutiScelti: scelta.minutiDi(DailyElement.dawn),
    );
  }

  /// La carta di oggi come la guarda Medora: serve alla scena, non al testo.
  DrawnCard? get _cartaDiMedora {
    final r = _responso;
    if (r == null) return null;
    return DrawnCard(
      card: r.carta,
      position: SpreadPosition.presente,
      reversed: r.stato.rovescio,
    );
  }

  @override
  Widget build(BuildContext context) {
    final responso = _responso;
    final scegliendo = responso == null && !_caricando;
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: _palette.goldSoft),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Indietro',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: TitoloCheNonSiRompe(
            chiaveDelTesto: const Key('arcano_alba_titolo'),
            testo: DailyElement.dawn.title,
            stile: TypographyTokens.titoloDiSchermata()),
      ),
      // **IL FONDO NON E' PIU' NERO**, voce DU.01: il cielo del Cerchio, lo
      // stesso della Stesa, con i pianeti e senza lo zodiaco.
      body: CosmosBackground(
        paletteOverride: _palette,
        child: SafeArea(
          child: _caricando
              ? const SizedBox.shrink()
              // **LA SCENA RIEMPIE LO SCHERMO.** Con la sola colonna, mentre
              // si sceglie restava un terzo di vuoto sotto il ventaglio: qui
              // la colonna e' alta almeno quanto la finestra e distribuisce
              // Medora, l'invito e l'arco. A responso aperto torna a scorrere
              // dall'alto, perche' li' il contenuto e' piu' lungo della
              // finestra.
              : LayoutBuilder(
                  builder: (context, spazio) => SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(SpacingTokens.lg,
                        SpacingTokens.sm, SpacingTokens.lg, SpacingTokens.xl),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                          minHeight: spazio.maxHeight -
                              SpacingTokens.sm -
                              SpacingTokens.xl),
                      child: Column(
                        key: const Key('arcano_alba_scena'),
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: scegliendo
                            ? MainAxisAlignment.spaceEvenly
                            : MainAxisAlignment.start,
                        children: [
                          // **MEDORA E' IN SCENA**, voce DU.04, e tace.
                          MedoraStage(
                            palette: _palette,
                            active: _cartaDiMedora,
                            height: scegliendo ? 250 : 170,
                            breathe: !_ridotto,
                            bustoFactor: 0.72,
                            bustoLarghezza: 0.86,
                          ),
                          if (scegliendo) ...[
                            ParagrafiDiLettura(
                              key: const Key('arcano_alba_invito'),
                              testo: DailyElement.dawn.cosaFai,
                              textAlign: TextAlign.center,
                              stile: TypographyTokens.lettura(),
                            ),
                            const SizedBox(height: SpacingTokens.md),
                            // **IL VENTAGLIO DEI VENTIDUE**, voci DU.02 e DU.05:
                            // lo stesso arco della Stesa, con ventidue dorsi.
                            GestureDetector(
                              behavior: HitTestBehavior.deferToChild,
                              onTapDown: (_) => _saltaLIngresso(),
                              child: AnimatedBuilder(
                                animation:
                                    Listenable.merge([_ingresso, _respiro]),
                                builder: (context, _) => StesaFan(
                                  palette: _palette,
                                  taken: const {},
                                  onPick: _scegli,
                                  scene: _scena,
                                  ingresso: _ingresso.value,
                                  respiro: _respiro.value,
                                  taglio: 0,
                                  mescolamento: 0,
                                  taglioIndice: 0,
                                  reduceMotion: _ridotto,
                                  carte: ArcanoDellAlbaScreen.dorsi,
                                ),
                              ),
                            ),
                          ],
                          if (responso != null) ...[
                            const SizedBox(height: SpacingTokens.sm),
                            _CartaCheSale(
                              responso: responso,
                              palette: _palette,
                              rivelazione: _rivelazione,
                            ),
                            AnimatedBuilder(
                              animation: _rivelazione,
                              builder: (context, figlio) => Opacity(
                                opacity: ((_rivelazione.value - 0.75) / 0.25)
                                    .clamp(0, 1),
                                child: figlio,
                              ),
                              child: _TreMovimenti(
                                  responso: responso,
                                  giorno: _adesso,
                                  palette: _palette),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

/// **LA CARTA SCELTA SALE E SI GIRA.**
///
/// Sale dal ventaglio verso il centro della scena crescendo, e a mezza strada
/// comincia a girare: la faccia compare **solo dopo il mezzo giro**, perche'
/// il verso non si puo' sapere prima (voce DU.07).
class _CartaCheSale extends StatelessWidget {
  const _CartaCheSale({
    required this.responso,
    required this.palette,
    required this.rivelazione,
  });

  final ResponsoDellAlba responso;
  final MaestroPalette palette;
  final AnimationController rivelazione;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: rivelazione,
      builder: (context, _) {
        final t = rivelazione.value;
        // La salita: parte piccola e in basso, come stava nell'arco, e
        // arriva piena al centro.
        final salita = Curves.easeOutCubic.transform((t / 0.45).clamp(0, 1));
        final giro = Curves.easeInOut.transform(((t - 0.35) / 0.5).clamp(0, 1));
        final scala = 0.62 + 0.38 * salita;
        final su = 70 * (1 - salita);
        final angolo = giro * math.pi;
        final mostraLaFaccia = giro >= 0.5;
        return Transform.translate(
          offset: Offset(0, su),
          child: Transform.scale(
            scale: scala,
            child: Center(
              child: SizedBox(
                width: 236,
                child: AspectRatio(
                  aspectRatio: TarotFrame.aspect,
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.0012)
                      ..rotateY(angolo),
                    child: mostraLaFaccia
                        ? Transform(
                            alignment: Alignment.center,
                            // La faccia si rimette dritta: senza, dopo il
                            // mezzo giro si vedrebbe specchiata.
                            transform: Matrix4.identity()..rotateY(math.pi),
                            child:
                                _Faccia(responso: responso, palette: palette),
                          )
                        : const _Dorso(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Il dorso del mazzo, uguale per tutte: **simmetrico al mezzo giro**, cosi'
/// una carta coperta non dice il verso (voce DU.07).
class _Dorso extends StatelessWidget {
  const _Dorso();

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          TarotDeck.dorsoFull,
          key: const Key('arcano_alba_dorso'),
          fit: BoxFit.cover,
        ),
      );
}

/// La faccia della carta, **coi suoi cartigli pieni** (voce DU.03): il
/// numerale in alto e il nome in basso, come su ogni carta del mazzo.
class _Faccia extends StatelessWidget {
  const _Faccia({required this.responso, required this.palette});

  final ResponsoDellAlba responso;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) => TarotCardArt(
        key: const Key('arcano_alba_faccia'),
        card: responso.carta,
        palette: palette,
        reversed: responso.stato.rovescio,
      );
}

class _TreMovimenti extends StatelessWidget {
  const _TreMovimenti(
      {required this.responso, required this.giorno, required this.palette});

  final ResponsoDellAlba responso;
  final DateTime giorno;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    final parola = responso.parola;
    return Padding(
      padding: const EdgeInsets.only(top: SpacingTokens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RigaDelDono(
            dono: DailyElement.dawn,
            giorno: giorno,
            superficie:
                AbitoDelResponso.di(DailyElement.dawn).superficiePeggiore,
          ),
          // Il primo movimento: la carta, il verso, l'attribuzione.
          Text(
            responso.primo,
            key: const Key('arcano_alba_carta'),
            style: TypographyTokens.cerimoniale()
                .copyWith(color: palette.goldSoft, height: 1.25),
          ),
          const SizedBox(height: SpacingTokens.md),
          // Il secondo: il dono. La parola, quando c'e', prima del testo che
          // la porta: e' il colpo d'occhio.
          if (parola != null) ...[
            Text(
              parola.toUpperCase(),
              key: const Key('arcano_alba_parola'),
              style: TypographyTokens.cerimonialeGrande()
                  .copyWith(color: palette.goldSoft, letterSpacing: 1.5),
            ),
            const SizedBox(height: SpacingTokens.xs),
          ],
          ParagrafiDiLettura(
            key: const Key('arcano_alba_dono'),
            testo: responso.secondo,
            stile: TypographyTokens.lettura()
                .copyWith(color: ColorTokens.textPrimary),
          ),
          const SizedBox(height: SpacingTokens.md),
          // Il terzo: Medora chiude, e solo qui c'e' il filo con ieri.
          ParagrafiDiLettura(
            key: const Key('arcano_alba_medora'),
            testo: responso.terzo,
            stile: TypographyTokens.lettura().copyWith(
                color: ColorTokens.textPrimary.withValues(alpha: 0.86),
                fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}
