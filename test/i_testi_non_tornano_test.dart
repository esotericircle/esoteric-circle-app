// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/horoscope/horoscope.dart';
import 'package:esoteric_circle/core/horoscope/i_testi_eu.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'oroscopo_eu_comune.dart';

/// **I TESTI NON TORNANO.** Ordine EU voce 14 ed EU Aggiunta, 1 ottobre 2026.
///
/// Il fondatore: *"IMPORTANTISSIMO: VERIFICA CHE L'INTERPRETAZIONE SIA REALE
/// E NON INVENTATA E CHE NON SIA RIPETITIVA. Voglio moltissime combinazioni in
/// modo che non ci siano ripetizioni almeno per 3 mesi"*; sulla regola
/// dell'Architetto, *"Giorno a 30, resto a 90"*.
///
/// Novanta giorni dal 1 ottobre 2026, dodici persone di segni e anni diversi,
/// sei con la carta natale e sei senza, nelle tre tradizioni, nei quattro
/// periodi e nei quattro domini, in Breve e in Lunga (la voce e' la stessa
/// per tutte e due: la Lunga aggiunge due paragrafi). Si contano:
/// - le voci del Giorno che tornano entro 30 giorni per la stessa persona,
///   tradizione e dominio: attese 0 senza carta; con la carta il numero si
///   scrive nel rapporto;
/// - le voci della Settimana, del Mese e dell'Anno che tornano entro 90
///   giorni: attese 0;
/// - le frasi uguali fra due periodi della stessa persona nello stesso
///   giorno, e le schede con un paragrafo di fascia diversa dal livello: le
///   misurano anche le guardie delle voci EU.16 ed EU.17, qui sui novanta
///   giorni.
/// La prova legge i testi dal codice, che porta i corpora carattere per
/// carattere (i_testi_eu_sono_quelli_dell_architetto_test.dart). La misura va
/// in `docs/collaudo/EU/ripetizioni_90_giorni.txt`.
void main() {
  test('in novanta giorni le voci non tornano prima del loro giro', () {
    final inizio = DateTime(2026, 10, 1);
    const quanti = 90;
    // Giorno: (persona, tradizione, dominio, titolo) -> ultimo giorno visto.
    final ultimoGiorno = <String, int>{};
    final tornateConCarta = <String>[];
    final tornateSenzaCarta = <String>[];
    // Periodi: (persona, tradizione, periodo, dominio) -> voce dell'unita'.
    final vistiPeriodi = <String, Map<String, int>>{};
    final tornatePeriodi = <String>[];
    final frasiUguali = <String>[];
    final fasciaSbagliata = <String>[];
    var giorniSchede = 0;
    for (final persona in dodiciPersone) {
      for (var k = 0; k < quanti; k++) {
        final oggi = DateTime(inizio.year, inizio.month, inizio.day + k);
        for (final t in TradizioneEu.values) {
          if (!persona.legge(t)) continue;
          final giorno = persona.giorno(t, oggi);
          final frasiDelGiorno = <String>{};
          for (final c in giorno) {
            giorniSchede++;
            final chiave = '${persona.nome}|${t.name}|${c.domain.name}|'
                '${FasciaEu.di(c.indicator).name}|${c.title}';
            final prima = ultimoGiorno[chiave];
            if (prima != null && k - prima < 30) {
              (persona.conCarta ? tornateConCarta : tornateSenzaCarta).add(
                  '${persona.nome}, ${t.name}, ${c.domain.label}: '
                  '"${c.title}" il giorno ${prima + 1} e il giorno ${k + 1}');
            }
            ultimoGiorno[chiave] = k;
            if (voceDellaScheda(t, PeriodoEu.giorno, c.domain, c.title,
                    c.text)?.$1 !=
                FasciaEu.di(c.indicator)) {
              fasciaSbagliata.add('${persona.nome} $k ${t.name} Giorno '
                  '${c.domain.label}');
            }
            frasiDelGiorno.addAll(frasiDelTesto(c.text));
          }
          // La Settimana, il Mese e l'Anno: ogni unita' nuova una volta.
          void periodo(String nome, String unita, List<(HoroscopeDomain, String,
                  String)> schede) {
            for (final (d, titolo, testo) in schede) {
              final chiave = '${persona.nome}|${t.name}|$nome|${d.name}';
              final visti = vistiPeriodi.putIfAbsent(chiave, () => {});
              final voce = '$titolo|$testo';
              final giaVisto = visti[voce];
              if (giaVisto != null && giaVisto != unita.hashCode) {
                tornatePeriodi.add('${persona.nome}, ${t.name}, $nome, '
                    '${d.label}: "$titolo" in due unita\' dei novanta giorni');
              }
              visti[voce] = unita.hashCode;
              for (final f in frasiDelTesto(testo)) {
                if (frasiDelGiorno.contains(f)) {
                  frasiUguali.add('${persona.nome} ${oggi.day}/${oggi.month} '
                      '${t.name} Giorno e $nome: "$f"');
                }
              }
            }
          }

          final numeroSettimana = ITestiEu.giorniDalloZero(oggi) ~/ 7;
          // La Settimana si apre ogni giorno sui sette che vengono, ma la sua
          // voce cambia col numero della settimana: si guarda una volta per
          // settimana, il primo giorno.
          if (k == 0 || ITestiEu.giorniDalloZero(oggi) % 7 == 0) {
            periodo('Settimana', 'S$numeroSettimana', [
              for (final d in persona.periodo(t, oggi, mese: false).domini)
                (d.dominio, d.voce.titolo, d.voce.testo(lunga: true)),
            ]);
          }
          if (k == 0 || oggi.day == 1) {
            periodo('Mese', 'M${oggi.year}-${oggi.month}', [
              for (final d in persona.periodo(t, oggi, mese: true).domini)
                (d.dominio, d.voce.titolo, d.voce.testo(lunga: true)),
            ]);
          }
          if (k % 15 == 0) {
            final anno = persona.anno(t, oggi);
            // L'unita' dell'anno: il suo numero, che la voce gia' guarda.
            periodo('Anno', 'A${anno.first.rigaDelLivello.hashCode}', [
              for (final c in anno) (c.domain, c.title, c.text),
            ]);
          }
        }
      }
    }
    // L'Occidentale e la Cinese per tutti; la Vedica per chi ha la Luna di
    // nascita.
    cardinaleMinimo(giorniSchede, 12 * quanti * 2 * 4,
        cosa: 'schede del Giorno guardate');
    final righe = <String>[
      'ORDINE EU VOCE 14, LE RIPETIZIONI IN NOVANTA GIORNI, sui corpora della '
          'EU Aggiunta. Novanta giorni dal 1 ottobre 2026, dodici persone (sei '
          'con la carta natale, sei senza), tre tradizioni, quattro periodi, '
          'quattro domini, Breve e Lunga.',
      '',
      'Voci del Giorno tornate entro 30 giorni, stessa persona, tradizione e '
          'dominio: senza carta ${tornateSenzaCarta.length}, con la carta '
          '${tornateConCarta.length}.',
      'Voci della Settimana, del Mese e dell\'Anno tornate nei 90 giorni: '
          '${tornatePeriodi.length}.',
      'Frasi uguali fra il Giorno e un altro periodo dello stesso giorno: '
          '${frasiUguali.length}.',
      'Schede del Giorno con un paragrafo di una fascia diversa dal livello: '
          '${fasciaSbagliata.length}.',
      'Schede del Giorno guardate: $giorniSchede.',
      '',
      if (tornateConCarta.isNotEmpty) ...[
        'Con la carta, le voci tornate entro 30 giorni:',
        ...tornateConCarta,
        '',
      ],
      ...tornateSenzaCarta,
      ...tornatePeriodi,
      ...frasiUguali,
      ...fasciaSbagliata,
    ];
    File('docs/collaudo/EU/ripetizioni_90_giorni.txt')
        .writeAsStringSync('${righe.join('\n')}\n');
    print(righe.take(7).join('\n'));
    expect(tornateSenzaCarta, isEmpty,
        reason: tornateSenzaCarta.take(6).join('\n'));
    expect(tornatePeriodi, isEmpty, reason: tornatePeriodi.take(6).join('\n'));
    expect(frasiUguali, isEmpty, reason: frasiUguali.take(6).join('\n'));
    expect(fasciaSbagliata, isEmpty, reason: fasciaSbagliata.take(6).join('\n'));
  });
}
