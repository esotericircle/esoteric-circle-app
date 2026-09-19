// ignore_for_file: avoid_print
/// GENERA LA PAGINA LEGALE PER IL WEB. Ordine EA voce 18.
///
/// **Perche' esiste.** Apple e Google chiedono, nelle schede dell'app, un
/// indirizzo pubblico dove leggere la privacy policy senza installare niente.
/// Il testo pero' vive dentro l'app, in `lib/core/legal/`: copiarlo a mano in
/// un file HTML vorrebbe dire due verita' che un giorno divergono, ed e'
/// esattamente il difetto che questo progetto evita ovunque.
///
/// **Cosa fa.** Legge gli stessi dati che la schermata monta e scrive
/// `hosting/index.html`, una pagina sola con le tre parti e le loro ancore:
/// `#privacy`, `#condizioni`, `#disclaimer`.
///
/// Si esegue dalla radice del progetto:
///
/// ```
/// dart run tool/genera_pagina_legale.dart
/// ```
library;

import 'dart:io';

import 'package:esoteric_circle/core/legal/pagina_legale.dart';

String _html(String grezzo) => grezzo
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;');

void main() {
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
        'body{margin:0;padding:24px 16px 64px;background:#0B0A1A;'
        'color:#E8E6F2;font:16px/1.6 Georgia,serif;max-width:46rem;'
        'margin-inline:auto}'
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
    b.writeln('<a href="#${parte.ancora}">${_html(parte.titolo)}</a>');
  }
  b.writeln('</nav></header>');
  for (final parte in paginaLegale) {
    b
      ..writeln('<section id="${parte.parte.ancora}">')
      ..writeln('<h1>${_html(parte.parte.titolo)}</h1>')
      ..writeln('<p class="data">Ultimo aggiornamento: '
          '${_html(parte.data)}</p>')
      ..writeln('<p>${_html(parte.apertura)}</p>');
    for (final sezione in parte.sezioni) {
      b
        ..writeln('<h2>${_html(sezione.titolo)}</h2>')
        ..writeln('<p>${_html(sezione.corpo)}</p>');
    }
    b.writeln('</section>');
  }
  b
    ..writeln('</body>')
    ..writeln('</html>');

  final dove = Directory('hosting');
  if (!dove.existsSync()) dove.createSync(recursive: true);
  final file = File('hosting/index.html');
  // **FINE RIGA UNIX, sempre**: su Windows scrivere a capo di sistema
  // farebbe apparire cambiato un file che non e' cambiato.
  file.writeAsStringSync(b.toString().replaceAll('\r\n', '\n'));
  print('PAGINA LEGALE: scritte ${paginaLegale.length} parti e '
      '${paginaLegale.fold<int>(0, (a, p) => a + p.sezioni.length)} sezioni '
      'in ${file.path}');
}
