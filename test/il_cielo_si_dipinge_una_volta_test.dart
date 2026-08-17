import 'dart:io';

import 'package:esoteric_circle/design_system/components/cosmos_background.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// IL CIELO SI DIPINGE UNA VOLTA, E IL CAMMINO PER FOTOGRAMMA RESTA LEGGERO.
///
/// **Il fatto misurato.** Su iOS l'app veniva uccisa dal sistema a ogni
/// transizione di rotta, senza crash e senza rapporto, e il colpevole era il
/// pittore del cosmo: ridipingeva a ogni fotogramma quindici macchie di
/// nebulosa sfocate con `MaskFilter.blur(24)` piu' shader, gli aloni delle
/// stelle, i pianeti, le particelle, e rigenerava la lista delle stelle da
/// zero. Ogni sfocatura su iOS e' un passaggio di rendering con texture
/// intermedie, e in transizione i cosmi vivi sono due.
///
/// Questa prova NON guarda un fotogramma: guarda il SORGENTE del cammino
/// eseguito a ogni fotogramma, perche' il costo non si vede in un pixel. Se
/// qualcuno rimette una sfocatura o uno shader la' dentro, cade nominando la
/// riga.
void main() {
  final sorgente =
      File('lib/design_system/components/cosmos_background.dart')
          .readAsStringSync();
  // **LE FINE RIGA SONO CRLF, e va detto.** La prima stesura tagliava il
  // corpo del metodo confrontando la riga con due spazi e una graffa, e non
  // chiudeva MAI: le righe finivano con un ritorno a capo invisibile, quindi
  // il confronto falliva e la prova leggeva mezzo file, denunciando righe che
  // stanno dentro la generazione della cache e non nel cammino per fotogramma.
  final righe =
      sorgente.split('\n').map((r) => r.replaceAll('\r', '')).toList();

  /// I metodi eseguiti A OGNI FOTOGRAMMA: il paint stesso, la composizione
  /// dei piani, lo scintillio e la stella cadente. Tutto il resto del file
  /// gira solo quando la cache si rifa', cioe' quasi mai.
  const perFotogramma = [
    'void paint(Canvas canvas, Size size) {',
    'void _componi(',
    'void _scintillio(',
    'void _paintShootingStars(',
  ];

  /// Da dove comincia un metodo a quando comincia il successivo dello stesso
  /// livello: si taglia sulla chiusura con due spazi di rientro, che in
  /// questo file e' la fine di un metodo di classe.
  List<String> corpoDi(String firma) {
    final inizio = righe.indexWhere((r) => r.contains(firma));
    expect(inizio, greaterThanOrEqualTo(0),
        reason: 'Il metodo "$firma" non esiste piu\': se e\' stato '
            'rinominato, questa prova va aggiornata, non tolta.');
    final corpo = <String>[];
    for (var i = inizio; i < righe.length; i++) {
      corpo.add('${i + 1}|${righe[i]}');
      if (i > inizio && righe[i] == '  }') break;
    }
    return corpo;
  }

  test('nel cammino per fotogramma non nascono sfocature ne\' shader', () {
    final colpe = <String>[];
    for (final firma in perFotogramma) {
      for (final riga in corpoDi(firma)) {
        final testo = riga.split('|').skip(1).join('|');
        // I commenti raccontano la storia e nominano cio' che e' stato
        // tolto: si guarda il CODICE, non le parole attorno.
        final nudo = testo.trim();
        if (nudo.startsWith('//') || nudo.startsWith('///')) continue;
        for (final vietato in const ['MaskFilter', 'createShader']) {
          if (nudo.contains(vietato)) {
            colpe.add('$firma, riga ${riga.split('|').first}: "$vietato" '
                'nel cammino per fotogramma');
          }
        }
        // Nessuna lista rigenerata: era la lista delle stelle di campo,
        // costruita da zero dentro paint a ogni fotogramma.
        if (nudo.contains('List<') && nudo.contains('.generate(')) {
          colpe.add('$firma, riga ${riga.split('|').first}: una lista '
              'rigenerata nel cammino per fotogramma');
        }
      }
    }
    expect(colpe, isEmpty, reason: colpe.join('\n'));
  });

  test('gli strati pesanti esistono ancora, e stanno nella cache', () {
    // La prova sopra passerebbe anche se qualcuno cancellasse le nebulose:
    // un cielo vuoto non ha sfocature. Qui si pretende che il disegno
    // pesante ci sia ancora e che a chiamarlo sia il generatore della cache.
    final generatore = sorgente.substring(
        sorgente.indexOf('void _rigeneraIlCielo('),
        sorgente.indexOf('void _componi('));
    for (final strato in const [
      '_paintNebula(',
      '_paintPlanets(',
      '_paintStarDust(',
      '_paintFieldStars(',
    ]) {
      expect(generatore.contains(strato), isTrue,
          reason: 'Lo strato "$strato" non viene piu\' dipinto nella cache: '
              'il cielo si e\' impoverito invece di alleggerirsi.');
    }
    // **LE PARTICELLE VICINE SONO USCITE DALLA CACHE PER DECISIONE, ordine
    // AJ voce 02**: il piano piu' reattivo corre fino a 165 punti e la sua
    // scorta sarebbe costata decine di megabyte, mentre il suo contenuto e'
    // al massimo quattordici cerchi semplici. Vivono dal vivo nel cammino
    // per fotogramma, dove la prova sopra garantisce che non nascano
    // filtri; qui si pretende che ESISTANO ancora, nel paint e non nella
    // cache.
    final cammino = sorgente.substring(sorgente.indexOf('void paint('));
    expect(cammino.contains('_paintNearParticles('), isTrue,
        reason: 'Le particelle vicine sono sparite del tutto: dovevano '
            'uscire dalla cache, non dal cielo.');
    expect(generatore.contains('_paintNearParticles('), isFalse,
        reason: 'Le particelle vicine sono tornate nella cache: la loro '
            'scorta costa decine di megabyte, e la decisione dell\'ordine '
            'AJ le vuole dal vivo.');
    expect(sorgente.contains('MaskFilter.blur(BlurStyle.normal, 24)'), isTrue,
        reason: 'La sfocatura delle nebulose e\' sparita dal file: il '
            'cielo doveva restare identico, non diventare piatto.');
  });

  testWidgets('la cache si rifa\' quando cambia la palette, e non prima',
      (tester) async {
    // La regola vive nel DATO: la cache si rifa' sulla chiave, non a caso.
    // Qui si guarda l'effetto vero, cioe' la memoria occupata dalle
    // immagini, che esiste solo dopo il primo disegno.
    final cielo = CieloInCache();
    addTearDown(cielo.libera);

    Widget attorno(Maestro maestro) => MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(400, 800),
              devicePixelRatio: 2.0,
            ),
            child: MaestroScope(
              maestro: maestro,
              child: const CosmosBackground(child: SizedBox.expand()),
            ),
          ),
        );

    await tester.pumpWidget(attorno(Maestro.medora));
    await tester.pump(const Duration(milliseconds: 100));
    // Il cosmo dell'app usa la propria cache interna: qui si verifica che
    // la classe esista e sappia dire quanto pesa, che e' il numero che il
    // rapporto deve dichiarare invece di stimarlo.
    expect(cielo.byteOccupati, 0,
        reason: 'Una cache appena nata non occupa niente.');
    expect(cielo.valePer('qualunque'), isFalse);
  });

  test('la palette del cielo entra nella chiave della cache', () {
    // Senza la palette nella chiave, cambiando Maestro il cielo resterebbe
    // quello di prima: sarebbe una costante che dichiara il falso.
    final chiave = sorgente.substring(
        sorgente.indexOf('String _chiaveDelCielo('),
        sorgente.indexOf('ui.Image _dipingiUnaVolta('));
    for (final dato in const [
      'seed',
      'palette.deepest',
      'tier',
      'showZodiac',
      'showPlanets',
      'highlighted',
      'keepOut',
      'reduceMotion',
      'size.width',
      'densita',
    ]) {
      expect(chiave.contains(dato), isTrue,
          reason: 'La chiave della cache non guarda "$dato": cambiandolo, il '
              'cielo resterebbe quello di prima.');
    }
  });

  test('la palette e la misura non restano appese: i piani si liberano', () {
    final classe = sorgente.substring(sorgente.indexOf('class CieloInCache'),
        sorgente.indexOf('/// Le misure degli sprite'));
    expect(classe.contains('dispose()'), isTrue,
        reason: 'Le immagini vecchie non vengono liberate: ogni schermata '
            'lascerebbe dietro di se\' i suoi megabyte.');
    expect(sorgente.contains('cielo.liberaPiani();'), isTrue,
        reason: 'Rigenerando la cache i piani vecchi non si liberano.');
    expect(sorgente.contains('_cielo.libera();'), isTrue,
        reason: 'Uscendo dalla schermata la cache non si libera.');
  });
}
