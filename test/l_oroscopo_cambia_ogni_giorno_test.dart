// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/horoscope/horoscope.dart';
import 'package:esoteric_circle/core/tempo/confine_del_giorno.dart';
import 'package:flutter_test/flutter_test.dart';

/// **L'OROSCOPO CAMBIA OGNI GIORNO IN TUTTE LE SUE PARTI.** Ordine ER voce
/// 14, 27 settembre 2026.
///
/// Domanda girata al fondatore: *"Ci metto anche l'Oroscopo (la prima metà
/// delle schede, oggi uguale tutti i giorni)?"*, risposta: *"Sì, con
/// l'Oroscopo"*.
///
/// **Le grandezze misurate**: per ognuno dei sei passaggi di giorno di una
/// settimana, quante delle 48 schede (12 segni per 4 domini) hanno il titolo
/// identico al giorno prima, e quante la prima parte; la stessa misura su
/// tutti i passaggi di un anno, capodanno compreso. La prima parte e' anche
/// la frase della card da condividere (`synthesis`).
void main() {
  List<HoroscopeCard> schede(Zodiac s, DateTime giorno) => Horoscope.forSign(
        sign: s,
        dayOfYear: ConfineDelGiorno.giornoDellAnno(giorno),
        year: giorno.year,
      );

  test(
      'ER.14: sette giorni di fila, nessun titolo e nessuna prima parte '
      'uguale al giorno prima', () {
    final inizio = DateTime(2026, 9, 27);
    final righe = <String>[
      'ORDINE ER VOCE 14: L\'OROSCOPO IN SETTE GIORNI DI FILA, 12 SEGNI PER 4 '
          'DOMINI, 27 settembre 2026',
      'Per ogni giorno, segno e dominio: la casa che la Luna attraversa, il '
          'titolo e la prima parte (che e\' anche la frase della card da '
          'condividere).',
      '',
    ];
    final titoliUguali = <int>[];
    final primeUguali = <int>[];
    Map<String, HoroscopeCard>? ieri;
    for (var g = 0; g < 7; g++) {
      // Il calendario, non le durate: al cambio dell'ora legale un giorno
      // non dura ventiquattro ore.
      final giorno = DateTime(inizio.year, inizio.month, inizio.day + g);
      final oggi = <String, HoroscopeCard>{};
      righe.add('== ${giorno.day}/${giorno.month}/${giorno.year} ==');
      for (final s in Zodiac.values) {
        final casa = Horoscope.casaDellaLuna(
                s, ConfineDelGiorno.giornoDellAnno(giorno), giorno.year) +
            1;
        for (final c in schede(s, giorno)) {
          oggi['${s.id}/${c.domain.name}'] = c;
          expect(c.text.startsWith(c.synthesis), isTrue,
              reason: 'la prima parte non apre il testo');
          righe.add(
              '${s.italianName.padRight(11)} ${c.domain.label.padRight(9)} '
              'casa ${casa.toString().padLeft(2)}  "${c.title}"  ${c.synthesis}');
        }
      }
      // **NELLO STESSO GIORNO I DODICI SEGNI LEGGONO DODICI SCHEDE.** Una
      // misura sul cambio di giorno resta verde anche se tutti i segni
      // leggono la stessa scheda: e' successo in questo ordine, alla prova
      // riscritta durante un innesto ("casa 1" per tutti i segni).
      // LAPIDE, EU Aggiunta, 1 ottobre 2026: qui si pretendeva che i dodici
      // segni leggessero dodici titoli diversi lo stesso giorno, perche' il
      // titolo veniva dalla casa della Luna contata dal segno. Adesso la voce
      // la sceglie la regola dell'Architetto: le fasce gia' tornate per la
      // persona piu' il suo scarto, i giorni dalla nascita. Due persone senza
      // data di nascita (scarto zero) con la stessa storia di fasce leggono
      // la stessa voce, ed e' la regola: la misura qui sotto la stampa
      // soltanto. Che una persona non rilegga una voce lo misura
      // i_testi_non_tornano_test.dart.
      if (ieri != null) {
        var t = 0, p = 0;
        for (final k in oggi.keys) {
          if (oggi[k]!.title == ieri[k]!.title) t++;
          if (oggi[k]!.synthesis == ieri[k]!.synthesis) p++;
        }
        titoliUguali.add(t);
        primeUguali.add(p);
      }
      ieri = oggi;
      righe.add('');
    }
    righe
      ..add('Schede col titolo identico al giorno prima, per passaggio di '
          'giorno: ${titoliUguali.map((n) => '$n su 48').join(', ')}.')
      ..add('Schede con la prima parte identica al giorno prima, per '
          'passaggio di giorno: ${primeUguali.map((n) => '$n su 48').join(', ')}.');
    // LAPIDE, EU Aggiunta: la prova dell'ordine ER non si riscrive piu', e'
    // la fotografia dei testi di allora.
    expect(righe, isNotEmpty);
    print('ORDINE ER VOCE 14: titoli uguali al giorno prima $titoliUguali, '
        'prime parti uguali $primeUguali');
    expect(titoliUguali, hasLength(6));
    expect(titoliUguali.every((n) => n == 0), isTrue);
    expect(primeUguali.every((n) => n == 0), isTrue);
  });

  test(
      'ER.14: un anno intero, capodanno compreso, e lo stesso giorno resta '
      'lo stesso', () {
    var passaggi = 0, uguali = 0;
    final vistiTitoli = <String>{};
    for (var g = 0; g < 366; g++) {
      final giorno = DateTime(2026, 6, 1 + g);
      final prima = DateTime(2026, 6, g);
      for (final s in Zodiac.values) {
        final a = schede(s, prima);
        final b = schede(s, giorno);
        for (var d = 0; d < 4; d++) {
          passaggi++;
          vistiTitoli.add(b[d].title);
          if (a[d].title == b[d].title || a[d].synthesis == b[d].synthesis) {
            uguali++;
          }
        }
      }
    }
    // Lo stesso giorno, due volte: la stessa scheda (ordine BK voce 06).
    final x = schede(Zodiac.leo, DateTime(2026, 9, 27));
    final y = schede(Zodiac.leo, DateTime(2026, 9, 27, 23, 59));
    print('ORDINE ER VOCE 14: passaggi di giorno in un anno $passaggi, con '
        'titolo o prima parte uguali $uguali; titoli diversi usati '
        '${vistiTitoli.length}');
    expect(passaggi, greaterThanOrEqualTo(12 * 4 * 365));
    expect(uguali, 0);
    expect([for (final c in x) c.text], [for (final c in y) c.text],
        reason: 'nello stesso giorno la scheda cambia');
    expect(vistiTitoli.length, greaterThanOrEqualTo(100),
        reason: 'in un anno si usano pochi titoli: il giorno non sceglie');
  });
}
