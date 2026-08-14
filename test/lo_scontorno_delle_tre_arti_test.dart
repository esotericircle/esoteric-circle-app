import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/sigilli/regole_delle_tre_arti.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// LO SCONTORNO DELLE TRE ARTI, MISURATO. Ordine T voce 02.
///
/// **Perche' esiste, e la ragione conta piu' della misura.** L'Architetto ha
/// creduto di vedere un alone rosso sui bordi delle tre immagini, Mauro non lo
/// vede, e nessuno dei due l'aveva misurato: **era un'ipotesi, non un difetto**.
/// Qui diventa un numero, e il numero decide.
///
/// **Come si misura.** Si guardano solo i pixel ad ALFA PARZIALE, che sono il
/// bordo sfumato della figura: e' li' che un alone vive. Si rendono sopra il
/// fondo scuro vero dell'app, perche' un colore sotto il cinquanta per cento di
/// opacita' su un fondo nero non e' il colore che sta nel file. Poi si conta
/// quanti di quei pixel portano un CALORE che il corpo opaco della figura non
/// porta: calore vuol dire quanto il rosso supera il piu' alto fra verde e blu,
/// ed e' la forma che avrebbe l'alone sospettato.
///
/// **Il confronto e' con la figura stessa e non con un colore assoluto**, ed e'
/// il punto: un'arte fatta di oro e rosso e' calda per costruzione, quindi
/// "rosso" da solo non e' un difetto. E' estraneo cio' che supera il calore che
/// il corpo pieno gia' si concede.
void main() {
  /// **IL FONDO VERO DELL'APP**, non un nero teorico: e' sopra questo che le tre
  /// immagini si vedranno.
  const fondo = Color(0xFF0B0D1A);

  /// **LA SOGLIA, DICHIARATA, E NON DERIVA DA CIO' CHE SI E' MISURATO.**
  ///
  /// Mezzo per cento dei pixel del bordo. La ragione e' cosa vuol dire "alone":
  /// un alone si vede quando forma una FASCIA lungo il contorno, e il contorno
  /// sfumato e' spesso due o tre pixel. Mezzo per cento vuol dire al massimo un
  /// pixel ogni duecento di bordo, cioe' un granello isolato ogni parecchie
  /// decine di pixel di profilo: non e' una fascia, e a video non c'e'.
  ///
  /// Non viene dai numeri trovati (0,055 / 0,190 / 0,095 per cento): viene da
  /// cosa deve essere vero perche' un occhio veda una riga colorata.
  const sogliaPerCento = 0.5;

  testWidgets('nessuna delle tre arti porta un alone estraneo sul bordo',
      (tester) async {
    await tester.runAsync(() async {
      var osservate = 0;
      final sopra = <String>[];
      for (final sentiero in Sentieri.tutti) {
        final file = File(RegoleDelleTreArti.arteDi(sentiero));
        if (!file.existsSync()) continue;
        osservate++;
        final codice = await ui.instantiateImageCodec(await file.readAsBytes());
        final arte = (await codice.getNextFrame()).image;
        final px = (await arte.toByteData(format: ui.ImageByteFormat.rawRgba))!
            .buffer
            .asUint8List();

        // IL CALORE CHE IL CORPO PIENO SI CONCEDE, preso al 99,5 per cento
        // perche' il massimo assoluto sarebbe un pixel solo e deciderebbe tutto.
        final caldoDelCorpo = <int>[];
        for (var i = 0; i < px.length; i += 4) {
          if (px[i + 3] < 250) continue;
          final piuAlto = px[i + 1] > px[i + 2] ? px[i + 1] : px[i + 2];
          caldoDelCorpo.add(px[i] - piuAlto);
        }
        caldoDelCorpo.sort();
        final confine =
            caldoDelCorpo[(caldoDelCorpo.length * 0.995).floor().clamp(
                0, caldoDelCorpo.length - 1)];

        var bordo = 0, estranei = 0;
        for (var i = 0; i < px.length; i += 4) {
          final a = px[i + 3];
          if (a == 0 || a >= 250) continue;
          bordo++;
          // Reso sopra il fondo vero dell'app.
          final k = a / 255.0;
          final r = px[i] * k + fondo.r * 255 * (1 - k);
          final g = px[i + 1] * k + fondo.g * 255 * (1 - k);
          final b = px[i + 2] * k + fondo.b * 255 * (1 - k);
          final caldo = r - (g > b ? g : b);
          if (caldo > confine) estranei++;
        }
        final quota = estranei * 100.0 / bordo;
        // ignore: avoid_print
        print('ORDINE T VOCE 02: ${sentiero.name} scontorno, bordo $bordo '
            'pixel ad alfa parziale, calore del corpo al 99,5 per cento '
            '$confine, estranei $estranei, cioe\' '
            '${quota.toStringAsFixed(3)} per cento');
        if (quota > sogliaPerCento) {
          sopra.add('${sentiero.name}: ${quota.toStringAsFixed(3)} per cento '
              '($estranei pixel su $bordo di bordo)');
        }
      }
      // ignore: avoid_print
      print('ORDINE T VOCE 02: arti osservate $osservate');
      expect(osservate, greaterThan(0),
          reason: 'nessuna arte guardata: la prova gira a vuoto');
      expect(sopra, isEmpty,
          reason: 'queste arti portano un alone estraneo sopra la soglia '
              'dichiarata di $sogliaPerCento per cento dei pixel di bordo, '
              'quindi si pulisce e si consegna la coppia prima e dopo: '
              '${sopra.join(" | ")}');
    });
  });
}
