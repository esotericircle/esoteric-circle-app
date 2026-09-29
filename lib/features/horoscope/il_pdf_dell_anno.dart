import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../core/horoscope/horoscope.dart';
import '../../services/avvisi_locali.dart';

/// **IL PDF DELL'ANNO, ordine ES voce 04.** L'annuale approvato dal fondatore
/// porta il PDF all'Illuminato: le quattro schede dell'anno in un foglio da
/// tenere, condiviso col foglio di sistema del telefono.
abstract final class IlPdfDellAnno {
  /// **L'EMBLEMA DELL'ANNO IN COPERTINA, ordine ES voce 05**: lo stesso che
  /// porta la card dell'Anno, in orizzontale perche' sta sopra il titolo di
  /// un foglio A4.
  ///
  /// **In JPEG e non nel WebP della card**, ed e' una misura: il PDF non
  /// porta il WebP, lo decodifica e lo tiene in pixel, e il foglio con
  /// l'emblema pesava 1,3 MB contro i 6 KB del testo. Il JPEG il PDF lo
  /// incorpora cosi' com'e': la copia in `assets/pdf/` e' la stessa immagine,
  /// ridotta a 960 per 540 (a quella misura sul foglio sono 260 punti per
  /// pollice), fatta dal WebP della card e non ridisegnata.
  static const String emblema = 'assets/pdf/Oroscopo-Anno-Oriz-1.jpg';

  /// Il documento, in byte: l'emblema, poi le quattro schede con titolo,
  /// dominio e testo.
  ///
  /// [copertina] sono i byte dell'emblema, per le prove; senza, si legge
  /// dagli asset. **Se l'immagine non si legge il PDF si fa lo stesso**,
  /// senza copertina: l'anno scritto vale piu' della sua cornice.
  static Future<List<int>> documento(
    List<HoroscopeCard> schede, {
    required String titolo,
    required String sottotitolo,
    List<int>? copertina,
  }) async {
    pw.ImageProvider? immagine;
    try {
      final byte =
          copertina ?? (await rootBundle.load(emblema)).buffer.asUint8List();
      immagine = pw.MemoryImage(Uint8List.fromList(byte));
    } catch (errore) {
      immagine = null;
    }
    final doc = pw.Document(title: titolo, author: 'Esoteric Circle');
    pw.Widget? testata;
    if (immagine != null) {
      testata = pw.Center(child: pw.Image(immagine, height: 150));
    }
    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (_) => [
        if (testata != null) ...[testata, pw.SizedBox(height: 18)],
        pw.Text(titolo,
            style: const pw.TextStyle(
                fontSize: 22, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        pw.Text(sottotitolo, style: const pw.TextStyle(fontSize: 11)),
        pw.SizedBox(height: 18),
        for (final s in schede) ...[
          pw.Text(s.domain.label.toUpperCase(),
              style: const pw.TextStyle(fontSize: 9, letterSpacing: 1.2)),
          pw.SizedBox(height: 2),
          pw.Text(s.title,
              style: const pw.TextStyle(
                  fontSize: 15, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Text(s.text, style: const pw.TextStyle(fontSize: 11.5)),
          if (s.rigaDelLivello != null) ...[
            pw.SizedBox(height: 4),
            pw.Text(s.rigaDelLivello!, style: const pw.TextStyle(fontSize: 9)),
          ],
          pw.SizedBox(height: 16),
        ],
        pw.Text(
            'Esoteric Circle, oroscopo dell\'anno dalla Rivoluzione Solare.',
            style: const pw.TextStyle(fontSize: 8)),
      ],
    ));
    return doc.save();
  }

  /// Scrive il PDF e apre il foglio di condivisione.
  static Future<void> condividi(
    List<HoroscopeCard> schede, {
    required String titolo,
    required String sottotitolo,
  }) async {
    final byte =
        await documento(schede, titolo: titolo, sottotitolo: sottotitolo);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/il_tuo_anno.pdf');
    await file.writeAsBytes(byte, flush: true);
    await SharePlus.instance.share(ShareParams(
      files: [XFile(file.path, mimeType: 'application/pdf')],
      text: titolo,
    ));
  }
}

/// **L'AVVISO DEL COMPLEANNO SOLARE, ordine ES voce 04**: all'istante del
/// prossimo ritorno del Sole, "il tuo anno nuovo è pronto". Solo col permesso
/// degli avvisi gia' concesso: qui non si chiede niente.
abstract final class LAvvisoDellAnno {
  static const int id = 90404;

  static Future<void> programma(DateTime prossimoRitorno) async {
    try {
      if (!await avvisiDelCerchio.permessoConcesso()) return;
      await avvisiDelCerchio.programma(
        id: id,
        quando: prossimoRitorno.toLocal(),
        titolo: 'Medora · Il tuo anno nuovo',
        testo: 'Il Sole è tornato dov\'era alla tua nascita: il tuo oroscopo '
            'dell\'anno è pronto.',
        canale: 'oroscopo_annuale',
        carico: 'oroscopo',
      );
    } catch (errore) {
      // Un avviso che non si programma non ferma la lettura dell'anno.
    }
  }
}
