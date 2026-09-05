import 'dart:io';

import 'package:esoteric_circle/core/astro/natal_chart.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/horoscope/cielo_di_oggi.dart';
import 'package:esoteric_circle/core/rituals/risposta_del_soffio.dart';
import 'package:flutter_test/flutter_test.dart';

/// LA RISPOSTA DEL SOFFIO, e la forma che non deve avere.
///
/// Il Soffio non lascia una parola, perche' quella e' del Rito dell'Alba, e non
/// lascia un gesto, perche' l'Alba chiude gia' con un gesto. Lascia una
/// risposta: cosa si apre e cosa oggi non si lascia forzare. **E la forma
/// conta quanto il contenuto**: l'Alba comanda, "volgi lo sguardo", "appoggia
/// le mani", e se il Soffio comandasse anche lui i due riti si
/// somiglierebbero, che e' esattamente cio' che si voleva evitare facendone
/// due.
void main() {
  /// Una carta vera, con l'ascendente: senza ora e luogo il cielo non si
  /// interroga sulla carta, e la risposta non deve uscire affatto.
  const carta = NatalChart(
    sunSign: Zodiac.aries,
    hasTime: true,
    ascendantLongitude: 15.0,
    midheavenLongitude: 285.0,
    planets: [
      PlanetPosition(
          id: 'sun',
          name: 'Sole',
          glyph: '☉',
          longitude: 10.0,
          sign: Zodiac.aries),
      PlanetPosition(
          id: 'moon',
          name: 'Luna',
          glyph: '☽',
          longitude: 100.0,
          sign: Zodiac.cancer),
      PlanetPosition(
          id: 'mars',
          name: 'Marte',
          glyph: '♂',
          longitude: 200.0,
          sign: Zodiac.libra),
      PlanetPosition(
          id: 'venus',
          name: 'Venere',
          glyph: '♀',
          longitude: 250.0,
          sign: Zodiac.sagittarius),
      PlanetPosition(
          id: 'saturn',
          name: 'Saturno',
          glyph: '♄',
          longitude: 320.0,
          sign: Zodiac.aquarius),
    ],
  );

  CieloDiOggi cieloDi(DateTime giorno) =>
      CieloDiOggi.perIlGiorno(adesso: giorno, carta: carta);

  test('senza carta non c e risposta, e non c e un ripiego che parla lo stesso',
      () {
    final senza =
        CieloDiOggi.perIlGiorno(adesso: DateTime(2026, 8, 6), carta: null);
    expect(RispostaDelSoffio.diOggi(senza), isNull,
        reason: 'senza carta la risposta esce lo stesso: e un oroscopo da '
            'giornale travestito da transito');
  });

  test('la risposta esce dai transiti veri, e li nomina', () {
    var viste = 0;
    for (var g = 1; g <= 60; g++) {
      final r = RispostaDelSoffio.diOggi(
          cieloDi(DateTime(2026, 8, 1).add(Duration(days: g))));
      if (r == null) continue;
      viste++;
      for (final riga in [r.apre, r.nonForzare]) {
        if (riga == null) continue;
        // NOMINA IL CIELO DA CUI VIENE: chi legge deve poter risalire al
        // transito, non fidarsi.
        expect(riga.contains(' in '), isTrue, reason: riga);
        expect(riga.endsWith('.'), isTrue, reason: riga);
      }
    }
    expect(viste, greaterThan(30),
        reason: 'in sessanta giorni la risposta e uscita solo $viste volte: '
            'la prova non copre abbastanza cielo per dire qualcosa');
  });

  test('la variante che nomina un transito assente NON entra', () {
    // La regola dell'ordine, presa alla lettera. Le due righe nascono da due
    // famiglie di aspetto diverse: quando una famiglia non c'e' nel cielo di
    // quel giorno, la riga non compare, e non ne compare una al posto suo.
    var conSoloUna = 0;
    for (var g = 1; g <= 120; g++) {
      final cielo = cieloDi(DateTime(2026, 1, 1).add(Duration(days: g)));
      final r = RispostaDelSoffio.diOggi(cielo);
      if (r == null) continue;
      final morbide =
          cielo.voci.where((v) => v.aspetto.harmony == AspectHarmony.soft);
      final tese =
          cielo.voci.where((v) => v.aspetto.harmony == AspectHarmony.hard);
      expect(r.apre != null, morbide.isNotEmpty,
          reason: 'la riga di cio che si apre non segue il cielo');
      expect(r.nonForzare != null, tese.isNotEmpty,
          reason: 'la riga di cio che non cede non segue il cielo');
      if (r.apre == null || r.nonForzare == null) conSoloUna++;
    }
    // E il caso capita davvero: se non capitasse mai, la prova qui sopra
    // sarebbe verde senza aver mai percorso il ramo che le interessa.
    expect(conSoloUna, greaterThan(0),
        reason: 'in centoventi giorni non e mai mancata una delle due '
            'famiglie: questa prova non ha mai misurato l assenza');
  });

  test('la risposta non comanda MAI, e non e la forma dell Alba', () {
    // I MODI IMPERATIVI CHE L'ALBA USA DAVVERO, presi dal suo corpus e non
    // inventati: sono i verbi con cui l'Alba apre le sue frasi.
    const comandi = [
      'volgi',
      'appoggia',
      'alzati',
      'guarda',
      'poggia',
      'apri',
      'chiudi',
      'bevi',
      'sbadiglia',
      'disegna',
      'scegli',
      'prendi',
      'copri',
      'spegni',
      'allunga',
      'individua',
      'trova',
      'resta',
      'conta',
      'tieni',
      'fai',
    ];
    final rotte = <String>[];
    for (var g = 1; g <= 120; g++) {
      final r = RispostaDelSoffio.diOggi(
          cieloDi(DateTime(2026, 1, 1).add(Duration(days: g))));
      if (r == null) continue;
      for (final riga in [r.apre, r.nonForzare]) {
        if (riga == null) continue;
        final parole = riga.toLowerCase().split(RegExp(r'[^a-zàèéìòù]+'));
        for (final c in comandi) {
          if (parole.contains(c)) rotte.add('"$c" dentro: $riga');
        }
        // Ne' una domanda, ne' una promessa di esito.
        if (riga.contains('?')) rotte.add('una domanda: $riga');
        for (final p in const [
          'andrà',
          'andra',
          'otterrai',
          'riuscirai',
          'sarà',
          'sara',
          'vedrai',
          'troverai'
        ]) {
          if (parole.contains(p)) rotte.add('una promessa "$p": $riga');
        }
      }
    }
    expect(rotte, isEmpty,
        reason: 'la risposta del Soffio ha preso la forma dell Alba:\n'
            '${rotte.take(5).join('\n')}');
  });

  test('e non passa da una seconda porta sul cielo', () {
    // TRASVERSALE, sul FATTO: il file che compone la risposta deve interrogare
    // il cielo solo attraverso la porta che c'e' gia'. Una seconda porta
    // potrebbe dire una cosa diversa dell'Oroscopo nella stessa mattina.
    final sorgente =
        File('lib/core/rituals/risposta_del_soffio.dart').readAsStringSync();
    for (final vietato in const [
      'AspettiDiOggi.perIlGiorno',
      'TransitiDelGiorno',
      'Effemeridi',
    ]) {
      expect(sorgente.contains(vietato), isFalse,
          reason: 'la risposta si calcola il cielo per conto suo ($vietato) '
              'invece di riceverlo dalla porta che gia esiste');
    }
  });
}
