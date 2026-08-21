import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../core/maestro/maestro.dart';
import '../../core/sigilli/sentieri.dart';
import '../../core/sigilli/traguardo.dart';

/// DI CHI E' LA FESTA, quando i traguardi celebrati sono piu' di uno.
///
/// **La regola, che viene dall'ordine AO voce 05 e sopravvive alla
/// demolizione**: e' del traguardo PIU' IMPORTANTE, cioe' del primo grande se
/// ce n'e' uno, e a parita' del primo nominato. Prima viveva in
/// `direzione_della_festa.dart` insieme alle particelle; quel file muore con
/// l'ordine AT voce 03, ma questa risposta serve ancora, perche' decide QUALE
/// transizione parte e di che colore e' la scena.
class MaestroDellaFesta {
  const MaestroDellaFesta._();

  static Maestro di(List<Traguardo> traguardi, List<Sentiero> sentieri) {
    if (sentieri.isEmpty) return Maestro.medora;
    for (var i = 0; i < traguardi.length && i < sentieri.length; i++) {
      if (traguardi[i].eGrande) return sentieri[i].maestro;
    }
    return sentieri.first.maestro;
  }
}

/// LA TRANSIZIONE DI STELLE. Ordine AT voci 04 e 05.
///
/// **Cosa sostituisce.** Le tre feste a particelle disegnate da noi, una per
/// Maestro. Al loro posto c'e' un filmato vero con canale alpha, due secondi,
/// che copre lo schermo e scopre il traguardo a meta' corsa.
///
/// **Perche' NON si usa `Image.asset` e NON si precaricano i fotogrammi.**
/// Cinquanta fotogrammi a 720 per 1280 in RGBA fanno **184 megabyte** di
/// memoria: su un Android medio l'app muore. Qui il codec avanza un fotogramma
/// per volta con `getNextFrame`, se ne tiene UNO solo a schermo e il precedente
/// si butta appena il nuovo e' pronto. Non esiste in nessun punto una
/// `List<ui.Image>` con la sequenza intera.
///
/// **Il tempo comanda, non l'indice.** L'indice di fotogramma nasce dai
/// millesimi trascorsi, cioe' `(millesimi / 40).floor()` limitato a 0..49:
/// cosi' il frame 21 e' l'istante 800 anche se il file, per come `libwebp`
/// fonde i fotogrammi identici, di fotogrammi ne dichiara quaranta invece di
/// cinquanta (misurato, ordine AT voce 02).
class TransizioneDiStelle extends StatefulWidget {
  const TransizioneDiStelle({
    super.key,
    required this.maestro,
    this.suFrame,
    this.suFine,
  });

  /// Di chi e' la festa: decide quale dei tre filmati parte.
  final Maestro maestro;

  /// Chiamata a ogni cambio di fotogramma, con l'indice da 0 a 49. La usa la
  /// regia per scoprire il traguardo al frame 21.
  final void Function(int indice)? suFrame;

  /// Chiamata quando la transizione ha finito i suoi due secondi.
  final VoidCallback? suFine;

  /// **QUANTI FOTOGRAMMI, e quanto dura ciascuno.** Il filmato e' a venticinque
  /// al secondo per due secondi: cinquanta fotogrammi da quaranta millesimi.
  static const int quantiFotogrammi = 50;
  static const Duration passo = Duration(milliseconds: 40);
  static const Duration durata = Duration(milliseconds: 2000);

  /// **IL FOTOGRAMMA IN CUI IL TRAGUARDO COMPARE.** Ordine AT voce 05: il frame
  /// 21 contato da uno, cioe' 800 millesimi esatti dall'inizio. Li' il lampo
  /// della stella copre lo stacco, ed e' per questo che il fondatore ha messo
  /// il taglio proprio li'.
  static const int frameDelloStacco = 21;
  static const Duration istanteDelloStacco = Duration(milliseconds: 800);

  /// Il filmato di ciascun Maestro. **Un traguardo senza dominio usa quello di
  /// Medora**, come dice l'ordine AT voce 08.
  static String asseDi(Maestro maestro) => switch (maestro) {
        Maestro.medora => 'assets/transizioni/stella_medora.webp',
        Maestro.caligo => 'assets/transizioni/stella_caligo.webp',
        Maestro.aura => 'assets/transizioni/stella_aura.webp',
      };

  /// **QUANTE IMMAGINI VIVE CI SONO ADESSO, e serve davvero.** Ordine AT voce
  /// 04: ogni `ui.Image` creata deve ricevere `dispose()`. Questo contatore lo
  /// rende verificabile da una prova invece che da una lettura del codice.
  @visibleForTesting
  static int immaginiVive = 0;

  @override
  State<TransizioneDiStelle> createState() => TransizioneDiStelleState();
}

class TransizioneDiStelleState extends State<TransizioneDiStelle>
    with SingleTickerProviderStateMixin {
  ui.Codec? _codec;
  ui.Image? _corrente;
  Ticker? _ticker;
  Duration _inizio = Duration.zero;

  /// L'ultimo indice servito, per non chiedere due volte lo stesso fotogramma.
  int _indiceServito = -1;

  /// Vero mentre si sta chiedendo il fotogramma successivo: senza questo, un
  /// tick che arriva mentre il codec lavora ne chiederebbe un altro, e i due
  /// arriverebbero fuori ordine.
  bool _inVolo = false;

  bool _finita = false;

  @override
  void initState() {
    super.initState();
    _apri();
  }

  Future<void> _apri() async {
    try {
      final dati =
          await rootBundle.load(TransizioneDiStelle.asseDi(widget.maestro));
      if (!mounted) return;
      _codec = await ui.instantiateImageCodec(
          dati.buffer.asUint8List(dati.offsetInBytes, dati.lengthInBytes));
      if (!mounted) {
        _codec?.dispose();
        return;
      }
      _ticker = createTicker(_tick)..start();
    } catch (errore) {
      // **SI IGNORA, E SI DICHIARA PERCHE'.** Un filmato che non si apre non
      // deve portarsi via la festa: la scena resta senza transizione e il
      // traguardo si vede subito, che e' meglio di uno schermo nero. La regia
      // se ne accorge perche' la fine arriva comunque.
      assert(() {
        debugPrint('transizione di stelle non aperta: $errore');
        return true;
      }());
      widget.suFine?.call();
    }
  }

  void _tick(Duration adesso) {
    if (_finita) return;
    if (_inizio == Duration.zero) _inizio = adesso;
    final trascorsi = adesso - _inizio;
    if (trascorsi >= TransizioneDiStelle.durata) {
      _finita = true;
      widget.suFine?.call();
      return;
    }
    // **L'INDICE NASCE DAL TEMPO**, non dal conto dei tick: un fotogramma
    // saltato non fa scivolare tutta la sequenza.
    final indice = (trascorsi.inMilliseconds / 40)
        .floor()
        .clamp(0, TransizioneDiStelle.quantiFotogrammi - 1);
    if (indice == _indiceServito || _inVolo) return;
    _indiceServito = indice;
    widget.suFrame?.call(indice);
    _avanza();
  }

  Future<void> _avanza() async {
    final codec = _codec;
    if (codec == null || _inVolo) return;
    _inVolo = true;
    try {
      final f = await codec.getNextFrame();
      TransizioneDiStelle.immaginiVive++;
      if (!mounted) {
        f.image.dispose();
        TransizioneDiStelle.immaginiVive--;
        return;
      }
      // **IL PRECEDENTE SI BUTTA APPENA IL NUOVO E' PRONTO**: al massimo due
      // immagini vive in un istante, mai la sequenza.
      final vecchio = _corrente;
      setState(() => _corrente = f.image);
      if (vecchio != null) {
        vecchio.dispose();
        TransizioneDiStelle.immaginiVive--;
      }
    } catch (errore) {
      assert(() {
        debugPrint('fotogramma non decodificato: $errore');
        return true;
      }());
    } finally {
      _inVolo = false;
    }
  }

  @override
  void dispose() {
    _ticker?.dispose();
    if (_corrente != null) {
      _corrente!.dispose();
      TransizioneDiStelle.immaginiVive--;
    }
    _codec?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final immagine = _corrente;
    if (immagine == null) return const SizedBox.expand();
    return IgnorePointer(
      child: CustomPaint(
        key: Key('transizione_${widget.maestro.id}'),
        size: Size.infinite,
        painter: _PittoreDelFotogramma(immagine),
      ),
    );
  }
}

/// Dipinge il fotogramma corrente a schermo intero, ritagliando cio' che
/// avanza. **Niente `MaskFilter` e niente shader per fotogramma**, ordine AT
/// voce 04: a venticinque fotogrammi al secondo, un filtro per fotogramma e' il
/// modo piu' rapido di far cadere il conto sotto i cinquanta.
class _PittoreDelFotogramma extends CustomPainter {
  const _PittoreDelFotogramma(this.immagine);

  final ui.Image immagine;

  @override
  void paint(Canvas tela, Size misura) {
    final iw = immagine.width.toDouble(), ih = immagine.height.toDouble();
    // BoxFit.cover: la scala e' quella che copre il lato piu' esigente.
    final scala = misura.width / iw > misura.height / ih
        ? misura.width / iw
        : misura.height / ih;
    final w = iw * scala, h = ih * scala;
    tela.drawImageRect(
      immagine,
      Rect.fromLTWH(0, 0, iw, ih),
      Rect.fromLTWH((misura.width - w) / 2, (misura.height - h) / 2, w, h),
      Paint()..filterQuality = FilterQuality.low,
    );
  }

  @override
  bool shouldRepaint(_PittoreDelFotogramma old) => old.immagine != immagine;
}
