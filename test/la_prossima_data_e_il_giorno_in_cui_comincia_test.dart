// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/sigilli/eventi_del_cielo.dart';
import 'package:esoteric_circle/core/astro/prossimi_eventi.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:flutter_test/flutter_test.dart';

/// **LA PROSSIMA DATA E' IL GIORNO IN CUI L'EVENTO COMINCIA, misurato ora per
/// ora.** Ordine DS voce 08, 17 settembre 2026.
///
/// **Il fatto.** Sulle catture di un fondatore, Medora ha detto *"la Luna che
/// si prepara a transitare nel segno opposto fra tre giorni"* e *"il Primo
/// Quarto che si avvicina"*. Il fondatore sospettava un'invenzione del
/// modello. **Non lo era**: le due frasi venivano dal blocco calcolato che
/// arriva al modello, e quel blocco diceva *"Primo quarto: fra 2 giorni"* e
/// *"La Luna nel segno opposto: fra 3 giorni"*. **Ed era sbagliato di un
/// giorno tutte e due le volte.** Il 17 settembre 2026 il Primo quarto
/// comincia il 18 alle 10 e la Luna entra in Capricorno il 19 alle 8.
///
/// **La causa.** Il motore guarda il cielo a mezzanotte di ogni giorno. Un
/// evento che comincia alle 10 del 18 lo vede a mezzanotte del 19, e lo data
/// al 19. Per i solstizi e le stazioni la correzione del giorno prima c'era
/// gia' (ordine AN voce 01), ma la ragione vale per ogni evento: cio' che a
/// una mezzanotte c'e' e a quella prima non c'era e' cominciato nel giorno di
/// mezzo.
///
/// **La misura.** La prova precedente chiedeva che il motore di oggi vedesse
/// l'evento nel giorno indicato, e una data in ritardo di un giorno la
/// passava lo stesso. Questa guarda il cielo **ogni ora** e pretende che la
/// prima ora in cui l'evento e' attivo cada nel giorno che la data dice.
void main() {
  /// Gli eventi della Luna, che cominciano a qualunque ora del giorno.
  const dellaLuna = <String>{
    EventiDelCielo.lunaNelTuoSegno,
    EventiDelCielo.lunaNelSegnoOpposto,
    EventiDelCielo.lunaPiena,
    EventiDelCielo.lunaNuova,
    EventiDelCielo.primoQuarto,
    EventiDelCielo.ultimoQuarto,
  };

  bool attivo(String evento, DateTime istante, Zodiac segno) =>
      EventiDelCielo.diOggi(adesso: istante, segno: segno).contains(evento);

  /// Il primo istante attivo: ora per ora, e dentro l'ultima ora minuto per
  /// minuto. **L'ora sola non basta**: un evento che comincia alle 23:40 si
  /// trova alle 0 del giorno dopo, e la griglia lo darebbe al giorno
  /// sbagliato. Il minuto lo rimette dove sta.
  DateTime? primoIstanteAttivo(String evento, DateTime da, Zodiac segno) {
    for (var h = 0; h <= 24 * 40; h++) {
      final ora = DateTime(da.year, da.month, da.day, da.hour + h);
      if (!attivo(evento, ora, segno)) continue;
      if (h == 0) return ora;
      for (var m = 59; m >= 0; m--) {
        final minuto = DateTime(ora.year, ora.month, ora.day, ora.hour - 1, m);
        if (!attivo(evento, minuto, segno)) {
          return minuto.add(const Duration(minutes: 1));
        }
      }
      return DateTime(ora.year, ora.month, ora.day, ora.hour - 1);
    }
    return null;
  }

  test('il caso del fondatore: il 17 settembre 2026, Sole in Cancro', () {
    final adesso = DateTime(2026, 9, 17, 0, 21);
    final elenco = ProssimiEventi.da(adesso: adesso, segno: Zodiac.cancer);
    int fra(String evento) =>
        elenco.firstWhere((e) => e.evento == evento).fraQuantiGiorni;
    print('ORDINE DS VOCE 08: ${[
      for (final e in elenco.take(6)) '${e.evento} fra ${e.fraQuantiGiorni}'
    ].join(', ')}');
    expect(fra(EventiDelCielo.primoQuarto), 1,
        reason: 'il Primo quarto comincia il 18 alle 10: dal 17 e domani');
    expect(fra(EventiDelCielo.lunaNelSegnoOpposto), 2,
        reason: 'la Luna entra in Capricorno il 19 alle 8: dal 17 e fra due '
            'giorni');
  });

  test(
      'per tre mesi, ogni evento della Luna e datato al giorno in cui '
      'comincia', () {
    final sbagliati = <String>[];
    var controllati = 0;
    for (var giorno = 0; giorno < 90; giorno += 7) {
      final adesso = DateTime(2026, 9, 1 + giorno, 0, 5);
      for (final segno in const [Zodiac.cancer, Zodiac.aries, Zodiac.libra]) {
        for (final e
            in ProssimiEventi.da(adesso: adesso, segno: segno, orizzonte: 30)) {
          if (!dellaLuna.contains(e.evento) || e.fraQuantiGiorni == 0) {
            continue;
          }
          // Si parte dalla fine del giorno prima di quello atteso: cosi' la
          // prima ora attiva trovata e' l'inizio vero, non un residuo di un
          // passaggio precedente dello stesso evento.
          final prima = DateTime(adesso.year, adesso.month,
              adesso.day + e.fraQuantiGiorni - 2, 12);
          // Se all'inizio della scansione l'evento c'e' gia', la scansione
          // non vede il suo inizio: non si conta, invece di contarlo male.
          if (attivo(e.evento, prima, segno)) continue;
          final vera = primoIstanteAttivo(e.evento, prima, segno);
          if (vera == null) continue;
          controllati++;
          final giornoVero = DateTime(vera.year, vera.month, vera.day);
          if (giornoVero != e.quando) {
            sbagliati.add('${segno.name} dal ${adesso.day}/${adesso.month}: '
                '${e.evento} datato ${e.quando.day}/${e.quando.month}, '
                'comincia ${vera.day}/${vera.month} alle ${vera.hour}:'
                '${vera.minute.toString().padLeft(2, "0")}');
          }
        }
      }
    }
    print('ORDINE DS VOCE 08: eventi della Luna misurati ora per ora '
        '$controllati, datati male ${sbagliati.length}');
    expect(controllati, greaterThan(40), reason: 'la prova gira quasi a vuoto');
    expect(sbagliati, isEmpty, reason: sbagliati.take(12).join('\n'));
  });
}
