import 'dart:typed_data';
import 'dart:ui' as ui;

/// **IL TITOLO DEL VIDEO DELLA RIVELAZIONE, DISEGNATO DA FLUTTER.** Ordine FZ
/// voce FZ.08: *"il centro del video dell'animale (il verso), con sopra il
/// titolo di oggi ("mi ha trovato" e il nome dell'animale su due righe) e la
/// data"*.
///
/// **PERCHE' NON PIU' `drawtext`.** Fino al 20 ottobre 2026 il titolo lo
/// scriveva FFmpeg col filtro `drawtext` (`IlFiltroDelTitoloInVideo`). La
/// simulazione da persona sul Realme 767f596c ha visto "Condividi come video"
/// non fare niente: nessun foglio, nessun messaggio, il file di uscita a zero
/// byte. **Misurato nella libreria vera**: la variante del pacchetto in uso,
/// `ffmpeg_kit_flutter_new_min_gpl`, su Android non ha `drawtext` (serve
/// freetype, che la variante "min" non porta), mentre ha `overlay`, il
/// decodificatore `png` e `libx264`. Le prove giravano con un FFmpeg finto,
/// e sul PC `drawtext` c'e': nessuno l'aveva mai visto cadere. Padre: ordine
/// FZ voce FZ.08.
///
/// Adesso il titolo e' un'immagine trasparente grande quanto il video, con lo
/// stesso carattere della card (Cinzel), e FFmpeg la sovrappone.
abstract final class IlTitoloInImmagine {
  /// La misura del video del cammino: 1080 per 1920.
  static const int larga = 1080;
  static const int alta = 1920;

  /// L'oro chiaro del nome e l'oro morbido delle altre righe, quelli della
  /// card della rivelazione.
  static const ui.Color oro = ui.Color(0xFFF6E7C0);
  static const ui.Color oroSoft = ui.Color(0xFFD6A868);

  /// Le tre righe: misura del carattere e cima, in pixel del video.
  static const List<({double misura, double cima})> righe = [
    (misura: 64, cima: 140),
    (misura: 88, cima: 220),
    (misura: 40, cima: 340),
  ];

  /// **IL PNG DEL TITOLO**, trasparente fuori dalle lettere.
  static Future<Uint8List> png({
    required String rigaUno,
    required String rigaDue,
    required String data,
  }) async {
    final registro = ui.PictureRecorder();
    final tela = ui.Canvas(registro);
    final testi = [rigaUno, rigaDue, data];
    final colori = [oroSoft, oro, oroSoft];
    for (var i = 0; i < testi.length; i++) {
      _riga(tela, testi[i], righe[i].misura, righe[i].cima, colori[i]);
    }
    final immagine = await registro.endRecording().toImage(larga, alta);
    final dati = await immagine.toByteData(format: ui.ImageByteFormat.png);
    return dati!.buffer.asUint8List();
  }

  static void _riga(ui.Canvas tela, String testo, double misura, double cima,
      ui.Color colore) {
    ui.Paragraph paragrafo(ui.Color c, {double bordo = 0}) {
      final stile = ui.TextStyle(
        fontFamily: 'Cinzel',
        fontSize: misura,
        color: bordo > 0 ? null : c,
        foreground: bordo > 0
            ? (ui.Paint()
              ..style = ui.PaintingStyle.stroke
              ..strokeWidth = bordo
              ..color = c)
            : null,
      );
      final b = ui.ParagraphBuilder(ui.ParagraphStyle(
        textAlign: ui.TextAlign.center,
        maxLines: 1,
      ))
        ..pushStyle(stile)
        ..addText(testo);
      return b.build()
        ..layout(const ui.ParagraphConstraints(width: larga * 1.0));
    }

    // **UN BORDO SCURO SOTTO LE LETTERE**, come il `borderw=2` di prima:
    // l'oro resta leggibile sopra il bosco chiaro del video.
    tela.drawParagraph(
        paragrafo(const ui.Color(0x80000000), bordo: 4), ui.Offset(0, cima));
    tela.drawParagraph(paragrafo(colore), ui.Offset(0, cima));
  }

  /// **I FILTRI CHE IL COMANDO USA**, e solo quelli che la libreria Android
  /// della variante `min-gpl` ha davvero (lette nella libreria il 20 ottobre
  /// 2026: `overlay` si', `drawtext` no). La guardia
  /// `il_video_della_rivelazione_si_fa_sul_telefono_test` pretende che ogni
  /// filtro del comando stia in [filtriDisponibili].
  static const String filtro = '[0:v][1:v]overlay=0:0';

  static const Set<String> filtriDisponibili = {'overlay', 'scale', 'format'};
}
