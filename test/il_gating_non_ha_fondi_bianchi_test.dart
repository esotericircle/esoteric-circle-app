import 'dart:io';

import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';

/// IL GATING NON PASSA DALLE SNACKBAR DI SISTEMA, ordine L voce 1.
///
/// L'avviso premium col fondo bianco era una SnackBar coi colori di fabbrica
/// (superficie inversa chiara). Il gating passa dalla bolla del Maestro,
/// `showUpgradeInvite`, e le poche SnackBar di servizio rimaste vestono il
/// buio dell'app dal tema, mai il bianco di fabbrica.
void main() {
  test('nessuna SnackBar in tutta l\'app parla di piani o abbonamenti', () {
    // L'ENUMERAZIONE sul sorgente: ogni chiamata showSnackBar il cui corpo
    // bilanciato nomina il piano, l'abbonamento o il Premium e' un gating
    // travestito da avviso di sistema, e la prova cade nominando il file.
    int? chiusaDi(String s, int aperta) {
      var profondita = 0;
      String? inStringa;
      for (var j = aperta; j < s.length; j++) {
        final c = s[j];
        if (inStringa != null) {
          if (c == r'\') {
            j++;
          } else if (c == inStringa) {
            inStringa = null;
          }
        } else if (c == '/' && j + 1 < s.length && s[j + 1] == '/') {
          final fine = s.indexOf('\n', j);
          if (fine == -1) return null;
          j = fine;
        } else if (c == "'" || c == '"') {
          inStringa = c;
        } else if (c == '(') {
          profondita++;
        } else if (c == ')') {
          profondita--;
          if (profondita == 0) return j;
        }
      }
      return null;
    }

    final spie = ['premium', 'abbonati', 'abbonamento', 'piano superiore'];
    final colpe = <String>[];
    for (final f in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      final s = f.readAsStringSync();
      final percorso = f.path.replaceAll(r'\', '/');
      for (final m in RegExp(r'showSnackBar\s*\(').allMatches(s)) {
        final aperta = s.indexOf('(', m.start);
        final chiusa = chiusaDi(s, aperta);
        if (chiusa == null) continue;
        final corpo = s.substring(aperta, chiusa).toLowerCase();
        for (final spia in spie) {
          if (corpo.contains(spia)) {
            colpe.add('$percorso:${s.substring(0, m.start).split('\n').length} '
                '(parla di "$spia")');
            break;
          }
        }
      }
    }
    expect(colpe, isEmpty,
        reason: 'queste SnackBar di sistema fanno gating: il gating passa '
            'dalla bolla del Maestro, showUpgradeInvite.\n${colpe.join('\n')}');
  });

  test('le SnackBar di servizio vestono il buio dal tema, mai il bianco', () {
    final tema = AppTheme.dark().snackBarTheme;
    final fondo = tema.backgroundColor;
    expect(fondo, isNotNull,
        reason: 'Il tema non veste le SnackBar: tornano alla superficie '
            'inversa di fabbrica, che sul tema scuro e\' chiara.');
    expect(fondo!.computeLuminance(), lessThan(0.25),
        reason: 'Il fondo delle SnackBar e\' chiaro: l\'avviso col fondo '
            'bianco e\' tornato.');
  });
}
