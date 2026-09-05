import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/sigilli/disegno_del_sentiero.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// IL COMPIMENTO DEI TRE SENTIERI, COL DENOMINATORE RIFONDATO.
/// Ordine T voce 02.
///
/// **Il denominatore vecchio dava un risultato impossibile.** Misurando i pixel
/// che cambiano fra il traguardo 54 e il 55 e dividendoli per l'INCHIOSTRO della
/// figura, il Loto rispondeva 183 per cento e la Costellazione 110: come quota
/// non vuol dire niente, perche' l'ultimo petalo che si apre muove piu' area di
/// quanta ne fosse dipinta prima. **Il denominatore giusto e' la SUPERFICIE, cioe'
/// il rettangolo che contiene tutti e cinquantacinque gli ancoraggi**, che e' la
/// stessa cosa per il prima e per il dopo.
///
/// **E LA SOGLIA DEL QUARANTACINQUE PER CENTO NON SI PUO' APPLICARE QUI, e va
/// detto invece di riportarla.** La voce S.02 la fisso' su una grandezza diversa
/// due volte: il confronto era fra il disegno a META' cammino e quello completo,
/// non fra il 54 e il 55, e il denominatore era l'impronta della figura, non la
/// sua superficie. Due misure con numeratore e denominatore diversi non si
/// confrontano. **In piu' quella soglia non e' mai stata una prova**: nella suite
/// non esiste nessuna riga che la faccia rispettare, quindi era un proposito.
///
/// Qui si misurano tutte e due le grandezze sullo stesso denominatore, cosi'
/// Mauro puo' fissare la soglia sapendo su cosa la sta fissando.
void main() {
  const tela = Size(360, 462);

  Future<Uint8List> dipingi(Sentiero sentiero, Set<String> accesi) async {
    final punti = GeometriaDelSentiero.punti(sentiero);
    const p = MaestroPalette.medora;
    final pittore = switch (sentiero) {
      Sentiero.costellazione => PittoreDellaCostellazione(
          punti: punti,
          accesi: accesi,
          evidenziato: null,
          oro: p.gold,
          oroTenue: p.goldSoft),
      Sentiero.albero => PittoreDellAlbero(
          punti: punti,
          accesi: accesi,
          evidenziato: null,
          oro: p.gold,
          oroTenue: p.goldSoft),
      Sentiero.loto => PittoreDelLoto(
          punti: punti,
          accesi: accesi,
          evidenziato: null,
          oro: p.gold,
          oroTenue: p.goldSoft),
    };
    final registratore = ui.PictureRecorder();
    final t = Canvas(registratore);
    t.drawRect(Rect.fromLTWH(0, 0, tela.width, tela.height),
        Paint()..color = const Color(0xFF0B0D1A));
    pittore.paint(t, tela);
    final immagine = await registratore
        .endRecording()
        .toImage(tela.width.toInt(), tela.height.toInt());
    return (await immagine.toByteData(format: ui.ImageByteFormat.rawRgba))!
        .buffer
        .asUint8List();
  }

  int luminanza(Uint8List px, int i) =>
      (px[i] * 299 + px[i + 1] * 587 + px[i + 2] * 114) ~/ 1000;

  testWidgets('MISURA: quanto cambia la figura, sulla sua superficie',
      (tester) async {
    await tester.runAsync(() async {
      var osservati = 0;
      for (final sentiero in Sentieri.tutti) {
        osservati++;
        final punti = GeometriaDelSentiero.punti(sentiero);
        // **IL DENOMINATORE: il rettangolo dei cinquantacinque ancoraggi.**
        var minX = 1.0, maxX = 0.0, minY = 1.0, maxY = 0.0;
        for (final p in punti) {
          if (p.dove.dx < minX) minX = p.dove.dx;
          if (p.dove.dx > maxX) maxX = p.dove.dx;
          if (p.dove.dy < minY) minY = p.dove.dy;
          if (p.dove.dy > maxY) maxY = p.dove.dy;
        }
        final superficie =
            ((maxX - minX) * tela.width) * ((maxY - minY) * tela.height);

        final ordinati = Sentieri.di(sentiero).toList()
          ..sort((a, b) => Sentieri.ordineNelCammino(a)
              .compareTo(Sentieri.ordineNelCammino(b)));
        final tutti = ordinati.map((t) => t.id).toSet();
        final a54 = ordinati.take(54).map((t) => t.id).toSet();
        final aMeta = ordinati.take(27).map((t) => t.id).toSet();

        final pieno = await dipingi(sentiero, tutti);
        final r54 = await dipingi(sentiero, a54);
        final meta = await dipingi(sentiero, aMeta);

        int cambiati(Uint8List a, Uint8List b) {
          var n = 0;
          for (var i = 0; i < a.length; i += 4) {
            if ((luminanza(a, i) - luminanza(b, i)).abs() >= 12) n++;
          }
          return n;
        }

        final ultimo = cambiati(r54, pieno);
        final secondaMeta = cambiati(meta, pieno);
        // ignore: avoid_print
        print('ORDINE T VOCE 02: ${sentiero.name} compimento. Superficie della '
            'figura ${superficie.round()} pixel su ${(tela.width * tela.height).round()} '
            'di tela. Dal 54 al 55 cambiano $ultimo pixel, cioe\' '
            '${(ultimo / superficie * 100).toStringAsFixed(1)} per cento della '
            'superficie. Da meta\' cammino al 55 cambiano $secondaMeta, cioe\' '
            '${(secondaMeta / superficie * 100).toStringAsFixed(1)} per cento.');
      }
      // ignore: avoid_print
      print('ORDINE T VOCE 02: sentieri misurati $osservati');
      expect(osservati, greaterThan(0),
          reason: 'la prova non ha misurato nessun sentiero: gira a vuoto');
    });
  });

  testWidgets(
      'l\'ultimo traguardo da\' alla figura qualcosa che prima non aveva',
      (tester) async {
    await tester.runAsync(() async {
      // **NON E' LA SOGLIA DELLA S.02, e non finge di esserlo.** Qui si pretende
      // solo che l'ultimo traguardo NON sia invisibile: sotto l'uno per cento
      // della superficie della figura, accendere il cinquantacinquesimo non si
      // vede, e allora il grande non e' un compimento. La soglia vera la fissa
      // Mauro davanti ai numeri stampati qui sopra.
      const minimo = 1.0;
      var osservati = 0;
      final muti = <String>[];
      for (final sentiero in Sentieri.tutti) {
        osservati++;
        final punti = GeometriaDelSentiero.punti(sentiero);
        var minX = 1.0, maxX = 0.0, minY = 1.0, maxY = 0.0;
        for (final p in punti) {
          if (p.dove.dx < minX) minX = p.dove.dx;
          if (p.dove.dx > maxX) maxX = p.dove.dx;
          if (p.dove.dy < minY) minY = p.dove.dy;
          if (p.dove.dy > maxY) maxY = p.dove.dy;
        }
        final superficie =
            ((maxX - minX) * tela.width) * ((maxY - minY) * tela.height);
        final ordinati = Sentieri.di(sentiero).toList()
          ..sort((a, b) => Sentieri.ordineNelCammino(a)
              .compareTo(Sentieri.ordineNelCammino(b)));
        final pieno =
            await dipingi(sentiero, ordinati.map((t) => t.id).toSet());
        final r54 =
            await dipingi(sentiero, ordinati.take(54).map((t) => t.id).toSet());
        var n = 0;
        for (var i = 0; i < pieno.length; i += 4) {
          if ((luminanza(pieno, i) - luminanza(r54, i)).abs() >= 12) n++;
        }
        final quota = n / superficie * 100;
        if (quota < minimo) {
          muti.add('${sentiero.name}: ${quota.toStringAsFixed(2)} per cento');
        }
      }
      // ignore: avoid_print
      print('ORDINE T VOCE 02: compimenti controllati $osservati');
      expect(osservati, greaterThan(0));
      expect(muti, isEmpty,
          reason: 'su questi sentieri l\'ultimo traguardo non da\' alla figura '
              'niente che si veda: ${muti.join(", ")}');
    });
  });
}
