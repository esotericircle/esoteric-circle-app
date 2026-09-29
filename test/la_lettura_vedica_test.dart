// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/astro/l_alba_e_il_tramonto.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/horoscope/horoscope.dart';
import 'package:esoteric_circle/core/horoscope/i_segni_delle_tradizioni.dart';
import 'package:esoteric_circle/core/horoscope/la_lettura_vedica.dart';
import 'package:esoteric_circle/core/horoscope/oroscopo_vedico_data.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **LA TRADIZIONE VEDICA, APERTA. Ordine ES voce 09, 29 settembre 2026.**
///
/// Il fondatore: *"Se sceglie oroscopo cinese significa che è selezionabile e
/// sbloccato"*, e per la Vedica il metodo dell'Architetto (segno lunare
/// siderale di Lahiri, Chandra Bala, Tara Bala, Rahu Kalam), *"COnfermo
/// tutto."*.
///
/// Cosa si pretende, contro Drik Panchang
/// (`docs/collaudo/ES/vedica_verifica.csv`, `rahu_kalam.csv`):
/// - il rashi e il nakshatra di venti nascite;
/// - l'alba, il tramonto e il Rahu Kalam di Roma, Milano e Palermo, sette
///   giorni, al minuto;
/// - la Chandra Bala e la Tara Bala della regola (l'esempio di Raman);
/// - le schede: la frase del gruppo giusto, il livello della regola scritto
///   nella prova, l'altra frase al ritorno dello stesso caso, nessun
///   segnaposto, il corpus uguale al codice.
void main() {
  const offsetDiRoma = Duration(hours: 2); // ottobre, ora legale
  final citta = {
    'Roma': const LuogoDelGiorno(
        lat: 41 + 53 / 60 + 30 / 3600,
        lon: 12 + 30 / 60 + 40 / 3600,
        citta: 'Roma'),
    'Milano': const LuogoDelGiorno(
        lat: 45 + 27 / 60 + 51 / 3600,
        lon: 9 + 11 / 60 + 22 / 3600,
        citta: 'Milano'),
    'Palermo': const LuogoDelGiorno(
        lat: 38 + 7 / 60 + 55 / 3600,
        lon: 13 + 20 / 60 + 8 / 3600,
        citta: 'Palermo'),
  };

  String hm(DateTime utc) {
    final l = utc.add(offsetDiRoma);
    return '${l.hour.toString().padLeft(2, '0')}:'
        '${l.minute.toString().padLeft(2, '0')}';
  }

  test('venti nascite: rashi e nakshatra di Drik Panchang', () {
    final righe = File('docs/collaudo/ES/vedica_verifica.csv')
        .readAsLinesSync()
        .skip(1)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => r.split(','))
        .toList();
    cardinaleMinimo(righe.length, 20, cosa: 'nascite');
    const drik = {
      'Ashwini': 'Ashvini', 'Swati': 'Svati', 'Mrigashirsha': 'Mrigashira', //
    };
    final diversi = <String>[];
    for (final c in righe) {
      final ut = DateTime.parse('${c[3].replaceFirst(' ', 'T')}:00Z');
      final (r, k) = LaLetturaVedica.lunaAlle(ut);
      var rashi = ISegniDelleTradizioni.rashi[r];
      if (rashi == 'Mina') rashi = 'Meena';
      final nak = LaLetturaVedica.nakshatra[k].$1;
      final atteso = drik[c[11]] ?? c[11];
      if (rashi != c[10] || nak != atteso) {
        diversi.add('${c[0]}: $rashi $nak, Drik ${c[10]} ${c[11]}');
      }
    }
    print('ORDINE ES VOCE 09: nascite con rashi o nakshatra diverso da Drik '
        '${diversi.length} su ${righe.length}');
    expect(diversi, isEmpty, reason: diversi.join('\n'));
  });

  test('alba, tramonto e Rahu Kalam al minuto di Drik Panchang', () {
    final righe = File('docs/collaudo/ES/rahu_kalam.csv')
        .readAsLinesSync()
        .skip(1)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => r.split(','))
        .toList();
    cardinaleMinimo(righe.length, 21, cosa: 'giorni del Rahu Kalam');
    var estremi = 0;
    final diversi = <String>[];
    var scartoMassimo = 0.0;
    for (final c in righe) {
      final g = DateTime.parse(c[1]);
      final luogo = citta[c[0]]!;
      final e = LAlbaEIlTramonto.delGiorno(g,
          lat: luogo.lat, lon: luogo.lon, offset: offsetDiRoma)!;
      // Contro l'alba del JPL (skyfield, DE421) al secondo.
      final jplAlba = DateTime.parse('${c[1]}T${c[4]}Z').subtract(offsetDiRoma);
      final jplTram = DateTime.parse('${c[1]}T${c[5]}Z').subtract(offsetDiRoma);
      for (final s in [
        e.alba.difference(jplAlba).inMilliseconds.abs() / 1000,
        e.tramonto.difference(jplTram).inMilliseconds.abs() / 1000,
      ]) {
        if (s > scartoMassimo) scartoMassimo = s;
      }
      final rk = LaLetturaVedica.rahuKalam(g, luogo, offset: offsetDiRoma)!;
      for (final (mio, suo) in [(hm(rk.$1), c[12]), (hm(rk.$2), c[13])]) {
        estremi++;
        if (mio != suo) diversi.add('${c[0]} ${c[1]}: $mio, Drik $suo');
      }
    }
    print('ORDINE ES VOCE 09: estremi del Rahu Kalam diversi da Drik '
        '${diversi.length} su $estremi; alba e tramonto, scarto massimo dal '
        'JPL ${scartoMassimo.toStringAsFixed(1)} secondi');
    expect(diversi, isEmpty, reason: diversi.join('\n'));
    expect(scartoMassimo, lessThan(20));
  });

  test('Chandra Bala e Tara Bala della regola', () {
    // Raman, Muhurtha III: nato in Ashvini, giorno in Shravana, conto 22,
    // resto 4, Kshema.
    expect(LaLetturaVedica.tara(0, 21), 4);
    expect(LaLetturaVedica.tara(5, 5), 1);
    expect(LaLetturaVedica.tara(0, 26), 9);
    expect(LaLetturaVedica.casa(6, 6), 1);
    expect(LaLetturaVedica.casa(6, 1), 8);
    const case_ = {
      1: EsitoVedico.favorevole, 2: EsitoVedico.attenzione, //
      3: EsitoVedico.favorevole, 4: EsitoVedico.sfavorevole,
      5: EsitoVedico.attenzione, 6: EsitoVedico.favorevole,
      7: EsitoVedico.favorevole, 8: EsitoVedico.ottava,
      9: EsitoVedico.attenzione, 10: EsitoVedico.favorevole,
      11: EsitoVedico.favorevole, 12: EsitoVedico.sfavorevole,
    };
    for (final e in case_.entries) {
      expect(LaLetturaVedica.esitoDellaCasa(e.key), e.value, reason: 'casa');
    }
    const tare = [
      EsitoVedico.attenzione,
      EsitoVedico.favorevole,
      EsitoVedico.sfavorevole,
      EsitoVedico.favorevole,
      EsitoVedico.attenzione,
      EsitoVedico.favorevole,
      EsitoVedico.sfavorevole,
      EsitoVedico.favorevole,
      EsitoVedico.favorevole,
    ];
    for (var t = 1; t <= 9; t++) {
      expect(LaLetturaVedica.esitoDellaTara(t), tare[t - 1], reason: 'tara');
    }
    // Il livello della Generale, scritto qui e non riletto dal codice.
    expect(LaLetturaVedica.livelloDelGiorno(EsitoVedico.favorevole, 2), 5);
    expect(LaLetturaVedica.livelloDelGiorno(EsitoVedico.favorevole, 1), 4);
    expect(LaLetturaVedica.livelloDelGiorno(EsitoVedico.favorevole, 3), 3);
    expect(LaLetturaVedica.livelloDelGiorno(EsitoVedico.sfavorevole, 3), 2);
    expect(LaLetturaVedica.livelloDelGiorno(EsitoVedico.ottava, 2), 2);
    expect(LaLetturaVedica.livelloDelGiorno(EsitoVedico.favorevole, 7), 2);
    expect(LaLetturaVedica.livelloDelGiorno(EsitoVedico.attenzione, null), 3);
  });

  // Le nascite delle prove delle schede: con l'ora (stella nota) e senza.
  final conOra = NascitaDeiSegni(
      locale: DateTime(1990, 3, 15, 8, 30), oraNota: true, fuso: 'Europe/Rome');

  test('ogni scheda dice la frase del suo gruppo, e il ritorno cambia frase',
      () {
    RegExp gruppo(List<String> varianti) => RegExp(varianti
        .map((v) => RegExp.escape(v)
            .replaceAll(RegExp(r'\\\{\w+\\\}'), '.+?')
            .replaceAll(RegExp(r'\\\[[^\]]*\\\]'), '.+?'))
        .join('|'));
    int? quale(String testo, List<String> varianti) {
      for (var i = 0; i < varianti.length; i++) {
        if (gruppo([varianti[i]]).hasMatch(testo)) return i;
      }
      return null;
    }

    final roma = citta['Roma']!;
    final fuori = <String>[];
    final difetti = <String>[];
    var schede = 0;
    var ritorni = 0;
    var uguali = 0;
    final ultima = <String, int>{};
    final (rashiN, nakN) = LaLetturaVedica.lunaDiNascita(conOra)!;
    for (var k = 0; k < 120; k++) {
      final adesso = DateTime(2026, 9, 1 + k, 9);
      final s = LaLetturaVedica.schede(
          adesso: adesso,
          nascita: conOra,
          luogo: roma,
          forma: CourtesyForm.unknown)!;
      final (r, n) = LaLetturaVedica.lunaAlle(
          LaLetturaVedica.istanteDelGiorno(DateTime(2026, 9, 1 + k), roma));
      // La regola scritta qui, non riletta dal codice: dalla Luna di nascita
      // alla Luna di oggi, il segno di partenza compreso; la tara a gruppi di
      // nove.
      final h = (r - rashiN + 12) % 12 + 1;
      final t = ((n - nakN! + 27) % 27) % 9 + 1;
      final g = OroscopoVedicoData.chandraBala[h - 1];
      if (!gruppo(g).hasMatch(s[0].text)) fuori.add('generale $k');
      final ga = OroscopoVedicoData.amore[h - 1];
      if (!gruppo(ga).hasMatch(s[1].text)) fuori.add('amore $k');
      if (!gruppo(OroscopoVedicoData.lavoro[h - 1]).hasMatch(s[2].text)) {
        fuori.add('lavoro $k');
      }
      if (!gruppo(OroscopoVedicoData.fortuna[h - 1]).hasMatch(s[3].text)) {
        fuori.add('fortuna $k');
      }
      if (!gruppo(OroscopoVedicoData.taraBala[t - 1]).hasMatch(s[0].text)) {
        fuori.add('tara $k');
      }
      // Il ritorno dello stesso caso: la casa della Luna e la tara.
      for (final (cosa, varianti) in [
        ('casa $h', g),
        ('tara $t', OroscopoVedicoData.taraBala[t - 1]),
      ]) {
        final v = quale(s[0].text, varianti);
        if (ultima.containsKey(cosa)) {
          ritorni++;
          if (ultima[cosa] == v) uguali++;
        }
        ultima[cosa] = v!;
      }
      for (final c in s) {
        schede++;
        for (final testo in [c.text, c.title, c.rigaDelLivello!]) {
          if (RegExp(r"[{}\[\]]|, e |  | \.|\.\.|—|\b[Dd]i (il|la|lo|l')\b")
              .hasMatch(testo)) {
            difetti.add(testo);
          }
        }
      }
    }
    cardinaleMinimo(schede, 480, cosa: 'schede vediche');
    print('ORDINE ES VOCE 09: schede fuori dal loro gruppo ${fuori.length} su '
        '$schede; stessa frase al ritorno dello stesso caso $uguali su '
        '$ritorni; testi con un difetto di scrittura ${difetti.length}');
    expect(fuori, isEmpty, reason: fuori.take(6).join('\n'));
    expect(uguali, 0);
    expect(difetti, isEmpty, reason: difetti.take(4).join('\n'));
  });

  test('senza l\'ora la Generale lo dice; senza la citta\' il Rahu la chiede',
      () {
    final senzaOra = NascitaDeiSegni(
        locale: DateTime(1990, 3, 15, 12), oraNota: false, fuso: 'Europe/Rome');
    final s = LaLetturaVedica.schede(
        adesso: DateTime(2026, 10, 5, 9), nascita: senzaOra)!;
    expect(
        s[0].text, contains('Con l\'ora di nascita leggo anche la tua stella'));
    expect(
        OroscopoVedicoData.rahuSenzaCitta
            .any((f) => s[0].text.contains(f.substring(0, 30))),
        isTrue,
        reason: s[0].text);
    // Breve e Approfondita diverse su tutte e quattro le schede.
    final prof = LaLetturaVedica.schede(
        adesso: DateTime(2026, 10, 5, 9),
        nascita: conOra,
        luogo: citta['Roma'],
        approfondite: {for (final d in HoroscopeDomain.values) d: true})!;
    final breve = LaLetturaVedica.schede(
        adesso: DateTime(2026, 10, 5, 9),
        nascita: conOra,
        luogo: citta['Roma'])!;
    for (var i = 0; i < 4; i++) {
      expect(prof[i].text, isNot(breve[i].text), reason: '$i');
    }
    // Il Rahu Kalam di Roma del 5 ottobre, lunedi': 08:38-10:05 (Drik); alle
    // nove e' in corso.
    expect(breve[0].text, contains('10:05'));
  });

  test('le frasi del codice sono quelle del corpus', () {
    final corpus = File('docs/corpus/oroscopo_vedico.md')
        .readAsStringSync()
        .replaceAll('\r\n', '\n');
    // Ogni frase numerata del corpus, riunita sulle righe rientrate.
    final dalCorpus = <String>{};
    String? corrente;
    for (final riga in corpus.split('\n')) {
      final m = RegExp(r'^\d+\.\s+(.+)$').firstMatch(riga);
      if (m != null) {
        if (corrente != null) dalCorpus.add(corrente);
        corrente = m.group(1)!.trim();
      } else if (corrente != null &&
          riga.startsWith('   ') &&
          riga.trim().isNotEmpty) {
        corrente = '$corrente ${riga.trim()}';
      } else if (corrente != null) {
        dalCorpus.add(corrente);
        corrente = null;
      }
    }
    if (corrente != null) dalCorpus.add(corrente);
    final dalCodice = {
      for (final g in OroscopoVedicoData.chandraBala) ...g,
      for (final g in OroscopoVedicoData.taraBala) ...g,
      ...OroscopoVedicoData.righeDelPianeta,
      for (final g in OroscopoVedicoData.amore) ...g,
      for (final g in OroscopoVedicoData.lavoro) ...g,
      for (final g in OroscopoVedicoData.fortuna) ...g,
      ...OroscopoVedicoData.rahuPrima,
      ...OroscopoVedicoData.rahuInCorso,
      ...OroscopoVedicoData.rahuPassato,
      ...OroscopoVedicoData.rahuSenzaCitta,
    };
    print('ORDINE ES VOCE 09: frasi del corpus ${dalCorpus.length}, del '
        'codice ${dalCodice.length}');
    cardinaleMinimo(dalCorpus.length, 142, cosa: 'frasi del corpus vedico');
    expect(dalCodice, dalCorpus,
        reason: 'rigenerare con python tool/_gen_oroscopo_vedico.py');
  });
}
