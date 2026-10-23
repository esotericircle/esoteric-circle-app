import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../scene/la_scena_in_video.dart';

/// **LO STUDIO DI MEDORA**, la scena della Sinastria evolutiva. Ordine
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
/// **Non c'e' un tavolo da carte qui**: la Sinastria evolutiva non
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

  /// **LA SCENA A TUTTO SCHERMO**, ordine GD voce GD.13, 23 ottobre 2026. Il
  /// fondatore: *"Video introduzione bello, ma è tagliato per fare spazio a
  /// testo e pulsante, ma perché è tagliato? Il video copre tutta l'area del
  /// telefono e sopra testi e pulsante"*. Il taglio della scena (lo stesso
  /// riquadro del video, 688 per 1223 pixel dello sfondo) copre lo schermo
  /// [schermo] come un `BoxFit.cover`: la scala e' la piu' grande delle due,
  /// e cio' che avanza si toglie in parti uguali dai due lati (a 360 per 800,
  /// quarantacinque punti per lato; sui telefoni piu' larghi che alti di
  /// 688 su 1223, in alto e in basso). Restituisce la scala in punti per
  /// pixel e l'origine del taglio sullo schermo.
  static ({double scala, Offset origine}) aTuttoSchermo(Size schermo) {
    final s = math.max(
        schermo.width / immagine.width, schermo.height / altoDelTaglio);
    return (
      scala: s,
      origine: Offset((schermo.width - immagine.width * s) / 2,
          (schermo.height - altoDelTaglio * s) / 2),
    );
  }

  /// **IL PIXEL DELLA TESTA DI MEDORA**, nello sfondo: dove la testa comincia
  /// (misurato sulla posa, 403; il rettangolo delle pose comincia a 392,1 con
  /// l'aria sopra i capelli). La domanda della GD.13 sta sopra di lui.
  static const double testaDiMedora = 403;

  /// **IL TAVOLO DI MEDORA**, ordine GD voce GD.18: il centro del piano
  /// scuro del tavolo nello sfondo (il disco fra il bordo d'oro, da 70 a 620
  /// in larghezza, da 900 a 1110 in altezza), dove la statua posa la base.
  static const Offset baseDellaStatua = Offset(345, 1045);

  /// L'altezza della statua sul tavolo, in pixel dello sfondo: dalla base
  /// fino a sotto il viso di Medora (che finisce intorno a 530), cosi' la
  /// statua e' grande e Medora resta in vista dietro di lei.
  static const double altezzaDellaStatua = 500;

  /// Il rettangolo della statua nello sfondo, per un'immagine di misura
  /// [misura] (le statue sono gia' ritagliate alla figura).
  static Rect statuaNellImmagine(Size misura) {
    final larga = altezzaDellaStatua * misura.width / misura.height;
    return Rect.fromLTWH(baseDellaStatua.dx - larga / 2,
        baseDellaStatua.dy - altezzaDellaStatua, larga, altezzaDellaStatua);
  }

  /// **LE DODICI STATUE**, una per segno della relazione: le coppie dipinte
  /// del fondatore scontornate da `tool/scontorna_le_statue_della_sinastria.py`
  /// (GD.18), con la loro misura in pixel dopo il ritaglio alla figura.
  static const Map<String, Size> statue = {
    'ariete': Size(664, 987),
    'toro': Size(682, 978),
    'gemelli': Size(693, 996),
    'cancro': Size(520, 1079),
    'leone': Size(613, 1057),
    'vergine': Size(632, 977),
    'bilancia': Size(670, 991),
    'scorpione': Size(522, 973),
    'sagittario': Size(590, 1034),
    'capricorno': Size(519, 974),
    'acquario': Size(560, 956),
    'pesci': Size(725, 936),
  };

  /// Il file della statua del segno [segno] (il nome italiano minuscolo).
  static String statua(String segno) =>
      'assets/img/sinastria/statua_${segno}_v1.webp';
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
    return Rect.fromLTWH(0, (sopra - GeometriaDelloStudio.taglioInAlto) * s, w,
        (sotto - sopra) * s);
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
/// Non porta carte ne' un piano: la Sinastria evolutiva mostra qui solo
/// la scena, e il contenuto della lettura sta sotto o sopra, nella schermata
/// che la monta.
///
/// **A TUTTO SCHERMO**, ordine GD voce GD.13: con [altezza] la scena copre
/// tutto il rettangolo largo quanto il genitore e alto [altezza], come un
/// `BoxFit.cover` ([GeometriaDelloStudio.aTuttoSchermo]); senza, e' alta
/// quanto il taglio a quella larghezza, come prima. Lo sfondo, il video,
/// Medora e la statua usano la stessa scala e la stessa origine: restano
/// allineati in ogni forma dello schermo.
///
/// **LA STATUA SUL TAVOLO**, ordine GD voce GD.18: con [statua] (il segno
/// della relazione) la figura dipinta e scontornata compare grande sul
/// tavolo di Medora, in dissolvenza quando [statuaVisibile] diventa vero.
class LoStudioDiMedora extends StatelessWidget {
  const LoStudioDiMedora({
    super.key,
    this.posa = GeometriaDelloStudio.posaDelleManiAperte,
    this.filmato,
    this.filmatoSaltato = false,
    this.altezza,
    this.statua,
    this.statuaVisibile = true,
    this.riduciMovimento = false,
  });

  /// La posa di Medora quando la scena e' ferma.
  final String posa;

  /// Il video della scena, quando e' cominciato: prende il posto dello
  /// sfondo e di Medora ferma. Nullo, la scena ferma.
  final Widget? filmato;

  /// **IL VIDEO SALTATO COL TOCCO**, ordine FU voce FU.15: il filmato sfuma
  /// e la posa ferma appare al suo posto, in dissolvenza incrociata.
  final bool filmatoSaltato;

  /// L'altezza della scena a tutto schermo (GD.13); nulla, quella del taglio.
  final double? altezza;

  /// Il segno della relazione (il nome italiano minuscolo) della statua sul
  /// tavolo (GD.18); nullo, nessuna statua.
  final String? statua;
  final bool statuaVisibile;

  /// Con Riduci Movimento la statua c'e' gia', senza dissolvenza.
  final bool riduciMovimento;

  static const Duration dissolvenzaDellaStatua = Duration(milliseconds: 900);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, vincoli) {
      final w = vincoli.maxWidth;
      final schermo = altezza;
      final double s;
      final Offset o;
      if (schermo == null) {
        s = GeometriaDelloStudio.scala(w);
        o = Offset.zero;
      } else {
        final g = GeometriaDelloStudio.aTuttoSchermo(Size(w, schermo));
        s = g.scala;
        o = g.origine;
      }
      final alta = schermo ?? GeometriaDelloStudio.altezza(w);
      Rect nelloSchermo(Rect r) => Rect.fromLTWH(
          o.dx + r.left * s, o.dy + r.top * s, r.width * s, r.height * s);
      final medora = nelloSchermo(GeometriaDelloStudio.medoraNellImmagine);
      final misuraDellaStatua =
          statua == null ? null : GeometriaDelloStudio.statue[statua];
      final altoDelFilmato =
          (ScenaDellaSinastriaInVideo.sotto - ScenaDellaSinastriaInVideo.sopra) *
              s;
      return SizedBox(
        width: w,
        height: alta,
        child: Stack(
          clipBehavior: Clip.hardEdge,
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
                        minWidth: GeometriaDelloStudio.immagine.width * s,
                        maxWidth: GeometriaDelloStudio.immagine.width * s,
                        minHeight: GeometriaDelloStudio.immagine.height * s,
                        maxHeight: GeometriaDelloStudio.immagine.height * s,
                        child: Transform.translate(
                          offset: Offset(o.dx,
                              o.dy - GeometriaDelloStudio.taglioInAlto * s),
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
                          minWidth: GeometriaDelloStudio.immagine.width * s,
                          maxWidth: GeometriaDelloStudio.immagine.width * s,
                          minHeight: altoDelFilmato,
                          maxHeight: altoDelFilmato,
                          child: Transform.translate(
                            offset: Offset(
                                o.dx,
                                o.dy +
                                    (ScenaDellaSinastriaInVideo.sopra -
                                            GeometriaDelloStudio.taglioInAlto) *
                                        s),
                            child: SizedBox(
                              key: const Key('studio_filmato'),
                              width: GeometriaDelloStudio.immagine.width * s,
                              height: altoDelFilmato,
                              child: IlFilmatoCheSfuma(
                                  saltato: filmatoSaltato, child: filmato!),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (filmato == null || filmatoSaltato)
              Positioned.fromRect(
                rect: medora,
                child: LaScenaFermaCheAppare(
                  appare: filmatoSaltato,
                  child: Image.asset(posa,
                      key: const Key('studio_medora'),
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.medium),
                ),
              ),
            if (misuraDellaStatua != null)
              Positioned.fromRect(
                rect: nelloSchermo(
                    GeometriaDelloStudio.statuaNellImmagine(misuraDellaStatua)),
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    opacity: statuaVisibile ? 1 : 0,
                    duration: riduciMovimento
                        ? Duration.zero
                        : dissolvenzaDellaStatua,
                    curve: Curves.easeOut,
                    child: Image.asset(
                        GeometriaDelloStudio.statua(statua!),
                        key: const Key('sinastria_evolutiva_statua'),
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.medium),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}
