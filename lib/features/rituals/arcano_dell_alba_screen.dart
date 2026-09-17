import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/astro/sky_location.dart';
import '../../core/astro/solar_time.dart';
import '../../core/maestro/maestro.dart';
import '../../core/rituals/arcano_dell_alba/archivio_dell_alba.dart';
import '../../core/rituals/arcano_dell_alba/responso_dell_alba.dart';
import '../../core/rituals/avvisi_del_rito.dart';
import '../../core/rituals/rito_alba.dart';
import '../../core/rituals/daily_elements.dart';
import '../../core/rituals/ritual_streak.dart';
import '../../core/rituals/scelta_degli_avvisi.dart';
import '../../core/sigilli/ora_rituale.dart';
import '../../core/tarot/tarot_card.dart';
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

/// **L'ARCANO DELL'ALBA, il dono del mattino di Medora.** Ordine DT voci 01,
/// 02, 03 e 04, 17 settembre 2026.
///
/// **Prende il posto di due doni**, il Rito dell'Alba e l'Arcano del Giorno,
/// e ne tiene l'ora del primo, le sette.
///
/// **UN GESTO SOLO.** Carte coperte, tutte uguali: se ne sceglie una e si
/// gira. Nessun altro comando, nessuna opzione, nessun pulsante verso il cielo,
/// i transiti o le altre arti. Il cuore delle preferite non c'e' per la stessa
/// ragione: e' un comando.
///
/// **IL VERSO LO DECIDE IL SISTEMA, e la carta scelta non conta.** Le carte
/// coperte sono lo stesso dorso, disegnato uguale, nello stesso ordine e con
/// la stessa animazione; lo stato si estrae dal sacchetto nel momento del
/// tocco, dal caso sicuro del sistema, e quale carta si e' toccata non entra
/// nel conto. Il verso compare solo quando la faccia si vede, e il dorso del
/// mazzo e' simmetrico al mezzo giro: una carta coperta non puo' dire niente.
///
/// **Solo i ventidue arcani maggiori, e il limite delle stese non si tocca**:
/// questo dono non passa da `QuestionAllowance`.
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

  /// Quante carte coperte si mostrano. Non e' il numero dei doni ne' quello
  /// del mazzo: e' quante se ne offrono alla mano, e nessun altro conto
  /// dipende da lui.
  static const int carteCoperte = 3;

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
    with SingleTickerProviderStateMixin {
  /// Il responso di oggi, quando la carta e' stata scelta.
  ResponsoDellAlba? _responso;

  /// Quale carta coperta si e' toccata, per sapere quale girare.
  int? _toccata;

  /// Vero finche' non si sa se oggi la carta e' gia' stata scelta.
  bool _caricando = true;

  /// Il giro della carta. **Nasce in initState e non alla prima lettura**: se
  /// la schermata si chiude prima di aver letto l'archivio, una creazione
  /// pigra lo farebbe nascere dentro dispose, a albero gia' smontato.
  late final AnimationController _giro;

  DateTime get _adesso => widget.now ?? DateTime.now();

  static final MaestroPalette _palette =
      MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));

  @override
  void initState() {
    super.initState();
    _giro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    unawaited(_riprendi());
  }

  @override
  void dispose() {
    _giro.dispose();
    super.dispose();
  }

  /// Se oggi la carta e' gia' stata scelta, la si ritrova girata: non si
  /// sceglie due volte.
  Future<void> _riprendi() async {
    final gia = await ArchivioDellAlba.diOggi(_adesso);
    if (!mounted) return;
    setState(() {
      _responso = gia;
      _caricando = false;
      if (gia != null) _giro.value = 1;
    });
  }

  Future<void> _scegli(int quale) async {
    if (_toccata != null || _responso != null || _caricando) return;
    setState(() => _toccata = quale);
    final responso =
        await ArchivioDellAlba.estraiOggi(_adesso, caso: widget.caso);
    if (!mounted) return;
    setState(() => _responso = responso);
    final ridotto = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (ridotto) {
      _giro.value = 1;
    } else {
      await _giro.forward(from: 0);
    }
    if (!mounted) return;
    // La carta e' girata: l'invito se ne va e restano la carta e i movimenti.
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
    return Scaffold(
      backgroundColor: ColorTokens.neutralDeepest,
      appBar: AppBar(
        backgroundColor: _palette.deepest.withValues(alpha: 0.4),
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
      body: SafeArea(
        top: false,
        child: _caricando
            ? const SizedBox.shrink()
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(SpacingTokens.lg,
                    SpacingTokens.md, SpacingTokens.lg, SpacingTokens.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (responso == null || _giro.value < 1) ...[
                      ParagrafiDiLettura(
                        key: const Key('arcano_alba_invito'),
                        testo: DailyElement.dawn.cosaFai,
                        textAlign: TextAlign.center,
                        stile: TypographyTokens.lettura()
                            .copyWith(color: ColorTokens.textPrimary),
                      ),
                      const SizedBox(height: SpacingTokens.lg),
                    ],
                    _Carte(
                      giro: _giro,
                      toccata: _toccata,
                      responso: responso,
                      palette: _palette,
                      onScegli: _scegli,
                    ),
                    if (responso != null)
                      AnimatedBuilder(
                        animation: _giro,
                        builder: (context, figlio) =>
                            _giro.value < 1 ? const SizedBox.shrink() : figlio!,
                        child: _TreMovimenti(
                            responso: responso,
                            giorno: _adesso,
                            palette: _palette),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}

/// Le carte coperte, e quella toccata che si gira.
class _Carte extends StatelessWidget {
  const _Carte({
    required this.giro,
    required this.toccata,
    required this.responso,
    required this.palette,
    required this.onScegli,
  });

  final AnimationController giro;
  final int? toccata;
  final ResponsoDellAlba? responso;
  final MaestroPalette palette;
  final ValueChanged<int> onScegli;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: giro,
      builder: (context, _) {
        final r = responso;
        // A carta girata resta la sola carta, grande: le altre non servono
        // piu' e non devono sembrare un'altra scelta possibile.
        if (r != null && giro.value >= 1) {
          return Center(
            child: SizedBox(
              width: 220,
              child: AspectRatio(
                aspectRatio: 0.62,
                child: _Faccia(responso: r, palette: palette),
              ),
            ),
          );
        }
        return Row(
          children: [
            for (var i = 0; i < ArcanoDellAlbaScreen.carteCoperte; i++) ...[
              if (i > 0) const SizedBox(width: SpacingTokens.sm),
              Expanded(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: toccata == null || toccata == i ? 1 : 0.25,
                  child: Semantics(
                    button: toccata == null,
                    label: 'Carta coperta ${i + 1}. Toccala per girarla.',
                    child: GestureDetector(
                      key: Key('arcano_alba_carta_$i'),
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onScegli(i),
                      child: AspectRatio(
                        aspectRatio: 0.62,
                        child: toccata == i && r != null
                            ? _CartaCheSiGira(
                                t: giro.value, responso: r, palette: palette)
                            : const _Dorso(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Il dorso del mazzo, uguale per ogni carta coperta.
class _Dorso extends StatelessWidget {
  const _Dorso();

  @override
  Widget build(BuildContext context) => Image.asset(
        TarotDeck.dorsoFull,
        key: const Key('arcano_alba_dorso'),
        fit: BoxFit.contain,
      );
}

/// **LA CARTA CHE SI GIRA sull'asse verticale.** Nella prima meta' del giro si
/// vede il dorso, identico per ogni verso; la faccia, col suo verso, compare
/// solo dalla seconda meta'.
class _CartaCheSiGira extends StatelessWidget {
  const _CartaCheSiGira(
      {required this.t, required this.responso, required this.palette});

  final double t;
  final ResponsoDellAlba responso;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    final angolo = t * math.pi;
    final faccia = t >= 0.5;
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateY(angolo),
      child: faccia
          ? Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()..rotateY(math.pi),
              child: _Faccia(responso: responso, palette: palette),
            )
          : const _Dorso(),
    );
  }
}

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
        // **I CARTIGLI ACCESI, per richiesta del fondatore del 17 settembre
        // 2026**: una carta coi cartigli vuoti sembra una carta incompiuta.
        // Il nome inciso e' arte della carta e sta sotto la misura di
        // lettura come su ogni carta del mazzo; il nome col verso e
        // l'attribuzione si leggono nel primo movimento, a misura piena.
      );
}

/// **I TRE MOVIMENTI**, ciascuno col suo compito e la sua chiave.
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
