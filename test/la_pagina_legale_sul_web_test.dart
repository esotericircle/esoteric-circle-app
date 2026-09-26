// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/legal/pagina_legale.dart';
import 'package:flutter_test/flutter_test.dart';

/// LA PAGINA LEGALE SUL WEB. Ordine EA voce 18, 20 settembre 2026.
///
/// **Perche' esiste.** Apple e Google chiedono, nelle schede dell'app, un
/// indirizzo pubblico dove leggere la privacy policy senza installare niente.
/// Il testo pero' vive dentro l'app, in `lib/core/legal/`: copiarlo a mano in
/// un file HTML vorrebbe dire due verita' che un giorno divergono, ed e'
/// il difetto che questo progetto evita ovunque.
///
/// **Perche' e' una prova e non uno strumento in `tool/`.** Ci ho provato:
/// `dart run tool/...` non compila questo progetto, il compilatore cade sulla
/// trasformazione FFI di un plugin. `flutter test` invece gira, e la pagina
/// nasce da qui.
///
/// **Cosa fa.** Compone la pagina dagli stessi dati che la schermata monta e
/// la confronta con `hosting/index.html`. Se sono diverse, la prova cade e
/// dice come rifarla:
///
/// ```
/// AGGIORNA_PAGINA_LEGALE=1 flutter test test/la_pagina_legale_sul_web_test.dart
/// ```
void main() {
  String html(String grezzo) => grezzo
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');

  String componi() {
    final b = StringBuffer()
      ..writeln('<!doctype html>')
      ..writeln('<html lang="it">')
      ..writeln('<head>')
      ..writeln('<meta charset="utf-8">')
      ..writeln('<meta name="viewport" '
          'content="width=device-width, initial-scale=1">')
      ..writeln('<title>Esoteric Circle, privacy, condizioni e disclaimer'
          '</title>')
      ..writeln('<style>')
      ..writeln(':root{color-scheme:dark}'
          'body{margin:0 auto;padding:24px 16px 64px;background:#0B0A1A;'
          'color:#E8E6F2;font:16px/1.6 Georgia,serif;max-width:46rem}'
          'h1{font-size:1.6rem;color:#E9C46A;margin:32px 0 4px}'
          'h2{font-size:1.1rem;color:#E9C46A;margin:28px 0 4px}'
          'p{margin:8px 0;color:#C9C6DC}'
          '.data{color:#8F8CA8;font-size:.9rem}'
          'nav a{color:#E9C46A;margin-right:16px}'
          'header p{color:#E8E6F2}')
      ..writeln('</style>')
      ..writeln('</head>')
      ..writeln('<body>')
      ..writeln('<header><h1>Esoteric Circle</h1>')
      ..writeln('<nav>');
    for (final parte in ParteLegale.values) {
      b.writeln('<a href="#${parte.ancora}">${html(parte.titolo)}</a>');
    }
    b.writeln('</nav></header>');
    for (final parte in paginaLegale) {
      b
        ..writeln('<section id="${parte.parte.ancora}">')
        ..writeln('<h1>${html(parte.parte.titolo)}</h1>')
        ..writeln('<p class="data">Ultimo aggiornamento: '
            '${html(parte.data)}</p>')
        ..writeln('<p>${html(parte.apertura)}</p>');
      for (final sezione in parte.sezioni) {
        b
          ..writeln('<h2>${html(sezione.titolo)}</h2>')
          ..writeln('<p>${html(sezione.corpo)}</p>');
      }
      b.writeln('</section>');
    }
    b
      ..writeln('</body>')
      ..writeln('</html>');
    return b.toString();
  }

  test('la pagina web porta gli stessi testi dell\'app', () {
    final atteso = componi();
    final file = File('hosting/index.html');
    if (Platform.environment['AGGIORNA_PAGINA_LEGALE'] == '1') {
      file.parent.createSync(recursive: true);
      file.writeAsStringSync(atteso);
      print('PAGINA LEGALE: riscritta ${file.path}, '
          '${atteso.length} caratteri');
    }
    expect(file.existsSync(), isTrue,
        reason: 'manca hosting/index.html: si rifa\' con '
            'AGGIORNA_PAGINA_LEGALE=1 flutter test '
            'test/la_pagina_legale_sul_web_test.dart');
    expect(file.readAsStringSync().replaceAll('\r\n', '\n'), atteso,
        reason: 'la pagina pubblicata non porta piu\' i testi dell\'app: '
            'si rifa\' con AGGIORNA_PAGINA_LEGALE=1 flutter test '
            'test/la_pagina_legale_sul_web_test.dart');
  });

  test('le tre parti stanno nella pagina, ognuna con la sua ancora', () {
    final testo = File('hosting/index.html').readAsStringSync();
    expect(paginaLegale.length, 3,
        reason: 'le parti della pagina legale sono ${paginaLegale.length}: '
            'privacy policy, condizioni d\'uso e disclaimer sono tre');
    var sezioni = 0;
    for (final parte in ParteLegale.values) {
      expect(testo.contains('id="${parte.ancora}"'), isTrue,
          reason: 'la pagina non ha l\'ancora #${parte.ancora}, che e\' '
              'l\'indirizzo diretto di ${parte.titolo}');
      sezioni +=
          paginaLegale.firstWhere((p) => p.parte == parte).sezioni.length;
    }
    print('ORDINE EA VOCE 18: sezioni nella pagina unica $sezioni');
    expect(sezioni, greaterThanOrEqualTo(20),
        reason: 'le sezioni sono $sezioni: qualcosa dei tre testi si e\' '
            'perso per strada');
  });

  test('e l\'hosting di Firebase la pubblica, con gli indirizzi diretti', () {
    final conf = File('firebase.json').readAsStringSync();
    expect(conf.contains('"hosting"'), isTrue,
        reason: 'firebase.json non pubblica piu\' niente sul web, e senza '
            'indirizzo le schede degli store non si compilano');
    expect(conf.contains('"public": "hosting"'), isTrue);
    for (final parte in ParteLegale.values) {
      expect(conf.contains('"source": "/${parte.ancora}"'), isTrue,
          reason: 'manca l\'indirizzo diretto /${parte.ancora}');
    }
  });
}
