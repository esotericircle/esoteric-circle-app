// ignore_for_file: avoid_print
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'sorgenti_di_lib.dart';

/// **LE ANIMAZIONI CHE SONO IL RITO NON SI ACCORCIANO.** Ordine EF, 23
/// settembre 2026.
///
/// **Il fatto del fondatore, verbatim**: *"il soffio sonoro ha funzionato, ma
/// l'immagine e' cambiata di botto e non c'e' stata animazione con i petali
/// che si sono staccati e allontanati dal centro del soffione"*. E prima:
/// *"L'animazione del soffione ha sempre funzionato, quindi non dire cazzate
/// e sistemalo"*.
///
/// **Aveva ragione lui, e la causa non era quella che sembrava.** Le
/// animazioni giravano: **duravano venti volte meno**. Quando la piattaforma
/// dichiara `disableAnimations`, Flutter non spegne un `AnimationController`,
/// **ne moltiplica la durata per 0,05**, ed e' il comportamento di partenza,
/// `AnimationBehavior.normal`. Su Android `disableAnimations` viene dalla
/// scala di durata degli animatori, **un numero che moltissimi mettono a zero
/// per far sembrare il telefono piu' rapido**: sul Realme del fondatore le tre
/// scale sono a zero.
///
/// Misurato sul suo telefono, con la build 2276:
///
/// | animazione | durata dichiarata | durata vera |
/// |---|---|---|
/// | volo dei semi | 900 ms | **45 ms** |
/// | respiro | 28 s | **1,4 s** |
///
/// La schermata diceva *"Il respiro e' compiuto"* dopo otto secondi, e il
/// volo dei petali finiva prima che l'occhio lo cogliesse. Da qui *"e'
/// cambiata di botto"*.
///
/// **La cura e' `AnimationBehavior.preserve`**, che e' il modo documentato di
/// dire che **quell'animazione e' il contenuto e non un abbellimento**. Il
/// volo dei semi e' il gesto del rito; il respiro e' cio' che la persona deve
/// seguire col corpo. Una guida del respiro che corre venti volte piu' in
/// fretta del respiro e' il contrario di una guida.
///
/// **Cosa NON copre questa guardia, e va detto.** Non tutte le animazioni
/// dell'app: solo quelle elencate qui, che sono il gesto e il conteggio del
/// rito. Le decorazioni possono benissimo accorciarsi, ed e' giusto che lo
/// facciano per chi quella scala l'ha messa a zero davvero per non vedere
/// movimento.
void main() {
  /// I motori che portano il rito, col file in cui vivono.
  ///
  /// **Ognuno e' qui perche' il fondatore ne ha visto l'assenza a video**, non
  /// perche' sembrasse importante a chi scrive.
  const motoriDelRito = <String, String>{
    'lib/features/rituals/breath_destiny_screen.dart':
        'il volo dei semi e la brezza del Soffio del Destino',
    'lib/design_system/components/guida_del_respiro.dart':
        'il conteggio del respiro guidato',
  };

  test('ogni motore del rito dichiara AnimationBehavior.preserve', () {
    final colpe = <String>[];
    var controlloriGuardati = 0;

    for (final voce in motoriDelRito.entries) {
      final sorgente = senzaCommenti(File(voce.key).readAsStringSync());
      // Quanti `AnimationController(` nascono in quel file, e quanti di loro
      // dichiarano il comportamento.
      final nati = 'AnimationController('.allMatches(sorgente).length;
      final dichiarati = 'animationBehavior: AnimationBehavior.preserve'
          .allMatches(sorgente)
          .length;
      controlloriGuardati += nati;
      if (nati == 0) {
        colpe.add('${voce.key}: non nasce nessun AnimationController, e '
            'questa prova guarda un file che non ha niente da dire su '
            '${voce.value}');
      } else if (dichiarati < nati) {
        colpe.add('${voce.key}: ${nati - dichiarati} motori su $nati non '
            'dichiarano AnimationBehavior.preserve, quindi su un telefono con '
            'la scala degli animatori a zero ${voce.value} durera\' un '
            'ventesimo e non si vedra\'');
      }
    }

    print('ORDINE EF: motori del rito guardati $controlloriGuardati');
    // **Il cardinale, perche' il conto nasce a esecuzione.** Se un domani
    // qualcuno spostasse quei controllori altrove, questa prova girerebbe su
    // zero e sarebbe verde senza aver guardato niente.
    expect(controlloriGuardati, greaterThanOrEqualTo(3),
        reason: 'i motori del rito trovati sono $controlloriGuardati: erano '
            'tre, il volo dei semi, la brezza e il conteggio del respiro. Se '
            'sono meno, questa prova non sta piu\' guardando cio\' per cui e\' '
            'nata');
    expect(colpe, isEmpty, reason: colpe.join('\n'));
  });
}
