import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/rituals/animal_catalog.dart';
import '../../../../core/viaggio/dove_sta_la_testa.dart';
import '../../../../core/viaggio/il_segno_dell_animale.dart';
import '../../../../core/viaggio/le_sagome_in_celle.dart';
import '../../../../design_system/theme/maestro_palette.dart';
import '../../../../design_system/tokens/color_tokens.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';
import '../../../../design_system/typography/paragrafi_di_lettura.dart';
import 'sfondo_del_mondo_di_sotto.dart';

/// **IL SEGNO CHE RISPONDE.** Ordine DI voce 14, 12 settembre 2026.
///
/// *"La persona scrive una domanda in una riga. L'animale risponde con un
/// gesto, non con un discorso. La risposta e' una immagine o una animazione
/// breve dell'animale piu' una riga sola di testo che dice cosa ha fatto e
/// cosa vuol dire per la domanda posta."*
///
/// **IL GESTO E' L'ILLUSTRAZIONE CHE SI MUOVE**, e lo dico per quello che e':
/// per ognuno dei dodici animali c'e' un'illustrazione sola, e sei gesti per
/// dodici animali farebbero settantadue disegni che non esistono. Qui il
/// gesto e' un movimento dell'illustrazione vera, diverso per ogni gesto: si
/// volta ruotando su se stessa, si avvicina crescendo, si allontana
/// rimpicciolendo e sbiadendo, si siede abbassandosi, guarda lontano
/// spostandosi e voltandosi, porta qualcosa con una luce che nasce dove sta la
/// sua bocca. **I disegni veri dei gesti sono un lavoro da fare**, e il
/// rapporto lo dice.
class IlSegnoCheRisponde extends StatefulWidget {
  const IlSegnoCheRisponde({
    super.key,
    required this.animale,
    required this.palette,
    required this.siPuoChiedere,
    required this.quandoTorna,
    required this.chiedi,
    required this.quandoTorni,
    required this.quandoNutri,
  });

  final GuideAnimal animale;
  final MaestroPalette palette;

  /// Se il piano consente un segno adesso. Se no, si dice quando torna e si
  /// offre il nutrimento: *"non si mostra un muro"*.
  final bool siPuoChiedere;

  /// La riga che dice quando torna un segno, gia' composta dai tetti.
  final String quandoTorna;

  /// Chiede il segno, col modello o con la riserva: non fallisce mai.
  final Future<UnSegno> Function(String domanda) chiedi;

  final VoidCallback quandoTorni;
  final VoidCallback quandoNutri;

  /// **QUANTO DURA IL GESTO.** Un secondo e mezzo: abbastanza per vederlo
  /// accadere, poco per aspettarlo.
  static const Duration quantoDuraIlGesto = Duration(milliseconds: 1500);

  /// La lunghezza massima della domanda: una riga.
  static const int domandaAlMassimo = 120;

  /// **COME SI MUOVE L'ILLUSTRAZIONE**, per ogni gesto, a [t] fra 0 e 1.
  /// Pubblica perche' una guardia possa pretendere che ogni gesto si muova
  /// davvero, e in un modo suo.
  static ({double scala, double specchio, double dx, double dy, double luce})
      movimento(GestoDelSegno gesto, double t) {
    final e = Curves.easeInOutCubic.transform(t.clamp(0.0, 1.0));
    switch (gesto) {
      case GestoDelSegno.siVolta:
        return (scala: 0.85, specchio: math.cos(math.pi * e), dx: 0, dy: 0, luce: 1);
      case GestoDelSegno.siAvvicina:
        return (scala: 0.72 + 0.36 * e, specchio: 1, dx: 0, dy: 40 * e, luce: 1);
      case GestoDelSegno.siSiede:
        return (scala: 0.85 - 0.05 * e, specchio: 1, dx: 0, dy: 26 * e, luce: 1);
      case GestoDelSegno.portaQualcosa:
        return (scala: 0.78 + 0.12 * e, specchio: 1, dx: 0, dy: 16 * e, luce: 1);
      case GestoDelSegno.siAllontana:
        return (
          scala: 0.85 - 0.30 * e,
          specchio: 1,
          dx: 0,
          dy: -46 * e,
          luce: 1 - 0.45 * e,
        );
      case GestoDelSegno.guardaLontano:
        return (
          scala: 0.85,
          specchio: e < 0.5 ? 1 : -1,
          dx: -30 * e,
          dy: 0,
          luce: 1,
        );
    }
  }

  @override
  State<IlSegnoCheRisponde> createState() => _IlSegnoCheRispondeState();
}

class _IlSegnoCheRispondeState extends State<IlSegnoCheRisponde> {
  final TextEditingController _domanda = TextEditingController();
  UnSegno? _segno;
  bool _inAttesa = false;
  double _t = 0;
  /// Il gesto si misura coi battiti del `Timer`, che sul telefono seguono
  /// l'orologio vero e nelle prove quello simulato.
  Timer? _passo;

  @override
  void dispose() {
    _passo?.cancel();
    _domanda.dispose();
    super.dispose();
  }

  Future<void> _chiedi() async {
    final testo = _domanda.text.trim();
    if (testo.isEmpty || _inAttesa) return;
    FocusScope.of(context).unfocus();
    setState(() => _inAttesa = true);
    final segno = await widget.chiedi(testo);
    if (!mounted) return;
    setState(() {
      _segno = segno;
      _inAttesa = false;
      _t = 0;
    });
    _passo?.cancel();
    _passo = Timer.periodic(const Duration(milliseconds: 16), (t) {
      if (!mounted) return t.cancel();
      final quanto = 16 *
          t.tick /
          IlSegnoCheRisponde.quantoDuraIlGesto.inMilliseconds;
      setState(() => _t = quanto.clamp(0.0, 1.0));
      if (quanto >= 1) t.cancel();
    });
  }

  String get _conArticolo => '${widget.animale.articolo}${widget.animale.name}';

  /// *al Lupo*, *alla Volpe*, *all'Aquila*.
  String get _alNome {
    final a = widget.animale.articolo;
    if (a == 'il ') return 'al ${widget.animale.name}';
    if (a == 'la ') return 'alla ${widget.animale.name}';
    // L'articolo elide davanti a vocale, e la preposizione con lui.
    return 'al$a${widget.animale.name}';
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final segno = _segno;
    final mov = segno == null
        ? (scala: 0.85, specchio: 1.0, dx: 0.0, dy: 0.0, luce: 1.0)
        : IlSegnoCheRisponde.movimento(segno.gesto, _t);
    return Stack(
      fit: StackFit.expand,
      children: [
        const SfondoDelMondoDiSotto(quale: SfondoDelViaggio.fondo),
        LayoutBuilder(builder: (context, vincoli) {
          // **LA MISURA VERA DI QUESTO ANIMALE**, ordine DI voce 10: con le
          // proporzioni del Lupo per tutti, il Gufo stava in un riquadro
          // largo con due bande vuote ai lati, e la luce di cio' che porta
          // cadeva fuori dal becco. Alto al massimo poco piu' di meta' scena.
          final misura =
              LeSagome.misure[widget.animale.name] ?? const Size(898, 760);
          var larga = vincoli.maxWidth * 0.86;
          var alta = larga * misura.height / misura.width;
          final tetto = vincoli.maxHeight * 0.55;
          if (alta > tetto) {
            alta = tetto;
            larga = alta * misura.width / misura.height;
          }
          final testa = DoveStaLaTesta.di(widget.animale.name);
          return Align(
            alignment: const Alignment(0, -0.35),
            child: Transform.translate(
              offset: Offset(mov.dx, mov.dy),
              child: Transform.scale(
                scale: mov.scala,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.diagonal3Values(mov.specchio, 1, 1),
                  child: SizedBox(
                    key: const Key('viaggio_animale_del_segno'),
                    width: larga,
                    height: alta,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          widget.animale.fullPath,
                          fit: BoxFit.contain,
                          opacity: AlwaysStoppedAnimation(mov.luce),
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                        // **LA LUCE DI CIO' CHE PORTA**, dove sta la bocca: il
                        // fondo del rettangolo della testa, gia' tabulato per
                        // i dodici animali.
                        if (segno?.gesto == GestoDelSegno.portaQualcosa &&
                            testa != null)
                          Positioned(
                            left: larga * testa.center.dx - 18,
                            top: alta * testa.bottom - 18,
                            width: 36,
                            height: 36,
                            child: Opacity(
                              opacity: _t,
                              child: DecoratedBox(
                                key: const Key('viaggio_cosa_portata'),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(colors: [
                                    palette.goldSoft,
                                    palette.gold.withValues(alpha: 0),
                                  ]),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
        Align(
          alignment: Alignment.bottomCenter,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(SpacingTokens.lg),
              child: _ilPannello(palette, segno),
            ),
          ),
        ),
      ],
    );
  }

  Widget _ilPannello(MaestroPalette palette, UnSegno? segno) {
    final torna = TextButton(
      key: const Key('viaggio_torna_dal_segno'),
      onPressed: widget.quandoTorni,
      child: Text('Torna',
          style: TypographyTokens.etichetta().copyWith(color: palette.goldSoft)),
    );
    if (!widget.siPuoChiedere && segno == null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // **IL TESTO DA LEGGERE PASSA DALLA SUA PORTA**, ordine DI: la
          // guardia della lettura ha trovato qui un Text diretto.
          ParagrafiDiLettura(
            key: const Key('viaggio_quando_torna_un_segno'),
            testo: widget.quandoTorna,
            textAlign: TextAlign.center,
            stile: TypographyTokens.lettura().copyWith(color: palette.goldSoft),
          ),
          const SizedBox(height: SpacingTokens.md),
          FilledButton(
            key: const Key('viaggio_nutri_dal_segno'),
            onPressed: widget.quandoNutri,
            style: FilledButton.styleFrom(
              backgroundColor: palette.primary,
              foregroundColor: palette.onPrimary,
              minimumSize: const Size.fromHeight(52),
            ),
            child: Text(_nutriLo, style: TypographyTokens.etichetta()),
          ),
          torna,
        ],
      );
    }
    if (segno != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // **LA RIGA ARRIVA A GESTO FINITO**: prima si guarda cosa fa, poi si
          // legge cosa vuol dire.
          Opacity(
            opacity: _t >= 1 ? 1 : 0,
            child: ParagrafiDiLettura(
              key: const Key('viaggio_riga_del_segno'),
              testo: segno.riga,
              textAlign: TextAlign.center,
              stile: TypographyTokens.lettura()
                  .copyWith(color: ColorTokens.textPrimary, height: 1.5),
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          torna,
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Chiedi un segno $_alNome',
          key: const Key('viaggio_chiedi_un_segno_titolo'),
          textAlign: TextAlign.center,
          style: TypographyTokens.titoloScheda()
              .copyWith(color: ColorTokens.textPrimary),
        ),
        const SizedBox(height: SpacingTokens.xs),
        Text(
          '${_maiuscola(_conArticolo)} non parla: risponde con un gesto.',
          textAlign: TextAlign.center,
          style: TypographyTokens.didascalia()
              .copyWith(color: ColorTokens.textSecondary),
        ),
        const SizedBox(height: SpacingTokens.md),
        TextField(
          key: const Key('viaggio_domanda_del_segno'),
          controller: _domanda,
          maxLines: 1,
          maxLength: IlSegnoCheRisponde.domandaAlMassimo,
          textInputAction: TextInputAction.send,
          onSubmitted: (_) => unawaited(_chiedi()),
          style:
              TypographyTokens.corpo().copyWith(color: ColorTokens.textPrimary),
          decoration: InputDecoration(
            hintText: 'Una domanda, in una riga',
            hintStyle: TypographyTokens.corpo()
                .copyWith(color: ColorTokens.textSecondary),
            filled: true,
            fillColor: Colors.black.withValues(alpha: 0.35),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
              borderSide: BorderSide(color: palette.gold.withValues(alpha: 0.3)),
            ),
          ),
        ),
        const SizedBox(height: SpacingTokens.sm),
        FilledButton(
          key: const Key('viaggio_chiedi_il_segno'),
          onPressed: _inAttesa ? null : () => unawaited(_chiedi()),
          style: FilledButton.styleFrom(
            backgroundColor: palette.primary,
            foregroundColor: palette.onPrimary,
            minimumSize: const Size.fromHeight(52),
          ),
          child: Text(_inAttesa ? 'Ti sta guardando' : 'Chiedi',
              style: TypographyTokens.etichetta()),
        ),
        torna,
      ],
    );
  }

  String get _nutriLo => widget.animale.femminile ? 'Nutrila' : 'Nutrilo';

  static String _maiuscola(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
