import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// **LO STUDIO DI MEDORA**, la scena della Sinastria approfondita. Ordine
/// FT voce FT.02, 14 ottobre 2026.
///
/// **Stesso lavoro della Stesa** (il fondatore, 13 ottobre 2026: "vorrei
/// fare lo stesso lavoro che abbiamo fatto per animare lo sfondo dei
/// tarocchi e cosi' faremo per ogni funzionalita'"), misurato allo stesso
/// modo (ordine FS voce A2): lo sfondo e' `studio_di_medora_v1.webp`
/// (688x1536), Medora e' una delle due pose scontornate quando la scena e'
/// ferma, il video `medora_astrolabio_in_polvere_v1.mp4` (720x1280) prende
/// il suo posto quando parte, nello stesso riquadro dello sfondo.
///
/// **Non c'e' un tavolo da carte qui**: la Sinastria approfondita non
/// dispone carte sul piano come il Tarocchi, quindi questa scena non ha
/// l'omografia ne' il piano piatto di `GeometriaDelTavolo`: solo lo sfondo,
/// la posa (o il video) di Medora, e il posto per il contenuto della
/// lettura sotto di lei.
class GeometriaDelloStudio {
  const GeometriaDelloStudio._();

  static const String sfondo = 'assets/img/sinastria/studio_di_medora_v1.webp';

  /// **LE DUE POSE DI MEDORA**, il primo e l'ultimo fotogramma del video,
  /// scontornate con `tool/scontorna_le_pose_della_sinastria.py` (FT.01):
  /// con l'astrolabio, finche' il video non comincia; a mani aperte (la
  /// polvere d'oro gia' sparsa), quando la scena e' ferma (Riduci
  /// Movimento, o un video che non si carica).
  static const String posaDellAstrolabio =
      'assets/img/sinastria/medora_astrolabio_v1.webp';
  static const String posaDelleManiAperte =
      'assets/img/sinastria/medora_mani_aperte_v1.webp';

  /// Le misure dell'immagine di sfondo e delle due pose, in pixel.
  static const Size immagine = Size(688, 1536);
  static const Size immagineDiMedora = Size(1120, 960);

  /// **IL TAGLIO DELLA SCENA**: dal pixel 0 al 1223 (un taglio 9 a 16, come
  /// quello su cui l'Architetto ha composto i due fotogrammi di riferimento,
  /// `docs/collaudo/FT/riferimenti/`), a tutta larghezza. A differenza del
  /// tavolo della Stesa, qui non si nasconde nessuna volta vuota in cima: la
  /// composizione tiene le candele, il telescopio e l'arco della finestra
  /// gia' dentro il taglio.
  ///
  /// **MISURATO, non supposto** (come FS voce A2): `video_ultimo_
  /// fotogramma.png` (il fotogramma consegnato dall'Architetto, 720x1280)
  /// allineato a `studio_di_medora_v1.webp` con ORB e RANSAC (251 punti
  /// buoni su 300), scala 1,04654, il riquadro risulta dal pixel -0,04 al
  /// 1223,1, a tutta larghezza (688). Misure in
  /// `docs/collaudo/FT/ft02_allineamento.txt`.
  static const double taglioInAlto = 0;
  static const double taglioInBasso = 1223;

  static const double altoDelTaglio = taglioInBasso - taglioInAlto;

  /// La scala: punti logici per pixel dell'immagine, a larghezza [w].
  static double scala(double w) => w / immagine.width;

  /// L'altezza della scena a larghezza [w].
  static double altezza(double w) => altoDelTaglio * scala(w);

  /// **IL RETTANGOLO DI MEDORA**, in pixel dell'immagine di sfondo, con
  /// entrambe le pose: misurato con lo stesso metodo ORB/RANSAC, allineando
  /// ciascuna posa (dal commit del fondatore, sfondo bianco) al suo
  /// fotogramma di riferimento composto (`composizione_primo_fotogramma.png`
  /// e `composizione_ultimo_fotogramma.png`), poi riportato nelle coordinate
  /// dello sfondo con la stessa trasformazione del taglio. Le due pose
  /// convergono sullo stesso rettangolo **a meno di due decimi di pixel**
  /// (astrolabio: 47,06-392,21 a 639,85-899,71; mani aperte: 47,17-392,08 a
  /// 639,69-899,84), come le due pose della Stesa: qui il rettangolo medio.
  static const Rect medoraNellImmagine =
      Rect.fromLTRB(47.1, 392.1, 639.8, 899.8);

  /// Il rettangolo di Medora nella scena, a larghezza [w].
  static Rect medora(double w) {
    final s = scala(w);
    return Rect.fromLTWH(
      medoraNellImmagine.left * s,
      medoraNellImmagine.top * s,
      medoraNellImmagine.width * s,
      medoraNellImmagine.height * s,
    );
  }
}

/// **IL VIDEO DELLA SCENA DELLA SINASTRIA.** Ordine FT voce FT.02.
class ScenaDellaSinastriaInVideo {
  const ScenaDellaSinastriaInVideo._();

  static const String _dentro = 'brand_assets';
  static const String _dove = 'sinastria';
  static const String _file = 'medora_astrolabio_in_polvere_v1.mp4';

  /// Il filmato del fondatore: 720 per 1280, 24 fotogrammi al secondo, 192
  /// fotogrammi, 8,000 secondi, con l'audio. L'impronta sta in
  /// `docs/stato_asset.json`.
  static const String filmato = '$_dentro/$_dove/$_file';

  static const Size misura = Size(720, 1280);
  static const int fotogrammi = 192;
  static const Duration durata =
      Duration(microseconds: fotogrammi * 1000000 ~/ 24);

  /// **IL RIQUADRO DEL FILMATO NELLO SFONDO**, uguale al taglio della scena
  /// ([GeometriaDelloStudio.taglioInAlto]..[taglioInBasso]): a differenza
  /// del tavolo della Stesa, qui le due cose coincidono, quindi il video
  /// riempie l'intera scena senza un offset suo.
  static const double sopra = GeometriaDelloStudio.taglioInAlto;
  static const double sotto = GeometriaDelloStudio.taglioInBasso;

  /// Il rettangolo del filmato nella scena larga [w].
  static Rect nellaScena(double w) {
    final s = GeometriaDelloStudio.scala(w);
    return Rect.fromLTWH(0, (sopra - GeometriaDelloStudio.taglioInAlto) * s,
        w, (sotto - sopra) * s);
  }
}

/// **IL LETTORE DELLA SCENA DELLA SINASTRIA, dietro una porta sola.** Stessa
/// forma di `LettoreDellaScena` del Tarocchi (`la_scena_della_stesa_in_
/// video.dart`): una finta ne prende il posto nelle prove headless, e chi lo
/// implementa promette di non lanciare mai.
abstract class LettoreDellaScenaSinastria {
  factory LettoreDellaScenaSinastria.vero() = _LettoreDellaScenaSinastriaVero;

  Future<void> apri();
  bool get pronto;
  bool get fallito;
  bool get cominciato;
  bool get finito;
  void ascolta(VoidCallback? quandoCambia);
  Future<void> volume(double quanto);
  Future<void> avvia();
  Future<void> sospendi();
  Widget disegna();
  void chiudi();
}

typedef FabbricaDellaScenaSinastria = LettoreDellaScenaSinastria Function();

class _LettoreDellaScenaSinastriaVero implements LettoreDellaScenaSinastria {
  _LettoreDellaScenaSinastriaVero();

  VideoPlayerController? _c;
  AppLifecycleListener? _ciclo;
  VoidCallback? _quandoCambia;
  bool _pronto = false;
  bool _fallito = false;
  bool _cominciato = false;
  bool _finito = false;

  @override
  bool get pronto => _pronto;
  @override
  bool get fallito => _fallito;
  @override
  bool get cominciato => _cominciato;
  @override
  bool get finito => _finito;

  @override
  void ascolta(VoidCallback? quandoCambia) => _quandoCambia = quandoCambia;

  @override
  Future<void> apri() async {
    // **MESCOLATO AGLI ALTRI SUONI**, come il lettore della Stesa: senza
    // `mixWithOthers` il video chiede il fuoco esclusivo e su Android ferma
    // la musica di chi ascolta altro (ordine CN).
    final c = VideoPlayerController.asset(ScenaDellaSinastriaInVideo.filmato,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true));
    _c = c;
    try {
      await c.initialize();
      if (!identical(_c, c)) return;
      await c.setVolume(0);
      await c.setLooping(false);
      c.addListener(_guarda);
      _ciclo = AppLifecycleListener(
        onHide: () => c.pause().catchError((Object errore) {
          debugPrint('Il filmato della scena della Sinastria non si ferma: '
              '$errore');
        }),
      );
      _pronto = true;
    } catch (errore) {
      debugPrint('Il filmato della scena della Sinastria non si prepara, la '
          'scena resta ferma: $errore');
      _fallito = true;
    }
    _quandoCambia?.call();
  }

  void _guarda() {
    final c = _c;
    if (c == null) return;
    final v = c.value;
    var cambiato = false;
    if (!_cominciato && v.position > Duration.zero) {
      _cominciato = true;
      cambiato = true;
    }
    if (!_finito &&
        v.isInitialized &&
        v.duration > Duration.zero &&
        (v.isCompleted || v.position >= v.duration)) {
      _finito = true;
      cambiato = true;
    }
    if (v.hasError && !_fallito) {
      _fallito = true;
      cambiato = true;
    }
    if (cambiato) _quandoCambia?.call();
  }

  @override
  Future<void> volume(double quanto) async {
    try {
      await _c?.setVolume(quanto.clamp(0.0, 1.0).toDouble());
    } catch (errore) {
      debugPrint('Il volume della scena della Sinastria non cambia: $errore');
    }
  }

  @override
  Future<void> avvia() async {
    if (_finito) return;
    try {
      await _c?.play();
    } catch (errore) {
      debugPrint('Il filmato della scena della Sinastria non parte: $errore');
    }
  }

  @override
  Future<void> sospendi() async {
    try {
      await _c?.pause();
    } catch (errore) {
      debugPrint('Il filmato della scena della Sinastria non si ferma: '
          '$errore');
    }
  }

  /// `BoxFit.fill`: il riquadro ha gia' quasi esattamente la proporzione del
  /// filmato (688 su 1223 contro 720 su 1280).
  @override
  Widget disegna() {
    final c = _c;
    if (c == null) return const SizedBox.shrink();
    return FittedBox(
      fit: BoxFit.fill,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: c.value.size.width,
        height: c.value.size.height,
        child: VideoPlayer(c),
      ),
    );
  }

  @override
  void chiudi() {
    final c = _c;
    _c = null;
    _quandoCambia = null;
    _ciclo?.dispose();
    _ciclo = null;
    if (c == null) return;
    c.removeListener(_guarda);
    c.pause().catchError((Object _) {});
    c.dispose().catchError((Object _) {});
  }
}

/// **LA SCENA**: lo sfondo tagliato e Medora, ferma o nel video.
///
/// Non porta carte ne' un piano: la Sinastria approfondita mostra qui solo
/// la scena, e il contenuto della lettura sta sotto, nella schermata che la
/// monta (come "Scegli la tua stesa" sta sotto il tavolo della Stesa).
class LoStudioDiMedora extends StatelessWidget {
  const LoStudioDiMedora({
    super.key,
    this.posa = GeometriaDelloStudio.posaDelleManiAperte,
    this.filmato,
  });

  /// La posa di Medora quando la scena e' ferma.
  final String posa;

  /// Il video della scena, quando e' cominciato: prende il posto dello
  /// sfondo e di Medora ferma. Nullo, la scena ferma.
  final Widget? filmato;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, vincoli) {
      final w = vincoli.maxWidth;
      final s = GeometriaDelloStudio.scala(w);
      final alta = GeometriaDelloStudio.altezza(w);
      final medora = GeometriaDelloStudio.medora(w);
      return SizedBox(
        width: w,
        height: alta,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              top: 0,
              width: w,
              height: alta,
              child: ClipRect(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: OverflowBox(
                        alignment: Alignment.topLeft,
                        minWidth: w,
                        maxWidth: w,
                        minHeight: GeometriaDelloStudio.immagine.height * s,
                        maxHeight: GeometriaDelloStudio.immagine.height * s,
                        child: Transform.translate(
                          offset: Offset(
                              0, -GeometriaDelloStudio.taglioInAlto * s),
                          child: Image.asset(GeometriaDelloStudio.sfondo,
                              key: const Key('studio_sfondo'),
                              fit: BoxFit.fill,
                              filterQuality: FilterQuality.medium),
                        ),
                      ),
                    ),
                    // IL VIDEO, sopra lo sfondo, stessa tecnica dello
                    // sfondo (`OverflowBox` piu' `Transform.translate`, mai
                    // un `Positioned` col top negativo: FS voce 14, la
                    // banda vista sul telefono quando il video partiva gia'
                    // spostato in alto di un top negativo contro il bordo
                    // del `ClipRect`).
                    if (filmato != null)
                      Positioned.fill(
                        child: OverflowBox(
                          alignment: Alignment.topLeft,
                          minWidth: w,
                          maxWidth: w,
                          minHeight: (ScenaDellaSinastriaInVideo.sotto -
                                  ScenaDellaSinastriaInVideo.sopra) *
                              s,
                          maxHeight: (ScenaDellaSinastriaInVideo.sotto -
                                  ScenaDellaSinastriaInVideo.sopra) *
                              s,
                          child: Transform.translate(
                            offset: Offset(
                                0,
                                (ScenaDellaSinastriaInVideo.sopra -
                                        GeometriaDelloStudio.taglioInAlto) *
                                    s),
                            child: SizedBox(
                              key: const Key('studio_filmato'),
                              width: w,
                              height: (ScenaDellaSinastriaInVideo.sotto -
                                      ScenaDellaSinastriaInVideo.sopra) *
                                  s,
                              child: filmato!,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (filmato == null)
              Positioned.fromRect(
                rect: medora,
                child: Image.asset(posa,
                    key: const Key('studio_medora'),
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.medium),
              ),
          ],
        ),
      );
    });
  }
}
