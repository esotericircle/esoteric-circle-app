import 'dart:math' as math;

import 'package:esoteric_circle/features/maestri/caligo/rune/fisica_della_gettata.dart';
import 'package:flutter_test/flutter_test.dart';

/// LA FISICA DELLA GETTATA, MISURATA SUI NUMERI.
///
/// Il determinismo viene prima della bellezza: a parita' di seme le posizioni
/// finali coincidono al decimo di punto. Poi le leggi del gesto: gravita',
/// due rimbalzi smorzati, rotazione in volo, inclinazione propria da ferma,
/// nessuna sovrapposizione, nessuna pietra fuori dal campo.
void main() {
  // Le pietre del pozzo sono 52x64 punti su un telo da circa 328x300: le
  // semiestensioni normalizzate che la schermata passa davvero.
  const sl = 26 / 328;
  const sa = 32 / 300;

  List<Offset> arriviDiProva(int quante, int seme) {
    final rng = math.Random(seme);
    return List.generate(
        quante,
        (_) => Offset(
            0.14 + rng.nextDouble() * 0.72, 0.14 + rng.nextDouble() * 0.72));
  }

  group('il determinismo viene prima della bellezza', () {
    test('stesso seme, stesse posizioni finali al decimo di punto', () {
      final arrivi = arriviDiProva(7, 42);
      final a = FisicaDellaGettata(
          seme: 12345, arrivi: arrivi, semiLarghezza: sl, semiAltezza: sa);
      final b = FisicaDellaGettata(
          seme: 12345, arrivi: arrivi, semiLarghezza: sl, semiAltezza: sa);
      for (var i = 0; i < a.quante; i++) {
        final pa = a.a(i, 1.0).posizione;
        final pb = b.a(i, 1.0).posizione;
        // Al decimo di PUNTO su un telo da 328: in normalizzato e' 0.1/328.
        expect((pa.dx - pb.dx).abs() * 328, lessThan(0.1),
            reason: 'La pietra $i non cade due volte nello stesso posto.');
        expect((pa.dy - pb.dy).abs() * 300, lessThan(0.1));
        expect(a.a(i, 1.0).rotazione, b.a(i, 1.0).rotazione,
            reason: 'La pietra $i non ha la stessa inclinazione finale.');
      }
    });

    test('semi diversi, disposizioni diverse', () {
      final arrivi = arriviDiProva(5, 42);
      final a = FisicaDellaGettata(
          seme: 1, arrivi: arrivi, semiLarghezza: sl, semiAltezza: sa);
      final b = FisicaDellaGettata(
          seme: 2, arrivi: arrivi, semiLarghezza: sl, semiAltezza: sa);
      var almenoUnaDiversa = false;
      for (var i = 0; i < a.quante; i++) {
        if (a.a(i, 1.0).rotazione != b.a(i, 1.0).rotazione) {
          almenoUnaDiversa = true;
        }
      }
      expect(almenoUnaDiversa, isTrue,
          reason: 'Due semi diversi producono la stessa gettata: il seme non '
              'governa niente.');
    });

    test('il seme deriva da persona, giorno, domanda e rune', () {
      final a = FisicaDellaGettata.semeDa(
          'a', DateTime(2026, 8, 7), 'domanda', ['Fehu']);
      expect(
          a,
          FisicaDellaGettata.semeDa(
              'a', DateTime(2026, 8, 7), 'domanda', ['Fehu']));
      expect(
          a,
          isNot(FisicaDellaGettata.semeDa(
              'b', DateTime(2026, 8, 7), 'domanda', ['Fehu'])));
      expect(
          a,
          isNot(FisicaDellaGettata.semeDa(
              'a', DateTime(2026, 8, 8), 'domanda', ['Fehu'])));
      expect(
          a,
          isNot(FisicaDellaGettata.semeDa(
              'a', DateTime(2026, 8, 7), 'altra', ['Fehu'])));
    });
  });

  group('le leggi del gesto', () {
    final fisica = FisicaDellaGettata(
        seme: 777,
        arrivi: arriviDiProva(7, 9),
        semiLarghezza: sl,
        semiAltezza: sa);

    test('a scena ferma nessuna pietra ne copre un\'altra, zero pixel', () {
      final finali = fisica.arrivi;
      var peggiore = 0.0;
      for (var i = 0; i < finali.length; i++) {
        for (var j = i + 1; j < finali.length; j++) {
          final dx = (finali[j].dx - finali[i].dx).abs();
          final dy = (finali[j].dy - finali[i].dy).abs();
          final copertoX = math.max(0.0, sl * 2 - dx) * 328;
          final copertoY = math.max(0.0, sa * 2 - dy) * 300;
          final area = copertoX * copertoY;
          if (area > peggiore) peggiore = area;
        }
      }
      expect(peggiore, 0,
          reason: 'Due pietre si coprono per $peggiore pixel quadri a scena '
              'ferma.');
    });

    test('forzando due pietre nello stesso punto, la separazione le stacca',
        () {
      // Il rosso della sovrapposizione, eseguito come caso limite vero: due
      // pietre gettate ESATTAMENTE nello stesso punto.
      final f = FisicaDellaGettata(
          seme: 5,
          arrivi: const [Offset(0.5, 0.5), Offset(0.5, 0.5)],
          semiLarghezza: sl,
          semiAltezza: sa);
      final a = f.arrivi[0];
      final b = f.arrivi[1];
      final dx = (a.dx - b.dx).abs();
      final dy = (a.dy - b.dy).abs();
      expect(dx >= sl * 2 || dy >= sa * 2, isTrue,
          reason: 'Due pietre gettate nello stesso punto restano una '
              'sull\'altra.');
    });

    test('nessuna pietra esce dal campo, in nessun momento posato', () {
      for (var i = 0; i < fisica.quante; i++) {
        final p = fisica.a(i, 1.0).posizione;
        expect(p.dx, inInclusiveRange(sl, 1 - sl));
        expect(p.dy, inInclusiveRange(sa, 1 - sa));
      }
    });

    test('la quota cade, rimbalza due volte smorzata e muore a terra', () {
      // Si campiona fitto il volo della prima pietra e si contano i picchi
      // di quota dopo il primo contatto: devono essere DUE, il primo al 32%
      // e il secondo al 10% della caduta, come lo smorzamento dichiara.
      final campioni = <double>[];
      for (var t = 0.0; t <= 1.0; t += 0.002) {
        campioni.add(fisica.a(0, t).quota);
      }
      final picchi = <double>[];
      for (var k = 1; k < campioni.length - 1; k++) {
        if (campioni[k] > campioni[k - 1] && campioni[k] >= campioni[k + 1]) {
          picchi.add(campioni[k]);
        }
      }
      expect(picchi.length, 2,
          reason: 'I rimbalzi sono ${picchi.length}, non due.');
      expect(picchi[0],
          closeTo(FisicaDellaGettata.smorzamento, 0.02),
          reason: 'Il primo rimbalzo non rispetta lo smorzamento dichiarato.');
      expect(
          picchi[1],
          closeTo(
              FisicaDellaGettata.smorzamento * FisicaDellaGettata.smorzamento,
              0.02),
          reason: 'Il secondo rimbalzo non e\' il quadrato dello smorzamento.');
      expect(campioni.last, 0, reason: 'La pietra non si ferma a terra.');
    });

    test('ruota mentre cade, e da ferma nessuna e\' dritta ne\' uguale a '
        'un\'altra', () {
      // In volo la rotazione cambia davvero.
      final aMezzaAria = fisica.a(0, fisica.primoContatto(0) * 0.5).rotazione;
      final daFerma = fisica.a(0, 1.0).rotazione;
      expect(aMezzaAria, isNot(closeTo(daFerma, 0.001)),
          reason: 'La pietra non ruota durante la caduta.');
      // Da ferme: mai perfettamente allineate, mai due uguali.
      final finali = [
        for (var i = 0; i < fisica.quante; i++) fisica.a(i, 1.0).rotazione
      ];
      for (final r in finali) {
        expect(r.abs(), greaterThanOrEqualTo(FisicaDellaGettata.inclinazioneMinima - 1e-9),
            reason: 'Una pietra si e\' posata perfettamente dritta.');
      }
      expect(finali.toSet().length, finali.length,
          reason: 'Due pietre hanno la stessa inclinazione: sembrano '
              'stampate, non gettate.');
    });

    test('il moto e\' continuo: nessun salto brusco fra due fotogrammi', () {
      // LA GRANDEZZA DELLA SCATTOSITA'. Non si misura il costo del
      // fotogramma, che dipende dalla macchina: si misura quanto una pietra
      // SI SPOSTA fra due fotogrammi a sessanta al secondo. Il teletrasporto
      // di oggi sposta la pietra dell'intero percorso in un fotogramma solo;
      // una caduta vera, su un telo da 328 punti e una gettata da 1300
      // millisecondi, non supera i pochi punti per passo.
      const durataMs = 1300.0;
      const passo = 16.7 / durataMs;
      var salto = 0.0;
      for (var i = 0; i < fisica.quante; i++) {
        var prima = fisica.a(i, 0.0);
        for (var t = passo; t <= 1.0; t += passo) {
          final ora = fisica.a(i, t);
          if (ora.visibile && prima.visibile) {
            final d = Offset(
                    (ora.posizione.dx - prima.posizione.dx) * 328,
                    (ora.posizione.dy - prima.posizione.dy) * 300)
                .distance;
            if (d > salto) salto = d;
          }
          prima = ora;
        }
      }
      expect(salto, lessThan(30.0),
          reason: 'Fra due fotogrammi una pietra salta di '
              '${salto.toStringAsFixed(1)} punti: e\' uno scatto, non una '
              'caduta.');
    });
  });
}
