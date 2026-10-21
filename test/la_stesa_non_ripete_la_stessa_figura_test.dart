// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/astro/natal_chart.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/horoscope/cielo_di_oggi.dart';
import 'package:esoteric_circle/core/horoscope/corrente_del_cielo.dart';
import 'package:esoteric_circle/core/tarot/figure_della_stesa.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:esoteric_circle/core/tarot/voce_della_stesa.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **DENTRO UNA STESSA STESA NON SI RIPETE LA STESSA IMMAGINE.** Ordine DS
/// voce 09, 17 settembre 2026.
///
/// Un fondatore esterno ha sottolineato a mano due righe dello stesso
/// Consiglio: *"un passaggio stretto che si attraversa, non un muro"* e *"un
/// nodo da sciogliere e non un muro"*.
///
/// **Cosa si misura.** Il Consiglio, cioe' il testo che l'app compone a pezzi
/// da tavole diverse: e' li' che un pezzo non sapeva cosa aveva detto l'altro.
/// I testi delle tre carte sono il corpus della carta, uno per carta e per
/// verso, e non sono composti qui.
///
/// **Dall'ordine GA, voci GA.03 e GA.07, 20 ottobre 2026**, il Consiglio e'
/// il responso principale di casa, `VoceDellaStesa.responsoDiCasa`: due
/// paragrafi da sei pezzi. Il fatto del cielo non sta piu' nei paragrafi,
/// va nel "Da dove viene" della stessa schermata: resta il primo dei pezzi,
/// e le forme scelte continuano a girargli intorno.
void main() {
  test('il rilevatore prende la ripetizione vista dal fondatore', () {
    final ripetute = FigureDellaStesa.ripetute(
        'Davanti a te c\'è la Torre. E non è una condanna: è un passaggio '
        'stretto che si attraversa, non un muro. Una delle tre è uscita al '
        'rovescio, quindi c\'è un nodo da sciogliere e non un muro.');
    expect(ripetute.keys, contains('barriera'));
    // E prende la stessa figura detta con un'altra parola.
    expect(
        FigureDellaStesa.ripetute(
                'C\'è un nodo da sciogliere. La quadratura si sta sciogliendo.')
            .keys,
        contains('nodo'));
  });

  test('il lessico porta le figure che il Consiglio usa davvero', () {
    for (final figura in const [
      'barriera',
      'nodo',
      'strada',
      'passo',
      'passaggio',
      'terreno',
      'rotta',
      'granello',
      'frana',
    ]) {
      expect(FigureDellaStesa.famiglie.keys, contains(figura),
          reason: 'il lessico ha perso la figura $figura: la guardia sotto '
              'smetterebbe di vederla senza cadere');
    }
  });

  final carta = NatalChart(
    sunSign: Zodiac.leo,
    planets: const [
      PlanetPosition(
          id: 'sun',
          name: 'Sole',
          glyph: '☉',
          longitude: 128.4,
          sign: Zodiac.leo),
      PlanetPosition(
          id: 'moon',
          name: 'Luna',
          glyph: '☽',
          longitude: 12.7,
          sign: Zodiac.leo),
      PlanetPosition(
          id: 'venus',
          name: 'Venere',
          glyph: '♀',
          longitude: 95.0,
          sign: Zodiac.cancer),
    ],
    ascendantLongitude: 205.0,
    midheavenLongitude: 115.0,
    houses: [
      for (var n = 1; n <= 12; n++)
        HouseCusp(number: n, longitude: (205.0 + (n - 1) * 30.0) % 360.0),
    ],
    hasTime: true,
  );

  test('DIECI STESE DI FILA, per intero, e nessuna ripete una figura', () {
    final adesso = DateTime(2026, 9, 17, 0, 37);
    final fatto = CorrenteDelCielo.fattoDelGiorno(
        CieloDiOggi.perIlGiorno(adesso: adesso, carta: carta));
    final colpevoli = <String>[];
    for (var i = 0; i < 10; i++) {
      final spread =
          TarotSpread.dalMazzo(TarotSpread.mazzoMescolato(seed: 1709 + i));
      final topic = TarotTopic.values[i % TarotTopic.values.length];
      final letto =
          VoceDellaStesa.responsoDiCasa(spread, topic, fattoDelCielo: fatto);
      print('ORDINE DS VOCE 09, STESA ${i + 1}: '
          '${spread.cards.map((c) => '${c.card.name}${c.reversed ? " (rovesciata)" : ""}').join(', ')}\n'
          '${letto.titolo}\n${letto.risposta}\n${letto.cosaFare}\n');
      final r = FigureDellaStesa.ripetuteFra(
          VoceDellaStesa.pezzi(spread, topic, fattoDelCielo: fatto));
      if (r.isNotEmpty) colpevoli.add('stesa ${i + 1}: $r');
    }
    expect(colpevoli, isEmpty, reason: colpevoli.join('\n'));
  });

  test('i pezzi sono il Consiglio: ognuno sta nel testo che si legge', () {
    // **Dall'ordine GA il Consiglio e' il responso principale di casa**, la
    // risposta e il "Cosa fare adesso": sei pezzi, il verdetto, che cosa dice
    // la carta che regge, che cosa vuol dire, l'aggancio, il gesto e
    // l'approdo. Erano otto o piu', col legame, il seguito, i versi e la
    // chiusura del terzo paragrafo, che la forma Breve non ha piu'.
    var guardati = 0;
    // Sessanta semi e non quaranta dall'ordine GA voce GA.06: i pezzi per
    // lettura sono scesi da sei a cinque o sei, e il cardinale resta 240.
    for (var seme = 0; seme < 60; seme++) {
      final spread =
          TarotSpread.dalMazzo(TarotSpread.mazzoMescolato(seed: seme));
      final topic = TarotTopic.values[seme % TarotTopic.values.length];
      final testo = VoceDellaStesa.paragrafi(spread, topic).join('\n\n');
      final pezzi = VoceDellaStesa.pezzi(spread, topic);
      // Senza questa prova i pezzi potrebbero essere una lista qualunque, e
      // la guardia sotto misurerebbe un testo che nessuno legge.
      // **Dall'ordine GA voce GA.06 i pezzi sono le frasi scelte**, da tre a
      // sei per paragrafo secondo la domanda e le carte (LAPIDE: "sei pezzi",
      // il verdetto, che cosa dice, che cosa vuol dire, l'aggancio, il gesto e
      // l'approdo delle forme a segnaposto).
      expect(pezzi.length, greaterThanOrEqualTo(5),
          reason: 'seme $seme: ${pezzi.length} pezzi');
      for (final p in pezzi) {
        final senzaSegnaposto = p
            .split(RegExp(r'\{\w+\}|\[[^\]]*\]'))
            .where((s) => s.trim().length > 12);
        for (final s in senzaSegnaposto) {
          guardati++;
          expect(testo, contains(s.trim()),
              reason: 'il pezzo "$p" non sta nel responso');
        }
      }
    }
    cardinaleMinimo(guardati, 40 * 6, cosa: 'pezzi cercati nel responso');
  });

  test('DUEMILA STESE, con e senza cielo: nessuna figura in due pezzi', () {
    final adesso = DateTime(2026, 9, 17, 0, 37);
    final fatto = CorrenteDelCielo.fattoDelGiorno(
        CieloDiOggi.perIlGiorno(adesso: adesso, carta: carta));
    final perFigura = <String, int>{};
    var guardate = 0;
    String? esempio;
    for (var seme = 0; seme < 1000; seme++) {
      final spread =
          TarotSpread.dalMazzo(TarotSpread.mazzoMescolato(seed: seme));
      for (final cielo in [null, fatto]) {
        final topic = TarotTopic.values[seme % TarotTopic.values.length];
        guardate++;
        final r = FigureDellaStesa.ripetuteFra(
            VoceDellaStesa.pezzi(spread, topic, fattoDelCielo: cielo));
        for (final f in r.keys) {
          perFigura[f] = (perFigura[f] ?? 0) + 1;
          esempio ??= '${r[f]}';
        }
      }
    }
    print('ORDINE DS VOCE 09: Consigli guardati $guardate, figure ripetute '
        '$perFigura');
    expect(guardate, 2000);
    expect(perFigura, isEmpty, reason: 'per esempio: $esempio');
  });

  test('la coda del transito segue l\'aspetto, non il punto di nascita', () {
    final frasi = <String>[];
    for (var g = 0; g < 120; g++) {
      final cielo = CieloDiOggi.perIlGiorno(
          adesso: DateTime(2026, 1, 1).add(Duration(days: g)), carta: carta);
      final f = CorrenteDelCielo.fattoDelGiorno(cielo);
      if (f != null) frasi.add(f);
    }
    final ambigue = frasi
        .where((f) => RegExp(
                r'(di nascita|Ascendente|Medio Cielo) che si sta (stringendo|sciogliendo)')
            .hasMatch(f))
        .toSet();
    print('ORDINE DS VOCE 09: fatti del giorno guardati ${frasi.length}, con '
        'la coda attaccata al punto di nascita ${ambigue.length}');
    expect(frasi.length, greaterThan(40));
    expect(ambigue, isEmpty,
        reason: 'la coda si attacca al punto di nascita, e un Sole di nascita '
            'non si scioglie: ${ambigue.take(3)}');
  });
}
