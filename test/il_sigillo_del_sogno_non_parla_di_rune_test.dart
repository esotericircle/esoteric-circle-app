// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/maestro/la_voce_non_si_confonde.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **IL SIGILLO DEL SOGNO DI MEDORA NON PARLA DI RUNE.** Ordine ES voce 16,
/// 28 settembre 2026.
///
/// **Il fatto del fondatore**, sul telefono: il Sigillo del Sogno diceva
/// *"Porti dentro la notte la runa Berkano: lasciala parlare mentre chiudi
/// il giorno."* Il Sigillo e' di Medora dall'ordine DT voce 15, e la runa
/// viene dalla Runa del Tramonto, che e' l'arte di Caligo. La riga era
/// scritta dentro la schermata del rito, e la guardia della voce di Medora
/// dell'ordine EE voce 06 leggeva solo il corpus fisso: le frasi scritte
/// nella schermata non passavano da nessun controllo.
///
/// **Qui si leggono tutte le frasi scritte nella schermata del Sigillo**, i
/// letterali fra apici, commenti esclusi, col metro della casa,
/// `LaVoceNonSiConfonde`, lo stesso che sorveglia le risposte di Gemini:
/// nessuna parola di firma di Aura o di Caligo. Vista rossa sul codice di
/// prima: "runa" nella riga della Runa del Tramonto.
void main() {
  test('le frasi della schermata del Sigillo parlano con la voce di Medora',
      () {
    final sorgente =
        File('lib/features/rituals/dream_rite_screen.dart').readAsStringSync();
    // Via i commenti di riga, che spiegano la storia e possono nominare la
    // runa senza che nessuno la legga a schermo.
    final senzaCommenti = sorgente.split('\n').map((r) {
      final i = r.indexOf('//');
      return i < 0 ? r : r.substring(0, i);
    }).join('\n');
    final letterali = RegExp(r"'((?:[^'\\]|\\.)*)'")
        .allMatches(senzaCommenti)
        .map((m) => m.group(1)!)
        .where((t) => RegExp(r'\p{L}{3,}', unicode: true).hasMatch(t))
        .toList();
    cardinaleMinimo(letterali.length, 20,
        cosa: 'frasi scritte nella schermata del Sigillo del Sogno',
        perche: 'La schermata ha le frasi della nebbia, del cielo, del '
            'saluto e dei pulsanti: se la lettura si svuotasse, questa prova '
            'direbbe di si\' a niente.');
    final sporche = <String>[];
    for (final t in letterali) {
      // Il nome del rito, dato dal fondatore, non e' una frase con la voce di
      // un altro Maestro: "sigillo" e' parola di firma di Caligo, ma "Sigillo
      // del Sogno" e' un nome proprio. Si toglie il nome, e solo quello.
      final senzaIlNome = t.replaceAll('Sigillo del Sogno', '');
      final altrui =
          LaVoceNonSiConfonde.paroleAltruiIn(Maestro.medora, senzaIlNome);
      if (altrui.isNotEmpty) sporche.add('${altrui.join(", ")}: "$t"');
    }
    print('ORDINE ES VOCE 16: frasi della schermata lette '
        '${letterali.length}, con parole di Aura o di Caligo '
        '${sporche.length}');
    expect(sporche, isEmpty,
        reason: 'il Sigillo di Medora parla con la voce di un altro Maestro:'
            '\n${sporche.join("\n")}');
  });
}
