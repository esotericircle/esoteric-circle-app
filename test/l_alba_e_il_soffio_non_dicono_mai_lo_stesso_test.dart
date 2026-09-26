import 'package:esoteric_circle/core/astro/natal_chart.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/horoscope/cielo_di_oggi.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/rituals/dawn_gift.dart';
import 'package:esoteric_circle/core/rituals/risposta_del_soffio.dart';
import 'package:flutter_test/flutter_test.dart';

/// L'ALBA E IL SOFFIO NON DICONO MAI LO STESSO. 7 settembre 2026.
///
/// **Il fatto, per la seconda volta.** Parole del fondatore: *"i responsi di
/// Alba e Soffio sono ancora uguali"*. La prima volta era l'ordine CQ voce
/// 2.02, del 3 settembre.
///
/// **Perche' la prima riparazione non e' bastata, misurato.** Il Soffio aveva
/// preso una materia sua, i transiti veri sulla carta natale, e la passava al
/// dono come `rispostaPropria`. Ma `RispostaDelSoffio.diOggi` torna **nulla**
/// quando i transiti non ci sono, cioe' quando la carta natale non e'
/// completa, e `DawnGift.forMaestro` con `rispostaPropria` nulla restituisce
/// il rito dell'Alba intero, risposta compresa.
///
/// La riparazione valeva quindi solo per chi aveva dato ora e luogo di
/// nascita. **Chi non li aveva dati continuava a leggere la stessa frase due
/// volte al giorno**, e la condizione non era scritta da nessuna parte.
///
/// **QUESTA PROVA COPRE I TRE CASI, e la prima ne copriva uno.** E' l'unica
/// differenza che conta: una prova che monta solo la carta completa e' verde
/// mentre il difetto vive nel caso piu' comune.
void main() {
  final giorno = DateTime.utc(2026, 9, 7, 7);

  /// La carta di chi ha dato tutto.
  final completa = NatalChart(
    sunSign: Zodiac.leo,
    planets: const [
      PlanetPosition(
          id: 'sun', name: 'Sole', glyph: 'O', longitude: 128.4,
          sign: Zodiac.leo),
      PlanetPosition(
          id: 'moon', name: 'Luna', glyph: 'D', longitude: 12.7,
          sign: Zodiac.leo),
      PlanetPosition(
          id: 'venus', name: 'Venere', glyph: 'V', longitude: 44.2,
          sign: Zodiac.leo),
      PlanetPosition(
          id: 'mars', name: 'Marte', glyph: 'M', longitude: 61.9,
          sign: Zodiac.leo),
      PlanetPosition(
          id: 'saturn', name: 'Saturno', glyph: 'S', longitude: 300.5,
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

  /// La carta di chi ha detto "l'ora non la so".
  const senzaOra = NatalChart(
    sunSign: Zodiac.leo,
    planets: [
      PlanetPosition(
          id: 'sun', name: 'Sole', glyph: 'O', longitude: 128.4,
          sign: Zodiac.leo),
      PlanetPosition(
          id: 'moon', name: 'Luna', glyph: 'D', longitude: 12.7,
          sign: Zodiac.leo),
    ],
    hasTime: false,
  );

  final identita = BirthIdentity(birthMoment: DateTime(1990, 8, 10, 12));

  /// I due responsi dello stesso giorno, per la stessa persona.
  ({String? alba, String? soffio}) iDueResponsi(NatalChart? carta) {
    final alba = DawnGift.forChart(giorno,
        identity: carta == null ? null : identita, carta: carta);
    final propria = RispostaDelSoffio.diOggi(
        CieloDiOggi.perIlGiorno(adesso: giorno, carta: carta));
    // La schermata compone cosi': la materia del cielo se c'e', altrimenti
    // quella della Luna. Mai nulla, che e' il ramo da cui usciva l'Alba.
    final soffio = DawnGift.forMaestro(giorno, Maestro.aura,
        identity: carta == null ? null : identita,
        carta: carta,
        rispostaPropria:
            propria?.comeRisposta() ?? RispostaDelSoffio.senzaIlTuoCielo(giorno));
    String? intero(DawnGift g) => g.rito == null
        ? null
        : '${g.rito!.risposta.titolo} | ${g.rito!.risposta.risposta}';
    return (alba: intero(alba), soffio: intero(soffio));
  }

  const casi = <String, int>{
    'senza carta natale': 0,
    'con la carta ma senza ora': 1,
    'con la carta completa': 2,
  };

  test('Nei tre casi i due responsi sono diversi', () {
    expect(casi.length, 3,
        reason: 'i casi provati sono ${casi.length}: con meno di tre questa '
            'prova torna a coprire solo quello che era gia\' sano');
    final guardati = <String>[];
    casi.forEach((nome, quale) {
      final carta = switch (quale) {
        0 => null,
        1 => senzaOra,
        _ => completa,
      };
      final due = iDueResponsi(carta);
      expect(due.alba, isNotNull,
          reason: '[$nome] l\'Alba non ha nessun responso, quindi il '
              'confronto non misura niente');
      expect(due.soffio, isNotNull,
          reason: '[$nome] il Soffio non ha nessun responso');
      expect(due.soffio, isNot(due.alba),
          reason: 'NEL CASO "$nome" L\'ALBA E IL SOFFIO DICONO LA STESSA '
              'COSA:\n${due.alba}\n'
              'Due Doni con la stessa risposta a due ore di distanza sono un '
              'Dono solo mostrato due volte.');
      guardati.add(nome);
    });
    expect(guardati.length, casi.length,
        reason: 'il ciclo ha guardato ${guardati.length} casi su '
            '${casi.length}');
  });

  test('Senza il tuo cielo il Soffio dice comunque a cosa serve il respiro',
      () {
    // **IL TITOLO DICE COSA SI OTTIENE**, non com'e' il cielo. Ordine del
    // fondatore del 7 settembre: *"bisogna dichiarare a cosa serve, cosa si
    // ottiene quel giorno facendo il respiro"*.
    final r = RispostaDelSoffio.senzaIlTuoCielo(giorno);
    expect(r.titolo.toLowerCase(), contains('respiro'),
        reason: 'il titolo non nomina il respiro: "${r.titolo}"');
    expect(r.titolo.toLowerCase(), contains('ti serve a'),
        reason: 'il titolo non dice a cosa serve il respiro di oggi: '
            '"${r.titolo}"');
    expect(r.risposta.trim(), isNotEmpty,
        reason: 'il ripiego non porta nessuna riga sotto il titolo');
  });

  test('Il ripiego cambia col giorno, quindi non e\' una frase fissa', () {
    // La Luna cambia segno ogni due giorni e mezzo e fase ogni settimana: su
    // un mese i titoli distinti devono essere piu' di uno. Una frase fissa
    // sarebbe un secondo modo di dire sempre la stessa cosa, cioe' il difetto
    // da cui si viene.
    final titoli = <String>{};
    for (var g = 0; g < 30; g++) {
      titoli.add(RispostaDelSoffio.senzaIlTuoCielo(
              giorno.add(Duration(days: g)))
          .titolo);
    }
    expect(titoli.length, greaterThan(1),
        reason: 'su trenta giorni il ripiego dice sempre "${titoli.first}": '
            'e\' una frase fissa travestita da responso');

    final righe = <String>{};
    for (var g = 0; g < 30; g++) {
      righe.add(RispostaDelSoffio.senzaIlTuoCielo(giorno.add(Duration(days: g)))
          .risposta);
    }
    expect(righe.length, greaterThan(5),
        reason: 'su trenta giorni le righe distinte sono ${righe.length}: la '
            'Luna cambia segno ogni due giorni e mezzo, quindi ne servono di '
            'piu\'');
  });
}
