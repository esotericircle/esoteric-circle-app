import 'dart:typed_data';

import 'package:esoteric_circle/core/sigilli/forma_dell_elemento.dart';
import 'package:flutter_test/flutter_test.dart';

/// LA CHIUSURA NON DEVE MANGIARSI IL BORDO. Ordine Z voce 01.
///
/// **Perche' questa prova esiste, ed e' la guardia della guardia.** La chiusura
/// serve a sigillare le fessure sottili dentro un elemento. Fino all'ordine Z
/// faceva anche un'altra cosa, che nessuno aveva chiesto: l'erosione contava cio'
/// che sta fuori dalla finestra come vuoto, quindi consumava l'anello di bordo a
/// ogni giro. Con la maschera che non toccava piu' il bordo, **il controllo che
/// distingue una forma da una colata non poteva piu' accendersi**, e il conteggio
/// delle forme del Loto saliva da 22 a 50 senza che si fosse chiuso niente.
///
/// **Il difetto era invisibile proprio a chi guardava il conteggio**, perche' il
/// conteggio migliorava. Si vedeva solo nell'area, che quadruplicava, e nella
/// guardia, che smetteva di sparare. Questa prova lo prende dal verso giusto:
/// non guarda quante forme escono, guarda che il bordo sia ancora li'.
///
/// **La misura passa dalla porta pubblica.** La chiusura e' privata, quindi non
/// si prova da sola: si prova attraverso `cresci` su un'arte finta tutta della
/// stessa materia. Su una tela cosi' non c'e' nessun muro, quindi la crescita
/// DEVE arrivare al bordo della finestra e DEVE essere respinta come colata. Se
/// una chiusura si mangia il bordo, la respinta non arriva e al suo posto esce
/// una forma grande quanto la finestra, che e' esattamente il difetto.
void main() {
  /// Una materia che non e' oro: nell'oro il rosso sta sopra il verde e il verde
  /// sopra il blu. Qui il verde sta sopra tutti, quindi il muro non c'e'.
  const materia = [40, 90, 50];

  Uint8List tuttaMateria(int larghezza, int altezza) {
    final rgba = Uint8List(larghezza * altezza * 4);
    for (var i = 0; i < larghezza * altezza; i++) {
      rgba[i * 4] = materia[0];
      rgba[i * 4 + 1] = materia[1];
      rgba[i * 4 + 2] = materia[2];
      rgba[i * 4 + 3] = 255;
    }
    return rgba;
  }

  test('con qualunque chiusura una tela senza muri resta una colata', () {
    const lato = 300;
    final rgba = tuttaMateria(lato, lato);
    final sopravvissute = <String>[];
    var osservate = 0;
    // Zero compreso: e' il caso che gia' funzionava, e tenerlo dentro dice che
    // la correzione non ha rotto cio' che andava.
    for (var chiusura = 0; chiusura <= 5; chiusura++) {
      osservate++;
      final forma = CrescitaDellaForma.cresci(
        rgba,
        lato,
        lato,
        lato ~/ 2,
        lato ~/ 2,
        RegolaDellaForma(
          // **Zero vuol dire che non si guarda la materia**, quindi l'unico muro
          // possibile sarebbe l'oro, che qui non c'e'.
          tolleranza: 0,
          chiusura: chiusura,
          raggioMassimo: 50,
          areaMinima: CrescitaDellaForma.areaDelRipiego,
        ),
      );
      // ignore: avoid_print
      print('ORDINE Z VOCE 01: chiusura $chiusura, ripiego ${forma.eRipiego}, '
          'area ${forma.area}');
      if (!forma.eRipiego) {
        sopravvissute.add(
            'con chiusura $chiusura una tela senza nessun muro ha '
            'prodotto una forma di ${forma.area} pixel invece di essere '
            'respinta come colata: l\'erosione si e\' mangiata il bordo della '
            'finestra e la guardia non ha potuto accendersi');
      }
    }

    // **QUANTE CHIUSURE GUARDATE, e cade se sono zero.**
    // ignore: avoid_print
    print('ORDINE Z VOCE 01: chiusure osservate $osservate');
    expect(osservate, 6);
    expect(sopravvissute, isEmpty, reason: sopravvissute.join(' | '));
  });

  test('la chiusura sigilla ancora una fessura sottile dentro la materia', () {
    // **La correzione non deve spegnere la chiusura, solo il suo effetto sul
    // bordo.** Qui una venatura d'oro larga due pixel taglia in due la materia:
    // senza chiusura la crescita si ferma prima della venatura, con la chiusura
    // la scavalca e arriva dall'altra parte. Se questa riga cade, la cura ha
    // ucciso il paziente.
    const lato = 300;
    final rgba = tuttaMateria(lato, lato);
    // **IL RECINTO STA LARGO DENTRO LA FINESTRA, e la misura di quel margine e'
    // parte della prova.** Il recinto occupa da 120 a 179 e la finestra, che e'
    // il raggio massimo attorno al seme, va da 75 a 195: restano almeno sedici
    // pixel di margine da ogni lato, cioe' molto piu' della chiusura. Cosi' la
    // gonfiatura non puo' arrivare al bordo della finestra e cio' che si misura
    // qui e' la sigillatura della venatura, non la guardia della colata, che ha
    // la sua prova sopra.
    for (var y = 0; y < lato; y++) {
      for (var x = 0; x < lato; x++) {
        final fuori = x < 120 || x > 179 || y < 120 || y > 179;
        // Una venatura verticale di due pixel che taglia il recinto in due meta'
        // uguali da ventinove pixel.
        final venatura = x == 149 || x == 150;
        if (!fuori && !venatura) continue;
        final i = (y * lato + x) * 4;
        rgba[i] = 180;
        rgba[i + 1] = 120;
        rgba[i + 2] = 30;
      }
    }
    RegolaDellaForma regola(int chiusura) => RegolaDellaForma(
          tolleranza: 0,
          chiusura: chiusura,
          raggioMassimo: 60,
          areaMinima: CrescitaDellaForma.areaDelRipiego,
        );
    // Il seme sta nella meta' di sinistra: senza chiusura la crescita si ferma
    // alla venatura, con la chiusura la scavalca e prende anche l'altra meta'.
    final senza =
        CrescitaDellaForma.cresci(rgba, lato, lato, 135, 150, regola(0));
    final con =
        CrescitaDellaForma.cresci(rgba, lato, lato, 135, 150, regola(3));
    // ignore: avoid_print
    print('ORDINE Z VOCE 01: dentro il recinto, senza chiusura ${senza.area} '
        'pixel, con chiusura 3 ${con.area} pixel');
    expect(senza.eRipiego, isFalse,
        reason: 'dentro un recinto chiuso la crescita non e\' una colata');
    expect(con.eRipiego, isFalse);
    expect(con.area, greaterThan(senza.area * 3 ~/ 2),
        reason:
            'con la chiusura la crescita deve scavalcare la venatura da due '
            'pixel e prendersi anche l\'altra meta\' del recinto: se l\'area non '
            'cresce, la chiusura non sigilla piu\' niente e la correzione del '
            'bordo l\'ha spenta del tutto');
  });
}
