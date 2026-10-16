// ignore_for_file: avoid_print
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'sorgenti_di_lib.dart';

/// **OGNI SCENA HA LA SUA PROVA DEL SOLO VIDEO.** Ordine FX voce FXA.08, 16
/// ottobre 2026. Il fondatore: *"assicurati che tutto venga sovrapposto dopo
/// aver visto il video di scena e non che il Video si veda coperto da
/// riquadri e testi"*.
///
/// La regola la misura, scena per scena, la porta comune
/// `test/sopra_il_filmato.dart` (`soloIlFilmatoFinche`), chiamata dalla prova
/// di ogni scena a video in corso. Questa guardia tiene la regola valida
/// **per ogni scena futura**: una scena e' una schermata che apre un lettore
/// di scena (lo stesso riconoscimento di
/// `test/ogni_scena_si_salta_col_tocco_test.dart`), e il widget che la
/// schermata dichiara per primo deve essere montato da una prova che chiama
/// `soloIlFilmatoFinche`. La prova cade col nome della scena che non ce l'ha.
///
/// **LE DUE SCENE DEL RESPIRO DELLA LUNA**, il Respiro e la Collana, le
/// lavora in parallelo un'altra persona dentro lo stesso ordine FX: la loro
/// prova del solo video e' sua. Stanno in [inLavorazione] finche' non
/// l'hanno, e da quando l'hanno la guardia pretende che escano dall'elenco.
void main() {
  test('ogni scena dell\'app ha la sua prova del solo video', () {
    final apreUnaScena = RegExp(
        r'LettoreDellaScena\w*\.vero\)|RegiaDellaScena\(|LettoreDiScena\.vero\(');
    final primoWidget =
        RegExp(r'class (\w+) extends (?:StatefulWidget|StatelessWidget)');
    // Respiro e Collana hanno la loro prova dal 16 ottobre 2026, in
    // la_luna_di_quest_ora_e_una_sola_test.dart: l'elenco e' vuoto.
    const inLavorazione = <String>{};

    final prove = <String, String>{
      for (final f in Directory('test').listSync(recursive: true))
        if (f is File &&
            f.path.endsWith('_test.dart') &&
            f.readAsStringSync().contains('soloIlFilmatoFinche('))
          f.path.replaceAll('\\', '/'): f.readAsStringSync(),
    };

    final scene = <String>[];
    final senzaProva = <String>[];
    final usciteDallaLavorazione = <String>[];
    for (final f in sorgentiDiLib()) {
      final p = f.path.replaceAll('\\', '/');
      if (p.endsWith('lib/features/scene/la_scena_in_video.dart')) continue;
      final testo = f.readAsStringSync();
      if (!apreUnaScena.hasMatch(testo)) continue;
      final dove = p.substring(p.indexOf('lib/'));
      final schermata = primoWidget.firstMatch(testo)?.group(1);
      scene.add('$dove ($schermata)');
      final provata = schermata != null &&
          prove.values.any((t) => t.contains('$schermata('));
      if (inLavorazione.contains(dove)) {
        if (provata) usciteDallaLavorazione.add(dove);
        continue;
      }
      if (!provata) senzaProva.add('$dove ($schermata)');
    }
    scene.sort();
    print('ORDINE FX VOCE FXA.08: scene ${scene.length}, prove del solo '
        'video ${prove.length}: $scene');
    cardinaleMinimo(scene.length, 10,
        cosa: 'scene che aprono un lettore',
        perche: 'la Stesa, la Sinastria evolutiva, l\'Oracolo degli Angeli, '
            'l\'Oroscopo, la porta della Sinastria VIP, il Calendario Lunare, '
            'il dominio e la chat dei Maestri, il Respiro e la Collana: se la '
            'guardia non le trova tutte, il riconoscimento si e\' rotto.');
    cardinaleMinimo(prove.length, 8,
        cosa: 'prove che chiamano soloIlFilmatoFinche',
        perche: 'una per ognuna delle otto scene dell\'ordine FXA.08');
    expect(senzaProva, isEmpty,
        reason: 'FXA.08: queste scene aprono un video e nessuna prova guarda '
            'che sopra il video, mentre gira, si veda solo il video: '
            '$senzaProva');
    expect(usciteDallaLavorazione, isEmpty,
        reason: 'queste scene hanno adesso la loro prova del solo video: '
            'vanno tolte da inLavorazione, cosi\' la guardia le sorveglia '
            'come le altre: $usciteDallaLavorazione');
  });
}
