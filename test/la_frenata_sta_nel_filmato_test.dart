import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:esoteric_circle/features/tarot/la_scena_della_stesa_in_video.dart';
import 'package:flutter_test/flutter_test.dart';

import 'sorgenti_di_lib.dart';

/// **LA FRENATA DI MEDORA STA NEL FILMATO, NON NEL LETTORE.** Il fondatore,
/// 14 ottobre 2026: *"Medora deve fermarsi poco prima della fine del video,
/// quando ha la mano sul petto e non quando la allontana. Cerca di rallentare
/// l'ultimo secondo in modo che non si fermi di botto"*; e sulla 2310: *"come
/// se avesse un movimento piu' naturale di fermata"*.
///
/// LAPIDE: `la_scena_si_ferma_col_rallentamento_test.dart`, che provava la
/// formula della rampa di `setPlaybackSpeed`. La formula era giusta e la
/// prova verde, ma sul Realme il lettore Android applicava ogni velocita'
/// circa mezzo secondo dopo, e la frenata vera durava meno di mezzo secondo
/// (`docs/collaudo/FS/aggiunta_video/a5_la_frenata_nel_filmato.txt`). Una
/// prova sulla formula non poteva vederlo.
///
/// Qui si sorveglia cio' che arriva davvero al telefono: il file, con la sua
/// impronta (quella misurata, il cui profilo di frenata sta nel documento),
/// la sua durata e il suo numero di fotogrammi scritti dentro l'mp4, e un
/// lettore che non torna a cambiare velocita' o a saltare.
void main() {
  final file = File(ScenaDellaStesaInVideo.filmato);

  test('il filmato e\' quello misurato, con la sua impronta', () {
    expect(file.existsSync(), isTrue, reason: 'manca ${file.path}');
    final dichiarata =
        RegExp(r'"nota_video_della_stesa": "[^"]*SHA-256 ([0-9a-f]{64})')
            .firstMatch(File('docs/stato_asset.json').readAsStringSync());
    expect(dichiarata, isNotNull,
        reason: 'la nota del video in docs/stato_asset.json non dichiara la '
            'sua impronta');
    expect(
        sha256.convert(file.readAsBytesSync()).toString(), dichiarata!.group(1),
        reason: 'il file non e\' quello misurato nel documento della frenata');
  });

  test('durata e fotogrammi scritti nel file sono quelli del codice', () {
    final b = file.readAsBytesSync();
    final mvhd = _scatola(b, 'mvhd');
    expect(mvhd, isNotNull, reason: 'nessuna scatola mvhd nel file');
    final d = ByteData.sublistView(b);
    final versione = b[mvhd!];
    final scala = d.getUint32(mvhd + (versione == 1 ? 20 : 12));
    final durata =
        versione == 1 ? d.getUint64(mvhd + 24) : d.getUint32(mvhd + 16);
    final microsecondi = durata * 1000000 ~/ scala;
    expect((microsecondi - ScenaDellaStesaInVideo.durata.inMicroseconds).abs(),
        lessThan(30000),
        reason: 'il file dura $microsecondi microsecondi, il codice dice '
            '${ScenaDellaStesaInVideo.durata.inMicroseconds}');
    final stsz = _scatola(b, 'stsz');
    expect(stsz, isNotNull);
    expect(d.getUint32(stsz! + 8), ScenaDellaStesaInVideo.fotogrammi,
        reason: 'i fotogrammi del video nel file non sono quelli del codice');
  });

  test('il lettore della scena non cambia velocita\' e non salta', () {
    final codice = senzaCommenti(
        File('lib/features/tarot/la_scena_della_stesa_in_video.dart')
            .readAsStringSync());
    expect(codice.contains('setPlaybackSpeed('), isFalse,
        reason: 'la frenata a tempo d\'esecuzione e\' tornata: su Android '
            'arriva mezzo secondo tardi');
    expect(codice.contains('seekTo('), isFalse,
        reason: 'un salto nel filmato scatta su Android');
  });
}

/// L'inizio del contenuto della prima scatola [tipo] dell'mp4, subito dopo
/// il suo nome: le scatole stanno una dentro l'altra, e il nome di quattro
/// lettere basta a trovarle in un file di pochi megabyte.
int? _scatola(Uint8List b, String tipo) {
  final nome = ascii.encode(tipo);
  for (var i = 4; i + 4 <= b.length; i++) {
    if (b[i] == nome[0] &&
        b[i + 1] == nome[1] &&
        b[i + 2] == nome[2] &&
        b[i + 3] == nome[3]) {
      return i + 4;
    }
  }
  return null;
}
