import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:flutter_test/flutter_test.dart';

/// LE QUATTRO GARANZIE SUGLI AVATAR DEI TRE MAESTRI.
///
/// Gli avatar sono l'unico asset dell'app che viene disegnato a tutta altezza
/// di schermo, quindi e' l'unico dove una tela sbagliata si paga in memoria
/// invece che in spazio su disco. Queste prove tengono ferme le quattro cose
/// che rendono il lavoro del 5 agosto 2026 non reversibile per distrazione.
void main() {
  /// I tre file che l'app carica davvero. I master PNG in `brand_assets/` non
  /// entrano nel pacchetto e non sono sorvegliati qui.
  final avatar = {
    for (final m in Maestro.values) m: File(m.avatarAsset),
  };

  /// Il riquadro dei pixel non trasparenti e la misura della tela.
  Future<
      ({
        int larghezza,
        int altezza,
        int figura,
        int alto,
        int basso,
        int trasparenti
      })> misura(File f) async {
    final codec = await ui.instantiateImageCodec(await f.readAsBytes());
    final frame = await codec.getNextFrame();
    final img = frame.image;
    final dati = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
    final byte = dati!.buffer.asUint8List();
    final w = img.width;
    final h = img.height;
    var alto = -1;
    var basso = -1;
    var trasparenti = 0;
    for (var y = 0; y < h; y++) {
      var opaca = false;
      for (var x = 0; x < w; x++) {
        final a = byte[(y * w + x) * 4 + 3];
        if (a == 0) trasparenti++;
        if (a > 0) opaca = true;
      }
      if (opaca) {
        if (alto < 0) alto = y;
        basso = y;
      }
    }
    return (
      larghezza: w,
      altezza: h,
      figura: basso - alto + 1,
      alto: alto,
      basso: basso,
      trasparenti: trasparenti,
    );
  }

  test('i tre Maestri hanno la stessa altezza di figura', () async {
    // LA TOLLERANZA, E PERCHE' NON E' ZERO.
    //
    // Le tre figure escono da `tool/normalizza_avatar.py`, che le scala tutte
    // alla stessa altezza in pixel: sulla carta la differenza e' zero. Quello
    // che puo' spostarla di un pelo e' il giro attraverso il WebP: il
    // ricampionamento Lanczos lascia sui bordi pixel quasi trasparenti, e
    // basta che uno di quelli cada sopra o sotto la soglia perche' il riquadro
    // opaco cambi di una riga. Sei pixel su 1658 sono lo 0,36 per cento:
    // assorbono quel rumore e NON assorbono un errore di normalizzazione, che
    // si misura in decine o centinaia di pixel. Se questa prova diventa rossa,
    // non si allarga la tolleranza: si guarda cosa e' successo alla figura.
    const tolleranza = 6;

    final misure = <Maestro, int>{};
    for (final e in avatar.entries) {
      misure[e.key] = (await misura(e.value)).figura;
    }
    final valori = misure.values.toList();
    final minimo = valori.reduce((a, b) => a < b ? a : b);
    final massimo = valori.reduce((a, b) => a > b ? a : b);
    expect(massimo - minimo, lessThanOrEqualTo(tolleranza),
        reason: 'Le figure non hanno piu\' la stessa altezza: '
            '${misure.map((m, v) => MapEntry(m.displayName, v))}. '
            'Affiancati nello stesso riquadro uno dei Maestri sembrera\' piu\' '
            'piccolo degli altri. Rigenera con tool/normalizza_avatar.py.');
  });

  test('i tre Maestri poggiano sulla stessa linea', () async {
    // Stessa ragione della tolleranza sopra: e' il rumore del bordo, non
    // l'inquadratura.
    const tolleranza = 6;
    final piedi = <Maestro, int>{};
    for (final e in avatar.entries) {
      piedi[e.key] = (await misura(e.value)).basso;
    }
    final valori = piedi.values.toList();
    final minimo = valori.reduce((a, b) => a < b ? a : b);
    final massimo = valori.reduce((a, b) => a > b ? a : b);
    expect(massimo - minimo, lessThanOrEqualTo(tolleranza),
        reason: 'I piedi non sono piu\' alla stessa quota: '
            '${piedi.map((m, v) => MapEntry(m.displayName, v))}. '
            'Affiancati, le figure sembreranno sospese a mezz\'aria.');
  });

  test('ogni avatar ha ancora il canale alpha e non e\' diventato opaco',
      () async {
    for (final e in avatar.entries) {
      final m = await misura(e.value);
      // La figura non riempie la tela: attorno c'e' sempre trasparenza vera.
      // Se qualcuno risalva l'asset appiattito su un fondo, questo conteggio
      // crolla a zero e il Maestro compare dentro un rettangolo colorato in
      // ogni schermata che lo mostra.
      final area = m.larghezza * m.altezza;
      final quota = m.trasparenti / area;
      expect(quota, greaterThan(0.10),
          reason: '${e.key.displayName} ha solo il '
              '${(quota * 100).toStringAsFixed(1)} per cento di pixel del '
              'tutto trasparenti: l\'asset e\' stato appiattito su un fondo. '
              'Nel Santuario e nella chat comparirebbe un rettangolo dietro '
              'la figura.');
    }
  });

  test('nessun avatar supera il peso dichiarato', () async {
    // LA SOGLIA, E COSA PROTEGGE.
    //
    // Prima del 5 agosto 2026 i tre pesavano 619, 584 e 517 kB in WebP, e i
    // master PNG in brand_assets arrivavano a 6,4 MB. Oggi il piu' pesante e'
    // Medora con 258 kB. 320.000 byte lasciano spazio a un ridisegno piu'
    // ricco senza lasciare rientrare dalla finestra il mezzo megabyte di
    // prima. Base 1000, come tutti i pesi di questo progetto.
    const massimo = 320000;
    for (final e in avatar.entries) {
      final peso = e.value.lengthSync();
      expect(peso, lessThanOrEqualTo(massimo),
          reason: '${e.key.displayName} pesa $peso byte, oltre i $massimo '
              'dichiarati. Se l\'asset e\' cambiato per davvero, rigeneralo '
              'con tool/normalizza_avatar.py, che salva in WebP di qualita\' '
              '88 come le sei famiglie.');
    }
  });

  test('nessun avatar supera la tela dichiarata', () async {
    // LA TELA, E PERCHE' E' PICCOLA.
    //
    // **Un'immagine decodificata occupa larghezza per altezza per 4 byte in
    // RAM, qualunque sia la compressione del file.** A 2056x3060, la tela di
    // prima, i tre avatar tenevano 75,5 MB di memoria su un telefono. A
    // 1142x1700 ne tengono 23,3: cinquantadue megabyte in meno, ed e' il
    // risultato che conta di quel giro, piu' dei file piu' leggeri.
    //
    // 1700 non e' un numero tondo scelto a caso. L'altezza a cui l'app disegna
    // davvero un avatar e' stata misurata montando le schermate vere: il
    // massimo e' 1633 px fisici, il busto centrale del Santuario su uno
    // schermo di 360x900 punti logici a rapporto di pixel 4. **Quel massimo
    // non e' un tetto, e' una retta:** il busto del Santuario non ha una
    // misura fissa, cresce con l'altezza dello schermo. Il margine del 4 per
    // cento copre uno schermo alto fino a 931 punti logici a rapporto 4.
    //
    // Chi alza questi numeri paga memoria che nessuno vede. Chi li abbassa fa
    // disegnare gli avatar ingranditi sui telefoni alti.
    const telaLarghezza = 1142;
    const telaAltezza = 1700;

    for (final e in avatar.entries) {
      final m = await misura(e.value);
      expect(m.larghezza, lessThanOrEqualTo(telaLarghezza),
          reason: '${e.key.displayName} e\' largo ${m.larghezza}, oltre i '
              '$telaLarghezza dichiarati.');
      expect(m.altezza, lessThanOrEqualTo(telaAltezza),
          reason: '${e.key.displayName} e\' alto ${m.altezza}, oltre i '
              '$telaAltezza dichiarati. In RAM costa '
              '${(m.larghezza * m.altezza * 4 / 1000000).toStringAsFixed(1)} MB '
              'da decodificato invece di '
              '${(telaLarghezza * telaAltezza * 4 / 1000000).toStringAsFixed(1)} MB, '
              'e l\'app non lo disegna mai cosi\' grande.');
    }
  });
}
