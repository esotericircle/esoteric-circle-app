import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/motion/parallax_controller.dart';
import '../../core/synastry/vip_catalog.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';

/// LE TRE PROFONDITA' DEL CIELO DEI VOLTI. Ordine BO voce 05.
///
/// **Perche' tre e non due o cinque.** Due piani non fanno profondita', fanno
/// uno sfondo e un davanti. Cinque su uno schermo da 360 punti vorrebbero dire
/// ritratti sotto i cinquanta punti sul piano piu' lontano, cioe' sotto il
/// bersaglio minimo che il dito pretende. Tre e' il numero che regge tutte e
/// due le cose: il piu' piccolo resta toccabile, e fra il piu' vicino e il piu'
/// lontano c'e' un rapporto di grandezza che l'occhio legge come distanza.
///
/// La profondita' e' quella che `ParallaxController` gia' usa per il cosmo, e
/// non una scala nuova: il piano vicino corre piu' del lontano, come le stelle
/// dietro.
enum ProfonditaDelVolto {
  vicino(0.26, 96.0),
  medio(0.17, 78.0),
  fondo(0.10, 62.0);

  const ProfonditaDelVolto(this.depth, this.larghezza);

  /// La profondita' per `ParallaxController.layerOffset`.
  final double depth;

  /// La larghezza del ritratto su questo piano, in punti logici.
  ///
  /// **Nessuna scende sotto 48**, che e' il bersaglio minimo del dito: il piu'
  /// lontano sta a 62, cioe' con margine.
  final double larghezza;
}

/// Dove sta un ritratto nel cielo, e su quale piano.
class PostoNelCielo {
  const PostoNelCielo({
    required this.vip,
    required this.profondita,
    required this.centro,
  });

  final Vip vip;
  final ProfonditaDelVolto profondita;

  /// Il centro del ritratto, in punti logici dentro il cielo.
  final Offset centro;

  Rect get riquadro {
    final l = profondita.larghezza;
    final h = l / kRapportoDelRitratto;
    return Rect.fromCenter(center: centro, width: l, height: h);
  }
}

/// Il rapporto del ritratto, largo su alto. E' quello della cornice VIP.
const double kRapportoDelRitratto = 0.78;

/// LA DISPOSIZIONE DEL CIELO, calcolata e non disegnata a mano.
///
/// **E' deterministica, e non e' un dettaglio.** Un cielo che si ridispone a
/// ogni apertura sarebbe impossibile da ritrovare: chi ha visto Rihanna in
/// alto a destra la cerca li' il giorno dopo. La posizione nasce dall'indice
/// nel catalogo, quindi due aperture danno lo stesso cielo, e una prova puo'
/// misurarlo.
class DisposizioneDelCielo {
  const DisposizioneDelCielo._();

  /// Quante colonne, alla larghezza di riferimento.
  static const int colonne = 3;

  /// L'altezza di una fila, in punti logici.
  static const double altezzaDellaFila = 132;

  /// Lo scarto massimo dal centro della cella, in punti: e' cio' che toglie
  /// alla scena l'aria della griglia senza farne un mucchio.
  static const double scartoMassimo = 22;

  /// L'altezza del cielo per un dato numero di volti.
  static double altezzaPer(int quanti) =>
      ((quanti + colonne - 1) ~/ colonne) * altezzaDellaFila +
      SpacingTokens.xl;

  /// I posti dei volti, dentro un cielo largo [larghezza].
  ///
  /// **Ogni fila porta uno di ciascun piano**, e non e' un caso: se i piani
  /// si raggruppassero, meta' schermo si muoverebbe a una velocita' e meta'
  /// a un'altra, e la parallasse diventerebbe una faglia invece che una
  /// profondita'.
  static List<PostoNelCielo> per(List<Vip> vips, double larghezza) {
    final passo = larghezza / colonne;
    final posti = <PostoNelCielo>[];
    for (var i = 0; i < vips.length; i++) {
      final riga = i ~/ colonne;
      final colonna = i % colonne;
      // Il piano ruota con la posizione, cosi' ogni fila li ha tutti e tre e
      // due volti vicini non stanno mai sullo stesso piano.
      final piano = ProfonditaDelVolto
          .values[(i + riga) % ProfonditaDelVolto.values.length];
      // Lo scarto e' pseudocasuale ma DETERMINISTICO: nasce dall'indice con
      // una funzione di dispersione, non da un generatore con un seme.
      final dx = _scarto(i * 2 + 1) * scartoMassimo;
      final dy = _scarto(i * 2 + 2) * scartoMassimo;
      posti.add(PostoNelCielo(
        vip: vips[i],
        profondita: piano,
        centro: Offset(
          (passo * (colonna + 0.5) + dx).clamp(
              piano.larghezza / 2 + 4, larghezza - piano.larghezza / 2 - 4),
          // **ANCHE IN ALTO SI TRATTIENE, e la prima stesura non lo faceva.**
          // Lo scarto verticale della prima fila portava il ritratto sopra il
          // bordo del cielo, a meno quindici punti: fuori dal riquadro il
          // tocco non arriva e mezzo volto si taglia. Trovato dalla prova che
          // conta i riquadri, non guardando.
          (altezzaDellaFila * (riga + 0.5) + dy).clamp(
              _mezzaAltezzaDi(piano) + 4,
              altezzaPer(vips.length) - _mezzaAltezzaDi(piano) - 4),
        ),
      ));
    }
    return posti;
  }

  /// Mezza altezza del ritratto su quel piano, nome e didascalia compresi.
  static double _mezzaAltezzaDi(ProfonditaDelVolto piano) =>
      piano.larghezza / kRapportoDelRitratto / 2;

  /// Un numero fra -1 e 1, sempre lo stesso per lo stesso indice.
  static double _scarto(int i) {
    // Dispersione a moltiplicatore, la stessa famiglia dei semi FNV gia' in
    // uso nel progetto: niente casualita', solo aritmetica.
    final x = math.sin(i * 12.9898) * 43758.5453;
    return (x - x.floor()) * 2 - 1;
  }
}

/// IL CIELO DEI VOLTI. Ordine BO voce 05.
///
/// **La galleria non e' piu' una lista.** Era una `SliverGrid` di mattonelle
/// tutte uguali, ferme, con un rapporto fisso: cinquanta ritratti messi in
/// fila come un catalogo di prodotti. Adesso i volti stanno sospesi su tre
/// profondita' e si muovono con la parallasse gia' esistente, quella del
/// cosmo: inclinando il telefono i piani scorrono l'uno sull'altro.
///
/// **Con Riduci Movimento la parallasse e' ferma e la disposizione resta.** Non
/// si torna alla griglia: chi ha tolto le animazioni non ha chiesto un'altra
/// app, ha chiesto che non si muova.
class CieloDeiVolti extends StatelessWidget {
  const CieloDeiVolti({
    super.key,
    required this.vips,
    required this.larghezza,
    required this.palette,
    required this.onApri,
  });

  final List<Vip> vips;

  /// **LA LARGHEZZA ARRIVA DA FUORI, e non da un `LayoutBuilder`.**
  ///
  /// La prima stesura la chiedeva a un `LayoutBuilder`, ed e' costato un
  /// difetto misurato: a **ogni fotogramma di parallasse** quel render object
  /// veniva marcato da rilayoutare, quindi la disposizione dei cinquanta
  /// volti si ricalcolava sessanta volte al secondo per una larghezza che non
  /// era cambiata. Trovato dalla prova che conta i rilayout, non guardando.
  /// La larghezza la sa gia' chi monta il cielo: gliela si chiede.
  final double larghezza;

  final MaestroPalette palette;
  final void Function(Vip) onApri;

  @override
  Widget build(BuildContext context) {
    final riduciMovimento = MediaQuery.of(context).disableAnimations;
    final posti = DisposizioneDelCielo.per(vips, larghezza);
    return SizedBox(
      key: const Key('sinastria_cielo_dei_volti'),
      width: larghezza,
      height: DisposizioneDelCielo.altezzaPer(vips.length),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // I piani si montano dal piu' LONTANO al piu' vicino, cosi' quando
          // due ritratti si sfiorano quello davanti sta davvero davanti.
          for (final piano in ProfonditaDelVolto.values.reversed)
            for (final posto in posti)
              if (posto.profondita == piano)
                _VoltoSospeso(
                  key: Key('vip_${posto.vip.name}'),
                  posto: posto,
                  palette: palette,
                  fermo: riduciMovimento,
                  onTap: () => onApri(posto.vip),
                ),
        ],
      ),
    );
  }
}

class _VoltoSospeso extends StatelessWidget {
  const _VoltoSospeso({
    super.key,
    required this.posto,
    required this.palette,
    required this.fermo,
    required this.onTap,
  });

  final PostoNelCielo posto;
  final MaestroPalette palette;
  final bool fermo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final r = posto.riquadro;
    final figura = _figura(context);
    if (fermo) {
      return Positioned(left: r.left, top: r.top, width: r.width, child: figura);
    }
    // **IL POSTO STA FERMO, SI MUOVE IL DISEGNO. E' la differenza fra undici
    // millesimi per fotogramma e uno e mezzo.**
    //
    // La prima stesura spostava il volto cambiando `left` e `top` del
    // `Positioned`: ogni inclinazione faceva rifare il LAYOUT dello Stack con
    // cinquanta figli, e ridipingere cinquanta ombre sfocate. Misurato:
    // 11,5 millesimi per fotogramma, contro gli otto che il budget concede.
    //
    // Adesso il `Positioned` non si muove mai e lo scarto passa da un
    // `Transform`, che tocca solo la fase di disegno; sotto, un
    // `RepaintBoundary` tiene in cache il ritratto con la sua ombra, cosi'
    // muovere un volto vuol dire ricomporre una texture gia' pronta invece di
    // rifare la sfocatura. Il tocco segue il `Transform` per costruzione,
    // quindi il bersaglio resta dov'e' il volto e non dov'era.
    //
    // **Il `Selector` ridisegna questo ritratto soltanto quando lo scarto del
    // SUO piano cambia**: gli altri quarantanove non si toccano.
    return Positioned(
      left: r.left,
      top: r.top,
      width: r.width,
      child: Selector<ParallaxController, Offset>(
        selector: (_, p) => p.layerOffset(posto.profondita.depth),
        builder: (context, scarto, child) =>
            Transform.translate(offset: scarto, child: child),
        child: RepaintBoundary(child: figura),
      ),
    );
  }

  Widget _figura(BuildContext context) {
    final vip = posto.vip;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: kRapportoDelRitratto,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
                border: Border.all(
                    color: palette.gold.withValues(
                        alpha: 0.25 + posto.profondita.depth)),
                boxShadow: [
                  BoxShadow(
                    color: palette.deepest.withValues(alpha: 0.55),
                    blurRadius: 10 + posto.profondita.depth * 20,
                    offset: Offset(0, 3 + posto.profondita.depth * 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
                child: vip.hasImage
                    // **LA MINIATURA E NON IL RITRATTO PIENO.** Cinquanta
                    // ritratti pieni in scena sarebbero un ordine di grandezza
                    // di memoria in piu' della lista di prima: qui si carica
                    // esattamente lo stesso asset che la griglia caricava.
                    ? Image.asset(vip.thumbPath!,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(
                            Icons.auto_awesome,
                            color: palette.goldSoft,
                            size: 24))
                    : Icon(Icons.auto_awesome,
                        color: palette.goldSoft, size: 24),
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.xxs),
          Text(
            vip.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TypographyTokens.didascalia().copyWith(
                color: palette.goldSoft
                    .withValues(alpha: 0.55 + posto.profondita.depth)),
          ),
        ],
      ),
    );
  }
}
