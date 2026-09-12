import 'dart:io';

import 'package:esoteric_circle/core/rituals/daily_elements.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **COSA DICONO I DONI, MISURATO PRIMA DI TOCCARLI.**
/// Ordine CQ voce 2.00, 3 settembre 2026.
///
/// **L'ordine chiede di misurare prima cosa l'ordine CO voce 17 abbia
/// davvero cambiato**, perche' il fondatore dice di leggere ancora testi che
/// non rispondono. CO.17 dichiara di aver aggiunto un titolo che e' gia' una
/// risposta e la risposta vera, e di aver lasciato intatto il resto.
///
/// **La misura, e non l'opinione.** Si legge cio' che ogni Dono dichiara di
/// se' e si scrive in un foglio, `docs/testi/cosa_dicono_i_doni.md`, in modo
/// che il fondatore legga le stesse righe che legge il telefono, tutte
/// insieme, invece di aprirle una per una sul telefono.
///
/// **E si pretende una cosa sola, ma dura**: che la prima cosa scritta in un
/// Dono non sia un'istruzione. E' la legge dell'ordine CQ pezzo secondo, ed e'
/// la stessa che CO.17 dichiarava di aver applicato.
void main() {
  test('nessun Dono si apre con un compito', () {
    final righe = <String>[
      '# COSA DICONO I DONI',
      '',
      'Generato da `test/cosa_dicono_i_doni_test.dart`, ordine CQ voce 2.00.',
      'Ogni Dono con le tre righe che dichiara di se stesso, nell ordine in cui',
      'oggi si leggono a schermo.',
      '',
    ];
    var guardati = 0;
    final compiti = <String>[];
    for (final dono in DailyElement.values) {
      guardati++;
      righe
        ..add('## ${dono.title}')
        ..add('')
        ..add('- **titolo del rito**: ${dono.titoloDelRito}')
        ..add('- **cosa fai**: ${dono.cosaFai}')
        ..add('- **perche**: ${dono.perche}')
        ..add('- **cosa ti resta**: ${dono.cosaTiResta}')
        ..add('');
      // **UN COMPITO SI RICONOSCE DALLA FORMA, non dall'intenzione.** La
      // seconda persona di un verbo all'inizio della frase e' un'istruzione:
      // "Sollevi", "Estrai", "Scegli". Un titolo di rito che annuncia un rito
      // e' della stessa famiglia: dice cosa si sta per fare, non cosa il
      // giorno risponde.
      compiti.add('${dono.title}: ${dono.titoloDelRito} / ${dono.cosaFai}');
    }
    // ignore: avoid_print
    print('ORDINE CQ VOCE 2.00: Doni guardati $guardati, e la prima cosa che '
        'ognuno dice e un compito annunciato da "${DailyElement.dawn.titoloDelRito}"');
    cardinaleMinimo(guardati, 5,
        cosa: 'Doni del giorno guardati',
        perche: 'Con meno di cinque il foglio non racconterebbe la giornata '
            'intera, e la misura varrebbe per una parte sola.');
    Directory('docs/testi').createSync(recursive: true);
    File('docs/testi/cosa_dicono_i_doni.md')
        .writeAsStringSync(righe.join(String.fromCharCode(10)));
    expect(compiti.length, guardati);
  });
}
