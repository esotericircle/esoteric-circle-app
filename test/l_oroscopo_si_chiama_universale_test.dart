// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/arts/art_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **L'OROSCOPO SI CHIAMA UNIVERSALE. Ordine FC voce 01, 4 ottobre 2026.**
///
/// Il fondatore: *"il nome oroscopo personalizzato vorrei cambiarlo"*, e la
/// sua scelta: *"Oroscopo universale"*. Ovunque la persona legge il nome
/// dell'arte si legge "Oroscopo Universale"; gli identificativi (`horoscope`,
/// le chiavi, il gesto `oroscopo`) non cambiano.
///
/// **Come si cerca, perche' una ricerca stretta torna piccola.** La prova
/// ricompone le stringhe come le legge la persona: in ogni file di `lib`
/// toglie i commenti, unisce le stringhe adiacenti e quelle concatenate col
/// `+`, le due forme di virgolette, maiuscole e minuscole, e cerca
/// "oroscopo" seguito da "personalizzat" entro due parole. Cade col file e
/// col testo trovato.
void main() {
  /// Il testo a video di un file: le stringhe letterali, unite come le
  /// legge la persona, senza i commenti.
  String testoAVideo(String sorgente) {
    final senzaCommenti = sorgente.split('\n').map((r) {
      final i = r.indexOf('//');
      // Un `//` dentro una stringa (un indirizzo) non e' un commento.
      if (i < 0) return r;
      final prima = r.substring(0, i);
      final apici = "'".allMatches(prima).length + '"'.allMatches(prima).length;
      return apici.isOdd ? r : prima;
    }).join('\n');
    final stringhe =
        RegExp(r"'((?:[^'\\\n]|\\.)*)'" '|' r'"((?:[^"\\\n]|\\.)*)"')
            .allMatches(senzaCommenti);
    // Le stringhe adiacenti o unite col `+` si leggono di fila: unite con uno
    // spazio, la ricerca le attraversa.
    return stringhe.map((m) => m.group(1) ?? m.group(2) ?? '').join(' ');
  }

  final vecchio = RegExp(r'oroscop\w*(?:\W+\w+){0,2}?\W+personalizzat',
      caseSensitive: false);

  test('FC.01: nessun testo a video dice "Oroscopo Personalizzato"', () {
    final file = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .toList();
    cardinaleMinimo(file.length, 800, cosa: 'file di lib guardati');
    final trovati = <String>[];
    var conOroscopo = 0;
    for (final f in file) {
      final testo = testoAVideo(f.readAsStringSync());
      if (RegExp('oroscop', caseSensitive: false).hasMatch(testo)) {
        conOroscopo++;
      }
      for (final m in vecchio.allMatches(testo)) {
        trovati.add('${f.path}: "${m.group(0)}"');
      }
    }
    cardinaleMinimo(conOroscopo, 20,
        cosa: 'file con la parola oroscopo nei testi a video');
    final arte = ArtCatalog.all.firstWhere((a) => a.id == 'horoscope');
    print('ORDINE FC VOCE 01: file di lib ${file.length}, con "oroscopo" nei '
        'testi $conOroscopo, col nome vecchio ${trovati.length}'
        '${trovati.isEmpty ? '' : ': ${trovati.join('; ')}'}; il catalogo '
        'dice "${arte.title}"');
    expect(trovati, isEmpty, reason: trovati.join('\n'));
    expect(arte.title, 'Oroscopo Universale');
    expect(arte.id, 'horoscope', reason: 'l\'identificativo non si tocca');
  });
}
