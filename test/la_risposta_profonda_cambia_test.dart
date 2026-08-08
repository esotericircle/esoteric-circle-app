import 'package:esoteric_circle/core/astro/natal_chart.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/horoscope/cielo_di_oggi.dart';
import 'package:esoteric_circle/core/horoscope/corrente_del_cielo.dart';
import 'package:esoteric_circle/core/horoscope/horoscope.dart';
import 'package:flutter_test/flutter_test.dart';

/// LA RISPOSTA PROFONDA CAMBIA DAVVERO IL TESTO.
///
/// Registro voce 62, ordine 2168 voce 2. Il selettore "Profonda"
/// nell'Oroscopo non produceva alcun effetto visibile.
///
/// **LA CAUSA, letta e non ipotizzata.** Il valore ARRIVA: dalla schermata
/// (`_depth`) passa a `Horoscope.forSign(profonde:)`, poi a `cardFor`, poi a
/// `CorrenteDelCielo.componi(profonda:)`, che con `quanteVoci` prende tre
/// voci del cielo invece di una. Il testo CAMBIA. Ma cambia **solo quando
/// c'e' il cielo vero**: `componi` torna nulla se la carta natale manca, e in
/// quel caso il testo viene dal pool a hash, dove la profondita' non ha
/// nessun effetto. Fino alla 2166 la carta natale non sopravviveva alla
/// chiusura dell'app, quindi per chi riapriva il selettore non faceva
/// letteralmente niente: **il difetto della voce 62 e quello della voce 60
/// erano lo stesso difetto**, visto da due schermate diverse.
///
/// Questa prova misura la DIFFERENZA fra le due profondita' nel testo
/// prodotto, non l'esistenza del selettore: un selettore che c'e' ed e'
/// scollegato e' esattamente cio' che si vuole prendere.
void main() {
  NatalChart cartaCompleta() => const NatalChart(
        sunSign: Zodiac.leo,
        moonSign: Zodiac.pisces,
        ascendant: Zodiac.scorpio,
        ascendantLongitude: 215.4,
        hasTime: true,
        planets: [
          PlanetPosition(
              id: 'sun',
              name: 'Sole',
              glyph: '☉',
              longitude: 142.0,
              sign: Zodiac.leo),
          PlanetPosition(
              id: 'moon',
              name: 'Luna',
              glyph: '☾',
              longitude: 350.0,
              sign: Zodiac.pisces),
          PlanetPosition(
              id: 'mercury',
              name: 'Mercurio',
              glyph: '☿',
              longitude: 130.0,
              sign: Zodiac.leo),
          PlanetPosition(
              id: 'venus',
              name: 'Venere',
              glyph: '♀',
              longitude: 95.0,
              sign: Zodiac.cancer),
          PlanetPosition(
              id: 'mars',
              name: 'Marte',
              glyph: '♂',
              longitude: 200.0,
              sign: Zodiac.libra),
        ],
      );

  test('col cielo vero, profonda dice PIU\' cose di breve', () {
    final cielo = CieloDiOggi.perIlGiorno(
        adesso: DateTime(2026, 8, 8), carta: cartaCompleta());
    if (!cielo.ceCieloVero) {
      // Il cielo di un giorno puo' non portare nessun transito: senza voci
      // non c'e' niente da approfondire, e la prova lo dichiara invece di
      // passare in silenzio su un caso che non ha misurato.
      markTestSkipped('Il cielo di questo giorno non porta transiti: non '
          'c\'e' ' niente da approfondire.');
      return;
    }

    final differenze = <String>[];
    for (final dominio in HoroscopeDomain.values) {
      final breve = Horoscope.cardFor(
        sign: Zodiac.leo,
        dayOfYear: 220,
        year: 2026,
        domain: dominio,
        cielo: cielo,
        profonda: false,
      );
      final profonda = Horoscope.cardFor(
        sign: Zodiac.leo,
        dayOfYear: 220,
        year: 2026,
        domain: dominio,
        cielo: cielo,
        profonda: true,
      );
      // ignore: avoid_print
      print('PROFONDITA\' ${dominio.name}: breve ${breve.text.length} '
          'caratteri, profonda ${profonda.text.length}');
      if (profonda.text == breve.text) {
        differenze.add('${dominio.name}: il testo profondo e\' IDENTICO al '
            'breve, quindi il selettore non fa niente');
      } else if (profonda.text.length <= breve.text.length) {
        differenze.add('${dominio.name}: il testo profondo non e\' piu\' '
            'lungo del breve (${profonda.text.length} contro '
            '${breve.text.length})');
      }
    }
    expect(differenze, isEmpty, reason: differenze.join('\n'));
  });

  test('quante voci prende ciascuna profondita\', dal dato', () {
    // La regola vive qui e si legge: una voce col breve, tre col profondo.
    expect(CorrenteDelCielo.quanteVoci(profonda: false), 1);
    expect(CorrenteDelCielo.quanteVoci(profonda: true), 3);
    expect(CorrenteDelCielo.quanteVoci(profonda: true),
        greaterThan(CorrenteDelCielo.quanteVoci(profonda: false)),
        reason: 'Se le due profondita\' prendessero lo stesso numero di voci, '
            'il selettore sarebbe un comando che non comanda niente.');
  });

  test('SENZA cielo vero la profondita\' non cambia niente, ed e\' la causa '
      'della voce 62', () {
    // **QUESTA PROVA NON CHIEDE UNA CORREZIONE: FISSA LA CAUSA.** Senza carta
    // natale il testo viene dal pool a hash, e li' la profondita' non ha
    // nessun effetto perche' non c'e' nessun cielo da approfondire. E' il
    // motivo per cui Mauro non vedeva succedere niente: la sua carta non
    // sopravviveva alla chiusura dell'app. Il giorno che qualcuno decidesse
    // di dare una risposta profonda anche senza cielo, questa prova cadra' e
    // andra' riscritta con la nuova regola, invece di lasciare credere che
    // il selettore funzionasse gia'.
    const senzaCielo = CieloDiOggi.nessuno;
    final breve = Horoscope.cardFor(
      sign: Zodiac.leo,
      dayOfYear: 220,
      year: 2026,
      domain: HoroscopeDomain.generale,
      cielo: senzaCielo,
      profonda: false,
    );
    final profonda = Horoscope.cardFor(
      sign: Zodiac.leo,
      dayOfYear: 220,
      year: 2026,
      domain: HoroscopeDomain.generale,
      cielo: senzaCielo,
      profonda: true,
    );
    expect(profonda.text, breve.text,
        reason: 'Senza cielo vero i due testi dovrebbero coincidere, perche\' '
            'vengono entrambi dal pool a hash. Se non coincidono piu\', '
            'qualcuno ha dato una risposta profonda anche senza carta: e\' un '
            'cambiamento buono, ma va scritto qui.');
  });
}
