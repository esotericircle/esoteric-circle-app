import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

/// **L'ORO DELL'OROSCOPO.** Ordine ER voce 07, 27 settembre 2026.
///
/// Il fondatore: *"la scheda dell'oroscopo, l'emblema sembra più bronzo che
/// oro"*. Misurato dall'Architetto nello spazio Lab sui pixel dell'oro:
/// luminosita' 41,8 e rosso 9,9, contro 51,2 e 5,5 dei Tarocchi. Corretto sul
/// PC del fondatore senza toccare lo sfondo, *"Sì, salvalo"*. Questi sono i
/// tre file corretti: un sfondo vecchio rimesso per sbaglio (una copia da un
/// ramo, un ripristino) torna bronzo, e questa prova lo dice.
void main() {
  const corretti = {
    'Oroscopo-Vert-1.webp': 'a3b34daa4ee33454c856890b7f5992c1d886d4bc',
    'Oroscopo-Square-1.webp': '365574e4fa9aacf0847a0fe18b854fc4b30b409f',
    'Oroscopo-Oriz-1.webp': 'e419b2d688a81d8346d61854679467105cf3cfe0',
  };

  test('i tre sfondi dell\'Oroscopo sono quelli con l\'oro corretto', () {
    for (final e in corretti.entries) {
      final file = File('assets/schede/${e.key}');
      expect(file.existsSync(), isTrue, reason: 'manca ${e.key}');
      expect(sha1.convert(file.readAsBytesSync()).toString(), e.value,
          reason: '${e.key} non e\' quello con l\'oro corretto: l\'emblema '
              'torna bronzo');
    }
  });
}
