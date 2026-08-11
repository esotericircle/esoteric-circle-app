import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/entitlement/question_allowance.dart';
import '../../core/sigilli/bonus_della_condivisione.dart';
import '../../core/sigilli/diario_del_cammino.dart';
import '../../core/sigilli/sentieri.dart';
import '../../design_system/components/cosmos_background.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../services/app_services.dart';
import 'card_del_traguardo.dart';

/// LA CELEBRAZIONE DI UN TRAGUARDO, nelle sue due forme.
///
/// **Ogni traguardo viene celebrato, senza eccezioni, e ogni celebrazione
/// offre la condivisione.** Cambia la forma, non il fatto: a schermo pieno
/// per il primo traguardo in assoluto e per i cinque grandi, in
/// sovrimpressione per i mini. Cinquanta interruzioni a schermo pieno per
/// sentiero trasformerebbero la magia in fastidio, e un mini che passa senza
/// una parola non sarebbe un traguardo.
class Celebrazione {
  const Celebrazione._();

  /// Celebra cio' che si e' appena acceso, nella forma giusta.
  ///
  /// [primoInAssoluto] e' vero quando questo e' il primissimo Sigillo della
  /// persona: quello va a schermo pieno anche se e' un mini, perche' il primo
  /// premio deve sembrare grande.
  static Future<void> festeggia(
    BuildContext context, {
    required Traguardo traguardo,
    required Sentiero sentiero,
    required bool primoInAssoluto,
    String? serie,
  }) async {
    if (traguardo.eGrande || primoInAssoluto) {
      await Navigator.of(context).push(_RottaDellaCelebrazione(
        traguardo: traguardo,
        sentiero: sentiero,
        serie: serie,
      ));
      return;
    }
    mostraLaSovrimpressione(context,
        traguardo: traguardo, sentiero: sentiero, serie: serie);
  }
}

/// LA FORMA GRANDE: la scena prende tutto, il Maestro parla, il segno si
/// compie. Non finisce mai col punto: in fondo c'e' il prossimo traguardo.
class _RottaDellaCelebrazione extends PageRouteBuilder<void> {
  _RottaDellaCelebrazione({
    required this.traguardo,
    required this.sentiero,
    this.serie,
  }) : super(
          opaque: false,
          barrierColor: const Color(0xCC05060A),
          pageBuilder: (context, _, __) => CelebrazioneAScermoPieno(
            traguardo: traguardo,
            sentiero: sentiero,
            serie: serie,
          ),
        );

  final Traguardo traguardo;
  final Sentiero sentiero;
  final String? serie;
}

class CelebrazioneAScermoPieno extends StatefulWidget {
  const CelebrazioneAScermoPieno({
    super.key,
    required this.traguardo,
    required this.sentiero,
    this.serie,
  });

  final Traguardo traguardo;
  final Sentiero sentiero;

  /// "terzo giorno di seguito", quando c'e' una serie da dire.
  final String? serie;

  @override
  State<CelebrazioneAScermoPieno> createState() =>
      _CelebrazioneAScermoPienoState();
}

class _CelebrazioneAScermoPienoState extends State<CelebrazioneAScermoPieno>
    with SingleTickerProviderStateMixin {
  late final AnimationController _segno = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  bool _partito = false;

  /// IL MOVIMENTO SI DECIDE IN didChangeDependencies, non in initState: la
  /// MediaQuery non si puo' leggere prima che initState sia finito, e leggerla
  /// li' faceva cadere l'intera scena. Lo ha trovato la prova, al primo giro.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_partito) return;
    _partito = true;
    if (MediaQuery.of(context).disableAnimations) {
      _segno.value = 1;
    } else {
      _segno.forward();
    }
  }

  @override
  void dispose() {
    _segno.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final diario = context.watch<DiarioDelCammino>();
    final prossimo = diario.prossimoDi(widget.sentiero);

    return CosmosBackground(
      seed: 23,
      child: Material(
        type: MaterialType.transparency,
        child: SafeArea(
          // LA SCENA SCORRE SE LO SCHERMO E' BASSO, invece di traboccare: su
          // un telefono piccolo, o con la scrittura ingrandita, la festa non
          // deve diventare una riga gialla di errore. La prova lo ha trovato
          // al primo montaggio, su uno schermo da 600 punti.
          child: LayoutBuilder(
            builder: (context, vincoli) => SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: vincoli.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: SpacingTokens.xxl),
                    SegnoDelMaestro(
                      sentiero: widget.sentiero,
                      avanzamento: _segno,
                      grande: true,
                    ),
                    const SizedBox(height: SpacingTokens.lg),
                    Text(
                      widget.traguardo.nome,
                      key: const Key('celebrazione_nome'),
                      textAlign: TextAlign.center,
                      style: TypographyTokens.cerimonialeGrande()
                          .copyWith(color: palette.goldSoft),
                    ),
                    if (widget.serie != null) ...[
                      const SizedBox(height: SpacingTokens.xs),
                      Text(widget.serie!,
                          key: const Key('celebrazione_serie'),
                          style: TypographyTokens.etichetta()
                              .copyWith(color: palette.goldSoft)),
                    ],
                    const SizedBox(height: SpacingTokens.md),
                    Text(
                      widget.traguardo.frase,
                      key: const Key('celebrazione_frase'),
                      textAlign: TextAlign.center,
                      style: TypographyTokens.corpo().copyWith(
                          color: ColorTokens.textPrimary, height: 1.5),
                    ),
                    const SizedBox(height: SpacingTokens.md),
                    EosCheVolano(
                        quanti: widget.traguardo.eos, avanzamento: _segno),
                    const SizedBox(height: SpacingTokens.lg),
                    VieDellaCondivisione(
                      suScelta: (modo) => condividiIlTraguardo(
                        context,
                        traguardo: widget.traguardo,
                        modo: modo,
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.xl),
                    // NON SI CHIUDE MAI COL PUNTO: il prossimo traguardo e'
                    // sempre li', e sempre uno vicino. Un premio che finisce con
                    // un tasto Chiudi spegne il ciclo.
                    if (prossimo != null)
                      Container(
                        key: const Key('celebrazione_prossimo'),
                        padding: const EdgeInsets.all(SpacingTokens.md),
                        decoration: BoxDecoration(
                          color: palette.surfaceElevated.withValues(alpha: 0.7),
                          borderRadius:
                              BorderRadius.circular(SpacingTokens.radiusLg),
                          border: Border.all(
                              color: palette.gold.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          children: [
                            Text('Il prossimo',
                                style: TypographyTokens.etichetta()
                                    .copyWith(color: palette.goldSoft)),
                            const SizedBox(height: 4),
                            Text(prossimo.nome,
                                textAlign: TextAlign.center,
                                style: TypographyTokens.titoloScheda()
                                    .copyWith(color: ColorTokens.textPrimary)),
                          ],
                        ),
                      ),
                    const SizedBox(height: SpacingTokens.sm),
                    TextButton(
                      key: const Key('celebrazione_continua'),
                      onPressed: () => Navigator.of(context).maybePop(),
                      child: Text('Continua il cammino',
                          style: TypographyTokens.etichetta()
                              .copyWith(color: ColorTokens.textSecondary)),
                    ),
                    const SizedBox(height: SpacingTokens.md),
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

/// IL SEGNO DEL MAESTRO: il frutto che matura, la stella che si accende, il
/// petalo che si apre. Mai uno scrigno, in nessuna delle due forme.
class SegnoDelMaestro extends StatelessWidget {
  const SegnoDelMaestro({
    super.key,
    required this.sentiero,
    required this.avanzamento,
    this.grande = false,
  });

  final Sentiero sentiero;
  final Animation<double> avanzamento;
  final bool grande;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final misura = grande ? 96.0 : 32.0;
    final icona = switch (sentiero) {
      Sentiero.costellazione => Icons.star_rounded,
      Sentiero.albero => Icons.spa_rounded,
      Sentiero.loto => Icons.local_florist_rounded,
    };
    return AnimatedBuilder(
      key: const Key('segno_del_maestro'),
      animation: avanzamento,
      builder: (context, _) {
        final t = Curves.easeOutBack.transform(avanzamento.value.clamp(0, 1));
        return Opacity(
          opacity: avanzamento.value.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: 0.6 + 0.4 * t,
            child: Icon(icona, size: misura, color: palette.goldSoft),
          ),
        );
      },
    );
  }
}

/// GLI EOS CHE VOLANO NEL BORSELLINO, e il saldo che scatta a vista.
class EosCheVolano extends StatelessWidget {
  const EosCheVolano({
    super.key,
    required this.quanti,
    required this.avanzamento,
  });

  final int quanti;
  final Animation<double> avanzamento;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return AnimatedBuilder(
      key: const Key('eos_che_volano'),
      animation: avanzamento,
      builder: (context, _) {
        final visti = (quanti * avanzamento.value).round();
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome, size: 18, color: palette.goldSoft),
            const SizedBox(width: 6),
            Text('+$visti Eos',
                key: const Key('eos_contati'),
                style: TypographyTokens.titoloScheda()
                    .copyWith(color: palette.goldSoft)),
          ],
        );
      },
    );
  }
}

/// LA FORMA IN SOVRIMPRESSIONE, per i mini.
///
/// **Non blocca mai.** Vive in un overlay che NON intercetta i tocchi
/// (`IgnorePointer` su tutto tranne la fascia, che e' l'unica cosa toccabile),
/// si ritira da sola dopo qualche secondo, e chi la ignora non perde niente:
/// il Sigillo e' gia' acceso nel journal e da li' si riapre e si condivide.
void mostraLaSovrimpressione(
  BuildContext context, {
  required Traguardo traguardo,
  required Sentiero sentiero,
  String? serie,
}) {
  final overlay = Overlay.maybeOf(context);
  if (overlay == null) return;
  late final OverlayEntry fascia;
  fascia = OverlayEntry(
    builder: (ctx) => _FasciaDellaCelebrazione(
      traguardo: traguardo,
      sentiero: sentiero,
      serie: serie,
      suFine: () {
        if (fascia.mounted) fascia.remove();
      },
    ),
  );
  overlay.insert(fascia);
}

class _FasciaDellaCelebrazione extends StatefulWidget {
  const _FasciaDellaCelebrazione({
    required this.traguardo,
    required this.sentiero,
    required this.suFine,
    this.serie,
  });

  final Traguardo traguardo;
  final Sentiero sentiero;
  final String? serie;
  final VoidCallback suFine;

  @override
  State<_FasciaDellaCelebrazione> createState() =>
      _FasciaDellaCelebrazioneState();
}

class _FasciaDellaCelebrazioneState extends State<_FasciaDellaCelebrazione>
    with SingleTickerProviderStateMixin {
  late final AnimationController _segno = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  Timer? _ritiro;

  /// Quanto resta a schermo prima di ritirarsi da sola.
  static const Duration quantoResta = Duration(seconds: 6);

  @override
  void initState() {
    super.initState();
    _segno.forward();
    _ritiro = Timer(quantoResta, widget.suFine);
  }

  @override
  void dispose() {
    _ritiro?.cancel();
    _segno.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Positioned(
      left: SpacingTokens.md,
      right: SpacingTokens.md,
      top: MediaQuery.of(context).padding.top + SpacingTokens.sm,
      child: Material(
        key: const Key('sovrimpressione_del_traguardo'),
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: SpacingTokens.md, vertical: SpacingTokens.sm),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [palette.surfaceElevated, palette.deepest],
            ),
            borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
            border: Border.all(color: palette.gold.withValues(alpha: 0.45)),
          ),
          child: Row(
            children: [
              SegnoDelMaestro(sentiero: widget.sentiero, avanzamento: _segno),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(widget.traguardo.nome,
                        key: const Key('sovrimpressione_nome'),
                        style: TypographyTokens.titoloScheda()
                            .copyWith(color: palette.goldSoft)),
                    Text(
                      widget.serie ?? '+${widget.traguardo.eos} Eos',
                      key: const Key('sovrimpressione_eos'),
                      style: TypographyTokens.didascalia()
                          .copyWith(color: ColorTokens.textSecondary),
                    ),
                  ],
                ),
              ),
              // IL PULSANTE DI CONDIVISIONE C'E' ANCHE QUI, e porta alla
              // stessa card e allo stesso bonus della forma grande.
              VieDellaCondivisione(
                compatte: true,
                suScelta: (modo) => condividiIlTraguardo(
                  context,
                  traguardo: widget.traguardo,
                  modo: modo,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// RIAPRE LA CARD di un Sigillo gia' acceso, dal journal, anche settimane
/// dopo: il bonus in sospeso si incassa da qui.
Future<void> mostraLaCardDelTraguardo(
  BuildContext context, {
  required Traguardo traguardo,
  required Sentiero sentiero,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (foglio) => Padding(
      padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, SpacingTokens.lg,
          SpacingTokens.lg, SpacingTokens.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CardDelTraguardo(traguardo: traguardo, sentiero: sentiero),
          const SizedBox(height: SpacingTokens.md),
          VieDellaCondivisione(
            suScelta: (modo) {
              Navigator.of(foglio).pop();
              condividiIlTraguardo(context, traguardo: traguardo, modo: modo);
            },
          ),
        ],
      ),
    ),
  );
}

/// CONDIVIDE UN TRAGUARDO e incassa il bonus graduato, che e' uno solo.
Future<void> condividiIlTraguardo(
  BuildContext context, {
  required Traguardo traguardo,
  required ModoDellaCondivisione modo,
}) async {
  final diario = context.read<DiarioDelCammino>();
  final porta = context.read<AppServices>().porta;
  final borsa = context.read<QuestionAllowance>();
  await diario.segnaCondiviso(traguardo.id);
  final saldo = await PremioDelTraguardo.bonus(porta, traguardo, modo);
  if (saldo != null) await borsa.sincronizza();
}
