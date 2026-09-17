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
import '../tarot/tarot_card_art.dart';
import 'tavolo_dei_ventidue.dart';

/// **L'ARCANO DELL'ALBA, il dono del mattino di Medora.** Ordine DT voci 01,
/// 02, 03 e 04; **rifatto in scena dall'ordine DU**, 17 settembre 2026.
///
/// **IL FATTO CHE HA FATTO NASCERE L'ORDINE DU**, nelle parole del fondatore
/// davanti alla 2267: *"un compitino, superficialita'"*. Tre carte coperte su
/// un fondo nero, nessuna animazione, Medora assente. Aveva ragione.
///
/// **ADESSO E' UNA SCENA SUA.** La prima stesura riusava il ventaglio della
/// Stesa e metteva Medora in cima: **il fondatore ha bocciato tutti e due**,
/// *"e' identico alla Stesa"*, e ha chiesto di togliere anche l'avatar.
/// Adesso c'e' il fondo stellato (`CosmosBackground`) e **il tavolo dei
/// ventidue** (`TavoloDeiVentidue`): i dorsi entrano a spirale, si posano su
/// righe leggermente sovrapposte e continuano a respirare; la carta scelta
/// sale al centro con una scia di stelline e si gira.
///
/// **I due gesti del mazzo**, mischia e taglia, muovono le figure sul tavolo
/// e non l'esito: la carta si estrae dal caso sicuro nel momento del tocco.
/// Nessun disclaimer (voce DU.10), **nessuna voce e nessun Protoface** (voce
/// DU.06).
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

  /// Quale dorso e' stato toccato, quando la scelta e' avvenuta adesso: il
  /// tavolo lo fa salire al centro. Resta nullo su una carta ritrovata.
  int? _toccata;

  /// **LA RIVELAZIONE**: la carta scelta che sale, cresce e si gira, con la
  /// scia di stelline dietro. L'ingresso e il respiro del tavolo li governa
  /// il tavolo, che e' l'unico a sapere dove stanno le carte.
  late final AnimationController _rivelazione;

  /// Vero quando la carta e' stata scelta in questa sessione: in quel caso la
  /// carta grande la disegna il tavolo, alla fine del volo.
  bool get _inRivelazione => _toccata != null;

  DateTime get _adesso => widget.now ?? DateTime.now();

  static final MaestroPalette _palette =
      MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));

  @override
  void initState() {
    super.initState();
    _rivelazione = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));
    unawaited(_riprendi());
  }

  @override
  void dispose() {
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
      if (gia != null) _rivelazione.value = 1;
    });
  }

  Future<void> _scegli(int quale) async {
    if (_responso != null || _caricando || _toccata != null) return;
    final responso =
        await ArchivioDellAlba.estraiOggi(_adesso, caso: widget.caso);
    if (!mounted) return;
    setState(() {
      _responso = responso;
      _toccata = quale;
    });
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
                        // **LA SCENA NON SALTA MENTRE LA CARTA VOLA**: la
                        // colonna resta distribuita finche' il volo finisce,
                        // e solo dopo il responso scorre dall'alto.
                        mainAxisAlignment: scegliendo || _inRivelazione
                            ? MainAxisAlignment.spaceEvenly
                            : MainAxisAlignment.start,
                        children: [
                          // **L'INVITO LASCIA IL POSTO, NON LA LISTA.**
                          // Togliendolo, il tavolo cambiava indice fra i
                          // figli e Flutter lo ricostruiva da capo: le carte
                          // rientravano in scena a meta' del volo. Visto
                          // sull'anteprima, non dedotto.
                          if (scegliendo || _inRivelazione)
                            // L'invito si spegne mentre la carta sale, senza
                            // sparire di colpo.
                            Opacity(
                              opacity: (1 - _rivelazione.value * 2.4)
                                  .clamp(0.0, 1.0),
                              child: ParagrafiDiLettura(
                                key: const Key('arcano_alba_invito'),
                                testo: DailyElement.dawn.cosaFai,
                                textAlign: TextAlign.center,
                                stile: TypographyTokens.lettura(),
                              ),
                            )
                          else
                            const SizedBox.shrink(),
                          // **IL TAVOLO DEI VENTIDUE**, voci DU.02, DU.04 e
                          // DU.05: i ventidue dorsi entrano a spirale, si
                          // posano su righe sovrapposte e respirano; la carta
                          // scelta sale al centro con la sua scia di stelline.
                          // Resta in scena anche durante la rivelazione,
                          // perche' e' lui a farla.
                          if (scegliendo || _inRivelazione)
                            TavoloDeiVentidue(
                              key: const ValueKey('tavolo_dei_ventidue'),
                              palette: _palette,
                              onScegli: _scegli,
                              rivelazione: _rivelazione,
                              scelta: _toccata,
                              ridotto: _ridotto,
                              quante: ArcanoDellAlbaScreen.dorsi,
                              faccia: (context) => _Faccia(
                                  responso: _responso!, palette: _palette),
                            ),
                          if (responso != null && !_inRivelazione) ...[
                            const SizedBox(height: SpacingTokens.sm),
                            _CartaGrande(responso: responso, palette: _palette),
                          ],
                          if (responso != null) ...[
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

/// La carta grande, ferma: e' quella che si rivede riaprendo il dono, quando
/// il volo e il giro sono gia' avvenuti in un altro momento.
class _CartaGrande extends StatelessWidget {
  const _CartaGrande({required this.responso, required this.palette});

  final ResponsoDellAlba responso;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) => Center(
        child: SizedBox(
          width: 236,
          child: AspectRatio(
            aspectRatio: TarotFrame.aspect,
            child: _Faccia(responso: responso, palette: palette),
          ),
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
