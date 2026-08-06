import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/features/maestri/widgets/maestro_bust.dart';
import 'package:flutter_test/flutter_test.dart';

/// IL VOLTO DICHIARATO DEVE STARE DENTRO LA FIGURA DISEGNATA.
///
/// `MaestroBust.facePoints` tiene tre numeri per Maestro, in frazioni della
/// tela dell'asset: la cima della testa, la linea del colletto e il centro
/// orizzontale del viso. Da li' esce l'ingrandimento del ritratto tondo.
///
/// **Sono numeri in codice che descrivono un fatto dell'immagine, quindi
/// scadono quando l'immagine cambia, e scadono in silenzio.** E' successo il 5
/// agosto 2026: gli avatar sono stati rigenerati su una tela nuova, con le
/// figure portate alla stessa altezza e i piedi sulla stessa linea, e da quel
/// momento le vecchie frazioni indicavano un punto che sull'immagine nuova non
/// era piu' il volto. Nessuna prova se ne era accorta, perche' nessuna
/// guardava le due cose insieme.
///
/// Questa le guarda insieme. Non giudica se il taglio e' bello, che e' un
/// giudizio di Mauro sulle anteprime: pretende che la fascia dichiarata cada
/// dentro la figura opaca e nella sua meta' alta, che e' dove sta una testa.
/// Chi cambia un avatar senza rimisurare qui trova rosso invece di un volto
/// storto.
void main() {
  /// Il riquadro dei pixel non trasparenti dell'asset, in pixel.
  Future<({int larghezza, int altezza, int alto, int basso, int sinistra,
      int destra})> riquadro(Maestro m) async {
    final codec =
        await ui.instantiateImageCodec(await File(m.avatarAsset).readAsBytes());
    final frame = await codec.getNextFrame();
    final img = frame.image;
    final dati = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
    final byte = dati!.buffer.asUint8List();
    final w = img.width;
    final h = img.height;
    var alto = -1, basso = -1, sinistra = w, destra = -1;
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        if (byte[(y * w + x) * 4 + 3] == 0) continue;
        if (alto < 0) alto = y;
        basso = y;
        if (x < sinistra) sinistra = x;
        if (x > destra) destra = x;
      }
    }
    return (
      larghezza: w,
      altezza: h,
      alto: alto,
      basso: basso,
      sinistra: sinistra,
      destra: destra
    );
  }

  for (final m in Maestro.values) {
    test('la fascia del volto di ${m.displayName} cade dentro la sua figura',
        () async {
      final p = MaestroBust.facePoints[m]!;
      final r = await riquadro(m);

      final cimaTesta = p.headTopY * r.altezza;
      final colletto = p.collarY * r.altezza;
      final centroViso = p.centerX * r.larghezza;

      // 1. La fascia sta nel verso giusto.
      expect(colletto, greaterThan(cimaTesta),
          reason: '${m.displayName}: il colletto dichiarato sta sopra la cima '
              'della testa. Con una fascia negativa l\'ingrandimento del tondo '
              'va all\'incontrario.');

      // 2. La cima della testa non sta sopra il primo pixel disegnato. Sopra
      //    la figura c\'e\' solo aria: inquadrare li\' significa mettere il
      //    vuoto al posto del viso.
      expect(cimaTesta, greaterThanOrEqualTo(r.alto.toDouble()),
          reason: '${m.displayName}: la cima della testa dichiarata e\' a '
              '${cimaTesta.toStringAsFixed(0)} px, sopra il primo pixel '
              'disegnato che sta a ${r.alto}. Il tondo inquadrerebbe l\'aria '
              'sopra il Maestro. Rimisura headTopY sull\'asset nuovo.');

      // 3. Il colletto sta nella META\' ALTA della figura. Una testa sta in
      //    cima: se il colletto dichiarato scende sotto la meta\', la fascia
      //    non e\' piu\' un volto ma mezzo Maestro, e nel tondo entra il busto
      //    invece della faccia.
      final mezzeria = r.alto + (r.basso - r.alto) / 2;
      expect(colletto, lessThan(mezzeria),
          reason: '${m.displayName}: il colletto dichiarato e\' a '
              '${colletto.toStringAsFixed(0)} px, sotto la mezzeria della '
              'figura (${mezzeria.toStringAsFixed(0)}). Nel tondo entrerebbe '
              'il busto invece del volto. Rimisura collarY sull\'asset nuovo.');

      // 4. Il centro del viso cade dentro la larghezza della figura.
      expect(centroViso, greaterThanOrEqualTo(r.sinistra.toDouble()),
          reason: '${m.displayName}: il centro del viso e\' a sinistra della '
              'figura.');
      expect(centroViso, lessThanOrEqualTo(r.destra.toDouble()),
          reason: '${m.displayName}: il centro del viso e\' a destra della '
              'figura.');
    });
  }

  for (final m in Maestro.values) {
    test('${m.displayName} ha ancora l\'inquadratura a cui le frazioni '
        'appartengono', () async {
      // LA PROVA CHE PRENDE IL DIFETTO VERO.
      //
      // Chiedere che la fascia stia dentro la figura non basta, ed e\' stato
      // misurato: le frazioni di prima del 5 agosto 2026, applicate agli asset
      // nuovi, cadevano ancora dentro la figura e sarebbero passate. Quello
      // che era cambiato non era la fascia, era l\'INQUADRATURA sotto.
      //
      // Qui si confronta l\'inquadratura vera dell\'asset con quella
      // dichiarata accanto ai facePoints. La tolleranza e\' la stessa del
      // rumore di bordo delle altre prove.
      const tolleranza = 6;
      final r = await riquadro(m);

      expect(r.larghezza, MaestroBust.faceRefTela,
          reason: '${m.displayName}: la tela e\' ${r.larghezza} invece di '
              '${MaestroBust.faceRefTela}. I facePoints sono frazioni di una '
              'tela diversa da questa: vanno rimisurati.');
      expect(r.altezza, MaestroBust.faceRefTelaAltezza,
          reason: '${m.displayName}: la tela e\' alta ${r.altezza} invece di '
              '${MaestroBust.faceRefTelaAltezza}.');
      expect((r.alto - MaestroBust.faceRefFiguraCima).abs(),
          lessThanOrEqualTo(tolleranza),
          reason: '${m.displayName}: la figura comincia a ${r.alto} invece di '
              '${MaestroBust.faceRefFiguraCima}. L\'inquadratura e\' cambiata, '
              'quindi headTopY e collarY indicano un altro punto del disegno. '
              'Rimisurali sull\'asset nuovo e aggiorna anche questi quattro '
              'numeri di riferimento.');
      expect((r.basso - MaestroBust.faceRefFiguraPiedi).abs(),
          lessThanOrEqualTo(tolleranza),
          reason: '${m.displayName}: i piedi stanno a ${r.basso} invece di '
              '${MaestroBust.faceRefFiguraPiedi}.');
    });
  }

  test('la cima della testa e il centro del viso sono vicini fra loro',
      () async {
    // IL CONTROLLO DI SANITA\' DELLA NORMALIZZAZIONE, SUI DUE NUMERI A CUI SI
    // APPLICA.
    //
    // I tre avatar hanno la stessa altezza di figura e i piedi sulla stessa
    // linea, quindi le teste finiscono quasi alla stessa quota e i visi quasi
    // sullo stesso asse. Su `headTopY` e su `centerX` lo scostamento deve
    // essere piccolo, e se non lo e\' vuol dire che la normalizzazione non ha
    // funzionato: in quel caso non si aggiustano i numeri per far passare la
    // prova, si guarda la figura.
    //
    // **`collarY` NON e\' in questo controllo, e la ragione e\' misurata.** La
    // fascia fra cima della testa e colletto non descrive dove sta la testa,
    // descrive quanto e\' GRANDE, e le tre teste sono disegnate di grandezze
    // diverse: nella tela da 1700 px la testa di Caligo misura circa 258 px,
    // quella di Medora 238, quella di Aura 221. Chiedere che i tre colletti
    // stessero vicini significava chiedere che i tre Maestri avessero la testa
    // della stessa taglia, e il 6 agosto 2026 quella pretesa ha quasi bloccato
    // la correzione che rimpiccioliva la fascia di Aura per farle il volto
    // grande come quello di Medora. Il numero che conta su questa voce non e\'
    // la vicinanza delle fasce ma il RISULTATO nel tondo, e lo sorveglia
    // `test/il_volto_nel_tondo_test.dart`.
    //
    // Sulla soglia: lo scarto vero oggi e\' 0,010 sulla cima e 0,005 sul
    // centro. 0,05 sta lontano dai valori veri di proposito, perche' una
    // soglia appoggiata addosso al dato cade sul rumore della virgola mobile,
    // ed e\' gia\' successo qui con 0,040000000000000036 contro 0,04. Un rosso
    // arrivato per caso non e\' una misura.
    const scartoMassimo = 0.05;

    double spanDi(double Function(MaestroFacePoint p) quale) {
      final v = Maestro.values
          .map((m) => quale(MaestroBust.facePoints[m]!))
          .toList();
      return v.reduce((a, b) => a > b ? a : b) -
          v.reduce((a, b) => a < b ? a : b);
    }

    expect(spanDi((p) => p.headTopY), lessThanOrEqualTo(scartoMassimo),
        reason: 'Le cime delle teste dichiarate divergono piu\' di '
            '$scartoMassimo: con le figure allineate non dovrebbero. '
            'Controlla la normalizzazione prima dei numeri.');
    expect(spanDi((p) => p.centerX), lessThanOrEqualTo(scartoMassimo),
        reason: 'I centri del viso dichiarati divergono piu\' di '
            '$scartoMassimo: con le figure centrate non dovrebbero.');
  });
}
