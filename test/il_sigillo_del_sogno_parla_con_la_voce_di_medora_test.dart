// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/maestro/la_voce_non_si_confonde.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/rituals/dream_rite_corpus.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **IL SIGILLO DEL SOGNO PARLA CON LA VOCE DI MEDORA.** Ordine EE voce 06,
/// 23 settembre 2026.
///
/// **Il fatto.** Sopra il titolo del rito si leggeva *"Respiro · Il saluto di
/// Medora"*. Il Sigillo del Sogno e' di **Medora**
/// (`daily_elements.dart:10`), e **"respiro" e' parola di firma di Aura**
/// (`voce_del_maestro.dart:350`). Non era un'etichetta scritta a mano: era
/// **la parola della notte del segno Acquario**, una delle dodici del
/// corpus, che il rito mostra sopra il titolo.
///
/// **Il censimento ha trovato tre violazioni su cinquantacinque campi**, non
/// una: *Radice* per il Toro e *Respiro* per l'Acquario, tutte e due parole
/// di firma di Aura, piu' *"hai fatto sentire qualcuno a casa"* per il
/// Cancro, dove *sentire* e' di Aura pure lui. Sono diventate *Terra*,
/// *Spazio* e *"hai dato a qualcuno un posto dove stare"*.
///
/// **Padre: PROVENIENZA IGNOTA.** Il corpus nasce col file e nessun ordine
/// risulta averlo confrontato col lessico di firma dei tre Maestri: il
/// divieto incrociato dell'ordine BP voce 1 vive nell'istruzione che va al
/// modello, e **i testi fissi non passano di li'**.
///
/// **Si misura col metro della casa**, `LaVoceNonSiConfonde`, lo stesso che
/// sorveglia le risposte di Gemini: le parole si guardano intere, quindi
/// *runa* non scatta dentro *pruna*.
void main() {
  test('nessuna delle dodici voci della notte porta parole di Aura o Caligo',
      () {
    const segni = Zodiac.values;
    cardinaleMinimo(segni.length, 12,
        cosa: 'segni lunari con una voce della notte',
        perche: 'Il corpus ne ha una per segno: se la tavola si svuotasse, '
            'questa prova direbbe di si\' a niente.');

    var campi = 0;
    final sporche = <String>[];
    for (final segno in segni) {
      final voce = DreamRiteCorpus.voce(segno);
      final pezzi = <String, String>{
        'parola': voce.parola,
        'immagine': voce.immagine,
        'giorno': voce.giorno,
        'riconoscimento': voce.riconoscimento,
        'posa': voce.posa,
      };
      pezzi.forEach((nome, testo) {
        campi++;
        final altrui =
            LaVoceNonSiConfonde.paroleAltruiIn(Maestro.medora, testo);
        if (altrui.isNotEmpty) {
          sporche.add('${segno.name}.$nome porta ${altrui.join(", ")}: '
              '"$testo"');
        }
      });
    }
    print('ORDINE EE VOCE 06: campi del corpus del sogno $campi, '
        'con parole altrui ${sporche.length}');
    expect(campi, greaterThanOrEqualTo(60),
        reason: 'i campi letti sono $campi: la voce della notte ne ha cinque '
            'per segno, e se ne sparisse uno questa prova guarderebbe meno '
            'di quello che dice');
    expect(sporche, isEmpty,
        reason: 'il rito di Medora parla con la voce di un altro Maestro:\n'
            '${sporche.join("\n")}');
  });
}
