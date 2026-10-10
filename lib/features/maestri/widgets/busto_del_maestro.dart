import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/maestro/maestro.dart';
import '../../../design_system/theme/maestro_palette.dart';

/// LA PORTA UNICA DEL BUSTO, ordine I voce 1.
///
/// In ogni schermata in cui un Maestro compare in alto, dominio, chat, arti,
/// si mostra il BUSTO: la figura dalla vita in su che sfuma in basso, ottenuta
/// RITAGLIANDO l'immagine intera dell'avatar con lo stesso metodo con cui
/// Medora compare nella Stesa di Tarocchi. Nessuna arte nuova: il ritaglio e'
/// un fatto di resa, non un asset.
///
/// **La scelta dell'immagine vive qui e solo qui.** Prima erano tre punti a
/// scegliere da se': `MedoraStage` con l'asset scritto in casa, la vecchia
/// `MaestroPresence` che mostrava la figura INTERA nel dominio e nella chat
/// vuota, e il `MaestroBust` del Santuario. Adesso chiunque mostri la figura
/// del Maestro in alto passa da questa porta; l'UNICA eccezione e' la home "Il
/// Cerchio", dove i tre restano interi dietro la carta, dichiarata dalla
/// guardia `test/il_busto_e_la_forma_del_maestro_test.dart`.
///
/// **Il metodo del ritaglio, identico per i tre.** L'immagine intera viene
/// resa alta `height / fattore` dentro un `OverflowBox` allineato in alto e
/// tagliato da un `ClipRect`: resta in scena la parte alta della figura, dalla
/// testa fin sotto le mani. Il taglio inferiore non e' una linea netta: una
/// `ShaderMask` in `dstIn` lo sfuma con le stesse fermate usate da Medora
/// nella Stesa, cosi' il busto non lascia bordo su nessun fondale. Stesso
/// fattore, stessa altezza e stesse fermate per i tre Maestri: il taglio cade
/// sulla stessa linea per costruzione, non per accordo fra schermate.
class BustoDelMaestro extends StatefulWidget {
  const BustoDelMaestro({
    super.key,
    required this.maestro,
    this.height = altezzaCanonica,
    this.fattore = fattoreDelBusto,
    this.larghezza = 1.0,
    this.aura = true,
    this.respira = true,
  });

  final Maestro maestro;

  /// L'altezza del riquadro. Il valore canonico e' [altezzaCanonica] e vale
  /// per ogni schermata: la grandezza del busto e' una regola, non un gusto
  /// locale. La Stesa la varia solo mentre si pesca, ed e' uno stato della sua
  /// scena, non una seconda regola.
  final double height;

  /// Quanta parte dell'immagine intera resta in scena: [fattoreDelBusto] e' il
  /// busto pieno, un valore piu' piccolo stringe sul volto.
  final double fattore;

  /// Quanta parte della larghezza resta in scena, centrata sul volto.
  final double larghezza;

  /// L'alone dietro la figura. Le scene che hanno gia' il proprio, come la
  /// Stesa, lo spengono per non sommarne due.
  final bool aura;

  /// Il micro respiro di scala. Le scene che animano gia' il busto per conto
  /// loro, come la Stesa, lo spengono per non sommare due respiri.
  final bool respira;

  /// L'altezza canonica del busto in alto, la stessa con cui Medora presiede
  /// la Stesa di Tarocchi a stesa compiuta.
  static const double altezzaCanonica = 300;

  /// Quanta parte dell'avatar a figura intera resta in scena nel busto pieno:
  /// dalla testa fino sotto le mani. E' il numero della Stesa, portato qui
  /// perche' la Stesa e' il riferimento dichiarato dall'ordine.
  static const double fattoreDelBusto = 0.58;

  /// Le fermate della sfumatura del taglio inferiore: piena fino all'86 per
  /// cento, poi si spegne. Le stesse della Stesa.
  static const List<double> fermateDellaSfumatura = [0.0, 0.86, 1.0];

  /// L'altezza della tela degli avatar, la stessa di
  /// `tool/normalizza_avatar.py` e di `avatar_dei_maestri_test.dart`.
  ///
  /// **L'avatar non si disegna mai oltre la sua tela**: stirarlo lo sfoca, e
  /// la guardia `nessuno_disegna_oltre_la_tela_test` cade. Sul telefono di
  /// riferimento (rapporto 3) l'altezza canonica sta sotto il tetto; sugli
  /// schermi a rapporto 4 il busto si riduce di quel tanto che basta perche'
  /// l'immagine resti alla grandezza vera dei suoi pixel.
  static const int telaAvatarAltezza = 1700;

  /// L'immagine del Maestro, scelta in un punto solo: l'avatar intero
  /// dichiarato dal Maestro stesso. Chi ha bisogno del percorso, per
  /// precaricare o per verificare, lo chiede da qui.
  static String assetDi(Maestro maestro) => maestro.avatarAsset;

  @override
  State<BustoDelMaestro> createState() => _BustoDelMaestroState();
}

class _BustoDelMaestroState extends State<BustoDelMaestro>
    with SingleTickerProviderStateMixin {
  late final AnimationController _respiro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4200),
  );

  bool _avviato = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_avviato) return;
    _avviato = true;
    if (!widget.respira || MediaQuery.of(context).disableAnimations) {
      _respiro.value = 0.5;
    } else {
      _respiro.repeat();
    }
  }

  @override
  void dispose() {
    _respiro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(ThemeKey.of(widget.maestro));
    // Il tetto della tela: l'immagine intera si disegna alta height/fattore,
    // e in pixel fisici non deve superare la tela dell'asset. Dove il
    // rapporto di pixel e' alto, l'altezza scende di conseguenza.
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final tettoImmagine = BustoDelMaestro.telaAvatarAltezza / dpr - 0.01;
    final altezza = math.min(widget.height, tettoImmagine * widget.fattore);
    return SizedBox(
      key: Key('busto_${widget.maestro.id}'),
      height: altezza,
      child: AnimatedBuilder(
        animation: _respiro,
        builder: (context, _) {
          final t = _respiro.value;
          final respiro = 1 - (t - 0.5).abs() * 2; // 0..1..0
          final scala = 1.0 + 0.012 * respiro;
          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              if (widget.aura)
                Center(
                  child: Container(
                    width: altezza * 0.92,
                    height: altezza * 0.92,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [
                        palette.glow.withValues(alpha: 0.10 + 0.16 * respiro),
                        palette.primary.withValues(alpha: 0.08),
                        Colors.transparent,
                      ], stops: const [
                        0.0,
                        0.55,
                        1.0
                      ]),
                    ),
                  ),
                ),
              Transform.scale(
                scale: scala,
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  height: altezza,
                  width:
                      widget.larghezza < 1 ? altezza * widget.larghezza : null,
                  // Il taglio del busto sfuma, non e' una linea netta.
                  child: ShaderMask(
                    blendMode: BlendMode.dstIn,
                    shaderCallback: (rect) => const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white,
                        Colors.white,
                        Colors.transparent,
                      ],
                      stops: BustoDelMaestro.fermateDellaSfumatura,
                    ).createShader(rect),
                    child: ClipRect(
                      child: OverflowBox(
                        alignment: Alignment.topCenter,
                        minWidth: 0,
                        maxWidth: double.infinity,
                        minHeight: altezza / widget.fattore,
                        maxHeight: altezza / widget.fattore,
                        child: Image.asset(
                          BustoDelMaestro.assetDi(widget.maestro),
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Center(
                            child: Icon(widget.maestro.icon,
                                color: palette.goldSoft, size: altezza * 0.2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
