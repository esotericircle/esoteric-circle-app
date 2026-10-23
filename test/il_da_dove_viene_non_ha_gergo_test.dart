// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/horoscope/i_testi_eu.dart';
import 'package:esoteric_circle/core/horoscope/il_lessico_del_cielo.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'oroscopo_eu_comune.dart';

/// **IL "DA DOVE VIENE" NON HA GERGO, E NON E' UN MURO.** Ordine GA voce
/// GA.06, sesto e ultimo giro per questo difetto, 21 ottobre 2026.
///
/// Il fondatore: *"Le risposte vanno curate, sono la parte più importante e
/// criticata dell'app."* Due letture cieche indipendenti sul "Da dove viene"
/// hanno dato D3 sei su dodici e tre su dodici. La quinta cura aveva messo la
/// spiegazione accanto al termine, e non bastava: allungava il testo, e il
/// lettore trovava muri (114 parole), frasi vuote ("il segno che conta per
/// questo campo") e gergo rimasto ("trigono", "casa cadente", "le Sette
/// Uccisioni", "scelto dal suo reggente", "Cipride", "Inno orfico").
///
/// **La forma**, come la direbbe un amico che sa leggere il cielo:
/// - il CORPO, prima riga: due frasi nella Breve, tre nella Lunga, che dicono
///   che cosa fa il cielo e che cosa vuol dire per il campo, senza nessun
///   termine tecnico;
/// - nella Lunga, la riga breve del rito: "Il rito del giorno: ...", senza
///   nomi di dei o di scuole;
/// - in coda, su una riga separata e una sola volta, "Fonte: ...", con la
///   tradizione e la scuola, e al piu' un termine tecnico.
///
/// **Si leggono i "Da dove viene" veri** di dodici persone, nelle tre
/// tradizioni, nei quattro periodi, nei quattro domini, in Breve e in Lunga.
/// Il corpo deve inoltre dire il giudizio della scheda (favorevole,
/// equilibrio, salita) e non nominare "oggi" in una settimana, in un mese o
/// in un anno.
void main() {
  // Nel corpo e nel rito: niente di tutto questo.
  final vietate = RegExp(
      r'\bquadratur|\btrigon|\bsestil|\bopposizion|\bcongiunzion|'
      r'\b(\d+|prima|seconda|terza|quarta|quinta|sesta|settima|ottava|nona|'
      r'decima|undicesima|dodicesima)\s+casa\b|\bcase\b|'
      r'\bcasa\s+(\d+|solare|angolare|succedente|cadente|dal)|'
      r'\bangolar|\bsuccedent|\bcadent|Ascendente|Medio Cielo|'
      r'Rivoluzione Solare|\btar[ae]\b|Naidhana|Chandra Bala|Tara Bala|'
      r'Chandrashtama|Sade Sati|Rahu Kalam|BaZi|Sette Uccisioni|\bRivale\b|'
      r'\bUfficial|\bRicchezza|\bCompagno\b|\bNutrimento\b|\bSigill|'
      r'Tai Sui|Tong Shu|\bMithuna|\bMesha|\bVrishabha|\bKarka|\bSimha|'
      r'\bKanya|\bTula\b|\bVrishchika|\bDhanu|\bMakara|\bKumbha|\bMina\b|'
      r'reggente|Inno orfico|Ficino|Cipride|Lieo|Demetra|Afrodite|Dioniso|'
      r'gli dei|\bi dei\b|\bdio\b|polarità|elemento di nascita|\bramo\b|\brami\b|'
      r'\bterna\b|\bterne\b|\bBaZi\b|\bgraha\b|\bnakshatra\b|\bayanamsa\b|'
      // Micro-giro GA.06: le fasi della Luna dette in parole, la gabbia "e'
      // la media dei suoi giorni", il rito detto "per il giorno" di un anno.
      r'calante a metà|crescente a metà|è la media dei suoi|'
      r'per il giorno che');

  // Le frasi che non dicono niente.
  final vuote = RegExp(r'conta per questo campo|lo mette in primo piano|'
      r'segno che conta|scelto dal suo|il segno che per la tradizione indiana '
      r'conta|: lì resta sullo sfondo|perché c.è intensità, fra');

  // I termini che la riga Fonte puo' portare, al massimo uno.
  final tecniciDellaFonte = RegExp(r'BaZi|Tong Shu|Sade Sati|gochara');

  final giorni = [
    DateTime(2026, 9, 3),
    DateTime(2026, 10, 14),
    DateTime(2026, 10, 25),
    DateTime(2026, 11, 8),
    DateTime(2026, 12, 19),
    DateTime(2027, 1, 27),
  ];
  final perPeriodo = [DateTime(2026, 10, 20), DateTime(2026, 11, 22)];

  test(
      'il corpo e\' breve e senza gergo, il rito e la fonte hanno la loro riga',
      () {
    // (chi, periodo, lunga, livello, riga)
    final righe = <(String, PeriodoEu, bool, int, String)>[];
    void aggiungi(
        String chi, PeriodoEu per, bool lunga, int livello, String? riga) {
      if (riga != null && riga.trim().isNotEmpty) {
        righe.add((chi, per, lunga, livello, riga));
      }
    }

    for (final p in dodiciPersone) {
      for (final t in TradizioneEu.values) {
        if (!p.legge(t)) continue;
        for (final lunga in [false, true]) {
          for (final g in giorni) {
            for (final c in p.giorno(t, g, lunga: lunga)) {
              aggiungi(
                  '${p.nome} ${t.name} giorno ${c.domain.name} $g',
                  PeriodoEu.giorno,
                  lunga,
                  c.indicator,
                  c.responso?.daDoveViene);
            }
          }
          if (t != TradizioneEu.occidentale || p.conCarta) {
            for (final g in perPeriodo) {
              for (final c in p.anno(t, g, lunga: lunga)) {
                aggiungi(
                    '${p.nome} ${t.name} anno ${c.domain.name} $g',
                    PeriodoEu.anno,
                    lunga,
                    c.indicator,
                    c.responso?.daDoveViene);
              }
            }
          }
        }
      }
    }
    // Settimana e Mese: piu' costosi, una persona su tre.
    for (var i = 0; i < dodiciPersone.length; i += 3) {
      final p = dodiciPersone[i];
      for (final t in TradizioneEu.values) {
        if (!p.legge(t)) continue;
        for (final mese in [false, true]) {
          final per = p.periodo(t, perPeriodo[mese ? 1 : 0], mese: mese);
          for (final dom in per.domini) {
            for (final lunga in [false, true]) {
              aggiungi(
                  '${p.nome} ${t.name} ${mese ? 'mese' : 'settimana'} '
                  '${dom.dominio.name}',
                  mese ? PeriodoEu.mese : PeriodoEu.settimana,
                  lunga,
                  dom.livello,
                  dom.responso(t, mese: mese, lunga: lunga).daDoveViene);
            }
          }
        }
      }
    }

    final difetti = <String>[];
    var piuLungoBreve = 0;
    var piuLungoLunga = 0;
    var frasiMax = 0;
    var conRito = 0;
    for (final (chi, per, lunga, livello, riga) in righe) {
      final linee = riga.split('\n');
      final corpo = linee.first;
      final fonti = linee.where((l) => l.startsWith('Fonte: ')).toList();
      final riti = linee.where((l) => l.startsWith('Il rito ')).toList();
      if (fonti.length != 1 || linee.last != fonti.first) {
        difetti.add('$chi: la riga Fonte non e\' una, in coda');
        continue;
      }
      if (!fonti.first.startsWith('Fonte: astrologia ') ||
          tecniciDellaFonte.allMatches(fonti.first).length > 1) {
        difetti.add('$chi: la Fonte e\' mal fatta: ${fonti.first}');
      }
      if (lunga && riti.length != 1) {
        // Una Lunga senza rito (nessuno scelto) non e' un difetto di qui.
      }
      if (!lunga && riti.isNotEmpty) {
        difetti.add('$chi: il rito nella Breve');
      }
      conRito += riti.length;
      for (final r in riti) {
        if (!RegExp(
                r"^Il rito (del giorno|della settimana|del mese|dell'anno): ")
            .hasMatch(r)) {
          difetti.add('$chi: il rito non ha la sua forma: $r');
        }
      }
      // Il corpo e il rito: niente gergo, niente frasi vuote.
      for (final testo in [corpo, ...riti]) {
        final v = vietate.firstMatch(testo);
        if (v != null) difetti.add('$chi: «${v.group(0)}» in «$testo»');
        final e = vuote.firstMatch(testo);
        if (e != null) difetti.add('$chi: frase vuota «${e.group(0)}»');
      }
      // Quante frasi e quante parole: due nella Breve, tre nella Lunga.
      final frasi = corpo
          .split(RegExp(r'(?<=[.!?])\s+'))
          .where((f) => f.trim().isNotEmpty)
          .length;
      final parole = corpo.trim().split(RegExp(r'\s+')).length;
      if (frasi > frasiMax) frasiMax = frasi;
      if (lunga) {
        if (parole > piuLungoLunga) piuLungoLunga = parole;
      } else {
        if (parole > piuLungoBreve) piuLungoBreve = parole;
      }
      if (frasi > (lunga ? 3 : 2)) {
        difetti
            .add('$chi: $frasi frasi nel corpo ${lunga ? 'Lungo' : 'Breve'}');
      }
      if (parole > (lunga ? 66 : 56)) {
        difetti
            .add('$chi: $parole parole nel corpo ${lunga ? 'Lungo' : 'Breve'}');
      }
      // Il giudizio dice quello che dice la scheda.
      final atteso = livello >= 4
          ? RegExp(r'favorevole')
          : livello == 3
              ? RegExp(r'in equilibrio|neutro')
              : RegExp(r'in salita|contrastato|più leggero|chiede impegno');
      if (!atteso.hasMatch(corpo)) {
        difetti.add('$chi: il corpo non dice il giudizio del livello '
            '$livello (${IlLessicoDelCielo.giudizio(livello)}): «$corpo»');
      }
      // La coerenza con la fascia: un cielo in equilibrio non "ti sostiene" e
      // non "ti mette alla prova", un cielo favorevole non mette alla prova,
      // un cielo in salita non sostiene.
      final stonata = livello >= 4
          ? RegExp(r'alla prova|in salita|contrastato')
          : livello == 3
              ? RegExp(r'ti sostiene|ti sostengono|alla prova|in salita')
              : RegExp(r'ti sostiene|ti sostengono');
      final s = stonata.firstMatch(corpo);
      if (s != null) {
        difetti
            .add('$chi: «${s.group(0)}» sotto il livello $livello: «$corpo»');
      }
      // Il periodo giusto: mai "oggi" o "la tua giornata" fuori dal Giorno.
      if (per != PeriodoEu.giorno &&
          RegExp(r'\boggi\b|di oggi|della tua giornata', caseSensitive: false)
              .hasMatch(corpo)) {
        difetti.add('$chi: parla di oggi in un periodo: «$corpo»');
      }
    }
    cardinaleMinimo(righe.length, 1200, cosa: 'righe del "Da dove viene"');
    cardinaleMinimo(conRito, 300, cosa: 'righe del rito');
    print('GA.06 giro 6: righe lette ${righe.length}, con la riga del rito '
        '$conRito, difetti ${difetti.length}; il corpo piu lungo: Breve '
        '$piuLungoBreve parole, Lunga $piuLungoLunga; frasi al massimo '
        '$frasiMax');
    // Per genere di difetto (senza chi e senza il testo), per leggere in una
    // riga che cosa e' rotto e non solo i primi trenta.
    final generi = <String, int>{};
    for (final d in difetti) {
      final dopo = d.substring(d.indexOf(': ') + 2);
      final genere = dopo.length > 40 ? dopo.substring(0, 40) : dopo;
      generi[genere] = (generi[genere] ?? 0) + 1;
    }
    generi.forEach((g, n) => print('  GENERE: $n x $g'));
    for (final d in difetti.take(12)) {
      print('  DIFETTO: $d');
    }
    expect(difetti, isEmpty, reason: difetti.take(6).join('\n'));
  }, timeout: const Timeout(Duration(minutes: 25)));
}
