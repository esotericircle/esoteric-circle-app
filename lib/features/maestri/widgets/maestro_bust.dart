import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/maestro/maestro.dart';
import '../../../core/quality/quality_tier.dart';
import '../../../design_system/theme/maestro_palette.dart';

/// Punto del volto di un Maestro, in coordinate normalizzate 0..1 sull'immagine
/// intera dell'avatar (origine in alto a sinistra). Misurato sugli asset reali.
@immutable
class MaestroFacePoint {
  const MaestroFacePoint({
    required this.centerX,
    required this.headTopY,
    required this.collarY,
  });

  /// Ascissa del centro del volto, frazione della larghezza.
  final double centerX;

  /// Ordinata della sommita' del capo, frazione dell'altezza.
  final double headTopY;

  /// Ordinata della linea del collo, frazione dell'altezza.
  final double collarY;
}

/// L'inquadratura calcolata del volto dentro il cerchio, in pixel logici. Tutti
/// i valori scalano in proporzione al diametro dell'anello, cosi' header, lente
/// e bolla mostrano lo stesso identico taglio a misure diverse.
@immutable
class BustFraming {
  const BustFraming({
    required this.imageHeight,
    required this.verticalOffset,
    required this.faceDx,
    required this.boxHeight,
    required this.bandTop,
    required this.bandBottom,
  });

  /// Altezza a cui disegnare l'immagine intera dell'avatar.
  final double imageHeight;

  /// Traslazione verticale dell'immagine, dopo l'allineamento in alto.
  final double verticalOffset;

  /// Correzione orizzontale, frazione della larghezza dell'immagine, per portare
  /// il centro del volto al centro del cerchio.
  final double faceDx;

  /// Altezza del riquadro del widget: il diametro piu' lo spazio sopra l'anello
  /// dove la testa sporge.
  final double boxHeight;

  /// Ordinata della sommita' del capo nel riquadro.
  final double bandTop;

  /// Ordinata della linea del collo nel riquadro.
  final double bandBottom;
}

/// Il volto del Maestro che rompe il cerchio, in chiave 2.5D.
///
/// L'inquadratura non usa piu' una frazione di ritaglio unica sui tre avatar,
/// che dava tagli incoerenti (a volte i soli occhi, a volte la figura intera),
/// ma un punto del volto misurato per Maestro (`MaestroBust.facePoints`) piu' una
/// regola indipendente dalla dimensione: la fascia dal capo al collo riempie
/// circa l'80 per cento del diametro del cerchio, centrata sul centro del volto.
/// Cosi' il taglio e' identico in header, lente e bolla, cambia solo la misura e
/// se la testa sporge sopra l'anello o resta contenuta nel tondo.
///
/// Con [popOut] vero (header e lente) la sommita' del capo esce appena sopra
/// l'anello; con [popOut] falso (bolla della chat) lo stesso volto resta tutto
/// dentro il cerchio, senza sporgenza.
///
/// Robustezza: il volto e' un `Image` con `errorBuilder`, lo stesso schema
/// solido della bolla, quindi si disegna appena l'immagine e' decodificata.
/// L'icona lineare di riferimento compare solo se l'`errorBuilder` scatta per un
/// asset davvero mancante, mai come fondale e mai durante il caricamento.
///
/// Movimento: il cenno di speaking fa pulsare l'aura. Con Riduci Movimento o su
/// Quality Tier basso la presenza resta statica.
class MaestroBust extends StatefulWidget {
  const MaestroBust({
    super.key,
    required this.maestro,
    this.ring = 44,
    this.popOut = true,
    this.speaking = false,
    this.image,
  });

  final Maestro maestro;

  /// Diametro dell'anello alla base.
  final double ring;

  /// Vero: la testa sporge appena sopra l'anello (header, lente). Falso: il
  /// volto resta contenuto nel tondo (bolla), stesso taglio, senza sporgenza.
  final bool popOut;

  /// Quando vero, l'aura pulsa: il cenno di speaking mentre il Maestro risponde.
  final bool speaking;

  /// Sorgente dell'immagine. In produzione resta null e si usa l'avatar del
  /// Maestro; i test possono iniettare un provider che fallisce o che dipinge.
  final ImageProvider? image;

  /// Dove sta il volto dentro l'asset, in frazioni della sua tela: la cima
  /// della testa, la linea del colletto e il centro orizzontale del viso.
  ///
  /// **Sono tre numeri in codice che descrivono un fatto dell'immagine, quindi
  /// scadono quando l'immagine cambia.** E' successo il 5 agosto 2026: gli
  /// avatar sono stati rigenerati su una tela nuova, con le tre figure portate
  /// alla stessa altezza e i piedi sulla stessa linea, e queste frazioni sono
  /// diventate false da un momento all'altro senza che niente diventasse
  /// rosso. Ora le sorveglia `test/facce_dentro_la_figura_test.dart`: chi
  /// rigenera un avatar con un'inquadratura diversa da quella dichiarata qui
  /// sotto trova una prova rossa invece di un volto storto.
  ///
  /// **Quello che la prova NON promette**, misurato e non supposto: chiedere
  /// soltanto che la fascia cada dentro la figura non basta. Rimettendo queste
  /// frazioni ai valori di prima sugli asset di oggi, quel controllo passa
  /// verde, perche' anche le frazioni sbagliate cadono dentro la figura. E'
  /// per questo che accanto c'e' l'inquadratura di riferimento, ed e' quella
  /// il vero legame fra questi numeri e le immagini.
  ///
  /// **Come sono stati trovati questi numeri, il 6 agosto 2026.** Non leggendo
  /// l'asset con una griglia sovrapposta, che era il metodo del giorno prima e
  /// ha sbagliato due Maestri su tre: misurando il RISULTATO. Il tondo viene
  /// disegnato davvero, l'immagine catturata, e sui suoi pixel si misurano due
  /// cose, quanto la testa riempie la corda del cerchio e di quanto e'
  /// scentrata. Poi si correggono le frazioni finche' i tre non coincidono. Il
  /// conto lo fa e lo sorveglia `test/il_volto_nel_tondo_test.dart`.
  ///
  /// Il riferimento e' Medora, giudicata giusta a video da Mauro. Prima della
  /// correzione la testa di Caligo riempiva il 43,3 per cento della corda
  /// contro il 49,7 di Medora, e quella di Aura il 37,2; Aura era anche
  /// spostata a destra di 5,4 punti, con una fascia di fondo verde vuota a
  /// sinistra. Dopo: riempimento 48,6 e 47,4, scarti -1,0 e -0,1 contro il
  /// -0,9 di Medora.
  ///
  /// **Il `centerX` di Aura era sbagliato dall'inizio, non per colpa della
  /// riduzione della tela.** Misurato: il centro della sua figura nella fascia
  /// del volto vale 0,5003 sull'asset vecchio e 0,4999 su quello nuovo, quattro
  /// decimillesimi di scarto, cioe' rumore di ricampionamento. Una frazione
  /// della larghezza non cambia sotto una scalatura orizzontale. Il valore
  /// dichiarato era 0,49 in entrambi i casi, ed e' rimasto falso per mesi
  /// perche' nessuno aveva mai messo i tre tondi uno accanto all'altro.
  ///
  /// **Le fasce sono diverse fra loro di proposito.** `collarY` meno
  /// `headTopY` non dice dove sta la testa, dice quanto e' grande, e le tre
  /// teste sono disegnate di taglie diverse: nella tela da 1700 px quella di
  /// Caligo misura circa 258 px, quella di Medora 238, quella di Aura 221. Una
  /// fascia stretta ingrandisce il volto nel tondo, una larga lo
  /// rimpicciolisce.
  static const Map<Maestro, MaestroFacePoint> facePoints = {
    Maestro.medora:
        MaestroFacePoint(centerX: 0.50, headTopY: 0.015, collarY: 0.243),
    Maestro.aura:
        MaestroFacePoint(centerX: 0.5018, headTopY: 0.030, collarY: 0.258),
    Maestro.caligo:
        MaestroFacePoint(centerX: 0.4968, headTopY: 0.013, collarY: 0.241),
  };

  /// L'INQUADRATURA A CUI I `facePoints` APPARTENGONO.
  ///
  /// Le frazioni qui sopra hanno senso solo dentro una precisa inquadratura
  /// degli asset: questa tela, e la figura che va da questa riga a quest'altra.
  /// Cambiala e quelle frazioni indicano un altro punto dell'immagine, senza
  /// che niente lo dica.
  ///
  /// Dichiararla qui e' quello che rende il legame verificabile: una prova
  /// confronta questi quattro numeri con gli asset veri, e se qualcuno
  /// rigenera un avatar con un'inquadratura diversa la prova cade prima che il
  /// volto storto arrivi a video. E' il motivo per cui non basta chiedere che
  /// la fascia stia "dentro la figura": le frazioni vecchie del 5 agosto 2026
  /// cadevano ancora dentro la figura nuova, e sarebbero passate.
  static const int faceRefTela = 1142;
  static const int faceRefTelaAltezza = 1700;
  static const int faceRefFiguraCima = 21;
  static const int faceRefFiguraPiedi = 1679;

  /// Quanta parte del diametro riempie la fascia dichiarata, che va dalla
  /// cima della testa al petto.
  ///
  /// **Nel tondo si vede dal petto alla testa intera, e tutto sta dentro il
  /// cerchietto.** Regola di Mauro del 6 agosto 2026, arrivata dopo due
  /// tentativi sbagliati: con 0,8 la sola testa mangiava quattro quinti del
  /// cerchio; con 0,58 e la testa che usciva sopra, a Caligo veniva tagliata.
  /// A 0,95 la fascia riempie quasi tutto il diametro, quindi il petto arriva
  /// al bordo basso e il capo resta appena dentro quello alto.
  ///
  /// L'unica cosa che puo' restare fuori e' un pezzetto della corona di Aura,
  /// che sale sopra la testa e rende la sua immagine piu' alta delle altre.
  static const double kBandOfDiameter = 0.95;

  /// Spazio sopra l'anello, in frazione del diametro, dove la testa sporge.
  static const double kTopPad = 0.0;

  /// Di quanto la sommita' del capo resta sotto il bordo dell'anello.
  ///
  /// Lo stesso valore nei due casi: **nessuno sborda piu'**. Prima
  /// `kCrestOut` era positivo e faceva uscire la testa sopra il cerchio in
  /// header e lente, dando due tagli diversi dello stesso ritratto. Il taglio
  /// e' uno solo, e il parametro `popOut` non cambia piu' l'inquadratura.
  static const double kCrestOut = -0.03;
  /// Nella bolla la testa non puo' uscire, quindi resta un filo sotto il
  /// bordo: a zero il cerchio le rasava la sommita' del capo.
  static const double kCrestIn = -0.03;

  /// Calcola l'inquadratura per un Maestro a un dato diametro. E' la regola
  /// dell'inquadratura, in un punto solo, cosi' i test la verificano e il build
  /// la usa senza divergere. Tutti i valori scalano linearmente col diametro.
  static BustFraming framingFor({
    required Maestro maestro,
    required double ring,
    required bool popOut,
  }) {
    final p = facePoints[maestro]!;
    final band = p.collarY - p.headTopY;
    final imageHeight = kBandOfDiameter * ring / band;
    final topPad = popOut ? kTopPad * ring : 0.0;
    final boxHeight = ring + topPad;
    final ringTopY = topPad;
    final crest = (popOut ? kCrestOut : kCrestIn) * ring;
    final bandTop = ringTopY - crest;
    final verticalOffset = bandTop - p.headTopY * imageHeight;
    final bandBottom = verticalOffset + p.collarY * imageHeight;
    return BustFraming(
      imageHeight: imageHeight,
      verticalOffset: verticalOffset,
      faceDx: 0.5 - p.centerX,
      boxHeight: boxHeight,
      bandTop: bandTop,
      bandBottom: bandBottom,
    );
  }

  @override
  State<MaestroBust> createState() => _MaestroBustState();
}

class _MaestroBustState extends State<MaestroBust>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );

  /// Vero solo quando l'immagine dell'avatar ha fallito il caricamento, saputo
  /// dall'`errorBuilder`. Allora si mostra l'icona di ripiego. Mai come fondale,
  /// mai durante il caricamento.
  bool _failed = false;

  ImageProvider get _provider =>
      widget.image ?? AssetImage(widget.maestro.avatarAsset);

  @override
  void didUpdateWidget(MaestroBust oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.maestro != widget.maestro || oldWidget.image != widget.image) {
      _failed = false;
    }
  }

  void _markFailed() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_failed) setState(() => _failed = true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(ThemeKey.of(widget.maestro));
    final tier = context.watch<QualityTierController>().tier;
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final motion = !reduceMotion && tier != QualityTier.low;
    final pulsa = widget.speaking && motion;
    if (pulsa && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!pulsa && _controller.isAnimating) {
      _controller
        ..stop()
        ..value = 0;
    }

    final ring = widget.ring;
    final framing = MaestroBust.framingFor(
      maestro: widget.maestro,
      ring: ring,
      popOut: widget.popOut,
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final pulse = pulsa ? _controller.value : 0.0;
        return SizedBox(
          width: ring,
          height: framing.boxHeight,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              // L'anello alla base, con l'aura che pulsa. L'icona di ripiego vive
              // qui, ma solo quando l'immagine ha fallito davvero.
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: ring,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: palette.primary.withValues(alpha: 0.5),
                    border: Border.all(
                      color: palette.gold.withValues(alpha: 0.6 + 0.3 * pulse),
                      width: 1.4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            palette.glow.withValues(alpha: 0.25 + 0.45 * pulse),
                        blurRadius: 8 + 14 * pulse,
                        spreadRadius: 1 + 3 * pulse,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: _failed
                      ? Icon(
                          widget.maestro.icon,
                          key: Key('maestro_bust_icon_${widget.maestro.id}'),
                          color: palette.goldSoft,
                          size: ring * 0.44,
                        )
                      : null,
                ),
              ),
              // L'ombra di contatto: una macchia morbida sotto il mento, sul
              // piano dell'anello, che stacca il volto e lo fa sporgere.
              if (!_failed && widget.popOut)
                Positioned(
                  bottom: ring * 0.36,
                  child: Container(
                    width: ring * 0.62,
                    height: ring * 0.15,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                          Radius.elliptical(ring * 0.31, ring * 0.075)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.30),
                          blurRadius: ring * 0.14,
                        ),
                      ],
                    ),
                  ),
                ),
              // Il volto inquadrato. Copre l'intero riquadro; nel popOut la testa
              // esce sopra l'anello, nella bolla resta dentro il tondo.
              if (!_failed)
                Positioned.fill(
                  child: _FaceView(
                    provider: _provider,
                    framing: framing,
                    ring: ring,
                    popOut: widget.popOut,
                    onError: _markFailed,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Disegna l'avatar inquadrato sul volto secondo [framing]. Nel popOut ritaglia
/// a rettangolo e sfuma in basso verso il collo; nella bolla ritaglia al tondo
/// dell'anello. Il centro del volto va al centro del cerchio con una traslazione
/// frazionaria, indipendente dalle proporzioni dell'immagine.
class _FaceView extends StatelessWidget {
  const _FaceView({
    required this.provider,
    required this.framing,
    required this.ring,
    required this.popOut,
    required this.onError,
  });

  final ImageProvider provider;
  final BustFraming framing;
  final double ring;
  final bool popOut;
  final VoidCallback onError;

  @override
  Widget build(BuildContext context) {
    Widget image = OverflowBox(
      alignment: Alignment.topCenter,
      minWidth: 0,
      maxWidth: double.infinity,
      minHeight: 0,
      maxHeight: double.infinity,
      child: Transform.translate(
        offset: Offset(0, framing.verticalOffset),
        child: FractionalTranslation(
          // Sposta il centro del volto al centro del cerchio, in frazione della
          // larghezza dell'immagine: aspetto-indipendente.
          translation: Offset(framing.faceDx, 0),
          child: Image(
            image: provider,
            height: framing.imageHeight,
            fit: BoxFit.fitHeight,
            alignment: Alignment.topCenter,
            filterQuality: FilterQuality.medium,
            errorBuilder: (_, __, ___) {
              onError();
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    // SEMPRE IL CERCHIO, per tutti e tre, in ogni uso.
    //
    // Regola di Mauro del 6 agosto 2026, dopo aver guardato i tondi: tutti
    // stanno dentro il cerchietto, nessuno sborda. Qui c'erano due strade, il
    // ritaglio a cerchio per la bolla e uno rettangolare con la testa che
    // usciva sopra per header e lente, e portavano a due tagli diversi dello
    // stesso ritratto: Caligo finiva con la testa tagliata. La strada e' una
    // sola, e il taglio e' lo stesso ovunque.
    //
    // Con una strada sola sparisce anche la sfumatura in basso, che serviva
    // solo a nascondere il bordo netto del ritaglio rettangolare.
    return ClipOval(child: image);
  }
}

