import 'dart:io';

import 'package:esoteric_circle/core/config/la_regione_dei_dati.dart';
import 'package:esoteric_circle/core/viaggio/la_domanda_capita.dart';
import 'package:esoteric_circle/core/viaggio/il_segno_dell_animale.dart';
import 'package:esoteric_circle/core/viaggio/la_scena_dal_modello.dart';
import 'package:esoteric_circle/services/ai/firebase_maestro_ai_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'sorgenti_di_lib.dart';

/// **I MODELLI STANNO NELLA REGIONE DEI DATI.** Ordine DJ voce 03,
/// 13 settembre 2026.
///
/// *"Regola permanente che entra da qui in avanti, per tutta l'app: il
/// runtime chiama solo modelli disponibili nella regione dove stanno i dati,
/// e chi scrive un ordine verifica la disponibilita' regionale prima di
/// nominare un modello."*
///
/// **Si guardano tutti i nomi di modello scritti in `lib` e nel server**, non
/// le costanti che si sanno: un modello nuovo scritto in una schermata sola
/// sarebbe la stessa violazione. Ognuno deve stare fra i modelli verificati in
/// `LaRegioneDeiDati`, dove un modello entra solo dopo una chiamata vera nella
/// regione. **E ogni chiamata a Vertex dell'app parte dalla regione dei
/// dati**, mai da `global`.
void main() {
  test('OGNI MODELLO NOMINATO IN lib E NEL SERVER E VERIFICATO NELLA REGIONE '
      'DEI DATI, e nessuna chiamata parte da global', () {
    // **UN MODELLO HA LA VERSIONE E LA SUA VARIANTE**, `gemini-2.5-flash`:
    // la prima stesura prendeva anche `gemini-2.5`, che e' il prefisso della
    // famiglia con cui si decide come spegnere il ragionamento.
    final nome = RegExp(
        r'''['"](gemini-[0-9][0-9.]*-[a-z][0-9a-z.\-]*|imagen-[0-9a-z.\-]+)['"]''');
    final sorgenti = <File>[
      ...sorgentiDiLib(),
      ...Directory('functions/src')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.ts') && !f.path.contains('.test.')),
    ];
    final trovati = <String, List<String>>{};
    final daGlobal = <String>[];
    for (final f in sorgenti) {
      for (final riga in f.readAsLinesSync()) {
        final codice = riga.trimLeft();
        if (codice.startsWith('//') || codice.startsWith('*')) continue;
        for (final m in nome.allMatches(codice)) {
          trovati.putIfAbsent(m.group(1)!, () => []).add(f.path);
        }
        if (RegExp(r'''location:\s*['"]global['"]|regione\s*=\s*['"]global['"]''')
            .hasMatch(codice)) {
          daGlobal.add('${f.path}: $codice');
        }
      }
    }
    // ignore: avoid_print
    print('ORDINE DJ VOCE 03: modelli nominati ${trovati.keys.toList()..sort()}, '
        'verificati in ${LaRegioneDeiDati.regione} '
        '${LaRegioneDeiDati.modelliVerificati.keys.toList()}');
    cardinaleMinimo(trovati.length, 2,
        cosa: 'modelli nominati nel codice',
        perche: 'Senza nomi di modello nessun modello sarebbe fuori regione.');
    final fuori = [
      for (final e in trovati.entries)
        if (!LaRegioneDeiDati.modelliVerificati.containsKey(e.key))
          '${e.key} in ${e.value.toSet().join(', ')}',
    ];
    expect(fuori, isEmpty,
        reason: 'questi modelli non sono stati verificati in '
            '${LaRegioneDeiDati.regione}: ${fuori.join('; ')}');
    expect(daGlobal, isEmpty, reason: daGlobal.join('\n'));
  });

  test('LE CHIAMATE DELL APP PARTONO DALLA REGIONE DEI DATI, coi modelli '
      'verificati', () {
    expect(LaRegioneDeiDati.regione, 'europe-west1');
    expect(FirebaseMaestroAiProvider.kVertexLocation, LaRegioneDeiDati.regione);
    expect(LaDomandaCapita.regione, LaRegioneDeiDati.regione);
    expect(LaScenaDalModello.regione, LaRegioneDeiDati.regione);
    expect(GestiDelSegno.regione, LaRegioneDeiDati.regione);
    for (final m in [
      FirebaseMaestroAiProvider.kMaestroChatModel,
      FirebaseMaestroAiProvider.kMaestroDistillModel,
      FirebaseMaestroAiProvider.kMaestroBreveModel,
      FirebaseMaestroAiProvider.kMaestroProfondaModel,
      LaDomandaCapita.modello,
      LaScenaDalModello.modello,
      GestiDelSegno.modello,
    ]) {
      expect(LaRegioneDeiDati.modelliVerificati, contains(m),
          reason: '$m non e verificato in ${LaRegioneDeiDati.regione}');
    }
  });
}
