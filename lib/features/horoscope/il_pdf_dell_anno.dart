import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/condivisione/porta_della_condivisione.dart';
import '../../core/horoscope/horoscope.dart';
import '../../services/avvisi_locali.dart';

/// **LA TIPOGRAFIA DEL FOGLIO DELL'ANNO, in punti di stampa.** Ordine ES
/// voce 04.
///
/// Il PDF non e' lo schermo: si stampa o si legge su un foglio A4, e le sue
/// misure sono punti tipografici, non i ruoli di `TypographyTokens` che
/// servono a un telefono tenuto in mano. **La prima stesura le scriveva a
/// mano dentro il documento**, e la guardia della tipografia nel dato le ha
/// contate come debito dello schermo (cinque rossi alla suite intera): qui
/// stanno tutte, con il loro nome, in un punto solo. Un foglio A4 si legge a
/// 11 o 12 punti, e i titoli stanno fra 15 e 22.
abstract final class IlFoglioDellAnno {
  static const double titolo = 22;
  static const double sottotitolo = 11;
  static const double etichetta = 9;
  static const double titoloDellaScheda = 15;
  static const double testo = 11.5;
  static const double firma = 8;

  static const double dopoLaTestata = 18;
  static const double dopoIlTitolo = 6;
  static const double dopoLEtichetta = 2;
  static const double primaDelLivello = 4;
  static const double fraLeSchede = 16;
}

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
        if (testata != null) ...[
          testata,
          pw.SizedBox(height: IlFoglioDellAnno.dopoLaTestata)
        ],
        pw.Text(titolo,
            style: const pw.TextStyle(
                fontSize: IlFoglioDellAnno.titolo,
                fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: IlFoglioDellAnno.dopoIlTitolo),
        pw.Text(sottotitolo,
            style: const pw.TextStyle(fontSize: IlFoglioDellAnno.sottotitolo)),
        pw.SizedBox(height: IlFoglioDellAnno.dopoLaTestata),
        for (final s in schede) ...[
          pw.Text(s.domain.label.toUpperCase(),
              style: const pw.TextStyle(
                  fontSize: IlFoglioDellAnno.etichetta, letterSpacing: 1.2)),
          pw.SizedBox(height: IlFoglioDellAnno.dopoLEtichetta),
          pw.Text(s.title,
              style: const pw.TextStyle(
                  fontSize: IlFoglioDellAnno.titoloDellaScheda,
                  fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: IlFoglioDellAnno.dopoIlTitolo),
          pw.Text(s.text,
              style: const pw.TextStyle(fontSize: IlFoglioDellAnno.testo)),
          if (s.rigaDelLivello != null) ...[
            pw.SizedBox(height: IlFoglioDellAnno.primaDelLivello),
            // Come a schermo: il simbolo sta dopo la lettura, col suo nome
            // (Linee Guida, sezione 2, "il simbolo non apre mai").
            pw.Text('DA DOVE VIENE',
                style: const pw.TextStyle(
                    fontSize: IlFoglioDellAnno.etichetta, letterSpacing: 1.2)),
            pw.Text(s.rigaDelLivello!,
                style:
                    const pw.TextStyle(fontSize: IlFoglioDellAnno.etichetta)),
          ],
          pw.SizedBox(height: IlFoglioDellAnno.fraLeSchede),
        ],
        pw.Text(
            'Esoteric Circle, oroscopo dell\'anno dalla Rivoluzione Solare.',
            style: const pw.TextStyle(fontSize: IlFoglioDellAnno.firma)),
      ],
    ));
    return doc.save();
  }

  /// Scrive il PDF e apre il foglio di condivisione. Torna vero se la
  /// condivisione e' avvenuta: chi chiama paga il premio (ordine BG voce 04).
  static Future<bool> condividi(
    List<HoroscopeCard> schede, {
    required String titolo,
    required String sottotitolo,
  }) async {
    final byte =
        await documento(schede, titolo: titolo, sottotitolo: sottotitolo);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/il_tuo_anno.pdf');
    await file.writeAsBytes(byte, flush: true);
    // **DALLA PORTA UNICA DELLA CONDIVISIONE**, come ogni cosa che si manda
    // dal Cerchio (ordine P voce 28): la prima stesura apriva il foglio di
    // sistema da se', e la suite l'ha presa.
    return PortaDellaCondivisione.daFile(file.path,
        testo: titolo, tipo: 'application/pdf');
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
