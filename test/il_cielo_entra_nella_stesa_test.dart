import 'package:esoteric_circle/core/astro/natal_chart.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/horoscope/cielo_di_oggi.dart';
import 'package:esoteric_circle/core/horoscope/corrente_del_cielo.dart';
import 'package:esoteric_circle/core/horoscope/riflessione_del_cielo.dart';
import 'package:esoteric_circle/core/responsi/la_forma_del_responso.dart';
import 'package:esoteric_circle/core/tarot/tarot_reading.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:esoteric_circle/core/tarot/voce_della_stesa.dart';
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

  // **LAPIDE: "col cielo vero il consiglio lo raccoglie, e resta in due o tre
  // paragrafi".** Ordine GA voci GA.03 e GA.07, 20 ottobre 2026: la riga del
  // cielo vero non sta piu' nei paragrafi del responso, che hanno da 40 a 50
  // parole ciascuno e con lei dentro uscirebbero dalla misura; va nel "Da
  // dove viene", e la mette `TarotReading`. Della lettura di casa resta da
  // pretendere che il cielo non entri nei paragrafi, che non cambi la loro
  // misura e che le forme scelte girino intorno alle sue figure.
  test(
      'col cielo vero la lettura di casa resta in due paragrafi nella misura, '
      'e il cielo non ci entra', () {
    final cielo = CieloDiOggi.perIlGiorno(adesso: adesso, carta: carta);
    final fatto = CorrenteDelCielo.fattoDelGiorno(cielo)!;
    for (final seed in const [2, 5, 9]) {
      final spread =
          TarotSpread.dalMazzo(TarotSpread.mazzoMescolato(seed: seed));
      final con = VoceDellaStesa.paragrafi(spread, TarotTopic.bivio,
          fattoDelCielo: fatto);
      final pezzi =
          VoceDellaStesa.pezzi(spread, TarotTopic.bivio, fattoDelCielo: fatto);

      expect(con.join(' '), isNot(contains(fatto)),
          reason: 'seme $seed: il fatto del cielo e\' tornato nei paragrafi');
      expect(con, hasLength(2), reason: 'seme $seed: ${con.length} paragrafi');
      for (final p in con) {
        expect(LaFormaDelResponso.aMisura(p), isTrue,
            reason: 'seme $seed: col cielo un paragrafo ha '
                '${LaFormaDelResponso.parole(p)} parole');
      }
      // Il cielo resta il primo dei pezzi: le figure gli girano intorno.
      expect(pezzi.first, fatto.trim());
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

    // E il consiglio resta quello di oggi, identico. Per la lettura di casa
    // la pretesa e' che un cielo vuoto, che e' cio' che arriva quando il
    // fatto del giorno manca, non sposti nemmeno una scelta (ordine GA: il
    // fatto nullo e il fatto vuoto sono la stessa assenza).
    final spread = TarotSpread.dalMazzo(TarotSpread.mazzoMescolato(seed: 2));
    for (final vuoto in const ['', '   ']) {
      expect(
          VoceDellaStesa.paragrafi(spread, TarotTopic.bivio,
              fattoDelCielo: vuoto),
          VoceDellaStesa.paragrafi(spread, TarotTopic.bivio),
          reason: 'un cielo vuoto cambia la lettura di casa');
    }
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
