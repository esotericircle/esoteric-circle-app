import 'package:esoteric_circle/core/astro/natal_chart.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/horoscope/cielo_di_oggi.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/rituals/dawn_gift.dart';
import 'package:esoteric_circle/core/rituals/risposta_del_soffio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **L'ALBA E IL SOFFIO NON DICONO LA STESSA COSA.**
/// Ordine CQ voce 2.02, 3 settembre 2026.
///
/// **Il fatto, parole del fondatore:** l'Alba e il Soffio danno risposte
/// identiche.
///
/// **La causa, misurata e non dedotta.** Il Soffio costruisce il suo dono con
/// `DawnGift.forMaestro`, che dentro chiama `RitoAlba.diOggi` con la sola
/// data: il rito, la parola e la risposta erano **letteralmente lo stesso
/// oggetto** di quello dell'Alba. Cambiava il Maestro nella cornice e
/// nient'altro.
///
/// **PROVENIENZA: ordine CE voce 09**, che ha dato al Soffio la scheda comune
/// dei Doni per non scriverne una seconda. La scelta era giusta e il difetto
/// e' nato dal passaggio: la scheda porta il rito, e il rito era uno solo.
///
/// **Cosa NON si pretende qui.** Che i due Doni siano diversi in tutto: il
/// gesto e la parola del giorno restano comuni, ed e' voluto, perche' quella
/// parte e' il rito e il rito e' lo stesso. **Si pretende che sia diversa la
/// RISPOSTA**, che e' la prima cosa che si legge.
void main() {
  // Una carta natale vera serve al Soffio: senza ora e luogo di nascita non
  // ci sono transiti, e il Dono non ha materia propria. E' il caso normale di
  // chi ha completato il Risveglio.
  final carta = NatalChart(
    sunSign: Zodiac.gemini,
    hasTime: true,
    ascendantLongitude: 212.0,
    planets: const [
      PlanetPosition(
          id: 'sun', name: 'Sole', glyph: '☉', longitude: 84.0,
          sign: Zodiac.gemini),
      PlanetPosition(
          id: 'moon', name: 'Luna', glyph: '☽', longitude: 197.0,
          sign: Zodiac.libra),
      PlanetPosition(
          id: 'mars', name: 'Marte', glyph: '♂', longitude: 311.0,
          sign: Zodiac.aquarius),
      PlanetPosition(
          id: 'venus', name: 'Venere', glyph: '♀', longitude: 42.0,
          sign: Zodiac.taurus),
    ],
  );

  test('la risposta del Soffio nasce dai suoi transiti, non dal rito dell Alba',
      () {
    var guardati = 0;
    final uguali = <String>[];
    final esempi = <String>[];
    for (var i = 0; i < 60; i++) {
      final giorno = DateTime(2026, 1, 1).add(Duration(days: i * 6));
      final soffio = RispostaDelSoffio.diOggi(
          CieloDiOggi.perIlGiorno(adesso: giorno, carta: carta));
      if (soffio == null) continue;
      guardati++;
      final donoAlba = DawnGift.forChart(giorno);
      final donoSoffio = DawnGift.forMaestro(giorno, Maestro.aura,
          rispostaPropria: soffio.comeRisposta());
      final titoloAlba = donoAlba.rito?.risposta.titolo;
      final titoloSoffio = donoSoffio.rito?.risposta.titolo;
      if (esempi.length < 2 && titoloSoffio != null) {
        esempi.add('$giorno: Alba "$titoloAlba" / Soffio "$titoloSoffio"');
      }
      if (titoloAlba == titoloSoffio) uguali.add('$giorno');
    }
    // ignore: avoid_print
    print('ORDINE CQ VOCE 2.02: giorni guardati $guardati, con lo stesso '
        'titolo ${uguali.length}. Esempi: ${esempi.join(" | ")}');
    cardinaleMinimo(guardati, 20,
        cosa: 'giorni in cui il Soffio ha una risposta propria',
        perche: 'Senza giorni con transiti veri non ci sarebbe niente da '
            'confrontare, e la prova sarebbe verde per un insieme vuoto.');
    expect(uguali, isEmpty,
        reason: 'in questi giorni il Soffio dice la stessa cosa dell Alba: '
            '${uguali.take(3).join(", ")}');
  });

  test('e il gesto invece resta comune, che e voluto', () {
    final giorno = DateTime(2026, 4, 10);
    final soffio = RispostaDelSoffio.diOggi(
        CieloDiOggi.perIlGiorno(adesso: giorno, carta: carta));
    final donoAlba = DawnGift.forChart(giorno);
    final donoSoffio = DawnGift.forMaestro(giorno, Maestro.aura,
        rispostaPropria: soffio?.comeRisposta());
    // ignore: avoid_print
    print('ORDINE CQ VOCE 2.02: la parola del giorno, Alba '
        '"${donoAlba.rito?.parola}" e Soffio "${donoSoffio.rito?.parola}"');
    expect(donoSoffio.rito?.parola, donoAlba.rito?.parola,
        reason: 'la parola del giorno e diversa fra i due Doni: il rito e lo '
            'stesso, e una parola diversa vorrebbe dire due riti che si '
            'contraddicono nella stessa giornata');
    expect(donoSoffio.rito?.gesto, donoAlba.rito?.gesto,
        reason: 'il gesto e diverso fra i due Doni');
  });

  test('senza transiti il Soffio non finge, e torna al rito comune', () {
    // **CHI NON HA DATO ORA E LUOGO NON HA TRANSITI**, e il Soffio non deve
    // inventarne: torna alla risposta del rito, che e' una risposta vera
    // anche se comune. Meglio dire la stessa cosa dell'Alba che dire una cosa
    // falsa.
    final giorno = DateTime(2026, 4, 10);
    final senza = DawnGift.forMaestro(giorno, Maestro.aura);
    // ignore: avoid_print
    print('ORDINE CQ VOCE 2.02: senza carta il Soffio dice '
        '"${senza.rito?.risposta.titolo}"');
    expect(senza.rito?.risposta.titolo, isNotNull,
        reason: 'senza carta il Soffio resta senza risposta: e un Dono muto');
  });
}
