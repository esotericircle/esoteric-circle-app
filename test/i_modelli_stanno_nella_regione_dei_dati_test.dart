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

  test('E IL DOCUMENTO CHE L AGENTE LEGGE NON NOMINA UNA FAMIGLIA DI MODELLI '
      'CHE L APP NON CHIAMA', () {
    // **IL BUCO CHE HA FATTO NASCERE QUESTA PROVA.** Ordine ED voce 04, 21
    // settembre 2026. La prova qui sopra guarda `lib` e il server, e li'
    // faceva il suo lavoro. **CLAUDE.md non lo guardava nessuno**, e la sua
    // riga 96 ha detto per settimane *"Gemini 3 Pro per i Maestri, Gemini 3
    // Flash per i task ripetitivi"* mentre l'app non ha mai chiamato un
    // modello della famiglia 3. E' il documento che l'agente legge per primo
    // a ogni apertura: una bugia li' vale piu' di una bugia in un commento.
    //
    // **Si misura la FAMIGLIA, non il nome esatto**, perche' la bugia era
    // scritta a parole e in discorso, *"Gemini 3 Pro"*, e una ricerca del
    // nome col trattino non l'avrecbe mai vista. `Gemini-TTS` non porta
    // numero e non entra, ed e' giusto: non e' un modello di testo.
    final famiglie = LaRegioneDeiDati.modelliVerificati.keys
        .map((m) => RegExp(r'gemini-([0-9][0-9.]*)').firstMatch(m)?.group(1))
        .whereType<String>()
        .toSet();
    final documento = File('CLAUDE.md').readAsStringSync();
    final nominate = RegExp(r'[Gg]emini[- ]([0-9][0-9.]*)')
        .allMatches(documento)
        .map((m) => m.group(1)!)
        .toSet();
    // ignore: avoid_print
    print('ORDINE ED VOCE 04: famiglie in CLAUDE.md $nominate, '
        'verificate in ${LaRegioneDeiDati.regione} $famiglie');
    cardinaleMinimo(nominate.length, 1,
        cosa: 'famiglie di modelli nominate in CLAUDE.md',
        perche: 'Se la riga dei modelli sparisse, questa prova direbbe di '
            'si\' a niente: il documento deve dire quali modelli girano.');
    final fuori = nominate.difference(famiglie).toList();
    expect(fuori, isEmpty,
        reason: 'CLAUDE.md nomina la famiglia Gemini $fuori, che l\'app non '
            'chiama da nessuna parte: chi legge il documento per primo si fa '
            'un\'idea falsa di cosa gira. Le famiglie vere sono $famiglie');
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
