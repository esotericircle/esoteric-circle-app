import 'dart:ui' as ui;

import 'package:esoteric_circle/core/face/face_classifier.dart';
import 'package:esoteric_circle/core/face/face_trait.dart';
import 'package:esoteric_circle/core/face/mian_xiang.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/maestri/aura/face/colore_dell_elemento.dart';
import 'package:esoteric_circle/features/maestri/aura/face/face_constellation.dart';
import 'package:esoteric_circle/features/maestri/aura/face/face_constellation_painter.dart';
import 'package:esoteric_circle/features/maestri/aura/face/face_share_card.dart';
import 'package:esoteric_circle/features/maestri/aura/face/face_silhouette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// **I CINQUE ELEMENTI COLORANO LA SCENA, E SI LEGGONO SCRITTI.**
/// Ordine CR voce 09, 6 settembre 2026.
///
/// **Parole dell'ordine**: *"Le zone del volto si colorano secondo l'elemento
/// dominante misurato, e il colore vince sulla scena"*.
///
/// **IL RISCHIO CHE QUESTA GUARDIA SORVEGLIA, ed e' il rischio di tutto questo
/// ordine.** Un colore acceso su una scena dove nessuna misura e' avvenuta
/// direbbe che una misura c'e' stata: sarebbe la bugia del muro travestita da
/// tinta.
///
/// **E SI PRETENDE CHE IL COLORE NON SIA L'UNICO PORTATORE.** Un responso
/// affidato a una tinta e' un responso che chi non distingue i colori non
/// riceve: il nome dell'elemento deve stare scritto.
///
/// **DUE PRETESE DI QUESTA GUARDIA SONO NATE SBAGLIATE, e la Regola A le ha
/// colte.** La prima chiedeva che la scena senza elemento fosse identica a
/// quella con l'oro: falso, perche' il ripiego di Aura non e' un colore solo,
/// le linee e l'alone sono oro e il nucleo delle stelle e' il bagliore. La
/// seconda contava i pixel vicini all'elemento contro quelli vicini all'oro, e
/// cadeva sulla Terra, che e' un ocra vicinissimo all'oro: misurava la
/// distanza fra due tinte invece del dominio sulla scena. Sono state rifatte
/// sui fatti, dopo aver misurato il disegno vero.
void main() {
  final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.aura));

  /// Dipinge e restituisce i pixel, per guardare i colori davvero usati.
  Future<List<int>> pixel(CustomPainter pittore,
      {Size lato = const Size(160, 160)}) async {
    final registratore = ui.PictureRecorder();
    pittore.paint(Canvas(registratore, Offset.zero & lato), lato);
    final immagine = await registratore
        .endRecording()
        .toImage(lato.width.toInt(), lato.height.toInt());
    final dati = await immagine.toByteData(format: ui.ImageByteFormat.rawRgba);
    return dati == null ? const [] : dati.buffer.asUint8List().toList();
  }

  FaceReading letturaCon(FaceTrait forma) => FaceReading(letture: [
        for (final c in FaceCategory.values)
          TraitLettura(
            tratto: c == FaceCategory.formaVolto
                ? forma
                : FaceTrait.perCategoria(c).first,
            marcatezza: c == FaceCategory.formaVolto ? 1.0 : 0.2,
          ),
      ]);

  test('ogni elemento ha il suo colore, e sono cinque diversi', () {
    final colori = <Color>{};
    for (final e in ElementoDelVolto.values) {
      colori.add(ColoreDellElemento.di(e));
    }
    expect(colori.length, ElementoDelVolto.values.length,
        reason: 'due elementi condividono un colore: allora il colore non '
            'distingue niente, e la scena dice meno di quanto promette');
  });

  test('nessun elemento resta senza colore', () {
    // **SI INTERROGANO TUTTI**, anche quelli che oggi il classificatore non
    // raggiunge: il giorno che il Metallo diventasse raggiungibile, un colore
    // mancante si scoprirebbe a video invece che qui.
    for (final e in ElementoDelVolto.values) {
      expect(() => ColoreDellElemento.di(e), returnsNormally,
          reason: 'l\'elemento ${e.nome} non ha colore');
    }
    expect(ColoreDellElemento.tutti.length, ElementoDelVolto.values.length,
        reason: 'la tavola dei colori non copre tutti gli elementi');
  });

  test('senza elemento la scena non e\' quella di nessun elemento', () async {
    // **DUE STRUMENTI SBAGLIATI PRIMA DI QUESTO, e vanno detti.** Ho
    // provato a confrontare il ripiego con l'oro: falso, perche' il ripiego
    // di Aura non e' un colore solo, le linee e l'alone sono oro e il
    // nucleo delle stelle e' il bagliore. Poi a contare i pixel vicini
    // all'oro contro un colore estraneo: e la scena senza elemento tende
    // all'estraneo, 2312 pixel contro 529, perche' i nuclei bianchi e gli
    // aloni sfumati non somigliano a nessuna delle due tinte. **La
    // distanza fra colori non misura questo fatto**, e insistere avrebbe
    // prodotto una guardia tarata sul caso invece che sulla cosa.
    //
    // Il fatto si misura senza euristiche: un colore di ripiego, qualunque
    // sia, farebbe coincidere la scena senza misura con una scena
    // colorata. Qui si pretende che non coincida con NESSUNA delle cinque.
    final cost = FaceConstellation.da(FaceSilhouette.contorni());
    final senza = await pixel(FaceConstellationPainter(
      costellazione: cost,
      palette: palette,
    ));
    for (final e in ElementoDelVolto.values) {
      final con = await pixel(FaceConstellationPainter(
        costellazione: cost,
        palette: palette,
        elemento: ColoreDellElemento.di(e),
      ));
      expect(senza, isNot(equals(con)),
          reason: 'senza nessuna misura la scena e\' gia\' quella '
              'dell\'elemento ${e.nome}: un colore sta comparendo dove '
              'nessuna forma e\' stata misurata, ed e\' la bugia del '
              'muro travestita da tinta');
    }
  });

  test('il colore dell\'elemento vince sulla scena', () async {
    // **MISURATO SUL DISEGNO VERO**: applicando un elemento cambia il CENTO
    // PER CENTO dei pixel accesi, per tutti e cinque. Un colore che arrivasse
    // solo a una parte del disegno scenderebbe sotto, ed e' esattamente quello
    // che vuol dire vincere sulla scena invece di comparirci.
    final cost = FaceConstellation.da(FaceSilhouette.contorni());
    final senza = await pixel(FaceConstellationPainter(
      costellazione: cost,
      palette: palette,
    ));
    for (final e in ElementoDelVolto.values) {
      final con = await pixel(FaceConstellationPainter(
        costellazione: cost,
        palette: palette,
        elemento: ColoreDellElemento.di(e),
      ));
      var accesi = 0;
      var cambiati = 0;
      for (var i = 0; i < senza.length; i += 4) {
        if (senza[i + 3] < 40 && con[i + 3] < 40) continue;
        accesi++;
        if (senza[i] != con[i] ||
            senza[i + 1] != con[i + 1] ||
            senza[i + 2] != con[i + 2] ||
            senza[i + 3] != con[i + 3]) {
          cambiati++;
        }
      }
      expect(accesi, greaterThan(500),
          reason: 'la scena ha troppi pochi pixel accesi per dire qualcosa');
      expect(cambiati / accesi, greaterThan(0.9),
          reason: 'con l\'elemento ${e.nome} il colore tocca solo '
              '${(100 * cambiati / accesi).toStringAsFixed(1)} per cento '
              'della scena: compare ma non vince');
    }
  });

  testWidgets('la card dice l\'elemento a parole, non solo col colore',
      (tester) async {
    for (final forma in FaceTrait.perCategoria(FaceCategory.formaVolto)) {
      final atteso = MianXiang.elementoDa(forma);
      if (atteso == null) continue;
      await tester.pumpWidget(MaterialApp(
        home: Center(
          child: SingleChildScrollView(
            child: FaceShareCard(
              reading: letturaCon(forma),
              costellazione: FaceConstellation.da(FaceSilhouette.contorni()),
            ),
          ),
        ),
      ));
      await tester.pump();
      expect(find.textContaining(atteso.nome), findsWidgets,
          reason: 'la card mostra il colore dell\'elemento e non lo nomina: '
              'chi non distingue i colori non riceve la lettura');
    }
  });
}
