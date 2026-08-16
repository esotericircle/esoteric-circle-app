import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/design_system/tokens/color_tokens.dart';
import 'package:esoteric_circle/features/sigilli/direzione_della_festa.dart';
import 'package:esoteric_circle/features/sigilli/pittore_della_festa.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// UNA PARTICELLA GIA' NATA NON SALTA. Ordine AC voce 03.
///
/// **Il difetto, trovato dentro l'ordine X e rimasto scoperto perche' nessun
/// ordine lo copriva.** Le tre estrazioni di una particella si facevano dentro
/// il ciclo e solo per quelle gia' nate: una non nata ne consumava una, una nata
/// tre. Quindi **ogni nascita spostava il flusso di tutte quelle dopo di lei**, e
/// le stelle gia' in volo si ritrovavano in un altro punto invece di proseguire.
/// Per il primo quarantacinque per cento della festa il disegno si rimescolava a
/// ogni fotogramma, ed e' la ragione per cui il movimento di Medora non si legge
/// come un'esplosione.
///
/// **Si guardano le POSIZIONI e non i pixel**, perche' due stelle vicine sui
/// pixel non si distinguono e un salto si confonderebbe con una sovrapposizione.
/// Chi disegna e chi misura passano dalla stessa porta, `posizioni`, quindi non
/// possono scostarsi.
///
/// **Vale per tutte e tre le feste**, perche' il pittore e' comune: una
/// correzione che valesse per Medora e non per Aura sarebbe una correzione a
/// meta' su un difetto che sta nel meccanismo.
void main() {
  /// **QUANTO PUO' SPOSTARSI IN UN PASSO, e da dove viene il numero.** Non dalla
  /// misura: dal modello. In un passo di avanzamento pari a 0,01 il raggio di una
  /// particella dal centro cresce al massimo di `passo * lato maggiore * 1,35`,
  /// perche' il fattore del raggio sta fra 0,35 e 1,35; sulle altre due direzioni
  /// la corsa e' al massimo `passo * 1,25` dell'altezza. Su una tela di 1080 per
  /// 2391 il piu' grande dei due vale circa 32 punti. **Si ammette il doppio**,
  /// 64, perche' fra un passo e l'altro cambia anche il fattore che schiaccia la
  /// verticale e non si vuole una prova che cade sul terzo decimale. Un salto
  /// vero, quello che questa riga deve prendere, misura centinaia di punti.
  const salto = 64.0;

  const misura = Size(1080, 2391);

  /// Le tre coppie di istanti sono quelle dove il difetto viveva: prima che le
  /// particelle siano tutte nate, cioe' sotto 0,45.
  const coppie = [
    [0.18, 0.19],
    [0.30, 0.31],
    [0.44, 0.45],
  ];

  PittoreDellaFesta pittore(Maestro maestro, double avanzamento) =>
      PittoreDellaFesta(
        maestro: maestro,
        avanzamento: avanzamento,
        oro: ColorTokens.gold,
        oroTenue: ColorTokens.goldLight,
        eGrande: false,
        effettiPieni: true,
      );

  test('nessuna particella gia\' nata salta da un istante al successivo', () {
    final saltate = <String>[];
    var osservate = 0;
    var confrontate = 0;
    for (final maestro in Maestro.values) {
      for (final coppia in coppie) {
        osservate++;
        final prima = pittore(maestro, coppia[0]).posizioni(misura);
        final dopo = pittore(maestro, coppia[1]).posizioni(misura);
        var quante = 0;
        for (final voce in prima.entries) {
          final arrivo = dopo[voce.key];
          // Una particella che nel frattempo e' finita non si giudica: qui si
          // guardano quelle che c'erano prima e ci sono ancora.
          if (arrivo == null) continue;
          confrontate++;
          if ((arrivo - voce.value).distance > salto) quante++;
        }
        // ignore: avoid_print
        print('ORDINE AC VOCE 03: ${maestro.id} '
            '(${FesteDeiMaestri.di(maestro).direzione.name}) da ${coppia[0]} a '
            '${coppia[1]}: vive ${prima.length}, saltate $quante');
        if (quante > 0) {
          saltate.add('${maestro.id} da ${coppia[0]} a ${coppia[1]}: $quante '
              'particelle su ${prima.length}');
        }
      }
    }
    // **QUANTE OSSERVAZIONI, e cade se sono zero.**
    // ignore: avoid_print
    print('ORDINE AC VOCE 03: coppie osservate $osservate, particelle '
        'confrontate $confrontate');
    expect(osservate, Maestro.values.length * coppie.length);
    expect(confrontate, greaterThan(0),
        reason: 'nessuna particella e\' stata confrontata: la prova gira a '
            'vuoto e direbbe che va tutto bene');
    expect(saltate, isEmpty,
        reason: 'delle particelle gia' ' nate si spostano di piu\' di $salto '
            'punti in un passo di un centesimo: ${saltate.join(" | ")}. Vuol '
            'dire che i numeri di una particella dipendono ancora dall\'ordine '
            'in cui si e\' arrivati a lei, quindi ogni nascita rimescola tutte '
            'quelle dopo');
  });

  test('la festa resta la stessa a ogni ridisegno', () {
    // **Il seme e' fisso, e questa riga lo pretende.** La correzione tocca
    // QUANDO si estrae, non da dove: se un giorno qualcuno legasse i numeri
    // all'istante invece che all'indice, la festa cambierebbe a ogni montaggio e
    // non sarebbe piu' la TUA festa.
    var osservate = 0;
    for (final maestro in Maestro.values) {
      osservate++;
      final una = pittore(maestro, 0.5).posizioni(misura);
      final altra = pittore(maestro, 0.5).posizioni(misura);
      expect(una.length, altra.length);
      for (final chiave in una.keys) {
        expect(altra[chiave], una[chiave],
            reason: 'la particella $chiave di ${maestro.id} cade in due punti '
                'diversi a parita\' di avanzamento');
      }
    }
    // ignore: avoid_print
    print('ORDINE AC VOCE 03: feste confrontate con se stesse $osservate');
    expect(osservate, Maestro.values.length);
  });
}
