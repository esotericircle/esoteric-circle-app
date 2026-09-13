import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/rituals/animal_catalog.dart';
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
/// **IL GESTO E' IL SUO DISEGNO, E FINCHE' IL DISEGNO NON C'E' E'
/// L'ILLUSTRAZIONE CHE SI MUOVE.** Ordine DJ voce 08: tre gesti per dodici
/// animali, trentasei disegni, `GestiDelSegno.disegniAttesi`. **Quando il
/// disegno del gesto e' nel pacchetto si vede il disegno**, che compare mentre
/// il gesto accade. **Quando manca si vede l'illustrazione intera
/// dell'animale**, e il gesto e' un suo movimento, diverso per ognuno: si
/// avvicina crescendo, si volta ruotando su se stessa, si allontana
/// rimpicciolendo e sbiadendo. Mai un riquadro vuoto: finche' il pacchetto
/// non ha risposto, si vede l'illustrazione.
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
        return (
          scala: 0.85,
          specchio: math.cos(math.pi * e),
          dx: 0,
          dy: 0,
          luce: 1
        );
      case GestoDelSegno.siAvvicina:
        return (
          scala: 0.72 + 0.36 * e,
          specchio: 1,
          dx: 0,
          dy: 40 * e,
          luce: 1
        );
      case GestoDelSegno.siAllontana:
        return (
          scala: 0.85 - 0.30 * e,
          specchio: 1,
          dx: 0,
          dy: -46 * e,
          luce: 1 - 0.45 * e,
        );
    }
  }

  /// **SE IL DISEGNO DI UN GESTO E' NEL PACCHETTO.** Si chiede, non si
  /// suppone, come per il verso dell'animale: la risposta si ricorda, perche'
  /// il pacchetto non cambia mentre l'app gira.
  static Future<bool> ilDisegnoCE(String percorso) async {
    final saputo = _disegni[percorso];
    if (saputo != null) return saputo;
    try {
      final dati = await rootBundle.load(percorso);
      return _disegni[percorso] = dati.lengthInBytes > 0;
    } catch (errore) {
      // **UN DISEGNO CHE NON C'E' NON E' UN GUASTO**: e' un file ancora da
      // consegnare. Si mostra l'illustrazione, e basta.
      return _disegni[percorso] = false;
    }
  }

  static final Map<String, bool> _disegni = {};

  /// Le prove possono dichiarare quali disegni ci sono.
  @visibleForTesting
  static void disegniNelleProve(Map<String, bool> quali) {
    _disegni
      ..clear()
      ..addAll(quali);
  }

  @override
  State<IlSegnoCheRisponde> createState() => _IlSegnoCheRispondeState();
}

class _IlSegnoCheRispondeState extends State<IlSegnoCheRisponde> {
  final TextEditingController _domanda = TextEditingController();
  UnSegno? _segno;

  /// Il disegno del gesto di [_segno], quando il pacchetto dice che c'e'.
  String? _disegno;
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
    final percorso = GestiDelSegno.disegnoDi(widget.animale, segno.gesto);
    final c = await IlSegnoCheRisponde.ilDisegnoCE(percorso);
    if (!mounted) return;
    setState(() {
      _segno = segno;
      _disegno = c ? percorso : null;
      _inAttesa = false;
      _t = 0;
    });
    _passo?.cancel();
    _passo = Timer.periodic(const Duration(milliseconds: 16), (t) {
      if (!mounted) return t.cancel();
      final quanto =
          16 * t.tick / IlSegnoCheRisponde.quantoDuraIlGesto.inMilliseconds;
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
    final disegno = _disegno;
    // **COL DISEGNO IL GESTO E' GIA' DISEGNATO**, e l'illustrazione non si
    // muove: il disegno compare mentre il gesto accade.
    final mov = segno == null || disegno != null
        ? (scala: 0.85, specchio: 1.0, dx: 0.0, dy: 0.0, luce: 1.0)
        : IlSegnoCheRisponde.movimento(segno.gesto, _t);
    return Stack(
      fit: StackFit.expand,
      children: [
        const SfondoDelMondoDiSotto(quale: SfondoDelViaggio.fondo),
        LayoutBuilder(builder: (context, vincoli) {
          // **LA MISURA VERA DI QUESTO ANIMALE**, ordine DI voce 10: con le
          // proporzioni del Lupo per tutti, il Gufo stava in un riquadro
          // largo con due bande vuote ai lati. Alto al massimo poco piu' di
          // meta' scena.
          final misura =
              LeSagome.misure[widget.animale.name] ?? const Size(898, 760);
          var larga = vincoli.maxWidth * 0.86;
          var alta = larga * misura.height / misura.width;
          final tetto = vincoli.maxHeight * 0.55;
          if (alta > tetto) {
            alta = tetto;
            larga = alta * misura.width / misura.height;
          }
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
                    child: disegno != null
                        ? Opacity(
                            opacity: _t,
                            child: Image.asset(
                              disegno,
                              key: const Key('viaggio_disegno_del_gesto'),
                              fit: BoxFit.contain,
                              // Un disegno che il pacchetto dichiara e non
                              // decodifica lascia il posto all'illustrazione.
                              errorBuilder: (_, __, ___) => Image.asset(
                                  widget.animale.fullPath,
                                  fit: BoxFit.contain),
                            ),
                          )
                        : Image.asset(
                            widget.animale.fullPath,
                            key: const Key('viaggio_illustrazione_del_segno'),
                            fit: BoxFit.contain,
                            opacity: AlwaysStoppedAnimation(mov.luce),
                            errorBuilder: (_, __, ___) =>
                                const SizedBox.shrink(),
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
          style:
              TypographyTokens.etichetta().copyWith(color: palette.goldSoft)),
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
              borderSide:
                  BorderSide(color: palette.gold.withValues(alpha: 0.3)),
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
