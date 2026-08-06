import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/maestro/maestro.dart';
import '../../../design_system/theme/maestro_palette.dart';
import '../../../design_system/tokens/spacing_tokens.dart';

/// Un mezzo busto del Maestro davanti al palco del Santuario, dentro la sua
/// carta in formato ritratto con cornice dorata lavorata, stile tarocco.
///
/// La testa esce dal bordo alto della cornice, che resta un piano dietro: e' li'
/// che scatta il 2.5D. Il master full body e' segnaposto in attesa del crop a
/// mezzo busto; il codice lo anima soltanto (respiro e aura del centrale). I
/// busti laterali restano piu' scuri, arretrati e quasi fermi: si smorza la
/// sola figura scontornata, mai un rettangolo dietro.
class MaestroBust extends StatelessWidget {
  const MaestroBust({
    super.key,
    required this.maestro,
    required this.height,
    required this.central,
    this.dim = 0.0,
    this.breath = 0.0,
    this.preferred = false,
    this.conAlone = true,
  });

  /// Spegne l'alone dietro la figura.
  ///
  /// **Esiste per la misura, e non e' un'opzione di prodotto.** L'unico modo di
  /// dire se un alone fa davvero qualcosa e' rendere la stessa carta due volte,
  /// con e senza, e confrontare i pixel: guardare la sola resa accesa direbbe
  /// soltanto che qualcosa e' stato dipinto. Nell'app resta sempre acceso.
  final bool conAlone;

  final Maestro maestro;
  final double height;
  final bool central;

  /// Quanto scurire e arretrare il busto, da 0 (centrale, pieno) a 1.
  final double dim;

  /// Fase del respiro idle, da 0 a 1, usata solo dal centrale.
  final double breath;

  /// Vero per il Maestro preferito, con un marcatore discreto sulla cornice.
  final bool preferred;

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(ThemeKey.of(maestro));
    // Carta in formato ritratto, piu' alta che larga, come un tarocco.
    final frameWidth = height * 0.58;
    final frameHeight = height * 0.84;
    final floatY = central ? (breath - 0.5) * 8 : 0.0;
    final auraPulse = 0.5 + 0.5 * breath;

    // La sola figura si scurisce, rispettando l'alpha del PNG: nessun velo
    // rettangolare dietro. srcATop tinge solo i pixel opachi del master.
    final Color? figureTint =
        dim > 0 ? Colors.black.withValues(alpha: dim * 0.5) : null;

    Widget bust = SizedBox(
      width: frameWidth * 1.3,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // Aura del Maestro dietro, viva solo per il centrale.
          if (central)
            Positioned(
              bottom: frameHeight * 0.2,
              child: Container(
                width: frameWidth * 1.7,
                height: frameWidth * 1.7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      palette.glow.withValues(alpha: 0.10 + 0.22 * auraPulse),
                      palette.primary.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
          // La carta con la cornice dorata lavorata, un piano dietro.
          Positioned(
            bottom: 0,
            child: _MaestroFrame(
              width: frameWidth,
              height: frameHeight,
              palette: palette,
              central: central,
            ),
          ),
          // L'ALONE, nello strato di mezzo: davanti al fondo della carta e
          // dietro la figura. E' l'unico posto in cui puo' stare per fare
          // quello che deve, cioe' staccare il busto dal suo fondo.
          if (conAlone)
            Positioned(
              bottom: 0,
              child: AloneDietroLaFigura(
                width: frameWidth,
                height: frameHeight,
              ),
            ),
          // Il busto: master full body, allineato in basso e piu' alto della
          // cornice, cosi' la testa rompe il bordo alto. La figura si scurisce
          // via colorBlendMode, che rispetta la trasparenza del PNG.
          Transform.translate(
            offset: Offset(0, floatY),
            child: Image.asset(
              maestro.avatarAsset,
              height: height,
              fit: BoxFit.contain,
              alignment: Alignment.bottomCenter,
              color: figureTint,
              colorBlendMode: BlendMode.srcATop,
              errorBuilder: (context, error, stack) => _fallback(palette),
            ),
          ),
          // Marcatore del preferito: un piccolo rombo dorato discreto,
          // incastonato al centro del bordo basso della carta.
          if (preferred)
            Positioned(
              bottom: -3,
              child: _PreferredGem(color: palette.goldSoft),
            ),
        ],
      ),
    );

    // I laterali sono arretrati: solo un velo di opacita' complessiva, senza
    // alcun rettangolo scuro (la penombra della figura la da' figureTint).
    if (dim > 0) {
      bust = Opacity(opacity: 1 - dim * 0.28, child: bust);
    }
    return bust;
  }

  Widget _fallback(MaestroPalette palette) {
    return Container(
      width: height * 0.4,
      height: height * 0.4,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: palette.primary.withValues(alpha: 0.4),
        border: Border.all(color: palette.gold.withValues(alpha: 0.6)),
      ),
      child:
          Icon(maestro.icon, color: palette.goldSoft, size: height * 0.16),
    );
  }
}

/// L'ALONE BIANCO DIETRO LA FIGURA, in un punto solo per tutti e tre.
///
/// **Perche' esiste.** Le tre figure si perdevano nel fondo della propria
/// carta, che e' scuro come loro: mancava lo stacco fra il busto e il piano che
/// gli sta dietro. L'alone non e' un ornamento, e' quello stacco.
///
/// **Dove vive, e non e' indifferente.** Davanti al fondo della carta e dietro
/// la figura. Dietro la carta non si vedrebbe affatto, coperto dal fondo;
/// davanti alla figura le farebbe una velatura sopra il viso. Lo strato di
/// mezzo e' l'unico che funziona.
///
/// **Non esce dalla cornice.** Il ritaglio ha lo stesso raggio della carta,
/// quindi l'alone sfuma dentro i suoi bordi invece di allargarsi attorno a
/// essa: un alone che sborda diventa un bagliore intorno al riquadro, che e'
/// un'altra cosa e si legge come un errore di stampa.
///
/// **Non pulsa, ed e' una scelta.** L'aura del Maestro che sta dietro la carta
/// respira gia' col busto centrale: due pulsazioni sovrapposte sullo stesso
/// oggetto diventano rumore. Non pulsando, non c'e' nessuna animazione da
/// spegnere con Riduci Movimento, e questo widget non ha bisogno di saperne
/// niente.
class AloneDietroLaFigura extends StatelessWidget {
  const AloneDietroLaFigura({
    super.key,
    required this.width,
    required this.height,
  });

  final double width;
  final double height;

  /// DOVE STA IL CENTRO, in coordinate della carta.
  ///
  /// Segue il BUSTO e non il centro geometrico della carta. La figura e' alta
  /// quanto tutta la scena e appoggiata in basso, mentre la carta e' alta
  /// l'ottantaquattro per cento: il torace e le spalle cadono quindi nella
  /// meta' alta del riquadro, non a meta'. Il numero e' dichiarato qui e
  /// verificato dalla misura differenziale, che cade se l'alone si accende
  /// dove la figura non c'e'.
  static const Alignment centro = Alignment(0, -0.28);

  /// Quanto e' ampio, in frazioni del lato maggiore del riquadro.
  static const double raggio = 0.78;

  /// Le opacita' del bianco, dal cuore al bordo.
  ///
  /// **Tarate sulla misura, non a occhio, e la misura e' stata rifatta.** La
  /// luminanza attorno alla silhouette passa da 43,5 a 62,6, cioe' sale del
  /// 43,9 per cento contro il venticinque chiesto.
  ///
  /// I numeri precedenti erano gonfiati e vanno saputi: 75,7 per cento con la
  /// prima taratura e 41,2 con la seconda, misurati pero' fra una resa in cui
  /// l'avatar non era ancora decodificato e una in cui lo era. Quel confronto
  /// non misurava l'alone, misurava anche la comparsa della figura. Precaricando
  /// l'immagine prima di tutte e due le rese, la seconda taratura si e' rivelata
  /// da 17,5 per cento, cioe' sotto il minimo, ed e' salita qui.
  static const double alCuore = 0.30;
  static const double aMezzo = 0.12;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
      child: SizedBox(
        width: width,
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: centro,
              radius: raggio,
              colors: [
                Colors.white.withValues(alpha: alCuore),
                Colors.white.withValues(alpha: aMezzo),
                Colors.white.withValues(alpha: 0.0),
              ],
              stops: const [0.0, 0.48, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}

/// La carta del Maestro: cornice dorata a doppio filo con fioroni agli angoli,
/// stile tarocco, tinta sulla palette del Maestro. E' la finestra da cui il
/// mezzo busto sporge in avanti.
class _MaestroFrame extends StatelessWidget {
  const _MaestroFrame({
    required this.width,
    required this.height,
    required this.palette,
    required this.central,
  });

  final double width;
  final double height;
  final MaestroPalette palette;
  final bool central;

  @override
  Widget build(BuildContext context) {
    final double outerAlpha = central ? 0.85 : 0.5;
    final double innerAlpha = central ? 0.6 : 0.35;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            palette.surfaceElevated.withValues(alpha: 0.95),
            palette.deepest.withValues(alpha: 0.92),
          ],
        ),
        borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
        border: Border.all(
          color: palette.gold.withValues(alpha: outerAlpha),
          width: 2,
        ),
        boxShadow: central
            ? [
                BoxShadow(
                  color: palette.glow.withValues(alpha: 0.35),
                  blurRadius: 34,
                  spreadRadius: -6,
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          // Secondo filo dorato interno, il tratto lavorato della cornice.
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(SpacingTokens.radiusMd),
                  border: Border.all(
                    color: palette.goldSoft.withValues(alpha: innerAlpha),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
          // Fioroni: quattro piccoli rombi dorati agli angoli interni.
          for (final a in const [
            Alignment.topLeft,
            Alignment.topRight,
            Alignment.bottomLeft,
            Alignment.bottomRight,
          ])
            Align(
              alignment: a,
              child: Padding(
                padding: const EdgeInsets.all(9),
                child: _Diamond(
                  size: 5,
                  color: palette.goldSoft.withValues(alpha: outerAlpha),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Piccolo rombo dorato, gemma del marcatore del preferito.
class _PreferredGem extends StatelessWidget {
  const _PreferredGem({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.14),
      ),
      child: _Diamond(size: 7, color: color),
    );
  }
}

/// Un rombo pieno, mattone ornamentale della cornice.
class _Diamond extends StatelessWidget {
  const _Diamond({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: math.pi / 4,
      child: Container(width: size, height: size, color: color),
    );
  }
}
