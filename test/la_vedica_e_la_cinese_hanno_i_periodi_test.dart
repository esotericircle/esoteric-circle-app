// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/astro/meeus/il_cielo_di_meeus.dart';
import 'dart:io';

import 'package:esoteric_circle/core/horoscope/horoscope.dart';
import 'package:esoteric_circle/core/horoscope/i_segni_delle_tradizioni.dart';
import 'package:esoteric_circle/core/horoscope/i_testi_eu.dart';
import 'package:esoteric_circle/core/horoscope/l_anno_delle_tradizioni.dart';
import 'package:esoteric_circle/core/horoscope/la_lettura_vedica.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'oroscopo_eu_comune.dart';

/// **LA VEDICA E LA CINESE HANNO SETTIMANA, MESE E ANNO.** Ordine EU voce 02,
/// 1 ottobre 2026.
///
/// Il fondatore: *"manca l'oroscopo settimanale, mensile e annuale per vedica
/// e cinese, attualmente c'è solo quello giornaliero."*; sul metodo
/// dell'Architetto, *"Proposta Architetto"*.
///
/// Si misura, e si scrive in `docs/collaudo/EU/vedica_cinese_periodi.txt`:
/// - per tre persone la Settimana e il Mese di tutte e due le tradizioni,
///   col livello di ogni giorno accanto a quello del Giorno della stessa
///   data, composto a parte: i livelli diversi devono essere zero;
/// - l'anno cinese al 1 ottobre 2026 per dieci date di nascita: l'animale
///   dell'anno, il Capodanno e il Tai Sui, contro la lista pubblicata per
///   l'anno del Cavallo di fuoco (South China Morning Post, *How to appease
///   the tai sui in the Year of the Horse 2026*, e Chow Tai Fook, *2026 Year
///   of the Horse: Offending Tai Sui*: lo offendono il Cavallo, il Topo, il
///   Bue e il Coniglio);
/// - Giove e Saturno al compleanno, contati dalla Luna di nascita, per dieci
///   persone, contro il JPL DE421 (`tool/gochara_jpl.py`,
///   `docs/collaudo/EU/gochara_jpl.csv`).
void main() {
  test('Settimana, Mese e Anno della Vedica e della Cinese', () {
    final righe = <String>[
      'ORDINE EU VOCE 02, LA SETTIMANA, IL MESE E L\'ANNO DELLA VEDICA E '
          'DELLA CINESE, 1 ottobre 2026.',
      '',
    ];
    final diversi = <String>[];
    var giorni = 0;
    // 1. I livelli dei giorni del periodo contro il Giorno di quella data.
    righe.add('1. LIVELLI DEI GIORNI DEL PERIODO E DEL GIORNO DELLA STESSA '
        'DATA (periodo / Giorno)');
    final oggi = DateTime(2026, 10, 1);
    for (final persona in dodiciPersone.where((p) => p.rashi != null).take(3)) {
      for (final t in [TradizioneEu.vedica, TradizioneEu.cinese]) {
        for (final mese in [false, true]) {
          final p = persona.periodo(t, oggi, mese: mese);
          for (final d in p.domini) {
            final pezzi = <String>[];
            for (final g in d.giorni) {
              giorni++;
              final delGiorno = persona
                  .giorno(t, g.giorno, lunga: false)
                  .firstWhere((c) => c.domain == d.dominio);
              pezzi.add('${g.livello}/${delGiorno.indicator}');
              if (g.livello != delGiorno.indicator ||
                  g.titolo != delGiorno.title) {
                diversi.add('${persona.nome} ${t.name} ${d.dominio.label} '
                    '${g.giorno}');
              }
            }
            if (d.dominio == HoroscopeDomain.generale ||
                d.dominio == HoroscopeDomain.amore) {
              righe.add('${persona.nome}, ${t.name}, '
                  '${mese ? 'Mese' : 'Settimana'}, ${d.dominio.label}: '
                  '${pezzi.join(' ')}');
            }
          }
        }
      }
    }
    righe.add('Giorni dei periodi col livello o il titolo diverso dal Giorno '
        'della stessa data: ${diversi.length} su $giorni.');
    righe.add('');

    // 2. L'anno cinese e il Tai Sui contro la lista pubblicata del 2026.
    righe.add('2. L\'ANNO CINESE AL 1 OTTOBRE 2026 E IL TAI SUI');
    const offendono = {6, 0, 1, 3}; // Cavallo, Topo, Bue, Coniglio
    final cinesiDiversi = <String>[];
    final nascite = [
      for (var i = 0; i < 10; i++) DateTime(1960 + i * 5, 3 + i % 9, 10 + i),
    ];
    for (final n in nascite) {
      final animale = ISegniDelleTradizioni.cinese(
              NascitaDeiSegni(locale: n, oraNota: false, fuso: 'Europe/Rome'))
          .animale!;
      final anno =
          LAnnoDelleTradizioni.cinese(oggi, animale, annoDiNascita: n.year)!;
      final offeso = LAnnoDelleTradizioni.taiSui(animale, 6) != null;
      final atteso = offendono.contains(animale);
      final nome = ISegniDelleTradizioni.animali[animale].$1;
      righe.add('nato il ${n.day}/${n.month}/${n.year}: $nome; anno dal '
          '${anno.da.day}/${anno.da.month}/${anno.da.year} al '
          '${anno.a.day}/${anno.a.month}/${anno.a.year}; Tai Sui '
          '${offeso ? 'offeso' : 'non offeso'}, la lista pubblicata '
          '${atteso ? 'offeso' : 'non offeso'}; livelli ${anno.livelli.first}');
      if (offeso != atteso ||
          anno.da != DateTime(2026, 2, 17) ||
          anno.a != DateTime(2027, 2, 6)) {
        cinesiDiversi.add(nome);
      }
    }
    righe.add('Anni con animale, Capodanno o Tai Sui diversi dalla fonte: '
        '${cinesiDiversi.length} su ${nascite.length}.');
    righe.add('');

    // 3. Giove e Saturno contati dalla Luna di nascita, contro il JPL.
    righe.add('3. GIOVE E SATURNO AL COMPLEANNO, DALLA LUNA DI NASCITA, '
        'CONTRO IL JPL DE421');
    final jpl = File('docs/collaudo/EU/gochara_jpl.csv')
        .readAsLinesSync()
        .skip(1)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => r.split(','))
        .toList();
    final vedichiDiversi = <String>[];
    for (final r in jpl) {
      final parti = r[0].split(' ');
      final data = parti[0].split('-').map(int.parse).toList();
      final ora = parti[1].split(':').map(int.parse).toList();
      final n = DateTime(data[0], data[1], data[2], ora[0], ora[1]);
      final nascita =
          NascitaDeiSegni(locale: n, oraNota: true, fuso: 'Europe/Rome');
      final rashi = LaLetturaVedica.lunaDiNascita(nascita)!.$1;
      final anno = LAnnoDelleTradizioni.vedico(oggi, n, rashi);
      final istante =
          DateTime.utc(anno.da.year, anno.da.month, anno.da.day, 12);
      int casa(CorpoCeleste c) => LaLetturaVedica.casa(
          rashi, LAnnoDelleTradizioni.siderale(c, istante) ~/ 30);
      final giove = casa(CorpoCeleste.giove);
      final saturno = casa(CorpoCeleste.saturno);
      final dalJpl = (int.parse(r[1]), int.parse(r[4]), int.parse(r[6]));
      righe.add('${r[0]}: Luna di nascita ${ISegniDelleTradizioni.rashi[rashi]}'
          ' (JPL ${ISegniDelleTradizioni.rashi[dalJpl.$1]}); compleanno '
          '${anno.da.day}/${anno.da.month}/${anno.da.year} (JPL ${r[2]}); Giove '
          'casa $giove (JPL ${dalJpl.$2}), Saturno casa $saturno (JPL '
          '${dalJpl.$3}); livelli ${anno.livelli.join(' ')}');
      if (rashi != dalJpl.$1 || giove != dalJpl.$2 || saturno != dalJpl.$3) {
        vedichiDiversi.add(r[0]);
      }
    }
    righe.add('Persone con Giove o Saturno contati diversi dal JPL: '
        '${vedichiDiversi.length} su ${jpl.length}.');
    cardinaleMinimo(giorni, 3 * 2 * (7 + 30) * 4, cosa: 'giorni dei periodi');
    cardinaleMinimo(jpl.length, 10, cosa: 'persone del JPL');
    File('docs/collaudo/EU/vedica_cinese_periodi.txt')
        .writeAsStringSync('${righe.join('\n')}\n');
    print('ORDINE EU VOCE 02: giorni diversi dal Giorno ${diversi.length} su '
        '$giorni; anni cinesi diversi dalla fonte ${cinesiDiversi.length} su '
        '10; Giove e Saturno diversi dal JPL ${vedichiDiversi.length} su '
        '${jpl.length}');
    expect(diversi, isEmpty, reason: diversi.take(5).join('\n'));
    expect(cinesiDiversi, isEmpty, reason: cinesiDiversi.join(', '));
    expect(vedichiDiversi, isEmpty, reason: vedichiDiversi.join(', '));
  });
}
