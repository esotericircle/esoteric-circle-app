// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/responsi/confine_del_responso.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'le_frasi_dei_corpora_in_attesa.dart';

/// **IL CONFINE SUI DODICI CORPORA, E IL CONFINE COM'ERA.** Ordine EV, voce
/// EV.07, 1 ottobre 2026.
///
/// L'Architetto ha corretto i corpora e ha deciso che il confine del
/// responso torna com'era prima dell'ordine EU: l'eccezione per il futuro di
/// un gesto scelto ("in cui partirai", "a che ora tornerai") non c'e' piu'.
/// Tre pretese:
///
/// 1. il confine non porta piu' l'eccezione dell'ordine EU: una frase col
///    futuro in una relativa e' una previsione come le altre;
/// 2. ogni voce dei dodici corpora (le quattro parti di ogni scheda) passa il
///    confine, salvo le frasi dichiarate una per una in
///    `le_frasi_dei_corpora_in_attesa.dart`, che aspettano i testi
///    dell'Architetto;
/// 3. quell'elenco dice il vero: ogni frase dichiarata c'e' ancora nel suo
///    corpus ed e' ancora segnata. Quando l'Architetto la riscrive, l'elenco
///    va accorciato, e la guardia lo pretende.
void main() {
  final cartella = Directory('docs/corpus/eu');
  final campo = RegExp(r'^- (Risposta|Che cosa fare)[^:]*: (.*)$');

  test('il confine non porta piu\' l\'eccezione dell\'ordine EU', () {
    final sorgente =
        File('lib/core/responsi/confine_del_responso.dart').readAsStringSync();
    expect(sorgente.contains('futuroDellaTuaScelta'), isFalse,
        reason: 'il confine porta ancora l\'eccezione per il futuro di un '
            'gesto scelto: l\'Architetto ha deciso che non c\'e\' piu\'');
    expect(
        ConfineDelResponso.violazioni(
            'Decidi già adesso a che ora tornerai a casa.'),
        isNotEmpty,
        reason: 'il futuro in una relativa passa ancora il confine');
  });

  test('ORDINE EV VOCE 07: i dodici corpora passano il confine', () {
    final corpora = [
      for (final f in cartella.listSync())
        if (f.path.contains('oroscopo_eu_') && f.path.endsWith('.md'))
          f as File,
    ];
    cardinaleMinimo(corpora.length, 12, cosa: 'corpora dell\'ordine EU');
    var voci = 0;
    final fuori = <String>[];
    final segnate = <String>{};
    for (final f in corpora) {
      final nome = f.uri.pathSegments.last;
      final righe = f.readAsLinesSync();
      for (var i = 0; i < righe.length; i++) {
        final m = campo.firstMatch(righe[i]);
        if (m == null) continue;
        voci++;
        for (final v in ConfineDelResponso.violazioni(m.group(2)!)) {
          if (eInAttesaDellArchitetto(v.intorno)) {
            segnate.add(v.intorno.trim());
          } else {
            fuori.add('$nome riga ${i + 1}: $v');
          }
        }
      }
    }
    cardinaleMinimo(voci, 6000, cosa: 'voci dei dodici corpora');
    print('ORDINE EV VOCE 07: voci dei dodici corpora $voci, fuori dal '
        'confine ${fuori.length}, in attesa dell\'Architetto '
        '${segnate.length} su ${frasiDeiCorporaInAttesa.length} dichiarate');
    expect(fuori, isEmpty,
        reason: 'frasi dei corpora fuori dal confine e non dichiarate:\n'
            '${fuori.join('\n')}');
    final nonPiuVere = [
      for (final f in frasiDeiCorporaInAttesa)
        if (!segnate.contains(f.frase))
          '${f.corpus} riga ${f.riga}: ${f.frase}',
    ];
    expect(nonPiuVere, isEmpty,
        reason: 'frasi dichiarate in attesa che non ci sono piu\' o non sono '
            'piu\' segnate: l\'Architetto le ha riscritte, si tolgono '
            'dall\'elenco:\n${nonPiuVere.join('\n')}');
  });
}
