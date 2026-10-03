import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/rituals/daily_rituals.dart';
import 'package:esoteric_circle/core/tempo/confine_del_giorno.dart';
import 'package:flutter_test/flutter_test.dart';

import 'sorgenti_di_lib.dart';

/// IL GIORNO SI CONTA DALLA PORTA, IN TUTTA L'APP. Ordine BL.
///
/// **Il difetto, e sono due.** L'app contava i giorni sottraendo due istanti
/// locali: `data.difference(DateTime(data.year)).inDays`. Quella formula
/// misura una DURATA, e con l'ora legale di mezzo una durata non fa giorni
/// interi.
///
/// Dove l'ora non era normalizzata, il numero cambiava **alle una di notte**
/// invece che a mezzanotte: per i sette mesi dell'ora legale chi apriva l'app
/// nella prima ora del giorno riceveva il giorno prima. Il punto che pesa di
/// piu' e' il Maestro del Rito dell'Alba, cioe' il primo gesto della giornata.
///
/// Dove l'ora era gia' normalizzata il difetto era un altro e non meno grave:
/// sbagliava il PASSO nei due giorni del cambio d'ora. Misurato con
/// `TZ=Europe/Rome`: il 29 e il 30 marzo 2026 davano lo stesso numero, 87,
/// quindi un giorno si ripeteva; fra il 25 e il 26 ottobre si passava da 296 a
/// 298, quindi un numero non usciva mai.
void main() {
  // ------------------------------------------------------------------
  // BL.01, la guardia strutturale: vale in QUALUNQUE fuso.
  // ------------------------------------------------------------------
  test('nessun punto di lib conta i giorni sottraendo due date', () {
    // **PERCHE' STRUTTURALE E NON NUMERICA.** Dove l'ora legale non esiste,
    // per esempio in UTC, il difetto non si manifesta affatto: una prova fatta
    // di soli numeri sarebbe verde sulla macchina che la lancia e rossa sul
    // telefono di chi usa l'app. Questa riga invece cade ovunque, ed e' la
    // ragione per cui basta UNA prova per tutti e cinque i punti.
    //
    // Sorveglia tutto `lib`, mentre la guardia dell'ordine BK sorveglia i
    // cinque file del responso: quella e' piu' stretta e resta, perche' se un
    // giorno questa venisse allargata o allentata, l'Oroscopo avrebbe ancora
    // la sua.
    final colpevoli = <String>[];
    var osservati = 0;
    for (final f in sorgentiDiLib()) {
      osservati++;
      final percorso = f.path.replaceAll(r'\', '/');
      final righe = f.readAsLinesSync();
      for (var i = 0; i < righe.length; i++) {
        final r = righe[i];
        // I COMMENTI SI SALTANO: i due punti che descrivono questo difetto lo
        // NOMINANO per spiegarlo, e accusarli vorrebbe dire pretendere che la
        // ragione di una cura non si possa scrivere accanto alla cura.
        final nudo = r.trimLeft();
        if (nudo.startsWith('//')) continue;
        if (r.contains('difference(DateTime(')) {
          colpevoli.add('$percorso:${i + 1}');
        }
      }
    }
    expect(osservati, greaterThan(100),
        reason: 'la prova non ha guardato quasi niente: se lib si e\' spostata '
            'questa riga diventa una bugia verde');
    expect(colpevoli, isEmpty,
        reason: 'questi punti contano i giorni sottraendo due istanti locali, '
            'che con l\'ora legale non fa giorni interi. Usa '
            'ConfineDelGiorno.giornoDellAnno, oppure giorniDa quando l\'origine '
            'e\' fissa.\n${colpevoli.join('\n')}');
  });

  test('la porta conta giorni di calendario, col passo sempre di uno', () {
    // I due giorni del cambio d'ora, dove la formula vecchia sbagliava il
    // passo, e un bisestile per buona misura.
    for (final primo in [
      DateTime(2026, 3, 28),
      DateTime(2026, 3, 29),
      DateTime(2026, 10, 24),
      DateTime(2026, 10, 25),
      DateTime(2028, 2, 28),
      DateTime(2026, 12, 30),
    ]) {
      final dopo = DateTime(primo.year, primo.month, primo.day + 1);
      expect(ConfineDelGiorno.giornoDellAnno(dopo),
          ConfineDelGiorno.giornoDellAnno(primo) + 1,
          reason: 'fra il ${primo.day}/${primo.month} e il giorno dopo il '
              'passo non e\' di uno: in primavera un giorno si ripete, in '
              'autunno se ne salta uno');
    }
  });

  test('e la porta non guarda l\'ora', () {
    for (final giorno in [DateTime(2026, 8, 5), DateTime(2026, 1, 5)]) {
      final atteso = ConfineDelGiorno.giornoDellAnno(giorno);
      for (var ora = 0; ora < 24; ora++) {
        expect(
            ConfineDelGiorno.giornoDellAnno(
                DateTime(giorno.year, giorno.month, giorno.day, ora, 30)),
            atteso,
            reason: 'il ${giorno.day}/${giorno.month} alle $ora:30 il numero '
                'cambia dentro il giorno');
      }
    }
  });

  test('giorniDa tiene la sua origine, e conta come giornoDellAnno', () {
    // La base fissa del 2026 non si sposta: cambia il modo di contare, mai il
    // numero di partenza, o si spostano rotazioni gia' viste dalle persone.
    expect(ConfineDelGiorno.giorniDa(DateTime(2026), DateTime(2026, 1, 1)), 0);
    expect(ConfineDelGiorno.giorniDa(DateTime(2026), DateTime(2026, 8, 5)),
        ConfineDelGiorno.giornoDellAnno(DateTime(2026, 8, 5)));
    // E attraversa gli anni, che e' la ragione per cui esiste.
    expect(
        ConfineDelGiorno.giorniDa(DateTime(2026), DateTime(2027, 1, 1)), 365);
  });

  // ------------------------------------------------------------------
  // BL.02, la prova numerica dove il comportamento SI VEDE.
  // ------------------------------------------------------------------
  group('il Maestro del Rito dell\'Alba non cambia dentro il giorno', () {
    /// **IL FUSO DEVE AVERE L'ORA LEGALE, o questa prova passa per il motivo
    /// sbagliato.** In UTC il difetto non esiste: una prova numerica verde su
    /// una macchina in UTC non dimostrerebbe niente. Qui si misura il fuso
    /// vero, confrontando lo scarto di gennaio con quello di luglio, e se
    /// l'ora legale non c'e' la prova si dichiara saltata invece di fingere.
    final conOraLegale = DateTime(2026, 1, 15).timeZoneOffset !=
        DateTime(2026, 7, 15).timeZoneOffset;

    test('lo stesso giorno civile da\' lo stesso Maestro, a ogni ora', () {
      if (!conOraLegale) {
        markTestSkipped('questo fuso non ha l\'ora legale (gennaio e luglio '
            'hanno lo stesso scarto): il difetto non si manifesta e la misura '
            'direbbe il vero per il motivo sbagliato. Lanciala con '
            'TZ=Europe/Rome. La guardia strutturale qui sopra vale comunque.');
        return;
      }
      // Dentro l'ora legale, dove la formula vecchia cambiava alle 01:00.
      final giorno = DateTime(2026, 8, 5);
      final atteso = DailyRituals.dawnMaestro(giorno);
      for (final istante in [
        DateTime(2026, 8, 5, 0, 0),
        DateTime(2026, 8, 5, 0, 59),
        DateTime(2026, 8, 5, 1, 0),
        DateTime(2026, 8, 5, 12, 0),
        DateTime(2026, 8, 5, 23, 59),
      ]) {
        expect(DailyRituals.dawnMaestro(istante), atteso,
            reason: 'alle ${istante.hour}:${istante.minute} il Rito dell\'Alba '
                'e\' di un altro Maestro: chi apre l\'app nella prima ora del '
                'giorno riceve il dono di ieri');
      }
    });

    test('e attraversando la mezzanotte il Maestro CAMBIA', () {
      if (!conOraLegale) {
        markTestSkipped('fuso senza ora legale, vedi sopra');
        return;
      }
      final ieri = DailyRituals.dawnMaestro(DateTime(2026, 8, 4, 23, 59));
      final oggi = DailyRituals.dawnMaestro(DateTime(2026, 8, 5, 0, 0));
      expect(oggi, isNot(ieri),
          reason: 'passata la mezzanotte il Rito dell\'Alba deve essere di un '
              'altro Maestro, o la rotazione non ruota');
      expect(Maestro.fixedOrder.length, greaterThan(1));
    });
  });
}
