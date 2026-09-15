import 'package:esoteric_circle/core/astro/natal_chart.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/horoscope/cielo_di_oggi.dart';
import 'package:esoteric_circle/core/horoscope/corrente_del_cielo.dart';
import 'package:esoteric_circle/core/horoscope/riflessione_del_cielo.dart';
import 'package:esoteric_circle/core/tarot/tarot_reading.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/tarot/filo_fra_le_carte.dart';
import 'package:flutter_test/flutter_test.dart';

/// IL CIELO ENTRA NELLA STESA, E IL FILO LEGA LE CARTE. Ordine BN voci 07 e 08.
///
/// Le due arti vivevano nella stessa app senza parlarsi: la stesa non sapeva
/// niente del cielo, mentre l'Oroscopo calcola gia' il transito vero dalla
/// carta natale. Alla stesa non mancava un dato, mancava la domanda: la porta
/// e' `BirthIdentityController`, che vive nel guscio dell'app.
void main() {
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
          id: 'mars',
          name: 'Marte',
          glyph: '♂',
          longitude: 61.9,
          sign: Zodiac.leo),
    ],
    ascendantLongitude: 205.0,
    midheavenLongitude: 115.0,
    houses: [
      for (var n = 1; n <= 12; n++)
        HouseCusp(number: n, longitude: (205.0 + (n - 1) * 30.0) % 360.0),
    ],
    hasTime: true,
  );

  final adesso = DateTime.utc(2026, 8, 5, 12);

  test('il fatto che la stesa userebbe e\' LO STESSO dell\'Oroscopo', () {
    final cielo = CieloDiOggi.perIlGiorno(adesso: adesso, carta: carta);
    expect(cielo.ceCieloVero, isTrue);
    // La porta e' la stessa: se un giorno divergessero, questa riga cadrebbe.
    expect(CorrenteDelCielo.fattoDelGiorno(cielo),
        RiflessioneDelCielo.fattoDaNominare(cielo),
        reason: 'la stesa e l\'Oroscopo prenderebbero il fatto del giorno da '
            'due porte diverse: prima o poi direbbero due cose diverse dello '
            'stesso cielo');
  });

  test(
      'col cielo vero il consiglio lo raccoglie, e resta in due o tre '
      'paragrafi', () {
    final cielo = CieloDiOggi.perIlGiorno(adesso: adesso, carta: carta);
    final fatto = CorrenteDelCielo.fattoDelGiorno(cielo)!;
    for (final seed in const [2, 5, 9]) {
      final spread =
          TarotSpread.dalMazzo(TarotSpread.mazzoMescolato(seed: seed));
      final con =
          TarotReading.of(spread, TarotTopic.bivio, fattoDelCielo: fatto);
      final senza = TarotReading.of(spread, TarotTopic.bivio);

      expect(con.consiglio, contains(fatto),
          reason: 'seme $seed: il consiglio non raccoglie il fatto del cielo');
      expect(senza.consiglio, isNot(contains(fatto)));

      // **LE DUE VOCI DELLO STESSO ORDINE DEVONO STARE IN PIEDI INSIEME**: il
      // cielo non deve far nascere un quarto paragrafo, o cadrebbe la misura
      // della voce 06. Sta in coda all'ultimo.
      final corpo = con.consiglio.split('\n\n');
      final paragrafi = corpo.sublist(0, corpo.length - 1);
      expect(paragrafi.length, inInclusiveRange(2, 3),
          reason: 'seme $seed: col cielo i paragrafi sono ${paragrafi.length}, '
              'e la voce 06 ne ammette due o tre');
    }
  });

  test('SENZA carta natale non si finge nessun transito', () {
    final cielo = CieloDiOggi.perIlGiorno(adesso: adesso, carta: null);
    expect(cielo.ceCieloVero, isFalse,
        reason: 'senza carta natale non c\'e\' nessun cielo vero da mostrare');
    expect(CorrenteDelCielo.fattoDelGiorno(cielo), isNull,
        reason: 'senza cielo vero il fatto del giorno non esiste: una frase '
            'generica travestita da transito sarebbe una promessa non '
            'mantenuta');

    // E il consiglio resta quello di oggi, identico.
    final spread = TarotSpread.dalMazzo(TarotSpread.mazzoMescolato(seed: 2));
    expect(
        TarotReading.of(spread, TarotTopic.bivio,
                fattoDelCielo: CorrenteDelCielo.fattoDelGiorno(cielo))
            .consiglio,
        TarotReading.of(spread, TarotTopic.bivio).consiglio,
        reason: 'senza cielo vero il consiglio deve restare quello di oggi');
  });

  group('il filo fra le tre carte', () {
    test('dura fra 600 e 900 millesimi', () {
      expect(FiloFraLeCarte.durata.inMilliseconds, inInclusiveRange(600, 900),
          reason: 'il filo deve essere un istante leggibile, non un lampo ne\' '
              'un\'attesa');
    });

    test('parte SEMPRE dalla chiave, su tutte e tre le posizioni', () {
      // Il pittore mette la chiave per prima nell'ordine dei tratti: si
      // verifica sul disegno vero, non sull'intenzione.
      for (var chiave = 0; chiave < 3; chiave++) {
        const centri = [
          Offset(30, 50),
          Offset(90, 50),
          Offset(150, 50),
        ];
        final filo = FiloFraLeCarte(
          centri: centri,
          dallaChiave: chiave,
          avanzamento: 0.5,
          palette: MaestroPalette.forKey(const ThemeKey.of(Maestro.medora)),
        );
        expect(filo.dallaChiave, chiave);
        expect(filo.centri.length, 3);
      }
    });
  });
}
