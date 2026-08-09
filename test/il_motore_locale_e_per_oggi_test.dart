import 'dart:io';

import 'package:esoteric_circle/core/astro/celestial.dart';
import 'package:esoteric_circle/core/astro/effemeridi.dart';
import 'package:flutter_test/flutter_test.dart';

/// IL MOTORE LOCALE E' PER IL CIELO DI OGGI, NON PER LE NASCITE.
///
/// Ordine 2170, voce 5. Le nostre effemeridi sbagliano Saturno di **0,570
/// gradi al 21 marzo 1950**, contro i 0,141 misurati sulle date del 2026:
/// quattro volte tanto. La causa e' la forma dei polinomi, costruiti attorno
/// all'epoca corrente.
///
/// **Oggi non tocca nessuno**, perche' la carta di nascita viene dal motore
/// remoto, che su tre nascite in tre epoche e' esatto al mezzo millesimo di
/// grado. Ma toccherebbe tutto il giorno che la portassimo in casa: mezzo
/// grado su Saturno sposta un aspetto e puo' cambiare la casa di un pianeta.
///
/// Queste prove esistono perche' quel giorno lo si affronti sapendolo.
void main() {
  double scarto(double a, double b) {
    final d = (a - b).abs() % 360.0;
    return d > 180.0 ? 360.0 - d : d;
  }

  test('l\'epoca verificata e\' dichiarata, e comprende oggi', () {
    expect(Effemeridi.primoAnnoVerificato, lessThanOrEqualTo(2026));
    expect(Effemeridi.ultimoAnnoVerificato, greaterThanOrEqualTo(2026));
    expect(Effemeridi.dentroEpocaVerificata(DateTime(2026, 8, 10)), isTrue,
        reason: 'il cielo di oggi cade fuori dall\'epoca verificata: allora '
            'non e\' verificato nemmeno cio\' che l\'app mostra stanotte');
  });

  test('una NASCITA del secolo scorso cade fuori dall\'epoca verificata', () {
    // Il confine non e' un divieto tecnico: il calcolo torna comunque un
    // numero. E' il confine oltre il quale quel numero non l'ha misurato
    // nessuno, e percio' non si puo' promettere.
    for (final nascita in [
      DateTime(1950, 3, 21),
      DateTime(1972, 3, 7),
      DateTime(1985, 12, 21),
      DateTime(1990, 6, 15),
    ]) {
      expect(Effemeridi.dentroEpocaVerificata(nascita), isFalse,
          reason: 'una nascita del ${nascita.year} risulta dentro l\'epoca '
              'verificata: allora qualcuno ha allargato il confine senza '
              'rimisurare gli scarti');
    }
  });

  test('e il motivo del confine e\' MISURATO, non temuto', () {
    // Il numero che regge tutto il ragionamento, ripreso qui perche' se un
    // giorno le effemeridi migliorassero questa prova cadrebbe e sarebbe una
    // buona notizia da riscrivere, invece di una nota vecchia da credere.
    final jd1950 = Celestial.julianDay(DateTime.utc(1950, 3, 21, 6, 15));
    final saturno1950 =
        Effemeridi.longitudineEclittica(CorpoCeleste.saturno, jd1950);
    final s1950 = scarto(saturno1950, 164.9486174); // JPL Horizons

    final jdOggi = Celestial.julianDay(DateTime.utc(2026, 8, 24));
    final saturnoOggi =
        Effemeridi.longitudineEclittica(CorpoCeleste.saturno, jdOggi);
    final sOggi = scarto(saturnoOggi, 14.0890698); // JPL Horizons

    // ignore: avoid_print
    print('EPOCA: Saturno sbaglia ${s1950.toStringAsFixed(3)} gradi al 1950 '
        'e ${sOggi.toStringAsFixed(3)} gradi nel 2026, cioe\' '
        '${(s1950 / sOggi).toStringAsFixed(1)} volte tanto');

    expect(sOggi, lessThan(Effemeridi.scartoMisurato[CorpoCeleste.saturno]!),
        reason: 'nell\'epoca verificata Saturno sfora lo scarto dichiarato: la '
            'promessa in effemeridi.dart non e\' piu\' vera');
    expect(s1950, greaterThan(sOggi * 2),
        reason: 'fuori epoca Saturno non sbanda piu\': se e\' migliorato, la '
            'nota accanto a scartoMisurato va riscritta con la misura nuova, '
            'e il confine dell\'epoca puo\' allargarsi');
  });

  test('NESSUNO usa il motore locale per calcolare una carta di nascita', () {
    // **LA PROVA CHE DEVE CADERE il giorno che qualcuno ci prova.**
    //
    // Si guardano i file che calcolano una carta natale e si pretende che non
    // chiamino le effemeridi locali. Oggi la carta viene dal motore remoto, e
    // questo elenco e' vuoto: se domani qualcuno collegasse `Effemeridi` a un
    // calcolo di nascita per risparmiare una chiamata, si troverebbe qui.
    final colpe = <String>[];
    for (final f in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      final percorso = f.path.replaceAll('\\', '/');
      final testo = f.readAsStringSync();
      // Chi nomina insieme la carta natale e le effemeridi locali.
      final usaEffemeridi = testo.contains('Effemeridi.longitudineEclittica');
      if (!usaEffemeridi) continue;
      final parlaDiNascita = testo.contains('NatalChart(') ||
          testo.contains('natalChart') ||
          testo.contains('BirthDetails');
      if (parlaDiNascita) {
        colpe.add(percorso);
      }
    }
    expect(colpe, isEmpty,
        reason: 'questi file calcolano una carta di nascita con le effemeridi '
            'locali: $colpe.\nFuori dall\'epoca verificata Saturno sbaglia '
            'mezzo grado, che sposta un aspetto e puo\' cambiare la casa di un '
            'pianeta. Se la scelta e\' voluta, prima si rimisurano gli scarti '
            'sulle epoche di nascita e si allarga il confine dichiarato in '
            'effemeridi.dart.');
  });
}
