import 'package:esoteric_circle/core/rituals/runes.dart';
import 'package:esoteric_circle/features/maestri/caligo/rune/bindrune.dart';
import 'package:flutter_test/flutter_test.dart';

/// La geometria del sigillo della settimana: un solo stelo, rami agganciati che
/// non attraversano lo stelo, non escono dal riquadro e non superano il limite.
void main() {
  final settimana = <String>[
    'Fehu',
    'Uruz',
    'Ansuz',
    'Raidho',
    'Gebo',
    'Wunjo',
    'Laguz',
  ];

  test('Nessun segmento esce dal riquadro', () {
    for (final nomi in [
      settimana,
      kElderFuthark.map((r) => r.name).toList(),
      ['Isa'],
      ['Isa', 'Isa', 'Fehu'],
    ]) {
      for (final ramo in BindruneSigillo.ramiDi(nomi)) {
        for (final p in ramo) {
          expect(p.dx, inInclusiveRange(0.0, 1.0), reason: 'x fuori: $p');
          expect(p.dy, inInclusiveRange(0.0, 1.0), reason: 'y fuori: $p');
        }
      }
    }
  });

  test('I rami non superano il limite dichiarato', () {
    // Tutte e ventiquattro le rune: i rami restano entro il tetto.
    final tutti =
        BindruneSigillo.ramiDi(kElderFuthark.map((r) => r.name).toList());
    expect(tutti.length, lessThanOrEqualTo(BindruneSigillo.maxRami));
    expect(BindruneSigillo.ramiDi(settimana).length,
        lessThanOrEqualTo(BindruneSigillo.maxRami));
  });

  test('Ogni runa porta al massimo due rami', () {
    for (final r in kElderFuthark) {
      expect(BindruneSigillo.ramiDi([r.name]).length,
          lessThanOrEqualTo(BindruneSigillo.maxRamiPerRuna),
          reason: r.name);
    }
  });

  test('Fehu e Uruz non collassano sullo stesso segno', () {
    final fehu = BindruneSigillo.ramiDi(['Fehu']);
    final uruz = BindruneSigillo.ramiDi(['Uruz']);
    expect(fehu, isNotEmpty);
    expect(uruz, isNotEmpty);
    // Fehu porta le sue due barre, Uruz la sua spalla: numero di rami diverso,
    // oppure forma diversa. In ogni caso non sono lo stesso segno.
    final formaFehu = fehu.map((r) => r.length).toList();
    final formaUruz = uruz.map((r) => r.length).toList();
    expect(
        fehu.length != uruz.length ||
            formaFehu.toString() != formaUruz.toString(),
        isTrue,
        reason: 'Fehu e Uruz producono lo stesso disegno');
    // E Fehu ha davvero due barre, che sono il suo segno.
    expect(fehu.length, 2);
  });

  test('Le rune ripetute contano una volta sola', () {
    final uno = BindruneSigillo.ramiDi(['Fehu']);
    final sette = BindruneSigillo.ramiDi(List.filled(7, 'Fehu'));
    expect(sette.length, uno.length);
  });

  test('Nessun ramo attraversa lo stelo', () {
    // Ogni ramo sta interamente da un lato del centro, salvo il punto di
    // aggancio che tocca lo stelo.
    for (final ramo in BindruneSigillo.ramiDi(settimana)) {
      final scarti = ramo.map((p) => p.dx - 0.5).toList();
      final positivi = scarti.where((s) => s > 0.001).length;
      final negativi = scarti.where((s) => s < -0.001).length;
      expect(positivi == 0 || negativi == 0, isTrue,
          reason: 'ramo a cavallo dello stelo: $ramo');
    }
  });

  test('I rami si alternano fra destra e sinistra', () {
    final rami = BindruneSigillo.ramiDi(settimana);
    expect(rami.length, greaterThan(2));
    final lati = <int>[];
    for (final ramo in rami) {
      final estremo = ramo
          .map((p) => p.dx - 0.5)
          .reduce((a, b) => a.abs() > b.abs() ? a : b);
      lati.add(estremo >= 0 ? 1 : -1);
    }
    for (var i = 1; i < lati.length; i++) {
      expect(lati[i], isNot(lati[i - 1]),
          reason: 'due rami di fila sullo stesso lato');
    }
  });

  test('Due rami dello stesso lato non cadono alla stessa quota', () {
    final rami = BindruneSigillo.ramiDi(settimana);
    final quotePerLato = <int, List<double>>{};
    for (final ramo in rami) {
      final estremo = ramo
          .map((p) => p.dx - 0.5)
          .reduce((a, b) => a.abs() > b.abs() ? a : b);
      final lato = estremo >= 0 ? 1 : -1;
      // La quota d'aggancio: il punto piu' vicino allo stelo.
      final aggancio = ramo
          .reduce((a, b) => (a.dx - 0.5).abs() <= (b.dx - 0.5).abs() ? a : b);
      final lista = quotePerLato.putIfAbsent(lato, () => <double>[]);
      for (final q in lista) {
        expect((q - aggancio.dy).abs(), greaterThan(0.02),
            reason: 'due rami sovrapposti sullo stesso lato');
      }
      lista.add(aggancio.dy);
    }
  });

  test('Lo stelo e\' alto il settanta per cento del riquadro', () {
    expect(BindruneSigillo.steloBasso - BindruneSigillo.steloAlto,
        closeTo(0.70, 0.001));
  });

  test('Una runa di solo stelo non genera rami', () {
    // Isa e' un'asta verticale: contribuisce allo stelo, non ai rami.
    expect(BindruneSigillo.ramiDi(['Isa']), isEmpty);
  });
}
