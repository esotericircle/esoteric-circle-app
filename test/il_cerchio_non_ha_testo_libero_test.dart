// ignore_for_file: avoid_print
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **ZERO TESTO LIBERO NEL MOTORE SOCIALE, ordine EY voce 10 punto 1.**
///
/// In nessun punto del motore sociale una persona scrive una frase che
/// un'altra leggera'. La guardia enumera ogni campo di testo delle schermate
/// sociali (`lib/features/cerchio`) e cade se ne compare uno che non e' una
/// delle tre identita' dichiarate qui sotto: il proprio nome nel Cerchio, il
/// sigillo di un'altra persona, il codice da inquadrare scritto a mano. Sono
/// identita', non messaggi: nessuno le legge come frase, e ognuna ha una
/// lunghezza massima e un filtro di caratteri. Cade anche se una porta sociale
/// del server accetta un campo di testo libero da recapitare.
void main() {
  const ammessi = {
    // Il proprio nome, con le regole del nome (venti caratteri al massimo).
    'profilo_campo_nome': 20,
    // Il sigillo di un'altra persona: quattro caratteri.
    'invita_campo_sigillo': 4,
    // Il codice da inquadrare, scritto a mano: sei caratteri.
    'invita_campo_codice': 6,
    // Ordine FD voce 06.4: la ricerca nella rubrica. Filtra l'elenco sul
    // telefono e non esce mai di li': nessuna porta la riceve.
    'rubrica_ricerca': 40,
  };

  test('GUARDIA EY.10: nessun campo di testo libero nelle schermate sociali',
      () {
    final file = Directory('lib/features/cerchio')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .toList();
    var campi = 0;
    final colpevoli = <String>[];
    for (final f in file) {
      final s = f.readAsStringSync();
      for (final m in RegExp(
              r'\b(TextField|TextFormField|EditableText|CupertinoTextField)\(')
          .allMatches(s)) {
        campi++;
        final dopo = s.substring(m.start, (m.start + 700).clamp(0, s.length));
        final chiave = RegExp(r"Key\('(\w+)'\)").firstMatch(dopo)?.group(1);
        final massimo = int.tryParse(
            RegExp(r'maxLength: (\d+)').firstMatch(dopo)?.group(1) ?? '');
        if (chiave == null || !ammessi.containsKey(chiave)) {
          colpevoli.add('${f.path}: campo $chiave non dichiarato');
        } else if (massimo == null || massimo > ammessi[chiave]!) {
          colpevoli.add('${f.path}: $chiave senza la sua lunghezza massima');
        }
      }
    }
    cardinaleMinimo(file.length, 8,
        cosa: 'file delle schermate sociali',
        perche: 'Su una cartella vuota nessun campo sarebbe colpevole.');
    print('EY.10 TESTO LIBERO: ${file.length} file sociali, $campi campi, '
        'colpevoli ${colpevoli.length}');
    expect(campi, ammessi.length);
    expect(colpevoli, isEmpty);
  });

  test('nessuna porta sociale del server recapita un testo scritto', () {
    final porte =
        File('functions/src/il_cerchio_sociale.ts').readAsStringSync();
    // I campi del corpo che le porte leggono: nessuno e' un testo da
    // consegnare a un'altra persona.
    final letti = {
      for (final m in RegExp(r'request\.data\?\.(\w+)').allMatches(porte))
        m.group(1)!,
      for (final m in RegExp(r'corpo\.(\w+)').allMatches(porte)) m.group(1)!,
    };
    const vietati = {'testo', 'messaggio', 'nota', 'frase', 'commento'};
    print('EY.10 CAMPI LETTI DALLE PORTE SOCIALI: ${letti.toList()..sort()}');
    expect(letti.intersection(vietati), isEmpty);
  });
}
